package com.shiku.im.user.service.impl;


import com.alibaba.fastjson.JSONObject;
import com.shiku.common.model.PageResult;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.friends.dao.FriendsDao;
import com.shiku.im.friends.service.FriendsRedisRepository;
import com.shiku.im.room.dao.RoomDao;
import com.shiku.im.support.Callback;
import com.shiku.im.user.dao.RoleDao;
import com.shiku.im.user.dao.UserDao;
import com.shiku.im.user.entity.Role;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreRedisRepository;
import com.shiku.im.user.utils.KSessionUtil;
import com.shiku.im.utils.SKBeanUtils;
import lombok.extern.slf4j.Slf4j;
import org.bson.Document;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
@Slf4j
@Service
public class RoleManagerImpl{

	@Autowired
	private RoleDao roleDao;
	public RoleDao getRoleDao(){
		return roleDao;
	}
	@Autowired
	private UserDao userDao;
	@Autowired
	private RoomDao roomDao;

	@Lazy
	@Autowired
	private FriendsDao friendsDao;

	@Autowired
	private FriendsRedisRepository firendsRedisRepository;

	@Autowired
	private UserCoreRedisRepository userCoreRedisRepository;

	@Autowired
	private UserManagerImpl userManager;


	public int getUserRoleByUserId(Integer userId){
		Object roleQuery = getRoleDao().queryOneField("role", new Document("userId", userId));
		return null == roleQuery ? 0 : (int) roleQuery;
	}

	public Role getUserRole(Integer userId,String phone,Integer type){
		Role role = getRoleDao().getUserRole(userId,phone,type);
		return role;
	}

	public List<Role> getUserRoles(Integer userId,String phone,Integer type){
		return getRoleDao().getUserRoleList(userId,phone,type);
	}

	public List<Integer> getUserRoles(Integer userId){
		List<Integer> roleType = new ArrayList<Integer>();
		List<Role> asList = getRoleDao().getUserRoleList(userId,null,null);
		asList.forEach(role -> {
			roleType.add((int) role.getRole());
		});
		return roleType;
	}

	// ???????????????????????????
	public PageResult<Role> adminList(String keyWorld, int page, int limit, Integer type, Integer userId){
		PageResult<Role> result = new PageResult<Role>();

		result = getRoleDao().getAdminRoleList(keyWorld,page,limit,type,userId);
		result.getData().forEach(role ->{
			role.setNickName(userManager.getNickName(role.getUserId()));
		});

		return result;
	}

	/** @Description:?????????????????????
	* @param areaCode
	* @param account
	* @param password
	* @param role
	**/
	public void addAdmin(String telePhone, String phone, byte role, Integer type) {
		User accountUser = userManager.getUser(telePhone);
		if (null == accountUser)
			throw new ServiceException("???????????????");

		Role userRole = getUserRole(0, phone,null);
		if(null != userRole){
			throw new ServiceException("??????????????????" + (userRole.getRole() == 5 ? "?????????" : userRole.getRole() == 6 ? "???????????????" : userRole.getRole() == 1 ? "??????" :
				userRole.getRole() == 4 ? "??????" : userRole.getRole() == 2 ? "?????????" : userRole.getRole() == 3 ? "?????????" : "???????????????"));
		}
		/*if(null != userRole){
			byte roles = userRole.getRole();
			if(0 == type){
				if (userRole.getRole() == 5 || userRole.getRole() == 6 || userRole.getRole() == 1)
					throw new ServiceException("??????????????????" + (userRole.getRole() == 5 ? "?????????" : userRole.getRole() == 6 ? "???????????????" : "??????" ));
			}else if(4 == type){
				if (userRole.getRole() == 4)
					throw new ServiceException("??????????????????????????????");
			}else if(7 == type){
				if (userRole != null && userRole.getRole() == 7)
					throw new ServiceException("??????????????????????????????");
			}else if(1 == type){
				if (userRole != null && userRole.getRole() == 1)
					throw new ServiceException("????????????????????????");
				else if(userRole.getRole() == 5 || userRole.getRole() == 6)
					throw new ServiceException("??????????????????"+(userRole.getRole() == 5 ? "?????????" : "???????????????"));
			}
		}*/
		Role accountRole = null;
		if(type == 4)
			accountRole = new Role(accountUser.getUserId(), accountUser.getPhone(), role, (byte) 1, 0,promotionUrl(accountUser.getUserId()));
		else
			accountRole = new Role(accountUser.getUserId(), accountUser.getPhone(), role, (byte) 1, 0);
		getRoleDao().addRole(accountRole);
//		updateFriend(accountUser.getUserId(),null);
	}

