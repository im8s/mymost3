package com.sk.weichat.xmpp.listener;

public interface AuthStateListener {
    int AUTH_STATE_INIT = 0;
    int AUTH_STATE_ING = 1;// 连接中
    int AUTH_STATE_SUCCESS = 2; // 已连接
    int AUTH_STATE_CLOSE = 3; // 连接关闭
    int AUTH_STATE_ERROR = 4; // 连接断开

    // XMPP的状态的回调
    void onAuthStateChange(int authState);
}
