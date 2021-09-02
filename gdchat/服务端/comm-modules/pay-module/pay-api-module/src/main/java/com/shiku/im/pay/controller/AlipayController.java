package com.shiku.im.pay.controller;

import com.alibaba.fastjson.JSONObject;
import com.alipay.api.AlipayApiException;
import com.alipay.api.internal.util.AlipaySignature;
import com.alipay.api.request.AlipayFundTransOrderQueryRequest;
import com.alipay.api.response.AlipayFundTransOrderQueryResponse;
import com.alipay.util.AliPayParam;
import com.alipay.util.AliPayUtil;
import com.shiku.im.api.service.AuthServiceOldUtils;
import com.shiku.im.api.service.AuthServiceUtils;
import com.shiku.im.api.service.base.AbstractController;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.utils.BeanUtils;
import com.shiku.im.comm.utils.DateUtil;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.pay.constants.PayResultCode;
import com.shiku.im.pay.entity.BaseConsumeRecord;
import com.shiku.im.pay.service.impl.ConsumeRecordManagerImpl;
import com.shiku.im.pay.service.impl.TransfersRecordManagerImpl;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.entity.UserMoneyLog;
import com.shiku.im.user.constants.MoneyLogConstants.*;
import com.shiku.im.user.service.impl.AuthKeysServiceImpl;
import com.shiku.im.user.service.impl.UserManagerImpl;
import com.shiku.im.utils.ConstantUtil;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.StringUtil;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;


@Api(value="AlipayController",tags="支付宝接口")
@RestController
@RequestMapping(value = "/alipay" ,method={RequestMethod.GET,RequestMethod.POST})
public class AlipayController extends AbstractController {
	
	@Autowired
	private TransfersRecordManagerImpl transfersManager;

	@Autowired
	private ConsumeRecordManagerImpl consumeRecordManager;

	@Autowired
	private UserManagerImpl userManager;

	@Autowired
	private AuthKeysServiceImpl authKeysService;

	@Autowired
	private AuthServiceUtils authServiceUtils;
	@Autowired
	private AuthServiceOldUtils authServiceOldUtils;

	@ApiOperation("支付宝支付回调")
	@RequestMapping("/callBack")
	public String payCheck(HttpServletRequest request, HttpServletResponse response){
		Map<String,String> params = new HashMap<String,String>();
		Map requestParams = request.getParameterMap();
		for (Iterator iter = requestParams.keySet().iterator(); iter.hasNext();) {
		    String name = (String) iter.next();
		    String[] values = (String[]) requestParams.get(name);
		    String valueStr = "";
		    for (int i = 0; i < values.length; i++) {
		        valueStr = (i == values.length - 1) ? valueStr + values[i]
		                    : valueStr + values[i] + ",";
		  	}
		    //乱码解决，这段代码在出现乱码时使用。
			//valueStr = new String(valueStr.getBytes("ISO-8859-1"), "utf-8");
			params.put(name, valueStr);
		}
		try {
			String tradeNo = params.get("out_trade_no");
			String tradeStatus=params.get("trade_status");
			logger.info("订单号    "+tradeNo);
			boolean flag = AlipaySignature.rsaCheckV1(params,AliPayUtil.ALIPAY_PUBLIC_KEY, AliPayUtil.CHARSET,"RSA2");
			if(flag){
				BaseConsumeRecord entity = consumeRecordManager.getConsumeRecordByNo(tradeNo);
				if(null==entity) {
					logger.info("订单号  错误 不存在 {} ", tradeNo);
					return "failure";
				}
				if(entity.getStatus()!= KConstants.OrderStatus.END&&"TRADE_SUCCESS".equals(tradeStatus)){
					//把支付宝返回的订单信息存到数据库
					AliPayParam aliCallBack=new AliPayParam();
					BeanUtils.populate(aliCallBack, params);
					consumeRecordManager.getConsumeRecordDao().saveEntity(aliCallBack);
					User user=userManager.getUser(entity.getUserId());
					user.setAliUserId(aliCallBack.getBuyer_id());

					UserMoneyLog userMoneyLog =new UserMoneyLog(entity.getUserId(),0,tradeNo,entity.getMoney(),
							MoenyAddEnum.MOENY_ADD, MoneyLogEnum.CASH_OUT, MoneyLogTypeEnum.NORMAL_PAY);
					userMoneyLog.setExtra("ALI_PAY");
					userManager.rechargeUserMoenyV1(userMoneyLog);
					entity.setStatus(KConstants.OrderStatus.END);
					entity.setOperationAmount(entity.getMoney());
					Double balance = userManager.getUserMoenyV1(entity.getUserId());
					entity.setCurrentBalance(balance);
					consumeRecordManager.getConsumeRecordDao().update(entity.getId(), entity);
					logger.info("支付宝支付成功 {}",tradeNo);
					return "success";
				}else if("TRADE_CLOSED".equals(tradeStatus)) {
					logger.info("订单号  已取消  {}  ",tradeNo);
					consumeRecordManager.getConsumeRecordDao().updateAttribute(entity.getId(), "status", -1);
					return "success";
				}

			}else{
				logger.info("支付宝回调失败"+flag);
				return "failure";
			}
		} catch (AlipayApiException e) {
			e.printStackTrace();
		}
		return "failure";
	}
	
