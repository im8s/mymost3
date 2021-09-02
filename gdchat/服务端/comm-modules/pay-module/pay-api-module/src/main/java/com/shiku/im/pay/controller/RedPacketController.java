package com.shiku.im.pay.controller;


import com.alibaba.fastjson.JSONObject;
import com.shiku.im.api.service.AuthServiceOldUtils;
import com.shiku.im.api.service.AuthServiceUtils;
import com.shiku.im.api.service.base.AbstractController;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.constants.KConstants.ResultCode;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.DateUtil;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.pay.constants.PayResultCode;
import com.shiku.im.pay.service.impl.ConsumeRecordManagerImpl;
import com.shiku.im.redpack.entity.RedPacket;
import com.shiku.im.redpack.service.RedPacketManagerImpl;
import com.shiku.im.room.entity.Room;
import com.shiku.im.room.service.impl.RoomManagerImplForIM;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.user.service.impl.AuthKeysServiceImpl;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.StringUtil;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;


@Api(value="RedPacketController",tags="红包功能相关接口")
@RestController
@RequestMapping(value="",method={RequestMethod.GET,RequestMethod.POST})
public class RedPacketController extends AbstractController {

	@Autowired
	private RedPacketManagerImpl redPacketManager;
	
	@Autowired
	private UserCoreService userCoreService;
	
	@Autowired
	private AuthKeysServiceImpl authKeysService;

	@Autowired
	private RoomManagerImplForIM roomManager;


	@Autowired
	private AuthServiceUtils authServiceUtils;
	@Autowired
	private AuthServiceOldUtils authServiceOldUtils;
	@Autowired
	private ConsumeRecordManagerImpl consumeRecordManager;

