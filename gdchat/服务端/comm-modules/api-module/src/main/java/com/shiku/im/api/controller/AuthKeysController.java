package com.shiku.im.api.controller;

import com.alibaba.fastjson.JSONObject;
import com.shiku.im.api.AbstractController;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.constants.KConstants.ResultCode;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.common.service.PaymentManager;
import com.shiku.im.friends.entity.Friends;
import com.shiku.im.friends.service.impl.FriendsManagerImpl;
import com.shiku.im.api.service.AuthServiceUtils;
import com.shiku.im.sms.SMSServiceImpl;
import com.shiku.im.user.entity.AuthKeys;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.model.KeyPairParam;
import com.shiku.im.user.service.UserRedisService;
import com.shiku.im.user.service.impl.AuthKeysServiceImpl;
import com.shiku.im.user.service.impl.UserManagerImpl;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.Base64;
import com.shiku.utils.StringUtil;
import com.shiku.utils.encrypt.RSA;
import io.swagger.annotations.*;
import org.apache.commons.lang3.RandomUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

/**
 *
 * 用户授权数据相关接口 
 *
 */

@Api(value="AuthKeysController",tags="用户授权数据相关接口 ")
@RestController
@RequestMapping(value="",method={RequestMethod.GET,RequestMethod.POST})
public class AuthKeysController extends AbstractController {

	//支付密码未设置
	static final int PayPasswordNotExist = 104002;

	//支付密码错误
	static final int PayPasswordIsWrong = 104003;

	@Autowired
	private AuthKeysServiceImpl authKeysService;

	@Autowired
	private UserManagerImpl userManager;

	@Autowired
	private FriendsManagerImpl friendsManager;

	@Autowired
	private UserRedisService userRedisService;

	@Autowired(required = false)
	private PaymentManager paymentManager;

	@Autowired
	private SMSServiceImpl smsService;

	@Autowired
	private AuthServiceUtils authServiceUtils;
	/*@Autowired
	private AuthServiceOldUtils authServiceOldUtils;*/



	@RequestMapping(value = "/authkeys/getPayPrivateKey")
	@ApiOperation(value = "获取用户支付私钥",notes = "只能本人能调用")
	public JSONMessage getPayPrivateKey() {
		try {
			Integer userId = ReqUtil.getUserId();
			String privateKey = authKeysService.getPayPrivateKey(userId);
			if(StringUtil.isEmpty(privateKey))
				return JSONMessage.success();
			JSONObject jsonObject=new JSONObject();
			jsonObject.put("privateKey",privateKey);
			return JSONMessage.success(jsonObject);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		} catch(Exception e) {
			e.printStackTrace();
			return JSONMessage.failureByException(e);
		}
	}

