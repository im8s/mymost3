package com.shiku.im.open.opensdk;

import cn.hutool.core.codec.Base64;
import com.alibaba.fastjson.JSONObject;
import com.google.common.collect.Maps;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.comm.utils.DesUtil;
import com.shiku.im.message.MessageService;
import com.shiku.im.open.dao.GroupHelperDao;
import com.shiku.im.open.dao.HelperDao;
import com.shiku.im.open.dao.OpenLoginInfoDao;
import com.shiku.im.open.dao.SkOpenAppDao;
import com.shiku.im.open.entity.GroupHelper;
import com.shiku.im.open.entity.Helper;
import com.shiku.im.open.opensdk.entity.OpenLoginInfo;
import com.shiku.im.open.opensdk.entity.SkOpenAccount;
import com.shiku.im.open.opensdk.entity.SkOpenApp;
import com.shiku.im.open.opensdk.until.SkOpenUtil;
import com.shiku.im.room.entity.Room;
import com.shiku.im.room.service.RoomCoreService;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreRedisRepository;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
import lombok.extern.slf4j.Slf4j;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.net.URL;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@SuppressWarnings("restriction")
@Slf4j
@Service
public class OpenAppManageImpl{

	@Autowired
	private SkOpenAppDao skOpenAppDao;
	@Autowired
	private HelperDao helperDao;
	@Autowired
	private GroupHelperDao groupHelperDao;
	@Autowired
	private RoomCoreService roomCoreService;

	@Autowired
	private OpenLoginInfoDao openLoginInfoDao;


	@Autowired
	private OpenAccountManageImpl openAccountManage;

	@Autowired
	private OpenCheckLogManageImpl openCheckLogManage;

	@Autowired
	private MessageService messageService;
	@Autowired
	private UserCoreService userCoreService;

	@Autowired
	private UserCoreRedisRepository userCoreRedisRepository;

	/*@Autowired
	private MongoTemplate mongoTemplate;*/

	/**
	 * 创建应用
	 * @param skOpenApp
	 * @return
	 */
	public synchronized SkOpenApp createApp(SkOpenApp skOpenApp, String telephone, String password) {
		SkOpenAccount skOpenAccount = openAccountManage.ckeckOpenAccount(telephone, password);
		if(null == skOpenAccount){
			throw new ServiceException(KConstants.ResultCode.AccountOrPasswordIncorrect);
		}
		if(!Integer.valueOf(skOpenApp.getAccountId()).equals(skOpenAccount.getUserId())){
			throw new ServiceException("请填写自己的账号");
		}
		SkOpenApp getSkOpenApp = null;
		if (!StringUtil.isEmpty(skOpenApp.getAppName())) {
			getSkOpenApp = skOpenAppDao.getSkOpenApp(skOpenApp.getAppName(),skOpenApp.getAppType());
			if(null != getSkOpenApp)
				throw new ServiceException("已经存在该名称的应用，基于应用名称唯一原则，请重新提交一个新名称。如果你认为已有名称侵犯了你的合法权益，可以进行侵权投诉");
		}
		SkOpenApp entity = new SkOpenApp(skOpenApp);
		skOpenAppDao.addSkOpenApp(entity);
		openCheckLogManage.saveOpenCheckLogs(entity.getAccountId(), null, entity.getAccountId(), String.valueOf(0), null);
		return entity;
	}
	
	/**
	 * 删除应用
	 * @param id
	 */
	public void deleteAppById(ObjectId id,String accountId){

		List<Helper> helQuery = helperDao.getHelperList(id.toString(),0,0);
		if(null != helQuery){
			for(Helper heObject:helQuery){
				groupHelperDao.deleteGroupHelper(heObject.getId().toString());
			}
		}
		helperDao.deleteHelper(id.toString());
		skOpenAppDao.deleteSkOpenApp(id,accountId);
	}
	
	/**
	 * app列表
	 * @param pageIndex
	 * @param pageSize
	 * @return
	 */
	public List<SkOpenApp> appList(String userId,Integer type,Integer pageIndex,Integer pageSize){
		return skOpenAppDao.getSkOpenAppList(userId,type,pageIndex,pageSize);
	}
	
	/**
	 * app详情
	 * @param id
	 * @return
	 */
	public SkOpenApp appInfo(ObjectId id){
		return skOpenAppDao.getSkOpenApp(id);
	}
	
