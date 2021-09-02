package com.shiku.im.user.model;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

@ApiModel("用户信息")
public class UserExample extends BaseExample {
	@ApiModelProperty("生日")
	private Long birthday;
	@ApiModelProperty("详细信息")
	private String description;
	@ApiModelProperty("身份证")
	private String idcard;
	@ApiModelProperty("身份证地址")
	private String idcardUrl;
	@ApiModelProperty("姓名")
	private String name;
	@ApiModelProperty("昵称")
	private  String nickname;
	@ApiModelProperty("密码")
	private  String password;
	@ApiModelProperty("性别")
	private Integer sex; //0:男   1:女
	@ApiModelProperty("电话号码")
	private  String telephone;
	@ApiModelProperty("0-普通会员 1-商务号 (用来区分是否可以主动添加会员)")
	private Integer permitUserType;


	/**
	 * 账号
	 */
	@ApiModelProperty("账号")
	private String account;
	
	/**
	 * account 加密后的通讯账号 
	 */
	@ApiModelProperty("account 加密后的通讯账号 ")
	private String encryAccount;

	@ApiModelProperty("编号")
	private int userId=0;

	@ApiModelProperty("参数码")
	private String areaCode="86";
	@ApiModelProperty("标识码")
	private String randcode;
	@ApiModelProperty("电话")
	private String phone;
	@ApiModelProperty("用户类型")
	private Integer userType;
	@ApiModelProperty("当前包名")
	private String appId;//ios  当前包名
	@ApiModelProperty("心跳包的时候用到")
	private int xmppVersion; //xmpp 心跳包的时候用到

	@ApiModelProperty("标识d")
	private Integer d = 0;
	@ApiModelProperty("标识w")
	private Integer w = 0;
	@ApiModelProperty("邮箱")
	private String email;
	@ApiModelProperty("支付密码")
	private String payPassWord; //支付密码
	@ApiModelProperty("多设备登陆")
	private int multipleDevices=-1; //多设备登陆
	@ApiModelProperty("是否使用短信验证码注册")
	private byte isSmsRegister = 0; //是否使用短信验证码注册 0:不是  1:是
	@ApiModelProperty("用户地理位置")
	private String area;// 用户地理位置
	@ApiModelProperty("我的邀请码")
	private String myInviteCode; //我的邀请码
	@ApiModelProperty("注册时填写的邀请码")
	private String inviteCode; //注册时填写的邀请码
	@ApiModelProperty("来自uid的邀请")
	private Integer invitedUserId; //来自uid的邀请
	@ApiModelProperty("朋友圈背景URL")
	private String msgBackGroundUrl;// 朋友圈背景URL
	@ApiModelProperty("第三方登录标识")
	private int isSdkLogin;// 第三方登录标识  0 不是     1 是
	@ApiModelProperty("登录类型")
	private int loginType;// 登录类型 0：账号密码登录，1：短信验证码登录
	@ApiModelProperty("短信验证码")
	private String verificationCode;// 短信验证码

	//当前登陆设备
	@ApiModelProperty("当前登陆设备")
	private String deviceKey;

	@ApiModelProperty("当前设备编号")
	private String deviceId;
	
	//用户授权标识
	@ApiModelProperty("用户授权标识")
	private String authKey;
	
	// 个人隐私设置
//	private int allowGreet=1;// 允许打招呼
	@ApiModelProperty("加好友需验证")
	private int friendsVerify=-1;// 加好友需验证 1：开启    0：关闭
//	private int openService=-1;//是否开启客服模式 1：开启    0：关闭
	@ApiModelProperty("是否振动")
	private int isVibration=-1;// 是否振动   1：开启    0：关闭
	@ApiModelProperty("让对方知道我正在输入")
	private int isTyping=-1;// 让对方知道我正在输入   1：开启       0：关闭
	@ApiModelProperty("使用google地图  ")
	private int isUseGoogleMap=-1;// 使用google地图    1：开启   0：关闭
	@ApiModelProperty("是否开启加密传输")
	private int isEncrypt=-1;// 是否开启加密传输    1:开启    0:关闭
//	private int multipleDevices=1;// 是否开启多点登录   1:开启     0:关闭
	@ApiModelProperty("关闭手机号搜索用户")
	private int closeTelephoneFind=0;// 关闭手机号搜索用户    关闭次选项 不用使用手机号搜索用户   0 开启    1 关闭    默认开启
	
