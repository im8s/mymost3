package com.shiku.im.api.service;

import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.config.AppConfig;
import com.shiku.im.user.service.UserCoreRedisRepository;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.redisson.ex.LockFailException;
import com.shiku.utils.DateUtil;
import com.shiku.utils.Md5Util;
import com.shiku.utils.StringUtil;
import org.redisson.api.RBucket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;

/**
 * 各种 加密 权限验证的类
 * 
 *
 */
@Component
public class AuthServiceOldUtils {
	
	private  String apiKey=null;


	private   Logger logger=LoggerFactory.getLogger(AuthServiceOldUtils.class);


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
	public boolean checkMacExistRedis(String userId,String mac){


		try {
			String lockKey = userCoreRedisRepository.buildRedisKey(LOCK_APIMAC, userId);
			return (boolean) userCoreRedisRepository.executeOnLock(lockKey, obj->{
				String redisKey = userCoreRedisRepository.buildRedisKey(API_MAC_KEY, userId,mac);
				RBucket<String> bucket = userCoreRedisRepository.getRedissonClient().getBucket(redisKey);
				if(bucket.isExists()){
					bucket.expire(30,TimeUnit.SECONDS);
					return true;
				}else {
					//logger.info("mac {} isExists {} ",mac,false);
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

	/**
	 * 检验接口请求时间
	 * @param time
	 * @return
	 */
	public  boolean authRequestTime(long time) {
		long currTime= DateUtil.currentTimeSeconds();
		//允许 3分钟时差
		if(((currTime-time)<180&&(currTime-time)>-180)) {
			return true;
		}else {
			System.out.println(String.format("====> authRequestTime error server > %s client %s", currTime,time));
			return false;
		}
	}
	
	
	/**
	 * 检验 开放的 不需要 token 的接口
	 * @param time
	 * @return
	 */
	public  boolean authOpenApiSecret(long time,String secret) {

		
		if(!authRequestTime(time)) {
			return false;
		}
		if(StringUtil.isEmpty(secret)) {
			return false;
		}
		/**
		 * 判断  系统配置是否要校验
		 */
		if(0== SKBeanUtils.getSystemConfig().getIsAuthApi()) {
			return true;
		}
		/**
		 * 密钥 
			md5(apikey+time) 
		 */
		
		/**
		 *  apikey+time
		 */
		String key =new StringBuffer()
					.append(getApiKey())
					.append(time).toString();
		
		return secret.equals(Md5Util.md5Hex(key));
		
	}
	
	/**
	 * 普通接口授权
	 * @param userId
	 * @param time
	 * @param token
	 * @param secret
	 * @return
	 */
	public  boolean authRequestApi(String userId,long time,String token,String secret,String url) {
		if(KConstants.filterSet.contains(url)) {
			return true;
		}

		if (!authRequestTime(time)) {
			if (url.contains("/console"))
				return true;// 过滤掉layui分页导致的参数复用time不更新
			return false;
		}
		if(StringUtil.isEmpty(secret)) {
			return false;
		}
		

		/**
		 * 判断  系统配置是否要校验
		 */
		if(0==SKBeanUtils.getSystemConfig().getIsAuthApi()) {
			return true;
		}
		String secretKey=getRequestApiSecret(userId, time, token);
		
		if(!secretKey.equals(secret)) {
			return false;
		}
		if(url.equals("/console/Recharge")){
			if(checkMacExistRedis(userId,url+secret)){
				return false;
			}
		}
		return true;
		
	}
	
	public  String getRequestApiSecret(String userId,long time,String token) {
		
		/**
		 * 密钥 
			md5(apikey+time+userid+token) 
		 */
		
		
		/**
		 *  apikey+time+userid+token
		 */
		String key =new StringBuffer()
					.append(getApiKey())
					.append(time)
					.append(userId)
					.append(token).toString();

		return Md5Util.md5Hex(key);
		
	}
	/**
	 * 发送短信验证码 授权
	 * @param userId
	 * @param time
	 * @param token
	 * @return
	 */
	public  boolean authSendTelMsgSecret(String userId,long time,String secret) {
		
		/**
		 * 密钥 
			md5(apikey+time+userid+token) 
		 */
		
		
		/**
		 *  apikey+time+userid+token
		 */
		String key =new StringBuffer()
					.append(getApiKey())
					.append(time)
					.append(userId).toString();
		
		return secret.equals(Md5Util.md5Hex(key));
		
	}
	
	public  boolean authRedPacket(String payPassword,String userId,String token,long time,String secret) {
		
		if(!authRequestTime(time)) {
			return false;
		}
		if(StringUtil.isEmpty(secret)) {
			return false;
		}
		if(StringUtil.isEmpty(payPassword)){
			return false;
		}
			
		String secretKey=getRedPacketSecret(payPassword,userId, token,time);
		
		if(!secretKey.equals(secret)) {
			return false;
		}else {
			return true;
		}
		
	}
	
	public  boolean authRedPacketV1(String payPassword,String userId,String token,long time,String money,String secret) {
		if(!authRequestTime(time)) {
			return false;
		}
		if(StringUtil.isEmpty(secret)) {
			return false;
		}
		if(StringUtil.isEmpty(payPassword)){
			return false;
		}
			
		String secretKey=getRedPacketSecretV1(payPassword,userId, token,time,money);
		
		if(!secretKey.equals(secret)) {
			return false;
		}else {
			return true;
		}
		
	}
	public  boolean authRedPacket(String userId,String token,long time,String secret) {
		if(!authRequestTime(time)) {
			return false;
		}
		if(StringUtil.isEmpty(secret)) {
			return false;
		}
			
		String secretKey=getRedPacketSecret(userId, token,  time);
		
		if(!secretKey.equals(secret)) {
			return false;
		}else {
			return true;
		}
		
	}
	/**
	 * 检验授权 红包相关接口
	 * @param payPassword
	 * @param userId
	 * @param token
	 * @param openid
	 * @param time
	 * @param secret
	 * @return
	 */
	public  String getRedPacketSecret(String payPassword,String userId,String token,long time) {
		
		/**
		 * 密钥 
			md5( md5(apikey+time) +userid+token) 
		 */
		
		/**
		 * apikey+time+money
		 */
		String apiKey_time=new StringBuffer()
				.append(getApiKey())
				.append(time).toString();
		
		/**
		 * userid+token
		 */
		String userid_token=new StringBuffer()
				.append(userId)
				.append(token).toString();
		/**
		 * payPassword
		 */
		String md5payPassword=payPassword;
		/**
		 * md5(apikey+time+money)
		 */
		String md5ApiKey_time=Md5Util.md5Hex(apiKey_time);
		
		/**
		 *  md5(apikey+time+money) +userid+token+payPassword
		 */
		String key =new StringBuffer()
					.append(md5ApiKey_time)
					.append(userid_token)
					.append(md5payPassword).toString();
		
		return Md5Util.md5Hex(key);
		
	}
	
	public  String getRedPacketSecretV1(String payPassword,String userId,String token,long time,String money) {
		/**
		 * 密钥 
			md5( md5(apikey+time+money) +userid+token) 
		 */
		
		/**
		 * apikey+time+money
		 */
		String apiKey_time_money=new StringBuffer()
				.append(getApiKey())
				.append(time)
				.append(money).toString();
		
		/**
		 * userid+token
		 */
		String userid_token=new StringBuffer()
				.append(userId)
				.append(token).toString();
		/**
		 * payPassword
		 */
		String md5payPassword=payPassword;
		/**
		 * md5(apikey+time+money)
		 */
		String md5ApiKey_time_money=Md5Util.md5Hex(apiKey_time_money);
		
		/**
		 *  md5(apikey+time+money) +userid+token+payPassword
		 */
		String key =new StringBuffer()
					.append(md5ApiKey_time_money)
					.append(userid_token)
					.append(md5payPassword).toString();
		
		return Md5Util.md5Hex(key);
		
	}

	public  String getRedPacketSecret(String userId,String token,long time) {
		
		/**
		 * 密钥 
			md5( md5(apikey+time) +userid+token) 
		 */
		
		/**
		 * apikey+time
		 */
		String apiKey_time=new StringBuffer()
				.append(getApiKey())
				.append(time).toString();
		
		/**
		 * userid+token
		 */
		String userid_token=new StringBuffer()
				.append(userId)
				.append(token).toString();
//		/**
//		 * payPassword
//		 */
//		String md5payPassword=payPassword;
		/**
		 * md5(apikey+time)
		 */
		String md5ApiKey_time=Md5Util.md5Hex(apiKey_time);
		
		/**
		 *  md5(apikey+time) +userid+token+payPassword
		 */
		String key =new StringBuffer()
					.append(md5ApiKey_time)
					.append(userid_token).toString();
		
		return Md5Util.md5Hex(key);
		
	}
	/**
	 * 发消息、群发消息、发群组消息
	 * @param userId
	 * @param time
	 * @param content
	 * @param secret
	 * @return
	 */
	public  boolean authSendMsg(String userId,long time,String content,String secret) {
		if(!authRequestTime(time)) {
			return false;
		}
		if(StringUtil.isEmpty(secret)) {
			return false;
		}
		/**
		 * 密钥 
			md5(apikey+userid+time+content)
		 */
		
		
		
		/**
		 *  apikey+userid+time+content
		 */
		String key =new StringBuffer()
					.append(getApiKey())
					.append(userId)
					.append(time)
					.append(content).toString();
		
		String secretKey=Md5Util.md5Hex(key);
		
		if(!secretKey.equals(secret)) {
			return false;
		}else {
			return true;
		}
		
	}
	
	public  boolean authWxTransferPay(String payPassword,String userId,String token,String amount,String openid,long time,String secret) {
		if(!authRequestTime(time)) {
			return false;
		}
		if(StringUtil.isEmpty(secret)) {
			return false;
		}
		if(StringUtil.isEmpty(payPassword)){
			return false;
		}
		String secretKey=getWxTransferPaySecret(payPassword,userId, token, amount, openid, time);
		if(!secretKey.equals(secret)) {
			return false;
		}else {
			return true;
		}
		
	}
	/**
	 * 微信 提现 的 加密 认证方法
	 * @return
	 */
	public  String getWxTransferPaySecret(String payPassword,String userId,String token,String amount,String openid,long time) {
		/**
		 * 提现密钥 
			md5(apiKey+openid+userid + md5(token+amount+time) ) 
		 */
		
		/**
		 * apiKey+openid+userid
		 */
		String apiKey_openid_userId=new StringBuffer()
				.append(getApiKey())
				.append(openid)
				.append(userId).toString();
		
		/**
		 * token+amount+time
		 */
		String token_amount_time=new StringBuffer()
				.append(token)
				.append(amount)
				.append(time).toString();
	
		/**
		 * md5(token+amount+time)
		 */
		String md5Token=Md5Util.md5Hex(token_amount_time);
		
		/**
		 * md5(payPassword)
		 */
		String md5PayPassword=payPassword;
		
		/**
		 * apiKey+openid+userid + md5(token+amount+time)
		 */
		String key =new StringBuffer()
					.append(apiKey_openid_userId)
					.append(md5Token)
					.append(md5PayPassword).toString();
		
		return Md5Util.md5Hex(key);
	}


	/** @Description:（应用授权的 加密 认证方法） 
	* @param appId
	* @param userId
	* @param appSecret
	* @param token
	* @param time
	* @param secret
	* @return
	**/ 
	public  boolean getAppAuthorization(String appId,String appSecret,long time,String secret) {
		boolean flag = false;
		if(!authRequestTime(time)) {
			return flag;
		}
		if(StringUtil.isEmpty(appId)) {
			return flag;
		}
		if(StringUtil.isEmpty(appSecret)){
			return flag;
		}
		String secretKey = getAppAuthorizationSecret(appId, time, appSecret);
		if(!secretKey.equals(secret)) {
			return flag;
		}else {
			return !flag;
		}
	}
	
	public  boolean getAuthInterface(String appId,String userId,String token,long time,String appSecret,String secret){
		boolean flag=false;
		if(!authRequestTime(time)) {
			return flag;
		}
		if(StringUtil.isEmpty(appId)) {
			return flag;
		}
		if(StringUtil.isEmpty(appSecret)){
			return flag;
		}
		String secretKey = getAuthInterfaceSecret(appId, userId, token, time, appSecret);
		if(!secretKey.equals(secret)) {
			return flag;
		}else {
			return !flag;
		}
	}
	
	public  String getAppAuthorizationSecret(String appId,long time,String appSecret){
		// secret=md5(appId+md5(time)+md5(appSecret))	
		/**
		 * md5(time)
		 */
		String times = new StringBuffer()
				.append(time).toString();
		String md5Time = Md5Util.md5Hex(times);
		
		/**
		 * appId+md5(time)
		 */
		String AppIdMd5time = new StringBuffer()
				.append(appId)
				.append(md5Time).toString();
		
		/**
		 * appId+md5(time)+md5(appSecret)
		 */
		String md5AppSecret = Md5Util.md5Hex(appSecret);
		
		String secret=new StringBuffer()
				.append(AppIdMd5time)
				.append(md5AppSecret).toString();
		
		
		String key = Md5Util.md5Hex(secret);
		
		return key;
	}
	
	public  String getAuthInterfaceSecret(String appId,String userId,String token,long time,String appSecret){
		// secret=md5(apikey+appId+userid+md5(token+time)+md5(appSecret))
		
		/**
		 * md5(appSecret)
		 */
		String md5AppSecret=Md5Util.md5Hex(appSecret);
		
		/**
		 * md5(token+time)
		 */
		
		String tokenTime=new StringBuffer()
				.append(token)
				.append(time).toString();
		String md5TokenTime=Md5Util.md5Hex(tokenTime);
		
		/**
		 * apikey+appId+userId
		 */
		
		String apiKeyAppIdUserId=new StringBuffer()
				.append(getApiKey())
				.append(appId)
				.append(userId).toString();
		
		String secret=new StringBuffer()
				.append(apiKeyAppIdUserId)
				.append(md5TokenTime)
				.append(md5AppSecret).toString();
		
		String key=Md5Util.md5Hex(secret);
		return key;
	}
	
	// 校验付款码付款接口加密
	public  boolean authPaymentCode(String paymentCode,String userId,String money,String token,long time,String secret){
		if(StringUtil.isEmpty(paymentCode)){
			return false;
		}
		if(StringUtil.isEmpty(userId)){
			return false;
		}
		if(StringUtil.isEmpty(money)){
			return false;
		}
		if(StringUtil.isEmpty(token)){
			return false;
		}
		String secretKey = getPaymentCodeSecret(paymentCode,userId,money,token,time);
		if(secretKey.equals(secret)){
			return true;
		}else{
			return false;
		}
	}
	
	public  String getPaymentCodeSecret(String paymentCode,String userId,String money,String token,long time){
		
		 // 付款码付款加密 secret = md5(md5(apiKey+time+money+paymentCode)+userId+token)
		 
		
		/**
		 * md5(apikey+time+money+paymentCode)
		 */
		String Apikey_time_money_paymentCode=new StringBuffer()
				.append(getApiKey())
				.append(time)
				.append(money)
				.append(paymentCode).toString();
		
		String md5Apikey_time_money_paymentCode=Md5Util.md5Hex(Apikey_time_money_paymentCode);
		/**
		 * userId+token
		 */
		String userId_token=new StringBuffer()
				.append(userId)
				.append(token).toString();
		
		String secret=new StringBuffer()
				.append(md5Apikey_time_money_paymentCode)
				.append(userId_token).toString();
		
		String key=Md5Util.md5Hex(secret);
		return key;
		
	}
	
	public  boolean authQRCodeReceipt(String userId,String token,String money,long time,String payPassword,String secret){
		if(StringUtil.isEmpty(userId)){
			return false;
		}
		if(StringUtil.isEmpty(token)){
			return false;
		}
		if(StringUtil.isEmpty(money)){
			return false;
		}
		if(!authRequestTime(time)){
			return false;
		}
		if(StringUtil.isEmpty(payPassword)){
			return false;
		}
		String secretKey = getQRCodeReceiptSecret(userId,token,money,time,payPassword);
		if(secretKey.equals(secret)){
			return true;
		}else{
			return false;
		}
	}
	
	public  String getQRCodeReceiptSecret(String userId,String token,String money,long time,String payPassword){
		 // 二维码收款加密 secret = md5(md5(apiKey+time+money+payPassword)+userId+token)
		
		/**
		 * md5(apiKey+time+money)
		 */
		String apiKey_time_money_payPassword=new StringBuffer()
				.append(getApiKey())
				.append(time)
				.append(money)
				.append(payPassword).toString();
		
		String md5Apikey_time_money_payPassword=Md5Util.md5Hex(apiKey_time_money_payPassword);
		
		/**
		 * userId_token
		 */
		String userId_token=new StringBuffer()
				.append(userId)
				.append(token).toString();
		
		String secret=new StringBuffer()
				.append(md5Apikey_time_money_payPassword)
				.append(userId_token).toString();
		
		String key=Md5Util.md5Hex(secret);
		return key;
	}
	
	public  boolean authPaymentSecret(String userId,String token,String payPassword,long time,String secret){
		if(StringUtil.isEmpty(userId)){
			return false;
		}
		if(StringUtil.isEmpty(token)){
			return false;
		}
		if(!authRequestTime(time)){
			return false;
		}
		if(StringUtil.isEmpty(payPassword)){
			return false;
		}
		String secretKey = getPaymentSecret(userId,token,time,payPassword);
		if(secretKey.equals(secret)){
			return true;
		}else{
			return false;
		}
		
	}
	
	public  String getPaymentSecret(String userId,String token,long time,String payPassword){
		// 付款加密规则
		// md5(userId+token+md5(apiKey+time+payPassword))
		
		/**
		 * userId_token
		 */
		String userId_token=new StringBuffer()
				.append(userId)
				.append(token).toString();
		/**
		 * md5(apiKey+time+payPassword)
		 */
		String apiKey_time_payPassword=new StringBuffer()
				.append(apiKey)
				.append(time)
				.append(payPassword).toString();
		
		String Md5ApiKey_time_payPassword = Md5Util.md5Hex(apiKey_time_payPassword);
		
		String secret=new StringBuffer()
				.append(userId_token)
				.append(Md5ApiKey_time_payPassword).toString();
		
		String key=Md5Util.md5Hex(secret);
		return key;
		
	}

	
}
