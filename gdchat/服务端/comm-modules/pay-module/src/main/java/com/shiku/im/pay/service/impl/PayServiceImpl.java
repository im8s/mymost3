package com.shiku.im.pay.service.impl;

import com.alibaba.fastjson.JSONObject;
import com.shiku.commons.task.TimerTask;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.config.AppConfig;
import com.shiku.im.message.MessageService;
import com.shiku.im.message.MessageType;
import com.shiku.im.open.dao.SkOpenAppDao;
import com.shiku.im.open.opensdk.OpenAppManageImpl;
import com.shiku.im.open.opensdk.OpenWebManageImpl;
import com.shiku.im.open.opensdk.entity.SkOpenApp;
import com.shiku.im.pay.constants.ConsumeRecordEnum;
import com.shiku.im.pay.constants.PayResultCode;
import com.shiku.im.pay.dao.CodePayDao;
import com.shiku.im.pay.dao.ConsumeRecordDao;
import com.shiku.im.pay.dao.PayOrderDao;
import com.shiku.im.pay.entity.BaseConsumeRecord;
import com.shiku.im.pay.entity.CodePay;
import com.shiku.im.pay.entity.PayOrder;
import com.shiku.im.pay.service.PayRedisService;
import com.shiku.im.pay.service.PayService;
import com.shiku.im.pay.utils.OtpHelper;
import com.shiku.im.user.constants.MoneyLogConstants.MoenyAddEnum;
import com.shiku.im.user.constants.MoneyLogConstants.MoneyLogEnum;
import com.shiku.im.user.constants.MoneyLogConstants.MoneyLogTypeEnum;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.entity.UserMoneyLog;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.vo.JSONMessage;
import com.shiku.redisson.ex.LockFailException;
import com.shiku.utils.Base64;
import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
import com.wxpay.utils.MD5Util;
import com.wxpay.utils.WXPayUtil;
import com.wxpay.utils.http.HttpClientConnectionManager;
import lombok.extern.slf4j.Slf4j;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.conn.tsccm.ThreadSafeClientConnManager;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.net.UnknownHostException;
import java.util.*;
@Slf4j
@Service
public class PayServiceImpl implements PayService {
	
	public static DefaultHttpClient httpclient = new DefaultHttpClient(new ThreadSafeClientConnManager());
	@Autowired
	private ConsumeRecordDao consumeRecordDao;
	@Autowired
	private PayOrderDao payOrderDao;
	@Autowired(required = false)
	private SkOpenAppDao skOpenAppDao;
	@Autowired
	private CodePayDao codePayDao;


	@Autowired
	private PayRedisService payRedisService;

	@Autowired
	private UserCoreService userCoreService;

	@Autowired
	private MessageService messageService;

	@Autowired
	private OpenAppManageImpl openAppManage;

	@Autowired
	private OpenWebManageImpl openWebManage;

	@Autowired
	private AppConfig appConfig;


	/**
	 * ???????????? ???????????? paymentCode
	 */
	private static final String LOCK_PAYMENTCODE="lock:pay:paymentCode:%s";


	


	/**
	 * ??????20????????????
	 * ????????????   (userId+n+opt)??????+(userId+n+opt)+opt+(time/opt)
	 * @param paymentCode
	 * @return
	 */
	public Integer analysisCode(String paymentCode){
		int n=9;// ?????????
		String userIdCodeLength=paymentCode.substring(0, 1);// ???????????????userId+n+opt????????????
		
		// userIdCode=userId+n+opt
		String userIdCode=paymentCode.substring(userIdCodeLength.length(),Integer.valueOf(userIdCodeLength)+1);
		
		int three=userIdCodeLength.length()+userIdCode.length();
		String opt=paymentCode.substring(three, three+3);
		
		int four=three+3;
		// timeCode=time/opt
		String timeCode=paymentCode.substring(four,paymentCode.length());
		
		int userId=Integer.valueOf(userIdCode)-n-Integer.valueOf(opt);
		
		long time=Integer.valueOf(timeCode)*Integer.valueOf(opt);
		if(System.currentTimeMillis()/1000-time<256){
			return userId;
		}else{
			time=Integer.valueOf(timeCode)*(Integer.valueOf(opt)-100);
			if(System.currentTimeMillis()/1000-time<256){
				return userId;
			}else{
				return null;
			}
		}
		
	}


