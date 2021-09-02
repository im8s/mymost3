package com.shiku.im.sms;

import com.alibaba.fastjson.JSONObject;
import com.aliyuncs.dysmsapi.model.v20170525.SendSmsResponse;
import com.google.common.collect.Maps;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.entity.Config;
import com.shiku.im.jedis.RedisCRUD;
import com.shiku.im.sms.model.SmsConfig;
import com.shiku.im.utils.ConstantUtil;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.utils.StringUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.MessageFormat;
import java.util.concurrent.ConcurrentMap;

@Slf4j
@Service
public class SMSServiceImpl {

	private String app_id = "";
	private String app_secret = "";
	private String app_template_id_invite = "";
	private String app_template_id_random = "";
	public static final String SMS_ALI = "aliyun";
	public static final String SMS_TTGJ = "ttgj";
	public static final String vaildTimes = "vaildTimes";// 短信验证码有效次数

	public static RedisCRUD getRedisCRUD(){
		return SKBeanUtils.getRedisCRUD();
	}


	@Autowired
	private SmsConfig smsConfig;

	@Autowired
	SMSVerificationUtils smsVerificationUtils;

	public String getSmsCode(String telephone){
		String key = String.format(KConstants.Key.RANDCODE, telephone);
		String _randcode = getRedisCRUD().get(key);
		JSONObject parseObject = JSONObject.parseObject(_randcode);
		if(null == parseObject)
			throw new ServiceException(KConstants.ResultCode.VerifyCodeErrOrExpired);
		return  parseObject.getString(telephone);
	}
	public boolean isAvailable(String telephone, String randcode) {
		// 验证码有效次数维护
		String key = String.format(KConstants.Key.RANDCODE, telephone);
		String _randcode = getRedisCRUD().get(key);
		JSONObject parseObject = JSONObject.parseObject(_randcode);
		if(null == parseObject)
			throw new ServiceException(KConstants.ResultCode.VerifyCodeErrOrExpired);
		Object effectiveCode = parseObject.get(telephone);
		int codeTimes = (int) parseObject.get(vaildTimes);
		ConcurrentMap<Object, Object> codeMap = Maps.newConcurrentMap();
		codeTimes--;
		if(codeTimes < 0){
			getRedisCRUD().del(key);
			throw new ServiceException(KConstants.ResultCode.VerifyCodeErrOrExpired);
		}
		codeMap.put(vaildTimes,codeTimes);
		codeMap.put(telephone, effectiveCode);
		getRedisCRUD().setObject(key, JSONObject.toJSONString(codeMap), KConstants.Expire.MINUTE*3);
		return randcode.equals(effectiveCode);
	}
	public void deleteSMSCode(String telephone) {
		String key = String.format(KConstants.Key.RANDCODE, telephone);
		getRedisCRUD().del(key);
	}

	public boolean checkImgCode(String telephone, String imgCode) {
		String key = String.format(KConstants.Key.IMGCODE, telephone);
		String cached = getRedisCRUD().get(key);
		return imgCode.toUpperCase().equals(cached);
	}
	public String sendSmsToInternational(String telephone,String areaCode,String language,int type) {
		Config config = SKBeanUtils.getImCoreService().getConfig();
		String key = String.format(KConstants.Key.RANDCODE, telephone);
		Long ttl = getRedisCRUD().ttl(key);
		String code=getRedisCRUD().get(key);
		if (ttl >120) {
			String msg = ConstantUtil.getMsgByCode(KConstants.ResultCode.ManySedMsg + "", language);
			msg = MessageFormat.format(msg, ttl - 120);
			log.info("msg : " + msg);
			throw new ServiceException(msg);
		}
		if (StringUtil.isEmpty(code))
			code = StringUtil.randomCode();
		else {
			JSONObject parseObject = JSONObject.parseObject(code);
			code = parseObject.getString(telephone);
			log.info(" redis code is : {}", code);
		}
		final String smsCode=code;
		//线程之间异常捕获
		try {
			if (1 == smsConfig.getOpenSMS()) { // 需要发送短信
				if (SMS_ALI.equals(config.getSMSType()))
					aliSMS(telephone, language, smsCode, areaCode, key,type);
				else if (SMS_TTGJ.equals(config.getSMSType()))
					ttgjSMS(telephone, areaCode, language, smsCode, key);
			} else {
				ConcurrentMap<Object, Object> map = Maps.newConcurrentMap();
				map.put(telephone, smsCode);
				map.put("vaildTimes", 3);
				String jsonString = JSONObject.toJSONString(map);
				getRedisCRUD().setObject(key, jsonString, KConstants.Expire.MINUTE * 3);
			}
		} catch (ServiceException e) {
			e.printStackTrace();
			log.error("短信发送： "+e.getMessage());
//			throw new ServiceException(KConstants.ResultCode.SedMsgFail);
			throw new ServiceException(e.getResultCode());
		}
		return code;
	}

