package com.shiku.im.push.rocketmq;


import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.google.common.collect.Maps;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.constants.MsgType;
import com.shiku.im.friends.entity.Friends;
import com.shiku.im.friends.service.FriendsManager;
import com.shiku.im.live.entity.LiveRoom;
import com.shiku.im.live.service.impl.LiveRoomManagerImpl;
import com.shiku.im.message.IMessageService;
import com.shiku.im.message.MessageType;
import com.shiku.im.push.service.JPushServices;
import com.shiku.im.push.service.PushServiceUtils;
import com.shiku.im.push.vo.HwMsgNotice;
import com.shiku.im.push.vo.MsgNotice;
import com.shiku.im.room.service.RoomCoreRedisRepository;
import com.shiku.im.room.service.RoomCoreService;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreRedisRepository;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
import org.apache.rocketmq.client.producer.SendResult;
import org.apache.rocketmq.client.producer.SendStatus;
import org.apache.rocketmq.spring.annotation.RocketMQMessageListener;
import org.apache.rocketmq.spring.core.RocketMQListener;
import org.apache.rocketmq.spring.core.RocketMQTemplate;
import org.bson.types.ObjectId;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;
@Service
@ConditionalOnProperty(prefix="im.pushConfig",name="IsOpen",havingValue="0",matchIfMissing=true)
@RocketMQMessageListener(topic = "pushMessage", consumerGroup = "GID_consumer_pushMessage")
public class PushMessageListenerConcurrently implements RocketMQListener<String>{

	@Resource
	private RocketMQTemplate rocketMQTemplate;
	
