using agsXMPP;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PBMessage;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using TestSocket.socket;
using WinFrmTalk.Dictionarys;
using WinFrmTalk.Model;
using WinFrmTalk.socket;

namespace WinFrmTalk
{
    /// <summary>
    /// 此类是关于咕喃的一系列业务操作
    /// </summary>
    internal static class ShiKuManager
    {
        /// <summary>
        /// Xmpp管理类
        /// </summary>
        public static XmppManager mSocketCore;

        public static string Resource { get; set; }

        private static long lastInput;

        #region 初始化XMPP连接
        /// <summary>
        /// 初始化XMPP连接对象
        /// </summary>
        /// <param name="curruser">当前的用户对象</param>
        /// <param name="Pwd">用户密码</param>
        public static void InitialXmpp()
        {
            Resource = MultiDeviceManager.Instance.IsEnable ? "pc" : "youjob";
            //实例化XmppManager类
            mSocketCore = new XmppManager();
        }
        #endregion

        #region 获取xmpp当前状态
        /// <summary>
        /// 获取xmpp状态
        /// </summary>
        /// <returns></returns>
        public static SocketConnectionState GetXmppState()
        {
            if (mSocketCore == null)
            {
                return SocketConnectionState.Disconnected;
            }

            return mSocketCore.ConnectState;
        }


        /// <summary>
        /// 判断当前xmpp是否在线
        /// </summary>
        /// <returns></returns>
        public static bool IsAuthenticated()
        {
            return GetXmppState() == SocketConnectionState.Authenticated;
        }
        #endregion

        #region 退出程序
        /// <summary>
        /// 退出程序
        /// </summary>
        internal static void ApplicationExit()
        {
            ////停止xmpp连接
            mSocketCore.Disconnect();
            //接口退出登陆
            UserHttpLoginout(Applicate.MyAccount.userId);
        }
        #endregion

        // xmpp发送消息
        public static void SendMessage(MessageObject messageObject)
        {
            SnedMessageObject(messageObject);
        }

        public static void SnedMessageObject(MessageObject messageObject)
        {
            mSocketCore.SendMessage(messageObject);
        }

        #region =========================发送好友验证消息=================================

        // 打招呼
        internal static void SendHelloFriendMsg(Friend toFriend)
        {
            MessageObject message = new MessageObject();
            message.ToId = toFriend.UserId;
            message.FromId = Applicate.MyAccount.userId;
            message.toUserId = toFriend.UserId;//接收者
            message.toUserName = toFriend.NickName;
            message.fromUserId = Applicate.MyAccount.userId;
            message.fromUserName = Applicate.MyAccount.nickname;//这里放自己的昵称
            message.type = kWCMessageType.FriendRequest;
            message.timeSend = TimeUtils.CurrentTimeDouble();
            message.messageId = Guid.NewGuid().ToString("N");//生成Guid
            message.content = "您好";
            message.reSendCount = 3;
            SnedMessageObject(message);//指定发送的UserId
        }


        #region 好友验证时回话
        /// <summary>
        /// 好友验证时回话
        /// </summary>
        /// <param name="target">需回话的UserId</param>
        internal static void SendAnswerBack(string content, Friend target)
        {
            MessageObject jsonMsg = new MessageObject();
            jsonMsg.FromId = Applicate.MyAccount.userId;
            jsonMsg.ToId = target.UserId;
            jsonMsg.fromUserId = Applicate.MyAccount.userId;//UserId
            jsonMsg.fromUserName = Applicate.MyAccount.nickname;//自己的昵称
            jsonMsg.toUserId = target.UserId;//指定接收者
            jsonMsg.toUserName = target.NickName;//接收者名称
            jsonMsg.content = content;//内容
            jsonMsg.type = kWCMessageType.RequestRefuse;//回话消息
            jsonMsg.messageId = Guid.NewGuid().ToString("N");//MessageId
            jsonMsg.timeSend = TimeUtils.CurrentTimeDouble();
            //jsonMsg.Insert();//存入数据库
            SnedMessageObject(jsonMsg);
        }
        #endregion