	@ApiOperation(value = "查询是否支持消息加密",notes = "只能本人能调用")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="areaCode" , value="区号",dataType="String",required=true,defaultValue = "86"),
			@ApiImplicitParam(paramType="query" , name="telephone" , value="手机号",dataType="String",required=true)
	})
	@RequestMapping(value = "/authkeys/isSupportSecureChat")
	public JSONMessage isSupportSecureChat(@RequestParam(defaultValue ="86") String areaCode,@RequestParam String telephone) {
		Map<String,Object> result = new HashMap<>();
		try {
			User user = userManager.getUser(areaCode+telephone);
			if(user==null) {
				return JSONMessage.failureByErrCode(ResultCode.UserNotExist);
			}
			//根据用户是否存在dh公钥，返回给客户端是否支持消息加密
			AuthKeys authKeys = authKeysService.getAuthKeys(user.getUserId());
			result.put("isSupportSecureChat",(authKeys!=null && authKeys.getMsgDHKeyPair()!=null)?1:0);
			return JSONMessage.success(result);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}


	/**
	 * 获取某个用户的历史DH 公钥列表
	 * @param userId
	 * @return
	 */
	@ApiOperation(value = "获取某个用户的历史DH 公钥列表")
	@ApiImplicitParam(paramType="query" , name="userId" , value="用户Id",dataType="int",required=true,defaultValue = "0")
	@RequestMapping(value = "/authkeys/getDHMsgKeyList")
	public JSONMessage getDHMsgKeyList(@RequestParam(defaultValue ="0")int userId) {
		try {
			List<AuthKeys.PublicKey> publicKeyList;
			Integer loginId = ReqUtil.getUserId();
			if(0==userId) {
				publicKeyList = authKeysService.queryMsgDHPublicKeyList(loginId);
				Map<String,Object> result=new HashMap<>();
				result.put("userId",userId);
				result.put("publicKeyList",publicKeyList);
				return JSONMessage.success(result);
			}
			Friends friends = friendsManager.getFriends(loginId, userId);
			if(null==friends)
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			 publicKeyList = authKeysService.queryMsgDHPublicKeyList(userId);
			 Map<String,Object> result=new HashMap<>();
			 result.put("userId",userId);
			 result.put("publicKeyList",publicKeyList);
			return JSONMessage.success(result);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		} catch(Exception e) {
			e.printStackTrace();
			return JSONMessage.failureByException(e);
		}
	}
	@ApiOperation(value = "上传用户RSA消息公私钥 废弃")
	@RequestMapping(value = "/authkeys/uploadMsgKey")
	public JSONMessage uploadMsgKey(KeyPairParam param) {
		try {
			if(StringUtil.isEmpty(param.getRsaPrivateKey())) {
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			}
			Integer userId = ReqUtil.getUserId();


			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		} catch(Exception e) {
			e.printStackTrace();
			return JSONMessage.failureByException(e);
		}
	}
	@ApiOperation("上传用户DH消息公私钥")
	@RequestMapping(value = "/authkeys/uploadDhMsgKey")
	public JSONMessage uploadDHMsgKey(KeyPairParam param) {
		try {
			if(StringUtil.isEmpty(param.getDhPrivateKey())) {
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			}
			Integer userId = ReqUtil.getUserId();
			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		} catch(Exception e) {
			e.printStackTrace();
			return JSONMessage.failureByException(e);
		}
	}

	@ApiOperation("上传用户RSA消息公私钥 ")
	@RequestMapping(value = "/authkeys/uploadRsaMsgKey")
	public JSONMessage uploadMsgRSAKey(@ModelAttribute @ApiParam KeyPairParam param) {
		try {
			if(StringUtil.isEmpty(param.getRsaPrivateKey())) {
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			}
			Integer userId = ReqUtil.getUserId();


			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		} catch(Exception e) {
			e.printStackTrace();
			return JSONMessage.failureByException(e);
		}
	}
	@ApiOperation(value = "上传用户支付公私钥")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="publicKey" , value="支付公钥",dataType="String",required=true,defaultValue = ""),
		@ApiImplicitParam(paramType="query" , name="privateKey" , value="支付私钥",dataType="String",required=true,defaultValue = ""),
		@ApiImplicitParam(paramType="query" , name="mac" , value="mac值验签",dataType="String",required=true,defaultValue = ""),
	})
	@RequestMapping(value = "/authkeys/uploadPayKey")
	public JSONMessage uploadPayKey(@RequestParam(defaultValue ="") String publicKey,@RequestParam(defaultValue ="")String privateKey
			,@RequestParam(defaultValue ="")String mac) {
		try {
			if(StringUtil.isEmpty(privateKey)||StringUtil.isEmpty(publicKey)||StringUtil.isEmpty(mac)) {
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			}
			int userId=ReqUtil.getUserId();
			String payPwd =authKeysService.getPayPassword(userId);
			if(StringUtil.isEmpty(payPwd))
				return JSONMessage.failureByErrCode(PayPasswordNotExist);
			if(!authServiceUtils.checkUserUploadPayKeySign(privateKey, publicKey, mac,payPwd))
				return JSONMessage.failureByErrCode(ResultCode.AUTH_FAILED);
			authKeysService.uploadPayKey(userId, publicKey, privateKey);
			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		} catch(Exception e) {
			return JSONMessage.failureByException(e);
		}
	}
	
	/**
	*获取交易 随机码
	* @return
	**/
	@ApiOperation(value = "获取支付Code ",notes = "支付相关接口的第一步")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="salt" , value="盐值",dataType="String",required=true,defaultValue = ""),
		@ApiImplicitParam(paramType="query" , name="mac" , value="mac值验签",dataType="String",required=true,defaultValue = ""),
	})
	@RequestMapping(value = "/transaction/getCode")
	public JSONMessage transactionGetCode(@RequestParam(defaultValue ="")String mac,
			@RequestParam(defaultValue ="")String salt) {
		if (paymentManager == null){
			 return JSONMessage.failureByErrCode(ResultCode.CLOSEPAY);
		}
		int userId=ReqUtil.getUserId();

		 String payPassword =authKeysService.getPayPassword(userId);
		 if(StringUtil.isEmpty(payPassword))
			 return JSONMessage.failureByErrCode(PayPasswordNotExist);
		if(!authServiceUtils.authTransactiongetCode(userId+"", getAccess_token(), salt, mac, payPassword))
			return JSONMessage.failureByErrCode(PayPasswordIsWrong);
		String publicKey=authKeysService.getPayPublicKey(userId);
		if(StringUtil.isEmpty(publicKey)) {
			return JSONMessage.success();
		}
		try {
			byte[] codeArr=new byte[16];
			Random rom =new Random();
			rom.nextBytes(codeArr);
			byte[] key = RSA.encrypt(codeArr,Base64.decode(publicKey));
			
			String code=Base64.encode(codeArr);
			String codeId=StringUtil.randomUUID();

			paymentManager.saveTransactionSignCode(userId, codeId,code);
			Map<String,String> map=new HashMap<String,String>();
			
			map.put("code",Base64.encode(key));
			map.put("codeId",codeId);
			/*logger.info("server code ====》 {}",code);
			logger.info("codeArr ====》 {}",Base64.encode(codeArr));
			logger.info("publicKey ====》 {}",publicKey);
			logger.info("code ====》 {}",Base64.encode(key));
			logger.info("data  ---> {}",map);*/
			return JSONMessage.success(map);
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}

	@ApiOperation(value = "上传用户登陆公私钥")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="publicKey" , value="公钥",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="privateKey" , value="私钥",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="mac" , value="mac 验签值",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="salt" , value="盐值",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="userId" , value="用户Id",dataType="int",required=true)
	})
	@RequestMapping(value = "/authkeys/uploadLoginKey")
	public JSONMessage uploadLoginKey(@RequestParam(defaultValue ="") String publicKey,@RequestParam(defaultValue ="")String privateKey
			,@RequestParam(defaultValue ="")String mac,@RequestParam(defaultValue ="") int userId,@RequestParam(defaultValue ="") String salt) {
		try {
			if(StringUtil.isEmpty(privateKey)||StringUtil.isEmpty(publicKey)||StringUtil.isEmpty(mac)) {
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			}
			User user = userManager.getUser(userId);
			if(null==user)
				return JSONMessage.failureByErrCode(ResultCode.AccountNotExist);
			String password =authKeysService.queryLoginPassword(userId);
			if(StringUtil.isEmpty(password)&&!StringUtil.isEmpty(user.getPassword())){
				userManager.resetPassword(userId,user.getPassword());
				password=user.getPassword();
			}
			if(!authServiceUtils.authUploadLoginKeyPair(userId+"",publicKey,privateKey,salt,mac,password))
				return JSONMessage.failureByErrCode(ResultCode.AUTH_FAILED);
			authKeysService.uploadLoginKeyPair(userId, publicKey, privateKey);
			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		} catch(Exception e) {
			e.printStackTrace();
			return JSONMessage.failureByException(e);
		}
	}

	/**
	 *获取登陆 随机码
	 * @return
	 **/
	@ApiOperation(value = "获取登陆 随机码",notes ="密码登陆的第一步")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="areaCode" , value="手机区号",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="account" , value="手机号 或者 通讯号",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="mac" , value="mac 验签值",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="salt" , value="盐值",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="deviceId" , value="设备类型 android ios 等",dataType="int",required=true),
	})
	@RequestMapping(value = "/auth/getLoginCode")
	public JSONMessage getLoginCode(@RequestParam(defaultValue ="")String areaCode,@RequestParam(defaultValue ="")String account,@RequestParam(defaultValue ="")String mac,
										  @RequestParam(defaultValue ="")String salt,@RequestParam(defaultValue ="")String deviceId) {
		if(!KConstants.DeviceKey.RESOURCES.contains(deviceId))
			return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
		User user = userManager.getUser(areaCode+account);
		if(null==user)
			user=userManager.getUserByAccount(account);
		if(null==user)
			return JSONMessage.failureByErrCode(ResultCode.AccountNotExist);
		int userId=user.getUserId();
		Map<String,String> map=new HashMap<String,String>();
		String password =authKeysService.queryLoginPassword(userId);
		if(StringUtil.isEmpty(password)&&!StringUtil.isEmpty(user.getPassword())){

			userManager.resetPassword(userId,user.getPassword());
			password=user.getPassword();
		}
		if(!authServiceUtils.authLogingetCode(areaCode+account, salt, mac,password,userId)){

			return JSONMessage.failureByErrCode(ResultCode.AccountOrPasswordIncorrect);
		}

		map.put("userId",userId+"");
		String publicKey=authKeysService.getLoginPublicKey(userId);
		if(StringUtil.isEmpty(publicKey)) {
			return JSONMessage.success(map);
		}
		try {
			byte[] codeArr=RandomUtils.nextBytes(16);

			byte[] key = RSA.encrypt(codeArr,Base64.decode(publicKey));

			String code=Base64.encode(codeArr);

			userRedisService.saveLoginCode(userId, deviceId,code);
			map.put("code",Base64.encode(key));
			/*logger.info("server code ====》 {}",code);
			logger.info("codeArr ====》 {}",code);
			logger.info("publicKey ====》 {}",publicKey);
			logger.info("code ====》 {}",Base64.encode(key));
			logger.info("data  ---> {}",map);*/
			return JSONMessage.success(map);
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}
	@ApiOperation(value = "获取登陆私钥")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="userId" , value="用户ID",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="mac" , value="mac 验签值",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="salt" , value="盐值",dataType="String",required=true),
	})
	@RequestMapping(value = "/authkeys/getLoginPrivateKey")
	public JSONMessage getLoginPrivateKey(@RequestParam(defaultValue ="0")int userId,@RequestParam(defaultValue ="")String mac,
										  @RequestParam(defaultValue ="")String salt) {
		try {
			User user = userManager.getUser(userId);
			if(null==user)
				return JSONMessage.failureByErrCode(ResultCode.AccountNotExist);
			String privateKey=authKeysService.getLoginPrivateKey(userId);
			if(StringUtil.isEmpty(privateKey)) {
				return JSONMessage.success();
			}
			String password =authKeysService.queryLoginPassword(userId);
			if(!authServiceUtils.authLogingetCode(userId+"", salt, mac, password,userId))
				return JSONMessage.failureByErrCode(ResultCode.AccountOrPasswordIncorrect);

			JSONObject jsonObject=new JSONObject();
			jsonObject.put("privateKey",privateKey);
			return JSONMessage.success(jsonObject);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		} catch(Exception e) {
			e.printStackTrace();
			return JSONMessage.failureByException(e);
		}
	}

	@ApiOperation(value = "忘记支付密码",notes = "找回支付密码")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="userId" , value="用户ID",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="mac" , value="mac 验签值",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="salt" , value="盐值",dataType="String",required=true),
	})
	@RequestMapping(value = "/authkeys/resetPayPassword")
	public JSONMessage resetPayPassword(@RequestParam(defaultValue="") String mac,@RequestParam(defaultValue="") String salt) {
		if (paymentManager == null){
			 return JSONMessage.failureByErrCode(ResultCode.CLOSEPAY);
		}
		try {
			if(StringUtil.isEmpty(mac)||StringUtil.isEmpty(salt)) {
				return JSONMessage.failureByErrCode(ResultCode.ParamsAuthFail);
			}
			int userId=ReqUtil.getUserId();
            User user = userManager.getUser(userId);
            String smsCode = smsService.getSmsCode(user.getTelephone());
            if(!authServiceUtils.checkResetPayPassWordSign(userId,getAccess_token(),mac,salt,smsCode))
				return JSONMessage.failureByErrCode(ResultCode.VerifyCodeErrOrExpired);
			authKeysService.updatePayPassword(userId, "");
			userManager.updatePayPassword(userId,"");
			authKeysService.deletePayKey(userId);
			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		} catch(Exception e) {
			return JSONMessage.failureByException(e);
		}
	}
	
}
