package com.shiku.im.admin.controller;

import cn.hutool.extra.servlet.ServletUtil;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.mongodb.MongoCommandException;
import com.mongodb.MongoQueryException;
import com.shiku.common.model.PageResult;
import com.shiku.common.model.PageVO;
import com.shiku.commons.thread.JSONMsg;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.admin.dao.MsgInferceptDAO;
import com.shiku.im.admin.entity.*;
import com.shiku.im.admin.service.MsgInferceptManager;
import com.shiku.im.admin.service.impl.AdminManagerImpl;
import com.shiku.im.admin.service.impl.ErrorMessageManageImpl;
import com.shiku.im.admin.service.impl.WhiteLoginListRepository;
import com.shiku.im.admin.utils.ExcelUtil;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.comm.utils.*;
import com.shiku.im.common.service.PaymentManager;
import com.shiku.im.common.service.RedPacketsManager;
import com.shiku.im.config.AppConfig;
import com.shiku.im.dto.ClientConfigDto;
import com.shiku.im.entity.*;
import com.shiku.im.friends.entity.AddressBook;
import com.shiku.im.friends.entity.Friends;
import com.shiku.im.friends.entity.FriendsterWebsite;
import com.shiku.im.friends.service.impl.AddressBookManagerImpl;
import com.shiku.im.friends.service.impl.FriendsManagerImpl;
import com.shiku.im.friends.service.impl.FriendsterWebsiteManagerImpl;
import com.shiku.im.live.entity.LiveRoom;
import com.shiku.im.live.service.impl.LiveRoomManagerImpl;
import com.shiku.im.message.IMessageRepository;
import com.shiku.im.message.MessageService;
import com.shiku.im.message.dao.TigaseMsgDao;
import com.shiku.im.model.ErrorMessage;
import com.shiku.im.model.PressureParam;
import com.shiku.im.msg.entity.Comment;
import com.shiku.im.msg.entity.Msg;
import com.shiku.im.msg.entity.MusicInfo;
import com.shiku.im.msg.entity.Praise;
import com.shiku.im.msg.service.impl.MsgCommentManagerImpl;
import com.shiku.im.msg.service.impl.MsgManagerImpl;
import com.shiku.im.msg.service.impl.MsgPraiseManagerImpl;
import com.shiku.im.msg.service.impl.MusicManagerImpl;
import com.shiku.im.open.entity.OfficialInfo;
import com.shiku.im.open.opensdk.OfficialInfoCheckImpl;
import com.shiku.im.open.opensdk.OpenAccountManageImpl;
import com.shiku.im.open.opensdk.OpenAppManageImpl;
import com.shiku.im.open.opensdk.OpenCheckLogManageImpl;
import com.shiku.im.open.opensdk.entity.SkOpenAccount;
import com.shiku.im.open.opensdk.entity.SkOpenApp;
import com.shiku.im.open.opensdk.entity.SkOpenCheckLog;
import com.shiku.im.pay.entity.BaseConsumeRecord;
import com.shiku.im.room.entity.Room;
import com.shiku.im.room.service.impl.RoomManagerImplForIM;
import com.shiku.im.room.vo.RoomVO;
import com.shiku.im.support.Callback;
import com.shiku.im.user.constants.MoneyLogConstants.MoenyAddEnum;
import com.shiku.im.user.constants.MoneyLogConstants.MoneyLogEnum;
import com.shiku.im.user.constants.MoneyLogConstants.MoneyLogTypeEnum;
import com.shiku.im.user.dao.InviteCodeDao;
import com.shiku.im.user.dao.ReportDao;
import com.shiku.im.user.entity.*;
import com.shiku.im.user.model.SdkLoginInfo;
import com.shiku.im.user.model.UserExample;
import com.shiku.im.user.service.impl.RoleManagerImpl;
import com.shiku.im.user.service.impl.UserManagerImpl;
import com.shiku.im.user.utils.KSessionUtil;
import com.shiku.im.utils.ConstantUtil;
import com.shiku.im.utils.IPUtil;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.Md5Util;
import eu.bitwalker.useragentutils.DeviceType;
import eu.bitwalker.useragentutils.OperatingSystem;
import eu.bitwalker.useragentutils.UserAgent;
import org.apache.commons.lang3.StringUtils;
import org.apache.poi.ss.usermodel.Workbook;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;
import springfox.documentation.annotations.ApiIgnore;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * ??????????????????
 */

@ApiIgnore
@RestController
@RequestMapping("/console")
public class AdminController  {

	public static final String LOGIN_USER_KEY = "LOGIN_USER";

	protected Logger logger= LoggerFactory.getLogger(AdminController.class);

	@Autowired
	private MsgManagerImpl msgManager;
	@Autowired
	private MsgCommentManagerImpl commentManager;
	@Autowired
	private MsgPraiseManagerImpl msgPraiseManager;
	@Autowired
	private MsgInferceptDAO msgInferceptDAO;
	@Autowired
	private TigaseMsgDao tigaseMsgDao;
	@Autowired
	private ReportDao reportDao;
	@Autowired
	private OfficialInfoCheckImpl officialInfoCheck;
	@Autowired
	private RoleManagerImpl roleManager;
	@Autowired
	private LiveRoomManagerImpl liveRoomManager;
	@Autowired
	private RoomManagerImplForIM roomManager;
	@Autowired
	private UserManagerImpl userManager;
	@Autowired
	private FriendsManagerImpl friendsManager;
	@Autowired
	private AdminManagerImpl adminManager;
	@Autowired
	private ErrorMessageManageImpl errorMessageManage;
	@Autowired
	private OpenCheckLogManageImpl openCheckLogManage;
	@Autowired
	private OpenAppManageImpl openAppManage;
	@Autowired
	private MessageService messageService;
	@Autowired
	private MusicManagerImpl musicManager;
	@Autowired
	private OpenAccountManageImpl openAccountManage;
	@Autowired
	private MsgInferceptManager msgInferceptManager;
	@Autowired
	private IMessageRepository messageRepository;
	@Autowired
	private AppConfig appConfig;
	@Autowired(required = false)
	private PaymentManager paymentManager;
	@Autowired(required = false)
	private RedPacketsManager redPacketsManager;
	@Autowired
	private FriendsterWebsiteManagerImpl friendsterWebsiteManager;
	@Autowired
	private WhiteLoginListRepository whiteLoginListRepository;
	@Autowired
	private AddressBookManagerImpl addressBookManager;

	@Autowired
	private InviteCodeDao inviteCodeDao;
	protected ObjectId parse(String s) {
		return StringUtil.isEmpty(s) ? null : new ObjectId(s);
	}

	@RequestMapping(value = "/config")
	public JSONMessage getConfig() {
		Config config = SKBeanUtils.getSystemConfig();
		config.setDistance(ConstantUtil.getAppDefDistance());
		return JSONMessage.success(config);
	}

