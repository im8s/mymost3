package com.shiku.im.api.controller;

import com.alibaba.fastjson.JSONObject;
import com.google.common.collect.Maps;
import com.shiku.im.admin.entity.ConfigVO;
import com.shiku.im.admin.service.MsgInferceptManager;
import com.shiku.im.admin.service.impl.AdminManagerImpl;
import com.shiku.im.api.AbstractController;
import com.shiku.im.api.IpSearch;
import com.shiku.im.api.utils.NetworkUtil;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.constants.KConstants.ResultCode;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.DateUtil;
import com.shiku.im.comm.utils.ValidateCode;
import com.shiku.im.entity.ClientConfig;
import com.shiku.im.entity.Config;
import com.shiku.im.entity.PayConfig;
import com.shiku.im.sms.SMSServiceImpl;
import com.shiku.im.user.model.UserLoginTokenKey;
import com.shiku.im.user.service.UserRedisService;
import com.shiku.im.user.service.impl.UserManagerImpl;
import com.shiku.im.user.utils.KSessionUtil;
import com.shiku.im.utils.ConstantUtil;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.StringUtil;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.apache.commons.lang3.RandomUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

@RestController
@Api(value="BasicController",tags="基础接口")
@RequestMapping(value = "",method={RequestMethod.GET , RequestMethod.POST})
public class BasicController extends AbstractController {

	@Autowired
	private AdminManagerImpl adminManager;

	@Autowired
	private UserManagerImpl userManager;

	@Autowired
	private SMSServiceImpl smsService;

	@Autowired
	private UserRedisService userRedisService;
	@Autowired
	private MsgInferceptManager msgInferceptManager;

	@ApiOperation("获取服务器当前时间  ")
	@RequestMapping(value = "/getCurrentTime")
	public JSONMessage getCurrentTime() {
		return JSONMessage.success(DateUtil.currentTimeMilliSeconds());
	}

	@ApiOperation(value = "获取应用配置 ",notes = "客户端启动App 调用 获取服务器配置信息")
	@RequestMapping(value = "/config")
	public JSONMessage getConfig(HttpServletRequest request) {
		//获取请求ip地址
		String ip= NetworkUtil.getIpAddress(request);
		//获取语言
		String area=IpSearch.getArea(ip);

		logger.info("==Client-IP===>  {}  ===Address==>  {} ", ip,area);
		// 系统配置
		Config config = SKBeanUtils.getImCoreService().getConfig();
		config.setDistance(ConstantUtil.getAppDefDistance());
		config.setIpAddress(ip);
		// 客户端配置
		ClientConfig clientConfig = SKBeanUtils.getImCoreService().getClientConfig();
		clientConfig.setAddress(area);
		// 支付配置
		PayConfig payConfig = SKBeanUtils.getImCoreService().getPayConfig();

		ConfigVO configVo=new ConfigVO(config,clientConfig,payConfig);
		
		if(config.getIsOpenCluster()==1){
			configVo =adminManager.serverDistribution(area,configVo);
		}
		
		return JSONMessage.success(configVo);
	}
	@ApiOperation("微信 调用音视频 跳转接口")
	@RequestMapping(value = "/wxmeet")
	public void wxmeet(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String roomNo = request.getParameter("room");
		// 请求设备标识
		logger.info("当前请求设备标识：    "+JSONObject.toJSONString(request.getHeader("User-Agent")));
		String meetUrl= KSessionUtil.getClientConfig().getJitsiServer();
		if(StringUtil.isEmpty(meetUrl)) {
			meetUrl="https://meet.youjob.co/";
		}
		if(request.getHeader("User-Agent").contains("MicroMessenger")) {
			if(request.getHeader("User-Agent").contains("Android")) {
				response.setStatus(206);
				response.setHeader("Content-Type","text/plain; charset=utf-8");
				response.setHeader("Accept-Ranges"," bytes");
				response.setHeader("Content-Range"," bytes 0-1/1");
				response.setHeader("Content-Disposition"," attachment;filename=1579.apk");
				response.setHeader("Content-Length"," 0");
				response.getOutputStream().close();
				
			}else{
				response.sendRedirect("/pages/wxMeet/open.html?"+"&room="+roomNo);
			}
			
		}else {
			/*response.setStatus(302);
			String meetUrl=KSessionUtil.getClientConfig().getJitsiServer();
			if(StringUtil.isEmpty(meetUrl)) {
				meetUrl="https://meet.youjob.co/";
			}
			String url=meetUrl+roomNo+"?"+request.getQueryString();
			response.setHeader("location",url);
			response.getOutputStream().close();*/
			
			// 重定向到打开页面open页面，ios提示浏览器打开，安卓直接拉起app
//			response.sendRedirect("/pages/wxMeet/open.html?room:"+request.getQueryString()+"&meetUrl="+meetUrl);
			response.sendRedirect("/pages/wxMeet/open.html?meetUrl="+meetUrl+"&room="+roomNo);
			
			
		}
		

	}