        // 回话
        internal static void SendReplyFriendMsg(Friend toFriend, string content)
        {
            MessageObject message = new MessageObject();
            message.ToId = toFriend.UserId;
            message.FromId = Applicate.MyAccount.userId;
            message.toUserId = toFriend.UserId;//接收者
            message.toUserName = toFriend.NickName;
            message.fromUserId = Applicate.MyAccount.userId;
            message.fromUserName = Applicate.MyAccount.nickname;//这里放自己的昵称
            message.type = kWCMessageType.RequestAgree;
            message.timeSend = TimeUtils.CurrentTimeDouble();
            message.messageId = Guid.NewGuid().ToString("N");//生成Guid
            message.content = content;
            SnedMessageObject(message);//指定发送的UserId
        }

        // 通过验证
        internal static void SendAgreeFriendMsg(Friend toFriend)
        {
            MessageObject message = new MessageObject();
            message.ToId = toFriend.UserId;
            message.FromId = Applicate.MyAccount.userId;
            message.toUserId = toFriend.UserId;//接收者
            message.toUserName = toFriend.NickName;
            message.fromUserId = Applicate.MyAccount.userId;
            message.fromUserName = Applicate.MyAccount.nickname;//这里放自己的昵称
            message.type = kWCMessageType.RequestAgree;
            message.timeSend = TimeUtils.CurrentTimeDouble();
            message.messageId = Guid.NewGuid().ToString("N");//生成Guid
            SnedMessageObject(message);//指定发送的UserId
        }

        // 直接成为好友（对方没有开启好友验证）    
        internal static void SendBecomeFriendMsg(Friend toFriend)
        {
            MessageObject message = new MessageObject();
            message.ToId = toFriend.UserId;
            message.FromId = Applicate.MyAccount.userId;
            message.toUserId = toFriend.UserId;//接收者
            message.toUserName = toFriend.NickName;
            message.fromUserId = Applicate.MyAccount.userId;
            message.fromUserName = Applicate.MyAccount.nickname;//这里放自己的昵称
            message.type = kWCMessageType.RequestFriendDirectly;
            message.timeSend = TimeUtils.CurrentTimeDouble();
            message.messageId = Guid.NewGuid().ToString("N");//生成Guid
            SnedMessageObject(message);//指定发送的UserId
        }

        // 删除好友    
        internal static void SendDelFriendMsg(Friend toFriend)
        {
            MessageObject message = new MessageObject();
            message.ToId = toFriend.UserId;
            message.FromId = Applicate.MyAccount.userId;
            message.toUserId = toFriend.UserId;//接收者
            message.toUserName = toFriend.NickName;
            message.fromUserId = Applicate.MyAccount.userId;
            message.fromUserName = Applicate.MyAccount.nickname;//这里放自己的昵称
            message.type = kWCMessageType.DeleteFriend;
            message.timeSend = TimeUtils.CurrentTimeDouble();
            message.messageId = Guid.NewGuid().ToString("N");//生成Guid
            SnedMessageObject(message);//指定发送的UserId
        }

        // 拉黑好友  
        internal static void SendBlockfriend(Friend toFriend)
        {
            MessageObject message = new MessageObject();
            message.ToId = toFriend.UserId;
            message.FromId = Applicate.MyAccount.userId;
            message.toUserId = toFriend.UserId;//接收者
            message.toUserName = toFriend.NickName;
            message.fromUserId = Applicate.MyAccount.userId;
            message.fromUserName = Applicate.MyAccount.nickname;//这里放自己的昵称
            message.type = kWCMessageType.BlackFriend;
            message.timeSend = TimeUtils.CurrentTimeDouble();
            message.messageId = Guid.NewGuid().ToString("N");//生成Guid
            SnedMessageObject(message);//指定发送的UserId
        }
        // 取消拉黑好友    
        internal static void SendCancelBlockFriendMsg(Friend toFriend)
        {
            MessageObject message = new MessageObject();
            message.ToId = toFriend.UserId;
            message.FromId = Applicate.MyAccount.userId;
            message.toUserId = toFriend.UserId;//接收者
            message.toUserName = toFriend.NickName;
            message.fromUserId = Applicate.MyAccount.userId;
            message.fromUserName = Applicate.MyAccount.nickname;//这里放自己的昵称
            message.type = kWCMessageType.CancelBlackFriend;
            message.timeSend = TimeUtils.CurrentTimeDouble();
            message.messageId = Guid.NewGuid().ToString("N");//生成Guid
            SnedMessageObject(message);//指定发送的UserId
        }

