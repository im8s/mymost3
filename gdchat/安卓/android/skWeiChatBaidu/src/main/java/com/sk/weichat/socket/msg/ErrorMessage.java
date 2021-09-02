package com.sk.weichat.socket.msg;


import com.alibaba.fastjson.JSON;

public class ErrorMessage extends AbstractMessage {

    private short code;

    private String arg;

    public short getCode() {
        return code;
    }

    public void setCode(short code) {
        this.code = code;
    }

    public String getArg() {
        return arg;
    }

    public void setArg(String arg) {
        this.arg = arg;
    }

    @Override
    public String toString() {
        return JSON.toJSONString(this);
    }
}
