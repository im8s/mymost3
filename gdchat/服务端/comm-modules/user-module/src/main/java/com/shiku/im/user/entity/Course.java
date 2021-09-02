package com.shiku.im.user.entity;

import java.util.List;

import org.bson.types.ObjectId;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@ApiModel("课程")
@Document(value="course")
public class Course {
	@ApiModelProperty("课程id")
	private @Id ObjectId courseId;//课程Id
	@ApiModelProperty("用户Id")
	private int userId;//用户Id
	@ApiModelProperty("消息Id")
	private List<String> messageIds;//消息Id
	@ApiModelProperty("创建时间")
	private long createTime;//创建时间
	@ApiModelProperty("修改时间")
	private long updateTime;//修改时间
	@ApiModelProperty("课程名称")
	private String courseName;//课程名称
	@ApiModelProperty("房间jid")
	private String roomJid;//房间jid
	
	public Course() {}

	public Course(ObjectId courseId, int userId, List<String> messageIds, long createTime, long updateTime,
			String courseName, String roomJid) {
		this.courseId = courseId;
		this.userId = userId;
		this.messageIds = messageIds;
		this.createTime = createTime;
		this.updateTime = updateTime;
		this.courseName = courseName;
		this.roomJid = roomJid;
	}

	public String getRoomJid() {
		return roomJid;
	}

	public void setRoomJid(String roomJid) {
		this.roomJid = roomJid;
	}

	public ObjectId getCourseId() {
		return courseId;
	}
	public void setCourseId(ObjectId courseId) {
		this.courseId = courseId;
	}
	public int getUserId() {
		return userId;
	}
	public void setUserId(int userId) {
		this.userId = userId;
	}
	
	public List<String> getMessageIds() {
		return messageIds;
	}

	public void setMessageIds(List<String> messageIds) {
		this.messageIds = messageIds;
	}

	public long getCreateTime() {
		return createTime;
	}
	
	public long getUpdateTime() {
		return updateTime;
	}

	public void setUpdateTime(long updateTime) {
		this.updateTime = updateTime;
	}

	public void setCreateTime(long createTime) {
		this.createTime = createTime;
	}
	public String getCourseName() {
		return courseName;
	}
	public void setCourseName(String courseName) {
		this.courseName = courseName;
	}
	
	
}	
