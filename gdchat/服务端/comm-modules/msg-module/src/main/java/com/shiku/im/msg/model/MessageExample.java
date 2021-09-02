package com.shiku.im.msg.model;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;

@ApiModel("消息实体")
public class MessageExample {
	@ApiModelProperty("标题")
	private String bodyTitle;
	@ApiModelProperty("城市编号")
	private int cityId;
	@ApiModelProperty("标识")
	private int flag;
	@ApiModelProperty("信息编号")
	private String msgId;
	@ApiModelProperty("每页大小")
	private int pageSize = 20;

	public String getBodyTitle() {
		return bodyTitle;
	}

	public int getCityId() {
		return cityId;
	}

	public int getFlag() {
		return flag;
	}

	public String getMsgId() {
		return msgId;
	}

	public int getPageSize() {
		return pageSize;
	}

	public void setBodyTitle(String bodyTitle) {
		this.bodyTitle = bodyTitle;
	}

	public void setCityId(int cityId) {
		this.cityId = cityId;
	}

	public void setFlag(int flag) {
		this.flag = flag;
	}

	public void setMsgId(String msgId) {
		this.msgId = msgId;
	}

	public void setPageSize(int pageSize) {
		this.pageSize = pageSize;
	}

}
