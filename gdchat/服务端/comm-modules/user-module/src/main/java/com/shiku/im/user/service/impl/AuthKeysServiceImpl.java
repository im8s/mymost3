package com.shiku.im.user.service.impl;

import com.alibaba.fastjson.JSONObject;
import com.shiku.im.comm.utils.DateUtil;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.common.service.PaymentManager;
import com.shiku.im.friends.service.impl.FriendsManagerImpl;
import com.shiku.im.user.dao.AuthKeysDao;
import com.shiku.im.user.entity.AuthKeys;
import com.shiku.im.user.model.KeyPairParam;
import com.shiku.im.user.service.AuthKeysService;
import com.shiku.im.user.service.UserCoreRedisRepository;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.user.service.UserRedisService;
import com.shiku.im.user.utils.WXUserUtils;
import lombok.extern.slf4j.Slf4j;
import org.bson.Document;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 *
 */
@Slf4j
@Service
public class AuthKeysServiceImpl implements AuthKeysService {

	@Autowired
	private AuthKeysDao authKeysDao;


	/*@Autowired
	@Qualifier(value = "userDao")
	private UserDaoImpl userDao;*/

	@Autowired
	private UserCoreService userManager;

	@Autowired
	private UserRedisService userRedisService;

	@Autowired
	private UserCoreRedisRepository userCoreRedisRepository;

	@Autowired(required = false)
	private PaymentManager paymentManager;


	@Autowired(required = false)
	private FriendsManagerImpl friendsManager;

	@Override
	public List<AuthKeys> getYopNotNull() {
		return authKeysDao.getYopNotNull();
	}

	public AuthKeys getAuthKeys(int userId){
		AuthKeys authKeys=userRedisService.getAuthKeys(userId);
		if(null==authKeys){

//			Query<AuthKeys> query=createQuery();
//			query.project("dhMsgKeyList", false);
//			query.filter("_id",userId);
//			authKeys=findOne(query);
			authKeys = authKeysDao.queryAuthKeys(userId);
			if(null!=authKeys)
				userRedisService.saveAuthKeys(userId,authKeys);
		}
		return authKeys;
	}

	public synchronized void updateLoginPassword(int userId,String password) {
//		AuthKeys userKeys = get(userId);
		AuthKeys userKeys = authKeysDao.getAuthKeys(userId);
		if(null==userKeys) {
			userKeys=new AuthKeys(userId);
			userKeys.setPassword(password);
//			save(userKeys);
			authKeysDao.addAuthKeys(userKeys);
			return;
		}

//		UpdateOperations<AuthKeys> operations = createUpdateOperations();
//		operations.set("password", password);
//		operations.set("modifyTime",DateUtil.currentTimeSeconds());
//		updateAttributeByOps(userId, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("password", password);
		map.put("modifyTime", DateUtil.currentTimeSeconds());
		authKeysDao.updateAuthKeys(userId,map);
//		SKBeanUtils.getUserRepository().updatePassowrd(userId,password);
		userManager.updatePassowrd(userId,password);
		//给好友发送更新公钥的xmpp 消息 803
		if(userKeys.getMsgDHKeyPair()!=null && userKeys.getMsgRsaKeyPair()!=null) {
			sendUpdatePublicKeyMsgToFriends(userKeys.getMsgDHKeyPair().getPublicKey(), userKeys.getMsgRsaKeyPair().getPublicKey(), userId);

		}
		//删除自己的

		userRedisService.deleteAuthKeys(userId);
		userCoreRedisRepository.deleteUserByUserId(userId);
		updateLoginPasswordCleanKeyPair(userId);
	}
	public  String queryLoginPassword(int userId) {
//		Object dbObj = queryOneFieldById("password", userId);
		Object dbObj = authKeysDao.queryOneFieldById("password", userId);
		if(null==dbObj){
			/*String oldPwd = userManager.queryPassword(userId);
			String newPassword = LoginPassword.encodeFromOldPassword(oldPwd);
			updateLoginPassword(userId,newPassword);*/
			return null;
		}

		return dbObj.toString();
	}
	public String getPayPassword(Integer userId) {
//		Object key = queryOneFieldById("payPassword", userId);
		Object key = authKeysDao.queryOneFieldById("payPassword", userId);
		if(null==key)
			return null;
		else return String.valueOf(key);
	}

	public String getWalletUserNo(int userId){
		Object key = authKeysDao.queryOneFieldById("walletUserNo",userId);
		if(null == key)
			return null;
		else return String.valueOf(key);
	}

