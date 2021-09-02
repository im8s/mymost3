package com.shiku.im.admin.entity;

import org.bson.types.ObjectId;

import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Getter
@Setter
@Document(value = "serverListConfig")
public class ServerListConfig {
	@Id
	private ObjectId id;
	private String name;// 机器名称
	private String url; // 服务器地址
	private String port;// 端口
	private int count;// 当前人数
	private int maxPeople;// 人数上限
	private String area;// 地区
	private int type;// 服务器类型     1 xmpp服务器    2 http服务器    3 视频服务器   4 直播服务器
	private int status;// 状态  1正常   -1禁用    使用中提示不能禁用
}