	/**
	 *  通过审核/申请获取权限 
	 * @param
	 * @param skOpenApp
	 */
	public void openAccess(SkOpenApp skOpenApp){
		Map<String,Object> map = new HashMap<>();
		if(skOpenApp.getIsAuthShare()!=0)
			map.put("isAuthShare", skOpenApp.getIsAuthShare());
		if(skOpenApp.getIsAuthLogin()!=0)
			map.put("isAuthLogin", skOpenApp.getIsAuthLogin());
		if(skOpenApp.getIsAuthPay()!=0){
			map.put("isAuthPay", skOpenApp.getIsAuthPay());
		}
		if(skOpenApp.getIsGroupHelper()!=0){
			map.put("isGroupHelper", skOpenApp.getIsGroupHelper());
		}
		if(!StringUtil.isEmpty(skOpenApp.getHelperName())){
			map.put("helperName", skOpenApp.getHelperName());
		}
		if(!StringUtil.isEmpty(skOpenApp.getHelperDesc())){
			map.put("helperDesc", skOpenApp.getHelperDesc());
		}
		if(!StringUtil.isEmpty(skOpenApp.getHelperDeveloper())){
			map.put("helperDeveloper", skOpenApp.getHelperDeveloper());
		}
		if(!StringUtil.isEmpty(skOpenApp.getPayCallBackUrl())){
			map.put("payCallBackUrl", skOpenApp.getPayCallBackUrl());
		}
			
		skOpenAppDao.updateSkOpenApp(skOpenApp.getId(),skOpenApp.getAccountId(),map);
	}
	
	/**
	 * 通过审核、禁用 APP
	 * @param id
	 */
	public void approvedAPP(String id,Integer status,String userId,String reason){
		Map<String,Object> map = new HashMap<>();
		map.put("status", status);
		SkOpenApp skOpenApp = skOpenAppDao.getSkOpenApp(new ObjectId(id));
		String appId=null;
		if(!StringUtil.isEmpty(skOpenApp.getAppId())){
			appId=skOpenApp.getAppId();
		}
		if(1 == status){
			appId = SkOpenUtil.getAppId();
			map.put("appId", appId);
			map.put("appSecret", SkOpenUtil.getAppScrect(appId));
		}
		
		skOpenAppDao.updateSkOpenApp(new ObjectId(id),null,map);
		openCheckLogManage.saveOpenCheckLogs(skOpenApp.getAccountId(),appId,userId,String.valueOf(status),reason);
		
	}
	
	public void allowAccess(){
		
	}
	
	// 校验授权app
	public SkOpenApp authorization(String appId,String appSecret){
		SkOpenApp skOpenApp = skOpenAppDao.getSkOpenApp(appId);
		if(null == skOpenApp)
			throw new ServiceException("应用不存在！");
		if(null != skOpenApp && skOpenApp.getStatus() < 1)
			throw new ServiceException("应用状态异常！");
		if(skOpenApp.getAppSecret().equals(appSecret)){
			return skOpenApp;
		}else{
			throw new ServiceException("授权校验失败！");
		}
	}
	
	public void authInterfaceWeb(String appId,int type){
		SkOpenApp skOpenApp = skOpenAppDao.getSkOpenApp(appId);
		if(null == skOpenApp)
			throw new ServiceException("该第三方网站平台尚未申请");
		switch (type) {
		case 1:
			if(skOpenApp.getIsAuthLogin()!=1){
				throw new ServiceException("登录权限未开通");
			}
			break;
		case 2:
			if(skOpenApp.getIsAuthShare()!=1){
				throw new ServiceException("分享权限未开通");
			}
			break;
		case 3:
			if(skOpenApp.getIsAuthPay()!=1){
				throw new ServiceException("支付权限未开通");
			}
			break;
		default:
			break;
		}
		
	}
	
	public int authInterface(String appId,String appSecret,int type){
		int flag=0;

		SkOpenApp openApp = skOpenAppDao.findByAppIdAndSecret(appId,appSecret);
		switch (type) {
		case 1:
			if(openApp.getIsAuthLogin()!=(byte)1){
				throw new ServiceException("登录权限未开通");
			}else{
				flag=1;
				
			}
			break;
		case 2:
			if(openApp.getIsAuthShare()!=(byte)1){
				throw new ServiceException("分享权限未开通");
			}else{
				flag=1;
				
			}
			break;
		case 3:
			if(openApp.getIsAuthPay()!=(byte)1){
				throw new ServiceException("支付权限未开通");
			}else{
				flag=1;
				
			}
			break;
		default:
			break;
		}
		return flag;
		
	}
	