	//聊天记录 销毁  时间   -1 0  永久   1 一天
	@ApiModelProperty("聊天记录 销毁  时间")
	private String chatRecordTimeOut="0";
	
	@ApiModelProperty("聊天记录 最大 漫游时长")
	private double chatSyncTimeLen=0;//  聊天记录 最大 漫游时长    -1 永久  -2 不同步
	
	@ApiModelProperty("是否安卓后台常驻保活app")
	private Integer isKeepalive = -1;// 是否安卓后台常驻保活app 0：取消保活  1：保活
	
	@ApiModelProperty("显示上次上线时间")
	private Integer showLastLoginTime = 0;// 显示上次上线时间   -1 所有人不显示 1所有人显示  2 所有好友显示   3 手机联系人显示
	
	@ApiModelProperty("显示我的手机号码")
	private Integer showTelephone = 0;// 显示我的手机号码   -1 所有人不显示 1所有人显示  2 所有好友显示   3 手机联系人显示
	
	@ApiModelProperty("允许手机号搜索")
	private Integer phoneSearch = -1;// 允许手机号搜索 1 允许 0 不允许
	
	@ApiModelProperty("允许昵称搜索")
	private Integer nameSearch = -1;// 允许昵称搜索  1 允许 0 不允许
	
	@ApiModelProperty("通过什么方式添加我")
	private String friendFromList;// 通过什么方式添加我  0:系统添加好友 1:二维码 2：名片 3：群组 4： 手机号搜索 5： 昵称搜索

	@ApiModelProperty("设备类型")
	private String deviceType;

	public Long getBirthday() {
		return birthday;
	}

