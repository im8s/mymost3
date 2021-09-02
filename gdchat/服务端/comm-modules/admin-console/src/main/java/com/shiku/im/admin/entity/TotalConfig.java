package com.shiku.im.admin.entity;

import org.bson.types.ObjectId;

import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Getter
@Setter
@Document(value="totalConfig")
public class TotalConfig {
	@Id
	private ObjectId id;
	private String area;// 地区 China  HK
	private String xmppConfig;// UrlConfig配置表id
	private String liveConfig;// UrlConfig配置表id
	private String httpConfig;// UrlConfig配置表id
	private String videoConfig;// UrlConfig配置表id
	private String name;// 中国地区 配置 
	private int status;// 状态 1正常 -1禁用 
}
