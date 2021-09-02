package com.shiku.im.user.service.impl;

import com.alibaba.fastjson.JSONObject;
import com.shiku.common.model.PageResult;
import com.shiku.common.model.PageVO;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.comm.utils.*;
import com.shiku.im.common.service.PaymentManager;
import com.shiku.im.company.service.CompanyManager;
import com.shiku.im.config.AppConfig;
import com.shiku.im.entity.Config;
import com.shiku.im.friends.dao.FriendsDao;
import com.shiku.im.friends.entity.Friends;
import com.shiku.im.friends.service.impl.AddressBookManagerImpl;
import com.shiku.im.friends.service.impl.FriendsManagerImpl;
import com.shiku.im.live.dao.LiveRoomDao;
import com.shiku.im.live.dao.LiveRoomMemberDao;
import com.shiku.im.message.IMessageRepository;
import com.shiku.im.message.MessageService;
import com.shiku.im.message.MessageType;
import com.shiku.im.msg.dao.MsgCommentDao;
import com.shiku.im.msg.dao.MsgDao;
import com.shiku.im.msg.dao.MsgPraiseDao;
import com.shiku.im.msg.service.MsgRedisRepository;
import com.shiku.im.room.dao.RoomDao;
import com.shiku.im.room.dao.RoomMemberDao;
import com.shiku.im.room.service.RoomManager;
import com.shiku.im.sms.SMSServiceImpl;
import com.shiku.im.support.Callback;
import com.shiku.im.user.dao.*;
import com.shiku.im.user.entity.*;
import com.shiku.im.user.model.*;
import com.shiku.im.user.service.*;
import com.shiku.im.user.utils.KSessionUtil;
import com.shiku.im.user.utils.UserUtil;
import com.shiku.im.user.utils.WXUserUtils;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.redisson.ex.LockFailException;
import com.shiku.utils.Md5Util;
import com.shiku.utils.StringUtils;
import com.shiku.utils.ValueUtil;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomUtils;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.redisson.api.RAtomicLong;
import org.redisson.api.RLock;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.net.URL;
import java.util.*;
import java.util.concurrent.TimeUnit;

@Slf4j
@SuppressWarnings("deprecation")
@Service(UserManagerImpl.BEAN_ID)
public class UserManagerImpl implements UserManager {

	//余额异常
	static final int BALANCE_DATA_EX = 104004;

	public static final String BEAN_ID = "UserManagerImpl";

	@Autowired
	private UserDao userDao;
    public UserDao getUserDao(){
    	return userDao;
	}

	@Autowired
	private RoleDao roleDao;

	@Autowired
	private RoleManagerImpl roleManager;

	@Lazy
	@Autowired(required=false)
	private FriendsDao friendsDao;

	@Autowired
	private SdkLoginInfoDao sdkLoginInfoDao;
	@Autowired(required=false)
	private CompanyManager companyManager;



	@Autowired(required=false)
	private ReportDao reportDao;

	@Autowired(required=false)
	private OfflineOperationDao offlineOperationDao;

	@Autowired(required=false)
	private WxUserDao wxUserDao;

	@Autowired
	private InviteCodeDao inviteCodeDao;

	@Autowired(required=false)
	private RoomManager roomManager;

	@Autowired(required=false)
	private RoomDao roomDao;
	@Autowired(required=false)
	private RoomMemberDao roomMemberDao;
	@Autowired(required=false)
	private MsgDao msgDao;
	@Autowired(required=false)
	private MsgPraiseDao msgPraiseDao;
	@Autowired(required=false)
	private MsgCommentDao msgCommentDao;
	@Autowired(required=false)
	private LiveRoomDao liveRoomDao;
	@Autowired(required=false)
	private LiveRoomMemberDao liveRoomMemberDao;


	@Autowired(required=false)
	private AddressBookManagerImpl addressBookManager;

	@Autowired(required=false)
	private FriendsManagerImpl friendsManager;

	/*@Autowired(required=false)
	private FriendGroupManagerImpl friendGroupManager;*/

    @Autowired
	private AuthKeysServiceImpl authKeysService;


	@Autowired
	private UserRedisService userRedisService;
	@Autowired
	private UserCoreRedisRepository userCoreRedisRepository;

	@Autowired(required=false)
	private MsgRedisRepository msgRedisRepository;
	@Autowired
	private UserCoreRedisRepository userCoreRedis;

	@Autowired
	private UserCoreService userCoreService;


	@Autowired(required=false)
	@Lazy
	private MessageService messageService;

	@Autowired(required=false)
	private IMessageRepository messageRepository;

	@Autowired(required=false)
	private SMSServiceImpl smsService;

	@Autowired(required=false)
	private UserHandler userHandler;

	@Autowired(required=false)
	private AppConfig appConfig;

	@Autowired(required = false)
	private PaymentManager paymentManager;

	/**
	 * 获取userID的 分布式锁 Key
	 */
	private static final String userIdLockKey="userIdLock";

	/**
	 * increaseUserId name
	 */
	private static final String INCREASE_USERID="increaseUserId";



	@Override
	public User createUser(String telephone, String password) {
		User user = new User();
		user.setUserId(createUserId());
		user.setUserKey(Md5Util.md5Hex(telephone));
		user.setPassword(Md5Util.md5Hex(password));
		user.setTelephone(telephone);

		getUserDao().addUser(user);

		return user;
	}

	@Override
	public void createUser(User user) {
		getUserDao().addUser(user);

	}

	@Override
	public User.UserSettings getSettings(int userId) {
		User.UserSettings settings=null;
		User user=null;
		user=getUser(userId);
		if(null==user)
			return null;
		settings=user.getSettings();
		return null!=settings?settings:new User.UserSettings();
	}

	//不经过Redis 直接从数据库获取数据
	public User getUserFromDB(int userId) {
		//先从 Redis 缓存中获取
		User user = getUserDao().getUser(userId);
		if (null == user) {
			System.out.println("id为" + userId + "的用户不存在");
			friendsManager.deleteFansAndFriends(userId);
			return null;
		} else
			userCoreRedis.saveUserByUserId(userId, user);

		return user;
	}

	@Override
	public User getUser(int userId) {
		//先从 Redis 缓存中获取
		User user =userCoreService.getUser(userId);

		return user;
	}

	public boolean getUserByAccount(String account,Integer userId){
		return null == userDao.getUserByAccount(account,userId);
	}

	public User getUserByAccount(String account) {
		//先从 Redis 缓存中获取
		User user =userCoreRedis.queryUserByAccount(account);
		if(null==user){
				user = getUserDao().queryOne("account", account);
			if (null == user){
				log.info("该用户不存在, account: {}",account);
				return null;
			}
			userCoreRedis.saveUserByAccount(account, user);
		}
		
		return user;
	}
	
	
	/* (non-Javadoc)
	 * @see cn.xyz.mianshi.service.UserManager#getNickName(int)
	 */
	@Override
	public String getNickName(int userId) {
		String nickName=userCoreRedis.queryUserNickName(userId);
		if(!StringUtil.isEmpty(nickName))
			return nickName;
		return (String) getUserDao().getOneFieldById("nickname", userId);
	}
	
	
	public synchronized int getMsgNum(int userId) {
		int userMsgNum = userCoreRedis.getUserMsgNum(userId);
		if(0!=userMsgNum) {
			return userMsgNum;
		}else {
			userMsgNum=(int)getUserDao().getOneFieldById("msgNum",userId);
			userCoreRedis.saveUserMsgNum(userId, userMsgNum);
		}
		/*
		 * if(0==userMsgNum){ updateAttributeByIdAndKey(userId, "msgNum", 0); return 0;
		 * }
		 */
		
		 return userMsgNum;
	}
	
	public synchronized void changeMsgNum(int userId,int num) {
		userCoreRedis.saveUserMsgNum(userId, num);
		getUserDao().updateAttribute(userId,"msgNum",num);

	}
	
	/** @Description:（锁定解锁用户状态） 
	* @param userId
	* @param status
	**/ 
	public void changeStatus(int fromUserId,int userId,int status) {
		getUserDao().updateAttribute(userId,"status",status);
		//维护redis中的数据
		userCoreRedis.cleanUserInfo(userId);

		// 发送xmpp type = 98 的消息通知客户端
		if (-1 == status) {
			ThreadUtils.executeInThread(new Callback() {
				@Override
				public void execute(Object obj) {
					MessageBean messageBean=new MessageBean();
					messageBean.setType(MessageType.CONSOLELOCKUSER);
					messageBean.setFromUserId(String.valueOf(fromUserId));
					messageBean.setFromUserName("后台系统管理员");
					messageBean.setContent("该用户已被后台系统管理员锁定封号处理");
					messageBean.setMessageId(StringUtil.randomUUID());
					messageBean.setToUserId(String.valueOf(userId));
					messageBean.setToUserName(getNickName(userId));
					messageBean.setObjectId(status);
					messageService.send(messageBean);
				}
			});
		}
	}

	@Override
	public UserVo getUser(int userId, int toUserId) {
		User user = getUser(toUserId);
		if(null != user){
			UserVo userVo=new UserVo();
			BeanUtils.copyProperties(user,userVo);

			Friends friends = friendsDao.getFriends(userId,toUserId);
			userVo.setFriends(friends);
			if(userId == toUserId){
				List<Integer> userRoles = roleManager.getUserRoles(userId);
				user.setRole(userRoles);
			}
			// 隐私设置数据
			setUserSettingInfo(userVo,userId,toUserId);
			return userVo;
		}else{
			throw new ServiceException(KConstants.ResultCode.UserNotExist);
		}
	}
	
	private void setUserSettingInfo(UserVo user, Integer userId, Integer toUserId) {
		String phone = getUser(userId).getPhone();
		if(!StringUtil.isEmpty(phone) && !"18938880001".equals(phone)){
			// 上线时间显示
			User.UserLoginLog loginLog = getUserDao().queryUserLoginLog(userId);
			if(null != user.getSettings()){
				if (-1 != user.getSettings().getShowLastLoginTime()) {
					boolean flag = friendsManager.isAddressBookOrFriends(userId, toUserId,
							user.getSettings().getShowLastLoginTime());
					if (flag&&null!=loginLog&&null!=loginLog.getLoginLog())
						user.setShowLastLoginTime(loginLog.getLoginLog().getLoginTime());
				}else if (-1 == user.getSettings().getShowLastLoginTime() && userId.equals(toUserId)) {
					if(null!=loginLog&&null!=loginLog.getLoginLog())
						user.setShowLastLoginTime(loginLog.getLoginLog().getLoginTime());
				}
				// 手机号显示
				if (-1 == user.getSettings().getShowTelephone() && !userId.equals(toUserId)) {
					user.setAreaCode("");
					user.setTelephone("");
					user.setPhone("");
				} else if (2 == user.getSettings().getShowTelephone() || 3 == user.getSettings().getShowTelephone()) {
					if(userId.equals(toUserId))
						return;
					boolean flag = friendsManager.isAddressBookOrFriends(userId, toUserId,
							user.getSettings().getShowTelephone());
					if (!flag) {
						user.setAreaCode("");
						user.setTelephone("");
						user.setPhone("");
					}
				}
			}
	}
		// 朋友圈隐私设置访问相关
		User userInfo = getUser(userId);
		if(null != userInfo.getSettings().getNotSeeFilterCircleUserIds()){
			if(userInfo.getSettings().getNotSeeFilterCircleUserIds().contains(toUserId)){
				user.setNotLetSeeHim(true);
			}
			user.getSettings().setNotSeeFilterCircleUserIds(null);
		}else{
			user.setNotLetSeeHim(false);
		}
		if(null != userInfo.getSettings().getFilterCircleUserIds()){
			if(userInfo.getSettings().getFilterCircleUserIds().contains(toUserId)){
				user.setNotSeeHim(true);
			}
			user.getSettings().setFilterCircleUserIds(null);
		}else{
			user.setNotSeeHim(false);
		}
	}

