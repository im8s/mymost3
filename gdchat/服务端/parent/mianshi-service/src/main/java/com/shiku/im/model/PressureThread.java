package com.shiku.im.model;

import com.alibaba.fastjson.JSON;
import com.shiku.im.comm.model.MessageBean;
import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;
import java.util.concurrent.atomic.AtomicInteger;


public class PressureThread implements Runnable{
	
	
	public static Logger logger = LoggerFactory.getLogger(PressureThread.class);
	
	private PressureParam param;
	
	private String jid;
	
	private String roomName;
	
	private AtomicInteger mySendCount;
	private List<Object> mucChats=Collections.synchronizedList(new ArrayList<>());
	
	public PressureThread() {
		// TODO Auto-generated constructor stub
	}
	
	public PressureThread(String jid,String roomName,PressureParam param,List<Object> mucChats) { this.jid=jid;
		this.param=param;
		this.mucChats=mucChats;
		this.mySendCount=new AtomicInteger(0);
		this.roomName=roomName;
	}
	@Override
	public void run() {
//		double timeSend = getTimeSend(System.currentTimeMillis());
		if(param.getAtomic().get()>=param.getSendAllCount()) {
			return;
		}
		int i=mySendCount.get();
		if(i>=param.getSendMsgNum()) {
			return;
		}

		String content = "=== ";
		// TODO Auto-generated method stub

		MessageBean messageBean =null;
		String userId=null;
		long timeSend = 0;
			// 获取connList size 大小的随机数  随机发送消息
		int nextInt = new Random().nextInt(mucChats.size());

	 	messageBean= new MessageBean();
		userId="";
		messageBean.setFromUserId(userId);
		messageBean.setFromUserName(userId);
		messageBean.setToUserId(jid);
		messageBean.setType(1);
		timeSend = DateUtil.getSysCurrentTimeMillis_sync()+i;
		messageBean.setTimeSend(getTimeSend(timeSend));
		messageBean.setMessageId(StringUtil.randomUUID());
		messageBean.setContent(param.getTimeStr()+" "+userId+" "+ content + i);// 批次 + userId + 消息序号
		try {

			logger.info(" timeStr {}  {}  === {}  sendMsg muc  {} count {}  {}  time {}",param.getTimeStr(),userId,roomName,i,param.getAtomic().incrementAndGet(),messageBean.getTimeSend());
		} catch (Exception e) {
			logger.error(e.getMessage());
		}finally {
			mySendCount.incrementAndGet();		
		}
		
		/*
		 * for (MultiUserChat musc : mucChats) { XMPPTCPConnection conn =
		 * (XMPPTCPConnection) musc.getXmppConnection();
		 * PingManager.getInstanceFor(conn).setPingInterval(100); }
		 */
		
	}

	
	private double getTimeSend(long ts){
		double time =(double)ts;
		DecimalFormat dFormat = new DecimalFormat("#.000");
		return new Double(dFormat.format(time/1000));
	}
	

	public static String getFullString() {
		return new SimpleDateFormat("MM-dd HH:mm").format(currentTimeSeconds());
	}
	public static long currentTimeSeconds() {
		return System.currentTimeMillis();
	}
}