	public synchronized void updatePayPassword(int userId,String payPassword) {
//		AuthKeys userKeys = get(userId);
		AuthKeys userKeys = authKeysDao.getAuthKeys(userId);
		if(null==userKeys) {
			userKeys=new AuthKeys(userId);

			userKeys.setPayPassword(payPassword);
//			save(userKeys);
			authKeysDao.addAuthKeys(userKeys);
			return;
		}
//		UpdateOperations<AuthKeys> operations = createUpdateOperations();
//		operations.set("payPassword", payPassword);
//		operations.set("modifyTime",DateUtil.currentTimeSeconds());
//		updateAttributeByOps(userId, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("payPassword", payPassword);
		map.put("modifyTime",DateUtil.currentTimeSeconds());
		authKeysDao.updateAuthKeys(userId,map);
	}
	public synchronized void uploadPayKey(int userId,String publicKey,String privateKey) {
//		AuthKeys userKeys = get(userId);
		AuthKeys userKeys = authKeysDao.getAuthKeys(userId);
		if(null==userKeys) {
			userKeys=new AuthKeys(userId);
			AuthKeys.KeyPair keyPair=new AuthKeys.KeyPair(publicKey, privateKey);
			keyPair.setCreateTime(userKeys.getCreateTime());
			userKeys.setPayKeyPair(keyPair);
//			save(userKeys);
			authKeysDao.addAuthKeys(userKeys);
			return;
		}
//		UpdateOperations<AuthKeys> operations = createUpdateOperations();
//		operations.set("payKeyPair.publicKey", publicKey);
//		operations.set("payKeyPair.privateKey", privateKey);
		long time=DateUtil.currentTimeSeconds();
//		operations.set("payKeyPair.modifyTime",time);
//		operations.set("modifyTime",time);
//		updateAttributeByOps(userId, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("payKeyPair.publicKey", publicKey);
		map.put("payKeyPair.privateKey", privateKey);
		map.put("payKeyPair.modifyTime",time);
		map.put("modifyTime",time);
		authKeysDao.updateAuthKeys(userId,map);

	}
	public synchronized void uploadLoginKeyPair(int userId,String publicKey,String privateKey) {
//		AuthKeys userKeys = get(userId);
		AuthKeys userKeys = authKeysDao.getAuthKeys(userId);
		if(null==userKeys) {
			userKeys=new AuthKeys(userId);
			AuthKeys.KeyPair keyPair=new AuthKeys.KeyPair(publicKey, privateKey);
			keyPair.setCreateTime(userKeys.getCreateTime());
			userKeys.setLoginKeyPair(keyPair);
//			save(userKeys);
			authKeysDao.addAuthKeys(userKeys);
			return;
		}
		if(null!=userKeys.getLoginKeyPair()&&!StringUtil.isEmpty(userKeys.getLoginKeyPair().getPrivateKey())) {
			log.error("{}  登陆公私钥 已经存在  不能更新  ",userId);
			return;
		}
//		UpdateOperations<AuthKeys> operations = createUpdateOperations();
//		operations.set("loginKeyPair.publicKey", publicKey);
//		operations.set("loginKeyPair.privateKey", privateKey);
		long time=DateUtil.currentTimeSeconds();
//		operations.set("loginKeyPair.modifyTime",time);
//		operations.set("modifyTime",time);
//		updateAttributeByOps(userId, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("loginKeyPair.publicKey", publicKey);
		map.put("loginKeyPair.privateKey", privateKey);
		map.put("loginKeyPair.modifyTime",time);
		map.put("modifyTime",time);
		authKeysDao.updateAuthKeys(userId,map);
	}
	public  void deleteLoginKeyPair(int userId) {
//		AuthKeys userKeys = get(userId);
		AuthKeys userKeys = authKeysDao.getAuthKeys(userId);
		if(null==userKeys) {
			return;
		}
		if(null==userKeys.getLoginKeyPair()||StringUtil.isEmpty(userKeys.getLoginKeyPair().getPublicKey()))
		    return;
//		UpdateOperations<AuthKeys> operations = createUpdateOperations();
//		operations.set("loginKeyPair.publicKey", "");
//		operations.set("loginKeyPair.privateKey", "");
		long time=DateUtil.currentTimeSeconds();
//		operations.set("loginKeyPair.modifyTime",time);
//		operations.set("modifyTime",time);
//		updateAttributeByOps(userId, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("loginKeyPair.publicKey", "");
		map.put("loginKeyPair.privateKey", "");
		map.put("loginKeyPair.modifyTime",time);
		map.put("modifyTime",time);
		authKeysDao.updateAuthKeys(userId,map);

	}