	public boolean paymentCodePayAuth(OtpHelper.QrCode qrCode) throws Exception {



		return true;
	};
	/**
	 * ???????????????????????????
	 * @param userId ?????????
	 * @param fromUserId ?????????--???????????????
	 * @param money
	 */
	public  void paymentCodePay(OtpHelper.QrCode qrCode,String paymentCode,Integer userId,Integer fromUserId,String money,String desc) throws Exception {

		String redisKey = payRedisService.buildRedisKey(LOCK_PAYMENTCODE, fromUserId);
		try {
			payRedisService.executeOnLock(redisKey,obj->{
				// ????????????????????????
				if(checkPaymentCode(fromUserId, paymentCode)){
					 throw new ServiceException(PayResultCode.PayCodeExpired);
				}
				if(null!=qrCode){
					String apiKey =appConfig.getApiKey();
					String qrKey = payRedisService.queryPayQrKey(qrCode.getUserId());
					if(StringUtil.isEmpty(qrKey)){
						throw new ServiceException(KConstants.ResultCode.AUTH_FAILED);
					}
					byte[] decode = Base64.decode(qrKey);
					long time=System.currentTimeMillis()/60000;
					long otp = OtpHelper.otp(apiKey, qrCode.getUserId(), time, decode,qrCode.getRandByte());
					if(qrCode.getOtp()!=otp){
						otp = OtpHelper.otp(apiKey, qrCode.getUserId(), time-1, decode,qrCode.getRandByte());
						if(qrCode.getOtp()!=otp){
							otp = OtpHelper.otp(apiKey, qrCode.getUserId(), time+1, decode,qrCode.getRandByte());
							if(qrCode.getOtp()!=otp){
								throw new ServiceException(KConstants.ResultCode.AUTH_FAILED);
							}
						}
					}
				}


				Double balance = userCoreService.getUserMoenyV1(fromUserId);
				Double doubleMoney = Double.valueOf(money);
				if(balance<doubleMoney){
					throw new ServiceException(PayResultCode.InsufficientBalance);
				}
				if(doubleMoney>50){
					throw new ServiceException("???????????? 50?????????!");
				}else if(balance< doubleMoney){
					throw new ServiceException("??????????????????,????????????");
				}
				double toDayCodePayCount = queryToDayCodePayCount(fromUserId);
				if((toDayCodePayCount+doubleMoney)>500){
					throw new ServiceException("????????????????????????,????????????");
				}
				double count = queryCodePayCount(fromUserId);
				if(count>5000){
					throw new ServiceException("?????????????????????,????????????");
				}

				try {
					userCoreService.payMoenyBalanceOnLock(fromUserId, doubleMoney, obj1 -> {
					   paymentCodePayOnLock(paymentCode, userId, fromUserId, money, desc);
					   return null;
				   });
				} catch (ServiceException e) {
					throw e;
				}catch (Exception e) {
					throw new ServiceException(e.getMessage());
				}

				return true;
			});
		} catch (LockFailException e) {
			throw new ServiceException(KConstants.ResultCode.SystemIsBusy);
		}catch (Exception e) {
			throw e;
		}


	}

