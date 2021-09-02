package com.sk.weichat.socket.msg;


import com.alibaba.fastjson.JSON;

public class MessageReceiptStatus extends AbstractMessage {

    private byte status; // 0  发送中     1  到达服务器  2 已接收   3 已读

    private String messageId; // 提示信息

    public byte getStatus() {
        return status;
    }

    public void setStatus(byte status) {
        this.status = status;
    }

    public String getMessageId() {
        return messageId;
    }

    public void setMessageId(String messageId) {
        this.messageId = messageId;
    }

    @Override
    public String toString() {
        return JSON.toJSONString(this);
    }
}
