package com.shiku.im.admin.entity;

import org.bson.types.ObjectId;

import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

@Getter
@Setter
@Document(value = "urlConfig")
public class UrlConfig {
	@Id
	private ObjectId id;
	private String type;// 服务器类型  1 xmpp服务器    2 http服务器    3 视频服务器   4 直播服务器
	@Indexed
	private String area;// 访问来源地区
//	private String name;// 节点名称
//	private List<ObjectId> Ids;// 服务器地址
	@Indexed
	private String toArea;// 提供服务地区
}
