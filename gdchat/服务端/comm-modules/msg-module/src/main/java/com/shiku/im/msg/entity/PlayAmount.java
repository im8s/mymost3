package com.shiku.im.msg.entity;

import org.bson.types.ObjectId;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * 
 * @Description: TODO(播放量统计)
 * 
 * @date 2019年8月13日 上午11:31:21
 * @version V1.0
 */
@Document(value = "s_palyVolume")
@Data
public class PlayAmount {
	@Id
	private ObjectId id;
	
	@Indexed
	private String msgId; // 观看消息id
	
	private int userId; // 观看的用户Id
	
	private String nickName;// 观看用户昵称
	
	private long time; // 观看时间
	
	public PlayAmount() {

	}

	public PlayAmount(ObjectId id, String msgId, int userId, String nickName, long time) {
		this.id = id;
		this.msgId = msgId;
		this.userId = userId;
		this.nickName = nickName;
		this.time = time;
	}
	
	
}