	@Override
	public User getUser(String telephone) {
		User user=getUserDao().getUser(telephone);
		if(null == user){
			throw new ServiceException(KConstants.ResultCode.UserNotExist);
		}
		return user;
	}
	/**
	 * 
	* @Description: TODO(获取登陆过的设备列表)
	* @param @return    参数
	 */
	public Map<String, User.DeviceInfo> getLoginDeviceMap(Integer userId){
		User.UserLoginLog userLoginLog = getUserDao().findOne(User.UserLoginLog.class,"_id",userId);
		if(null==userLoginLog)
			return null;
		return userLoginLog.getDeviceMap();

	}

	@Override
	public int getUserId(String accessToken) {
		return 0;
	}

	@Override
	public boolean isRegister(String telephone) {
		return 1 == getUserDao().getCount(telephone);
	}

	@Override
	public User login(String telephone, String password) {
		String userKey = Md5Util.md5Hex(telephone);

		User user = getUserDao().getUserv1(userKey, null);
		if (null == user) {
			throw new ServiceException(KConstants.ResultCode.AccountNotExist);
		} else {
			user.setPayPassword("");
			String _md5 = Md5Util.md5Hex(password);

			if (password.equals(user.getPassword()) || _md5.equals(user.getPassword())) {
				return user;
			} else {
				throw new ServiceException(KConstants.ResultCode.AccountOrPasswordIncorrect);
			}
		}
	}
	
	public User mpLogin(String telephone, String password){
		String userKey = Md5Util.md5Hex(telephone);
		User user = getUserDao().getUserv1(userKey, null);
		if (null == user) {
			throw new ServiceException(KConstants.ResultCode.AccountNotExist);
		} else {
			if(2 != user.getUserType())
				throw new ServiceException(KConstants.ResultCode.NO_PERMISSION);
			user.setPayPassword("");
			// 账号密码登录
			if (!password.equals(user.getPassword()) ){
				password= LoginPassword.encodeFromOldPassword(password);
				if(!password.equals(user.getPassword())) {
					//log.info("server {}  client {}",user.getPassword(),password);
					throw new ServiceException(KConstants.ResultCode.AccountOrPasswordIncorrect);

				}
			}
			return user;
		}
	}

	public Map<String, Object> loginV1(LoginExample example) {
		User user = null;
		try {
			user = getUserDao().getUser(example.getUserId());
			// user.getSettings().getAuthSwitch() == 1 &&
			if (!StringUtil.isEmpty(example.getSerial())) {
				Map<String, Object> map = findAuto(user, example.getSerial(), example.getDeviceType());
				if (map != null) {
					return map;
				}
			}
			return loginSuccessV1(user, example);
		} catch (Exception e) {
			throw e;
		}
	}
	public KSession createAutoLoginSesson(UserLoginTokenKey loginTokenKey, String language, String token){
		KSession session;

		if(StringUtil.isEmpty(loginTokenKey.getDeviceId())||StringUtil.isEmpty(token)){
			token=KSessionUtil.getAccess_token(loginTokenKey.getUserId());
		}
		/**
		 * 老版本自动登陆
		 */
		if(!StringUtil.isEmpty(token)) {
			session = userRedisService.queryUserSesson(token);
			if(null!=session)
				return session;
		}


		session=new KSession(loginTokenKey.getUserId(),language,loginTokenKey.getDeviceId());
		session.setLoginToken(loginTokenKey.getLoginToken());
		session.setAccessToken(StringUtil.randomUUID());
		session.setHttpKey(com.shiku.utils.Base64.encode(RandomUtils.nextBytes(16)));
		session.setMessageKey(com.shiku.utils.Base64.encode(RandomUtils.nextBytes(16)));
		session.setPayKey(com.shiku.utils.Base64.encode(RandomUtils.nextBytes(16)));

		userCoreRedisRepository.loginSaveAccessTokenByDeviceId(session.getUserId(),session.getDeviceId(),session.getAccessToken());
		userRedisService.saveUserSesson(session);
		userHandler.refreshUserSessionHandler(session.getUserId(),session);
		return session;
	}

	public  Map<String, Object> createAutoLoginResultMap(KSession session){
		Map<String, Object> result=new HashMap<>();
		result.put("access_token",session.getAccessToken());
		result.put("httpKey",session.getHttpKey());
		result.put("messageKey",session.getMessageKey());
		result.put("payKey",session.getPayKey());

		return  result;
	}

	public Map<String, Object> loginAutoV1(LoginExample example,UserLoginTokenKey userLoginToken,String token) {

		int userId = example.getUserId();
		KSession session=null;
		if(null!=userLoginToken)
			 session=createAutoLoginSesson(userLoginToken,example.getLanguage(),token);
		else {
			userLoginToken=new UserLoginTokenKey();
			userLoginToken.setUserId(userId);
			userLoginToken.setDeviceId("shikuim");
			session = createAutoLoginSesson(userLoginToken, example.getLanguage(), token);
		}
		if(null==session)
			throw new ServiceException(KConstants.ResultCode.LoginTokenInvalid);
		User user = getUser(userId);
		if (null == user)
			throw new ServiceException(KConstants.ResultCode.AccountNotExist);
		else if (-1 == user.getStatus())
			throw new ServiceException(KConstants.ResultCode.ACCOUNT_IS_LOCKED);

		User.LoginLog loginLog = getUserDao().getLogin(userId);

		// 1=没有设备号、2=设备号一致、3=设备号不一致
		int serialStatus = 1;
		if(null != example && null != example.getSerial() && null != loginLog && null != loginLog.getSerial()){

			serialStatus = null == loginLog ? 1 : (example.getSerial().equals(loginLog.getSerial()) ? 2 : 3);
		}
		// 1=令牌存在、0=令牌不存在

		try {

			Map<String, Object> result = createAutoLoginResultMap(session);
			result.put("serialStatus", serialStatus);
			result.put("tokenExists", true);
			result.put("userId", userId);
			result.put("nickname", user.getNickname());
			result.put("name", user.getName());
			result.put("login", loginLog);
			result.put("settings", getSettings(userId));
			result.put("serialStatus", serialStatus);
			result.put("multipleDevices", user.getSettings().getMultipleDevices());
			// 用户角色
			List<Integer> userRoles = roleManager.getUserRoles(userId);
			if(null != userRoles && userRoles.size() > 0)
				result.put("role", (0 == userRoles.size() ? "":userRoles));
			String payPwd = authKeysService.getPayPassword(userId);
			if (StringUtil.isEmpty(payPwd)) {
				result.put("payPassword", "0");
			} else {
				result.put("payPassword", "1");
			}

			//查找出该用户的推广型邀请码(一码多用)
			InviteCode myInviteCode =findUserPopulInviteCode(user.getUserId());
			result.put("myInviteCode", (myInviteCode==null?"":myInviteCode.getInviteCode()));

            // 判断用户是否开启云钱包功能
            String walletUserNo = authKeysService.getWalletUserNo(user.getUserId());
            if(!StringUtil.isEmpty(walletUserNo)){
                result.put("walletUserNo",1);
            }else{
                result.put("walletUserNo",0);
            }

			updateLoc(example.getLatitude(), example.getLongitude(), userId);
            updateIpInfo(userId, example.getIp(), example.getIpLocation());
			getUserDao().updateLoginLogTime(userId);

			examineTigaseUser(userId, user.getPassword());
			destroyMsgRecord(userId);
			return result;
		} catch (NullPointerException e) {
			throw new ServiceException(KConstants.ResultCode.AccountNotExist);
		} catch (Exception e) {
			throw new ServiceException(e.getMessage());
		}
	}

	//密码登陆成功方法
	public Map<String, Object> loginSuccessV1(User user, LoginExample example){
		if (null == user) {
			throw new ServiceException(KConstants.ResultCode.AccountNotExist);
		}else if(-1 == user.getStatus()) {
			throw new ServiceException(KConstants.ResultCode.ACCOUNT_IS_LOCKED);
		}
		if(0==example.getUserId())
			example.setUserId(user.getUserId());
        UserLoginTokenKey loginKey=new UserLoginTokenKey(example.getUserId(),example.getDeviceId());
        loginKey.setLoginKey(com.shiku.utils.Base64.encode(RandomUtils.nextBytes(16)));
        loginKey.setLoginToken(StringUtil.randomUUID());
        userRedisService.saveLoginTokenKeys(loginKey);

		KSession session=createAutoLoginSesson(loginKey,"zh",null);

		Map<String, Object> data=createAutoLoginResultMap(session);

		// 获取上次登录日志
		User.LoginLog login = getUserDao().getLogin(user.getUserId());

		// 保存登录日志
		getUserDao().updateUserLoginLog(user.getUserId(), example);

		data.put("loginKey",loginKey.getLoginKey());
		data.put("loginToken",loginKey.getLoginToken());

		data.put("userId", user.getUserId());

		data.put("nickname", user.getNickname());
		String payPwd = authKeysService.getPayPassword(user.getUserId());
		if(StringUtil.isEmpty(payPwd)){
			data.put("payPassword", 0);
		}else{
			data.put("payPassword", 1);
		}
		// 判断如果是第三方sdk登录,返回客户端
		if(example.getIsSdkLogin()==1){
			data.put("telephone", user.getPhone());
			data.put("areaCode", user.getAreaCode());
			data.put("password", user.getPassword());
		}
		if(1 == example.getLoginType())
			data.put("password", user.getPassword());
		data.put("sex",user.getSex());
		data.put("birthday", user.getBirthday());
		data.put("offlineNoPushMsg", user.getOfflineNoPushMsg());
		data.put("multipleDevices", user.getSettings().getMultipleDevices());
		data.put("login", login);
		data.put("settings", getSettings(user.getUserId()));
		if(StringUtil.isEmpty(login.getSerial())){
			data.put("isupdate", 1);//用户登陆不同设备，通知客户端更新用户
		}else if(!login.getSerial().equals(example.getSerial())){
			data.put("isupdate", 1);
		}else{
			data.put("isupdate", 0);
		}


		//好友关系数量
		try {
			data.put("friendCount", friendsDao.queryAllFriends(user.getUserId()).size());
		}catch (Exception e){
			log.error(e.getMessage(),e);
			data.put("friendCount", 0);
		}
		// 用户角色
		List<Integer> userRoles = roleManager.getUserRoles(user.getUserId());
		if(null != userRoles && userRoles.size() > 0)
			data.put("role", (0 == userRoles.size() ? "":userRoles));
		///检查该用户  是否注册到 Tigase
		examineTigaseUser(user.getUserId(), user.getPassword());
		destroyMsgRecord(user.getUserId());

		// 保存用户登录位置信息
		user.setArea(example.getArea());
		// 地理位置
		User.Loc loc = new User.Loc(example.getLongitude(),example.getLatitude());
		user.setLoc(loc);
		if(null == user.getAccount()){
			user.setAccount(UserUtil.getAccountNo(user.getUserId()));
			user.setEncryAccount(Md5Util.md5Hex(user.getAccount()));
		}
		if(null == user.getEncryAccount())
			user.setEncryAccount(Md5Util.md5Hex(user.getAccount()));
		// 好友权限
		if (null != example.getPermitUserType()) {
			user.setPermitUserType(example.getPermitUserType());
		}
		getUserDao().saveEntity(user);
		// ip
		updateIpInfo(user.getUserId(), example.getIp(), example.getIpLocation());

		//查找出该用户的推广形(一码多用)邀请码
		InviteCode myInviteCode = findUserPopulInviteCode(user.getUserId());
		data.put("myInviteCode", (myInviteCode==null?"":myInviteCode.getInviteCode()));
		//saveIosAppId(user.getUserId(), example.getAppId());

		// 判断用户是否开启云钱包功能
		String walletUserNo = authKeysService.getWalletUserNo(user.getUserId());
		if(!StringUtil.isEmpty(walletUserNo)){
			data.put("walletUserNo",1);
		}else{
			data.put("walletUserNo",0);
		}
		return data;
	}