	public void setBirthday(Long birthday) {
		this.birthday = birthday;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getIdcard() {
		return idcard;
	}

	public void setIdcard(String idcard) {
		this.idcard = idcard;
	}

	public String getIdcardUrl() {
		return idcardUrl;
	}

	public void setIdcardUrl(String idcardUrl) {
		this.idcardUrl = idcardUrl;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getNickname() {
		return nickname;
	}

	public void setNickname(String nickname) {
		this.nickname = nickname;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public Integer getSex() {
		return sex;
	}

	public void setSex(Integer sex) {
		this.sex = sex;
	}

	public String getTelephone() {
		return telephone;
	}

	public void setTelephone(String telephone) {
		this.telephone = telephone;
	}

	public Integer getPermitUserType() {
		return permitUserType;
	}

	public void setPermitUserType(Integer permitUserType) {
		this.permitUserType = permitUserType;
	}

	public String getAccount() {
		return account;
	}

	public void setAccount(String account) {
		this.account = account;
	}

	public String getEncryAccount() {
		return encryAccount;
	}

	public void setEncryAccount(String encryAccount) {
		this.encryAccount = encryAccount;
	}

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public String getAreaCode() {
		return areaCode;
	}

	public void setAreaCode(String areaCode) {
		this.areaCode = areaCode;
	}

	public String getRandcode() {
		return randcode;
	}

	public void setRandcode(String randcode) {
		this.randcode = randcode;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}

	public Integer getUserType() {
		return userType;
	}

	public void setUserType(Integer userType) {
		this.userType = userType;
	}

	public String getAppId() {
		return appId;
	}

	public void setAppId(String appId) {
		this.appId = appId;
	}

	public int getXmppVersion() {
		return xmppVersion;
	}

	public void setXmppVersion(int xmppVersion) {
		this.xmppVersion = xmppVersion;
	}

	public Integer getD() {
		return d;
	}

	public void setD(Integer d) {
		this.d = d;
	}

	public Integer getW() {
		return w;
	}

	public void setW(Integer w) {
		this.w = w;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getPayPassWord() {
		return payPassWord;
	}

	public void setPayPassWord(String payPassWord) {
		this.payPassWord = payPassWord;
	}

	public int getMultipleDevices() {
		return multipleDevices;
	}

	public void setMultipleDevices(int multipleDevices) {
		this.multipleDevices = multipleDevices;
	}

	public byte getIsSmsRegister() {
		return isSmsRegister;
	}

	public void setIsSmsRegister(byte isSmsRegister) {
		this.isSmsRegister = isSmsRegister;
	}

	public String getArea() {
		return area;
	}

	public void setArea(String area) {
		this.area = area;
	}

	public String getMyInviteCode() {
		return myInviteCode;
	}

	public void setMyInviteCode(String myInviteCode) {
		this.myInviteCode = myInviteCode;
	}

	public String getInviteCode() {
		return inviteCode;
	}

	public void setInviteCode(String inviteCode) {
		this.inviteCode = inviteCode;
	}

	public Integer getInvitedUserId() {
		return invitedUserId;
	}

	public void setInvitedUserId(Integer invitedUserId) {
		this.invitedUserId = invitedUserId;
	}

	public String getMsgBackGroundUrl() {
		return msgBackGroundUrl;
	}

	public void setMsgBackGroundUrl(String msgBackGroundUrl) {
		this.msgBackGroundUrl = msgBackGroundUrl;
	}

	public int getIsSdkLogin() {
		return isSdkLogin;
	}

	public void setIsSdkLogin(int isSdkLogin) {
		this.isSdkLogin = isSdkLogin;
	}

	public int getLoginType() {
		return loginType;
	}

	public void setLoginType(int loginType) {
		this.loginType = loginType;
	}

	public String getVerificationCode() {
		return verificationCode;
	}

	public void setVerificationCode(String verificationCode) {
		this.verificationCode = verificationCode;
	}

	public String getDeviceKey() {
		return deviceKey;
	}

	public void setDeviceKey(String deviceKey) {
		this.deviceKey = deviceKey;
	}

	public String getDeviceId() {
		return deviceId;
	}

	public void setDeviceId(String deviceId) {
		this.deviceId = deviceId;
	}

	public String getAuthKey() {
		return authKey;
	}

	public void setAuthKey(String authKey) {
		this.authKey = authKey;
	}

	public int getFriendsVerify() {
		return friendsVerify;
	}

	public void setFriendsVerify(int friendsVerify) {
		this.friendsVerify = friendsVerify;
	}

	public int getIsVibration() {
		return isVibration;
	}

	public void setIsVibration(int isVibration) {
		this.isVibration = isVibration;
	}

	public int getIsTyping() {
		return isTyping;
	}

	public void setIsTyping(int isTyping) {
		this.isTyping = isTyping;
	}

	public int getIsUseGoogleMap() {
		return isUseGoogleMap;
	}

	public void setIsUseGoogleMap(int isUseGoogleMap) {
		this.isUseGoogleMap = isUseGoogleMap;
	}

	public int getIsEncrypt() {
		return isEncrypt;
	}

	public void setIsEncrypt(int isEncrypt) {
		this.isEncrypt = isEncrypt;
	}

	public int getCloseTelephoneFind() {
		return closeTelephoneFind;
	}

	public void setCloseTelephoneFind(int closeTelephoneFind) {
		this.closeTelephoneFind = closeTelephoneFind;
	}

	public String getChatRecordTimeOut() {
		return chatRecordTimeOut;
	}

	public void setChatRecordTimeOut(String chatRecordTimeOut) {
		this.chatRecordTimeOut = chatRecordTimeOut;
	}

	public double getChatSyncTimeLen() {
		return chatSyncTimeLen;
	}

	public void setChatSyncTimeLen(double chatSyncTimeLen) {
		this.chatSyncTimeLen = chatSyncTimeLen;
	}

	public Integer getIsKeepalive() {
		return isKeepalive;
	}

	public void setIsKeepalive(Integer isKeepalive) {
		this.isKeepalive = isKeepalive;
	}

	public Integer getShowLastLoginTime() {
		return showLastLoginTime;
	}

	public void setShowLastLoginTime(Integer showLastLoginTime) {
		this.showLastLoginTime = showLastLoginTime;
	}

	public Integer getShowTelephone() {
		return showTelephone;
	}

	public void setShowTelephone(Integer showTelephone) {
		this.showTelephone = showTelephone;
	}

	public Integer getPhoneSearch() {
		return phoneSearch;
	}

	public void setPhoneSearch(Integer phoneSearch) {
		this.phoneSearch = phoneSearch;
	}

	public Integer getNameSearch() {
		return nameSearch;
	}

	public void setNameSearch(Integer nameSearch) {
		this.nameSearch = nameSearch;
	}

	public String getFriendFromList() {
		return friendFromList;
	}

	public void setFriendFromList(String friendFromList) {
		this.friendFromList = friendFromList;
	}

	public String getDeviceType() {
		return deviceType;
	}

	public void setDeviceType(String deviceType) {
		this.deviceType = deviceType;
	}
}
