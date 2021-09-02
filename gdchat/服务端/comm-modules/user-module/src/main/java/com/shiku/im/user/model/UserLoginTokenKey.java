package com.shiku.im.user.model;

import lombok.Data;

@Data
public class UserLoginTokenKey {
    private int userId;
    private String deviceId;
    private String loginKey;
    private String loginToken;

    public UserLoginTokenKey(){

    }

    public UserLoginTokenKey(int userId, String deviceId){
        this.userId=userId;
        this.deviceId=deviceId;
    }
}
