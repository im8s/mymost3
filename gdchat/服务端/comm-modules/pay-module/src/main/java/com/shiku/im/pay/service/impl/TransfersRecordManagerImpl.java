package com.shiku.im.pay.service.impl;

import com.alipay.api.AlipayApiException;
import com.alipay.api.request.AlipayFundTransToaccountTransferRequest;
import com.alipay.api.response.AlipayFundTransToaccountTransferResponse;
import com.alipay.util.AliPayUtil;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.utils.NumberUtil;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.pay.constants.PayResultCode;
import com.shiku.im.pay.dao.AliPayTransfersRecordDao;
import com.shiku.im.pay.dao.ConsumeRecordDao;
import com.shiku.im.pay.dao.TransfersRecordDao;
import com.shiku.im.pay.entity.AliPayTransfersRecord;
import com.shiku.im.pay.entity.BaseConsumeRecord;
import com.shiku.im.pay.entity.TransfersRecord;
import com.shiku.im.user.config.WXConfig;
import com.shiku.im.user.constants.MoneyLogConstants.MoenyAddEnum;
import com.shiku.im.user.constants.MoneyLogConstants.MoneyLogEnum;
import com.shiku.im.user.constants.MoneyLogConstants.MoneyLogTypeEnum;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.entity.UserMoneyLog;
import com.shiku.im.user.service.UserCoreRedisRepository;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.CollectionUtil;
import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
import com.wxpay.utils.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.DecimalFormat;
import java.util.HashMap;
import java.util.Map;

@Service
public class TransfersRecordManagerImpl {

	@Autowired
	private TransfersRecordDao transfersRecordDao;
	public TransfersRecordDao getTransfersRecordDao(){
		return transfersRecordDao;
	}
	@Autowired
	private ConsumeRecordDao consumeRecordDao;
	@Autowired
	private AliPayTransfersRecordDao aliPayTransfersRecordDao;


	private static final String TRANSFERS_PAY = "https://api.mch.weixin.qq.com/mmpaymkttransfers/promotion/transfers"; // 企业付款

	protected Logger logger= LoggerFactory.getLogger(this.getClass());


	@Autowired
	private UserCoreService userCoreService;

	/*@Autowired
	private AuthKeysService authKeysService;*/

	@Autowired
	private ConsumeRecordManagerImpl consumeRecordManager;

	@Autowired
	private UserCoreRedisRepository userCoreRedisRepository;

	@Autowired(required = false)
	private WXConfig wxConfig;


	/**
	 * 提现的 分布式锁 Key
	 */
	private static final String transferLockKey="transferLock:%s";


	/**
	 * 微信提现
	 * 数据库操作
	 * @param record
	 */
	private  void  transfersToWXUser(TransfersRecord record) {
		try {
			BaseConsumeRecord entity=new BaseConsumeRecord();
			entity.setTime(DateUtil.currentTimeSeconds());
			entity.setType(KConstants.ConsumeType.PUT_RAISE_CASH);
			entity.setChangeType(KConstants.MOENY_REDUCE);
			entity.setDesc("微信提现");
			entity.setStatus(KConstants.OrderStatus.END);
			entity.setTradeNo(record.getOutTradeNo());
			entity.setPayType(KConstants.PayType.BALANCEAY);

			
			DecimalFormat df = new DecimalFormat("#.00");
			double total=Double.valueOf(record.getTotalFee());
			
			total= Double.valueOf(df.format(total));
			
			entity.setMoney(total);

			UserMoneyLog userMoneyLog =new UserMoneyLog(record.getUserId(),0,record.getOutTradeNo(),total,
					MoenyAddEnum.MOENY_REDUCE, MoneyLogEnum.CASH_OUT, MoneyLogTypeEnum.NORMAL_PAY);

			userMoneyLog.setExtra("WX_PAY");


			Double balance = userCoreService.rechargeUserMoenyV1(userMoneyLog);

			entity.setServiceCharge(Double.valueOf(record.getFee()));// 手续费
			entity.setOperationAmount(Double.valueOf(record.getRealFee()));// 实际操作金额
			entity.setCurrentBalance(balance);// 当前余额
			consumeRecordManager.saveConsumeRecord(entity);
			transfersRecordDao.addTransfersRecord(record);

		} catch (Exception e) {
			e.printStackTrace();
		}
		
		
	}
	