        #endregion


        #region =========================发送可见类型的消息=================================

        // 发送文字消息 | 发送Emoji表情
        internal static MessageObject SendTextMessage(Friend toFriend, string content, bool sendmsg = true)
        {
            MessageObject message = GetMessageObject(toFriend);
            message.type = kWCMessageType.Text;
            message.content = content;

            if (toFriend.IsGroup == 0 && toFriend.IsOpenReadDel == 1)
            {
                message.isReadDel = 1;
                Console.WriteLine("发送了一条阅后即焚消息 ： " + content);
            }

            message.InsertData();//存库

            if (sendmsg)
            {
                SnedMessageObject(message);//指定发送的UserId
            }
            return message;
        }

        // 发送图片消息
        internal static MessageObject SendImageMessage(Friend toFriend, string url, string path, int size, bool sendmsg = true)
        {
            MessageObject message = GetMessageObject(toFriend);
            message.type = kWCMessageType.Image;
            message.content = url;
            message.fileName = path;
            message.fileSize = size;
            //获取像素
            if (File.Exists(path))
            {
                using (Bitmap bmp = new Bitmap(path))
                {
                    message.location_x = bmp.Width;
                    message.location_y = bmp.Height;
                }
            }

            if (toFriend.IsGroup == 0 && toFriend.IsOpenReadDel == 1)
            {
                message.isReadDel = 1;
                Console.WriteLine("发送了一条阅后即焚图片");
            }

            message.InsertData();//存库           
            if (sendmsg)
            {
                SnedMessageObject(message);//指定发送的UserId
            }
            return message;
        }


        // 发送视频消息
        internal static MessageObject SendVideoMessage(Friend toFriend, string url, string path, long size, bool sendmsg = true)
        {
            MessageObject message = GetMessageObject(toFriend);
            message.type = kWCMessageType.Video;
            message.content = url;
            message.fileName = path;
            message.fileSize = size;

            if (toFriend.IsGroup == 0 && toFriend.IsOpenReadDel == 1)
            {
                message.isReadDel = 1;
                Console.WriteLine("发送了一条阅后即焚视频");
            }

            message.InsertData();//存库
            if (sendmsg)
            {
                SnedMessageObject(message);//指定发送的UserId
            }
            return message;
        }
        /// <summary>
        /// 发送语音消息
        /// </summary>
        /// <param name="toFriend"></param>
        /// <param name="url"></param>
        /// <param name="path"></param>
        /// <param name="size"></param>
        /// <param name="sendmsg"></param>
        /// <returns></returns>
        internal static MessageObject SendVoiceMessage(Friend toFriend, string url, string path, long size, int timeLen, bool sendmsg = true)
        {
            MessageObject message = GetMessageObject(toFriend);
            message.type = kWCMessageType.Voice;
            message.content = url;
            message.fileName = path;
            message.fileSize = size;
            message.timeLen = timeLen;

            if (toFriend.IsGroup == 0 && toFriend.IsOpenReadDel == 1)
            {
                message.isReadDel = 1;
                Console.WriteLine("发送了一条阅后即焚录音");
            }

            message.InsertData();//存库
            if (sendmsg)
            {
                SnedMessageObject(message);//指定发送的UserId
            }
            return message;
        }


        // 发送文件消息
        internal static MessageObject SendFileMessage(Friend toFriend, string url, string path, long size, bool sendmsg = true)
        {
            MessageObject message = GetMessageObject(toFriend);
            message.type = kWCMessageType.File;
            message.content = url;
            message.fileName = path;
            message.fileSize = size;
            message.InsertData();//存库
            if (sendmsg)
            {
                SnedMessageObject(message);//指定发送的UserId
            }
            return message;
        }

