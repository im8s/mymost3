package com.shiku.im.friends.service.impl;


import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.friends.dao.FriendGroupDao;
import com.shiku.im.friends.entity.FriendGroup;
import com.shiku.im.support.Callback;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.rmi.ServerException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class FriendGroupManagerImpl {
	@Autowired
	private FriendGroupDao friendGroupDao;

	@Autowired
	private UserCoreService userCoreService;
	
	public void autoCreateGroup(Integer userId){
		FriendGroup group=new FriendGroup();
		group.setUserId(userId);
		group.setGroupName("家人");
		FriendGroup group1=new FriendGroup();
		group1.setUserId(userId);
		group1.setGroupName("同事");
		saveGroup(group);
		saveGroup(group1);
	}
	
	public FriendGroup saveGroup(FriendGroup group){
		if(null==group.getGroupId()){
			group.setCreateTime(DateUtil.currentTimeSeconds());
			group.setGroupId(new ObjectId());
//			save(group);
			friendGroupDao.addFriendGroup(group);
		}else{
//			update(group.getGroupId(), group);
			friendGroupDao.updateFriendGroup(group.getGroupId(),group);
		}
		// 多点登录同步好友标签
		int userId = group.getUserId();
		if(userCoreService.isOpenMultipleDevices(userId))
			multipointLoginUpdateFriendsGroup(userId, userCoreService.getNickName(userId));
		return group;
	}
	
	// 多点登录同步好友标签通知
	public void multipointLoginUpdateFriendsGroup(Integer userId,String nickName){
		userCoreService.multipointLoginDataSync(userId, nickName, KConstants.MultipointLogin.SYNC_LABEL);
		friendGroupDao.multipointLoginUpdateFriendsGroup(userId,nickName);


	}
	
	public FriendGroup queryGroupName(Integer userId,String groupName){
		return friendGroupDao.getFriendGroup(userId,groupName);
	}
	//更新分组的名称
	public void updateGroupName(Integer userId,ObjectId groupId,String groupName) throws ServerException{
		Map<String,Object> map = new HashMap<>();
		map.put("groupName", groupName);
		try {
			friendGroupDao.updateFriendGroup(userId,groupId,map);
			if(userCoreService.isOpenMultipleDevices(userId))
				multipointLoginUpdateFriendsGroup(userId, userCoreService.getNickName(userId));
		}catch (ServiceException e){

		}

//		if(update.getUpdatedCount()>0){
			// 多点登录同步好友标签

//		}else{
//			throw new ServiceException(KConstants.ResultCode.UpdateFailure);
//		}

	}
	/**
	* @Description: TODO(修改好友的分组ID)
	* @param @param userId
	* @param @param toUserId
	* @param @param groupId    参数
	 * @throws ServerException 
	 */
	public void updateFriendGroup(int userId, Integer toUserId,List<String> groupIdStrList) throws ServiceException{
		try {
			List<FriendGroup> groupList = friendGroupDao.getFriendGroupList(userId);
			ThreadUtils.executeInThread(new Callback() {
				@Override
				public void execute(Object obj) {
					//修改后的 分组Id	
					List<ObjectId> groupIdList=new ArrayList<ObjectId>();
					for (String str : groupIdStrList) {
						if(!StringUtil.isEmpty(str)&&
								(ObjectId.isValid(str))) {
							groupIdList.add(new ObjectId(str));
						}
					}
					Map<String,Object> map = new HashMap<>();
					for (FriendGroup friendGroup : groupList) {
						//好友Id 不在分组中
						if(!friendGroup.getUserIdList().contains(toUserId)){
							//修改后的分组 Id 中没有当前分组 不处理
							if(!groupIdList.contains(friendGroup.getGroupId()))
								continue;
							friendGroup.getUserIdList().add(toUserId);
							map.put("userIdList",friendGroup.getUserIdList());
							friendGroupDao.updateFriendGroup(userId,friendGroup.getGroupId(),map);
						}else{
							//好友Id 在分组中
							//并且当前分组在 修改后的分组ID 中 不处理
							if(groupIdList.contains(friendGroup.getGroupId()))
								continue;
							friendGroup.getUserIdList().remove(toUserId);
							map.put("userIdList", friendGroup.getUserIdList());
							friendGroupDao.updateFriendGroup(userId,friendGroup.getGroupId(),map);
						}
					}
				}
			});
			// 多点登录同步好友标签
			if(userCoreService.isOpenMultipleDevices(userId))
				multipointLoginUpdateFriendsGroup(userId, userCoreService.getNickName(userId));
		
		} catch (Exception e) {
			throw new ServiceException(e.getMessage());
		}
	}
	
	public void updateGroupUserList(Integer userId,ObjectId groupId,List<Integer> userIdList) throws ServerException{
		Map<String,Object> map = new HashMap<>();
		map.put("userIdList", userIdList);
		friendGroupDao.updateFriendGroup(userId,groupId,map);
//		if(update.getUpdatedCount()>0){
			// 多点登录同步好友标签
			if(userCoreService.isOpenMultipleDevices(userId))
				multipointLoginUpdateFriendsGroup(userId, userCoreService.getNickName(userId));
//		}else {
//			throw new ServiceException(KConstants.ResultCode.UpdateFailure);
//		}
		
	}
	
	public void deleteGroup(Integer userId,ObjectId groupId) throws ServerException{
//		Query<FriendGroup> query = getDatastore().createQuery(getEntityClass()).field("groupId").equal(groupId).field("userId").equal(userId);
//		WriteResult deleteByQuery = deleteByQuery(query);
		friendGroupDao.deleteGroup(userId,groupId);
//		if(deleteByQuery.getN()>0){
			// 多点登录同步好友标签
			if(userCoreService.isOpenMultipleDevices(userId))
				multipointLoginUpdateFriendsGroup(userId, userCoreService.getNickName(userId));
//		}else {
//			throw new ServiceException(KConstants.ResultCode.UpdateFailure);
//		}
		
	}
	
	public List<FriendGroup> queryGroupList(long userId){
		return friendGroupDao.getFriendGroupList((int)userId);
	}

	/**
	 * 删除好友时维护好友标签
	 * @param userId
	 */
	public void deleteFriendToFriendGroup(Integer userId,final Integer friendId){
		List<FriendGroup> friendGroups = queryGroupList(userId);
		if(null==friendGroups&&0==friendGroups.size()){
			return;
		}
		friendGroups.forEach(friendGroup -> {
			if(null!=friendGroup.getUserIdList()&&friendGroup.getUserIdList().contains(friendId)) {
				friendGroup.getUserIdList().remove(friendId);
				try {
					updateGroupUserList(userId,friendGroup.getGroupId(),friendGroup.getUserIdList());
				} catch (ServerException e) {

				}
			}
		});

		friendGroups = queryGroupList(friendId);
		if(null==friendGroups&&0==friendGroups.size()){
			return;
		}
		friendGroups.forEach(friendGroup -> {
			if(null!=friendGroup.getUserIdList()&&friendGroup.getUserIdList().contains(userId)) {
				friendGroup.getUserIdList().remove(userId);
				try {
					updateGroupUserList(friendId,friendGroup.getGroupId(),friendGroup.getUserIdList());
				} catch (ServerException e) {

				}
			}
		});
	}
}
