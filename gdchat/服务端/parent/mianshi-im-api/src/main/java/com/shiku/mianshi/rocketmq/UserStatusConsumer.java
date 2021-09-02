package com.shiku.mianshi.rocketmq;

import com.mongodb.BasicDBObject;
import com.mongodb.client.model.UpdateOptions;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.config.MQConfig;
import com.shiku.im.live.service.impl.LiveRoomManagerImpl;
import com.shiku.im.room.service.RoomCoreRedisRepository;
import com.shiku.im.room.service.RoomRedisRepository;
import com.shiku.im.support.Callback;
import com.shiku.im.user.dao.UserCoreDao;
import com.shiku.im.user.service.UserCoreRedisRepository;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.utils.SKBeanUtils;
import org.apache.rocketmq.spring.annotation.RocketMQMessageListener;
import org.apache.rocketmq.spring.core.RocketMQListener;
import org.apache.rocketmq.spring.core.RocketMQTemplate;
import org.bson.Document;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.Arrays;
import java.util.List;
@Component
//@ConditionalOnProperty(prefix="im.mqConfig",name="isConsumerUserStatus",havingValue="1",matchIfMissing=true)
@RocketMQMessageListener(topic = "userStatusMessage", consumerGroup = "consumer-userStatusMessage")
public class UserStatusConsumer implements RocketMQListener<String>{
	
	private static final Logger log = LoggerFactory.getLogger(UserStatusConsumer.class);
	
	
	/*@Resource
	private RocketMQTemplate rocketMQTemplate;
	
	@Autowired(required=false) 
	private MQConfig mqConfig;*/

		@Autowired
		private UserCoreRedisRepository userCoreRedisRepository;

		@Autowired
		private UserCoreDao userCoreDao;

		@Autowired
		private RoomCoreRedisRepository roomCoreRedisRepository;

		@Autowired
		private LiveRoomManagerImpl liveRoomManager;

		@Override
		public void onMessage(String message) {
			
			try {
				String[] split = message.split(":");
			
				log.info("userId  {} status  {} resource > {}",split[0],split[1],split[2]);
				if("1".equals(split[1])) {
					handleLogin(Integer.valueOf(split[0]), split[2]);
				}else {
					Integer userId = Integer.valueOf(split[0]);
					closeConnection(Integer.valueOf(split[0]), split[2]);
					// 需过滤系统号的上下线
					resetLiveRoom(userId);
				}
				
			} catch (Exception e) {
				log.error(e.getMessage(),e);
			}
		}
		
		
		public static final List<String> RESOURCES=Arrays.asList("ios","android","youjob","web","pc","mac");
		
		/**
		 * 用户登陆记录表
		 */
		private static final String USERLOGINLOG = "userLoginLog";
		
		/**
		 * 
		* @Description: TODO(用户 登陆xmpp 上线时  更新 用户的数据库状态信息 )
		 */
		public void handleLogin(Integer userId,String resource){
			try {
				long cuTime=System.currentTimeMillis() / 1000;
				userCoreRedisRepository.saveUserOnline(userId.toString(), 1);
				     Document query = new Document("_id", userId);

				userCoreDao.updateAttribute(userId,"onlinestate", 1);
						
						if(!RESOURCES.contains(resource)){
							return;
						}
						refreshUserRoomsStatus(userId, 1);
						Document userLogin =  SKBeanUtils.getDatastore().getCollection(USERLOGINLOG).find(query).first();
						Document loginValues=null;
						Document deviceMapObj=null;
						Document deviceObj=null;
						if(null==userLogin){
							loginValues=new Document("_id", userId);
							loginValues.append("loginLog", null);
							deviceMapObj=initDeviceMap(resource, cuTime);
							loginValues.append("deviceMap", deviceMapObj);
							SKBeanUtils.getDatastore().getCollection(USERLOGINLOG).updateOne(query, new BasicDBObject("$set", loginValues),new UpdateOptions().upsert(true));
							return;
						}
						
						 deviceMapObj= (Document) userLogin.get("deviceMap");
						if(null==deviceMapObj){
							loginValues=new Document("_id", userId);
							loginValues.append("loginLog", new BasicDBObject().append("loginTime", cuTime));
							deviceMapObj=initDeviceMap(resource, cuTime);
							loginValues.append("deviceMap", deviceMapObj);
							SKBeanUtils.getDatastore().getCollection(USERLOGINLOG).updateOne(query, new BasicDBObject("$set", loginValues),new UpdateOptions().upsert(true));
							return;
						}
						if(null==deviceMapObj.get(resource)){
							deviceMapObj.put(resource, initDeviceObj(resource, cuTime));
						}else {
							deviceObj= (Document) deviceMapObj.get(resource);
							deviceObj.put("online", 1);
							deviceObj.put("loginTime", cuTime);
							deviceMapObj.replace(resource, deviceObj);
						}
						loginValues=new Document("deviceMap", deviceMapObj);
						SKBeanUtils.getDatastore().getCollection(USERLOGINLOG).updateOne(query, new BasicDBObject("$set", loginValues),new UpdateOptions().upsert(true));
				
			} catch (Exception e) {
				e.printStackTrace();
			}
			
			
			
		}
		
