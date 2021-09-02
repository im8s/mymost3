package com.sk.weichat.xmpp;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Binder;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.WorkerThread;
import androidx.core.app.NotificationCompat;

import com.sk.weichat.AppConstant;
import com.sk.weichat.BuildConfig;
import com.sk.weichat.MyApplication;
import com.sk.weichat.R;
import com.sk.weichat.audio.NoticeVoicePlayer;
import com.sk.weichat.bean.Friend;
import com.sk.weichat.bean.MsgRoamTask;
import com.sk.weichat.bean.SyncBean;
import com.sk.weichat.bean.User;
import com.sk.weichat.bean.event.MessageEventBG;
import com.sk.weichat.bean.message.ChatMessage;
import com.sk.weichat.bean.message.LastChatHistoryList;
import com.sk.weichat.bean.message.NewFriendMessage;
import com.sk.weichat.bean.message.XmppMessage;
import com.sk.weichat.broadcast.MsgBroadcast;
import com.sk.weichat.call.JitsistateMachine;
import com.sk.weichat.db.dao.ChatMessageDao;
import com.sk.weichat.db.dao.FriendDao;
import com.sk.weichat.db.dao.MsgRoamTaskDao;
import com.sk.weichat.helper.PrivacySettingHelper;
import com.sk.weichat.pay.sk.SKPayActivity;
import com.sk.weichat.socket.EMConnectionManager;
import com.sk.weichat.socket.msg.ExitGroupMessage;
import com.sk.weichat.socket.msg.JoinGroupMessage;
import com.sk.weichat.socket.msg.MessageHead;
import com.sk.weichat.socket.msg.PullBatchGroupMessage;
import com.sk.weichat.ui.MainActivity;
import com.sk.weichat.ui.base.CoreManager;
import com.sk.weichat.ui.message.ChatActivity;
import com.sk.weichat.ui.message.HandleSyncMoreLogin;
import com.sk.weichat.ui.message.MucChatActivity;
import com.sk.weichat.util.AppUtils;
import com.sk.weichat.util.Constants;
import com.sk.weichat.util.PreferenceUtils;
import com.sk.weichat.util.TimeUtils;
import com.sk.weichat.xmpp.listener.AuthStateListener;
import com.sk.weichat.xmpp.listener.ChatMessageListener;
import com.xuan.xuanhttplibrary.okhttp.HttpUtils;
import com.xuan.xuanhttplibrary.okhttp.callback.ListCallback;
import com.xuan.xuanhttplibrary.okhttp.result.ArrayResult;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import me.leolin.shortcutbadger.ShortcutBadger;
import okhttp3.Call;

public class CoreService extends Service {
    static final boolean DEBUG = true;
    static final String TAG = "XmppCoreService";

    private static final Intent SERVICE_INTENT = new Intent();
    private static final String EXTRA_LOGIN_USER_ID = "login_user_id";
    private static final String EXTRA_LOGIN_PASSWORD = "login_password";
    private static final String EXTRA_LOGIN_NICK_NAME = "login_nick_name";

    private static final String MESSAGE_CHANNEL_ID = "message";

    static {
        SERVICE_INTENT.setComponent(new ComponentName(BuildConfig.APPLICATION_ID, CoreService.class.getName()));
    }

    private CoreServiceBinder mBinder;
    private boolean isInit;
    /* 当前登陆用户的基本属性 */
    private String mLoginUserId;
    @SuppressWarnings("unused")
    private String mLoginNickName;

    private XmppConnectionManager mConnectionManager;// 唯一
    private ReceiptManager mReceiptManager;// 唯一

    /**
     * 本地 发送 通知 至 通知栏
     */
    private int notifyId = 1003020303;
    private NotificationManager mNotificationManager;
    private NotificationCompat.Builder mBuilder;
    /**
     * 发送 已读 消息
     */
    private ReadBroadcastReceiver receiver = new ReadBroadcastReceiver();

    private NotifyConnectionListener mNotifyConnectionListener = new NotifyConnectionListener() {
        @Override
        public void notifyConnecting() {
            ListenerManager.getInstance().notifyAuthStateChange(AuthStateListener.AUTH_STATE_ING);
        }

        @Override
        public void notifyConnected() {
            ListenerManager.getInstance().notifyAuthStateChange(AuthStateListener.AUTH_STATE_ING);
        }

        @Override
        public void notifyAuthenticated() {
            ListenerManager.getInstance().notifyAuthStateChange(AuthStateListener.AUTH_STATE_SUCCESS);// 通知登陆成功
            authenticatedOperating();
        }

        @Override
        public void notifyConnectionClosed() {
            ListenerManager.getInstance().notifyAuthStateChange(AuthStateListener.AUTH_STATE_CLOSE);
        }

        @Override
        public void notifyConnectionClosedOnError(String arg0) {
            ListenerManager.getInstance().notifyAuthStateChange(AuthStateListener.AUTH_STATE_ERROR);
        }
    };

