using PBMessage;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using TestSocket.socket;
using WinFrmTalk.Model;

namespace WinFrmTalk.socket
{
    // socket 核心
    class SocketCore
    {
        public delegate void ConnectEventHandler(SocketConnectionState state);
        public delegate void MessageDataHandler(ChatMessage packet);
        public delegate void ReceiptHandler(string messageId, int succeed);


        //private static object rece_lock = new object();
        //private static bool isLock = false;

        private string token;
        public string userId;
        private string ip;
        private int port;
        private Socket tcpClient;
        private ByteBuffer dataBuffer; // 消息缓冲区，用于处理粘包，半包
        private Queue<ImPacket> mSendQueue; // 发送队列
        private bool isSend;
        private int timeCount;
        private StringBuilder messageIds;
        private ConnectManager mConnectManager;
        private bool mAlive;
        private PBMessageSerializer mSerializer; // 序列化和反序列化类

        private SocketConnectionState _currtstate;

        public SocketConnectionState ConnectState
        {
            get
            {
                return _currtstate;
            }

            private set
            {
                if (_currtstate != value)
                {
                    _currtstate = value;
                    OnStateChanged?.Invoke(_currtstate);

                    if (_currtstate == SocketConnectionState.Connected)
                    {
                        mAlive = true;
                    }

                }
            }
        }

        // ping时间
        public int PingTime
        {
            set
            {
                if (mConnectManager != null)
                {
                    mConnectManager.PING_INTERVAL = value * 1000;
                }
            }
        }

        //
        // 摘要:
        //     This event just informs about the current state of the Connection
        public event ConnectEventHandler OnStateChanged;
        //public event ConnectEventHandler OnClose;

        //
        // 摘要:
        //     This event just informs about the current state of the Connection
        public event MessageDataHandler OnMessage;

        public event ReceiptHandler OnReceipt;


        public SocketCore(string ip, int port)
        {
            this.ip = ip;
            this.port = port;
            mSendQueue = new Queue<ImPacket>();
            mSerializer = new PBMessageSerializer();
            mConnectManager = new ConnectManager(this);
            mConnectManager.PING_INTERVAL = 72 * 1000;
            dataBuffer = ByteBuffer.Allocate(StateObject.BUFFER_SIZE * 2);
            messageIds = new StringBuilder();
            tcpClient = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            StartReceiptTread();
        }


        public void SetLoginUser(string token, string userId)
        {
            this.token = token;
            this.userId = userId;
        }

        public bool Authenticated() {

            return SocketConnectionState.Authenticated == ConnectState;
        }


        public void Connect()
        {
            if (ConnectState == SocketConnectionState.Disconnected)
            {
                ConnectState = SocketConnectionState.Connecting;
                //IPAddress iPAddress = IPAddress.Parse(ip);
                //IPEndPoint iP = new IPEndPoint(iPAddress, port);
                tcpClient.BeginConnect(ip, port, new AsyncCallback(OnConnectCallBack), tcpClient);
            }
            else
            {
                Console.WriteLine("现在不能连接 状态" + ConnectState);
            }
        }


        public void SendMessage(ProtoBuf.IExtensible message, short comm)
        {
            // 1.将类转成byte数组
            byte[] data = SerializerProtobuf(message);
            // 2.将数组编码成 协议包
            ImPacket packet = new ImPacket(data, comm);
            // 3.使用socket把包输出到管道
            Send(packet);
            Console.WriteLine("发送 消息" + comm);
        }

        private void Send(ImPacket packet)
        {

            if (!tcpClient.Connected)
            {
                OnSendFailed(packet);
                return;
            }

            //Console.WriteLine("cc" +tcpClient.Connected);

            if (isSend)
            {
                mSendQueue.Enqueue(packet);
            }
            else
            {
                try
                {
                    isSend = true;
                    byte[] databuff = ProBufUtils.EncodePacket(packet);
                    tcpClient.BeginSend(databuff, 0, databuff.Length, SocketFlags.None, new AsyncCallback(OnSendSuccess), null);
                    //Console.WriteLine("发送数据: " + packet.command);
                }
                catch (Exception)
                {
                    OnSendFailed(packet);
                    isSend = false;
                    if (mSendQueue.Count > 0)
                    {
                        Send(mSendQueue.Dequeue());
                    }
                }
            }
        }

