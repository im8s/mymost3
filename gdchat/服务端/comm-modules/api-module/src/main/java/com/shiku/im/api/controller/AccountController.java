package com.shiku.im.api.controller;

import cn.hutool.core.collection.CollectionUtil;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.shiku.im.admin.service.impl.WhiteLoginListRepository;
import com.shiku.im.api.AbstractController;
import com.shiku.im.api.utils.IpLocationUtil;
import com.shiku.im.utils.IPUtil;
import com.shiku.im.api.utils.NetworkUtil;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.api.service.AuthServiceUtils;
import com.shiku.im.sms.SMSServiceImpl;
import com.shiku.im.user.dao.UserDao;
import com.shiku.im.user.entity.AuthKeys;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.model.*;
import com.shiku.im.user.service.UserRedisService;
import com.shiku.im.user.service.impl.AuthKeysServiceImpl;
import com.shiku.im.user.service.impl.UserManagerImpl;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.Base64;
import com.shiku.utils.StringUtil;
import com.shiku.utils.encrypt.AES;
import com.shiku.utils.encrypt.MD5;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * UserController  中方法太多了比较乱
 * 将 用户 账号 登陆 注册 第三方 账号 相关操作 抽取处理
 */

@RestController
@Api(value="AccountController",tags="用户账号登陆注册相关操作  新接口")
@RequestMapping(value="",method={RequestMethod.GET,RequestMethod.POST})
public class AccountController extends AbstractController {


    @Autowired
    private AuthKeysServiceImpl authKeysService;
    @Autowired
    private UserDao userDao;

    @Autowired
    private SMSServiceImpl smsService;
    
    @Autowired
    UserRedisService userRedisService;
    
    @Autowired
    private UserManagerImpl userManager;

    @Autowired
    private AuthServiceUtils authServiceUtils;

    @Autowired
    private WhiteLoginListRepository whiteLoginListRepository;


