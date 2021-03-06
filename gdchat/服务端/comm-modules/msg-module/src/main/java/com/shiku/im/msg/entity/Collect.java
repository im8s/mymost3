package com.shiku.im.msg.entity;

import com.shiku.utils.DateUtil;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

/** @version:（1.0） 
* @ClassName	Collect
* @Description: （朋友圈收藏详情） 
* @date:2018年11月24日下午6:39:27  
*/ 
@Document(value = "s_collect")
public class Collect {
	private @Indexed ObjectId msgId;// 收藏所属消息Id
	
	private String nickname;// 收藏用户昵称
	
	private @Id ObjectId collectId;// 收藏Id
	
	private long time;// 收藏时间
	
	private int userId;// 收藏用户Id
	
	
	public Collect(ObjectId msgId, String nickname,int userId) {
		this.msgId = msgId;
		this.nickname = nickname;
		this.time = DateUtil.currentTimeSeconds();
		this.userId = userId;
	}
	public Collect() {
		
	}
	public ObjectId getMsgId() {
		return msgId;
	}
	public void setMsgId(ObjectId msgId) {
		this.msgId = msgId;
	}
	public String getNickname() {
		return nickname;
	}
	public void setNickname(String nickname) {
		this.nickname = nickname;
	}
	public ObjectId getCollectId() {
		return collectId;
	}
	public void setCollectId(ObjectId collectId) {
		this.collectId = collectId;
	}
	public long getTime() {
		return time;
	}
	public void setTime(long time) {
		this.time = time;
	}
	public int getUserId() {
		return userId;
	}
	public void setUserId(int userId) {
		this.userId = userId;
	}
	
}
