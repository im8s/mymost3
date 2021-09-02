package com.sk.weichat.xmpp;

import android.os.Handler;
import android.os.Message;
import android.util.Log;

import com.sk.weichat.bean.event.MessageSendChat;
import com.sk.weichat.bean.message.ChatMessage;
import com.sk.weichat.bean.message.NewFriendMessage;
import com.sk.weichat.bean.message.XmppMessage;
import com.sk.weichat.db.dao.ChatMessageDao;
import com.sk.weichat.socket.EMConnectionManager;
import com.sk.weichat.ui.me.sendgroupmessage.ChatActivityForSendGroup;
import com.sk.weichat.xmpp.listener.ChatMessageListener;
import com.sk.weichat.xmpp.listener.ChatReceiptListener;

import java.util.HashMap;
import java.util.Map;

import de.greenrobot.event.EventBus;
import fm.jiecao.jcvideoplayer_lib.MessageEvent;

/**
 * @项目名称: SkWeiChat-Baidu
 * @包名: com.sk.weichat.xmpp
 * @作者:王阳
 * @创建时间: 2015年10月15日 下午5:04:34
 * @描述: 消息回执的处理
 * @SVN版本号: $Rev$
 * @修改人: $Author$
 * @修改时间: $Date$
 * @修改的内容: TODO
 */
public class ReceiptManager implements Handler.Callback, ChatReceiptListener {

    public static final long MESSAGE_DELAY = 20 * 1000; // 消息发送超时时间
    public static final int RECEIPT_OUT = 0x111; // 超时
    public static final int RECEIPT_ERR = 0x112;  // 失败
    public static final int RECEIPT_YES = 0x113;  // 成功

    private EMConnectionManager mConnection;
    private String mLoginUserId;
    /**
     * 没有收到回执的消息
     */
    private Map<String, ChatMessage> mReceiptMap = new HashMap<>();
    /**
     * 重发次数表
     */
    private Map<String, Integer> mReSendMap = new HashMap<String, Integer>();
    private Handler mReceiptMapHandler;

    public ReceiptManager(CoreService service, EMConnectionManager connection) {
        mConnection = connection;
        mLoginUserId = mConnection.getLoginUserID();
        mConnection.addReceiptReceivedListener(this);
        mReceiptMapHandler = new Handler(this);
    }

    /**
     * 添加一个即将发送的消息
     */
    public void addWillSendMessage(ChatMessage chatMessage) {
        String messageId = chatMessage.getPacketId();

        // 将之前可能存在的回执缓存清除掉
        if (mReceiptMap.containsKey(messageId)) {
            mReceiptMap.remove(messageId);
            mReceiptMapHandler.removeMessages(RECEIPT_OUT, messageId);
        }

        // 记录一条新发送出去的消息(还没有接收到回执)
        mReceiptMap.put(messageId, chatMessage);

        // 默认先标记没有接收到回执
        Message handlerMsg = mReceiptMapHandler.obtainMessage();
        handlerMsg.obj = messageId;
        handlerMsg.what = RECEIPT_OUT;
        // 延迟二十秒发送 将这条消息置为 发送失败
        mReceiptMapHandler.sendMessageDelayed(handlerMsg, MESSAGE_DELAY);
    }

    public void reset() {
        mReceiptMap.clear();
    }

    @Override
    public boolean handleMessage(Message msg) {
        String messageId = (String) msg.obj;
        if (!mReceiptMap.containsKey(messageId)) {
            Log.e("xuan", "回执对应消息不存在: " + msg);
            return true;
        }

        ChatMessage chatMessage = mReceiptMap.get(messageId);
        // 此消息发送超时
        if (msg.what == RECEIPT_OUT) {
            int index = 0;
            if (mReSendMap.containsKey(messageId)) {
                index = mReSendMap.get(messageId);
            } else {
                index = chatMessage.getReSendCount();
            }

            if (index > 0) {// 在这里把发送失败的消息在发送一次
                mReSendMap.put(messageId, index - 1);
                //调用重发
                EventBus.getDefault().post(new MessageSendChat(chatMessage.isGroup(), chatMessage.getToUserId(), chatMessage));  // @see MainActivity
            } else {// 重发结束，发送失败
                if (isRoomVerify(chatMessage, RECEIPT_ERR)) {
                    ListenerManager.getInstance().notifyMessageSendStateChange(mLoginUserId, chatMessage, ChatMessageListener.MESSAGE_SEND_FAILED);
                }
            }
            // 超时情况不能从map中删除消息id, 否则收到回执时会因为map中没有消息而无法处理，
            return true;
        } else if (msg.what == RECEIPT_ERR) {
            if (isRoomVerify(chatMessage, RECEIPT_ERR)) {
                ListenerManager.getInstance().notifyMessageSendStateChange(mLoginUserId, chatMessage, ChatMessageListener.MESSAGE_SEND_FAILED);

                if (ChatActivityForSendGroup.isAlive) {
                    // 收到消息回执，通知消息群发页面
                    EventBus.getDefault().post(new MessageEvent(chatMessage.getToUserId()));
                }
            }
        } else if (msg.what == RECEIPT_YES) {
            if (isRoomVerify(chatMessage, RECEIPT_YES)) {
                ListenerManager.getInstance().notifyMessageSendStateChange(mLoginUserId, chatMessage, ChatMessageListener.MESSAGE_SEND_SUCCESS);

                if (ChatActivityForSendGroup.isAlive) {
                    // 收到消息回执，通知消息群发页面
                    EventBus.getDefault().post(new MessageEvent(chatMessage.getToUserId()));
                }
            }

        }
        mReceiptMap.remove(messageId);
        return true;
    }