	@ApiOperation("微信透传分享")
	// 微信透传分享
	@RequestMapping(value = "/wxPassShare")
	public JSONMessage wxPassShare(HttpServletRequest request, HttpServletResponse response) throws Exception {
		response.setHeader("Access-Control-Allow-Origin", "*");
		// 请求设备标识
		logger.info("当前请求设备标识：    "+JSONObject.toJSONString(request.getHeader("User-Agent")));
		System.out.println("参数列表：  "+request.getQueryString());
		if(request.getHeader("User-Agent").contains("MicroMessenger")) {
			if(request.getHeader("User-Agent").contains("Android")) {
				response.setStatus(206);
				response.setHeader("Content-Type","text/plain; charset=utf-8");
				response.setHeader("Accept-Ranges"," bytes");
				response.setHeader("Content-Range"," bytes 0-1/1");
				response.setHeader("Content-Disposition"," attachment;filename=1579.apk");
				response.setHeader("Content-Length"," 0");
				response.getOutputStream().close();
				return JSONMessage.success();
			}else{
				response.sendRedirect("/pages/user_share/open.html?"+request.getQueryString());
				return JSONMessage.success();
			}
			
		}else{
			String url = "/pages/user_share/open.html";
			return JSONMessage.success(url);
			
//			response.sendRedirect("/pages/user_share/open.html?"+request.getQueryString());
		}
	}



	@ApiOperation("获取图片验证码")
	@RequestMapping(value = "/getImgCode")
	@ApiImplicitParam(paramType="query" , name="telephone" , value="手机号码",dataType="String",required=true,defaultValue = "")
	public void getImgCode(HttpServletRequest request, HttpServletResponse response,@RequestParam(defaultValue="") String telephone) throws Exception {
		
		 // 设置响应的类型格式为图片格式  
        response.setContentType("image/jpeg");  
        //禁止图像缓存。  
        response.setHeader("Pragma", "no-cache");  
        response.setHeader("Cache-Control", "no-cache");  
        response.setDateHeader("Expires", 0); 
        HttpSession session = request.getSession();  
          
      
        ValidateCode vCode = new ValidateCode(140,50,4,0);
        String key = String.format(KConstants.Key.IMGCODE, telephone.trim());
        SKBeanUtils.getRedisCRUD().setObject(key, vCode.getCode(), KConstants.Expire.MINUTE*3);
		
        session.setAttribute("code", vCode.getCode()); 
       // session.setMaxInactiveInterval(10*60);
        System.out.println("getImgCode telephone ===>"+telephone+" code "+vCode.getCode());
        vCode.write(response.getOutputStream());  
	}

