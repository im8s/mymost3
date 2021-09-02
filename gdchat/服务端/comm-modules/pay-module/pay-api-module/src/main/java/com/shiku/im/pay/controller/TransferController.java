package com.shiku.im.pay.controller;

import com.alibaba.fastjson.JSONObject;
import com.shiku.im.api.service.base.AbstractController;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.constants.KConstants.ResultCode;
import com.shiku.im.comm.utils.DateUtil;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.config.AppConfig;
import com.shiku.im.pay.constants.PayResultCode;
import com.shiku.im.pay.service.impl.ConsumeRecordManagerImpl;
import com.shiku.im.pay.service.impl.TransfersRecordManagerImpl;
import com.shiku.im.api.service.AuthServiceOldUtils;
import com.shiku.im.api.service.AuthServiceUtils;
import com.shiku.im.user.config.WXConfig;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.user.service.impl.AuthKeysServiceImpl;
import com.shiku.im.utils.ConstantUtil;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.CollectionUtil;
import com.shiku.utils.StringUtil;
import com.wxpay.utils.*;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.text.DecimalFormat;
import java.util.HashMap;
import java.util.Map;

/**
 * 微信 提现的接口
 * 
 *
 * @version 2.2
 */

@Api(value="TransferController",tags="微信 提现的接口")
@RestController
@RequestMapping(value="/transfer",method={RequestMethod.GET,RequestMethod.POST})
public class TransferController extends AbstractController {

	
	
	private static final String TRANSFERS_PAY = "https://api.mch.weixin.qq.com/mmpaymkttransfers/promotion/transfers"; // 企业付款

	private static final String TRANSFERS_PAY_QUERY = "https://api.mch.weixin.qq.com/mmpaymkttransfers/gettransferinfo"; // 企业付款查询
	
	@Resource
	private WXConfig wxConfig;
	
	@Resource
	private AppConfig appConfig;
	
	@Autowired
	private TransfersRecordManagerImpl transfersManager;

	@Autowired
	private AuthKeysServiceImpl authKeysService;

	@Autowired
	private UserCoreService userCoreService;

