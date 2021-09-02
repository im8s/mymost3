package com.shiku.im.api.controller;

import com.alibaba.fastjson.JSON;
import com.shiku.im.api.AbstractController;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.constants.MsgType;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.friends.entity.Friends;
import com.shiku.im.friends.service.FriendsManager;
import com.shiku.im.msg.entity.Msg;
import com.shiku.im.msg.model.AddCommentParam;
import com.shiku.im.msg.model.AddGiftParam;
import com.shiku.im.msg.model.AddMsgParam;
import com.shiku.im.msg.model.MessageExample;
import com.shiku.im.msg.service.impl.*;
import com.shiku.im.user.dao.impl.CollectionDaoImpl;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.StringUtil;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.bson.types.ObjectId;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 商务圈接口
 * 
 * 
 *
 */
@Api(value="MsgController",tags="商务圈接口")
@RestController
@RequestMapping(value="/b/circle/msg",method={RequestMethod.GET,RequestMethod.POST})
public class MsgController extends AbstractController {

	private static Logger logger = LoggerFactory.getLogger(MsgController.class);
	@Autowired
	private MsgManagerImpl msgManager;
	@Autowired
	private MsgCommentManagerImpl msgCommentManager;
	@Autowired
	private MsgPraiseManagerImpl msgPraiseManager;
	@Autowired
	private MsgGiftManagerImpl msgGiftManager;
	@Autowired
	private MsgListManagerImpl msgListManager;
	@Autowired
	private MsgPlayAmountMangerImpl msgPlayAmountManger;
	@Autowired
	private MsgForwardAmountManagerImpl msgForwardAmountManager;

	@Autowired
	private FriendsManager friendsManager;

	@Autowired
	private CollectionDaoImpl collectionDao;

