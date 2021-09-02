using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using WinFrmTalk;
using WinFrmTalk.Model;

/// <summary>
/// xmpp 回执管理类
/// create: xuan
/// tiem: 2019-3-25 15:22:53
/// </summary>
public class XmppReceiptManager
{

    // 单例模式
    private XmppReceiptManager()
    {
        InitReceiptManager();
    }

    private static XmppReceiptManager _instance;
    public static XmppReceiptManager Instance => _instance ?? (_instance = new XmppReceiptManager());


    public const int MESSAGE_DELAY = 20;// * 1000; // 超时时间
    public const int RECEIPT_ERR = -1; // 失败
    public const int RECEIPT_YES = 1; // 成功
    public const int RECEIPT_ERR_DIS = -2; // 敏感词

    // 未收到回执的消息队列
    private ConcurrentDictionary<string, MessageObject> mReceiptMap = new ConcurrentDictionary<string, MessageObject>();
    // 发送时间表
    private ConcurrentDictionary<string, long> mResendTime = new ConcurrentDictionary<string, long>();

    private void InitReceiptManager()
    {
        Task.Factory.StartNew(() =>
        {
            while (true)
            {
                Thread.Sleep(1000);
                CheckMessageDelay();
            }
        });

    }

    private void CheckMessageDelay()
    {
        if (mReceiptMap.Count == 0)
        {
            return;
        }

        long currt = TimeUtils.CurrentTime();
        Console.WriteLine("time : " + currt + "  线程中有  " + mReceiptMap.Count + " 条消息发送中");
        foreach (var item in mReceiptMap.Keys)
        {
            if (mReceiptMap.ContainsKey(item) && mResendTime.ContainsKey(item))
            {
                long send;
                bool success = mResendTime.TryGetValue(item, out send);

                if (success && currt - send >= MESSAGE_DELAY)
                {
                    MessageObject message = null;

                    bool msgstate = mReceiptMap.TryGetValue(item, out message);
                    if (msgstate)
                    {
                        if (message.reSendCount > 0)
                        {
                            message.reSendCount--;
                            mResendTime[item] = currt;
                            LogUtils.Log("消息发送超时 id：" + item + " 启动重发：" + message.reSendCount);
                            ShiKuManager.SendMessage(message);
                        }
                        else
                        {
                            LogUtils.Log("消息发送失败 id：" + item);
                            OnReceiveReceipt(RECEIPT_ERR, item);
                        }
                    }
                }
            }
        }

    }


    /// <summary>
    /// 添加一个正在发送的消息
    /// </summary>
    /// <param name="message"></param>
    public void AddWillSendMessage(MessageObject message)
    {
        string messageId = message.messageId;

        if (UIUtils.IsNull(messageId))
        {
            return;
        }

        if (mReceiptMap.ContainsKey(messageId))
        {
            return;
        }

        mReceiptMap.TryAdd(messageId, message);
        mResendTime.TryAdd(messageId, TimeUtils.CurrentTime());
    }

    /// <summary>
    /// 收到了一个回执
    /// </summary>
    /// <param name="messageId"></param>
    public void OnReceiveReceipt(int state, string messageId)
    {
        LogUtils.Log("收到消息回执:messageId =" + messageId + "  state  " + state);

        if (mReceiptMap.ContainsKey(messageId))
        {
            MessageObject message = null;
            long time;
            bool statevalue = mReceiptMap.TryGetValue(messageId, out message);
            if (statevalue)
            {
                mReceiptMap.TryRemove(messageId, out message);
                mResendTime.TryRemove(messageId, out time);

                message.UpdateIsSend(state, messageId);

                if (!isFriendVerify(message, state))
                {
                    // 普通消息发送成功
                    if (RECEIPT_YES == state)
                    {
                        message.isSend = 1;
                        Messenger.Default.Send(message, MessageActions.XMPP_UPDATE_SEND_SUCCESS);//更新UI送达标志 消息已发送成功
                    }
                    else
                    {
                        message.isSend = -1;
                        Messenger.Default.Send(message, MessageActions.XMPP_UPDATE_SEND_FAILED);// 更新UI消息发送失败标志 消息已发送失败 参数 messageObject
                    }
                }

                if (state != RECEIPT_ERR_DIS)
                {
                    if (message.UpdateLastSend() > 0)
                    {
                        Messenger.Default.Send(message, MessageActions.XMPP_SHOW_SINGLE_MESSAGE);
                    }
                }
            }
        }
    }

