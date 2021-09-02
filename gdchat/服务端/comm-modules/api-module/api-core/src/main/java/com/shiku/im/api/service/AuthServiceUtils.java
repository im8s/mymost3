package com.shiku.im.api.service;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.alibaba.fastjson.TypeReference;
import com.shiku.im.comm.utils.LoginPassword;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.config.AppConfig;
import com.shiku.im.user.model.KSession;
import com.shiku.im.user.service.AuthKeysService;
import com.shiku.im.user.service.IBaseUserManager;
import com.shiku.im.user.service.UserCoreRedisRepository;
import com.shiku.redisson.ex.LockFailException;
import com.shiku.utils.Base64;
import com.shiku.utils.ParamsSign;
import com.shiku.utils.StringUtil;
import com.shiku.utils.encrypt.AES;
import com.shiku.utils.encrypt.MAC;
import com.shiku.utils.encrypt.MD5;
import com.shiku.utils.encrypt.RSA;
import org.redisson.api.RBucket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/**
 * 各种 加密 权限验证的类
 *
 *
 */
@Component
public class AuthServiceUtils {

	private   Logger logger=LoggerFactory.getLogger(AuthServiceUtils.class);
	
	private  String apiKey=null;

	@Autowired
	private AppConfig appConfig;
	public  String getApiKey() {
		if(null==apiKey){
			synchronized (this){
				if(null==apiKey){
					apiKey=appConfig.getApiKey();
				}
			}
		}

		return apiKey;
	}
	@Lazy
	@Autowired
	private  IBaseUserManager userManager;
	@Lazy
	@Autowired
	private  AuthKeysService authKeysService;



	public static final String API_MAC_KEY="api:mac:%s:%s";

	public static final String LOCK_APIMAC="lock:apimac:%s";

	@Autowired
	private UserCoreRedisRepository userCoreRedisRepository;

	/**
	 * 查询用户请求的mac 值在redis 中是否存在
	 * @param userId
	 * @param mac
	 * @return
	 */
	public boolean checkMacExistRedis(int userId,String mac){

		if(0==userId){
			return false;
		}

		try {
			String lockKey = userCoreRedisRepository.buildRedisKey(LOCK_APIMAC, userId);
			return (boolean) userCoreRedisRepository.executeOnLock(lockKey, obj->{
				String redisKey = userCoreRedisRepository.buildRedisKey(API_MAC_KEY, userId,mac);
				RBucket<String> bucket = userCoreRedisRepository.getRedissonClient().getBucket(redisKey);
				if(bucket.isExists()){
					bucket.expire(30, TimeUnit.SECONDS);
					return true;
				}else {
					bucket.set(mac,30, TimeUnit.SECONDS);
					return false;
				}
			});

		} catch (LockFailException e) {
			return false;
		}catch (Exception e) {
			logger.error(e.getMessage(),e);
			return false;
		}


	}
	

