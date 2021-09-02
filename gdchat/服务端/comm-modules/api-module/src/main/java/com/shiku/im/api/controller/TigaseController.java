package com.shiku.im.api.controller;

import com.alibaba.fastjson.JSON;
import com.shiku.im.api.AbstractController;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.message.IMessageRepository;
import com.shiku.im.message.dao.TigaseMsgDao;
import com.shiku.im.room.entity.Room;
import com.shiku.im.room.service.RoomRedisRepository;
import com.shiku.im.room.service.impl.RoomManagerImplForIM;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.StringUtil;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Tigase支持接口
 * 
 * 
 *
 */

@RestController
@Api(value="TigaseController",tags="消息记录及漫游接口")
@RequestMapping(value="/tigase",method={RequestMethod.GET,RequestMethod.POST})
public class TigaseController extends AbstractController {

	@Autowired
	private IMessageRepository messageRepository;

	@Autowired
	private TigaseMsgDao tigaseMsgDao;

	@Autowired
	private RoomManagerImplForIM roomManager;

	@Autowired
	private RoomRedisRepository roomRedisRepository;

	

	

	// 单聊聊天记录
	@ApiOperation("单聊聊天记录")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="receiver" , value="接收者userId",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="startTime" , value="开始时间（单位：毫秒）",dataType="long",defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="endTime" , value="结束时间（单位：毫秒）",dataType="long",defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="页码（默认：0）",dataType="int",defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="页大小（默认：50）",dataType="int",defaultValue = "20"),
		@ApiImplicitParam(paramType="query" , name="maxType" , value="最大类型",dataType="int",defaultValue = "200")
	})
	@RequestMapping("/shiku_msgs")
	public JSONMessage queryChatMessageRecord(@RequestParam int receiver, @RequestParam(defaultValue = "0") long startTime,
											  @RequestParam(defaultValue = "0") long endTime, @RequestParam(defaultValue = "0") int pageIndex,
											  @RequestParam(defaultValue = "20") int pageSize, @RequestParam(defaultValue = "200") int maxType) {

		int sender = ReqUtil.getUserId();
		if (startTime > 0)
			startTime = (startTime / 1000) - 1;
		if (endTime > 0)
			endTime = (endTime / 1000) + 1;
		List<Document> list =tigaseMsgDao.
				queryChatMessageRecord(sender,receiver,startTime,endTime,pageIndex,pageSize,maxType);
		return JSONMessage.success(list);

	}

	// 群组聊天记录
	@ApiOperation("群聊聊天记录")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="roomId" , value="房间编号",dataType="int",required=true),
			@ApiImplicitParam(paramType="query" , name="startTime" , value="开始时间（单位：毫秒）",dataType="long",defaultValue = "0"),
			@ApiImplicitParam(paramType="query" , name="endTime" , value="结束时间（单位：毫秒）",dataType="long",defaultValue = "0"),
			@ApiImplicitParam(paramType="query" , name="pageIndex" , value="页码（默认：0）",dataType="int",defaultValue = "0"),
			@ApiImplicitParam(paramType="query" , name="pageSize" , value="页大小（默认：50）",dataType="int",defaultValue = "20"),
			@ApiImplicitParam(paramType="query" , name="maxType" , value="最大类型",dataType="int",defaultValue = "200")
	})
	@RequestMapping("/shiku_muc_msgs")
	public JSONMessage queryMucMsgs(@RequestParam String roomId, @RequestParam(defaultValue = "0") long startTime,
			@RequestParam(defaultValue = "0") long endTime, @RequestParam(defaultValue = "0") int pageIndex,
			@RequestParam(defaultValue = "20") int pageSize, @RequestParam(defaultValue = "200") int maxType) {

		/*if (startTime > 0)
			startTime = (startTime / 1000);
		if (endTime > 0)
			endTime = (endTime / 1000);*/
		/*
		 * if(maxType>0) q.put("contentType",new BasicDBObject(MongoOperator.LT,
		 * maxType));
		 */
		boolean flag = false;
		ObjectId roomObjId =roomManager.getRoomId(roomId);
		if (null != roomObjId) {
			Room.Member member =roomManager.getMember(roomObjId, ReqUtil.getUserId());
			if(null!=member&&null!=member.getCreateTime()){
				if (startTime >= 0  && startTime < member.getCreateTime()){
					startTime = member.getCreateTime();
					flag = true;
				}
			}

		}
		List<Document> list = tigaseMsgDao.queryMucMsgs(roomId,startTime,endTime,pageIndex,pageSize,maxType,flag);

		/* Collections.reverse(list);//倒序 */
		return JSONMessage.success("", list);
	}

	/**
	 * @Description: TODO(一段时间内最新的聊天历史记录) startTime 开始时间 毫秒数 endTime 结束时间 毫秒数
	 * @param @return 参数
	 */
	@ApiOperation("一段时间内最新的聊天历史记录")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="startTime" , value="开始时间",dataType="long",defaultValue = "0"),
			@ApiImplicitParam(paramType="query" , name="endTime" , value="结束时间",dataType="long",defaultValue = "0"),
			@ApiImplicitParam(paramType="query" , name="pageSize" , value="当前页",dataType="int",defaultValue = "0")
	})
	@RequestMapping("/getLastChatList")
	public JSONMessage queryLastChatList(@RequestParam(defaultValue = "0") long startTime,
			@RequestParam(defaultValue = "0") long endTime, @RequestParam(defaultValue = "0") int pageSize) {

		Integer userId = ReqUtil.getUserId();
		List<String> roomJidList = roomRedisRepository.queryUserRoomJidList(userId);
//		logger.info(" ===== lastChatList ===== : "+ JSON.toJSONString(roomJidList));
		List<Document> resultList =messageRepository.queryLastChatList(userId.toString(),startTime,endTime,pageSize,roomJidList);

		return JSONMessage.success(resultList);
	}

	/*
	 * @RequestMapping(value = "/push") public JSONMessage push(@RequestParam String
	 * text, @RequestParam String body) { System.out.println("push"); List<Integer>
	 * userIdList = JSON.parseArray(text, Integer.class); try { //String c = new
	 * String(body.getBytes("iso8859-1"),"utf-8");
	 * KXMPPServiceImpl.getInstance().send(userIdList,body); return
	 * JSONMessage.success(); } catch (Exception e) { e.printStackTrace(); } return
	 * JSONMessage.failure("推送失败"); // {userId:%1$s,toUserIdList:%2$s,body:'%3$s'} }
	 */



	// 获取消息接口(阅后即焚)
	// type 1 单聊 2 群聊
	@ApiOperation("获取消息接口")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="type" , value="聊天类型（默认1）  1 单聊  2 群聊",dataType="int"),
		@ApiImplicitParam(paramType="query" , name="messageId" , value="消息Id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="roomJid" , value="编号",dataType="ObjectId",required=true)
	})
	@RequestMapping("/getMessage")
	public JSONMessage getMessage(@RequestParam(defaultValue = "1") int type, @RequestParam String messageId,
			@RequestParam(defaultValue = "") String roomJid) throws Exception {
		return JSONMessage.success(tigaseMsgDao.queryMessage(ReqUtil.getUserId(),roomJid,messageId));

	}

	 /*删除消息接口
	 type 1 单聊 2 群聊
	 delete 1 删除属于自己的消息记录 2：撤回 删除 整条消息记录
	 */
	@ApiOperation("删除消息接口")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="type" , value="聊天类型 1 单聊  2 群聊",dataType="int",required=true,defaultValue = "1"),
		@ApiImplicitParam(paramType="query" , name="delete" , value="delete 1： 删除属于自己的消息记录 2：撤回 删除整条消息记录",dataType="int",required=true,defaultValue = "1"),
		@ApiImplicitParam(paramType="query" , name="messageId" , value="要删除的消息Id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="roomJid" , value="群组Jid",dataType="String",required=true)
	})
	@RequestMapping("/deleteMsg")
	public JSONMessage deleteMsg(@RequestParam(defaultValue = "1") int type,
			@RequestParam(defaultValue = "1") int delete, @RequestParam(defaultValue = "") String messageId,
			@RequestParam(defaultValue = "") String roomJid) throws Exception {
		if(StringUtil.isEmpty(messageId)){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
		}
		int sender = ReqUtil.getUserId();

		tigaseMsgDao.deleteMsgUpdateLastMessage(sender,roomJid,messageId,delete,type);
		return JSONMessage.success();

	}



	/**
	 * 单聊清空消息
	 * 
	 * @param toUserId
	 * @return
	 */
	// type 0 是清空单个 1 是 清空所有
	@ApiOperation("单聊清空消息")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="toUserId" , value="目标用户id",dataType="int",required=true,defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="type" , value="类型",dataType="int",required=true,defaultValue = "0")
	})
	@RequestMapping("/emptyMyMsg")
	public JSONMessage emptyMsg(@RequestParam(defaultValue = "0") int toUserId,
			@RequestParam(defaultValue = "0") int type) {

		int sender = ReqUtil.getUserId();
		tigaseMsgDao.cleanFriendMessage(sender,toUserId,type);
		return JSONMessage.success();

	}



	// 修改消息的已读状态

	@ApiOperation("修改消息的已读状态")
	@ApiImplicitParam(paramType="query" , name="messageId" , value="消息Id",dataType="String",required=true,defaultValue = "0")
	@RequestMapping("/changeRead")
	public JSONMessage changeRead(@RequestParam String messageId) throws Exception {

		tigaseMsgDao.changeMsgReadStatus(messageId,0,0);

		return JSONMessage.success();

	}

}
