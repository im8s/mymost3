package com.shiku.im.msg.entity;

import org.bson.types.ObjectId;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * 
 * @Description: TODO(转发量统计)
 * 
 * @date 2019年8月13日 上午11:45:10
 * @version V1.0
 */
@Document(value = "s_forwardAmount")
@Data
public class ForwardAmount {
	@Id
	private ObjectId id;
	
	@Indexed
	private String msgId;// 被转发消息Id
	
	private int userId;// 转发用户Id
	
	private String nickName;// 转发用户昵称
	
	private long time;// 转发时间
	
	public ForwardAmount() {

	}

	public ForwardAmount(ObjectId id, String msgId, int userId, String nickName, long time) {
		this.id = id;
		this.msgId = msgId;
		this.userId = userId;
		this.nickName = nickName;
		this.time = time;
	}
	
	
}