    // 是否是新朋友验证回执消息
    public bool isFriendVerify(MessageObject message, int state)
    {

        // 已读回执
        if (message.type == kWCMessageType.IsRead)
        {

            message.messageId = message.content;
            message.UpdateIsRead(message.messageId);
            Messenger.Default.Send(message, MessageActions.XMPP_UPDATE_SEND_READ);

            return true;
        }

        // 正在输入
        if (message.type == kWCMessageType.Typing)
        {
            return true;
        }

        if (message.type == kWCMessageType.OnlineStatus)
        {
            LogUtils.Log("收到登录回执：：：");
            return true;
        }

        if (message.type == kWCMessageType.SYNC_CLEAN)
        {
            Messenger.Default.Send(message.toUserId, MessageActions.CLEAR_FRIEND_MSGS);
            LogUtils.Log("删除某个好友的聊天记录" + message.toUserName);
            return true;
        }


        // 新朋友验证回执
        if (message.type >= kWCMessageType.FriendRequest && message.type <= kWCMessageType.PhoneContactToFriend)
        {
            // 朋友验证消息发送成功
            if (RECEIPT_YES == state)
            {
                message.isSend = 1;
            }

            else
            {
                message.isSend = -1;
            }
            ProcessVerifingMsgReceipt(message);
            Messenger.Default.Send(message, MessageActions.XMPP_UPDATE_VERIFY_RECEPIT);// 更新UI消息发送失败标志 消息已发送失败 参数 messageObject
            return true;
        }


        // 撤回消息回执
        if (message.type == kWCMessageType.Withdraw)
        {
            message.messageId = message.content;
            MessageObject oMsg = message.GetMessageObject();
            if (oMsg != null)
            {
                string content = null;
                if (string.Equals(oMsg.fromUserId, oMsg.myUserId))
                {
                    content = "你撤回了一条消息";
                }
                else
                {
                    content = "你撤回了 " + UIUtils.QuotationName(oMsg.fromUserName) + "的一条消息";
                }

                oMsg.content = content;
                oMsg.UpdateChangeTip(content);
                message = oMsg;
            }
            else
            {
                message.UpdateChangeTip("你撤回了一条消息");
            }
            Messenger.Default.Send(message, MessageActions.XMPP_UPDATE_RECALL_MESSAGE);
            return true;
        }


        //音视频消息回执
        if (message.type >= kWCMessageType.AudioChatAsk && message.type <= kWCMessageType.AudioMeetingSetSpeaker)
        {
            message.isSend = state;
            Messenger.Default.Send(message, MessageActions.XMPP_UPDATE_MEETING_RECEIPT);// 更新UI消息

            if (message.type == kWCMessageType.VideoChatCancel || message.type == kWCMessageType.AudioChatCancel)
            {
                message.content = message.type == kWCMessageType.VideoChatCancel ? "取消了视频通话" : "取消了语音通话";
                if (message.InsertData() > 0)
                {
                    if (message.UpdateLastSend() > 0)
                    {
                        Messenger.Default.Send(message, MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);
                        Messenger.Default.Send(message, MessageActions.XMPP_SHOW_SINGLE_MESSAGE);
                    }
                }

                return true;
            }

            if (message.type == kWCMessageType.VideoChatEnd || message.type == kWCMessageType.AudioChatEnd)
            {

                string str = message.type == kWCMessageType.VideoChatEnd ? "视频" : "语音";
                message.content = "结束了" + str + "通话,时长:" + TimeUtils.FromatCountdown(message.timeLen);

                if (message.InsertData() > 0)
                {
                    if (message.UpdateLastSend() > 0)
                    {
                        Messenger.Default.Send(message, MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);
                        Messenger.Default.Send(message, MessageActions.XMPP_SHOW_SINGLE_MESSAGE);
                    }
                }
            }

            return true;
        }

        // 新朋友验证
        if (message.type >= kWCMessageType.FriendRequest && message.type <= kWCMessageType.PhoneContactToFriend)
        {
            // 朋友验证消息发送成功
            if (RECEIPT_YES == state)
            {
                message.isSend = 1;
            }
            else
            {
                message.isSend = -1;
            }

            Messenger.Default.Send(message, MessageActions.XMPP_UPDATE_VERIFY_RECEPIT);// 更新UI消息发送失败标志 消息已发送失败 参数 messageObject
            return true;
        }

        return false;
    }