	public Map<String, String> authorizeUrl(String appId,String callbackUrl){
		SkOpenApp skOpenWeb = skOpenAppDao.getSkOpenApp(appId);
		if(null == skOpenWeb){
			throw new ServiceException("该网站未在开放平台尚未申请");
		}
		try {
			URL requestUrl = new URL(callbackUrl);
			URL serverCallbackUrl = new URL(skOpenWeb.getCallbackUrl());
			if(!requestUrl.getHost().equals(serverCallbackUrl.getHost())){
				throw new ServiceException("回调地址和申请填写的回调地址不符合");
			}
		} catch (Exception e){
			e.printStackTrace();
			throw new ServiceException("回调地址和申请填写的回调地址不符合");
		}
		if(null == skOpenWeb)
			throw new ServiceException("该网站未在开放平台尚未申请");

		/*if(!callbackUrl.equals(skOpenWeb.getCallbackUrl()))
			throw new ServiceException("回调地址和申请填写的回调地址不符合");*/

		Map<String, String> webInfo = Maps.newConcurrentMap();
		webInfo.put("webAppName", skOpenWeb.getAppName());
		webInfo.put("webAppsmallImg", skOpenWeb.getAppsmallImg());
		return webInfo;
	}
	
	public String codeAuthorCheckImpl(String appId,String state) throws Exception{
		SkOpenApp skOpenApp = skOpenAppDao.getSkOpenApp(appId);
		if(null == skOpenApp)
			throw new ServiceException("该应用未在开放平台尚未申请");
		String time = String.valueOf(DateUtil.currentTimeSeconds());
		String userId = userCoreRedisRepository.getUserIdBytoken(state);
		if(StringUtil.isEmpty(userId))
			throw new ServiceException("state无效");
//		String key = time.substring(2, time.length());
		String desUserId = DesUtil.encrypt(userId, time);
		// 规则code = appId位数 + appId + time + des(userId)
		String str = appId.length()+appId+time+desUserId;
//		String encodeBuffer = (new BASE64Encoder()).encodeBuffer(str.getBytes());
		String encodeBuffer = Base64.encode(str.getBytes());
		return encodeBuffer;
	}
	
	public Map<String,String> codeOauthImpl(String code) throws Exception {
		// base64解密 
		long currTime = DateUtil.currentTimeSeconds();
		byte[] decodeBuffer = Base64.decode(code);
//		byte[] decodeBuffer = (new BASE64Decoder()).decodeBuffer(code);
		log.info("=== 解密 code === : "+decodeBuffer.toString());
		// 规则code = appId位数 + appId + time + des(userId)
		String strByte = new String(decodeBuffer);
		// 时间容错三分钟：18sk598d214577e943e41551404075s1hkrmNjyhiau95u5Rp4DQ==
		String codeTime = strByte.substring(20, 20+(String.valueOf(currTime).length()));
		Long endTime = Long.valueOf(codeTime);
		if((currTime-endTime) > 180 || currTime-endTime < -180){
			log.info(String.format("====> codeOauthImpl error server > %s client %s", currTime,endTime));
			throw new ServiceException("参数 code 已过期失效");
		} 
		String appId = strByte.substring(2, 20);
		SkOpenApp skOpenApp = skOpenAppDao.getSkOpenApp(appId);
		if(null == skOpenApp)
			throw new ServiceException("应用不存在！");
		String desUserId = strByte.substring(30, strByte.length());
		// des解密userId
		User user = userCoreService.getUser(Integer.valueOf(DesUtil.decrypt(desUserId, codeTime)));
		if(null == user)
			throw new ServiceException("暂无授权用户");
		// 数据存档
		OpenLoginInfo openLoginInfo = openLoginInfoDao.getOpenLoginInfo(user.getUserId());
		String openId = null;
		if(null == openLoginInfo){
			// openId = base64(userId 位数+userId+sk) 
			String substrAppId = appId.substring(2, appId.length());
			String openIdByte = user.getUserId().toString().length()+user.getUserId().toString()+substrAppId;
			log.info("==== openId ====  length: "+user.getUserId().toString().length() + " userId : "+user.getUserId().toString()+"  subSK: "+substrAppId);
			log.info("==== base64 ====  "+openIdByte);
			openId = Base64.encode(openIdByte.getBytes());// base64
//			openId = (new BASE64Encoder()).encodeBuffer(openIdByte.getBytes());// base64
			OpenLoginInfo loginInfo = new OpenLoginInfo(user.getUserId(), openId, appId, skOpenApp.getAppName(), 1);
			openLoginInfoDao.addOpenLoginInfo(loginInfo);
		}else{
			openId = openLoginInfo.getOpenId();
		}
		Map<String,String> map = Maps.newConcurrentMap();
		map.put("nickName", user.getNickname());
		map.put("sex", user.getSex().toString());
		map.put("birthday",user.getBirthday().toString());
		map.put("provinceId", user.getProvinceId().toString());
		map.put("cityId", user.getCityId().toString());
		//var imgUrl = AppConfig.avatarBase + (parseInt(userId) % 10000) + "/" + userId + ".jpg";
		String imgUrl = SKBeanUtils.getImCoreService().getClientConfig().getDownloadAvatarUrl();
		String userImgUrl = imgUrl+"avatar/o/"+(user.getUserId() % 10000) + "/" + user.getUserId() + ".jpg";
		map.put("image", userImgUrl);
		map.put("openId", openId);
		return  map;
	}
	