	@Override
	public Map<String, Object> login(LoginExample example) {
		User user =null;
		try {
			if(0!=example.getUserId())
				user=getUserDao().getUser(example.getUserId());
			else
				user=getUserDao().getUser(example.getAreaCode(),example.getTelephone(), null);
			    loginLogic(user,example);
			return  loginSuccessV1(user,example);
		}catch (Exception e){
			throw  e;
		}
	}


	//查找用户的一码多用,推广型邀请码

	public InviteCode findUserPopulInviteCode(int userId) {

		//获取系统当前的邀请码模式 0:关闭   1:开启一对一邀请(一码一用)    2:开启一对多邀请(一码多用,推广型)
		int inviteCodeMode = SKBeanUtils.getSystemConfig().getRegisterInviteCode();
		if(inviteCodeMode!=2) { //如果当前系统不是推广型邀请码模式,则不返回数据
			return null;
		}

		InviteCode inviteCode = inviteCodeDao.findUserInviteCode(userId);
		if(inviteCode==null) { //如果用户没有一对多，推广型邀请码则生成一个
			//当前邀请码标识号
			long curInviteCodeNo = createInviteCodeNo(1);
			String inviteCodeStr = RandomUtil.idToSerialCode(DateUtil.currentTimeSeconds()+curInviteCodeNo+1+ RandomUtil.getRandomNum(100,1000)); //生成邀请码
			inviteCode = new InviteCode(userId, inviteCodeStr, System.currentTimeMillis(), -1);
			inviteCodeDao.addInviteCode(inviteCode);
		}
		return inviteCode;

	}
	public Map<String, Object> findAuto(User user , String serial,String deviceType){
		//根据用户编号查询以往登录信息
		User.LoginDevices loginDevices = userDao.getLoginDevices(user.getUserId());

		Map<String, Object> mapResultStatus = null;
		if (null != loginDevices) {
			/*boolean anyMatch = loginDevices.getDeviceList().stream()
			.anyMatch(device -> device.getSerial().equals(serial) && device.getDeviceType().equals(deviceType));*/
			boolean flag = false;
			for (User.LoginDevice loginDevice : loginDevices.getDeviceList()) {//第一次注册
				if (StringUtils.isEmpty(loginDevice.getDeviceType()) && serial.equals(loginDevice.getSerial())) {
					flag = true;
					break;
				} else {//不是第一次注册
					if (serial.equals(loginDevice.getSerial()) && loginDevice.getDeviceType().equals(deviceType)) {
						flag = true;
						break;
					}
				}
			}
			log.info("====== flag ===== ：" + flag);
			if (!flag) {
				//获取随机字符串--判断用户是否授权
				String key = StringUtil.randomUUID();
				//设置设备序列号
				Map<String, Object> authMessage = new HashMap<String, Object>();
				authMessage.put("serial", serial);
				//设置设备版本类型
				authMessage.put("deviceType", deviceType);
				//设置状态  0-未授权 ， 1已授权
				authMessage.put("status", "0");
				//保存到redis的session

				//防止redis清空
				Map<String, Object> redisData = new HashMap<String, Object>();
				redisData.put("isNull", "false");
				userRedisService.savaAuthKey("redis_isNull", redisData);

				userRedisService.savaAuthKey(key, authMessage);

				//测试
/*
				Map<String,Object> maps1 = (Map<String,Object>)userRedisService.queryAuthKey(key);
				if(null != maps1){
					System.out.println(maps1.toString());
				}
*/

//				Map<String, Object> maps = (Map<String, Object>) userRedisService.queryAuthKey(key);
				if (1 == SKBeanUtils.getImCoreService().getClientConfig().getIsOpenAuthSwitch()&&1 == user.getSettings().getAuthSwitch()) {
					System.out.println("发送信息了！！！！！！！！");
					//发信息给旧设备
					messageService.pushAuthLoginDeviceMessage(user.getUserId(), key);
					mapResultStatus = new HashMap<>();
					mapResultStatus.put("authKey", key);
				}else{
					addLoginDevices(user.getUserId(), serial, deviceType);
				}
			}
		}else{
			//保存设备版本信息
			savaDeviceMessage(user.getUserId(), serial, deviceType);
		}
		return mapResultStatus;
	}

	/**
	 * 保存登入信息
	 * @param userId 用户Id
	 * @param serial 设备序列号
	 * @param deviceType 设备 类型
	 */
	public void savaDeviceMessage(int userId,String serial,String deviceType){
		System.out.println("用户为空,加入设备号！！！");
			//以往没有登入信息----第一次登入
		User.LoginDevices  lds = new User.LoginDevices();
			//设置编号
		lds.setUserId(userId);
			//设置创建时间
		lds.setCreateTime(System.currentTimeMillis());
			//设置版本号
		User.LoginDevice loginDevice = new User.LoginDevice();
			//设置序列号
			loginDevice.setSerial(serial);
			//设置登入时间
			loginDevice.setAuthTime(DateUtil.currentTimeSeconds());
			//设置设备类型
			loginDevice.setDeviceType(deviceType);
			//设置状态
			loginDevice.setStatus((byte) 0);

		lds.getDeviceList().add(loginDevice);

		//保存到数据库
		userDao.addLoginDevices(lds);

		User.LoginDevices l = userDao.getLoginDevices(userId);

		if (l != null) {
			System.out.println(l.toString());
		}
	}




	/**
	 * 修改状态
	 * @param userId
	 * @param authKey
	 */
	public Map<String, Object> updateStatus(int userId, String authKey) {
		Map<String, Object> map = (Map<String, Object>) userRedisService.queryAuthKey(authKey);
		if (null != map) {
			//修改为已授权状态
			map.put("status", "1");
			System.out.println(map.get("status"));
			userRedisService.savaAuthKey(authKey, map);
			addLoginDevices(userId,(String) map.get("serial"),(String) map.get("deviceType"));
			/*User.LoginDevices loginDevices = new User.LoginDevices();
			loginDevices = userDao.getLoginDevices(userId);
			User.LoginDevice loginDevice = new User.LoginDevice();
			//获取设备类型  与 设备序列号
			loginDevice.setSerial((String) map.get("serial"));
			loginDevice.setDeviceType((String) map.get("deviceType"));
			//设置创建时间
			loginDevice.setAuthTime(DateUtil.currentTimeMilliSeconds());
			//设置状态
			loginDevice.setStatus((byte) 0);
			//保存到数据库
			loginDevices.getDeviceList().add(loginDevice);
			userDao.addLoginDevices(loginDevices);*/
		}
		return map;
	}

	public void addLoginDevices(int userId,String serial,String deviceType){
		// = new User.LoginDevices()
		User.LoginDevices loginDevices;
		loginDevices = userDao.getLoginDevices(userId);
		if(loginDevices.getDeviceList().contains(serial)){
			log.info("该设备已经授权，无需重复授权");
			return;
		}
		User.LoginDevice loginDevice = new User.LoginDevice();
		//获取设备类型  与 设备序列号
		loginDevice.setSerial(serial);
		loginDevice.setDeviceType(deviceType);
		//设置创建时间
		loginDevice.setAuthTime(DateUtil.currentTimeSeconds());
		//设置状态
		loginDevice.setStatus((byte) 0);
		//保存到数据库
		loginDevices.getDeviceList().add(loginDevice);
		userDao.addLoginDevices(loginDevices);
	}

	/**
	 * 登陆逻辑操作
	 * @param user
	 * @param example
	 * @return
	 */
	public  boolean loginLogic(User user,LoginExample example){
		if (null == user) {
			throw new ServiceException(KConstants.ResultCode.AccountNotExist);
		}else if(-1 == user.getStatus()){
			throw new ServiceException(KConstants.ResultCode.ACCOUNT_IS_LOCKED);
		}else {
			if(0 == example.getLoginType()){
				// 账号密码登录
				String password = example.getPassword();
				if (!password.equals(user.getPassword()) ){
					password=LoginPassword.encodeFromOldPassword(password);
					if(StringUtil.isEmpty(password)||!password.equals(user.getPassword()))
					 throw new ServiceException(KConstants.ResultCode.AccountOrPasswordIncorrect);
				}

			}else if (1 == example.getLoginType()) {
				// 短信验证码登录
				if(null == example.getVerificationCode())
					throw new ServiceException(KConstants.ResultCode.SMSCanNotEmpty);
				if(!smsService.isAvailable(user.getTelephone(),example.getVerificationCode()))
					throw new ServiceException(KConstants.ResultCode.VerifyCodeErrOrExpired);
				// 清除短信验证码
				smsService.deleteSMSCode(user.getTelephone());
			}
			//登录成功后维护客服模块当前用户的会话人数和会话状态
			if (null == user.getUserId()) {
				throw new ServiceException(KConstants.ResultCode.FailedGetUserId);
			}else{
				//将用户的客服模式置为关闭
				User.UserSettings settings = user.getSettings();
				settings.setOpenService(0);
				user.setSettings(settings);
				updateSettings(user.getUserId(),user.getSettings());
				//将客服模块分配状态置为不分配
				companyManager.modifyEmployeesByuserId(user.getUserId());
			}
			return true;
		}
	}



