package com.shiku.im.msg.entity;

import org.bson.types.ObjectId;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;


@Data
@Document(value="musicInfo")
public class MusicInfo {
	
	@Id
	private ObjectId id;
	public String cover; // 封面图地址
    public long length; // 音乐长度
    public String name; // 音乐名称
    public String nikeName; // 创作人
    public String path; // 音乐地址
    
    private int useCount;//使用 数量
}
