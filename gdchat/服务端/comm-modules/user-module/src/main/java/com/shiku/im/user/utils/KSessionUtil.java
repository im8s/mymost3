package com.shiku.im.user.utils;

import com.alibaba.fastjson.JSON;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.entity.ClientConfig;
import com.shiku.im.jedis.RedisCRUD;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.utils.StringUtil;
import lombok.extern.slf4j.Slf4j;

import java.util.HashMap;
import java.util.Map;

@Slf4j
public final class KSessionUtil {



	public static final String GET_CLIENTCONFIG = "clientConfig";

	// 根据access_token获取管理员userId
	public static final String GET_ADMIN_USERID_BYTOKEN ="adminToken:userId:%s";

	// 根据管理员userId获取access_token
	public static final String GET_ADMIN_TOKEN_BY_USER_ID = "adminToken:token:%s";


	/**
	 * 根据用户Id获取access_token
	 */
	//public static final String GET_USERID_BYTOKEN = "at_%1$s";
	public static final String GET_USERID_BYTOKEN = "loginToken:userId:%s";
	
	//public static final String GET_ACCESS_TOKEN_BY_USER_ID ="uk_%1$s";
	public static final String GET_ACCESS_TOKEN_BY_USER_ID = "loginToken:token:%s";

	public static final String GET_ACCESS_TOKEN_BY_USERDEVICEID = "loginToken:token:%s:%s";

	public static final String GET_API_TOKEN_BY_USER_ID = "apiToken:%s";


	
	

	/**
	 * 根据access_token获取Session
	 */
	public static final String GET_SESSION_BY_ACCESS_TOKEN = "login:%s:session";
	
	
	public static final String GET_USER_BY_USERID = "user:%s:data";
	

	

	
	public static RedisCRUD getRedisCRUD(){
		return SKBeanUtils.getRedisCRUD();
	}

	public static void setClientConfig(ClientConfig clientConfig){
		getRedisCRUD().set(GET_CLIENTCONFIG, clientConfig.toString());
	}
	public static ClientConfig getClientConfig() {
		String config=getRedisCRUD().get(GET_CLIENTCONFIG);
		return StringUtil.isEmpty(config) ? null : JSON.parseObject(config, ClientConfig.class);
	}
	
	public static Map<String, Object> loginSaveAccessToken(Object userKey,Object userId,String accessToken) {
		HashMap<String, Object> data = new HashMap<String, Object>();
		try {
			
			int expire= KConstants.Expire.DAY7*5;
			String atKey = String.format(GET_ACCESS_TOKEN_BY_USER_ID, userKey);
			if(StringUtil.isEmpty(accessToken))
				accessToken=SKBeanUtils.getRedisCRUD().get(atKey);
			if(StringUtil.isEmpty(accessToken))
				accessToken = StringUtil.randomUUID();
			SKBeanUtils.getRedisCRUD().setWithExpireTime(atKey, accessToken,expire);
			
			String userIdKey =String.format(GET_USERID_BYTOKEN, accessToken);
			SKBeanUtils.getRedisCRUD().setWithExpireTime(userIdKey, String.valueOf(userId),expire);
			
			data.put("access_token", accessToken);
			data.put("expires_in",expire);


			return data;
		}catch (Exception e) {
			e.printStackTrace();
			return data;
		} 
	}
	


