package com.shiku.im.user.model;

import com.alibaba.fastjson.JSON;
import lombok.Data;

@Data
public class KSession {

	private int userId;
	/*
	设备标识
	 */
	private String deviceId;
	private String language="zh";

	private String loginToken;

	private String accessToken;
	private String httpKey;
	private String payKey;
	private String messageKey;


	public KSession() {
		super();
	}

	public KSession(Integer userId,String language,String deviceId) {
		this.userId = userId;
		this.language=language;
		this.deviceId=deviceId;
	}
	
	public KSession( Integer userId) {
		this.userId = userId;
	}





	@Override
	public String toString() {
		return JSON.toJSONString(this);
	}



}
