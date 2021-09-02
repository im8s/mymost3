package com.sk.weichat.xmpp;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;

import com.sk.weichat.MyApplication;
import com.sk.weichat.helper.LoginHelper;
import com.sk.weichat.socket.EMConnectionManager;
import com.sk.weichat.socket.SocketException;
import com.sk.weichat.socket.msg.ChatMessage;
import com.sk.weichat.ui.UserCheckedActivity;
import com.sk.weichat.ui.base.CoreManager;
import com.sk.weichat.util.HttpUtil;
import com.sk.weichat.view.cjt2325.cameralibrary.util.LogUtil;

/**
 * XMPP连接类
 */
public class XmppConnectionManager {
    /* Handler */
    private static final int MSG_CONNECTING = 0; // 连接中...
    private static final int MSG_CONNECTED = 1; // 已连接
    private static final int MSG_AUTHENTICATED = 2; // 已认证
    private static final int MSG_CONNECTION_CLOSED = 3; // 连接关闭
    private static final int MSG_CONNECTION_CLOSED_ON_ERROR = 4; // 连接错误
    public static int mXMPPCurrentState;
    private Context mContext;

    private EMConnectionManager mConnection;

    private NotifyConnectionListener mNotifyConnectionListener;
    private XChatMessageListener mMessageListener;
    private XMuChatMessageListener mXMuChatMessageListener;

    private boolean mIsNetWorkActive;// 当前网络是否连接上

    @SuppressLint("HandlerLeak")
    private Handler mNotifyConnectionHandler = new Handler() {
        public void handleMessage(Message msg) {
            mXMPPCurrentState = msg.what;
            Log.e("zq", "当前XMPP连接状态:" + mXMPPCurrentState);
            if (msg.what == MSG_CONNECTING) {
                if (mNotifyConnectionListener != null) {
                    mNotifyConnectionListener.notifyConnecting();
                }
            } else if (msg.what == MSG_CONNECTED) {
                if (mNotifyConnectionListener != null) {
                    mNotifyConnectionListener.notifyConnected();
                }
            } else if (msg.what == MSG_AUTHENTICATED) {
                if (mNotifyConnectionListener != null) {
                    mNotifyConnectionListener.notifyAuthenticated();
                }
            } else if (msg.what == MSG_CONNECTION_CLOSED) {
                if (mNotifyConnectionListener != null) {
                    mNotifyConnectionListener.notifyConnectionClosed();
                }
            } else if (msg.what == MSG_CONNECTION_CLOSED_ON_ERROR) {
                if (mNotifyConnectionListener != null) {
                    String err = (String) msg.obj;
                    mNotifyConnectionListener.notifyConnectionClosedOnError(err);
                }
            }
        }
    };

    // 切换网络之后mNetWorkChangeReceiver会回调两次，且两次都是有网络的，会对Socket的断网重连造成一些影响，需要容错
    private long mLastLoginTime;// 上一次回调到该监听的时间
    private boolean isInValid;// 失效了 代表需要重新创建Socket连接
    private BroadcastReceiver mNetWorkChangeReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (TextUtils.isEmpty(action)) {
                return;
            }