        public void Disconnect(bool reconn = false)
        {

            if (!reconn)
            {
                mAlive = false;
            }

            if (tcpClient.Connected)
            {
                tcpClient.Disconnect(true);
                tcpClient.Dispose();
            }

            if (mConnectManager != null)
            {
                mConnectManager.StopPING(reconn);
            }

            tcpClient = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            ConnectState = SocketConnectionState.Disconnected;
        }

        private void Login()
        {

            if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(token))
            {
                Console.WriteLine("现在还不能登陆 请先设置 SetLoginUser ");
                return;
            }

            if (ConnectState != SocketConnectionState.Connected)
            {
                Console.WriteLine("现在还不能登陆 状态" + ConnectState);
                return;
            }

            ConnectState = SocketConnectionState.Authenticating;
            MessageHead head = new MessageHead();
            head.chatType = 1;
            head.from = userId + "/" + ShiKuManager.Resource;
            head.to = "service";
            head.messageId = Guid.NewGuid().ToString("N");

            AuthMessage auth = new AuthMessage();
            auth.token = token;
            auth.password = "";
            auth.messageHead = head;

            // 1.将类转成byte数组
            byte[] data = SerializerProtobuf(auth);
            // 2.将数组编码成 协议包
            ImPacket packet = new ImPacket(data, Command.COMMAND_AUTH_REQ);
            // 3.将包转成 byte数组发送出去
            Send(packet);
        }


        private void OnConnectCallBack(IAsyncResult ar)
        {
            Socket client = (Socket)ar.AsyncState;
            if (client.IsBound)
            {
                ConnectState = SocketConnectionState.Connected;

                Console.WriteLine("连接服务器________________________成功");

                StateObject state = new StateObject();
                state.workSocket = client;
                client.BeginReceive(state.buffer, 0, state.buffer.Length, SocketFlags.None, new AsyncCallback(OnRecvMessage), state);

                Thread.Sleep(200);
                Login();
            }
            else
            {
                client.Close();
                Disconnect(true);
                Console.WriteLine("连接服务器_______________________失败");
            }
        }

        private void OnRecvMessage(IAsyncResult ar)
        {
            try
            {
                StateObject message = (StateObject)ar.AsyncState;
                if (message == null || message.workSocket == null)
                {
                    return;
                }

                int readlenght = message.workSocket.EndReceive(ar);
                if (readlenght == 0)
                {
                    if (mAlive)
                    {
                        Console.WriteLine("被动  断开连接......");
                        Thread.Sleep(300);
                        Disconnect(true);
                        Thread.Sleep(300);
                        // 触发重连
                        if (mConnectManager != null)
                        {
                            mConnectManager.OnReceLoginMessage(false);
                        }
                    }
                    else
                    {
                        Console.WriteLine("主动  断开连接......");
                    }
                    return;
                }

                byte[] readBytes = new byte[readlenght];
                Array.Copy(message.buffer, readBytes, readlenght);

                dataBuffer.WriteBytes(readBytes, readBytes.Length);

                DecoderDataPacket();

                message.workSocket.BeginReceive(message.buffer, 0, message.buffer.Length, SocketFlags.None, new AsyncCallback(OnRecvMessage), message);
            }
            catch (Exception ex)
            {
                Console.WriteLine("RecMessage Exception: ");
                Console.WriteLine(ex.Message);
                if ((!tcpClient.Connected) && ConnectState == SocketConnectionState.Authenticated)
                {
                    ConnectState = SocketConnectionState.Disconnected;
                }
            }
        }

        private void OnSendSuccess(IAsyncResult ar)
        {
            //Console.WriteLine("发送成功: ");
            isSend = false;
            if (mSendQueue.Count > 0)
            {
                Send(mSendQueue.Dequeue());
            }
        }