	/**
	 * 保存所有后台登录的用户Token
	 * @param userId
	 * @param adminToken
	 * @return
	 */
	public static Map<String, Object> adminLoginSaveToken(Object userId,String adminToken){
		HashMap<String, Object> data = new HashMap<String, Object>();
		try {
			int expire = KConstants.Expire.DAY1;
			
			String userIdKey = String.format(GET_ADMIN_TOKEN_BY_USER_ID, userId);
			if(StringUtil.isEmpty(adminToken))
				//根据 userId 到redis 查找 token
				adminToken = SKBeanUtils.getRedisCRUD().get(userIdKey);
			
			if(StringUtil.isEmpty(adminToken))
				// redis 中不存在则生成一个token保存到redis中
				adminToken = StringUtil.randomUUID();  
				
			SKBeanUtils.getRedisCRUD().setWithExpireTime(userIdKey, adminToken, expire);
				
			String tokenKey = String.format(GET_ADMIN_USERID_BYTOKEN, adminToken);
			SKBeanUtils.getRedisCRUD().setWithExpireTime(tokenKey, String.valueOf(userId), expire);
				
			data.put("access_Token", adminToken);
			data.put("expires_in", expire);
			
			return data;
		} catch (Exception e) {
			e.printStackTrace();
			return data;
		}
	}
	
	public static void removeAdminToken(Object userKey){
		log.info(" removeAdminToken ===== userKey ===== :"+userKey);
		
		String key = String.format(GET_ADMIN_TOKEN_BY_USER_ID, userKey);
		String admin_token = SKBeanUtils.getRedisCRUD().get(key);
		
		if(!StringUtil.isEmpty(admin_token))
			getRedisCRUD().delete(key);
		if(!StringUtil.isEmpty(admin_token)){
			String userIdKey = String.format(GET_ADMIN_USERID_BYTOKEN, admin_token);
			SKBeanUtils.getRedisCRUD().del(userIdKey);
		}
		
	}
	

	
	public static void  removeAccessToken(Object userKey) {
		log.info("  removeAccessToken  =====  userKey  ======= :"+userKey);
		// 根据userKey拿token
		String key = String.format(GET_ACCESS_TOKEN_BY_USER_ID, userKey);
		String access_token = SKBeanUtils.getRedisCRUD().get(key);
		
		
		if (!StringUtil.isEmpty(access_token)) {
			getRedisCRUD().delete(key);
		}
		if (!StringUtil.isEmpty(access_token)) {
			String userIdKey =String.format(GET_USERID_BYTOKEN, access_token);
			SKBeanUtils.getRedisCRUD().del(userIdKey);
		}
	}
	
	/*public static void  removeToken(Object token) {
		String userId=null;
			if (!StringUtil.isEmpty(token.toString())) {
				String userIdKey =String.format(GET_USERID_BYTOKEN, token);
				userId=SKBeanUtils.getRedisCRUD().get(userIdKey);
				SKBeanUtils.getRedisCRUD().del(userId);
			}
			
			// 根据userKey拿token
			String key = String.format(GET_ACCESS_TOKEN_BY_USER_ID, userId);
			String access_token = SKBeanUtils.getRedisCRUD().get(key);
			if (!StringUtil.isEmpty(access_token)) {
				getRedisCRUD().delete(key);
			}
			
	}*/

				


	public static String getAccess_token(long userId){
		String key = String.format(GET_ACCESS_TOKEN_BY_USER_ID,userId);
		return getRedisCRUD().get(key);
	}
	public static String getUserIdBytoken(String token){
		String key = String.format(GET_USERID_BYTOKEN,token);
		return getRedisCRUD().get(key);
	}
	
	public static String getAdminToken(long userId){
		String key = String.format(GET_ADMIN_TOKEN_BY_USER_ID, userId);
		return getRedisCRUD().get(key);
	}
	public static String getAdminUserIdByToken(String token){
		String key = String.format(GET_ADMIN_USERID_BYTOKEN, token);
		return getRedisCRUD().get(key);
	}
	

	
	

	
	public static final String GET_ADDRESS_BYIP="clientIp:%s";
	public static String getAddressByIp(String ip){
		String key = String.format(GET_ADDRESS_BYIP, ip);
		return getRedisCRUD().get(key);
	}
	public static void setAddressByIp(String ip,String address){
		String key = String.format(GET_ADDRESS_BYIP, ip);
		getRedisCRUD().setWithExpireTime(key, address,KConstants.Expire.HOUR12);
		
	}
	
	
	
	
}
