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
    /// Xmpp控制类
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

        #region 构造函数
        /// <summary>
        /// 构造函数：初始化XmppClientConnection对象
        /// </summary>
        internal XmppManager()
        {
            // 初始化消息队列
            MessageLooper.Interval = 500; // 0.5秒没有消息就去更新界面
            MessageLooper.Elapsed += new ElapsedEventHandler(OnMessageLoop);
            MessageLooper.AutoReset = false;   //设置是执行一次（false）还是一直执行(true)；
            MessageLooper.Enabled = true;     //是否执行System.Timers.Timer.Elapsed事件；

            string ip = Applicate.URLDATA.data.XMPPHost;
            string userId = Applicate.MyAccount.userId;
            string token = Applicate.Access_Token;

            // 初始化 设置ip port
            mSocketCore = new SocketCore(ip, 6666);//5666
            // 设置登录用户
            mSocketCore.SetLoginUser(token, userId);
            // 设置ping间隔时间 秒
            mSocketCore.PingTime = Applicate.URLDATA.data.xmppPingTime;
            // 设置socket状态回调
            mSocketCore.OnStateChanged += OnSocketStateChanged;
            // 设置收到消息回调
            mSocketCore.OnMessage += XmppCon_OnMessage;
            // 设置消息回执回调
            mSocketCore.OnReceipt += XmppCon_OnReceipt;
            // 设置连接断开回调
            //mSocketCore.OnClose += XmppCon_OnClose;

            mSocketCore.Connect();
        }

        #endregion

        #region 您已在其他设备登录
        /// <summary>
        /// 流错误时
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void LoginConflict()
        {
            var res = MessageBox.Show(Applicate.GetWindow<FrmMain>(), "您已在其他设备登录,请重新登录！", "其他设备登录提示");
            ShiKuManager.ApplicationExit();
            Application.Restart();
        }

        #endregion

        #region --------------OnXmppStateChanged----------------
        /// <summary>
        /// Xmpp连接状态改变时 
        /// <param name="sender"></param>
        /// <param name="state"></param>
        public void OnSocketStateChanged(SocketConnectionState state)
        {
            LogUtils.Log("------OnSocketStateChanged：" + state);

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
                    // 去下载最近消息列表
                    DownChatList();
        
                    // 同步其他设备操作数据
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

        #region XMPP连接关闭时
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

        #region 收到消息回执
        /// <summary>
        /// 收到消息回执  
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
                // 敏感词
                XmppReceiptManager.Instance.OnReceiveReceipt(XmppReceiptManager.RECEIPT_ERR_DIS, messageid);
            }
            else
            {
                XmppReceiptManager.Instance.OnReceiveReceipt(XmppReceiptManager.RECEIPT_ERR, messageid);
            }
        }
        #endregion

        #region XmppCon_OnMessage接收到消息---------------------------
        /// <summary>
        /// Xmpp接收到信息时  
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="xmppMsg"></param>
        public void XmppCon_OnMessage(ChatMessage chat)
        {
            //协议消息ChatMessage 转换成 pc消息实体MessageObject
            MessageObject message = ToMessageObject(chat);

            Console.WriteLine("XmppCon_OnMessage " + chat.type + " ,  id" + chat.messageHead.messageId);

            // 判断是否离线消息
            bool isOfflieMsg = chat.messageHead.offline;
            message.isSend = 1;//已送达: 收到的消息都是成功的消息

            if (message.isEncrypt > 0)
            {
                // 消息解密
                if (!UIUtils.IsNull(message.content))
                {
                    DES.DecryptMessage(message, chat.timeSend);
                }

                message.isEncrypt = 0;
            }

            if (message.isGroup == 1 && isOfflieMsg)
            {
                // 群聊离线消息
                Console.WriteLine("群聊离线消息");

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

        // xmpp 收到消息
        private void DoMessage(MessageObject msg, bool isOfflieMsg)
        {
            if (msg.type == kWCMessageType.IsRead)
            {
                ProcessReadMessage(msg);//处理已读消息
                return;
            }

            // 正在输入
            if (msg.type == kWCMessageType.Typing)
            {
                if (!msg.IsMySend())
                {
                    Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);
                }

                return;
            }
            //申请建立会话
            if (msg.type == kWCMessageType.CustomerBuiltConnnect)
            {
                var content = "您好我是客户" + msg.fromUserName + ",很高兴为您服务，请问有什么问题可以帮您的?";
                var friend = msg.GetFriend();

                ShiKuManager.SendTextMessage(friend, content);
                return;
            }
            // 双向删除
            if (msg.type == kWCMessageType.SYNC_CLEAN)
            {
                Messenger.Default.Send(msg.fromUserId, MessageActions.CLEAR_FRIEND_MSGS);
                HttpUtils.Instance.ShowTip(msg.fromUserName + " 清除了您与他的聊天记录");
                return;
            }

            // 截图
            if (msg.type == kWCMessageType.TYPE_SCREENSHOT)
            {
                HttpUtils.Instance.ShowTip(msg.fromUserName + "正在对您的阅后即焚消息截图");
                return;
            }

            //群控制消息
            if (msg.type >= kWCMessageType.RoomMemberNameChange && msg.type <= kWCMessageType.RoomNoticeEdit)
            {
                ProcessGroupManageMessage(msg, isOfflieMsg);//处理群聊控制消息
            }

            //新朋友验证消息
            if (msg.type >= kWCMessageType.FriendRequest && msg.type <= kWCMessageType.PhoneContactToFriend)
            {
                ProcessFriendVerifyMessage(msg);//新朋友验证消息
                return;
            }

            //群文件消息
            if (msg.type >= kWCMessageType.RoomFileUpload && msg.type <= kWCMessageType.RoomFileDownload)
            {
                ProcessGroupFileMessage(msg);//群文件消息
                return;
            }

            //音视频消息
            if (msg.type >= kWCMessageType.AudioChatAsk && msg.type <= kWCMessageType.AudioMeetingSetSpeaker)
            {
                ProcessPhoneCallMessage(msg);//音视频消息
                return;
            }

            // 特殊的消息类型显示 。 合并转发，戳一戳，图文
            if (msg.type >= kWCMessageType.ImageTextSingle && msg.type <= kWCMessageType.TYPE_93)
            {
                ProcessSpecialMessage(msg);//特殊的消息类型显示
                return;
            }

            // 多设备同步消息
            if (msg.type >= kWCMessageType.Device_SYNC_OTHER && msg.type <= kWCMessageType.Device_SYNC_GROUP)
            {
                if (msg.InsertData() > 0)//数据库成功插入
                {
                    ProcessDeviceSyncMessage(msg, isOfflieMsg);//多设备同步消息
                }
                return;
            }

            // 端到端加密相关消息
            if (msg.type >= kWCMessageType.TYPE_SECURE_REFRESH_KEY && msg.type <= kWCMessageType.TYPE_SECURE_NOTIFY_REFRESH_KEY)
            {
                /* 端到端加密相关消息 */
                ProcessSecureMessage(msg);
             
                return;
            }

            // 支付凭证
            if (msg.type == kWCMessageType.TYPE_PAY_CERTIFICATE)
            {
                return;
            }

            // 撤回消息
            if (msg.type == kWCMessageType.Withdraw)
            {
                /* 此处应修改消息内容为"xx撤回了一条消息" */
                ProcessRecallMessage(msg);
                return;
            }
            
            // 红包消息
            if (msg.type == kWCMessageType.RedPacket || msg.type == kWCMessageType.TRANSFER)
            {
                if (!Applicate.ENABLE_RED_PACKAGE)//没有开启红包
                {
                    msg.content = msg.type == kWCMessageType.RedPacket ? "收到红包请在手机端查看" : "收到转账请在手机端查看";
                    UpdateFriendLastContentTip(msg);
                    return;
                }
            }

            // 被后台删除（删除该好友账户）
            if (msg.type == kWCMessageType.TYPE_REMOVE_ACCOUNT)
            {
                var tmpFriend = new Friend() { UserId = msg.objectId }.GetByUserId();
                // 设置为被删除
                tmpFriend.UpdateFriendState(tmpFriend.UserId, Friend.STATUS_26);
                // 清空消息记录
                msg.FromId = tmpFriend.UserId;
                msg.ToId = msg.myUserId;
                msg.DeleteTable();
                // 通知界面刷新
                Messenger.Default.Send(tmpFriend, MessageActions.DELETE_FRIEND);
                // 显示提示
                HttpUtils.Instance.ShowTip("服务器删除了" + tmpFriend.NickName);
                // 更新新的朋友未读数量
                //Messenger.Default.Send(Friend.ID_NEW_FRIEND, FriendListLayout.NOTIFY_FRIENDLIST_UNREAD_COUNT);
                return;
            }
            //后台删除好友(解除用户与好友关系)
            if (msg.type == kWCMessageType.TYPE_DELETEFRIENDS)
            {
                var list = JsonConvert.DeserializeObject<Dictionary<string, object>>(msg.objectId);
                string fromUserId = UIUtils.DecodeString(list, "fromUserId");
                string fromUserName = UIUtils.DecodeString(list, "fromUserName");
                string toUserId = UIUtils.DecodeString(list, "toUserId");
                string toUserName = UIUtils.DecodeString(list, "toUserName");
                
                var tmpFriend = new Friend() { UserId = toUserId }.GetByUserId();
                // 设置为被删除
                tmpFriend.UpdateFriendState(tmpFriend.UserId, Friend.STATUS_26);
                // 清空消息记录
                msg.FromId = tmpFriend.UserId;
                msg.ToId = msg.myUserId;
                msg.DeleteTable();
                // 通知界面刷新
                Messenger.Default.Send(tmpFriend, MessageActions.DELETE_FRIEND);
                // 显示提示
                HttpUtils.Instance.ShowTip("服务器解除了你与" + tmpFriend.NickName + "的好友关系");
                // 更新新的朋友未读数量
                //Messenger.Default.Send(Friend.ID_NEW_FRIEND, FriendListLayout.NOTIFY_FRIENDLIST_UNREAD_COUNT);
                return;
            }
            //后台加入黑名单
            if (msg.type == kWCMessageType.TYPE_JOINBLACKLIST)
            {
                var list = JsonConvert.DeserializeObject<Dictionary<string, object>>(msg.objectId);
                string fromUserId = UIUtils.DecodeString(list, "fromUserId");
                string fromUserName = UIUtils.DecodeString(list, "fromUserName");
                string toUserId = UIUtils.DecodeString(list, "toUserId");
                string toUserName = UIUtils.DecodeString(list, "toUserName");
                Friend friend = new Friend { UserId = toUserId }.GetByUserId();

                ShiKuManager.SendBlockfriend(friend);//发送拉黑好友推送
            }
            //从黑名单移除
            if (msg.type == kWCMessageType.TYPE_MOVE_BALACKLIST)
            {
                var list = JsonConvert.DeserializeObject<Dictionary<string, object>>(msg.objectId);
                string fromUserId = UIUtils.DecodeString(list, "fromUserId");
                string fromUserName = UIUtils.DecodeString(list, "fromUserName");
                string toUserId = UIUtils.DecodeString(list, "toUserId");
                string toUserName = UIUtils.DecodeString(list, "toUserName");
                Friend friend = new Friend { UserId = toUserId }.GetByUserId();

                ShiKuManager.SendCancelBlockFriendMsg(friend);//发送取消拉黑好友推送
            }
            
            // 容错处理
            if (string.IsNullOrEmpty(msg.content))
            {
                return;
            }
            
            // 能走到这里就是普通消息了
            if (msg.InsertData() > 0)//数据库成功插入
            {
                msg.UpdateLastSend();
                NotifactionNormalMessage(msg);//  通知UI  //通知各页面收到消息
            }
            
            // @群成员消息 必须要等消息存了之后才能去发广播
            if (msg.isGroup == 1 && msg.type == kWCMessageType.Text && (!string.IsNullOrEmpty(msg.objectId)))
            {
                Friend room = msg.GetFriend();
                if (room != null && room.IsAtMe == 0)
                {
                    if (room.UserId.Equals(msg.objectId))
                    {
                        // @全体成员
                        room.UpdateAtMeState(2);
                        LocalDataUtils.SetStringData(room.UserId + "GROUP_AT_MESSAGEID" + msg.myUserId, msg.messageId);
                        Messenger.Default.Send(room, MessageActions.ROOM_UPDATE_AT_ME);//通知界面刷新
                    }
                    else if (msg.objectId.Contains(msg.myUserId))
                    {
                        // 我被@了
                        room.UpdateAtMeState(1);
                        LocalDataUtils.SetStringData(room.UserId + "GROUP_AT_MESSAGEID" + msg.myUserId, msg.messageId);
                        Messenger.Default.Send(room, MessageActions.ROOM_UPDATE_AT_ME);//通知界面刷新
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
                // 更新UI消息发送失败标志 消息已发送失败 参数 
                Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_SEND_FAILED);
                return;
            }

            if (!HttpUtils.Instance.AvailableNetwork())
            {
                msg.isSend = -1;
                msg.UpdateIsSend(-1, msg.messageId);
                // 更新UI消息发送失败标志 消息已发送失败 参数 
                Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_SEND_FAILED);
                return;
            }

            MessageObject chatMessage = msg.CopyMessage();

            // 消息加密传输
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

            // 是否是发给我的设备的消息
            if (msg.toUserId.Equals("android") || msg.toUserId.Equals("ios") || msg.toUserId.Equals("web") || msg.toUserId.Equals("mac"))
            {
                chatMessage.toUserName = msg.toUserId;
                chatMessage.toUserId = msg.fromUserId;
            }

            // 修改禅道bug # 8033
            if (chatMessage.type == kWCMessageType.File)
            {
                chatMessage.fileName = FileUtils.GetFileName(chatMessage.fileName);
            }

            ChatMessage chat = ToChatMessage(chatMessage);
            // 添加到回执管理器
            XmppReceiptManager.Instance.AddWillSendMessage(msg);
            mSocketCore.SendMessage(chat, Command.COMMAND_CHAT_REQ);
            Console.WriteLine("发送消息" + chat.content);
        }


        #region ========================================================消息处理模块=================================================
        /// <summary>
        /// 新朋友验证相关消息处理
        /// </summary>
        /// <param name="msg">消息</param>
        private void ProcessFriendVerifyMessage(MessageObject msg)
        {
            if (msg.IsExist())
            {
                return;
            }

            // 做一个容错处理
            var tmpFriend = msg.GetFriend();
            if (tmpFriend == null || string.IsNullOrEmpty(tmpFriend.UserId))
            {
                tmpFriend = new Friend()
                {
                    UserId = msg.fromUserId,
                    IsGroup = 0,
                    NickName = msg.fromUserName,
                };

                tmpFriend.InsertAuto();//添加对应好友至数据库
            }
            
            switch (msg.type)
            {
                case kWCMessageType.DeleteFriend://被删除
                    // 显示提示
                    if (string.Equals(msg.fromUserId, msg.myUserId))
                    {
                        HttpUtils.Instance.ShowTip("已删除" + tmpFriend.NickName);
                        // 设置把删除
                        tmpFriend.UpdateFriendState(tmpFriend.UserId, Friend.STATUS_16);
                    }
                    else
                    {
                        HttpUtils.Instance.ShowTip("我已被" + tmpFriend.NickName + "删除");
                        // 设置为被删除
                        tmpFriend.UpdateFriendState(tmpFriend.UserId, Friend.STATUS_17);
                    }

                    // 通知界面刷新
                    Messenger.Default.Send(tmpFriend, MessageActions.DELETE_FRIEND);
                    // 清空消息记录
                    msg.DeleteTable();
                    // 更新新的朋友未读数量
                    Messenger.Default.Send(Friend.ID_NEW_FRIEND, FriendListLayout.NOTIFY_FRIENDLIST_UNREAD_COUNT);
                    break;
                case kWCMessageType.BlackFriend://被拉黑

                    // 显示提示
                    if (string.Equals(msg.fromUserId, msg.myUserId))
                    {
                        HttpUtils.Instance.ShowTip("已拉黑" + tmpFriend.NickName);
                        // 设置为被拉黑
                        tmpFriend.UpdateFriendState(tmpFriend.UserId, Friend.STATUS_18);
                    }
                    else
                    {
                        HttpUtils.Instance.ShowTip("我已被" + tmpFriend.NickName + "拉黑");
                        // 设置为被拉黑
                        tmpFriend.UpdateFriendState(tmpFriend.UserId, Friend.STATUS_19);
                    }

                    // 通知界面刷新
                    Messenger.Default.Send(tmpFriend, MessageActions.ADD_BLACKLIST);

                    // 清空消息记录
                    msg.DeleteTable();
                    // 更新新的朋友未读数量
                    Messenger.Default.Send(Friend.ID_NEW_FRIEND, FriendListLayout.NOTIFY_FRIENDLIST_UNREAD_COUNT);
                    break;
                case kWCMessageType.RequestRefuse://对方回话
                case kWCMessageType.FriendRequest://对方请求添加我
                                                  // 更新新的朋友未读数量
                    Messenger.Default.Send(Friend.ID_NEW_FRIEND, FriendListLayout.NOTIFY_FRIENDLIST_UNREAD_COUNT);
                    break;
                case kWCMessageType.RequestFriendDirectly://直接添加好友
                case kWCMessageType.RequestAgree://被同意
                case kWCMessageType.CancelBlackFriend://被对方取消黑名单
                case kWCMessageType.PhoneContactToFriend://被对方从手机联系人直接添加成好友

                    MessageObject tip = msg.CopyMessage();
                    tip.type = kWCMessageType.Remind;
                    tip.content = "你们已经成为好友，快来聊天吧";
                    if (tip.InsertData() == 1)
                    {
                        Console.WriteLine("保存成功");
                    }//保存提示消息

                    tmpFriend.BecomeFriend(msg.type);

                    // 更新聊天记录页
                    Messenger.Default.Send(tip, MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);
                    Messenger.Default.Send(tip, MessageActions.XMPP_SHOW_SINGLE_MESSAGE);

                    //添加至好友列表
                    Messenger.Default.Send(tmpFriend.UserId, FriendListLayout.ADD_EXISTS_FRIEND);
                    // 更新新的朋友未读数量
                    Messenger.Default.Send(Friend.ID_NEW_FRIEND, FriendListLayout.NOTIFY_FRIENDLIST_UNREAD_COUNT);

                    break;
                default:
                    break;
            }

            // 刷新新的朋友界面
            if (string.Equals(msg.fromUserId, msg.myUserId))
            {
                Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_VERIFY_RECEPIT);// 更新UI消息发送失败标志 消息已发送失败 参数 messageObject
            }
            else
            {
                NotifactionVerifyMessage(msg);
            }
        }
        
        // 撤回消息处理
        private void ProcessRecallMessage(MessageObject msg)
        {
            // 存库防止消息重复处理
            //msg.InsertData();

            string content = msg.fromUserId.Equals(mLoginUserId) ? "你" : msg.fromUserName;
            content += "撤回了一条消息";
            msg.messageId = msg.content;
            MessageObject oMsg = msg.GetMessageObject();
            
            if (string.Equals(msg.fromUserId, msg.myUserId))
            {
                if (string.Equals(oMsg.fromUserId, oMsg.myUserId))
                {
                    content = "你撤回了一条消息";
                }
                else
                {
                    content = "你撤回了 " + UIUtils.QuotationName(oMsg.fromUserName) + "的一条消息";
                }
            }
            else
            {
                if (string.Equals(oMsg.fromUserId, oMsg.myUserId))
                {
                    content = UIUtils.QuotationName(msg.fromUserName) + "撤回了一条你的消息";
                }
                else
                {
                    if (string.Equals(oMsg.fromUserId, msg.fromUserId))
                    {
                        content = UIUtils.QuotationName(msg.fromUserName) + "撤回了一条消息";
                    }
                    else
                    {
                        content = UIUtils.QuotationName(msg.fromUserName) + "撤回了一条成员的消息";
                    }
                }
            }

            oMsg.content = content;
            oMsg.type = kWCMessageType.Remind;

            // 去更新撤回消息
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
        /// 处理音视频聊天消息
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

            // 修改禅道7474问题，web挂断消息出现在公众号的问题
            if ("10000".Equals(msg.toUserId))
            {
                return;
            }

            Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_MEETING_MESSAGE);//

            switch (msg.type)
            {
                case kWCMessageType.AudioChatCancel://
                    msg.content = "取消了语音通话";
                    UpdateFriendLastContentTip(msg);
                    break;
                case kWCMessageType.AudioChatEnd://
                    msg.content = "结束了语音通话：" + TimeUtils.FromatCountdown(msg.timeLen);
                    UpdateFriendLastContentTip(msg);
                    break;
                case kWCMessageType.VideoChatCancel://
                    msg.content = "取消了视频通话";
                    UpdateFriendLastContentTip(msg);
                    break;
                case kWCMessageType.VideoChatEnd://
                    msg.content = "结束了视频通话：" + TimeUtils.FromatCountdown(msg.timeLen);
                    UpdateFriendLastContentTip(msg);
                    break;
                case kWCMessageType.AudioMeetingSetSpeaker://
                    msg.content = "对方忙线中";
                    UpdateFriendLastContentTip(msg);
                    break;
            }
        }

        /// <summary>
        /// 处理红包相关消息
        /// </summary>
        /// <param name="msg"></param>
        private void ProcessMoenyMessage(MessageObject msg)
        {
            switch (msg.type)
            {
                case kWCMessageType.RedBack:
                    msg.content = "有红包退回请在手机端查看";
                    break;
                case kWCMessageType.TYPE_TRANSFER_RECEIVE://删除群文件
                    msg.content = "转账已被领取请在手机端查看";
                    break;
                case kWCMessageType.TYPE_93:
                    msg.content = "收到收款消息请在手机端查看";
                    break;
                case kWCMessageType.TYPE_TRANSFER_BACK:
                    msg.content = "转账已退回请在手机端查看";
                    break;
                default:
                    msg.content = "暂不支持此类型的消息显示";
                    break;
            }

            UpdateFriendLastContentTip(msg);
        }

        /// <summary>
        /// 处理红包相关消息
        /// </summary>
        /// <param name="msg"></param>
        private void ProcessSpecialMessage(MessageObject msg)
        {
            // 红包 转账相关消息 
            if (msg.type >= kWCMessageType.RedBack && msg.type <= kWCMessageType.TYPE_93)
            {
                switch (msg.type)
                {
                    case kWCMessageType.RedBack:
                        msg.content = "有红包退回请在手机端查看";
                        break;
                    case kWCMessageType.TYPE_TRANSFER_RECEIVE:
                        msg.content = "转账已被领取请在手机端查看";
                        break;
                    case kWCMessageType.TYPE_93:
                        msg.content = "收到收款消息请在手机端查看";
                        break;
                    case kWCMessageType.TYPE_TRANSFER_BACK:
                        msg.content = "转账已退回请在手机端查看";
                        break;
                    default:
                        msg.content = "暂不支持此类型的消息显示";
                        break;
                }

                UpdateFriendLastContentTip(msg);
                return;
            }

            // 特殊消息类型显示
            switch (msg.type)
            {
                case kWCMessageType.ImageTextSingle:
                case kWCMessageType.ImageTextMany:
                    if (msg.InsertData() > 0)//数据库成功插入
                    {
                        msg.UpdateLastSend();
                        NotifactionNormalMessage(msg);//  通知UI  //通知各页面收到消息
                    }
                    break;
                case kWCMessageType.PokeMessage:
                    msg.content = "暂不支持此消息类型的显示";
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
                        seetext = ",请在手机上查看";
                    }
                    if (msg.fromUserId.Equals(msg.myUserId))
                    {
                        fromName = "你";
                    }
                    else
                    {
                        fromName = msg.fromUserName;
                    }

                    if (msg.toUserId.Equals(msg.myUserId) || msg.fromUserId.Equals(msg.toUserId))
                    {
                        if (msg.fromUserId.Equals(msg.myUserId))
                        {
                            toName = "自己";
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
                    msg.content = fromName + "领取了" + toName + "的红包" + seetext;
                    UpdateFriendLastContentTip(msg);
                    break;
                case kWCMessageType.History:

                    if (msg.InsertData() > 0)//数据库成功插入
                    {
                        msg.UpdateLastSend();
                        NotifactionNormalMessage(msg);//  通知UI  //通知各页面收到消息
                    }

                    break;
            }
        }

        /// <summary>
        /// 已读消息的处理
        /// </summary>
        /// <param name="msg"></param>
        private void ProcessReadMessage(MessageObject msg)
        {
            // 先去找到我发出的这条消息
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
                        Messenger.Default.Send(target, MessageActions.XMPP_UPDATE_RECEIVED_READ);//已读消息的处理
                    }
                }
            }
            else
            {
                if (msg.InsertData() > 0)
                {
                    if (target.isReadDel == 1)
                    {
                        // 对方查看了我的一条阅后即焚消息
                        var friend = target.GetFriend();
                        friend.UpdateLastContent("对方查看了我的一条阅后即焚消息", msg.timeSend);
                        // 刷新最后一条聊天记录
                        NotifactionListSingleMessage(target);
                    }

                    // 去更新已读
                    if (target.UpdateIsRead(msg.content) > 0)
                    {
                        Messenger.Default.Send(target, MessageActions.XMPP_UPDATE_RECEIVED_READ);//已读消息的处理
                    }
                }
            }
        }

        /// <summary>
        /// 群文件消息处理
        /// </summary>
        /// <param name="msg"></param>     
        public void ProcessGroupFileMessage(MessageObject msg)
        {
            Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_ROOM_CHANGE_MESSAGE);
            // 更新最后一条消息内容，通知UI刷新
            switch (msg.type)
            {
                case kWCMessageType.RoomFileUpload://上传群文件
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + "上传了群文件:" + msg.fileName;
                    break;
                case kWCMessageType.RoomFileDelete://删除群文件
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + "删除了群文件:" + msg.fileName;
                    break;
                case kWCMessageType.RoomFileDownload://下载群文件
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + "下载了群文件:" + msg.fileName;
                    break;
                default:
                    break;
            }

            UpdateFriendLastContentTip(msg);
        }

        /// <summary>
        /// 群控制消息处理
        /// <para>
        /// RoomMemberNameChange和RoomManagerTransfer之间的群设置消息
        /// 先执行数据库操作再执行UI
        /// </para>
        /// </summary>
        /// <param name="msg">对应的处理消息</param>
        private void ProcessGroupManageMessage(MessageObject msg, bool deley)
        {
            var room = new Friend();
            room.RoomId = msg.fileName;//RoomId
            room.UserId = msg.objectId;//设置RoomJid
            room.NickName = msg.content;
            msg.FromId = msg.objectId;
            msg.ToId = mLoginUserId;
            msg.isGroup = 1;
            room.IsGroup = 1;

            switch (msg.type)
            {
                case kWCMessageType.RoomMemberNameChange://改群内昵称

                    // 通知聊天记录页刷新
                    NotifactionRoomControlMsg(msg);

                    room = msg.GetFriend();
                    var mem = new RoomMember() { userId = msg.toUserId, roomId = room.RoomId, nickName = msg.content };
                    mem.UpdateMemberNickname();

                    // 更新最后一条消息内容，通知UI刷新
                    msg.content = UIUtils.QuotationName(msg.toUserName) + "修改昵称为:" + UIUtils.QuotationName(msg.content);

                    msg.type = kWCMessageType.Remind;
                    if (msg.InsertData() > 0)
                    {
                        msg.UpdateLastSend();

                        NotifactionNormalMessage(msg);
                    }
                    break;
                case kWCMessageType.RoomNameChange://改群名

                    // 通知聊天记录页刷新
                    NotifactionRoomControlMsg(msg);

                    room = msg.GetFriend();
                    room.NickName = msg.content;
                    room.UpdateNickName();

                    msg.content = UIUtils.QuotationName(msg.fromUserName) + "修改群名为:" + UIUtils.QuotationName(msg.content);

                    msg.type = kWCMessageType.Remind;

                    if (msg.InsertData() > 0)
                    {
                        msg.UpdateLastSend();
                        NotifactionNormalMessage(msg);
                    }
                    break;
                case kWCMessageType.RoomDismiss://解散

                    if (msg.InsertData() > 0)
                    {
                        // xmpp退出群组
                        ExitRoom(msg.objectId);
                        // 从朋友表中删除
                        room.DeleteByUserId();
                        // 通知界面更新
                        Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_ROOM_DELETE);

                        Messenger.Default.Send(room, MessageActions.DELETE_FRIEND);
                    }

                    //// 我是群主,我把一个群解散了
                    //if (msg.myUserId.Equals(msg.fromUserId))
                    //{
                    //    // 从朋友表中删除
                    //    room.DeleteByUserId();
                    //}
                    //else
                    //{
                    //    //room.UpdateFriendState(0);
                    //    // 从朋友表中删除
                    //    room.DeleteByUserId();
                    //    // 通知聊天记录页刷新
                    //    // NotifactionRoomControlMsg(msg);
                    //    // 这个群被群组解散
                    //    msg.type = kWCMessageType.Remind;
                    //    msg.content = "该群已被群主解散";

                    //    if (msg.InsertData() > 0)
                    //    {
                    //        msg.UpdateLastSend();
                    //        NotifactionNormalMessage(msg);
                    //    }
                    //}

                    // 通知界面更新
                    //Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_ROOM_DELETE);

                    break;
                case kWCMessageType.RoomExit://退群

                    room = msg.GetFriend();

                    if (room == null || room.Status != 2)
                    {
                        return;
                    }

                    // 我退出群组，或者我被t出
                    if (msg.toUserId.Equals(msg.myUserId))
                    {
                        // xmpp退出群组
                        ExitRoom(msg.objectId);

                        // 从朋友表中删除
                        room.DeleteByUserId();
                        // 通知界面更新
                        Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_ROOM_DELETE);

                        Messenger.Default.Send(room, MessageActions.DELETE_FRIEND);

                        msg.InsertData();
                        //// xmpp 退出群组
                        //Presence pres = new Presence();
                        //pres.From = new Jid(Applicate.MyAccount.userId, XmppCon.MyJID.Server, "pc");
                        //pres.To = new Jid(room.RoomId, "muc." + XmppCon.MyJID.Server, "thirdwitch");
                        //pres.Type = PresenceType.unavailable;
                        //XmppCon.Send(pres);

                        // 删除聊天记录表

                        // 更新界面 我主动退出
                        //Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_ROOM_DELETE);
                        //// 删除朋友
                        //room.DeleteByUserId();
                        //NotifactionListSingleMessage(msg);
                    }
                    else
                    {
                        // 通知聊天记录页刷新
                        NotifactionRoomControlMsg(msg);
                        //5d6643240c03d001805233ca

                        //某群员退出了群聊
                        room = msg.GetFriend();
                        RoomMember roomMembers = new RoomMember();
                        roomMembers.roomId = room.RoomId;

                        if (msg.fromUserId.Equals(msg.toUserId) || msg.fromUserName.Equals(msg.toUserName))
                        {
                            msg.content = UIUtils.QuotationName(msg.fromUserName) + "退出了群组";
                            roomMembers.userId = msg.fromUserId;
                            roomMembers = roomMembers.GetRommMember();
                            roomMembers.DeleteByUserId();
                        }
                        else
                        {
                            msg.content = UIUtils.QuotationName(msg.fromUserName) + "移除成员:" + UIUtils.QuotationName(msg.toUserName);
                            roomMembers.userId = msg.toUserId;
                            roomMembers = roomMembers.GetRommMember();
                            roomMembers.DeleteByUserId();
                        }

                        Messenger.Default.Send(room.RoomId, MessageActions.UPDATE_HEAD);//发送刷新头像通知

                        UpdateFriendLastContentTip(msg);
                    }

                    break;
                case kWCMessageType.RoomNotice://公告

                    // 通知聊天记录页刷新
                    NotifactionRoomControlMsg(msg);// -- 放开这个d代码会有卡死的风险

                    // 更新最后一条消息内容，通知UI刷新
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + "发布新公告: \n" + msg.content;
                    UpdateFriendLastContentTip(msg);

                    break;
                case kWCMessageType.RoomInvite://进群

                    // 通知聊天记录页刷新
                    NotifactionRoomControlMsg(msg);

                    string desc = "";

                    if (msg.fromUserId.Equals(msg.toUserId))
                    {
                        desc = UIUtils.QuotationName(msg.fromUserName) + "进入群组";
                    }
                    else
                    {
                        desc = UIUtils.QuotationName(msg.fromUserName) + "邀请成员:" + UIUtils.QuotationName(msg.toUserName);
                    }

                    Console.WriteLine("join  :" + desc);

                    bool isExistsRoom = room.ExistsFriend();
                    if (isExistsRoom) // 如果我已经在群里了
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
                            JoinRoom(msg.objectId, 0);//Xmpp加入群聊(处理完群组后加入)
                        }
                        msg.UpdateLastSend();
                        NotifactionNormalMessage(msg);
                    }
                    
                    if (!isExistsRoom) // && !deley
                    {
                        Messenger.Default.Send(room, MessageActions.ROOM_UPDATE_INVITE);//刷新列表
                    }
                    else
                    {
                        Messenger.Default.Send(room.RoomId, MessageActions.UPDATE_HEAD);//发送刷新头像通知
                    }

                    break;
                case kWCMessageType.RoomReadVisiblity://显示阅读人数

                    // 通知聊天记录页刷新
                    NotifactionRoomControlMsg(msg);
                    
                    room = msg.GetFriend();
                    room.ShowRead = int.Parse(msg.content);
                    room.UpdateShowRead();

                    if (room.ShowRead == 1)
                    {
                        msg.content = UIUtils.QuotationName(msg.fromUserName) + "开启了显示消息已读人数功能";
                    }
                    else
                    {
                        msg.content = UIUtils.QuotationName(msg.fromUserName) + "关闭了显示消息已读人数功能";
                    }

                    msg.type = kWCMessageType.Remind;
                    if (msg.InsertData() > 0)
                    {
                        msg.UpdateLastSend();
                        NotifactionNormalMessage(msg);
                    }
                    //更新群聊是否显示人数  room.UpdateShowRead(int.Parse(msg.content));
                    break;
                case kWCMessageType.RoomIsVerify://群验证


                    // 通知聊天记录页刷新
                    NotifactionRoomControlMsg(msg);

                    if ("0".Equals(msg.content) || "1".Equals(msg.content))
                    {
                        room.IsNeedVerify = int.Parse(msg.content);
                        room.UpdateNeedVerify();
                        msg.content = room.IsNeedVerify == 0 ? " 已关闭进群验证" : " 已开启进群验证";
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
                            msg.content = msg.fromUserName + "申请加入";//自己主动加入
                        }
                        else
                        {
                            msg.content = msg.fromUserName + "想邀请" + userids.Length + "位朋友加入群聊";
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
                case kWCMessageType.RoomUnseenRole://隐身人

                    // 通知聊天记录页刷新
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
                            msg.content = UIUtils.QuotationName(msg.fromUserName) + "设置隐身人" + UIUtils.QuotationName(msg.toUserName);
                        }
                        else
                        {
                            msg.content = UIUtils.QuotationName(msg.fromUserName) + "取消隐身人" + UIUtils.QuotationName(msg.toUserName);
                        }

                        msg.type = kWCMessageType.Remind;
                        if (msg.InsertData() > 0)
                        {
                            msg.UpdateLastSend();
                            NotifactionNormalMessage(msg);
                        }
                    }


                    break;
                case kWCMessageType.RoomAdmin://管理员

                    // 通知聊天记录页刷新
                    NotifactionRoomControlMsg(msg);


                    if (msg.content == "0")//取消管理员
                    {
                        msg.content = UIUtils.QuotationName(msg.fromUserName) + "取消管理员" + UIUtils.QuotationName(msg.toUserName);
                    }
                    else if (msg.content == "1")//设置管理员8
                    {
                        msg.content = UIUtils.QuotationName(msg.fromUserName) + "设置:" + UIUtils.QuotationName(msg.toUserName) + "为管理员";
                    }

                    // 更新最后一条消息内容，通知UI刷新
                    msg.type = kWCMessageType.Remind;

                    if (msg.InsertData() > 0)
                    {
                        msg.UpdateLastSend();
                        NotifactionNormalMessage(msg);
                    }

                    break;
                case kWCMessageType.RoomIsPublic://公开群

                    // 通知聊天记录页刷新
                    NotifactionRoomControlMsg(msg);
                    msg.content = msg.content == "0" ? " 将本群修改为公开群组" : " 将本群修改为私密群组";
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + msg.content;
                    // 更新最后一条消息内容，通知UI刷新
                    UpdateFriendLastContentTip(msg);

                    break;
                case kWCMessageType.RoomInsideVisiblity://显示群内成员
                                                        // 通知聊天记录页刷新
                    NotifactionRoomControlMsg(msg);
                    room.UpdateShowMember(int.Parse(msg.content));
                    msg.content = msg.content == "0" ? " 关闭了查看群成员功能" : " 开启了查看群成员功能";
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + msg.content;
                    // 更新最后一条消息内容，通知UI刷新
                    UpdateFriendLastContentTip(msg);

                    break;
                case kWCMessageType.RoomUserRecommend://是否允许发送名片
                    NotifactionRoomControlMsg(msg); // 通知聊天记录页刷新
                    room.UpdateAllowSendCard(int.Parse(msg.content));//
                    msg.content = msg.content == "0" ? " 关闭了群内私聊功能" : " 开启了群内私聊功能";
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + msg.content;
                    // 更新最后一条消息内容，通知UI刷新
                    UpdateFriendLastContentTip(msg);
                    break;
                case kWCMessageType.RoomMemberBan://禁言成员

                    double banTime = double.Parse(msg.content);

                    if (msg.myUserId.Equals(msg.toUserId)) // 我被禁言
                    {
                        if (banTime > TimeUtils.CurrentTime() + 3)
                        {
                            LocalDataUtils.SetStringData(room.UserId + "BANNED_TALK" + msg.myUserId, msg.content);
                        }
                        else
                        {
                            // 取消禁言
                            LocalDataUtils.SetStringData(room.UserId + "BANNED_TALK" + msg.myUserId, "0");
                        }

                        Messenger.Default.Send(msg, MessageActions.ROOM_UPDATE_BANNED_TALK);
                    }


                    if (banTime > TimeUtils.CurrentTime() + 3)
                    {
                        var date = Helpers.StampToDatetime(banTime);
                        string time = date.Month + "-" + date.Day + " " + date.Hour + ":" + date.Minute;
                        msg.content = UIUtils.QuotationName(msg.fromUserName) + "对" + UIUtils.QuotationName(msg.toUserName) + "设置了禁言,截止:" + time;
                    }
                    else
                    {
                        msg.content = UIUtils.QuotationName(msg.toUserName) + "已被" + UIUtils.QuotationName(msg.fromUserName) + "取消禁言";
                    }

                    // 更新最后一条消息内容，通知UI刷新
                    UpdateFriendLastContentTip(msg);

                    break;
                case kWCMessageType.RoomAllBanned://群组全员禁言 

                    LocalDataUtils.SetStringData(room.UserId + "BANNED_TALK_ALL" + msg.myUserId, msg.content);
                    if (!deley)
                    {
                        Messenger.Default.Send(msg, MessageActions.ROOM_UPDATE_BANNED_TALK);
                    }

                    msg.content = msg.content == "0" ? "已关闭全体禁言" : "已开启全体禁言";
                    // 更新最后一条消息内容，通知UI刷新
                    UpdateFriendLastContentTip(msg);

                    break;
                case kWCMessageType.RoomAllowMemberInvite://是否允许群内普通成员邀请陌生人
                    NotifactionRoomControlMsg(msg); // 通知聊天记录页刷新
                    room.UpdateAllowInviteFriend(int.Parse(msg.content));
                    msg.content = msg.content == "0" ? " 关闭了普通成员邀请功能" : " 开启了普通成员邀请功能";
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + msg.content;

                    // 更新最后一条消息内容，通知UI刷新
                    UpdateFriendLastContentTip(msg);

                    break;
                case kWCMessageType.RoomManagerTransfer://转让群主
                    NotifactionRoomControlMsg(msg); // 通知聊天记录页刷新

                    msg.content = UIUtils.QuotationName(msg.toUserName) + "已成为新群主";
                    // 更新最后一条消息内容，通知UI刷新
                    UpdateFriendLastContentTip(msg);

                    room = msg.GetFriend();
                    var oldroomhost = new RoomMember() { userId = msg.fromUserId, roomId = room.RoomId, role = 3 };
                    oldroomhost.UpdateRole();//
                                             // 修改群组创建人id
                    var member = new RoomMember() { userId = msg.toUserId, roomId = room.RoomId, role = 1 };
                    member.UpdateRole();
                    member.userId = msg.fromUserId;
                    member.role = 1;

                    break;
                case kWCMessageType.RoomAllowUploadFile://是否允许成员上传群文件
                    NotifactionRoomControlMsg(msg); // 通知聊天记录页刷新

                    room.UpdateAllowUploadFile(int.Parse(msg.content));
                    msg.content = msg.content == "0" ? " 关闭了普通成员上传群共享" : " 开启了普通成员上传群共享";
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + msg.content;
                    // 更新最后一条消息内容，通知UI刷新
                    UpdateFriendLastContentTip(msg);

                    break;
                case kWCMessageType.RoomAllowConference://是否允许群会议
                    NotifactionRoomControlMsg(msg); // 通知聊天记录页刷新 
                    room.UpdateAllowConference(int.Parse(msg.content));
                    msg.content = msg.content == "0" ? " 关闭了普通成员发起会议功能" : " 开启了普通成员发起会议功能";
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + msg.content;
                    // 更新最后一条消息内容，通知UI刷新
                    UpdateFriendLastContentTip(msg);

                    break;
                case kWCMessageType.RoomAllowSpeakCourse://是否允许群成员开课

                    NotifactionRoomControlMsg(msg); // 通知聊天记录页刷新 
                    room.UpdateAllowSpeakCourse(int.Parse(msg.content));
                    msg.content = msg.content == "0" ? " 关闭了普通成员发送课件功能" : " 开启了普通成员发送课件功能";
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + msg.content;
                    // 更新最后一条消息内容，通知UI刷新
                    UpdateFriendLastContentTip(msg);
                    break;
                case kWCMessageType.RoomNewOverDate://群消息过期
                    LogUtils.Log("收到群消息过期   " + msg.content);
                    LocalDataUtils.SetStringData(msg.roomJid + "chatRecordTimeOut" + Applicate.MyAccount.userId, msg.content);
                    break;
                case kWCMessageType.RoomNoticeEdit://编辑群公告
                                                   // 通知聊天记录页刷新
                    NotifactionRoomControlMsg(msg);

                    // 更新最后一条消息内容，通知UI刷新
                    msg.content = UIUtils.QuotationName(msg.fromUserName) + "修改了群公告:\n" + msg.content;
                    UpdateFriendLastContentTip(msg);

                    break;
                default:
                    return;
            }

        }

        #endregion

        #region 多点登录同步消息处理
        /// <summary>
        /// 多点登录同步消息处理
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

                    Console.WriteLine("其他端修改了登陆密码");
                }
                else if (SYNC_PAY_PASSWORD.Equals(msg.objectId))
                {
                    Console.WriteLine("其他端修改了支付密码");
                }
                else if (SYNC_PRIVATE_SETTINGS.Equals(msg.objectId))
                {
                    Console.WriteLine("其他端修改了隐私设置");
                }
                else if (SYNC_LABEL.Equals(msg.objectId))
                {
                    Console.WriteLine("其他端修改了标签");
                }
            }
            else if (msg.type == kWCMessageType.Device_SYNC_FRIEND)
            {
                if (string.Equals(msg.toUserId, msg.myUserId))
                {
                    Console.WriteLine("多点登录同步--->更新自己的信息");
                }
                else
                {
                    Console.WriteLine("多点登录同步--->更新好友的信息");
                    HandleFriendUpdate(msg.toUserId);
                }
            }
            else if (msg.type == kWCMessageType.Device_SYNC_GROUP)
            {
                if (!isOfflieMsgppMsg)
                {
                    Console.WriteLine("多点登录同步--->更新群组的信息");
                    HandleGroupUpdate(msg.toUserId);
                }
            }
        }

        /// <summary>
        /// 密码已被修改需重新登录
        /// </summary>
        private void UpdatePwdRestart()
        {
            HttpUtils.Instance.ShowTip("密码已被修改需重新登录");

            //登录记住密码清空
            Configuration cfa = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            cfa.AppSettings.Settings["passWord"].Value = String.Empty;
            cfa.Save();
            ShiKuManager.ApplicationExit();
            LocalDataUtils.SetStringData(Applicate.QUIT_TIME, TimeUtils.CurrentIntTime().ToString());
            //此处调用退出接口
            Application.ExitThread();
            Application.Exit();
            Application.Restart();
            Process.GetCurrentProcess().Kill();
        }
        #endregion

        #region 端到端加密通讯消息处理
        /// <summary>
        /// 端到端加密通讯消息处理
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

            LogUtils.Save("==========未处理的端到端协议===========\n" + msg.ToJson(true));
        }


        #endregion

        #region ========================================================通知模块========================================================  

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
                // 一次性更新多条 参数 List<MessageObject>
                NotifactionListAllMessage(mssageList);
            }
            else
            {
                // 单条刷新 参数 MessageObject
                NotifactionListSingleMessage(mssageList[0]);
            }

            mssageList.Clear();// 清理消息队列
        }

        public void NotifactionListAllMessage(List<MessageObject> messages)
        {
            LogUtils.Log("xmpp 通知 更新项 all");
            Messenger.Default.Send(messages, MessageActions.XMPP_SHOW_ALL_MESSAGE);
        }
        
        public void NotifactionListSingleMessage(MessageObject messages)
        {
            Messenger.Default.Send(messages, MessageActions.XMPP_SHOW_SINGLE_MESSAGE);
        }
        
        /// <summary>
        /// 普通消息的通知
        /// </summary>
        /// <param name="msg"></param>
        public void NotifactionNormalMessage(MessageObject msg)
        {
            // 消息排队机制 -> 针对与消息列表
            if (mssageList.Count > 0)
            {
                mssageList.Add(msg); // 已经启动过计时器了，直接往列表里加消息就可以
                MessageLooper.Stop();
                MessageLooper.Start();
            }
            else
            {
                MessageLooper.Start();// 启动定时器 -> 0.5秒后调用 OnMessageLoop 更新列表
                mssageList.Add(msg);
            }

            // 更新聊天记录页
            Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);
        }

        /// <summary>
        /// 撤回消息的通知
        /// </summary>
        /// <param name="msg"></param>
        public void NotifactionRecallMessage(MessageObject msg)
        {
            Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_RECALL_MESSAGE);//通知各页面收到消息
        }

        /// <summary>
        ///  
        /// </summary>
        /// <param name="msg"></param>
        public void NotifactionVerifyMessage(MessageObject msg)
        {
            Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_VERIFY_MESSAGE);//朋友验证相关消息通知
        }

        /// <summary>
        /// 群控制相关消息通知
        /// </summary>
        /// <param name="msg"></param>
        public void NotifactionRoomControlMsg(MessageObject msg)
        {
            Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_ROOM_CHANGE_MESSAGE);//群控制相关消息通知
        }

        /// <summary>
        /// 音视频协议相关消息通知
        /// </summary>
        /// <param name="msg"></param>
        public void NotifactionMeetingMessage(MessageObject msg)
        {
            Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_MEETING_MESSAGE);//收到了一个音视频协议消息
        }

        #endregion

        #region ========================================================群组相关========================================================

        /// <summary>
        /// 创建群组
        /// </summary>
        /// <param name="roomName">群名字</param>
        /// <param name="description">群描述</param>
        /// <returns>roomJid</returns>
        public string CreateGroup(string roomName, string description)
        {
            string jid = Guid.NewGuid().ToString("N");

            JoinRoom(jid, 0);

            return jid;
        }

        /// <summary>
        /// 加入群聊
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

            Console.WriteLine("发送加入群组消息");
        }

        /// <summary>
        /// 退出群组
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
            Console.WriteLine("发送退出群组消息");
        }


        #endregion

        #region ========================================================内部方法========================================================

        //private void StartBatchReceiptTread()
        //{
        //    Task.Factory.StartNew(() =>
        //    {
        //        while (true)
        //        {
        //            Thread.Sleep(1000);
        //            timeCount++;
        //            // 每隔5秒 | 消息数超过50 发一次回执
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
        /// 发送批量消息回执(送达)
        /// </summary>
        /// <param name="recivemsg">信息的UID</param>
        /// <param name="From">接收回执者</param>
        /// <param name="to">发送回执者</param>
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
            Console.WriteLine("发送回执消息消息");
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

                // 聊天记录漫游
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
                            Console.WriteLine("生成离线任务");
                        }
                        else
                        {
                            // 本地没有记录， 直接就是正常的漫游逻辑
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

            // 批量拉取群聊离线消息
            BatchJoinMucChat();
        }

        public void SyscMultiDeviceData()
        {
            // 获取最后离线时间
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


        //更新好友的信息
        private void HandleFriendUpdate(string userId)
        {
            if (userId.Equals(Applicate.MyAccount.userId))
            {
                // 更新自己的数据
                //handleSelfUpdate();
                return;
            }

            Console.WriteLine("多点登录同步--->更新好友的信息" + userId);

            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/get")
                   .AddParams("access_token", Applicate.Access_Token)
                   .AddParams("userId", userId)
                   .Build().Execute((suus, data) =>
                   {
                       if (suus)
                       {
                           Friend jsonFriend = JsonConvert.DeserializeObject<Friend>(JsonConvert.SerializeObject(data)); //使用Friend解析出来

                           //服务器存在关系 新增本地数据
                           if (data.ContainsKey("friends"))
                           {
                               // 解析服务器数据
                               AttentionFriend attention = JsonConvert.DeserializeObject<AttentionFriend>(data["friends"].ToString());
                               jsonFriend.Status = attention.ToFriendStatus();
                               jsonFriend.RemarkName = attention.remarkName;

                               // 获取本地数据
                               Friend local = new Friend() { UserId = userId }.GetFdByUserId();
                               // 本地不存在， 新增
                               if (local == null || UIUtils.IsNull(local.NickName))
                               {
                                   // 本地不存在新增
                                   jsonFriend.TopTime = attention.openTopChatTime;
                                   jsonFriend.InsertAuto();

                                   //添加至好友列表
                                   if (jsonFriend.Status == Friend.STATUS_FRIEND || jsonFriend.Status == 4)
                                   {
                                       Messenger.Default.Send(jsonFriend.UserId, FriendListLayout.ADD_EXISTS_FRIEND);
                                   }
                               }
                               else
                               {
                                   if (!string.Equals(local.RemarkName, jsonFriend.RemarkName))
                                   {
                                       // 其他设备更新了好友备注
                                       local.RemarkName = jsonFriend.RemarkName;
                                       local.UpdateRemarkName();
                                       Messenger.Default.Send(local, MessageActions.UPDATE_FRIEND_REMARKS);
                                   }


                                   local.UpdateFriendState(jsonFriend.Status);
                                   // 本地存在，更新状态
                                   if (jsonFriend.Status == Friend.STATUS_FRIEND || jsonFriend.Status == 4)//是好友关系
                                   {
                                       Messenger.Default.Send(local.UserId, FriendListLayout.ADD_EXISTS_FRIEND);
                                   }

                                   if (jsonFriend.Status == Friend.STATUS_UNKNOW)//是好友关系
                                   {
                                       Messenger.Default.Send(local, MessageActions.DELETE_FRIEND);
                                   }


                                   if (jsonFriend.Status == Friend.STATUS_UNKNOW || jsonFriend.Status == Friend.STATUS_UNKNOW)//是好友关系
                                   {
                                       Messenger.Default.Send(local, MessageActions.ADD_BLACKLIST);
                                   }

                                   // 更新消息保存天数
                                   LocalDataUtils.SetStringData(local.UserId + "chatRecordTimeOut" + Applicate.MyAccount.userId, attention.chatRecordTimeOut.ToString());

                                   // 刷新阅后即焚状态
                                   if (local.IsOpenReadDel != attention.isOpenSnapchat)
                                   {
                                       local.IsOpenReadDel = attention.isOpenSnapchat;
                                       local.UpdateReadDel();
                                       Messenger.Default.Send(local, MessageActions.UPDATE_FRIEND_READDEL);//刷新列表
                                   }

                                   // 刷新免打扰状态
                                   if (attention.offlineNoPushMsg != local.Nodisturb)
                                   {
                                       local.Nodisturb = attention.offlineNoPushMsg;
                                       local.UpdateNodisturb();
                                       Messenger.Default.Send(local, MessageActions.UPDATE_FRIEND_DISTURB);//刷新列表
                                   }


                                   // 刷新置顶状态
                                   if (attention.openTopChatTime > 0 && local.TopTime > 0)
                                   {
                                       // 本地和服务器状态一致 不要刷新
                                       return;
                                   }

                                   if (attention.openTopChatTime == 0 && local.TopTime == 0)
                                   {
                                       // 本地和服务器状态一致 不要刷新
                                       return;
                                   }


                                   Console.WriteLine("更新置顶状态 " + attention.openTopChatTime);
                                   // 更新置顶状态
                                   local.TopTime = attention.openTopChatTime;
                                   local.UpdateTopTime(local.TopTime);
                                   Messenger.Default.Send(local, MessageActions.UPDATE_FRIEND_TOP);
                               }
                           }
                           else
                           {
                               // 服务器不存在关系 删除本地数据
                               Friend local = new Friend() { UserId = userId }.GetFdByUserId();
                               if (local != null)
                               {
                                   local.UpdateFriendState(Friend.STATUS_UNKNOW);
                                   // 通知界面刷新
                                   Messenger.Default.Send(local, MessageActions.DELETE_FRIEND);
                               }
                           }
                       }
                   });

        }

        //更新群组的信息
        public void HandleGroupUpdate(string roomId)
        {
            Console.WriteLine("多点登录同步--->更新群组的信息");

            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/getRoom") //获取群详情
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("roomId", roomId)
                    .NoErrorTip()
                    .Build().Execute((success, result) =>
                    {
                        if (success)
                        {
                            Friend friend = DecodeFriend(result);

                            // 我在此群的状态
                            string roomByme = UIUtils.DecodeString(result, "member"); ;
                            if (UIUtils.IsNull(roomByme))
                            {
                                // 被踢出群组
                                if (friend != null)
                                {
                                    // xmpp退出群组
                                    ExitRoom(friend.UserId);
                                    // 从朋友表中删除
                                    friend.DeleteByUserId();
                                    // 通知界面更新
                                    MessageObject msg = new MessageObject()
                                    { type = kWCMessageType.RoomExit, FromId = friend.UserId, ToId = Applicate.MyAccount.userId };
                                    Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_ROOM_DELETE);
                                }
                            }
                            else
                            {
                                if (friend.ExistsFriend())
                                {   // 更新

                                }
                                else
                                {
                                    // 创建
                                    friend.Status = Friend.STATUS_FRIEND;
                                    friend.InsertAuto();
                                    long seconds = TimeUtils.CurrentTime() - friend.CreateTime;
                                    JoinRoom(friend.UserId, seconds);
                                    Messenger.Default.Send(friend, MessageActions.ROOM_UPDATE_INVITE);//刷新列表
                                }
                            }
                        }
                        else
                        {
                            // 该群组被解散了
                            Friend friend = new Friend().GetFriendByRoomId(roomId);
                            if (friend != null)
                            {
                                // xmpp退出群组
                                ExitRoom(friend.UserId);
                                // 从朋友表中删除
                                friend.DeleteByUserId();
                                // 通知界面更新
                                MessageObject msg = new MessageObject() { FromId = friend.UserId, ToId = mLoginUserId, type = kWCMessageType.RoomExit };
                                Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_ROOM_DELETE);
                            }
                        }
                    });
        }


        /// <summary>
        /// 群组信息接口数据 转成 friend 
        /// </summary>
        /// <param name="result"></param>
        private Friend DecodeFriend(Dictionary<string, object> keyValues)
        {

            Friend firend = new Friend();

            //是否显示群已读
            firend.ShowRead = UIUtils.DecodeInt(keyValues, "showRead");
            // 显示群成员
            firend.ShowMember = UIUtils.DecodeInt(keyValues, "showMember");
            // 允许普通群成员私聊
            firend.AllowSendCard = UIUtils.DecodeInt(keyValues, "allowSendCard");
            //允许普通群成员邀请好友
            firend.AllowInviteFriend = UIUtils.DecodeInt(keyValues, "allowInviteFriend");
            //允许普通群成员上传文件
            firend.AllowUploadFile = UIUtils.DecodeInt(keyValues, "allowUploadFile");
            //允许普通群成员召开会议
            firend.AllowConference = UIUtils.DecodeInt(keyValues, "allowConference");
            //允许普通群成员发起讲课
            firend.AllowSpeakCourse = UIUtils.DecodeInt(keyValues, "allowSpeakCourse");
            //是否开启群主验证
            firend.IsNeedVerify = UIUtils.DecodeInt(keyValues, "isNeedVerify");

            //"name": "飞飞",
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

            // 获取禁言状态
            long talkTime = UIUtils.DecodeLong(keyValues, "talkTime");
            talkTime = talkTime > 0 ? 1 : 0;
            LocalDataUtils.SetStringData(firend.UserId + "BANNED_TALK_ALL" + Applicate.MyAccount.userId, talkTime.ToString());

            // 设置群聊消息过期时间
            string outtime = UIUtils.DecodeString(keyValues, "chatRecordTimeOut");
            LocalDataUtils.SetStringData(firend.UserId + "chatRecordTimeOut" + Applicate.MyAccount.userId, outtime);

            return firend;
            //"allowHostUpdate": 1,  // 是否允许群主修改群属性
            //"chatRecordTimeOut":      消息保存天数
            //"createTime": 1554106810, 创建时间
            //"isAttritionNotice": 1,群组减员通知
            //"isLook": 1, // 是否公开群组
            //"modifyTime": 1554116921, // 最后一次发言时间
            //"talkTime": 0, // 禁言时间

            //"videoMeetingNo": "355228" // 群会议地址
            //"call": "305228",// 群会议地址

            //"areaId": 440307,
            //"category": 0,
            //"cityId": 440300,
            //"countryId": 1,
            //"provinceId": 440000,
            //"latitude": 22.608988,
            //"longitude": 114.066209,

            //"s": 1,// 群组状态 -1 锁定 1 正常
        }


        /// <summary>
        ///下载最近聊天列表，必须要下载完所有好友后才能调用
        /// </summary>
        private void DownChatList()
        {
            // 获取最后离线时间
            string quitTime = LocalDataUtils.GetStringData(Applicate.QUIT_TIME);
            if (UIUtils.IsNull(quitTime))
            {
                quitTime = "1546315200000";
            }
            else
            {
                // 偏移一点时间差，防止同一秒的时间
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
                         // 通知最近消息列表刷新
                         Messenger.Default.Send("0", MessageActions.DOWN_CHATLIST_COMPT);
                     }
                 });
        }

        /// <summary>
        /// 批量拉取群聊离线消息
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

            Console.WriteLine("批量拉取群聊离线消息");
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

        #region ===================ChatMessage转换成MessageObject======================
        // ChatMessage转换成MessageObject
        public MessageObject ToMessageObject(ChatMessage message)
        {
            MessageObject chat = new MessageObject();
            chat.fromUserId = message.fromUserId;
            chat.fromUserName = message.fromUserName;
            chat.toUserId = message.toUserId;
            chat.toUserName = message.toUserName;
            chat.timeSend = message.timeSend / 1000.0;

            //touserid 为空就是自己
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
            // 兼容老版本
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

            // 非群聊全部当成单聊处理
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

            // 我的设备的消息
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

        #region ===================MessageObject转换成ChatMessage======================
        // MessageObject转换成ChatMessage
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


            // 加密
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
            head.chatType = message.isGroup + 1; // 单聊1， 群聊2
            head.from = message.FromId + "/" + ShiKuManager.Resource;

            if (message.fromUserId.Equals(message.toUserId))
            {
                // 发送给我的设备的消息
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

