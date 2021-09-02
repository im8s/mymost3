package com.shiku.im.friends.service.impl;

import com.alibaba.fastjson.JSONObject;
import com.shiku.common.model.PageResult;
import com.shiku.common.model.PageVO;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.comm.utils.DateUtil;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.friends.dao.FriendsDao;
import com.shiku.im.friends.entity.Friends;
import com.shiku.im.friends.entity.NewFriends;
import com.shiku.im.friends.service.FriendsManager;
import com.shiku.im.friends.service.FriendsRedisRepository;
import com.shiku.im.message.IMessageRepository;
import com.shiku.im.message.MessageService;
import com.shiku.im.message.MessageType;
import com.shiku.im.support.Callback;
import com.shiku.im.user.dao.OfflineOperationDao;
import com.shiku.im.user.entity.AuthKeys;
import com.shiku.im.user.entity.OfflineOperation;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.event.UserChageNameEvent;
import com.shiku.im.user.service.AuthKeysService;
import com.shiku.im.user.service.RoleCoreService;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.MapUtil;
import org.bson.Document;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class FriendsManagerImpl implements FriendsManager {

	private static final String groupCode = "110";

	private static Logger Log = LoggerFactory.getLogger(FriendsManager.class);
	@Lazy
	@Autowired
	private FriendsDao friendsDao;
	public FriendsDao getFriendsDao(){
		return friendsDao;
	}
	@Autowired
	private OfflineOperationDao offlineOperationDao;

	@Autowired
	private AuthKeysService authKeysService;

	@Autowired
	private AddressBookManagerImpl addressBookManager;

	@Autowired
	private FriendGroupManagerImpl friendGroupManager;

	@Autowired
	private FriendsRedisRepository firendsRedisRepository;

	@Autowired
	@Lazy
	private MessageService messageService;

	@Autowired(required = false)
	private IMessageRepository messageRepository;

	@Autowired
	private RoleCoreService roleCoreService;

	@Autowired
	private UserCoreService userManager;

	public FriendsRedisRepository getFirendsRedisRepository() {
		return firendsRedisRepository;
	}
	

	private  UserCoreService getUserManager(){
		return userManager;
	};
	
	@Override
	public Friends addBlacklist(Integer userId, Integer toUserId) {
		// 是否存在AB关系
		Friends friendsAB = getFriendsDao().getFriends(userId, toUserId);
		Friends friendsBA= getFriendsDao().getFriends(toUserId, userId);

		if (null == friendsAB) {
			Friends friends = new Friends(userId, toUserId,getUserManager().getNickName(toUserId), Friends.Status.Stranger, Friends.Blacklist.Yes,0);
			getFriendsDao().saveFriends(friends);
		}else {
			// 更新关系
			getFriendsDao().updateFriends(new Friends(userId, toUserId,null, -1, Friends.Blacklist.Yes,(0 == friendsAB.getIsBeenBlack())?0:friendsAB.getIsBeenBlack()));
			if(null==friendsBA){
				Friends friends = new Friends(toUserId, userId,getUserManager().getNickName(userId), Friends.Status.Stranger, Friends.Blacklist.No,1);
				getFriendsDao().saveFriends(friends);
			}else {
				getFriendsDao().updateFriends(new Friends(toUserId, userId,null, null, (0 == friendsBA.getBlacklist()?Friends.Blacklist.No:friendsBA.getBlacklist()),1));
			}

		}
		messageRepository.deleteLastMsg(userId.toString(), toUserId.toString());
		//messageRepository.deleteLastMsg(toUserId.toString(),userId.toString());

		/**
		 * 维护好友标签数据
		 */
		friendGroupManager.deleteFriendToFriendGroup(userId,toUserId);

		// 维护好友数据
		deleteFriendsInfo(userId, toUserId);
		// 更新好友设置操作时间
		updateOfflineOperation(userId, toUserId);
		return getFriendsDao().getFriends(userId, toUserId);
	}

	/** @Description: 维护用户通讯录好友缓存 
	* @param userId
	* @param toUserId
	**/ 
	private void deleteAddressFriendsInfo(Integer userId,Integer toUserId){
		// 通讯录好友id
		firendsRedisRepository.delAddressBookFriendsUserIds(userId);
		firendsRedisRepository.delAddressBookFriendsUserIds(toUserId);
		deleteFriendsInfo(userId, toUserId);
	}

	/** @Description: 维护用户好友缓存
	* @param userId
	* @param toUserId
	**/ 
	public void deleteFriendsInfo(Integer userId,Integer toUserId){
		// 好友userIdsList
		firendsRedisRepository.deleteFriendsUserIdsList(userId);
		firendsRedisRepository.deleteFriendsUserIdsList(toUserId);
		// 好友列表
		firendsRedisRepository.deleteFriends(userId);
		firendsRedisRepository.deleteFriends(toUserId);
	}
	
	// 后台加入黑名单（后台可以互相拉黑）
	public Friends consoleAddBlacklist(Integer userId, Integer toUserId,Integer adminUserId) {
		// 是否存在AB关系
		Friends friendsAB = getFriendsDao().getFriends(userId, toUserId);
		Friends friendsBA= getFriendsDao().getFriends(toUserId, userId);
		if (null == friendsAB) {
			Friends friends = new Friends(userId, toUserId,getUserManager().getNickName(toUserId), Friends.Status.Stranger, Friends.Blacklist.Yes,0);
			getFriendsDao().saveFriends(friends);
		} else {
			// 更新关系
			getFriendsDao().updateFriends(new Friends(userId, toUserId,null, -1, Friends.Blacklist.Yes,(0 == friendsAB.getIsBeenBlack())?0:friendsAB.getIsBeenBlack()));
			getFriendsDao().updateFriends(new Friends(toUserId, userId,null, null, (0 == friendsBA.getBlacklist()?Friends.Blacklist.No:friendsBA.getBlacklist()),1));
		}
		messageRepository.deleteLastMsg(userId.toString(), toUserId.toString());
		ThreadUtils.executeInThread(new Callback() {
			
			@Override
			public void execute(Object obj) {

				//xmpp推送消息
				MessageBean messageBean=new MessageBean();
				messageBean.setType(MessageType.joinBlacklist);
				messageBean.setFromUserId(adminUserId+"");
				messageBean.setFromUserName("后台系统管理员");
				MessageBean beanVo = new MessageBean();
				beanVo.setFromUserId(userId+"");
				beanVo.setFromUserName(getUserManager().getNickName(userId));
				beanVo.setToUserId(toUserId+"");
				beanVo.setToUserName(getUserManager().getNickName(toUserId));
				messageBean.setObjectId(JSONObject.toJSONString(beanVo));
				messageBean.setMessageId(StringUtil.randomUUID());
				try {
					List<Integer> userIdlist = new ArrayList<Integer>();
					userIdlist.add(userId);
					userIdlist.add(toUserId);
					messageService.send(messageBean,userIdlist);
				} catch (Exception e) {
				}
			
			}
		});
		// 维护好友数据
		deleteFriendsInfo(userId, toUserId);
		// 更新好友设置操作时间
		updateOfflineOperation(userId, toUserId);
		return getFriendsDao().getFriends(userId, toUserId);
	}
	
	
	
	
	public Friends updateFriends(Friends friends){
		return getFriendsDao().updateFriends(friends);
	}
	
	public boolean isBlack(Integer toUserId) {
		Friends friends = getFriends(ReqUtil.getUserId(), toUserId);
		if (friends == null)
			return false;
		return friends.getStatus() == -1 ? true : false;
	}
	
	public boolean isBlack(Integer userId,Integer toUserId) {
		Friends friends = getFriends(userId, toUserId);
		if (friends == null)
			return false;
		return friends.getStatus() == -1 ? true : false;
	}

	private void saveFansCount(int userId) {
		/*BasicDBObject q = new BasicDBObject("_id", userId);
		DBCollection dbCollection = SKBeanUtils.getTigaseDatastore().getDB().getCollection("shiku_msgs_count");
		if (0 == dbCollection.count(q)) {
			BasicDBObject jo = new BasicDBObject("_id", userId);
			jo.put("count", 0);// 消息数
			jo.put("fansCount", 1);// 粉丝数
			dbCollection.insert(jo);
		} else {
			dbCollection.update(q, new BasicDBObject("$inc", new BasicDBObject("fansCount", 1)));
		}*/
	}

	@Override
	public boolean addFriends(Integer userId, Integer toUserId) {

		int toUserType = 0;
		List<Integer> toUserRoles = roleCoreService.getUserRoles(toUserId);
		if (toUserRoles.size() > 0 && null != toUserRoles) {
			if (toUserRoles.contains(2))
				toUserType = 2;
		}
		int userType = 0;
		List<Integer> userRoles = roleCoreService.getUserRoles(userId);
		if (userRoles.size() > 0 && null != userRoles) {
			if (userRoles.contains(2))
				userType = 2;
		}
		Friends friends = getFriends(userId, toUserId);
		if (null == friends) {
			getFriendsDao().saveFriends(new Friends(userId, toUserId, getUserManager().getNickName(toUserId),
					Friends.Status.Friends, 0, 0, toUserRoles, toUserType, 4));
			saveFansCount(toUserId);
		} else {
			saveFansCount(toUserId);
//			
			Map<String,Object> map = new HashMap<>();
			map.put("modifyTime", DateUtil.currentTimeSeconds());
			map.put("status", Friends.Status.Friends);
			map.put("toUserType", toUserType);
			map.put("toFriendsRole", toUserRoles);
			friendsDao.updateFriends(userId,toUserId,map);
		}
		Friends toFriends = getFriends(toUserId, userId);
		if (null == toFriends) {
			getFriendsDao().saveFriends(new Friends(toUserId, userId, getUserManager().getNickName(userId),
					Friends.Status.Friends, 0, 0, userRoles, userType, 4));
			saveFansCount(toUserId);
		} else {
			saveFansCount(toUserId);
//			
			Map<String,Object> map = new HashMap<>();
			map.put("modifyTime", DateUtil.currentTimeSeconds());
			map.put("status", Friends.Status.Friends);
			map.put("toUserType", userType);
			map.put("toFriendsRole", userRoles);
			friendsDao.updateFriends(toUserId,userId,map);
		}
		// 更新好友设置操作时间
		updateOfflineOperation(userId, toUserId);
		// 维护好友数据
		deleteFriendsInfo(userId, toUserId);
		return true;
	}
	
	@Override
	public Friends deleteBlacklist(Integer userId, Integer toUserId) {
		// 是否存在AB关系
		Friends friendsAB = getFriendsDao().getFriends(userId, toUserId);
		Friends friendsBA = getFriendsDao().getFriends(toUserId, userId);

		if (null == friendsAB) {
			// 无记录
		} else {
			// 陌生人黑名单
			if (Friends.Blacklist.Yes == friendsAB.getBlacklist() && Friends.Status.Stranger == friendsAB.getStatus()) {
				// 物理删除
				getFriendsDao().deleteFriends(userId, toUserId);
			} else {
				// 恢复关系
				getFriendsDao().updateFriends(new Friends(userId, toUserId,null, 2, Friends.Blacklist.No,(0 == friendsAB.getIsBeenBlack()?0:friendsAB.getIsBeenBlack())));
				if(null!=friendsBA){
					getFriendsDao().updateFriends(new Friends(toUserId, userId,null, (2 == friendsBA.getStatus()?2:friendsBA.getStatus()), (0 == friendsBA.getBlacklist()?Friends.Blacklist.No:friendsBA.getBlacklist()),0));
				}

			}
			// 是否存在AB关系
			friendsAB = getFriendsDao().getFriends(userId, toUserId);
			// 维护好友数据
			deleteFriendsInfo(userId, toUserId);
			// 更新好友设置操作时间
			updateOfflineOperation(userId, toUserId);
		}
		
		return friendsAB;
	}

	/** @Description:（后台移除黑名单） 
	* @param userId
	* @param toUserId
	* @return
	**/ 
	public Friends consoleDeleteBlacklist(Integer userId, Integer toUserId, Integer adminUserId) {
		// 是否存在AB关系
		Friends friendsAB = getFriendsDao().getFriends(userId, toUserId);
		Friends friendsBA = getFriendsDao().getFriends(toUserId, userId);

		if (null == friendsAB) {
			// 无记录
		} else {
			// 陌生人黑名单
			if (Friends.Blacklist.Yes == friendsAB.getBlacklist() && Friends.Status.Stranger == friendsAB.getStatus()) {
				// 物理删除
				getFriendsDao().deleteFriends(userId, toUserId);
			} else {
				// 恢复关系
				getFriendsDao().updateFriends(new Friends(userId, toUserId,null, 2, Friends.Blacklist.No,(0 == friendsAB.getIsBeenBlack()?0:friendsAB.getIsBeenBlack())));
				getFriendsDao().updateFriends(new Friends(toUserId, userId,null, (2 == friendsBA.getStatus()?2:friendsBA.getStatus()), (0 == friendsBA.getBlacklist()?Friends.Blacklist.No:friendsBA.getBlacklist()),0));
			}
			// 是否存在AB关系
			friendsAB = getFriendsDao().getFriends(userId, toUserId);
		}
		
		ThreadUtils.executeInThread(new Callback() {
			
			@Override
			public void execute(Object obj) {

				//xmpp推送消息
				MessageBean messageBean=new MessageBean();
				messageBean.setType(MessageType.moveBlacklist);
				messageBean.setFromUserId(adminUserId+"");
				messageBean.setFromUserName("后台系统管理员");
				MessageBean beanVo = new MessageBean();
				beanVo.setFromUserId(userId+"");
				beanVo.setFromUserName(getUserManager().getNickName(userId));
				beanVo.setToUserId(toUserId+"");
				beanVo.setToUserName(getUserManager().getNickName(toUserId));
				messageBean.setObjectId(JSONObject.toJSONString(beanVo));
				messageBean.setMessageId(StringUtil.randomUUID());
				try {
					List<Integer> userIdlist = new ArrayList<Integer>();
					userIdlist.add(userId);
					userIdlist.add(toUserId);
					messageService.send(messageBean,userIdlist);
				} catch (Exception e) {
				}
			
			
			}
		});
		// 维护好友数据
		deleteFriendsInfo(userId, toUserId);
		return friendsAB;
	}
	
	@Override
	public boolean deleteFriends(Integer userId, Integer toUserId) {
		getFriendsDao().deleteFriends(userId, toUserId);
		getFriendsDao().deleteFriends(toUserId, userId);
		messageRepository.deleteLastMsg(userId.toString(), toUserId.toString());
		messageRepository.deleteLastMsg(toUserId.toString(),userId.toString());
		// 删除好友间消息记录
		messageRepository.delFriendsChatMsg(userId,toUserId);
		messageRepository.delFriendsChatMsg(toUserId,userId);

		// 维护通讯录好友
		addressBookManager.deleteAddressBook(userId, toUserId);
		addressBookManager.deleteAddressBook(toUserId, userId);


		/**
		 * 维护好友标签数据
		 */
		friendGroupManager.deleteFriendToFriendGroup(userId,toUserId);
		// 维护好友数据
		deleteFriendsInfo(userId, toUserId);
		// 更新好友设置操作时间
		updateOfflineOperation(userId, toUserId);

		return true;
	}
	
	/** @Description:（后台删除好友-xmpp发通知） 
	* @return
	**/
	public boolean consoleDeleteFriends(Integer userId, Integer adminUserId, String... toUserIds) {
		for(String strtoUserId : toUserIds){
			Integer toUserId = Integer.valueOf(strtoUserId);

			getFriendsDao().deleteFriends(userId, toUserId);
			getFriendsDao().deleteFriends(toUserId, userId);

			messageRepository.deleteLastMsg(userId.toString(), toUserId.toString());
			messageRepository.deleteLastMsg(toUserId.toString(),userId.toString());

			ThreadUtils.executeInThread(new Callback() {
				
				@Override
				public void execute(Object obj) {
					//以系统号发送删除好友通知
					MessageBean messageBean=new MessageBean();
					messageBean.setType(MessageType.deleteFriends);
					messageBean.setFromUserId(adminUserId+"");
					messageBean.setFromUserName("后台系统管理员");
					MessageBean beanVo = new MessageBean();
					beanVo.setFromUserId(userId+"");
					beanVo.setFromUserName(getUserManager().getNickName(userId));
					beanVo.setToUserId(toUserId+"");
					beanVo.setToUserName(getUserManager().getNickName(toUserId));
					messageBean.setObjectId(JSONObject.toJSONString(beanVo));
					messageBean.setMessageId(StringUtil.randomUUID());
					messageBean.setContent("系统解除了你们好友关系");
					messageBean.setMessageId(StringUtil.randomUUID());
					try {
						List<Integer> userIdlist = new ArrayList<Integer>();
						userIdlist.add(userId);
						userIdlist.add(toUserId);
						messageService.send(messageBean,userIdlist);
					} catch (Exception e) {
					}
					// 维护好友缓存
					deleteFriendsInfo(userId, toUserId);
				}
			});
		}		
		return true;
	}
	

	@SuppressWarnings("unused")
	@Override
	public JSONMessage followUser(Integer userId, Integer toUserId, Integer fromAddType) {
		final String serviceCode = "08";
		JSONMessage jMessage = null;
		User toUser = getUserManager().getUser(toUserId);
		int toUserType = 0;
		List<Integer> toUserRoles = roleCoreService.getUserRoles(toUserId);
		if(toUserRoles.size()>0 && null != toUserRoles){
			if(toUserRoles.contains(2))
				toUserType = 2;
			else
				return JSONMessage.failureByErrCode(KConstants.ResultCode.ProhibitAddFriends);
		}
		//好友不存在
		if(null==toUser){
			if(10000==toUserId)
				return null;
			else
				return JSONMessage.failureByErrCode(KConstants.ResultCode.UserNotExist);
				
		}
			
		try {
			User user = getUserManager().getUser(userId);
			int userType = 0;
			List<Integer> userRoles = roleCoreService.getUserRoles(userId);
			if(userRoles.size()>0 && null != userRoles){
				if(userRoles.contains(2))
					userType = 2;
			}

			// 是否存在AB关系
			Friends friendsAB = getFriendsDao().getFriends(userId, toUserId);
			// 是否存在BA关系
			Friends friendsBA = getFriendsDao().getFriends(toUserId, userId);
			// 获取目标用户设置
			User.UserSettings userSettingsB = getUserManager().getSettings(toUserId);

			// ----------------------------
			// 0 0 0 0 无记录 执行关注逻辑
			// A B 1 0 非正常 执行关注逻辑
			// A B 1 1 拉黑陌生人 执行关注逻辑
			// A B 2 0 关注 重复关注
			// A B 3 0 好友 重复关注
			// A B 2 1 拉黑关注 恢复关系
			// A B 3 1 拉黑好友 恢复关系
			// ----------------------------
			// 无AB关系或陌生人黑名单关系，加关注
			if(null != friendsAB&&friendsAB.getIsBeenBlack()==1){
				return jMessage = JSONMessage.failureByErrCode(KConstants.ResultCode.AddFriendsFailure);
			}
			if (null == friendsAB || Friends.Status.Stranger == friendsAB.getStatus()) {
				// 目标用户拒绝关注
				if (0 == userSettingsB.getAllowAtt()) {
					jMessage = new JSONMessage(groupCode, serviceCode, "01", "关注失败，目标用户拒绝关注");
				}
				// 目标用户允许关注
				else {
					int statusA = 0;

					// 目标用户加好需验证，执行加关注。过滤公众号开启好友验证
					if (1 == userSettingsB.getFriendsVerify() && 2 != toUserType) {
						// ----------------------------
						// 0 0 0 0 无记录 执行单向关注
						// B A 1 0 非正常 执行单向关注
						// B A 1 1 拉黑陌生人 执行单向关注
						// B A 2 0 关注 加好友
						// B A 3 0 好友 加好友
						// B A 2 1 拉黑关注 加好友
						// B A 3 1 拉黑好友 加好友
						// ----------------------------
						// 无BA关系或陌生人黑名单关系，单向关注
						if (null == friendsBA || Friends.Status.Stranger == friendsBA.getStatus()) {
							statusA = Friends.Status.Attention;
						} else {
							statusA = Friends.Status.Friends;

							getFriendsDao()
									.updateFriends(new Friends(toUserId, user.getUserId(),user.getNickname(), Friends.Status.Friends));
						}
					}
					// 目标用户加好友无需验证，执行加好友
					else {
						statusA = Friends.Status.Friends;

						if (null == friendsBA) {
							getFriendsDao().saveFriends(new Friends(toUserId, user.getUserId(),user.getNickname(),
									Friends.Status.Friends, Friends.Blacklist.No,0,userRoles,userType,fromAddType));

							saveFansCount(toUserId);
						} else
							getFriendsDao()
									.updateFriends(new Friends(toUserId, user.getUserId(),user.getNickname(), Friends.Status.Friends,userType,userRoles));//改变usertype
					}

					if (null == friendsAB) {
						getFriendsDao().saveFriends(new Friends(userId, toUserId,toUser.getNickname(), statusA, Friends.Blacklist.No,0,toUserRoles,toUserType,fromAddType));
						saveFansCount(toUserId);
					} else {
						getFriendsDao().updateFriends(new Friends(userId, toUserId,toUser.getNickname(), statusA, Friends.Blacklist.No,0));
					}

					if (statusA == Friends.Status.Attention) {
						HashMap<String, Object> newMap = MapUtil.newMap("type", 1);
						newMap.put("fromAddType", fromAddType);
						jMessage = JSONMessage.success(KConstants.ResultCode.AttentionSuccess, newMap);
					} else {
						HashMap<String, Object> newMap = MapUtil.newMap("type", 2);
						newMap.put("fromAddType", fromAddType);
						jMessage = JSONMessage.success(KConstants.ResultCode.AttentionSuccessAndFriends,newMap);
					}

				}
			}
			// 有关注或好友关系，重复关注
			else if (Friends.Blacklist.No == friendsAB.getBlacklist()) {
				if (Friends.Status.Attention == friendsAB.getStatus()) {
					// 开启好友验证后关闭
					if(0 == userSettingsB.getFriendsVerify()){
						Integer statusA = Friends.Status.Friends;
						if (null == friendsBA) {
							getFriendsDao().saveFriends(new Friends(toUserId, user.getUserId(),user.getNickname(),Friends.Status.Friends, Friends.Blacklist.No,0,userRoles,userType,fromAddType));
							saveFansCount(toUserId);
						} else{
							getFriendsDao().updateFriends(new Friends(toUserId, user.getUserId(),user.getNickname(), Friends.Status.Friends));
						}
						if (null == friendsAB) {
							getFriendsDao().saveFriends(new Friends(userId, toUserId,toUser.getNickname(), statusA, Friends.Blacklist.No,0,toUserRoles,toUserType,fromAddType));
							saveFansCount(toUserId);
						} else {
							getFriendsDao().updateFriends(new Friends(userId, toUserId,toUser.getNickname(), statusA, Friends.Blacklist.No,0));
						}
						HashMap<String, Object> newMap = MapUtil.newMap("type", 2);
						newMap.put("fromAddType", fromAddType);
						jMessage = JSONMessage.success(KConstants.ResultCode.AttentionSuccessAndFriends, newMap);
					}else if(1 == userSettingsB.getFriendsVerify()){
						HashMap<String, Object> newMap = MapUtil.newMap("type", 1);
						newMap.put("fromAddType", fromAddType);
						jMessage = JSONMessage.success(KConstants.ResultCode.AttentionSuccess, newMap);
					}
				} else {
					HashMap<String, Object> newMap = MapUtil.newMap("type", 2);
					newMap.put("fromAddType", fromAddType);
					jMessage = JSONMessage.success(KConstants.ResultCode.AttentionSuccessAndFriends,newMap);
				}
			}
			// 有关注黑名单或好友黑名单关系，恢复关系
			else {
				getFriendsDao().updateFriends(new Friends(userId, toUserId,toUser.getNickname(), Friends.Blacklist.No));

				jMessage = null;
			}
			// 维护好友数据
			deleteFriendsInfo(userId, toUserId);
			// 更新好友设置操作时间
			updateOfflineOperation(userId, toUserId);
		} catch (Exception e) {
			Log.error("关注失败", e);
			jMessage = JSONMessage.failureByErrCode(KConstants.ResultCode.AttentionFailure);
		}
		return jMessage;
	}
	
	/** @Description:更新好友设置操作时间
	* @param userId
	* @param toUserId
	**/ 
	public void updateOfflineOperation(Integer userId,Integer toUserId){
//		Query<OfflineOperation> query = getDatastore().createQuery(OfflineOperation.class).field("userId").equal(userId).field("tag").equal(KConstants.MultipointLogin.TAG_FRIEND).field("friendId").equal(String.valueOf(toUserId));
		OfflineOperation offlineOperation = offlineOperationDao.queryOfflineOperation(userId,KConstants.MultipointLogin.TAG_FRIEND,String.valueOf(toUserId));
		if(null == offlineOperation){
//			getDatastore().save(new OfflineOperation(userId, KConstants.MultipointLogin.TAG_FRIEND, String.valueOf(toUserId), DateUtil.currentTimeSeconds()));
			offlineOperationDao.addOfflineOperation(userId,KConstants.MultipointLogin.TAG_FRIEND,String.valueOf(toUserId),DateUtil.currentTimeSeconds());
		}else{
//			UpdateOperations<OfflineOperation> ops = getDatastore().createUpdateOperations(OfflineOperation.class);
//			ops.set("operationTime", DateUtil.currentTimeSeconds());
//			getDatastore().update(query, ops);
			Map<String,Object> map = new HashMap<>();
			map.put("operationTime", DateUtil.currentTimeSeconds());
			offlineOperationDao.updateOfflineOperation(userId,toUserId.toString(),map);
		}
	}
	
	// 批量添加好友
	@Override
	public JSONMessage batchFollowUser(Integer userId, String toUserIds) {
		JSONMessage jMessage = null;
		if(StringUtil.isEmpty(toUserIds))
			return null;
		int[] toUserId = StringUtil.getIntArray(toUserIds, ",");
		for(int i = 0; i < toUserId.length; i++){
			//好友不存在
			if(userId==toUserId[i]||10000==toUserId[i])
				continue;
			User toUser = getUserManager().getUser(toUserId[i]);
			if(null==toUser)
				continue;
			int toUserType = 0;
			List<Integer> toUserRoles = roleCoreService.getUserRoles(toUserId[i]);
			if(toUserRoles.size()>0 && null != toUserRoles){
				if(toUserRoles.contains(2))
					toUserType = 2;
			}
			
			try {
				User user = getUserManager().getUser(userId);
				int userType = 0;
				List<Integer> userRoles = roleCoreService.getUserRoles(userId);
				if(userRoles.size()>0 && null != userRoles){
					if(userRoles.contains(2))
						userType = 2;
				}

				// 是否存在AB关系
				Friends friendsAB = getFriendsDao().getFriends(userId, toUserId[i]);
				// 是否存在BA关系
				Friends friendsBA = getFriendsDao().getFriends(toUserId[i], userId);
				// 获取目标用户设置
				User.UserSettings userSettingsB = getUserManager().getSettings(toUserId[i]);

				if(null != friendsAB&&friendsAB.getIsBeenBlack()==1){
//					return jMessage = JSONMessage.failure("加好友失败");
//					continue;
					throw new ServiceException(KConstants.ResultCode.WasAddBlacklist);
				}
				if (null == friendsAB || Friends.Status.Stranger == friendsAB.getStatus()) {
					// 目标用户拒绝关注
					if (0 == userSettingsB.getAllowAtt()) {
//						jMessage = new JSONMessage(groupCode, serviceCode, "01", "关注失败，目标用户拒绝关注");
						continue;
					}
					// 目标用户允许关注
					else {
						int statusA = 0;
							statusA = Friends.Status.Friends;

							if (null == friendsBA) {
								getFriendsDao().saveFriends(new Friends(toUserId[i], user.getUserId(),user.getNickname(),
										Friends.Status.Friends, Friends.Blacklist.No,0,userRoles,userType,4));

								saveFansCount(toUserId[i]);
							} else
								getFriendsDao()
										.updateFriends(new Friends(toUserId[i], user.getUserId(),user.getNickname(), Friends.Status.Friends));

						if (null == friendsAB) {
							getFriendsDao().saveFriends(new Friends(userId, toUserId[i],toUser.getNickname(), statusA, Friends.Blacklist.No,0,toUserRoles,toUserType,4));
							saveFansCount(toUserId[i]);
						} else {
							getFriendsDao().updateFriends(new Friends(userId, toUserId[i],toUser.getNickname(), statusA, Friends.Blacklist.No,0));
						}

					}
				}
				// 有关注或好友关系，重复关注
				else if (Friends.Blacklist.No == friendsAB.getBlacklist()) {
					if (Friends.Status.Attention == friendsAB.getStatus()){
						// 已关注的修改为好友状态
						getFriendsDao().updateFriends(new Friends(userId, toUserId[i],toUser.getNickname(), Friends.Status.Friends,toUserType,toUserRoles));
						// 添加成为好友
						getFriendsDao().saveFriends(new Friends(toUserId[i], user.getUserId(),user.getNickname(),
								Friends.Status.Friends, Friends.Blacklist.No,0,userRoles,"",userType));
//						continue;
					}
				}else {
					// 有关注黑名单或好友黑名单关系，恢复关系
					getFriendsDao().updateFriends(new Friends(userId, toUserId[i],toUser.getNickname(), Friends.Blacklist.No));
					jMessage = null;
				}
				notify(userId, toUserId[i]);
				jMessage = JSONMessage.success();
				// 维护好友数据
				deleteAddressFriendsInfo(userId, toUserId[i]);
				// 更新好友设置操作时间
				updateOfflineOperation(userId, toUserId[i]);
			} catch (Exception e) {
				Log.error("通讯录添加好友失败", e.getMessage());
				throw  e;
			}
		}
		return jMessage;
	}
	
	
	/** @Description:（通讯录自动添加好友） 
	* @param userId
	* @param addressBook<userid 用户id, toRemark 备注 >
	* @return
	**/ 
	public JSONMessage autofollowUser(Integer userId, Map<String, String> addressBook) {
		final String serviceCode = "08";
		Integer toUserId  = Integer.valueOf(addressBook.get("toUserId"));
		String toRemark = addressBook.get("toRemark");

//		final String serviceCode = "08";
		JSONMessage jMessage = null;
			User toUser = getUserManager().getUser(toUserId);
			int toUserType = 0;
			List<Integer> toUserRoles = roleCoreService.getUserRoles(toUserId);
			if(toUserRoles.size()>0 && null != toUserRoles){
				if(toUserRoles.contains(2))
					toUserType = 2;
			}
			//好友不存在
			if(10000==toUser.getUserId())
				return null;
			try {
				User user = getUserManager().getUser(userId);
				int userType = 0;
				List<Integer> userRoles = roleCoreService.getUserRoles(userId);
				if(userRoles.size()>0 && null != userRoles){
					if(userRoles.contains(2))
						userType = 2;
				}

				// 是否存在AB关系
				Friends friendsAB = getFriendsDao().getFriends(userId, toUserId);
				// 是否存在BA关系
				Friends friendsBA = getFriendsDao().getFriends(toUserId, userId);
				// 获取目标用户设置
				User.UserSettings userSettingsB = getUserManager().getSettings(toUserId);

				if(null != friendsAB&&friendsAB.getIsBeenBlack()==1){
					return jMessage = JSONMessage.failureByErrCode(KConstants.ResultCode.AddFriendsFailure);
				}
				if (null == friendsAB || Friends.Status.Stranger == friendsAB.getStatus()) {
					// 目标用户拒绝关注
					if (0 == userSettingsB.getAllowAtt()) {
						jMessage = JSONMessage.failureByErrCode(KConstants.ResultCode.AttentionFailure);
					}
					// 目标用户允许关注
					else {
						int statusA = 0;
						// 目标用户加好友无需验证，执行加好友
//						else {
							statusA = Friends.Status.Friends;

							if (null == friendsBA) {
								getFriendsDao().saveFriends(new Friends(toUserId, user.getUserId(),user.getNickname(),
										Friends.Status.Friends, Friends.Blacklist.No,0,userRoles,"",userType));

								saveFansCount(toUserId);
							} else
								getFriendsDao()
										.updateFriends(new Friends(toUserId, user.getUserId(),user.getNickname(), Friends.Status.Friends));
//						}

						if (null == friendsAB) {
							getFriendsDao().saveFriends(new Friends(userId, toUserId,toUser.getNickname(), statusA, Friends.Blacklist.No,0,toUserRoles,toRemark,toUserType));
							saveFansCount(toUserId);
						} else {
							getFriendsDao().updateFriends(new Friends(userId, toUserId,toUser.getNickname(), statusA, Friends.Blacklist.No,0));
						}

					}
				}
				// 有关注或好友关系，重复关注
				else if (Friends.Blacklist.No == friendsAB.getBlacklist()) {
					if (Friends.Status.Attention == friendsAB.getStatus()){
						// 已关注的修改为好友状态
						getFriendsDao().updateFriends(new Friends(userId, toUserId,toUser.getNickname(), Friends.Status.Friends,toUserType,toUserRoles));
						// 添加成为好友
						getFriendsDao().saveFriends(new Friends(toUserId, user.getUserId(),user.getNickname(),
								Friends.Status.Friends, Friends.Blacklist.No,0,userRoles,"",userType));
					}
				}else {
					// 有关注黑名单或好友黑名单关系，恢复关系
					getFriendsDao().updateFriends(new Friends(userId, toUserId,toUser.getNickname(), Friends.Blacklist.No));
					jMessage = null;
				}
				notify(userId, toUserId);
				// 维护好友数据
				deleteFriendsInfo(userId, toUserId);
				jMessage = JSONMessage.success();
			} catch (Exception e) {
				Log.error("关注失败", e);
				jMessage = JSONMessage.failureByErrCode(KConstants.ResultCode.AttentionFailure);
			}
		return jMessage;
	}
	
	public void notify(Integer userId,Integer toUserId){
		ThreadUtils.executeInThread((Callback) obj -> {
				MessageBean messageBean=new MessageBean();
				messageBean.setType(MessageType.batchAddFriend);
				messageBean.setFromUserId(String.valueOf(userId));
				messageBean.setFromUserName(getUserManager().getNickName(userId));
				messageBean.setToUserId(String.valueOf(toUserId));
				messageBean.setToUserName(getUserManager().getNickName(toUserId));
				messageBean.setContent(toUserId);
				messageBean.setMsgType(0);// 单聊消息
				messageBean.setMessageId(StringUtil.randomUUID());
				try {
					messageService.send(messageBean);
				} catch (Exception e) {
					e.printStackTrace();
				}
		});
	}
	
	public Friends getFriends(int userId, int toUserId) {
		return getFriendsDao().getFriends(userId, toUserId);
	}
	
	public void getFriends(int userId, String... toUserIds) {
		for (String strToUserId : toUserIds) {
			Integer toUserId = Integer.valueOf(strToUserId);
			Friends friends = getFriendsDao().getFriends(userId, toUserId);
			if(null == friends)
				throw new ServiceException(KConstants.ResultCode.NotYourFriends);
		
		}
//		return getFriendsRepository().getFriends(userId, toUserId);
//		return getFriendsRepository().getFriends(userId, toUserId);
	}
	
	public List<Friends> getFansList(Integer userId) {
		
		List<Friends> result =getFriendsDao().queryAllFriends(userId);
		result.forEach(friends->{
		   User	user = getUserManager().getUser(friends.getToUserId());
			
			friends.setToNickname(user.getNickname());
		});
		


		return result;
	}

	

	@Override
	public Friends getFriends(Friends p) {
		return getFriendsDao().getFriends(p.getUserId(), p.getToUserId());
	}

	@Override
	public List<Integer> queryFriendUserIdList(int userId) {
		List<Integer> result;

		try {
			result = firendsRedisRepository.getFriendsUserIdsList(userId);
			if (null != result && result.size() > 0) {

				return result;
			} else {
				result = friendsDao.queryFriendUserIdList(userId);

				firendsRedisRepository.saveFriendsUserIdsList(userId, result);
			}
			return result;
		} catch (Exception e) {
			Log.error(e.getMessage(),e);
			throw e;
		}


	}

	@Override
	public List<Friends> queryBlacklist(Integer userId,int pageIndex,int pageSize) {
		return getFriendsDao().queryBlacklist(userId,pageIndex,pageSize);
	}
	
	public PageVO queryBlacklistWeb(Integer userId, int pageIndex, int pageSize) {
		List<Friends> data = getFriendsDao().queryBlacklistWeb(userId,pageIndex,pageSize);
		return new PageVO(data, Long.valueOf(data.size()), pageIndex, pageSize);
	}


	/**
	 * 查询好友是否开启 免打扰
	 * @return
	 */
	@Override
	public boolean getFriendIsNoPushMsg(int userId, int toUserId) {
		Document query=new Document("userId", userId).append("toUserId", toUserId);
		query.put("offlineNoPushMsg", 1);
		Object field = getFriendsDao().queryOneField("offlineNoPushMsg",query);
		return null!=field;
	}
	@Override
	public List<Friends> queryFollow(Integer userId,int status) {
		List<Friends> userfriends = firendsRedisRepository.getFriendsList(userId);
		if(null != userfriends && userfriends.size() > 0){
			return userfriends;
		}else{
			if(0 == status)
				status = 2;  //好友
			List<Friends> result = getFriendsDao().queryFriendsList(userId,status,0,0);
			Iterator<Friends> iter = result.iterator();
			while (iter.hasNext()) { 
				Friends friends=iter.next();
				User user = getUserManager().getUser(friends.getToUserId());
				if(null==user){
					iter.remove();
					deleteFansAndFriends(friends.getToUserId());
					continue;
				}
				AuthKeys authks = authKeysService.getAuthKeys(user.getUserId());
				if(authks!=null) {
					friends.setDhMsgPublicKey(authks.getMsgDHKeyPair()!=null ? authks.getMsgDHKeyPair().getPublicKey() : "");
					friends.setRsaMsgPublicKey(authks.getMsgRsaKeyPair()!=null ? authks.getMsgRsaKeyPair().getPublicKey() : "");
				}

				friends.setToNickname(user.getNickname());
			}
			firendsRedisRepository.saveFriendsList(userId,result);
			return result;
		}
	}
	
	
	public PageResult<Friends> consoleQueryFollow(Integer userId,Integer toUserId,int status,int page,int limit) {
		PageResult<Friends> result = new PageResult<Friends>();
		result = getFriendsDao().consoleQueryFollow(userId,toUserId,status,page,limit);
		Iterator<Friends> iter = result.getData().iterator(); 
		while (iter.hasNext()) { 
			Friends friends=iter.next();
			User user = getUserManager().getUser(friends.getToUserId());
			friends.setNickname(getUserManager().getNickName(userId));
			if(null==user){
				iter.remove();
				deleteFansAndFriends(friends.getToUserId());
				continue;
			}
			friends.setToNickname(user.getNickname());
		}
		return result;
	}

	
	
	

	@Override
	public List<Integer> queryFollowId(Integer userId) {
		return getFriendsDao().queryFollowId(userId);
	}

	@Override
	public List<Friends> queryFriends(Integer userId) {
		List<Friends> result = getFriendsDao().queryFriends(userId);

		for (Friends friends : result) {
			User toUser = getUserManager().getUser(friends.getToUserId());
			if(null==toUser){
				deleteFansAndFriends(friends.getToUserId());
				continue;
			}
			friends.setToNickname(toUser.getNickname());
			//friends.setCompanyId(toUser.getCompanyId());
		}

		return result;
	}
	
	
	@Override   //返回好友的userId 和单向关注的userId
	public List<Integer> friendsAndAttentionUserId(Integer userId,String type) {
		List<Friends> result;
		if("friendList".equals(type) || "blackList".equals(type)){  //返回好友的userId 和单向关注的userId
			 result = getFriendsDao().friendsOrBlackList(userId, type);
		}else{
			throw new ServiceException(KConstants.ResultCode.ParamsAuthFail);
		}
		List<Integer> userIds = new ArrayList<Integer>();
		for (Friends friend : result) {
			userIds.add(friend.getToUserId());
		}
		return userIds;
	}

	@Override
	public PageVO queryFriends(Integer userId,int status,String keyword, int pageIndex, int pageSize) {
		PageResult<Friends> pageData = friendsDao.queryFollowByKeyWord(userId,status,keyword,pageIndex,pageSize);
		long total = pageData.getCount();
		for (Friends friends : pageData.getData()) {
			User toUser = getUserManager().getUser(friends.getToUserId());
			if(null==toUser){
				deleteFansAndFriends(friends.getToUserId());
				continue;
			}
			if(toUser.getUserId()==10000){
				continue;
			}
			friends.setToNickname(toUser.getNickname());
			AuthKeys authks = authKeysService.getAuthKeys(toUser.getUserId());
			if(authks!=null) {
				friends.setDhMsgPublicKey(authks.getMsgDHKeyPair()!=null ? authks.getMsgDHKeyPair().getPublicKey() : "");
				friends.setRsaMsgPublicKey(authks.getMsgRsaKeyPair()!=null ? authks.getMsgRsaKeyPair().getPublicKey() : "");
			}
		};
		return new PageVO(pageData.getData(), total);
	}
	public List<Friends> queryFriendsList(Integer userId,int status, int pageIndex, int pageSize) {
		List<Friends> pageData = friendsDao.queryFriendsList(userId,status,pageIndex,pageSize);
		for (Friends friends : pageData) {
			User toUser = getUserManager().getUser(friends.getToUserId());
			if(null==toUser){
				deleteFansAndFriends(friends.getToUserId());
				continue;
			}
			friends.setToNickname(toUser.getNickname());
		}
		return pageData;
	}

	
	
	/**
	 * 取消关注
	 */
	@Override
	public boolean unfollowUser(Integer userId, Integer toUserId) {
		// 删除用户关注
		getFriendsDao().deleteFriends(userId, toUserId);
		// 更新好友设置操作时间
		updateOfflineOperation(userId, toUserId);
		return true;
	}

	@Override
	public Friends updateRemark(int userId, int toUserId, String remarkName,String describe) {
		return getFriendsDao().updateFriendRemarkName(userId, toUserId, remarkName,describe);
	}

	

	@Override
	public void deleteFansAndFriends(int userId) {
		/*List<Integer> list = queryFollowId(userId);
		list.forEach(toUserId->{
			getFriendsDao().deleteFriends(toUserId,userId);

			firendsRedisRepository.deleteFriends(toUserId);
			firendsRedisRepository.deleteFriendsUserIdsList(toUserId);
		});*/
		getFriendsDao().deleteFriends(userId);



	}

	/* (non-Javadoc)
	 * @see cn.xyz.mianshi.service.FriendsManager#newFriendList(int,int,int)
	 */
	@Override
	public List<NewFriends> newFriendList(int userId, int pageIndex, int pageSize) {
		
		List<NewFriends> pageData = friendsDao.getNewFriendsList(userId,pageIndex,pageSize);
		Friends friends=null;
		for (NewFriends newFriends : pageData) {
			friends=getFriends(newFriends.getUserId(), newFriends.getToUserId());
			newFriends.setToNickname(getUserManager().getNickName(newFriends.getToUserId()));

			if(null!=friends)
				newFriends.setStatus(friends.getStatus());
		}
		return pageData;
		
	}
	
	@SuppressWarnings("deprecation")
	public PageVO newFriendListWeb(int userId,int pageIndex,int pageSize) {
		
		List<NewFriends> pageData = friendsDao.getNewFriendsList(userId,pageIndex,pageSize);
		Friends friends = null;
		for (NewFriends newFriends : pageData) {
			friends=getFriends(newFriends.getUserId(), newFriends.getToUserId());
			newFriends.setToNickname(getUserManager().getNickName(newFriends.getToUserId()));
			if(null!=friends)
				newFriends.setStatus(friends.getStatus());
		}
		return new PageVO(pageData, (long)pageData.size(), pageIndex, pageSize);
	}


	public NewFriends newFriendLast(int userId,int toUserId) {
		NewFriends newFriend = friendsDao.getNewFriendLast(userId,toUserId);
		newFriend.setToNickname(getUserManager().getNickName(newFriend.getToUserId()));
		return newFriend;
	}
	
	/* 消息免打扰、阅后即焚、聊天置顶相关修改
	 * type = 0  消息免打扰 ,type = 1  阅后即焚 ,type = 2  聊天置顶
	 */
	@Override
	public Friends updateOfflineNoPushMsg(int userId, int toUserId, int offlineNoPushMsg ,int type) {
		Map<String,Object> map = new HashMap<>();
		switch (type) {
		case 0:
			map.put("offlineNoPushMsg", offlineNoPushMsg);
			break;
		case 1:
			map.put("isOpenSnapchat", offlineNoPushMsg);
			break;
		case 2:
			map.put("openTopChatTime", (offlineNoPushMsg == 0 ? 0 : DateUtil.currentTimeSeconds()));
			break;
		default:
			break;
		}
		// 多点登录下消息免打扰xmpp通知
		if(getUserManager().isOpenMultipleDevices(userId)){
			getUserManager().multipointLoginUpdateUserInfo(userId, getUserManager().getNickName(userId), toUserId,getUserManager().getNickName(toUserId),1);
		}
		firendsRedisRepository.deleteFriends(userId);
		return friendsDao.updateFriendsReturn(userId,toUserId,map);
	}
	
	
	/**
	 * 添加好友统计      时间单位每日，最好可选择：每日、每月、每分钟、每小时
	 * @param startDate
	 * @param endDate
	 *
	 */
	public List<Object> getAddFriendsCount(String startDate, String endDate, short timeUnit){
		
		List<Object> countData = new ArrayList<>();
		
		long startTime = 0; //开始时间（秒）
		
		long endTime = 0; //结束时间（秒）,默认为当前时间
		
		/**
		 * 如时间单位为月和天，默认开始时间为当前时间的一年前 ; 时间单位为小时，默认开始时间为当前时间的一个月前;
		 * 时间单位为分钟，则默认开始时间为当前这一天的0点
		 */
		long defStartTime = timeUnit==4? DateUtil.getTodayMorning().getTime()/1000 
				: timeUnit==3 ? DateUtil.getLastMonth().getTime()/1000 : DateUtil.getLastYear().getTime()/1000;
		
		startTime = StringUtil.isEmpty(startDate) ? defStartTime :DateUtil.toDate(startDate).getTime()/1000;
		endTime = StringUtil.isEmpty(endDate) ? DateUtil.currentTimeSeconds() : DateUtil.toDate(endDate).getTime()/1000;
				
//		BasicDBObject queryTime = new BasicDBObject("$ne",null);
//
//		if(startTime!=0 && endTime!=0){
//			queryTime.append("$gt", startTime);
//			queryTime.append("$lt", endTime);
//		}
//
//		BasicDBObject query = new BasicDBObject("createTime",queryTime);
//
//		//获得用户集合对象
//		DBCollection collection = SKBeanUtils.getDatastore().getCollection(getEntityClass());
		
		String mapStr = "function Map() { "   
	            + "var date = new Date(this.createTime*1000);" 
	            +  "var year = date.getFullYear();"
				+  "var month = (\"0\" + (date.getMonth()+1)).slice(-2);"  //month 从0开始，此处要加1
				+  "var day = (\"0\" + date.getDate()).slice(-2);"
				+  "var hour = (\"0\" + date.getHours()).slice(-2);"
				+  "var minute = (\"0\" + date.getMinutes()).slice(-2);"
				+  "var dateStr = date.getFullYear()"+"+'-'+"+"(parseInt(date.getMonth())+1)"+"+'-'+"+"date.getDate();";
				
				if(timeUnit==1){ // counType=1: 每个月的数据
					mapStr += "var key= year + '-'+ month;";
				}else if(timeUnit==2){ // counType=2:每天的数据
					mapStr += "var key= year + '-'+ month + '-' + day;";
				}else if(timeUnit==3){ //counType=3 :每小时数据
					mapStr += "var key= year + '-'+ month + '-' + day + '  ' + hour +' : 00';";
				}else if(timeUnit==4){ //counType=4 :每分钟的数据
					mapStr += "var key= year + '-'+ month + '-' + day + '  ' + hour + ':'+ minute;";
				}
	           
				mapStr += "emit(key,1);}";
		
		 String reduce = "function Reduce(key, values) {" +
			                "return Array.sum(values);" +
	                    "}";
//		 MapReduceCommand.OutputType type =  MapReduceCommand.OutputType.INLINE;//
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
//
//		}
		countData = friendsDao.getAddFriendsCount(startTime,endTime,mapStr,reduce);
		return countData;
	}
	
	// 好友之间的聊天记录
	public PageResult<Document> chardRecord(Integer sender, Integer receiver, Integer page, Integer limit){
		return messageRepository.queryFirendMsgRecord(sender,receiver,page,limit);
	}
	
	/**
	 * @Description:（删除好友间的聊天记录）
	**/ 
	public void delFriendsChatRecord(String... messageIds){
		 messageRepository.delFriendsChatRecord(messageIds);
	}


	
	/** @Description:校验是否为好友或通讯录好友 
	* @param userId
	* @param toUserId
	* @param type  -1 所有人不显示 1所有人显示  2 所有好友显示   3 手机联系人显示
	* @return
	**/ 
	public boolean isAddressBookOrFriends(Integer userId,Integer toUserId,int type){
		boolean flag = false;
		switch (type) {
		case -1:
			break;
		case 1:
			flag = !flag;
			break;
		case 2:
			List<Integer> friendsUserIdsList= queryFriendUserIdList(userId);
			if (null != friendsUserIdsList && friendsUserIdsList.size() > 0) {
				flag = friendsUserIdsList.contains(toUserId);
			}

			break;
		case 3:
			List<Integer> addressBookUserIdsList;
			List<Integer> allAddressBookUserIdsList = firendsRedisRepository.getAddressBookFriendsUserIds(userId);
			if(null != allAddressBookUserIdsList && allAddressBookUserIdsList.size() > 0)
				addressBookUserIdsList = allAddressBookUserIdsList;
			else{
				List<Integer> AddressBookUserIdsDB = addressBookManager.getAddressBookUserIds(userId);
				addressBookUserIdsList = AddressBookUserIdsDB;
				firendsRedisRepository.saveAddressBookFriendsUserIds(userId, addressBookUserIdsList);
			}
			flag = addressBookUserIdsList.contains(toUserId);
			break;
		default:
			break;
		}
		return flag;
	}

	/**
	 * 修改和某个好友的消息加密方式
	 * @param userId
	 * @param toUserId
	 * @param type
	 */
	public void  modifyEncryptType(int userId,int toUserId,byte type) {
		friendsDao.updateFriendsEncryptType(userId, toUserId, type);
		firendsRedisRepository.deleteFriends(userId);
		if(getUserManager().isOpenMultipleDevices(userId)){
			getUserManager().multipointLoginUpdateUserInfo(userId, getUserManager().getNickName(userId), toUserId,getUserManager().getNickName(toUserId),1);
		}
	}

	public void sendUpdatePublicKeyMsgToFriends(String dhPublicKey,String rsaPublicKey, int userId){
		List<Integer> friendIds = queryFriendUserIdList(userId);
		// 删除好友的好友缓存
		friendIds.forEach(toUserId -> {
			deleteRedisUserFriends(toUserId);
		});
		MessageBean mb = new MessageBean();
		mb.setContent(dhPublicKey+","+rsaPublicKey);
		mb.setFromUserId(userId + "");
		mb.setFromUserName(userManager.getNickName(userId));
		mb.setMessageId(UUID.randomUUID().toString());
		mb.setMsgType(0);// 单聊消息
		mb.setType(MessageType.updateFriendsEncryptKey);
		messageService.send(mb,friendIds);

	}

	public void deleteRedisUserFriends(int userId){
		firendsRedisRepository.deleteFriends(userId);
	}

	@EventListener
	public void handlerUserChageNameEvent(UserChageNameEvent event){
		//log.info(" friends handlerUserChageNameEvent {}",event.getUserId());
		//修改好友昵称

		friendsDao.updateFriendsAttribute(0, event.getUserId(), "toNickname",event.getNickName());

	}

}
