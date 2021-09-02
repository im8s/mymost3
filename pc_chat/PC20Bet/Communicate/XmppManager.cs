using Newtonsoft.Json;
using PBMessage;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Threading.Tasks;
using System.Timers;
using System.Windows.Forms;
using TestSocket.socket;
using WinFrmTalk.Communicate;
using WinFrmTalk.Model;
using WinFrmTalk.socket;


namespace WinFrmTalk
{
    /// <summary>
    /// Xmpp������
    /// </summary>
    internal class XmppManager
    {
        private const string SYNC_LOGIN_PASSWORD = "sync_login_password";
        private const string SYNC_PAY_PASSWORD = "sync_pay_password";
        private const string SYNC_PRIVATE_SETTINGS = "sync_private_settings";
        private const string SYNC_LABEL = "sync_label";

        private System.Timers.Timer MessageLooper = new System.Timers.Timer();
        private string mLoginUserId;

        private SocketCore mSocketCore;

        public SocketConnectionState ConnectState
        {
            get
            {
                if (mSocketCore == null)
                {
                    return SocketConnectionState.Disconnected;
                }

                return mSocketCore.ConnectState;
            }
        }

        #region ���캯��
        /// <summary>
        /// ���캯������ʼ��XmppClientConnection����
        /// </summary>
        internal XmppManager()
        {
            // ��ʼ����Ϣ����
            MessageLooper.Interval = 500; // 0.5��û����Ϣ��ȥ���½���
            MessageLooper.Elapsed += new ElapsedEventHandler(OnMessageLoop);
            MessageLooper.AutoReset = false;   //������ִ��һ�Σ�false������һֱִ��(true)��
            MessageLooper.Enabled = true;     //�Ƿ�ִ��System.Timers.Timer.Elapsed�¼���

            string ip = Applicate.URLDATA.data.XMPPHost;
            string userId = Applicate.MyAccount.userId;
            string token = Applicate.Access_Token;

            // ��ʼ�� ����ip port
            mSocketCore = new SocketCore(ip, 6666);//5666
            // ���õ�¼�û�
            mSocketCore.SetLoginUser(token, userId);
            // ����ping���ʱ�� ��
            mSocketCore.PingTime = Applicate.URLDATA.data.xmppPingTime;
            // ����socket״̬�ص�
            mSocketCore.OnStateChanged += OnSocketStateChanged;
            // �����յ���Ϣ�ص�
            mSocketCore.OnMessage += XmppCon_OnMessage;
            // ������Ϣ��ִ�ص�
            mSocketCore.OnReceipt += XmppCon_OnReceipt;
            // �������ӶϿ��ص�
            //mSocketCore.OnClose += XmppCon_OnClose;

            mSocketCore.Connect();
        }

        #endregion

        #region �����������豸��¼
        /// <summary>
        /// ������ʱ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void LoginConflict()
        {
            var res = MessageBox.Show(Applicate.GetWindow<FrmMain>(), "�����������豸��¼,�����µ�¼��", "�����豸��¼��ʾ");
            ShiKuManager.ApplicationExit();
            Application.Restart();
        }

        #endregion

        #region --------------OnXmppStateChanged----------------
        /// <summary>
        /// Xmpp����״̬�ı�ʱ 
        /// <param name="sender"></param>
        /// <param name="state"></param>
        public void OnSocketStateChanged(SocketConnectionState state)
        {
            LogUtils.Log("------OnSocketStateChanged��" + state);

            Messenger.Default.Send(state, MessageActions.XMPP_UPDATE_STATE);
            switch (state)
            {
                case SocketConnectionState.Disconnected:
                    break;
                case SocketConnectionState.Connecting:
                    break;
                case SocketConnectionState.Connected:
                    break;
                case SocketConnectionState.Authenticating:
                    break;
                case SocketConnectionState.Authenticated:
                    mLoginUserId = Applicate.MyAccount.userId;
                    // ȥ���������Ϣ�б�
                    DownChatList();
        
                    // ͬ�������豸��������
                    SyscMultiDeviceData();
                    break;
                case SocketConnectionState.LoginConflict:
                    LoginConflict();
                    break;
                default:
                    break;
            }
        }
        #endregion

        #region XMPP���ӹر�ʱ
        private void XmppCon_OnClose(SocketConnectionState state)
        {

        }

        public void Disconnect()
        {
            if (mSocketCore != null)
            {
                mSocketCore.Disconnect();
            }
        }
        #endregion

        #region �յ���Ϣ��ִ
        /// <summary>
        /// �յ���Ϣ��ִ  
        /// </summary>
        /// <param name="packet"></param>
        /// <param name="success"></param>
        public void XmppCon_OnReceipt(string messageid, int success)
        {
            if (success == 1)
            {
                XmppReceiptManager.Instance.OnReceiveReceipt(XmppReceiptManager.RECEIPT_YES, messageid);
            }
            else if (success == -2)
            {
                // ���д�
                XmppReceiptManager.Instance.OnReceiveReceipt(XmppReceiptManager.RECEIPT_ERR_DIS, messageid);
            }
            else
            {
                XmppReceiptManager.Instance.OnReceiveReceipt(XmppReceiptManager.RECEIPT_ERR, messageid);
            }
        }
        #endregion

        #region XmppCon_OnMessage���յ���Ϣ---------------------------
        /// <summary>
        /// Xmpp���յ���Ϣʱ  
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="xmppMsg"></param>
        public void XmppCon_OnMessage(ChatMessage chat)
        {
            //Э����ϢChatMessage ת���� pc��Ϣʵ��MessageObject
            MessageObject message = ToMessageObject(chat);

            Console.WriteLine("XmppCon_OnMessage " + chat.type + " ,  id" + chat.messageHead.messageId);

            // �ж��Ƿ�������Ϣ
            bool isOfflieMsg = chat.messageHead.offline;
            message.isSend = 1;//���ʹ�: �յ�����Ϣ���ǳɹ�����Ϣ

            if (message.isEncrypt > 0)
            {
                // ��Ϣ����
                if (!UIUtils.IsNull(message.content))
                {
                    DES.DecryptMessage(message, chat.timeSend);
                }

                message.isEncrypt = 0;
            }

            if (message.isGroup == 1 && isOfflieMsg)
            {
                // Ⱥ��������Ϣ
                Console.WriteLine("Ⱥ��������Ϣ");

                MsgRoamTask task = new MsgRoamTask() { userId = message.ChatJid, ownerId = message.myUserId }.QueryLastTask();

                if (task != null)
                {
                    if (task.startMsgId.Equals(message.messageId))
                    {
                        task.DeleteTask();
                    }

                    if (task.endTime == 0)
                    {
                        task.UpdateTaskEndTime(message.timeSend);
                    }
                }
            }

            if (message.type > 0)
            {
                if (message.type == kWCMessageType.EMOT_PACKAGE || message.type == kWCMessageType.CUSTOM_EMOT)
                {
                    message.type = kWCMessageType.Image;
                }

                DoMessage(message, isOfflieMsg);
            }
        }
        #endregion

        // xmpp �յ���Ϣ
        private void DoMessage(MessageObject msg, bool isOfflieMsg)
        {
            if (msg.type == kWCMessageType.IsRead)
            {
                ProcessReadMessage(msg);//�����Ѷ���Ϣ
                return;
            }

            // ��������
            if (msg.type == kWCMessageType.Typing)
            {
                if (!msg.IsMySend())
                {
                    Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);
                }

                return;
            }
            //���뽨���Ự
            if (msg.type == kWCMessageType.CustomerBuiltConnnect)
            {
                var content = "�������ǿͻ�" + msg.fromUserName + ",�ܸ���Ϊ������������ʲô������԰�����?";
                var friend = msg.GetFriend();

                ShiKuManager.SendTextMessage(friend, content);
                return;
            }
            // ˫��ɾ��
            if (msg.type == kWCMessageType.SYNC_CLEAN)
            {
                Messenger.Default.Send(msg.fromUserId, MessageActions.CLEAR_FRIEND_MSGS);
                HttpUtils.Instance.ShowTip(msg.fromUserName + " ������������������¼");
                return;
            }

            // ��ͼ
            if (msg.type == kWCMessageType.TYPE_SCREENSHOT)
            {
                HttpUtils.Instance.ShowTip(msg.fromUserName + "���ڶ������ĺ󼴷���Ϣ��ͼ");
                return;
            }

            //Ⱥ������Ϣ
            if (msg.type >= kWCMessageType.RoomMemberNameChange && msg.type <= kWCMessageType.RoomNoticeEdit)
            {
                ProcessGroupManageMessage(msg, isOfflieMsg);//����Ⱥ�Ŀ�����Ϣ
            }

            //��������֤��Ϣ
            if (msg.type >= kWCMessageType.FriendRequest && msg.type <= kWCMessageType.PhoneContactToFriend)
            {
                ProcessFriendVerifyMessage(msg);//��������֤��Ϣ
                return;
            }

            //Ⱥ�ļ���Ϣ
            if (msg.type >= kWCMessageType.RoomFileUpload && msg.type <= kWCMessageType.RoomFileDownload)
            {
                ProcessGroupFileMessage(msg);//Ⱥ�ļ���Ϣ
                return;
            }

            //����Ƶ��Ϣ
            if (msg.type >= kWCMessageType.AudioChatAsk && msg.type <= kWCMessageType.AudioMeetingSetSpeaker)
            {
                ProcessPhoneCallMessage(msg);//����Ƶ��Ϣ
                return;
            }

            // �������Ϣ������ʾ �� �ϲ�ת������һ����ͼ��
            if (msg.type >= kWCMessageType.ImageTextSingle && msg.type <= kWCMessageType.TYPE_93)
            {
                ProcessSpecialMessage(msg);//�������Ϣ������ʾ
                return;
            }

            // ���豸ͬ����Ϣ
            if (msg.type >= kWCMessageType.Device_SYNC_OTHER && msg.type <= kWCMessageType.Device_SYNC_GROUP)
            {
                if (msg.InsertData() > 0)//���ݿ�ɹ�����
                {
                    ProcessDeviceSyncMessage(msg, isOfflieMsg);//���豸ͬ����Ϣ
                }
                return;
            }

            // �˵��˼��������Ϣ
            if (msg.type >= kWCMessageType.TYPE_SECURE_REFRESH_KEY && msg.type <= kWCMessageType.TYPE_SECURE_NOTIFY_REFRESH_KEY)
            {
                /* �˵��˼��������Ϣ */
                ProcessSecureMessage(msg);
             
                return;
            }

            // ֧��ƾ֤
            if (msg.type == kWCMessageType.TYPE_PAY_CERTIFICATE)
            {
                return;
            }

            // ������Ϣ
            if (msg.type == kWCMessageType.Withdraw)
            {
                /* �˴�Ӧ�޸���Ϣ����Ϊ"xx������һ����Ϣ" */
                ProcessRecallMessage(msg);
                return;
            }
            
