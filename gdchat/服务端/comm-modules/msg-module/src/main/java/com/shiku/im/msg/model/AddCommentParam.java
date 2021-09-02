package com.shiku.im.msg.model;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;

@ApiModel("回复评论")
public class AddCommentParam {
	@ApiModelProperty("消息编号")
	private String messageId;
	@ApiModelProperty("目标用户编号")
	private int toUserId;
	@ApiModelProperty("目标昵称")
	private String toNickname;
	@ApiModelProperty("目标用户")
	private String toBody;
	@ApiModelProperty("用户")
	private String body;

	public String getMessageId() {
		return messageId;
	}

	public void setMessageId(String messageId) {
		this.messageId = messageId;
	}

	public int getToUserId() {
		return toUserId;
	}

	public void setToUserId(int toUserId) {
		this.toUserId = toUserId;
	}

	public String getToNickname() {
		return toNickname;
	}

	public void setToNickname(String toNickname) {
		this.toNickname = toNickname;
	}

	public String getToBody() {
		return toBody;
	}

	public void setToBody(String toBody) {
		this.toBody = toBody;
	}

	public String getBody() {
		return body;
	}

	public void setBody(String body) {
		this.body = body;
	}

}
