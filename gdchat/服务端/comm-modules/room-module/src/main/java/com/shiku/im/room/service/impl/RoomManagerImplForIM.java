package com.shiku.im.room.service.impl;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.google.common.collect.Lists;
import com.mongodb.BasicDBObject;
import com.mongodb.DBObject;
import com.shiku.common.model.PageResult;
import com.shiku.common.model.PageVO;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.comm.utils.DateUtil;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.entity.Config;
import com.shiku.im.message.IMessageRepository;
import com.shiku.im.message.MessageService;
import com.shiku.im.message.MessageType;
import com.shiku.im.room.dao.*;
import com.shiku.im.room.entity.Room;
import com.shiku.im.room.entity.Room.Member;
import com.shiku.im.room.entity.Room.Notice;
import com.shiku.im.room.entity.Room.Share;
import com.shiku.im.room.service.RoomCoreRedisRepository;
import com.shiku.im.room.service.RoomManager;
import com.shiku.im.room.service.RoomRedisRepository;
import com.shiku.im.room.vo.RoomVO;
import com.shiku.im.support.Callback;
import com.shiku.im.user.dao.OfflineOperationDao;
import com.shiku.im.user.dao.RoleDao;
import com.shiku.im.user.entity.OfflineOperation;
import com.shiku.im.user.entity.Role;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.event.DeleteUserEvent;
import com.shiku.im.user.event.UserChageNameEvent;
import com.shiku.im.user.service.RoleCoreService;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.utils.ConstantUtil;
import com.shiku.im.utils.SKBeanUtils;
import org.bson.types.ObjectId;
import org.redisson.api.RBucket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;

import java.util.*;
@Service(RoomManager.BEAN_ID)
public class RoomManagerImplForIM implements RoomManager {
	
	public static final String  SHIKU_ROOMJIDS_USERID = "shiku_roomJids_userId";

	private Logger log= LoggerFactory.getLogger(RoomManager.class);

	@Autowired
	private RoomDao roomDao;
	public RoomDao getRoomDao(){
		return roomDao;
	}

	@Autowired
	private RoomCoreDao roomCoreDao;

	@Autowired
	private RoomMemberDao roomMemberDao;

	@Autowired
	private RoomMemberCoreDao roomMemberCoreDao;

	@Autowired
	private OfflineOperationDao offlineOperationDao;
	@Autowired
	private RoomNoticeDao roomNoticeDao;



	@Autowired
	private RoomRedisRepository roomRedisRepository;

	@Autowired
	private RoomCoreRedisRepository roomCoreRedisRepository;


	@Autowired
	private ShareDao shareDao;
	@Autowired
	private RoleDao roleDao;

	@Autowired
	private RoleCoreService roleCoreService;


	@Autowired
	@Lazy
	private MessageService messageService;

	@Autowired
	private IMessageRepository messageRepository;
	
	@Autowired
	private UserCoreService userCoreService;
	

	
	
//	private final String roomMemerList="roomMemerList:";
	

	
	

	@Override
	public Room add(User user, Room entity, List<Integer> memberUserIdList, JSONObject userKeys) {
		//Config config = SKBeanUtils.getSystemConfig();
		user.setNum(user.getNum() + 1);
		if (1 == entity.getIsSecretGroup()) {
			entity.setEncryptType((byte) 3);
		}
		Config config = SKBeanUtils.getSystemConfig();

		entity.initRoomConfig(user.getUserId(), user.getNickname(), config); // 初始化群组配置


		List<Role> userRoles = roleCoreService.getUserRoles(user.getUserId(), null, 0);
		if (null != userRoles && userRoles.size() > 0) {
			for (Role role : userRoles) {
				if (role.getRole() == 4) {
					entity.setPromotionUrl(role.getPromotionUrl());
				}
			}
		}

		if (null == entity.getName())
			entity.setName("我的群组");
		if (null == entity.getDesc())
			entity.setDesc("");

		if (null == entity.getLongitude())
			entity.setLongitude(0d);
		if (null == entity.getLatitude())
			entity.setLatitude(0d);

		if (null == entity.getJid()) {
			entity.setJid(StringUtil.randomUUID());
			messageService.createMucRoomToIMServer(entity.getJid(), user.getPassword(), user.getUserId().toString(),
					entity.getName());

		}

		// 保存房间配置
		roomDao.addRoom(entity);
		// 创建者
		Member member = new Member();
		member.setActive(DateUtil.currentTimeSeconds());
		member.setCreateTime(member.getActive());
		member.setModifyTime(0L);
		member.setNickname(user.getNickname());
		member.setRole(1);
		member.setRoomId(entity.getId());
		member.setSub(1);
		member.setTalkTime(0L);
		member.setCall(entity.getCall());
		member.setVideoMeetingNo(entity.getVideoMeetingNo());
		member.setUserId(user.getUserId());
		if (userKeys != null)
			member.setChatKeyGroup(userKeys.getString(user.getUserId() + ""));

		// 初始成员列表
		List<Member> memberList = Lists.newArrayList(member);

		//没有邀请群成员
//		if(null == memberUserIdList ||memberUserIdList.isEmpty()){
		sendToChatNewMemberMessage(user.getUserId(), entity, member);

		/**
		 * 删除 用户加入的群组 jid  缓存
		 */

		if (0 == userCoreService.getOnlinestateByUserId(user.getUserId())) {
			roomCoreRedisRepository.addRoomPushMember(entity.getJid(), user.getUserId());
		}
		roomRedisRepository.deleteUserRoomJidList(user.getUserId());

		// 保存成员列表
		roomMemberDao.addMemberList(memberList);

		updateUserSize(entity.getId(), memberList.size());
		memberList.clear();
		/*// 用户加入的群组
		roomCoreRedisRepository.saveJidsByUserId(user.getUserId(), entity.getJid(), entity.getId());
		// 更新群组相关设置操作时间
		updateOfflineOperation(user.getUserId(), entity.getId(), null);
		roomCoreRedisRepository.deleteRoom(entity.getId().toString());
		roomCoreRedisRepository.deleteMemberList(entity.getId().toString());*/
//		}else
		if (null != memberUserIdList && !memberUserIdList.isEmpty()) {
			// 初始成员列表不为空
			Long currentTimeSeconds = DateUtil.currentTimeSeconds();
			ObjectId roomId = entity.getId();
			/*//添加群主
			memberUserIdList.add(user.getUserId());
			sendToChatNewMemberMessage(user.getUserId(), entity, member);*/

			/*ThreadUtils.executeInThread(new Callback() {
				@Override
				public void execute(Object obj) {*/
					Member _member = null;
					for (int userId : memberUserIdList) {
						User _user = userCoreService.getUser(userId);
						//群主在上面已经添加了
						if (userId != entity.getUserId()) {
							//成员
							_member = new Member();
							_member.setActive(currentTimeSeconds);
							_member.setCreateTime(currentTimeSeconds);
							_member.setModifyTime(0L);
							_member.setNickname(_user.getNickname());
							_member.setRole(3);
							_member.setRoomId(roomId);
							_member.setSub(1);
							_member.setCall(entity.getCall());
							_member.setVideoMeetingNo(entity.getVideoMeetingNo());
							_member.setTalkTime(0L);
							_member.setUserId(_user.getUserId());
							if (userKeys != null)
								_member.setChatKeyGroup(userKeys.getString(userId + ""));
							memberList.add(_member);

							// 发送单聊通知到被邀请人， 群聊
							sendNewMemberMessage(user.getUserId(), entity, _member);

							updateOfflineOperation(_member.getUserId(), entity.getId(), null);
						}
						/**
						 * 删除 用户加入的群组 jid  缓存
						 */

						if (0 == userCoreService.getOnlinestateByUserId(userId)) {
							roomCoreRedisRepository.addRoomPushMember(entity.getJid(), userId);
						}
						roomCoreRedisRepository.saveJidsByUserId(userId, entity.getJid(), entity.getId());
					}

					// 保存成员列表
					roomMemberDao.addMemberList(memberList);
					updateUserSize(entity.getId(), memberList.size());

			/*	}
			});*/
		}
		// 用户加入的群组
		roomCoreRedisRepository.saveJidsByUserId(user.getUserId(), entity.getJid(), entity.getId());
		// 更新群组相关设置操作时间
		updateOfflineOperation(user.getUserId(), entity.getId(), null);
		roomCoreRedisRepository.deleteRoom(entity.getId().toString());
		roomCoreRedisRepository.deleteMemberList(entity.getId().toString());

		return entity;
	}

	/** @Description:更新群组相关设置操作时间
	 *   群组多点登录数据同步需要同步双方
	* @param userId
	* @param roomId
	**/ 
	public void updateOfflineOperation(Integer userId,ObjectId roomId,String toUserIds){
		log.info("userId is : {} ,  toUserIds is : {}",userId,toUserIds);
		long currentTime = DateUtil.currentTimeSeconds();
		OfflineOperation offlineOperation = offlineOperationDao.queryOfflineOperation(userId,null,String.valueOf(roomId));
		if(null == offlineOperation){
			offlineOperationDao.addOfflineOperation(userId, KConstants.MultipointLogin.TAG_ROOM,String.valueOf(roomId),DateUtil.currentTimeSeconds());
		}else{
			OfflineOperation updateEntity = new OfflineOperation();
			updateEntity.setOperationTime(currentTime);
			offlineOperationDao.updateOfflineOperation(userId,String.valueOf(roomId),updateEntity);
		}
		if(!StringUtil.isEmpty(toUserIds)){
			List<Integer> toUserIdList = StringUtil.getIntList(toUserIds, ",");
			toUserIdList.forEach(toUserId ->{
				OfflineOperation toOfflineOperation = offlineOperationDao.queryOfflineOperation(userId,null,String.valueOf(roomId));
				if(null == toOfflineOperation){
					offlineOperationDao.addOfflineOperation(toUserId, KConstants.MultipointLogin.TAG_ROOM, String.valueOf(roomId), currentTime);
				}else{
					OfflineOperation updateEntity = new OfflineOperation();
					updateEntity.setOperationTime(currentTime);
					offlineOperationDao.updateOfflineOperation(userId,String.valueOf(roomId),updateEntity);
				}
			});
		}
	}
	

	
	@Override
	public void delete(ObjectId roomId,Integer userId) {
		Room room = roomCoreDao.getRoomById(roomId);
		if(null==room){
			System.out.println("====> RoomManagerImplForIM > delete room is null ");
			return;
		}
		Member member = getMember(roomId, userId);

		List<Integer> userRoles = roleCoreService.getUserRoles(userId);
		if(null != member){
			if(!userRoles.contains(5) && !userRoles.contains(6)){
				if (1 != member.getRole()) {
					throw new ServiceException(KConstants.ResultCode.NO_PERMISSION);
				}
			}
		}else{
			if (!userRoles.contains(5) && !userRoles.contains(6)) {
				throw new ServiceException(KConstants.ResultCode.NO_PERMISSION);
			}
				
		}

		String roomJid=room.getJid();
		if(room.getUserSize() >0){
			MessageBean messageBean = new MessageBean();
			messageBean.setFromUserId(room.getUserId() + "");
			messageBean.setFromUserName(getMemberNickname(roomId, room.getUserId()));
			messageBean.setType(MessageType.DELETE_ROOM);
			messageBean.setObjectId(room.getJid());
			messageBean.setContent(room.getName());
			messageBean.setMessageId(StringUtil.randomUUID());
			// 发送单聊群聊
			sendChatGroupMsg(roomId, room.getJid(), messageBean);
		}

		ThreadUtils.executeInThread(new Callback() {
			@Override
			public void execute(Object obj) {
				roomMemberDao.deleteById(roomId);
				List<Integer> memberIdList = getMemberIdList(roomId);
				for (Integer id : memberIdList) {
					// 维护用户加入群组 Jids 缓存
					roomCoreRedisRepository.delJidsByUserId(id,roomJid);
				}
				//删除群组 清除 群组成员
				roomMemberDao.deleteRoomMember(roomId,null);

				//删除公告
				roomNoticeDao.deleteNotice(roomId,null);

				// 删除 群共享的文件 和 删除群组离线消息记录
				destroyRoomMsgFileAndShare(roomId, roomJid);

				// 删除群组相关的举报信息
				userCoreService.delReport(null, roomId.toString());

				roomDao.deleteRoom(roomId);

				// 维护群组、群成员缓存
				updateRoomInfoByRedis(roomId.toString());

				roomRedisRepository.deleteNoticeList(roomId.toString());
				// 处理面对面建群
				if(null != roomRedisRepository.queryLocationRoom(roomJid)){
					String jid=roomRedisRepository.queryLocationRoomJid(room.getLongitude(), room.getLatitude(), room.getLocalRoomKey());
					log.info(" ======  getRoomInfo jid ======"+jid);
					if(!StringUtil.isEmpty(jid)){
						roomRedisRepository.deleteLocalRoomJid(room.getLongitude(), room.getLatitude(), room.getLocalRoomKey());
						roomRedisRepository.deleteLocalRoom(roomJid);
					}
				}
			}
		});
		// 更新群组相关设置操作时间
		updateOfflineOperation(userId, roomId,null);
	}

