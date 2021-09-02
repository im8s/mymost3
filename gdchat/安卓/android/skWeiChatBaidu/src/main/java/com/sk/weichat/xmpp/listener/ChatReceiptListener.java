package com.sk.weichat.xmpp.listener;

public interface ChatReceiptListener {

    void onReceiveReceipt(int state, String messageId);
}
