package com.shiku.im.comm.model;

import com.alibaba.fastjson.JSON;

public class MessageBean {

    private Object content;
    private String fileName;
    private String fromUserId = "10005";
    private String fromUserName = "10005";
    private Object objectId;
    private Number timeSend;
    private String toUserId;
    private String toUserName;
    private int fileSize;
    private int type;

    private String messageId;

    private String other;

    private int msgType; // 消息type  0：普通单聊消息    1：群组消息    2：广播消息  3:压测消息

    private String roomJid;// 群组jid

    /**
     * 外面的to 消息发送给谁
     */
    private String to;

    public Object getContent() {
        return content;
    }

    public String getFileName() {
        return fileName;
    }

    public String getFromUserId() {
        return fromUserId;
    }

    public String getFromUserName() {
        return fromUserName;
    }

    public Object getObjectId() {
        return objectId;
    }

    public Number getTimeSend() {
        return timeSend;
    }

    public String getToUserId() {
        return toUserId;
    }

    public String getToUserName() {
        return toUserName;
    }

    public int getFileSize() {
        return fileSize;
    }

    public void setFileSize(int fileSize) {
        this.fileSize = fileSize;
    }

    public int getType() {
        return type;
    }

    public void setContent(Object content) {
        this.content = content;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public void setFromUserId(String fromUserId) {
        this.fromUserId = fromUserId;
    }

    public void setFromUserName(String fromUserName) {
        this.fromUserName = fromUserName;
    }

    public void setObjectId(Object objectId) {
        this.objectId = objectId;
    }

    public void setTimeSend(Number timeSend) {
        this.timeSend = timeSend;
    }

    public void setToUserId(String toUserId) {
        this.toUserId = toUserId;
    }

    public void setToUserName(String toUserName) {
        this.toUserName = toUserName;
    }

    public void setType(int type) {
        this.type = type;
    }

    @Override
    public String toString() {
        return JSON.toJSONString(this);
    }

    public String getOther() {
        return other;
    }

    public void setOther(String other) {
        this.other = other;
    }

    public String getMessageId() {
        return messageId;
    }

    public void setMessageId(String messageId) {
        this.messageId = messageId;
    }

    public int getMsgType() {
        return msgType;
    }

    public void setMsgType(int msgType) {
        this.msgType = msgType;
    }

    public String getRoomJid() {
        return roomJid;
    }

    public void setRoomJid(String roomJid) {
        this.roomJid = roomJid;
    }

    public String getTo() {
        return to;
    }

    public void setTo(String to) {
        this.to = to;
    }
}