    @Override
    public void onReceiveReceipt(int state, String messageId) {
        mReceiptMapHandler.removeMessages(RECEIPT_OUT, messageId);
        android.os.Message handlerMsg = mReceiptMapHandler.obtainMessage(state);
        handlerMsg.obj = messageId;
        mReceiptMapHandler.sendMessage(handlerMsg);
        Log.e("msg", "收到消息回执:messageId =" + messageId);
    }

    /**
     * 差异化处理，群组加入、退出，消息已读回执， 新朋友消息
     *
     * @param chatMessage
     * @param state
     * @return
     */
    private boolean isRoomVerify(ChatMessage chatMessage, int state) {
        String info = state == RECEIPT_YES ? "成功" : "失败";
        int type = chatMessage.getType();
        if (type == XmppMessage.TYPE_EXIT_ROOM) {
            Log.e("xuan", "收到退出群消息回执: " + info + "  roomjid " + chatMessage.getPacketId());
            if (state == RECEIPT_ERR) {
                //  EventBus.getDefault().post(new EventXMPPJoinGroupFailed(chatMessage.getContent()));// 通知聊天界面xmpp退出群组失败
            }
            return false;
        } else if (type == XmppMessage.TYPE_JOIN_ROOM) {
            Log.e("xuan", "收到加入群消息回执: " + info + "  roomjid " + chatMessage.getPacketId());
            if (state == RECEIPT_ERR) {
                // EventBus.getDefault().post(new EventXMPPJoinGroupFailed(chatMessage.getContent()));// 通知聊天界面xmpp加入群组失败
            }
            return false;
        } else if (type == XmppMessage.TYPE_READ) {
            if (state == RECEIPT_YES) {
                ChatMessageDao.getInstance().updateMessageRead(mLoginUserId, chatMessage.getToUserId(), chatMessage.getContent(), true); // 传入的 packetId是被回执的消息的packetId
            }
            return state == RECEIPT_ERR; // 如果发送失败就委托给重发机制去处理
        } else if (type >= XmppMessage.TYPE_SAYHELLO && type <= XmppMessage.TYPE_BACK_DELETE) {
            Log.e("xuan", "收到新朋友消息回执 : " + info + "  roomjid " + chatMessage.getPacketId());
            // chatMessage. toFriendMessage只适用于其他人对我进行好友操作，在该地方chatMessage为自己发送的，如果也调用toFriendMessage会造成数据紊乱
            // NewFriendMessage friendMessage = chatMessage.toFriendMessage();
            NewFriendMessage friendMessage = cloneNewFriendMessage(chatMessage);
            if (state == RECEIPT_ERR) {
                ListenerManager.getInstance().notifyNewFriendSendStateChange(chatMessage.getToUserId(), friendMessage, ChatMessageListener.MESSAGE_SEND_FAILED);
            } else {
                ListenerManager.getInstance().notifyNewFriendSendStateChange(chatMessage.getToUserId(), friendMessage, ChatMessageListener.MESSAGE_SEND_SUCCESS);
            }
            return false;
        }
        return true;
    }

    /**
     * clone 一份NewFriendMessage 对象
     *
     * @param chatMessage
     * @return
     */
    private NewFriendMessage cloneNewFriendMessage(ChatMessage chatMessage) {
        NewFriendMessage message = new NewFriendMessage();
        message.setPacketId(chatMessage.getPacketId());
        // 首先是传输协议的字段，
        message.setFromUserId(chatMessage.getFromUserId());
        message.setFromUserName(chatMessage.getFromUserName());
        message.setToUserId(chatMessage.getToUserId());
        message.setToUserName(chatMessage.getToUserName());
        message.setType(chatMessage.getType());
        message.setContent(chatMessage.getContent());
        message.setTimeSend(chatMessage.getTimeSend());
        // 本地数据库状态
        message.setOwnerId(chatMessage.getFromUserId());
        message.setUserId(chatMessage.getToUserId());
        message.setNickName(chatMessage.getToUserName());
        message.setRead(true);
        message.setMySend(true);
        return message;
    }
}