	public  void deletePayKey(int userId) {
//		AuthKeys userKeys = get(userId);
		AuthKeys userKeys = authKeysDao.getAuthKeys(userId);
		if(null==userKeys) {
			return;
		}
//		UpdateOperations<AuthKeys> operations = createUpdateOperations();
//		operations.set("payKeyPair.publicKey", "");
//		operations.set("payKeyPair.privateKey", "");
		long time=DateUtil.currentTimeSeconds();
//		operations.set("payKeyPair.modifyTime",time);
//		operations.set("modifyTime",time);
//		updateAttributeByOps(userId, operations);
		Map<String,Object> map = new HashMap<>();
		map.put("payKeyPair.publicKey", "");
		map.put("payKeyPair.privateKey", "");
		map.put("payKeyPair.modifyTime",time);
		map.put("modifyTime",time);
		authKeysDao.updateAuthKeys(userId,map);
	}
	public  String getPayPublicKey(int userId) {
		Document payPublicKey =(Document) authKeysDao.queryOneFieldById("payKeyPair", userId);
		if(null==payPublicKey)
			return null;
		else return payPublicKey.getString("publicKey");
	}


	@Override
	public void cleanTransactionSignCode(int userId, String codeId) {
		if (paymentManager == null){
			return;
		}
		paymentManager.cleanTransactionSignCode(userId,codeId);
	}

	@Override
	public String queryTransactionSignCode(int userId, String codeId) {
		if (paymentManager == null){
			return "";
		}
		return paymentManager.queryTransactionSignCode(userId,codeId);
	}

	public String getPayPrivateKey(int userId) {
//		BasicDBObject payPublicKey =(BasicDBObject) queryOneFieldById("payKeyPair", userId);
		Document payPublicKey = (Document) authKeysDao.queryOneFieldById("payKeyPair", userId);
		if(null==payPublicKey)
			return null;
		else return payPublicKey.getString("privateKey");
	}
	public  String getLoginPublicKey(int userId) {
//		BasicDBObject dbObject =(BasicDBObject) queryOneFieldById("loginKeyPair", userId);
		Document dbObject =(Document) authKeysDao.queryOneFieldById("loginKeyPair", userId);
		if(null==dbObject)
			return null;
		else return dbObject.getString("publicKey");
	}
	public String getLoginPrivateKey(int userId) {
//		BasicDBObject dbObject =(BasicDBObject) queryOneFieldById("loginKeyPair", userId);
		Document dbObject =(Document) authKeysDao.queryOneFieldById("loginKeyPair", userId);
		if(null==dbObject)
			return null;
		else return dbObject.getString("privateKey");
	}

	/**
	 * 修改密码  清除 需要更新的 公私钥
	 */
	public void updateLoginPasswordCleanKeyPair(int userId){
		deleteLoginKeyPair(userId);
		userRedisService.deleteAuthKeys(userId);

	}
	public synchronized boolean uploadMsgKey(int userId, KeyPairParam param) {
//		AuthKeys userKeys = get(userId);
		AuthKeys userKeys = authKeysDao.getAuthKeys(userId);
		if(null==userKeys) {
			userKeys=new AuthKeys(userId);
			AuthKeys.KeyPair rsakeyPair=new AuthKeys.KeyPair(param.getRsaPublicKey(), param.getRsaPrivateKey());
			rsakeyPair.setCreateTime(userKeys.getCreateTime());

			AuthKeys.KeyPair dhkeyPair=new AuthKeys.KeyPair(param.getDhPublicKey(), param.getDhPrivateKey());
			dhkeyPair.setCreateTime(userKeys.getCreateTime());
			userKeys.setMsgRsaKeyPair(rsakeyPair);
			userKeys.setMsgDHKeyPair(dhkeyPair);
			AuthKeys.PublicKey puKey=new AuthKeys.PublicKey();
			puKey.setKey(param.getDhPublicKey());
			puKey.setTime(userKeys.getCreateTime());
			userKeys.getDhMsgKeyList().add(puKey);
//			save(userKeys);
			authKeysDao.addAuthKeys(userKeys);
			return true;
		}
//		UpdateOperations<AuthKeys> operations = createUpdateOperations();
		Map<String,Object> map = new HashMap<>();
		if(!StringUtil.isEmpty(param.getDhPublicKey())) {
			AuthKeys.PublicKey puKey=new AuthKeys.PublicKey();
			puKey.setKey(param.getDhPublicKey());
			puKey.setTime(DateUtil.currentTimeSeconds());
			userKeys.getDhMsgKeyList().add(puKey);
//			operations.set("msgDHKeyPair.publicKey", param.getDhPublicKey());
//			operations.set("dhMsgKeyList", userKeys.getDhMsgKeyList());
			map.put("msgDHKeyPair.publicKey", param.getDhPublicKey());
			map.put("dhMsgKeyList", userKeys.getDhMsgKeyList());
		}
		if(!StringUtil.isEmpty(param.getDhPrivateKey())) {
//			operations.set("msgDHKeyPair.privateKey", param.getDhPrivateKey());
			map.put("msgDHKeyPair.privateKey", param.getDhPrivateKey());
		}
		if(!StringUtil.isEmpty(param.getRsaPublicKey())) {
//			operations.set("msgRsaKeyPair.publicKey", param.getRsaPublicKey());
			map.put("msgRsaKeyPair.publicKey", param.getRsaPublicKey());
		}
		if(!StringUtil.isEmpty(param.getRsaPrivateKey())) {

//			operations.set("msgRsaKeyPair.privateKey", param.getRsaPrivateKey());
			map.put("msgRsaKeyPair.privateKey", param.getRsaPrivateKey());
		}
//		operations.set("modifyTime", DateUtil.currentTimeSeconds());
		map.put("modifyTime", DateUtil.currentTimeSeconds());
		//清除缓存
		userRedisService.deleteAuthKeys(userId);

//		return updateAttributeByOps(userId, operations);
		return authKeysDao.updateAuthKeys(userId,map);
	}

