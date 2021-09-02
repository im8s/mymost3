package com.sk.weichat.xmpp;

import android.util.Log;

import com.sk.weichat.socket.EMConnectionManager;
import com.sk.weichat.socket.msg.MessageHead;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class SendReceiptManager {
    private static final String TAG = "ReceiptManagerNew";

    private EMConnectionManager mConnectionManager;
    private List<MessageHead> messageQueue = new ArrayList<>();
    private Thread sendThread;
    private boolean stop = false;

    public SendReceiptManager(EMConnectionManager connectionManager) {
        mConnectionManager = connectionManager;

        sendThread = new SendThread();
        sendThread.start();
    }

    public void release() {
        stop = true;

        if (sendThread != null) {
            sendThread.interrupt();
            sendThread = null;
        }
        messageQueue.clear();
    }

    public void addReceipt(MessageHead messageHead) {
        messageQueue.add(messageHead);
    }

    private class SendThread extends Thread {
        private long flushTime;

        @Override
        public void run() {
            try {
                while (!stop) {
                    // 每秒醒来一次，判断5秒没发回执就发一次，或者消息数量大于100也发一次，
                    if (!messageQueue.isEmpty()) {
                        if (TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis() - flushTime) > 5
                                || messageQueue.size() > 100)
                            flush();
                    }
                    TimeUnit.SECONDS.sleep(1);
                }
            } catch (Exception e) {
                Log.e(TAG, "发回执线程结束", e);
            }
        }

        private void flush() {
            flushTime = System.currentTimeMillis();
            // 消息列表的使用是异步的，为免被马上清空，克隆一份，
            sendReceipt(new ArrayList<>(messageQueue));
            messageQueue.clear();
        }

        private void sendReceipt(List<MessageHead> messageIdList) {
            mConnectionManager.sendReceipt(messageIdList);
        }
    }

}