	/**
	 * 支付宝提现
	 * @param record
	 */
	private  void transfersToAliPay(AliPayTransfersRecord record){
		try {

			double total=Double.valueOf(record.getTotalFee());

			UserMoneyLog userMoneyLog =new UserMoneyLog(record.getUserId(),0,record.getOutTradeNo(),total,
					MoenyAddEnum.MOENY_REDUCE, MoneyLogEnum.CASH_OUT, MoneyLogTypeEnum.NORMAL_PAY);

			userMoneyLog.setExtra("ALI_PAY");


			Double balance =userCoreService.rechargeUserMoenyV1(userMoneyLog);

			BaseConsumeRecord entity=new BaseConsumeRecord();
			entity.setUserId(ReqUtil.getUserId());
			entity.setTime(DateUtil.currentTimeSeconds());
			entity.setType(KConstants.ConsumeType.PUT_RAISE_CASH);
			entity.setChangeType(KConstants.MOENY_REDUCE);
			entity.setDesc("支付宝提现");
			entity.setStatus(KConstants.OrderStatus.END);
			entity.setTradeNo(record.getOutTradeNo());
			entity.setPayType(KConstants.PayType.BALANCEAY);

			entity.setMoney(total);
			entity.setServiceCharge(Double.valueOf(record.getFee()));// 手续费
			entity.setOperationAmount(Double.valueOf(record.getRealFee()));// 实际操作金额
			entity.setBusinessId(record.getOutTradeNo());
			// 当前余额
			entity.setCurrentBalance(balance);
			aliPayTransfersRecordDao.addAliPayTransfersRecord(record);
			consumeRecordDao.addConsumRecord(entity);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}



	public JSONMessage wxWithdrawalPay(String amount, User user, String remoteAddr) {
		int userId=user.getUserId();
		String openid=user.getOpenid();
		/**
		 * 默认提现 0.3元
		 */
		//amount="30";



		DecimalFormat df = new DecimalFormat("#.00");
		/**
		 * 0.5
		 * 提现金额
		 */
		double total=Double.valueOf(amount);

		if(0.5>total) {
			return JSONMessage.failureByErrCode(PayResultCode.WithdrawMin);
		}
		/**
		 * 0.01
		 *
		 * 0.6%
		 * 提现手续费
		 * 2020-01-07 12:00 费率改为从配置文件中获取
		 */
		double fee =Double.valueOf(df.format((total*SKBeanUtils.getImCoreService().getPayConfig().getMyChangeWithdrawRate())));
		if(0.01>fee) {
			fee=0.01;
		}else  {
			fee= NumberUtil.getCeil(fee, 2);
		}

		/**
		 * 0.49
		 * 实际到账金额
		 */
		Double totalFee= Double.valueOf(df.format(total-fee));
		/**
		 * 调用 提交代码 支持分布式锁
		 */
		try {
			final double feel = fee;
			return (JSONMessage) userCoreService.payMoenyBalanceOnLock(userId,total, callback -> {
				return transfersToWXOnLock(user,total,totalFee,feel,remoteAddr);
			});

		} catch (Exception e) {
			logger.error(e.getMessage(),e);
		}

		return JSONMessage.failureByErrCode(PayResultCode.WithdrawFailure);


	}

	/**
	 * 提现 到微信 账户中
	 * @param user
	 * @param total
	 * @param totalFee
	 * @param fee
	 * @param remoteAddr
	 * @return
	 */
	private JSONMessage transfersToWXOnLock(User user,double total,double totalFee,double fee,String remoteAddr){

		int userId=user.getUserId();
		Double balance = userCoreService.getUserMoenyV1(userId);
		if(totalFee>balance) {
			return JSONMessage.failureByErrCode(PayResultCode.InsufficientBalance);
		}

		/**
		 * 49.0
		 */
		Double realFee=(totalFee*100);

		/**
		 * 49
		 */
		String realFeeStr=realFee.intValue()+"";

		logger.info(String.format("=== transferPay userid %s username %s 提现金额   %s 手续费   %s  到账金额   %s ",
				userId,user.getNickname(),total,fee,totalFee));
		/**
		 * ow9Ctwy_qP8OoLr_6T-5oMnBud8w
		 */




		Map<String, String> restmap = null;

		TransfersRecord record=new TransfersRecord();
		try {
			record.setUserId(userId);
			record.setAppid(wxConfig.getAppid());
			record.setMchId(wxConfig.getMchid());
			record.setNonceStr(WXPayUtil.getNonceStr());
			record.setOutTradeNo(StringUtil.getOutTradeNo());
			record.setOpenid(user.getOpenid());
			record.setTotalFee(String.valueOf(total));
			record.setFee(fee+"");
			record.setRealFee(totalFee+"");
			record.setCreateTime(DateUtil.currentTimeSeconds());
			record.setStatus(0);

			Map<String, String> parm = new HashMap<String, String>();
			parm.put("mch_appid", wxConfig.getAppid()); //公众账号appid
			parm.put("mchid", wxConfig.getMchid()); //商户号
			parm.put("nonce_str", record.getNonceStr()); //随机字符串
			parm.put("partner_trade_no", record.getOutTradeNo()); //商户订单号
			parm.put("openid", user.getOpenid()); //用户openid
			parm.put("check_name", "NO_CHECK"); //校验用户姓名选项 OPTION_CHECK
			//parm.put("re_user_name", "安迪"); //check_name设置为FORCE_CHECK或OPTION_CHECK，则必填
			parm.put("amount", realFeeStr); //转账金额
			parm.put("desc", "即时通讯提现"); //企业付款描述信息
			parm.put("spbill_create_ip", remoteAddr); //支付Ip地址
			parm.put("sign", PayUtil.getSign(parm, wxConfig.getApiKey()));

			String restxml = HttpUtils.posts(TRANSFERS_PAY, XmlUtil.xmlFormat(parm, false));
			restmap = WXNotify.parseXmlToList2(restxml);
		} catch (Exception e) {
			logger.error(e.getMessage());
		}

		if (CollectionUtil.isNotEmpty(restmap) && "SUCCESS".equals(restmap.get("result_code"))) {
			logger.info("提现成功：" + restmap.get("result_code") + ":" + restmap.get("return_code"));
			Map<String, String> transferMap = new HashMap<>();
			transferMap.put("partner_trade_no", restmap.get("partner_trade_no"));//商户转账订单号
			transferMap.put("payment_no", restmap.get("payment_no")); //微信订单号
			transferMap.put("payment_time", restmap.get("payment_time")); //微信支付成功时间

			record.setPayNo(restmap.get("payment_no"));
			record.setPayTime(restmap.get("payment_time"));
			record.setResultCode(restmap.get("result_code"));
			record.setReturnCode(restmap.get("return_code"));
			record.setStatus(1);
			record.setUserId(ReqUtil.getUserId());
			transfersToWXUser(record);

			return JSONMessage.success(transferMap);
		}else {
			if (CollectionUtil.isNotEmpty(restmap)) {
				String resultMsg=restmap.get("err_code") + ":" + restmap.get("err_code_des");
				logger.error("提现失败： 请联系管理员 " + resultMsg);
				record.setErrCode(restmap.get("err_code"));
				record.setErrDes(restmap.get("err_code_des"));
				record.setStatus(-1);
				transfersRecordDao.addTransfersRecord(record);
				return JSONMessage.failure(resultMsg);
			}
			return JSONMessage.failureByErrCode(PayResultCode.WithdrawFailure);
		}
	}

	private JSONMessage transfersToAliPayOnLock(User user,String amount,double totalFee,double fee){
		int userId=user.getUserId();
		Double balance = userCoreService.getUserMoenyV1(userId);
		if(totalFee>balance) {
			return JSONMessage.failureByErrCode(PayResultCode.InsufficientBalance);
		}
		String orderId=StringUtil.getOutTradeNo();
		AliPayTransfersRecord record=new AliPayTransfersRecord();
		record.setUserId(userId);
		record.setAppid(AliPayUtil.APP_ID);
		record.setOutTradeNo(orderId);
		record.setAliUserId(user.getAliUserId());
		record.setTotalFee(amount);
		record.setFee(fee+"");
		record.setRealFee(totalFee+"");
		record.setCreateTime(DateUtil.currentTimeSeconds());
		record.setStatus(0);

		AlipayFundTransToaccountTransferRequest request = new AlipayFundTransToaccountTransferRequest();
//		request.setBizModel(bizModel);

		request.setBizContent("{" +
				"    \"out_biz_no\":\""+orderId+"\"," +  // 订单Id
				"    \"payee_type\":\"ALIPAY_USERID\"," + // 收款人的账户类型
				"    \"payee_account\":\""+user.getAliUserId()+"\"," + // 收款人
				"    \"amount\":\""+totalFee+"\"," +	// 金额
				"    \"payer_show_name\":\"余额提现\"," +
				"    \"remark\":\"转账备注\"," +
				"  }");
		try {
			AlipayFundTransToaccountTransferResponse response = AliPayUtil.getAliPayClient().execute(request);
			System.out.println("支付返回结果  "+response.getCode());
			if(response.isSuccess()){
				record.setResultCode(response.getCode());
				record.setCreateTime(DateUtil.toTimestamp(response.getPayDate()));
				record.setStatus(1);
				transfersToAliPay(record);

				logger.info("支付宝提现成功");
				return JSONMessage.success();
			} else {
				record.setErrCode(response.getErrorCode());
				record.setErrDes(response.getMsg());
				record.setStatus(-1);
				aliPayTransfersRecordDao.addAliPayTransfersRecord(record);
				logger.info("支付宝提现失败");
				return JSONMessage.failureByErrCode(PayResultCode.WithdrawFailure);
			}
		} catch (AlipayApiException e) {
			e.printStackTrace();
			return JSONMessage.failureByErrCode(PayResultCode.WithdrawFailure);
		}
	}

	public  JSONMessage aliWithdrawalPay(User user, String amount) {
		int userId=user.getUserId();
		// 提现金额
		double total=(Double.valueOf(amount));


		/**
		 * 提现手续费 0.6%
		 * 支付宝是没有手续费，但是因为充值是收取0.6%费用，在这里提现收取0.6%的费用
		 * 2020-01-07 12:00 费率改为从配置文件中获取
		 */
		DecimalFormat df = new DecimalFormat("#.00");
		double fee =Double.valueOf(df.format(total* SKBeanUtils.getImCoreService().getPayConfig().getMyChangeWithdrawRate()));
		if(0.01>fee) {
			fee=0.01;
		}else  {
			fee=NumberUtil.getCeil(fee, 2);
		}

		/**
		 *
		 * 实际到账金额  = 提现金额-手续费
		 */
		Double totalFee= Double.valueOf(df.format(total-fee));

		/**
		 * 调用 提交代码 支持分布式锁
		 */

		try {
			final  double fee1  = fee;
			return (JSONMessage) userCoreService.payMoenyBalanceOnLock(userId,total, callback->{
				return transfersToAliPayOnLock(user,amount,totalFee,fee1);
			});
		} catch (Exception e) {
			logger.error(e.getMessage(),e);
			return JSONMessage.failureByErrCode(PayResultCode.WithdrawFailure);
		}



	}

}
