package com.sk.weichat.socket.msg;


import com.alibaba.fastjson.JSON;

public class SuccessMessage extends AbstractMessage {

    private static final long serialVersionUID = 1L;

    @Override
    public String toString() {
        return JSON.toJSONString(this);
    }
}