    public static Intent getIntent() {
        return SERVICE_INTENT;
    }

    // 要用ContextCompat.startForegroundService启动，否则安卓8.0以上可能崩溃，而且是不一定复现的那种，
    public static Intent getIntent(Context context, String userId, String password, String nickName) {
        Intent intent = new Intent(context, CoreService.class);
        intent.putExtra(EXTRA_LOGIN_USER_ID, userId);
        intent.putExtra(EXTRA_LOGIN_PASSWORD, password);
        intent.putExtra(EXTRA_LOGIN_NICK_NAME, nickName);
        return intent;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        mBinder = new CoreServiceBinder();
        if (CoreService.DEBUG) {
            Log.e(CoreService.TAG, "CoreService OnCreate :" + android.os.Process.myPid());
        }
        register(); // 注册发送已读消息的广播监听
    }

    @Override
    public IBinder onBind(Intent intent) {
        // 绑定服务只是为了提供一些外部调用的方法
        if (CoreService.DEBUG) {
            Log.e(CoreService.TAG, "CoreService onBind");
        }
        return mBinder;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (CoreService.DEBUG) {
            Log.e(CoreService.TAG, "CoreService onStartCommand");
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationBuilder();
            startForeground(1, mBuilder.build());
            stopForeground(true);
        }

        init();

        return START_STICKY;
    }

    public void login() {
        mConnectionManager.login();
    }

    public void initConnection() {
        mConnectionManager = new XmppConnectionManager(this, mNotifyConnectionListener);
        mReceiptManager = new ReceiptManager(this, mConnectionManager.getConnection());
        mConnectionManager.addMessageListener();
    }

    private void release() {
        if (mConnectionManager != null) {
            mConnectionManager.release();
            mConnectionManager = null;
        }
        // todo 不一定要将mReceiptManager  reset
        if (mReceiptManager != null) {
            mReceiptManager.reset();
        }
    }