    @ApiOperation(value = "用户注册V1 新接口")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType="query" , name="deviceId" , value="设备类型 android ios",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="data" , value="加密数据",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="salt" , value="颜值",dataType="String",required=true),
    })
    @RequestMapping(value = "/user/register/v1")
    public JSONMessage registerV1(@RequestParam(defaultValue = "") String deviceId,@RequestParam String data, @RequestParam String salt,HttpServletRequest request) {
        UserExample example;
        try {

            JSONObject jsonObject = authServiceUtils.authApiKeyCheckSign(data, salt);
            if(null==jsonObject)
                return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
            example=jsonObject.toJavaObject(UserExample.class);
            if(null==example)
                return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
            // 校验短信验证码
            if(null != jsonObject.get("smsCode")&&!StringUtil.isEmpty(jsonObject.getString("smsCode"))){
                if(!smsService.isAvailable(String.valueOf(jsonObject.get("areaCode"))+String.valueOf(jsonObject.get("telephone")),String.valueOf(jsonObject.get("smsCode"))))
                    throw new ServiceException(KConstants.ResultCode.VerifyCodeErrOrExpired);
            }
            KeyPairParam param=jsonObject.toJavaObject(KeyPairParam.class);

            example.setDeviceType( getDeviceType(request.getHeader("User-Agent")));
            example.setDeviceId(deviceId);
            example.setPhone(example.getTelephone());
           /* if(!AuthServiceUtils.checkUserUploadMsgKeySign(param.getMac(), example.getTelephone(), example.getPassword()))
                return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);*/
            example.setTelephone(example.getAreaCode() + example.getTelephone());
            Map<String,Object> result = userManager.registerIMUser(example);
           
            authKeysService.uploadMsgKey(example.getUserId(),param);
			authKeysService.updateLoginPassword(example.getUserId(),example.getPassword());

            String jsonRsult= JSONObject.toJSONString(result);
            jsonRsult= AES.encryptBase64(jsonRsult, MD5.encrypt(authServiceUtils.getApiKey()));
            Map<String, Object> dataMap=new HashMap<>();
            dataMap.put("data",jsonRsult);
            return JSONMessage.success(null, dataMap);
        } catch (Exception e) {
            return JSONMessage.failureByException(e);
        }
    }


    @ApiOperation(value = "用户微信注册V1 新接口")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType="query" , name="data" , value="加密数据",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="salt" , value="颜值",dataType="String",required=true)
    })
    @RequestMapping(value = "/user/registerSDK/v1")
    public JSONMessage registerSDKV1(@RequestParam String data, @RequestParam String salt) {
        try {
            UserExample example;
            JSONObject jsonObject = authServiceUtils.authApiKeyCheckSign(data, salt);
            if(null==jsonObject)
                return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
            example=jsonObject.toJavaObject(UserExample.class);
            if(null==example)
                return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
            
            KeyPairParam param=jsonObject.toJavaObject(KeyPairParam.class);
            //example.setTelephone(example.getAccount());
            example.setPhone(example.getTelephone());
            example.setTelephone(example.getAreaCode() + example.getTelephone());
            example.setAccount(jsonObject.getString("loginInfo"));
            example.setLoginType(jsonObject.getIntValue("type"));
            if(0==example.getLoginType()){
                return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
            }
            Map<String,Object> result= userManager.registerIMUserBySdk(example, example.getLoginType());
            
            authKeysService.uploadMsgKey(example.getUserId(),param);
            authKeysService.updateLoginPassword(example.getUserId(),example.getPassword());
            
            String jsonRsult= JSONObject.toJSONString(result);
            jsonRsult= AES.encryptBase64(jsonRsult, MD5.encrypt(authServiceUtils.getApiKey()));
            Map<String, Object> dataMap=new HashMap<>();
            dataMap.put("data",jsonRsult);
            return JSONMessage.success(null, dataMap);
        } catch (Exception e) {
           return JSONMessage.failureByException(e);
        }

    }

    @ApiOperation(value = "用户微信绑定手机号 新接口")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType="query" , name="data" , value="加密数据",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="salt" , value="颜值",dataType="String",required=true)
    })
    @RequestMapping(value = "/user/bindingTelephone/v1")
    public JSONMessage bindingTelephoneV1(HttpServletRequest request, @ModelAttribute LoginExample example, @RequestParam(defaultValue ="") String data, @RequestParam(defaultValue ="") String salt){
        try {
            example.setDeviceType(getDeviceType(request.getHeader("User-Agent")));
            User user=userManager.getUser(example.getUserId());
            // 账号不存在
            if(null==user)
                return JSONMessage.failureByErrCode(KConstants.ResultCode.SdkLoginNotExist);
            String code = userRedisService.queryLoginSignCode(user.getUserId(), example.getDeviceId());

            if(StringUtil.isEmpty(code))
                return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
            userRedisService.cleanLoginCode(example.getUserId(),example.getDeviceId());
            byte[] deCode= Base64.decode(code);


            JSONObject jsonParam = authServiceUtils.authUserLoginCheck(example.getUserId(), data, salt, user.getPassword(), deCode);
            if(null==jsonParam)
                return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
            LoginExample jsonExample=jsonParam.toJavaObject(LoginExample.class);
            if(null==jsonExample)
                return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
            jsonExample.copySignExample(example);
            jsonExample.setLoginType(jsonParam.getIntValue("type"));
            if(0==jsonExample.getLoginType()){
                return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
            }
            String loginOpenId=jsonParam.getString("loginInfo");
            SdkLoginInfo sdkLoginInfo = userManager.findSdkLoginInfo(jsonExample.getLoginType(),loginOpenId);
            if (null!=sdkLoginInfo)
                return JSONMessage.failureByErrCode(KConstants.ResultCode.ThirdPartyAlreadyBound);
                userManager.addSdkLoginInfo(jsonExample.getLoginType(), user.getUserId(), jsonParam.getString("loginInfo"));
            jsonExample.setIsSdkLogin(1);
            Map<String,Object> result = userManager.loginV1(jsonExample);
            String jsonRsult=JSONObject.toJSONString(result);
            jsonRsult=AES.encryptBase64(jsonRsult,deCode);
            Map<String, Object> dataMap=new HashMap<>();
            dataMap.put("data",jsonRsult);
            return JSONMessage.success(null, dataMap);
        } catch (Exception e) {
            return JSONMessage.failureByException(e);
        }

    }



    @ApiOperation(value = "绑定微信账号 新接口")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType="query" , name="loginInfo" , value="微信openId",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="data" , value="加密数据",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="salt" , value="颜值",dataType="String",required=true)
    })
    @RequestMapping(value = "/user/bindWxAccount")
    public JSONMessage bindWxAccount(@ModelAttribute LoginExample example,@RequestParam(defaultValue ="") String data, @RequestParam(defaultValue ="") String salt
            ,@RequestParam(defaultValue ="") String loginInfo,@RequestParam(defaultValue ="2") int type){
        try {
            Integer userId = ReqUtil.getUserId();
            User user=userManager.getUser(userId);
            // 账号不存在
            if(null==user)
                return JSONMessage.failureByErrCode(KConstants.ResultCode.SdkLoginNotExist);
            if(0==type){
                return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
            }
            example.setUserId(userId);
            String code = userRedisService.queryLoginSignCode(user.getUserId(), example.getDeviceId());

            SdkLoginInfo sdkLoginInfo = userManager.findSdkLoginInfo(type,loginInfo);
            if (null!=sdkLoginInfo){
                return JSONMessage.failureByErrCode(KConstants.ResultCode.ThirdPartyAlreadyBound);
            }
                userManager.addSdkLoginInfo(type, user.getUserId(), loginInfo);

          return JSONMessage.success();
        } catch (Exception e) {
            return JSONMessage.failureByException(e);
        }

    }
    @ApiOperation(value = "用户微信注册V1 新接口")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType="query" , name="loginInfo" , value="微信openId",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="data" , value="加密数据",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="salt" , value="颜值",dataType="String",required=true)
    })
    @RequestMapping(value = "/user/sdkLogin/v1")
    public JSONMessage sdkLoginV1(HttpServletRequest request,@ModelAttribute LoginExample example,@RequestParam String data,@RequestParam String salt){
        example.setDeviceType(getDeviceType(request.getHeader("User-Agent")));
        JSONObject jsonParam=authServiceUtils.decodeApiKeyDataJson(data);
        jsonParam=authServiceUtils.authWxLoginCheck(jsonParam, data, salt);

        if(null==jsonParam)
                return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
        LoginExample jsonExample=jsonParam.toJavaObject(LoginExample.class);
        if(null==jsonExample)
            return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
        jsonExample.copySignExample(example);
        jsonExample.setAccount(jsonParam.getString("loginInfo"));
        jsonExample.setLoginType(jsonParam.getIntValue("type"));
        if(0==jsonExample.getLoginType()){
            return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
        }
       SdkLoginInfo sdkLoginInfo=userManager.findSdkLoginInfo(jsonExample.getLoginType(), jsonExample.getAccount());
        // 未绑定手机号码
        if(null==sdkLoginInfo)
            return JSONMessage.failureByErrCode(KConstants.ResultCode.UNBindingTelephone);
        User user=userDao.get(sdkLoginInfo.getUserId());
        if(null == user){
            return JSONMessage.failureByErrCode(KConstants.ResultCode.UserNotExist);
        }
        jsonExample.setPassword(user.getPassword());
        jsonExample.setUserId(user.getUserId());
        jsonExample.setIsSdkLogin(1);

        Map<String,Object> result = userManager.loginV1(jsonExample);
        if(null!=result){
            AuthKeys authKeys = authKeysService.getAuthKeys(jsonExample.getUserId());
            if(null!=authKeys&&null!=authKeys.getMsgDHKeyPair()&&!StringUtil.isEmpty(authKeys.getMsgDHKeyPair().getPrivateKey())){
                result.put("isSupportSecureChat",1);
            }
        }
        String jsonRsult=JSONObject.toJSONString(result);
        jsonRsult=AES.encryptBase64(jsonRsult,MD5.encrypt(authServiceUtils.getApiKey()));
        Map<String, Object> dataMap=new HashMap<>();
        dataMap.put("data",jsonRsult);
        return JSONMessage.success(null, dataMap);

    }

    @ApiOperation(value = "用户短信登陆 新接口")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType="query" , name="data" , value="加密数据",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="salt" , value="颜值",dataType="String",required=true)
    })
    @RequestMapping(value = "/user/smsLogin")
    public JSONMessage smsLogin(HttpServletRequest request, @ModelAttribute LoginExample example,@RequestParam(defaultValue ="") String data,@RequestParam(defaultValue ="") String salt) {
        try {
			/*if(null == example.getVerificationCode())
				return JSONMessage.failureByErrCode(KConstants.ResultCode.SMSCanNotEmpty);*/
            //PC登录验证白名单ip
            if (interceptPcLoginWhiteList(NetworkUtil.getIpAddress(request), example.getDeviceId())) return JSONMessage.failure("您的网络条件暂不支持登录pc端");

            example.setDeviceType(getDeviceType(request.getHeader("User-Agent")));
            example.setTelephone(example.getAreaCode()+example.getAccount());
            String smsCode = smsService.getSmsCode(example.getTelephone());
            if(StringUtil.isEmpty(smsCode)){
                return JSONMessage.failureByErrCode(KConstants.ResultCode.VerifyCodeErrOrExpired);
            }
            byte[] decode = MD5.encrypt(smsCode);
            JSONObject jsonParam = authServiceUtils.authSmsLoginCheck(example.getTelephone(),decode,data,salt);
            if(null==jsonParam)
                return JSONMessage.failureByErrCode(KConstants.ResultCode.VerifyCodeErrOrExpired);
            LoginExample jsonExample=jsonParam.toJavaObject(LoginExample.class);
            if(null==jsonExample)
                return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
           jsonExample.copySignExample(example);

            Map<String,Object> result = userManager.smsLogin(jsonExample);
            String jsonRsult=JSONObject.toJSONString(result);
            jsonRsult=AES.encryptBase64(jsonRsult,decode);
            Map<String, Object> dataMap=new HashMap<>();
            dataMap.put("data",jsonRsult);
            return JSONMessage.success(null, dataMap);
        } catch (ServiceException e) {
            return JSONMessage.failureByException(e);
        }
    }

    private boolean interceptPcLoginWhiteList(String realIp, String deviceId) {
        if (KConstants.DeviceKey.PC.equals(deviceId)) {
            logger.info("PC端登录ip:{}", realIp);
            List<String> ips = whiteLoginListRepository.getLoginWhitelist().get(0);
            if (CollectionUtil.isNotEmpty(ips) && !IPUtil.hitIp(realIp, ips)) {
                return true;
            }
        }
        return false;
    }

    @ApiOperation(value = "用户密码登陆 新接口")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType="query" , name="data" , value="加密数据",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="salt" , value="颜值",dataType="String",required=true)
    })
    @RequestMapping(value = "/user/login/v1")
    public JSONMessage loginV1(HttpServletRequest request, @ModelAttribute LoginExample example,@RequestParam(defaultValue ="") String data,@RequestParam(defaultValue ="") String salt) {
        try {
            //PC登录验证白名单ip
            if (interceptPcLoginWhiteList(NetworkUtil.getIpAddress(request), example.getDeviceId())) return JSONMessage.failure("您的网络条件暂不支持登录pc端");

            example.setDeviceType(getDeviceType(request.getHeader("User-Agent")));
            example.setIp(NetworkUtil.getIpAddress(request));
            example.setIpLocation(IpLocationUtil.getIpLocation(example.getIp()));
            logger.info("登录获取ip:{} location:{}", example.getIp(), example.getIpLocation());
            User user = userManager.getUser(example.getUserId());
            String code = userRedisService.queryLoginSignCode(user.getUserId(), example.getDeviceId());

            if(StringUtil.isEmpty(code))
                return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
            userRedisService.cleanLoginCode(example.getUserId(),example.getDeviceId());
            byte[] deCode= Base64.decode(code);
            String password = authKeysService.queryLoginPassword(example.getUserId());
            JSONObject jsonParam =authServiceUtils.authUserLoginCheck(example.getUserId(),data,salt,password,deCode);
            if(null==jsonParam)
                return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
            LoginExample jsonExample=jsonParam.toJavaObject(LoginExample.class);
            if(null==jsonExample)
                return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
            jsonExample.copySignExample(example);
            Map<String, Object> result = userManager.loginV1(jsonExample);
            String jsonRsult=JSONObject.toJSONString(result);
            jsonRsult=AES.encryptBase64(jsonRsult,deCode);
            Map<String, Object> dataMap=new HashMap<>();
            dataMap.put("data",jsonRsult);
            return JSONMessage.success(null, dataMap);
        } catch (ServiceException e) {
            return JSONMessage.failureByException(e);
        }
    }

    @ApiOperation(value = "用户自动登陆 新接口")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType="query" , name="data" , value="加密数据",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="salt" , value="颜值",dataType="String",required=true)
    })
    @RequestMapping(value = "/user/login/auto/v1")
    public JSONMessage loginAutoV1(HttpServletRequest request, @ModelAttribute LoginExample example,@RequestParam(defaultValue ="") String data,
                                   @RequestParam(defaultValue ="") String loginToken,@RequestParam(defaultValue ="") String salt) {
        try {
            UserLoginTokenKey loginTokenKey = userRedisService.queryLoginTokenKeys(loginToken);
            if(null==loginTokenKey){
                return JSONMessage.failureByErrCode(KConstants.ResultCode.LoginTokenInvalid);
            }
            example.setUserId(loginTokenKey.getUserId());
            example.setDeviceId(loginTokenKey.getDeviceId());
            example.setIp(NetworkUtil.getIpAddress(request));
            example.setIpLocation(IpLocationUtil.getIpLocation(example.getIp()));
            logger.info("自动登录获取ip:{} location:{}", example.getIp(), example.getIpLocation());
            //PC登录验证白名单ip
            if (interceptPcLoginWhiteList(NetworkUtil.getIpAddress(request), example.getDeviceId())) return JSONMessage.failure("您的网络条件暂不支持登录pc端");

            JSONObject jsonParam = authServiceUtils.authUserAutoLoginCheck(example.getUserId(), loginToken, loginTokenKey.getLoginKey(), salt, data);
            if(null==jsonParam)
                    return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
            LoginExample jsonExample=jsonParam.toJavaObject(LoginExample.class);
            if(null==jsonExample)
                return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
            jsonExample.copySignExample(example);
            Object result = userManager.loginAutoV1(jsonExample,loginTokenKey,null);
            String jsonRsult=JSONObject.toJSONString(result);
            jsonRsult=AES.encryptBase64(jsonRsult,Base64.decode(loginTokenKey.getLoginKey()));
            Map<String, Object> dataMap=new HashMap<>();
            dataMap.put("data",jsonRsult);
            return JSONMessage.success(null, dataMap);
        } catch (ServiceException e) {
            return JSONMessage.failureByException(e);
        }
    }





    /**
     * 解除绑定
     * @param type
     * @return
     */
    @ApiOperation("解除绑定微信")
    @ApiImplicitParam(paramType="query" , name="type",value="类型",dataType="int")
    @RequestMapping(value = "/user/unbind")
    public JSONMessage unbind(@RequestParam(defaultValue="2") int type){
        if(0==type){
            return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
        }
         userManager.unbind(type, ReqUtil.getUserId());
        return JSONMessage.success();
    }

    /**
     * 获取用户绑定信息
     * @return
     */

    @ApiOperation("获取用户微信绑定信息")
    @RequestMapping(value="/user/getBindInfo")
    public JSONMessage getBingInfo(){
        Object data = userManager.getBindInfo(ReqUtil.getUserId());
        return JSONMessage.success(data);
    }

    /**
     * 获取微信 openid
     * @param code
     * @return
     */
    @ApiOperation("获取微信 openid")
    @ApiImplicitParam(paramType="query" , name="code",value="标识码",dataType="String")
    @RequestMapping(value ="/user/getWxOpenId")
    public JSONMessage getWxOpenId(@RequestParam String code){
        Object data=userManager.getWxOpenId(code);
        if(data!=null){
            return JSONMessage.success(data);
        }else{
            return JSONMessage.failureByErrCode(KConstants.ResultCode.GetOpenIdFailure);
        }

    }
}
