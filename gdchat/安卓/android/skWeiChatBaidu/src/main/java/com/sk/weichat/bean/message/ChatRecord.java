package com.sk.weichat.bean.message;

/**
 * Created by Administrator on 2017/6/28.
 * 同步聊天记录
 * 处理服务器返回的聊天记录实体
 */

public class ChatRecord {

    /**
     * _id : 5cb82b808784f52ec9eab517
     * message : {"content":"吃鸡","deleteTime":-1,"fileSize":0,"fileTime":0,"fromUserId":"10008295","fromUserName":"伏风","isEncrypt":false,"isReadDel":false,"location_x":0.0,"location_y":0.0,"messageHead":{"chatType":2,"from":"10008295/android","messageId":"9fa67ec5b4a946398e4670bc17823fe9","offline":false,"to":"758aa0ad02984c53a6120771eab03303"},"timeSend":1555573631199,"toUserId":"758aa0ad02984c53a6120771eab03303","type":1}
     * room_jid : 758aa0ad02984c53a6120771eab03303
     * sender_jid : 10008295/android
     * sender : 10008295
     * ts : 1555573632589
     * contentType : 1
     * messageId : 9fa67ec5b4a946398e4670bc17823fe9
     * timeSend : 1555573631199
     * deleteTime : -1
     * content : 吃鸡
     */

    private String _id;
    private String message;
    private String room_jid;
    private String sender_jid;
    private String sender;
    private long ts;
    private int contentType;
    private String messageId;
    private long timeSend;
    private long deleteTime;
    private String content;

    // 单聊的接口有返回是否已读，群聊没有，
    private int isRead;

    public int getIsRead() {
        return isRead;
    }

    public void setIsRead(int isRead) {
        this.isRead = isRead;
    }

    public String get_id() {
        return _id;
    }

    public void set_id(String _id) {
        this._id = _id;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getRoom_jid() {
        return room_jid;
    }

    public void setRoom_jid(String room_jid) {
        this.room_jid = room_jid;
    }

    public String getSender_jid() {
        return sender_jid;
    }

    public void setSender_jid(String sender_jid) {
        this.sender_jid = sender_jid;
    }

    public String getSender() {
        return sender;
    }

    public void setSender(String sender) {
        this.sender = sender;
    }

    public long getTs() {
        return ts;
    }

    public void setTs(long ts) {
        this.ts = ts;
    }

    public int getContentType() {
        return contentType;
    }

    public void setContentType(int contentType) {
        this.contentType = contentType;
    }

    public String getMessageId() {
        return messageId;
    }

    public void setMessageId(String messageId) {
        this.messageId = messageId;
    }

    public long getTimeSend() {
        return timeSend;
    }

    public void setTimeSend(long timeSend) {
        this.timeSend = timeSend;
    }

    public long getDeleteTime() {
        return deleteTime;
    }

    public void setDeleteTime(long deleteTime) {
        this.deleteTime = deleteTime;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}
