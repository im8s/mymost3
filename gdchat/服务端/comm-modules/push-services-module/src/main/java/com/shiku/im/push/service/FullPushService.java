package com.shiku.im.push.service;

import com.alibaba.fastjson.JSONObject;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.push.vo.MsgNotice;
import com.shiku.im.support.Callback;
import com.shiku.im.user.entity.PushInfo;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreRedisRepository;
import com.shiku.im.utils.SKBeanUtils;
import org.json.simple.JSONArray;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/** @version:（1.0） 
* @ClassName	FullPushService
* 
* @Description: （全量推送） 
* @date:2019年6月12日上午11:32:45  
*/
@Component
public class FullPushService extends PushServiceUtils {

	@Autowired
	private UserCoreRedisRepository userCoreRedisRepository;


	public synchronized  void pushToDevice(MsgNotice notice){
		try {
			fullHwPush(notice);
			fullVivoPush(notice);
			officialFullPush(notice);
			fullAPNSPush(notice);
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}
	}
	
	// 华为批量推送
	public  void fullHwPush(MsgNotice notice){
		ThreadUtils.executeInThread((Callback) obj -> {
			// TODO Auto-generated method stub
			Query query =new Query().addCriteria(Criteria.where("pushServer").is(KConstants.PUSHSERVER.HUAWEI));
			// 华为处理
			List<PushInfo> pushInfos = SKBeanUtils.getDatastore().find(query,PushInfo.class);
			JSONArray deviceTokens = new JSONArray();//目标设备Token
			List<List<PushInfo>> fixedGrouping = StringUtil.fixedGrouping(pushInfos, 100);
			fixedGrouping.forEach(singlePushInfo ->{
				synchronized (singlePushInfo) {
					singlePushInfo.forEach(pushInfo ->{
						deviceTokens.add(pushInfo.getPushToken());
					});
					try {
						// 华为批量推送
						log.info("HUAWEI PUSH INFO tokens : {}",JSONObject.toJSONString(deviceTokens));
						HWPushService.fullSendPushMessage(notice, deviceTokens);
						Thread.sleep(100);
						deviceTokens.clear();
					} catch (Exception e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}
			});
		});
	}
	
	// vivo批量推送
	public  void fullVivoPush(MsgNotice notice){
		ThreadUtils.executeInThread((Callback) obj -> {
			// TODO Auto-generated method stub
			// vivo处理
			Query query =new Query().addCriteria(Criteria.where("pushServer").is(KConstants.PUSHSERVER.VIVO));

			List<PushInfo> pushInfosVivo = SKBeanUtils.getDatastore().find(query,PushInfo.class);
			List<List<PushInfo>> vivofixedGrouping = StringUtil.fixedGrouping(pushInfosVivo, 100);
			Set<String> retIds = new HashSet<String>();
			vivofixedGrouping.forEach(vivoPushInfo ->{
				vivoPushInfo.forEach(info ->{
					retIds.add(info.getPushToken());
				});
				try {
					// vivo批量推送
					log.info("VIVO PUSH INFO tokens : {}",JSONObject.toJSONString(retIds));
					VIVOPushService.listSend(notice, retIds);
					Thread.sleep(100);
					retIds.clear();
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			});
		});
		
	}
	
	// apns标题栏推送
	public  void fullAPNSPush(MsgNotice notice){
		ThreadUtils.executeInThread((Callback) obj -> {
			Query query =new Query().addCriteria(Criteria.where("pushServer").is(KConstants.PUSHSERVER.APNS));
			List<Integer> pushInfosApns = SKBeanUtils.getDatastore().findDistinct(query, "userId", "pushInfo", Integer.class);

			//List<Integer> pushInfosApns =SKBeanUtils.getDatastore().distinct("pushInfo", "userId",new BasicDBObject("pushServer", KConstants.PUSHSERVER.APNS));
			log.info("fullPush IOS apns : {}",JSONObject.toJSONString(pushInfosApns));
			pushInfosApns.forEach(userId ->{
				synchronized (userId) {
					User.DeviceInfo iosDevice=userCoreRedisRepository.getIosPushToken(userId);
					if(null == iosDevice)
						return;
					PushServiceUtils.pushToIos(userId, notice, iosDevice);
				}
			});
		});
	}
	
	// 官方支持的全量推送
	public  void officialFullPush(MsgNotice notice){
		ThreadUtils.executeInThread((Callback) obj -> {
			// 处理oppo、小米、魅族、
			try {
				OPPOPushService.broadcastMessage(notice);
			} catch (Exception e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			try {
				XMPushService.sendBroadcast(notice);
			} catch (Exception e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			try {
				MZPushService.pushToAPP(notice);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		});
	}
}
