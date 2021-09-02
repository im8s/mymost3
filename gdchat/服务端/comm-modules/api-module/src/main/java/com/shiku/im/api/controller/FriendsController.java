package com.shiku.im.api.controller;

import com.shiku.im.api.AbstractController;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.friends.entity.Friends;
import com.shiku.im.friends.service.impl.FriendsManagerImpl;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.impl.UserManagerImpl;
import com.shiku.im.vo.JSONMessage;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 关系接口
 * 
 * 
 *
 */

@Api(value="FriendsController",tags="好友关注接口")
@RestController
@RequestMapping(value="/friends",method={RequestMethod.GET,RequestMethod.POST})
public class FriendsController extends AbstractController {

	/** @Description: 新增关注
	* @param toUserId
	* @param fromAddType 1:二维码 2：名片 3：群组 4： 手机号搜索 5： 昵称搜索6:其他方式添加
	* @return
	**/ 
	
	@Autowired
	private UserManagerImpl userManager;

	@Autowired
	private FriendsManagerImpl friendsManager;

	@ApiOperation("加关注")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="toUserId" , value="被关注用户Id",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="fromAddType" , value="添加好友的方式",dataType="int",required=true,defaultValue = "0"),
			@ApiImplicitParam(paramType="query" , name="addMethod" , value="添加或同意0-添加，1-同意",dataType="int",required=true,defaultValue = "0")
	})
	@RequestMapping("/attention/add")
	public JSONMessage addAtt(@RequestParam Integer toUserId, @RequestParam(defaultValue = "0") Integer fromAddType, @RequestParam(defaultValue = "0") Integer addMethod) {
		try {
			int userId=ReqUtil.getUserId();
			User user = userManager.getUser(userId);
			//普通会员不能加好友
			if (addMethod.equals(0) && !new Integer(1).equals(user.getPermitUserType())) {
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NotAddFriend);
			}
			if(userId==toUserId) {
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NotAddSelf);
			}
			String friendFroms = userManager.getUser(toUserId).getSettings().getFriendFromList();
			List<Integer> friendFromList = StringUtil.getIntList(friendFroms, ",");
			if (null == friendFromList || 0 == friendFromList.size())
				// 添加失败,该用户禁止该方式添加好友
				return JSONMessage.failureByErrCode(KConstants.ResultCode.ProhibitAddFriends);