	@Autowired
	private AuthServiceUtils authServiceUtils;
	@Autowired
	private AuthServiceOldUtils authServiceOldUtils;
	@Autowired
	private ConsumeRecordManagerImpl consumeRecordManager;
	
	
	/**
	 * 企业向个人支付转账
	 * @param request
	 * @param response
	 * @param openid 用户openid
	 * @param callback
	 */
	@ApiOperation("企业向个人支付转账")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="amount" , value="数量",dataType="String",required=true,defaultValue = ""),
			@ApiImplicitParam(paramType="query" , name="time" , value="时间",dataType="long",required=true,defaultValue = "0"),
			@ApiImplicitParam(paramType="query" , name="secret" , value="加密值",dataType="String",required=true,defaultValue = ""),
			@ApiImplicitParam(paramType="query" , name="callback" , value="回调值",dataType="String",required=true,defaultValue = ""),
			@ApiImplicitParam(paramType="query" , name="salt" , value="盐加密",dataType="String",required=true,defaultValue = "")
	})
    @RequestMapping(value = "/wx/pay", method = RequestMethod.POST)
	public JSONMessage transferPay(HttpServletRequest request, HttpServletResponse response,
								   @RequestParam(defaultValue="") String amount, @RequestParam(defaultValue="0") long time,
								   @RequestParam(defaultValue="") String secret, String callback, String salt) {
		if(true){
			return JSONMessage.failureByErrCode(ResultCode.PleaseUpgradeLatestVersion);
		}
		if(1 != SKBeanUtils.getImCoreService().getClientConfig().getEnableWxPay()){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.FUNCTION_NOTOPEN);
		}
		if(StringUtil.isEmpty(amount)) {
			return JSONMessage.failureByErrCode(PayResultCode.NoTransferMoney);
		}else if(StringUtil.isEmpty(secret)) {
			return JSONMessage.failureByErrCode(ResultCode.ParamsLack);
		}
		
		int userId = ReqUtil.getUserId();
		User user =userCoreService.getUser(userId);
		if(null==user) {
			//return JSONMessage.failure("");
		}
		/**
		 * 默认提现 0.3元
		 */
		//amount="30";
		
		String openid=user.getOpenid();
		//业务判断 openid是否有收款资格
		if(StringUtil.isEmpty(openid)) {
			 openid=authKeysService.getWxopenid(userId);
			if(StringUtil.isEmpty(openid))
				return JSONMessage.failureByErrCode(PayResultCode.NoWXAuthorization);
		}else if(!authServiceOldUtils.authRequestTime(time)) {
			return JSONMessage.failureByErrCode(ResultCode.AUTH_FAILED);
		}
		
		DecimalFormat df = new DecimalFormat("#.00");
		/**
		 * 0.5
		 * 提现金额
		 */
		double total=Double.valueOf(amount)/100;
		if(0.5>total) {
			return JSONMessage.failureByErrCode(PayResultCode.WithdrawMin);
		}
		String token = getAccess_token();
		if(StringUtil.isEmpty(salt)){
			if(!authServiceOldUtils.authWxTransferPay(user.getPayPassword(),userId+"", token, amount,openid,time, secret)) {
				return JSONMessage.failureByErrCode(ResultCode.AUTH_FAILED);
			}
		}


		if(StringUtil.isEmpty(amount)) {
			return JSONMessage.failureByErrCode(PayResultCode.NoTransferMoney);
		}
		// 提现金额
		if(SKBeanUtils.getImCoreService().getPayConfig().getMaxWithdrawAmount()<total) {
			return JSONMessage.failureByErrCode(PayResultCode.TransferMaxMoney);
		}
		// 判断用户单日消费金额
		Double todayMoney = consumeRecordManager.getUserPayMoney(userId,KConstants.ConsumeType.PUT_RAISE_CASH,KConstants.OrderStatus.END, DateUtil.getTodayMorning().getTime()/1000 ,DateUtil.getTodayNight().getTime()/1000);
		todayMoney = todayMoney + total;
		if(todayMoney>SKBeanUtils.getImCoreService().getPayConfig().getDayMaxWithdrawAmount()){
			return JSONMessage.failureByErrCode(PayResultCode.ExceedDayMaxAmount);
		}

		user.setOpenid(openid);
		return transfersManager.wxWithdrawalPay(String.valueOf(total),user,request.getRemoteAddr());
		
	}
	
	/**
	 * 企业向个人支付转账
	 * @param request
	 * @param response
	 * @param openid 用户openid
	 * @param callback
	 */
	@ApiOperation("企业向个人支付转账")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="data" , value="加密参数",dataType="String",required=true,defaultValue = ""),
			@ApiImplicitParam(paramType="query" , name="codeId" , value="标识编号",dataType="String",required=true,defaultValue = "0"),
			@ApiImplicitParam(paramType="query" , name="callback" , value="回调参数",dataType="String",required=true)
	})
    @RequestMapping(value = "/wx/pay/v1", method = RequestMethod.POST)
	public JSONMessage transferPayV1(HttpServletRequest request, HttpServletResponse response, 
			@RequestParam(defaultValue="") String data,
			@RequestParam(defaultValue="") String codeId, String callback) {

		if(1 != SKBeanUtils.getImCoreService().getClientConfig().getEnableWxPay()){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.FUNCTION_NOTOPEN);
		}

		int userId = ReqUtil.getUserId();
		String token = getAccess_token();

		String openid=authKeysService.getWxopenid(userId);
		String pwd=authKeysService.getPayPassword(userId);
		//业务判断 openid是否有收款资格
		if(StringUtil.isEmpty(openid)) {
			return JSONMessage.failureByErrCode(PayResultCode.NoWXAuthorization);
		}
		JSONObject jsonObj = authServiceUtils.authWxWithdrawalPay(userId, token, data, codeId, pwd);
		if(null==jsonObj) {
			return JSONMessage.failureByErrCode(ResultCode.AUTH_FAILED);
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
		Double todayMoney = consumeRecordManager.getUserPayMoney(userId,KConstants.ConsumeType.PUT_RAISE_CASH,KConstants.OrderStatus.END, DateUtil.getTodayMorning().getTime()/1000 ,DateUtil.getTodayNight().getTime()/1000);
		todayMoney = todayMoney + total;
		if(todayMoney>SKBeanUtils.getImCoreService().getPayConfig().getDayMaxWithdrawAmount()){
			return JSONMessage.failureByErrCode(PayResultCode.ExceedDayMaxAmount);
		}

		User user = userCoreService.getUser(userId);
		user.setOpenid(openid);
		return transfersManager.wxWithdrawalPay(amount,user,request.getRemoteAddr());
		
	}

		

	/**
	 * 企业向个人转账查询
	 * @param request
	 * @param response
	 * @param tradeno 商户转账订单号
	 * @param callback
	 */
	@ApiOperation("企业向个人转账查询")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="tradeno" , value="包裹值",dataType="int",required=true,defaultValue = "0"),
			@ApiImplicitParam(paramType="query" , name="callback" , value="回调值",dataType="int",required=true,defaultValue = "0")
	})
    @RequestMapping(value = "/pay/query", method = RequestMethod.POST)
	public void orderPayQuery(HttpServletRequest request, HttpServletResponse response, String tradeno,
			String callback) {
		logger.info("[/transfer/pay/query]");
		if (StringUtil.isEmpty(tradeno)) {
			
		}

		Map<String, String> restmap = null;
		try {
			Map<String, String> parm = new HashMap<String, String>();
			parm.put("appid", wxConfig.getAppid());
			parm.put("mch_id", wxConfig.getMchid());
			parm.put("partner_trade_no", tradeno);
			parm.put("nonce_str", WXPayUtil.getNonceStr());
			parm.put("sign", PayUtil.getSign(parm, wxConfig.getApiKey()));

			String restxml = HttpUtils.posts(TRANSFERS_PAY_QUERY, XmlUtil.xmlFormat(parm, true));
			restmap = WXNotify.parseXmlToList2(restxml);
		} catch (Exception e) {
			logger.error(e.getMessage());
		}

		if (CollectionUtil.isNotEmpty(restmap) && "SUCCESS".equals(restmap.get("result_code"))) {
			// 订单查询成功 处理业务逻辑
			logger.info("订单查询：订单" + restmap.get("partner_trade_no") + "支付成功");
			Map<String, String> transferMap = new HashMap<>();
			transferMap.put("partner_trade_no", restmap.get("partner_trade_no"));//商户转账订单号
			transferMap.put("openid", restmap.get("openid")); //收款微信号
			transferMap.put("payment_amount", restmap.get("payment_amount")); //转账金额
			transferMap.put("transfer_time", restmap.get("transfer_time")); //转账时间
			transferMap.put("desc", restmap.get("desc")); //转账描述
		
		}else {
			if (CollectionUtil.isNotEmpty(restmap)) {
				logger.error("订单转账失败：" + restmap.get("err_code") + ":" + restmap.get("err_code_des"));
			}
			
		}
	}

}
