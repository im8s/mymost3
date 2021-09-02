package com.sk.weichat.socket.msg;


import com.alibaba.fastjson.JSON;

public class AuthRespMessage extends AbstractMessage {

    /**
     * 登陆结果  1 登陆 成功     0 登陆失败
     */
    private byte status;

    /**
     * 提示信息
     */
    private String arg;

    /**
     * token
     */
    private String token;

    /**
     * 在线设备列表
     */
    private String resources;

    public byte getStatus() {
        return status;
    }

    public void setStatus(byte status) {
        this.status = status;
    }

    public String getArg() {
        return arg;
    }

    public void setArg(String arg) {
        this.arg = arg;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getResources() {
        return resources;
    }

    public void setResources(String resources) {
        this.resources = resources;
    }

    @Override
    public String toString() {
        return JSON.toJSONString(this);
    }
}