	public Map<String, Object> smsLogin(LoginExample example){
		// 短信验证码登录

		User user=getUser(example.getTelephone());

		if(user.getSettings().getAuthSwitch()==1&&!StringUtil.isEmpty(example.getSerial())){
			Map<String, Object> map = findAuto(user, example.getSerial(),example.getDeviceType());
			if(map != null){
				return map;
			}
		}
		// 清除短信验证码
		smsService.deleteSMSCode(example.getTelephone());
		Map<String, Object> result = loginSuccessV1(user, example);
		if(null!=result){
			AuthKeys authKeys = authKeysService.getAuthKeys(example.getUserId());
			if(null!=authKeys&&null!=authKeys.getMsgDHKeyPair()&&!StringUtil.isEmpty(authKeys.getMsgDHKeyPair().getPrivateKey())){
				result.put("isSupportSecureChat",1);
			}
		}
		return result;

	}
	
	private void updateLoc(double latitude, double longitude, Integer userId) {
		User.Loc loc = new User.Loc(longitude, latitude);
		getUserDao().updateLoc(userId,loc);
	}

	private void updateIpInfo(Integer userId, String ip, String ipLocation) {
		User.IpInfo ipInfo = new User.IpInfo();
		if (StringUtil.isEmpty(ip) && StringUtil.isEmpty(ipLocation)) {
			return;
		}
		ipInfo.setIp(ip);
		ipInfo.setIpLocation(ipLocation);
		getUserDao().updateIpInfo(userId, ipInfo);
	}

	public void savePushToken(Integer userId, User.DeviceInfo info){
		userDao.savePushToken(userId,info);
		
	}
	public void saveVoipPushToken(Integer userId,String token){
		/*Query<UserLoginLog> query=getDatastore().createQuery(UserLoginLog.class);
		query.filter("_id", userId);
		UpdateOperations<UserLoginLog> ops = getDatastore().createUpdateOperations(UserLoginLog.class);
		try {
				//ops.set("deviceMap."+KConstants.DeviceKey.IOS+".pushServer",info.getPushServer());
				ops.set("deviceMap."+KConstants.DeviceKey.IOS+".voipToken",token);
				//ops.set("deviceMap."+KConstants.DeviceKey.IOS+".appId",appId);

			getDatastore().update(query, ops);
		} catch (Exception e) {
			e.printStackTrace();
		}*/
		User.DeviceInfo deviceInfo = userCoreRedis.getIosPushToken(userId);
		if(null!=deviceInfo){
			deviceInfo.setVoipToken(token);
			userCoreRedis.saveIosPushToken(userId, deviceInfo);
		}
	}
	