	public void delAdminById(String adminId,Integer type,Integer adminUserId) {
		if(type == 3){
			ThreadUtils.executeInThread(new Callback() {

				@Override
				public void execute(Object obj) {
					if(!StringUtil.isEmpty(adminId)){
						String[] admins = StringUtil.getStringList(adminId,",");
						userManager.deleteUser(adminUserId,admins);
						for (String userId : admins) {
							getRoleDao().deleteAdminRole(Integer.valueOf(userId),type);
						}
					}
				}
			});
		}else if(type == 2){
			Map<String,Object> map = new HashMap<>();
			map.put("userType",0);
			userDao.updateUser(Integer.valueOf(adminId),map);
			getRoleDao().deleteAdminRole(Integer.valueOf(adminId),type);
			updateFriend(Integer.valueOf(adminId),0);
			// ??????redis????????????
			userCoreRedisRepository.deleteUserByUserId(Integer.valueOf(adminId));
		}else{
			getRoleDao().deleteAdminRole(Integer.valueOf(adminId),type);
			updateFriend(Integer.valueOf(adminId),0);
		}
			
	}
	
	
	public Role modifyRole(Role role){
		
		Map<String,Object> map = new HashMap<>();
		if(role.getRole() != 0) {
			map.put("role", role.getRole());
		}
		
		if(role.getStatus() != 0) {
			map.put("status", role.getStatus());
		}
		
		if(0 != role.getLastLoginTime())
			map.put("lastLoginTime", role.getLastLoginTime());

		if(!StringUtil.isEmpty(role.getPromotionUrl())){
			map.put("promotionUrl", role.getPromotionUrl());
			// ???????????????????????????
			Map<String,Object> roomOps = new HashMap<>();
			roomOps.put("promotionUrl", role.getPromotionUrl());
			roomDao.updateRoomByUserId(role.getUserId(),roomOps);
		}
		Role findAndModify = getRoleDao().updateRole(role.getUserId(),role.getRole(),map);
		updateFriend(role.getUserId(),null);
		if(role.getStatus()==-1){
			//??????redis????????????
			KSessionUtil.removeAdminToken(role.getUserId());
			userCoreRedisRepository.deleteUserByUserId(role.getUserId());
		}

		return findAndModify;
	}
	
	private String promotionUrl(Integer userId){
		/**
		 * ?????????http://www.duoyewu.com/tn/?pid=10000&com=2
			pid??????????????????????????????ID,???ID????????????
			com??????????????????3????????????
			1. ???????????????????????????
			2. ?????????????????????
			3 .???????????????????????????
		 */
		String promotionUrl = SKBeanUtils.getSystemConfig().getPromotionUrl();
		if(StringUtil.isEmpty(promotionUrl))
			throw new ServiceException("????????????????????????????????????????????????");
		return new StringBuffer().append(promotionUrl).append(userId).toString();
	}
	
	// ???????????????????????????toUserType,toUserType????????????0???2;
	public void updateFriend(Integer toUserId,Integer userType){
		List<Integer> roles = getUserRoles(toUserId);
		Map<String,Object> map = new HashMap<>();
		map.put("toFriendsRole", roles);
		if(null != userType){
			if(0 == userType){
				Role role = roleDao.getUserRoleByUserId(toUserId);
				if(null != role)
					roleDao.deleteRole(toUserId);
			}
			map.put("toUserType", userType);
		}
//		friendsDao.updateFriends(toUserId,0,map);
		friendsDao.updateFriends(0,toUserId,map);
		ThreadUtils.executeInThread((Callback) obj -> {
			List<Integer> queryFansIdByUserId = friendsDao.queryFriendUserIdList(toUserId);
			//log.info("updateFriend === userId "+JSONObject.toJSONString(queryFansIdByUserId));
			queryFansIdByUserId.forEach(userId ->{
				firendsRedisRepository.deleteFriends(userId);
			});
		});
	}

	public void deleteAllRoles(Integer userId){
		getRoleDao().deleteRole(userId);
	}
}