	public KeyPairParam queryMsgKeyPair(){
		return  null;
	}
	/**
	 * 上传 dh 消息公钥
	 * @param userId
	 * @param publicKey
	 * @param privateKey
	 */
	public synchronized void uploadDHMsgKey(int userId,String publicKey,String privateKey) {
//		AuthKeys userKeys = get(userId);
		AuthKeys userKeys = authKeysDao.getAuthKeys(userId);
		if(null==userKeys) {
			userKeys=new AuthKeys(userId);
			AuthKeys.KeyPair keyPair=new AuthKeys.KeyPair(publicKey, privateKey);
			keyPair.setCreateTime(userKeys.getCreateTime());
			userKeys.setMsgDHKeyPair(keyPair);
			AuthKeys.PublicKey puKey=new AuthKeys.PublicKey();
			puKey.setKey(publicKey);
			puKey.setTime(keyPair.getCreateTime());
			userKeys.getDhMsgKeyList().add(puKey);
//			save(userKeys);
			authKeysDao.addAuthKeys(userKeys);
			return;
		}
//		UpdateOperations<AuthKeys> operations = createUpdateOperations();
		Map<String,Object> map = new HashMap<>();
		if(!StringUtil.isEmpty(publicKey)) {
			AuthKeys.PublicKey puKey=new AuthKeys.PublicKey();
			puKey.setKey(publicKey);
			puKey.setTime(DateUtil.currentTimeSeconds());
			userKeys.getDhMsgKeyList().add(puKey);
//			operations.set("msgDHKeyPair.publicKey", publicKey);
//			operations.set("dhMsgKeyList", userKeys.getDhMsgKeyList());
			map.put("msgDHKeyPair.publicKey", publicKey);
			map.put("dhMsgKeyList", userKeys.getDhMsgKeyList());
		}
		if(!StringUtil.isEmpty(privateKey)) {	
//			operations.set("msgDHKeyPair.privateKey", privateKey);
			map.put("msgDHKeyPair.privateKey", privateKey);
		}
//		operations.set("modifyTime", DateUtil.currentTimeSeconds());
		map.put("modifyTime", DateUtil.currentTimeSeconds());
		
//		updateAttributeByOps(userId, operations);
		authKeysDao.updateAuthKeys(userId,map);
	}
	
	public String getMsgDHPublicKey(int userId) {
//		BasicDBObject dbObject =(BasicDBObject) queryOneFieldById("msgDHKeyPair", userId);
		Document dbObject = (Document) authKeysDao.queryOneFieldById("msgDHKeyPair", userId);
		if(null==dbObject)
			return null;
		else return dbObject.getString("publicKey");
	}