	/**
	* @Description: TODO(全员禁言)
	* @param @param roomId  群主ID
	* @param @param talkTime   禁言到期时间   0 取消禁言
	 */
	public void roomAllBanned(ObjectId roomId,long talkTime){
		ThreadUtils.executeInThread(new Callback() {
			@Override
			public void execute(Object obj) {
				roomMemberDao.updateRoomMember(roomId,talkTime);
			}
		});
		
	}
	
	
	public synchronized Object update(User user, RoomVO roomVO, int isAdmin, int isConsole) {

//		Query<Room> query = getRoomDatastore().createQuery(getEntityClass());
//		query.filter("_id", roomVO.getRoomId());
//
//		UpdateOperations<Room> operations = getRoomDatastore().createUpdateOperations(getEntityClass());
		Map<String,Object> map = new HashMap<>();

		Room room = getRoom(roomVO.getRoomId());
		if(0 == isConsole){
			if(null != room && room.getS() == -1)
				throw new ServiceException(KConstants.ResultCode.RoomIsLock);
		}
		if (!StringUtil.isEmpty(roomVO.getRoomName())&&(!room.getName().equals(roomVO.getRoomName()))) {
			UpdateGroupNickname(user, roomVO, isAdmin,room);
			return null;
		}
		/*全员禁言*/
		if(-2<roomVO.getTalkTime()){
			allBannedSpeak(user, roomVO, room);
			return null;
		}

		if (!StringUtil.isEmpty(roomVO.getDesc())) {
//			operations.set("desc", roomVO.getDesc());
			map.put("desc", roomVO.getDesc());
		}
		if (!StringUtil.isEmpty(roomVO.getSubject())) {
//			operations.set("subject", roomVO.getSubject());
			map.put("subject", roomVO.getSubject());
		}
		try {
			if (!StringUtil.isEmpty(roomVO.getNotice())) {
				if (1 != isConsole && getMember(room.getId(), ReqUtil.getUserId()).getRole() == 3) {
				  throw new ServiceException(KConstants.ResultCode.NO_PERMISSION);
				}
				String noticeId = newNotice(user, roomVO, isAdmin, room);
				Map data=new HashMap();
				data.put("noticeId",noticeId);
				return data;
			}
		} catch (Exception e) {
				e.printStackTrace();
			}
		if(-1<roomVO.getShowRead()&&room.getShowRead()!=roomVO.getShowRead()){
			alreadyReadNums(user, roomVO, isAdmin, room);
			return null;
		}
		if(-1 != roomVO.getIsNeedVerify()){
			groupVerification(user, roomVO, isAdmin, room);
			return null;
		}
		if(-1!=roomVO.getIsLook()){
			roomIsPublic(user, roomVO, isAdmin, room);
			return null;
		}
		if(null != roomVO.getMaxUserSize() && roomVO.getMaxUserSize()>=0){
			if(roomVO.getMaxUserSize() < room.getUserSize())
				throw new ServiceException(KConstants.ResultCode.NotLowerGroupMember);
			int maxUserSize = SKBeanUtils.getImCoreService().getConfig().getMaxCrowdNumber();
			if(roomVO.getMaxUserSize() > maxUserSize)
				throw new ServiceException(KConstants.ResultCode.RoomMemberAchieveMax);
//			operations.set("maxUserSize",roomVO.getMaxUserSize());
			map.put("maxUserSize",roomVO.getMaxUserSize());
		}
		// 锁定、取消锁定群组
		if(null != roomVO.getS() && 0 != roomVO.getS()){
			roomIsLocking(user, roomVO, isAdmin, room);
			return null;
		}
			
		if(-1!=roomVO.getShowMember()){
			showMember(user, roomVO, isAdmin, room);
			return null;
		}
		if(-1!=roomVO.getAllowSendCard()){
			roomAllowSendCard(user, roomVO, isAdmin, room);
			return null;
		}
		
		if(-1!=roomVO.getAllowInviteFriend()){
			roomAllowInviteFriend(user, roomVO, room);
			return null;
		}
		
		if(-1!=roomVO.getAllowUploadFile()){
			roomAllowUploadFile(user, roomVO, room);
			return null;
		}
		
		if(-1!=roomVO.getAllowConference()){
			roomAllowConference(user, roomVO, room);
			return null;
		}
		
		if(-1!=roomVO.getAllowSpeakCourse()){
			roomAllowSpeakCourse(user, roomVO, room);
			return null;
		}

		if(-1!=roomVO.getForbidQuit()){
			roomForbidQuit(user, roomVO, room);
			return null;
		}

		if(-1!=roomVO.getAllowHostUpdate())
			map.put("allowHostUpdate",roomVO.getAllowHostUpdate());
		
		if(0!=roomVO.getChatRecordTimeOut())// 聊天记录超时
			ChatRecordTimeOut(user,roomVO,room);
			
		
		if(-1!=roomVO.getIsAttritionNotice())
			map.put("isAttritionNotice",roomVO.getIsAttritionNotice());

		map.put("modifyTime", DateUtil.currentTimeSeconds());
		

		synchronized (this){
			roomDao.updateRoom(room.getId(),map);
		}
		// 维护群组相关缓存
		roomRedisRepository.deleteRoom(roomVO.getRoomId().toString());
		return null;
	}

	public void updateEncryptType(Room room,int encryptType){
//		updateAttribute(room.getId(),"encryptType",encryptType);
		Map<String,Object> map = new HashMap<>();
		map.put("encryptType",encryptType);
		roomDao.updateRoom(room.getId(),map);
//		roomDao.updateRoomEncryptType(room.getId(),encryptType);
		roomRedisRepository.deleteRoom(room.getId().toString());
		MessageBean messageBean = new MessageBean();
		try {
			// IMPORTANT 1-2、改房间名推送-已改
			messageBean.setFromUserId(room.getUserId() + "");
			messageBean.setFromUserName(userCoreService.getNickName(room.getUserId()));
			messageBean.setType(MessageType.ModifyEncryptType);
			messageBean.setObjectId(room.getJid());
			messageBean.setContent(encryptType);
			messageBean.setMessageId(StringUtil.randomUUID());
			messageBean.setToUserId(room.getJid());
			// 发送群聊
			sendGroupMsg(room.getJid(), messageBean);

			// 多点登录维护数据
			if(userCoreService.isOpenMultipleDevices(room.getUserId())){
				String nickName = userCoreService.getNickName(room.getUserId());
				multipointLoginUpdateUserInfo(room.getUserId(), nickName, room.getUserId(), nickName, room.getId());
			}
		} catch (Exception e) {
			log.error(e.getMessage());
		}

	}
	public void resetGroupChatKey(Room room,final JSONObject jsonGroupKeys){

		ThreadUtils.executeInThread(obj -> {
			try {
//				final DBCollection dbCollection = getRoomDatastore().getCollection(Room.Member.class);

//				getRoomDatastore().getDB().getCollection(mucMsg+room.getJid()).drop();
				roomDao.dropRoomChatHistory(room.getJid());
				MessageBean messageBean = new MessageBean();
				messageBean.setFromUserId(room.getUserId() + "");
				messageBean.setFromUserName(userCoreService.getNickName(room.getUserId()));
				messageBean.setType(806);
				messageBean.setObjectId(room.getJid());
				messageBean.setToUserId(room.getJid());
				messageBean.setContent(room.getName());
				messageBean.setMessageId(StringUtil.randomUUID());
				sendGroupMsg(room.getJid(),messageBean);
                jsonGroupKeys.entrySet().stream().forEach( entny ->{
//                    DBObject query = new BasicDBObject().append("roomId", room.getId()).append("userId",entny.getKey());
//                    BasicDBObject values=new BasicDBObject(com.shiku.common.core.MongoOperator.SET,new BasicDBObject("chatKeyGroup",entny.getValue()));
//                    dbCollection.update(query,values);
					Map<String,Object> map = new HashMap<>();
					map.put("chatKeyGroup",entny.getValue());
                	roomMemberDao.updateRoomMember(room.getId(),Integer.valueOf(entny.getKey()),map);
                });
				dropRoomChatHistory(room.getJid());
			}catch (Exception e){
				e.printStackTrace();
			}

		});




	}
	public void updateGroupChatKey(Room room,int userId,final String key){

			try {
//				final DBCollection dbCollection = getRoomDatastore().getCollection(Room.Member.class);
				/*MessageBean messageBean = new MessageBean();
				messageBean.setFromUserId(room.getUserId() + "");
				messageBean.setFromUserName(userCoreService.getNickName(room.getUserId()));
				messageBean.setType(806);
				messageBean.setObjectId(room.getJid());
				messageBean.setToUserId(room.getJid());
				messageBean.setContent(room.getName());
				messageBean.setMessageId(StringUtil.randomUUID());
				sendGroupMsg(room.getJid(),messageBean);*/

				DBObject query = new BasicDBObject().append("roomId", room.getId()).append("userId",userId);
				BasicDBObject values=new BasicDBObject(com.shiku.common.core.MongoOperator.SET,new BasicDBObject("chatKeyGroup",key));
//				dbCollection.update(query,values);
				Map<String,Object> map = new HashMap<>();
				map.put("chatKeyGroup",key);
				roomMemberDao.updateRoomMember(room.getId(),userId,map);
			}catch (Exception e){
				e.printStackTrace();
			}





	}

	/** @Description:维护群组、群成员 缓存 
	* @param roomId
	**/ 
	protected void updateRoomInfoByRedis(String roomId){
		roomRedisRepository.deleteRoom(roomId);
		roomRedisRepository.deleteMemberList(roomId);
	}
	
	// 修改群昵称
	public synchronized void UpdateGroupNickname(User user,RoomVO roomVO,int isAdmin,Room room) {
		
//		operations.set("name", roomVO.getRoomName());
//		updateGroup(query, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("name", roomVO.getRoomName());
		roomDao.updateRoom(roomVO.getRoomId(),map);
		/**
		 * 维护群组缓存
		 */
		roomRedisRepository.deleteRoom(room.getId().toString());
		MessageBean messageBean = new MessageBean();
		if (1 == isAdmin) {
			// IMPORTANT 1-2、改房间名推送-已改
			messageBean.setFromUserId(user.getUserId() + "");
			messageBean.setFromUserName(("10005".equals(user.getUserId().toString())?"后台管理员":getMemberNickname(room.getId(), user.getUserId())));
			messageBean.setType(MessageType.CHANGE_ROOM_NAME);
			messageBean.setObjectId(room.getJid());
			messageBean.setContent(roomVO.getRoomName());
			messageBean.setMessageId(StringUtil.randomUUID());
		}
		// 发送群聊
		sendGroupMsg(room.getJid(), messageBean);
		
	}
	
	// 全员禁言
	public void allBannedSpeak(User user,RoomVO roomVO,Room room){
//		operations.set("talkTime", roomVO.getTalkTime());
//		updateGroup(query, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("talkTime", roomVO.getTalkTime());
		roomDao.updateRoom(roomVO.getRoomId(),map);
		roomAllBanned(roomVO.getRoomId(), roomVO.getTalkTime());
		/**
		 * 维护群组、群成员缓存
		 */
		updateRoomInfoByRedis(room.getId().toString());
		MessageBean messageBean=new MessageBean();
		messageBean.setType(MessageType.RoomAllBanned);
		messageBean.setFromUserId(user.getUserId().toString());
		messageBean.setFromUserName(getMemberNickname(room.getId(), user.getUserId()));
		messageBean.setContent(String.valueOf(roomVO.getTalkTime()));
		messageBean.setObjectId(room.getJid());
		messageBean.setMessageId(StringUtil.randomUUID());
		// 发送群聊通知
		sendGroupMsg(room.getJid(), messageBean);
	}
	
	// 新公告
	public String newNotice(User user,RoomVO roomVO,int isAdmin,Room room){
		Notice notice = new Notice(new ObjectId(),roomVO.getRoomId(),roomVO.getNotice(),user.getUserId(),user.getNickname());
		// 更新最新公告
//		operations.set("notice", notice);
//		updateGroup(query, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("notice", notice);
		roomDao.updateRoom(roomVO.getRoomId(),map);
		// 新增历史公告记录
//		getRoomDatastore().save(notice);
		roomNoticeDao.addNotice(notice);
		/**
		 * 维护公告
		 */
		roomRedisRepository.deleteNoticeList(room.getId());
		/**
		 * 维护群组缓存
		 */
		roomRedisRepository.deleteRoom(room.getId().toString());
		MessageBean messageBean = new MessageBean();
		if (1 == isAdmin) {
			// IMPORTANT 1-5、改公告推送-已改
			messageBean.setFromUserId(user.getUserId() + "");
			messageBean.setFromUserName(getMemberNickname(room.getId(), user.getUserId()));
			messageBean.setType(MessageType.NEW_NOTICE);
			messageBean.setObjectId(room.getJid());
			messageBean.setContent(roomVO.getNotice());
			messageBean.setMessageId(StringUtil.randomUUID());
		}
		// 发送群聊
		sendGroupMsg(room.getJid(), messageBean);
		return notice.getId().toString();
	}
	
	// 显示已读人数
	public void alreadyReadNums(User user,RoomVO roomVO,int isAdmin,Room room){
//		operations.set("showRead", roomVO.getShowRead());
//		updateGroup(query, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("showRead", roomVO.getShowRead());
		roomDao.updateRoom(roomVO.getRoomId(),map);
		/**
		 * 维护群组缓存
		 */
		roomRedisRepository.deleteRoom(room.getId().toString());
		MessageBean messageBean=new MessageBean();
		if(1==isAdmin){
			messageBean.setType(MessageType.SHOWREAD);
			messageBean.setFromUserId(user.getUserId().toString());
			messageBean.setFromUserName(getMemberNickname(room.getId(), user.getUserId()));
			messageBean.setContent(String.valueOf(roomVO.getShowRead()));
			messageBean.setObjectId(room.getJid());
			messageBean.setMessageId(StringUtil.randomUUID());
		}
		// 发送群聊
		sendGroupMsg(room.getJid(), messageBean);
	}
	
	// 群组验证
	public void groupVerification(User user,RoomVO roomVO,int isAdmin,Room room){
//		operations.set("isNeedVerify",roomVO.getIsNeedVerify());
//		updateGroup(query, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("isNeedVerify",roomVO.getIsNeedVerify());
		roomDao.updateRoom(roomVO.getRoomId(),map);
		/**
		 * 维护群组缓存
		 */
		roomRedisRepository.deleteRoom(room.getId().toString());
		MessageBean messageBean=new MessageBean();
		if(1==isAdmin){
			messageBean.setType(MessageType.RoomNeedVerify);
			messageBean.setFromUserId(user.getUserId().toString());
			messageBean.setFromUserName(getMemberNickname(room.getId(), user.getUserId()));
			messageBean.setContent(String.valueOf(roomVO.getIsNeedVerify()));
			messageBean.setObjectId(room.getJid());
			messageBean.setMessageId(StringUtil.randomUUID());
		}
		// 发送群聊
		sendGroupMsg(room.getJid(), messageBean);
	}
	
