package com.sk.weichat.socket.msg;

import com.alibaba.fastjson.JSON;

/**
 * @author lidaye
 */
public class JoinGroupMessage extends AbstractMessage {
    /**
     * 群组 jid
     */
    private String jid;

    /**
     * 接受多少秒时间内的消息
     */
    private long seconds;

    public String getJid() {
        return jid;
    }

    public void setJid(String jid) {
        this.jid = jid;
    }

    public long getSeconds() {
        return seconds;
    }

    public void setSeconds(long seconds) {
        this.seconds = seconds;
    }

    @Override
    public String toString() {
        return JSON.toJSONString(this);
    }
}