        private void OnSendFailed(ImPacket packet)
        {
            Console.WriteLine("发送失败: ");

            if (packet == null)
            {
                return;
            }

            switch (packet.command)
            {
                case Command.COMMAND_AUTH_RESP: // 登录失败
                    mConnectManager.OnReceLoginMessage(false);
                    break;
                case Command.COMMAND_CHAT_REQ: // 消息发送失败
                    ChatMessage message = DeserializeProtobuf<ChatMessage>(packet.body);
                    string messageid = message.messageHead.messageId;
                    OnReceipt?.Invoke(messageid, -1);
                    break;
                case Command.COMMAND_PING_REQ:// ping消息失败
                    mConnectManager.OnRecePingMessage(0);
                    break;
            }

        }


        // 解析数据包
        private void DecoderDataPacket()
        {
            // 最少要14为才能读取到 body 长度
            if (dataBuffer.ReadableBytes() < 14)
            {
                return;
            }

            // 标记位置 
            dataBuffer.MarkReaderIndex();

            //协议版本号;
            byte version = dataBuffer.ReadByte();

            //标志位
            byte maskByte = dataBuffer.ReadByte();

            // 同步消息位
            if (ImPacket.DecodeHasSynSeq(maskByte))
            {
                //同步发送设 同步序列号;
                int synSeq = dataBuffer.ReadInt();
            }

            // 命令号
            short command = dataBuffer.ReadShort();

            // 内容长度
            int bodyLen = dataBuffer.ReadInt();

            if (bodyLen <= 0)
            {
                dataBuffer.DiscardReadBytes();
                return;
            }

            // 半包情况
            if (dataBuffer.ReadableBytes() < bodyLen)
            {
                // 退回到标记位置
                dataBuffer.ResetReaderIndex();
                return;
            }

            byte[] body = new byte[bodyLen];
            dataBuffer.ReadBytes(body, 0, bodyLen);

            ImPacket packet = new ImPacket(body, command);
            DecoderImPacket(packet);

            // 释放掉已经读过的数据
            dataBuffer.DiscardReadBytes();

            if (dataBuffer.ReadableBytes() > 14)
            {
                // 粘包情况
                DecoderDataPacket();
            }
        }

        // 解析协议包
        private void DecoderImPacket(ImPacket packet)
        {
            if (packet == null)
            {
                return;
            }

            //Console.WriteLine("DecoderImPacket  " + packet.command);

            switch (packet.command)
            {
                case Command.COMMAND_AUTH_RESP:
                    DecoderLoginData(packet);
                    break;
                case Command.COMMAND_LOGIN_CONFLICT_RESP:
                    // 被挤下线
                    Console.WriteLine("被挤下线");

                    var res = MessageBox.Show(Applicate.GetWindow<FrmMain>(), "您已在其他设备登录,请重新登录！", "其他设备登录提示");
                    ShiKuManager.ApplicationExit();
                    Application.Restart();

                    break;
                case Command.COMMAND_CHAT_REQ:
                    ChatMessage message = DeserializeProtobuf<ChatMessage>(packet.body);
                    // 发送消息回执给服务器
                    messageIds.Append(message.messageHead.messageId);
                    messageIds.Append(",");

                    // 回调外界
                    if (message.messageHead.chatType == 2 && message.fromUserId.Equals(userId))
                    {
                        // 群聊自己的消息也是回执
                        string device = message.messageHead.from.Replace(userId + "/", "");
                        if ("pc".Equals(device))
                        {
                            OnReceipt?.Invoke(message.messageHead.messageId, 1);
                            if (message.type == 26)
                            {
                                OnNotiyRece(message);
                            }
                        }
                        else
                        {
                            OnNotiyRece(message);
                        }
                    }
                    else
                    {
                        OnNotiyRece(message);
                    }

                    break;
                case Command.COMMAND_BATCH_JOIN_GROUP_RESP:

                    PullGroupMessageRespProBuf batchMsg = DeserializeProtobuf<PullGroupMessageRespProBuf>(packet.body);
                    Console.WriteLine("批量拉群离线消息 应有 " + batchMsg.count + "   实有 " + batchMsg.messageList.Count);

                    if (batchMsg.count > 100)
                    {
                        int num = Convert.ToInt32(batchMsg.count - 100);
                        int reline = new Friend() { UserId = batchMsg.jid, IsGroup = 1 }.UpdateRedNum(num);
                        // 防止消息不准的问题 这里删除消息表完美

                        double fristtime = batchMsg.messageList[0].timeSend;
                        new MessageObject() { FromId = batchMsg.jid }.DeleteMessageLow(fristtime);
                    }

                    foreach (var item in batchMsg.messageList)
                    {
                        OnNotiyRece(item);
                    }

                    break;
                case Command.COMMAND_SUCCESS:
                    CommonSuccessProBuf success = DeserializeProtobuf<CommonSuccessProBuf>(packet.body);
                    string messageid = success.messageHead.messageId;
                    OnReceipt?.Invoke(messageid, 1);
                    break;
                case Command.COMMAND_ERROR:
                    CommonErrorProBuf error = DeserializeProtobuf<CommonErrorProBuf>(packet.body);
                    if (error.code == -2)
                    {
                        HttpUtils.Instance.ShowTip("敏感词禁止发送!");
                    }
                    messageid = error.messageHead.messageId;
                    OnReceipt?.Invoke(messageid, -2);
                    break;
            }
        }


