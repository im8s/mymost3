package com.shiku.im.api.controller;

import cn.hutool.core.collection.CollUtil;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.shiku.common.model.PageVO;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.constants.KConstants.ResultCode;
import com.shiku.im.comm.constants.KConstants.Room_Role;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.config.AppConfig;
import com.shiku.im.friends.service.FriendsManager;
import com.shiku.im.message.dao.TigaseMsgDao;
import com.shiku.im.open.service.GroupHelperService;
import com.shiku.im.room.entity.Room;
import com.shiku.im.room.entity.Room.Member;
import com.shiku.im.room.entity.Room.Notice;
import com.shiku.im.room.service.impl.RoomManagerImplForIM;
import com.shiku.im.room.vo.RoomVO;
import com.shiku.im.user.entity.AuthKeys;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.impl.AuthKeysServiceImpl;
import com.shiku.im.user.service.impl.UserManagerImpl;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.StringUtil;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 群组接口
 * 
 * 
 *
 */

@Api(value="RoomController",tags="群组接口")
@RestController
@RequestMapping(value ="/room",method={RequestMethod.GET , RequestMethod.POST})
@Slf4j
public class RoomController {

	@Autowired
	private UserManagerImpl userManager;

	@Autowired
	private RoomManagerImplForIM roomManager;

	@Autowired
	private AuthKeysServiceImpl authKeysService;

	@Autowired
	private FriendsManager friendsManager;

	@Autowired
	private GroupHelperService groupHelperService;

	@Autowired
	private AppConfig appConfig;

	@Autowired
	private TigaseMsgDao tigaseMsgDao;