//				return JSONMessage.failure("添加失败,该用户禁止该方式添加好友");
			else {
				if (!fromAddType.equals(0) && !fromAddType.equals(6) && !friendFromList.contains(fromAddType)) {
					return JSONMessage.failureByErrCode((fromAddType.equals(1) ? KConstants.ResultCode.NotQRCodeAddFriends
							: fromAddType.equals(2) ? KConstants.ResultCode.NotCardAddFriends
									: fromAddType.equals(3) ? KConstants.ResultCode.NotFromGroupAddFriends
											: fromAddType.equals(4) ? KConstants.ResultCode.NotTelephoneAddFriends
													: fromAddType.equals(5) ? KConstants.ResultCode.NotNickNameAddFriends : KConstants.ResultCode.AddFriendsFailure));
				}
			}
			JSONMessage followUser = friendsManager.followUser(userId, toUserId, fromAddType);
			return followUser;
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failureByErrCode(KConstants.ResultCode.AddFriendsFailure);
		}
	}
	
	/** @Description:（批量添加好友） 
	* @param toUserId
	* @return
	**/

	@ApiOperation("批量添加好友")
	@ApiImplicitParam(paramType="query" , name="toUserIds" , value="被关注用户Id",dataType="String",required=true)
	@RequestMapping("/attention/batchAdd")
	public JSONMessage addFriends(@RequestParam(value = "toUserIds") String toUserIds) {
		int userId=ReqUtil.getUserId();
		User user = userManager.getUser(userId);
		if (!new Integer(1).equals(user.getPermitUserType())) {
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NotAddFriend);
		}
		return friendsManager.batchFollowUser(ReqUtil.getUserId(), toUserIds);
	}
	
	//添加黑名单
	@ApiOperation("添加黑名单")
	@ApiImplicitParam(paramType="query" , name="toUserId" , value="拼接的被关注用户Id（用逗号分隔）",dataType="int",required=true)
	@RequestMapping("/blacklist/add")
	public JSONMessage addBlacklist(@RequestParam Integer toUserId) {
		int userId=ReqUtil.getUserId();
		if(userId==toUserId) {
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NotOperateSelf);
		}
		if(friendsManager.isBlack(toUserId))
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NotRepeatOperation);
		Object data=friendsManager.addBlacklist(ReqUtil.getUserId(), toUserId);
		return JSONMessage.success(data);
	}
	
	//加好友
	@ApiOperation("同意加好友")
	@ApiImplicitParam(paramType="query" , name="toUserId" , value="目标用户Id",dataType="int",required=true)
	@RequestMapping("/add")
	public JSONMessage addFriends(@RequestParam(value = "toUserId") Integer toUserId) {
		int userId=ReqUtil.getUserId();
		if(userId==toUserId) {
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NotAddSelf);
		}
		Friends friends = friendsManager.getFriends(userId, toUserId);
		if(null!=friends)
			return JSONMessage.failureByErrCode(KConstants.ResultCode.FriendsIsExist);
		friendsManager.addFriends(userId, toUserId);

		return JSONMessage.success();
	}
	
	
	//修改好友 属性
	@ApiOperation("修改好友 属性")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="toUserId" , value="目标用户Id",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="chatRecordTimeOut" , value="好友聊天记录删除时间 1天=1.0",dataType="String",defaultValue = "-1")
	})
	@RequestMapping("/update")
	public JSONMessage updateFriends(@RequestParam(value = "toUserId") Integer toUserId,@RequestParam(defaultValue="-1") String chatRecordTimeOut) {
		Friends friends = friendsManager.getFriends(ReqUtil.getUserId(), toUserId);
		
		if(null==friends)
			 return JSONMessage.failureByErrCode(KConstants.ResultCode.FriendsNotExist);
		double recordTimeOut=-1;
		recordTimeOut=Double.valueOf(chatRecordTimeOut);
		friends.setChatRecordTimeOut(recordTimeOut);
		friendsManager.updateFriends(friends);

		return JSONMessage.success();
	}
	
	
	//移出黑名单
	@ApiOperation("取消拉黑")
	@ApiImplicitParam(paramType="query" , name="toUserId" , value="目标用户Id",dataType="int",required=true)
	@RequestMapping("/blacklist/delete")
	@ResponseBody
	public JSONMessage deleteBlacklist(@RequestParam Integer toUserId) {
		if(!friendsManager.isBlack(toUserId))
//			return JSONMessage.failure("好友："+toUserId+"不在我的黑名单中");
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NotOnMyBlackList);
		Object data = friendsManager.deleteBlacklist(ReqUtil.getUserId(), toUserId);
		return JSONMessage.success(data);
	}
	
	//取消关注
	@ApiOperation("取消关注")
	@ApiImplicitParam(paramType="query" , name="toUserId" , value="目标用户Id",dataType="int",required=true)
	@RequestMapping("/attention/delete")
	public JSONMessage deleteFollow(@RequestParam(value = "toUserId") Integer toUserId) {
		int userId=ReqUtil.getUserId();
		if(userId==toUserId) {
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NotOperateSelf);
		}
		friendsManager.unfollowUser(userId, toUserId);
		return JSONMessage.success();
	}
	
	//删除好友
	@ApiOperation("删除好友")
	@ApiImplicitParam(paramType="query" , name="toUserId" , value="目标用户Id",dataType="int",required=true)
	@RequestMapping("/delete")
	public JSONMessage deleteFriends(@RequestParam Integer toUserId) {
		try {
			Integer userId = ReqUtil.getUserId();
			if(userId==toUserId) {
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NotOperateSelf);
			}
			Friends friends = friendsManager.getFriends(userId, toUserId);
			if(null==friends)
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NotYourFriends);
			friendsManager.deleteFriends(userId, toUserId);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
		return JSONMessage.success();
	}

	//修改备注
	@ApiOperation("修改备注")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="toUserId" , value="目标用户Id",dataType="int",required=true,defaultValue = ""),
		@ApiImplicitParam(paramType="query" , name="remarkName" , value="备注名",dataType="String",required=true,defaultValue = ""),
			@ApiImplicitParam(paramType="query" , name="describe" , value="描述",dataType="String",required=true,defaultValue = "")
	})
	@RequestMapping("/remark")
	public JSONMessage friendsRemark(@RequestParam int toUserId, @RequestParam(defaultValue = "") String remarkName,@RequestParam(defaultValue = "") String describe) {
		try {
			friendsManager.updateRemark(ReqUtil.getUserId(), toUserId, remarkName,describe);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
		return JSONMessage.success();
	}
	
	//黑名单列表
	@ApiOperation("黑名单列表")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页",dataType="int",required=true,defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页大小",dataType="int",required=true,defaultValue = "10")
	})
	@RequestMapping("/blacklist")
	public JSONMessage queryBlacklist(@RequestParam(defaultValue="0") int pageIndex,@RequestParam(defaultValue="10") int pageSize) {
		List<Friends> data = friendsManager.queryBlacklist(ReqUtil.getUserId(),pageIndex,pageSize);

		return JSONMessage.success(data);
	}


	//适用于web黑名单分页
	@ApiOperation("适用于web黑名单分页")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页",dataType="int",required=true,defaultValue = "0"),
			@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页大小",dataType="int",required=true,defaultValue = "10")
	})
	@RequestMapping("/queryBlacklistWeb")
	public JSONMessage queryBlacklistWeb(@RequestParam(defaultValue="0") int pageIndex,@RequestParam(defaultValue="10") int pageSize) {
		Object queryBlacklistWeb = friendsManager.queryBlacklistWeb(ReqUtil.getUserId(),pageIndex,pageSize);
		return JSONMessage.success(queryBlacklistWeb);
	}
	
	//粉丝列表
	@ApiOperation("获取粉丝列表")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="userId" , value="用户Id",dataType="String"),
			@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页码数",dataType="String"),
			@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据条数",dataType="String")
	})
	@RequestMapping("/fans/list")
	public JSONMessage queryFans(@RequestParam(defaultValue = "0") Integer userId) {

		return JSONMessage.success();
	}
	
	//关注列表
	@ApiOperation("关注列表")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="userId" , value="用户Id",dataType="int",defaultValue = ""),
		@ApiImplicitParam(paramType="query" , name="status" , value="状态值，默认值0 （1=关注；2=好友；0=陌生人）",dataType="int")
	})
	@RequestMapping("/attention/list")
	public JSONMessage queryFollow(@RequestParam(defaultValue = "") Integer userId,@RequestParam(defaultValue = "0")int status) {
		List<Friends> data = friendsManager.queryFollow(ReqUtil.getUserId(),status);

		return JSONMessage.success(data);
	}
	

	@ApiOperation("获取好友详情")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="userId" , value="用户Id",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="toUserId" , value="目标用户Id",dataType="int",required=true)
	})
	@RequestMapping("/get")
	public JSONMessage getFriends(@RequestParam(defaultValue = "") Integer userId,int toUserId) {
		userId = ReqUtil.getUserId();
		//userId = (null == userId ? ReqUtil.getUserId() : userId);
		Friends data = friendsManager.getFriends(userId, toUserId);

		return JSONMessage.success(data);
	}
	

	@ApiOperation("获取好友列表")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="userId" , value="用户Id",dataType="int",required=true,defaultValue = ""),
		@ApiImplicitParam(paramType="query" , name="keyword" , value="关键词（用于搜索）",dataType="int",defaultValue = "")
	})
	@RequestMapping("/list")
	public JSONMessage queryFriends(@RequestParam(defaultValue="") Integer userId,@RequestParam(defaultValue="") String keyword) {
		//userId = (null == userId ? ReqUtil.getUserId() : userId);
		userId =ReqUtil.getUserId();
		Object data = friendsManager.queryFriends(userId);

		return JSONMessage.success(data);
	}

	@ApiOperation("查找好友")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="userId" , value="用户Id",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="keyword" , value="关键词（用于搜索）",dataType="String",defaultValue = ""),
		@ApiImplicitParam(paramType="query" , name="status" , value="状态",dataType="int",defaultValue = "2"),
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页",dataType="int",defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据大小",dataType="int",defaultValue = "10"),
	})
	@RequestMapping("/page")
	public JSONMessage getFriendsPage(@RequestParam Integer userId,@RequestParam(defaultValue="") String keyword,
			@RequestParam(defaultValue = "2") int status,
			@RequestParam(defaultValue = "0") int pageIndex,
			@RequestParam(defaultValue = "10") int pageSize) {
		userId =ReqUtil.getUserId();
		Object data = friendsManager.queryFriends(userId,status,keyword, pageIndex, pageSize);

		return JSONMessage.success(data);
	}

	
	/** @Description:是否开启或关闭消息免打扰、阅后即焚、聊天置顶
	* @param userId
	* @param toUserId
	* @param offlineNoPushMsg  0:关闭,1:开启
	* @param type  type = 0  消息免打扰 ,type = 1  阅后即焚 ,type = 2 聊天置顶
	* @return
	**/
	@ApiOperation("好友消息免打扰，阅后即焚，聊天置顶")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="offlineNoPushMsg" , value="是否开启消息免打扰，阅后即焚，聊天置顶",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="userId" , value="目标用户Id",dataType="int",defaultValue = ""),
		@ApiImplicitParam(paramType="query" , name="type" , value="type = 0  消息免打扰 ,type = 1  阅后即焚 ,type = 2 聊天置顶",dataType="int",defaultValue = ""),
			@ApiImplicitParam(paramType="query" , name="toUserId" , value="目标用户编号",dataType="int",defaultValue = "0")
	})
	@RequestMapping("/update/OfflineNoPushMsg")
	public JSONMessage updateOfflineNoPushMsg(@RequestParam Integer userId,@RequestParam Integer toUserId,@RequestParam(defaultValue="0") int offlineNoPushMsg,@RequestParam(defaultValue = "0")int type){
		try {
			Friends data=friendsManager.updateOfflineNoPushMsg(ReqUtil.getUserId(),toUserId,offlineNoPushMsg,type);
			return JSONMessage.success(data);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}
	
	

	@ApiOperation("获取好友的userId 和单向关注的userId  或黑名单的userId")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="userId" , value="用户ID",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="type" , value="类型",dataType="String",required=true)
	})
	@RequestMapping("/friendsAndAttention") //返回好友的userId 和单向关注的userId  及黑名单的userId
	public JSONMessage getFriendsPage(@RequestParam Integer userId,@RequestParam(defaultValue="") String type) {
		Object data = friendsManager.friendsAndAttentionUserId(ReqUtil.getUserId(),type);
		return JSONMessage.success(data);
	}
	

	@ApiOperation("获取新的朋友列表")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="userId" , value="用户ID",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页码数",dataType="int",defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据条数",dataType="int",defaultValue = "10")
	})
	@RequestMapping("/newFriend/list")
	public JSONMessage newFriendList(@RequestParam Integer userId,@RequestParam(defaultValue="0") int pageIndex,
			@RequestParam(defaultValue="10") int pageSize) {
		Object data = friendsManager.newFriendList(ReqUtil.getUserId(), pageIndex, pageSize);

		return JSONMessage.success(data);
	}
	

	@ApiOperation("新朋友列表")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="userId" , value="用户ID",dataType="int",required=true),
			@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页码数",dataType="int",defaultValue = "0"),
			@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据条数",dataType="int",defaultValue = "10")
	})
	@RequestMapping("/newFriendListWeb")
	public JSONMessage newFriendListWeb(@RequestParam Integer userId,@RequestParam(defaultValue="0") int pageIndex,
			@RequestParam(defaultValue="10") int pageSize) {
		try {
			Object data = friendsManager.newFriendListWeb(ReqUtil.getUserId(), pageIndex, pageSize);
			return JSONMessage.success(data);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}


	@ApiOperation("H5新朋友的单条最新记录")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="toUserId" , value="对方用户ID",dataType="int",required=true)
	})
	@RequestMapping("/newFriend/last")
	public JSONMessage newFriendListWeb(@RequestParam Integer toUserId) {
		try {
			Object data = friendsManager.newFriendLast(ReqUtil.getUserId(), toUserId);
			return JSONMessage.success(data);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}


	
	/*
	 * @RequestMapping("/addAllFriendsSys") public JSONMessage
	 * addAllFriendsSys(@RequestParam(defaultValue="10000") Integer toUserId) {
	 * List<Integer> userIds=SKBeanUtils.getUserManager().getAllUserId();
	 * ExecutorService pool = Executors.newFixedThreadPool(10); for (Integer userId
	 * : userIds) { pool.execute(new Runnable() {
	 * 
	 * @Override public void run() {
	 * friendsManager.followUser(userId, toUserId, 0); } });
	 * 
	 * } return JSONMessage.success(); }
	 */

	/**
	 * 修改和该好友的消息加密方式
	 * @param userId
	 * @param pageIndex
	 * @param pageSize
	 * @return
	 */
	@ApiOperation("修改和该好友的消息加密方式")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="toUserId" , value="目标用户编号",dataType="int",required=true),
			@ApiImplicitParam(paramType="query" , name="encryptType" , value="加密类型",dataType="byte",defaultValue = "0")
	})
	@RequestMapping("/modify/encryptType")
	public JSONMessage modifyEncryptType(@RequestParam Integer toUserId,@RequestParam(defaultValue="0") byte encryptType) {
		try {
			friendsManager.modifyEncryptType(ReqUtil.getUserId(),toUserId,encryptType);

			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}

}
