package com.sk.weichat.socket.msg;

import com.alibaba.fastjson.JSON;

public class MessageHead implements Cloneable {

    /**
     * 发送用户id;
     */
    protected String from;
    /**
     * 目标用户id;
     */
    protected String to;

    /**
     * 聊天类型;(1 单聊 2 群聊 )
     */
    protected byte chatType;

    /**
     * 消息id
     */
    protected String messageId;

    /**
     * 是否离线消息   true 离线消息
     */
    protected boolean offline;

    public String getFrom() {
        return from;
    }

    public void setFrom(String from) {
        this.from = from;
    }

    public String getTo() {
        return to;
    }

    public void setTo(String to) {
        this.to = to;
    }

    public byte getChatType() {
        return chatType;
    }

    public void setChatType(byte chatType) {
        this.chatType = chatType;
    }

    public String getMessageId() {
        return messageId;
    }

    public void setMessageId(String messageId) {
        this.messageId = messageId;
    }

    public boolean isOffline() {
        return offline;
    }

    public void setOffline(boolean offline) {
        this.offline = offline;
    }

    @Override
    public String toString() {
        return JSON.toJSONString(this);
    }

}
