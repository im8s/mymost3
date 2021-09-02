package com.shiku.im.user.entity;

import org.bson.types.ObjectId;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

/** @version:（1.0） 
* @ClassName	OffineOperation
* @Description: 离线时操作记录 
* @date:2019年5月30日下午3:01:39  
*/
@Data
@Document(value = "offlineOperation")
public class OfflineOperation {
	@Id
	private ObjectId id;
	private Integer userId;
	private String tag;// 标签名称 
	private String friendId;// 被操作的好友Id、操作的房间roomId
	private long operationTime;// 操作时间
	public OfflineOperation() {
	
	}
	public OfflineOperation(Integer userId, String tag, String friendId, long updateTime) {
		this.userId = userId;
		this.tag = tag;
		this.friendId = friendId;
		this.operationTime = updateTime;
	}
	
}