	public  boolean checkMacSign(String mac,String serverMac,byte[] decode){
		try {
			return Arrays.equals(Base64.decode(mac), MAC.encode(serverMac.getBytes(),decode));
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
	private  boolean checkMacSignBase64(String mac,String serverMac,String macKey){
		try {
			return Arrays.equals(Base64.decode(mac), MAC.encode(serverMac.getBytes(),Base64.decode(macKey)));
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}

	}
	private  boolean checkMacSign(String mac,StringBuffer serverMac,String macKey){
		return checkMacSign(mac,serverMac.toString(),macKey.getBytes());
	}
	private  boolean checkMacSign(String mac,StringBuffer serverMac,byte[] macKey){
		return checkMacSign(mac,serverMac.toString(),macKey);
	}
	private  JSONObject checkMacSign(JSONObject jsonObject,String mac,StringBuffer serverMac,byte[] macKey){
		 if(checkMacSign(mac,serverMac.toString(),macKey))
		 	return jsonObject;
		 else
		 	return null;
	}

	public  boolean authOpenApiByMac(Map<String,String> paramMap){
		String mac = paramMap.remove("secret");
		if(StringUtil.isEmpty(mac))
			return false;
		String salt = paramMap.remove("salt");

		String paramStr = ParamsSign.joinValues(paramMap);
		StringBuffer  macStrBuf=new StringBuffer();
		String apiKey=getApiKey();
		macStrBuf.append(apiKey).append(paramStr).append(salt);
		return  checkMacSign(mac, macStrBuf.toString(),MD5.encrypt(apiKey));
	}

	/**
	 * @return 0-失败 1-成功 2-使用幂等数据返回
	 */
	public int authRequestApiByMac(Map<String,String> paramMap, KSession session,String url){
		if(null==session) {
			logger.info("【验签失败】session为空！paramMap:{}, session:{}, url:{}", JSON.toJSONString(paramMap), JSON.toJSONString(session), url);
			return 0;
		}
		String mac = paramMap.remove("secret");
		if(StringUtil.isEmpty(mac)) {
			logger.info("【验签失败】secret为空！paramMap:{}, session:{}, url:{}", JSON.toJSONString(paramMap), JSON.toJSONString(session), url);
			return 0;
		}
		String salt = paramMap.remove("salt");
		String accessToken = paramMap.remove("access_token");

		String paramStr = ParamsSign.joinValues(paramMap);
		StringBuffer  macStrBuf=new StringBuffer();
		macStrBuf.append(getApiKey()).append(session.getUserId()).append(accessToken).append(paramStr).append(salt);
		if(!checkMacSignBase64(mac, macStrBuf.toString(),session.getHttpKey())){
			logger.info("【验签失败】checkMacSignBase64失败！paramMap:{}, session:{}, url:{}, mac:{}, serverMac:{}, macKey:{}",
					JSON.toJSONString(paramMap), JSON.toJSONString(session), url, mac, macStrBuf.toString(), session.getHttpKey());
			return 0;
		}

		boolean result = !checkMacExistRedis(session.getUserId(),url+mac);
		if (!result) {
			logger.info("【验签失败-同请求1ms内操作太快-使用幂等数据返回】checkMacExistRedis失败！paramMap:{}, session:{}, url:{}, userId:{}, mac:{}",
					JSON.toJSONString(paramMap), JSON.toJSONString(session), url, session.getUserId(), url+mac);
			return 2;
		}
		return result ? 1 : 0;
	}

	/**
	 * apiKey  验签参数
	 * @param data
	 * @param salt
	 * @return
	 */
	public  JSONObject authApiKeyCheckSign(String data,String salt){
		byte[] deCode=MD5.encrypt(getApiKey());
		JSONObject jsonObject = decodeDataToJson(data, deCode);
		Map<String, String> paramMap = jsonObjToStrMap(jsonObject);

		String mac=paramMap.remove("mac");
		if(StringUtil.isEmpty(mac))
			return null;

		String paramStr = ParamsSign.joinValues(paramMap);
		StringBuffer  macStrBuf=new StringBuffer();

		macStrBuf.append(getApiKey()).append(paramStr).append(salt);
		return checkMacSign(jsonObject,mac,macStrBuf,deCode);


	}

	public  JSONObject decodeApiKeyDataJson(String data) {

		String jsonStr;
		try {
			jsonStr=AES.decryptStringFromBase64(data,MD5.encrypt(getApiKey()));
		} catch (Exception e) {
			logger.error("AES 解密失败  ====》  {}",e.getMessage());
			return null;
		}
		logger.info(jsonStr);
		JSONObject jsonObj=JSONObject.parseObject(jsonStr);

		String sign=jsonObj.getString("mac");
		if(StringUtil.isEmpty(sign))
			return null;
		return jsonObj;
	}
	public  boolean authTransactiongetCode(String userId,String token,String salt,String mac,String payPwd) {
		String macValue=getApiKey()+userId+token+salt;
		return  checkMacSign(mac,macValue,payPwd.getBytes());
	}
	public  boolean authLogingetCode(String account,String salt,String mac,String password,int userId) {
		String macValue=getApiKey()+account+salt;
		boolean flag=false;
		flag=checkMacSign(mac,macValue,password.getBytes());
		if(!flag) {
			password = LoginPassword.encodeFromOldPassword(password);
			flag= checkMacSign(mac,macValue,password.getBytes());
			if(flag)
				userManager.resetPassword(userId,password);
		}
		return flag;
	}
	public  JSONObject authUserLoginCheck(int userId,String data,String salt,String password,byte[] deCode){
		JSONObject jsonObj=decodeDataToJson(data,deCode);
		if(null==jsonObj)
			return null;
		Map<String,String> paramMap=jsonObjToStrMap(jsonObj);
		if(null==paramMap)
			return null;
		String mac = paramMap.remove("mac");
		if(StringUtil.isEmpty(mac))
			return null;
		String paramStr = ParamsSign.joinValues(paramMap);
		StringBuffer  macStrBuf=new StringBuffer();

		macStrBuf.append(getApiKey()).append(userId).append(paramStr).append(salt).append(password);
		 if(checkMacSign(mac,macStrBuf.toString(),deCode))
		 	return jsonObj;
		 else
		 return null;

	}

	public  JSONObject authUserAutoLoginCheck(int userId,String loginToken,String loginKey,String salt,String data){
		byte[] decode = Base64.decode(loginKey);

		JSONObject jsonObj=decodeDataToJson(data,decode);
		if(null==jsonObj)
			return null;
		Map<String,String> paramMap=jsonObjToStrMap(jsonObj);
		if(null==paramMap)
			return null;
		String mac = paramMap.remove("mac");
		if(StringUtil.isEmpty(mac))
			return null;

		String paramStr = ParamsSign.joinValues(paramMap);
		StringBuffer  macStrBuf=new StringBuffer();

		macStrBuf.append(getApiKey()).append(userId).append(loginToken).append(paramStr).append(salt);
		if(Arrays.equals(Base64.decode(mac), MAC.encode(macStrBuf.toString().getBytes(),decode)))
			return jsonObj;
		else
			return null;

	}
	public  JSONObject authSmsLoginCheck(String account,byte[] decode,String data,String salt){
		JSONObject jsonObj=decodeDataToJson(data,decode);
		if(null==jsonObj)
			return null;
		Map<String,String> paramMap=jsonObjToStrMap(jsonObj);
		if(null==paramMap)
			return null;
		String mac = paramMap.remove("mac");
		if(StringUtil.isEmpty(mac))
			return null;
		String paramStr = ParamsSign.joinValues(paramMap);
		StringBuffer  macStrBuf=new StringBuffer();

		macStrBuf.append(getApiKey()).append(account).append(paramStr).append(salt);
		return checkMacSign(jsonObj,mac,macStrBuf,decode);
	}
	public  JSONObject authWxLoginCheck(JSONObject jsonObj,String data,String salt){
		byte[] decode = MD5.encrypt(getApiKey());

		Map<String,String> paramMap=jsonObjToStrMap(jsonObj);
		if(null==paramMap)
			return null;
		String mac = paramMap.remove("mac");
		if(StringUtil.isEmpty(mac))
			return null;
		String paramStr = ParamsSign.joinValues(paramMap);
		StringBuffer  macStrBuf=new StringBuffer();

		macStrBuf.append(getApiKey()).append(paramStr).append(salt);
		return checkMacSign(jsonObj,mac,macStrBuf,decode);

	}
	public  boolean authUploadLoginKeyPair(String account,String publicKey,String privateKey,String salt,String mac,String password) {
		StringBuffer  macStrBuf=new StringBuffer();
		macStrBuf.append(getApiKey()).append(account).append(privateKey).append(publicKey).append(salt);

		return checkMacSign(mac,macStrBuf,password.getBytes());

	}
	public  boolean checkResetPayPassWordSign(int userId ,String token,String mac,String salt,String smsCode) {
		StringBuffer macStrBuf=new StringBuffer();
		macStrBuf.append(getApiKey()).append(userId).append(token).append(salt);
		try {
			return Arrays.equals(Base64.decode(mac), MAC.encode(macStrBuf.toString().getBytes(), MD5.encrypt(smsCode)));
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public  boolean checkUserUploadPayKeySign(String privateKey,String publicKey,String macKey,String payPwd) {
		byte[] priKeyArr = Base64.decode(privateKey);
		byte[] pubKeyArr = Base64.decode(publicKey);
		byte[] macVue=Arrays.copyOf(priKeyArr,priKeyArr.length +pubKeyArr.length);
        System.arraycopy(pubKeyArr, 0, macVue, priKeyArr.length, pubKeyArr.length);

		try {
			return Arrays.equals(Base64.decode(macKey), MAC.encode(macVue, payPwd));
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
	public  boolean checkUserUploadMsgKeySign(String mac,String telephone,String password) {
		try {
			byte [] bytesMD5 = Base64.decode(password);
			byte[] key=AES.encrypt(getApiKey().getBytes(),bytesMD5);
			System.out.println(Base64.encode(key));
			Base64.encode(MAC.encode(key,telephone.getBytes()));
			return Arrays.equals(Base64.decode(mac), MAC.encode(key,telephone.getBytes()));
		} catch (Exception e) {
			e.printStackTrace();
			return  false;
		}
		//return mac.equals(MAC.encodeBase64(key,telephone.getBytes()));
	}
	public  byte[] getPayCodeById(int userId,String codeId) {
		String code = authKeysService.queryTransactionSignCode(userId, codeId);
		if(StringUtil.isEmpty(code))
			return null;
		authKeysService.cleanTransactionSignCode(userId,codeId);
		return Base64.decode(code);
	}
	public  Map<String,String> jsonObjToStrMap(JSONObject jsonObject){
		return jsonObject.getInnerMap().entrySet().stream()
				.collect(Collectors.toMap(obj-> obj.getKey(),obj -> obj.getValue().toString()));
	}
	public  Map<String,String> objMapToStrMap(Map<String,Object> objMap){
		return objMap.entrySet().stream()
				.collect(Collectors.toMap(obj-> obj.getKey(),obj -> obj.getValue().toString()));
	}
	public  JSONObject decodeDataToJson(String data,byte[] decode) {

		String jsonStr;
		try {
			jsonStr=AES.decryptStringFromBase64(data,decode);
		} catch (Exception e) {
			logger.error("AES 解密失败  ====》  {}",e.getMessage());
			return null;
		}
		logger.info(jsonStr);
		JSONObject jsonObj=JSONObject.parseObject(jsonStr);

		/*String sign=jsonObj.getString("mac");
		if(StringUtil.isEmpty(sign))
			return null;*/
		return jsonObj;
	}
	public   JSONObject decodePayDataJson(String data,byte[] decode) {
		
		String jsonStr;
		try {
			jsonStr=AES.decryptStringFromBase64(data,decode);
		} catch (Exception e) {
			logger.error("AES 解密失败  ====》  {}",e.getMessage());
			return null;
		}
		logger.info(jsonStr);
		JSONObject jsonObj=JSONObject.parseObject(jsonStr);
		
		String sign=jsonObj.getString("mac");
		if(StringUtil.isEmpty(sign))
			return null;
		return jsonObj;
	}
	public  Map<String, String> decodePayDataJsonToMap(String data, byte[] decode) {

		String jsonStr;
		try {
			jsonStr=AES.decryptStringFromBase64(data,decode);
		} catch (Exception e) {
			logger.error("AES 解密失败  ====》  {}",e.getMessage());
			return null;
		}
		logger.info(jsonStr);

		return JSONObject.parseObject(jsonStr, new TypeReference<Map<String,String>>(){}.getType());
	}
	private  JSONObject checkAuthRSA(JSONObject jsonObj,StringBuffer macStrBuf,String payPwd,String publicKey,byte[] decode) {
		String sign=jsonObj.getString("mac");
		macStrBuf.append(jsonObj.get("time")).append(payPwd);
		if(RSA.verifyFromBase64(macStrBuf.toString(),Base64.decode(publicKey), sign)) {
			 return jsonObj;
		 }else
			 return null;
	}
	
	  private  JSONObject checkAuthMac(JSONObject jsonObj,StringBuffer macStrBuf,
			  String payPwd,byte[] decode) { 
		  String mac=jsonObj.getString("mac");
		  if(StringUtil.isEmpty(mac))
			  return null;
		  macStrBuf.append(jsonObj.get("time")).append(payPwd);
		  return checkMacSign(jsonObj,mac,macStrBuf,decode);
	  }
	 
	
	public  JSONObject authSendRedPacketByMac(int userId,String token,String data,String codeId,String payPwd) {
		byte[] decode =getPayCodeById(userId, codeId);
		if(null==decode)
			return null;
		JSONObject jsonObj = decodePayDataJson( data, decode);
		if(null==jsonObj)
			return null;
		/*
		 * 
		 * {"moneyStr":"1","toUserId":"10017133","time":"1562833566942",
		 * "access_token":"0fdc4014d5c6416aa86a7ce3f496518c",
		 * "mac":"y0j1O+FA17UBpZ8wWydKJQ==","count":"1",
		 * "greetings":"恭喜发财,万事如意","type":"1"}
		 * */
		
		
		
		int type=jsonObj.getIntValue("type"); 
		int count=jsonObj.getIntValue("count");
		String moneyStr=jsonObj.getString("moneyStr");
		String greetings=jsonObj.getString("greetings");
		String roomJid = jsonObj.getString("roomJid");
		
		
		int toUserId=jsonObj.getIntValue("toUserId");
		
		StringBuffer  macStrBuf=new StringBuffer();
		//apiKey + 自己的userId +token统一拼接在开头
		 macStrBuf.append(getApiKey()).append(userId).append(token);
		  
		  //type + moneyStr + count + greetings + toUserId
		 macStrBuf.append(type).append(moneyStr)
		 .append(count).append(greetings);
		 if(!StringUtil.isEmpty(roomJid))
			 macStrBuf.append(roomJid);
		 else
			 macStrBuf.append(toUserId);
		String publicKey=authKeysService.getPayPublicKey(userId);
		jsonObj=checkAuthRSA(jsonObj,macStrBuf,payPwd,publicKey,decode);
		//jsonObj=checkAuthMac(jsonObj, macStrBuf, payPwd, decode);
		 if(null==jsonObj)
			return null;
		 jsonObj.put("money", moneyStr);
		/*
		 * RedPacket packet=new RedPacket(); packet.setUserId(Integer.valueOf(userId));
		 * packet.setCount(count); packet.setType(type); packet.setGreetings(greetings);
		 * packet.setMoney(Double.valueOf(moneyStr)); if(!StringUtil.isEmpty(roomJid))
		 * packet.setRoomJid(roomJid); else packet.setToUserId(toUserId);
		 */
		 
		 return jsonObj;
	}
	
	public  JSONObject authSendTransfer(int userId,String token,String data,String codeId,String payPwd) {
		byte[] decode =getPayCodeById(userId, codeId);
		if(null==decode)
			return null;
		JSONObject jsonObj = decodePayDataJson( data, decode);
		if(null==jsonObj)
			return null;
		
		StringBuffer macStrBuf=new StringBuffer();
		 macStrBuf.append(getApiKey()).append(userId).append(token);
		 macStrBuf.append(jsonObj.get("toUserId")).append(jsonObj.get("money"));
		 if(!StringUtil.isEmpty(jsonObj.getString("remark")))
			 macStrBuf.append(jsonObj.getString("remark"));
		 String publicKey=authKeysService.getPayPublicKey(userId);
		 	jsonObj=checkAuthRSA(jsonObj,macStrBuf,payPwd,publicKey,decode);
		 //jsonObj=checkAuthMac(jsonObj, macStrBuf, payPwd, decode);
		 if(null!=jsonObj)
			return jsonObj;
		 else
			 return null;
	}
	/*
	 * 二维码 收款    扫码 付款
	 * */
	public  JSONObject authQrCodeTransfer(int userId,String token,String data,String codeId,String payPwd) {
		byte[] decode =getPayCodeById(userId, codeId);
		if(null==decode)
			return null;
		JSONObject jsonObj = decodePayDataJson(data, decode);
		if(null==jsonObj)
			return null;
		StringBuffer macStrBuf=new StringBuffer();
		 macStrBuf.append(getApiKey()).append(userId).append(token);
		 
		 macStrBuf.append(jsonObj.get("toUserId")).append(jsonObj.get("money"));
		 if(!StringUtil.isEmpty(jsonObj.getString("desc")))
			 macStrBuf.append(jsonObj.getString("desc"));
		String publicKey=authKeysService.getPayPublicKey(userId);
		jsonObj=checkAuthRSA(jsonObj,macStrBuf,payPwd,publicKey,decode);
		 //jsonObj=checkAuthMac(jsonObj, macStrBuf, payPwd, decode);
		 if(null!=jsonObj)
			return jsonObj;
		 else
			 return null;
	}

	/*
	 * 商户支付平台下单支付
	 * */
	public  JSONObject authPaymentOrderPay(int userId,String token,JSONObject jsonObj,byte[] decode,String payPwd) {

		StringBuffer macStrBuf=new StringBuffer();
		macStrBuf.append(getApiKey()).append(userId).append(token);

		//macStrBuf.append(jsonObj.get("payOrderId"));

		//macStrBuf.append(jsonObj.getString("amount"));

		macStrBuf.append(jsonObj.getString("sign"));

		String publicKey=authKeysService.getPayPublicKey(userId);
		logger.info(" macStrBuf ==> {} ",macStrBuf.toString());
		jsonObj=checkAuthRSA(jsonObj,macStrBuf,payPwd,publicKey,decode);

		if(null!=jsonObj) {
			return jsonObj;
		} else {
			return null;
		}
	}
	/*
	 * 商户 下单付款 
	 * */
	public  JSONObject authOrderPay(int userId,String token,String data,String codeId,String payPwd) {
		byte[] decode =getPayCodeById(userId, codeId);
		if(null==decode)
			return null;
		JSONObject jsonObj = decodePayDataJson( data, decode);
		if(null==jsonObj)
			return null;
		StringBuffer macStrBuf=new StringBuffer();
		 macStrBuf.append(getApiKey()).append(userId).append(token);
		 
		 macStrBuf.append(jsonObj.get("appId")).append(jsonObj.get("prepayId"));
		 macStrBuf.append(jsonObj.getString("sign"))
		 			.append(jsonObj.getString("money"));
		String publicKey=authKeysService.getPayPublicKey(userId);
		jsonObj=checkAuthRSA(jsonObj,macStrBuf,payPwd,publicKey,decode);
		//jsonObj=checkAuthMac(jsonObj, macStrBuf, payPwd, decode);
		 if(null!=jsonObj)
			return jsonObj;
		 else
			 return null;
	}

	public  JSONObject authPayGetQrKey(int userId,String token,String data,byte[] decode,String payPwd) {
		JSONObject jsonObj = decodePayDataJson( data, decode);
		if(null==jsonObj)
			return null;
		StringBuffer macStrBuf=new StringBuffer();
		macStrBuf.append(getApiKey()).append(userId).append(token);


		String publicKey=authKeysService.getPayPublicKey(userId);
		jsonObj=checkAuthRSA(jsonObj,macStrBuf,payPwd,publicKey,decode);

		if(null!=jsonObj)
			return jsonObj;
		else
			return null;
	}
	public  boolean authPayVerifyQrKey(int userId,String token,byte[] qrKey,String salt,String mac) {

		StringBuffer macStrBuf=new StringBuffer();
		macStrBuf.append(getApiKey()).append(userId).append(token).append(salt);


		String publicKey=authKeysService.getPayPublicKey(userId);
		return  checkMacSign(mac,macStrBuf.toString(),qrKey);
	}
	public  JSONObject authBindWxopenid(int userId,String token,String data,String codeId,String payPwd) {
		byte[] decode =getPayCodeById(userId, codeId);
		if(null==decode)
			return null;
		JSONObject jsonObj = decodePayDataJson(data, decode);
		if(null==jsonObj)
			return null;
		StringBuffer macStrBuf=new StringBuffer();
		 macStrBuf.append(getApiKey()).append(userId).append(token);
		 
		 macStrBuf.append(jsonObj.get("code"));
		String publicKey=authKeysService.getPayPublicKey(userId);
		jsonObj=checkAuthRSA(jsonObj,macStrBuf,payPwd,publicKey,decode);
		//jsonObj=checkAuthMac(jsonObj, macStrBuf, payPwd, decode);
		 if(null!=jsonObj)
			return jsonObj;
		 else
			 return null;
	}
	public  JSONObject authBindAliUserId(int userId,String token,String data,String codeId,String payPwd) {
		byte[] decode =getPayCodeById(userId, codeId);
		if(null==decode)
			return null;
		JSONObject jsonObj = decodePayDataJson( data, decode);
		if(null==jsonObj)
			return null;
		StringBuffer macStrBuf=new StringBuffer();
		 macStrBuf.append(getApiKey()).append(userId).append(token);
		 
		 macStrBuf.append(jsonObj.get("aliUserId"));

		String publicKey=authKeysService.getPayPublicKey(userId);
		jsonObj=checkAuthRSA(jsonObj,macStrBuf,payPwd,publicKey,decode);
		//jsonObj=checkAuthMac(jsonObj, macStrBuf, payPwd, decode);
		 if(null!=jsonObj)
			return jsonObj;
		 else
			 return null;
	}
	/*
	 * 微信取现付款
	 * */
	public  JSONObject authWxWithdrawalPay(int userId,String token,String data,String codeId,String payPwd) {
		byte[] decode =getPayCodeById(userId, codeId);
		if(null==decode)
			return null;
		JSONObject jsonObj = decodePayDataJson( data, decode);
		if(null==jsonObj)
			return null;
		StringBuffer macStrBuf=new StringBuffer();
		 macStrBuf.append(getApiKey()).append(userId).append(token);
		 
		 macStrBuf.append(jsonObj.get("amount"));
		String publicKey=authKeysService.getPayPublicKey(userId);
		jsonObj=checkAuthRSA(jsonObj,macStrBuf,payPwd,publicKey,decode);
		//jsonObj=checkAuthMac(jsonObj, macStrBuf, payPwd, decode);
		 if(null!=jsonObj)
			return jsonObj;
		 else
			 return null;
	}
	/*
	 * 支付宝取现付款
	 * */
	public  JSONObject authAliWithdrawalPay(int userId,String token,String data,String codeId,String payPwd) {
		byte[] decode =getPayCodeById(userId, codeId);
		if(null==decode)
			return null;
		JSONObject jsonObj = decodePayDataJson(data, decode);
		if(null==jsonObj)
			return null;
		StringBuffer macStrBuf=new StringBuffer();
		 macStrBuf.append(getApiKey()).append(userId).append(token);
		 
		 macStrBuf.append(jsonObj.get("amount"));

		String publicKey=authKeysService.getPayPublicKey(userId);
		jsonObj=checkAuthRSA(jsonObj,macStrBuf,payPwd,publicKey,decode);
		//jsonObj=checkAuthMac(jsonObj, macStrBuf, payPwd, decode);
		 if(null!=jsonObj)
			return jsonObj;
		 else
			 return null;
	}

	// 扫码手动充值--提现
	public JSONObject authManualWithdraw(int userId,String token,String data,String codeId,String payPwd){
		byte[] decode = getPayCodeById(userId,codeId);
		if(null == data){
			return null;
		}
		JSONObject jsonObj = decodePayDataJson(data,decode);
		if(null == jsonObj)
			return null;
		StringBuffer macStrBuf = new StringBuffer();
		macStrBuf.append(getApiKey()).append(userId).append(token);
		macStrBuf.append(jsonObj.get("amount"));
		macStrBuf.append(jsonObj.get("withdrawAccountId"));
		String publickey = authKeysService.getPayPublicKey(userId);
		jsonObj = checkAuthRSA(jsonObj,macStrBuf,payPwd,publickey,decode);
		if(null != jsonObj)
			return jsonObj;
		else
			return null;
	}

}