        // 发送视酷GIF表情（其他的Gif一律使用图片消息发送）
        internal static MessageObject SendGifMessage(Friend toFriend, string content, bool sendmsg = true)
        {
            MessageObject message = GetMessageObject(toFriend);
            message.type = kWCMessageType.Gif;
            message.content = content;
            message.InsertData();//存库
            if (sendmsg)
            {
                SnedMessageObject(message);//指定发送的UserId
            }
            return message;
        }

        // 发送好友名片
        internal static MessageObject SendCardMessage(Friend toFriend, Friend friend, bool sendmsg = true)
        {
            MessageObject message = GetMessageObject(toFriend);
            message.type = kWCMessageType.Card;
            message.content = friend.NickName;
            message.objectId = friend.UserId;
            message.InsertData();//存库
            if (sendmsg)
            {
                SnedMessageObject(message);//指定发送的UserId
            }
            return message;

        }


        /**
         * 发送群消息前验证
         * 1.全体禁言
         * 2.我被禁言
         * return true 不允许发送消息
         **/

        public static bool SendRoomMsgVerify(Friend toFriend)
        {
            if (toFriend.IsGroup == 0)
            {
                return false;
            }

            if (UIUtils.IsNull(toFriend.RoomId) || UIUtils.IsNull(toFriend.UserId))
            {
                return false;
            }

            // 获取我在群里边的身份
            int role = RoomMemberDao.Instance.GetRoleByUserId(toFriend.RoomId, Applicate.MyAccount.userId);
            //管理员和群主除外
            if (role != 1 && role != 2)
            {
                // 获取全体禁言情况
                string all = LocalDataUtils.GetStringData(toFriend.UserId + "BANNED_TALK_ALL" + Applicate.MyAccount.userId, "0");
                if (!"0".Equals(all))
                {
                    return true;
                }

                //是否单个禁言
                string single = LocalDataUtils.GetStringData(toFriend.UserId + "BANNED_TALK" + Applicate.MyAccount.userId, "0");
                if (!"0".Equals(single))
                {
                    return true;
                }

                return false;
            }
            else
            {
                return false;
            }
        }



        // 发送At消息
        internal static MessageObject SendAtMessage(Friend toFriend, List<Friend> atUsers, string content, bool sendmsg = true)
        {
            MessageObject message = GetMessageObject(toFriend);

            string objectId = "";
            if (atUsers == null || atUsers.Count == 0)
            {
                // @全体成员
                objectId = toFriend.UserId;
            }
            else
            {
                // @某成员
                StringBuilder sb = new StringBuilder();
                foreach (var item in atUsers)
                {
                    sb.Append(item.UserId);
                    sb.Append(" ");
                }
                sb.Remove(sb.Length - 1, 1);
                objectId = sb.ToString();
            }

            message.content = content;
            message.objectId = objectId;
            message.type = kWCMessageType.Text;
            message.InsertData();//存库
            if (sendmsg)
            {
                SnedMessageObject(message);//指定发送的UserId
            }
            return message;
        }


        // 发送回复消息
        internal static MessageObject SendReplayMessage(Friend toFriend, MessageObject replayMsg, string content, bool sendmsg = true)
        {
            MessageObject message = GetMessageObject(toFriend);
            message.content = content;
            message.objectId = replayMsg.ToJson(true);
            message.type = kWCMessageType.Replay;

            if (toFriend.IsGroup == 0 && toFriend.IsOpenReadDel == 1)
            {
                message.isReadDel = 1;
                LogUtils.Log("发送了一条阅后即焚录音");
            }

            message.InsertData();//存库
            if (sendmsg)
            {
                SnedMessageObject(message);//指定发送的UserId
            }
            return message;
        }