	@ApiOperation("获取最热信息列表")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="cityId" , value="城市编号",dataType="int",required=true,defaultValue = "0"),
			@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页",dataType="int",required=true,defaultValue = "0")
	})
	@RequestMapping(value = "/hot")
	public JSONMessage getHostMsgList(@RequestParam(defaultValue = "0") int cityId,
									  @RequestParam(defaultValue = "0") Integer pageIndex) {
		Object data = msgListManager.getHotList(cityId, pageIndex, 0);
		return JSONMessage.success(null, data);
	}

	@ApiOperation("获取最近列表")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="cityId" , value="城市编号",dataType="int",required=true,defaultValue = "0"),
			@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页",dataType="int",required=true,defaultValue = "0")
	})
	@RequestMapping(value = "/latest")
	public JSONMessage getLatestMsgList(@RequestParam(defaultValue = "0") int cityId,
			@RequestParam(defaultValue = "0") Integer pageIndex) {
		Object data = msgListManager.getLatestList(cityId, pageIndex, 0);
		return JSONMessage.success(null, data);
	}

	//评论
	@ApiOperation("评论")
	@RequestMapping(value = "/comment/add")
	public JSONMessage addComment(@ModelAttribute AddCommentParam param) {
		JSONMessage jMessage;
		int userId = ReqUtil.getUserId();
		if (StringUtil.isEmpty(param.getMessageId())) {
			jMessage = JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
		} else {
			try {
				if(StringUtil.isEmpty(param.getBody()))
					return JSONMessage.failureByErrCode(KConstants.ResultCode.CommentNotNull);
				Msg msg = msgManager.get(0,parse(param.getMessageId()));
				if(null==msg){
					return JSONMessage.failureByErrCode(KConstants.ResultCode.ContenNoExist);
				} else if (1 == msg.getIsAllowComment() && userId != msg.getUserId()) {
					return JSONMessage.failureByErrCode(KConstants.ResultCode.NotComment);
				}
				Friends friends = friendsManager.getFriends(userId, msg.getUserId());
				if((null==friends||1==friends.getIsBeenBlack())&&!msg.getUserId().equals(userId)){
					return JSONMessage.failureByErrCode(KConstants.ResultCode.NotYourFriends);
				}

				ObjectId data = msgCommentManager.add(userId, param);
				jMessage = null == data ? JSONMessage.failure(null) : JSONMessage.success(null, data);
			} catch (ServiceException e) {
				return JSONMessage.failureByException(e);
			}
		}

		return jMessage;
	}


	@ApiOperation("送礼物")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="messageId" , value="圈子消息Id",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="gifts" , value="礼物列表（json字符串）",dataType="String",required=true)
		})
	@RequestMapping(value = "/gift/add")
	public JSONMessage addGift(@RequestParam String messageId, @RequestParam String gifts) {
		JSONMessage jMessage;

		if (StringUtil.isEmpty(messageId) || StringUtil.isEmpty(gifts)) {
			jMessage = JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
		} else {
			try {
				Object data = msgGiftManager.add(ReqUtil.getUserId(), new ObjectId(messageId),
						JSON.parseArray(gifts, AddGiftParam.class));
				jMessage = null == data ? JSONMessage.failure(null) : JSONMessage.success(data);
			} catch (ServiceException e) {
				return JSONMessage.failureByException(e);
			}
		}

		return jMessage;
	}

	@ApiOperation("添加信息")
	@RequestMapping(value = "/add")
	public JSONMessage addMsg(@ModelAttribute AddMsgParam param) {
		if (0 == param.getType() || 0 == param.getFlag() || 0 == param.getVisible()) {
			//判断是否是文本信息并文本信息为空
		} else if (MsgType.TYPE_TEXT == param.getType() && StringUtil.isEmpty(param.getText())) {
		} else if (MsgType.TYPE_IMAGE == param.getType() && StringUtil.isEmpty(param.getImages())) {
		} else if (MsgType.TYPE_VOICE == param.getType() && StringUtil.isEmpty(param.getAudios())) {
		} else if (MsgType.TYPE_FILE == param.getType() && StringUtil.isEmpty(param.getFiles())) {
		} else if (MsgType.TYPE_SHARE_LINK == param.getType() && StringUtil.isEmpty(param.getSdkUrl())){
		} else {
			try {
				Object data = msgManager.add(ReqUtil.getUserId(), param);
				return JSONMessage.success(data);
			} catch (Exception e) {
				logger.error("发商务圈消息失败", e);
				return JSONMessage.failureByException(e);
			}
		}
		return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
	}

	@ApiOperation("点赞")
	@ApiImplicitParam(paramType="query" , name="messageId" , value="圈子消息Id",dataType="String",required=true)
	@RequestMapping(value = "/praise/add")
	public JSONMessage addPraise(@RequestParam String messageId) {
		JSONMessage jMessage;
		if (StringUtil.isEmpty(messageId)) {
			jMessage = JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
		} else {
			try {
				ObjectId data = msgPraiseManager.add(ReqUtil.getUserId(), new ObjectId(messageId));
				jMessage = null == data ? JSONMessage.failure(null) : JSONMessage.success(data);
			} catch (ServiceException e) {
				logger.error("赞失败", e);
				return JSONMessage.failureByException(e);
			}
		}
		return jMessage;
	}
	
	/**
	 * 转发数量统计
	 * @param messageId
	 * @return
	 */

	@ApiOperation("转发数量统计")
	@ApiImplicitParam(paramType="query" , name="messageId" , value="圈子消息Id",dataType="String",required=true)
	@RequestMapping(value = "/forward/add")
	public JSONMessage addForward(@RequestParam String messageId){
		if(StringUtil.isEmpty(messageId)){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
		}
		try {
			msgForwardAmountManager.addForwardAmount(ReqUtil.getUserId(), messageId);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
		return JSONMessage.success();
		
	}
	
	/**
	 * 观看数量统计
	 * @param messageId
	 * @return
	 */
	@ApiOperation("观看数量统计")
	@ApiImplicitParam(paramType="query" , name="messageId" , value="圈子消息Id",dataType="String",required=true)
	@RequestMapping(value = "/playAmount/add")
	public JSONMessage addWatch(@RequestParam String messageId){
		if(StringUtil.isEmpty(messageId)){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
		}
		try {
			msgPlayAmountManger.addPlayAmount(ReqUtil.getUserId(), messageId);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
		return JSONMessage.success();
		
	}

	@ApiOperation("删除评论")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="messageId" , value="朋友圈消息Id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="commentId" , value="评论Id",dataType="String",required=true)
	})
	@RequestMapping(value = "/comment/delete")
	public JSONMessage deleteComment(@RequestParam String messageId, String commentId) {
		if (StringUtil.isEmpty(messageId) || StringUtil.isEmpty(commentId)) {
			return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
		}
		ObjectId objectId=null;
		try {
			objectId = new ObjectId(messageId);
		} catch (Exception e) {
			return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
		}

		try {
			Object data = msgManager.get(ReqUtil.getUserId(),objectId);
			if(null != data){
				boolean ok = msgCommentManager.delete(objectId,commentId);
				return ok ? JSONMessage.success(): JSONMessage.failure(null);
			}else {
				return JSONMessage.failureByErrCode(KConstants.ResultCode.DataNotExists);
			}

		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}


	@ApiOperation("删除数据")
	@ApiImplicitParam(paramType="query" , name="messageId" , value="朋友圈消息Id",dataType="String",required=true)
	@RequestMapping(value = "/delete")
	public JSONMessage deleteMsg(@RequestParam String messageId) {
		JSONMessage jMessage;
		ObjectId objectId;
		if (StringUtil.isEmpty(messageId)) {
			return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
		}
		try {
			try {
				objectId = new ObjectId(messageId);
			} catch (Exception e) {
				return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
			}
			Object data = msgManager.get(ReqUtil.getUserId(),objectId);
			if(null==data) {
				return JSONMessage.failureByErrCode(KConstants.ResultCode.DataNotExists);
			}
			boolean ok = msgManager.delete(new ObjectId(messageId));
				jMessage = ok ? JSONMessage.success() : JSONMessage.failure(null);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}

		return jMessage;
	}


	@ApiOperation("取消赞")
	@ApiImplicitParam(paramType="query" , name="messageId" , value="圈子消息Id",dataType="String",required=true)
	@RequestMapping(value = "/praise/delete")
	public JSONMessage deletePraise(@RequestParam String messageId) {
		JSONMessage jMessage;
		ObjectId objectId =null;
		if (StringUtil.isEmpty(messageId)) {
			return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
		} else {
			try {
				objectId = new ObjectId(messageId);
			} catch (Exception e) {
				return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
			}
			try {
				boolean ok = msgPraiseManager.delete(ReqUtil.getUserId(),objectId);
				jMessage = ok ? JSONMessage.success() : JSONMessage.failure(null);
			} catch (ServiceException e) {
				return  JSONMessage.failureByException(e);
			}



		}

		return jMessage;
	}
	
	/** @Description:（取消收藏）
	* @param messageId
	* @return
	**/
	@ApiOperation("取消收藏")
	@ApiImplicitParam(paramType="query" , name="messageId" , value="圈子消息Id",dataType="String",required=true,defaultValue="")
	@RequestMapping(value = "/deleteCollect")
	public JSONMessage deleteCollect(@RequestParam(defaultValue="") String messageId) {
		try {
			if(StringUtil.isEmpty(messageId))
				return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);

			collectionDao.deleteCollect(ReqUtil.getUserId(), messageId);

			return JSONMessage.success();
		}catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}

	@ApiOperation("转发朋友圈消息 ")
	@RequestMapping(value = "/forwarding")
	public JSONMessage forwardingMsg(@ModelAttribute AddMsgParam param) {
		JSONMessage jMessage;

		if (StringUtil.isEmpty(param.getText()) || StringUtil.isEmpty(param.getMessageId())) {
			jMessage = JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
		} else {
			try {
				Object data = msgManager.forwarding(ReqUtil.getUserId(), param);
				jMessage = null == data ? JSONMessage.failure(null) : JSONMessage.success(data);
			} catch (ServiceException e) {
				return JSONMessage.failureByException(e);
			}
		}

		return jMessage;
	}


	@ApiOperation("获取评论列表")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="messageId" , value="消息编号",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="commentId" , value="评论编号",dataType="String",required=true,defaultValue = ""),
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页",dataType="int",required=true,defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数量",dataType="int",required=true,defaultValue = "100")
	})
	@RequestMapping(value = "/comment/list")
	public JSONMessage getCommentList(@RequestParam String messageId,
			@RequestParam(value = "commentId", defaultValue = "") String commentId,
			@RequestParam(value = "pageIndex", defaultValue = "0") int pageIndex,
			@RequestParam(value = "pageSize", defaultValue = "100") int pageSize) {
		JSONMessage jMessage = null;
		ObjectId objectId=null;
		ObjectId commentObjId=null;
		try {
			 objectId = new ObjectId(messageId);
			 if(!StringUtil.isEmpty(commentId))
				 commentObjId=new ObjectId(commentId);
		} catch (Exception e) {
			return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
		} 
		try {
			Object data = msgCommentManager.find(objectId,
					commentObjId, pageIndex, pageSize);
			jMessage = JSONMessage.success(data);
		} catch (ServiceException e) {
			return  JSONMessage.failureByException(e);
		}


		return jMessage;
	}

	@ApiOperation("获取最新商务消息")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType = "query",name = "userId",value = "用户编号",dataType = "int",defaultValue = ""),
			@ApiImplicitParam(paramType = "query",name = "messageId",value = "消息编号",dataType = "String",defaultValue = ""),
			@ApiImplicitParam(paramType = "query",name = "pageSize",value = "当前页大小",dataType = "int",defaultValue = "10")
	})
	@RequestMapping(value = "/ids")
	public JSONMessage getFriendsMsgIdList(@RequestParam(value = "userId", defaultValue = "") Integer userId,
			@RequestParam(defaultValue = "") String messageId,
			@RequestParam(value = "pageSize", defaultValue = "10") Integer pageSize) {
		JSONMessage jMessage;

		try {
			ObjectId msgId = !ObjectId.isValid(messageId) ? null : new ObjectId(messageId);
			Object data = msgManager.getMsgIdList(null == userId ? ReqUtil.getUserId() : userId, 0, msgId, pageSize);
			jMessage = JSONMessage.success(data);
		} catch (ServiceException e) {
			return  JSONMessage.failureByException(e);
		}


		return jMessage;
	}


	@ApiOperation("获取朋友圈")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType = "query",name = "userId",value = "用户编号",dataType = "int",defaultValue = ""),
			@ApiImplicitParam(paramType = "query",name = "messageId",value = "消息编号",dataType = "String",defaultValue = ""),
			@ApiImplicitParam(paramType = "query",name = "pageSize",value = "当前页大小",dataType = "int",defaultValue = "10"),
			@ApiImplicitParam(paramType = "query",name = "pageIndex",value = "当前页",dataType = "int",defaultValue = "0")
	})
	@RequestMapping(value = "/list")
	public JSONMessage getFriendsMsgList(@RequestParam(value = "userId", defaultValue = "") Integer userId,
			@RequestParam(value = "messageId", defaultValue = "") String messageId,
			@RequestParam(value = "pageSize", defaultValue = "10") Integer pageSize,
			@RequestParam(value = "pageIndex", defaultValue = "0") Integer pageIndex) {
		JSONMessage jMessage;
		try {
			Object data = msgManager.getMsgList(null == userId ? ReqUtil.getUserId() : userId,
					!ObjectId.isValid(messageId) ? null : new ObjectId(messageId), pageSize,pageIndex);
			jMessage = JSONMessage.success(data);
		} catch (ServiceException e) {
			return  JSONMessage.failureByException(e);
		}

		return jMessage;
	}
	
	@ApiOperation("获取短视频列表")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType = "query",name = "lable",value = "标签",dataType = "String",defaultValue = ""),
			@ApiImplicitParam(paramType = "query",name = "pageSize",value = "当前页大小",dataType = "int",defaultValue = "10"),
			@ApiImplicitParam(paramType = "query",name = "pageIndex",value = "当前页",dataType = "int",defaultValue = "0")
	})
	@RequestMapping(value = "/pureVideo")
	public JSONMessage getPureVideoMsgList(@RequestParam(defaultValue = "10") Integer pageSize,
			@RequestParam(defaultValue = "0") Integer pageIndex,@RequestParam(defaultValue = "") String lable){
		try {
			List<Msg> data = msgManager.getPureVideo(pageIndex,pageSize,lable);
			data.forEach(msg -> {
			msg.setComments(msgCommentManager.find(msg.getMsgId(), null, 0, 10));
			msg.setPraises(msgPraiseManager.find(msg.getMsgId(), null, 0, 10));
			msg.setGifts(msgGiftManager.find(msg.getMsgId(), null, 0, 10));
			msg.setIsPraise(msgPraiseManager.exists(ReqUtil.getUserId(), msg.getMsgId()) ? 1 : 0);
			msg.setIsCollect(msgPraiseManager.existsCollect(ReqUtil.getUserId(), msg.getMsgId()) ? 1 : 0);
			msg.setPlayAmount(msgPlayAmountManger.find(msg.getMsgId(), null, 0, 10));
			msg.setForwardAmount(msgForwardAmountManager.find(msg.getMsgId(), null, 0, 10));
		});
			return JSONMessage.success(data);
		} catch (ServiceException e) {
			return  JSONMessage.failureByException(e);
		}

	}

	@ApiOperation("获取礼物列表")
	@ApiImplicitParam(paramType = "query",name = "messageId",value = "消息编号",dataType = "String")
	@RequestMapping(value = "/gift/gbgift")
	public JSONMessage getGiftGroupByGfit(@RequestParam String messageId) {
		JSONMessage jMessage;

		try {
			Object data =msgGiftManager.findByGift(new ObjectId(messageId));

			jMessage = JSONMessage.success(data);
		} catch (ServiceException e) {
			return  JSONMessage.failureByException(e);
		}


		return jMessage;
	}

	@ApiOperation("获取礼物")
	@ApiImplicitParam(paramType = "query",name = "messageId",value = "消息编号",dataType = "String")
	@RequestMapping(value = "/gift/gbuser")
	public JSONMessage getGiftGroupByUser(@RequestParam String messageId) {
		JSONMessage jMessage;

		try {
			Object data = msgGiftManager.findByUser(new ObjectId(messageId));

			jMessage = JSONMessage.success(data);
		} catch (ServiceException e) {
			return  JSONMessage.failureByException(e);
		}


		return jMessage;
	}

	@ApiOperation("获取礼物列表")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType = "query",name = "giftId",value = "礼物编号",dataType = "String",defaultValue = ""),
			@ApiImplicitParam(paramType = "query",name = "messageId",value = "信息大小",dataType = "int"),
			@ApiImplicitParam(paramType = "query",name = "pageSize",value = "当前页数据量",dataType = "int",defaultValue = "10"),
			@ApiImplicitParam(paramType = "query",name = "pageIndex",value = "当前页",dataType = "int",defaultValue = "0")
	})
	@RequestMapping(value = "/gift/list")
	public JSONMessage getGiftList(@RequestParam String messageId,
			@RequestParam(value = "giftId", defaultValue = "") String giftId,
			@RequestParam(value = "pageIndex", defaultValue = "0") Integer pageIndex,
			@RequestParam(value = "pageSize", defaultValue = "100") Integer pageSize) {
		JSONMessage jMessage;

		try {
			Object data = msgGiftManager.find(new ObjectId(messageId), new ObjectId(giftId), pageIndex, pageSize);

			jMessage = JSONMessage.success(data);
		} catch (ServiceException e) {
			return  JSONMessage.failureByException(e);
		}

		return jMessage;
	}
	//获取单条商务圈

	@ApiOperation("获取单条商务圈")
	@ApiImplicitParam(paramType="query" , name="messageId" , value="圈子消息Id",dataType="String",required=true)
	@RequestMapping(value = "/get")
	public JSONMessage getMsgById(@RequestParam String messageId) {
		JSONMessage jMessage;

		if (StringUtil.isEmpty(messageId)||!ObjectId.isValid(messageId))
			jMessage = JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
		else
			try {
				Object data = msgManager.get(ReqUtil.getUserId(), new ObjectId(messageId));
				jMessage = JSONMessage.success(data);
			} catch (ServiceException e) {
				return  JSONMessage.failureByException(e);
			}


		return jMessage;
	}


	@ApiOperation("批量获取商务圈失败")
	@ApiImplicitParam(paramType="query",name="ids",value = "编号",dataType="String",required=true)
	@RequestMapping(value = "/gets")
	public JSONMessage getMsgByIds(@RequestParam String ids) {
		JSONMessage jMessage;

		if (StringUtil.isEmpty(ids))
			jMessage = JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
		else
			try {
				Object data = msgManager.getMsgListByIds(ReqUtil.getUserId(), ids);
				jMessage = JSONMessage.success(data);
			} catch (ServiceException e) {
				return  JSONMessage.failureByException(e);
			}


		return jMessage;
	}

	@ApiOperation("获取赞")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="messageId" , value="公共消息Id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="praiseId" , value="当前页最后一个赞的赞Id",dataType="String"),
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页码数，默认0",dataType="int"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据数量，默认100",dataType="int")
	})
	@RequestMapping(value = "/praise/list")
	public JSONMessage getPraiseList(@RequestParam String messageId,
			@RequestParam(value = "praiseId", defaultValue = "") String praiseId,
			@RequestParam(value = "pageIndex", defaultValue = "0") Integer pageIndex,
			@RequestParam(value = "pageSize", defaultValue = "100") Integer pageSize) {
		JSONMessage jMessage;

		try {
			if (StringUtil.isEmpty(messageId)) {
				jMessage = JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
			} else {
				Object data = msgPraiseManager.getPraiseList(new ObjectId(messageId), StringUtil.isEmpty(praiseId) ? null : new ObjectId(praiseId),pageIndex, pageSize);
				jMessage = JSONMessage.success(data);
			}
		} catch (ServiceException e) {
			return  JSONMessage.failureByException(e);
		}


		return jMessage;
	}

	@ApiOperation("获取广场的最新消息")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="messageId" , value="消息编号",dataType="String",defaultValue = ""),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="数据数量，默认10",dataType="int",defaultValue = "10")
	})
	@RequestMapping("/square")
	public JSONMessage getSquareMsgList(@RequestParam(value = "messageId", defaultValue = "") String _id,
			@RequestParam(value = "pageSize", defaultValue = "10") Integer pageSize) {
		ObjectId msgId = !ObjectId.isValid(_id) ? null : new ObjectId(_id);
		Object data = msgManager.getSquareMsgList(0, msgId, pageSize);

		return JSONMessage.success(data);
	}

	@ApiOperation("获取用户信息列表")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="userId" , value="用户编号",dataType="int",required=true),
			@ApiImplicitParam(paramType="query" , name="messageId" , value="消息编号",dataType="String"),
			@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据数量，默认100",dataType="int")
	})
	@RequestMapping(value = "/user/ids")
	public JSONMessage getUserMsgIdList(@RequestParam(value = "userId", defaultValue = "") Integer userId,
			@RequestParam(value = "messageId", defaultValue = "") String messageId,
			@RequestParam(value = "pageSize", defaultValue = "10") Integer pageSize) {
		Object data = msgManager.getUserMsgIdList(null == userId ? ReqUtil.getUserId() : userId, userId,
				!ObjectId.isValid(messageId) ? null : new ObjectId(messageId), pageSize);

		return JSONMessage.success(data);
	}

	@ApiOperation("获取用户列表")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="userId" , value="用户编号",dataType="int",required=true),
			@ApiImplicitParam(paramType="query" , name="messageId" , value="消息编号",dataType="String",defaultValue = ""),
			@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据数量，默认100",dataType="int")
	})
	@RequestMapping(value = "/user")
	public JSONMessage getUserMsgList(@RequestParam(value = "userId", defaultValue = "") Integer userId,
			@RequestParam(value = "messageId", defaultValue = "") String messageId,
			@RequestParam(value = "pageIndex", defaultValue = "0") Integer pageIndex,
			@RequestParam(value = "pageSize", defaultValue = "10") Integer pageSize) {
		try {
			Object data = msgManager.getUserMsgList(ReqUtil.getUserId(), null == userId ? ReqUtil.getUserId() : userId,
					!ObjectId.isValid(messageId) ? null : new ObjectId(messageId),pageIndex, pageSize);
			return JSONMessage.success(data);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}


	@ApiOperation("查询消息")
	@RequestMapping("/query")
	public JSONMessage queryByExample(@ModelAttribute MessageExample example) {
		Object data = msgManager.findByExample(ReqUtil.getUserId(), example);

		return JSONMessage.success(data);
	}

}
