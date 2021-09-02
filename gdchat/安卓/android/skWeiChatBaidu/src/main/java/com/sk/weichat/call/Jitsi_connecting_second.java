package com.sk.weichat.call;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.media.MediaPlayer;
import android.os.Build;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.IBinder;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.facebook.react.modules.core.PermissionListener;
import com.sk.weichat.R;
import com.sk.weichat.Reporter;
import com.sk.weichat.bean.Friend;
import com.sk.weichat.bean.VideoFile;
import com.sk.weichat.bean.event.EventNotifyByTag;
import com.sk.weichat.bean.message.ChatMessage;
import com.sk.weichat.bean.message.XmppMessage;
import com.sk.weichat.db.dao.FriendDao;
import com.sk.weichat.db.dao.VideoFileDao;
import com.sk.weichat.helper.AvatarHelper;
import com.sk.weichat.helper.CutoutHelper;
import com.sk.weichat.helper.DialogHelper;
import com.sk.weichat.ui.base.BaseActivity;
import com.sk.weichat.util.AppUtils;
import com.sk.weichat.util.HttpUtil;
import com.sk.weichat.util.PermissionUtil;
import com.sk.weichat.util.PreferenceUtils;
import com.sk.weichat.util.TimeUtils;
import com.sk.weichat.view.SelectionFrame;
import com.sk.weichat.view.TipDialog;

import org.jitsi.meet.sdk.JitsiMeetActivityDelegate;
import org.jitsi.meet.sdk.JitsiMeetActivityInterface;
import org.jitsi.meet.sdk.JitsiMeetConferenceOptions;
import org.jitsi.meet.sdk.JitsiMeetView;
import org.jitsi.meet.sdk.JitsiMeetViewListener;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import androidx.annotation.Nullable;
import de.greenrobot.event.EventBus;
import de.greenrobot.event.Subscribe;
import de.greenrobot.event.ThreadMode;
import io.jsonwebtoken.Jwts;

import static com.sk.weichat.bean.message.XmppMessage.TYPE_EXIT_VOICE;
import static com.sk.weichat.bean.message.XmppMessage.TYPE_VIDEO_OUT;

/**
 * 2018-2-27 录屏，保存至本地视频
 */
