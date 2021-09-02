package com.shiku.im.api.controller;

import com.shiku.im.api.AbstractController;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.friends.entity.FriendGroup;
import com.shiku.im.friends.service.impl.FriendGroupManagerImpl;
import com.shiku.im.vo.JSONMessage;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
/**
* @Description: TODO(好友分组接口)
* 
* @date 2018年6月7日
 */

@Api(value="FriendGroupController",tags="好友分组接口")
@RestController
@RequestMapping(value="",method={RequestMethod.GET,RequestMethod.POST})
public class FriendGroupController extends AbstractController {
	
	@Autowired
	private FriendGroupManagerImpl friendGroupManager;

	//好友分组列表
	@ApiOperation("好友分组列表")
	@RequestMapping("/friendGroup/list")
	public JSONMessage friendGroupList() {
		Object data=null;
		try {
			data= friendGroupManager.queryGroupList(ReqUtil.getUserId());
			return JSONMessage.success(data);
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}

	@ApiOperation("添加好友列表")
	@RequestMapping("/friendGroup/add")
	public JSONMessage friendGroupAdd(@ModelAttribute FriendGroup group) {
		Object data=null;
		try {
			if(null!=friendGroupManager.queryGroupName(ReqUtil.getUserId(),group.getGroupName())){
				//分组名称已存在
				return JSONMessage.failureByErrCode(KConstants.ResultCode.GroupNameExist);
			}
			if(0==group.getUserId())
				group.setUserId(ReqUtil.getUserId());
			
			data=friendGroupManager.saveGroup(group);
			return JSONMessage.success(data);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}
	
	//更新分组的好友列表
	@ApiOperation("更新分组的好友列表")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="groupId" , value="分组编号",dataType="String",required=true,defaultValue = ""),
		@ApiImplicitParam(paramType="query" , name="userIdListStr" , value="用户列表编号",dataType="String",required=true,defaultValue = "")
	})
	@RequestMapping("/friendGroup/updateGroupUserList")
	public JSONMessage updateGroupUserList(@RequestParam(defaultValue="")String groupId,
			@RequestParam(defaultValue="")String userIdListStr) {
		try {
			if(!ObjectId.isValid(groupId))
				return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
			List<Integer> userIdList= StringUtil.getIntList(userIdListStr, ",");
			friendGroupManager.updateGroupUserList(ReqUtil.getUserId(),parse(groupId), userIdList);
			return JSONMessage.success();
			
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}
	
	@ApiOperation("更新好友")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="toUserId" , value="用户编号",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="groupIdStr" , value="分组编号",dataType="String",required=true,defaultValue = "")
	})
	@RequestMapping("/friendGroup/updateFriend")
	public JSONMessage updateFriend(@RequestParam Integer toUserId,@RequestParam(defaultValue="") String groupIdStr) {
		try {
			List<String> groupIdList = StringUtil.getListBySplit(groupIdStr,",");
			friendGroupManager.updateFriendGroup(ReqUtil.getUserId(), toUserId,groupIdList);
			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}
	
	@ApiOperation("修改好友列表")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="groupId" , value="分组编号",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="groupName" , value="分组姓名",dataType="String",required=true)
	})
	@RequestMapping("/friendGroup/update")
	public JSONMessage friendGroupUpdate(@RequestParam String groupId,@RequestParam String groupName) {
		try {
			if(!ObjectId.isValid(groupId))
				return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
			if(null!=friendGroupManager.queryGroupName(ReqUtil.getUserId(),groupName)){
				//分组名称已存在
				return JSONMessage.failureByErrCode(KConstants.ResultCode.GroupNameExist);
			}
			friendGroupManager.updateGroupName(ReqUtil.getUserId(),parse(groupId), groupName);
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}
	
	@ApiOperation("修改好友列表")
	@ApiImplicitParam(paramType="query" , name="groupId" , value="分组编号",dataType="String",required=true)
	@RequestMapping("/friendGroup/delete")
	public JSONMessage friendGroupDelete(@RequestParam String groupId) {
		try {
			if(!ObjectId.isValid(groupId))
				return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
			friendGroupManager.deleteGroup(ReqUtil.getUserId(),parse(groupId));
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}
	

}
