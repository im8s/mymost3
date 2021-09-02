package com.shiku.im.admin.entity;

import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;

/**
 * @Description: TODO
 *
 * @Date 2019/12/7
 **/
public class RedReceive {

    private @Id
    ObjectId id;

    @Indexed
    private ObjectId redId;//红包Id

    private @Indexed Integer userId;//接受者用户ID

    private @Indexed Integer sendId;
    //接受者用户名称
    private String userName;
    //红包发送者昵称
    private String sendName;

    private Double money;//接受金额

    private long time;//接受时间

    /**
     * 红包回复语
     */
    private String reply;


    public ObjectId getId() {
        return id;
    }

    public void setId(ObjectId id) {
        this.id = id;
    }

    public ObjectId getRedId() {
        return redId;
    }

    public void setRedId(ObjectId redId) {
        this.redId = redId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Double getMoney() {
        return money;
    }

    public void setMoney(Double money) {
        this.money = money;
    }

    public long getTime() {
        return time;
    }

    public void setTime(long time) {
        this.time = time;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getSendName() {
        return sendName;
    }

    public void setSendName(String sendName) {
        this.sendName = sendName;
    }

    public Integer getSendId() {
        return sendId;
    }

    public void setSendId(Integer sendId) {
        this.sendId = sendId;
    }

    public String getReply() {
        return reply;
    }

    public void setReply(String reply) {
        this.reply = reply;
    }
}