	private ExecutorService threadPool=Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors()*2);;
	
	public PushMessageListenerConcurrently() {
		PushThread pushThread=new PushThread();
		threadPool.execute(pushThread);
		log.info("pushThread  start end ===>");
	}
	private static final Logger log = LoggerFactory.getLogger(PushMessageListenerConcurrently.class);


	@Autowired
	private RoomCoreService roomCoreService;


	@Autowired
	private UserCoreService userCoreService;

	@Autowired
	private FriendsManager friendsManager;

	@Autowired
	private LiveRoomManagerImpl liveRoomManager;

	@Autowired
	private IMessageService messageService;


	@Autowired
	private UserCoreRedisRepository userCoreRedisRepository;
	@Autowired
	private RoomCoreRedisRepository roomCoreRedisRepository;


	/**
	 * ArrayListBlockingQueue
	 * 
	 * LinkedBlockingQueue
	 */
	Queue<MsgNotice> queue =new LinkedBlockingQueue<>();
	
	@Override
	public void onMessage(String body) {
		JSONObject jsonMsg= null;
		try {
			if(KConstants.isDebug)
				log.info(" new msg ==> "+body);
			try {
				jsonMsg=JSON.parseObject(body);
				/*if(null!=jsonMsg.get("timeSend")){
					if((DateUtil.currentTimeSeconds()-KConstants.Expire.HOUR)>jsonMsg.getLong("timeSend")) {
						return;
					}
				}*/
			} catch (Exception e) {
				log.error(e.getMessage(),e);
				return;
			}
				offLinePush(jsonMsg);
			
		}catch (NullPointerException e) {
			log.error(e.getMessage(),e);

		} catch (Exception e) {
			log.error(e.getMessage(),e);
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
	 * ????????? ???????????? ??????????????????
	 * @param message
	 */
	public void reSendPushToMq(String message) {
		try {
			SendResult result =rocketMQTemplate.syncSend("pushMessage", message);
			if(SendStatus.SEND_OK!=result.getSendStatus()){
				log.error("reSendPushToMq > "+result.toString());
			}
		} catch (Exception e) {
			log.error(e.getMessage(),e);
		}
	}
	
	/**
	 * ????????????
	* @param jsonMsg
	 */
	public void offLinePush(JSONObject jsonMsg)throws Exception {
		MsgNotice notice=null;
		try {
			//String c = new String(body.getBytes("iso8859-1"),"utf-8");
			 notice=parseMsgNotice(jsonMsg);
			
			if(null==notice){
				return ;
			}
			/*
			 * if(KConstants.isDebug)
			 * log.info("MsgNotice ==> {}  > {} ",notice.getText(),notice.toString());
			 */
			
		}catch (NumberFormatException e) {
			log.error(e.getMessage(),e);
			return;
		} catch (Exception e) {
			log.error(e.getMessage(),e);
			throw e;
		}
		push(notice);
	}
	
	
	
	private void push(final MsgNotice notice) {
		try {
			if(!notice.getIsGroup()) {
				//pushOne(notice.getTo(), notice);
				queue.offer(notice);
			}else 
				pushGroup(notice.getTo(), notice);
		} catch (Exception e) {
			log.error(e.getMessage(),e);
		}
		
			
	}
	//?????????????????????
	private void pushOne(final int to,MsgNotice notice){
		try {
			if(to==notice.getFrom())
				return;
			//???????????????????????????????????????
			if(!notice.getIsGroup()) {
				//???????????????????????????????????????????????????
				if(friendsManager.getFriendIsNoPushMsg(to, notice.getFrom())){
					return ;
				}
			}
			
			/*Map<String, DeviceInfo> loginDeviceMap = getUserManager().getLoginDeviceMap(to);
			if(null==loginDeviceMap){
				 log.error("deviceMap is Null > "+to);
				 return;
			}*/
			/**
			 * ????????? ????????? ???ios ????????? android ?????????
			 */
			
			/*androidDevice=loginDeviceMap.get(KConstants.DeviceKey.Android);
			iosDevice=loginDeviceMap.get(KConstants.DeviceKey.IOS);*/
			
			final User.DeviceInfo androidDevice=userCoreRedisRepository.getAndroidPushToken(to);
			final User.DeviceInfo iosDevice=userCoreRedisRepository.getIosPushToken(to);
			if(null==androidDevice&&null==iosDevice) {
//				log.error("deviceMap is Null > {}",to);
				System.out.print("deviceMap is Null, to : "+to);
				return;
			}else if(null!=androidDevice&&null!=iosDevice) 
				if(StringUtil.isEmpty(androidDevice.getPushToken())&&
					StringUtil.isEmpty(iosDevice.getPushToken())) {
				log.error("PushToken is Null > {}",to);
				return;
			}
			
			try {
				if(null!=androidDevice){
					//log.info("???????????? "+androidDevice.getPushServer()+"  ????????????"+androidDevice.getAdress());
					String adress = androidDevice.getAdress();
					if(!StringUtil.isEmpty(adress)) {
						if(androidDevice.getPushServer().equals(KConstants.PUSHSERVER.HUAWEI)&&!adress.equals(PushServiceUtils.pushConfig.getServerAdress())){
							//log.info("????????????????????????");
							HwMsgNotice hwMsgNotice=new HwMsgNotice(androidDevice.getPushToken(),notice);
							rocketMQTemplate.convertAndSend("HWPushMessage",hwMsgNotice.toString());
							return;
						}
					}
					
					PushServiceUtils.pushToAndroid(to, notice, androidDevice);
					
					
					/*if(0==androidDevice.getOnline()){
							
					}else {
							log.error("androidDevice  is Online => {}",to);
					}*/
				}
				if(null!=iosDevice){
					byte flag = SKBeanUtils.getImCoreService().getClientConfig().getIsOpenAPNSorJPUSH();
					if(0 == flag){
						PushServiceUtils.pushToIos(to, notice, iosDevice);
					}else{
						Map<String, String> content = Maps.newConcurrentMap();
						content.put("msg", notice.getText());
						content.put("regId", iosDevice.getPushToken());
						content.put("title", notice.getTitle());
						JPushServices.buildPushObject_ios_tagAnd_alertWithExtrasAndMessage(content);
					}
					
					/*if(0==iosDevice.getOnline()){
						PushServiceUtils.pushToIos(to, notice, iosDevice);
					}else {
							log.error("iosDevice  is Online => {}",to);
					}*/
				}
			} catch (Exception e) {
				log.error(e.getMessage(),e);
			}
				
			
			
		} catch (Exception e) {
			log.error(e.getMessage(),e);
			queue.offer(notice);
		}
	}
	//???????????????
	private void pushGroup(int to,MsgNotice notice){
		log.info("===== ???????????????pushGroup : "+JSONObject.toJSONString(notice));
		if(notice.getType()==1&&!StringUtil.isEmpty(notice.getObjectId())
					&&!notice.getObjectId().equals(notice.getRoomJid())){
				//@ ?????????
				String[] objectIdlist=notice.getObjectId().split(" ");
				for(int i=0;i<objectIdlist.length;i++){
					try {
						ObjectId roomId = roomCoreService.getRoomId(notice.getRoomJid());
						 log.info("????????? roomId :{}  userId : {}     boolean :{}",roomId,Integer.valueOf(objectIdlist[i]),roomCoreService.getMemberIsNoPushMsg(roomId,Integer.valueOf(objectIdlist[i])));
						 if(roomCoreService.getMemberIsNoPushMsg(roomId,Integer.valueOf(objectIdlist[i]))) {
							 continue;
						 }
						notice.setTo(Integer.parseInt(objectIdlist[i]));
						//notice.setToName(getUserManager().getNickName(Integer.parseInt(objectIdlist[i])));
						notice.setStatus(1);
						pushOne(Integer.parseInt(objectIdlist[i]), notice);
					} catch (Exception e) {
						log.error(e.getMessage(),e);
					}
					 
				}
		}else{
			List<Integer> groupUserList=null;
			try {
				groupUserList = roomCoreRedisRepository.queryRoomPushMemberUserIds(notice.getRoomJid());
				log.info("roomPushMemberUserIds : {}",groupUserList);
				groupUserList.remove((Integer)notice.getFrom());
			} catch (Exception e) {
				log.error(e.getMessage(),e);
				queue.offer(notice);
				return;
			}
			for (Integer userId : groupUserList) {
					//notice.setToName(getUserManager().getNickName(userId));
				 
					notice.setTo(userId);
					notice.setStatus(1);
					pushOne(userId, notice);
				
			}
		}
		
		
	}
	
	private MsgNotice parseMsgNotice(JSONObject jsonObj) throws Exception{
		MsgNotice notice=new MsgNotice();
		int messageType = 0;
		String text =null;
		String jid=null;
		
		
		try {
				String msgId=jsonObj.getString("messageId");
				if(!StringUtil.isEmpty(msgId))
					notice.setMessageId(msgId);
				
				messageType = jsonObj.getIntValue("type");
				if(MsgType.TYPE_RED_BACK!=messageType)
					notice.setFrom(jsonObj.getIntValue("fromUserId"));
				
				if(StringUtil.isEmpty(notice.getName()))
					notice.setName(jsonObj.getString("fromUserName"));
				notice.setToName(jsonObj.getString("toUserName"));
				notice.setFileName(jsonObj.getString("fileName"));
				jid=jsonObj.getString("roomJid");
				notice.setIsGroup(jsonObj.getBooleanValue("isGroup"));
				if(!notice.getIsGroup())
					notice.setTo(jsonObj.getIntValue("toUserId"));
				notice.setTitle(notice.getName());
				if(!StringUtil.isEmpty(jsonObj.getString("content"))&&
						jsonObj.getString("content").contains("http://api.map.baidu.com/staticimage")){
					messageType=MsgType.TYPE_LOCATION;
					if(notice.getIsGroup()){
						notice.setTitle(roomCoreService.getRoomName(jid));
						notice.setRoomJid(jid);
						notice.setGroupName("("+notice.getTitle()+")");
						text=notice.getName()+notice.getGroupName()+":[??????]";
					}else{
						notice.setTitle(notice.getName());
						text=notice.getName()+":[??????]";
					}
				}
				if(!StringUtil.isEmpty(jsonObj.getString("objectId"))) {
					notice.setObjectId(jsonObj.getString("objectId"));
				}
				LiveRoom liveRoom = null;
				if(!StringUtil.isEmpty(jid)){
					notice.setRoomJid(jid);
					if(!MessageType.liveRoomType.contains(messageType)){
						ObjectId roomId = roomCoreService.getRoomId(jid);
						if (null != roomId) {
							notice.setRoomId(roomId.toString());
						}

						notice.setTitle(roomCoreService.getRoomName(jid));
					}else{
						liveRoom = liveRoomManager.getLiveRoomByJid(jid);
						if (null != liveRoom) {
							notice.setRoomId(liveRoom.getRoomId().toString());
							notice.setTitle(liveRoom.getName());
						}

					}
					notice.setGroupName("("+notice.getTitle()+")");
				}else if(!StringUtil.isEmpty(jsonObj.getString("objectId"))){
					if(!MessageType.liveRoomType.contains(messageType)){
						String roomName = roomCoreService.getRoomName(jsonObj.getString("objectId"));
						if(null!= roomName) {
							notice.setTitle(roomName);
							notice.setGroupName("("+notice.getTitle()+")");
						}

					}else if(MessageType.liveRoomType.contains(messageType)){
						liveRoomManager.getLiveRoomByJid(jsonObj.getString("objectId"));
						if(null != liveRoom){
							notice.setTitle(liveRoom.getName());
							notice.setGroupName("("+notice.getTitle()+")");
						}
					}
				}
			if (0 < jsonObj.getIntValue("isEncrypt") || 0 < jsonObj.getIntValue("encryptType")) {
				text="[??????]";
			} else if (1 == jsonObj.getIntValue("isReadDel")) {
				text = "[????????????T]";// ??????????????????
			} else
				text = jsonObj.getString("content");
			notice.setType(messageType);
			text = parseText(messageType, notice, text);
			if (null == text) {
				//log.error("{} text ???null ???????????????????????????",msgId);
				return null;
			}
		} catch (Exception e) {
			throw e;
		}
		
		notice.setText(text);
		if(!notice.getIsGroup()) {
			Friends friends = friendsManager.getFriends(notice.getTo(), notice.getFrom());
			if(null!=friends&&!StringUtil.isEmpty(friends.getRemarkName())) {
				notice.setName(friends.getRemarkName());
			}
			if(StringUtil.isEmpty(notice.getToName()))
				notice.setToName(userCoreService.getNickName(notice.getTo()));
		}else {
			notice.setName(userCoreService.getNickName(notice.getFrom()));
		}
		return notice;
	}
	private String parseText(int messageType,MsgNotice notice,String content) {
		String text=null;
		
		try {
			
			switch (messageType) {
				case MsgType.TYPE_TEXT:
				case MsgType.TYPE_FEEDBACK:
					
					text =content;
					
					text=notice.getName()+(notice.getIsGroup()?notice.getGroupName():"")+":"+text;
					if(notice.getIsGroup()) {
						if(!StringUtil.isEmpty(notice.getObjectId())&&!StringUtil.isEmpty(notice.getRoomJid())){
							text="[??????@???]"+notice.getName()+notice.getGroupName()+":"+content;
							if(notice.getObjectId().equals(notice.getRoomJid())){
								text="[???????????????]"+notice.getName()+notice.getGroupName()+":"+content;
							}
									
						}
					}
					break;
				case MsgType.TYPE_IMAGE:
				case MsgType.TYPE_GIF:
					text=notice.getName()+(notice.getIsGroup()?notice.getGroupName():"")+":[??????]";
					break;
				case MsgType.TYPE_VOICE:
					text=notice.getName()+(notice.getIsGroup()?notice.getGroupName():"")+":[??????]";
					break;
				case MsgType.TYPE_LOCATION:
					text=notice.getName()+(notice.getIsGroup()?notice.getGroupName():"")+":[??????]";
					break;
				case MsgType.TYPE_VIDEO:
					text=notice.getName()+(notice.getIsGroup()?notice.getGroupName():"")+":[??????]";
					break;
				case MsgType.TYPE_CARD:
					text=notice.getName()+(notice.getIsGroup()?notice.getGroupName():"")+":[??????]";
					break;
				case MsgType.TYPE_FILE:
					text=notice.getName()+(notice.getIsGroup()?notice.getGroupName():"")+":[??????]";
					break;
				case MsgType.TYPE_RED:
					text=notice.getName()+(notice.getIsGroup()?notice.getGroupName():"")+":[??????]";
					break;
				case MsgType.TYPE_LINK:
				case MsgType.TYPE_SHARE_LINK:
					text=notice.getName()+(notice.getIsGroup()?notice.getGroupName():"")+":[??????]";
					break;
				case MsgType.TYPE_83:
					text=notice.getName()+(notice.getIsGroup()?notice.getGroupName():"")+":???????????????";
					break;
				case MsgType.TYPE_SHAKE:
					text=notice.getName()+":[?????????]";
					break;
				case MsgType.TYPE_CHAT_HISTORY:
					text=notice.getName()+":[????????????]";
					break;
				case MsgType.TYPE_RED_BACK:
					text="????????????:[????????????]";
					break;
				case MsgType.TYPE_TRANSFER:
					text=notice.getName()+(notice.getIsGroup()?notice.getGroupName():"")+":[??????]";
					break;
				case MsgType.TYPE_RECEIVETRANSFER:
					text=notice.getName()+(notice.getIsGroup()?notice.getGroupName():"")+":???????????????";
					break;
				case MsgType.TYPE_REFUNDTRANSFER:
					text="????????????:[????????????]";
					break;
				case MsgType.TYPE_IMAGE_TEXT:
				case MsgType.TYPE_IMAGE_TEXT_MANY:
					text=notice.getName()+(notice.getIsGroup()?notice.getGroupName():"")+":[??????]";
					break;
				case MsgType.TYPE_BACK:
					text=notice.getName()+(notice.getIsGroup()?notice.getGroupName():"")+":?????????????????????";
					break;
				case MsgType.DIANZAN:
					text=notice.getName()+":???????????????????????? [?????????]";
					break;	
				case MsgType.PINGLUN:
					text=notice.getName()+":???????????????????????? [?????????]";
					break;	
				case MsgType.ATMESEE:
					text=notice.getName()+":???????????? [?????????]";
					break;	
				case MsgType.TYPE_MUCFILE_ADD:
					
					text=notice.getName()+(notice.getIsGroup()?notice.getGroupName():"")+":??????????????????";
					break;
				case MsgType.TYPE_MUCFILE_DEL:
					
					text=notice.getName()+(notice.getIsGroup()?notice.getGroupName():"")+":???????????????";
					break;
				case MsgType.TYPE_SAYHELLO:
					text=notice.getName()+":??????????????????";
					break;
				case MsgType.TYPE_FRIEND:
					text=notice.getName()+":??????????????????";
					break;
				case MsgType.TYPE_DELALL:
					text=notice.getName()+":?????????????????????";
					break;
				case MsgType.TYPE_PASS:
					text=notice.getName()+":??????????????????";
					break;
				/*case MsgType.TYPE_CHANGE_NICK_NAME:
					notice.setIsGroup(1);
					text=notice.getName()+(notice.getGroupName())+":?????????????????????"+content;
					break;*/
				case MsgType.TYPE_CHANGE_ROOM_NAME:
				
					text='"'+notice.getName()+'"'+(notice.getGroupName())+":??????????????????"+content;
					break;
				case MsgType.TYPE_DELETE_ROOM:
					text="("+content+"):??????????????????";
					break;
				case MsgType.TYPE_DELETE_MEMBER:
					
					if(notice.getFrom()==notice.getTo()) {
						//notice.setName(SKBeanUtils.getUserManager().getNickName(notice.getTo()));
						text='"'+notice.getName()+'"'+" ???????????????:"+(notice.getGroupName());
					}else {
						//notice.setName(SKBeanUtils.getUserManager().getNickName(notice.getTo()));
						text='"'+notice.getName()+'"'+" ?????????????????????:"+(notice.getGroupName());
					}
					break;
				case MsgType.TYPE_NEW_NOTICE:
					
					text='"'+notice.getName()+'"'+(notice.getGroupName())+" ??????????????????:"+content;
					break;
				case MsgType.TYPE_GAG:
					long ts=Long.parseLong(content);
					//long time=DateUtil.currentTimeSeconds();
					if(0<ts)
						text='"'+notice.getName()+'"'+(notice.getGroupName())+" ???????????????";
					else text='"'+notice.getName()+'"'+(notice.getGroupName())+" ???????????????";
					break;
				case MsgType.NEW_MEMBER:
					if(!notice.getIsGroup()){
						if(notice.getFrom()!=notice.getTo()) {
							text='"'+notice.getName()+'"'+" ????????????????????????:"+(notice.getGroupName());
							}else {
								text='"'+notice.getName()+'"'+" ???????????????:"+(notice.getGroupName());
							}
						}else{
							if(notice.getFrom()!=notice.getTo()) {
								text='"'+notice.getName()+'"'+" ?????? '"+notice.getToName()+"' ???????????????:"+(notice.getGroupName());
							}else {
								text='"'+notice.getName()+'"'+" ???????????????:"+(notice.getGroupName());
						}
					}


					break;
				case MsgType.TYPE_SEND_MANAGER:
					if(1==Integer.parseInt(content))
						text=notice.getName()+(notice.getGroupName())+" ????????????????????????";
					else 
						text=notice.getToName()+(notice.getGroupName())+" ????????????????????????";
					break;
				case MsgType.TYPE_GROUP_TRANSFER:
					text=notice.getName()+" ????????? "+(notice.getGroupName())+" ?????????????????????";
					break;
				case MsgType.TYPE_INPUT:
				case MsgType.TYPE_CHANGE_SHOW_READ:
					return null;
				case MsgType.TYPE_IS_CONNECT_VOICE:
					text=notice.getName()+":?????????????????????";
					break;
				case MsgType.TYPE_IS_CONNECT_VIDEO:
					text=notice.getName()+":?????????????????????";
					break;
				case MsgType.TYPE_IS_MU_CONNECT_Video:
					text=notice.getName()+":???????????????????????????";
					break;
				case MsgType.TYPE_IS_MU_CONNECT_VOICE:
					text=notice.getName()+":???????????????????????????";
					break;
				case MsgType.TYPE_NO_CONNECT_VOICE:
					text=notice.getName()+":?????????????????????";
					break;
				case MsgType.TYPE_NO_CONNECT_VIDEO:
					text=notice.getName()+":?????????????????????";
					break;
				case MsgType.CODEPAYMENT:
					text = notice.getName()+":????????????";
					break;
				case MsgType.CODEARRIVAL:
					text = notice.getName()+":????????????";
					break;
				case MsgType.MANUAL_RECHARGE:
					text = "??????????????????";
					break;
				case MsgType.MANUAL_WITHDRAW:
					text = "??????????????????";
					break;
				default:
					if(100<messageType)
						return null;
					else if(StringUtil.isEmpty(content))
						return null;
					else 
						text=content;
					break;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		if (StringUtils.hasText(text)) {
			if (text.length() > 50)
				text = text.substring(0, 50) + "...";
		}
		return text;
	}
	
	public class PushThread extends Thread {
		
		@Override
		public void run() {
			while (true) {
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
					if(!notice.getIsGroup())
						pushOne(notice.getTo(), notice);
					else if(1==notice.getStatus()){
						pushOne(notice.getTo(), notice);
					}else if(notice.getIsGroup()){
						pushGroup(notice.getTo(), notice);
					}
				}
			}
		}
	}

}
