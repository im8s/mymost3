package com.shiku.im.model;

import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 
 *
 */
@Setter
@Getter
public class PressureParam {

	
	
	private  int checkNum=1;// 参与发送的人数
	
	private int sendMsgNum=100;// 发送总条数
	
	private String roomJid="";
	
	private int timeInterval=30;// 每条消息间隔时间ms
	
	private List<String> jids;
	
	private AtomicInteger atomic;
	
	private int sendAllCount;
	

	private long startTime;
	
	
	private String timeStr;
	

	
	@Setter
	@Getter
	public static class PressureResult{
		private int sendAllCount;// 发送总条数
		
		private long timeCount;// 总用时
		
		private String TimeStr;// 当前批次
	}
	
}