	// ?????????????????????
	@RequestMapping(value = "/config/set", method = RequestMethod.POST)
	public JSONMessage setConfig(@ModelAttribute Config config) throws Exception {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!= KConstants.Admin_Role.SUPER_ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
			}
			//???????????????????????????10000
			if (config.getMaxCrowdNumber() > 10000){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.MaxCrowdNumber);
			}
			if (config.getMaxCrowdNumber() < config.getMaxUserSize()){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.PassRoomMax);
			}
			adminManager.setConfig(config);
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	// ?????????????????????
	@RequestMapping(value = "/clientConfig/set")
	public JSONMessage setClientConfig(@ModelAttribute ClientConfigDto clientConfig) throws Exception{
		try {
			// ????????????
			String accessToken = null == clientConfig.getAccess_token() ? "" : clientConfig.getAccess_token().split(",")[0];
			String uidStr = KSessionUtil.getAdminUserIdByToken(accessToken);
			Integer uid = cn.hutool.core.util.NumberUtil.isNumber(uidStr) ? Integer.valueOf(uidStr) : 0;
			byte role = (byte) roleManager.getUserRoleByUserId(uid);
			if(role!=KConstants.Admin_Role.SUPER_ADMIN && !ClientConfigDto.SECRET_VALUE.equals(clientConfig.getSecret())){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
			}
			adminManager.setClientConfig(clientConfig);
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	@RequestMapping(value = "/clientConfig")
	public JSONMessage getClientConfig() {
		ClientConfig clientConfig = adminManager.getClientConfig();
		return JSONMessage.success(null, clientConfig);
	}

	// ??????????????????
	@RequestMapping(value = "/payConfig/set")
	public JSONMessage setPayConfig(@ModelAttribute PayConfig payConfig){
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
			}
			if(payConfig.getMyChangeWithdrawRate()<0.006){
				return JSONMessage.failure("??????????????????0.006");
			}
			adminManager.setPayConfig(payConfig);
			return JSONMessage.success();
		}catch (Exception e){
			return JSONMessage.failure(e.getMessage());
		}
	}

	@RequestMapping(value = "/payConfig")
	public JSONMessage getPayConfig(){
		PayConfig payConfig = adminManager.getPayConfig();
		return JSONMessage.success(payConfig);
	}


	@RequestMapping(value = "/chat_logs_all")
	public JSONMessage chat_logs_all(@RequestParam(defaultValue = "0") long startTime,
									 @RequestParam(defaultValue = "0") long endTime, @RequestParam(defaultValue = "") String sender,
									 @RequestParam(defaultValue = "") String receiver, @RequestParam(defaultValue = "0") int page,
									 @RequestParam(defaultValue = "10") int limit,@RequestParam(defaultValue = "") String keyWord, HttpServletRequest request) throws Exception {

		int userId =0;
		int toUserId=0;
		if(!StringUtil.isEmpty(sender.trim())){
			userId=Integer.valueOf(sender);
		}
		if(!StringUtil.isEmpty(receiver.trim())){
			toUserId=Integer.valueOf(receiver);
		}
		PageResult<Document> pageResult = tigaseMsgDao.chat_logs_all(startTime, endTime, userId, toUserId, page, limit, keyWord);
		return JSONMessage.success(pageResult);
	}

	@RequestMapping(value = "/chat_logs_all/del", method = { RequestMethod.POST })
	public JSONMessage chat_logs_all_del(@RequestParam(defaultValue = "0") long startTime,
										 @RequestParam(defaultValue = "0") long endTime, @RequestParam(defaultValue = "0") int sender,
										 @RequestParam(defaultValue = "0") int receiver, @RequestParam(defaultValue = "0") int pageIndex,
										 @RequestParam(defaultValue = "25") int pageSize, HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
		}
		tigaseMsgDao.chat_logs_all_del(startTime,endTime,sender,receiver,pageIndex,pageSize);
		return JSONMessage.success();

	}

	@RequestMapping(value = "/deleteChatMsgs")
	public JSONMessage deleteChatMsgs(@RequestParam(defaultValue = "") String msgId,
									  @RequestParam(defaultValue = "0") int type) {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
		}
		if (StringUtil.isEmpty(msgId) && type != 1 && type != 2)
			return JSONMessage.failure("????????????");

		try {
			tigaseMsgDao.deleteChatMsgs(msgId,type);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
		return JSONMessage.success();
	}

	@RequestMapping(value = "/deleteRoom")
	public JSONMessage deleteRoom(@RequestParam(defaultValue = "") String roomId, @RequestParam(defaultValue = "0") Integer userId) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
			}
			roomManager.delete(new ObjectId(roomId),userId);
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}

	// ???????????????????????????
	@RequestMapping(value = "/inviteJoinRoom")
	public JSONMessage inviteJoinRoom(@RequestParam(defaultValue ="") String roomId,@RequestParam(defaultValue = "") String userIds,@RequestParam(defaultValue = "") Integer inviteUserId) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
			}
			if (StringUtil.isEmpty(userIds)) {
				return JSONMessage.failure("?????????????????????");
			}
			Room room = roomManager.getRoom(new ObjectId(roomId));
			if (null == room)
				return JSONMessage.failure("??????????????? ????????????!");
			else if (-1 == room.getS())
				return JSONMessage.failure("???????????????????????????!");
			else {
				List<Integer> userIdList = StringUtil.getIntList(userIds, ",");
				if (room.getMaxUserSize() < room.getUserSize() + userIdList.size())
					return JSONMessage.failure("??????????????? ????????????!");
				User user = new User();
				user.setUserId(inviteUserId);
				user.setNickname("???????????????");
				roomManager.consoleJoinRoom(user, new ObjectId(roomId), userIdList, false);
				return JSONMessage.success();
			}
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ??????????????????
	 *
	 * @param roomId
	 * @param userId
	 * @param pageIndex
	 * @return
	 */
	@RequestMapping(value = "/deleteMember")
	public JSONMessage deleteMember(@RequestParam String roomId, @RequestParam String userId,
									@RequestParam(defaultValue = "0") int pageIndex,@RequestParam String adminUserId) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
			}

			if (StringUtil.isEmpty(userId) || StringUtil.isEmpty(adminUserId))
				return JSONMessage.failure("????????????");
			else {
				User user = userManager.getUser(Integer.valueOf(adminUserId));
				if (null != user) {
					String[] userIds = StringUtil.getStringList(userId);
					for (String strUserids : userIds) {
						Integer strUserId = Integer.valueOf(strUserids);
						roomManager.deleteMember(user, new ObjectId(roomId), strUserId,false);
					}
				} else {
					return JSONMessage.failure("???????????????");
				}
			}
			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failureByErrCode(e.getResultCode());
		}
	}

	@RequestMapping(value = "/deleteUser")
	public JSONMessage deleteUser(@RequestParam(defaultValue = "") String userId) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
			}
			if (!StringUtil.isEmpty(userId)) {
				String[] strUserIds = StringUtil.getStringList(userId, ",");
				userManager.deleteUser(ReqUtil.getUserId(),strUserIds);
			}
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}	public User getUser() {
		Object obj = RequestContextHolder.getRequestAttributes().getAttribute(LOGIN_USER_KEY,
				RequestAttributes.SCOPE_SESSION);
		return null == obj ? null : (User) obj;
	}

	/**
	 * ????????????
	 *
	 * @param startTime
	 * @param endTime
	 * @param room_jid_id
	 * @param page
	 * @param limit
	 * @param request
	 * @return
	 */
	@RequestMapping(value = "/groupchat_logs_all")
	public JSONMessage groupchat_logs_all(@RequestParam(defaultValue = "0") long startTime,
										  @RequestParam(defaultValue = "0") long endTime, @RequestParam(defaultValue = "") String room_jid_id,
										  @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "10") int limit,
										  @RequestParam(defaultValue = "") String keyWord) {
		PageResult<Document> result=null;

		try {
			result =tigaseMsgDao.groupchat_logs_all(startTime,endTime,room_jid_id,page,limit,keyWord);
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}


		return JSONMessage.success(result);
	}

	@RequestMapping(value = "/groupchat_logs_all/del")
	public JSONMessage groupchat_logs_all_del(@RequestParam(defaultValue = "0") long startTime,
											  @RequestParam(defaultValue = "0") long endTime, @RequestParam(defaultValue = "") String msgId,
											  @RequestParam(defaultValue = "") String room_jid_id)
			throws Exception {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
		}
		if (StringUtil.isEmpty(msgId))
			return JSONMessage.failure("????????????");
		tigaseMsgDao.groupchat_logs_all_del(startTime,endTime,msgId,room_jid_id);
		return JSONMessage.success();
	}

	@RequestMapping(value = "/groupchatMsgDel")
	public JSONMessage groupchatMsgDel(@RequestParam(defaultValue = "") String roomJid,
									   @RequestParam(defaultValue = "0") int type) {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
		}

		try {
			tigaseMsgDao.groupchatMsgDel(roomJid,type);
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
		return JSONMessage.success();
	}

	@RequestMapping(value = "/login", method = { RequestMethod.GET })
	public void openLogin(HttpServletRequest request, HttpServletResponse response) {

		String path = request.getContextPath() + "/pages/console/login.html";
		try {
			response.sendRedirect(path);
		} catch (IOException e) {
			e.printStackTrace();
		}

	}

	private boolean interceptAdminLoginWhiteList(String realIp, String account) {
		logger.info("Admin?????????ip:{},??????:{}", realIp, account);
		List<String> ips = whiteLoginListRepository.getLoginWhitelist().get(1);
		if (CollectionUtil.isNotEmpty(ips) && !IPUtil.hitIp(realIp, ips)) {
			return true;
		}
		return false;
	}

	/**
	 * @Description: ???????????????????????????????????????????????????????????????????????????????????????
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 **/
	@RequestMapping(value = "/login", method = { RequestMethod.POST })
	public JSONMsg login(HttpServletRequest request, HttpServletResponse response) throws Exception {
		final Integer code = 86;
		String account = request.getParameter("account");
		//Admin?????????????????????ip
		if (this.interceptAdminLoginWhiteList(ServletUtil.getClientIP(request), account)) return JSONMessage.failure("?????????????????????????????????????????????");
		String password = request.getParameter("password");
		String areaCode = request.getParameter("areaCode");
		HashMap<String, Object> map = new HashMap<>();
		User user = userManager.getUser((StringUtil.isEmpty(areaCode) ? (code + account) : (areaCode + account)));
		if (null == user)
			return JSONMessage.failure("???????????????");
		Role userRole = roleManager.getUserRole(user.getUserId(), null, 5);
		if (null == userRole)
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
		if (null != userRole && -1 == userRole.getStatus())
			return JSONMessage.failure("????????????????????????");
		if (!password.equals(user.getPassword())) {
			password = LoginPassword.encodeFromOldPassword(password);
			if (!password.equals(user.getPassword())) {
				return JSONMessage.failure("????????????????????????");
			}
		}
		Map<String, Object> tokenMap = KSessionUtil.adminLoginSaveToken(user.getUserId().toString(), null);
		map.put("access_Token", tokenMap.get("access_Token"));
		map.put("adminId", user.getTelephone());
		map.put("account", user.getUserId() + "");
		map.put("apiKey", appConfig.getApiKey());
		map.put("role", userRole.getRole() + "");
		map.put("nickname", user.getNickname());
		map.put("registerInviteCode", adminManager.getConfig().getRegisterInviteCode());
		// ????????????????????????
		updateLastLoginTime(user.getUserId());
		return JSONMessage.success(map);
	}

	private void updateLastLoginTime(Integer userId) {
		Role role = new Role(userId);
		roleManager.modifyRole(role);
	}

	@RequestMapping(value = "/logout")
	public JSONMessage logout(HttpServletRequest request, HttpServletResponse response) {
		try {
			request.getSession().removeAttribute(LOGIN_USER_KEY);
			KSessionUtil.removeAdminToken(ReqUtil.getUserId());
			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}

	@RequestMapping(value = "/pushToAll")
	public void pushToAll(HttpServletResponse response, @RequestParam int fromUserId, @RequestParam String body) {

		MessageBean mb = JSON.parseObject(body, MessageBean.class);
		mb.setFromUserId(fromUserId + "");
		
		mb.setMsgType(0);
		mb.setMessageId(StringUtil.randomUUID());
		ThreadUtils.executeInThread(new Callback() {

			@Override
			public void execute(Object obj) {
				List<Integer> allUserId = userManager.getUserDao().getAllUserId();
				allUserId.forEach(userId->{
					try {
						mb.setToUserId(String.valueOf(userId));
						messageService.send(mb);
					} catch (Exception e) {
						e.printStackTrace();
					}
				});

			}
		});
		try {
			response.setContentType("text/html; charset=UTF-8");
			PrintWriter writer = response.getWriter();
			writer.write(
					"<script type='text/javascript'>alert('\u6279\u91CF\u53D1\u9001\u6D88\u606F\u5DF2\u5B8C\u6210\uFF01');window.location.href='/pages/qf.jsp';</script>");
			writer.flush();
			writer.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	@RequestMapping(value = "/roomList")
	public JSONMessage roomList(@RequestParam(defaultValue = "") String keyWorld,@RequestParam(defaultValue = "") String isSecretGroup,
								@RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "15") int limit,@RequestParam(defaultValue = "0") int leastNumbers) {

		PageResult<Room> result = new PageResult<Room>();

		Query query = roomManager.getRoomDao().createQuery();

		if (!StringUtil.isEmpty(keyWorld)) {
			query.addCriteria(Criteria.where("name").regex(keyWorld));
		}
		if (!StringUtil.isEmpty(isSecretGroup)) {
			query.addCriteria(Criteria.where("isSecretGroup").is(Integer.valueOf(isSecretGroup)));
		}
		if(leastNumbers > 0)
			query.addCriteria(Criteria.where("userSize").gt(leastNumbers));
		query.with(Sort.by(Sort.Order.desc("createTime")));
		query.with(PageRequest.of(page-1,limit));
		result.setData(roomManager.getRoomDao().queryListsByQuery(query));
		result.setCount(roomManager.getRoomDao().count(query));

		return JSONMessage.success(result);
	}

	@RequestMapping(value = "/getRoomMember")
	public JSONMessage getRoom(@RequestParam(defaultValue = "") String roomId) {
		Room room = roomManager.consoleGetRoom(new ObjectId(roomId));
		return JSONMessage.success(null, room);
	}

	/**
	 * ?????????????????????
	 *
	 * @param pageIndex
	 * @param pageSize
	 * @param room_jid_id
	 * @return
	 */
	@RequestMapping(value = "/roomMsgDetail")
	public JSONMessage roomDetail(@RequestParam(defaultValue = "0") int page,
								  @RequestParam(defaultValue = "50") int limit, @RequestParam(defaultValue = "") String room_jid_id) {

		PageResult<Document> result =tigaseMsgDao.roomDetail(page,limit,room_jid_id);
		return JSONMessage.success(result);
	}

	/**
	 * ??????????????????????????????
	 *
	 * @param userId
	 * @param startDate
	 * @param endDate
	 * @param page
	 * @param limit
	 * @return
	 */
	@RequestMapping(value = "/getGiftList")
	public JSONMessage getGiftList(@RequestParam(defaultValue = "") String userId, @RequestParam(defaultValue = "") String startDate,
								   @RequestParam(defaultValue = "") String endDate, @RequestParam(defaultValue = "0") int page,
								   @RequestParam(defaultValue = "10") int limit) {
		try {
			PageResult<Givegift> result = liveRoomManager.getGiftList(Integer.valueOf(userId), startDate, endDate, page,
					limit);
			return JSONMessage.success(result);
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}

	}

	@RequestMapping(value = "/userList")
	public JSONMessage userList(@RequestParam(defaultValue = "0") int page,
								@RequestParam(defaultValue = "10") int limit, @RequestParam(defaultValue = "") String onlinestate,
								@RequestParam(defaultValue = "") String keyWord, @RequestParam(defaultValue = "") String startDate,
								@RequestParam(defaultValue = "") String endDate) {
		Query query = userManager.getUserDao().createQuery();

		if (!StringUtil.isEmpty(keyWord)) {
			// Integer ?????????2147483647
			boolean flag = NumberUtil.isNum(keyWord);
			if(flag){
				Integer length = keyWord.length();
				if(length > 9){
					query.addCriteria(
							new Criteria().orOperator(Criteria.where("nickname").regex(keyWord),
									Criteria.where("telephone").regex(keyWord),
									Criteria.where("account").regex(keyWord)));

				}else{
					query.addCriteria(
							new Criteria().orOperator(Criteria.where("nickname").regex(keyWord),
									Criteria.where("telephone").regex(keyWord),
									Criteria.where("_id").is(Integer.valueOf(keyWord)),Criteria.where("account").regex(keyWord)));

				}
			}else{
				query.addCriteria(
						new Criteria().orOperator(Criteria.where("nickname").regex(keyWord),
								Criteria.where("telephone").regex(keyWord),Criteria.where("account").regex(keyWord)));
			}
		}
		if (!StringUtil.isEmpty(onlinestate)) {
			query.addCriteria(Criteria.where("onlinestate").is(Integer.valueOf(onlinestate)));
		}
		if(!StringUtil.isEmpty(startDate) && !StringUtil.isEmpty(endDate)){
			long startTime = 0; //?????????????????????
			long endTime = 0; //?????????????????????,?????????????????????
			startTime = StringUtil.isEmpty(startDate) ? 0 : DateUtil.toDate(startDate).getTime()/1000;
			endTime = StringUtil.isEmpty(endDate) ? DateUtil.currentTimeSeconds() : DateUtil.toDate(endDate).getTime()/1000;
			long formateEndtime = DateUtil.getOnedayNextDay(endTime,1,0);
			query.addCriteria(Criteria.where("createTime").gt(startTime).lte(formateEndtime));
		}
		query.with(PageRequest.of(page-1,limit));
		query.with(Sort.by(Sort.Order.desc("createTime")));
		List<User> pageData=userManager.getUserDao().queryListsByQuery(query);
		// ???????????????
		pageData.forEach(userInfo -> {
			Query logLogQuery = userManager.getUserDao().createQuery("userId", userInfo.getUserId());
			User.UserLoginLog loginLog =userManager.getUserDao().getDatastore().findOne(logLogQuery, User.UserLoginLog.class);
			if (null != loginLog)
				userInfo.setLoginLog(loginLog.getLoginLog());
			try {
				userInfo.setBalance(userManager.getUserMoenyV1(userInfo.getUserId()));
			}catch (Exception e){
				logger.error(e.getMessage());
			}
			userInfo.setPassword("");
			userInfo.setIsOpenResetPwd(SKBeanUtils.getImCoreService().getClientConfig().getIsOpenSecureChat());
		});
		PageResult<User> result = new PageResult<User>();
		result.setData(pageData);
		result.setCount(userManager.getUserDao().count(query));
		return JSONMessage.success(result);
	}
	/**
	 * ??????????????????
	 *
	 * @param pageIndex
	 * @param pageSize
	 * @return
	 */
	@SuppressWarnings("deprecation")
	@RequestMapping(value = "/newRegisterUser")
	public JSONMessage newRegisterUser(@RequestParam(defaultValue = "0") int pageIndex,
									   @RequestParam(defaultValue = "10") int pageSize) {
		Query query = userManager.getUserDao().createQuery();
		long total =userManager.getUserDao().count(query);
		query.with(PageRequest.of(pageIndex,pageSize));
		query.with(Sort.by(Sort.Order.desc("createTime")));
		List<User> pageData = userManager.getUserDao().queryListsByQuery(query);
		PageVO page = new PageVO(pageData, total, pageIndex, pageSize);
		return JSONMessage.success(null, page);
	}

	/**
	 * ????????????
	 *
	 * @param userId
	 * @return
	 */
	@RequestMapping(value = "/restPwd")
	public JSONMessage restPwd(@RequestParam(defaultValue = "0") Integer userId) {
		// ????????????
		if(1000==userId){
			return JSONMessage.failure("????????? ?????????????????????");
		}
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
		}
		if (0 < userId)
			userManager.resetPassword(userId, Md5Util.md5Hex("123456"));
		return JSONMessage.success();
	}

	/**
	 * ??????admin??????
	 *
	 * @param userId
	 * @return
	 */
	@RequestMapping(value = "/updateAdminPassword")
	public JSONMessage updatePassword(@RequestParam(defaultValue="") String oldPassword,@RequestParam(defaultValue = "0") Integer userId, String password) {
		try {
			User user = userManager.getUser(userId);
			if (oldPassword.equals(user.getPassword()) || LoginPassword.encodeFromOldPassword(oldPassword).equals(user.getPassword())) {
				userManager.resetPassword(userId, password);
				return JSONMessage.success();
			}else{
				return JSONMessage.failure("?????????????????????");
			}

		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ??????????????????
	 * @param userId
	 * @param password
	 * @return
	 */
	@RequestMapping(value = "/updateUserPassword")
	public JSONMessage updateUserPassword(@RequestParam(defaultValue = "0") Integer userId, String password){
		try {
			if(1000==userId){
				return JSONMessage.failure("????????? ?????????????????????");
			}
			userManager.resetPassword(userId, password);
			return JSONMessage.success();
		} catch (Exception e) {

			return JSONMessage.failure(e.getMessage());
		}

	}

	/**	 * ????????????
	 *
	 * @param userId
	 * @return
	 */
	@RequestMapping(value = "/friendsList")
	public JSONMessage friendsList(@RequestParam(defaultValue = "0") Integer userId,
								   @RequestParam(defaultValue = "0") Integer toUserId, @RequestParam(defaultValue = "0") int status,
								   @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "10") int limit) {
		try {
			PageResult<Friends> friendsList = friendsManager.consoleQueryFollow(userId, toUserId,
					status, page, limit);
			return JSONMessage.success(friendsList);
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ????????????
	 *
	 * @param userId
	 * @param toUserIds
	 * @return
	 */
	@RequestMapping("/deleteFriends")
	public JSONMessage deleteFriends(@RequestParam(defaultValue = "0") Integer userId,
									 @RequestParam(defaultValue = "") String toUserIds,@RequestParam(defaultValue = "")Integer adminUserId) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}

			if (StringUtil.isEmpty(toUserIds))
				JSONMessage.failure("????????????");
			else {
				String[] toUserId = StringUtil.getStringList(toUserIds, ",");

				//friendsManager.getFriends(userId, toUserId);

				friendsManager.consoleDeleteFriends(userId, adminUserId,toUserId);
			}
			return JSONMessage.success();

		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	@RequestMapping(value = "/getUpdateUser")
	public JSONMessage updateUser(@RequestParam(defaultValue = "0") Integer userId) {
		User user = null;
		if (0 == userId)
			user = new User();
		else {
			user = userManager.getUser(userId);
			List<Integer> userRoles = roleManager.getUserRoles(userId);
			System.out.println("???????????????" + JSONObject.toJSONString(userRoles));
			if (null != userRoles) {
				for (Integer role : userRoles) {
					if (role.equals(2)) {
						user.setUserType(2);
					} else {
						user.setUserType(0);
					}
				}
			}
		}
		return JSONMessage.success(user);
	}

	@RequestMapping(value = "/updateUser")
	public JSONMessage saveUserMsg(HttpServletRequest request, HttpServletResponse response,
								   @RequestParam(defaultValue = "0") Integer userId, @ModelAttribute UserExample example) throws Exception {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
		}
		try {
			if (!StringUtil.isEmpty(example.getTelephone())) {
				example.setPhone(example.getTelephone());
				example.setTelephone(example.getAreaCode() + example.getTelephone());
			}
			// ??????????????????(?????????????????????????????????????????????????????????)
			if (!StringUtil.isEmpty(example.getPassword()))
				example.setPassword(Md5Util.md5Hex(example.getPassword()));

			// ??????????????????
			if (0 == userId) {
				userManager.registerIMUser(example);

			} else {
				userManager.updateUser(userId, example);
				// ???????????????????????????toUserType
//				roleManager.updateFriend(userId, example.getUserType());
			}
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
		return JSONMessage.success();
	}
	/**
	 * @Description:??????????????????
	 * @param page
	 * @param limit
	 * @return
	 **/
	@RequestMapping("/redPacketList")
	public JSONMessage getRedPacketList(@RequestParam(defaultValue = "") String userName,
										@RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "10") int limit,@RequestParam(defaultValue = "") String redPacketId) {
		if(redPacketsManager == null){
			return JSONMessage.success(KConstants.ResultCode.CLOSEPAY,null);
		}
		try {
			if(page!=0){
				page = page-1;
			}
			PageResult<RedPacket> result = (PageResult<RedPacket>)redPacketsManager.getRedPacketList(userName,page , limit,redPacketId);
			//PageResult<RedPacket> result = (PageResult<RedPacket>)redPacketsManager.getRedPacketList(userName,page , limit,redPacketId);
			return JSONMessage.success(result);
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getErrMessage());
		}
	}

	@RequestMapping("/receiveWater")
	public JSONMessage receiveWater(@RequestParam(defaultValue = "") String redId,
									@RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "10") int limit) {
		if(redPacketsManager == null){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.CLOSEPAY);
		}
		try {
			PageResult<RedReceive> result = (PageResult<RedReceive>)redPacketsManager.receiveWater(redId, page-1, limit);
			return JSONMessage.success(result);
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getErrMessage());
		}
	}

	@RequestMapping(value = "/addRoom")
	public JSONMessage addRomm(HttpServletRequest request, HttpServletResponse response, @ModelAttribute Room room,
							   @RequestParam(defaultValue = "") String ids) throws Exception {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
		}

		List<Integer> idList = StringUtil.isEmpty(ids) ? null : JSON.parseArray(ids, Integer.class);
		if (null == room.getId()) {
			User user = userManager.getUser(room.getUserId());
			String jid = com.shiku.utils.StringUtil.randomUUID();
			messageService.createMucRoomToIMServer(jid,user.getPassword(), user.getUserId().toString(),
					room.getName());
			room.setJid(jid);
			roomManager.add(user, room, idList,null);
		}

		return JSONMessage.success();
	}

	@RequestMapping(value = "/updateRoom")
	public JSONMessage updateRoom(HttpServletRequest request, HttpServletResponse response,
								  @ModelAttribute RoomVO roomVo) throws Exception {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}

			User user = userManager.getUserDao().get(roomVo.getUserId());
			if (null == user)
				return JSONMessage.failure("????????????");
			roomManager.update(user, roomVo, 1, 1);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}

		return JSONMessage.success();
	}

	@RequestMapping(value = "/roomUserManager")
	public JSONMessage roomUserManager(@RequestParam(defaultValue = "0") int page,
									   @RequestParam(defaultValue = "10") int limit, @RequestParam(defaultValue = "") String id) throws Exception {

		try {
			PageResult<Room.Member> result = null;
			if (!StringUtil.isEmpty(id)) {
				result = roomManager.getMemberListByPage(new ObjectId(id), page, limit);
			}
			return JSONMessage.success(result);
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}

	}

	@RequestMapping(value = "/roomMemberList")
	public JSONMessage roomMemberList(@RequestParam String id) {
		Object data = roomManager.getMemberList(new ObjectId(id), "");
		return JSONMessage.success(null, data);
	}

	@RequestMapping(value = "/sendMessage", method = { RequestMethod.POST })
	public JSONMessage sendMssage(@RequestParam String body, Integer from, Integer to, Integer count) {
		try {

			logger.info("body=======>  " + body);
			// String msg = new String(body.getBytes("iso8859-1"),"utf-8");
			if (null == from) {
				List<Friends> uList = friendsManager.queryFriendsList(to, 0, 0, count);
				new Thread(new Runnable() {

					@Override
					public void run() {
						User user = null;
						MessageBean messageBean = null;

						for (Friends friends : uList) {
							try {
								user = userManager.getUser(friends.getToUserId());
								messageBean = new MessageBean();
								messageBean.setType(1);
								messageBean.setContent(body);
								messageBean.setFromUserId(user.getUserId() + "");
								messageBean.setFromUserName(user.getNickname());
								//messageBean.setMessageId(UUID.randomUUID().toString());
								messageBean.setToUserId(to.toString());
								messageBean.setMsgType(0);
								messageBean.setMessageId(StringUtil.randomUUID());
								messageService.send(messageBean);
							} catch (Exception e) {
								e.printStackTrace();
							}

						}
					}
				}).start();
			} else {
				new Thread(new Runnable() {

					@Override
					public void run() {
						User user = userManager.getUserDao().get(from);
						MessageBean messageBean = new MessageBean();
						messageBean.setContent(body);
						messageBean.setFromUserId(user.getUserId().toString());
						messageBean.setFromUserName(user.getNickname());
						messageBean.setToUserId(to.toString());
						messageBean.setMsgType(0);
						messageBean.setMessageId(StringUtil.randomUUID());
						messageService.send(messageBean);
					}
				}).start();
			}
			return JSONMessage.success();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return JSONMessage.success();
	}



	private byte[] generateId(String username) throws NoSuchAlgorithmException {
		MessageDigest md = MessageDigest.getInstance("SHA-256");
		return md.digest(username.getBytes());
	}



	/**
	 * ???????????????
	 *
	 * @param name
	 * @param nickName
	 * @param userId
	 * @param page
	 * @param limit
	 * @param status
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/liveRoomList")
	public JSONMessage liveRoomList(@RequestParam(defaultValue = "") String name,
									@RequestParam(defaultValue = "") String nickName, @RequestParam(defaultValue = "0") Integer userId,
									@RequestParam(defaultValue = "0") Integer page, @RequestParam(defaultValue = "10") Integer limit,
									@RequestParam(defaultValue = "-1") Integer status) throws Exception {
		if (paymentManager == null){
			return JSONMessage.success(KConstants.ResultCode.CLOSEPAY,null);
		}
		PageResult<LiveRoom> result = new PageResult<LiveRoom>();
		try {
			result = liveRoomManager.findConsoleLiveRoomList(name, nickName, userId, page, limit, status, 1);
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
		return JSONMessage.success(result);
	}

	/**
	 * ?????????????????????
	 *
	 * @param request
	 * @param response
	 * @param liveRoom
	 * @return
	 * @throws IOException
	 */
	@RequestMapping(value = "/saveNewLiveRoom", method = { RequestMethod.POST })
	public JSONMessage saveNewLiveRoom(HttpServletRequest request, HttpServletResponse response, LiveRoom liveRoom)
	{
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}

			liveRoomManager.createLiveRoom(liveRoom);
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}

		return JSONMessage.success();
	}

	/**
	 * ???????????????
	 *
	 * @param liveRoomId
	 * @return
	 */
	@RequestMapping(value = "/deleteLiveRoom", method = { RequestMethod.POST })
	public JSONMessage deleteLiveRoom(@RequestParam String liveRoomId) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}

			liveRoomManager.deleteLiveRoom(new ObjectId(liveRoomId));
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}

	/**
	 * ????????????????????????
	 *
	 * @param liveRoomId
	 * @param currentState
	 * @return
	 */
	@RequestMapping(value = "/operationLiveRoom")
	public JSONMessage operationLiveRoom(@RequestParam String liveRoomId,
										 @RequestParam(defaultValue = "0") int currentState) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}

			liveRoomManager.operationLiveRoom(new ObjectId(liveRoomId), currentState);
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}

	/**
	 * ?????????????????????
	 *
	 * @param pageIndex
	 * @param name
	 * @param nickName
	 * @param userId
	 * @param pageSize
	 * @param roomId
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/liveRoomUserManager")
	public JSONMessage liveRoomManager(@RequestParam(defaultValue = "0") int pageIndex,
									   @RequestParam(defaultValue = "") String name, @RequestParam(defaultValue = "") String nickName,
									   @RequestParam(defaultValue = "0") Integer userId, @RequestParam(defaultValue = "10") int pageSize,
									   @RequestParam(defaultValue = "") String roomId) throws Exception {
		List<LiveRoom.LiveRoomMember> pageData = Lists.newArrayList();
		pageData = liveRoomManager.findLiveRoomMemberList(new ObjectId(roomId),pageIndex,pageSize);
		PageResult<LiveRoom.LiveRoomMember> result = new PageResult<LiveRoom.LiveRoomMember>();
		result.setData(pageData);
		result.setCount(pageData.size());
		return JSONMessage.success(result);
	}

	/**
	 * ?????????????????????
	 *
	 * @param userId
	 * @param liveRoomId
	 * @param response
	 * @param pageIndex
	 * @return
	 */
	@RequestMapping(value = "/deleteRoomUser")
	public JSONMessage deleteliveRoomUserManager(@RequestParam Integer userId,
												 @RequestParam(defaultValue = "") String liveRoomId, HttpServletResponse response,
												 @RequestParam(defaultValue = "0") int pageIndex) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			liveRoomManager.kick(userId, new ObjectId(liveRoomId));
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}

