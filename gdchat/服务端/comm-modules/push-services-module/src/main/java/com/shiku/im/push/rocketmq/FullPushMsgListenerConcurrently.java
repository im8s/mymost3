package com.shiku.im.push.rocketmq;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.push.service.FullPushService;
import com.shiku.im.push.vo.MsgNotice;
import com.shiku.utils.DateUtil;
import lombok.extern.slf4j.Slf4j;
import org.apache.rocketmq.spring.annotation.RocketMQMessageListener;
import org.apache.rocketmq.spring.core.RocketMQListener;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Queue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;

/** @version:（1.0） 
 * @ClassName	SystemNoticeMsgListenerConcurrently
 * @Description: 全量推送 
 * @date:2019年5月29日下午3:12:10  
 */ 
@Slf4j
@Service
@RocketMQMessageListener(topic = "fullPushMessage", consumerGroup = "my-consumer-fullPushMessage")
public class FullPushMsgListenerConcurrently implements  RocketMQListener<String>{



	@Override
	public void onMessage(String body) {
		JSONObject jsonMsg= null;
		try {
			if(KConstants.isDebug)
				log.info(" new msg ==> "+body);
			try {
				jsonMsg=JSON.parseObject(body);
			} catch (Exception e) {
				e.printStackTrace();
			}
			push(parseMsgNotice(jsonMsg));
		} catch (Exception e) {
			e.printStackTrace();
			log.error("=== error "+body+" ===> "+e.getMessage());
			try {
				if((DateUtil.currentTimeSeconds()-KConstants.Expire.HOUR)<jsonMsg.getLong("timeSend")) {
					return;
				}
			} catch (Exception e2) {
				log.error("=== error "+body+" ===> "+e2.getMessage());
			}
//			reSendPushToMq(messageExt);
		}
	}

	private MsgNotice parseMsgNotice(JSONObject jsonObj) {
		MsgNotice notice=new MsgNotice();
		try {
			notice.setTitle(jsonObj.getString("title"));
			notice.setText(jsonObj.getString("content"));
			if(null != jsonObj.getString("objectId"))
				notice.setObjectId(jsonObj.getString("objectId"));
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}
		return notice;
	}

	/**
	 * ArrayListBlockingQueue
	 * 
	 * LinkedBlockingQueue
	 */
	Queue<MsgNotice> queue =new LinkedBlockingQueue<>();

	private void push(final MsgNotice notice) {
		try {
			queue.offer(notice);
			System.out.println(" fullPush  query : "+JSONObject.toJSONString(queue));
		} catch (Exception e) {
			log.error("Queue push Exception {}",e.getMessage());
		}
	}

	private ExecutorService threadPool=Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors()*2);;
	public FullPushMsgListenerConcurrently() {
		FullPush pushThread=new FullPush();
		threadPool.execute(pushThread);
		log.info("pushThread  start end ===>");
	}

	@Autowired
	private FullPushService fullPushService;

	public class FullPush extends Thread{
		@Override
		public void run() {
			while (true) {
				//				System.out.println("FullPush thread aueue : "+JSONObject.toJSONString(queue));
				if(queue.isEmpty()) {
					try {
						Thread.sleep(1000);
					} catch (Exception e) {
						e.printStackTrace();
					}
				}else {
					MsgNotice notice = queue.poll();
					if(null==notice)
						return;
					fullPushService.pushToDevice(notice);
				}
			}
		}
	}


}