        // 发送位置消息
        internal static MessageObject SendLocationMessage(Friend toFriend, double latitude, double longitude, string address, bool sendmsg = true)
        {
            MessageObject message = GetMessageObject(toFriend);
            message.location_x = longitude;
            message.location_y = latitude;
            message.objectId = address;
            message.content = ("https://api.map.baidu.com/staticimage?width=400&height=140&&zoom=18&markers=" + latitude + "," + longitude);
            message.type = kWCMessageType.Location;
            message.InsertData();//存库
            if (sendmsg)
            {
                SnedMessageObject(message);//指定发送的UserId
            }
            return message;
        }


        #endregion


        #region =========================发送音视频消息=================================


        // 发起音视频聊天
        internal static void SendAskMeetMessage(Friend toFriend, bool video)
        {
            var message = GetMessageObject(toFriend);
            if (video)
            {
                message.type = kWCMessageType.VideoChatAsk;
                message.content = "邀请您视频通话";
            }
            else
            {
                message.type = kWCMessageType.AudioChatAsk;
                message.content = "邀请您语音通话";
            }
            message.fileName = Applicate.URLDATA.data.jitsiServer;
            SnedMessageObject(message);//发消息
        }

        // 接听音视频聊天
        internal static void SendAgreeMeetMessage(Friend toFriend, bool video)
        {
            var message = GetMessageObject(toFriend);
            message.type = video ? kWCMessageType.VideoChatAccept : kWCMessageType.AudioChatAccept;
            SnedMessageObject(message);//发消息
        }

        // 拒绝音视频聊天 - 接听或拨号界面 发送 取消
        internal static void SendCancelMeetMessage(Friend toFriend, bool video)
        {
            var message = GetMessageObject(toFriend);
            message.type = video ? kWCMessageType.VideoChatCancel : kWCMessageType.AudioChatCancel;
            SnedMessageObject(message);//发消息
        }

        // 挂断音视频聊天 - 只有在音视频界面在才会有挂断
        internal static void SendEndMeetMessage(Friend toFriend, bool video, int timelen)
        {
            var message = GetMessageObject(toFriend);
            message.type = video ? kWCMessageType.VideoChatEnd : kWCMessageType.AudioChatEnd;
            message.timeLen = timelen;
            SnedMessageObject(message);//发消息
        }

        // 通话ping, 防止有一方断网，自己还不知道的情况， 通话成功后发3秒一次， 10次容错
        internal static void SendMeetPingMessage(Friend toFriend)
        {
            var message = GetMessageObject(toFriend);
            message.type = kWCMessageType.PhoneCalling;
            SnedMessageObject(message);//发消息
        }

        // 发送音视频忙线消息,我正在音视频通话的时候，有人给我发起音视频我就发忙线
        internal static void SendBusyMeetMessage(Friend toFriend)
        {
            var message = GetMessageObject(toFriend);
            message.type = kWCMessageType.AudioMeetingSetSpeaker;
            SnedMessageObject(message);//发消息
        }


        // 发起群聊语音会议
        internal static void SendGroupAudioMeetMsg(List<Friend> toFriends, string roomId, string roomJid)
        {
            foreach (var friend in toFriends)
            {
                var message = GetMessageObject(friend);
                message.type = kWCMessageType.AudioMeetingInvite;
                message.content = "邀请您加入语音会议";
                message.fileName = roomId;
                message.objectId = roomJid;
                SnedMessageObject(message);//发消息
            }
        }

        // 发起群聊视频会议
        internal static void SendGroupVideoMeetMsg(List<Friend> toFriends, string roomId, string roomJid)
        {
            foreach (var friend in toFriends)
            {
                var message = GetMessageObject(friend);
                message.type = kWCMessageType.VideoMeetingInvite;
                message.content = "邀请您加入视频会议";
                message.fileName = roomId;
                message.objectId = roomJid;
                SnedMessageObject(message);//发消息
            }
        }

        #endregion


        #region =========================发送群验证消息=================================
        internal static void SendRoomverification(Friend toFriend, List<Friend> InviteFriedLst, string rESON, string jid)
        {
            MessageObject message = GetMessageObject(toFriend);
            message.type = kWCMessageType.RoomIsVerify;
            JObject data = new JObject();
            data.Add("userIds", UIUtils.AppendFrindIds(InviteFriedLst));
            data.Add("userNames", UIUtils.AppendFrindNames(InviteFriedLst));
            data.Add("roomJid", jid);
            data.Add("isInvite", "0");
            data.Add("reason", rESON);
            message.objectId = data.ToString();
            SnedMessageObject(message);//发消息
        }
        #endregion