	/**
	 * ???????????????????????????
	 * @param userId ?????????
	 * @param fromUserId ?????????--???????????????
	 * @param money
	 */
	public  void paymentCodePayOnLock(String paymentCode,Integer userId,Integer fromUserId,String money,String desc){

		User fromUser = userCoreService.getUser(fromUserId);
		User user = userCoreService.getUser(userId);

		Double doubleMoney = Double.valueOf(money);

		CodePay codePay=new CodePay();
		codePay.setQrCode(paymentCode);
		codePay.setUserId(fromUserId);
		codePay.setUserName(fromUser.getNickname());
		codePay.setType(1);
		codePay.setToUserId(userId);
		codePay.setToUserName(user.getNickname());
		codePay.setMoney(Double.valueOf(money));
		codePay.setCreateTime(DateUtil.currentTimeSeconds());
		codePay.setId(ObjectId.get());
		saveCodePay(codePay);

		/**
		 * ????????? ??????????????????
		 */
		UserMoneyLog userMoneyLog =new UserMoneyLog(fromUserId,userId,codePay.getId().toString(),doubleMoney,
				MoenyAddEnum.MOENY_REDUCE, MoneyLogEnum.PAYMENTCODE_PAY, MoneyLogTypeEnum.NORMAL_PAY);

		// ??????
		Double lessBalance = userCoreService.rechargeUserMoenyV1(userMoneyLog);
		String lessTradeNo= StringUtil.getOutTradeNo();
		//????????????????????????
		BaseConsumeRecord lessRecord=new BaseConsumeRecord();
		lessRecord.setUserId(fromUserId);
		lessRecord.setToUserId(userId);
		lessRecord.setTradeNo(lessTradeNo);
		lessRecord.setMoney(doubleMoney);
		lessRecord.setBusinessId(userMoneyLog.getBusinessId());

		lessRecord.setCurrentBalance(lessBalance);
		lessRecord.setStatus(KConstants.OrderStatus.END);
		lessRecord.setType(KConstants.ConsumeType.SEND_PAYMENTCODE);
		lessRecord.setChangeType(KConstants.MOENY_REDUCE);
		//????????????
		lessRecord.setPayType(KConstants.PayType.BALANCEAY);
		lessRecord.setOperationAmount(doubleMoney);
		if(!StringUtil.isEmpty(desc)){
			lessRecord.setDesc(desc);
		}else{
			lessRecord.setDesc(ConsumeRecordEnum.getDesc(KConstants.ConsumeType.SEND_PAYMENTCODE));
		}

		lessRecord.setTime(DateUtil.currentTimeSeconds());
		consumeRecordDao.addConsumRecord(lessRecord);
		// ??????xmpp??????????????????
		User sysUser = userCoreService.getUser(1100);
		MessageBean messageBean = new MessageBean();
		messageBean.setFromUserId(sysUser.getUserId().toString());
		messageBean.setFromUserName(sysUser.getNickname());
		messageBean.setType(MessageType.CODEPAYMENT);
		messageBean.setContent(JSONObject.toJSONString(codePay));
		messageBean.setMsgType(0);// ??????????????????
		messageBean.setMessageId(StringUtil.randomUUID());
		messageBean.setToUserId(fromUserId.toString());
		messageBean.setToUserName(fromUser.getNickname());
		try {
			messageService.send(messageBean);
		} catch (Exception e) {
			e.printStackTrace();
		}

		/**
		 * ????????? ??????????????????
		 */
		UserMoneyLog toUserMoneyLog =new UserMoneyLog(userId,fromUserId,codePay.getId().toString(),doubleMoney,
				MoenyAddEnum.MOENY_ADD, MoneyLogEnum.PAYMENTCODE_PAY, MoneyLogTypeEnum.RECEIVE);

		// ??????
		Double addBalance =  userCoreService.rechargeUserMoenyV1(toUserMoneyLog);
		String addTradeNo=StringUtil.getOutTradeNo();
		//????????????????????????
		BaseConsumeRecord addRecord=new BaseConsumeRecord();
		addRecord.setUserId(userId);
		addRecord.setToUserId(fromUserId);
		addRecord.setTradeNo(addTradeNo);
		addRecord.setMoney(doubleMoney);
		addRecord.setCurrentBalance(addBalance);
		addRecord.setBusinessId(toUserMoneyLog.getBusinessId());
		addRecord.setStatus(KConstants.OrderStatus.END);
		addRecord.setType(KConstants.ConsumeType.RECEIVE_PAYMENTCODE);
		addRecord.setChangeType(KConstants.MOENY_ADD);
		addRecord.setPayType(KConstants.PayType.BALANCEAY); //????????????
		addRecord.setDesc(ConsumeRecordEnum.getDesc(KConstants.ConsumeType.RECEIVE_PAYMENTCODE));
		addRecord.setTime(DateUtil.currentTimeSeconds());
		addRecord.setOperationAmount(doubleMoney);
		consumeRecordDao.addConsumRecord(addRecord);
		// ??????xmpp??????????????????
		MessageBean message=new MessageBean();
		message.setFromUserId(sysUser.getUserId().toString());
		message.setFileName(sysUser.getNickname());
		message.setType(MessageType.CODEARRIVAL);
		message.setMsgType(0);
		message.setMessageId(StringUtil.randomUUID());
		message.setContent(JSONObject.toJSONString(codePay));
		message.setToUserId(userId.toString());
		message.setToUserName(user.getNickname());
		try {
			messageService.send(message);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// ???????????????????????????
		payRedisService.savePaymentCode(paymentCode, fromUserId);
	}



	public String getPayQrKey(int userId){
		String qrKey = payRedisService.queryPayQrKey(userId);
		if(!StringUtil.isEmpty(qrKey)) {
			return  qrKey;
		}
		byte[] codeArr=new byte[16];
		Random rom =new Random();
		rom.nextBytes(codeArr);
		qrKey = Base64.encode(codeArr);
		payRedisService.savePayQrKey(userId,qrKey);
		return qrKey;
	}
	
	/**
	 * ????????????????????????
	 * @param userId
	 * @param paymentCode
	 * @return
	 */
	public boolean checkPaymentCode(Integer userId,String paymentCode){
		Integer value=payRedisService.getPaymentCode(paymentCode);
		if(null!=value){
			return true;
		}else{
			return false;
		}
		
	}
	
	/**
	 * ???????????????????????????
	 * @param userId  ?????????(????????????)
	 * @param fromUserId  ?????????(????????????)--???????????????
	 * @param money
	 */
	public synchronized void receipt(Integer userId,Integer fromUserId,String money,String desc) throws Exception {
		userCoreService.payMoenyBalanceOnLock(userId,Double.valueOf(money),obj -> {
			 receiptOnLock(userId,fromUserId,money,desc);
			return null;
		});
	}

	public  void receiptOnLock(Integer userId,Integer fromUserId,String money,String desc){
		User user = userCoreService.getUser(userId);
		User fromUser = userCoreService.getUser(fromUserId);

		Double doubleMoney = Double.valueOf(money);

		CodePay codePay=new CodePay();
		codePay.setUserId(fromUserId);
		codePay.setType(2);
		codePay.setUserName(fromUser.getNickname());
		codePay.setToUserId(userId);
		codePay.setToUserName(user.getNickname());
		codePay.setMoney(doubleMoney);
		codePay.setCreateTime(DateUtil.currentTimeSeconds());
		codePay.setId(ObjectId.get());
		saveCodePay(codePay);

		/**
		 * ??????????????? ??????????????????
		 */
		UserMoneyLog userMoneyLog =new UserMoneyLog(userId,fromUserId,codePay.getId().toString(),doubleMoney,
				MoenyAddEnum.MOENY_REDUCE, MoneyLogEnum.RQCODE_PAY, MoneyLogTypeEnum.NORMAL_PAY);

		userCoreService.rechargeUserMoenyV1(userMoneyLog);
		String lessTradeNo=StringUtil.getOutTradeNo();
		//????????????????????????
		BaseConsumeRecord lessRecord=new BaseConsumeRecord();
		lessRecord.setUserId(userId);
		lessRecord.setToUserId(fromUserId);
		lessRecord.setTradeNo(lessTradeNo);
		lessRecord.setMoney(doubleMoney);
		lessRecord.setStatus(KConstants.OrderStatus.END);
		lessRecord.setCurrentBalance(userMoneyLog.getEndMoeny());
		lessRecord.setBusinessId(userMoneyLog.getBusinessId());
		lessRecord.setType(KConstants.ConsumeType.SEND_QRCODE);
		lessRecord.setChangeType(KConstants.MOENY_REDUCE);
		lessRecord.setPayType(KConstants.PayType.BALANCEAY); // ????????????
		lessRecord.setOperationAmount(doubleMoney);
		if(!StringUtil.isEmpty(desc)) {
			lessRecord.setDesc(desc);
		}else {
			lessRecord.setDesc("????????????????????????");
		}
		lessRecord.setTime(DateUtil.currentTimeSeconds());
		consumeRecordDao.addConsumRecord(lessRecord);
		User sysUser = userCoreService.getUser(1100);

		MessageBean messageBean = new MessageBean();
		messageBean.setFromUserId(sysUser.getUserId().toString());
		messageBean.setFromUserName(sysUser.getNickname());
		messageBean.setType(MessageType.CODERECEIPT);
		messageBean.setContent(JSONObject.toJSONString(codePay));
		messageBean.setMsgType(0);// ??????????????????
		messageBean.setMessageId(StringUtil.randomUUID());
		messageBean.setToUserId(user.getUserId().toString());
		messageBean.setToUserName(user.getNickname());
		try {
			messageService.send(messageBean);
		} catch (Exception e) {
			e.printStackTrace();
		}

		UserMoneyLog toUserMoneyLog =new UserMoneyLog(fromUserId,userId,codePay.getId().toString(),doubleMoney,
				MoenyAddEnum.MOENY_ADD, MoneyLogEnum.RQCODE_PAY, MoneyLogTypeEnum.RECEIVE);
		// ??????
		userCoreService.rechargeUserMoeny(toUserMoneyLog);
		String addTradeNo=StringUtil.getOutTradeNo();
		// ????????????????????????
		BaseConsumeRecord addRecord=new BaseConsumeRecord();
		addRecord.setUserId(fromUserId);
		addRecord.setToUserId(userId);
		addRecord.setTradeNo(addTradeNo);
		addRecord.setMoney(doubleMoney);
		addRecord.setCurrentBalance(toUserMoneyLog.getEndMoeny());
		addRecord.setBusinessId(userMoneyLog.getBusinessId());
		addRecord.setStatus(KConstants.OrderStatus.END);
		addRecord.setType(KConstants.ConsumeType.RECEIVE_QRCODE);
		addRecord.setChangeType(KConstants.MOENY_ADD);
		addRecord.setPayType(KConstants.PayType.BALANCEAY); //????????????
		addRecord.setDesc("????????????????????????");
		addRecord.setTime(DateUtil.currentTimeSeconds());
		addRecord.setOperationAmount(doubleMoney);
		consumeRecordDao.addConsumRecord(addRecord);
		// ??????xmpp??????????????????
		MessageBean message=new MessageBean();
		message.setFromUserId(sysUser.getUserId().toString());
		message.setFromUserName(sysUser.getNickname());
		message.setType(MessageType.CODEERECEIPTARRIVAL);
		message.setMsgType(0);
		message.setMessageId(StringUtil.randomUUID());
		message.setContent(JSONObject.toJSON(codePay));
		message.setToUserId(fromUser.getUserId().toString());
		message.setToUserName(fromUser.getNickname());
		try {
			messageService.send(message);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public void saveCodePay(CodePay entity){
		codePayDao.addCodePay(entity);
	}
	
	/**
	 * ??????????????????
	 * @param xml
	 * @return
	 * @throws Exception
	 */
	public JSONMessage unifiedOrderImpl(Map<String, String> map) throws Exception{
		// ??????
		if(!checkSign(map.get("appId"), map.get("body"), map.get("input_charset"), map.get("nonce_str"), map.get("out_trade_no"), map.get("total_fee"), map.get("trade_type"),map.get("notify_url"),map.get("spbill_create_ip"), map.get("sign"))){
			throw new ServiceException(PayResultCode.AuthSignFailed);
		}
		
		// ??????app???????????????????????????
		if("APP".equals(map.get("trade_type"))){
			SkOpenApp openApp = openAppManage.getOpenAppByAppId(map.get("appId"));
			if(null==openApp){
				throw new ServiceException(PayResultCode.NotWithThirdParty);
			}else if(openApp.getIsAuthPay()!=1){
				// ??????????????????
				throw new ServiceException(KConstants.ResultCode.NO_PERMISSION);
			}
		}else if("WEB".equals(map.get("trade_type"))){
			SkOpenApp openWeb=openWebManage.checkWebAPPByAppId(map.get("appId"));
			if(null==openWeb){
				throw new ServiceException(PayResultCode.NotWithThirdParty);
			}else if(openWeb.getIsAuthPay()!=1){
				// ??????????????????
				throw new ServiceException(KConstants.ResultCode.NO_PERMISSION);
			}
		}
		
		// ????????????
		PayOrder payOrder = new PayOrder();
		payOrder.setAppId(map.get("appId"));
		payOrder.setMoney(map.get("total_fee"));
		payOrder.setTrade_no(map.get("trade_no"));
		payOrder.setCreateTime(DateUtil.currentTimeSeconds());
		payOrder.setIPAdress(map.get("spbill_create_ip"));
		payOrder.setDesc(map.get("body"));
		payOrder.setAppType(map.get("trade_type"));
		payOrder.setCallBackUrl(map.get("notify_url"));
		payOrder.setStatus((byte)0);
		payOrder.setSign(map.get("sign"));
		payOrder.setId(ObjectId.get());
//		saveEntity(payOrder);
		payOrderDao.addPayOrder(payOrder);
		payRedisService.savePayOrderSign(payOrder.getId().toString(), map.get("sign"));
		
		SortedMap<String, String> contentMap = new TreeMap<String, String>();
		contentMap.put("prepay_id", payOrder.getId().toString());
		String resultxml = WXPayUtil.paramsToxmlStr(contentMap);
		return JSONMessage.success(resultxml);
	}
	
	/**
	 * ????????????
	 * @param appId 
	 * @param body ????????????
	 * @param input_charset ????????????
	 * @param nonce_str ????????????
	 * @param trade_no ????????????
	 * @param total_fee ??????
	 * @param trade_type ??????????????????
	 * @param sign ??????
	 * @return
	 */
	public boolean checkSign(String appId,String body,String input_charset,String nonce_str,String trade_no,
			String total_fee,String trade_type,String notify_url,String spbill_create_ip,String sign){
		SortedMap<String, String> contentMap = new TreeMap<String, String>();
		contentMap.put("appId", appId);
		contentMap.put("body", body);
		contentMap.put("input_charset", input_charset);
		contentMap.put("nonce_str", nonce_str);
		contentMap.put("notify_url", notify_url);
		contentMap.put("spbill_create_ip", spbill_create_ip);
		contentMap.put("total_fee", total_fee);
		contentMap.put("out_trade_no", trade_no);
		contentMap.put("trade_type", trade_type);
		
		String signKey=createSign(contentMap);
		
		if(signKey.equals(sign)){
			return true;
		}else{
			return false;
		}
		
	}
	
	/**
	 * ???????????????????????????
	 * @param appId
	 * @param prepayId
	 * @return
	 */
	public JSONMessage getOrderInfo(String appId,String prepayId){
//		Query<PayOrder> query = getDatastore().createQuery(PayOrder.class).field("_id").equal(new ObjectId(prepayId));
//		query.field("appId").equal(appId);
//		PayOrder payOrder = query.get();
		PayOrder payOrder = payOrderDao.getPayOrder(new ObjectId(prepayId),appId);
		Map<String,String> map = new HashMap<>();
		map.put("money", payOrder.getMoney());
		map.put("desc", payOrder.getDesc());
		return JSONMessage.success(null, map);
	}
	
	/**
	 * ??????????????????
	 * @param appId
	 * @param prepayId
	 * @param sign
	 * @param userId
	 * @return
	 */
	public JSONMessage passwordPayment(String appId,String prepayId,String sign,Integer userId,String token,long time,String secret,String salt) throws Exception {
		

		
		if(!payRedisService.queryPayOrderSign(prepayId).equals(sign)){
			throw new ServiceException(PayResultCode.AuthSignFailed);
		}
		
		PayOrder payOrder = payOrderDao.getPayOrder(new ObjectId(prepayId),null);
		if(null==payOrder){
			throw new ServiceException(PayResultCode.OrderNotExist);
		}
		if(!payOrder.getAppId().equals(appId)){
			throw new ServiceException(PayResultCode.AppIdWrong);
		}

		try {
			userCoreService.payMoenyBalanceOnLock(userId,Double.valueOf(payOrder.getMoney()),obj->{
				return passwordPaymentOnLock(payOrder,appId,userId);
			});
		} catch (Exception e) {
			log.error(e.getMessage(),e);
		}

		return JSONMessage.success();
	}

	public JSONMessage passwordPaymentOnLock(PayOrder payOrder,String appId,Integer userId){

		User user = userCoreService.getUser(userId);

		payOrder.setUserId(userId.toString());
		payOrder.setStatus((byte)1);
		payOrderDao.addPayOrder(payOrder);

		Double doubleMoney = Double.valueOf(payOrder.getMoney());
		/**
		 *??????????????????
		 */
		UserMoneyLog userMoneyLog =new UserMoneyLog(userId,0,payOrder.getTrade_no(),doubleMoney,
				MoenyAddEnum.MOENY_REDUCE, MoneyLogEnum.OPEN_ORDER_PAY, MoneyLogTypeEnum.NORMAL_PAY);

		// ??????
		userCoreService.rechargeUserMoenyV1(userMoneyLog);
		// ??????????????????
		String lessTradeNo=StringUtil.getOutTradeNo();
		BaseConsumeRecord consumeRecord = new BaseConsumeRecord();
		consumeRecord.setMoney(doubleMoney);
		consumeRecord.setBusinessId(payOrder.getId().toString());
		// ????????????type????????????(??????)
		consumeRecord.setType(KConstants.ConsumeType.SDKTRANSFR_PAY);
		consumeRecord.setChangeType(KConstants.MOENY_REDUCE);
		consumeRecord.setPayType(3);
		consumeRecord.setDesc(payOrder.getDesc());
		consumeRecord.setTime(DateUtil.currentTimeSeconds());
		consumeRecord.setStatus(KConstants.OrderStatus.END);
		consumeRecord.setTradeNo(lessTradeNo);
		consumeRecord.setCurrentBalance(userMoneyLog.getEndMoeny());
		consumeRecord.setBusinessId(payOrder.getTrade_no());
		consumeRecord.setUserId(userId);
		consumeRecordDao.addConsumRecord(consumeRecord);


		User sysUser = userCoreService.getUser(1100);
		SkOpenApp openApp = openAppManage.getOpenAppByAppId(appId);
		JSONObject obj = new JSONObject();
		obj.put("orderId", payOrder.getId().toString());
		obj.put("money", payOrder.getMoney());
		obj.put("icon", openApp.getAppImg());
		obj.put("name", openApp.getAppName());
		MessageBean message=new MessageBean();
		message.setFromUserId(sysUser.getUserId().toString());
		message.setFromUserName(sysUser.getNickname());
		message.setType(MessageType.OPENPAYSUCCESS);
		message.setMsgType(0);
		message.setMessageId(StringUtil.randomUUID());
		message.setContent(obj);
		message.setToUserId(user.getUserId().toString());
		message.setToUserName(user.getNickname());
		try {
			messageService.send(message);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// ????????????????????????
		ThreadUtils.executeTimerTask(new PaySyncCallback(payOrder),5,30);

		return JSONMessage.success();
	}

	/**
	 * ??????????????????
	 * @param appId
	 * @param prepayId
	 * @param sign
	 * @param userId
	 * @return
	 */
	public boolean passwordPaymentV1(String appId,String prepayId,String sign,Integer userId) throws Exception {
		
		if(!payRedisService.queryPayOrderSign(prepayId).equals(sign)){
			throw new ServiceException(PayResultCode.AuthSignFailed);
		}
		
		PayOrder order = payOrderDao.getPayOrder(new ObjectId(prepayId),null);
		if(null==order){
			throw new ServiceException(PayResultCode.OrderNotExist);
		}
		
		if(!order.getAppId().equals(appId)){
			throw new ServiceException(PayResultCode.AppIdWrong);
		}
		userCoreService.payMoenyBalanceOnLock(userId,Double.valueOf(order.getMoney()),obj -> {
			return passwordPaymentV1OnLock(order,appId,userId);
		});
		
		return true;
	}
	public boolean passwordPaymentV1OnLock(PayOrder order,String appId,Integer userId){

		User user = userCoreService.getUser(userId);

		order.setUserId(userId.toString());
		order.setStatus((byte)1);
		payOrderDao.addPayOrder(order);

		Double doubleMoney = Double.valueOf(order.getMoney());


		/**
		 *??????????????????
		 */
		UserMoneyLog userMoneyLog =new UserMoneyLog(userId,0,order.getTrade_no(),doubleMoney,
				MoenyAddEnum.MOENY_REDUCE, MoneyLogEnum.OPEN_ORDER_PAY, MoneyLogTypeEnum.NORMAL_PAY);
		// ??????
		userCoreService.rechargeUserMoenyV1(userMoneyLog);




		// ??????????????????
		String lessTradeNo=StringUtil.getOutTradeNo();
		BaseConsumeRecord consumeRecord = new BaseConsumeRecord();
		consumeRecord.setMoney(doubleMoney);
		consumeRecord.setBusinessId(order.getId().toString());
		// ????????????type????????????(??????)
		consumeRecord.setType(KConstants.ConsumeType.SDKTRANSFR_PAY);
		consumeRecord.setChangeType(KConstants.MOENY_REDUCE);
		consumeRecord.setPayType(3);
		consumeRecord.setDesc(order.getDesc());
		consumeRecord.setTime(DateUtil.currentTimeSeconds());
		consumeRecord.setStatus(KConstants.OrderStatus.END);
		consumeRecord.setTradeNo(lessTradeNo);
		consumeRecord.setCurrentBalance(userMoneyLog.getEndMoeny());
		consumeRecord.setBusinessId(userMoneyLog.getBusinessId());
		consumeRecord.setUserId(userId);
		consumeRecordDao.addConsumRecord(consumeRecord);


		User sysUser = userCoreService.getUser(1100);
		SkOpenApp openApp = openAppManage.getOpenAppByAppId(appId);
		JSONObject obj = new JSONObject();
		obj.put("orderId", order.getId().toString());
		obj.put("money", order.getMoney());
		obj.put("icon", openApp.getAppImg());
		obj.put("name", openApp.getAppName());
		MessageBean message=new MessageBean();
		message.setFromUserId(sysUser.getUserId().toString());
		message.setFromUserName(sysUser.getNickname());
		message.setType(MessageType.OPENPAYSUCCESS);
		message.setMsgType(0);
		message.setMessageId(StringUtil.randomUUID());
		message.setContent(obj);
		message.setToUserId(user.getUserId().toString());
		message.setToUserName(user.getNickname());
		try {
			messageService.send(message);
		} catch (Exception e) {
			log.error(e.getMessage(),e);
		}

		// ????????????????????????
		ThreadUtils.executeTimerTask(new PaySyncCallback(order),5,30);

		return true;
	}
	
	
	/**
	 * ??????md5??????,?????????:???????????????a-z??????,???????????????????????????????????????
	 */
	public String createSign(SortedMap<String, String> packageParams) {
		StringBuffer sb = new StringBuffer();
		Set es = packageParams.entrySet();
		Iterator it = es.iterator();
		while (it.hasNext()) {
			Map.Entry entry = (Map.Entry) it.next();
			String k = (String) entry.getKey();
			String v = (String) entry.getValue();
			if (null != v && !"".equals(v) && !"sign".equals(k)
					&& !"key".equals(k)) {
				sb.append(k + "=" + v + "&");
				//System.out.println(k+"----"+v);
			}
		}
//		sb.append("key=" + this.getKey());
		//System.out.println("key====="+this.getKey());
		String sign = MD5Util.MD5Encode(sb.toString(), "UTF-8")
				.toUpperCase();
		return sign;

	}
	
    public double queryCodePayCount(int userId){
//        DBObject groupFileds =new BasicDBObject();
//        groupFileds.put("userId", "$userId");
//        // ????????????
//        BasicDBObject query =new BasicDBObject();
//        query.put("userId", userId);
//        DBObject macth=new BasicDBObject("$match",query);
//
//        DBObject fileds = new BasicDBObject("_id", groupFileds);
//        fileds.put("count", new BasicDBObject("$sum","$money"));
//        DBObject group = new BasicDBObject("$group", fileds);
//        DBCollection collection = getDatastore().getCollection(CodePay.class);
//        AggregationOutput out= collection.aggregate(Arrays.asList(macth,group));
//        Iterator<DBObject> result=out.results().iterator();
//        while (result.hasNext()){
//            return  Double.valueOf(result.next().get("count").toString());
//        }
//       return 0;
		return codePayDao.queryCodePayCount(userId);
    }
	public double queryToDayCodePayCount(int userId){
//		DBObject groupFileds =new BasicDBObject();
//		groupFileds.put("userId", "$userId");
//		// ????????????
//		BasicDBObject query =new BasicDBObject();
//		query.put("userId", userId);
//		query.put("createTime",
//				new BasicDBObject(MongoOperator.GT,DateUtil.getTodayMorning().getTime()/1000)
//						.append(MongoOperator.LTE,DateUtil.currentTimeSeconds()));
//
//		DBObject macth=new BasicDBObject("$match",query);
//
//		DBObject fileds = new BasicDBObject("_id", groupFileds);
//		fileds.put("count", new BasicDBObject("$sum","$money"));
//		DBObject group = new BasicDBObject("$group", fileds);
//		DBCollection collection = getDatastore().getCollection(CodePay.class);
//		AggregationOutput out= collection.aggregate(Arrays.asList(macth,group));
//		Iterator<DBObject> result=out.results().iterator();
//		while (result.hasNext()){
//			return  Double.valueOf(result.next().get("count").toString());
//		}
//		return 0;
		return codePayDao.queryToDayCodePayCount(userId);
	}

	private class PaySyncCallback extends TimerTask {
		private PayOrder order;
		/**
		 * 
		 */
		public PaySyncCallback(PayOrder order) {
			this.order=order;
		}
		@Override
		public void run() {
			String callBackUrl = order.getCallBackUrl();
			SkOpenApp skOpenApp = skOpenAppDao.getSkOpenApp(order.getId());
			if(StringUtil.isEmpty(callBackUrl)) {
//				if(order.getAppType().equals("APP")){
//					Query<SkOpenApp> openAppQuery=getDatastore().createQuery(SkOpenApp.class).field("appId").equal(order.getAppId());
//					callBackUrl = openAppQuery.get().getPayCallBackUrl();
//				}else{
//					Query<SkOpenApp> openWebQuery = getDatastore().createQuery(SkOpenApp.class).field("appId").equal(order.getAppId());
//					callBackUrl = openWebQuery.get().getPayCallBackUrl();
//				}
				callBackUrl = skOpenApp.getPayCallBackUrl();
			}
			try {
				SortedMap<String, String> contentMap = new TreeMap<String, String>();
				contentMap.put("out_trade_no", order.getTrade_no());
				String xmlParam = WXPayUtil.paramsToxmlStr(contentMap);
				HttpPost httpPost = HttpClientConnectionManager.getPostMethod(callBackUrl);
				httpPost.setEntity(new StringEntity(xmlParam,"UTF-8"));
				log.info("?????????????????????,????????????");
				HttpResponse response =httpclient.execute(httpPost);
				int responseCode = response.getStatusLine().getStatusCode();
				if(responseCode==200){
					log.info("??????????????????");
					this.cancel();
				}else{
					log.info("????????????????????????????????????");
				}
			}catch(UnknownHostException e1){
				log.error(e1.getMessage()+" ??????????????????????????????");
			}catch (Exception e) {
				e.printStackTrace();
				this.cancel();
			}
		}
			
		
		
	}
}