	/**
	 * 新增房间
	 *
	 * @param room
	 * @param text
	 * @return
	 */
	@ApiOperation("创建群组")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="room" , value="群组实体",dataType="Object",required=true),
		@ApiImplicitParam(paramType="query" , name="text" , value="要加入群组的用户userId集合（json字符串）",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="keys" , value="钥匙",dataType="String",required=true)
	})
	@RequestMapping("/add")
	public JSONMessage add(@ModelAttribute Room room, @RequestParam(defaultValue = "") String text, @RequestParam(defaultValue = "") String keys) {
		List<Integer> idList = StringUtil.isEmpty(text) ? null : JSON.parseArray(text, Integer.class);

		JSONObject userKeys = (!StringUtil.isEmpty(keys) && room.getIsSecretGroup()==1) ? JSON.parseObject(keys):null;

 		/*if(null!=roomManager.exisname(room.getName(),null)){
			return JSONMessage.failure("房间名已经存在");
		}*/
		Object data = roomManager.add(userManager.getUser(ReqUtil.getUserId()), room, idList,userKeys);
		return JSONMessage.success(data);
	}

	/**
	 * 删除房间
	 *
	 * @param roomId
	 * @return
	 */

	@ApiOperation("删除房间")
	@ApiImplicitParam(paramType="query" , name="roomId" , value="房间Id",dataType="String",required=true)
	@RequestMapping("/delete")
	public JSONMessage delete(@RequestParam String roomId) {
		try {
			int userId=ReqUtil.getUserId();
			ObjectId roomObjId;
			try {
				roomObjId=new ObjectId(roomId);
			}catch (Exception e){
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			}
			Room room = roomManager.getRoom(roomObjId);
			if(null == room){
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			}
			int role = roomManager.findMemberAndRole(roomObjId,userId);
			if(Room_Role.CREATOR!=role)
				return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
			roomManager.delete(roomObjId,userId);
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}

	/**
	 * 更新房间
	 *
	 * @param roomId
	 * @param roomName
	 * @param notice
	 * @param desc
	 * @return
	 */
	@ApiOperation("更新房间")
	@ApiImplicitParam(paramType="query" , name="roomId" , value="房间Id",dataType="String",required=true)
	@RequestMapping("/update")
	public JSONMessage update(@RequestParam String roomId,
			@ModelAttribute RoomVO roomVO) {
		try {
			int userId=ReqUtil.getUserId();
			ObjectId roomObjId;
			try {
				roomObjId=new ObjectId(roomId);
			}catch (Exception e){
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			}
			if(StringUtil.isEmpty(roomId))
				throw new ServiceException(ResultCode.ParamsAuthFail);
			Room room = roomManager.getRoom(roomObjId);
			if(null == room){
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			}
			int role = roomManager.findMemberAndRole(roomObjId,userId);
			if(0>role||Room_Role.MEMBER==role)
				return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);

			User user = userManager.getUser(userId);
			roomVO.setRoomId(new ObjectId(roomId));
			Object result= roomManager.update(user, roomVO,1,0);
			return JSONMessage.success(result);
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}

	/**
	 * 更新群组加密类型
	 * @param roomId
	 * @param encryptType
	* @return
	 */
	@ApiOperation("更新群组加密类型")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="roomId" , value="房间Id",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="encryptType" , value="加密类型",dataType="int",required=true,defaultValue = "0")
	})
	@RequestMapping("/updateEncryptType")
	public JSONMessage updateEncryptType(@RequestParam String roomId,
										 @RequestParam(defaultValue = "0") int encryptType ) {
		try {
			int userId=ReqUtil.getUserId();
			ObjectId roomObjId;
			try {
				roomObjId=new ObjectId(roomId);
			}catch (Exception e){
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			}
			if(StringUtil.isEmpty(roomId))
				throw new ServiceException(ResultCode.ParamsAuthFail);
			Room room = roomManager.getRoom(roomObjId);
			if(null == room){
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			}
			int role = roomManager.findMemberAndRole(roomObjId,userId);
			if(Room_Role.CREATOR!=role)
				return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
			roomManager.updateEncryptType(room,encryptType);
			 return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}
	/**
	 * 重置群组 chatGroppKey
	 * @param roomId
	 * @param encryptType
	 * @return
	 */
	@ApiOperation("重置群组 chatGroupKey")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="roomId" , value="群组Id",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="keys" , value="加密Key",dataType="String",required=true,defaultValue = "")
	})
	@RequestMapping("/resetGroupChatKey")
	public JSONMessage resetGroupChatKey(@RequestParam String roomId,
										 @RequestParam(defaultValue = "") String keys ) {
		try {
			int userId=ReqUtil.getUserId();
			ObjectId roomObjId;
			try {
				roomObjId=new ObjectId(roomId);
			}catch (Exception e){
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			}
			if(StringUtil.isEmpty(roomId))
				throw new ServiceException(ResultCode.ParamsAuthFail);
			Room room = roomManager.getRoom(roomObjId);
			if(null == room){
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			}
			int role = roomManager.findMemberAndRole(roomObjId,userId);
			if(Room_Role.CREATOR!=role)
				return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
			JSONObject userKeys = (!StringUtil.isEmpty(keys) && room.getIsSecretGroup()==1) ? JSON.parseObject(keys):null;
			roomManager.resetGroupChatKey(room,userKeys);
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}


	@ApiOperation("修改自己的群组 chatGroupKey")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="roomId" , value="群组Id",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="key" , value="chatGroupKey",dataType="String",required=true,defaultValue = "")
	})
	@RequestMapping("/updateGroupChatKey")
	public JSONMessage updateGroupChatKey(@RequestParam String roomId,
										 @RequestParam(defaultValue = "") String key ) {
		try {
			int userId=ReqUtil.getUserId();
			ObjectId roomObjId;
			try {
				roomObjId=new ObjectId(roomId);
			}catch (Exception e){
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			}
			if(StringUtil.isEmpty(roomId)||StringUtil.isEmpty(key))
				throw new ServiceException(ResultCode.ParamsAuthFail);
			Room room = roomManager.getRoom(roomObjId);
			if(null == room){
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			}
			int role = roomManager.findMemberAndRole(roomObjId,userId);
			if(0>role)
				return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
			roomManager.updateGroupChatKey(room, userId,key);
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}

	/**
	 * 获取群组成员 RSA 公钥
	 * @param roomId
	 * @param userId  群组成员 用户Id
	 * @return
	 */
	@ApiOperation("获取群组成员 RSA 公钥")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="roomId" , value="房间Id",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="userId" , value="用户编号",dataType="int",required=true,defaultValue = "0")
	})
	@RequestMapping("/getMemberRsaPublicKey")
	public JSONMessage getMemberRsaPublicKey(@RequestParam String roomId,
										 @RequestParam(defaultValue = "0") int userId ) {
		try {
			int myuserId=ReqUtil.getUserId();
			ObjectId roomObjId;
			try {
				roomObjId=new ObjectId(roomId);
			}catch (Exception e){
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			}
			if(StringUtil.isEmpty(roomId))
				throw new ServiceException(ResultCode.ParamsAuthFail);
			Room room = roomManager.getRoom(roomObjId);
			if(null == room){
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			}
			int myrole = roomManager.findMemberAndRole(roomObjId,myuserId);
			int role = roomManager.findMemberAndRole(roomObjId,userId);
			if(0>myrole||0>role)
				return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
			AuthKeys authKeys = authKeysService.getAuthKeys(userId);
			if(null!=authKeys&&null!=authKeys.getMsgRsaKeyPair()){
				Map<String,String> result=new HashMap<>();
				result.put("rsaPublicKey",authKeys.getMsgRsaKeyPair().getPublicKey());
				return JSONMessage.success(result);
			}
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}
	/**
	 * 获取群组所有成员 RSA 公钥
	 * @param roomId
	 * @param userId  群组成员 用户Id
	 * @return
	 */
	@ApiOperation("获取群组所有成员 RSA 公钥")
	@ApiImplicitParam(paramType="query" , name="roomId" , value="房间Id",dataType="String",required=true)
	@RequestMapping("/getAllMemberRsaPublicKey")
	public JSONMessage getAllMemberRsaPublicKey(@RequestParam String roomId) {
		try {
			int myuserId=ReqUtil.getUserId();
			ObjectId roomObjId;
			try {
				roomObjId=new ObjectId(roomId);
			}catch (Exception e){
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			}
			if(StringUtil.isEmpty(roomId))
				throw new ServiceException(ResultCode.ParamsAuthFail);
			Room room = roomManager.getRoom(roomObjId);
			if(null == room){
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			}
			int myrole = roomManager.findMemberAndRole(roomObjId,myuserId);
			if(0==myrole)
				return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
			List<Integer> memberIdList = roomManager.getMemberIdList(roomObjId);

			Map<String, String> resultMap = authKeysService.queryUseRSAPublicKeyList(memberIdList);

			return JSONMessage.success(resultMap);
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}

	/**
	 * 根据房间Id获取群组
	 * 包括 成员 列表
	 * 公告列表
	 * @param roomId
	 * @return
	 */
	@ApiOperation("根据房间Id获取群组")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="roomId" , value="群组Id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页",dataType="int",required=true,defaultValue = ""),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据量",dataType="int",required=true,defaultValue = "500"),
	})
	@RequestMapping("/get")
	public JSONMessage get(@RequestParam(defaultValue = "") String roomId,@RequestParam(defaultValue="0") Integer pageIndex,@RequestParam(defaultValue="100") Integer pageSize) {
		try {
			ObjectId roomObjId;
			try {
				roomObjId=new ObjectId(roomId);
			}catch (Exception e){
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			}
			Room data = roomManager.get(roomObjId,pageIndex,pageSize);
			if(null==data)
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			data.setMember(roomManager.getMember(roomObjId, ReqUtil.getUserId()));
			if (data.getUserSize()>50)data.setShowRead((byte)0);
			return JSONMessage.success(data);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}

	/**
	* @Description: TODO(只获取群组属性和群主管理员信息， 不包括 成员列表 和公告列表)
	* @param @param roomId
	* @param @return    参数
	 */
	@ApiOperation("只获取群组属性和群主管理员信息， 不包括 成员列表 和公告列表")
	@ApiImplicitParam(paramType="query" , name="roomId" , value="群组Id",dataType="String",required=true)
	@RequestMapping("/getRoom")
	public JSONMessage getRoom(@RequestParam String roomId) {
		try {
			ObjectId roomObjId=null;
			try {
				roomObjId=new ObjectId(roomId);
			}catch (Exception e){
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			}
 			Room data = roomManager.getRoom(roomObjId);
			if(null==data)
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			data.setMember(roomManager.getMember(roomObjId, ReqUtil.getUserId()));
			if (data.getUserSize()>50)data.setShowRead((byte) 0);
			return JSONMessage.success(data);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}

	}

	@ApiOperation("转让群主")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="roomId" , value="群组Id",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="toUserId" , value="目标用户编号",dataType="int",required=true,defaultValue = "0"),
	})
	@RequestMapping("/transfer")
	public JSONMessage transfer(@RequestParam String roomId,@RequestParam(defaultValue="0") Integer toUserId) {
		if(0==toUserId)
			return JSONMessage.failureByErrCode(ResultCode.SpecifyNewOwner);
		ObjectId roomObjId=null;
		try {
			roomObjId=new ObjectId(roomId);
		}catch (Exception e){
			return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
		}
		Room room = roomManager.getRoom(roomObjId);
		if(null==room)
			return JSONMessage.failureByErrCode(ResultCode.NotRoom);
		if(room.getS() == -1)
			return JSONMessage.failureByErrCode(ResultCode.RoomIsLock);
		else if(toUserId.equals(room.getUserId()))
			return JSONMessage.failureByErrCode(ResultCode.NotTransferToSelf);
		else if(!ReqUtil.getUserId().equals(room.getUserId()))
			return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
		else if (null==roomManager.getMember(roomObjId, toUserId)) {
			return JSONMessage.failureByErrCode(ResultCode.NotGroupMember);
		}
		try {
			roomManager.transfer(room, toUserId);
		}catch (Exception e){
			return JSONMessage.failureByException(e);
		}
		return JSONMessage.success();
	}

	/**
	 * 获取房间列表（按创建时间排序）
	 *
	 * @param pageIndex
	 * @param pageSize
	 * @return
	 */
	@ApiOperation("获取房间列表")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页码数",dataType="int",required=true,defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据条数",dataType="int",defaultValue = "10"),
		@ApiImplicitParam(paramType="query" , name="roomName" , value="群名称（用于搜索）",dataType="String")
	})
	@RequestMapping("/list")
	public JSONMessage list(@RequestParam(defaultValue = "0") int pageIndex,
			@RequestParam(defaultValue = "10") int pageSize, @RequestParam(defaultValue = "") String roomName) {
		Object data =null;
		if(0==appConfig.getIsBeta())
			data=roomManager.selectList(pageIndex, pageSize, roomName);

		return JSONMessage.success(data);
	}

	@ApiOperation("添加群成员")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="roomId" , value="群组Id",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="menber" , value="成员对象",dataType="int"),
		@ApiImplicitParam(paramType="query" , name="text" , value="要添加的成员用户Id集合（用于搜索）",dataType="String"),
			@ApiImplicitParam(paramType="query" , name="keys" , value="钥匙",dataType="String")
	})
	@RequestMapping("/member/update")
	public JSONMessage updateMember(@RequestParam String roomId, @ModelAttribute Member member, @RequestParam(defaultValue = "") String text, @RequestParam(defaultValue = "") String keys) {
		try {
			List<Integer> idList = StringUtil.isEmpty(text) ? null : JSON.parseArray(text, Integer.class);
			User user = userManager.getUser(ReqUtil.getUserId());
			ObjectId roomObjId=null;
			try {
				roomObjId=new ObjectId(roomId);
			}catch (Exception e){
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			}
			if(StringUtil.isEmpty(text)&&null==member.getUserId()) {
				return JSONMessage.failureByErrCode(ResultCode.ParamsLack);
			}else if(StringUtil.isEmpty(text)&&
					(null==member.getTalkTime()&&StringUtil.isEmpty(member.getRemarkName())
					&&0==member.getRole()&&StringUtil.isEmpty(member.getNickname())
						)) {
				return JSONMessage.failureByErrCode(ResultCode.ParamsLack);
			}

			Room room = roomManager.getRoom(roomObjId);
			if(null == room){
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			}else{
				if(-1 == room.getS())
					return JSONMessage.failureByErrCode(ResultCode.RoomIsLock);
				if (null == idList){
					Member optMember = roomManager.getMember(roomObjId, user.getUserId());
					int role= roomManager.findMemberAndRole(roomObjId, member.getUserId());
					if(null==optMember)
						return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
					else if(1!=optMember.getRole()&&role==Room_Role.ADMIN&&!optMember.getUserId().equals(user.getUserId()))
						return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
					else if(!StringUtil.isEmpty(member.getNickname())&&!optMember.getUserId().equals(member.getUserId()))
						return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
					else if(!user.getUserId().equals(member.getUserId())&&1!=optMember.getRole()&&role==Room_Role.ADMIN)
						return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
					if(null!=member.getTalkTime()) {
						if(role== KConstants.Room_Role.CREATOR)
							return JSONMessage.failureByErrCode(ResultCode.NotGroupMember);
						else if(optMember.getRole()==Room_Role.MEMBER)
							return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
					}
					roomManager.updateMember(user, roomObjId, member);
				}else{
					if(1==room.getIsNeedVerify()&&!user.getUserId().equals(room.getUserId()))
						return JSONMessage.failureByErrCode(ResultCode.InviteNeedAgree);
					if(!user.getUserId().equals(room.getUserId())&&1==idList.size()){
						if(null==friendsManager.getFriends(user.getUserId(), idList.get(0)))
							return JSONMessage.failureByErrCode(ResultCode.NotFriendNoInvite);
					}
					JSONObject userKeys = (!StringUtil.isEmpty(keys) && room.getIsSecretGroup()==1) ? JSON.parseObject(keys):null;

					roomManager.updateMember(user,roomObjId, idList,userKeys);
				}
			}
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
		return JSONMessage.success();
	}

	/**
	 * 批量删除成员
	 *
	 * @param roomId 房间id
	 * @param userIds 用户id列表
	 */
	@RequestMapping("/member/deleteBatch")
	public JSONMessage deleteMemberBatch(@RequestParam String roomId, @RequestParam List<Integer> userIds) {
		if (StringUtil.isEmpty(roomId) || CollUtil.isEmpty(userIds)) {
			return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
		}
		for (Integer userId : userIds) {
			try {
				this.doDelMember(roomId, userId);
			} catch (ServiceException e) {
				log.error("批量移除群成员部分失败,roomId:{}, userId:{}, 错误码:{}, 错误:{}", roomId, userId, e.getErrCode(), e.getErrMessage());
			}
		}
		return JSONMessage.success();
	}

	//退出群组
	@ApiOperation("退出群组")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="roomId" , value="房间Id",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="userId" , value="要删除的成员Id",dataType="int",required=true)
	})
	@RequestMapping("/member/delete")
	public JSONMessage deleteMember(@RequestParam String roomId, @RequestParam int userId) {
		try {
			this.doDelMember(roomId, userId);
			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}

	private void doDelMember(String roomId, int userId) throws ServiceException {
		User user = userManager.getUser(ReqUtil.getUserId());
		ObjectId roomObjId=null;
		try {
			roomObjId=new ObjectId(roomId);
		}catch (Exception e){
			throw new ServiceException(ResultCode.ParamsAuthFail);
		}
		Room room = roomManager.getRoom(roomObjId);
		if(null == room){
			throw new ServiceException(ResultCode.NotRoom);
		}
		if(-1 == room.getS()){
			throw new ServiceException(ResultCode.RoomIsLock);
		}
		int role = roomManager.findMemberAndRole(roomObjId,ReqUtil.getUserId());
		int toRole = roomManager.findMemberAndRole(roomObjId,userId);
		if(0>role)
			throw new ServiceException(ResultCode.NO_PERMISSION);
		else if(userId!=user.getUserId()) {
			if(Room_Role.MEMBER==role)
				throw new ServiceException(ResultCode.NO_PERMISSION);
			if(Room_Role.ADMIN==role&& Room_Role.ADMIN==toRole)
				throw new ServiceException(ResultCode.NO_PERMISSION);
		}
		roomManager.deleteMember(user,roomObjId, userId,false);
		try {
			tigaseMsgDao.deleteGroupMsgByUid(userId, room.getJid());
		} catch (Exception e) {
			log.error("踢人删除该用户聊天记录失败，uid:{}", userId, e);
		}
	}

	/** @Description:群消息的置顶和消息免打扰
	* @param offlineNoPushMsg 0:关闭,1:开启
	* @param roomId
	* @param userId
	* @param type = 0  消息免打扰 ,type = 1 聊天置顶
	* @return
	**/
	@ApiOperation("群消息的置顶和消息免打扰")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="roomId" , value="群组Id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="offlineNoPushMsg" , value="是否开启消息免打扰、聊天置顶0:关闭，1：开启",dataType="int",defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="type" , value="0 :消息免打扰 , 1: 聊天置顶,",dataType="int"),
		@ApiImplicitParam(paramType="query" , name="userId" , value="用户Id",dataType="int")
	})
	@RequestMapping("/member/setOfflineNoPushMsg")
	public JSONMessage setOfflineNoPushMsg(@RequestParam(defaultValue="0") int offlineNoPushMsg,@RequestParam String roomId,@RequestParam int userId,@RequestParam(defaultValue="0") int type){
		ObjectId roomObjId=null;
		try {
			roomObjId=new ObjectId(roomId);
		}catch (Exception e){
			return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
		}
        Integer userId1 = ReqUtil.getUserId();
        int role = roomManager.findMemberAndRole(roomObjId, userId1);
        if(0>role)
            return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
		Room room = roomManager.getRoom(roomObjId);
		if(null == room){
			return JSONMessage.failureByErrCode(ResultCode.NotRoom);
		}
		Integer offlineUserId = (0 != userId ? userId : userId1);
		roomManager.Memberset(offlineNoPushMsg, roomObjId, offlineUserId,type);
		return JSONMessage.success();
	}

	@ApiOperation("获取成员详情")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="roomId" , value="群组Id",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="userId" , value="目标成员userId",dataType="int",required=true,defaultValue = "0")
	})
	@RequestMapping("/member/get")
	public JSONMessage getMember(@RequestParam String roomId, @RequestParam(defaultValue="0") int userId) {
		if(0==userId)
			userId=ReqUtil.getUserId();
		ObjectId roomObjId=null;
		try {
			roomObjId=new ObjectId(roomId);
		}catch (Exception e){
			return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
		}
		Room room = roomManager.getRoom(roomObjId);
		if(null == room){
			return JSONMessage.failureByErrCode(ResultCode.NotRoom);
		}
		Member data = roomManager.getMember(roomObjId, userId);
		if(data==null)
			return JSONMessage.failureByErrCode(ResultCode.MemberNotInGroup);
		/*if(StringUtil.isEmpty(data.getCall()))
			data.setCall(roomManager.getCall(roomObjId));
		if(StringUtil.isEmpty(data.getVideoMeetingNo()))
			data.setVideoMeetingNo(roomManager.getVideoMeetingNo(roomObjId));*/
		return JSONMessage.success(data);
	}

	@ApiOperation("查询群成员")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="roomId" , value="群组Id",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="keyword" , value="关键字",dataType="String",required=true)
	})
	@RequestMapping("/member/list")
	public JSONMessage getMemberList(@RequestParam String roomId,@RequestParam(defaultValue="") String keyword) {
		Object data=null;
		try {
			ObjectId roomObjId=new ObjectId(roomId);
			Room room = roomManager.getRoom(roomObjId);
			if(null == room){
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			}
			int role = roomManager.findMemberAndRole(roomObjId,ReqUtil.getUserId());
			if(0>role)
				return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
			 data = roomManager.getMemberList(roomObjId,keyword);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}

		return JSONMessage.success(data);
	}

	/** @Description: 群成员列表分页
	* @param roomId
	* @param joinTime
	* @param pageIndex
	* @param pageSize
	* @return
	**/
	@ApiOperation("群成员列表分页")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="roomId" , value="群组d",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="joinTime" , value="连接时间",dataType="long",defaultValue = "0"),
			@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页",dataType="int"),
			@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据量",dataType="int",defaultValue = "100")
	})
	@RequestMapping("/member/getMemberListByPage")
	public JSONMessage getMemberListByPage(@RequestParam(defaultValue="") String roomId,@RequestParam(defaultValue="0") long joinTime,@RequestParam(defaultValue="") Integer pageIndex,@RequestParam(defaultValue="100") Integer pageSize) {
		try {
			ObjectId roomObjId=new ObjectId(roomId);
			Room room = roomManager.getRoom(roomObjId);
			if(null == room){
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			}
			int role = roomManager.findMemberAndRole(roomObjId,ReqUtil.getUserId());
			if (0 > role)
				return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
			List<Member> memberListByPage = roomManager.getMemberListByPageImpl(roomObjId,joinTime,pageSize);
			return JSONMessage.success(memberListByPage);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}

	@ApiOperation("获取群组公告列表")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="keyword" , value="重要单元",dataType="String",required=true,defaultValue = ""),
		@ApiImplicitParam(paramType="query" , name="roomId" , value="群组Id",dataType="String",required=true)
	})
	@RequestMapping("/notice/list")
	public JSONMessage getNoticeList(@RequestParam String roomId,@RequestParam(defaultValue="") String keyword) {
		Object data = roomManager.getNoticeList(new ObjectId(roomId));
		return JSONMessage.success(data);
	}

	//获取房间
	@ApiOperation("获取房间")
	@ApiImplicitParam(paramType="query" , name="roomId" , value="群组Id",dataType="String",required=true)
	@RequestMapping("/get/call")
	public JSONMessage getRoomCall(@RequestParam String roomId){
		Object data=roomManager.getCall(new ObjectId(roomId));
		return JSONMessage.success(data);

	}


	@ApiOperation("加入群组")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="roomId" , value="房间Id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="type" , value="1=自己的房间；2=加入的房间",dataType="int",defaultValue = "2")
	})
	@RequestMapping("/join")
	public JSONMessage join(@RequestParam String roomId, @RequestParam(defaultValue = "2") int type) {
		try {
			ObjectId roomObjId=new ObjectId(roomId);
			Room room = roomManager.getRoom(roomObjId);
			if(null == room){
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			}
			roomManager.join(ReqUtil.getUserId(),roomObjId, type);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
		return JSONMessage.success();
	}

	@ApiOperation("用户历史房间列表")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="type" , value="0=所有；1=自己的房间；2=加入的房间（默认为0）",dataType="int",defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页码数",dataType="int",defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据条数",dataType="int",defaultValue = "10")
	})
	@RequestMapping("/list/his")
	public JSONMessage historyList(@RequestParam(defaultValue = "0") int type,
			@RequestParam(defaultValue = "0") int pageIndex, @RequestParam(defaultValue = "10") int pageSize) {

		Object data = null;
		try {
			data = roomManager.selectHistoryList(ReqUtil.getUserId(), type, pageIndex, pageSize);
		}catch (ServiceException e){
			JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
		}
		return JSONMessage.success(data);
	}

	//设置/取消管理员
	@ApiOperation("设置/取消 管理员 ")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="roomId" , value="群组id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="touserId" , value="目标用户id",dataType="int"),
		@ApiImplicitParam(paramType="query" , name="type" , value="角色值 1=创建者、2=管理员、3=成员",dataType="int")
	})
	@RequestMapping("/set/admin")
	public JSONMessage setAdmin(@RequestParam String roomId,@RequestParam int touserId,@RequestParam int type){
		try {
			ObjectId roomObjId=new ObjectId(roomId);
			Room room = roomManager.getRoom(roomObjId);
			if(null == room){
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			}
			int role = roomManager.findMemberAndRole(roomObjId,ReqUtil.getUserId());
			if(Room_Role.CREATOR!=role)
				return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
			if(touserId == ReqUtil.getUserId())
				return JSONMessage.failureByErrCode(ResultCode.RoomOwnerNotSetAdmin);
			roomManager.setAdmin(roomObjId, touserId,type,ReqUtil.getUserId());
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}
		return JSONMessage.success();
	}

	@ApiOperation("设置/取消 群组中的大神、导师 标签")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="roomId" , value="群组id",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="touserId" , value="目标用户id",dataType="int"),
			@ApiImplicitParam(paramType="query" , name="type" , value="附属角色值标签类型 1=大神、2=导师",dataType="int"),
			@ApiImplicitParam(paramType="query" , name="operate" , value="操作类型 1=新增、2=取消",dataType="int")
	})
	@RequestMapping("/set/extRole")
	public JSONMessage setExtRole(@RequestParam String roomId,@RequestParam int toUserId,@RequestParam int type, @RequestParam int operate){
		String msg = "";
		if (1 == type && operate == 1) {
			msg = "新增大神成功!";
		} else if (1 == type && operate == 2) {
			msg = "取消大神成功!";
		} else if (2 == type && operate == 1) {
			msg = "新增导师成功!";
		} else if (2 == type && operate == 2) {
			msg = "取消导师成功!";
		}
		try {
			ObjectId roomObjId=new ObjectId(roomId);
			Room room = roomManager.getRoom(roomObjId);
			if(null == room){
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			}
			int role = roomManager.findMemberAndRole(roomObjId,ReqUtil.getUserId());
			if(Room_Role.CREATOR!=role && Room_Role.ADMIN!=role)
				return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
			roomManager.setExtRole(roomObjId, toUserId, type, ReqUtil.getUserId(), operate);
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}
		return JSONMessage.success(msg);
	}

	/** @Description:（设置/取消 隐身人、监护人（其他人完全看不到他；隐身人和监控人的区别是，前者不可以说话，后者能说话））
	* @param roomId 房间id
	* @param touserId  被指定人
 	* @param type 4:设置隐身人  -1:取消隐身人，5：设置监控人，0：取消监控人
	* @return
	**/
	@ApiOperation("设置/取消 隐身人、监护人（其他人完全看不到他；隐身人和监控人的区别是，前者不可以说话，后者能说话")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="roomId" , value="房间id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="touserId" , value="被指定人",dataType="int"),
		@ApiImplicitParam(paramType="query" , name="type" , value="4:设置隐身人  -1:取消隐身人，5：设置监控人，0：取消监控人",dataType="int")
	})
	@RequestMapping("/setInvisibleGuardian")
	public JSONMessage setInvisibleGuardian(@RequestParam String roomId,@RequestParam int touserId,@RequestParam int type){
		try {
			ObjectId roomObjId=new ObjectId(roomId);
			Room room = roomManager.getRoom(roomObjId);
			if(null == room){
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			}
			if(roomManager.getMember(roomObjId, ReqUtil.getUserId()).getRole()!=1)
				return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
			Member member = roomManager.getMember(roomObjId,touserId);
			if(null == member)
				return JSONMessage.failureByErrCode(ResultCode.MemberNotInGroup);
			int role = member.getRole();// 成员角色：1=创建者、2=管理员、3=普通成员、4=隐身人、5=监控人
			if((4 == type && role != 3)||(5 == type && role !=3)){
				return JSONMessage.failureByErrCode(ResultCode.NotRepeatOperation);
			}
			if(-1 == type && role != 4){
				return JSONMessage.failureByErrCode(ResultCode.MemberNotInvisible);
			}
			if(0 == type && role != 5){
				return JSONMessage.failureByErrCode(ResultCode.MemberNotMonitor);
			}
			roomManager.setInvisibleGuardian(new ObjectId(roomId), touserId,type,ReqUtil.getUserId());
		} catch (Exception e) {

		}
		return JSONMessage.success();
	}

	//添加（群共享）
	@ApiOperation("添加群共享")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="roomId" , value="群组id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="type" , value="类型",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="size" , value="文件大小",dataType="long",required=true),
		@ApiImplicitParam(paramType="query" , name="userId" , value="上传者userId",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="url" , value="文件url",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="name" , value="文件名称",dataType="String",required=true)
	})
	@RequestMapping("/add/share")
	public JSONMessage Addshare(@RequestParam ObjectId roomId,@RequestParam int type,@RequestParam long size,@RequestParam int userId
			,@RequestParam String url,@RequestParam String name){
		try {
			Room room = roomManager.getRoom(roomId);
			if(null == room){
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			}
			int role = roomManager.findMemberAndRole(roomId,ReqUtil.getUserId());
			if(0>role)
				return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);

			Object data=roomManager.Addshare(roomId,size,type ,userId, url,name);
			return JSONMessage.success(data);
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}

	}

	//查询(群共享)
	@ApiOperation("查询群共享")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="access_token" , value="访问令牌",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="roomId" , value="群组id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="time" , value="时间（用于搜索）",dataType="String"),
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页码数",dataType="String"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据条数",dataType="int"),
		@ApiImplicitParam(paramType="query" , name="userId" , value="用户id",dataType="int")
	})
	@RequestMapping("/share/find")
	public JSONMessage findShare(@RequestParam ObjectId roomId,@RequestParam(defaultValue="0") int pageIndex,@RequestParam(defaultValue="0") long time
			,@RequestParam(defaultValue="0") int userId,@RequestParam(defaultValue="10") int pageSize){
		Room room = roomManager.getRoom(roomId);
		if(null == room){
			return JSONMessage.failureByErrCode(ResultCode.NotRoom);
		}
		int role = roomManager.findMemberAndRole(roomId,ReqUtil.getUserId());
		if(0>role)
			return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
		Object data=roomManager.findShare(roomId, time, userId, pageIndex, pageSize);
		return JSONMessage.success(data);
	}

	@ApiOperation("获取群共享详情")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="roomId" , value="房间Id",dataType="ObjectId",required=true),
		@ApiImplicitParam(paramType="query" , name="shareId" , value="共享文件Id",dataType="ObjectId",required=true)
	})
	@RequestMapping("/share/get")
	public JSONMessage getShare(@RequestParam ObjectId roomId,@RequestParam ObjectId shareId){
		Room room = roomManager.getRoom(roomId);
		if(null == room){
			return JSONMessage.failureByErrCode(ResultCode.NotRoom);
		}
		int role = roomManager.findMemberAndRole(roomId,ReqUtil.getUserId());
		if(0>role)
			return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
		Object data=roomManager.getShare(roomId, shareId);
		return JSONMessage.success(data);
	}

	//删除
	@ApiOperation("删除群共享")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="roomId" , value="群组Id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="shareId" , value="共享文件Id",dataType="String"),
	})
	@RequestMapping("/share/delete")
	public JSONMessage deleteShare(@RequestParam String roomId,@RequestParam String shareId){
		ObjectId roomObjId=null;
		ObjectId shareObjId=null;
		try {
			roomObjId=new ObjectId(roomId);
			shareObjId=new  ObjectId(shareId);
		}catch (Exception e){
			return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
		}

		int userId=ReqUtil.getUserId();
		Room room = roomManager.getRoom(roomObjId);
		if(null == room){
			return JSONMessage.failureByErrCode(ResultCode.NotRoom);
		}
		final Room.Share share = roomManager.getShare(roomObjId, shareObjId);
		if(null==share)
			return JSONMessage.failureByErrCode(ResultCode.DataNotExists);
		int role = roomManager.findMemberAndRole(roomObjId,userId);
		if((0>role||Room_Role.MEMBER==role)&&userId!=share.getUserId())
			return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
		roomManager.deleteShare(roomObjId,shareObjId,userId);
		return JSONMessage.success();
	}


	//删除群公告
	@ApiOperation("删除群公告")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="roomId" , value="群组Id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="noticeId" , value="公告ID",dataType="String",required=true)
	})
	@RequestMapping("/notice/delete")
	public JSONMessage deleteNotice(@RequestParam(defaultValue = "") String roomId,
			@RequestParam(defaultValue = "") String noticeId) {
		ObjectId roomObjId=new ObjectId(roomId);

		try {
			Room room = roomManager.getRoom(roomObjId);
			if(null == room){
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			}
			if (StringUtil.isEmpty(roomId) || StringUtil.isEmpty(noticeId)) {
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			}
			int role = roomManager.findMemberAndRole(roomObjId,ReqUtil.getUserId());
			if(0>role||Room_Role.MEMBER==role)
				return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);

			roomManager.deleteNotice(roomObjId, new ObjectId(noticeId));
			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}

	}

	/**
	 * 发送群消息
	 * @param jid
	 * @return
	 */

	@ApiOperation("发送群消息")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="jidArr" , value="群组Id",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="userId" , value="用户编号",dataType="int",required=true,defaultValue = "1"),
			@ApiImplicitParam(paramType="query" , name="type" , value="类型",dataType="int",required=true,defaultValue = "1"),
			@ApiImplicitParam(paramType="query" , name="content" , value="内容",dataType="String",required=true,defaultValue = "")
	})
	@RequestMapping("/sendMsg")
	public JSONMessage sendMsg (@RequestParam(defaultValue="") String jidArr,@RequestParam(defaultValue="1") int userId,
			@RequestParam(defaultValue="1") int type,@RequestParam(defaultValue="")String content){
		String[] split = jidArr.split(",");

		roomManager.sendMsgToRooms(split, userId, type, content);

		return JSONMessage.success();

	}

	/** @Description:（公告列表）
	* @param roomId
	* @param pageIndex
	* @param pageSize
	* @return
	**/
	@ApiOperation("公告列表")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="roomId" , value="房间登入",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页",dataType="int",defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页大小",dataType="int",defaultValue = "10")
	})
	@RequestMapping("/noticesPage")
	public JSONMessage noticesPage(@RequestParam(defaultValue="") String roomId,@RequestParam(defaultValue = "0") int pageIndex,@RequestParam(defaultValue = "10") int pageSize){
		try {
			ObjectId roomObjId=new ObjectId(roomId);
			Room room = roomManager.getRoom(roomObjId);
			if(null == room){
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			}
			PageVO noticeList = roomManager.getNoticeList(roomObjId, pageIndex, pageSize);
			return JSONMessage.success(noticeList);
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/** @Description:修改群公告
	* @param roomId
	* @param noticeId
	* @param noticeContent
	* @return
	**/

	@ApiOperation("修改群公告")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="roomId" , value="群编号",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="noticeId" , value="注意编号",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="noticeContent" , value="注意内容",dataType="String",required=true)
	})
	@RequestMapping("/updateNotice")
	public JSONMessage updateNotice(@RequestParam(defaultValue="") String roomId,@RequestParam(defaultValue="") String noticeId,@RequestParam(defaultValue="") String noticeContent){
		try {
			Integer userId = ReqUtil.getUserId();
			ObjectId roomObjId=new ObjectId(roomId);
			Room room = roomManager.getRoom(roomObjId);
			if(null == room){
				return JSONMessage.failureByErrCode(ResultCode.NotRoom);
			}
			if(StringUtil.isEmpty(noticeContent) || StringUtil.isEmpty(roomId) || StringUtil.isEmpty(noticeId))
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			int role = roomManager.findMemberAndRole(roomObjId,ReqUtil.getUserId());
			if(0>role||Room_Role.MEMBER==role)
				return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
			Notice updateNotice = roomManager.updateNotice(roomObjId, new ObjectId(noticeId), noticeContent,userId);
			return JSONMessage.success(updateNotice);
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}
	}


	@ApiOperation("查询房间")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="name" , value="名称",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="longitude" , value="精度",dataType="double",required=true),
			@ApiImplicitParam(paramType="query" , name="latitude" , value="维度",dataType="double",required=true),
			@ApiImplicitParam(paramType="query" , name="password" , value="密码",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="isQuery" , value="是否查询",dataType="int",required=true),
	})
	@RequestMapping("/location/query")
	public JSONMessage queryLocationRoom(String name,double longitude,double latitude,String password,int isQuery){
		try {
			Room room = roomManager.queryLocationRoom(name, longitude, latitude, password,isQuery);
			return JSONMessage.success(room);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}


	@ApiOperation("连接房间")
	@ApiImplicitParam(paramType="query" , name="jid" , value="编号",dataType="String",required=true)
	@RequestMapping("/location/join")
	public JSONMessage joinLocationRoom(String jid){
		try {
			Room room =roomManager.joinLocationRoom(jid);
			return JSONMessage.success(room);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}

	@ApiOperation("退出房间")
	@ApiImplicitParam(paramType="query" , name="jid" , value="编号",dataType="String",required=true)
	@RequestMapping("/location/exit")
	public JSONMessage exitLocationRoom(String jid){
		try {
			roomManager.exitLocationRoom(jid);
			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}

	/**
	 * 添加群助手
	 * @param groupHelper
	 * @return
	 */
	@ApiOperation("添加群助手")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="helperId" , value="群助手编号",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="roomId" , value="房间编号",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="roomJid" , value="编号",dataType="String",required=true)
	})
	@RequestMapping("/addGroupHelper")
	public JSONMessage addGroupHelper(@RequestParam String helperId,@RequestParam String roomId,@RequestParam String roomJid){
		try {
			Integer userId = ReqUtil.getUserId();
			Object data = groupHelperService.addGroupHelper(helperId,roomId,roomJid,userId);
			return JSONMessage.success(data);
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * 添加自动回复关键字
	 * @param roomId
	 * @param keyword
	 * @param value
	 * @return
	 */
	@ApiOperation("添加自动回复关键字")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="helperId" , value="群助手编号",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="roomId" , value="房间编号",dataType="String",required=true,defaultValue = ""),
			@ApiImplicitParam(paramType="query" , name="roomJid" , value="编号",dataType="String",required=true,defaultValue = ""),
			@ApiImplicitParam(paramType="query" , name="value" , value="值",dataType="String",required=true,defaultValue = ""),
			@ApiImplicitParam(paramType="query" , name="keyword" , value="钥匙",dataType="String",required=true)
	})
	@RequestMapping("/addAutoResponse")
	public JSONMessage addAutoResponse(@RequestParam(defaultValue="") String helperId,@RequestParam(defaultValue="") String roomId,@RequestParam(defaultValue="") String keyword,@RequestParam(defaultValue="") String value){
		try {
			Object data = groupHelperService.addAutoResponse(roomId, helperId,keyword, value);
			return JSONMessage.success(data);
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * 更新自动回复关键字及回复
	 * @param keyWordId
	 * @param keyword
	 * @param value
	 * @return
	 */
	@ApiOperation("更新自动回复关键字及回复")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="groupHelperId" , value="群助手编号",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="keyWordId" , value="重要单元编号",dataType="String",required=true,defaultValue = ""),
			@ApiImplicitParam(paramType="query" , name="keyword" , value="重要单元",dataType="String",required=true,defaultValue = ""),
			@ApiImplicitParam(paramType="query" , name="value" , value="值",dataType="String",required=true,defaultValue = "")
	})
	@RequestMapping("/updateAutoResponse")
	public JSONMessage updateKeyWord(@RequestParam(defaultValue="") String groupHelperId,@RequestParam(defaultValue="") String keyWordId,@RequestParam(defaultValue="") String keyword,@RequestParam(defaultValue="") String value){
		try {
			Object data = groupHelperService.updateKeyword(groupHelperId,keyWordId, keyword, value);
			return JSONMessage.success(data);
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * 删除自动回复关键字
	 * @param groupHelperId
	 * @param keyWordId
	 * @return
	 */
	@ApiOperation("删除自动回复关键字")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="groupHelperId" , value="群助手编号",dataType="String",required=true,defaultValue = ""),
			@ApiImplicitParam(paramType="query" , name="keyWordId" , value="重要单元编号",dataType="String",required=true,defaultValue = "")
	})
	@RequestMapping("/deleteAutoResponse")
	public JSONMessage deleteAutoResponse(@RequestParam(defaultValue="") String groupHelperId,@RequestParam(defaultValue="") String keyWordId){
		try {
			Object data = groupHelperService.deleteAutoResponse(ReqUtil.getUserId(),groupHelperId, keyWordId);
			return JSONMessage.success(data);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}

	/**
	 * 删除群助手
	 * @param id
	 * @return
	 */
	@ApiOperation("删除群助手")
	@ApiImplicitParam(paramType="query" , name="groupHelperId" , value="群助手编号",dataType="String",required=true,defaultValue = "")
	@RequestMapping("/deleteGroupHelper")
	public JSONMessage deleteGroupHelper(@RequestParam(defaultValue="") String groupHelperId){
		try {

			groupHelperService.deleteGroupHelper(ReqUtil.getUserId(),groupHelperId);
			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}

	/**
	 * 查询房间群助手
	 * @param roomId
	 * @return
	 */
	@ApiOperation("查询房间群助手")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="roomId" , value="房间编号",dataType="String",required=true,defaultValue = ""),
			@ApiImplicitParam(paramType="query" , name="helperId" , value="群助手编号",dataType="String",required=true,defaultValue = "")
	})
	@RequestMapping("/queryGroupHelper")
	public JSONMessage queryGroupHelper(@RequestParam(defaultValue="") String roomId,@RequestParam(defaultValue="") String helperId){
		try {
			Object data = groupHelperService.queryGroupHelper(roomId,helperId);
			return JSONMessage.success(data);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}

	}

	/** @Description:群组复制
	* @param roomId
	* @return
	**/

	@ApiOperation("群复制 ")
	@ApiImplicitParam(paramType="query" , name="roomId" ,value="群组Id",dataType="String",required=true)
	@RequestMapping("/copyRoom")
	public JSONMessage copyRoom(@RequestParam(defaultValue="") String roomId){
		try {
			Integer userId = ReqUtil.getUserId();

			ObjectId roomObjId=new ObjectId(roomId);
			int role = roomManager.findMemberAndRole(roomObjId,ReqUtil.getUserId());
			if(Room_Role.CREATOR!=role)
				return JSONMessage.failureByErrCode(ResultCode.NO_PERMISSION);
			User user = userManager.getUser(userId);
			Room copyRoom = roomManager.copyRoom(user, roomId);
			return JSONMessage.success(copyRoom);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}
}