	// 发送云钱包通知短信
	public void sendCloudWalletSmsNotification(String telephone,String areaCode,String language,int type){
		Config config = SKBeanUtils.getImCoreService().getConfig();
		try {
			if (1 == smsConfig.getOpenSMS()) { // 需要发送短信
				if (SMS_ALI.equals(config.getSMSType()))
					aliSMS(telephone, language, "", areaCode, "",type);
				else if (SMS_TTGJ.equals(config.getSMSType()))
					ttgjSMS(telephone, areaCode, language, "", "");
			} else {

			}
		} catch (ServiceException e) {
			e.printStackTrace();
			log.error("短信发送： "+e.getMessage());
			throw new ServiceException(e.getResultCode());
		}
	}

	//天天国际短信服务
	public void ttgjSMS(String telephone,String areaCode,String language,String smsCode,String key){
		String msgId = smsVerificationUtils.sendSmsToMs360(telephone, areaCode, smsCode);
		if (!StringUtil.isEmpty(msgId)) {
			if (!"-".equals(msgId.substring(0, 1))) {
				ConcurrentMap<Object, Object> map = Maps.newConcurrentMap();
				map.put(telephone, smsCode);
				map.put("vaildTimes", 3);
				String jsonString = JSONObject.toJSONString(map);
				getRedisCRUD().setObject(key, jsonString, KConstants.Expire.MINUTE*3);
			} else {
				log.info("    发送短信错误      msgId=====>" + msgId);
//				throw new ServiceException(KConstants.ResultCode.SedMsgFail, language);
				throw new ServiceException(KConstants.ResultCode.SedMsgFail);
			}
		} else {
			throw new ServiceException(KConstants.ResultCode.SedMsgFail, language);
		}
	}

	// 阿里云短信服务
	public void aliSMS(String telephone, String language, String smsCode, String areaCode, String key,int type) {
		try {
			SendSmsResponse sendSms = smsVerificationUtils.sendSms(telephone, smsCode, areaCode,type);
			if (null != sendSms && "OK".equals(sendSms.getCode())) {
				if(type != 3){
					ConcurrentMap<Object, Object> map = Maps.newConcurrentMap();
					map.put(telephone, smsCode);
					map.put("vaildTimes", 3);
					String jsonString = JSONObject.toJSONString(map);
					getRedisCRUD().setObject(key, jsonString, KConstants.Expire.MINUTE * 3);
				}
			}
			if (!StringUtil.isEmpty(sendSms.getCode()) && !"OK".equals(sendSms.getCode()))
				throw new ServiceException(sendSms.getCode());
		} catch (Exception e) {
			String message = e.getMessage();
			if (message.equals("isv.DAY_LIMIT_CONTROL")) {
				throw new ServiceException(KConstants.ResultCode.SendVerificationCodeErrorByUpper);
			} else if (message.equals("isv.MOBILE_NUMBER_ILLEGAL")) {
				throw new ServiceException(KConstants.ResultCode.SendVerificationCodeErrorByIllegalPhone);
			} else if (message.equals("isv.BUSINESS_LIMIT_CONTROL")) {
				throw new ServiceException(KConstants.ResultCode.SendVerificationCodeErrorByRequest);
			} else {
				throw new ServiceException("短信发送失败!");
			}
		}
	}
	
	public static class Result {
		private String access_token;
		private Integer expires_in;
		private String idertifier;
		private String res_code;
		private String res_message;

		public String getAccess_token() {
			return access_token;
		}

		public Integer getExpires_in() {
			return expires_in;
		}

		public String getIdertifier() {
			return idertifier;
		}

		public String getRes_code() {
			return res_code;
		}

		public String getRes_message() {
			return res_message;
		}

		public void setAccess_token(String access_token) {
			this.access_token = access_token;
		}

		public void setExpires_in(Integer expires_in) {
			this.expires_in = expires_in;
		}

		public void setIdertifier(String idertifier) {
			this.idertifier = idertifier;
		}

		public void setRes_code(String res_code) {
			this.res_code = res_code;
		}

		public void setRes_message(String res_message) {
			this.res_message = res_message;
		}
	}


	public String getApp_id() {
		return app_id;
	}

	public String getApp_secret() {
		return app_secret;
	}

	public String getApp_template_id_invite() {
		return app_template_id_invite;
	}

	public String getApp_template_id_random() {
		return app_template_id_random;
	}




}
