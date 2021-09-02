package com.sk.weichat.bean.message;

public class CourseChatBean {

    /**
     * courseId : 5cc278fefc84d31ecad82a79
     * courseMessageId : 5cc278fefc84d31ecad82a7a
     * createTime : 1
     * message : {"content":"爸就","deleteTime":-1,"fileSize":0,"fileTime":0,"fromUserId":"10008295","fromUserName":"伏风","isEncrypt":false,"isReadDel":false,"location_x":0.0,"location_y":0.0,"messageHead":{"chatType":2,"from":"10008295/android","messageId":"24a0cb009dfa4347a495e5d9f46acb90","offline":false,"to":"962f9b1cdcc447c9b7b2badb9c9237f4"},"timeSend":1556246326552,"toUserId":"962f9b1cdcc447c9b7b2badb9c9237f4","type":1}
     * userId : 10008295
     */

    private String courseId;
    private String courseMessageId;
    private long createTime;
    private String message;
    private int userId;

    public String getCourseId() {
        return courseId;
    }

    public void setCourseId(String courseId) {
        this.courseId = courseId;
    }

    public String getCourseMessageId() {
        return courseMessageId;
    }

    public void setCourseMessageId(String courseMessageId) {
        this.courseMessageId = courseMessageId;
    }

    public long getCreateTime() {
        return createTime;
    }

    public void setCreateTime(long createTime) {
        this.createTime = createTime;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }
}
