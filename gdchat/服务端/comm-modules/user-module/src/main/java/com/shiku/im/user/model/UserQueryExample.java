package com.shiku.im.user.model;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;

@ApiModel("用户备份类")
public class UserQueryExample {

	@ApiModelProperty("用户编号")
	private Integer userId;
	@ApiModelProperty("当前页")
	private Integer pageSize = 10;
	@ApiModelProperty("昵称")
	private String nickname;
	@ApiModelProperty("性别")
	private Integer sex;
	@ApiModelProperty("开始时间")
	private Long startTime;
	@ApiModelProperty("结束时间")
	private Long endTime;

	public Integer getUserId() {
		return userId;
	}

	public void setUserId(Integer userId) {
		this.userId = userId;
	}

	public Integer getPageSize() {
		return pageSize;
	}

	public void setPageSize(Integer pageSize) {
		this.pageSize = pageSize;
	}

	public String getNickname() {
		return nickname;
	}

	public void setNickname(String nickname) {
		this.nickname = nickname;
	}

	public Integer getSex() {
		return sex;
	}

	public void setSex(Integer sex) {
		this.sex = sex;
	}

	public Long getStartTime() {
		return startTime;
	}

	public void setStartTime(Long startTime) {
		this.startTime = startTime;
	}

	public Long getEndTime() {
		return endTime;
	}

	public void setEndTime(Long endTime) {
		this.endTime = endTime;
	}

}
