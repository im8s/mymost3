package com.shiku.im.mpserver.controller;

import com.alibaba.fastjson.JSONObject;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import com.google.common.collect.Lists;
import com.mongodb.DBObject;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.config.AppConfig;
import com.shiku.im.entity.ClientConfig;
import com.shiku.im.friends.entity.Friends;
import com.shiku.im.friends.service.impl.FriendsManagerImpl;
import com.shiku.im.message.IMessageRepository;
import com.shiku.im.message.MessageService;
import com.shiku.im.mpserver.MpConfig;
import com.shiku.im.mpserver.model.MenuVO;
import com.shiku.im.mpserver.service.impl.MPServiceImpl;
import com.shiku.im.mpserver.service.impl.MenuManagerImpl;
import com.shiku.im.mpserver.utils.BusinessUtils;
import com.shiku.im.mpserver.utils.MobileValidateUtils;
import com.shiku.im.mpserver.utils.ValidateIDCardUtils;
import com.shiku.im.mpserver.vo.Menu;
import com.shiku.im.open.entity.OfficialInfo;
import com.shiku.im.open.opensdk.OfficialInfoCheckImpl;
import com.shiku.im.sms.SMSServiceImpl;
import com.shiku.im.support.Callback;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.model.KSession;
import com.shiku.im.user.service.UserRedisService;
import com.shiku.im.user.service.impl.UserManagerImpl;
import com.shiku.im.user.utils.KSessionUtil;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
import org.apache.commons.lang3.RandomUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.*;

/**
 * ???????????????????????????
 *
 * 
 *
 */
@RestController
@RequestMapping("/mp")
public class AdminMpController extends AbstractController {
	@Autowired
	private FriendsManagerImpl friendsManager;
	

	
	@Autowired
	private MPServiceImpl mpManager;

	@Autowired
	private MenuManagerImpl menuManager;
	@Autowired
	private UserManagerImpl userManager;

	@Autowired
	private IMessageRepository messageRepository;


	@Autowired
	private MessageService messageService;

	@Autowired
	private SMSServiceImpl smsService;
	
	
	@Autowired
	private OfficialInfoCheckImpl officialInfoCheck;


	@Autowired
	private UserRedisService userRedisService;
	
	@Resource(name = "mpConfig")
	protected MpConfig mpConfig;

	@Autowired
	private AppConfig appConfig;


	@RequestMapping("/fans/delete")
	public JSONMessage deleteFans(HttpServletResponse response, @RequestParam int toUserId){
		Integer userId = ReqUtil.getUserId();
		friendsManager.consoleDeleteFriends(userId,userId, toUserId+"");
		return  JSONMessage.success();
	}




	@RequestMapping(value = "/login", method = { RequestMethod.GET })
	public void openLogin(HttpServletRequest request, HttpServletResponse response) {
		try {
			String path = request.getContextPath() + "/pages/mp/login.html";
			response.sendRedirect(path);
		} catch (IOException e) {
			e.printStackTrace();
		}

	}