        private void OnNotiyRece(ChatMessage message)
        {
            try
            {
                // 防止界面崩溃 影响socket
                OnMessage?.Invoke(message);
            }
            catch (Exception)
            {

                throw;
            }
        }

        // 发送回执给服务器（批量）
        private void SendMessageReceipt(string msgIds)
        {
            timeCount = 0;
            MessageHead head = new MessageHead();
            head.chatType = 1;
            head.from = userId + "/" + ShiKuManager.Resource;
            head.to = "service";
            head.messageId = Guid.NewGuid().ToString("N");

            MessageReceiptStatusProBuf receipt = new MessageReceiptStatusProBuf();
            receipt.messageId = msgIds;
            receipt.status = 2;
            receipt.messageHead = head;

            // 1.将类转成byte数组
            byte[] data = SerializerProtobuf(receipt);
            // 2.将数组编码成 协议包
            ImPacket packet = new ImPacket(data, Command.COMMAND_MESSAGE_RECEIPT_REQ);
            // 3.使用socket把包输出到管道
            Send(packet);
            Console.WriteLine("发送消息回执： " + msgIds);
        }

        // 循环发送回执线程
        private void StartReceiptTread()
        {
            Task.Factory.StartNew(() =>
            {
                while (true)
                {
                    Thread.Sleep(1000);
                    timeCount++;
                    // 每隔5秒 | 消息数超过50 发一次回执
                    if (timeCount > 4 || messageIds.Length > 800)
                    {
                        if (messageIds.Length > 0)
                        {
                            messageIds.Remove(messageIds.Length - 1, 1);
                            string ids = messageIds.ToString();
                            messageIds.Clear();
                            SendMessageReceipt(ids);
                        }
                    }
                }
            });
        }

        // 收到登录消息，解析登录数据
        private void DecoderLoginData(ImPacket packet)
        {
            AuthRespMessageProBuf auth = DeserializeProtobuf<AuthRespMessageProBuf>(packet.body);

            if (auth.status == 1)
            {
                Console.WriteLine("收到登陆消息");
                if (ConnectState != SocketConnectionState.Authenticated)
                {
                    ConnectState = SocketConnectionState.Authenticated;
                }

                Console.WriteLine("登陆一登录成功设备 " + auth.resources);
                MultiDeviceManager.Instance.ChangeDeviceState(auth.resources);
                // 开始ping服务器
                mConnectManager.OnReceLoginMessage(true);
            }
            else if (auth.status == 2)
            {
                // 其他端退出登陆
                MultiDeviceManager.Instance.ChangeDeviceState(auth.resources);
            }

        }

        private byte[] SerializerProtobuf(object content)
        {
            MemoryStream memory = new MemoryStream();
            mSerializer.Serialize(memory, content);
            return memory.ToArray();
        }

        private T DeserializeProtobuf<T>(byte[] content)
        {
            MemoryStream memory = new MemoryStream(content);
            return (T)mSerializer.Deserialize(memory, null, typeof(T));
        }


        private class StateObject
        {
            public Socket workSocket = null;
            public const int BUFFER_SIZE = 1024;
            public byte[] buffer = new byte[BUFFER_SIZE];
            public StringBuilder sb = new StringBuilder();
        }
    }
}
