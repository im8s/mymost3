package com.shiku.im.user.model;


import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Getter
@Setter
@Document(value = "sdkLoginInfo")
public class SdkLoginInfo {
	@Id
	private String id;
	
	private Integer userId;
	
	private int type;// 第三方登录类型   1：QQ 2:微信  
	
	private String loginInfo;// 登录标识  例 微信的openId
	
	private long createTime;// 绑定时间
	
}