	// 是否公开群组
	public void roomIsPublic(User user,RoomVO roomVO,int isAdmin,Room room){
//		operations.set("isLook",roomVO.getIsLook());
//		updateGroup(query, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("isLook",roomVO.getIsLook());
		roomDao.updateRoom(roomVO.getRoomId(),map);
		/**
		 * 维护群组缓存
		 */
		roomRedisRepository.deleteRoom(room.getId().toString());
		MessageBean messageBean=new MessageBean();
		if(1==isAdmin){
			messageBean.setType(MessageType.RoomIsPublic);
			messageBean.setFromUserId(user.getUserId().toString());
			messageBean.setFromUserName(getMemberNickname(room.getId(), user.getUserId()));
			messageBean.setContent(String.valueOf(roomVO.getIsLook()));
			messageBean.setObjectId(room.getJid());
			messageBean.setMessageId(StringUtil.randomUUID());
		}
		// 发送群聊
		sendGroupMsg(room.getJid(), messageBean);
	}
	
	// 群组是否被锁定
	public void roomIsLocking(User user,RoomVO roomVO,int isAdmin,Room room){
//		operations.set("s",roomVO.getS());
//		updateGroup(query, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("s",roomVO.getS());
		roomDao.updateRoom(roomVO.getRoomId(),map);
		/**
		 * 维护群组缓存
		 */
		roomRedisRepository.deleteRoom(room.getId().toString());
		MessageBean messageBean = new MessageBean();
		if (1 == isAdmin) {
			messageBean.setType(MessageType.consoleProhibitRoom);
			messageBean.setFromUserId(user.getUserId().toString());
			messageBean.setFromUserName(getMemberNickname(room.getId(), user.getUserId()));
			messageBean.setContent(roomVO.getS());
			messageBean.setObjectId(room.getJid());
			messageBean.setMessageId(StringUtil.randomUUID());
		}
		// 发送群聊
		sendChatGroupMsg(roomVO.getRoomId(), room.getJid(), messageBean);
	}
	
	
	// 是否允许发送名片
	public void roomAllowSendCard(User user,RoomVO roomVO,int isAdmin,Room room){
//		operations.set("allowSendCard",roomVO.getAllowSendCard());
//		updateGroup(query, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("allowSendCard",roomVO.getAllowSendCard());
		roomDao.updateRoom(roomVO.getRoomId(),map);
		/**
		 * 维护群组缓存
		 */
		roomRedisRepository.deleteRoom(room.getId().toString());
		MessageBean messageBean=new MessageBean();
		if(1==isAdmin){
			messageBean.setType(MessageType.RoomAllowSendCard);
			messageBean.setFromUserId(user.getUserId().toString());
			messageBean.setFromUserName(getMemberNickname(room.getId(), user.getUserId()));
			messageBean.setContent(String.valueOf(roomVO.getAllowSendCard()));
			messageBean.setObjectId(room.getJid());
			messageBean.setMessageId(StringUtil.randomUUID());
		}
		// 发送群聊
		sendGroupMsg(room.getJid(), messageBean);
	}
	
	// 普通成员 是否可以看到 群组内的成员
	public void showMember(User user, RoomVO roomVO, int isAdmin, Room room) {
//		operations.set("showMember", roomVO.getShowMember());
//		updateGroup(query, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("showMember", roomVO.getShowMember());
		roomDao.updateRoom(roomVO.getRoomId(),map);
		/**
		 * 维护群组缓存
		 */
		roomRedisRepository.deleteRoom(room.getId().toString());
		MessageBean messageBean = new MessageBean();
		if (1 == isAdmin) {
			messageBean.setType(MessageType.RoomShowMember);
			messageBean.setFromUserId(user.getUserId().toString());
			messageBean.setFromUserName(getMemberNickname(room.getId(), user.getUserId()));
			messageBean.setContent(String.valueOf(roomVO.getShowMember()));
			messageBean.setObjectId(room.getJid());
			messageBean.setMessageId(StringUtil.randomUUID());
		}
		// 发送群聊
		sendGroupMsg(room.getJid(), messageBean);
	}
	
	// 是否允许群成员邀请好友
	public void roomAllowInviteFriend(User user, RoomVO roomVO, Room room) {
//		operations.set("allowInviteFriend", roomVO.getAllowInviteFriend());
//		updateGroup(query, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("allowInviteFriend", roomVO.getAllowInviteFriend());
		roomDao.updateRoom(roomVO.getRoomId(),map);
		/**
		 * 维护群组缓存
		 */
		roomRedisRepository.deleteRoom(room.getId().toString());
		MessageBean messageBean = new MessageBean();
		messageBean.setType(MessageType.RoomAllowInviteFriend);
		messageBean.setFromUserId(user.getUserId().toString());
		messageBean.setFromUserName(getMemberNickname(room.getId(), user.getUserId()));
		messageBean.setContent(String.valueOf(roomVO.getAllowInviteFriend()));
		messageBean.setObjectId(room.getJid());
		messageBean.setMessageId(UUID.randomUUID().toString());
		messageBean.setMessageId(StringUtil.randomUUID());
		// 发送群聊
		sendGroupMsg(room.getJid(), messageBean);
	}
	
	// 是否允许群成员上传文件
	public void roomAllowUploadFile(User user, RoomVO roomVO, Room room) {
//		operations.set("allowUploadFile", roomVO.getAllowUploadFile());
//		updateGroup(query, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("allowUploadFile", roomVO.getAllowUploadFile());
		roomDao.updateRoom(roomVO.getRoomId(),map);
		/**
		 * 维护群组缓存
		 */
		roomRedisRepository.deleteRoom(room.getId().toString());
		MessageBean messageBean = new MessageBean();
		messageBean.setType(MessageType.RoomAllowUploadFile);
		messageBean.setFromUserId(user.getUserId().toString());
		messageBean.setFromUserName(getMemberNickname(room.getId(), user.getUserId()));
		messageBean.setContent(String.valueOf(roomVO.getAllowUploadFile()));
		messageBean.setObjectId(room.getJid());
		messageBean.setMessageId(StringUtil.randomUUID());
		// 发送群聊
		sendGroupMsg(room.getJid(), messageBean);
	}
	
	// 群组允许成员召开会议
	public void roomAllowConference(User user, RoomVO roomVO, Room room) {
//		operations.set("allowConference", roomVO.getAllowConference());
//		updateGroup(query, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("allowConference", roomVO.getAllowConference());
		roomDao.updateRoom(roomVO.getRoomId(),map);
		/**
		 * 维护群组缓存
		 */
		roomRedisRepository.deleteRoom(room.getId().toString());
		MessageBean messageBean = new MessageBean();
		messageBean.setType(MessageType.RoomAllowConference);
		messageBean.setFromUserId(user.getUserId().toString());
		messageBean.setFromUserName(getMemberNickname(room.getId(), user.getUserId()));
		messageBean.setContent(String.valueOf(roomVO.getAllowConference()));
		messageBean.setObjectId(room.getJid());
		messageBean.setMessageId(StringUtil.randomUUID());
		// 发送群聊
		sendGroupMsg(room.getJid(), messageBean);
	}
	
	//  群组允许成员开启讲课
	public void roomAllowSpeakCourse(User user, RoomVO roomVO, Room room) {
//		operations.set("allowSpeakCourse", roomVO.getAllowSpeakCourse());
//		updateGroup(query, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("allowSpeakCourse", roomVO.getAllowSpeakCourse());
		roomDao.updateRoom(roomVO.getRoomId(),map);
		/**
		 * 维护群组缓存
		 */
		roomRedisRepository.deleteRoom(room.getId().toString());
		MessageBean messageBean = new MessageBean();
		messageBean.setType(MessageType.RoomAllowSpeakCourse);
		messageBean.setFromUserId(user.getUserId().toString());
		messageBean.setFromUserName(getMemberNickname(room.getId(), user.getUserId()));
		messageBean.setContent(String.valueOf(roomVO.getAllowSpeakCourse()));
		messageBean.setObjectId(room.getJid());
		messageBean.setMessageId(StringUtil.randomUUID());
		// 发送群聊
		sendGroupMsg(room.getJid(), messageBean);
	}

	//  群组禁止成员退群
	public void roomForbidQuit(User user, RoomVO roomVO, Room room) {
		Map<String,Object> map = new HashMap<>(1);
		map.put("forbidQuit", roomVO.getForbidQuit());
		roomDao.updateRoom(roomVO.getRoomId(),map);
		/**
		 * 维护群组缓存
		 */
		roomRedisRepository.deleteRoom(room.getId().toString());
		MessageBean messageBean = new MessageBean();
		messageBean.setType(MessageType.ForbidQuit);
		messageBean.setFromUserId(user.getUserId().toString());
		messageBean.setFromUserName(getMemberNickname(room.getId(), user.getUserId()));
		messageBean.setContent(String.valueOf(roomVO.getForbidQuit()));
		messageBean.setObjectId(room.getJid());
		messageBean.setMessageId(StringUtil.randomUUID());
		// 发送群聊
		sendGroupMsg(room.getJid(), messageBean);
	}

	// 聊天记录超时设置 通知
	public void ChatRecordTimeOut(User user,RoomVO roomVO,Room room){
//		operations.set("chatRecordTimeOut",roomVO.getChatRecordTimeOut());
//		updateGroup(query, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("chatRecordTimeOut",roomVO.getChatRecordTimeOut());
		roomDao.updateRoom(roomVO.getRoomId(),map);
		/**
		 * 维护群组缓存
		 */
		roomRedisRepository.deleteRoom(room.getId().toString());
		MessageBean messageBean = new MessageBean();
		messageBean.setType(MessageType.ChatRecordTimeOut);
		messageBean.setFromUserId(user.getUserId().toString());
		messageBean.setFromUserName(getMemberNickname(room.getId(), user.getUserId()));
		messageBean.setContent(String.valueOf(roomVO.getChatRecordTimeOut()));
		messageBean.setObjectId(room.getJid());
		messageBean.setMessageId(StringUtil.randomUUID());
		
		// 发送群聊
		sendGroupMsg(room.getJid(), messageBean);
		
	}
	
//	public synchronized void updateGroup(Query<Room> query,UpdateOperations<Room> operations){
//		getRoomDatastore().update(query, operations);
//	}
	