	@RequestMapping(value = "/config", method = { RequestMethod.GET })
	public JSONMessage getConofig() {
		HashMap<String, Object> map = new HashMap<>();
		try {
			
			ClientConfig clientConfig = SKBeanUtils.getImCoreService().getClientConfig();
			
			map.put("imServerAddr", clientConfig.getXMPPHost());
			map.put("imDomian",clientConfig.getXMPPDomain());
			map.put("apiAddr", clientConfig.getApiUrl());
			map.put("fileAddr", clientConfig.getDownloadAvatarUrl());
			map.put("uploadAddr", clientConfig.getUploadUrl());
			
			map.put("isOpenWss", mpConfig.getIsOpenWss());
			return JSONMessage.success(map);
			
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
	}
	/**
	 * @Description: 2019-01-17 17:41 ????????????????????????????????????????????????
	* @param request
	* @return
	**/
	@RequestMapping(value = "/login", method = RequestMethod.POST)
	public JSONMessage login(HttpServletRequest request) {
		String account = request.getParameter("account");
		String password = request.getParameter("password");
		HashMap<String, Object> map = new HashMap<>();
		try {
			User user = userManager.mpLogin(account, password);

			//?????????????????????
			if (user.getUserType() == 2 && user.getStatus() == -1){
				OfficialInfo officialInfo = officialInfoCheck.getOfficialInfo(user.getTelephone());
				if (null == officialInfo){
					return JSONMessage.failure("?????????????????????");
				}
				//?????? 0--?????????  1--????????????  2--???????????????
				 if (0 == officialInfo.getVerify()){
					return JSONMessage.failure("??????????????????????????????????????????");
				}else if(2 == officialInfo.getVerify()){
					return JSONMessage.failureByErrCodeAndData(KConstants.ResultCode.NO_PASS,"???????????????????????????");
				}
			}

			Map<String, Object> tokenMap = KSessionUtil.adminLoginSaveToken(user.getUserId(), null);

			map.put("access_Token", tokenMap.get("access_Token"));
			map.put("userId", user.getUserId());
			//map.put("password",user.getPassword());
			map.put("nickname", user.getNickname());
			map.put("apiKey", appConfig.getApiKey());

			KSession session = new KSession(user.getUserId(),"zh","");
			session.setAccessToken(tokenMap.get("access_Token").toString());
			session.setHttpKey(com.shiku.utils.Base64.encode(RandomUtils.nextBytes(16)));
			userRedisService.saveUserSesson(session); //??????seession

			map.put("httpKey",session.getHttpKey());

			return JSONMessage.success(map);

		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}

	}


	/**
	 * ???????????????????????????
	 * @throws ServletException
	 * @throws IOException
	 */
	@RequestMapping(value="logout")
	public JSONMessage logout() {
		KSessionUtil.removeAdminToken(ReqUtil.getUserId());
		return JSONMessage.success();
	}


	@RequestMapping("/menu/{op}")
	public JSONMessage menuOp(HttpServletResponse response, @PathVariable String op, @RequestParam(defaultValue="0") long parentId
			, @RequestParam(defaultValue="") String desc, @RequestParam(defaultValue="") String name, @RequestParam(defaultValue="0") int index
			, @RequestParam(defaultValue="") String urls, @RequestParam(defaultValue="0") long id, @RequestParam(defaultValue="") String menuId)
			throws IOException {

			menuManager.menuOp(ReqUtil.getUserId(), op, parentId, desc, name, index, urls, id,menuId ,response);

			return JSONMessage.success();
	}


	//????????????
	@RequestMapping(value="/menu/saveupdate",method=RequestMethod.POST)
	@ResponseBody
	public JSONMessage saveupdate(@ModelAttribute Menu entity) throws IOException{
		menuManager.saveupdate(entity);
		return JSONMessage.success();
	}

	@RequestMapping("/fans")
	@ResponseBody
	public JSONMessage navFans(@RequestParam(defaultValue = "0") int pageIndex,
			@RequestParam(defaultValue = "10") int pageSize,@RequestParam(defaultValue = "") String keyWord) {
		User user = userManager.getUserDao().get(ReqUtil.getUserId());
		Object data=null;
		if (null != user) {
			data=friendsManager.queryFriends(user.getUserId(),0,keyWord, pageIndex, pageSize);
		}
		return JSONMessage.success(data);
	}



	@ResponseBody
	@RequestMapping("/getHomeCount")
	public JSONMessage getHomeCount() {
		JSONMessage message;
		User user = userManager.getUserDao().get(ReqUtil.getUserId());
		if(null != user) {
			JSONObject homeCount = menuManager.getHomeCount(user.getUserId());
			message=JSONMessage.success(homeCount);
		}else
			message = JSONMessage.failure("Session ===> user is null");
		return message;
	}


	@RequestMapping("/menuList")
	@ResponseBody
	@JsonSerialize(using = ToStringSerializer.class)
	public JSONMessage navMenu(HttpServletRequest request,HttpServletResponse response) {
		JSONMessage jsonMessage;
		User user = userManager.getUserDao().get(ReqUtil.getUserId());
		if(null != user) {
			List<MenuVO> navMenu = menuManager.navMenu(user.getUserId());
			jsonMessage = JSONMessage.success(null, navMenu);
		}else
			jsonMessage = JSONMessage.failure("Session ===> user is null");
		return jsonMessage;
	}

	@RequestMapping("/msgs")
	@ResponseBody
	public JSONMessage msg(@RequestParam(defaultValue = "0") int pageIndex,
						   @RequestParam(defaultValue = "15") int pageSize) {
		User user = userManager.getUserDao().get(ReqUtil.getUserId());
		return JSONMessage.success(null, mpManager.getMsgList(user.getUserId(), pageIndex, pageSize));
	}

	/**
	 * @Description: TODO(??????????????????????????????????????????)
	 * @param startTime
	 * @param pageSize
	 * @return
	 */
	@RequestMapping("/getLastChatList")
	@ResponseBody
	public JSONMessage msg(@RequestParam(defaultValue="0")long startTime,
			@RequestParam(defaultValue = "20") int pageSize) {
		try {
			Object result = mpManager.queryLastChatList( ReqUtil.getUserId(),startTime, pageSize);
			return JSONMessage.success(result);
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}



	@SuppressWarnings("unchecked")
	@RequestMapping("/msg/list")
	@ResponseBody
	public JSONMessage msgList(@RequestParam int toUserId, @RequestParam(defaultValue = "0") int pageIndex,
							   @RequestParam(defaultValue = "10") int pageSize) {
		User user = userManager.getUserDao().get(ReqUtil.getUserId());
		List<DBObject> msgList = (List<DBObject>) mpManager.getMsgList(toUserId, user.getUserId(), pageIndex, pageSize);
		ThreadUtils.executeInThread(new Callback() {

			@Override
			public void execute(Object obj) {
				for (DBObject dbObject : msgList) {
					messageRepository.updateMsgIsReadStatus(user.getUserId(),dbObject.get("messageId").toString());
				}
			}
		});
		return JSONMessage.success(null, msgList);
	}








	@RequestMapping(value = "/msg/send")
	@ResponseBody
	public JSONMessage msgSend(@RequestParam Integer toUserId, @RequestParam String body,
			@RequestParam(defaultValue="1") int type )
			throws Exception {
		User user = userManager.getUserDao().get(ReqUtil.getUserId());

		MessageBean mb = new MessageBean();
		// = new String(body.getBytes("ISO-8859-1"), "utf-8")
		mb.setContent(body);
		// mb.setFileName(fileName);
		mb.setFromUserId(user.getUserId() + "");
		mb.setFromUserName(user.getNickname());
		// mb.setObjectId(objectId);
		mb.setTimeSend(DateUtil.currentTimeSeconds());
		mb.setToUserId(toUserId + "");
		mb.setMessageId(UUID.randomUUID().toString());
		// mb.setToUserName(toUserName);
		mb.setMsgType(0);// ????????????
		mb.setType(type);
		mb.setMessageId(StringUtil.randomUUID());
		try {
			messageService.send(mb);
		} catch (Exception e) {
			System.out.println(user.getUserId() + "???????????????  "+e.getMessage());
			return JSONMessage.failure(e.getMessage());
		}
		return JSONMessage.success();
	}


	@RequestMapping(value="/textToAll")
	@ResponseBody
	public JSONMessage textToAll(@RequestParam String title){
		User user = userManager.getUserDao().get(ReqUtil.getUserId());

		MessageBean mb = new MessageBean();
		/*JSONObject jsonObj=new JSONObject();
		jsonObj.put("title", title);*/

		mb.setContent(title);
		mb.setFromUserId(user.getUserId() + "");
		mb.setFromUserName(user.getNickname());
		mb.setTimeSend(DateUtil.currentTimeSeconds());
		mb.setMsgType(2);// ????????????
		mb.setType(1);
		mb.setMessageId(StringUtil.randomUUID());
		try {
			ThreadUtils.executeInThread((Callback) obj -> messageService.send(mb));
		} catch (Exception e) {
			System.out.println(user.getUserId() + "???????????????");
			return JSONMessage.failure(e.getMessage());
		}
		return JSONMessage.success();
	}

	@RequestMapping(value = "/pushToAll")
	@ResponseBody
	public JSONMessage pushToAll(@RequestParam String title,@RequestParam String sub,@RequestParam String img,@RequestParam String url) throws Exception {
		User user = userManager.getUserDao().get(ReqUtil.getUserId());

		MessageBean mb = new MessageBean();
		JSONObject jsonObj=new JSONObject();
		jsonObj.put("title", title);
		jsonObj.put("sub", sub);
		jsonObj.put("img", img);
		jsonObj.put("url", url);
		mb.setContent(jsonObj.toString());
		// mb.setFileName(fileName);
		mb.setFromUserId(user.getUserId() + "");
		mb.setFromUserName(user.getNickname());
		// mb.setObjectId(objectId);
		mb.setTimeSend(DateUtil.currentTimeSeconds());
		// mb.setToUserId(fans.getToUserId() + "");
		// mb.setToUserName(toUserName);
		mb.setMsgType(2);// ????????????
		mb.setType(80);
		mb.setMessageId(StringUtil.randomUUID());
		try {
			ThreadUtils.executeInThread(new Callback() {

				@Override
				public void execute(Object obj) {
					messageService.send(mb);

				}
			});

		} catch (Exception e) {
			System.out.println(user.getUserId() + "???????????????");
			return JSONMessage.failure(e.getMessage());
		}
		return JSONMessage.success();
	}

	@RequestMapping(value="/manyToAll")
	@ResponseBody
	public JSONMessage many(@RequestParam(defaultValue="") String[] title,@RequestParam(defaultValue="") String[] url,@RequestParam(defaultValue="") String[] img) throws ServletException, IOException{
		User user = userManager.getUserDao().get(ReqUtil.getUserId());
		List<Friends> fansList = friendsManager.getFansList(user.getUserId());
		List<Integer> toUserIdList = Lists.newArrayList();
		for (Friends fans : fansList) {
			toUserIdList.add(fans.getToUserId());
		}
		List<Object> list=new ArrayList<Object>();
		JSONObject jsonObj=null;
		for(int i=0;i<title.length;i++){
			jsonObj=new JSONObject();
			jsonObj.put("title",title[i]);
			jsonObj.put("url", url[i]);
			jsonObj.put("img", img[i]);
			list.add(jsonObj);
		}
		MessageBean messageBean=new MessageBean();
		messageBean.setContent(list.toString());
		messageBean.setFromUserId(user.getUserId() + "");
		messageBean.setFromUserName(user.getNickname());
		messageBean.setTimeSend(DateUtil.currentTimeSeconds());
		messageBean.setType(81);
		messageBean.setMsgType(2);// ????????????
		messageBean.setMessageId(StringUtil.randomUUID());
		try {
			ThreadUtils.executeInThread((Callback) obj ->
					messageService.send(messageBean));
		} catch (Exception e) {
			System.out.println(user.getUserId() + "???????????????");
			return JSONMessage.failure(e.getMessage());
		}
		return JSONMessage.success();

	}


	//?????????????????????
	@RequestMapping("/opffcialInfoRegister")
	public JSONMessage registerOfficllnfo(@ModelAttribute OfficialInfo info, @RequestParam(defaultValue = "") String randcode){

		if (!MobileValidateUtils.checkMobileNumber(info.getAdminTelephone())){
			return JSONMessage.failure("?????????????????????????????????");
		}
		if (isRegister(info.getTelephone())){
			return JSONMessage.failure("??????????????????");
		}

		String telephone = "86" + info.getTelephone();
		//???????????????
		if(!smsService.isAvailable(telephone,randcode)) {
			//return JSONMessage.failureByErrCode(KConstants.ResultCode.VerifyCodeErrOrExpired);
			return JSONMessage.failure("??????????????????????????????");
		}
		//?????????????????????
		if (info.getCompanyBusinessLicense().length() == 15){
			boolean businessLicense15 = BusinessUtils.isBusinessLicense15(info.getCompanyBusinessLicense());
			if (!businessLicense15){
				return JSONMessage.failure("??????????????????????????????");
			}
		}else if(info.getCompanyBusinessLicense().length() == 18){
			boolean businessLicense18 = BusinessUtils.isBusinessLicense18(info.getCompanyBusinessLicense());
			if (!businessLicense18){
				return JSONMessage.failure("???????????????????????????????????????");
			}
		}

		//???????????????
		boolean flag = ValidateIDCardUtils.validateIdCard18(info.getAdminID());
		if (!flag){
			return JSONMessage.failure("???????????????????????????????????????");
		}
		//??????????????????
		info.setCreateTime(DateUtil.currentTimeSeconds());
		//??????areaCode
		if (info == null){
			info.setAreaCode("86");
		}
		//info.setTelephone(telephone);
		//???????????????????????????
		OfficialInfo save = SKBeanUtils.getDatastore().save(info);

		//????????????
		User user = userManager.createUser(info.getTelephone(),info.getPassword());
		if (null == info.getAreaCode()){
			user.setAreaCode("86");
		}else{
			user.setAreaCode(info.getAreaCode());
		}
		user.setUserType(2);
		user.setNickname("???????????????");
		user.setCreateTime(DateUtil.currentTimeSeconds());
		user.setModifyTime(DateUtil.currentTimeSeconds());
		user.setCityId(400300);
		//??????????????????
		user.setStatus(-1);
		user.setLoc(new User.Loc(10.0,10.0));
		user.setPhone(info.getTelephone().substring(2));
		//?????????????????????
		user.setSettings(new User.UserSettings());
		//??????????????????
//		userManager.save(user);
		userManager.getUserDao().addUser(user);
		return  JSONMessage.success();
	}

	//???????????????
	@RequestMapping(value = "/sendCode")
	public JSONMessage sendCode(@RequestParam String telephone,@RequestParam(defaultValue="86") String areaCode,@RequestParam(defaultValue="zh") String language){

		if (!MobileValidateUtils.checkMobileNumber(telephone)){
			return JSONMessage.failure("??????????????????????????????");
		}
		if (isRegister(telephone)){
			return JSONMessage.failure("?????????????????????");
		}
		try {
			telephone=areaCode+telephone;
			String code =smsService.sendSmsToInternational(telephone,areaCode,language,1);
			logger.info("code???"  + code);
		}catch (ServiceException e){
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
		return JSONMessage.success();
	}


	//????????????????????????
	public static boolean isRegister(String telephone){
		Query query =new Query().addCriteria(Criteria.where("telephone").is(telephone));
		if (null!=SKBeanUtils.getDatastore().findOne(query,OfficialInfo.class)) {
			return true;
		}
		return false;
	}

	//????????????????????????????????????
	@RequestMapping(value = "/getOfficialInfoByTel")
	public JSONMessage getOfficialInfoByTel(String telephone){
		OfficialInfo officialInfo = officialInfoCheck.getOfficialInfo(telephone);
		User user = userManager.getUser(telephone);
        Map<String, Object> data = new HashMap<>();
        data.put("officialInfo",officialInfo);
        data.put("user",user);
        return JSONMessage.success(data);
	}

	//??????????????????
	@RequestMapping(value = "/updateOfficialInfoByTel")
	public JSONMessage updateOfficialInfoByTel(@ModelAttribute OfficialInfo info){
		//?????????????????????
		if (info.getCompanyBusinessLicense().length() == 15){
			boolean businessLicense15 = BusinessUtils.isBusinessLicense15(info.getCompanyBusinessLicense());
			if (!businessLicense15){
				return JSONMessage.failure("??????????????????????????????");
			}
		}else if(info.getCompanyBusinessLicense().length() == 18){
			boolean businessLicense18 = BusinessUtils.isBusinessLicense18(info.getCompanyBusinessLicense());
			if (!businessLicense18){
				return JSONMessage.failure("???????????????????????????????????????");
			}
		}

		if (!MobileValidateUtils.checkMobileNumber(info.getAdminTelephone())){
			return JSONMessage.failure("?????????????????????????????????");
		}

		//???????????????
		boolean flag = ValidateIDCardUtils.validateIdCard18(info.getAdminID());
		if (!flag){
			return JSONMessage.failure("???????????????????????????????????????");
		}

		officialInfoCheck.updateOfficialInfoByTel(info);
		return JSONMessage.success();
	}
}
