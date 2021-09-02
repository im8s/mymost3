package com.shiku.im.push.rocketmq;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.push.service.HWPushService;
import com.shiku.im.push.vo.HwMsgNotice;
import com.shiku.utils.DateUtil;
import org.apache.rocketmq.client.producer.SendResult;
import org.apache.rocketmq.client.producer.SendStatus;
import org.apache.rocketmq.spring.annotation.RocketMQMessageListener;
import org.apache.rocketmq.spring.core.RocketMQListener;
import org.apache.rocketmq.spring.core.RocketMQTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
/**
 * 华为推送消费监听
 *
 *
 */
@Service
@ConditionalOnProperty(prefix="im.pushConfig",name="IsOpen",havingValue="1")
@RocketMQMessageListener(topic = "HWPushMessage", consumerGroup = "my-consumer-HWPushMessage")
public class HWMessageListenerConcurrently implements RocketMQListener<String>{
	
	@Resource
	private RocketMQTemplate rocketMQTemplate;
	
	private static final Logger log = LoggerFactory.getLogger(HWMessageListenerConcurrently.class);
	
	@Override
	public void onMessage(String body) {
		JSONObject jsonMsg= null;
		try {
			if(KConstants.isDebug)
				log.info(" new msg ==> "+body);
			try {
				jsonMsg=JSON.parseObject(body);
				if((DateUtil.currentTimeSeconds()-KConstants.Expire.HOUR)>jsonMsg.getLong("timeSend")) {
					return;
				}
			} catch (Exception e) {
				e.printStackTrace();
				return;
			}
			hwOfflinePush(body, jsonMsg);
			
		} catch (Exception e) {
			e.printStackTrace();
			log.error("=== error "+body+" ===> "+e.getMessage());
			try {
				if((DateUtil.currentTimeSeconds()-KConstants.Expire.HOUR)>jsonMsg.getLong("timeSend")) {
					return;
				}
			} catch (Exception e2) {
				return;
			}
			reSendPushToMq(body);
		}
	}
	
	
	/**
	 * 重新发 推送消息 发送到队列中
	 * @param message
	 */
	public void reSendPushToMq(String message) {
		try {
			SendResult result = rocketMQTemplate.syncSend("HWPushMessage", message);
			if(SendStatus.SEND_OK!=result.getSendStatus()){
				log.error("reSendPushToMq > "+result.toString());
			}
		} catch (Exception e) {
			log.error("reSendPushToMq Exception "+e.getMessage());
		}
	}
	
	public void hwOfflinePush(String messageExt,JSONObject jsonMsg) {
		//log.info("直接推送给华为设备");
		HwMsgNotice notice=null;
		try {
			notice=JSONObject.toJavaObject(jsonMsg,HwMsgNotice.class);
		} catch (Exception e) {
			log.info("JOSN转换错误");
			e.printStackTrace();
			return;
		}
		try {
			HWPushService.sendPushMessage(notice.getMsgNotice(),notice.getMsgNotice().getFileName(),notice.getToken());
			/**
			 * 音视频消息  发送透传通知
			 */
			if(100==notice.getMsgNotice().getType()||110==notice.getMsgNotice().getType()||
					115==notice.getMsgNotice().getType()||120==notice.getMsgNotice().getType()){
				HWPushService.sendTransMessage(notice.getMsgNotice(),notice.getMsgNotice().getFileName(),notice.getToken());
			}
		} catch (Exception e) {
			log.error("=== error "+jsonMsg+" ===> "+e.getMessage());
			try {
				if((DateUtil.currentTimeSeconds()-KConstants.Expire.HOUR)<jsonMsg.getLong("timeSend")) {
					return;
				}
			} catch (Exception e2) {
				return;
			}
			hwSendPushToMq(messageExt);
		}
	}
	/**
	 * 华为推送 重新发送 到队列中
	 * @param message
	 */
	public void hwSendPushToMq(String message){
		try {
			SendResult result = rocketMQTemplate.syncSend("HWPushMessage", message);
			if(SendStatus.SEND_OK!=result.getSendStatus()){
				log.error("HwSendPushToMq > "+result.toString());
			}
		} catch (Exception e) {
			log.error("HwSendPushToMq Exception "+e.getMessage());
		}
	}

}
