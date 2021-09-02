package com.sk.weichat.call;

import com.sk.weichat.bean.Friend;
import com.sk.weichat.bean.message.ChatMessage;

/**
 * Created by Administrator on 2017/6/26 0026.
 */
public class MessageEventSipPreview {
    public final int number;
    public final String userid;
    public final boolean isvoice;
    public final Friend friend;
    public ChatMessage message;

    public MessageEventSipPreview(int number, String userid, boolean isvoice, Friend friend, ChatMessage message) {
        this.number = number;
        this.userid = userid;
        this.isvoice = isvoice;
        this.friend = friend;
        this.message = message;
    }
}