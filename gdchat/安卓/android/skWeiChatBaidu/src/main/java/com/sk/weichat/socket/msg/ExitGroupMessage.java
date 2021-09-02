package com.sk.weichat.socket.msg;

import com.alibaba.fastjson.JSON;

/**
 * @author lidaye
 */
public class ExitGroupMessage extends AbstractMessage {

    /**
     * 群组 jid
     */
    private String jid;

    public String getJid() {
        return jid;
    }

    public void setJid(String jid) {
        this.jid = jid;
    }

    @Override
    public String toString() {
        return JSON.toJSONString(this);
    }
}