		/**
		* @Description: TODO(关闭 用户 xmpp 链接 调用的  修改用户 状态)
		* @param @param connection
		* @param @param userIdStr    参数
		 */
		public void closeConnection(Integer userId,String resource) {
			try {
				userCoreRedisRepository.saveUserOnline(userId.toString(), 0);
				
				long cuTime=System.currentTimeMillis() / 1000;
				Document query= new Document("_id", userId);
				userCoreDao.updateAttribute(userId,"onlinestate", 0);
						
						if(!RESOURCES.contains(resource)){
							return;
						}
						refreshUserRoomsStatus(userId, 0);
						Document userLogin = SKBeanUtils.getDatastore().getCollection(USERLOGINLOG).find(query).first();
						Document loginValues=null;
						Document deviceMapObj=null;
						Document deviceObj=null;
						if(null==userLogin){
							return;
						}
						
						deviceMapObj= (Document) userLogin.get("deviceMap");
						Document loginLog= (Document) userLogin.get("loginLog");
						if(null==deviceMapObj){
							return;
						}
						if(null==deviceMapObj.get(resource)){
							return;
						}else {
							deviceObj= (Document) deviceMapObj.get(resource);
							deviceObj.put("online", 0);
							deviceObj.put("offlineTime", cuTime);
						}
						
						loginValues=new Document("deviceMap", deviceMapObj);
						if(null!=loginLog) {
							loginLog.put("offlineTime", cuTime);
							loginValues.put("loginLog",loginLog);
						}
						SKBeanUtils.getDatastore().getCollection(USERLOGINLOG).updateOne(query, new Document("$set", loginValues),new UpdateOptions().upsert(true));
					
			} catch (Exception e) {
				log.error(e.getMessage());
			}
			
		}
		
		// 直播间的相关状态重置
		private void resetLiveRoom(Integer userId){
			// 退出已经加入的直播间和解散开启的直播间
			liveRoomManager.OutTimeRemoveLiveRoom(userId);
		}
		
		/**
		* @Description: TODO(初始化设备列表)
		* @param @param resource
		* @param @param time
		* @param @return    参数
		 */
		private Document initDeviceMap(String resource,long time){
			Document deviceMapObj=new Document();
			Document deviceObj=initDeviceObj(resource, time);
			deviceMapObj.put(resource, deviceObj);
			return deviceMapObj;
		}
		/**
		* @Description: TODO(初始化设备对象)
		* @param @param resource
		* @param @param time
		* @param @return    参数
		 */
		private Document initDeviceObj(String resource,long time){

			Document deviceObj=new Document();
				deviceObj.put("loginTime", time);
				deviceObj.put("online", 1);
				deviceObj.put("deviceKey", resource);
			return deviceObj; 	
			
		}
		
		private void refreshUserRoomsStatus(final Integer userId,final int status) {
			/*DeviceInfo androidDevice = KSessionUtil.getAndroidPushToken(userId);
			DeviceInfo iosDevice = KSessionUtil.getIosPushToken(userId);
			if(null==androidDevice&&null==iosDevice) {
				return;
			}*/
			ThreadUtils.executeInThread(obj -> {

				List<String> jidList = roomCoreRedisRepository.queryUserRoomJidList(userId);

				if(0==status) {
					List<String> noPushJidList = roomCoreRedisRepository.queryNoPushJidLists(userId);
					jidList.removeAll(noPushJidList);
					for (String jid : jidList) {
						roomCoreRedisRepository.addRoomPushMember(jid, userId);
					}
				}else {
					for (String jid : jidList) {
						roomCoreRedisRepository.removeRoomPushMember(jid,userId);
					}
				}
			});
			
		}
		


	
	
	

}