public class Jitsi_connecting_second extends BaseActivity implements JitsiMeetActivityInterface {
    private static final String TAG = "Jitsi_connecting_second";
    // 屏幕录制
    private static final int RECORD_REQUEST_CODE = 0x01;
    // 计时，给悬浮窗调用
    public static String time = null;
    private String mLocalHostJitsi = "https://meet.jit.si/";// 官网地址
    private String mLocalHost/* = "https://meet.youjob.co/"*/;  // 本地地址,现改为变量
    // 通话类型(单人语音、单人视频、群组语音、群组视频)
    private int mCallType;
    // 房间名，单聊发起人userId，群聊群组jid,
    private String fromUserId;
    // 收消息的对象，单聊是对方userId, 群聊是群组jid,
    private String toUserId;
    private long startTime = System.currentTimeMillis();// 通话开始时间
    private long stopTime; // 通话结束时间
    private FrameLayout mFrameLayout;
    private JitsiMeetView mJitsiMeetView;
    private ImageView ivChange;
    // 悬浮窗按钮
    private ImageView mFloatingView;
    // 录屏
    private LinearLayout mRecordLL;
    private ImageView mRecordIv;
    private TextView mRecordTv;
    // 标记当前手机版本是否为android 5.0,且为对方挂断
    private boolean isApi21HangUp;
    // private MediaProjection mediaProjection;
    private RecordService recordService;
    private ServiceConnection connection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName className, IBinder service) {
            DisplayMetrics metrics = new DisplayMetrics();
            getWindowManager().getDefaultDisplay().getMetrics(metrics);
            RecordService.RecordBinder binder = (RecordService.RecordBinder) service;
            recordService = binder.getRecordService();
            recordService.setConfig(metrics.widthPixels, metrics.heightPixels, metrics.densityDpi);
        }

        @Override
        public void onServiceDisconnected(ComponentName arg0) {
        }
    };
    private SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat("mm:ss");
    CountDownTimer mCountDownTimer = new CountDownTimer(18000000, 1000) {// 开始计时，用于显示在悬浮窗上，且每隔一秒发送一个广播更新悬浮窗
        @Override
        public void onTick(long millisUntilFinished) {
            time = formatTime();
            Jitsi_connecting_second.this.sendBroadcast(new Intent(CallConstants.REFRESH_FLOATING));
        }

        @Override
        public void onFinish() {// 12小时进入Finish

        }
    };
    private boolean isOldVersion = true;// 是否为老版本，如果一次 "通话中" 消息都没有收到，就判断对方使用的为老版本，自己也停止ping且不做检测
    private boolean isEndCallOpposite;// 对方是否结束了通话
    private int mPingReceiveFailCount;// 未收到对方发送 "通话中" 消息的次数
    // 每隔3秒给对方发送一条 "通话中" 消息
    CountDownTimer mCallingCountDownTimer = new CountDownTimer(3000, 1000) {
        @Override
        public void onTick(long millisUntilFinished) {

        }

        @Override
        public void onFinish() {// 计时结束
            if (isFinishing()) {
                // 避免activity结束后还在回调这个ping,
                return;
            }
            if (!HttpUtil.isGprsOrWifiConnected(Jitsi_connecting_second.this)) {
                TipDialog tipDialog = new TipDialog(Jitsi_connecting_second.this);
                tipDialog.setmConfirmOnClickListener(getString(R.string.check_network), () -> {
                    leaveJitsi();
                });

                tipDialog.show();
                return;
            }
            if ( mCallType == 1 || mCallType == 2 || mCallType == 3 || mCallType == 4 || mCallType == 5 || mCallType == 6) {// 单人音视频通话
                if (isEndCallOpposite) {// 未收到对方发送的 "通话中" 消息
                    // 考虑到弱网情况，当Count等于3时才真正认为对方已经结束了通话，否则继续发送 "通话中" 消息且count+1
                    int maxCount = 10;
                    if (mCallType == 5 || mCallType == 6) {
                        // 对讲机ping次数少点，
                        maxCount = 4;
                    }
                    if (mPingReceiveFailCount == maxCount) {
                        if (isOldVersion) {
                            return;
                        }
                        Log.e(TAG, "true-->" + TimeUtils.sk_time_current_time());
                        if (!isDestroyed()) {
                            stopTime = System.currentTimeMillis();
                            overCall((int) (stopTime - startTime) / 1000);
                            Toast.makeText(Jitsi_connecting_second.this, getString(R.string.tip_opposite_offline_auto__end_call), Toast.LENGTH_SHORT).show();
                            leaveJitsi();
/*
                            TipDialog tipDialog = new TipDialog(Jitsi_connecting_second.this);
                            tipDialog.setmConfirmOnClickListener(getString(R.string.tip_opposite_offline_end_call), () -> {
                                stopTime = System.currentTimeMillis();
                                overCall((int) (stopTime - startTime) / 1000);
                                leaveJitsi();
                            });
                            tipDialog.show();
*/
                        }
                    } else {
                        mPingReceiveFailCount++;
                        Log.e(TAG, "true-->" + mPingReceiveFailCount + "，" + TimeUtils.sk_time_current_time());
                        sendCallingMessage();
                    }
                } else {
                    Log.e(TAG, "false-->" + TimeUtils.sk_time_current_time());
                    sendCallingMessage();
                }
            }
        }
    };

    public static void start(Context ctx, String fromuserid, String touserid, int type) {
        start(ctx, fromuserid, touserid, type, null);
    }

    public static void start(Context ctx, String fromuserid, String touserid, int type, @Nullable String meetUrl) {
        if (type == CallConstants.Talk_Meet) {
            Intent intent = new Intent(ctx, JitsiTalk.class);
            intent.putExtra("type", type);
            intent.putExtra("fromuserid", fromuserid);
            intent.putExtra("touserid", touserid);
            if (!TextUtils.isEmpty(meetUrl)) {
                intent.putExtra("meetUrl", meetUrl);
            }
            ctx.startActivity(intent);
            return;
        }
        Intent intent = new Intent(ctx, Jitsi_connecting_second.class);
        intent.putExtra("type", type);
        intent.putExtra("fromuserid", fromuserid);
        intent.putExtra("touserid", touserid);
        if (!TextUtils.isEmpty(meetUrl)) {
            intent.putExtra("meetUrl", meetUrl);
        }
        ctx.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        CutoutHelper.setWindowOut(getWindow());
        super.onCreate(savedInstanceState);
        // 自动解锁屏幕 | 锁屏也可显示 | Activity启动时点亮屏幕 | 保持屏幕常亮
        getWindow().addFlags(
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                        | WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                        | WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                        | WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        setContentView(R.layout.jitsiconnecting);
        initData();
        initView();
        initEvent();
        EventBus.getDefault().register(this);
        JitsiMeetActivityDelegate.onHostResume(this);
        setSwipeBackEnable(false);
    }

    @Override
    public void onCoreReady() {
        super.onCoreReady();
        sendCallingMessage();// 对方可能一进入就已经挂掉了，我们就会误判对方未老版本，所以一进入就发送一条 "通话中" 消息给对方
    }

    private void initData() {
        mCallType = getIntent().getIntExtra("type", 0);
        fromUserId = getIntent().getStringExtra("fromuserid");
        toUserId = getIntent().getStringExtra("touserid");

        JitsistateMachine.isInCalling = true;
        if (mCallType == 1 || mCallType == 2) {
            JitsistateMachine.callingOpposite = toUserId;
        } else {
            // 会议的话，改成记住群id,以免发起会议的人发起单聊时被挤下，
            JitsistateMachine.callingOpposite = fromUserId;
        }

        if (mCallType == 1 || mCallType == 2) {// 集群
            mLocalHost = getIntent().getStringExtra("meetUrl");
            if (TextUtils.isEmpty(mLocalHost)) {
                mLocalHost = coreManager.getConfig().JitsiServer;
            }
        } else {
            mLocalHost = coreManager.getConfig().JitsiServer;
        }

        if (TextUtils.isEmpty(mLocalHost)) {
            DialogHelper.tip(mContext, getString(R.string.tip_meet_server_empty));
            finish();
        }

        // mCallingCountDownTimer.start();
    }

    private void leaveJitsi() {
        Log.e(TAG, "leaveJitsi() called ");
        finish();
    }

    /**
     * startWithAudioMuted:是否禁用语音
     * startWithVideoMuted:是否禁用录像
     */
    private void initView() {
        CutoutHelper.initCutoutHolderTop(getWindow(), findViewById(R.id.vCutoutHolder));
        if (mCallType == 1 || mCallType == 2) {
            ivChange = findViewById(R.id.ivChange);
            if (mCallType == 1) {
                ivChange.setImageResource(R.mipmap.call_change_to_video);
            }
            ivChange.setVisibility(View.VISIBLE);
            ivChange.setOnClickListener(v -> {
                toggleCallType();
                // 通知对方切换语音视频，
                sendToggleCallType();
            });
        }
        mFrameLayout = (FrameLayout) findViewById(R.id.jitsi_view);
        mJitsiMeetView = new JitsiMeetView(this);
        mFrameLayout.addView(mJitsiMeetView);

        mFloatingView = (ImageView) findViewById(R.id.open_floating);

        mRecordLL = (LinearLayout) findViewById(R.id.record_ll);
        mRecordIv = (ImageView) findViewById(R.id.record_iv);
        mRecordTv = (TextView) findViewById(R.id.record_tv);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {// 5.0以下录屏需要root，不考虑
            Intent intent = new Intent(this, RecordService.class);
            bindService(intent, connection, BIND_AUTO_CREATE);
            mRecordLL.setVisibility(View.VISIBLE);
        }
        // TODO 暂时关闭录屏功能
        mRecordLL.setVisibility(View.GONE);

        // 配置房间参数
        JitsiMeetConferenceOptions.Builder options = new JitsiMeetConferenceOptions.Builder()
                .setWelcomePageEnabled(false);
//TODO        mJitsiMeetView.setPictureInPictureEnabled(false);
        if (mCallType == 1 || mCallType == 3) {
            options.setVideoMuted(true);
        }
        try {
            options.setServerURL(new URL(mLocalHost));
        } catch (MalformedURLException e) {
            throw new IllegalStateException("jitsi地址异常: " + mLocalHost);
        }
        if (mCallType == 3) {// 群组语音添加标识，防止和群组视频进入同一房间地址
            options.setRoom("audio" + fromUserId);
        } else {
            options.setRoom(fromUserId);
        }
        loadJwt(options);
        // 开始加载
        mJitsiMeetView.join(options.build());
    }

    private void sendToggleCallType() {
        ChatMessage chatMessage = new ChatMessage();
        chatMessage.setType(XmppMessage.TYPE_CHANGE_VIDEO_ENABLE);
        // mCallType是切换后的类型，
        // content为1表示改成视频通话，为0表示改成语音通话，
        if (mCallType == 1) {
            chatMessage.setContent(String.valueOf(0));
        } else if (mCallType == 2) {
            chatMessage.setContent(String.valueOf(1));
        } else {
            Reporter.unreachable();
            return;
        }

        chatMessage.setFromUserId(coreManager.getSelf().getUserId());
        chatMessage.setFromUserName(coreManager.getSelf().getNickName());
        chatMessage.setToUserId(toUserId);
        chatMessage.setTimeSend(TimeUtils.sk_time_current_time());
        chatMessage.setPacketId(UUID.randomUUID().toString().replaceAll("-", ""));
        coreManager.sendChatMessage(toUserId, chatMessage);
    }

    private void toggleCallType() {
        toggleCallType(mCallType == 1);
    }

    /**
     * @param videoEnable 改通话类型之后的视频启动情况，为true表示改成视频通话，为false表示改成语音通话，
     */
    private void toggleCallType(boolean videoEnable) {
        if (videoEnable) {
            mCallType = 2;
            mJitsiMeetView.setVideoEnable();
            ivChange.setImageResource(R.mipmap.call_change_to_voice);
        } else {
            mCallType = 1;
            mJitsiMeetView.setVideoMuted();
            ivChange.setImageResource(R.mipmap.call_change_to_video);
        }
    }

    @SuppressWarnings("unchecked")
    private void loadJwt(JitsiMeetConferenceOptions.Builder options) {
        try {
            Map<String, String> user = new HashMap<>();
            user.put("avatar", AvatarHelper.getAvatarUrl(coreManager.getSelf().getUserId(), false));
            user.put("name", coreManager.getSelf().getNickName());
            Map<String, Object> context = new HashMap<>();
            context.put("user", user);
            Map<String, Object> payload = new HashMap<>();
            payload.put("context", context);
            String jwt = Jwts.builder().addClaims(payload)
                    .compact();
            options.setToken(jwt);
        } catch (Exception e) {
            Log.e(TAG, "loadJwt: 加载用户信息失败", e);
        }
    }

    private void initEvent() {
        ImageView iv = findViewById(R.id.ysq_iv);
        Friend friend = FriendDao.getInstance().getFriend(coreManager.getSelf().getUserId(), fromUserId);
        if (friend != null && friend.getRoomFlag() != 0) {
            iv.setVisibility(View.VISIBLE);
            // 群组会议，可邀请其他群成员
            iv.setOnClickListener(v -> {
                JitsiInviteActivity.start(this, mCallType, fromUserId);
            });
        }

        mJitsiMeetView.setListener(new JitsiMeetViewListener() {

            @Override
            public void onConferenceWillJoin(Map<String, Object> map) {
                Log.e("jitsi", "即将加入会议");
            }

            @Override
            public void onConferenceJoined(Map<String, Object> map) {
                Log.e(TAG, "已加入会议，显示悬浮窗按钮，开始计时");
                // 如果将runOnUiThread放在onConferenceWillJoin内，底部会闪现一条白边，偶尔白边还不会消失
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mFloatingView.setVisibility(View.VISIBLE);
                    }
                });
                // 会议开始，记录开始时间
                startTime = System.currentTimeMillis();
                // 开始计时
                mCountDownTimer.start();
            }

            @Override
            public void onConferenceTerminated(Map<String, Object> map) {
                Log.e(TAG, "5");
                // 即将离开会议
                if (!isApi21HangUp) {
                    stopTime = System.currentTimeMillis();
                    overCall((int) (stopTime - startTime) / 1000);
                }

                Log.e(TAG, "6");
                Jitsi_connecting_second.this.sendBroadcast(new Intent(CallConstants.CLOSE_FLOATING));
                finish();
            }
        });

        mFloatingView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (AppUtils.checkAlertWindowsPermission(Jitsi_connecting_second.this)) { // 已开启悬浮窗权限
                    // nonRoot = false→ 仅当activity为task根（即首个activity例如启动activity之类的）时才生效
                    // nonRoot = true → 忽略上面的限制
                    // 这个方法不会改变task中的activity中的顺序，效果基本等同于home键
                    moveTaskToBack(true);
                    // 开启悬浮窗
                    Intent intent = new Intent(getApplicationContext(), JitsiFloatService.class);
                    startService(intent);
                } else { // 未开启悬浮窗权限
                    SelectionFrame selectionFrame = new SelectionFrame(Jitsi_connecting_second.this);
                    selectionFrame.setSomething(null, getString(R.string.av_no_float), new SelectionFrame.OnSelectionFrameClickListener() {
                        @Override
                        public void cancelClick() {
                            hideBottomUIMenu();
                        }

                        @Override
                        public void confirmClick() {
                            PermissionUtil.startApplicationDetailsSettings(Jitsi_connecting_second.this, 0x01);
                            hideBottomUIMenu();
                        }
                    });
                    selectionFrame.show();
                }
            }
        });

        mRecordLL.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
