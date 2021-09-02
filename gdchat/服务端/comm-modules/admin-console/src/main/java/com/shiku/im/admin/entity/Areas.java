package com.shiku.im.admin.entity;

import org.springframework.data.mongodb.core.mapping.Document;

@Document(value="tb_areas")
public class Areas  {
	
	private int type;
	
	private String zip;
	

	private String ab;
	

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public String getZip() {
		return zip;
	}

	public void setZip(String zip) {
		this.zip = zip;
	}
	

	public String getAb() {
		return ab;
	}

	public void setAb(String ab) {
		this.ab = ab;
	}

	

	

}