	public void saveIosAppId(Integer userId,String appId){
		if(StringUtil.isEmpty(appId))
			return;
		getUserDao().saveIosAppId(userId,appId);
		
	}
	public void cleanPushToken(Integer userId, String devicekey) {
//		Query<UserLoginLog> query = getDatastore().createQuery(UserLoginLog.class);
//
//		query.field("_id").equal(userId);
//		UpdateOperations<UserLoginLog> ops = getDatastore().createUpdateOperations(UserLoginLog.class);
//		ops.set("loginLog.offlineTime",DateUtil.currentTimeSeconds());

		try {
			if(KConstants.DeviceKey.Android.equals(devicekey)){
				userCoreRedis.removeAndroidPushToken(userId);
			}else if (KConstants.DeviceKey.IOS.equals(devicekey)) {
				userCoreRedis.removeIosPushToken(userId);
			}
//			if(!StringUtil.isEmpty(devicekey))	{
//				ops.set("deviceMap."+devicekey+".pushServer","");
//				ops.set("deviceMap."+devicekey+".pushToken","");
//			}
//
//			getDatastore().update(query, ops);
			getUserDao().updateDeviceMap(userId,devicekey);
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		
	}
	
	@Override
	public void logout(String access_token,String areaCode,String userKey,String devicekey) {
		
		cleanPushToken(ReqUtil.getUserId(),devicekey);
		KSession session=userRedisService.queryUserSesson(access_token);
		userRedisService.cleanUserSesson(access_token);
		userRedisService.cleanLoginTokenKeys(session.getLoginToken());
	}

	@Override
	public List<Document> query(UserQueryExample param) {
		return getUserDao().queryUser(param);
	}
	public List<User> queryPublicUser(int page,int limit,String keyWorld) {
		return userDao.queryPublicUser(page,limit,keyWorld);

	}
	@SuppressWarnings("unchecked")
	@Override
	public Map<String, Object> register(UserExample example) {
		if (isRegister(example.getTelephone())) {
			throw new ServiceException(KConstants.ResultCode.PhoneRegistered);
		}
		String redisKey = userRedisService.buildRedisKey(LOCK_REGISTER_KEY, example.getTelephone());
		try {
			return (Map<String, Object>) userRedisService.executeOnLock(redisKey, back->registerOnLock(example));
		} catch (LockFailException e) {
			throw new ServiceException(KConstants.ResultCode.SystemIsBusy);
		} catch (InterruptedException e) {
			Thread.currentThread().interrupt();
			throw new ServiceException(KConstants.ResultCode.SystemIsBusy);
		}

	}

	private Map<String, Object> registerOnLock(UserExample example) {

		//生成userId
		Integer userId = createUserId();
		if(userDao.exists("_id",userId)){
			throw new ServiceException(KConstants.ResultCode.SystemIsBusy);
		}
		//新增用户
		Map<String, Object> data = getUserDao().addUser(userId, example);

		if(null != data) {
			try {
				userHandler.registerToIM(userId.toString(), example.getPassword());
			} catch (Exception e) {
				e.printStackTrace();
			}
			return data;
		}
		throw new ServiceException(KConstants.ResultCode.FailedRegist);

	}


	/**
	 * 余额改变 分布式锁
	 */
	private static final String LOCK_REGISTER_KEY="lock:register:%s";

	@SuppressWarnings("unchecked")
	@Override
	public Map<String, Object> registerIMUser(UserExample example) {
		String redisKey = userRedisService.buildRedisKey(LOCK_REGISTER_KEY, example.getTelephone());
		try {
			return (Map<String, Object>) userRedisService.executeOnLock(redisKey, back->registerIMUserOnLock(example));
		} catch (LockFailException e) {
			throw new ServiceException(KConstants.ResultCode.SystemIsBusy);
		} catch (InterruptedException e) {
			Thread.currentThread().interrupt();
			throw new ServiceException(KConstants.ResultCode.SystemIsBusy);
		}
	}
	private Map<String, Object> registerIMUserOnLock(UserExample example) {

		// 检查手机号是否已经注册
		if (isRegister(example.getTelephone())) {
			throw new ServiceException(KConstants.ResultCode.PhoneRegistered);
		}

		// 生成userId
		Integer userId = createUserId();
		if(userDao.exists("_id",userId)){
			throw new ServiceException(KConstants.ResultCode.SystemIsBusy);
		}
		example.setUserId(userId);

		userHandler.registerBeforeHandler(userId,example);//校验邀请码



		//example.setAccount(userId+StringUtil.randomCode());
		// 新增用户
		Map<String, Object> data = getUserDao().addUser(userId, example);

		//保存设备信息
		if (null == userDao.getLoginDevices(userId)&&!StringUtil.isEmpty(example.getSerial())) {
			savaDeviceMessage(userId, example.getSerial(), example.getDeviceType());
		}

		if (null != data) {
			try {
				userHandler.registerToIM(userId.toString(), example.getPassword());
				userHandler.registerAfterHandler(userId,example);
				// 清除短信验证码
				smsService.deleteSMSCode(example.getTelephone());
			} catch (Exception e) {
				e.printStackTrace();
				throw e;
			}


			LoginExample loginExample=new LoginExample();
			loginExample.setUserId(example.getUserId());
			loginExample.setDeviceId(loginExample.getDeviceId());
			loginExample.setLongitude(example.getLongitude());
			loginExample.setLatitude(example.getLatitude());
			loginExample.setPermitUserType(example.getPermitUserType());
			return loginSuccessV1(getUser(example.getUserId()),loginExample);
		}
		throw new ServiceException(KConstants.ResultCode.FailedRegist);
	}
	
	
	@Override
	public Map<String, Object> registerIMUserBySdk(UserExample example, int type) throws Exception {
		String wxAccount=example.getAccount();
		Map<String, Object> resultMap=registerUser(example);

		SdkLoginInfo entity=new SdkLoginInfo();
		entity.setUserId(example.getUserId());
		entity.setType(type);
		entity.setLoginInfo(wxAccount);
		sdkLoginInfoDao.saveEntity(entity);
		return resultMap;
	}


	private Map<String, Object> registerUser(UserExample example) throws Exception {
		// 检查手机号是否已经注册
		if (isRegister(example.getTelephone()))
			throw new ServiceException(KConstants.ResultCode.PhoneRegistered);
		
		// 生成userId
		Integer userId = createUserId();
		example.setUserId(userId);
		// 核验邀请码,及相关操作
		userHandler.registerBeforeHandler(userId,example);
		
		// 新增用户
		Map<String, Object> data = getUserDao().addUser(userId, example);
		if (null != data) {
			try {
				userHandler.registerToIM(userId.toString(), example.getPassword());


				userHandler.registerAfterHandler(userId,example);
				// 清除短信验证码
				smsService.deleteSMSCode(example.getTelephone());
			} catch (Exception e) {
				e.printStackTrace();
				throw e;
			}
			LoginExample loginExample=new LoginExample();
			loginExample.setUserId(example.getUserId());
			loginExample.setDeviceId(loginExample.getDeviceId());

			return loginSuccessV1(getUser(example.getUserId()),loginExample);
		}
		throw new ServiceException(KConstants.ResultCode.FailedRegist);
	}
	/**
	 * type = -1  屏蔽某人的朋友圈，
	 * type = 1 不让某人看我的朋友圈
	 */
	public void filterCircleUser(int toUserId,int type) {
		Integer userId = ReqUtil.getUserId();
		User.UserSettings settings = getSettings(userId);
		if(-1 == type){
			if(null==settings.getFilterCircleUserIds()) {
				settings.setFilterCircleUserIds(new HashSet<>());
			}
			settings.getFilterCircleUserIds().add(toUserId);
		}else if(1 == type){
			if(null==settings.getNotSeeFilterCircleUserIds()) {
				settings.setNotSeeFilterCircleUserIds(new HashSet<>());
			}
			settings.getNotSeeFilterCircleUserIds().add(toUserId);
		}
		updateSettings(userId, settings);
	}
	/**
	 * type = -1 取消 屏蔽 某人的生活圈，短视频
	 * type = 1 取消某人不让看我的生活圈，短视频
	 */
	public void cancelFilterCircleUser(int toUserId,int type) {
		Integer userId = ReqUtil.getUserId();
		User.UserSettings settings = getSettings(userId);
		if(-1 == type){
			if(null!=settings.getFilterCircleUserIds()) {
				settings.getFilterCircleUserIds().remove(toUserId);
			}
		}else if(1 == type){
			if(null!=settings.getNotSeeFilterCircleUserIds()) {
				settings.getNotSeeFilterCircleUserIds().remove(toUserId);
			}
		}
		updateSettings(userId, settings);
	}
	

	
	
	

	
	
	/**
	 * 管理后台自动创建用户 或者 群组
	 *
	 * @param example
	 * @return
	 */
	public void autoCreateUserOrRoom(int userNum,String roomId,Integer adminUserId) {
		
		ThreadUtils.executeInThread(new Callback() {
			@Override
			public void execute(Object obj) {
				boolean isJoinRoom = false;
				ObjectId  objRoomId = null;
				if(!roomId.isEmpty() && roomId!=null){
					objRoomId = new ObjectId(roomId);
					isJoinRoom = true;
				}
				addRobot(userNum, isJoinRoom, objRoomId, adminUserId);
			}
		});
	}
	
	public List<Integer> addRobot(int userNum,boolean isJoinRoom,ObjectId objRoomId,Integer adminUserId){
		Random rand = new Random();
		List<Integer> userIds = new ArrayList<Integer>();
		UserExample  userExample= new UserExample();
		//3=机器账号，由系统自动生成
		userExample.setAreaCode("86");
		userExample.setBirthday(DateUtil.currentTimeSeconds());
		userExample.setCountryId(ValueUtil.parse(0));
		userExample.setProvinceId(ValueUtil.parse(0));
		userExample.setCityId(ValueUtil.parse(400300));
		userExample.setAreaId(ValueUtil.parse(0));
		int j = 0;
		for (int i = 1; i <=userNum; i++) {
			//生成userId
			Integer userId = createUserId();
			userIds.add(userId);
			String  name = i%3 == 0 ? RandomUtil.getRandomZh(rand.nextInt(3)+2): 
				RandomUtil.getRandomEnAndNum(rand.nextInt(4)+2);
			userExample.setPassword(Md5Util.md5Hex(""+(userId-1000)/2));
			userExample.setTelephone("86"+String.valueOf(userId));
			userExample.setPhone(String.valueOf(userId));
			userExample.setName(name);
			userExample.setNickname(name);
			userExample.setDescription(String.valueOf(userId));
			userExample.setSex(userId%2 == 0 ? 0 : 1 );
			
			if(userId!=0 && getUserDao().addUser(userId, userExample)!=null){
				try {
					userHandler.registerToIM(userId.toString(), userExample.getPassword());
					System.out.println("第"+i+"条用户数据已经生成");
					
				} catch (Exception e) {
					e.printStackTrace();
				}
			}else{
				throw new ServiceException("自动生成用户数据失败");
		}
			if(isJoinRoom){
				long currentTime = DateUtil.currentTimeSeconds();
				j++;
				currentTime+=j;
				try {
					Integer userSize = roomManager.getRoom(objRoomId,adminUserId).getUserSize();
					int maxUserSize = SKBeanUtils.getSystemConfig().getMaxUserSize();
					if(userSize+1 > maxUserSize){
						log.info("群人数已达到上限，不能继续加入。当前上限人数"+maxUserSize);
						throw new ServiceException("群人数已达到上限，不能继续加入");
					}
					roomManager.joinRoom(userId,name,objRoomId,currentTime,adminUserId);
				} catch (ServiceException e) {
					log.error("addRobot error : ",e.getMessage());
					throw new ServiceException(e.getMessage());
				}
			}
			// 角色信息
			Role role = new Role(userId,String.valueOf(userId),(byte)3,(byte)1,0);
//			getDatastore().save(role);
			roleDao.addRole(role);
		}
		return userIds;
	}
	
	/**
	 * 根据手机号重置密码， 返回手机号对应的用户 userId 某些情况下会用到
	 */
	@Override
	public int resetPassword(String telephone, String newPassword) {
		User user = getUser(telephone);
		if(null==user){
			throw new ServiceException(KConstants.ResultCode.UserNotExist);
		}
		getUserDao().updatePassword(telephone, newPassword);


		userRedisService.cleanUserAllLoginInfo(user.getUserId());
		messageRepository.changePassword(user.getUserId()+"",user.getPassword(),newPassword);

		multipointLoginDataSync(user.getUserId(), user.getNickname(), KConstants.MultipointLogin.SYNC_LOGIN_PASSWORD);
		return user.getUserId();
	}
	
	public void resetPassword(int userId, String newPassword) {
	/*	if(get(userId).getPassword().equals(newPassword))
			throw new ServiceException("重置的密码不能与旧密码相同");*/
		User user = getUser(userId);
		authKeysService.updateLoginPassword(userId,newPassword);
		KSessionUtil.removeAccessToken(userId);
		userRedisService.cleanUserAllLoginInfo(userId);
		multipointLoginDataSync(userId, user.getNickname(), KConstants.MultipointLogin.SYNC_LOGIN_PASSWORD);
	}

	@Override
	public void updatePassword(int userId, String oldPassword, String newPassword) {
		User user = getUser(userId);
		String pwd=authKeysService.queryLoginPassword(userId);
		if(oldPassword.equals(newPassword)){
			// 新旧密码一致
			throw new ServiceException(KConstants.ResultCode.NewAndOldPwdConsistent);
		}
		if (oldPassword.equals(user.getPassword())||LoginPassword.encodeFromOldPassword(oldPassword).equals(user.getPassword())||oldPassword.equals(pwd)) {
			authKeysService.updateLoginPassword(userId,newPassword);
			messageRepository.changePassword(String.valueOf(userId),oldPassword,newPassword);
			KSessionUtil.removeAccessToken(userId);
			userRedisService.cleanUserAllLoginInfo(userId);
			// xmpp消息处理
			multipointLoginDataSync(userId, user.getNickname(), KConstants.MultipointLogin.SYNC_LOGIN_PASSWORD);
		} else
			throw new ServiceException(KConstants.ResultCode.OldPasswordIsWrong);

	}

	public String queryPassword(int userId) {
		return (String) getUserDao().getOneFieldById("password",userId);

	}
	public void updatePayPassword(int userId,String newPassword) {
		getUserDao().updateAttribute(userId,"payPassword",newPassword);
		multipointLoginDataSync(userId,null, KConstants.MultipointLogin.SYNC_PAY_PASSWORD);
		userCoreRedis.deleteUserByUserId(userId);
	}

	@Override
	public User updateSettings(int userId,User.UserSettings userSettings) {
		User user=userCoreService.updateSettings(userId, userSettings);

		userCoreRedis.deleteUserByUserId(userId);
		return user;
	}
	
	public void sendMessage(String jid,int chatType,int type,String content,String fileName) {
		Integer userId=ReqUtil.getUserId();
		MessageBean messageBean=new MessageBean();
		messageBean.setType(type);
		messageBean.setFromUserId(userId.toString());
		messageBean.setFromUserName(getNickName(userId));
		messageBean.setToUserId(jid);
		messageBean.setTo(jid);
		
		if(1==chatType) {
			messageBean.setMsgType(0);
			messageBean.setToUserName(getNickName(Integer.valueOf(jid)));
		}else {
			messageBean.setMsgType(1);
			messageBean.setRoomJid(jid);
		}
		
		messageBean.setContent(content);
		messageBean.setFileName(fileName);
		messageBean.setMessageId(StringUtil.randomCode());
		messageService.send(messageBean);
		
		/**
		 * 发送给自己
		 */
		messageBean.setMsgType(0);
		messageBean.setTo(userId.toString());
		messageService.send(messageBean);
		
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
		getUserDao().updateAttribute(userId, "openid", openid);

		return jsonObject;
	}
	
	public void bindAliUserId(int userId,String aliUserId){
		if(StringUtil.isEmpty(aliUserId)){
			return ;
		}
		getUserDao().updateAttribute(userId, "aliUserId", aliUserId);
	}

	@Override
	public User updateUser(int userId, UserExample param) {
		User user=update(userId, param);
		String payPwd=authKeysService.getPayPassword(userId);
		if(StringUtil.isEmpty(payPwd)){
			user.setPayPassword("0");
		}else{
			user.setPayPassword("1");
		}

		return user;
	}

	public User update(int userId,UserExample example) {
		Map<String, Object> map = new HashMap<>();
		User oldUser = getUser(userId);
		boolean updateName = false;
		List<Integer> userRoles = roleManager.getUserRoles(userId);
		if (null != example.getUserType()) {
			if (userRoles.size() == 0 || userRoles.contains(2) || userRoles.contains(0)) {
				boolean flag = userRoles.contains(2);
				if (example.getUserType() == 2 && !flag) {
					map.put("userType", example.getUserType());
					Role role = new Role(userId, example.getPhone(), (byte) 2, (byte) 1, 0);
					roleDao.addRole(role);
					roleManager.updateFriend(userId, 2);
				} else if (example.getUserType() == 0) {
					map.put("userType", example.getUserType());
					Role getRole = roleDao.getUserRoleByUserId(userId);
					if (null != getRole) {
						roleDao.deleteRole(userId);
					}
				}
				roleManager.updateFriend(userId, example.getUserType());

			} else {
				if (example.getUserType() == 2)
					throw new ServiceException("该用户已经有其他角色");
			}
		}
		if (!StringUtil.isEmpty(example.getAccount())&&!example.getAccount().equals(oldUser.getAccount())) {
			if (0 < oldUser.getSetAccountCount()) {
				throw new ServiceException("通讯号只能修改一次 ");
			}
			if (example.getAccount().length() > 18) {
				throw new ServiceException("通讯号最长十八位");
			}
			boolean userByAccount = getUserByAccount(example.getAccount(), userId);
			if (!userByAccount) {
				throw new ServiceException("账号已存在 ");
			}
			map.put("account", example.getAccount());
			map.put("setAccountCount", 1);
			map.put("encryAccount", Md5Util.md5Hex(example.getAccount()));
			map.put("modifyTime", DateUtil.currentTimeSeconds());
			User user = userDao.updateUserResult(userId, map);
			userCoreRedis.deleteUserByUserId(userId);
			return user;
		}
		if (!StringUtil.isEmpty(example.getNickname())) {
			map.put("nickname", example.getNickname());
			updateName = true;
		}


		if (!StringUtil.isEmpty(example.getTelephone())) {
			map.put("userKey", Md5Util.md5Hex(example.getPhone()));
			map.put("telephone", example.getTelephone());
		}
		if (!StringUtil.isEmpty(example.getPhone()))
			map.put("phone", example.getPhone());

		if (!StringUtil.isEmpty(example.getPayPassWord()))
			map.put("payPassword", example.getPayPassWord());
		if (!StringUtil.isEmpty(example.getMsgBackGroundUrl()))
			map.put("msgBackGroundUrl", example.getMsgBackGroundUrl());


		if (!StringUtil.isEmpty(example.getDescription()))
			map.put("description", example.getDescription());

		if (null != example.getBirthday())
			map.put("birthday", example.getBirthday());

		if (null != example.getSex())
			map.put("sex", example.getSex());

		if (null != example.getCountryId())
			map.put("countryId", example.getCountryId());

		if (null != example.getProvinceId())
			map.put("provinceId", example.getProvinceId());
		if (null != example.getCityId())
			map.put("cityId", example.getCityId());
		if (null != example.getAreaId())
			map.put("areaId", example.getAreaId());

		if (null != example.getName())
			map.put("name", example.getName());

		if (null != example.getIdcard())
			map.put("idcard", example.getIdcard());
		if (null != example.getIdcardUrl())
			map.put("idcardUrl", example.getIdcardUrl());
		if (-1 < example.getMultipleDevices())
			map.put("multipleDevices", example.getMultipleDevices());
		if (0 < example.getLongitude())
			map.put("loc.lng", example.getLongitude());
		if (0 < example.getLatitude())
			map.put("loc.lat", example.getLatitude());
		if (null != example.getPermitUserType())
			map.put("permitUserType", example.getPermitUserType());

		map.put("modifyTime", DateUtil.currentTimeSeconds());

		User user = userDao.updateUserResult(userId, map);
		// 删除redis中的用户
		userCoreRedis.deleteUserByUserId(userId);
		// 修改用户昵称时 同步该用户创建的群主昵称
		if (updateName) {
			ThreadUtils.executeInThread(obj -> {
				userHandler.updateNickNameHandler(userId,example.getNickname());
				Map<String, Object> map1 = new HashMap<>();
				map1.put("nickname", example.getNickname());
				//修改朋友圈中的用户名称
				msgDao.updateMsg(userId, map1);
				// 朋友圈评论、点赞的用户名称
				msgCommentDao.update(userId, map1);
				msgPraiseDao.update(userId, map1);

				// 修改创建的直播间中的nickName
				/*DBObject liveRoomValues = new BasicDBObject();
				liveRoomValues.put("nickName", example.getNickname());
				DBObject liveQuery = new BasicDBObject("$set", liveRoomValues);*/
				Map<String, Object> liveMap = new HashMap<>();
				liveMap.put("nickName", example.getNickname());
				liveRoomDao.updateLiveRoom(userId, liveMap);
				liveRoomMemberDao.updateMember(userId, map1);
				// 维护redis 用户相关数据
				updateUserRelevantInfo(userId);
			});
		}
		return user;
	}
		/** @Description: 维护用户相关数据
		 * @param userId
		 **/
	public void updateUserRelevantInfo(Integer userId){
		// 好友名称(维护自己好友列表的数据)
		List<Integer> toUserIds = friendsDao.queryFriendUserIdList(userId);
		toUserIds.forEach(toUserId ->{
			friendsManager.deleteRedisUserFriends(toUserId);
		});

		// 加入的群Ids
		List<ObjectId> roomIdList = roomManager.getRoomIdList(userId);
		roomIdList.forEach(str ->{
			roomManager.deleteRedisRoom(str.toString());
		});

		// 发送的朋友圈评论
		List<ObjectId> msgIds = msgCommentDao.getCommentIds(userId);
		msgIds.forEach(msgId ->{
			msgRedisRepository.deleteMsgComment(msgId.toString());
		});
		// 发送的朋友圈点赞
		List<ObjectId> strMsgIds = msgPraiseDao.getPraiseIds(userId);
		strMsgIds.forEach(msgId ->{
			msgRedisRepository.deleteMsgPraise(msgId.toString());
		});
	}

	/** @Description:多点登录下个人信息修改通知
	* @param userId
	* @param nickName
	* @param toUserId
	* @param toNickName
	* @param type  type=0:修改用户信息，type=1:修改好友备注
	**/ 
	public void multipointLoginUpdateUserInfo(Integer userId,String nickName,Integer toUserId,String toNickName,int type){
		OfflineOperation offlineOperation = null;
		if(0 == type){
			offlineOperation = offlineOperationDao.queryOfflineOperation(userId,null,String.valueOf(userId));
		}else if (1 == type){
			offlineOperation = offlineOperationDao.queryOfflineOperation(userId,null,String.valueOf(toUserId));
		}
		if(null  == offlineOperation)
			offlineOperationDao.addOfflineOperation(userId,KConstants.MultipointLogin.TAG_FRIEND,null==toUserId?String.valueOf(userId):String.valueOf(toUserId),DateUtil.currentTimeSeconds());
		else{
			OfflineOperation offlineOperation1Entity=new OfflineOperation();
			offlineOperation1Entity.setOperationTime(DateUtil.currentTimeSeconds());
			offlineOperationDao.updateOfflineOperation(offlineOperation.getId(),offlineOperation1Entity);
		}
		updatePersonalInfo(userId, nickName,toUserId,toNickName,type);
	}
	
	public List<User> findUserList(int pageIndex, int pageSize,Integer notId) {
		return userDao.findUserList(pageIndex,pageSize,notId);

	}
	
	/**
	 * 查找对应类型的用户数据
	 * @param pageIndex
	 * @param pageSize
	 * @param type
	 * @return
	 */
	public List<User> findUserList(int pageIndex, int pageSize,String keyworld,short onlinestate,short userType) throws ServiceException{
		
			return getUserDao().searchUsers(pageIndex, pageSize, keyworld,onlinestate, userType);
	}
	
	
	
	
	@Override
	public List<Document> findUser(int pageIndex, int pageSize) {
		return getUserDao().findUser(pageIndex, pageSize);
	}

	
	
	
	@Override
	public List<Integer> getAllUserId() {
		return getUserDao().getAllUserId();
	}

	
	@Override
	public void outtime(String access_token, int userId) {

		getUserDao().updateUserOfflineTime(userId);
	}

	@Override
	public void addUser(int userId, String password) {
		getUserDao().addUser(userId, password);
	}
	/**
	* @Description: TODO(销毁该用户 已过期的 聊天记录)
	* @param @param userId    参数
	*/
	public void destroyMsgRecord(int userId) {

		messageRepository.destroyUserMsgRecord(userId);
		
	}

	
	//用户充值 type 1 充值  2 消费
	public  Double rechargeUserMoeny(UserMoneyLog userMoneyLog){

			return rechargeUserMoenyV1(userMoneyLog);
	}
	public  Double rechargeUserMoenyV1(UserMoneyLog userMoneyLog){
		try {

			return userCoreService.rechargeUserMoenyV1(userMoneyLog);
		} catch (Exception e) {
			log.error(e.getMessage(),e);
			return 0.0;
		}
	}

	public Double getUserMoeny(Integer userId){

		return getUserMoenyV1(userId);
	}
	public Double getUserMoenyV1(Integer userId){
		try {
			return userCoreService.getUserMoenyV1(userId);
		} catch (Exception e) {
			throw  new ServiceException(BALANCE_DATA_EX);
		}
	}
		
		
	public int getOnlinestateByUserId(Integer userId) {
		return userRedisService.queryUserOnline(userId);
	}
		
		
	public void examineTigaseUser(Integer userId,String password){
		userHandler.registerToIM(userId.toString(),password);
		
		
	}
		
	public void report(Integer userId,Integer toUserId,int reason,String roomId,String webUrl){
		
		if(toUserId==null&&StringUtil.isEmpty(roomId)&&StringUtil.isEmpty(webUrl)){
			throw new ServiceException(KConstants.ResultCode.ParamsAuthFail);
		}
		reportDao.addReport(userId,toUserId,reason,roomId,webUrl);
		
	}

	public boolean checkReportUrlImpl(String webUrl) {
		try {
			URL requestUrl = new URL(webUrl);
			webUrl = requestUrl.getHost();
		} catch (Exception e) {
//			throw new ServiceException(KConstants.ResultCode.ParamsAuthFail);
			// 无主机host地址允许通过，eg:第三方分享进来的app协议类的请求
			return true;
		}
		List<Report> reportList = reportDao.getReportListByWebUrl(webUrl);
		if (null != reportList && reportList.size() > 0) {
			reportList.forEach(report -> {
				if (null != report && -1 == report.getWebStatus())
					throw new ServiceException(KConstants.ResultCode.WEBURLISREPORTED);
			});
		}
		return true;
	}
	
	
	/** @Description: 获取举报列表
	* @param type 0：用户相关，1：群组相关  2：web网页
	* @param sender
	* @param receiver
	* @param pageIndex
	* @param pageSize
	* @return
	**/ 
	public PageResult<Report> getReport(int type,int sender,String receiver,int pageIndex,int pageSize) {
			PageResult<Report> pageResult = new PageResult<>();
			try {
				if (type == 0) {
					pageResult = reportDao.getReportListResult(sender,receiver,pageIndex,pageSize,type);
					for(Report report : pageResult.getData()){
						report.setUserName(getNickName((int) report.getUserId()));
						report.setToUserName(getNickName((int) report.getToUserId()));
						if(KConstants.ReportReason.reasonMap.containsKey(report.getReason()))
							report.setInfo(KConstants.ReportReason.reasonMap.get(report.getReason()));
						if(null == getUser(Integer.valueOf(String.valueOf(report.getToUserId()))))
							report.setToUserStatus(-1);
						else{
							Integer status = getUser(Integer.valueOf(String.valueOf(report.getToUserId()))).getStatus();
							report.setToUserStatus(status);
						}
					}

				} else if (type == 1) {
					pageResult = reportDao.getReportListResult(sender,receiver,pageIndex,pageSize,type);
					for(Report report : pageResult.getData()){
						report.setUserName(getNickName((int) report.getUserId()));
						report.setRoomName(roomManager.getRoomName(new ObjectId(report.getRoomId())));
						Integer roomStatus = roomManager.getRoomStatus(new ObjectId(report.getRoomId()));
						if(null != roomStatus)
							report.setRoomStatus(roomStatus);
						if(KConstants.ReportReason.reasonMap.containsKey(report.getReason()))
							report.setInfo(KConstants.ReportReason.reasonMap.get(report.getReason()));
					}
					pageResult.setData(pageResult.getData());

				}else if(type == 2){
					pageResult = reportDao.getReportListResult(sender,receiver,pageIndex,pageSize,type);
					for(Report report : pageResult.getData()){
						report.setUserName(getNickName((int)report.getUserId()));
						if(KConstants.ReportReason.reasonMap.containsKey(report.getReason()))
							report.setInfo(KConstants.ReportReason.reasonMap.get(report.getReason()));
					}

				}
		} catch (Exception e) {
			e.printStackTrace();
		}


		return pageResult;
	}
	
	/** @Description: 删除相关的举报信息
	* @param userId
	* @param roomId
	**/ 
	public void delReport(Integer userId,String roomId){
		reportDao.deleteReport(userId,roomId);
	}
	
	// 删除 被删除的用户得账单记录
	public void delRecord(Integer userId){
		if (paymentManager == null){
			return;
		}else{
			paymentManager.deleteConsumRecordByUserId(userId);
		}

	}
		
	//获取用户Id
	public  Integer createUserId(){
		try {
			RLock lock = userRedisService.getLock(userIdLockKey);
			boolean lockResult = lock.tryLock(5, TimeUnit.SECONDS);
			int count =1;
			while (!lockResult){
				if (count == 5) {
					throw new ServiceException(KConstants.ResultCode.SystemIsBusy);
				}
				Thread.sleep(500);
				lockResult = lock.tryLock(5, TimeUnit.SECONDS);
				count++;
			}
			if(lockResult){
				RAtomicLong rAtomicLong =userRedisService.getRedissonClient().getAtomicLong(INCREASE_USERID);
				Long userId =rAtomicLong.get();
				try {
					if (userId==0){
						userId=getUserDao().createUserId(null).longValue();
						rAtomicLong.set(userId);
					}else {
						userId=rAtomicLong.incrementAndGet();
						getUserDao().createUserId(userId.intValue());
					}
					return userId.intValue();
				}catch (Exception e){
					log.error(e.getMessage(),e);
				}finally {
					lock.unlock();
				}
			}
		}catch (Exception e){
			log.error(e.getMessage(),e);
		}
		throw new ServiceException(KConstants.ResultCode.SystemIsBusy);
	}
		
	//获取Call
	public synchronized Integer createCall(){
		return getUserDao().createCall();
	}
		
	//获取videoMeetingNo
	public synchronized Integer createvideoMeetingNo(){
		return getUserDao().createvideoMeetingNo();
	}
	
	//获取注册邀请码计数值
	@Override
	public synchronized Integer createInviteCodeNo(int createNum){
		return getUserDao().createInviteCodeNo(createNum);
	}
	
	public Integer getServiceNo(String areaCode){
		return getUserDao().getServiceNo(areaCode);
	}
	

	
	//消息免打扰
	@Override
	public User updataOfflineNoPushMsg(int userId,int OfflineNoPushMsg) {
		User user=getUserDao().updateOfflineNoPushMsg(userId,OfflineNoPushMsg);
		user.setPayPassword("");
		return user;
	}

	@Override
	public List<Object> addCollection(int userId, String roomJid, String msgId, String type) {
		return null;
	}

	@Override
	public Object addEmoji(int userId, String url, String type) {
		return null;
	}

	@Override
	public List<Emoji> emojiList(int userId, int type, int pageSize, int pageIndex) {
		return null;
	}

	@Override
	public List<Emoji> emojiList(int userId) {
		return null;
	}

	@Override
	public void deleteEmoji(Integer userId, String emojiId) {

	}

	@Override
	public void addMessageCourse(int userId, List<String> messageIds, long createTime, String courseName, String roomJid) {

	}

	@Override
	public List<Course> getCourseList(int userId) {
		return null;
	}

	@Override
	public void updateCourse(Course course, String courseMessageId) {

	}

	@Override
	public boolean deleteCourse(Integer userId, ObjectId courseId) {
		return false;
	}

	@Override
	public List<CourseMessage> getCourse(String courseId) {
		return null;
	}


	@Override
		public WxUser addwxUser(JSONObject jsonObject) {
			WxUser wxUser=new WxUser();
			Integer userId=createUserId();
//			wxUser.setWxuserId(userId);
//			wxUser.setOpenId(jsonObject.getString("openid"));
//			wxUser.setNickname(jsonObject.getString("nickname"));
//			wxUser.setImgurl(jsonObject.getString("headimgurl"));
//			wxUser.setSex(jsonObject.getIntValue("sex"));
//			wxUser.setCity(jsonObject.getString("city"));
//			wxUser.setCountry(jsonObject.getString("country"));
//			wxUser.setProvince(jsonObject.getString("province"));
//			wxUser.setCreatetime(DateUtil.currentTimeSeconds());
//			getDatastore().save(wxUser);
			try {
				wxUser = wxUserDao.addWxUser(userId,jsonObject.getString("openid"),new String(jsonObject.getString("nickname").getBytes("ISO-8859-1"), "UTF-8")
						,jsonObject.getString("headimgurl"),jsonObject.getIntValue("sex"),jsonObject.getString("city")
						,jsonObject.getString("country"),jsonObject.getString("province"));
			}catch (Exception e){
				e.printStackTrace();
			}
			
			try {
				userHandler.registerToIM(userId.toString(),jsonObject.getString("openid"));
			} catch (Exception e) {
				e.printStackTrace();
			}
			return wxUser;
		}

		
		/**
		 * 用户注册统计      时间单位每日，最好可选择：每日、每月、每分钟、每小时
		 * @param startDate
		 * @param endDate
		 * @param counType  统计类型   1: 每个月的数据      2:每天的数据       3.每小时数据   4.每分钟的数据 (小时)
		 */
		public List<Object> getUserRegisterCount(String startDate, String endDate, short timeUnit){
			
			
			List<Object> countData = new ArrayList<>();
			
			
			long startTime = 0; //开始时间（秒）
			
			long endTime = 0; //结束时间（秒）,默认为当前时间
			
			/**
			 * 如时间单位为月和天，默认开始时间为当前时间的一年前 ; 时间单位为小时，默认开始时间为当前时间的一个月前;
			 * 时间单位为分钟，则默认开始时间为当前这一天的0点
			 */
			long defStartTime = timeUnit==4? DateUtil.getTodayMorning().getTime()/1000 
					: timeUnit==3 ? DateUtil.getLastMonth().getTime()/1000 : DateUtil.getLastYear().getTime()/1000;
			
			startTime = StringUtil.isEmpty(startDate) ? defStartTime :DateUtil.toDate(startDate).getTime()/1000;
			endTime = StringUtil.isEmpty(endDate) ? DateUtil.currentTimeSeconds() : DateUtil.toDate(endDate).getTime()/1000;
					
			String mapStr = "function Map() { "
		            + "var date = new Date(this.createTime*1000);" 
		            +  "var year = date.getFullYear();"
					+  "var month = (\"0\" + (date.getMonth()+1)).slice(-2);"  //month 从0开始，此处要加1
					+  "var day = (\"0\" + date.getDate()).slice(-2);"
					+  "var hour = (\"0\" + date.getHours()).slice(-2);"
					+  "var minute = (\"0\" + date.getMinutes()).slice(-2);"
					+  "var dateStr = date.getFullYear()"+"+'-'+"+"(parseInt(date.getMonth())+1)"+"+'-'+"+"date.getDate();";
					
					if(timeUnit==1){ // counType=1: 每个月的数据
						mapStr += "var key= year + '-'+ month;";
					}else if(timeUnit==2){ // counType=2:每天的数据
						mapStr += "var key= year + '-'+ month + '-' + day;";
					}else if(timeUnit==3){ //counType=3 :每小时数据
						mapStr += "var key= year + '-'+ month + '-' + day + '  ' + hour +' : 00';";
					}else if(timeUnit==4){ //counType=4 :每分钟的数据
						mapStr += "var key= year + '-'+ month + '-' + day + '  ' + hour + ':'+ minute;";
					}
		           
					mapStr += "emit(key,1);}";
			
			 String reduce = "function Reduce(key, values) {" +
				                "return Array.sum(values);" +
		                    "}";

			return getUserDao().getUserRegisterCount(startTime,endTime,mapStr,reduce);
		}
		
		
		
		// 1: 每个月的数据      2:每天的数据       3.每小时数据   4.每分钟的数据 
		public List<Object> userOnlineStatusCount(String startDate, String endDate, short timeUnit){
			
			List<Object> countData = new ArrayList<>();
			
			long startTime = 0; //开始时间（秒） 
			
			long endTime = 0; //结束时间（秒）,默认为当前时间
			
			/**
			 * 如时间单位为月和天，默认开始时间为当前时间的一年前 ; 时间单位为小时，默认开始时间为当前时间的一个月前;
			 * 时间单位为分钟，则默认开始时间为当前这一天的0点
			 */
			long defStartTime = timeUnit==4? DateUtil.getTodayMorning().getTime()/1000 
					: timeUnit==3 ? DateUtil.getLastMonth().getTime()/1000 : DateUtil.getLastYear().getTime()/1000;
					
			
			startTime = StringUtil.isEmpty(startDate) ? defStartTime :DateUtil.toDate(startDate).getTime()/1000;
			endTime = StringUtil.isEmpty(endDate) ? DateUtil.currentTimeSeconds() : DateUtil.toDate(endDate).getTime()/1000;

			String mapStr = "function Map() { "
					+ "var date = new Date(this.time*1000);"
					+  "var year = date.getFullYear();"
					+  "var month = (\"0\" + (date.getMonth()+1)).slice(-2);"  //month 从0开始，此处要加1
					+  "var day = (\"0\" + date.getDate()).slice(-2);"
					+  "var hour = (\"0\" + date.getHours()).slice(-2);"
					+  "var minute = (\"0\" + date.getMinutes()).slice(-2);"
					+  "var dateStr = date.getFullYear()"+"+'-'+"+"(parseInt(date.getMonth())+1)"+"+'-'+"+"date.getDate();";

			if(timeUnit==1){ // counType=1: 每个月的数据
				mapStr += "var key= year + '-'+ month;";
			}else if(timeUnit==2){ // counType=2:每天的数据
				mapStr += "var key= year + '-'+ month + '-' + day;";
			}else if(timeUnit==3){ //counType=3 :每小时数据
				mapStr += "var key= year + '-'+ month + '-' + day + '  ' + hour +' : 00';";
			}else if(timeUnit==4){ //counType=4 :每分钟的数据
				mapStr += "var key= year + '-'+ month + '-' + day + '  ' + hour + ':'+ minute;";
			}

			mapStr += "emit(key,this.count);}";

			String reduce = "function Reduce(key, values) {" +
					"return Array.sum(values);" +
					"}";

			return getUserDao().getUserOnlineStatusCount(startTime,endTime,timeUnit,mapStr,reduce);

		}
			
		/** @Description:（设置消息免打扰） 
		* @param offlineNoPushMsg
		* @return
		**/ 
		public User updatemessagefree(int offlineNoPushMsg) {
//			Query<User> q = getDatastore().createQuery(User.class).field("_id").equal(ReqUtil.getUserId());
//			UpdateOperations<User> ops = getDatastore().createUpdateOperations(getEntityClass());
//			ops.set("offlineNoPushMsg", offlineNoPushMsg);
//			User data = getDatastore().findAndModify(q, ops);
			Map<String,Object> map = new HashMap<>();
			map.put("offlineNoPushMsg", offlineNoPushMsg);
			User data = userDao.updateUserResult(ReqUtil.getUserId(),map);
			data.setPayPassword("");
			return data;
		}
		
		/** @Description:（获取微信用户） 
		* @param openid
		* @param userId
		* @return
		**/ 
	public WxUser getWxUser(String openid, Integer userId) {
		WxUser wxUser = null;
//		if (!StringUtil.isEmpty(openid))
//			wxUser = getDatastore().createQuery(WxUser.class).field("openId").equal(openid).get();
//		else if (null != userId) {
//			wxUser = getDatastore().createQuery(WxUser.class).field("wxuserId").equal(userId).get();
//		}
		wxUser = wxUserDao.getWxUser(openid,userId);
		return wxUser;
	}
		
	/**
	 * @Description:（按注册时间降序排序用户）
	 * @param pageIndex
	 * @param pageSize
	 * @return
	 **/
	public List<User> getUserlimit(int pageIndex, int pageSize,int isAuth) {
		
		List<User> dataList = getUserDao().getUserlimit(pageIndex,pageSize,isAuth);
		return dataList;
	}

	/**
	 * @Description:（附近的用户）
	 * @param poi
	 * @return
	 **/
	public List<User> nearbyUser(NearbyUser poi) {
		List<User> data = null;
		try {
			Config config = SKBeanUtils.getSystemConfig();
			data = getUserDao().getNearbyUser(poi,ReqUtil.getUserId(),config.getTelephoneSearchUser(),config.getNicknameSearchUser());
			return data;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return data;

	}
	
	
	public PageVO nearbyUserWeb(NearbyUser poi) {
		
		List<User> data = null;
		try {
			Config config = SKBeanUtils.getSystemConfig();
			data = getUserDao().getNearbyUser(poi,ReqUtil.getUserId(),config.getTelephoneSearchUser(),config.getNicknameSearchUser());
			return new PageVO(data, Long.valueOf(data.size()), poi.getPageIndex(), poi.getPageSize());
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}
		
	// 删除用户
	public void deleteUser(Integer adminUserId,String... userIds){
		try {
			Integer systemUserId = 10005;
			for (String strUserId : userIds) {
				Integer userId = Integer.valueOf(strUserId);
				// 系统账号过滤
				if(userId.equals(KConstants.systemAccount.ADMIN_CONSOLE_ACCOUNT) || userId.equals(KConstants.systemAccount.AMOUNT_ACCOUNT) || 
						userId.equals(KConstants.systemAccount.CUSTOMER_ACCOUNT)){
					log.info("过滤删除系统账号  ：{}",userId);
					continue;
				}
				if (0 != userId) {
					messageService.deleteTigaseUser(userId);
					// 发送xmpp通知 客户端更新本地数据
					consoleDeleteUserXmpp(systemUserId, userId);
					try {
						ThreadUtils.executeInThread((Callback) obj -> {

							try {
								userHandler.deleteUserHandler(adminUserId,userId);
								sdkLoginInfoDao.deleteByAttribute("userId",userId);
								// 删除用户的相关举报信息
								delReport(userId, null);
								// 删除用户的账单记录
								delRecord(userId);
								// 删除第三方绑定记录
								sdkLoginInfoDao.deleteSdkLoginInfoByUserId(userId);
								authKeysService.deletePayKey(userId);
							} catch (Exception e) {
								log.error(e.getMessage(),e);
							}

							getUserDao().deleteUserById(userId);
							// 清除用户相关缓存数据
							userRedisService.cleanUserInfo(userId);
							// 清除redis中没有系统号的表
							userCoreRedis.deleteNoSystemNumUserIds();

						});
					} catch (ServiceException e) {
						e.printStackTrace();
						throw new ServiceException(e.getResultCode());
					}
					
				}
			}
		} catch (ServiceException e) {
			e.printStackTrace();
			throw new ServiceException(e.getResultCode());
		}
	}	
	
	private void consoleDeleteUserXmpp(Integer userId,Integer toUserId){
		final List<Integer> friendsUserIdsList = friendsManager.queryFriendUserIdList(toUserId);
		if(null == friendsUserIdsList || friendsUserIdsList.size() == 0){
			return;
		}

		log.info(" delete user  =====> userId : "+toUserId+"   好友friends : "+friendsUserIdsList);
			ThreadUtils.executeInThread(obj -> {
				//以系统号发送删除好友通知
				//xmpp推送消息
				List<MessageBean> messageBeans = Collections.synchronizedList(new ArrayList<MessageBean>());
				friendsUserIdsList.forEach(strToUserId ->{
					MessageBean messageBean=new MessageBean();
					messageBean.setType(MessageType.consoleDeleteUsers);
					messageBean.setFromUserId(userId.toString());
					messageBean.setFromUserName(getNickName(toUserId));
					messageBean.setToUserId(strToUserId.toString());
					messageBean.setToUserName(getNickName(strToUserId));
					messageBean.setContent("后台管理员解除了你们好友关系");
					messageBean.setObjectId(toUserId);
					messageBean.setMessageId(StringUtil.randomUUID());
					messageBean.setMsgType(0);
					messageBeans.add(messageBean);
				});
				try {
					messageService.send(friendsUserIdsList,messageBeans);
				} catch (Exception e) {
						log.error(e.getMessage());
				}
		});
	}

	@Override
	public SdkLoginInfo addSdkLoginInfo(int type, Integer userId, String loginInfo) {
		SdkLoginInfo entity=sdkLoginInfoDao.addSdkLoginInfo(type,userId,loginInfo);
		return entity;
	}
	
	/**
	 * 获取用户绑定信息
	 * @param userId
	 * @return
	 */
	public List<SdkLoginInfo> getBindInfo(Integer userId){
		return sdkLoginInfoDao.querySdkLoginInfoByUserId(userId);
	}
	
	/**
	 * 解除绑定
	 * @param type
	 * @param userId
	 * @return
	 */
	public void unbind(int type,Integer userId){
		SdkLoginInfo sdkLoginInfo = sdkLoginInfoDao.getSdkLoginInfo(type,userId);
		if(null!=sdkLoginInfo){
			sdkLoginInfoDao.deleteSdkLoginInfo(type,userId);
		}else{
			throw new ServiceException(KConstants.ResultCode.NoBind);
		}
	}

	@Override
	public SdkLoginInfo findSdkLoginInfo(int type, String loginInfo) {
		return sdkLoginInfoDao.findSdkLoginInfo(type,loginInfo);
	}

	@Override
	public JSONObject getWxOpenId(String code) {
		if(StringUtil.isEmpty(code)) {
			return null;
		}
		JSONObject jsonObject = WXUserUtils.getWxOpenId(code);
		String openid=jsonObject.getString("openid");
		if(StringUtil.isEmpty(openid)) {
			return null;
		}
		return jsonObject;
	}
	
	public JSONObject getPublicWxOpenId(String code){
		if(StringUtil.isEmpty(code)) {
			return null;
		}
		JSONObject jsonObject = WXUserUtils.getPublicWxOpenId(code);
		String openid=jsonObject.getString("openid");
		if(StringUtil.isEmpty(openid)) {
			return null;
		}
		return jsonObject;
	}

	@Override
	public String getWxToken() {
		JSONObject jsonObject = WXUserUtils.getWxToken();
		String token=jsonObject.getString("access_token");
		return token;
	}
	
	public String getPublicWxToken(){
		JSONObject jsonObject = WXUserUtils.getPublicWxToken();
		String token=jsonObject.getString("access_token");
		return token;
	}

	/** @Description:是否开启多点登录
	* @return
	**/ 
	public boolean isOpenMultipleDevices(Integer userId){
		boolean flag = false;
		User user = getUser(userId);
		if(null != user){
			if(null == user.getSettings())
				return flag;
			return 1 == user.getSettings().getMultipleDevices();
		}
		return flag;
	}
	
	/** @Description:多点登录数据同步 
	* @param userId
	**/ 
	public void multipointLoginDataSync(Integer userId,String nickName,String operationType){
		ThreadUtils.executeInThread(obj -> {
					MessageBean messageBean=new MessageBean();
					messageBean.setType(MessageType.multipointLoginDataSync);
					String userName=nickName;
					if(StringUtil.isEmpty(userName)){
						userName=getNickName(userId);
					}
					messageBean.setFromUserId(String.valueOf(userId));
					messageBean.setFromUserName(userName);
					messageBean.setToUserId(String.valueOf(userId));
					messageBean.setToUserName(nickName);
					messageBean.setObjectId(operationType);
					messageBean.setMessageId(StringUtil.randomUUID());
					try {
						messageService.send(messageBean);
					} catch (Exception e) {
						e.printStackTrace();
					}
		});
	}
	
	/** @Description:多点登录下修改用户个人、好友资料,标签的通知 
	* @param userId
	* @param nickName
	* @param type=0 :修改个人信息，type=1:修改好友相关设置
	**/ 
	public void updatePersonalInfo(Integer userId,String nickName,Integer toUserId,String toNickName,int type){
		ThreadUtils.executeInThread(new Callback() {
			@Override
			public void execute(Object obj) {
					MessageBean messageBean=new MessageBean();
					messageBean.setType(MessageType.updatePersonalInfo);
					messageBean.setFromUserId(String.valueOf(userId));
					messageBean.setFromUserName(nickName);
					if(1 == type){
						messageBean.setTo(String.valueOf(userId));
					}
					messageBean.setToUserId(null == toUserId ? String.valueOf(userId) : String.valueOf(toUserId));
					messageBean.setToUserName(StringUtil.isEmpty(toNickName) ? nickName : toNickName);
					messageBean.setMessageId(StringUtil.randomUUID());
					try {
						messageService.send(messageBean);
					} catch (Exception e) {
						e.printStackTrace();
					}
			}
		});
	}
	
	/** @Description:获取离线时间段相关操作列表
	* @param userId
	* @param startTime
	* @return
	**/ 
	public List<OfflineOperation> getOfflineOperation(Integer userId,long startTime){
		return offlineOperationDao.getOfflineOperationList(userId,startTime);
	}

	@Override
	public User.LoginLog getLogin(int userId) {
		return userDao.getLogin(userId);
	}





	/*	//获取系统最大客服号
	private Integer getMaxServiceNo(){
		DBCollection collection=getDatastore().getDB().getCollection("sysServiceNo");
		BasicDBObject obj=(BasicDBObject) collection.findOne(null, new BasicDBObject("userId", 1), new BasicDBObject("userId", -1));
		if(null!=obj){
			return obj.getInt("userId");
		}else{
			BasicDBObject query=new BasicDBObject("_id",new BasicDBObject(MongoOperator.LT, 10200));
			query.append("_id",new BasicDBObject(MongoOperator.GT, 10200));
			BasicDBObject projection=new BasicDBObject("_id", 1);
			DBObject dbobj=getDatastore().getDB().getCollection("user").findOne(query, projection, new BasicDBObject("_id", -1));
			if(null==dbobj)
				return 10200;
			Integer id=new Integer(dbobj.get("_id").toString());
				return id;
		}
	}

	//创建系统服务号
	private Integer createServiceNo(String areaCode){
		DBCollection collection=getDatastore().getDB().getCollection("sysServiceNo");
		Integer userId=getMaxServiceNo()+1;
		BasicDBObject value=new BasicDBObject("areaCode", areaCode);
		value.append("userId", userId);
		collection.save(value);
		addUser(userId, Md5Util.md5Hex(userId+""));
		return userId;
	}*/
}