/*
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    if (recordService.isRunning()) {
                        if (recordService.stopRecord()) {
                            mRecordIv.setImageResource(R.drawable.recording);
                            mRecordTv.setText(getString(R.string.screen_record));
                            saveScreenRecordFile();// 将录制的视频保存至本地
                        }
                    } else {
                        // 申请屏幕录制
                        MediaProjectionManager projectionManager = (MediaProjectionManager) getSystemService(MEDIA_PROJECTION_SERVICE);
                        if (projectionManager != null) {
                            Intent captureIntent = projectionManager.createScreenCaptureIntent();
                            startActivityForResult(captureIntent, RECORD_REQUEST_CODE);
                        }
                    }
                }
*/
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == RECORD_REQUEST_CODE && resultCode == RESULT_OK) {
/*
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                MediaProjectionManager projectionManager = (MediaProjectionManager) getSystemService(MEDIA_PROJECTION_SERVICE);
                if (projectionManager != null) {
                    mediaProjection = projectionManager.getMediaProjection(resultCode, data);
                    recordService.setMediaProject(mediaProjection);
                    // 开始录制
                    recordService.startRecord();

                    mRecordIv.setImageResource(R.drawable.stoped);
                    mRecordTv.setText(getString(R.string.stop));
                }
            }
*/
        } else {
            JitsiMeetActivityDelegate.onActivityResult(
                    this, requestCode, resultCode, data);
        }
    }

    public void sendCallingMessage() {
        isEndCallOpposite = true;

        ChatMessage chatMessage = new ChatMessage();
        chatMessage.setType(XmppMessage.TYPE_IN_CALLING);

        chatMessage.setFromUserId(coreManager.getSelf().getUserId());
        chatMessage.setFromUserName(coreManager.getSelf().getNickName());
        chatMessage.setToUserId(toUserId);
        chatMessage.setTimeSend(TimeUtils.sk_time_current_time());
        chatMessage.setPacketId(UUID.randomUUID().toString().replaceAll("-", ""));
        coreManager.sendChatMessage(toUserId, chatMessage);

        mCallingCountDownTimer.start();// 重新开始计时
    }

    @Subscribe(threadMode = ThreadMode.MainThread)
    public void helloEventBus(final EventNotifyByTag message) {
        if (message.tag.equals(EventNotifyByTag.Interrupt)) {
            sendBroadcast(new Intent(CallConstants.CLOSE_FLOATING));
            leaveJitsi();
        }
    }

    @Subscribe(threadMode = ThreadMode.MainThread)
    public void helloEventBus(final MessageCallTypeChange message) {
        if (message.chatMessage.getType() == XmppMessage.TYPE_CHANGE_VIDEO_ENABLE) {
            if (message.chatMessage.getFromUserId().equals(toUserId)) {
                toggleCallType(TextUtils.equals(message.chatMessage.getContent(), "1"));
            }
        }
    }

    @Subscribe(threadMode = ThreadMode.MainThread)
    public void helloEventBus(final MessageCallingEvent message) {
        if (message.chatMessage.getType() == XmppMessage.TYPE_IN_CALLING) {
            if (message.chatMessage.getFromUserId().equals(toUserId)) {
                isOldVersion = false;
                // 收到 "通话中" 的消息，且该消息为当前通话对象发送过来的
                Log.e(TAG, "MessageCallingEvent-->" + TimeUtils.sk_time_current_time());
                mPingReceiveFailCount = 0;// 将count置为0
                isEndCallOpposite = false;
            }
        }
    }

    // 对方挂断
    @Subscribe(threadMode = ThreadMode.MainThread)
    public void helloEventBus(final MessageHangUpPhone message) {
        if (message.chatMessage.getFromUserId().equals(fromUserId)
                || message.chatMessage.getFromUserId().equals(toUserId)) {// 挂断方为当前通话对象 否则不处理
            if (Build.VERSION.SDK_INT == Build.VERSION_CODES.LOLLIPOP) {
                isApi21HangUp = true;
                TipDialog tip = new TipDialog(Jitsi_connecting_second.this);
                tip.setmConfirmOnClickListener(getString(R.string.av_hand_hang), new TipDialog.ConfirmOnClickListener() {
                    @Override
                    public void confirm() {
                        hideBottomUIMenu();
                    }
                });
                tip.show();
                return;
            }

            // 关闭悬浮窗
            sendBroadcast(new Intent(CallConstants.CLOSE_FLOATING));
            leaveJitsi();
        }
    }

    /*******************************************
     * Method
     ******************************************/
    // 发送挂断的XMPP消息
    private void overCall(int time) {
        if (mCallType == 1) {
            EventBus.getDefault().post(new MessageEventCancelOrHangUp(104, toUserId,
                    getString(R.string.sip_canceled) + getString(R.string.voice_chat),
                    time));
        } else if (mCallType == 2) {
            EventBus.getDefault().post(new MessageEventCancelOrHangUp(114, toUserId,
                    getString(R.string.sip_canceled) + getString(R.string.video_call),
                    time));
        }  if (mCallType == 3) {
            EventBus.getDefault().post(new MessageEventCancelOrHangUp(TYPE_VIDEO_OUT, fromUserId,
                    "结束了" + getString(R.string.video_call),
                    time));
        } else if (mCallType == 4) {
            EventBus.getDefault().post(new MessageEventCancelOrHangUp(TYPE_EXIT_VOICE, fromUserId,
                    "结束了" + getString(R.string.voice_chat),
                    time));
        } else if (mCallType == 5) {
            EventBus.getDefault().post(new MessageEventCancelOrHangUp(134, toUserId,
                    getString(R.string.sip_canceled) + getString(R.string.name_talk),
                    time));
        }
    }

    private String formatTime() {
        Date date = new Date(new Date().getTime() - startTime);
        return mSimpleDateFormat.format(date);
    }

    // 隐藏虚拟按键
    private void hideBottomUIMenu() {
        View v = this.getWindow().getDecorView();
        v.setSystemUiVisibility(View.GONE);
    }

    /*******************************************
     * 录屏，保存至本地视频
     ******************************************/
    public void saveScreenRecordFile() {
        // 录屏文件路径
        String imNewestScreenRecord = PreferenceUtils.getString(getApplicationContext(), "IMScreenRecord");
        File file = new File(imNewestScreenRecord);
        if (file.exists() && file.getName().trim().toLowerCase().endsWith(".mp4")) {
            VideoFile videoFile = new VideoFile();
            videoFile.setCreateTime(TimeUtils.f_long_2_str(getScreenRecordFileCreateTime(file.getName())));
            videoFile.setFileLength(getScreenRecordFileTimeLen(file.getPath()));
            videoFile.setFileSize(file.length());
            videoFile.setFilePath(file.getPath());
            videoFile.setOwnerId(coreManager.getSelf().getUserId());
            VideoFileDao.getInstance().addVideoFile(videoFile);
        }
    }

    private long getScreenRecordFileCreateTime(String srf) {
        int dot = srf.lastIndexOf('.');
        return Long.parseLong(srf.substring(0, dot));
    }

    private long getScreenRecordFileTimeLen(String srf) {
        long duration;
        MediaPlayer player = new MediaPlayer();
        try {
            player.setDataSource(srf);
            player.prepare();
            duration = player.getDuration() / 1000;
        } catch (Exception e) {
            duration = 10;
            e.printStackTrace();
        }
        player.release();
        return duration;
    }

    /*******************************************
     * 生命周期
     ******************************************/
    @Override
    public void onBackPressed() {
        // 不允许按返回键离开房间，也不能finish，
    }

    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        JitsiMeetActivityDelegate.onNewIntent(intent);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (JitsistateMachine.isFloating) {
            sendBroadcast(new Intent(CallConstants.CLOSE_FLOATING));
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        // 释放摄像头，
        JitsiMeetActivityDelegate.onHostPause(this);
        JitsistateMachine.reset();

        mCallingCountDownTimer.cancel();

        JitsiMeetActivityDelegate.onBackPressed();
        mJitsiMeetView.dispose();
        JitsiMeetActivityDelegate.onHostDestroy(this);

        EventBus.getDefault().unregister(this);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            if (connection != null) {
                // 1.用户开启录屏之后未结束录屏就直接结束通话了，此时需要释放部分资源，否则下次录屏会引发崩溃
                // 2.对方结束通话
                if (recordService.isRunning()) {
                    recordService.stopRecord();
                    saveScreenRecordFile();
                }
                unbindService(connection);
            }
        }

        if (mCountDownTimer != null) {
            mCountDownTimer.cancel();
        }
        Log.e(TAG, "onDestory");
        super.onDestroy();
    }

    @Override
    public void onRequestPermissionsResult(
            final int requestCode,
            final String[] permissions,
            final int[] grantResults) {
        JitsiMeetActivityDelegate.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    @Override
    public void requestPermissions(String[] permissions, int requestCode, PermissionListener listener) {
        JitsiMeetActivityDelegate.requestPermissions(this, permissions, requestCode, listener);
    }

    @Override
    public void onPointerCaptureChanged(boolean hasCapture) {
        Log.d(TAG, "onPointerCaptureChanged() called with: hasCapture = [" + hasCapture + "]");
    }
}
