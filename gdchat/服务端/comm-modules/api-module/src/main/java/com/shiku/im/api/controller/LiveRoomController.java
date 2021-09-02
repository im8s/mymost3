package com.shiku.im.api.controller;

import com.alibaba.fastjson.JSONObject;
import com.shiku.im.api.AbstractController;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.live.entity.LiveRoom;
import com.shiku.im.live.service.impl.LiveRoomManagerImpl;
import com.shiku.im.user.utils.KSessionUtil;
import com.shiku.im.vo.JSONMessage;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Api(value="LiveRoomController",tags="直播间接口")
@RestController
@RequestMapping(value ="/liveRoom",method={RequestMethod.GET,RequestMethod.POST})
public class LiveRoomController extends AbstractController {
	
	@Autowired
	private LiveRoomManagerImpl liveRoomManager;
	
	//获取直播间详情
	@ApiOperation("获取直播间详情")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="access_token" , value="授权钥匙",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="roomId" , value="直播间Id",dataType="String",required=true)
	})
	@RequestMapping(value = "/get")
	public JSONMessage getLiveRoom(@RequestParam(defaultValue="") String roomId) {
		Object data=null;
		try {
			LiveRoom room= liveRoomManager.getLiveRoomDao().get(new ObjectId(roomId));
			if(null!=room&&!room.getUrl().contains("//"))
				room.setUrl(KSessionUtil.getClientConfig().getLiveUrl()+room.getUrl());
			data=room;
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
		return JSONMessage.success(null,data);
	}
	
	//获取直播间详情
	@ApiOperation("获取直播间详情")
	@ApiImplicitParam(paramType = "query",name = "userId",value = "用户编号",defaultValue = "0")
	@RequestMapping(value = "/getLiveRoom")
	public JSONMessage getMyLiveRoom(@RequestParam(defaultValue = "0") Integer userId) {
		Object data = null;
		try {
			LiveRoom room = liveRoomManager.getLiveRoom(userId);
//			if (room != null && room.getUrl().contains("//"))
//				room.setUrl(KSessionUtil.getClientConfig().getLiveUrl() + room.getUrl());
			data = room;
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
		return JSONMessage.success(data);
	}
	
	//获取所有的直播房间
	@ApiOperation("获取直播间列表 ")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="name" , value="直播间名称（用于搜索）",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="nickName" , value="主播昵称（用于搜索）",dataType="String",required=true,defaultValue = ""),
		@ApiImplicitParam(paramType="query" , name="userId" , value="用户id",dataType="int",required=true,defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页码数",dataType="int",required=true,defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据条数",dataType="int",required=true,defaultValue = "10"),
			@ApiImplicitParam(paramType="query" , name="status" , value="状态",dataType="int",required=true,defaultValue = "-1")
	})
	@RequestMapping(value = "/list")
	public JSONMessage findLiveRoomList(@RequestParam(defaultValue="") String name,@RequestParam(defaultValue="") String nickName,
			@RequestParam(defaultValue="0") Integer userId,@RequestParam(defaultValue="0") Integer pageIndex,
			@RequestParam(defaultValue="10") Integer pageSize,@RequestParam(defaultValue="-1") Integer status) {
		
		try {
			Object data=liveRoomManager.findLiveRoomList(name, nickName, userId, pageIndex, pageSize,status,0);
			return JSONMessage.success(data);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
		
	}
	
	
	//创建直播间
	@ApiOperation("创建直播间 ")
	@RequestMapping(value = "/create")
	public JSONMessage createLiveRoom(@ModelAttribute LiveRoom room) {
		Object data=null;
		try {
			room.setUserId(ReqUtil.getUserId());
			data=liveRoomManager.createLiveRoom(room);
			return JSONMessage.success(data);
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}
	
	//更新直播间
	@ApiOperation("更新直播间")
	@RequestMapping(value = "/update")
	public JSONMessage updateLiveRoom(@ModelAttribute  LiveRoom room) {
		Map<String,Object> data=new HashMap<String,Object>();
		try {
			liveRoomManager.updateLiveRoom(ReqUtil.getUserId(),room);
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
		
		
	}
	//删除直播间
	@ApiOperation("删除直播间")
	@ApiImplicitParam(paramType="query" , name="roomId" , value="直播间Id",dataType="String",required=true,defaultValue = "")
	@RequestMapping(value = "/delete")
	public JSONMessage deleteLiveRoom(@RequestParam(defaultValue="")String roomId) {
		try {
			LiveRoom room = liveRoomManager.getLiveRoom(ReqUtil.getUserId());
			if(null!=room&&room.getRoomId().toString().equals(roomId)){
				liveRoomManager.deleteLiveRoom(new ObjectId(roomId));
				return JSONMessage.success();
			}else{
				return JSONMessage.failure(null);
			}

		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}
	//开始/结束直播
	@ApiOperation("查询房间成员")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="roomId" , value="直播间Id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="直播间Id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="直播间Id",dataType="String",required=true)
	})
	@RequestMapping(value = "/memberList")
	public JSONMessage findLiveRoomMemberList(@RequestParam(defaultValue="") String roomId ,@RequestParam(defaultValue="0") Integer pageIndex,@RequestParam(defaultValue="10") Integer pageSize) {
		Object data=null;
		ObjectId id=null;
		try {
			if(!StringUtil.isEmpty(roomId))
				id=new ObjectId(roomId);
			data=liveRoomManager.findLiveRoomMemberList(id,pageIndex,pageSize);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}

		return JSONMessage.success(null,data);
	}
	@ApiOperation("开始/结束直播")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType = "query",name = "roomId",value = "房间编号",dataType = "String"),
			@ApiImplicitParam(paramType = "query",name = "status",value = "状态",dataType = "int")
	})
	@RequestMapping(value="/start")
	public JSONMessage start(@RequestParam String roomId,@RequestParam int status){
		try {
			liveRoomManager.start(new ObjectId(roomId), status);
			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}
	//查询房间成员
	//获取单个成员
	@ApiOperation("获取单个成员")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="roomId" , value="直播间Id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="userId" , value="目标用户ID",dataType="int",required=true)
	})
	@RequestMapping(value="/get/member")
	public JSONMessage getLiveRoomMember(@RequestParam String roomId,@RequestParam Integer userId){
		Object data=null;
		data=liveRoomManager.getLiveRoomMember(new ObjectId(roomId), userId);
		if(data==null){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.UserNotInLiveRoom);
		}else{
			return JSONMessage.success(data);
		}
		
		
	}
	//加入直播间
	@ApiOperation("加入直播间")
	@ApiImplicitParam(paramType="query" , name="roomId" , value="直播间Id",dataType="String",required=true)
	@RequestMapping(value = "/enterInto")
	public JSONMessage enterIntoLiveRoom(@RequestParam(defaultValue="")String roomId) {
		/*Map<String,Object> data=new HashMap<String,Object>();*/
		boolean red=true;
		try {
			red=liveRoomManager.enterIntoLiveRoom(ReqUtil.getUserId(), new ObjectId(roomId));
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
		if(red==false){
			return JSONMessage.failure(null);
		}else{
			return JSONMessage.success();
		}
		
	}
	//退出直播间
	@ApiOperation("退出直播间")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="roomId" , value="直播间Id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="userId" , value="用户Id",dataType="int",required=true,defaultValue = "0")
	})
	@RequestMapping(value = "/quit")
	public JSONMessage exitLiveRoom(@RequestParam(defaultValue="")String roomId,@RequestParam(defaultValue="0")Integer userId) {
		try {
			logger.info("requtil  userId : {},  request  userId : {}",ReqUtil.getUserId(),userId);
			liveRoomManager.exitLiveRoom(ReqUtil.getUserId(), new ObjectId(roomId));
			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
		
	}
	
	//踢出直播间

	@ApiOperation("踢出直播间")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="roomId" , value="直播间Id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="userId" , value="用户Id",dataType="int",required=true)
	})
	@RequestMapping(value="/kick")
	public JSONMessage kick(@RequestParam String roomId,@RequestParam Integer userId){
		try {
			liveRoomManager.kick(userId, new ObjectId(roomId));
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
		return JSONMessage.success();
		
	}

	//开启/取消禁言
	@ApiOperation("开启/取消禁言")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="state" , value="状态值   1为禁言，0取消禁言",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="userId" , value="用户ID",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="roomId" , value="直播间Id",dataType="String",required=true)
	})
	@RequestMapping("/shutup")
	public JSONMessage shutup(@RequestParam(defaultValue = "") String talkTime,@RequestParam int state,@RequestParam Integer userId,@RequestParam String roomId){
		try {
			liveRoomManager.shutup(ReqUtil.getUserId(),state, userId,new ObjectId(roomId),talkTime);
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
		return JSONMessage.success();
	}
	
	
	//发送弹幕
	@ApiOperation("发送弹幕 ")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="userId" , value="用户ID",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="roomId" , value="直播间Id",dataType="ObjectId"),
		@ApiImplicitParam(paramType="query" , name="text" , value="弹幕内容",dataType="String")
	})
	@RequestMapping("/barrage")
	public JSONMessage barrage(@RequestParam Integer userId,@RequestParam ObjectId roomId,@RequestParam String text){
		JSONObject data=new JSONObject();
		ObjectId givegiftId;
		try {
			givegiftId=liveRoomManager.barrage(userId,roomId,text);
			data.put("givegiftId",givegiftId);
			return JSONMessage.success(null,data);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
		/*if(judge==true){
			return JSONMessage.success();
		}else{
			return JSONMessage.failure("余额不足");
		}*/
	}
	
	//显示所有礼物
	@ApiOperation("礼物列表")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="name" , value="礼物名称(用于搜索)",dataType="String",defaultValue = ""),
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页码数",dataType="int",defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据条数",dataType="int",defaultValue = "10")
	})
	@RequestMapping(value="/giftlist")
	public JSONMessage giftlist(@RequestParam(defaultValue="") String name ,@RequestParam(defaultValue="0") Integer pageIndex,@RequestParam(defaultValue="10") Integer pageSize){
		try {
			Object data=null;
			data=liveRoomManager.findAllgift(name,pageIndex, pageSize);
			if(null == data)
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NotHaveGift);
			return JSONMessage.success(data);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}
	
	
	
	//送礼物
	@ApiOperation("送礼物")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="userId" , value="用户ID",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="giftId" , value="礼物Id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="count" , value="数量",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="price" , value="价格",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="roomId" , value="直播间Id",dataType="int",required=true),
			@ApiImplicitParam(paramType="query" , name="toUserId" , value="目标用户编号",dataType="int",required=true)
	})
	@RequestMapping(value="/give")
	public JSONMessage give(@RequestParam Integer userId,@RequestParam Integer toUserId,@RequestParam String giftId,@RequestParam int count,
			@RequestParam Double price,@RequestParam String roomId){
			JSONObject data=new JSONObject();
			ObjectId giftid;
		try {
			giftid=liveRoomManager.giveGift(ReqUtil.getUserId(),toUserId ,new ObjectId(giftId), count, price,new ObjectId(roomId));
			data.put("giftId",giftid);
			return JSONMessage.success(null,data);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
		
	}
	
	/*//收到的礼物列表
	@RequestMapping(value="/getList")
	public JSONMessage get(@RequestParam Integer userId){
		Object data=null;
		data=liveRoomManager.getList(userId);
		JSONMessage.success(data);
	}*/
	
	//查询购买礼物的记录
	@ApiOperation("购买礼物的记录")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="userId" , value="用户ID",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据条数",dataType="int",defaultValue = "10"),
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页码数",dataType="int",defaultValue = "0")
	})
	@RequestMapping(value="/giftdeal")
	public JSONMessage giftdeal(@RequestParam Integer userId,@RequestParam(defaultValue="10") Integer pageSize,@RequestParam(defaultValue="0") Integer pageIndex){
		Object data=null;
		try {
			data=liveRoomManager.giftdeal(userId, pageIndex, pageSize);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return JSONMessage.success(data);
	}
	
	//设置管理员
	@ApiOperation("设置管理员")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , value="用户ID" , name="userId",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , value="类型值  1：创建者 2：管理员 3：成员" , name="type",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , value="直播间Id" , name="roomId",dataType="String",required=true)
	})
	@RequestMapping(value="/setmanage")
	public JSONMessage setManage(@RequestParam Integer userId,@RequestParam int type,@RequestParam String roomId){
		try {
			liveRoomManager.setmanage(userId,type,new ObjectId(roomId));
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}
	
	//点赞
	@ApiOperation("点赞")
	@ApiImplicitParam(paramType="query" , name="roomId" , value="直播间id",dataType="String",required=true)
	@RequestMapping(value="/praise")
	public JSONMessage addpraise(@RequestParam String roomId){
		try {
			liveRoomManager.addpraise(new ObjectId(roomId));
		} catch (Exception e) {
			e.printStackTrace();
		}
		return JSONMessage.success();
	}
	
	//清除过期直播间
	@ApiOperation("清除过期直播间")
	@RequestMapping(value="/clear")
	public JSONMessage clearLiveRoom(){
		try {
			liveRoomManager.clearLiveRoom();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return JSONMessage.success();
	}
	
}
