package com.shiku.im.model;

import java.util.Map;

import org.bson.types.ObjectId;

import com.alibaba.fastjson.JSON;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.mongodb.core.mapping.Document;

/** @version:（1.0） 
* @ClassName	Message
* @Description: （错误消息） 
*
* @date:2018年8月24日下午4:49:04  
*/ 
@Document(value = "message")
public class ErrorMessage {
	@Id
	private ObjectId id;
	private String code;
	private String zh;
	private String en;
	private String type;
	private String big5;
	
	@Transient
	private Map<String,String> map;

	public ObjectId getId() {
		return id;
	}

	public void setId(ObjectId id) {
		this.id = id;
	}
	
	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getZh() {
		return zh;
	}

	public void setZh(String zh) {
		this.zh = zh;
	}

	public String getEn() {
		return en;
	}

	public void setEn(String en) {
		this.en = en;
	}

	public String getBig5() {
		return big5;
	}

	public void setBig5(String big5) {
		this.big5 = big5;
	}
	
	public Map<String, String> getMap() {
		return map;
	}

	public void setMap(Map<String, String> map) {
		this.map = map;
	}

	@Override
	public String toString() {
		// TODO Auto-generated method stub
		return JSON.toJSONString(this);
	}

}
