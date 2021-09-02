package com.shiku.im.user.entity;

import org.bson.types.ObjectId;

import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;


@Getter
@Setter
@Document(value="pushInfo")
public class PushInfo {

	@Id
	private ObjectId id;
	
	/**
	 * 刷新时间
	 */
	private Long time;
	
	@Indexed
	private Integer userId;
	/**
	 * 设备号   android  ios  web
	 */
	private String deviceKey;
	
	/**
	 * 推送平台厂商 
	 * 华为 huawei
	 * 小米 xiaomi
	 * 百度 baidu
	 * apns ios
	 */
	@Indexed
	private String pushServer;
	
	/**
	 * 推送平台的 token
	 */
	@Indexed
	private String pushToken;
	
	/**
	 * VOip  推送 token
	 */
	//private String voipToken;
}
