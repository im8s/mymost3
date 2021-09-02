package com.sk.weichat.socket.msg;


import com.alibaba.fastjson.JSONObject;

/**
 * Login Message
 */
public class AuthMessage extends AbstractMessage {

    private String token;

    private String password;

    private String deviceId;

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }

    @Override
    public String toString() {
        JSONObject object = new JSONObject();
        object.put("messageHead", this.messageHead);
        object.put("token", this.token);
        object.put("password", this.password);
        object.put("deviceId", this.deviceId);
        String msg = object.toString();
        return msg;
    }

}
