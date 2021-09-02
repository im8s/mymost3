package com.shiku.im.push.rocketmq;

import com.alibaba.fastjson.JSON;
import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.push.server.AbstractMessagePushService;
import org.apache.rocketmq.spring.annotation.RocketMQMessageListener;
import org.apache.rocketmq.spring.core.RocketMQListener;
import org.apache.rocketmq.spring.core.RocketMQTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
@Component
@RocketMQMessageListener(topic = "xmppMessage", consumerGroup = "my-consumer-xmpppush")
public class SkXmppMsgListenerConcurrentlyMQ  implements RocketMQListener<String>{
	
	private static final Logger log = LoggerFactory.getLogger(SkXmppMsgListenerConcurrentlyMQ.class);
	

	
	@Resource
	private RocketMQTemplate rocketMQTemplate;


	/*@Resource
	private XMPPConfig xmppConfig;

	@Autowired
	private UserCoreService userCoreService;

	@Autowired
	private UserCoreRedisRepository userCoreRedisRepository;*/





	@Autowired
	private AbstractMessagePushService messagePushService;
	


	

	
	@Override
	public void onMessage(String body) {
		MessageBean message = null;
		try {
			log.info("new msg {}",body);
			message=JSON.parseObject(body, MessageBean.class);
			if(null!=message){
				messagePushService.onMessage(message);
			}
		} catch (Exception e) {
			log.error("=== "+body+" ===> "+e.getMessage());
			sendAgainToMQ(message);
		}
	}


	/**
	 * 将消息重新放入队列
	 * @param messageBean
	 */
	public synchronized void sendAgainToMQ(MessageBean messageBean){
		try {
			rocketMQTemplate.convertAndSend("xmppMessage",messageBean.toString());
		} catch (Exception e) {
			log.error("重新放入队列失败");
			e.printStackTrace();
		}
	}
	

}