//	/**
//	 * ??????
//	 *
//	 * @param userId
//	 * @param state
//	 * @param roomId
//	 * @return
//	 */
//	@RequestMapping(value = "/shutup")
//	public JSONMessage shutup(@RequestParam Integer userId, @RequestParam int state, @RequestParam ObjectId roomId) {
//		try {
//			Integer adminUserId = ReqUtil.getUserId();
//			// ????????????
//			byte role = (byte) roleManager.getUserRoleByUserId(adminUserId);
//			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
//				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
//			}
//
//			LiveRoom.LiveRoomMember shutup = liveRoomManager.shutup(adminUserId,state, userId, roomId);
//			System.out.println(JSONObject.toJSONString(shutup));
//			return JSONMessage.success(shutup);
//		} catch (Exception e) {
//			return JSONMessage.failureByException(e);
//		}
//	}

	/**
	 * ??????
	 */
	@RequestMapping(value = "/banplay")
	public void ban() {
		try {

		} catch (Exception e) {
			// TODO: handle exception
		}
	}

	/**
	 * ????????????
	 *
	 * @param name
	 * @param pageIndex
	 * @param pageSize
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/giftList")
	public JSONMessage giftList(@RequestParam(defaultValue = "") String name,
								@RequestParam(defaultValue = "0") int pageIndex, @RequestParam(defaultValue = "10") int pageSize) {
		if (paymentManager == null){
			return JSONMessage.failureByErrCodeAndData(KConstants.ResultCode.CLOSEPAY,null);
		}
		try {
			Map<String, Object> pageData = liveRoomManager.consolefindAllgift(name, pageIndex, pageSize);
			if (null != pageData) {
				long total = (long) pageData.get("total");
				List<Gift> giftList = (List<Gift>) pageData.get("data");
				return JSONMessage.success(new PageVO(giftList, total, pageIndex, pageSize, total));
			}
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}

	/**
	 * ????????????
	 *
	 * @param request
	 * @param response
	 * @param name
	 * @param photo
	 * @param price
	 * @param type
	 * @return
	 * @throws IOException
	 */
	@RequestMapping(value = "/add/gift", method = { RequestMethod.POST })
	public JSONMessage addGift(HttpServletRequest request, HttpServletResponse response, @RequestParam String name,
							   @RequestParam String photo, @RequestParam double price, @RequestParam int type) throws IOException {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			liveRoomManager.addGift(name, photo, price, type);
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}

	/**
	 * ????????????
	 * @param giftId
	 * @return
	 */
	@RequestMapping(value = "/delete/gift")
	public JSONMessage deleteGift(@RequestParam String giftId) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failure("????????????");
			}
			liveRoomManager.deleteGift(new ObjectId(giftId));
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}

	}

	
	/**
	 * ????????????????????????
	 * @param keyword
	 * @param page
	 * @param limit
	 * @return
	 */
	@RequestMapping(value = "/hitiInfoList")
	public JSONMessage hitiInfoList(String keyword, @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "10") int limit) {
		try {
			long totalNum = 0;
			PageResult<ErrorMessage> result = new PageResult<ErrorMessage>();
			Map<Long, List<ErrorMessage>> errorMessageList = errorMessageManage.findErrorMessage(keyword, page-1, limit);
			if (null != errorMessageList.keySet()) {
				for (Long total : errorMessageList.keySet()) {
					totalNum = total;
					result.setData(errorMessageList.get(total));
				}
			}
			//return JSONMessage.success(new PageVO(errorMessageList.get(totalNum), totalNum, page, limit, totalNum));
			result.setCount(totalNum);
			return JSONMessage.success(result);

		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}

	/**
	 * ??????????????????
	 *
	 * @param errorMessage
	 * @return
	 * @throws IOException
	 */
	@RequestMapping(value = "/saveErrorMessage")
	public JSONMessage saveErrorMessage(ErrorMessage errorMessage) throws IOException {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			if (null == errorMessage)
				return JSONMessage.failure("????????????");
			return errorMessageManage.saveErrorMessage(errorMessage);
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}
	}

	/**
	 * ??????????????????
	 *
	 * @param errorMessage
	 * @param id
	 * @return
	 */
	@RequestMapping(value = "/hitiInfoUpdate", method = { RequestMethod.POST })
	public JSONMessage hitiInfoUpdate(ErrorMessage errorMessage, String id) {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
		}
		if (null == errorMessage)
			return JSONMessage.failure("??????????????? errorMessage " + errorMessage);
		ErrorMessage data = errorMessageManage.updataErrorMessage(id, errorMessage);
		if (null == data)
			return JSONMessage.failure("????????????????????????");
		else
			return JSONMessage.success("????????????????????????", data);
	}

	/**
	 * ??????????????????
	 *
	 * @param code
	 * @return
	 */
	@RequestMapping(value = "/deleteErrorMessage")
	public JSONMessage deleteErrorMessage(@RequestParam(defaultValue = "") String code) {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
		}
		if (StringUtil.isEmpty(code))
			return JSONMessage.failure("????????????,code: " + code);
		boolean falg = errorMessageManage.deleteErrorMessage(code);
		if (!falg)
			return JSONMessage.failure("????????????????????????");
		else
			return JSONMessage.success();
	}

	/**
	 * ?????????(?????????)??????
	 *
	 * @param word
	 * @param pageIndex
	 * @param pageSize
	 * @return
	 */
	@RequestMapping(value = "/keywordfilter")
	public JSONMessage keywordfilter(@RequestParam(defaultValue = "") String word,
									 @RequestParam(defaultValue = "0") int pageIndex, @RequestParam(defaultValue = "10") int pageSize) {
		PageResult<KeyWord> pageResult = msgInferceptDAO.queryKeywordPageResult(word, pageIndex+1, pageSize);
		return JSONMessage.success(new PageVO(pageResult.getData(),pageResult.getCount(), pageIndex,  pageSize));
	}

	/**
	 * ????????????????????????
	 * @param userId
	 * @param toUserId
	 * @param page
	 * @param limit
	 * @param type
	 * @param content
	 * @return
	 */
	@RequestMapping(value = "/msgInterceptList")
	public JSONMessage keywordIntercept(@RequestParam(defaultValue = "") Integer userId,@RequestParam(defaultValue = "") String toUserId,
										@RequestParam(defaultValue = "0") int page,@RequestParam(defaultValue = "10") int limit,@RequestParam(defaultValue ="0") int type,
										@RequestParam(defaultValue="") String content){
		PageResult<MsgIntercept> data = msgInferceptManager.webQueryMsgInterceptList(userId, toUserId, page, limit, type, content);
		return JSONMessage.success(data);
	}

	/**
	 * ????????????????????????
	 * @param id
	 * @return
	 */
	@RequestMapping(value = "/deleteMsgIntercept")
	public JSONMessage deleteKeywordIntercept(@RequestParam(defaultValue = "") String id){
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
		}
		msgInferceptManager.deleteMsgIntercept(new ObjectId(id));
		return JSONMessage.success();
	}

	@RequestMapping("/sendMsg")
	public JSONMessage sendMsg(@RequestParam(defaultValue = "") String jidArr,
							   @RequestParam(defaultValue = "1") int userId, @RequestParam(defaultValue = "1") int type,
							   @RequestParam(defaultValue = "") String content) {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
		}
		String[] split = jidArr.split(",");
		roomManager.sendMsgToRooms(split, userId, type, content);
		return JSONMessage.success();
	}

	@RequestMapping("/sendUserMsg")
	public JSONMessage sendUserMsg(@RequestParam(defaultValue = "") int toUserId, @RequestParam(defaultValue = "1") int type,
								   @RequestParam(defaultValue = "") String content) {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
		}
		try {
			adminManager.sendMsgToUser(toUserId, type, content);
			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failureByErrCode(e.getResultCode());
		}
	}



	/**
	 * ???????????????
	 *
	 * @param response
	 * @param id
	 * @param word
	 * @throws IOException
	 * @throws ServletException
	 */
	@RequestMapping(value = "/addkeyword", method = { RequestMethod.POST })
	public JSONMessage addkeyword(HttpServletResponse response, @RequestParam(defaultValue = "") String id,
								  @RequestParam String word) throws IOException {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
		}
		KeyWord keyword = null;

		if (StringUtil.isEmpty(id)) {
			KeyWord word1 = msgInferceptDAO.findOne(KeyWord.class,"word", word);
			if(null!=word1){
				return JSONMessage.failure("??????????????????");
			}
			keyword = new KeyWord();
			keyword.setWord(word);
			keyword.setCreateTime(DateUtil.currentTimeSeconds());
			msgInferceptDAO.getDatastore().save(keyword);
		}else{
			KeyWord keyWord=new KeyWord();
			keyWord.setWord(word);
			keyWord.setCreateTime(DateUtil.currentTimeSeconds());
			msgInferceptDAO.getDatastore().save(keyWord);

		}
		return JSONMessage.success("????????????");
	}

	/**
	 * ???????????????
	 *
	 * @param response
	 * @param id
	 * @return
	 * @throws IOException
	 */
	@RequestMapping(value = "/deletekeyword", method = { RequestMethod.POST })
	public JSONMessage deletekeyword(HttpServletResponse response, @RequestParam String id) throws IOException {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
		}
		msgInferceptManager.deleteKeyword(new ObjectId(id));
		return JSONMessage.success();
	}

	/**
	 * ??????????????????
	 *
	 * @param request
	 * @param response
	 * @param startTime
	 * @param endTime
	 * @param room_jid_id
	 * @throws Exception
	 */
	@RequestMapping(value = "/deleteMsgGroup", method = { RequestMethod.POST })
	public void deleteMsgGroup(HttpServletRequest request, HttpServletResponse response,
							   @RequestParam(defaultValue = "0") long startTime, @RequestParam(defaultValue = "0") long endTime,
							   @RequestParam(defaultValue = "") String room_jid_id) throws Exception {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return ;
		}
		tigaseMsgDao.deleteGroupMsgBytime(startTime,endTime,room_jid_id);

		//referer(response, "/console/groupchat_logs_all?room_jid_id=" + room_jid_id, 0);
	}

	/**
	 * ????????????????????????
	 * @param userNum  ?????????????????????
	 * @param roomId
	 */
	@RequestMapping(value = "/autoCreateUser")
	public JSONMessage autoCreateUser(@RequestParam(defaultValue="10")int userNum,
									  @RequestParam(defaultValue = "") String roomId) {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
		}

		try {
			if(userNum>0) {
				if(!StringUtil.isEmpty(roomId)){
					ObjectId objId=parse(roomId);
					Room room = roomManager.getRoomDao().get(objId);
					if(null==room)
						return JSONMessage.failureByErrCode(KConstants.ResultCode.NotRoom);
					if(room.getMaxUserSize() <room.getUserSize()+userNum)
						return JSONMessage.failure("?????????????????????  ?????????????????????  "+(room.getMaxUserSize()-room.getUserSize())+"???") ;
				}
				userManager.autoCreateUserOrRoom(userNum, roomId,ReqUtil.getUserId());
			}else
				return JSONMessage.failure("????????????1???");
			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}

	}

	/**
	 * ???????????????????????????????????? excel
	 */
	@RequestMapping(value = "/exportData",method = RequestMethod.POST)
	public JSONMessage exportData(HttpServletRequest request, HttpServletResponse response,
								  @RequestParam(defaultValue = "3") short userType) {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
		}
		String fileName = "users.xlsx";

		int maxNum = 30000; // ????????????3????????????
		short onlinestate = -1;

		List<User> userList = userManager.findUserList(0, maxNum, "", onlinestate, userType);

		String name = "???????????????????????????";
		List<String> titles = Lists.newArrayList();
		titles.add("userId");
		titles.add("nickname");
		titles.add("telephone");
		titles.add("password");
		titles.add("sex");
		titles.add("createTime");

		List<Map<String, Object>> values = Lists.newArrayList();
		for (User user : userList) {
			Map<String, Object> map = Maps.newHashMap();
			map.put("userId", user.getUserId());
			map.put("nickname", user.getNickname());
			map.put("telephone", user.getTelephone());
			map.put("password", user.getUserType() == 3 ? "" + (user.getUserId() - 1000) / 2 : user.getPassword());
			map.put("sex", user.getSex() == 1 ? "???" : "???");
			map.put("createTime", Calendar.getInstance());
			values.add(map);
		}

		Workbook workBook = ExcelUtil.generateWorkbook(name, "xlsx", titles, values);
		try {
			response.reset();
			response.setHeader("Content-Disposition",
					"attachment;filename=" + new String(fileName.getBytes(), "utf-8"));
			ServletOutputStream out = response.getOutputStream();
			workBook.write(out);
			// ?????????????????????
			out.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return JSONMessage.success();
	}

	@RequestMapping(value = "/exportExcelByFriends",method = RequestMethod.POST)
	public JSONMessage exportExcelByFriends(HttpServletRequest request, HttpServletResponse response,
											@RequestParam(defaultValue = "0") Integer userId) {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
		}
		try {
			Workbook workBook = adminManager.exprotExcelFriends(userId, request, response);
			ServletOutputStream out = response.getOutputStream();
			workBook.write(out);
			// ?????????????????????
			out.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return JSONMessage.success();
	}

	/**
	 * @Description: ?????????????????????
	 * @param request
	 * @param response
	 * @return
	 *
	 */
	@RequestMapping(value = "/exportExcelByPhone",method = RequestMethod.POST)
	public JSONMessage exportExcelByPhone(HttpServletRequest request, HttpServletResponse response,@RequestParam(defaultValue = "") String startDate,
										  @RequestParam(defaultValue = "") String endDate,@RequestParam(defaultValue = "") String onlinestate,@RequestParam(defaultValue = "") String keyWord) {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
		}
		try {
			Workbook workBook = adminManager.exprotExcelPhone(startDate, endDate, onlinestate, keyWord, request, response);
			ServletOutputStream out = response.getOutputStream();
			workBook.write(out);
			// ?????????????????????
			out.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return JSONMessage.success();
	}



	/**
	 * @Description:???????????????
	 * @param request
	 * @param response
	 * @param roomId
	 * @return
	 **/
	@RequestMapping(value = "/exportExcelByGroupMember",method = RequestMethod.POST)
	public JSONMessage exportExcelByGroupMember(HttpServletRequest request, HttpServletResponse response,
												@RequestParam(defaultValue = "") String roomId) {
		try {
			Workbook workBook = adminManager.exprotExcelGroupMembers(roomId, request, response);
			ServletOutputStream out = response.getOutputStream();
			workBook.write(out);
			// ?????????????????????
			out.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return JSONMessage.success();
	}

	/**
	 * ????????????????????????
	 */
	@RequestMapping(value = "/getUserRegisterCount")
	public JSONMessage getUserRegisterCount(@RequestParam(defaultValue = "0") int pageIndex,
											@RequestParam(defaultValue = "100") int pageSize, @RequestParam(defaultValue = "2") short timeUnit,
											@RequestParam(defaultValue = "") String startDate, @RequestParam(defaultValue = "") String endDate) {

		try {

			Object data = userManager.getUserRegisterCount(startDate.trim(), endDate.trim(), timeUnit);
			return JSONMessage.success(null, data);

		} catch (MongoCommandException e) {
			return JSONMessage.success(0);
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}

	}

	/**
	 * ??????????????????????????????????????????????????? ??????
	 */
	@RequestMapping(value = "/countNum")
	public JSONMessage countNum(HttpServletRequest request, HttpServletResponse response) {

		try {
			long userNum = userManager.getUserDao().count();
			long roomNum = roomManager.countRoomNum();
			long msgNum = messageRepository.getMsgCountNum();
			long friendsNum = friendsManager.getFriendsDao().queryAllFriendsCount();

			Map<String, Long> dataMap = new HashMap<String, Long>();
			dataMap.put("userNum", userNum);
			dataMap.put("roomNum", roomNum);
			dataMap.put("msgNum", msgNum);
			dataMap.put("friendsNum", friendsNum);
			return JSONMessage.success(null, dataMap);

		} catch (MongoCommandException e) {
			return JSONMessage.success(0);
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}

	}

	/**
	 * ????????????????????????
	 */
	@RequestMapping(value = "/chatMsgCount")
	public JSONMessage chatMsgCount(@RequestParam(defaultValue = "0") int pageIndex,
									@RequestParam(defaultValue = "100") int pageSize, @RequestParam(defaultValue = "2") short timeUnit,
									@RequestParam(defaultValue = "") String startDate, @RequestParam(defaultValue = "") String endDate) {

		try {

			Object data = messageRepository.getChatMsgCount(startDate.trim(), endDate.trim(), timeUnit);
			return JSONMessage.success(data);

		} catch (MongoCommandException e) {
			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}

	}

	/**
	 * ???????????????????????????
	 */
	@RequestMapping(value = "/groupMsgCount")
	public JSONMessage groupMsgCount(@RequestParam String roomId, @RequestParam(defaultValue = "0") int pageIndex,
									 @RequestParam(defaultValue = "100") int pageSize, @RequestParam(defaultValue = "2") short timeUnit,
									 @RequestParam(defaultValue = "") String startDate, @RequestParam(defaultValue = "") String endDate) {

		try {

			Object data = messageRepository.getGroupMsgCount(roomId, startDate.trim(), endDate.trim(),
					timeUnit);
			return JSONMessage.success(data);

		} catch (MongoCommandException e) {
			return JSONMessage.success(0);
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}

	}

	/**
	 * ????????????????????????
	 */
	@RequestMapping(value = "/addFriendsCount")
	public JSONMessage addFriendsCount(@RequestParam(defaultValue = "0") int pageIndex,
									   @RequestParam(defaultValue = "100") int pageSize, @RequestParam(defaultValue = "2") short timeUnit,
									   @RequestParam(defaultValue = "") String startDate, @RequestParam(defaultValue = "") String endDate) {

		try {

			Object data = friendsManager.getAddFriendsCount(startDate.trim(), endDate.trim(),
					timeUnit);
			return JSONMessage.success(null, data);

		} catch (MongoCommandException e) {
			return JSONMessage.success(0);
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}

	}

	/**
	 * ????????????????????????
	 */
	@RequestMapping(value = "/addRoomsCount")
	public JSONMessage addRoomsCount(@RequestParam(defaultValue = "0") int pageIndex,
									 @RequestParam(defaultValue = "100") int pageSize, @RequestParam(defaultValue = "2") short timeUnit,
									 @RequestParam(defaultValue = "") String startDate, @RequestParam(defaultValue = "") String endDate) {

		try {

			Object data = roomManager.addRoomsCount(startDate.trim(), endDate.trim(), timeUnit);
			return JSONMessage.success(data);

		} catch (MongoCommandException e) {
			return JSONMessage.success(0);
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}

	}

	/**
	 * ????????????????????????
	 *
	 * @param pageIndex
	 * @param pageSize
	 * @param sign
	 * @param startDate
	 * @param endDate
	 * @param timeUnit
	 * @throws Exception
	 */
	@RequestMapping(value = "/getUserStatusCount")
	public JSONMessage getUserStatusCount(@RequestParam(defaultValue = "0") int pageIndex,
										  @RequestParam(defaultValue = "100") int pageSize, @RequestParam(defaultValue = "2") short timeUnit,
										  @RequestParam(defaultValue = "") String startDate, @RequestParam(defaultValue = "") String endDate)
			throws Exception {

		try {

			Object data = userManager.userOnlineStatusCount(startDate.trim(), endDate.trim(),
					timeUnit);
			return JSONMessage.success(null, data);

		} catch (MongoCommandException e) {
			return JSONMessage.success(0);
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * @Description:???????????????????????????????????????
	 * @param type
	 *            (type = 0????????????????????????,type=1????????????????????????,type=2????????????????????????)
	 * @param
	 * @return
	 **/
	@SuppressWarnings({ "static-access", "unchecked" })
	@RequestMapping(value = "/beReport")
	public JSONMessage beReport(@RequestParam(defaultValue = "0") int type,
								@RequestParam(defaultValue = "0") int sender, @RequestParam(defaultValue = "") String receiver,
								@RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "25") int limit) {
		JSONMessage jsonMessage = new JSONMessage();
		PageResult<Report> pageResult = new PageResult<>();
		try {
			page = page -1;
			pageResult = userManager.getReport(type, sender, receiver, page, limit);
			logger.info("???????????????" + JSONObject.toJSONString(pageResult.getData()));
			return jsonMessage.success(pageResult);
		} catch (Exception e) {
			e.printStackTrace();
			return jsonMessage.failure(e.getMessage());
		}

	}
	@RequestMapping("/isLockWebUrl")
	public JSONMessage isLockWebUrl(@RequestParam(defaultValue = "") String webUrlId,@RequestParam(defaultValue = "-1")int webStatus){
		if (StringUtil.isEmpty(webUrlId))
			return JSONMessage.failure("webUrl is null");
		ObjectId objectId = new ObjectId(webUrlId);
		Report report = reportDao.getReport(objectId);
		if(null == report)
			return JSONMessage.failure("??????????????????????????????");
		reportDao.updateAttribute(objectId,"webStatus", webStatus);
		return JSONMessage.success();
	}

	/**
	 * ????????????
	 *
	 * @param response
	 * @param id
	 * @return
	 * @throws IOException
	 */
	@RequestMapping(value = "/deleteReport")
	public JSONMessage deleteReport(HttpServletResponse response, @RequestParam String id) throws IOException {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failure("????????????");
			}
			Report report = reportDao.getReport(parse(id));
			if(null == report){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.DataNotExists);
			}
			reportDao.deleteReportById(report.getId());
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * api ????????????
	 *
	 * @param keyWorld
	 * @param page
	 * @param limit
	 * @return
	 */
	@RequestMapping(value = "/ApiLogList")
	public JSONMessage apiLogList(@RequestParam(defaultValue = "") String keyWorld,
								  @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "15") int limit) {

		try {
			PageResult<SysApiLog> data = adminManager.apiLogList(keyWorld, page, limit);
			return JSONMessage.success(data);

		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}

	}

	/**
	 * ?????? api ??????
	 *
	 * @param apiLogId
	 * @param type
	 * @return
	 */
	@RequestMapping(value = "/delApiLog")
	public JSONMessage delApiLog(@RequestParam(defaultValue = "") String apiLogId,
								 @RequestParam(defaultValue = "0") int type) {

		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}

			adminManager.deleteApiLog(apiLogId, type);
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * @Description:???????????????????????????
	 * @param limit
	 * @param page
	 * @return
	 **/
	@RequestMapping(value = "/getFriendsMsgList")
	public JSONMessage getFriendsMsgList(@RequestParam(defaultValue = "0") Integer page,
										 @RequestParam(defaultValue = "10") Integer limit, @RequestParam(defaultValue = "") String nickname,
										 @RequestParam(defaultValue = "0") Integer userId) {
		try {
			PageResult<Msg> data = msgManager.getMsgList(page, limit, nickname, userId);
			return JSONMessage.success(data);
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * @Description:?????????????????????
	 * @param userId
	 * @param messageId
	 * @return
	 **/
	@RequestMapping(value = "/deleteFriendsMsg")
	public JSONMessage deleteMsg(@RequestParam String messageId) {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
		}
		if (StringUtil.isEmpty(messageId)) {
//			return Result.ParamsAuthFail;
			return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
		} else {
			try {
				String[] messageIds = StringUtil.getStringList(messageId);
				msgManager.delete(messageIds);
			} catch (Exception e) {
				logger.error("???????????????????????????", e);
				return JSONMessage.failure(e.getMessage());
			}
		}
		return JSONMessage.success();
	}

	/**
	 * @Description:?????????????????????
	 * @param state
	 * @param roomId
	 * @return
	 **/
	@RequestMapping(value = "/lockingMsg")
	public JSONMessage lockingMsg(@RequestParam String msgId, @RequestParam int state) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}

			msgManager.lockingMsg(new ObjectId(msgId), state);
			return JSONMessage.success();
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * @Description:?????????????????????
	 * @return
	 **/
	@RequestMapping(value = "/commonListMsg")
	public JSONMessage commonListMsg(@RequestParam String msgId, @RequestParam(defaultValue = "0") Integer page,
									 @RequestParam(defaultValue = "10") Integer limit) {
		try {
			PageResult<Comment> result =commentManager.commonListMsg(new ObjectId(msgId), page, limit);
			return JSONMessage.success(result);
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * @Description:?????????????????????
	 * @param page
	 * @param limit
	 * @param msgId
	 * @return
	 **/
	@RequestMapping(value = "/praiseListMsg")
	public JSONMessage praiseListMsg(@RequestParam String msgId, @RequestParam(defaultValue = "0") Integer page,
									 @RequestParam(defaultValue = "10") Integer limit) {
		try {
			PageResult<Praise> result = msgPraiseManager.praiseListMsg(new ObjectId(msgId), page, limit);
			return JSONMessage.success(result);
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * @Description:??????????????????
	 * @param messageId
	 * @param commentId
	 * @return
	 **/
	@RequestMapping(value = "/comment/delete")
	public JSONMessage deleteComment(@RequestParam String messageId, @RequestParam String commentId) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failure("????????????");
			}
			if (StringUtil.isEmpty(messageId) || StringUtil.isEmpty(commentId)) {
				return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
			} else {
				commentManager.delete(new ObjectId(messageId), commentId);
				logger.error("??????????????????");
			}
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
		return JSONMessage.success();
	}

	/**
	 * @Description:??????????????????????????????
	 * @param userId
	 * @param status
	 * @return
	 **/
	@RequestMapping("/changeStatus")
	public JSONMessage changeStatus(@RequestParam int userId, @RequestParam int status) {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
		}
		userManager.changeStatus(ReqUtil.getUserId(),userId, status);
		return JSONMessage.success();
	}

	/**
	 * @Description:????????????????????????
	 * @param userId
	 * @param type
	 * @return
	 **/
	@RequestMapping("/systemRecharge")
	public JSONMessage systemRecharge(@RequestParam(defaultValue = "0") int userId,
									  @RequestParam(defaultValue = "0") int type, @RequestParam(defaultValue = "0") int page,
									  @RequestParam(defaultValue = "10") int limit, @RequestParam(defaultValue = "") String startDate,
									  @RequestParam(defaultValue = "") String endDate, @RequestParam(defaultValue = "") String tradeNo) {

		if (paymentManager == null){
			return JSONMessage.success(KConstants.ResultCode.CLOSEPAY,null);
		}
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.FINANCE){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
			}
			PageResult<BaseConsumeRecord> result = (PageResult<BaseConsumeRecord>) paymentManager.recharge(userId, type, page, limit, startDate, endDate ,tradeNo);
			return JSONMessage.success(result);
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getErrMessage());
		}
	}

	/**
	 * ????????????
	 *
	 * @param money
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/Recharge")
	public JSONMessage Recharge(Double money, int userId) throws Exception {
		if (paymentManager == null){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.CLOSEPAY);
		}
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
		}
		double consoleMaxRechargeAmount = SKBeanUtils.getImCoreService().getPayConfig().getConsoleMaxRechargeAmount();
		if(money > consoleMaxRechargeAmount){
			return JSONMessage.failure("??????????????????????????????????????????"+consoleMaxRechargeAmount);
		}
		// ????????????????????????
		if (null == userManager.getUser(userId)) {
			return JSONMessage.failure("????????????, ???????????????!");
		}

		String tradeNo = StringUtil.getOutTradeNo();

//		Map<String, Object> data = Maps.newHashMap();


		try {

			UserMoneyLog userMoneyLog =new UserMoneyLog(userId,userId,tradeNo,money,
					MoenyAddEnum.MOENY_ADD, MoneyLogEnum.ADMIN_RECHARGE, MoneyLogTypeEnum.RECEIVE);

			Double balance = userManager.rechargeUserMoeny(userMoneyLog);
			// ??????????????????

			BaseConsumeRecord record = new BaseConsumeRecord();
			record.setUserId(userId);
			record.setTradeNo(tradeNo);
			record.setMoney(money);
			record.setStatus(KConstants.OrderStatus.END);
			record.setType(KConstants.ConsumeType.SYSTEM_RECHARGE);
			record.setChangeType(KConstants.MOENY_ADD);
			record.setPayType(KConstants.PayType.SYSTEMPAY); // type = 3 ?????????????????????
			record.setDesc("??????????????????");
			record.setTime(DateUtil.currentTimeSeconds());
			record.setOperationAmount(money);
			record.setCurrentBalance(balance);
			record.setBusinessId(userMoneyLog.getBusinessId());
			paymentManager.savaConsumeRecor(record);
//			data.put("balance", balance);
			return JSONMessage.success(balance);
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}

	}

	/** @Description:????????????
	 * @param money
	 * @param userId
	 * @return
	 **/
	@RequestMapping("/handCash")
	public JSONMessage handCash(Double money, int userId){
		if (paymentManager == null){
			return JSONMessage.success(KConstants.ResultCode.CLOSEPAY,null);
			//return JSONMessage.failureByErrCodeAndData(KConstants.ResultCode.CLOSEPAY,null);
		}
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
		}
		double consoleMaxCodePaymentAmount = SKBeanUtils.getImCoreService().getPayConfig().getConsoleMaxCodePaymentAmount();
		if(money > consoleMaxCodePaymentAmount){
			return JSONMessage.failure("????????????????????????????????????????????????"+consoleMaxCodePaymentAmount);
		}
		// ????????????????????????
		if (null == userManager.getUser(userId)) {
			return JSONMessage.failure("????????????, ???????????????!");
		}else{
			Double balance = userManager.getUserMoeny(userId);
			if(balance < money)
				return JSONMessage.failure("????????????");
		}
		String tradeNo = StringUtil.getOutTradeNo();

		try {

			UserMoneyLog userMoneyLog =new UserMoneyLog(userId,userId,tradeNo,money,
					MoenyAddEnum.MOENY_REDUCE, MoneyLogEnum.ADMIN_RECHARGE, MoneyLogTypeEnum.NORMAL_PAY);
			userMoneyLog.setExtra("??????????????????");

			Double balance = userManager.rechargeUserMoeny(userMoneyLog);
			// ??????????????????
			BaseConsumeRecord record = new BaseConsumeRecord();
			record.setUserId(userId);
			record.setTradeNo(tradeNo);
			record.setMoney(money);
			record.setStatus(KConstants.OrderStatus.END);
			record.setType(KConstants.ConsumeType.SYSTEM_HANDCASH);
			record.setChangeType(KConstants.MOENY_REDUCE);
			record.setPayType(KConstants.PayType.SYSTEMPAY); // type = 3 ?????????????????????
			record.setDesc("??????????????????");
			record.setTime(DateUtil.currentTimeSeconds());
			record.setOperationAmount(money);
			record.setCurrentBalance(balance);
			record.setBusinessId(userMoneyLog.getBusinessId());
			paymentManager.savaConsumeRecor(record);
			return JSONMessage.success(balance);
		}catch (MongoCommandException e) {
			return JSONMessage.success(0);
		}catch (MongoQueryException e) {
			return JSONMessage.success(0);
		}  catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ????????????
	 *
	 * @param type
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/userBill")
	public JSONMessage userBill(@RequestParam int userId, int page, int limit, @RequestParam(defaultValue = "") String startDate,
								@RequestParam(defaultValue = "") String endDate,@RequestParam(defaultValue = "0") int type) throws Exception {
		if (paymentManager == null){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.CLOSEPAY);
		}
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.FINANCE){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			// ????????????????????????
			if (null == userManager.getUser(userId)) {
				return JSONMessage.failure("???????????????!");
			}
			//PageResult<BaseConsumeRecord> result = consumeRecordManager.consumeRecordList(userId, page, limit, (byte) 1,startDate,endDate,type);
			PageResult<BaseConsumeRecord> result = (PageResult<BaseConsumeRecord>)paymentManager.consumeRecordList(userId, page, limit, (byte) 1,startDate,endDate,type);
			return JSONMessage.success(result);

		} catch (MongoCommandException e) {
			return JSONMessage.success(0);
		}catch (MongoQueryException e) {
			return JSONMessage.success(0);
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}

	}

	@RequestMapping(value = "/consumeRecordInfo")
	public JSONMessage consumeRecordInfo(String tradeNo){
		if (paymentManager == null){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.CLOSEPAY);
		}
		try {
			//PageResult<BaseConsumeRecord> recordInfo = consumeRecordManager.getConsumeRecordByTradeNo(tradeNo);
			PageResult<BaseConsumeRecord> recordInfo = (PageResult<BaseConsumeRecord>)paymentManager.getConsumeRecordByTradeNo(tradeNo);
			return JSONMessage.success(recordInfo);
		}catch (MongoCommandException e) {
			return JSONMessage.success(0);
		}catch (MongoQueryException e) {
			return JSONMessage.success(0);
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ???????????????
	 *
	 * @param server
	 * @return
	 */
	@RequestMapping(value = "/addServerList")
	public JSONMessage addServerList(@ModelAttribute ServerListConfig server) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			adminManager.addServerList(server);
			return JSONMessage.success();
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ?????????????????????
	 *
	 * @param id
	 * @param pageIndex
	 * @param limit
	 * @return
	 */
	@RequestMapping(value = "/serverList")
	public JSONMessage serverList(@RequestParam(defaultValue = "") String id,
								  @RequestParam(defaultValue = "0") int pageIndex, @RequestParam(defaultValue = "10") int limit) {
		PageResult<ServerListConfig> result = adminManager
				.getServerList((!StringUtil.isEmpty(id) ? new ObjectId(id) : null), pageIndex, limit);
		return JSONMessage.success(null, result);
	}

	@RequestMapping(value = "/findServerByArea")
	public JSONMessage findServerByArea(@RequestParam(defaultValue = "") String area) {
		PageResult<ServerListConfig> result = adminManager.findServerByArea(area);
		return JSONMessage.success(null, result);
	}

	/**
	 * ???????????????
	 *
	 * @param server
	 * @return
	 */
	@RequestMapping(value = "/updateServer")
	public JSONMessage updateServer(@ModelAttribute ServerListConfig server) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			adminManager.updateServer(server);
			return JSONMessage.success();
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ???????????????
	 *
	 * @param id
	 * @return
	 */
	@RequestMapping(value = "/deleteServer")
	public JSONMessage deleteServer(@RequestParam String id) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			adminManager.deleteServer(new ObjectId(id));
			return JSONMessage.success();
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ??????????????????
	 *
	 * @param area
	 * @param pageIndex
	 * @param limit
	 * @return
	 */
	@RequestMapping(value = "/areaConfigList")
	public JSONMessage areaConfigList(@RequestParam(defaultValue = "") String area,
									  @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "10") int limit) {
		PageResult<AreaConfig> result = adminManager.areaConfigList(area, page, limit);
		return JSONMessage.success(result);
	}

	/**
	 * ??????????????????
	 *
	 * @param area
	 * @return
	 */
	@RequestMapping(value = "/addAreaConfig")
	public JSONMessage addAreaConfig(@ModelAttribute AreaConfig area) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			adminManager.addAreaConfig(area);
			return JSONMessage.success();
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}

	}

	/**
	 * ??????????????????
	 *
	 * @param area
	 * @return
	 */
	@RequestMapping(value = "/updateAreaConfig")
	public JSONMessage updateAreaConfig(@ModelAttribute AreaConfig area) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			adminManager.updateAreaConfig(area);
			return JSONMessage.success();
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ??????????????????
	 *
	 * @param id
	 * @return
	 */
	@RequestMapping(value = "/deleteAreaConfig")
	public JSONMessage deleteAreaConfig(@RequestParam String id) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			adminManager.deleteAreaConfig(new ObjectId(id));
			return JSONMessage.success();
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ??????????????????
	 *
	 * @param urlConfig
	 * @return
	 */
	@RequestMapping(value = "/addUrlConfig")
	public JSONMessage addUrlConfig(@ModelAttribute UrlConfig urlConfig) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			UrlConfig data = adminManager.addUrlConfig(urlConfig);
			return JSONMessage.success(data);
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ??????????????????
	 *
	 * @param id
	 * @param type
	 * @return
	 */
	@RequestMapping(value = "/findUrlConfig")
	public JSONMessage findUrlConfig(@RequestParam(defaultValue = "") String id,
									 @RequestParam(defaultValue = "") String type) {
		PageResult<UrlConfig> result = adminManager
				.findUrlConfig((!StringUtil.isEmpty(id) ? new ObjectId(id) : null), type);
		return JSONMessage.success(null, result);

	}

	/**
	 * ????????????
	 *
	 * @param id
	 * @return
	 */
	@RequestMapping(value = "/deleteUrlConfig")
	public JSONMessage deleteUrlConfig(@RequestParam(defaultValue = "") String id) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			adminManager.deleteUrlConfig(!StringUtil.isEmpty(id) ? new ObjectId(id) : null);
			return JSONMessage.success();
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ???????????????
	 *
	 * @param centerConfig
	 * @return
	 */
	@RequestMapping(value = "/addcenterConfig")
	public JSONMessage addCenterConfig(@ModelAttribute CenterConfig centerConfig) {
		try {
			CenterConfig data = adminManager.addCenterConfig(centerConfig);
			return JSONMessage.success(data);
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ?????????????????????
	 *
	 * @param type
	 * @param id
	 * @return
	 */
	@RequestMapping(value = "/findCenterConfig")
	public JSONMessage findCentConfig(@RequestParam(defaultValue = "") String type,
									  @RequestParam(defaultValue = "") String id) {
		PageResult<CenterConfig> result = adminManager.findCenterConfig(type,
				(!StringUtil.isEmpty(id) ? new ObjectId(id) : null));
		return JSONMessage.success(null, result);
	}

	/**
	 * ?????????????????????
	 *
	 * @param id
	 * @return
	 */
	@RequestMapping(value = "/deleteCenter")
	public JSONMessage deleteCenter(@RequestParam String id) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			adminManager.deleteCenter(new ObjectId(id));
			return JSONMessage.success();
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.success();
		}

	}

	/**
	 * ???????????????
	 *
	 * @param totalConfig
	 * @return
	 */
	@RequestMapping(value = "/addTotalConfig")
	public JSONMessage addTotalConfig(@ModelAttribute TotalConfig totalConfig) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			adminManager.addTotalConfig(totalConfig);
			return JSONMessage.success();
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
	}

	@RequestMapping(value = "/addAdmin")
	public JSONMessage addAdmin(@RequestParam(defaultValue = "86") Integer areaCode, @RequestParam String telePhone,
								@RequestParam byte role, @RequestParam(defaultValue = "0") Integer type) {

		try {
			// ????????????
			byte userRole = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(userRole!=KConstants.Admin_Role.SUPER_ADMIN&&userRole!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			// ????????????????????????
			// User user = userManager.getUser(areaCode+account);
			/*
			 * Admin admin =
			 * adminManager.findAdminByAccount(account);
			 * if(admin!=null) { return JSONMessage.failure("??????????????????"); }
			 * adminManager.addAdmin(account, password, role);
			 */
			roleManager.addAdmin(areaCode + telePhone, telePhone, role, type);
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failureByException(e);
		}

	}

	@RequestMapping(value = "/adminList")
	public JSONMessage adminList(@RequestParam String adminId, @RequestParam(defaultValue = "") String keyWorld,
								 @RequestParam(defaultValue = "1") int page, @RequestParam(defaultValue = "10") int limit,
								 @RequestParam(defaultValue = "0") int type, @RequestParam(defaultValue = "0") Integer userId) {
		try {
			// ????????????
//			byte userRoles = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
//			if(userRoles!=KConstants.Admin_Role.SUPER_ADMIN&&userRoles!=KConstants.Admin_Role.ADMIN){
//				return JSONMessage.failure("????????????");
//			}
			Role userRole = roleManager.getUserRole(userId,
					null, 5);
//			if(userRole.getRole()!=KConstants.Admin_Role.ADMIN&&userRole.getRole()!=KConstants.Admin_Role.SUPER_ADMIN){
//				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
//			}else{
//			if(userRole.getRole()==type){
//				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
//			}
//			}
			if (userRole != null && userRole.getRole() == KConstants.Admin_Role.ADMIN || userRole.getRole() == KConstants.Admin_Role.SUPER_ADMIN ||
					userRole.getRole() == KConstants.Admin_Role.TOURIST|| userRole.getRole() == KConstants.Admin_Role.CUSTOMER ||
					userRole.getRole() == KConstants.Admin_Role.FINANCE) {
				PageResult<Role> result = roleManager.adminList(keyWorld, page, limit, type, userId);
				return JSONMessage.success(result);
			} else {
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * @Description:??????????????????????????????
	 * @param adminId
	 * @param toAdminId
	 * @param admin
	 * @return
	 **/
	@RequestMapping(value = "/modifyAdmin")
	public JSONMessage modifyAdmin(@RequestParam Integer adminId, @RequestParam(defaultValue = "") String password,
								   @ModelAttribute Role role) {

		try {
			// ????????????
			byte userRole = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(userRole!=KConstants.Admin_Role.SUPER_ADMIN&&userRole!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}

			if (!StringUtil.isEmpty(password)) {
				User user = userManager.getUser(adminId);
				if (!password.equals(user.getPassword()))
					return JSONMessage.failure("????????????");
			}
			Role oAdmin = roleManager.getUserRole(adminId, null, 5);
			if (oAdmin != null && oAdmin.getRole() == 6 || oAdmin.getRole() == 5) { // role
				// =
				// 1
				// ???????????????
				Object result = roleManager.modifyRole(role);
				return JSONMessage.success(result);
			} else {
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}

		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * @Description:????????????????????????
	 * @param adminId
	 * @return
	 **/
	@RequestMapping(value = "/delAdmin")
	public JSONMessage deleteAdmin(@RequestParam String adminId, @RequestParam Integer type) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			roleManager.delAdminById(adminId, type,ReqUtil.getUserId());
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}

	}

	/**
	 * @Description:???????????????????????????
	 * @param userId
	 * @param toUserId
	 * @return
	 **/
	@RequestMapping("/friendsChatRecord")
	public JSONMessage friendsChatRecord(@RequestParam(defaultValue = "0") Integer userId,
										 @RequestParam(defaultValue = "0") Integer toUserId, @RequestParam(defaultValue = "0") int page,
										 @RequestParam(defaultValue = "10") int limit) {
		try {
			PageResult<Document> result = friendsManager.chardRecord(userId, toUserId, page, limit);
			return JSONMessage.success(result);
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * @Description:????????????????????????????????????
	 * @param messageId
	 * @return
	 **/
	@RequestMapping("/delFriendsChatRecord")
	public JSONMessage delFriendsChatRecord(@RequestParam(defaultValue = "") String messageId) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			if (StringUtil.isEmpty(messageId))
				return JSONMessage.failure("????????????");
			String[] strMessageIds = StringUtil.getStringList(messageId);
			friendsManager.delFriendsChatRecord(strMessageIds);
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * @Description:?????????????????????
	 * @param toUserId
	 * @param type
	 *            0 ??? ?????????????????? 1??????????????????
	 * @return
	 **/
	@SuppressWarnings("static-access")
	@RequestMapping("/blacklist/operation")
	public JSONMessage blacklistOperation(@RequestParam Integer userId, @RequestParam Integer toUserId,
										  @RequestParam(defaultValue = "0") Integer type,@RequestParam(defaultValue = "")Integer adminUserId) {
		JSONMessage jsonMessage = null;
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			if (0 == type) {
				if (friendsManager.isBlack(userId, toUserId))
					return jsonMessage.failure("????????????????????????");
				Friends data = friendsManager.consoleAddBlacklist(userId, toUserId,adminUserId);
				return jsonMessage.success("?????????????????????", data);
			} else if (1 == type) {
				if (!friendsManager.isBlack(userId, toUserId))
					return jsonMessage.failure("?????????" + toUserId + "????????????????????????");
				Friends data = friendsManager.consoleDeleteBlacklist(userId, toUserId,adminUserId);
				return jsonMessage.success("??????????????????", data);
			}
		} catch (Exception e) {
			return jsonMessage.failure(e.getMessage());
		}
		return jsonMessage;

	}

	/**
	 * ????????????app??????
	 *
	 * @param pageIndex
	 * @param pageSize
	 * @return
	 */
	@RequestMapping(value = "/openAppList")
	public JSONMessage openAppList(@RequestParam(defaultValue = "-2") int status,@RequestParam(defaultValue="0") int type,
								   @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "10") int limit,
								   @RequestParam(defaultValue = "") String keyWorld) {
		try {
			PageResult<SkOpenApp> list = adminManager.openAppList(status, type, page, limit, keyWorld);
			return JSONMessage.success(list);
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}

	}

	/**
	 * ????????????app??????
	 *
	 * @param id
	 * @return
	 */
	@RequestMapping(value = "/openAppDetail")
	public JSONMessage openAppDetail(@RequestParam(defaultValue = "") String id) {
		try {
			Object data = openAppManage.appInfo(new ObjectId(id));
			return JSONMessage.success(data);
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ???????????????????????????????????????
	 *
	 * @param id
	 * @param userId
	 * @param status
	 * @return
	 */
	@RequestMapping(value = "/approvedAPP")
	public JSONMessage approved(@RequestParam(defaultValue = "") String id,
								@RequestParam(defaultValue = "") String userId, @RequestParam(defaultValue = "0") int status,
								@RequestParam(defaultValue = "") String reason) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			openAppManage.approvedAPP(id, status, userId, reason);
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ????????????????????????app??????
	 *
	 * @param skOpenApp
	 * @return
	 */
	@RequestMapping(value = "/checkPermission")
	public JSONMessage checkPermission(@ModelAttribute SkOpenApp skOpenApp) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			openAppManage.openAccess(skOpenApp);
			return JSONMessage.success();
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
	}

//	/**
//	 * ????????????????????????web??????
//	 *
//	 * @param skOpenWeb
//	 * @return
//	 */
//	@RequestMapping(value = "/checkWebPermission")
//	public JSONMessage checkWebPermission(@ModelAttribute SkOpenWeb skOpenWeb) {
//		try {
//			SKBeanUtils.getOpenWebAppManage().openAccess(skOpenWeb);
//			return JSONMessage.success();
//		} catch (Exception e) {
//			e.printStackTrace();
//			return JSONMessage.failure(e.getMessage());
//		}
//	}

	/**
	 * ????????????????????????
	 *
	 * @param id
	 * @param accountId
	 * @return
	 */
	@RequestMapping(value = "/deleteOpenApp")
	public JSONMessage deleteOpenApp(@RequestParam(defaultValue = "") String id,
									 @RequestParam(defaultValue = "") String accountId) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			openAppManage.deleteAppById(new ObjectId(id), accountId);
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ??????????????????????????????
	 *
	 * @param pageIndex
	 * @param pageSize
	 * @return
	 */
	@RequestMapping(value = "/checkLogList")
	public JSONMessage checkLogList(@RequestParam(defaultValue = "0") int page,
									@RequestParam(defaultValue = "10") int limit,@RequestParam(defaultValue = "") String keyWorld) {
		try {
			PageResult<SkOpenCheckLog> data = openCheckLogManage.getOpenCheckLogList(page, limit,keyWorld);
			return JSONMessage.success(data);
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ????????????????????????
	 *
	 * @param id
	 * @return
	 */
	@RequestMapping(value = "/delOpenCheckLog")
	public JSONMessage delOpenCheckLog(@RequestParam(defaultValue = "") String id) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			openCheckLogManage.delOpenCheckLog(new ObjectId(id));
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ???????????????????????????
	 *
	 * @param page
	 * @param limit
	 * @return
	 */
	@RequestMapping(value = "/developerList")
	public JSONMessage developerList(@RequestParam(defaultValue = "0") int page,
									 @RequestParam(defaultValue = "10") int limit, @RequestParam(defaultValue = "-2") int status,
									 @RequestParam(defaultValue = "") String keyWorld) {
		try {
			PageResult<SkOpenAccount> data = openAccountManage.developerList(page, limit, status,
					keyWorld);
			return JSONMessage.success(data);
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ???????????????????????????
	 *
	 * @param userId
	 * @return
	 */
	@RequestMapping(value = "/developerDetail")
	public JSONMessage developerDetail(@RequestParam(defaultValue = "") Integer userId) {
		try {
			Object data = openAccountManage.getOpenAccount(userId);
			return JSONMessage.success(data);
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ???????????????????????????
	 *
	 * @param id
	 * @return
	 */
	@RequestMapping(value = "/deleteDeveloper")
	public JSONMessage deleteDeveloper(@RequestParam(defaultValue = "") String id) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			openAccountManage.deleteDeveloper(new ObjectId(id));
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ????????????????????????????????????
	 *
	 * @param id
	 * @param userId
	 * @param status
	 * @return
	 */
	@RequestMapping(value = "/checkDeveloper")
	public JSONMessage checkDeveloper(@RequestParam(defaultValue = "") String id,
									  @RequestParam(defaultValue = "") String userId, @RequestParam(defaultValue = "0") int status) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			openAccountManage.checkDeveloper(new ObjectId(id), status);
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	// ??????????????????????????????????????????
	@RequestMapping(value = "/authInterface")
	public JSONMessage authInterface(@RequestParam(defaultValue="") String appId,@RequestParam(defaultValue="1") int type){
		try {
			openAppManage.authInterfaceWeb(appId, type);
			return JSONMessage.success();

		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	//???????????????
	@RequestMapping(value="/create/inviteCode")
	public JSONMessage createInviteCode(@RequestParam(defaultValue="20") int nums,@RequestParam int userId,@RequestParam short type) throws IOException{
		try {
			adminManager.createInviteCode(nums, userId);
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}

	}

	// ???????????????
	@RequestMapping(value = "/inviteCodeList")
	public JSONMessage inviteCodeList(@RequestParam(defaultValue = "0") int userId,
									  @RequestParam(defaultValue = "") String keyworld, @RequestParam(defaultValue = "-1") short state,
									  @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "10") int limit) {
		try {
			PageResult<InviteCode> data = adminManager.inviteCodeList(userId, keyworld, state, page,
					limit);
			return JSONMessage.success(data);
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	// ???????????????
	@RequestMapping(value = "/delInviteCode")
	public JSONMessage delInviteCode(@RequestParam(defaultValue = "") int userId,
									 @RequestParam(defaultValue = "") String inviteCodeId) {

		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			boolean data = adminManager.delInviteCode(userId, inviteCodeId);
			return JSONMessage.success(data);
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * @Description:??????????????????
	 * @return
	 **/
	@RequestMapping("/pressureTest")
	public JSONMessage pressureTest(@ModelAttribute PressureParam param, HttpServletRequest request) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			if (param.getSendMsgNum() < 100)
				param.setSendMsgNum(100);
			if (param.getTimeInterval() < 30)
				param.setTimeInterval(30);
			if (param.getCheckNum() > 100)
				param.setCheckNum(100);
			System.out.println("pressureTest ====> " + request.getSession().getCreationTime() + " "
					+ request.getSession().getId());
			List<String> jids = StringUtil.getListBySplit(param.getRoomJid(), ",");
			param.setJids(jids);
			param.setSendAllCount(param.getSendMsgNum() * jids.size());
			JSONMessage result = messageService.pressureMucTest(param,ReqUtil.getUserId());
			if (null == result) {
				return JSONMessage.failure("???????????? ?????? ?????????  ????????? ?????? ??????????????????");
			}
			return result;
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ?????????????????????
	 *
	 * @param page
	 * @param limit
	 * @param keyword
	 * @return
	 */
	@RequestMapping(value = "/musicList")
	public JSONMessage queryMusicList(@RequestParam(defaultValue = "0") int page,
									  @RequestParam(defaultValue = "10") Integer limit, @RequestParam(defaultValue = "") String keyword) {
		PageResult<MusicInfo> result =adminManager.queryMusicInfo(page,
				limit, keyword);
		return JSONMessage.success(result);
	}

	/**
	 * ?????????????????????
	 *
	 * @param musicInfo
	 * @return
	 */
	@RequestMapping(value = "/addMusic")
	public JSONMessage addMusic(@ModelAttribute MusicInfo musicInfo) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			musicManager.addMusicInfo(musicInfo);
			return JSONMessage.success();
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}

	}

	/**
	 * ?????????????????????
	 *
	 * @param musicInfoId
	 * @return
	 */
	@RequestMapping(value = "/deleteMusic")
	public JSONMessage deleteMusic(@RequestParam(defaultValue = "") String musicInfoId) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			musicManager.deleteMusicInfo(new ObjectId(musicInfoId));
			return JSONMessage.success();
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}

	}

	/**
	 * ?????????????????????
	 *
	 * @param musicInfo
	 * @return
	 */
	@RequestMapping(value = "/updateMusic")
	public JSONMessage updateMusic(@ModelAttribute MusicInfo musicInfo) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			musicManager.updateMusicInfo(musicInfo);
			return JSONMessage.success();
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ????????????
	 *
	 * @param userId
	 * @param page
	 * @param limit
	 * @return
	 */
	@RequestMapping(value = "/transferList")
	public JSONMessage transferList(@RequestParam(defaultValue = "") String userId,
									@RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "15") int limit,
									@RequestParam(defaultValue = "") String startDate, @RequestParam(defaultValue = "") String endDate) {
		if (paymentManager == null){
			return JSONMessage.success(KConstants.ResultCode.CLOSEPAY,null);
		}
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.FINANCE){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
		}
		PageResult<Transfer> result = adminManager.queryTransfer(page, limit, userId, startDate,
				endDate);
		return JSONMessage.success(result);
	}

	/**
	 * ????????????
	 *
	 * @param userId
	 * @param page
	 * @param limit
	 * @return
	 */
	@RequestMapping(value = "/paymentCodeList")
	public JSONMessage paymentCodeList(@RequestParam(defaultValue = "0") int userId,
									   @RequestParam(defaultValue = "0") int type, @RequestParam(defaultValue = "0") int page,
									   @RequestParam(defaultValue = "15") int limit, @RequestParam(defaultValue = "") String startDate,
									   @RequestParam(defaultValue = "") String endDate) {
		if (paymentManager == null){
			return JSONMessage.success(KConstants.ResultCode.CLOSEPAY,null);
		}
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.FINANCE){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
		}
		//PageResult<BaseConsumeRecord> result = consumeRecordManager.payment(userId, type, page, limit, startDate, endDate);
		PageResult<BaseConsumeRecord> result = (PageResult<BaseConsumeRecord>)paymentManager.payment(userId, type, page, limit, startDate, endDate);
		return JSONMessage.success(result);
	}

	/**
	 * ???????????????????????????
	 *
	 * @param userId
	 * @param page
	 * @param limit
	 * @return
	 */
	@RequestMapping(value = "/getSdkLoginInfoList")
	public JSONMessage getSdkLoginInfoList(@RequestParam(defaultValue = "") String userId,
										   @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "15") int limit) {
		try {
			PageResult<SdkLoginInfo> result = adminManager.getSdkLoginInfoList(page, limit, userId);
			return JSONMessage.success(result);
		} catch (NumberFormatException e) {
			logger.info("error : {}"+e.getMessage());
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ?????????????????????
	 *
	 * @param id
	 * @return
	 */
	@RequestMapping(value = "/deleteSdkLoginInfo")
	public JSONMessage deleteSdkLoginInfo(@RequestParam(defaultValue = "") String id) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			adminManager.deleteSdkLoginInfo(new ObjectId(id));
			return JSONMessage.success();
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
	}

	/** @Description:????????????
	 * @param appId
	 * @param callbackUrl
	 * @param response
	 **/
	@RequestMapping(value = "/oauth/authorize")
	public void authorizeUrl(String appId,String callbackUrl,HttpServletResponse response,HttpServletRequest request) {
		try {
			Map<String, String> webInfo = openAppManage.authorizeUrl(appId, callbackUrl);
			String webAppName = webInfo.get("webAppName");
			webAppName = URLEncoder.encode(webAppName,"UTF-8");
			UserAgent ua = UserAgent.parseUserAgentString(request.getHeader("User-Agent"));
				OperatingSystem os = ua.getOperatingSystem();
			if(DeviceType.MOBILE.equals(os.getDeviceType())) {//?????????
				// ??????app?????????
				if(request.getHeader("User-Agent").toLowerCase().contains("app-shikuimapp")){
					logger.info("?????????,???????????????");
					callbackUrl = URLEncoder.encode(callbackUrl);
				}else{
					logger.info("?????????,???????????????");
					callbackUrl = URLEncoder.encode(URLEncoder.encode(callbackUrl));
				}
			}else{
				callbackUrl = URLEncoder.encode(URLEncoder.encode(callbackUrl));
			}
			logger.info("authorizeUrl callbackUrl : {} , webAppName : {}",callbackUrl,webAppName);
			response.sendRedirect("/pages/websiteAuthorh/index.html"+"?"+"appId="+appId+"&"+"callbackUrl="+callbackUrl+"&webAppName="+webAppName+"&webAppsmallImg="+webInfo.get("webAppsmallImg"));
		} catch (Exception e) {
			logger.error(e.getMessage());
		}

	}

	/**
	 * ??????????????????
	 * @param type
	 * @param body
	 * @return
	 */
	@RequestMapping(value = "/sendSysNotice")
	public JSONMessage sendSysNotice(@RequestParam(defaultValue="0") Integer type,@RequestParam(defaultValue="") String body,@RequestParam(defaultValue="") String title,@RequestParam(defaultValue="") String url){
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}
			if(StringUtil.isEmpty(body) || StringUtil.isEmpty(title))
				return JSONMessage.failure("???????????????????????????");
			adminManager.sendSysNotice(type, body, title,url);
			return JSONMessage.success();
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * @param page
	 * @param limit
	 * @return
	 * 	 		?????????????????????
	 */
	@RequestMapping(value = "/checkOfficialInfo")
	public JSONMessage getOfficialInfo(@RequestParam(defaultValue = "0") int page,
									@RequestParam(defaultValue = "10") int limit) {
		try {
			PageResult<OfficialInfo> data = officialInfoCheck.getOfficialInfoList(page, limit);
			return JSONMessage.success(data);
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	//?????????????????????
	@RequestMapping(value = "/delOfficialInfo")
	public JSONMessage  delOfficialInfo(String id){
		try {
			officialInfoCheck.delOfficialInfoLog(new ObjectId(id));
			return JSONMessage.success();
		}catch (Exception e){
			return JSONMessage.failure(e.getMessage());
		}
	}

	//??????????????????
	@RequestMapping(value = "/getOfficialInfo")
	public JSONMessage getOfficialInfo(String id){
		OfficialInfo officialInfo = officialInfoCheck.getOfficialInfo(new ObjectId(id));
		return JSONMessage.success(officialInfo);
	}

	//??????????????????
	@RequestMapping(value = "/updateOfficialInfo")
	public JSONMessage updateOfficialInfo(String id,int verify,String feedback){
		//????????????
		/*if (1 == verify){
			//??????User???status
			userManager.changeStatus(ReqUtil.getUserId(),verify);
		}*/
		//??????????????????
		OfficialInfo officialInfo = officialInfoCheck.updateOfficialInfo(new ObjectId(id),verify,feedback);
		return JSONMessage.success(officialInfo);
	}

    // ???????????????
	@RequestMapping(value = "/prohibitInviteCode")
	public JSONMessage prohibitInviteCode(@RequestParam(defaultValue = "") String userId,
										  @RequestParam(defaultValue = "") String inviteCodeId,
										  @RequestParam(defaultValue = "")  String status) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION, ReqUtil.getRequestLanguage());
			}

			int sta = Integer.valueOf(status);
			InviteCode inviteCode =inviteCodeDao.findUserInviteCode(Integer.valueOf(userId));
			if (sta == 1){
				inviteCode.setStatus((short)1);		//????????????
			}else{
				inviteCode.setStatus((short)-1);		//????????????
			}

			inviteCodeDao.addInviteCode(inviteCode);
			return JSONMessage.success();
		} catch (Exception e) {
			return JSONMessage.failure(e.getMessage());
		}
	}


	/**
	 * ?????????????????????
	 *
	 * @param page
	 * @param limit
	 * @return
	 */
	@RequestMapping(value = "/friendsterWebsiteList")
	public JSONMessage friendsterWebsiteList(@RequestParam(defaultValue = "0") int page,
										  @RequestParam(defaultValue = "10") Integer limit) {
		PageResult<FriendsterWebsite> result = friendsterWebsiteManager.queryFriendsterWebsiteList(page,
				limit);
		return JSONMessage.success(result);
	}

	/**
	 * ?????????????????????
	 *
	 * @return
	 */
	@RequestMapping(value = "/addFriendsterWebsite")
	public JSONMessage addFriendsterWebsite(@ModelAttribute FriendsterWebsite friendsterWebsite) {
		try {
			if (null == friendsterWebsite ||
					org.apache.commons.lang3.StringUtils.isAnyBlank(friendsterWebsite.getIcon(), friendsterWebsite.getTitle())
			|| org.apache.commons.lang3.StringUtils.isAllBlank(friendsterWebsite.getItunes(), friendsterWebsite.getUrl())) {
				return JSONMessage.failure("????????????????????????");
			}
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if (role != KConstants.Admin_Role.SUPER_ADMIN && role != KConstants.Admin_Role.ADMIN) {
				return JSONMessage.failure("????????????");
			}
			friendsterWebsiteManager.saveFriendsterWebsite(friendsterWebsite);
			return JSONMessage.success();
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}

	}

	/**
	 * ?????????????????????
	 *
	 * @return
	 */
	@RequestMapping(value = "/deleteFriendsterWebsite")
	public JSONMessage deleteFriendsterWebsite(@RequestParam(defaultValue = "") String id) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if (role != KConstants.Admin_Role.SUPER_ADMIN && role != KConstants.Admin_Role.ADMIN) {
				return JSONMessage.failure("????????????");
			}
			friendsterWebsiteManager.deleteById(new ObjectId(id));
			return JSONMessage.success();
		} catch (Exception e) {
			e.printStackTrace();
			return JSONMessage.failure(e.getMessage());
		}

	}

	/**
	 * ???????????????IP??????
	 *
	 * @param page
	 * @param limit
	 * @return
	 */
	@RequestMapping(value = "/loginWhiteList")
	public JSONMessage loginWhiteList() {
		Map<Integer, List<String>> whiteListMap = whiteLoginListRepository.getLoginWhitelist();
		PageResult<LoginWhiteList> result = new PageResult<>();
		if (CollectionUtil.isNotEmpty(whiteListMap)) {
			List<LoginWhiteList> loginWhiteLists = new ArrayList<>();
			whiteListMap.entrySet().forEach(e -> {
				loginWhiteLists.addAll(e.getValue().stream().map(s -> new LoginWhiteList().setType(e.getKey()).setIp(s)).collect(Collectors.toList()));
			});
			result.setCount(loginWhiteLists.size());
			result.setData(loginWhiteLists);
		}
		return JSONMessage.success(result);
	}

	/**
	 * ?????????????????????IP
	 *
	 * @return
	 */
	@RequestMapping(value = "/addLoginWhiteList")
	public JSONMessage addLoginWhiteList(@RequestParam(defaultValue = "") String ip, int type) {
		try {
			if (StringUtils.isBlank(ip)) {
				return JSONMessage.failure("?????????ip");
			}
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if (role != KConstants.Admin_Role.SUPER_ADMIN && role != KConstants.Admin_Role.ADMIN) {
				return JSONMessage.failure("????????????");
			}
			whiteLoginListRepository.addLoginWhitelist(ip, type);
			return JSONMessage.success();
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			return JSONMessage.failure(e.getMessage());
		}

	}

	/**
	 * ?????????????????????IP
	 *
	 * @return
	 */
	@RequestMapping(value = "/deleteLoginWhiteList")
	public JSONMessage deleteLoginWhiteList(@RequestParam(defaultValue = "") String ip, int type) {
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if (role != KConstants.Admin_Role.SUPER_ADMIN && role != KConstants.Admin_Role.ADMIN) {
				return JSONMessage.failure("????????????");
			}
			whiteLoginListRepository.delLoginWhitelist(ip, type);
			return JSONMessage.success();
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			return JSONMessage.failure(e.getMessage());
		}

	}

	/**
	 * ????????????
	 *
	 * ???inputJid?????????????????????currentGroup
	 */
	@RequestMapping(value = "/mergeGroup")
	public JSONMessage mergeGroup(String currentGroupId, String inputRoomId){
		try {
			// ????????????
			byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
			if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
			}

			if (StringUtil.isEmpty(inputRoomId)) {
				return JSONMessage.failure("?????????????????????????????????!");
			}
			if (currentGroupId.equals(inputRoomId)) {
				return JSONMessage.failure("?????????????????????????????????!");
			}
			Room room = roomManager.getRoom(new ObjectId(currentGroupId));
			if (null == room)
				return JSONMessage.failure("??????????????? ????????????!");
			else if (-1 == room.getS())
				return JSONMessage.failure("???????????????????????????!");
			else {
				List<Integer> userIdList = roomManager.getMemberIdList(new ObjectId(inputRoomId));
				if (CollectionUtil.isEmpty(userIdList)) {
					return JSONMessage.failure("?????????????????????????????????????????????????????????!");
				}
				User user = new User();
				user.setUserId(ReqUtil.getUserId());
				user.setNickname("???????????????");
				roomManager.consoleJoinRoom(user, new ObjectId(currentGroupId), userIdList, true);
				return JSONMessage.success();
			}
		} catch (ServiceException e) {
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	 * ?????????????????????
	 *
	 * @param page
	 * @param limit
	 * @return
	 */
	@RequestMapping(value = "/addressBookList")
	public JSONMessage addressBookList(@RequestParam(defaultValue = "0") int page,
											 @RequestParam(defaultValue = "10") Integer limit,
									   @RequestParam(defaultValue = "0") Integer userId) {
		PageResult<AddressBook> result = addressBookManager.getAllForAdmin(userId, page, limit);
		return JSONMessage.success(result);
	}

	/**
	 * ?????????????????????
	 * @param request
	 * @param response
	 * @param userId
	 * @return
	 **/
	@RequestMapping(value = "/exportExcelByAddressBook",method = RequestMethod.POST)
	public JSONMessage exportExcelByAddressBook(HttpServletRequest request, HttpServletResponse response,
												@RequestParam(defaultValue = "0") Integer userId) {
		// ????????????
		byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
		if(role!=KConstants.Admin_Role.SUPER_ADMIN&&role!=KConstants.Admin_Role.ADMIN){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
		}
		String name = userManager.getUser(userId).getNickname() + "??????????????????";
		String fileName ="AddressBook.xlsx";
		PageResult<AddressBook> addressBookPageResult = addressBookManager.getAllForAdmin(userId,1,9999);
		List<AddressBook> addressBooks = addressBookPageResult.getData();
		List<String> titles = Lists.newArrayList();
		titles.add("??????");
		titles.add("??????");

		List<Map<String, Object>> values = Lists.newArrayList();
		addressBooks.forEach(addressBook ->{
			Map<String, Object> map = Maps.newHashMap();
			map.put("??????", addressBook.getToRemarkName());
			map.put("??????", addressBook.getToTelephone());
			values.add(map);
		});

		Workbook workBook = ExcelUtil.generateWorkbook(name, "xlsx", titles, values);
		try {
			response.reset();
			response.setHeader("Content-Disposition",
					"attachment;filename=" + new String(fileName.getBytes(), "utf-8"));
			ServletOutputStream out = response.getOutputStream();
			workBook.write(out);
			// ?????????????????????
			out.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return JSONMessage.success();
	}
}