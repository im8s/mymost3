package com.shiku.im.open.opensdk.entity;

import com.shiku.utils.DateUtil;
import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.io.Serializable;

/** @version:（1.0） 
* @ClassName	SdkWebLoginInfo
* @Description: 第三方APP、网站授权登录的用户信息
* @date:2019年3月5日上午11:34:08  
*/ 
@Data
@Document(value = "openLoginInfo")
public class OpenLoginInfo implements Serializable{
	/**
	 * 序列化
	 */
	private static final long serialVersionUID = 4426956874820383854L;
	
	@Id
	private String id;
	
	private Integer userId;// 授权用户
	
	private String openId;// 唯一标识
	
	private long createTime;// 绑定时间
	
	private String appId;// appId
	
	private String openName;// 第三方的app或web网站名称
	
	private Integer type = 0; // 0:app授权,1:web网站授权

	public OpenLoginInfo(Integer userId, String openId, String appId, String openName,Integer type) {
		this.userId = userId;
		this.openId = openId;
		this.createTime = DateUtil.currentTimeSeconds();
		this.appId = appId;
		this.openName = openName;
		this.type = type;
	}

	public OpenLoginInfo() {
		
	}
	
}