            mIsNetWorkActive = isGprsOrWifiConnected();
            if (action.equals(ConnectivityManager.CONNECTIVITY_ACTION)) {
                Log.e("zq", "ConnectivityManager.CONNECTIVITY_ACTION-->HashCode" + this.hashCode());
                if (mIsNetWorkActive) {
                    Log.e("zq", "有网络连接1");
                    if (System.currentTimeMillis() - mLastLoginTime >= 1000) {
                        mLastLoginTime = System.currentTimeMillis();
                        if (isInValid) {
                            Log.e("zq", "isInValid == true，断开连接在登录1");
                            isInValid = false;
                            // Socket断开连接，即失效了，直接调用login没有用，需要先disconnect在登录(即建立一个Socket新的连接)
                            mConnection.disconnect();
                            login();
                        } else {
                            Log.e("zq", "isInValid == false，直接登录1");
                            // TODO: 应该判断socket已经连接上了才能login, 否则导致“连接中”变成“离线”，
                            login();
                        }
                    } else {
                        Log.e("zq", "有网络连接且连续回调到该广播1");
                    }
                } else {
                    Log.e("zq", "无网络连接1");
                }
            } else {
                Log.e("zq", "SocketException.SELECTION_KEY_INVALID-->HashCode" + this.hashCode());
                if (mIsNetWorkActive) {
                    Log.e("zq", "有网络连接2");
                    if (isInValid) {
                        Log.e("zq", "isInValid == true，断开连接在登录2");
                        isInValid = false;
                        // Socket断开连接，即失效了，直接调用login没有用，需要先disconnect在登录(即建立一个Socket新的连接)
                        mConnection.disconnect();
                        login();
                    } else {
                        Log.e("zq", "isInValid == false，已经处理过了，不处理2");
                    }
                } else {
                    Log.e("zq", "无网络连接2");
                }
            }
        }
    };

    public XmppConnectionManager(Context context, NotifyConnectionListener listener) {
        mContext = context;
        mNotifyConnectionListener = listener;

        mConnection = new EMConnectionManager(mContext);

        mConnection.addConnectionListener(new NotifyConnectionListener() {
            @Override
            public void notifyConnecting() {
                mNotifyConnectionHandler.sendEmptyMessage(MSG_CONNECTING);
            }

            @Override
            public void notifyConnected() {
                mNotifyConnectionHandler.sendEmptyMessage(MSG_CONNECTED);
            }

            @Override
            public void notifyAuthenticated() {
                mNotifyConnectionHandler.sendEmptyMessage(MSG_AUTHENTICATED);
            }

            @Override
            public void notifyConnectionClosed() {
                mNotifyConnectionHandler.sendEmptyMessage(MSG_CONNECTION_CLOSED);
            }

            @Override
            public void notifyConnectionClosedOnError(String err) {
                LogUtil.e("zq", "notifyConnectionClosedOnError：" + err);
                Message message = mNotifyConnectionHandler.obtainMessage();
                message.what = MSG_CONNECTION_CLOSED_ON_ERROR;
                message.obj = err;
                mNotifyConnectionHandler.sendMessage(message);

                if (TextUtils.equals(err, SocketException.LOGIN_CONFLICT_EXCEPTION)) {
                    ((CoreService) mContext).logout();
                    MyApplication.getInstance().mUserStatus = LoginHelper.STATUS_USER_TOKEN_CHANGE;
                    // 弹出对话框
                    UserCheckedActivity.start(mContext);
                } else if (TextUtils.equals(err, SocketException.SELECTION_KEY_INVALID)) {
                    /**
                     * 1.切换网络之后会回调到此处，但是会有两种情况产生
                     *  1.1：正常情况：先回调到该方法(即本地连接状态已置为离线)，之后网络监听监听到网络改变，判断是否有无网络，判断isInValid状态(是直接调用login还是disconnect之后在login)
                     *  1.2.：非正常情况：网络监听先监听到到网络改变(此时isInValid的状态为false，且本地连接状态为在线，调用login会直接Return掉)，之后在回调到该方法，之后无任何操作，造成断网连不上的问题
                     */
                    isInValid = true;
                    /**
                     * 2.异常断线也会回调到此处(网络正常，且不会触发网络监听，所以不会做后续处理，造成离线没有自动重连的问题)，原因UN_KNOW ，待查明
                     */
                    // 为了解决1.2、2的情况，回调到此处后发送一个广播出去重连
                    MyApplication.getInstance().sendBroadcast(new Intent(SocketException.SELECTION_KEY_INVALID));
                } else if (TextUtils.equals(err, SocketException.SOCKET_CHANNEL_OPEN_EXCEPTION)
                        || TextUtils.equals(err, SocketException.FINISH_CONNECT_EXCEPTION)) {
                    isInValid = true;
                    if (TextUtils.equals(err, SocketException.FINISH_CONNECT_EXCEPTION)) {
                        // 出现该异常，disconnect在login可能已经起不了作用了，换种方式重连
                        MyApplication.getInstance().sendBroadcast(new Intent(SocketException.FINISH_CONNECT_EXCEPTION));
                    }
                }
            }
        });

        initNetWorkStatusReceiver();
    }

    /*********************
     * 网络连接状态
     ***************/
    private void initNetWorkStatusReceiver() {
        // 获取程序启动时的网络状态
        mIsNetWorkActive = isGprsOrWifiConnected();
        // 注册网络监听广播
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
        intentFilter.addAction(SocketException.SELECTION_KEY_INVALID);
        mContext.registerReceiver(mNetWorkChangeReceiver, intentFilter);
    }

    private boolean isGprsOrWifiConnected() {
        // Todo 在部分机型上，系统的提供的网络判断也是不准确的，所以这里还需要优化
        return HttpUtil.isGprsOrWifiConnected(mContext);
    }

    public void addMessageListener() {
        CoreService service = (CoreService) mContext;
        mMessageListener = new XChatMessageListener(service);
        mXMuChatMessageListener = new XMuChatMessageListener(service);
        mConnection.addIncomingListener(mMessageListener);
        mConnection.addMuChatMessageListener(mXMuChatMessageListener);
    }

    public EMConnectionManager getConnection() {
        if (mConnection == null) {
            mConnection = new EMConnectionManager(mContext);
        }
        return mConnection;
    }

    public boolean isAuthenticated() {
        return mConnection != null && mConnection.isConnected() && mConnection.isAuthenticated();
    }

    public void sendMessage(ChatMessage chatMessage) {
        mConnection.sendMessage(chatMessage);
    }

    public synchronized void login() {
        if (mConnection.isAuthenticated()) {
            Log.e("zq", "已认证，Return");
            return;
        }

        String token = CoreManager.requireSelfStatus(mContext).accessToken;
        String userId = CoreManager.requireSelf(mContext).getUserId();
        mConnection.login(token, userId);
    }

    void logout() {
        if (mConnection == null) {
            return;
        }

        mConnection.removeConnectionListener();// 移除掉该监听，防止之后又回调到SocketException.SELECTION_KEY_INVALID又去重连导致两台设备循环登录

        if (mConnection.isConnected()) {
            mConnection.disconnect();
        }
    }

    void release() {
        mContext.unregisterReceiver(mNetWorkChangeReceiver);
    }
}