	public SkOpenApp getOpenAppByAppId(String appId){
		return skOpenAppDao.getSkOpenApp(appId);
	}
	
	/**
	 * 添加群助手
	 * @param entity
	 */
	public void addHelper(Helper entity){
		entity.setCreateTime(DateUtil.currentTimeSeconds());
		helperDao.saveEntity(entity);
	}
	
	/**
	 * 获取群助手列表
	 * @param openAppId
	 * @param pageIndex
	 * @param pageSize
	 * @return
	 */
	public List<Helper> getHelperList(String openAppId,Integer pageIndex,Integer pageSize){
		return helperDao.getHelperList(openAppId,pageIndex,pageSize);
	}
	
	public void updateHelper(Helper entity){

		
		helperDao.updateHelper(entity);
	}
	
	/**
	 * 删除群助手
	 * @param id
	 */
	public void deleteHelper(Integer userId,ObjectId id){
		helperDao.deleteHelper(userId,id);
	}
	
	/**
	 * 发送群助手消息
	 * @param roomId
	 * @param userId
	 * @param title
	 * @param desc
	 * @param imgUrl
	 * @param type
	 * @param url
	 */
	public JSONMessage sendMsgByGroupHelper(String roomId, Integer userId, String title,
											String desc, String imgUrl, Integer type, String url, String appId){
		GroupHelper groupHelper = groupHelperDao.findOne("roomId", roomId);
		if(null==groupHelper){
			return JSONMessage.failure("群助手不存在");
		}
		Room room = roomCoreService.getRoomById(new ObjectId(roomId));
		if(null==room){
			return JSONMessage.failure("房间不存在");
		}
		User user = userCoreService.getUser(userId);
		if(user==null){
			return JSONMessage.failure("用户不存在");
		}
		
		SkOpenApp openApp = getOpenAppByAppId(appId);
		if(openApp==null){
			return JSONMessage.failure("该应用未在第三方平台注册");
		}
		JSONObject body = new JSONObject();
		
		MessageBean messageBean=new MessageBean();
		if(type==1){// 发送图文
			body.put("appName", openApp.getAppName());
			body.put("appIcon", openApp.getAppImg());
			body.put("title", title);
			body.put("subTitle", desc);
			body.put("imageUrl", imgUrl);
			body.put("url", url);
			messageBean.setObjectId(body.toString());
			messageBean.setType(87);
		}else if(type==2){// 发送图片
			messageBean.setContent(imgUrl);
			messageBean.setType(2);
		}
		
		messageBean.setFromUserId(user.getUserId().toString());
		messageBean.setFromUserName(user.getNickname());
		messageBean.setRoomJid(groupHelper.getRoomJid());
		messageBean.setToUserId(room.getJid());
		// 发送群聊通知
		try {
			messageService.sendMsgToGroupByJid(groupHelper.getRoomJid(),messageBean);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return JSONMessage.success();
	}
}