	// 单聊通知某个人
	public void sendGroupOne(Integer userIds,MessageBean messageBean){
		try {
			messageBean.setMsgType(0);
			messageService.send(messageBean);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	// 发送群聊通知
	public void sendGroupMsg(String jid,MessageBean messageBean){
		try {
			messageService.sendMsgToGroupByJid(jid,messageBean);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	// 发送单聊通知某个人 ,且 发送群聊通知
	public void sendChatToOneGroupMsg(Integer userIds, String jid,MessageBean messageBean){
		try {
			// 发送单聊
			messageBean.setMsgType(0);
			messageBean.setMessageId(StringUtil.randomUUID());
			messageService.send(messageBean);
			// 发送群聊
			ThreadUtils.executeInThread(new Callback() {
				
				@Override
				public void execute(Object obj) {
					try {
						messageService.sendMsgToGroupByJid(jid, messageBean);
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			});
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	// 发送单聊通知群组所有人 ,且 发送群聊通知
	public void sendChatGroupMsg(ObjectId roomId,String jid,MessageBean messageBean){
		try {
			// 发送单聊
			messageBean.setMsgType(0);
			messageBean.setMessageId(StringUtil.randomUUID());
			messageService.send(messageBean,getMemberIdList(roomId));
			// 发送群聊
			ThreadUtils.executeInThread(new Callback() {
				
				@Override
				public void execute(Object obj) {
					try {
						messageService.sendMsgToGroupByJid(jid, messageBean);
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			});
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	
	/**
	* @Description: TODO(群主 转让)
	* @param @param roomId  群主ID
	* @param @param toUserId   新群主 用户ID   必须 是 群内成员
	 */
	public Room transfer(Room room,Integer toUserId){
		
		String nickName = userCoreService.getNickName(toUserId);
//		Query<Room> roomQuery = getRoomDatastore().createQuery(getEntityClass()).filter("_id", room.getId());
//		UpdateOperations<Room> roomOps = getRoomDatastore().createUpdateOperations(getEntityClass());
//		roomOps.set("userId", toUserId);
//		roomOps.set("nickname", nickName);
//		getRoomDatastore().update(roomQuery, roomOps);
		Map<String,Object> map = new HashMap<>();
		map.put("userId",toUserId);
		map.put("nickname",nickName);
		roomDao.updateRoom(room.getId(),map);

		/*修改 旧群主的角色*/
//		Query<Member> query = getRoomDatastore().createQuery(Member.class);
//		query.filter("roomId", room.getId());
//		query.filter("userId", room.getUserId());
//		UpdateOperations<Member> operations = getRoomDatastore().createUpdateOperations(Member.class);
//		operations.set("role", 3);
//		getRoomDatastore().update(query,operations);
		roomMemberDao.updateRoomMemberRole(room.getId(),room.getUserId(),3);
		
		/*赋值新群主的角色*/
//		query=SKBeanUtils.getImRoomDatastore().createQuery(Member.class);
//		query.filter("roomId", room.getId());
//		query.filter("userId",toUserId);
//		operations = SKBeanUtils.getImRoomDatastore().createUpdateOperations(Member.class);
//		operations.set("role", 1);
//		SKBeanUtils.getImRoomDatastore().update(query, operations);
		roomMemberDao.updateRoomMemberRole(room.getId(),toUserId,1);
		// 更新群组、群成员相关缓存
		updateRoomInfoByRedis(room.getId().toString());
		MessageBean message=new MessageBean();
		message.setType(MessageType.RoomTransfer);
		message.setFromUserId(room.getUserId()+"");
		message.setFromUserName(getMemberNickname(room.getId(), room.getUserId()));
		message.setObjectId(room.getJid());
		message.setToUserId(toUserId.toString());
		message.setToUserName(userCoreService.getNickName(toUserId));
		message.setMessageId(StringUtil.randomUUID());
		// 发送单聊通知被转让的人、群聊通知
		sendChatToOneGroupMsg(toUserId, room.getJid(), message);
//		return get(room.getId());
		return roomCoreDao.getRoomById(room.getId());
	}
	
	
	@Override
	public Room get(ObjectId roomId,Integer pageIndex,Integer pageSize) {
		// redis room 不包含 members noties
		Room specialRoom;
		Room redisRoom = roomRedisRepository.queryRoom(roomId);
		if(null != redisRoom){
			if(-1 == redisRoom.getS())
				throw new ServiceException(KConstants.ResultCode.RoomIsLock);
			specialRoom = specialHandleByRoom(redisRoom, roomId,pageIndex,pageSize);
			log.info("/room/get  :  redisRoom : {}",JSON.toJSONString(specialRoom));
		}else{
//			Room room = getRoomDatastore().createQuery(getEntityClass()).field("_id").equal(roomId).get();
			Room room = roomCoreDao.getRoomById(roomId);
			if(null != room && -1 == room.getS())
				throw new ServiceException(KConstants.ResultCode.RoomIsLock);
			if(null==room)
				throw new ServiceException(KConstants.ResultCode.NotRoom);
			specialRoom = specialHandleByRoom(room, roomId,pageIndex,pageSize);
			log.info("/room/get  :  DB Room : {}",JSON.toJSONString(specialRoom));
		}
		return specialRoom;
	}

	@Override
	public Room getRoomByJid(String roomJid) {
		return roomCoreDao.getRoomByJid(roomJid);
	}

	/** @Description: 房间相关特殊处理操作
	* @param room
	* @param roomId
	* @return
	**/ 
	public Room specialHandleByRoom(Room room,ObjectId roomId,Integer pageIndex,Integer pageSize){
		// 特殊身份处理
		Member member = getMember(roomId, ReqUtil.getUserId());
		log.info("==== request member ==== : userId :{}, member : {}", ReqUtil.getUserId(), JSON.toJSONString(member));
		if(null == member){
			// 主动加群（二维码扫描），该用户不再群组内，需要members
			Room joinRoom = getRoom(roomId);
//			List<Member> members = getMembers(roomId,pageIndex,pageSize);
			List<Member> members = getHeadMemberListByPageImpls(roomId, pageSize,0);
			joinRoom.setMembers(members);
			return joinRoom;
		}
		int role = member.getRole();
		List<Member> members = null;
//		 监护人和隐身人不能互看  保证每次都有自己
		if(1 != member.getRole()){
//			Query<Member> query = getRoomDatastore().createQuery(Room.Member.class).field("roomId").equal(roomId).order("role").order("createTime").offset(pageIndex*pageSize).limit(pageSize);
			if(role > KConstants.Room_Role.CREATOR && role < KConstants.Room_Role.INVISIBLE){
//				Query<Member> queryMemberSize = getRoomDatastore().createQuery(Room.Member.class).field("roomId").equal(roomId).offset(pageIndex*pageSize).limit(pageSize);
//				query.field("role").lessThan(KConstants.Room_Role.INVISIBLE).order("role");
//				members = query.asList();
				members = roomMemberDao.getMemberListLessThan(roomId,KConstants.Room_Role.INVISIBLE,pageIndex,pageSize);
//				int specialSize = queryMemberSize.field("role").greaterThanOrEq(4).asList().size();// 隐身人监护人
//				int specialSize = roomMemberDao.getMemberListLessThanOrEq(roomId,4,0,0).size();
				int specialSize = (int)roomMemberDao.getMemberNumGreaterThanOrEq(roomId,(byte) 4,pageIndex,pageSize);
				room.setUserSize(room.getUserSize()-specialSize);
			}else if(role == KConstants.Room_Role.INVISIBLE || role == KConstants.Room_Role.GUARDIAN){
				// 隐身人
//				query.or(query.criteria("role").lessThan(KConstants.Room_Role.INVISIBLE),query.criteria("userId").equal(ReqUtil.getUserId()));
//				members = query.asList();
				Map<String, Object> membersMap = roomMemberDao.getMemberListOr(roomId, KConstants.Room_Role.INVISIBLE, ReqUtil.getUserId(), pageIndex, pageSize);
				members = (List<Member>) membersMap.get("members");
				room.setUserSize(Integer.valueOf(membersMap.get("count").toString()));
			}
			room.setMembers(members);
		}else {
//			List<Member> membersList = getMembers(roomId,pageIndex,pageSize);
			List<Member> membersList = getHeadMemberListByPageImpls(roomId, pageSize,member.getRole());
			room.setMembers(membersList);
		}
		// 群公告
		List<Notice> noticesCache = roomRedisRepository.getNoticeList(roomId);
		if(null != noticesCache && noticesCache.size() > 0){
			room.setNotices(noticesCache);
		}else{
//			List<Notice> noticesDB = getRoomDatastore().createQuery(Room.Notice.class).field("roomId").equal(roomId).order("-time").asList();
			List<Notice> noticesDB = roomNoticeDao.getNoticList(roomId,0,0);
			room.setNotices(noticesDB);
			/**
			 * 维护群公告列表缓存
			 */
			roomRedisRepository.saveNoticeList(roomId, noticesDB);
		}
		return room;
	}
	
	/**
	 * @return
	 */
//	private Datastore getRoomDatastore() {
//		// TODO Auto-generated method stub
//		return SKBeanUtils.getImRoomDatastore();
//	}

	/** @Description: 首先返回群主、管理员然后按加群时间排序
	* @param roomId
	* @param pageIndex
	* @param pageSize
	* @return
	**/ 
	@SuppressWarnings("deprecation")
	public List<Member> getMembers(ObjectId roomId,Integer pageIndex,Integer pageSize){
		List<Member> members = new ArrayList<Member>();
		// 群成员
		List<Member> memberCacheList = roomRedisRepository.getMemberList(roomId.toString(),pageIndex,pageSize);
		if(null != memberCacheList && memberCacheList.size() > 0)
			members = memberCacheList;
		else{
			// 群主管理员
//			Query<Member> memberQuery = getRoomDatastore().createQuery(Room.Member.class).field("roomId").equal(roomId).field("role").lessThanOrEq(2).order("role").order("createTime");
//			List<Member> adminList = memberQuery.asList();
			List<Member> adminList = roomMemberDao.getMemberListLessThanOrEq(roomId,2,0,0);
			// 普通成员
//			Query<Member> query = getRoomDatastore().createQuery(Room.Member.class).field("roomId").equal(roomId).field("role").greaterThan(2).order("createTime");
			
//			List<Member> memberAllList = query.asList();
			List<Member> memberAllList = roomMemberDao.getMemberListGreaterThan(roomId,2,0,0);
			int adminSize = adminList.size();
			if(pageSize > adminSize){
				pageSize -= adminSize;
//				Query<Member> query = getRoomDatastore().createQuery(Room.Member.class).field("roomId").equal(roomId).field("role").greaterThan(2).order("createTime").offset(pageIndex*pageSize).limit(pageSize);
//				query.offset(pageIndex * pageSize).limit(pageSize);
//				List<Member> memberList = query.asList();// 普通群成员
				List<Member> memberList = roomMemberDao.getMemberListGreaterThan(roomId,2,pageIndex,pageSize);
				members.addAll(adminList);
				members.addAll(memberList);
			} else {
//				Query<Member> limit = memberQuery.offset(pageIndex * pageSize).limit(pageSize);
//				members = limit.asList();
				members = roomMemberDao.getMemberListLessThanOrEq(roomId,2,pageIndex,pageSize);
			}
			List<Member> dbMembers = new ArrayList<Member>();
			dbMembers.addAll(adminList);
			dbMembers.addAll(memberAllList);
			// 维护群成员缓存数据
			roomRedisRepository.saveMemberList(roomId.toString(), dbMembers);
		}
		
		return members;
	}
	
	/** @Description:room/get 和 joinTime 为0时返回群成员 列表
	 * // 补全问题 ： 例如 ：pageSize = 100 。  第一种情况 小于pageSize{ 群组 + 管理员 = 80人   返回 80+20普通群成员} 
	 *  第二种情况 大于等于pageSize{ 群组 + 管理员 = 120人   返回 120人 + 1名最先加群的普通群成员主要拿到createTime}
	* @param roomId
	* @param pageSize
	* @param role
	* @return
	**/ 
	@SuppressWarnings("deprecation")
	public List<Member> getHeadMemberListByPageImpls(ObjectId roomId,Integer pageSize,int role){

		List<Member> members = new ArrayList<Member>();
		// 群主管理员
//		Query<Member> adminMemberQuery = getRoomDatastore().createQuery(Room.Member.class).field("roomId").equal(roomId).field("role").lessThanOrEq(KConstants.Room_Role.ADMIN).order("role").order("createTime");
//		List<Member> adminList = adminMemberQuery.asList();
		List<Member> adminList = roomMemberDao.getMemberListLessThanOrEq(roomId,KConstants.Room_Role.ADMIN,0,0);
		int adminSize = adminList.size();
		if(adminSize < pageSize){
			// 补全pageSize
//			members.addAll(adminMemberQuery.asList());
			members.addAll(adminList);
//			Query<Member> lessMemberQuery = getRoomDatastore().createQuery(Room.Member.class).field("roomId").equal(roomId).field("role").greaterThan(KConstants.Room_Role.ADMIN).order("createTime").limit(pageSize - adminSize);
//			if(KConstants.Room_Role.CREATOR != role)
//				lessMemberQuery.field("role").notEqual(KConstants.Room_Role.INVISIBLE);
//			members.addAll(lessMemberQuery.asList());
			members.addAll(roomMemberDao.getMemberListAdminRole(roomId,role,pageSize - adminSize));
		}else{
//			members.addAll(adminMemberQuery.asList());
			members.addAll(adminList);
//			Query<Member> lessMemberQuery = getRoomDatastore().createQuery(Room.Member.class).field("roomId").equal(roomId).field("role").greaterThan(KConstants.Room_Role.ADMIN).order("createTime").limit(1);
//			if(KConstants.Room_Role.CREATOR != role)
//				lessMemberQuery.field("role").notEqual(KConstants.Room_Role.INVISIBLE);
//			members.addAll(lessMemberQuery.asList());
			members.addAll(roomMemberDao.getMemberListAdminRole(roomId,role,1));
		}
		return members;
	}
	
	/** @Description:群成员分页
	* @param roomId
	* @param joinTime
	* @param pageSize
	* @return
	**/ 
	public List<Member> getMemberListByPageImpl(ObjectId roomId,long joinTime,Integer pageSize){
//		int role = getMember(roomId, ReqUtil.getUserId()).getRole();
		Member member = getMember(roomId, ReqUtil.getUserId());
		if(null == member){
			throw new ServiceException(KConstants.ResultCode.MemberNotInGroup);
		}
		if(0 == joinTime)
			return getHeadMemberListByPageImpls(roomId, pageSize,member.getRole());
//		Query<Member> memberQuery = getRoomDatastore().createQuery(Room.Member.class).field("roomId").equal(roomId).field("role").greaterThan(2).field("createTime").greaterThanOrEq(joinTime).order("createTime").limit(pageSize);
//		if(KConstants.Room_Role.CREATOR != member.getRole())
//			memberQuery.field("role").notEqual(4);
//		return memberQuery.asList();
		List<Member> memberListByTime = roomMemberDao.getMemberListByTime(roomId, member.getRole(), joinTime, pageSize);
//		return roomMemberDao.getMemberListByTime(roomId,member.getRole(),joinTime,pageSize);
		log.info("===== getMemberListByPageImpl ====  roomId : {},   joinTime : {}, memberSize : {}",roomId,joinTime,memberListByTime.size());
		return memberListByTime;
	}
	
	public Room consoleGetRoom(ObjectId roomId) {
//		Room room = getRoomDatastore().createQuery(getEntityClass()).field("_id").equal(roomId).get();
		Room room = roomCoreDao.getRoomById(roomId);
		if (null != room) {
//			List<Member> members = getRoomDatastore().createQuery(Room.Member.class).field("roomId").equal(roomId).order("createTime").order("role").asList();
			List<Member> members = roomMemberDao.getMemberListOrder(roomId);
//			List<Notice> notices = getRoomDatastore().createQuery(Room.Notice.class).field("roomId").equal(roomId).order("-time").asList();
			List<Notice> notices = roomNoticeDao.getNoticList(roomId,0,0);
			room.setMembers(members);
			room.setNotices(notices);
			if(0==room.getUserSize()){
				room.setUserSize(members.size());
//				DBObject q = new BasicDBObject("_id", roomId);
//				DBObject o = new BasicDBObject("$set", new BasicDBObject("userSize", members.size()));
//				getRoomDatastore().getCollection(getEntityClass()).update(q, o);
				Map<String,Object> map = new HashMap<>();
				map.put("userSize",members.size());
				roomDao.updateRoom(roomId,map);
			}
		}
		return room;
	}
	
	
	/**
	* @Description: TODO(获取群组详情，群主和管理员信息，考虑特殊身份隐身人监护人，不获取普通群成员列表和公告列表,)
	* @param @param roomId
	* @param @return    参数
	 */
	public Room getRoom(ObjectId roomId){
		Room room = null;
		Room roomCache = roomRedisRepository.queryRoom(roomId);
		if(null != roomCache){
			room = roomCache;
		}else{
//			Room roomDB = getRoomDatastore().createQuery(getEntityClass()).field("_id").equal(roomId).get();
			Room roomDB = roomCoreDao.getRoomById(roomId);
			if(null == roomDB)
				throw new ServiceException(KConstants.ResultCode.NotRoom);
			room = roomDB;
			/**
			 * 缓存 房间
			 */
			roomRedisRepository.saveRoom(room);
		}
		// 群组和管理员信息
		room.setMembers(getAdministrationMemberList(roomId));
		Integer userId = ReqUtil.getUserId();
		int userRole = roleCoreService.getUserRoleByUserId(userId);
		Member member = null;
		int role = 0;
		member = getMember(roomId, userId);
		// 面对面建群，用户不在群组中处理
		if(null == member)
			return room;
		role = member.getRole();
		// 后台管理中获取群组详情
		if(KConstants.Admin_Role.ADMIN != userRole && KConstants.Admin_Role.SUPER_ADMIN != userRole){
			member = getMember(roomId, userId);
			if(null == member)
				throw new ServiceException(KConstants.ResultCode.MemberNotInGroup);
			role = member.getRole();	
		}
//		Query<Member> memberQuery = getRoomDatastore().createQuery(Member.class).field("roomId").equal(roomId);
		if(KConstants.Room_Role.CREATOR < role && role < KConstants.Room_Role.INVISIBLE){
//			long invisibleCustodyCount = memberQuery.field("role").greaterThanOrEq(KConstants.Room_Role.INVISIBLE).count();
			long invisibleCustodyCount = roomMemberDao.getMemberNumGreaterThanOrEq(roomId,KConstants.Room_Role.INVISIBLE,0,0);
			int userSize = (int) (room.getUserSize() - invisibleCustodyCount);
			room.setUserSize(userSize);
		}else if(KConstants.Room_Role.INVISIBLE == role || KConstants.Room_Role.GUARDIAN == role){
//			memberQuery.or(memberQuery.criteria("role").lessThan(KConstants.Room_Role.INVISIBLE),memberQuery.criteria("userId").equal(userId));
//			long userCount = memberQuery.count();
			long userCount = roomMemberDao.getMemberNumLessThan(roomId,KConstants.Room_Role.INVISIBLE,userId);
			room.setUserSize((int) userCount);
		}
		return room;
	}
	
	public Room getRoom(ObjectId roomId,Integer userId){
		Room room = null;
		Room roomCache = roomRedisRepository.queryRoom(roomId);
		if(null != roomCache){
			room = roomCache;
		}else{
//			Room roomDB = getRoomDatastore().createQuery(getEntityClass()).field("_id").equal(roomId).get();
			Room roomDB = roomCoreDao.getRoomById(roomId);
			if(null == roomDB)
				throw new ServiceException(KConstants.ResultCode.NotRoom);
			room = roomDB;
			/**
			 * 缓存 房间
			 */
			roomRedisRepository.saveRoom(room);
		}
		// 群组和管理员信息
		room.setMembers(getAdministrationMemberList(roomId));
		int userRole = roleCoreService.getUserRoleByUserId(userId);
		Member member = null;
		int role = 0;
		// 后台管理中获取群组详情
		if(KConstants.Admin_Role.ADMIN != userRole && KConstants.Admin_Role.SUPER_ADMIN != userRole){
			member = getMember(roomId, userId);
			if(null == member)
				throw new ServiceException(KConstants.ResultCode.MemberNotInGroup);
			role = member.getRole();	
		}
//		Query<Member> memberQuery = getRoomDatastore().createQuery(Member.class).field("roomId").equal(roomId);
		if(KConstants.Room_Role.CREATOR < role && role < KConstants.Room_Role.INVISIBLE){
//			long invisibleCustodyCount = memberQuery.field("role").greaterThanOrEq(KConstants.Room_Role.INVISIBLE).count();
			long invisibleCustodyCount = roomMemberDao.getMemberNumGreaterThanOrEq(roomId,KConstants.Room_Role.INVISIBLE,0,0);
			int userSize = (int) (room.getUserSize() - invisibleCustodyCount);
			room.setUserSize(userSize);
		}else if(KConstants.Room_Role.INVISIBLE == role || KConstants.Room_Role.GUARDIAN == role){
//			memberQuery.or(memberQuery.criteria("role").lessThan(KConstants.Room_Role.INVISIBLE),memberQuery.criteria("userId").equal(userId));
//			long userCount = memberQuery.count();
			long userCount = roomMemberDao.getMemberNumLessThan(roomId,KConstants.Room_Role.INVISIBLE,userId);
			room.setUserSize((int) userCount);
		}
		return room;
	}
	
	
	/** @Description: 获取群组详情，群主和管理员信息，不考虑特殊身份隐身人监护人，不获取普通群成员列表和公告列表,)
	* @param roomId
	* @param userId
	* @return
	**/ 
	public Room getRoomInfo(ObjectId roomId,Integer userId){
		Room room = null;
		Room roomCache = roomRedisRepository.queryRoom(roomId);
		if(null != roomCache){
			room = roomCache;
		}else{
			Room roomDB = roomCoreDao.getRoomById(roomId);
			if(null == roomDB)
				throw new ServiceException(KConstants.ResultCode.NotRoom);
			room = roomDB;
			/**
			 * 缓存 房间
			 */
			roomRedisRepository.saveRoom(room);
		}
		// 群组和管理员信息
		room.setMembers(getAdministrationMemberList(roomId));
		return room;
	}
	public Integer getCreateUserId(ObjectId roomId){
		return roomDao.getCreateUserId(roomId);
	}
	public ObjectId getRoomId(String jid) {
		return roomCoreDao.getRoomId(jid);
	}
	public String queryRoomJid(ObjectId roomId) {
		return roomCoreDao.queryRoomJid(roomId);
	}
	public Integer queryRoomStatus(ObjectId roomId) {
		return roomDao.queryRoomStatus(roomId);
	}
	public String getRoomName(String jid) {
		return roomCoreDao.getRoomNameByJid(jid);
	}

	@Override
	public String getRoomName(ObjectId roomId) {
		return roomCoreDao.getRoomNameByRoomId(roomId);
	}
	// 房间状态
	@Override
	public Integer getRoomStatus(ObjectId roomId) {
		return roomDao.getRoomStatus(roomId);
	}
	@Override
	public List<Room> selectList(int pageIndex, int pageSize, String roomName) {
		List<Room> roomList = roomDao.getRoomListOrName(pageIndex,pageSize,roomName);
		return roomList;
	}
	/**
	* @Description: TODO(查询用户加入的所有群的jid)
	* @param @param userId
	* @param @return    参数
	 */
	public List<String> queryUserRoomsJidList(int userId){
		List<ObjectId> roomIdList = queryUserRoomsIdList(userId);

		return roomCoreDao.queryUserRoomsJidList(roomIdList);
	}
	
	/** @Description:在表SHIKU_ROOMJIDS_USERID 下查询用户加入的所有群的jid
	* @param userId
	* @return
	**/ 
	public List<String> queryUserRoomsJidListByDB(int userId){
		return roomMemberCoreDao.queryUserRoomsJidListByDB(userId);
	}
	/**
	 * 查询用户开启免打扰的  群组Jid 列表
	 * @param userId
	 * @return
	 */
	public List<String> queryUserNoPushJidList(int userId){
		return roomMemberCoreDao.queryUserNoPushJidList(userId);
	}
	
	/**
	* @Description: TODO(查询用户加入的所有群的roomId)
	* @param @param userId
	* @param @return 参数
	 */
	public List<ObjectId> queryUserRoomsIdList(int userId){
		return roomMemberCoreDao.getRoomIdListByUserId(userId);
	}

	@Override
	public Object selectHistoryList(int userId, int type) {
		List<ObjectId> historyIdList = Lists.newArrayList();

		historyIdList = roomMemberCoreDao.getRoomIdListByType(userId,type);
		if (historyIdList.isEmpty()) {
			return null;
		}

		List<Room> historyList = roomDao.getRoomList(historyIdList,0,0,0);
		historyList.forEach(room -> {
			Member member = roomMemberDao.getMember(room.getId(),userId);
			room.setMember(member);
		});

		return historyList;
	}

	@SuppressWarnings("deprecation")
	@Override
	public Object selectHistoryList(int userId, int type, int pageIndex, int pageSize) {
		List<ObjectId> historyIdList = roomMemberCoreDao.getRoomIdListByType(userId,type);
		if (historyIdList.isEmpty())
			return historyIdList;

		List<Room> historyList = roomDao.getRoomList(historyIdList,1,pageIndex,pageSize);
		historyList.forEach(room -> {
			Member member = roomMemberDao.getMember(room.getId(),userId);
			room.setMember(member);
		});

		return historyList;
	}



	@Override
	public void deleteMember(User user, ObjectId roomId, int userId,boolean deleteUser) {
		Room room = getRoom(roomId,user.getUserId());
		Member roomMember = getMember(roomId, user.getUserId());
		Member member = getMember(roomId, userId);
		if(member == null)
			throw new ServiceException(KConstants.ResultCode.MemberNotInGroup);
		// 处理后台管理员
		if(null == roomMember){
			// 后台管理员
			Role role = roleDao.getUserRoleByUserId(user.getUserId());
			if(null != role){
				if(5 == role.getRole() || 6 == role.getRole()){
					if(-1 == role.getStatus())
						throw new ServiceException(KConstants.ResultCode.BackAdminStatusError);
					if(!deleteUser&&room.getUserId().equals(userId)){
						throw new ServiceException(KConstants.ResultCode.NotRemoveOwner);
					}
				}
			}else{
				throw new ServiceException(KConstants.ResultCode.MemberNotInGroup);
			}
		}else{
			//自己退群&&禁止普通群成员退群
			if (user.getUserId().equals(userId) && !new Integer(1).equals(user.getPermitUserType())) {
				throw new ServiceException(KConstants.ResultCode.NO_SUPPORT_QUIT_ROOM);
			}
			// 被踢出群
			if(!user.getUserId().equals(userId)){
				if(roomMember.getRole() >= 3)
					throw new ServiceException(KConstants.ResultCode.NO_PERMISSION);
				if(room.getUserId().equals(userId)){
					throw new ServiceException(KConstants.ResultCode.NotRemoveOwner);
				}
				// 处理管理员踢管理员和隐身人监护人的问题
				if(member.getRole() != 1 && member.getRole() != 3){
					// 处理群主和后台管理员踢人问题
					if (2 == roomMember.getRole()) {
						throw new ServiceException(KConstants.ResultCode.NO_PERMISSION);
					}
				}
			}
		}
		// 处理解散群组
		if(room.getUserId().equals(userId)){
			delete(roomId, userId);
			return;
		}
		User toUser = userCoreService.getUser(userId);
		// IMPORTANT 1-4、删除成员推送-已改
		MessageBean messageBean = new MessageBean();
		messageBean.setFromUserId(user.getUserId() + "");
		messageBean.setFromUserName(getMemberNickname(roomId, user.getUserId()));
		messageBean.setType(MessageType.DELETE_MEMBER);
		// messageBean.setObjectId(roomId.toString());
		messageBean.setObjectId(room.getJid());
		messageBean.setToUserId(userId + "");
		messageBean.setToUserName(toUser.getNickname());
		messageBean.setContent(room.getName());
		messageBean.setMessageId(StringUtil.randomUUID());
		// 群组减员发送通知
		if(1 == room.getIsAttritionNotice()){
			if(KConstants.Room_Role.INVISIBLE != member.getRole() && KConstants.Room_Role.GUARDIAN != member.getRole()){
				// 发送单聊通知被踢出本人、群聊
				sendChatToOneGroupMsg(userId, room.getJid(), messageBean);
			}else{
				sendGroupOne(userId, messageBean);
			}
		}else{
			sendGroupOne(userId, messageBean);
		}
		roomMemberDao.deleteRoomMember(roomId,userId);

		updateUserSize(roomId, -1);
		// 维护用户加入群组的jids
		roomCoreRedisRepository.delJidsByUserId(userId,room.getJid());

		roomCoreRedisRepository.removeRoomPushMember(room.getJid(), userId);
		/**
		 * 维护群组、群成员 缓存
		 */
		updateRoomInfoByRedis(roomId.toString());
		// 更新群组相关设置操作时间
		updateOfflineOperation(user.getUserId(), roomId,String.valueOf(userId));
	}

	/*
	 *907 邀请群成员消息  只发送单聊
	 * */
	public void sendToChatNewMemberMessage(int fromUserId,Room room,Member member){
		// IMPORTANT 1-7、新增成员
		MessageBean messageBean=createNewMemberMessage(fromUserId,room,member);

		// 发送单聊通知到被邀请人
		messageBean.setMsgType(0);
		if(StringUtil.isEmpty(messageBean.getMessageId()))
			messageBean.setMessageId(StringUtil.randomUUID());
		messageService.send(messageBean);

	}


	/**
	 * 发送 907 邀请群成员 进群消息 单聊和群聊
	 */
	public void sendNewMemberMessage(int fromUserId,Room room,Member member){
		MessageBean messageBean=createNewMemberMessage(fromUserId,room,member);

		// 发送单聊通知到被邀请人， 群聊
		sendChatToOneGroupMsg(member.getUserId(), room.getJid(), messageBean);
	}
	private MessageBean createNewMemberMessage(int fromUserId,Room room,Member member){
		// IMPORTANT 1-7、新增成员
		MessageBean messageBean = new MessageBean();
		messageBean.setType(MessageType.NEW_MEMBER);
		// messageBean.setObjectId(roomId.toString());
		messageBean.setObjectId(room.getJid());
		messageBean.setFromUserId(fromUserId+ "");
		messageBean.setFromUserName(userCoreService.getNickName(fromUserId));
		messageBean.setToUserId(member.getUserId()+ "");
		messageBean.setToUserName(member.getNickname());
		messageBean.setFileSize(room.getShowRead());
		messageBean.setContent(room.getName());
		messageBean.setFileName(room.getId().toString());

		JSONObject jsonObject=new JSONObject();
		jsonObject.put("showRead", room.getShowRead());
		jsonObject.put("lsLook", room.getIsLook());
		jsonObject.put("isNeedVerify", room.getIsNeedVerify());
		jsonObject.put("showMember", room.getShowMember());
		jsonObject.put("allowSendCard", room.getAllowSendCard());
		jsonObject.put("maxUserSize", room.getMaxUserSize());
		jsonObject.put("isSecretGroup",room.getIsSecretGroup());
		jsonObject.put("chatKeyGroup",member.getChatKeyGroup());

		messageBean.setOther(jsonObject.toJSONString());
		messageBean.setMessageId(StringUtil.randomUUID());
		return  messageBean;

	}




	@Override
	public void updateMember(User user, ObjectId roomId, List<Integer> userIdList,JSONObject userKeys) {
		Room room = roomCoreDao.getRoomById(roomId);
		Member invitationMember = getMember(roomId, user.getUserId());
		if(null != invitationMember && 4 == invitationMember.getRole())
			throw new ServiceException(KConstants.ResultCode.NotInviteInvisible);
		if(room.getMaxUserSize() <room.getUserSize()+userIdList.size())
			throw new ServiceException(KConstants.ResultCode.RoomMemberAchieveMax) ;
		List<Member> list=new ArrayList<>();
		int i = 0;
		for (int userId : userIdList) {
			i++;
			long currenTimes = DateUtil.currentTimeSeconds();
			currenTimes+=i;
			User _user = userCoreService.getUser(userId);
			if(null==_user) 
				continue;
			Member _member = new Member();
			if(0<findMemberAndRole(roomId, userId)) {
				log.info(" 用户   {}   已经加入群组   ",userId);
				continue;
			}
			
			_member.setUserId(userId);
			_member.setRole(3);
			_member.setActive(currenTimes);
			_member.setCreateTime(currenTimes);
			_member.setModifyTime(0L);
			_member.setNickname(userCoreService.getNickName(userId));
			_member.setRoomId(roomId);
			_member.setSub(1);
			_member.setTalkTime(0L);
			if(userKeys!=null)
				_member.setChatKeyGroup(userKeys.getString(userId+""));
			list.add(_member);
		}

		roomMemberDao.addMemberList(list);
		updateUserSize(roomId, list.size());

		list.stream().forEach(member ->{
				sendNewMemberMessage(user.getUserId(),room,member);
				// 维护用户加入的群jids
			  roomCoreRedisRepository.saveJidsByUserId(member.getUserId(),room.getJid(),roomId);
				if(0==userCoreService.getOnlinestateByUserId(member.getUserId())) {
					roomCoreRedisRepository.addRoomPushMember(room.getJid(),member.getUserId());
				}
			updateOfflineOperation(member.getUserId(), room.getId(),null);
		});
	
	
		/**
		 * 维护群组、群成员缓存
		 */
		updateRoomInfoByRedis(roomId.toString());
		// 更新群组相关设置操作时间
		updateOfflineOperation(user.getUserId(), roomId,StringUtil.getIntegerByList(userIdList, ","));
	}
	
	@Override
	public void updateMember(User user, ObjectId roomId, Member member) {
		Room room = getRoom(roomId);
		if(null != room && room.getS() == -1)
			throw new ServiceException(KConstants.ResultCode.RoomIsLock);
		Member oldMember = getMember(roomId, member.getUserId());
		if(null==oldMember) { 
			throw new ServiceException(KConstants.ResultCode.NotGroupMember);
		}
		User toUser = userCoreService.getUser(member.getUserId());
		
		if(null != roomMemberDao.getMember(roomId,member.getUserId())){
			if (!StringUtil.isEmpty(member.getNickname()) && !oldMember.getNickname().equals(member.getNickname())) {
				// IMPORTANT 1-1、改昵称推送-已改
				MessageBean messageBean = new MessageBean();
				messageBean.setType(MessageType.CHANGE_NICK_NAME);
				messageBean.setObjectId(room.getJid());
				messageBean.setFromUserId(user.getUserId() + "");
				messageBean.setFromUserName(getMemberNickname(roomId, user.getUserId()));
				messageBean.setToUserId(toUser.getUserId() + "");
				messageBean.setToUserName(oldMember.getNickname());
				messageBean.setContent(member.getNickname());
				messageBean.setMessageId(StringUtil.randomUUID());
				// 发送群聊
				sendGroupMsg(room.getJid(), messageBean);
			}
			if (null != member.getTalkTime()) {
				if(oldMember.getRole() == KConstants.Room_Role.INVISIBLE){
					throw new ServiceException(KConstants.ResultCode.NotChatInvisible);
				}
				// IMPORTANT 1-6、禁言
				MessageBean messageBean = new MessageBean();
				messageBean.setType(MessageType.GAG);
				// messageBean.setObjectId(roomId.toString());
				messageBean.setObjectId(room.getJid());
				messageBean.setFromUserId(user.getUserId() + "");
				messageBean.setFromUserName(getMemberNickname(roomId, user.getUserId()));
				messageBean.setToUserId(toUser.getUserId() + "");
				messageBean.setToUserName(oldMember.getNickname());
				messageBean.setContent(member.getTalkTime() + "");
				messageBean.setMessageId(StringUtil.randomUUID());
				// 发送单聊通知被禁言的人,群聊
				sendChatToOneGroupMsg(toUser.getUserId(), room.getJid(), messageBean);
			}
			Map<String,Object> map = new HashMap<>();
			if (!member.getUserId().equals(user.getUserId())&&0!= member.getRole())
				map.put("role", member.getRole());
			if (null != member.getSub())
				map.put("sub", member.getSub());
			if (null != member.getTalkTime())
				map.put("talkTime", member.getTalkTime());
			if (!StringUtil.isEmpty(member.getNickname()))
				map.put("nickname", member.getNickname());
			if (!StringUtil.isEmpty(member.getRemarkName()))
				map.put("remarkName", member.getRemarkName());
			map.put("modifyTime", DateUtil.currentTimeSeconds());
			map.put("call", room.getCall());
			map.put("videoMeetingNo", room.getVideoMeetingNo());
			map.put("role",oldMember.getRole());
			// 更新成员信息
			roomMemberDao.updateRoomMember(roomId,member.getUserId(),map);
		} else {
			Member invitationMember = getMember(roomId, user.getUserId());
			if(null != invitationMember && 4 == invitationMember.getRole())
				throw new ServiceException(KConstants.ResultCode.NotInviteInvisible);
			if(room.getMaxUserSize() < room.getUserSize()+1)
				throw new ServiceException(KConstants.ResultCode.RoomMemberAchieveMax);
			User _user = userCoreService.getUser(member.getUserId());
			Member _member = new Member(roomId,_user.getUserId(),_user.getNickname());
			roomMemberDao.addMember(_member);
			updateUserSize(roomId, 1);

			// 发送单聊通知到被邀请人， 群聊
			sendNewMemberMessage(user.getUserId(),room,_member);

			// 维护用户加入的群jids
			roomCoreRedisRepository.saveJidsByUserId(toUser.getUserId(),room.getJid(),roomId);
			if(0==userCoreService.getOnlinestateByUserId(member.getUserId())) {
				roomCoreRedisRepository.addRoomPushMember(room.getJid(), member.getUserId());
			}
			updateOfflineOperation(_member.getUserId(), room.getId(),null);
		}
		
		/**
		 * 维护群组、群成员缓存
		 */
		updateRoomInfoByRedis(roomId.toString());
		// 更新群组相关设置操作时间
		updateOfflineOperation(user.getUserId(), roomId,null);
	}

	@Override
	public Member getMember(ObjectId roomId, int userId) {
		return roomMemberDao.getMember(roomId,userId);
	}

	public int findMemberAndRole(ObjectId roomId, int userId) {
		Object role = roomMemberDao.findMemberRole(roomId,userId);
		return null!=role?(int)role:-1;
	}
	
	
	
	@Override
	public void Memberset(Integer offlineNoPushMsg, ObjectId roomId,int userId,int type) {
		Map<String,Object> map = new HashMap<>();
		 long currentTime = DateUtil.currentTimeSeconds();
		if(0 == type){
			map.put("offlineNoPushMsg",offlineNoPushMsg);
			String jid = queryRoomJid(roomId);
			if(1==offlineNoPushMsg) {
				roomRedisRepository.addToRoomNOPushJids(userId, jid);
			}else {
				roomRedisRepository.removeToRoomNOPushJids(userId, jid);
			}
		}else if(1 == type){ 
			map.put("openTopChatTime", (offlineNoPushMsg == 0 ? 0 : currentTime));
		}
		map.put("modifyTime", currentTime);
		roomMemberDao.updateRoomMember(roomId,userId,map);
		// 维护群组、群成员相关属性
		updateRoomInfoByRedis(roomId.toString());
		// 多点登录维护数据
		if(userCoreService.isOpenMultipleDevices(userId)){
			String nickName = userCoreService.getNickName(userId);
			multipointLoginUpdateUserInfo(userId, nickName, userId, nickName, roomId);
		}
	}

	@Override
	public List<Member> getMemberList(ObjectId roomId,String keyword) {
		List<Member>list=null;
		if(!StringUtil.isEmpty(keyword)){
			list = roomMemberDao.getMemberListByNickname(roomId,keyword);
		}else{
			List<Member> memberList = roomRedisRepository.getMemberList(roomId.toString());
			if(null != memberList && memberList.size() > 0){
				list = memberList;
			}else{
				List<Member> memberDBList = roomMemberDao.getMemberList(roomId,0,0);
				list = memberDBList;
//				roomRedisRepository.saveMemberList(roomId.toString(), memberDBList);
			}
		}
		return list;
	}
	
	/** @Description:获取群组中的群主和管理员
	* @param roomId
	* @return
	**/ 
	public List<Member> getAdministrationMemberList(ObjectId roomId) {
		List<Member> members = null;
		// 群成员
		List<Member> memberList = roomRedisRepository.getMemberList(roomId.toString());
		if(null != memberList && memberList.size() > 0){
			List<Member> adminMembers = new ArrayList<Member>();// 群组、管理员
			for (Member member : memberList) {
				if(member.getRole() == 1 || member.getRole() == 2){
					adminMembers.add(member);
				}
				members = adminMembers;
			}
		} else{
			//List<Member> membersList = roomMemberDao.getMemberList(roomId,0,0);
			List<Member> memberPageList = roomMemberDao.getMemberListLessThanOrEq(roomId,2,0,0);
			members = memberPageList;
			/**
			 * 维护群成员列表缓存
			 */
//			roomRedisRepository.saveMemberList(roomId.toString(), membersList);
		}
		return members;
	}
	
	/** @Description: 普通群成员userId列表，除了管理员和群主
	* @param roomId
	* @return
	**/ 
	@SuppressWarnings("unchecked")
	public List<Integer> getCommonMemberIdList(ObjectId roomId) {
//		List<Integer> members =distinct("shiku_room_member","userId",new BasicDBObject("roomId", roomId).append("role",3));
		List<Integer> members = roomMemberDao.getMemberUserIdList(roomId,3);
		return members;
	}
	/** @Description: 群成员userId列表
	* @param roomId
	* @return
	**/ 
	@SuppressWarnings("unchecked")
	public List<Integer> getMemberIdList(ObjectId roomId) {
		List<Integer> members = roomMemberDao.getMemberUserIdList(roomId,0);
		return members;
	}
	
	/** @Description: 群成员chatKeyGroup列表
	* @param roomId
	* @return
	**/
	@SuppressWarnings("unchecked")
	public JSONObject getMemberChatKeyGroups(ObjectId roomId) {
		JSONObject chatKeys = new JSONObject();
		List<Member> list = roomMemberDao.getMemberList(roomId,0,0);
		for(Iterator<Member> members = list.iterator();members.hasNext();) {
			Member member = members.next();
			chatKeys.put(member.getUserId()+"", member.getChatKeyGroup());
		}
		return chatKeys;
	}


	@SuppressWarnings("unchecked")
	public List<ObjectId> getRoomIdList(Integer userId) {
		return roomMemberCoreDao.getRoomIdListByUserId(userId);
	}
	
	/**
	 * 查询成员是否开启 免打扰
	 * @param roomId
	 * @param userId
	 * @return
	 */
	public boolean getMemberIsNoPushMsg(ObjectId roomId, int userId) {
		Object field = roomMemberDao.getMemberOneFile(roomId,userId,1);
		return null!=field;
	}
	
	public String getMemberNickname(ObjectId roomId,Integer userId){
		String nickname = null;
		if(roomMemberDao.getMemberList(roomId,0,0).size()==0)
			throw new ServiceException("群组不存在");
		if(0 != userId){
			Member member = roomMemberDao.getMember(roomId,userId);
			if(null == member){
				// 后台管理员
				Role role = roleDao.getUserRoleByUserId(userId);
				if(null != role){
					if(5 == role.getRole() || 6 == role.getRole()){
						if(1 == role.getStatus())
							nickname = "后台管理员";// 后台管理员操作群设置
						else
							throw new ServiceException("该管理员状态异常请重试");
					}
				}else{
					throw new ServiceException("该成员不在该群组中");
				}
			}else {
				nickname = member.getNickname();
			}
		}
		return nickname;
	}
	
	/*公告列表*/
	public List<Notice> getNoticeList(ObjectId roomId){
		List<Notice> notices;
		List<Notice> noticeList = roomRedisRepository.getNoticeList(roomId);
		if(null != noticeList && noticeList.size() > 0)
			notices = noticeList;
		else{
			List<Notice> noticesDB = roomNoticeDao.getNoticList(roomId,0,0);
			notices = noticesDB;
		}
		return notices;
	}
	
	/*公告列表*/
	public PageVO getNoticeList(ObjectId roomId, Integer pageIndex, Integer pageSize){
		
		List<Notice> pageData = roomNoticeDao.getNoticList(roomId,pageIndex,pageSize);
		return new PageVO(pageData, Long.valueOf(pageData.size()), pageIndex, pageSize);
	}

	@Override
	public Notice updateNotice(ObjectId roomId,ObjectId noticeId,String noticeContent,Integer userId){
		Map<String,Object> noticeMap = new HashMap<>();
		noticeMap.put("text",noticeContent);
		noticeMap.put("modifyTime",DateUtil.currentTimeSeconds());
		roomNoticeDao.updateNotic(roomId,noticeId,noticeMap);
		Notice notice = roomNoticeDao.getNotic(noticeId,roomId);
		// 维护最新一条公告
		Room room = getRoom(roomId,userId);
		if(room.getNotice().getId().equals(noticeId)){
			roomRedisRepository.deleteRoom(String.valueOf(roomId));
//			updateAttribute(roomId, "notice", notice);
			Map<String,Object> roomMap = new HashMap<>();
			roomMap.put("notice",notice);
			roomDao.updateRoom(roomId,roomMap);
		}
		roomRedisRepository.deleteNoticeList(roomId);
		ThreadUtils.executeInThread(obj -> {
			MessageBean messageBean = new MessageBean();
			messageBean.setFromUserId(userId + "");
			messageBean.setFromUserName(getMemberNickname(room.getId(), userId));
			messageBean.setType(MessageType.ModifyNotice);
			messageBean.setObjectId(room.getJid());
			messageBean.setContent(noticeContent);
			messageBean.setMessageId(StringUtil.randomUUID());
			// 发送群聊
			sendGroupMsg(room.getJid(), messageBean);
		});
		return notice;
	}
	
	public void deleteNotice(ObjectId roomId, ObjectId noticeId) {
		roomNoticeDao.deleteNotice(roomId,noticeId);
		// 维护room最新公告
		Room room = getRoom(roomId);
		if (null != room.getNotice() && noticeId.equals(room.getNotice().getId())) {
//			updateAttribute(roomId, "notice", new Notice());
			Map<String,Object> map = new HashMap<>();
			map.put("notice",new Notice());
			roomDao.updateRoom(roomId,map);
		}
		/**
		 * 维护群组信息 、公告缓存
		 */
		roomRedisRepository.deleteNoticeList(roomId);
		roomRedisRepository.deleteRoom(roomId.toString());
	}
	
	
	public PageResult<Member> getMemberListByPage(ObjectId roomId, int pageIndex, int pageSize) {
		return roomMemberDao.getMemberListResult(roomId,pageIndex,pageSize);
	}
	

	@Override
	public void join(int userId, ObjectId roomId, int type) {
		Room room = getRoom(roomId);
		if(room != null){
			if(room.getUserSize()+1>room.getMaxUserSize()){
				throw new ServiceException(KConstants.ResultCode.RoomMemberAchieveMax);
			}
		}else{
			throw new ServiceException(KConstants.ResultCode.NotRoom);
		}
		Member member = new Member();
		member.setUserId(userId);
		member.setRole(1 == type ? 1 : 3);
		sweepCode(roomId,userCoreService.getUser(userId), member);
//		updateMember(userCoreService.getUser(userId), roomId, member);
	}
	
	// 扫码加群
	public void sweepCode(ObjectId roomId,User user,Member member){
		Room room = getRoomInfo(roomId,user.getUserId());
		if(null != room && room.getS() == -1)
			throw new ServiceException(KConstants.ResultCode.RoomIsLock);
		int role = findMemberAndRole(roomId, member.getUserId());
		if(-1<role){
			return;
		}
		User toUser = userCoreService.getUser(member.getUserId());

		if(room.getMaxUserSize() < room.getUserSize()+1)
			throw new ServiceException(KConstants.ResultCode.RoomMemberAchieveMax);
		User memberUser = userCoreService.getUser(member.getUserId());
		member.setRoomId(roomId);
		member.setNickname(memberUser.getNickname());
		member.setCreateTime(DateUtil.currentTimeSeconds());

		roomMemberDao.addMember(member);
		updateUserSize(roomId, 1);

		// 发送单聊通知到被邀请人， 群聊
		sendNewMemberMessage(user.getUserId(),room,member);
		// 维护用户加入的群jids
		roomCoreRedisRepository.saveJidsByUserId(member.getUserId(),room.getJid(),roomId);
		if(0==userCoreService.getOnlinestateByUserId(member.getUserId())) {
			roomCoreRedisRepository.addRoomPushMember(room.getJid(), member.getUserId());
		}
		/**
		 * 维护群组、群成员缓存
		 */
		updateRoomInfoByRedis(roomId.toString());
		// 更新群组相关设置操作时间
		updateOfflineOperation(user.getUserId(), roomId,null);
	}
	
	public void joinRoom(Integer userId,String name,ObjectId roomId,long currentTime,Integer adminUserId) {
		Room room = getRoom(roomId,adminUserId);
		if(room == null){
			throw new ServiceException("房间不存在");
		}
		List<Member> memberList=Collections.synchronizedList(new ArrayList<Member>());
		List<MessageBean> messageList=Collections.synchronizedList(new ArrayList<MessageBean>());
		JSONObject jsonObject=new JSONObject();
		jsonObject.put("showRead", room.getShowRead());
		jsonObject.put("lsLook", room.getIsLook());
		jsonObject.put("isNeedVerify", room.getIsNeedVerify());
		jsonObject.put("showMember", room.getShowMember());
		jsonObject.put("allowSendCard", room.getAllowSendCard());
		jsonObject.put("maxUserSize", room.getMaxUserSize());
		Member member = new Member(roomId,userId,name,currentTime);
		memberList.add(member);
		roomMemberDao.addMember(member);
		roomCoreRedisRepository.saveJidsByUserId(member.getUserId(),room.getJid(),roomId);
		MessageBean messageBean = new MessageBean();
		messageBean.setType(MessageType.NEW_MEMBER);
		messageBean.setObjectId(room.getJid());
		messageBean.setFromUserId(userId + "");
		messageBean.setFromUserName(member.getNickname());
		messageBean.setToUserId(userId+"");
		messageBean.setToUserName(member.getNickname());
		messageBean.setFileSize(room.getShowRead());
		messageBean.setContent(room.getName());
		messageBean.setFileName(room.getId().toString());
		messageBean.setOther(jsonObject.toJSONString());
		messageBean.setMessageId(StringUtil.randomUUID());
		messageList.add(messageBean);
		updateUserSize(room.getId(), 1);
		/**
		 * 维护群组、群成员缓存
		 */
		updateRoomInfoByRedis(roomId.toString());
		
		messageService.sendManyMsgToGroupByJid(room.getJid(), messageList);
	}

	public void updateUserSize(ObjectId roomId, int userSize) {
		roomDao.updateRoomUserSize(roomId,userSize);
	}

	public void updateMaxUser(ObjectId roomId, int maxUserSize) {
		Map<String, Object> um = new HashMap<>(1);
		um.put("maxUserSize", maxUserSize);
		roomDao.updateRoom(roomId, um);
	}

	@Override
	public Room exisname(Object roomname,ObjectId roomId) {
		return roomDao.getRoom(roomname.toString(),roomId);
	}

	
	/**
	* @Description: TODO(删除 群共享的文件 和 群聊天消息的文件)
	* @param @param roomId
	* @param @param roomJid    参数
	 */
	public void destroyRoomMsgFileAndShare(ObjectId roomId,String roomJid){
		//删除共享文件 
		List<String> shareList = shareDao.getShareUrlList(roomId);
		for (String url : shareList) {
			try {
				ConstantUtil.deleteFile(url);
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		shareDao.deleteShare(roomId,null);
		List<String> fileList = roomDao.queryRoomHistoryFileType(roomJid);
		for (String url : fileList) {
			try {
				ConstantUtil.deleteFile(url);
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		// 删除群组离线消息记录
		roomDao.dropRoomChatHistory(roomJid);
	}
	

	/**
	* @Description: TODO(群主 通过xmpp 解散群组)
	* @param @param username 群主的userid
	* @param @param password  群主的密码
	* @param @param roomJid     房间jid
	 */
	public void destroyRoomToIM(String username,String password,String roomJid){
		messageRepository.dropRoomChatHistory(roomJid);
	}
	
	/** @Description:（解散群组后删除群组的离线消息） 
	* @param roomJid
	**/ 
	public void dropRoomChatHistory(String roomJid){
		roomDao.dropRoomChatHistory(roomJid);
	}
	//设置/取消管理员
	@Override
	public void setAdmin(ObjectId roomId, int touserId,int type,int userId) {
		Integer status = queryRoomStatus(roomId);
		if(null != status && status == -1)
			throw new ServiceException(KConstants.ResultCode.RoomIsLock);
		Member member = roomMemberDao.getMember(roomId,touserId);
		if(null == member)
			throw new ServiceException(KConstants.ResultCode.MemberNotInGroup);
		Map<String,Object> map = new HashMap<>();
		map.put("role",type);
		roomMemberDao.updateRoomMember(roomId,touserId,map);
		// 更新群组、群成员相关缓存
		updateRoomInfoByRedis(roomId.toString());
		Room room=getRoom(roomId);
		User user = userCoreService.getUser(userId);
		//xmpp推送
		MessageBean messageBean=new MessageBean();
		messageBean.setType(MessageType.SETADMIN);
		if(type==2){//1为设置管理员
			messageBean.setContent(1);
		}else{
			messageBean.setContent(0);
		}
		messageBean.setFromUserId(user.getUserId().toString());
		messageBean.setFromUserName(getMemberNickname(roomId, user.getUserId()));
		messageBean.setToUserName(member.getNickname());
		messageBean.setToUserId(member.getUserId().toString());
		messageBean.setObjectId(room.getJid());
		messageBean.setMessageId(StringUtil.randomUUID());
		// 发送单聊通知被设置的人、群聊
		sendChatToOneGroupMsg(member.getUserId(), room.getJid(), messageBean);
	}

	@Override
	public void setExtRole(ObjectId roomId, int toUserId, int type, int userId, int operate) {
		Integer status = queryRoomStatus(roomId);
		if(null != status && status == -1)
			throw new ServiceException(KConstants.ResultCode.RoomIsLock);
		Member member = roomMemberDao.getMember(roomId, toUserId);
		if(null == member)
			throw new ServiceException(KConstants.ResultCode.MemberNotInGroup);
		Map<String,Object> map = new HashMap<>();
		//取消直接设置为默认值-1，恢复普通extRole身份
		map.put("extRole",1!=operate?-1:type);
		roomMemberDao.updateRoomMember(roomId, toUserId, map);
		// 更新群组、群成员相关缓存
		updateRoomInfoByRedis(roomId.toString());
		Room room=getRoom(roomId);
		User user = userCoreService.getUser(userId);
		//xmpp推送
		MessageBean messageBean=new MessageBean();
		int msgType = 1 == type ? MessageType.SetGod : MessageType.SetTutor;
		messageBean.setType(msgType);
		if(operate==1){//1为新增设置
			messageBean.setContent(1);
		}else{//2为取消
			messageBean.setContent(0);
		}
		messageBean.setFromUserId(user.getUserId().toString());
		messageBean.setFromUserName(getMemberNickname(roomId, user.getUserId()));
		messageBean.setToUserName(member.getNickname());
		messageBean.setToUserId(member.getUserId().toString());
		messageBean.setObjectId(room.getJid());
		messageBean.setMessageId(StringUtil.randomUUID());
		// 发送单聊通知被设置的人、群聊
		sendChatToOneGroupMsg(member.getUserId(), room.getJid(), messageBean);
	}

	public void setInvisibleGuardian(ObjectId roomId, int touserId, int type, int userId) {
		Map<String,Object> map = new HashMap<>();
		Member member = roomMemberDao.getMember(roomId,touserId);
		if(type == -1 || type == 0)
			map.put("role",3);// 1=创建者、2=管理员、3=普通成员、4=隐身人、5=监控人
		else if(type == 4 || type == 5){
			map.put("role",type);
		}
		roomMemberDao.updateRoomMember(roomId,touserId,map);
		/**
		 * 维护群组、群成员相关缓存
		 */
		updateRoomInfoByRedis(roomId.toString());
		Room room=getRoom(roomId);
		//xmpp推送
		MessageBean messageBean=new MessageBean();
		messageBean.setType(MessageType.SetRoomSettingInvisibleGuardian);
		if(type==4){
			messageBean.setContent(1);
		}else if(type==5){
			messageBean.setContent(2);
		}else if(type == -1){
			messageBean.setContent(-1);
		}else if(type == 0){
			messageBean.setContent(0);
		}
		messageBean.setFromUserId(String.valueOf(userId));
		messageBean.setFromUserName(getMemberNickname(roomId, userId));
		messageBean.setToUserName(member.getNickname());
		messageBean.setToUserId(String.valueOf(touserId));
		messageBean.setObjectId(room.getJid());
		messageBean.setMessageId(StringUtil.randomUUID());
		// 发送单聊通知被设置的人、群聊
//		sendChatToOneGroupMsg(q.get().getUserId(), room.getJid(), messageBean);
		sendGroupOne(member.getUserId(), messageBean);
	}
	
	//添加文件（群共享）
	@Override
	public Share Addshare(ObjectId roomId,long size, int type,int userId, String url,String name) {
		User user = userCoreService.getUser(userId);
		Share share=new Share();
		share.setRoomId(roomId);
		share.setTime(DateUtil.currentTimeSeconds());
		share.setNickname(user.getNickname());
		share.setUserId(userId);
		share.setSize(size);
		share.setUrl(url);
		share.setType(type);
		share.setName(name);
		shareDao.addShare(share);
		/**
		 * 维护群文件缓存
		 */
		roomRedisRepository.deleteShareList(roomId);
		Room room=getRoom(roomId);
		//上传文件xmpp推送
		MessageBean messageBean=new MessageBean();
		messageBean.setType(MessageType.FILEUPLOAD);
		messageBean.setContent(share.getShareId().toString());
		messageBean.setFileName(share.getName());
		messageBean.setObjectId(room.getJid());
		messageBean.setFromUserId(user.getUserId().toString());
		messageBean.setFromUserName(getMemberNickname(roomId, user.getUserId()));
		messageBean.setMessageId(StringUtil.randomUUID());
		// 发送群聊通知
		sendGroupMsg(room.getJid(), messageBean);
		return share;
	}
	
	//查询所有
	@SuppressWarnings("deprecation")
	@Override
	public List<Share> findShare(ObjectId roomId, long time, int userId, int pageIndex, int pageSize) {
		if (userId != 0) {
			return shareDao.getShareList(roomId,userId,pageIndex,pageSize);
		}else{
			List<Share> shareList;
			List<Share> redisShareList = roomRedisRepository.getShareList(roomId, pageIndex, pageSize);
			if(null != redisShareList && redisShareList.size() > 0){
				shareList = redisShareList;
			}else{
				roomRedisRepository.saveShareList(roomId,shareDao.getShareList(roomId,0,0,0));
				shareList = shareDao.getShareList(roomId,0,pageIndex,pageSize);
			}
			return shareList;
		}
	}
	
	//删除
	@Override
	public void deleteShare(ObjectId roomId, ObjectId shareId,int userId) {

		User user = userCoreService.getUser(userId);
		Room room=getRoom(roomId);
		Share share = shareDao.getShare(roomId,shareId);
		//删除XMpp推送
		MessageBean messageBean=new MessageBean();
		messageBean.setType(MessageType.DELETEFILE);
		messageBean.setContent(share.getShareId().toString());
		messageBean.setFileName(share.getName());
		messageBean.setObjectId(room.getJid());
		messageBean.setFromUserId(user.getUserId().toString());
		messageBean.setFromUserName(getMemberNickname(roomId, user.getUserId()));
		messageBean.setMessageId(StringUtil.randomUUID());
		// 发送群聊通知
		sendGroupMsg(room.getJid(), messageBean);
		shareDao.deleteShare(roomId,shareId);
		/**
		 * 维护群文件缓存
		 */
		roomRedisRepository.deleteShareList(roomId);
	}
	//获取单个文件
	@Override
	public Share getShare(ObjectId roomId, ObjectId shareId) {
		return shareDao.getShare(roomId,shareId);
	}

	@Override
	public String getCall(ObjectId roomId) {
		Room room = roomCoreDao.getRoomById(roomId);
		return room.getCall();
	}

	@Override
	public String getVideoMeetingNo(ObjectId roomId) {
		Room room = roomCoreDao.getRoomById(roomId);
		return room.getVideoMeetingNo();
	}
	
	/**
	 * 发送消息 到群组中
	 * @param jidArr
	 * @param userId
	 * @param msgType
	 * @param content
	 */
	public void sendMsgToRooms(String[] jidArr, int userId,int msgType,String content) {
		User user = userCoreService.getUser(userId);
		MessageBean messageBean=new MessageBean();
		messageBean.setFromUserId(userId+"");
		messageBean.setFromUserName(user.getNickname());
		messageBean.setType(msgType);
		messageBean.setContent(content);
		messageBean.setMessageId(StringUtil.randomUUID());
		for (String jid : jidArr) {
			messageBean.setToUserId(jid);
			messageBean.setToUserName(getRoomName(jid));
//			messageBean.setObjectId(jid);
			messageService.sendMsgToMucRoom(messageBean, jid);
		}
	}
	
	/**
	 * 获取房间总数量
	 */
	@Override
    public Long countRoomNum(){
    	long roomNum = roomDao.getAllRoomNums();
		return roomNum;
    }
	
	
	/**
	 * 添加群组统计      时间单位每日，最好可选择：每日、每月、每分钟、每小时
	 * @param startDate
	 * @param endDate
	 * @param counType  统计类型   1: 每个月的数据      2:每天的数据       3.每小时数据   4.每分钟的数据 (小时)   
	 */
	public List<Object> addRoomsCount(String startDate, String endDate, short counType){
		
		List<Object> countData = new ArrayList<>();
		
		long startTime = 0; //开始时间（秒）
		
		long endTime = 0; //结束时间（秒）,默认为当前时间
		
		/**
		 * 如时间单位为月和天，默认开始时间为当前时间的一年前 ; 时间单位为小时，默认开始时间为当前时间的一个月前;
		 * 时间单位为分钟，则默认开始时间为当前这一天的0点
		 */
		long defStartTime = counType==4? DateUtil.getTodayMorning().getTime()/1000 
				: counType==3 ? DateUtil.getLastMonth().getTime()/1000 : DateUtil.getLastYear().getTime()/1000;
		
		startTime = StringUtil.isEmpty(startDate) ? defStartTime :DateUtil.toDate(startDate).getTime()/1000;
		endTime = StringUtil.isEmpty(endDate) ? DateUtil.currentTimeSeconds() : DateUtil.toDate(endDate).getTime()/1000;
				
//		BasicDBObject queryTime = new BasicDBObject("$ne",null);
//
//		if(startTime!=0 && endTime!=0){
//			queryTime.append("$gt", startTime);
//			queryTime.append("$lt", endTime);
//		}
		
//		BasicDBObject query = new BasicDBObject("createTime",queryTime);
//
//		//获得用户集合对象
//		DBCollection collection = SKBeanUtils.getImRoomDatastore().getCollection(getEntityClass());
		
		String mapStr = "function Map() { "   
	            + "var date = new Date(this.createTime*1000);" 
				+  "var year = date.getFullYear();"
				+  "var month = (\"0\" + (date.getMonth()+1)).slice(-2);"  //month 从0开始，此处要加1
				+  "var day = (\"0\" + date.getDate()).slice(-2);"
				+  "var hour = (\"0\" + date.getHours()).slice(-2);"
				+  "var minute = (\"0\" + date.getMinutes()).slice(-2);"
				+  "var dateStr = date.getFullYear()"+"+'-'+"+"(parseInt(date.getMonth())+1)"+"+'-'+"+"date.getDate();";
				
				if(counType==1){ // counType=1: 每个月的数据
					mapStr += "var key= year + '-'+ month;";
				}else if(counType==2){ // counType=2:每天的数据
					mapStr += "var key= year + '-'+ month + '-' + day;";
				}else if(counType==3){ //counType=3 :每小时数据
					mapStr += "var key= year + '-'+ month + '-' + day + '  ' + hour +' : 00';";
				}else if(counType==4){ //counType=4 :每分钟的数据
					mapStr += "var key= year + '-'+ month + '-' + day + '  ' + hour + ':'+ minute;";
				}
	           
				mapStr += "emit(key,1);}";
		
		 String reduce = "function Reduce(key, values) {" +
			                "return Array.sum(values);" +
	                    "}";
//		 MapReduceCommand.OutputType type =  MapReduceCommand.OutputType.INLINE;
//		 MapReduceCommand command = new MapReduceCommand(collection, mapStr, reduce,null, type,query);
		 

//		 MapReduceOutput mapReduceOutput = collection.mapReduce(command);
//		 Iterable<DBObject> results = mapReduceOutput.results();
//		 Map<String,Double> map = new HashMap<String,Double>();
//		for (Iterator iterator = results.iterator(); iterator.hasNext();) {
//			DBObject obj = (DBObject) iterator.next();
//
//			map.put((String)obj.get("_id"),(Double)obj.get("value"));
//			countData.add(JSON.toJSON(map));
//			map.clear();
//			//System.out.println(JSON.toJSON(obj));
//
//		}
		countData = roomDao.getAddRoomsCount(startTime,endTime,mapStr,reduce);
		return countData;
	}
	

	

	/** @Description: 
	* @param user
	* @param roomId
	* @param userIdList
	**/ 
	public void consoleJoinRoom(User user, ObjectId roomId, List<Integer> userIdList, boolean isMerge){
		try {
			int i = 0;
			Room room = getRoom(roomId);
			int afterSize = room.getUserSize() + userIdList.size();
			if (isMerge && afterSize >= room.getMaxUserSize()) {
				updateMaxUser(roomId, afterSize + 100);
			}
			for (Integer userId : userIdList) {
				long currentTime = DateUtil.currentTimeSeconds();
				i++;
				currentTime += i;
				Member data = getMember(roomId, userId);
				if (null != data) {
					log.info(userId + " 该成员已经在群组中,不能重复邀请");
					continue;
				}
				Member member = new Member();
				member.setActive(currentTime);
				member.setCreateTime(currentTime);
				member.setModifyTime(0L);
				member.setNickname(userCoreService.getNickName(userId));
				member.setRole(3);
				member.setRoomId(roomId);
				member.setSub(1);
				member.setTalkTime(0L);
				member.setUserId(userId);
				roomMemberDao.addMember(member);

				// 群组人数
				updateUserSize(roomId, 1);

				// 发送单聊通知到被邀请人， 群聊
				sendNewMemberMessage(user.getUserId(), room, member);


				// 维护用户加入的群jids
				roomCoreRedisRepository.saveJidsByUserId(userId, room.getJid(), roomId);

				if (0 == userCoreService.getOnlinestateByUserId(member.getUserId())) {
					roomCoreRedisRepository.addRoomPushMember(room.getJid(), member.getUserId());
				}
			}
		} catch (Exception e) {
			log.error("管理后台操作邀请入群异常", e);
			throw e;
		} finally {
			// 维护群组数据
			roomRedisRepository.deleteRoom(String.valueOf(roomId));
			roomRedisRepository.deleteMemberList(roomId.toString());
		}
	}
	
	// 面对面创群
	public Room queryLocationRoom(String name,double longitude,double latitude,String password,
			int isQuery){
		Integer userId = ReqUtil.getUserId();
		Room  room=roomRedisRepository.
				queryLocationRoom(userId, longitude, latitude, password, name);
		if(1==isQuery)
			return room;
		ThreadUtils.executeInThread(obj -> {
			for (Member mem : room.getMembers()) {
				if(userId.equals(mem.getUserId()))
					continue;
				MessageBean messageBean = new MessageBean();
				messageBean.setObjectId(room.getJid());
				messageBean.setFromUserId(userId.toString());
				messageBean.setFromUserName(userId.toString());
				messageBean.setType(MessageType.LocationRoom);
				messageBean.setToUserId(mem.getUserId().toString());
				messageService.send(messageBean);
			}
		});
		return room;
	}
	
	public synchronized Room joinLocationRoom(String roomJid) {
		ObjectId roomId = getRoomId(roomJid);
		Integer userId = ReqUtil.getUserId();
		User user=null;
		if(null==roomId) {
			Room room = roomRedisRepository.queryLocationRoom(roomJid);
			if(null==room)
				throw new ServiceException(KConstants.ResultCode.RoomTimeOut);
			user=userCoreService.getUser(userId);
			messageService.createMucRoomToIMServer(roomJid,user.getPassword(),userId.toString(), room.getName());
			roomId=new ObjectId();
			room.setId(roomId);
			add(user, room, null,null);
		
			roomRedisRepository.saveLocationRoom(roomJid,room);
		}else {
			user=userCoreService.getUser(userId);
			Member member=new Member();
			member.setUserId(userId);
			sweepCode(roomId, user, member);
		}
		return roomCoreDao.getRoomById(roomId);
	}
	public void exitLocationRoom(String roomJid) {
		Integer userId = ReqUtil.getUserId();
		roomRedisRepository.exitLocationRoom(userId, roomJid);
		ThreadUtils.executeInThread((Callback) obj -> {
			Room room = roomRedisRepository.queryLocationRoom(roomJid);
			for (Member mem : room.getMembers()) {
				if(userId.equals(mem.getUserId()))
					continue;
				MessageBean messageBean = new MessageBean();
				messageBean.setObjectId(room.getJid());
				messageBean.setFromUserId(userId.toString());
				messageBean.setFromUserName(userId.toString());
				messageBean.setType(MessageType.LocationRoom);
				messageBean.setToUserId(mem.getUserId().toString());
				messageService.send(messageBean);
			}
		});
	}

	
	/** @Description:多点登录下修改群组相关信息
	* @param userId
	* @param nickName
	* @param toUserId
	* @param toNickName
	* @param roomId
	**/ 
	public void multipointLoginUpdateUserInfo(Integer userId,String nickName,Integer toUserId,String toNickName,ObjectId roomId){
		updateRoomInfo(userId, nickName,toUserId,toNickName,roomId);
		OfflineOperation getOfflineOperation =  offlineOperationDao.queryOfflineOperation(userId,null,String.valueOf(roomId));
		if(null == getOfflineOperation)
			offlineOperationDao.addOfflineOperation(userId,KConstants.MultipointLogin.TAG_ROOM,String.valueOf(roomId),DateUtil.currentTimeSeconds());
		else{

			OfflineOperation offlineOperation = new OfflineOperation();
			offlineOperation.setOperationTime(DateUtil.currentTimeSeconds());
			offlineOperationDao.updateOfflineOperation(userId,String.valueOf(roomId),offlineOperation);
		}
	}
	
	/** @Description:多点登录下修改群组相关信息通知
	* @param userId
	* @param nickName
	**/ 
	public void updateRoomInfo(Integer userId,String nickName,Integer toUserId,String toNickName,ObjectId roomId){
		ThreadUtils.executeInThread((Callback) obj -> {
				MessageBean messageBean=new MessageBean();
				messageBean.setType(MessageType.updateRoomInfo);
				messageBean.setFromUserId(String.valueOf(userId));
				messageBean.setFromUserName(nickName);
				messageBean.setToUserId(String.valueOf(roomId));
				messageBean.setToUserName(getRoomName(roomId));
				messageBean.setMessageId(StringUtil.randomUUID());
				messageBean.setTo(String.valueOf(userId));
				try {
					messageService.send(messageBean);
				} catch (Exception e) {
					e.printStackTrace();
				}
		});
	}
	
	public Room copyRoom(User user,String roomId){
		ObjectId objRoomId = new ObjectId(roomId);
		Room room = getRoom(objRoomId);
		
		List<Integer> memberIdList = getMemberIdList(objRoomId);
		memberIdList.remove(user.getUserId());
		room.setId(new ObjectId());
		String jid = com.shiku.utils.StringUtil.randomUUID();
		room.setJid(jid);
		messageService.createMucRoomToIMServer(jid,user.getPassword(), user.getUserId().toString(),
				room.getName());
		Room newRoom = add(user, room, memberIdList,getMemberChatKeyGroups(objRoomId));
		return newRoom;
	}


	@Override
	public void deleteRedisRoom(String roomId){
		roomRedisRepository.deleteRoom(roomId);
	};

	@EventListener
	public void handlerUserChageNameEvent(UserChageNameEvent event){
		log.info(" room handlerUserChageNameEvent {}",event.getUserId());
		//修改群组中的创建人名称//修改nickname
		roomDao.updateAttribute("userId",event.getUserId(),"nickname",event.getNickName());
		roomMemberDao.updateRoomMemberAttribute(null, event.getUserId(), "nickname",event.getNickName());

	}

	@EventListener
	public void handlerDeleteUserEvent(DeleteUserEvent event){
		log.info(" room handlerDeleteUserEvent {}",event.getUserId());
		// 退出用户加入的群聊、解散创建的群组
        try {
            List<ObjectId> roomIdList = getRoomIdList(event.getUserId());
            User user = userCoreService.getUser(event.getAdminUserId());
            roomIdList.forEach(roomId -> {
                deleteMember(user, roomId,event.getUserId(),true);
            });
        } catch (Exception e) {
            log.error(e.getMessage(),e);
        }

    }
}