	/**
	 * 支付宝提现
	 * @param amount
	 * @param time
	 * @param secret
	 * @param callback
	 * @return
	 */
	@RequestMapping(value = "/transfer")
	@ApiOperation("支付宝提现")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="amount" , value="数量",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="time" , value="时间",dataType="long",required=true,defaultValue = "0"),
			@ApiImplicitParam(paramType="query" , name="secret" , value="秘钥",dataType="int",required=true),
			@ApiImplicitParam(paramType="query" , name="salt" , value="盐",dataType="int",required=true),
			@ApiImplicitParam(paramType="query" , name="callback" , value="回调",dataType="String",required=true)
	})
	public JSONMessage transfer(@RequestParam(defaultValue="") String amount,@RequestParam(defaultValue="0") long time,
			@RequestParam(defaultValue="") String secret, String callback,String salt){
		if(true){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.PleaseUpgradeLatestVersion);
		}
		if(1 != SKBeanUtils.getImCoreService().getClientConfig().getEnableAliPay()){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.FUNCTION_NOTOPEN);
		}
		if(StringUtil.isEmpty(amount)) {
			return JSONMessage.failureByErrCode(PayResultCode.NoTransferMoney);
		}

		int userId = ReqUtil.getUserId();
		User user=userManager.getUserDao().get(userId);
		String token = getAccess_token();
		String	aliUserId=authKeysService.getAliUserId(userId);
		if(StringUtil.isEmpty(aliUserId)){
			aliUserId=user.getAliUserId();
			if(StringUtil.isEmpty(aliUserId))
				return JSONMessage.failureByErrCode(PayResultCode.NotAliAuth);
		}
		if(StringUtil.isEmpty(salt)){
			if(!authServiceOldUtils.authWxTransferPay(user.getPayPassword(),userId+"", token, amount,user.getAliUserId(),time, secret)){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
			}
		}
		// 提现金额
		double total=(Double.valueOf(amount));
		if(SKBeanUtils.getImCoreService().getPayConfig().getMaxWithdrawAmount()<total) {
			return JSONMessage.failureByErrCode(PayResultCode.TransferMaxMoney);
		}
		// 判断用户单日消费金额
		Double todayMoney = consumeRecordManager.getUserPayMoney(userId,KConstants.ConsumeType.PUT_RAISE_CASH,KConstants.OrderStatus.END,DateUtil.getTodayMorning().getTime()/1000 ,DateUtil.getTodayNight().getTime()/1000);
		todayMoney = todayMoney + total;
		if(todayMoney>SKBeanUtils.getImCoreService().getPayConfig().getDayMaxWithdrawAmount()){
			return JSONMessage.failureByErrCode(PayResultCode.ExceedDayMaxAmount);
		}

		user.setAliUserId(aliUserId);
		return transfersManager.aliWithdrawalPay(user, amount);

	}
	/**
	 * 支付宝提现
	 * @return
	 */
	@RequestMapping(value = "/transfer/v1")
	@ApiOperation("支付宝提现")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="data" , value="加密参数",dataType="String",required=true,defaultValue = ""),
			@ApiImplicitParam(paramType="query" , name="codeId" , value="编号",dataType="String",required=true,defaultValue = ""),
			@ApiImplicitParam(paramType="query" , name="callback" , value="回调参数",dataType="String",required=true)
	})
	public JSONMessage transferV1(@RequestParam(defaultValue="") String data,
	@RequestParam(defaultValue="") String codeId, String callback){
		if(1 != SKBeanUtils.getImCoreService().getClientConfig().getEnableAliPay()){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.FUNCTION_NOTOPEN);
		}
		int userId = ReqUtil.getUserId();
		String token = getAccess_token();
		User user=userManager.getUser(userId);
		String	aliUserId=authKeysService.getAliUserId(userId);
		if(StringUtil.isEmpty(aliUserId)){
			aliUserId=user.getAliUserId();
			if(StringUtil.isEmpty(aliUserId)) {
				return JSONMessage.failureByErrCode(PayResultCode.NotAliAuth);
			}
		}
		String payPayPassword = authKeysService.getPayPassword(userId);
		JSONObject jsonObj = authServiceUtils.authAliWithdrawalPay(userId, token, data, codeId,payPayPassword);
		if(null==jsonObj) {
			return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
		}
		String amount = jsonObj.getString("amount");
		if(StringUtil.isEmpty(amount)) {
			return JSONMessage.failureByErrCode(PayResultCode.NoTransferMoney);
		}
		// 提现金额
		double total=(Double.valueOf(amount));
		if(SKBeanUtils.getImCoreService().getPayConfig().getMaxWithdrawAmount()<total) {
			return JSONMessage.failureByErrCode(PayResultCode.TransferMaxMoney);
		}
		// 判断用户单日消费金额
		Double todayMoney = consumeRecordManager.getUserPayMoney(userId,KConstants.ConsumeType.PUT_RAISE_CASH,KConstants.OrderStatus.END,DateUtil.getTodayMorning().getTime()/1000 ,DateUtil.getTodayNight().getTime()/1000);
		todayMoney = todayMoney + total;
		if(todayMoney>SKBeanUtils.getImCoreService().getPayConfig().getDayMaxWithdrawAmount()){
			return JSONMessage.failureByErrCode(PayResultCode.ExceedDayMaxAmount);
		}
		user.setAliUserId(aliUserId);
		return transfersManager.aliWithdrawalPay(user, amount);

		}


	
	/**
	 * 支付宝提现查询
	 * @param tradeno
	 * @param callback
	 * @return
	 */
	@RequestMapping(value ="/aliPayQuery")
	@ApiOperation("支付宝提现查询")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="callback" , value="回调参数",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="tradeno" , value="交易",dataType="String",required=true)
	})
	public JSONMessage aliPayQuery(String tradeno,String callback){
		if (StringUtil.isEmpty(tradeno)) {
			return null;
		}
		AlipayFundTransOrderQueryRequest request = new AlipayFundTransOrderQueryRequest();
		request.setBizContent("{" +
				"\"out_biz_no\":\""+tradeno+"\"," + // 订单号
				"\"order_id\":\"\"" +
				"  }");
		try {
			AlipayFundTransOrderQueryResponse response = AliPayUtil.getAliPayClient().execute(request);
			logger.info("支付返回结果  "+response.getCode());
			if(response.isSuccess()){
				logger.info("调用成功");
			} else {
				logger.info("调用失败");
			}
		} catch (AlipayApiException e) {
			e.printStackTrace();
		}

		return JSONMessage.success();
	}
}