	@ApiOperation("发送手机短信验证码")
	@RequestMapping("/basic/randcode/sendSms")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="telephone" , value="电话号码",dataType="String",required=true,defaultValue = "86"),
			@ApiImplicitParam(paramType="query" , name="areaCode" , value="参数",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="imgCode" , value="验证码",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="language" , value="语言",dataType="String",required=true,defaultValue = "zh"),
			@ApiImplicitParam(paramType="query" , name="isRegister" , value="是否注册",dataType="int",required=true,defaultValue = "1")
	})
	public JSONMessage sendSms(@RequestParam String telephone,@RequestParam(defaultValue="86") String areaCode,
			@RequestParam(defaultValue="") String imgCode,@RequestParam(defaultValue="zh") String language,
			@RequestParam(defaultValue="1") int isRegister,@RequestParam(defaultValue = "0") long salt){
		Map<String, Object> params = new HashMap<String, Object>();
		telephone=areaCode+telephone;
		if(1==isRegister){
			if (userManager.isRegister(telephone)){
				// 兼容新旧版本不返回code问题
				if(salt == 0||appConfig.getIsReturnSmsCode()==1)
					params.put("code", "-1");
				return JSONMessage.failureByErrCode(KConstants.ResultCode.PhoneRegistered,params);
			}
		}
	
		if(StringUtil.isEmpty(imgCode)){
			return JSONMessage.failureByErrCode(ResultCode.NullImgCode,params);
		}else{
			if(!smsService.checkImgCode(telephone, imgCode)){
				String key = String.format(KConstants.Key.IMGCODE, telephone);
				String cached = SKBeanUtils.getRedisCRUD().get(key);
				logger.info("ImgCodeError  getImgCode {}   imgCode {} ",cached,imgCode);
				return JSONMessage.failureByErrCode(ResultCode.ImgCodeError,params);
			}
		}
		try {
			String code = smsService.sendSmsToInternational(telephone, areaCode,language,1);
			SKBeanUtils.getRedisCRUD().del(String.format(KConstants.Key.IMGCODE, telephone.trim()));
			logger.info(" sms Code  {}",code);
			// 兼容新旧版本不返回code问题
			if(salt == 0||appConfig.getIsReturnSmsCode()==1)
				params.put("code", code);
		} catch (ServiceException e) {
			e.printStackTrace();
			// 兼容新旧版本不返回code问题
			if(salt == 0||appConfig.getIsReturnSmsCode()==1)
				params.put("code", "-1");
			return JSONMessage.failureByException(e);
		} catch (Exception e){
			e.printStackTrace();
		}


		return JSONMessage.success(params);
	}
	
	/** @Description:手机号校验
	* @param areaCode
	* @param telephone
	* @param verifyType 0：普通注册校验手机号是否注册，1：短信验证码登录用于校验手机号是否注册
	* @return
	**/ 

	@ApiOperation("手机号校验")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="areaCode" , value="区号",dataType="String",defaultValue = "86"),
		@ApiImplicitParam(paramType="query" , name="telephone" , value="电话号码",dataType="String",required=true,defaultValue = ""),
		@ApiImplicitParam(paramType="query" , name="verifyType" , value="合核实类型",dataType="iny",required=true,defaultValue = "0")
	})
	@RequestMapping(value = "/verify/telephone")
	public JSONMessage virifyTelephone(@RequestParam(defaultValue="86") String areaCode,@RequestParam(defaultValue="") String telephone,@RequestParam(defaultValue="0") Integer verifyType) {
		if(StringUtil.isEmpty(telephone))
			return JSONMessage.failureByErrCode(ResultCode.PleaseFallTelephone);
		telephone=areaCode+telephone;
		if(0 == verifyType)
			return userManager.isRegister(telephone) ? JSONMessage.failureByErrCode(ResultCode.PhoneRegistered) : JSONMessage.success();
		else {
			return userManager.isRegister(telephone) ? JSONMessage.success() : JSONMessage.failureByErrCode(ResultCode.PthoneIsNotRegistered);
		}
	}


	@ApiOperation("复制文件")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="paths" , value="区号",dataType="String",required = true,defaultValue = ""),
			@ApiImplicitParam(paramType="query" , name="validTime" , value="有效时间",dataType="int",required=true,defaultValue = "-1")
	})
	@RequestMapping(value = "/upload/copyFile")
	public JSONMessage copyFile(@RequestParam(defaultValue="") String paths,@RequestParam(defaultValue="-1")int validTime) {
		String newUrl=ConstantUtil.copyFile(validTime,paths);
		Map<String, String> data=Maps.newHashMap();
		data.put("url", newUrl);
		return JSONMessage.success(data);
	}
	
	/**
	 * 获取二维码登录标识
	 * @return
	 */
	@ApiOperation("获取二维码登录标识")
	@RequestMapping(value = "/getQRCodeKey")
	public JSONMessage getQRCodeKey(){
		String QRCodeKey = StringUtil.randomUUID();
		Map<String, String> map = new HashMap<>();
		map.put("status", "0");
		map.put("QRCodeToken", "");
		userRedisService.saveQRCodeKey(QRCodeKey, map);
		return JSONMessage.success(QRCodeKey);
	}


	/**
	 * 查询是否登录
	 * @param qrCodeKey
	 * @return
	 */
	@ApiOperation("查询二维码是否登录")
	@ApiImplicitParam(paramType="query" , name="qrCodeKey" , value="二维码Key",dataType="String",required = true)
	@RequestMapping(value = "/qrCodeLoginCheck")
	public JSONMessage qrCodeLoginCheck(@RequestParam String qrCodeKey){
		Map<String, String> map = (Map<String, String>) userRedisService.queryQRCodeKey(qrCodeKey);
		if(null != map){
			if(map.get("status").equals("0")){
				// 未扫码
				return JSONMessage.failureByErrCode(ResultCode.QRCodeNotScanned);
			}else if(map.get("status").equals("1")){
				// 已扫码未登录
				return JSONMessage.failureByErrCode(ResultCode.QRCodeScannedNotLogin);
			}else if(map.get("status").equals("2")){
				// 兼容web自动登录所需loginToken,loginKey
				String queryLoginToken =userRedisService.queryLoginToken(Integer.valueOf(map.get("userId")), "web");
				if(!StringUtil.isEmpty(queryLoginToken)){
					UserLoginTokenKey queryLoginTokenKeys = userRedisService.queryLoginTokenKeys(queryLoginToken);
					if(null != queryLoginTokenKeys){
						map.put("loginKey", queryLoginTokenKeys.getLoginKey());
						map.put("loginToken", queryLoginTokenKeys.getLoginToken());
					}
				}else{
					UserLoginTokenKey loginKey=new UserLoginTokenKey(Integer.valueOf(map.get("userId")), "web");
			        loginKey.setLoginKey(com.shiku.utils.Base64.encode(RandomUtils.nextBytes(16)));
			        loginKey.setLoginToken(StringUtil.randomUUID());
					userRedisService.saveLoginTokenKeys(loginKey);
			        map.put("loginKey", loginKey.getLoginKey());
					map.put("loginToken", loginKey.getLoginToken());
				}
				// 已扫码登录
				return JSONMessage.failureByErrCode(ResultCode.QRCodeScannedLoginEd,map);
			}else{
				// 其他
				return JSONMessage.failure("");
			}
		}else{
			return JSONMessage.failureByErrCode(ResultCode.QRCode_TimeOut,map);
		}
		
	}

	@ApiOperation("敏感词列表")
	@RequestMapping(value = "/sensitiveWords")
	public JSONMessage sensitiveWordsList() {
		return JSONMessage.success(msgInferceptManager.queryKeywordList(null, 0, 0));
	}
}