        #region =========================转发某条消息=================================

        // 转发某条消息
        internal static MessageObject SendForwardMessage(Friend toFriend, MessageObject oMsg)
        {
            bool isBannedTalk = EQControlManager.JudgeIsBannedTalk(toFriend);
            if (isBannedTalk)
                return oMsg;

            MessageObject message = oMsg.CopyMessage();
            message.timeSend = TimeUtils.CurrentTimeDouble();
            message.messageId = Guid.NewGuid().ToString("N");//生成Guid
            message.FromId = Applicate.MyAccount.userId;
            message.ToId = toFriend.UserId;
            message.toUserId = toFriend.UserId;//接收者
            message.fromUserId = Applicate.MyAccount.userId;
            message.fromUserName = Applicate.MyAccount.nickname;
            if (toFriend.IsGroup == 1)
            {
                message.isGroup = 1;

                // 获取我的群名片
                string nickName = new RoomMember() { roomId = toFriend.RoomId, userId = message.FromId }.GetNickName();
                if (!UIUtils.IsNull(nickName))
                {
                    message.fromUserName = nickName;
                }
            }


            message.toUserName = toFriend.NickName;
            message.isGroup = toFriend.IsGroup;

            message.InsertData();//存库
            message.UpdateLastSend();

            SnedMessageObject(message);//发消息
            mSocketCore.NotifactionListSingleMessage(message);

            return message;
        }


        // 合并转发多条消息- 
        internal static MessageObject SendForwardMessage(Friend toFriend, List<MessageObject> messages)
        {
            List<string> history = new List<string>();
            bool isGroup = false;
            string from = "";
            string to = "";
            foreach (var item in messages)
            {
                history.Add(item.ToJson(true));

                if (string.IsNullOrEmpty(from))
                {
                    isGroup = item.isGroup == 1;
                    from = item.IsMySend() ? item.toUserName : item.fromUserName;
                }

                if (UIUtils.IsNull(to))
                {
                    to = item.IsMySend() ? item.fromUserName : item.toUserName;
                }
            }
            string content = JsonConvert.SerializeObject(history);
            string objectId = isGroup ? "群聊的聊天记录" : UIUtils.QuotationName(from) + "和" + UIUtils.QuotationName(to) + "的聊天记录";

            MessageObject message = GetMessageObject(toFriend);
            message.type = kWCMessageType.History;
            message.content = content;
            message.objectId = objectId;
            SnedMessageObject(message);//发消息

            message.InsertData();//存库
            message.UpdateLastSend();

            return message;
        }


        #endregion


        #region =========================发送双向清除消息=================================
        // 发送清除某个好友与我的聊天记录
        internal static MessageObject SendClearFriendMsg(Friend toFriend)
        {
            MessageObject message = GetMessageObject(toFriend);
            message.type = kWCMessageType.SYNC_CLEAN;
            SnedMessageObject(message);//发消息
            return message;
        }

        #endregion


        #region =========================发送已读消息=================================

        // 对某条消息进行已读
        internal static void SendReadMessage(Friend toFriend, MessageObject oMsg)
        {
            if (oMsg.isRead == 1 || oMsg.type == kWCMessageType.labMoreMsg)
            {
                return;
            }


            Task.Factory.StartNew(() =>
            {
                //避免控件还在生成中，就发送了已读，然后群已读会添加已读人数去更新控件导致出错
                Thread.Sleep(600);

                if (oMsg.isRead == 1 || oMsg.type == kWCMessageType.labMoreMsg)
                {
                    return; // 已经发送过的不发
                }


                if (oMsg.IsMySend())
                {
                    return; // 不对自己的消息发已读
                }


                if (toFriend.IsGroup == 1)
                {
                    if (toFriend.ShowRead != 1)
                    {
                        oMsg.isRead = 1;
                        oMsg.UpdateIsReadPersons(0);
                        return;// 群消息 没有开已读人数不发已读
                    }
                }

                oMsg.isRead = 1; // 将原消息变为已读
                MessageObject message = GetMessageObject(toFriend);
                message.type = kWCMessageType.IsRead;
                message.content = oMsg.messageId;
                SendMessage(message);//发消息
            });
        }

