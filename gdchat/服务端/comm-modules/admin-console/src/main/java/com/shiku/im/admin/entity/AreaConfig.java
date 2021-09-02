package com.shiku.im.admin.entity;

import org.bson.types.ObjectId;

import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

@Getter
@Setter
@Document(value = "areaConfig")
public class AreaConfig {
	@Id
	private ObjectId id;
	@Indexed
	private String area;// 地区代号
	private String name;// 名称
//	private String xmppConfig;// urlConfig配置表Id
//	private String liveConfig;// urlConfig配置表Id
//	private String httpConfig;// urlConfig配置表Id
//	private String videoConfig;// urlConfig配置表Id
//	private String name;// 中国地区配置
//	private String status;// 状态 1 正常  -1 禁用
}
