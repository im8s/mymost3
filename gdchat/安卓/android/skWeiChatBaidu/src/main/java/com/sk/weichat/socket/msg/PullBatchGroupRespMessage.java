package com.sk.weichat.socket.msg;

import com.alibaba.fastjson.JSON;

import java.util.List;


/**
 * @author lidaye
 */
public class PullBatchGroupRespMessage extends AbstractMessage {

    /**
     * 请求ID 标识
     */
    private String messageId;

    /**
     * 群组jid
     */
    private String jid;

    /**
     * 消息数量
     */
    private long count;

    /**
     * 消息 集合
     */
    private List<ChatMessage> messageList;

    public String getMessageId() {
        return messageId;
    }

    public void setMessageId(String messageId) {
        this.messageId = messageId;
    }

    public String getJid() {
        return jid;
    }

    public void setJid(String jid) {
        this.jid = jid;
    }

    public long getCount() {
        return count;
    }

    public void setCount(long count) {
        this.count = count;
    }

    public List<ChatMessage> getMessageList() {
        return messageList;
    }

    public void setMessageList(List<ChatMessage> messageList) {
        this.messageList = messageList;
    }

    @Override
    public String toString() {
        return JSON.toJSONString(this);
    }

}