	public List<AuthKeys.PublicKey> queryMsgDHPublicKeyList(int userId) {
//		Object payPublicKey = queryOneFieldById("dhMsgKeyList", userId);
		Object payPublicKey = authKeysDao.queryOneFieldById("dhMsgKeyList", userId);
		if(null==payPublicKey)
			return null;
		else return (List)payPublicKey;
	}

	public Map<String,String> queryUseRSAPublicKeyList(List<Integer> userList) {
		return authKeysDao.queryUseRSAPublicKeyList(userList);
	}

	public synchronized void uploadMsgRSAKey(int userId,String publicKey,String privateKey) {
//		AuthKeys userKeys = get(userId);
		AuthKeys userKeys = authKeysDao.getAuthKeys(userId);
		if(null==userKeys) {
			userKeys=new AuthKeys(userId);
			AuthKeys.KeyPair keyPair=new AuthKeys.KeyPair(publicKey, privateKey);
			keyPair.setCreateTime(userKeys.getCreateTime());
			userKeys.setMsgRsaKeyPair(keyPair);

			AuthKeys.PublicKey puKey=new AuthKeys.PublicKey();
			puKey.setKey(publicKey);
			puKey.setTime(keyPair.getCreateTime());
//			save(userKeys);
			authKeysDao.addAuthKeys(userKeys);
			return;
		}
//		UpdateOperations<AuthKeys> operations = createUpdateOperations();
		Map<String,Object> map = new HashMap<>();
		if(!StringUtil.isEmpty(publicKey)){
			AuthKeys.PublicKey puKey=new AuthKeys.PublicKey();
			puKey.setKey(publicKey);
			puKey.setTime(DateUtil.currentTimeSeconds());
			userKeys.getDhMsgKeyList().add(puKey);
//			operations.set("msgRsaKeyPair.publicKey", publicKey);
			map.put("msgRsaKeyPair.publicKey", publicKey);
		}

		if(!StringUtil.isEmpty(privateKey)) {
//			operations.set("msgRsaKeyPair.privateKey", privateKey);
			map.put("msgRsaKeyPair.privateKey", privateKey);
		}
//		operations.set("modifyTime", DateUtil.currentTimeSeconds());
		map.put("modifyTime", DateUtil.currentTimeSeconds());

//		updateAttributeByOps(userId, operations);
		authKeysDao.updateAuthKeys(userId,map);
	}


	/**
	 * 用户 绑定微信 openId
	 * @param userId
	 * @param openid
	 */
	public Object bindWxopenid(int userId,String code) {
		if(StringUtil.isEmpty(code)) {
			return null;
		}
		JSONObject jsonObject = WXUserUtils.getWxOpenId(code);
		String openid=jsonObject.getString("openid");
		if(StringUtil.isEmpty(openid)) {
			return null;
		}
		System.out.println(String.format("======> bindWxopenid  userId %s  openid  %s", userId,openid));
//		updateAttribute(userId, "wxOpenId", openid);
		Map<String,Object> map = new HashMap<>();
		map.put("wxOpenId", openid);
		authKeysDao.updateAuthKeys(userId,map);
		return jsonObject;
	}
	public String getWxopenid(int userId) {
//		Object openId = queryOneFieldById("wxOpenId", userId);
		Object openId = authKeysDao.queryOneFieldById("wxOpenId", userId);
		if(null==openId)
			return null;
		else return String.valueOf(openId);
	}

	public void bindAliUserId(int userId,String aliUserId){
		if(StringUtil.isEmpty(aliUserId)){
			return ;
		}
//		updateAttribute(userId, "aliUserId", aliUserId);
		Map<String,Object> map = new HashMap<>();
		map.put("aliUserId", aliUserId);
		authKeysDao.updateAuthKeys(userId,map);
	}
	public String getAliUserId(int userId) {
//		Object openId = queryOneFieldById("aliUserId", userId);
		Object openId = authKeysDao.queryOneFieldById("aliUserId", userId);
		if(null==openId)
			return null;
		else return String.valueOf(openId);
	}
	@Override
	public void deleteAuthKeys(int userId){
		authKeysDao.deleteAuthKeys(userId);
	}
	
	public void sendUpdatePublicKeyMsgToFriends(String dhPublicKey,String rsaPublicKey, int userId){
		 friendsManager.sendUpdatePublicKeyMsgToFriends(dhPublicKey,rsaPublicKey,userId);

	}
	@Override
	public void save(AuthKeys authKeys) {
		authKeysDao.save(authKeys);
	}

	@Override
	public void update(int userId,Map<String,Object> map) {
		authKeysDao.updateAuthKeys(userId,map);
	}

}
