package com.shiku.im.open.entity;

import java.util.List;

import org.bson.types.ObjectId;
import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Document(value = "groupHelper")
public class GroupHelper {
	private @Id ObjectId id;
	
	private String helperId;// 群助手Id
	
	private String roomId;// 房间id
	
	private String roomJid;// 房间jid
	
	private List<KeyWord> keywords;// 关键字
	
	private Integer userId;// 创建用户Id
	
	@Transient
	private Helper helper;
	
	@Data
	public static class KeyWord{
		private String id;
		private String keyWord;
		private String value;
	}
}
