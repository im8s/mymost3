/**
 *
 */
package com.sk.weichat.socket.msg;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;

/**
 * 版本: [1.0]
 * 功能说明:
 *
 * @author : WChao 创建时间: 2017年7月26日 上午11:32:57
 */

public abstract class AbstractBody {

    /**
     * 发送用户id;
     */
    protected String from;
    /**
     * 目标用户id;
     */
    protected String to;

    /**
     * 聊天类型;(如公聊、私聊)
     */
    protected byte chatType;

    /**
     * 消息id
     */
    protected String messageId;

    /**
     * 扩展参数字段
     */
    //protected JSONObject extras;
    public String toJsonString() {
        return JSONObject.toJSONString(this);
    }

    public byte[] toByte() {
        return JSONObject.toJSONBytes(this);
    }

    @Override
    public String toString() {
        // TODO Auto-generated method stub
        return JSON.toJSONString(this);
    }
}
