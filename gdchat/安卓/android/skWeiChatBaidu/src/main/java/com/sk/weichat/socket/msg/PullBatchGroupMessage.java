package com.sk.weichat.socket.msg;

import com.alibaba.fastjson.JSON;

import java.util.List;

/**
 * @author lidaye
 */
public class PullBatchGroupMessage extends AbstractMessage {

    /**
     * jid 群组jid   lastTime 群组的最后一条消息时间
     * 群组数据集合["jid1,lastTime","jid2,lastTime"]
     */
    private List<String> jidList;

    /**
     * 拉取消息的截止时间
     */
    private long endTime;

    public List<String> getJidList() {
        return jidList;
    }

    public void setJidList(List<String> jidList) {
        this.jidList = jidList;
    }

    public long getEndTime() {
        return endTime;
    }

    public void setEndTime(long endTime) {
        this.endTime = endTime;
    }

    @Override
    public String toString() {
        return JSON.toJSONString(this);
    }
}