	private JSONMessage checkSendPacket(RedPacket packet, long time, String secret) {
		return null;
	}
	@ApiOperation("发红包")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="time" , value="时间",dataType="long",required=true,defaultValue = "0"),
			@ApiImplicitParam(paramType="query" , name="secret" , value="加密值",dataType="String",required=true,defaultValue = ""),
			@ApiImplicitParam(paramType="query" , name="salt" , value="盐加密值",dataType="String",required=true,defaultValue = "")
	})
	@RequestMapping("/redPacket/sendRedPacket")
	public JSONMessage sendRedPacket(RedPacket packet,
			@RequestParam(defaultValue="0") long time,
			@RequestParam(defaultValue="") String secret,@RequestParam(defaultValue ="") String salt) {
		if(true){
			return JSONMessage.failureByErrCode(ResultCode.PleaseUpgradeLatestVersion);
		}

		String token=getAccess_token();
		Integer userId = ReqUtil.getUserId();
		if (userCoreService.getUserMoenyV1(userId) < packet.getMoney()) {
			//余额不足
			return JSONMessage.failureByErrCode(PayResultCode.InsufficientBalance);
		} else if (0 != packet.getToUserId() && SKBeanUtils.getImCoreService().getPayConfig().getMaxRedpacktAmount() < packet.getMoney()) {
			return JSONMessage.failureByErrCode(PayResultCode.RedPacketAmountRange);
		} else if ((packet.getMoney() / packet.getCount()) < 0.01) {
			return JSONMessage.failureByErrCode(PayResultCode.RedPacketMinMoney);
		} else if (packet.getCount() > SKBeanUtils.getImCoreService().getPayConfig().getMaxRedpacktNumber()) {
			return JSONMessage.failureByErrCode(PayResultCode.RedPacke_MaxNumber);
		}
		// 判断用户单日发红包金额
		Double todayMoney = consumeRecordManager.getUserPayMoney(userId,KConstants.ConsumeType.SEND_REDPACKET,KConstants.OrderStatus.END, DateUtil.getTodayMorning().getTime()/1000 ,DateUtil.getTodayNight().getTime()/1000);
		todayMoney = todayMoney + packet.getMoney();
		if(todayMoney>SKBeanUtils.getImCoreService().getPayConfig().getDayMaxRedpacktAmount()){
			return JSONMessage.failureByErrCode(PayResultCode.ExceedDayMaxAmount);
		}

		//红包接口授权
		String payPassword = authKeysService.getPayPassword(userId);
		User user=userCoreService.getUser(userId);
		if(StringUtil.isEmpty(payPassword)){
			return JSONMessage.failureByErrCode(PayResultCode.PayPasswordNotExist);
		}
     if(StringUtil.isEmpty(salt)){
		if(!authServiceOldUtils.authRedPacket(payPassword,userId+"", token, time,secret)) {
			return JSONMessage.failureByErrCode(PayResultCode.PayPasswordIsWrong);
		}
     }
		// 判断红包个数是否超过房间人数
		if(!StringUtil.isEmpty(packet.getRoomJid())){
			Room room = roomManager.getRoomByJid(packet.getRoomJid());
			if(packet.getCount()>room.getUserSize()){
				return JSONMessage.failureByErrCode(PayResultCode.GreateRoomMember);
			}
		}
		try {
			Object result = redPacketManager.sendRedPacket(userId, packet);
			return JSONMessage.success(result);
		} catch (Exception e) {
			return JSONMessage.failureByException(e);

		}
	}
	
	/**
	 * 新版本发送红包
	 * @param packet
	 * @param time
	 * @param secret
	 * @return
	 */

	@ApiOperation("新版本发红包")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="access_token" , value="token",dataType="String",required=true)
	})
	@RequestMapping("/redPacket/sendRedPacket/v1")
	public JSONMessage sendRedPacketV1(RedPacket packet,
			@RequestParam(defaultValue="0") long time,@RequestParam(defaultValue="") String moneyStr,
			@RequestParam(defaultValue="") String secret,@RequestParam(defaultValue ="") String salt) {
		if(true){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.PleaseUpgradeLatestVersion);
		}
		String token=getAccess_token();
		Integer userId = ReqUtil.getUserId();
		packet.setMoney(Double.valueOf(moneyStr));
		if (userCoreService.getUserMoenyV1(userId) < packet.getMoney()) {
			//余额不足
			return JSONMessage.failureByErrCode(PayResultCode.InsufficientBalance);
		} else if (0 != packet.getToUserId() && SKBeanUtils.getImCoreService().getPayConfig().getMaxRedpacktAmount() < packet.getMoney()) {
			return JSONMessage.failureByErrCode(PayResultCode.RedPacketAmountRange);
		} else if ((packet.getMoney() / packet.getCount()) < 0.01) {
			return JSONMessage.failureByErrCode(PayResultCode.RedPacketMinMoney);
		} else if (packet.getCount() > SKBeanUtils.getImCoreService().getPayConfig().getMaxRedpacktNumber()) {
			return JSONMessage.failureByErrCode(PayResultCode.RedPacke_MaxNumber);
		}

		// 判断用户单日发红包金额
		Double todayMoney = consumeRecordManager.getUserPayMoney(userId,KConstants.ConsumeType.SEND_REDPACKET,KConstants.OrderStatus.END, DateUtil.getTodayMorning().getTime()/1000 ,DateUtil.getTodayNight().getTime()/1000);
		todayMoney = todayMoney + packet.getMoney();
		if(todayMoney>SKBeanUtils.getImCoreService().getPayConfig().getDayMaxRedpacktAmount()){
			return JSONMessage.failureByErrCode(PayResultCode.ExceedDayMaxAmount);
		}

		//红包接口授权
		String payPassword = authKeysService.getPayPassword(userId);
		if(StringUtil.isEmpty(payPassword)){
			return JSONMessage.failureByErrCode(PayResultCode.PayPasswordNotExist);
		}
		if(StringUtil.isEmpty(salt)){
			if(!authServiceOldUtils.authRedPacketV1(payPassword,userId+"", token, time,moneyStr,secret)) {
				return JSONMessage.failureByErrCode(PayResultCode.PayPasswordIsWrong);
			}
		}
		// 判断红包个数是否超过房间人数
		if(!StringUtil.isEmpty(packet.getRoomJid())){
			Room room = roomManager.getRoomByJid(packet.getRoomJid());
			if(packet.getCount()>room.getUserSize()){
				return JSONMessage.failureByErrCode(PayResultCode.GreateRoomMember);
			}
		}

		try {
			Object result = redPacketManager.sendRedPacket(userId, packet);
			return JSONMessage.success(result);
		} catch (Exception e) {
			return JSONMessage.failureByException(e);

		}
	}
	@ApiOperation("发红包V2 新版")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="codeId" , value="标识码",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="data" , value="加密数据",dataType="String",required=true)
	})
	@RequestMapping("/redPacket/sendRedPacket/v2")
	public JSONMessage sendRedPacketV2(@RequestParam(defaultValue="") String codeId,@RequestParam(defaultValue="") String data) {
		String token=getAccess_token();
		int userId = ReqUtil.getUserId();
		//红包接口授权
		String payPassword = authKeysService.getPayPassword(userId);
		if (StringUtil.isEmpty(payPassword)) {
			return JSONMessage.failureByErrCode(PayResultCode.PayPasswordNotExist);
		}
		JSONObject jsonObj = authServiceUtils.authSendRedPacketByMac(userId, token, data, codeId, payPassword);
		if (null == jsonObj)
			return JSONMessage.failureByErrCode(ResultCode.AUTH_FAILED);
		RedPacket packet = JSONObject.toJavaObject(jsonObj, RedPacket.class);
		if (null == packet)
			return JSONMessage.failureByErrCode(ResultCode.AUTH_FAILED);
		packet.setUserId(userId);
		//packet.setUserName(user.getNickname());
		if (userCoreService.getUserMoenyV1(userId) < packet.getMoney()) {
			//余额不足
			return JSONMessage.failureByErrCode(PayResultCode.InsufficientBalance);
		} else if (0 != packet.getToUserId() && SKBeanUtils.getImCoreService().getPayConfig().getMaxRedpacktAmount() < packet.getMoney()) {
			return JSONMessage.failureByErrCode(PayResultCode.RedPacketAmountRange);
		} else if ((packet.getMoney() / packet.getCount()) < 0.01) {
			return JSONMessage.failureByErrCode(PayResultCode.RedPacketMinMoney);
		} else if (packet.getCount() > SKBeanUtils.getImCoreService().getPayConfig().getMaxRedpacktNumber()) {
			return JSONMessage.failureByErrCode(PayResultCode.RedPacke_MaxNumber);
		}

		// 判断用户单日发红包金额
		Double todayMoney = consumeRecordManager.getUserPayMoney(userId,KConstants.ConsumeType.SEND_REDPACKET,KConstants.OrderStatus.END, DateUtil.getTodayMorning().getTime()/1000 ,DateUtil.getTodayNight().getTime()/1000);
		todayMoney = todayMoney + packet.getMoney();
		if(todayMoney> SKBeanUtils.getImCoreService().getPayConfig().getDayMaxRedpacktAmount()){
			return JSONMessage.failureByErrCode(PayResultCode.ExceedDayMaxAmount);
		}

		// 判断红包个数是否超过房间人数
		if(!StringUtil.isEmpty(packet.getRoomJid())){
			Room room = roomManager.getRoomByJid(packet.getRoomJid());
			if(packet.getCount()>room.getUserSize()){
				return JSONMessage.failureByErrCode(PayResultCode.GreateRoomMember);
			}
		}
		try {
			Object result = redPacketManager.sendRedPacket(userId, packet);
			return JSONMessage.success(result);
		} catch (Exception e) {
			return JSONMessage.failureByException(e);

		}

	}
	
	
	//获取红包详情
	@ApiOperation("获取红包详情")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="access_token" , value="授权钥匙",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="id" , value="红包Id",dataType="String",required=true)
	})
	@RequestMapping("/redPacket/getRedPacket")
	public JSONMessage getRedPacket(String id) {
		JSONMessage result=redPacketManager.getRedPacketById(ReqUtil.getUserId(), ReqUtil.parseId(id));
		//System.out.println("获取红包  ====>  "+result);
		return result;
	}
	//回复红包
	@ApiOperation("回复 红包")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="id" , value="编号",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="reply" , value="回复",dataType="String",required=true)
	})
	@RequestMapping("/redPacket/reply")
	public JSONMessage replyRedPacket(String id,String reply) {
		try {
			if(StringUtil.isEmpty(reply))
				return JSONMessage.failureByErrCode(PayResultCode.RedPacke_ReplyNotNull);
			redPacketManager.replyRedPacket(id, reply);
			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}
	//打开红包
	@ApiOperation("打开红包 抢红包")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="id" , value="编号",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="time" , value="时间",dataType="long",required=true),
			@ApiImplicitParam(paramType="query" , name="secret" , value="加密值",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="salt" , value="盐加密",dataType="String",required=true)
	})
	@RequestMapping("/redPacket/openRedPacket")
	public JSONMessage openRedPacket(String id,
			@RequestParam(defaultValue="0") long time,
			@RequestParam(defaultValue="") String secret,String salt) {
		String token=getAccess_token();
		if(!ObjectId.isValid(id)){
			return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
		}
		Integer userId = ReqUtil.getUserId();
		if(StringUtil.isEmpty(salt)){
			//红包接口授权
			if(!authServiceOldUtils.authRedPacket(userId+"", token, time, secret)) {
				return JSONMessage.failureByErrCode(ResultCode.AUTH_FAILED);
			}
		}
		JSONMessage result=redPacketManager.openRedPacketById(userId,ReqUtil.parseId(id));
		//System.out.println("打开红包  ====>  "+result);
		return result;
	}
	//查询发出的红包
	@ApiOperation("查询发出的红包 ")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="access_token" , value="授权钥匙",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页码数，默认值0",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据条数，默认值10",dataType="int")
		})
	@RequestMapping("/redPacket/getSendRedPacketList")
	public JSONMessage getSendRedPacketList(@RequestParam(defaultValue="0")int pageIndex,@RequestParam(defaultValue="10")int pageSize) {
		Object data=redPacketManager.getSendRedPacketList(ReqUtil.getUserId(),pageIndex,pageSize);
		return JSONMessage.success(data);
	}

	//查询收到的红包
	@ApiOperation("查询收到的红包")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页",dataType="int",defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页大小",dataType="int",defaultValue = "10")
	})
	@RequestMapping("/redPacket/getRedReceiveList")
	public JSONMessage getRedReceiveList(@RequestParam(defaultValue="0")int pageIndex,@RequestParam(defaultValue="10")int pageSize) {
		Object data=redPacketManager.getRedReceiveList(ReqUtil.getUserId(),pageIndex,pageSize);
		return	JSONMessage.success(data);
	}
}
