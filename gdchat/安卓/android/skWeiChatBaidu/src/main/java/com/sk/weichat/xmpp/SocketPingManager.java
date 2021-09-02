package com.sk.weichat.xmpp;


import android.util.Log;

import com.sk.weichat.MyApplication;
import com.sk.weichat.socket.EMConnectionManager;
import com.sk.weichat.ui.base.CoreManager;
import com.sk.weichat.xmpp.listener.AuthStateListener;

public class SocketPingManager {

    private static final long MESSAGE_DELAY = CoreManager.requireConfig(MyApplication.getContext()).xmppPingTime * 1000; // 延迟*之后ping一次服务器
    private static SocketPingManager instance;
    private EMConnectionManager mEMConnectionManager;
    private PingThread mPingThread;

    private SocketPingManager() {

    }

    public static synchronized SocketPingManager getInstance() {
        if (instance == null) {
            instance = new SocketPingManager();
        }
        return instance;
    }

    public void registerPing(EMConnectionManager connectionManager) {
        mEMConnectionManager = connectionManager;
        if (mPingThread == null) {
            mPingThread = new PingThread();
            mPingThread.start();
        } else {
            if (!mPingThread.isAlive()) {
                // 不能直接调用run, 会阻塞当前线程导致无法读取socket数据，
                mPingThread = new PingThread();
                mPingThread.start();
            }
        }
    }

    class PingThread extends Thread {

        public PingThread() {
        }

        @Override
        public void run() {
            super.run();
            Log.e("ping", "Start ping......");
            while (mEMConnectionManager.getCurrentState() == AuthStateListener.AUTH_STATE_SUCCESS) {
                mEMConnectionManager.sendPingMessage();
                try {
                    Thread.sleep(MESSAGE_DELAY);
                } catch (InterruptedException e) {
                    Log.e("ping", "InterruptedException ping......");
                    e.printStackTrace();
                }
            }
            Log.e("ping", "Stop ping......");
        }
    }
}
