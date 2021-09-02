package com.shiku.im.msg.entity;

import com.alibaba.fastjson.JSON;
import org.bson.types.ObjectId;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * 朋友圈评论
 *
 *
 */
@Document(value = "s_comment")
public class Comment {
	private String body;// 评论内容
	
	private @Id
	ObjectId commentId;// 评论Id
	private @Indexed
	ObjectId msgId;// 评论所属消息Id
	private String nickname;// 评论用户昵称
	private long time;// 评论时间
	private String toBody;// 被回复内容
	private String toNickname;// 被回复人用户昵称
	private int toUserId;// 被回复用户Id
	private int userId;// 评论用户Id

	public Comment() {
		super();
	}

	public Comment(ObjectId commentId, ObjectId msgId, int userId,
			String nickname, String body, int toUserId, String toNickname,
			String toBody, long time) {
		super();
		this.commentId = commentId;
		this.msgId = msgId;
		this.userId = userId;
		this.nickname = nickname;
		this.body = body;
		this.toUserId = toUserId;
		this.toNickname = toNickname;
		this.toBody = toBody;
		this.time = time;
	}

	public String getBody() {
		return body;
	}

	public ObjectId getCommentId() {
		return commentId;
	}

	public ObjectId getMsgId() {
		return msgId;
	}

	public String getNickname() {
		return nickname;
	}

	public long getTime() {
		return time;
	}

	public String getToBody() {
		return toBody;
	}

	public String getToNickname() {
		return toNickname;
	}

	public int getToUserId() {
		return toUserId;
	}

	public int getUserId() {
		return userId;
	}

	public void setBody(String body) {
		this.body = body;
	}

	public void setCommentId(ObjectId commentId) {
		this.commentId = commentId;
	}

	public void setMsgId(ObjectId msgId) {
		this.msgId = msgId;
	}

	public void setNickname(String nickname) {
		this.nickname = nickname;
	}

	public void setTime(long time) {
		this.time = time;
	}

	public void setToBody(String toBody) {
		this.toBody = toBody;
	}

	public void setToNickname(String toNickname) {
		this.toNickname = toNickname;
	}

	public void setToUserId(int toUserId) {
		this.toUserId = toUserId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	@Override
	public String toString() {
		return JSON.toJSONString(this);
	}

}
