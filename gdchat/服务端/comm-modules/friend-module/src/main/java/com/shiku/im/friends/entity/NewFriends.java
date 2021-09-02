/**
 * 
 */
package com.shiku.im.friends.entity;

import org.bson.types.ObjectId;

import com.alibaba.fastjson.annotation.JSONField;

import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 *
 * 2017年7月21日
 */
@Getter
@Setter
@Document(value="NewFriends")
public class NewFriends {
	
	@JSONField(serialize = false)
	private  @Id
	ObjectId id;// 关系Id
	
	@Indexed
	private int toUserId;// 好友Id
	@Indexed
	private int userId;// 用户Id
	
	private String from;//发起打招呼的用户ID
	
	private long createTime;// 建立关系时间
	private long modifyTime;// 修改时间
	
	private String content;// 信息内容
	
	private int direction;// 0=发出去的；1=收到的
	private int type;// 消息Type  
	private Integer status;// 状态（1=关注；2=好友；0=陌生人）
	private String toNickname;// 好友昵称
	

	

}