        #endregion


        #region =========================发送正在输入消息=============================

        // 发送正在输入消息
        internal static void SendInputMessage(Friend toFriend)
        {
            if (toFriend.IsGroup == 1)
            {
                return;// 群消息不发
            }

            if (!Applicate.MyAccount.sendInput)
            {
                return;
            }

            long curr = TimeUtils.CurrentTime();
            if (curr - lastInput < 15)
            {
                return;
            }

            lastInput = curr;

            MessageObject message = GetMessageObject(toFriend);
            message.type = kWCMessageType.Typing;
            SnedMessageObject(message);//发消息
            Console.WriteLine("发送正在输入");

        }

        #endregion


        #region =========================发送撤回消息=================================

        // 对某条消息进行撤回
        internal static void SendRecallMessage(Friend toFriend, MessageObject oMsg)
        {
            //if (oMsg.isSend == 1)
            //{
                MessageObject message = GetMessageObject(toFriend);
                message.type = kWCMessageType.Withdraw;
                message.content = oMsg.messageId;
                SendMessage(message);//发消息
            //}
        }

        #endregion

        #region =======================发送已领取红包消息===============================
        internal static void ReceivedRedPack(Friend toFriend, string username)
        {
            string content = username + "已经领取了" + toFriend.NickName + "的红包";
            MessageObject message = GetMessageObject(toFriend);
            message.type = kWCMessageType.Remind;
            message.content = content;
            message.InsertData();//存库
            toFriend.UpdateLastContent(content, message.timeSend);
            // 更新聊天记录页
            Messenger.Default.Send(message, MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);
            Messenger.Default.Send(message, MessageActions.XMPP_SHOW_SINGLE_MESSAGE);
        }

        #endregion

        #region =======================发送请求群聊密钥消息===============================
        internal static void SendRequestChatKeyMessage(Friend toFriend)
        {

        }

        #endregion

        #region ================根据friend对象，返回一个初始化message对象================
        // 获取一个 消息对象
        public static MessageObject GetMessageObject(Friend toFriend)
        {
            MessageObject message = new MessageObject();
            message.timeSend = TimeUtils.CurrentTimeDouble();//  SyscTimeSend
            message.messageId = Guid.NewGuid().ToString("N");//生成Guid

            message.FromId = Applicate.MyAccount.userId;
            message.ToId = toFriend.UserId;
            message.toUserId = toFriend.UserId;//接收者
            message.fromUserId = Applicate.MyAccount.userId;
            message.fromUserName = Applicate.MyAccount.nickname;//这里放自己的昵称
            message.toUserName = toFriend.NickName;
            message.reSendCount = 3;

            if (toFriend.IsGroup == 1)
            {
                message.isGroup = 1;

                // 获取我的群名片
                string nickName = new RoomMember() { roomId = toFriend.RoomId, userId = message.FromId }.GetNickName();
                if (!UIUtils.IsNull(nickName))
                {
                    message.fromUserName = nickName;
                }
            }

            // 消息过期时间
            double oTime = UIUtils.DoubleParse(LocalDataUtils.GetStringData(toFriend.UserId + "chatRecordTimeOut" + Applicate.MyAccount.userId, "0"));
            if (oTime > 0)
            {
                // 多端协商统一 deleteTime 秒
                double deleteTime = TimeUtils.CurrentIntTime() + (oTime * 24 * 60 * 60);
                message.deleteTime = deleteTime;
            }
            else
            {
                message.deleteTime = -1;
            }


            return message;
        }
        #endregion

        #region =========================Http退出登录=================================
        // Http退出登录
        private static void UserHttpLoginout(string userid)
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/outtime")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("userId", userid)
                .Build().Execute(null);
        }
        #endregion

    }
}