            // �����Ϣ
            if (msg.type == kWCMessageType.RedPacket || msg.type == kWCMessageType.TRANSFER)
            {
                if (!Applicate.ENABLE_RED_PACKAGE)//û�п������
                {
                    msg.content = msg.type == kWCMessageType.RedPacket ? "�յ���������ֻ��˲鿴" : "�յ�ת�������ֻ��˲鿴";
                    UpdateFriendLastContentTip(msg);
                    return;
                }
            }

            // ����̨ɾ����ɾ���ú����˻���
            if (msg.type == kWCMessageType.TYPE_REMOVE_ACCOUNT)
            {
                var tmpFriend = new Friend() { UserId = msg.objectId }.GetByUserId();
                // ����Ϊ��ɾ��
                tmpFriend.UpdateFriendState(tmpFriend.UserId, Friend.STATUS_26);
                // �����Ϣ��¼
                msg.FromId = tmpFriend.UserId;
                msg.ToId = msg.myUserId;
                msg.DeleteTable();
                // ֪ͨ����ˢ��
                Messenger.Default.Send(tmpFriend, MessageActions.DELETE_FRIEND);
                // ��ʾ��ʾ
                HttpUtils.Instance.ShowTip("������ɾ����" + tmpFriend.NickName);
                // �����µ�����δ������
                //Messenger.Default.Send(Friend.ID_NEW_FRIEND, FriendListLayout.NOTIFY_FRIENDLIST_UNREAD_COUNT);
                return;
            }
            //��̨ɾ������(����û�����ѹ�ϵ)
            if (msg.type == kWCMessageType.TYPE_DELETEFRIENDS)
            {
                var list = JsonConvert.DeserializeObject<Dictionary<string, object>>(msg.objectId);
                string fromUserId = UIUtils.DecodeString(list, "fromUserId");
                string fromUserName = UIUtils.DecodeString(list, "fromUserName");
                string toUserId = UIUtils.DecodeString(list, "toUserId");
                string toUserName = UIUtils.DecodeString(list, "toUserName");
                
                var tmpFriend = new Friend() { UserId = toUserId }.GetByUserId();
                // ����Ϊ��ɾ��
                tmpFriend.UpdateFriendState(tmpFriend.UserId, Friend.STATUS_26);
                // �����Ϣ��¼
                msg.FromId = tmpFriend.UserId;
                msg.ToId = msg.myUserId;
                msg.DeleteTable();
                // ֪ͨ����ˢ��
                Messenger.Default.Send(tmpFriend, MessageActions.DELETE_FRIEND);
                // ��ʾ��ʾ
                HttpUtils.Instance.ShowTip("���������������" + tmpFriend.NickName + "�ĺ��ѹ�ϵ");
                // �����µ�����δ������
                //Messenger.Default.Send(Friend.ID_NEW_FRIEND, FriendListLayout.NOTIFY_FRIENDLIST_UNREAD_COUNT);
                return;
            }
            //��̨���������
            if (msg.type == kWCMessageType.TYPE_JOINBLACKLIST)
            {
                var list = JsonConvert.DeserializeObject<Dictionary<string, object>>(msg.objectId);
                string fromUserId = UIUtils.DecodeString(list, "fromUserId");
                string fromUserName = UIUtils.DecodeString(list, "fromUserName");
                string toUserId = UIUtils.DecodeString(list, "toUserId");
                string toUserName = UIUtils.DecodeString(list, "toUserName");
                Friend friend = new Friend { UserId = toUserId }.GetByUserId();

                ShiKuManager.SendBlockfriend(friend);//�������ں�������
            }
            //�Ӻ������Ƴ�
            if (msg.type == kWCMessageType.TYPE_MOVE_BALACKLIST)
            {
                var list = JsonConvert.DeserializeObject<Dictionary<string, object>>(msg.objectId);
                string fromUserId = UIUtils.DecodeString(list, "fromUserId");
                string fromUserName = UIUtils.DecodeString(list, "fromUserName");
                string toUserId = UIUtils.DecodeString(list, "toUserId");
                string toUserName = UIUtils.DecodeString(list, "toUserName");
                Friend friend = new Friend { UserId = toUserId }.GetByUserId();

                ShiKuManager.SendCancelBlockFriendMsg(friend);//����ȡ�����ں�������
            }
            
            // �ݴ���
            if (string.IsNullOrEmpty(msg.content))
            {
                return;
            }
            
            // ���ߵ����������ͨ��Ϣ��
            if (msg.InsertData() > 0)//���ݿ�ɹ�����
            {
                msg.UpdateLastSend();
                NotifactionNormalMessage(msg);//  ֪ͨUI  //֪ͨ��ҳ���յ���Ϣ
            }
            
            // @Ⱥ��Ա��Ϣ ����Ҫ����Ϣ����֮�����ȥ���㲥
            if (msg.isGroup == 1 && msg.type == kWCMessageType.Text && (!string.IsNullOrEmpty(msg.objectId)))
            {
                Friend room = msg.GetFriend();
                if (room != null && room.IsAtMe == 0)
                {
                    if (room.UserId.Equals(msg.objectId))
                    {
                        // @ȫ���Ա
                        room.UpdateAtMeState(2);
                        LocalDataUtils.SetStringData(room.UserId + "GROUP_AT_MESSAGEID" + msg.myUserId, msg.messageId);
                        Messenger.Default.Send(room, MessageActions.ROOM_UPDATE_AT_ME);//֪ͨ����ˢ��
                    }
                    else if (msg.objectId.Contains(msg.myUserId))
                    {
                        // �ұ�@��
                        room.UpdateAtMeState(1);
                        LocalDataUtils.SetStringData(room.UserId + "GROUP_AT_MESSAGEID" + msg.myUserId, msg.messageId);
                        Messenger.Default.Send(room, MessageActions.ROOM_UPDATE_AT_ME);//֪ͨ����ˢ��
                    }
                }
            }
        }
        
        public void SendMessage(MessageObject msg)
        {
            if (!mSocketCore.Authenticated())
            {
                msg.isSend = -1;
                msg.UpdateIsSend(-1, msg.messageId);
                // ����UI��Ϣ����ʧ�ܱ�־ ��Ϣ�ѷ���ʧ�� ���� 
                Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_SEND_FAILED);
                return;
            }