    /// <summary>
    /// 开始处理验证消息回执
    /// </summary>
    /// <param name="msg"></param>
    private void ProcessVerifingMsgReceipt(MessageObject msg)
    {

        if (msg.IsExist())
        {
            return;
        }

        var tmpFriend = msg.GetFriend();
        if (tmpFriend == null || string.IsNullOrEmpty(tmpFriend.UserId))
        {
            tmpFriend = new Friend()
            {
                UserId = msg.toUserId,
                IsGroup = 0,
                NickName = msg.toUserName,
            };

            tmpFriend.InsertAuto();//添加对应好友至数据库
        }




        switch (msg.type)
        {
            case kWCMessageType.DeleteFriend:
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
                // 清空列表
                msg.DeleteTable();
                // 更新新的朋友未读数量
                Messenger.Default.Send(Friend.ID_NEW_FRIEND, FriendListLayout.NOTIFY_FRIENDLIST_UNREAD_COUNT);
                break;
            case kWCMessageType.BlackFriend:
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
                // 清空列表
                msg.DeleteTable();
                // 更新黑名单未读数量
                Messenger.Default.Send(Friend.ID_BAN_LIST, FriendListLayout.NOTIFY_FRIENDLIST_UNREAD_COUNT);
                break;
            case kWCMessageType.RequestFriendDirectly://直接添加好友
            case kWCMessageType.RequestAgree://被同意
            case kWCMessageType.CancelBlackFriend://被对方取消黑名单
            case kWCMessageType.PhoneContactToFriend://被对方从手机联系人直接添加成好友

                MessageObject tip = msg.CopyMessage();
                tip.type = kWCMessageType.Remind;
                tip.content = "你们已经成为好友，快来聊天吧";
                tip.InsertData();//保存提示消息

                tmpFriend.BecomeFriend(msg.type);

                // 更新聊天记录页
                Messenger.Default.Send(tip, MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);
                Messenger.Default.Send(tip, MessageActions.XMPP_SHOW_SINGLE_MESSAGE);
                //添加至好友列表
                Messenger.Default.Send(tmpFriend.UserId, FriendListLayout.ADD_EXISTS_FRIEND);
 				// 我同意添加对方为好友的消息不在产生新的朋友未读数量
                if (msg.type != kWCMessageType.RequestAgree)
                {// 更新新的朋友未读数量
                    Messenger.Default.Send(Friend.ID_NEW_FRIEND, FriendListLayout.NOTIFY_FRIENDLIST_UNREAD_COUNT);
                }                break;
            case kWCMessageType.FriendRequest://直接添加好友
                tmpFriend.UpdateFriendState(Friend.STATUS_10);
                break;
            default:
                break;
        }
    }


    /// <summary>
    /// 处理群组验证消息回执
    /// <para>(可能非必要，因控制消息不通过Xmpp直接发送，于Http成功调用即成功，可在成功后更新对应数据库或UI)</para>
    /// </summary>
    /// <param name="msg"></param>
    private void ProcessGroupManagesgReceipt(MessageObject msg)
    {
        var tmproom = new Friend() { UserId = msg.FromId }.GetByUserId();
        switch (msg.type)
        {
            case kWCMessageType.RoomNameChange:
                break;
            case kWCMessageType.RoomDismiss:
            case kWCMessageType.RoomExit:
                //tmproom.DeleteByJid(msg.FromId);//删除对应Jid的群组
                break;
            case kWCMessageType.RoomNotice:
                break;
            case kWCMessageType.RoomMemberBan:
                break;
            case kWCMessageType.RoomInvite:
                break;
            case kWCMessageType.RoomReadVisiblity:
                break;
            case kWCMessageType.RoomIsVerify:
                break;
            case kWCMessageType.RoomIsPublic:
                break;
            case kWCMessageType.RoomInsideVisiblity:
                break;
            case kWCMessageType.RoomUserRecommend:
                break;
            default:
                break;
        }
    }



}