    private void init() {
        if (isInit) {
            login();
            return;
        }
        isInit = true;
        User self = CoreManager.requireSelf(this);
        mLoginUserId = self.getUserId();
        mLoginNickName = self.getNickName();

        if (mConnectionManager != null) {
            release();
        }

        if (mConnectionManager == null) {
            initConnection();
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (CoreService.DEBUG) {
            Log.e(CoreService.TAG, "CoreService onDestroy");
        }

        release();

        if (receiver != null) {
            unregisterReceiver(receiver);
        }
    }

    /**
     * 获得XmppConnectionManager对象
     */
    public XmppConnectionManager getmConnectionManager() {
        return mConnectionManager;
    }

    public boolean isAuthenticated() {
        if (mConnectionManager != null && mConnectionManager.isAuthenticated()) {
            return true;
        }
        return false;
    }

    public void logout() {
        isInit = false;
        if (CoreService.DEBUG)
            Log.e(CoreService.TAG, "Xmpp登出");
        if (mConnectionManager != null) {
            mConnectionManager.logout();
        }
        stopSelf();
    }

    // 发送忙线消息
    public void sendBusyMessage(String toUserId, int type) {
        ChatMessage chatMessage = new ChatMessage();
        chatMessage.setType(XmppMessage.TYPE_IS_BUSY);

        chatMessage.setFromUserId(mLoginUserId);
        chatMessage.setFromUserName(mLoginNickName);
        chatMessage.setToUserId(toUserId);

        chatMessage.setObjectId(String.valueOf(type));
        chatMessage.setTimeSend(TimeUtils.sk_time_current_time());
        chatMessage.setPacketId(UUID.randomUUID().toString().replaceAll("-", ""));
        sendChatMessage(toUserId, chatMessage);
        if (ChatMessageDao.getInstance().saveNewSingleChatMessage(mLoginUserId, toUserId, chatMessage)) {
            ListenerManager.getInstance().notifyNewMesssage(mLoginUserId, toUserId, chatMessage, false);
        }
    }

    /**
     * 发送新的朋友消息
     */
    public void sendNewFriendMessage(String toUserId, NewFriendMessage message) {
        if (!isAuthenticated() || mReceiptManager == null) {
            ListenerManager.getInstance().notifyNewFriendSendStateChange(toUserId, message, ChatMessageListener.MESSAGE_SEND_FAILED);
            return;
        }

        ListenerManager.getInstance().notifyNewFriendSendStateChange(toUserId, message, ChatMessageListener.MESSAGE_SEND_ING);
        ChatMessage chatMessage = message.toChatMessage();
        chatMessage.setToUserId(toUserId);
        mReceiptManager.addWillSendMessage(chatMessage);
        mConnectionManager.sendMessage(com.sk.weichat.socket.msg.ChatMessage.toSocketMessage(chatMessage, true));
    }

    /**
     * 发送聊天消息
     */
    public void sendChatMessage(String toUserId, ChatMessage chatMessage) {
        if (!isAuthenticated() || mReceiptManager == null) {
            ListenerManager.getInstance().notifyMessageSendStateChange(mLoginUserId, toUserId, chatMessage.getPacketId(), ChatMessageListener.MESSAGE_SEND_FAILED);// 保存自己发送的消息 先给一个默认值
            return;
        }

        /**
         * 先添加一个等待接收回执的消息
         * 然后再发送这条消息
         */
        chatMessage.setToUserId(toUserId);
        mReceiptManager.addWillSendMessage(chatMessage);
        mConnectionManager.sendMessage(com.sk.weichat.socket.msg.ChatMessage.toSocketMessage(chatMessage, false));
    }

    public void sendMucChatMessage(String toUserId, ChatMessage chatMessage) {
        if (!isAuthenticated() || mReceiptManager == null) {
            ListenerManager.getInstance().notifyMessageSendStateChange(mLoginUserId, toUserId, chatMessage.getPacketId(), ChatMessageListener.MESSAGE_SEND_FAILED);
            return;
        }

        chatMessage.setToUserId(toUserId);
        chatMessage.setGroup(true);
        mReceiptManager.addWillSendMessage(chatMessage);
        mConnectionManager.sendMessage(com.sk.weichat.socket.msg.ChatMessage.toSocketMessage(chatMessage, false));
    }

    /* 批量加入群组 */
    public void batchJoinMucChat() {
        if (mConnectionManager == null) {
            // 可能http回调后已经掉线CoreService已经释放了，就不继续了，
            return;
        }
        List<String> jidList = new ArrayList<>();
        long lastSeconds;
        long offlineTime = PreferenceUtils.getLong(MyApplication.getContext(), Constants.OFFLINE_TIME + mLoginUserId, 0);// 离线时间存的为秒，需要毫秒
        if (offlineTime == 0) {
            lastSeconds = 1546272000000L;// 2019年1月1日
        } else {
            lastSeconds = offlineTime * 1000;
        }

        List<Friend> friends = FriendDao.getInstance().getAllRooms(mLoginUserId);// 获取本地所有群组
        if (friends != null && friends.size() > 0) {
            for (int i = 0; i < friends.size(); i++) {
                Friend friend = friends.get(i);
                if (friend.getGroupStatus() == 0) {// 群组状态正常才去获取离线消息
                    ChatMessage mLastChatMessage = ChatMessageDao.getInstance().getLastChatMessage(mLoginUserId, friend.getUserId(), offlineTime);
                    if (mLastChatMessage != null) {// 如果该群组的最后一条消息不为空，将该条消息的timeSend作为当前群组的离线时间，这样比上面全局的离线时间更加准确
                        long timeSend = mLastChatMessage.getTimeSend();
                        jidList.add(friend.getUserId() + "," + String.valueOf(timeSend));
                    } else {
                        jidList.add(friend.getUserId() + "," + String.valueOf(lastSeconds));
                    }
                }
            }
        }
        if (jidList.isEmpty()) {
            // 空数组就不发了，
            return;
        }
        PullBatchGroupMessage pullBatchGroupMessage = new PullBatchGroupMessage();
        pullBatchGroupMessage.setJidList(jidList);
        pullBatchGroupMessage.setEndTime(TimeUtils.sk_time_current_time());

        MessageHead head = new MessageHead();
        head.setMessageId(UUID.randomUUID().toString().replaceAll("-", ""));
        head.setFrom(mLoginUserId + "/" + EMConnectionManager.CURRENT_DEVICE);
        head.setTo("service");
        head.setChatType((byte) 2);
        pullBatchGroupMessage.setMessageHead(head);
        mConnectionManager.getConnection().batchJoinRoom(pullBatchGroupMessage);
    }

    /* 创建群聊 */
    public String createMucRoom(String roomName) {
        String roomJid = UUID.randomUUID().toString().replaceAll("-", "");
        joinMucChat(roomJid, 0);
        return roomJid;
    }

    /* 别人邀请我加入群组 加入群聊 */
    public String joinMucChat(String roomJid, long lastSeconds) {
        ChatMessage chatMessage = new ChatMessage();
        chatMessage.setGroup(true);
        chatMessage.setContent(roomJid);
        chatMessage.setPacketId(UUID.randomUUID().toString().replaceAll("-", ""));
        chatMessage.setType(XmppMessage.TYPE_JOIN_ROOM);
        mReceiptManager.addWillSendMessage(chatMessage);

        JoinGroupMessage join = new JoinGroupMessage();
        join.setJid(roomJid);
        join.setSeconds(lastSeconds);

        MessageHead head = new MessageHead();
        head.setMessageId(chatMessage.getPacketId());
        head.setFrom(mLoginUserId + "/" + EMConnectionManager.CURRENT_DEVICE);
        head.setTo("service");
        head.setChatType((byte) 2);
        join.setMessageHead(head);
        mConnectionManager.getConnection().joinRoom(join);
        return roomJid;
    }

    /* 退出群聊 */
    public void exitMucChat(String roomJid) {
        ChatMessage chatMessage = new ChatMessage();
        chatMessage.setGroup(true);
        chatMessage.setPacketId(UUID.randomUUID().toString().replaceAll("-", ""));
        chatMessage.setContent(roomJid);
        chatMessage.setTimeSend(0); // 新建群没有历史消息
        chatMessage.setType(XmppMessage.TYPE_EXIT_ROOM);
        mReceiptManager.addWillSendMessage(chatMessage);

        ExitGroupMessage exit = new ExitGroupMessage();
        exit.setJid(roomJid);

        MessageHead head = new MessageHead();
        head.setMessageId(chatMessage.getPacketId());
        head.setFrom(mLoginUserId + "/" + EMConnectionManager.CURRENT_DEVICE);
        head.setTo("service");
        head.setChatType((byte) 2);

        exit.setMessageHead(head);
        mConnectionManager.getConnection().exitRoom(exit);
    }

    /********************************************************************************
     *  其他操作
     ********************************************************************************/
    /*
    XMPP认证后需要做的操作
    */
    public void authenticatedOperating() {
        Log.e("zq", "认证之后需要调用的操作");
        new Thread(new Runnable() {
            @Override
            public void run() {
                // 删除本地已过期的消息
                List<Friend> nearlyFriendMsg = FriendDao.getInstance().getNearlyFriendMsg(mLoginUserId);
                for (int i = 0; i < nearlyFriendMsg.size(); i++) {
                    if (nearlyFriendMsg.get(i).getRoomFlag() == 0) {// 单聊可删除
                        ChatMessageDao.getInstance().deleteOutTimeChatMessage(mLoginUserId, nearlyFriendMsg.get(i).getUserId());
                    } else {// 群聊修改字段
                        ChatMessageDao.getInstance().updateExpiredStatus(mLoginUserId, nearlyFriendMsg.get(i).getUserId());
                    }
                }
            }
        }).start();

        MessageEventBG.isAuthenticated = true;
        // 从服务端获取与其它好友 || 群组内最后一条聊天消息列表(单聊：我在其他端的产生的聊天记录 群聊：离线消息大于100条时，之前的数据)
        getLastChatHistory();
        getInterfaceTransferInOfflineTime();
    }

    public void getInterfaceTransferInOfflineTime() {
        long syncTimeLen = PreferenceUtils.getLong(MyApplication.getContext(), Constants.OFFLINE_TIME + mLoginUserId, 0);

        Map<String, String> params = new HashMap();
        params.put("access_token", CoreManager.requireSelfStatus(this).accessToken);
        params.put("offlineTime", String.valueOf(syncTimeLen));

        HttpUtils.get().url(CoreManager.requireConfig(this).USER_OFFLINE_OPERATION)
                .params(params)
                .build()
                .execute(new ListCallback<SyncBean>(SyncBean.class) {
                    @Override
                    public void onResponse(ArrayResult<SyncBean> result) {
                        if (result.getResultCode() == 1 && result.getData() != null) {
                            List<SyncBean> syncBeans = result.getData();
                            for (int i = 0; i < syncBeans.size(); i++) {
                                HandleSyncMoreLogin.distributionService(syncBeans.get(i), CoreService.this);
                            }
                        }
                    }

                    @Override
                    public void onError(Call call, Exception e) {

                    }
                });
    }

    public void getLastChatHistory() {
        Map<String, String> params = new HashMap();
        params.put("access_token", CoreManager.requireSelfStatus(this).accessToken);

        long syncTimeLen;
        if (Constants.OFFLINE_TIME_IS_FROM_SERVICE) {// 离线时间为服务端获取 取出消息漫游时长
            String chatSyncTimeLen = String.valueOf(PrivacySettingHelper.getPrivacySettings(this).getChatSyncTimeLen());
            Double realSyncTime = Double.parseDouble(chatSyncTimeLen);
            if (realSyncTime == -2) {// 不同步
                batchJoinMucChat();
                //  joinExistGroup();
                return;
            } else if (realSyncTime == -1 || realSyncTime == 0) {// 同步 永久 syncTime == 0
                syncTimeLen = 0;
            } else {
                syncTimeLen = (long) (realSyncTime * 24 * 60 * 60);// 得到消息同步时长
            }
            Constants.OFFLINE_TIME_IS_FROM_SERVICE = false;
        } else {// syncTime为上一次本地保存的离线时间
            syncTimeLen = PreferenceUtils.getLong(MyApplication.getContext(), Constants.OFFLINE_TIME + mLoginUserId, 0);
        }
        params.put("startTime", String.valueOf(syncTimeLen * 1000));

        HttpUtils.get().url(CoreManager.requireConfig(this).GET_LAST_CHAT_LIST)
                .params(params)
                .build()
                .execute(new ListCallback<LastChatHistoryList>(LastChatHistoryList.class) {
                    @Override
                    public void onResponse(ArrayResult<LastChatHistoryList> result) {
                        if (result.getResultCode() == 1 && result.getData() != null) {
                            final List<LastChatHistoryList> data = result.getData();
                            new Thread(new Runnable() {
                                @Override
                                public void run() {
                                    long offlineTime = PreferenceUtils.getLong(MyApplication.getContext(), Constants.OFFLINE_TIME + mLoginUserId, 0);
                                    for (int i = 0; i < data.size(); i++) {
                                        LastChatHistoryList mLastChatHistoryList = data.get(i);

                                        if (mLastChatHistoryList.getType() == 1) {// 群组消息
                                            // 取出该群组最后一条消息
                                            ChatMessage mLocalLastMessage = ChatMessageDao.getInstance().getLastChatMessage(mLoginUserId, mLastChatHistoryList.getJid(), offlineTime);
                                            if (mLocalLastMessage == null) {
                                                // 兼容offlineTime错误导致查不到最后一条消息的情况，
                                                mLocalLastMessage = ChatMessageDao.getInstance().getLastChatMessage(mLoginUserId, mLastChatHistoryList.getJid(), System.currentTimeMillis() / 1000);
                                            }
                                            long startTime = 0;
                                            if (mLocalLastMessage != null) {
                                                startTime = mLocalLastMessage.getTimeSend();
                                            }
                                            if (mLocalLastMessage != null
                                                    && mLocalLastMessage.getPacketId().equals(mLastChatHistoryList.getMessageId())) {
                                                // 最后一条消息的msgId==服务端记录的该群组最后一条消息msgId(代表离线期间无消息产生 理论上服务端这个情况服务端是不会返回的)
                                                // 不需要生成任务
                                                Log.i("batchJoinRoom", "local last " + mLastChatHistoryList.getJid() + "," + mLocalLastMessage + ", offlineTime " + offlineTime);
                                            } else {
                                                Log.i("batchJoinRoom", "生成任务 " + mLastChatHistoryList.getJid() + "," + mLocalLastMessage + ", time " + startTime + "," + offlineTime);
                                                // 生成一条群组漫游任务，存入任务表
                                                MsgRoamTask mMsgRoamTask = new MsgRoamTask();
                                                mMsgRoamTask.setTaskId(TimeUtils.sk_time_current_time());
                                                mMsgRoamTask.setOwnerId(mLoginUserId);
                                                mMsgRoamTask.setUserId(mLastChatHistoryList.getJid());
                                                mMsgRoamTask.setStartTime(startTime);
                                                if (mLocalLastMessage != null) {
                                                    mMsgRoamTask.setStartMsgId(mLocalLastMessage.getPacketId());
                                                }
                                                MsgRoamTaskDao.getInstance().createMsgRoamTask(mMsgRoamTask);
                                            }
                                        }
                                        // 更新朋友表部分字段，用于显示
                                        String str;
                                        if (mLastChatHistoryList.getEncryptType() != 0) {
                                            mLastChatHistoryList.setIsEncrypt(mLastChatHistoryList.getEncryptType());
                                        }
                                        if (mLastChatHistoryList.getIsEncrypt() != 0
                                                && !TextUtils.isEmpty(mLastChatHistoryList.getContent())) {// 需要解密
                                            str = ChatMessageDao.getInstance().decrypt(mLastChatHistoryList.getType() == 1,
                                                    mLastChatHistoryList.getJid(), mLastChatHistoryList.getContent(), mLastChatHistoryList.getIsEncrypt(),
                                                    mLastChatHistoryList.getMessageId(), mLastChatHistoryList.getTimeSend());
                                        } else {
                                            str = mLastChatHistoryList.getContent();
                                        }

                                        FriendDao.getInstance().updateApartDownloadTime(mLastChatHistoryList.getUserId(), mLastChatHistoryList.getJid(),
                                                str, mLastChatHistoryList.getType(), mLastChatHistoryList.getTimeSend(),
                                                mLastChatHistoryList.getIsRoom(), mLastChatHistoryList.getFrom(), mLastChatHistoryList.getFromUserName(),
                                                mLastChatHistoryList.getToUserName());
                                    }

                                    // 以上任务生成之后，在通知XMPP加入群组 获取群组离线消息
                                    MsgBroadcast.broadcastMsgUiUpdate(MyApplication.getContext());
                                    batchJoinMucChat();
                                    //  joinExistGroup();
                                }
                            }).start();
                        } else {// 数据异常，也需要调用XMPP加入群组
                            batchJoinMucChat();
                            //  joinExistGroup();
                        }
                    }

                    @Override
                    public void onError(Call call, Exception e) {
                        // 同上
                        batchJoinMucChat();
                        //  joinExistGroup();
                    }
                });
    }

    // 现在加入了群组分页漫游，群组的离线消息不能立即获取，必须要等到'tigase/getLastChatList'接口调用完毕后在加入群组，获取离线消息记录
/*
    public void joinExistGroup() {
        // 先获取全局的离线-->上线 这个时间段的时间
        long lastSeconds;
        long offlineTime = PreferenceUtils.getLong(MyApplication.getContext(), Constants.OFFLINE_TIME + mLoginUserId, 0);// 离线时间存的为秒，需要毫秒
        if (offlineTime == 0) {
            lastSeconds = 1546272000000l;// 2019年1月1日
        } else {
            lastSeconds = offlineTime * 1000;
        }

        ExecutorService executorService = Executors.newFixedThreadPool(2 * Runtime.getRuntime().availableProcessors());

        List<Friend> friends = FriendDao.getInstance().getAllRooms(mLoginUserId);// 获取本地所有群组
        if (friends != null && friends.size() > 0) {
            for (int i = 0; i < friends.size(); i++) {
                Friend friend = friends.get(i);
                if (friend.getGroupStatus() == 0) {// 群组状态正常才去获取离线消息
                    AsyncUtils.doAsync(this, e -> {
                        Reporter.post("加入群组出异常，", e);
                    }, executorService, c -> {
                        ChatMessage mLastChatMessage = ChatMessageDao.getInstance().getLastChatMessage(mLoginUserId, friend.getUserId());
                        if (mLastChatMessage != null) {// 如果该群组的最后一条消息不为空，将该条消息的timeSend作为当前群组的离线时间，这样比上面全局的离线时间更加准确
                            long lastMessageTimeSend = mLastChatMessage.getTimeSend();
                            joinMucChat(friend.getUserId(), lastMessageTimeSend - 3);
                        } else {// 该群组本地无消息记录，取全局的离线时间
                            joinMucChat(friend.getUserId(), lastSeconds);
                        }
                    });
                }
            }
        }
    }
*/

    /*
    发送本地通知
     */
    // 这个方法有被异步线程调用，
    @WorkerThread
    public void notificationMessage(ChatMessage chatMessage, boolean isGroupChat) {
        boolean isAppForeground = AppUtils.isAppForeground(this);
        Log.e(TAG, "notificationMessage() called with: chatMessage = [" + chatMessage.getContent() + "], isGroupChat = [" + isGroupChat + "], isAppForeground = [" + isAppForeground + "]");

        boolean isReturned = true;
        if (JitsistateMachine.isInCalling && (chatMessage.getType() == XmppMessage.TYPE_IS_CONNECT_VOICE
                || chatMessage.getType() == XmppMessage.TYPE_IS_CONNECT_VIDEO
                || chatMessage.getType() == XmppMessage.TYPE_IS_MU_CONNECT_VOICE
                || chatMessage.getType() == XmppMessage.TYPE_IS_MU_CONNECT_VIDEO
                || chatMessage.getType() == XmppMessage.TYPE_IS_MU_CONNECT_TALK)) {
            // 正在通话中并且收到音视频邀请消息 强制通知
            isReturned = false;
        }

        if (isAppForeground) {// 在前台 不通知
            return;
        }

        int messageType = chatMessage.getType();
        String title;
        String content;
        boolean isSpecialMsg = false;// 特殊消息 跳转至主界面 而非聊天界面

        switch (messageType) {
            case XmppMessage.TYPE_REPLAY:
            case XmppMessage.TYPE_TEXT:
                if (chatMessage.getIsReadDel()) {
                    content = getString(R.string.tip_click_to_read);
                } else {
                    content = chatMessage.getContent();
                }
                break;
            case XmppMessage.TYPE_VOICE:
                content = getString(R.string.msg_voice);
                break;
            case XmppMessage.TYPE_GIF:
                content = getString(R.string.msg_animation);
                break;
            case XmppMessage.TYPE_IMAGE:
                content = getString(R.string.msg_picture);
                break;
            case XmppMessage.TYPE_VIDEO:
                content = getString(R.string.msg_video);
                break;
            case XmppMessage.TYPE_RED:
                content = getString(R.string.msg_red_packet);
                break;
            case XmppMessage.TYPE_LOCATION:
                content = getString(R.string.msg_location);
                break;
            case XmppMessage.TYPE_CARD:
                content = getString(R.string.msg_card);
                break;
            case XmppMessage.TYPE_FILE:
                content = getString(R.string.msg_file);
                break;
            case XmppMessage.TYPE_TIP:
                content = getString(R.string.msg_system);
                break;
            case XmppMessage.TYPE_IMAGE_TEXT:
            case XmppMessage.TYPE_IMAGE_TEXT_MANY:
                content = getString(R.string.msg_image_text);
                break;
            case XmppMessage.TYPE_LINK:
            case XmppMessage.TYPE_SHARE_LINK:
                content = getString(R.string.msg_link);
                break;
            case XmppMessage.TYPE_SHAKE:
                content = getString(R.string.msg_shake);
                break;
            case XmppMessage.TYPE_CHAT_HISTORY:
                content = getString(R.string.msg_chat_history);
                break;
            case XmppMessage.TYPE_TRANSFER:
                content = getString(R.string.tip_transfer_money);
                break;
            case XmppMessage.TYPE_TRANSFER_RECEIVE:
                content = getString(R.string.tip_transfer_money) + getString(R.string.transfer_friend_sure_save);
                break;
            case XmppMessage.TYPE_TRANSFER_BACK:
                content = getString(R.string.transfer_back);
                break;
            case XmppMessage.TYPE_PAY_CERTIFICATE:
                content = getString(R.string.pay_certificate);
                break;
            case XmppMessage.TYPE_SCAN_RECHARGE:
                content = getString(R.string.scan_recharge_notify);
                break;
            case XmppMessage.TYPE_SCAN_WITHDRAW:
                content = getString(R.string.scan_withdraw_notify);
                break;
            case XmppMessage.TYPE_SECURE_LOST_KEY:
                content = getString(R.string.request_chat_key_group_thumb);
                break;

            case XmppMessage.TYPE_IS_CONNECT_VOICE:
                content = getString(R.string.suffix_invite_you_voice);
                break;
            case XmppMessage.TYPE_IS_CONNECT_VIDEO:
                content = getString(R.string.suffix_invite_you_video);
                break;
            case XmppMessage.TYPE_IS_CONNECT_SCREEN:
                content = getString(R.string.suffix_invite_you_screen);
                break;
            case XmppMessage.TYPE_IS_MU_CONNECT_VOICE:
                content = getString(R.string.suffix_invite_you_voice_meeting);
                break;
            case XmppMessage.TYPE_IS_MU_CONNECT_SCREEN:
                content = getString(R.string.suffix_invite_you_screen);
                break;
            case XmppMessage.TYPE_IS_MU_CONNECT_VIDEO:
                content = getString(R.string.suffix_invite_you_video_meeting);
                break;
            case XmppMessage.TYPE_IS_MU_CONNECT_TALK:
                content = getString(R.string.suffix_invite_you_talk);
                break;

            case XmppMessage.TYPE_SAYHELLO:// 打招呼
                isSpecialMsg = true;
                content = getString(R.string.apply_to_add_me_as_a_friend);
                break;
            case XmppMessage.TYPE_PASS:    // 同意加好友
                isSpecialMsg = true;
                content = getString(R.string.agree_with_my_plus_friend_request);
                break;
            case XmppMessage.TYPE_FRIEND:  // 直接成为好友
                isSpecialMsg = true;
                content = getString(R.string.added_me_as_a_friend);
                break;

            case XmppMessage.DIANZAN:// 朋友圈点赞
                isSpecialMsg = true;
                content = getString(R.string.notification_praise_me_life_circle);
                break;
            case XmppMessage.PINGLUN:    // 朋友圈评论
                isSpecialMsg = true;
                content = getString(R.string.notification_comment_me_life_circle);
                break;
            case XmppMessage.ATMESEE:  // 朋友圈提醒我看
                isSpecialMsg = true;
                content = getString(R.string.notification_at_me_life_circle);
                break;
            case XmppMessage.FRIEND_PUBLISH:  // 朋友圈好友动态更新
                isSpecialMsg = true;
                content = getString(R.string.notification_refresh_life_circle);
                break;

            default:// 其他消息类型不通知
                return;
        }

        createNotificationBuilder();

        String id;
        PendingIntent pendingIntent;
        if (isSpecialMsg) {
            title = chatMessage.getFromUserName();
            content = chatMessage.getFromUserName() + content;
            pendingIntent = pendingIntentForSpecial();
        } else {
            if (isGroupChat) {
                id = chatMessage.getToUserId();
                content = chatMessage.getFromUserName() + "：" + content;// 群组消息通知需要带上消息发送方的名字
            } else {
                id = chatMessage.getFromUserId();
            }

            Friend friend = FriendDao.getInstance().getFriend(mLoginUserId, id);
            if (friend != null) {
                title = TextUtils.isEmpty(friend.getRemarkName()) ? friend.getNickName() : friend.getRemarkName();
            } else {
                title = chatMessage.getFromUserName();
            }

            if (isGroupChat) {
                pendingIntent = pendingIntentForMuc(friend);
            } else {
                pendingIntent = pendingIntentForSingle(friend);
            }

        }
        if (pendingIntent == null)
            return;

        mBuilder.setContentIntent(pendingIntent);
        mBuilder.setContentTitle(title) // 通知标题
                .setContentText(content)  // 通知内容
                .setTicker(getString(R.string.tip_new_message))
                .setWhen(System.currentTimeMillis()) // 通知时间
                .setPriority(Notification.PRIORITY_HIGH) // 通知优先级
                .setAutoCancel(true)// 当用户单击面板就可以让通知自动取消
                .setOngoing(false)
                .setDefaults(Notification.DEFAULT_SOUND)
                .setDefaults(Notification.DEFAULT_VIBRATE)
                .setDefaults(Notification.DEFAULT_LIGHTS)
                .setSmallIcon(R.mipmap.icon); // 通知icon
        Notification n = mBuilder.build();
        String userId;
        if (isGroupChat) {
            userId = chatMessage.getToUserId();
        } else {
            userId = chatMessage.getFromUserId();
        }
        int numMessage = FriendDao.getInstance().getMsgUnReadNumTotal(mLoginUserId);
        // 先通知后保存的数据库，所以数据库里读出来的未读消息数要加1，
        ShortcutBadger.applyNotification(getApplicationContext(), n, numMessage + 1);
        // TODO: 弹多个消息可能导致角标重复计算未读消息数，叠加起来就不正确了，
        // 要miui角标显示全部未读消息数量和弹多个通知本来就是冲突的，角标数量是计在这个通知上的，
        // wx时准时不准，不知道什么逻辑，
        mNotificationManager.notify(userId, notifyId, n);
        if (isSpecialMsg) {// 特殊消息响铃通知
            NoticeVoicePlayer.getInstance().start();
        }
    }

    private void createNotificationBuilder() {
        // 同步锁防止线程冲突，大量消息通知时可能需要，
        if (mNotificationManager == null) {
            synchronized (this) {
                if (mNotificationManager == null) {
                    mNotificationManager = (NotificationManager) getApplicationContext()
                            .getSystemService(NOTIFICATION_SERVICE);
                }
            }
        }
        if (mBuilder == null) {
            synchronized (this) {
                if (mBuilder == null) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        NotificationChannel channel = new NotificationChannel(
                                MESSAGE_CHANNEL_ID,
                                getString(R.string.message_channel_name),
                                NotificationManager.IMPORTANCE_DEFAULT);
                        // 关闭通知铃声，我们有自己播放，
                        channel.setSound(null, null);
                        mNotificationManager.createNotificationChannel(channel);
                        mBuilder = new NotificationCompat.Builder(this, channel.getId());
                    } else {
                        //noinspection deprecation
                        mBuilder = new NotificationCompat.Builder(this);
                    }
                }
            }
        }
    }

    /**
     * <跳到单人聊天界面>
     */
    public PendingIntent pendingIntentForSingle(Friend friend) {
        Intent intent;
        if (friend != null) {
            if (TextUtils.equals(friend.getUserId(), Friend.ID_SK_PAY)) {
                intent = new Intent(getApplicationContext(), SKPayActivity.class);
            } else {
                intent = new Intent(getApplicationContext(), ChatActivity.class);
                intent.putExtra(AppConstant.EXTRA_FRIEND, friend);
            }
        } else {
            intent = new Intent(getApplicationContext(), MainActivity.class);
        }
        intent.putExtra(Constants.IS_NOTIFICATION_BAR_COMING, true);
        PendingIntent pendingIntent = PendingIntent.getActivity(getApplicationContext(), 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);
        return pendingIntent;
    }

    /**
     * <跳到群组聊天界面>
     */
    public PendingIntent pendingIntentForMuc(Friend friend) {
        Intent intent;
        if (friend != null) {
            intent = new Intent(getApplicationContext(), MucChatActivity.class);
            intent.putExtra(AppConstant.EXTRA_USER_ID, friend.getUserId());
            intent.putExtra(AppConstant.EXTRA_NICK_NAME, friend.getNickName());
        } else {
            intent = new Intent(getApplicationContext(), MainActivity.class);
        }
        intent.putExtra(Constants.IS_NOTIFICATION_BAR_COMING, true);
        PendingIntent pendingIntent = PendingIntent.getActivity(getApplicationContext(), 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);
        return pendingIntent;
    }

    /**
     * <跳到主界面>
     */
    public PendingIntent pendingIntentForSpecial() {
        Intent intent = new Intent(getApplicationContext(), MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(getApplicationContext(), 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);
        return pendingIntent;
    }

    public void register() {
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(com.sk.weichat.broadcast.OtherBroadcast.Read);
        registerReceiver(receiver, intentFilter);
    }

    /*
    发送已读消息
     */
    public class ReadBroadcastReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals(com.sk.weichat.broadcast.OtherBroadcast.Read)) {
                Bundle bundle = intent.getExtras();
                String packetId = bundle.getString("packetId");
                boolean isGroup = bundle.getBoolean("isGroup");
                String friendId = bundle.getString("friendId");
                String friendName = bundle.getString("fromUserName");

                ChatMessage msg = new ChatMessage();
                msg.setType(XmppMessage.TYPE_READ);
                msg.setFromUserId(mLoginUserId);
                msg.setFromUserName(friendName);
                msg.setToUserId(friendId);
                msg.setContent(packetId);
                // 发送已读消息 本地置为已读
                msg.setSendRead(true);
                msg.setPacketId(UUID.randomUUID().toString().replaceAll("-", ""));
                msg.setTimeSend(TimeUtils.sk_time_current_time());
                if (isGroup) {
                    sendMucChatMessage(friendId, msg);
                } else {
                    sendChatMessage(friendId, msg);
                }
            }
        }
    }

    // Binder
    public class CoreServiceBinder extends Binder {
        public CoreService getService() {
            return CoreService.this;
        }
    }
}