            if (!HttpUtils.Instance.AvailableNetwork())
            {
                msg.isSend = -1;
                msg.UpdateIsSend(-1, msg.messageId);
                // ����UI��Ϣ����ʧ�ܱ�־ ��Ϣ�ѷ���ʧ�� ���� 
                Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_SEND_FAILED);
                return;
            }

            MessageObject chatMessage = msg.CopyMessage();

            // ��Ϣ���ܴ���
            chatMessage.isEncrypt = Applicate.MyAccount.isEncrypt;
            if (chatMessage.isEncrypt == 1 && !UIUtils.IsNull(chatMessage.content))
            {
                if (!UIUtils.IsNull(chatMessage.content))
                {
                    DES.EncryptMessage(chatMessage, Convert.ToInt64(msg.timeSend * 1000));
                }
                else
                {
                    chatMessage.isEncrypt = 0;
                }
            }
            else
            {
                chatMessage.isEncrypt = 0;
            }

            // �Ƿ��Ƿ����ҵ��豸����Ϣ
            if (msg.toUserId.Equals("android") || msg.toUserId.Equals("ios") || msg.toUserId.Equals("web") || msg.toUserId.Equals("mac"))
            {
                chatMessage.toUserName = msg.toUserId;
                chatMessage.toUserId = msg.fromUserId;
            }

            // �޸�����bug # 8033
            if (chatMessage.type == kWCMessageType.File)
            {
                chatMessage.fileName = FileUtils.GetFileName(chatMessage.fileName);
            }

            ChatMessage chat = ToChatMessage(chatMessage);
            // ��ӵ���ִ������
            XmppReceiptManager.Instance.AddWillSendMessage(msg);
            mSocketCore.SendMessage(chat, Command.COMMAND_CHAT_REQ);
            Console.WriteLine("������Ϣ" + chat.content);
        }


        #region ========================================================��Ϣ����ģ��=================================================
        /// <summary>
        /// ��������֤�����Ϣ����
        /// </summary>
        /// <param name="msg">��Ϣ</param>
        private void ProcessFriendVerifyMessage(MessageObject msg)
        {
            if (msg.IsExist())
            {
                return;
            }

            // ��һ���ݴ���
            var tmpFriend = msg.GetFriend();
            if (tmpFriend == null || string.IsNullOrEmpty(tmpFriend.UserId))
            {
                tmpFriend = new Friend()
                {
                    UserId = msg.fromUserId,
                    IsGroup = 0,
                    NickName = msg.fromUserName,
                };

                tmpFriend.InsertAuto();//��Ӷ�Ӧ���������ݿ�
            }
            
            switch (msg.type)
            {
                case kWCMessageType.DeleteFriend://��ɾ��
                    // ��ʾ��ʾ
                    if (string.Equals(msg.fromUserId, msg.myUserId))
                    {
                        HttpUtils.Instance.ShowTip("��ɾ��" + tmpFriend.NickName);
                        // ���ð�ɾ��
                        tmpFriend.UpdateFriendState(tmpFriend.UserId, Friend.STATUS_16);
                    }
                    else
                    {
                        HttpUtils.Instance.ShowTip("���ѱ�" + tmpFriend.NickName + "ɾ��");
                        // ����Ϊ��ɾ��
                        tmpFriend.UpdateFriendState(tmpFriend.UserId, Friend.STATUS_17);
                    }

                    // ֪ͨ����ˢ��
                    Messenger.Default.Send(tmpFriend, MessageActions.DELETE_FRIEND);
                    // �����Ϣ��¼
                    msg.DeleteTable();
                    // �����µ�����δ������
                    Messenger.Default.Send(Friend.ID_NEW_FRIEND, FriendListLayout.NOTIFY_FRIENDLIST_UNREAD_COUNT);
                    break;
                case kWCMessageType.BlackFriend://������

                    // ��ʾ��ʾ
                    if (string.Equals(msg.fromUserId, msg.myUserId))
                    {
                        HttpUtils.Instance.ShowTip("������" + tmpFriend.NickName);
                        // ����Ϊ������
                        tmpFriend.UpdateFriendState(tmpFriend.UserId, Friend.STATUS_18);
                    }
                    else
                    {
                        HttpUtils.Instance.ShowTip("���ѱ�" + tmpFriend.NickName + "����");
                        // ����Ϊ������
                        tmpFriend.UpdateFriendState(tmpFriend.UserId, Friend.STATUS_19);
                    }

                    // ֪ͨ����ˢ��
                    Messenger.Default.Send(tmpFriend, MessageActions.ADD_BLACKLIST);

                    // �����Ϣ��¼
                    msg.DeleteTable();
                    // �����µ�����δ������
                    Messenger.Default.Send(Friend.ID_NEW_FRIEND, FriendListLayout.NOTIFY_FRIENDLIST_UNREAD_COUNT);
                    break;
                case kWCMessageType.RequestRefuse://�Է��ػ�
                case kWCMessageType.FriendRequest://�Է����������
                                                  // �����µ�����δ������
                    Messenger.Default.Send(Friend.ID_NEW_FRIEND, FriendListLayout.NOTIFY_FRIENDLIST_UNREAD_COUNT);
                    break;
                case kWCMessageType.RequestFriendDirectly://ֱ����Ӻ���
                case kWCMessageType.RequestAgree://��ͬ��
                case kWCMessageType.CancelBlackFriend://���Է�ȡ��������
                case kWCMessageType.PhoneContactToFriend://���Է����ֻ���ϵ��ֱ����ӳɺ���

                    MessageObject tip = msg.CopyMessage();
                    tip.type = kWCMessageType.Remind;
                    tip.content = "�����Ѿ���Ϊ���ѣ����������";
                    if (tip.InsertData() == 1)
                    {
                        Console.WriteLine("����ɹ�");
                    }//������ʾ��Ϣ

                    tmpFriend.BecomeFriend(msg.type);

                    // ���������¼ҳ
                    Messenger.Default.Send(tip, MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);
                    Messenger.Default.Send(tip, MessageActions.XMPP_SHOW_SINGLE_MESSAGE);

                    //����������б�
                    Messenger.Default.Send(tmpFriend.UserId, FriendListLayout.ADD_EXISTS_FRIEND);
                    // �����µ�����δ������
                    Messenger.Default.Send(Friend.ID_NEW_FRIEND, FriendListLayout.NOTIFY_FRIENDLIST_UNREAD_COUNT);

                    break;
                default:
                    break;
            }

            // ˢ���µ����ѽ���
            if (string.Equals(msg.fromUserId, msg.myUserId))
            {
                Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_VERIFY_RECEPIT);// ����UI��Ϣ����ʧ�ܱ�־ ��Ϣ�ѷ���ʧ�� ���� messageObject
            }
            else
            {
                NotifactionVerifyMessage(msg);
            }
        }
        
        // ������Ϣ����
        private void ProcessRecallMessage(MessageObject msg)
        {
            // ����ֹ��Ϣ�ظ�����
            //msg.InsertData();

            string content = msg.fromUserId.Equals(mLoginUserId) ? "��" : msg.fromUserName;
            content += "������һ����Ϣ";
            msg.messageId = msg.content;
            MessageObject oMsg = msg.GetMessageObject();
            
            if (string.Equals(msg.fromUserId, msg.myUserId))
            {
                if (string.Equals(oMsg.fromUserId, oMsg.myUserId))
                {
                    content = "�㳷����һ����Ϣ";
                }
                else
                {
                    content = "�㳷���� " + UIUtils.QuotationName(oMsg.fromUserName) + "��һ����Ϣ";
                }
            }
            else
            {
                if (string.Equals(oMsg.fromUserId, oMsg.myUserId))
                {
                    content = UIUtils.QuotationName(msg.fromUserName) + "������һ�������Ϣ";
                }
                else
                {
                    if (string.Equals(oMsg.fromUserId, msg.fromUserId))
                    {
                        content = UIUtils.QuotationName(msg.fromUserName) + "������һ����Ϣ";
                    }
                    else
                    {
                        content = UIUtils.QuotationName(msg.fromUserName) + "������һ����Ա����Ϣ";
                    }
                }
            }

            oMsg.content = content;
            oMsg.type = kWCMessageType.Remind;

            // ȥ���³�����Ϣ
            if (oMsg.UpdateData() > 0)
            {
                NotifactionRecallMessage(oMsg);
            }

            Friend friend = msg.GetFriend();
            if (friend.UpdateLastContent(content, msg.timeSend) > 0)
            {
                Messenger.Default.Send(msg, MessageActions.XMPP_SHOW_SINGLE_MESSAGE);
            }
        }

        /// <summary>
        /// ��������Ƶ������Ϣ
        /// </summary>
        /// <param name="msg"></param>
        private void ProcessPhoneCallMessage(MessageObject msg)
        {
            if (msg.IsExist())
            {
                return;
            }
            
            if (msg.type == kWCMessageType.AudioChatAsk || msg.type == kWCMessageType.VideoChatAsk)
            {
                if (string.Equals(msg.fromUserId, msg.myUserId))
                {
                    return;
                }
            }

            // �޸�����7474���⣬web�Ҷ���Ϣ�����ڹ��ںŵ�����
            if ("10000".Equals(msg.toUserId))
            {
                return;
            }

            Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_MEETING_MESSAGE);//

            switch (msg.type)
            {
                case kWCMessageType.AudioChatCancel://
                    msg.content = "ȡ��������ͨ��";
                    UpdateFriendLastContentTip(msg);
                    break;
                case kWCMessageType.AudioChatEnd://
                    msg.content = "����������ͨ����" + TimeUtils.FromatCountdown(msg.timeLen);
                    UpdateFriendLastContentTip(msg);
                    break;
                case kWCMessageType.VideoChatCancel://
                    msg.content = "ȡ������Ƶͨ��";
                    UpdateFriendLastContentTip(msg);
                    break;
                case kWCMessageType.VideoChatEnd://
                    msg.content = "��������Ƶͨ����" + TimeUtils.FromatCountdown(msg.timeLen);
                    UpdateFriendLastContentTip(msg);
                    break;
                case kWCMessageType.AudioMeetingSetSpeaker://
                    msg.content = "�Է�æ����";
                    UpdateFriendLastContentTip(msg);
                    break;
            }
        }

        /// <summary>
        /// �����������Ϣ
        /// </summary>
        /// <param name="msg"></param>
        private void ProcessMoenyMessage(MessageObject msg)
        {
            switch (msg.type)
            {
                case kWCMessageType.RedBack:
                    msg.content = "�к���˻������ֻ��˲鿴";
                    break;
                case kWCMessageType.TYPE_TRANSFER_RECEIVE://ɾ��Ⱥ�ļ�
                    msg.content = "ת���ѱ���ȡ�����ֻ��˲鿴";
                    break;
                case kWCMessageType.TYPE_93:
                    msg.content = "�յ��տ���Ϣ�����ֻ��˲鿴";
                    break;
                case kWCMessageType.TYPE_TRANSFER_BACK:
                    msg.content = "ת�����˻������ֻ��˲鿴";
                    break;
                default:
                    msg.content = "�ݲ�֧�ִ����͵���Ϣ��ʾ";
                    break;
            }

            UpdateFriendLastContentTip(msg);
        }

        /// <summary>
        /// �����������Ϣ
        /// </summary>
        /// <param name="msg"></param>
        private void ProcessSpecialMessage(MessageObject msg)
        {
            // ��� ת�������Ϣ 
            if (msg.type >= kWCMessageType.RedBack && msg.type <= kWCMessageType.TYPE_93)
            {
                switch (msg.type)
                {
                    case kWCMessageType.RedBack:
                        msg.content = "�к���˻������ֻ��˲鿴";
                        break;
                    case kWCMessageType.TYPE_TRANSFER_RECEIVE:
                        msg.content = "ת���ѱ���ȡ�����ֻ��˲鿴";
                        break;
                    case kWCMessageType.TYPE_93:
                        msg.content = "�յ��տ���Ϣ�����ֻ��˲鿴";
                        break;
                    case kWCMessageType.TYPE_TRANSFER_BACK:
                        msg.content = "ת�����˻������ֻ��˲鿴";
                        break;
                    default:
                        msg.content = "�ݲ�֧�ִ����͵���Ϣ��ʾ";
                        break;
                }

                UpdateFriendLastContentTip(msg);
                return;
            }

            // ������Ϣ������ʾ
            switch (msg.type)
            {
                case kWCMessageType.ImageTextSingle:
                case kWCMessageType.ImageTextMany:
                    if (msg.InsertData() > 0)//���ݿ�ɹ�����
                    {
                        msg.UpdateLastSend();
                        NotifactionNormalMessage(msg);//  ֪ͨUI  //֪ͨ��ҳ���յ���Ϣ
                    }
                    break;
                case kWCMessageType.PokeMessage:
                    msg.content = "�ݲ�֧�ִ���Ϣ���͵���ʾ";
                    UpdateFriendLastContentTip(msg);
                    break;
                case kWCMessageType.Link:
                    UpdateFriendLastContentTip(msg);
                    break;
                case kWCMessageType.TYPE_83:
                    string fromName;
                    string toName;
                    string seetext = "";
                    if (!Applicate.ENABLE_RED_PACKAGE)
                    {
                        seetext = ",�����ֻ��ϲ鿴";
                    }
                    if (msg.fromUserId.Equals(msg.myUserId))
                    {
                        fromName = "��";
                    }
                    else
                    {
                        fromName = msg.fromUserName;
                    }

                    if (msg.toUserId.Equals(msg.myUserId) || msg.fromUserId.Equals(msg.toUserId))
                    {
                        if (msg.fromUserId.Equals(msg.myUserId))
                        {
                            toName = "�Լ�";
                        }
                        else
                        {
                            toName = msg.toUserName;
                        }
                    }
                    else
                    {
                        toName = msg.toUserName;
                    }
                    msg.ToId = msg.myUserId;
                    msg.FromId = msg.objectId;
                    msg.isGroup = 1;
                    msg.content = fromName + "��ȡ��" + toName + "�ĺ��" + seetext;
                    UpdateFriendLastContentTip(msg);
                    break;
                case kWCMessageType.History:

                    if (msg.InsertData() > 0)//���ݿ�ɹ�����
                    {
                        msg.UpdateLastSend();
                        NotifactionNormalMessage(msg);//  ֪ͨUI  //֪ͨ��ҳ���յ���Ϣ
                    }

                    break;
            }
        }

        /// <summary>
        /// �Ѷ���Ϣ�Ĵ���
        /// </summary>
        /// <param name="msg"></param>
        private void ProcessReadMessage(MessageObject msg)
        {
            // ��ȥ�ҵ��ҷ�����������Ϣ
            var target = new MessageObject()
            {
                FromId = msg.ChatJid,
                ToId = msg.myUserId,
                messageId = msg.content

            }.GetMessageObject();

            if (target == null || string.IsNullOrEmpty(target.messageId))
            {
                return;
            }

            if (msg.isGroup == 1)
            {
                //msg.FromId = target.FromId;
                //msg.ToId = target.ToId;

                if (msg.InsertReadData() > 0)
                {
                    int preson = target.readPersons + 1;
                    if (target.UpdateIsReadPersons(preson) > 0)
                    {
                        Messenger.Default.Send(target, MessageActions.XMPP_UPDATE_RECEIVED_READ);//�Ѷ���Ϣ�Ĵ���
                    }
                }
            }
            else
            {
                if (msg.InsertData() > 0)
                {
                    if (target.isReadDel == 1)
                    {
                        // �Է��鿴���ҵ�һ���ĺ󼴷���Ϣ
                        var friend = target.GetFriend();
                        friend.UpdateLastContent("�Է��鿴���ҵ�һ���ĺ󼴷���Ϣ", msg.timeSend);
                        // ˢ�����һ�������¼
                        NotifactionListSingleMessage(target);
                    }

                    // ȥ�����Ѷ�
                    if (target.UpdateIsRead(msg.content) > 0)
                    {
                        Messenger.Default.Send(target, MessageActions.XMPP_UPDATE_RECEIVED_READ);//�Ѷ���Ϣ�Ĵ���
                    }
                }
            }
        }

        /// <summary>
        /// Ⱥ�ļ���Ϣ����
        /// </summary>
        /// <param name="msg"></param>     
        public void ProcessGroupFileMessage(MessageObject msg)
        {
            Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_ROOM_CHANGE_MESSAGE);
            // �������һ����Ϣ���ݣ�֪ͨUIˢ��
            switch (msg.type)
            {
                case kWCMessageType.RoomFileUpload://�ϴ�Ⱥ�ļ�
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + "�ϴ���Ⱥ�ļ�:" + msg.fileName;
                    break;
                case kWCMessageType.RoomFileDelete://ɾ��Ⱥ�ļ�
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + "ɾ����Ⱥ�ļ�:" + msg.fileName;
                    break;
                case kWCMessageType.RoomFileDownload://����Ⱥ�ļ�
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + "������Ⱥ�ļ�:" + msg.fileName;
                    break;
                default:
                    break;
            }

            UpdateFriendLastContentTip(msg);
        }

        /// <summary>
        /// Ⱥ������Ϣ����
        /// <para>
        /// RoomMemberNameChange��RoomManagerTransfer֮���Ⱥ������Ϣ
        /// ��ִ�����ݿ������ִ��UI
        /// </para>
        /// </summary>
        /// <param name="msg">��Ӧ�Ĵ�����Ϣ</param>
        private void ProcessGroupManageMessage(MessageObject msg, bool deley)
        {
            var room = new Friend();
            room.RoomId = msg.fileName;//RoomId
            room.UserId = msg.objectId;//����RoomJid
            room.NickName = msg.content;
            msg.FromId = msg.objectId;
            msg.ToId = mLoginUserId;
            msg.isGroup = 1;
            room.IsGroup = 1;

            switch (msg.type)
            {
                case kWCMessageType.RoomMemberNameChange://��Ⱥ���ǳ�

                    // ֪ͨ�����¼ҳˢ��
                    NotifactionRoomControlMsg(msg);

                    room = msg.GetFriend();
                    var mem = new RoomMember() { userId = msg.toUserId, roomId = room.RoomId, nickName = msg.content };
                    mem.UpdateMemberNickname();

                    // �������һ����Ϣ���ݣ�֪ͨUIˢ��
                    msg.content = UIUtils.QuotationName(msg.toUserName) + "�޸��ǳ�Ϊ:" + UIUtils.QuotationName(msg.content);

                    msg.type = kWCMessageType.Remind;
                    if (msg.InsertData() > 0)
                    {
                        msg.UpdateLastSend();

                        NotifactionNormalMessage(msg);
                    }
                    break;
                case kWCMessageType.RoomNameChange://��Ⱥ��

                    // ֪ͨ�����¼ҳˢ��
                    NotifactionRoomControlMsg(msg);

                    room = msg.GetFriend();
                    room.NickName = msg.content;
                    room.UpdateNickName();

                    msg.content = UIUtils.QuotationName(msg.fromUserName) + "�޸�Ⱥ��Ϊ:" + UIUtils.QuotationName(msg.content);

                    msg.type = kWCMessageType.Remind;

                    if (msg.InsertData() > 0)
                    {
                        msg.UpdateLastSend();
                        NotifactionNormalMessage(msg);
                    }
                    break;
                case kWCMessageType.RoomDismiss://��ɢ

                    if (msg.InsertData() > 0)
                    {
                        // xmpp�˳�Ⱥ��
                        ExitRoom(msg.objectId);
                        // �����ѱ���ɾ��
                        room.DeleteByUserId();
                        // ֪ͨ�������
                        Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_ROOM_DELETE);

                        Messenger.Default.Send(room, MessageActions.DELETE_FRIEND);
                    }

                    //// ����Ⱥ��,�Ұ�һ��Ⱥ��ɢ��
                    //if (msg.myUserId.Equals(msg.fromUserId))
                    //{
                    //    // �����ѱ���ɾ��
                    //    room.DeleteByUserId();
                    //}
                    //else
                    //{
                    //    //room.UpdateFriendState(0);
                    //    // �����ѱ���ɾ��
                    //    room.DeleteByUserId();
                    //    // ֪ͨ�����¼ҳˢ��
                    //    // NotifactionRoomControlMsg(msg);
                    //    // ���Ⱥ��Ⱥ���ɢ
                    //    msg.type = kWCMessageType.Remind;
                    //    msg.content = "��Ⱥ�ѱ�Ⱥ����ɢ";

                    //    if (msg.InsertData() > 0)
                    //    {
                    //        msg.UpdateLastSend();
                    //        NotifactionNormalMessage(msg);
                    //    }
                    //}

                    // ֪ͨ�������
                    //Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_ROOM_DELETE);

                    break;
                case kWCMessageType.RoomExit://��Ⱥ

                    room = msg.GetFriend();

                    if (room == null || room.Status != 2)
                    {
                        return;
                    }

                    // ���˳�Ⱥ�飬�����ұ�t��
                    if (msg.toUserId.Equals(msg.myUserId))
                    {
                        // xmpp�˳�Ⱥ��
                        ExitRoom(msg.objectId);

                        // �����ѱ���ɾ��
                        room.DeleteByUserId();
                        // ֪ͨ�������
                        Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_ROOM_DELETE);

                        Messenger.Default.Send(room, MessageActions.DELETE_FRIEND);

                        msg.InsertData();
                        //// xmpp �˳�Ⱥ��
                        //Presence pres = new Presence();
                        //pres.From = new Jid(Applicate.MyAccount.userId, XmppCon.MyJID.Server, "pc");
                        //pres.To = new Jid(room.RoomId, "muc." + XmppCon.MyJID.Server, "thirdwitch");
                        //pres.Type = PresenceType.unavailable;
                        //XmppCon.Send(pres);

                        // ɾ�������¼��

                        // ���½��� �������˳�
                        //Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_ROOM_DELETE);
                        //// ɾ������
                        //room.DeleteByUserId();
                        //NotifactionListSingleMessage(msg);
                    }
                    else
                    {
                        // ֪ͨ�����¼ҳˢ��
                        NotifactionRoomControlMsg(msg);
                        //5d6643240c03d001805233ca

                        //ĳȺԱ�˳���Ⱥ��
                        room = msg.GetFriend();
                        RoomMember roomMembers = new RoomMember();
                        roomMembers.roomId = room.RoomId;

                        if (msg.fromUserId.Equals(msg.toUserId) || msg.fromUserName.Equals(msg.toUserName))
                        {
                            msg.content = UIUtils.QuotationName(msg.fromUserName) + "�˳���Ⱥ��";
                            roomMembers.userId = msg.fromUserId;
                            roomMembers = roomMembers.GetRommMember();
                            roomMembers.DeleteByUserId();
                        }
                        else
                        {
                            msg.content = UIUtils.QuotationName(msg.fromUserName) + "�Ƴ���Ա:" + UIUtils.QuotationName(msg.toUserName);
                            roomMembers.userId = msg.toUserId;
                            roomMembers = roomMembers.GetRommMember();
                            roomMembers.DeleteByUserId();
                        }

                        Messenger.Default.Send(room.RoomId, MessageActions.UPDATE_HEAD);//����ˢ��ͷ��֪ͨ

                        UpdateFriendLastContentTip(msg);
                    }

                    break;
                case kWCMessageType.RoomNotice://����

                    // ֪ͨ�����¼ҳˢ��
                    NotifactionRoomControlMsg(msg);// -- �ſ����d������п����ķ���

                    // �������һ����Ϣ���ݣ�֪ͨUIˢ��
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + "�����¹���: \n" + msg.content;
                    UpdateFriendLastContentTip(msg);

                    break;
                case kWCMessageType.RoomInvite://��Ⱥ

                    // ֪ͨ�����¼ҳˢ��
                    NotifactionRoomControlMsg(msg);

                    string desc = "";

                    if (msg.fromUserId.Equals(msg.toUserId))
                    {
                        desc = UIUtils.QuotationName(msg.fromUserName) + "����Ⱥ��";
                    }
                    else
                    {
                        desc = UIUtils.QuotationName(msg.fromUserName) + "�����Ա:" + UIUtils.QuotationName(msg.toUserName);
                    }

                    Console.WriteLine("join  :" + desc);

                    bool isExistsRoom = room.ExistsFriend();
                    if (isExistsRoom) // ������Ѿ���Ⱥ����
                    {
                        room.UpdateLastContent(desc, msg.timeSend);
                    }
                    else
                    {
                        room.Status = 2;
                        room.LastMsgTime = (int)msg.timeSend;
                        room.InsertAuto();
                    }

                    msg.content = desc;
                    msg.type = kWCMessageType.Remind;
                    if (msg.InsertData() > 0)
                    {
                        if (msg.toUserId.Equals(msg.myUserId))
                        {
                            JoinRoom(msg.objectId, 0);//Xmpp����Ⱥ��(������Ⱥ������)
                        }
                        msg.UpdateLastSend();
                        NotifactionNormalMessage(msg);
                    }
                    
                    if (!isExistsRoom) // && !deley
                    {
                        Messenger.Default.Send(room, MessageActions.ROOM_UPDATE_INVITE);//ˢ���б�
                    }
                    else
                    {
                        Messenger.Default.Send(room.RoomId, MessageActions.UPDATE_HEAD);//����ˢ��ͷ��֪ͨ
                    }

                    break;
                case kWCMessageType.RoomReadVisiblity://��ʾ�Ķ�����

                    // ֪ͨ�����¼ҳˢ��
                    NotifactionRoomControlMsg(msg);
                    
                    room = msg.GetFriend();
                    room.ShowRead = int.Parse(msg.content);
                    room.UpdateShowRead();

                    if (room.ShowRead == 1)
                    {
                        msg.content = UIUtils.QuotationName(msg.fromUserName) + "��������ʾ��Ϣ�Ѷ���������";
                    }
                    else
                    {
                        msg.content = UIUtils.QuotationName(msg.fromUserName) + "�ر�����ʾ��Ϣ�Ѷ���������";
                    }

                    msg.type = kWCMessageType.Remind;
                    if (msg.InsertData() > 0)
                    {
                        msg.UpdateLastSend();
                        NotifactionNormalMessage(msg);
                    }
                    //����Ⱥ���Ƿ���ʾ����  room.UpdateShowRead(int.Parse(msg.content));
                    break;
                case kWCMessageType.RoomIsVerify://Ⱥ��֤


                    // ֪ͨ�����¼ҳˢ��
                    NotifactionRoomControlMsg(msg);

                    if ("0".Equals(msg.content) || "1".Equals(msg.content))
                    {
                        room.IsNeedVerify = int.Parse(msg.content);
                        room.UpdateNeedVerify();
                        msg.content = room.IsNeedVerify == 0 ? " �ѹرս�Ⱥ��֤" : " �ѿ�����Ⱥ��֤";
                        msg.content = UIUtils.QuotationName(msg.fromUserName) + msg.content;
                        UpdateFriendLastContentTip(msg);
                    }
                    else
                    {
                        //  NotifactionRoomControlMsg(msg);
                        string objecid = msg.objectId;

                        string[] userids;
                        var notic = JsonConvert.DeserializeObject<Dictionary<string, object>>(objecid.ToString());
                        string roomJid = UIUtils.DecodeString(notic, "roomJid");
                        string nickname = msg.fromUserName;
                        string useids = UIUtils.DecodeString(notic, "userIds");
                        userids = useids.Split(',');
                        if (msg.fromUserId == useids)
                        {
                            msg.content = msg.fromUserName + "�������";//�Լ���������
                        }
                        else
                        {
                            msg.content = msg.fromUserName + "������" + userids.Length + "λ���Ѽ���Ⱥ��";
                        }

                        msg.FromId = roomJid;
                        msg.toUserId = Applicate.MyAccount.userId;
                        if (msg.InsertData() > 0)
                        {
                            msg.UpdateLastSend();
                            NotifactionNormalMessage(msg);
                        }
                    }

                    break;
                case kWCMessageType.RoomUnseenRole://������

                    // ֪ͨ�����¼ҳˢ��
                    NotifactionRoomControlMsg(msg);
                    room = msg.GetFriend();
                    RoomMember roomMember = new RoomMember();
                    roomMember.roomId = room.RoomId;
                    roomMember.role = "1".Equals(msg.content) ? 4 : 3;
                    roomMember.userId = msg.toUserId;
                    roomMember.nickName = msg.toUserName;
                    roomMember.InsertOrUpdate();

                    if (msg.fromUserId.Equals(msg.myUserId) || msg.myUserId.Equals(msg.toUserId))
                    {

                        if ("1".Equals(msg.content))
                        {
                            msg.content = UIUtils.QuotationName(msg.fromUserName) + "����������" + UIUtils.QuotationName(msg.toUserName);
                        }
                        else
                        {
                            msg.content = UIUtils.QuotationName(msg.fromUserName) + "ȡ��������" + UIUtils.QuotationName(msg.toUserName);
                        }

                        msg.type = kWCMessageType.Remind;
                        if (msg.InsertData() > 0)
                        {
                            msg.UpdateLastSend();
                            NotifactionNormalMessage(msg);
                        }
                    }


                    break;
                case kWCMessageType.RoomAdmin://����Ա

                    // ֪ͨ�����¼ҳˢ��
                    NotifactionRoomControlMsg(msg);


                    if (msg.content == "0")//ȡ������Ա
                    {
                        msg.content = UIUtils.QuotationName(msg.fromUserName) + "ȡ������Ա" + UIUtils.QuotationName(msg.toUserName);
                    }
                    else if (msg.content == "1")//���ù���Ա8
                    {
                        msg.content = UIUtils.QuotationName(msg.fromUserName) + "����:" + UIUtils.QuotationName(msg.toUserName) + "Ϊ����Ա";
                    }

                    // �������һ����Ϣ���ݣ�֪ͨUIˢ��
                    msg.type = kWCMessageType.Remind;

                    if (msg.InsertData() > 0)
                    {
                        msg.UpdateLastSend();
                        NotifactionNormalMessage(msg);
                    }

                    break;
                case kWCMessageType.RoomIsPublic://����Ⱥ

                    // ֪ͨ�����¼ҳˢ��
                    NotifactionRoomControlMsg(msg);
                    msg.content = msg.content == "0" ? " ����Ⱥ�޸�Ϊ����Ⱥ��" : " ����Ⱥ�޸�Ϊ˽��Ⱥ��";
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + msg.content;
                    // �������һ����Ϣ���ݣ�֪ͨUIˢ��
                    UpdateFriendLastContentTip(msg);

                    break;
                case kWCMessageType.RoomInsideVisiblity://��ʾȺ�ڳ�Ա
                                                        // ֪ͨ�����¼ҳˢ��
                    NotifactionRoomControlMsg(msg);
                    room.UpdateShowMember(int.Parse(msg.content));
                    msg.content = msg.content == "0" ? " �ر��˲鿴Ⱥ��Ա����" : " �����˲鿴Ⱥ��Ա����";
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + msg.content;
                    // �������һ����Ϣ���ݣ�֪ͨUIˢ��
                    UpdateFriendLastContentTip(msg);

                    break;
                case kWCMessageType.RoomUserRecommend://�Ƿ���������Ƭ
                    NotifactionRoomControlMsg(msg); // ֪ͨ�����¼ҳˢ��
                    room.UpdateAllowSendCard(int.Parse(msg.content));//
                    msg.content = msg.content == "0" ? " �ر���Ⱥ��˽�Ĺ���" : " ������Ⱥ��˽�Ĺ���";
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + msg.content;
                    // �������һ����Ϣ���ݣ�֪ͨUIˢ��
                    UpdateFriendLastContentTip(msg);
                    break;
                case kWCMessageType.RoomMemberBan://���Գ�Ա

                    double banTime = double.Parse(msg.content);

                    if (msg.myUserId.Equals(msg.toUserId)) // �ұ�����
                    {
                        if (banTime > TimeUtils.CurrentTime() + 3)
                        {
                            LocalDataUtils.SetStringData(room.UserId + "BANNED_TALK" + msg.myUserId, msg.content);
                        }
                        else
                        {
                            // ȡ������
                            LocalDataUtils.SetStringData(room.UserId + "BANNED_TALK" + msg.myUserId, "0");
                        }

                        Messenger.Default.Send(msg, MessageActions.ROOM_UPDATE_BANNED_TALK);
                    }


                    if (banTime > TimeUtils.CurrentTime() + 3)
                    {
                        var date = Helpers.StampToDatetime(banTime);
                        string time = date.Month + "-" + date.Day + " " + date.Hour + ":" + date.Minute;
                        msg.content = UIUtils.QuotationName(msg.fromUserName) + "��" + UIUtils.QuotationName(msg.toUserName) + "�����˽���,��ֹ:" + time;
                    }
                    else
                    {
                        msg.content = UIUtils.QuotationName(msg.toUserName) + "�ѱ�" + UIUtils.QuotationName(msg.fromUserName) + "ȡ������";
                    }

                    // �������һ����Ϣ���ݣ�֪ͨUIˢ��
                    UpdateFriendLastContentTip(msg);

                    break;
                case kWCMessageType.RoomAllBanned://Ⱥ��ȫԱ���� 

                    LocalDataUtils.SetStringData(room.UserId + "BANNED_TALK_ALL" + msg.myUserId, msg.content);
                    if (!deley)
                    {
                        Messenger.Default.Send(msg, MessageActions.ROOM_UPDATE_BANNED_TALK);
                    }

                    msg.content = msg.content == "0" ? "�ѹر�ȫ�����" : "�ѿ���ȫ�����";
                    // �������һ����Ϣ���ݣ�֪ͨUIˢ��
                    UpdateFriendLastContentTip(msg);

                    break;
                case kWCMessageType.RoomAllowMemberInvite://�Ƿ�����Ⱥ����ͨ��Ա����İ����
                    NotifactionRoomControlMsg(msg); // ֪ͨ�����¼ҳˢ��
                    room.UpdateAllowInviteFriend(int.Parse(msg.content));
                    msg.content = msg.content == "0" ? " �ر�����ͨ��Ա���빦��" : " ��������ͨ��Ա���빦��";
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + msg.content;

                    // �������һ����Ϣ���ݣ�֪ͨUIˢ��
                    UpdateFriendLastContentTip(msg);

                    break;
                case kWCMessageType.RoomManagerTransfer://ת��Ⱥ��
                    NotifactionRoomControlMsg(msg); // ֪ͨ�����¼ҳˢ��

                    msg.content = UIUtils.QuotationName(msg.toUserName) + "�ѳ�Ϊ��Ⱥ��";
                    // �������һ����Ϣ���ݣ�֪ͨUIˢ��
                    UpdateFriendLastContentTip(msg);

                    room = msg.GetFriend();
                    var oldroomhost = new RoomMember() { userId = msg.fromUserId, roomId = room.RoomId, role = 3 };
                    oldroomhost.UpdateRole();//
                                             // �޸�Ⱥ�鴴����id
                    var member = new RoomMember() { userId = msg.toUserId, roomId = room.RoomId, role = 1 };
                    member.UpdateRole();
                    member.userId = msg.fromUserId;
                    member.role = 1;

                    break;
                case kWCMessageType.RoomAllowUploadFile://�Ƿ������Ա�ϴ�Ⱥ�ļ�
                    NotifactionRoomControlMsg(msg); // ֪ͨ�����¼ҳˢ��

                    room.UpdateAllowUploadFile(int.Parse(msg.content));
                    msg.content = msg.content == "0" ? " �ر�����ͨ��Ա�ϴ�Ⱥ����" : " ��������ͨ��Ա�ϴ�Ⱥ����";
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + msg.content;
                    // �������һ����Ϣ���ݣ�֪ͨUIˢ��
                    UpdateFriendLastContentTip(msg);

                    break;
                case kWCMessageType.RoomAllowConference://�Ƿ�����Ⱥ����
                    NotifactionRoomControlMsg(msg); // ֪ͨ�����¼ҳˢ�� 
                    room.UpdateAllowConference(int.Parse(msg.content));
                    msg.content = msg.content == "0" ? " �ر�����ͨ��Ա������鹦��" : " ��������ͨ��Ա������鹦��";
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + msg.content;
                    // �������һ����Ϣ���ݣ�֪ͨUIˢ��
                    UpdateFriendLastContentTip(msg);

                    break;
                case kWCMessageType.RoomAllowSpeakCourse://�Ƿ�����Ⱥ��Ա����

                    NotifactionRoomControlMsg(msg); // ֪ͨ�����¼ҳˢ�� 
                    room.UpdateAllowSpeakCourse(int.Parse(msg.content));
                    msg.content = msg.content == "0" ? " �ر�����ͨ��Ա���Ϳμ�����" : " ��������ͨ��Ա���Ϳμ�����";
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + msg.content;
                    // �������һ����Ϣ���ݣ�֪ͨUIˢ��
                    UpdateFriendLastContentTip(msg);
                    break;
                case kWCMessageType.RoomNewOverDate://Ⱥ��Ϣ����
                    LogUtils.Log("�յ�Ⱥ��Ϣ����   " + msg.content);
                    LocalDataUtils.SetStringData(msg.roomJid + "chatRecordTimeOut" + Applicate.MyAccount.userId, msg.content);
                    break;
                case kWCMessageType.RoomNoticeEdit://�༭Ⱥ����
                                                   // ֪ͨ�����¼ҳˢ��
                    NotifactionRoomControlMsg(msg);

                    // �������һ����Ϣ���ݣ�֪ͨUIˢ��
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + "�޸���Ⱥ����:\n" + msg.content;
                    UpdateFriendLastContentTip(msg);

                    break;
                default:
                    return;
            }

        }

        #endregion

        #region ����¼ͬ����Ϣ����
        /// <summary>
        /// ����¼ͬ����Ϣ����
        /// </summary>
        /// <param name="msg"></param>
        private void ProcessDeviceSyncMessage(MessageObject msg, bool isOfflieMsgppMsg)
        {
            Console.WriteLine("ProcessDeviceSyncMessage  " + msg.messageId);

            if (msg.type == kWCMessageType.Device_SYNC_OTHER)
            {
                if (SYNC_LOGIN_PASSWORD.Equals(msg.objectId))
                {
                    if (Applicate.MODIFY_PASSWORD_NOTIFY)
                    {
                        UpdatePwdRestart();
                    }

                    Console.WriteLine("�������޸��˵�½����");
                }
                else if (SYNC_PAY_PASSWORD.Equals(msg.objectId))
                {
                    Console.WriteLine("�������޸���֧������");
                }
                else if (SYNC_PRIVATE_SETTINGS.Equals(msg.objectId))
                {
                    Console.WriteLine("�������޸�����˽����");
                }
                else if (SYNC_LABEL.Equals(msg.objectId))
                {
                    Console.WriteLine("�������޸��˱�ǩ");
                }
            }
            else if (msg.type == kWCMessageType.Device_SYNC_FRIEND)
            {
                if (string.Equals(msg.toUserId, msg.myUserId))
                {
                    Console.WriteLine("����¼ͬ��--->�����Լ�����Ϣ");
                }
                else
                {
                    Console.WriteLine("����¼ͬ��--->���º��ѵ���Ϣ");
                    HandleFriendUpdate(msg.toUserId);
                }
            }
            else if (msg.type == kWCMessageType.Device_SYNC_GROUP)
            {
                if (!isOfflieMsgppMsg)
                {
                    Console.WriteLine("����¼ͬ��--->����Ⱥ�����Ϣ");
                    HandleGroupUpdate(msg.toUserId);
                }
            }
        }

        /// <summary>
        /// �����ѱ��޸������µ�¼
        /// </summary>
        private void UpdatePwdRestart()
        {
            HttpUtils.Instance.ShowTip("�����ѱ��޸������µ�¼");

            //��¼��ס�������
            Configuration cfa = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            cfa.AppSettings.Settings["passWord"].Value = String.Empty;
            cfa.Save();
            ShiKuManager.ApplicationExit();
            LocalDataUtils.SetStringData(Applicate.QUIT_TIME, TimeUtils.CurrentIntTime().ToString());
            //�˴������˳��ӿ�
            Application.ExitThread();
            Application.Exit();
            Application.Restart();
            Process.GetCurrentProcess().Kill();
        }
        #endregion

        #region �˵��˼���ͨѶ��Ϣ����
        /// <summary>
        /// �˵��˼���ͨѶ��Ϣ����
        /// </summary>
        private void ProcessSecureMessage(MessageObject msg)
        {
            if (msg.type == kWCMessageType.TYPE_SECURE_SEND_KEY)
            {
                return;
            }

            if (kWCMessageType.TYPE_SECURE_NOTIFY_REFRESH_KEY == msg.type)
            {
                var room = msg.GetFriend();
                HandleGroupUpdate(room.RoomId);

                return;
            }

            if (kWCMessageType.TYPE_SECURE_REFRESH_KEY == msg.type)
            {
                HandleFriendUpdate(msg.fromUserId);
                return;
            }

            LogUtils.Save("==========δ����Ķ˵���Э��===========\n" + msg.ToJson(true));
        }


        #endregion

        #region ========================================================֪ͨģ��========================================================  

        private List<MessageObject> mssageList = new List<MessageObject>();

        private void OnMessageLoop(object source, System.Timers.ElapsedEventArgs e)
        {
            //Console.WriteLine("OnMessageLoop  + OnMessageLoop");

            if (mssageList.Count == 0)
            {
                return;
            }

            if (mssageList.Count > 1)
            {
                // һ���Ը��¶��� ���� List<MessageObject>
                NotifactionListAllMessage(mssageList);
            }
            else
            {
                // ����ˢ�� ���� MessageObject
                NotifactionListSingleMessage(mssageList[0]);
            }

            mssageList.Clear();// ������Ϣ����
        }

        public void NotifactionListAllMessage(List<MessageObject> messages)
        {
            LogUtils.Log("xmpp ֪ͨ ������ all");
            Messenger.Default.Send(messages, MessageActions.XMPP_SHOW_ALL_MESSAGE);
        }
        
        public void NotifactionListSingleMessage(MessageObject messages)
        {
            Messenger.Default.Send(messages, MessageActions.XMPP_SHOW_SINGLE_MESSAGE);
        }
        
        /// <summary>
        /// ��ͨ��Ϣ��֪ͨ
        /// </summary>
        /// <param name="msg"></param>
        public void NotifactionNormalMessage(MessageObject msg)
        {
            // ��Ϣ�Ŷӻ��� -> �������Ϣ�б�
            if (mssageList.Count > 0)
            {
                mssageList.Add(msg); // �Ѿ���������ʱ���ˣ�ֱ�����б������Ϣ�Ϳ���
                MessageLooper.Stop();
                MessageLooper.Start();
            }
            else
            {
                MessageLooper.Start();// ������ʱ�� -> 0.5������ OnMessageLoop �����б�
                mssageList.Add(msg);
            }

            // ���������¼ҳ
            Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);
        }

        /// <summary>
        /// ������Ϣ��֪ͨ
        /// </summary>
        /// <param name="msg"></param>
        public void NotifactionRecallMessage(MessageObject msg)
        {
            Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_RECALL_MESSAGE);//֪ͨ��ҳ���յ���Ϣ
        }

        /// <summary>
        ///  
        /// </summary>
        /// <param name="msg"></param>
        public void NotifactionVerifyMessage(MessageObject msg)
        {
            Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_VERIFY_MESSAGE);//������֤�����Ϣ֪ͨ
        }

        /// <summary>
        /// Ⱥ���������Ϣ֪ͨ
        /// </summary>
        /// <param name="msg"></param>
        public void NotifactionRoomControlMsg(MessageObject msg)
        {
            Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_ROOM_CHANGE_MESSAGE);//Ⱥ���������Ϣ֪ͨ
        }

        /// <summary>
        /// ����ƵЭ�������Ϣ֪ͨ
        /// </summary>
        /// <param name="msg"></param>
        public void NotifactionMeetingMessage(MessageObject msg)
        {
            Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_MEETING_MESSAGE);//�յ���һ������ƵЭ����Ϣ
        }

        #endregion

        #region ========================================================Ⱥ�����========================================================

        /// <summary>
        /// ����Ⱥ��
        /// </summary>
        /// <param name="roomName">Ⱥ����</param>
        /// <param name="description">Ⱥ����</param>
        /// <returns>roomJid</returns>
        public string CreateGroup(string roomName, string description)
        {
            string jid = Guid.NewGuid().ToString("N");

            JoinRoom(jid, 0);

            return jid;
        }

        /// <summary>
        /// ����Ⱥ��
        /// </summary>
        /// <param name="roomJid">RoomJId</param>
        /// <param name="lastExitTime"></param>
        public void JoinRoom(string roomJid, long seconds)
        {
            MessageHead head = new MessageHead();
            head.chatType = 2;
            head.from = mLoginUserId + "/" + ShiKuManager.Resource;
            head.to = "service";
            head.messageId = Guid.NewGuid().ToString("N");

            JoinGroupMessageProBuf join = new JoinGroupMessageProBuf();
            join.jid = roomJid;
            join.seconds = seconds;
            join.messageHead = head;

            mSocketCore.SendMessage(join, Command.COMMAND_JOIN_GROUP_REQ);

            Console.WriteLine("���ͼ���Ⱥ����Ϣ");
        }

        /// <summary>
        /// �˳�Ⱥ��
        /// </summary>
        /// <param name="roomJid">RoomJId</param>
        public void ExitRoom(string roomJid)
        {
            MessageHead head = new MessageHead();
            head.chatType = 2;
            head.from = mLoginUserId + "/" + ShiKuManager.Resource;
            head.to = "service";
            head.messageId = Guid.NewGuid().ToString("N");

            ExitGroupMessageProBuf exit = new ExitGroupMessageProBuf();
            exit.jid = roomJid;
            exit.messageHead = head;

            mSocketCore.SendMessage(exit, Command.COMMAND_EXIT_GROUP_REQ);
            Console.WriteLine("�����˳�Ⱥ����Ϣ");
        }


        #endregion

        #region ========================================================�ڲ�����========================================================

        //private void StartBatchReceiptTread()
        //{
        //    Task.Factory.StartNew(() =>
        //    {
        //        while (true)
        //        {
        //            Thread.Sleep(1000);
        //            timeCount++;
        //            // ÿ��5�� | ��Ϣ������50 ��һ�λ�ִ
        //            if (timeCount > 4 || messageIds.Length > 800)
        //            {
        //                if (messageIds.Length > 0)
        //                {
        //                    messageIds.Remove(messageIds.Length - 1, 1);
        //                    string ids = messageIds.ToString();
        //                    messageIds.Clear();
        //                    SendReceiptBatch(ids);
        //                }
        //            }
        //        }
        //    });
        //}

        /// <summary>
        /// ����������Ϣ��ִ(�ʹ�)
        /// </summary>
        /// <param name="recivemsg">��Ϣ��UID</param>
        /// <param name="From">���ջ�ִ��</param>
        /// <param name="to">���ͻ�ִ��</param>
        private void SendReceiptMessage(MessageHead source)
        {
            MessageHead head = new MessageHead();
            head.chatType = source.chatType;
            head.from = mLoginUserId + "/" + ShiKuManager.Resource;
            head.to = source.to;
            head.messageId = Guid.NewGuid().ToString("N");

            MessageReceiptStatusProBuf receipt = new MessageReceiptStatusProBuf();
            receipt.messageId = source.messageId;
            receipt.messageHead = head;

            mSocketCore.SendMessage(receipt, Command.COMMAND_MESSAGE_RECEIPT_REQ);
            Console.WriteLine("���ͻ�ִ��Ϣ��Ϣ");
        }
        
        private void UpdateChatListData(JsonLastChats list)
        {
            if (list == null || UIUtils.IsNull(list.data))
            {
                Messenger.Default.Send("1", MessageActions.DOWN_CHATLIST_COMPT);
                return;
            }

            //int count = 0;
            foreach (var item in list.data)
            {
                if (item.jid.Length < 8)
                {
                    continue;
                }

                Friend friend = new Friend()
                {
                    UserId = item.jid,
                    IsGroup = item.isRoom,
                };

                string lastContent;
                if (item.isEncrypt)
                {
                    lastContent = DES.DecryptMessage(item.content, item.timeSend, item.messageId);
                }
                else
                {
                    lastContent = item.content;
                }

                // �����¼����
                long startTime = (long)(new MessageObject() { FromId = friend.UserId }.GetLastTimeStamp());
                if (item.timeSend != startTime)
                {
                    if (friend.IsGroup == 1)
                    {
                        if (startTime != 0)
                        {
                            MessageObject local = new MessageObject() { isGroup = 1, FromId = friend.UserId }.GetLastMessage();
                            MsgRoamTask mMsgRoamTask = new MsgRoamTask();
                            mMsgRoamTask.taskId = TimeUtils.CurrentTimeMillis();
                            mMsgRoamTask.ownerId = mLoginUserId;
                            mMsgRoamTask.userId = friend.UserId;
                            mMsgRoamTask.startMsgId = local.messageId;
                            mMsgRoamTask.startTime = local.timeSend;
                            mMsgRoamTask.CreateTask();
                            Console.WriteLine("������������");
                        }
                        else
                        {
                            // ����û�м�¼�� ֱ�Ӿ��������������߼�
                            long time = startTime == 0 ? 1262275200000L : startTime * 1000;
                            friend.UpdateDownTime(time, item.timeSend);
                        }
                    }
                    else
                    {
                        long time = startTime == 0 ? 1262275200000L : startTime * 1000;
                        friend.UpdateDownTime(time, item.timeSend);
                    }
                }

                if (!UIUtils.IsNull(lastContent) && lastContent.Length > 30)
                {
                    lastContent = lastContent.Substring(0, 30);
                }
                
                lastContent = friend.ToLastContentTip((kWCMessageType)item.type, lastContent, item.from, item.fromUserName, item.toUserName);

                if (item.isRoom == 1)
                {
                    lastContent = item.fromUserName + ":" + lastContent;
                }

                //Console.WriteLine("UpdateChatListData  " + (count++) + "   /   " + list.data.Count);
                friend.UpdateFriendLastContent(lastContent, item.type, item.timeSend / 1000.0);

                //if (bigdata && count > 200)
                //{
                //    bigdata = false;
                //    Messenger.Default.Send("1", MessageActions.DOWN_CHATLIST_COMPT);
                //}
            }

            Messenger.Default.Send("1", MessageActions.DOWN_CHATLIST_COMPT);
            //LogUtils.Log("down chat list compte........");

            // ������ȡȺ��������Ϣ
            BatchJoinMucChat();
        }

        public void SyscMultiDeviceData()
        {
            // ��ȡ�������ʱ��
            string quitTime = Applicate.MyAccount.OfflineTime.ToString();

            if (string.Equals(quitTime, Applicate.DEF_START_TIME.ToString()))
            {
                return;
            }

            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/offlineOperation")
                 .AddParams("access_token", Applicate.Access_Token)
                 .AddParams("offlineTime", quitTime)
                 .Build().ExecuteList<SyncBeanList>((sccess, list) =>
                 {
                    if (sccess)
                    {
                        foreach (var item in list.data)
                        {
                            switch (item.tag)
                            {
                            case "label":
                                break;
                            case "friend":
                                HandleFriendUpdate(item.friendId);
                                break;
                            case "room":
                                HandleGroupUpdate(item.friendId);
                                break;
                            default:
                                break;
                            }
                        }
                    }

                 });
        }


        //���º��ѵ���Ϣ
        private void HandleFriendUpdate(string userId)
        {
            if (userId.Equals(Applicate.MyAccount.userId))
            {
                // �����Լ�������
                //handleSelfUpdate();
                return;
            }

            Console.WriteLine("����¼ͬ��--->���º��ѵ���Ϣ" + userId);

            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/get")
                   .AddParams("access_token", Applicate.Access_Token)
                   .AddParams("userId", userId)
                   .Build().Execute((suus, data) =>
                   {
                       if (suus)
                       {
                           Friend jsonFriend = JsonConvert.DeserializeObject<Friend>(JsonConvert.SerializeObject(data)); //ʹ��Friend��������

                           //���������ڹ�ϵ ������������
                           if (data.ContainsKey("friends"))
                           {
                               // ��������������
                               AttentionFriend attention = JsonConvert.DeserializeObject<AttentionFriend>(data["friends"].ToString());
                               jsonFriend.Status = attention.ToFriendStatus();
                               jsonFriend.RemarkName = attention.remarkName;

                               // ��ȡ��������
                               Friend local = new Friend() { UserId = userId }.GetFdByUserId();
                               // ���ز����ڣ� ����
                               if (local == null || UIUtils.IsNull(local.NickName))
                               {
                                   // ���ز���������
                                   jsonFriend.TopTime = attention.openTopChatTime;
                                   jsonFriend.InsertAuto();

                                   //����������б�
                                   if (jsonFriend.Status == Friend.STATUS_FRIEND || jsonFriend.Status == 4)
                                   {
                                       Messenger.Default.Send(jsonFriend.UserId, FriendListLayout.ADD_EXISTS_FRIEND);
                                   }
                               }
                               else
                               {
                                   if (!string.Equals(local.RemarkName, jsonFriend.RemarkName))
                                   {
                                       // �����豸�����˺��ѱ�ע
                                       local.RemarkName = jsonFriend.RemarkName;
                                       local.UpdateRemarkName();
                                       Messenger.Default.Send(local, MessageActions.UPDATE_FRIEND_REMARKS);
                                   }


                                   local.UpdateFriendState(jsonFriend.Status);
                                   // ���ش��ڣ�����״̬
                                   if (jsonFriend.Status == Friend.STATUS_FRIEND || jsonFriend.Status == 4)//�Ǻ��ѹ�ϵ
                                   {
                                       Messenger.Default.Send(local.UserId, FriendListLayout.ADD_EXISTS_FRIEND);
                                   }

                                   if (jsonFriend.Status == Friend.STATUS_UNKNOW)//�Ǻ��ѹ�ϵ
                                   {
                                       Messenger.Default.Send(local, MessageActions.DELETE_FRIEND);
                                   }


                                   if (jsonFriend.Status == Friend.STATUS_UNKNOW || jsonFriend.Status == Friend.STATUS_UNKNOW)//�Ǻ��ѹ�ϵ
                                   {
                                       Messenger.Default.Send(local, MessageActions.ADD_BLACKLIST);
                                   }

                                   // ������Ϣ��������
                                   LocalDataUtils.SetStringData(local.UserId + "chatRecordTimeOut" + Applicate.MyAccount.userId, attention.chatRecordTimeOut.ToString());

                                   // ˢ���ĺ󼴷�״̬
                                   if (local.IsOpenReadDel != attention.isOpenSnapchat)
                                   {
                                       local.IsOpenReadDel = attention.isOpenSnapchat;
                                       local.UpdateReadDel();
                                       Messenger.Default.Send(local, MessageActions.UPDATE_FRIEND_READDEL);//ˢ���б�
                                   }

                                   // ˢ�������״̬
                                   if (attention.offlineNoPushMsg != local.Nodisturb)
                                   {
                                       local.Nodisturb = attention.offlineNoPushMsg;
                                       local.UpdateNodisturb();
                                       Messenger.Default.Send(local, MessageActions.UPDATE_FRIEND_DISTURB);//ˢ���б�
                                   }


                                   // ˢ���ö�״̬
                                   if (attention.openTopChatTime > 0 && local.TopTime > 0)
                                   {
                                       // ���غͷ�����״̬һ�� ��Ҫˢ��
                                       return;
                                   }

                                   if (attention.openTopChatTime == 0 && local.TopTime == 0)
                                   {
                                       // ���غͷ�����״̬һ�� ��Ҫˢ��
                                       return;
                                   }


                                   Console.WriteLine("�����ö�״̬ " + attention.openTopChatTime);
                                   // �����ö�״̬
                                   local.TopTime = attention.openTopChatTime;
                                   local.UpdateTopTime(local.TopTime);
                                   Messenger.Default.Send(local, MessageActions.UPDATE_FRIEND_TOP);
                               }
                           }
                           else
                           {
                               // �����������ڹ�ϵ ɾ����������
                               Friend local = new Friend() { UserId = userId }.GetFdByUserId();
                               if (local != null)
                               {
                                   local.UpdateFriendState(Friend.STATUS_UNKNOW);
                                   // ֪ͨ����ˢ��
                                   Messenger.Default.Send(local, MessageActions.DELETE_FRIEND);
                               }
                           }
                       }
                   });

        }

        //����Ⱥ�����Ϣ
        public void HandleGroupUpdate(string roomId)
        {
            Console.WriteLine("����¼ͬ��--->����Ⱥ�����Ϣ");

            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/getRoom") //��ȡȺ����
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("roomId", roomId)
                    .NoErrorTip()
                    .Build().Execute((success, result) =>
                    {
                        if (success)
                        {
                            Friend friend = DecodeFriend(result);

                            // ���ڴ�Ⱥ��״̬
                            string roomByme = UIUtils.DecodeString(result, "member"); ;
                            if (UIUtils.IsNull(roomByme))
                            {
                                // ���߳�Ⱥ��
                                if (friend != null)
                                {
                                    // xmpp�˳�Ⱥ��
                                    ExitRoom(friend.UserId);
                                    // �����ѱ���ɾ��
                                    friend.DeleteByUserId();
                                    // ֪ͨ�������
                                    MessageObject msg = new MessageObject()
                                    { type = kWCMessageType.RoomExit, FromId = friend.UserId, ToId = Applicate.MyAccount.userId };
                                    Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_ROOM_DELETE);
                                }
                            }
                            else
                            {
                                if (friend.ExistsFriend())
                                {   // ����

                                }
                                else
                                {
                                    // ����
                                    friend.Status = Friend.STATUS_FRIEND;
                                    friend.InsertAuto();
                                    long seconds = TimeUtils.CurrentTime() - friend.CreateTime;
                                    JoinRoom(friend.UserId, seconds);
                                    Messenger.Default.Send(friend, MessageActions.ROOM_UPDATE_INVITE);//ˢ���б�
                                }
                            }
                        }
                        else
                        {
                            // ��Ⱥ�鱻��ɢ��
                            Friend friend = new Friend().GetFriendByRoomId(roomId);
                            if (friend != null)
                            {
                                // xmpp�˳�Ⱥ��
                                ExitRoom(friend.UserId);
                                // �����ѱ���ɾ��
                                friend.DeleteByUserId();
                                // ֪ͨ�������
                                MessageObject msg = new MessageObject() { FromId = friend.UserId, ToId = mLoginUserId, type = kWCMessageType.RoomExit };
                                Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_ROOM_DELETE);
                            }
                        }
                    });
        }


        /// <summary>
        /// Ⱥ����Ϣ�ӿ����� ת�� friend 
        /// </summary>
        /// <param name="result"></param>
        private Friend DecodeFriend(Dictionary<string, object> keyValues)
        {

            Friend firend = new Friend();

            //�Ƿ���ʾȺ�Ѷ�
            firend.ShowRead = UIUtils.DecodeInt(keyValues, "showRead");
            // ��ʾȺ��Ա
            firend.ShowMember = UIUtils.DecodeInt(keyValues, "showMember");
            // ������ͨȺ��Ա˽��
            firend.AllowSendCard = UIUtils.DecodeInt(keyValues, "allowSendCard");
            //������ͨȺ��Ա�������
            firend.AllowInviteFriend = UIUtils.DecodeInt(keyValues, "allowInviteFriend");
            //������ͨȺ��Ա�ϴ��ļ�
            firend.AllowUploadFile = UIUtils.DecodeInt(keyValues, "allowUploadFile");
            //������ͨȺ��Ա�ٿ�����
            firend.AllowConference = UIUtils.DecodeInt(keyValues, "allowConference");
            //������ͨȺ��Ա���𽲿�
            firend.AllowSpeakCourse = UIUtils.DecodeInt(keyValues, "allowSpeakCourse");
            //�Ƿ���Ⱥ����֤
            firend.IsNeedVerify = UIUtils.DecodeInt(keyValues, "isNeedVerify");

            //"name": "�ɷ�",
            //"desc": "1",
            //"subject": "",

            //"userSize": 6,
            //"maxUserSize": 1000,

            //"nickname": "2007",
            //"userId": 10009572,

            //"id": "5ca1c9b90c03d0640281ad58",
            //"jid": "d0495fea6ce34adea87a0fe8764bdd24",
            firend.UserId = UIUtils.DecodeString(keyValues, "jid");
            firend.RoomId = UIUtils.DecodeString(keyValues, "id");
            firend.NickName = UIUtils.DecodeString(keyValues, "name");
            firend.Description = UIUtils.DecodeString(keyValues, "desc");
            firend.LastMsgTime = UIUtils.DecodeDouble(keyValues, "modifyTime");
            firend.CreateTime = UIUtils.DecodeInt(keyValues, "createTime");
            firend.IsGroup = 1;

            // ��ȡ����״̬
            long talkTime = UIUtils.DecodeLong(keyValues, "talkTime");
            talkTime = talkTime > 0 ? 1 : 0;
            LocalDataUtils.SetStringData(firend.UserId + "BANNED_TALK_ALL" + Applicate.MyAccount.userId, talkTime.ToString());

            // ����Ⱥ����Ϣ����ʱ��
            string outtime = UIUtils.DecodeString(keyValues, "chatRecordTimeOut");
            LocalDataUtils.SetStringData(firend.UserId + "chatRecordTimeOut" + Applicate.MyAccount.userId, outtime);

            return firend;
            //"allowHostUpdate": 1,  // �Ƿ�����Ⱥ���޸�Ⱥ����
            //"chatRecordTimeOut":      ��Ϣ��������
            //"createTime": 1554106810, ����ʱ��
            //"isAttritionNotice": 1,Ⱥ���Ա֪ͨ
            //"isLook": 1, // �Ƿ񹫿�Ⱥ��
            //"modifyTime": 1554116921, // ���һ�η���ʱ��
            //"talkTime": 0, // ����ʱ��

            //"videoMeetingNo": "355228" // Ⱥ�����ַ
            //"call": "305228",// Ⱥ�����ַ

            //"areaId": 440307,
            //"category": 0,
            //"cityId": 440300,
            //"countryId": 1,
            //"provinceId": 440000,
            //"latitude": 22.608988,
            //"longitude": 114.066209,

            //"s": 1,// Ⱥ��״̬ -1 ���� 1 ����
        }


        /// <summary>
        ///������������б�����Ҫ���������к��Ѻ���ܵ���
        /// </summary>
        private void DownChatList()
        {
            // ��ȡ�������ʱ��
            string quitTime = LocalDataUtils.GetStringData(Applicate.QUIT_TIME);
            if (UIUtils.IsNull(quitTime))
            {
                quitTime = "1546315200000";
            }
            else
            {
                // ƫ��һ��ʱ����ֹͬһ���ʱ��
                quitTime = (Convert.ToDouble(quitTime) * 1000 - 5000).ToString();
            }

            //quitTime = Applicate.MyAccount.OfflineTime.ToString();

            //LogUtils.Log("down chat list ing start time: " + quitTime);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "tigase/getLastChatList")
                 .AddParams("access_token", Applicate.Access_Token)
                 .AddParams("startTime", quitTime)
                 .AddParams("pageSize", "100")
                 .NoErrorTip()
                 .Build().ExecuteList<JsonLastChats>((sccess, list) =>
                 {

                     if (sccess)
                     {
                         Task.Factory.StartNew(() =>
                         {
                             UpdateChatListData(list);
                             Console.WriteLine("down chat list compte........");
                         });
                     }
                     else
                     {
                         // ֪ͨ�����Ϣ�б�ˢ��
                         Messenger.Default.Send("0", MessageActions.DOWN_CHATLIST_COMPT);
                     }
                 });
        }

        /// <summary>
        /// ������ȡȺ��������Ϣ
        /// </summary>
        private void BatchJoinMucChat()
        {
            List<Friend> rooms = new Friend() { IsGroup = 1 }.GetFriendsByIsGroup();
            if (UIUtils.IsNull(rooms))
            {
                return;
            }

            long time = Applicate.MyAccount.OfflineTime * 1000;
            
            MessageHead head = new MessageHead();
            head.chatType = 2;
            head.from = mLoginUserId + "/" + ShiKuManager.Resource;
            head.to = "service";
            head.messageId = Guid.NewGuid().ToString("N");

            PullBatchGroupMessageReqProBuf batch = new PullBatchGroupMessageReqProBuf();

            foreach (var room in rooms)
            {
                batch.jidList.Add(room.UserId + "," + time);
                //if (last > 0)
                //{
                //    //  1564643426.304
                //    //long min = Math.Min(time, last);
                //    batch.jidList.Add(room.UserId + "," + time);
                //}
                //else
                //{
                //    batch.jidList.Add(room.UserId + "," + time);
                //}
            }
            batch.endTime = UIUtils.CurrentTimeMillis();
            batch.messageHead = head;
            mSocketCore.SendMessage(batch, Command.COMMAND_BATCH_JOIN_GROUP_REQ);

            Console.WriteLine("������ȡȺ��������Ϣ");
        }


        private void UpdateFriendLastContentTip(MessageObject msg)
        {
            msg.type = kWCMessageType.Remind;

            if (msg.InsertData() > 0)
            {
                msg.UpdateLastSend();
                NotifactionNormalMessage(msg);
            }
        }

        #endregion

        #region ===================ChatMessageת����MessageObject======================
        // ChatMessageת����MessageObject
        public MessageObject ToMessageObject(ChatMessage message)
        {
            MessageObject chat = new MessageObject();
            chat.fromUserId = message.fromUserId;
            chat.fromUserName = message.fromUserName;
            chat.toUserId = message.toUserId;
            chat.toUserName = message.toUserName;
            chat.timeSend = message.timeSend / 1000.0;

            //touserid Ϊ�վ����Լ�
            if (UIUtils.IsNull(chat.toUserId))
            {
                chat.toUserId = Applicate.MyAccount.userId;
            }

            if (UIUtils.IsNull(chat.toUserName))
            {
                chat.toUserName = Applicate.MyAccount.nickname;
            }

            if (chat.deleteTime > 0)
            {
                chat.deleteTime = message.deleteTime / 1000.0;
            }
            else
            {
                chat.deleteTime = message.deleteTime;
            }

            chat.type = (kWCMessageType)message.type;
            chat.isEncrypt = message.encryptType;
            // �����ϰ汾
            if (message.encryptType == 0 && message.isEncrypt)
            {
                chat.isEncrypt = 1;
            }
            chat.isReadDel = message.isReadDel ? 1 : 0;
            chat.content = message.content;
            chat.objectId = message.objectId;
            chat.fileName = message.fileName;
            chat.fileSize = message.fileSize;
            chat.timeLen = Convert.ToInt32(message.fileTime);
            chat.location_x = message.location_x;
            chat.location_y = message.location_y;

            MessageHead head = message.messageHead;

            // ��Ⱥ��ȫ�����ɵ��Ĵ���
            if (head.chatType == 2)
            {
                chat.isGroup = 1;
            }
            else
            {
                chat.isGroup = 0;
            }

            if (chat.isGroup == 1)
            {
                chat.FromId = message.toUserId;
                chat.ToId = mLoginUserId;
            }
            else
            {
                chat.FromId = chat.fromUserId;
                chat.ToId = head.to;
            }

            chat.messageId = head.messageId;

            // �ҵ��豸����Ϣ
            if (message.fromUserId.Equals(message.toUserId) && message.fromUserId.Equals(mLoginUserId))
            {
                string device = SplitDevice(head.from);
                if (!"Server".Equals(device))
                {
                    chat.FromId = device;
                    chat.ToId = mLoginUserId;
                    chat.fromUserName = chat.FromId;
                    chat.fromUserId = chat.FromId;
                }
            }

            return chat;
        }
        #endregion

        private string SplitDevice(string from)
        {
            if (!UIUtils.IsNull(from) && from.Contains("/"))
            {
                string[] value = from.Split('/');
                if (value.Length > 1)
                {
                    return value[1];
                }
                else
                {
                    return "";
                }
            }
            return "";
        }

        #region ===================MessageObjectת����ChatMessage======================
        // MessageObjectת����ChatMessage
        private ChatMessage ToChatMessage(MessageObject message)
        {
            ChatMessage chat = new ChatMessage();
            chat.fromUserId = message.fromUserId;
            chat.fromUserName = message.fromUserName;
            chat.toUserId = message.toUserId;
            chat.toUserName = message.toUserName;
            chat.timeSend = Convert.ToInt64(message.timeSend * 1000);
            if (message.deleteTime > 0)
            {
                chat.deleteTime = Convert.ToInt64(message.deleteTime * 1000); ;
            }
            else
            {
                chat.deleteTime = Convert.ToInt64(message.deleteTime);
            }

            chat.type = Convert.ToInt32(message.type);


            // ����
            chat.encryptType = message.isEncrypt;
            chat.isEncrypt = message.isEncrypt > 0;
            chat.isReadDel = message.isReadDel == 1;
            chat.content = message.content;
            chat.objectId = message.objectId;
            chat.fileName = message.fileName;
            chat.fileSize = message.fileSize;
            chat.fileTime = message.timeLen;
            chat.location_x = message.location_x;
            chat.location_y = message.location_y;

            MessageHead head = new MessageHead();
            head.messageId = message.messageId;
            head.chatType = message.isGroup + 1; // ����1�� Ⱥ��2
            head.from = message.FromId + "/" + ShiKuManager.Resource;

            if (message.fromUserId.Equals(message.toUserId))
            {
                // ���͸��ҵ��豸����Ϣ
                head.to = message.FromId + "/" + message.toUserName;
                chat.toUserName = message.fromUserName;
            }
            else
            {
                head.to = message.toUserId;
            }

            chat.messageHead = head;
            return chat;
        }
        #endregion
    }
}

