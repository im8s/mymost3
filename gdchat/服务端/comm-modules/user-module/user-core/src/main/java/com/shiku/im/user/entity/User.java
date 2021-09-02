package com.shiku.im.user.entity;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.annotation.JSONField;
import com.shiku.im.entity.Config;
import com.shiku.im.user.model.UserExample;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.utils.DateUtil;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Data
@Document(value = "user")
public class User {

	public static String getDBName(){
		return "user";
	}
	@Id
	private Integer userId;// 用户Id

	//@JSONField(serialize = false)

	@Indexed
	private String userKey;// 用户唯一标识

	/**
	 * 通讯账号 唯一
	 */
	@Indexed
	private String account;

	/**
	 * account 加密后的通讯账号
	 */
	private String encryAccount;

	/**
	 * 修改账号次数
	 */
	private int setAccountCount = 1;


	@JSONField(serialize = false)
	private String username; //用户名

	//@JSONField(serialize = false)
	private String password;

	private String appId; //ios 需要判断的包名

	// 用户类型：0=普通用户；  2=公众号 ；
	private Integer userType=0;

	//消息免打扰
	private Integer offlineNoPushMsg=0;//1为开启  0为关闭


	private String openid;// 微信openId


	private String aliUserId; // 支付宝用户Id

	/**
	 * dh 消息公钥
	 */
	private String dhMsgPublicKey;
	/**
	 * dh 消息私钥
	 */
	private String dhMsgPrivateKey;

	/**
	 * rsa 消息公钥
	 */
	private String rsaMsgPublicKey;
	/**
	 * rsa 消息私钥
	 */
	private String rsaMsgPrivateKey;

	@Indexed
	private String areaCode;

	@Indexed
	private String telephone;

	@Indexed
	private String phone;

	private String name;// 姓名

	@Indexed
	private String nickname;// 昵称

	@Indexed
	private Long birthday;// 生日

	@Indexed
	private Integer sex;// 性别  0 女 1:男

	@Indexed
	private long active=0;// 最后出现时间

	//@GeoSpatialIndexed
	private Loc loc;// 地理位置

	private String description;// 签名、说说、备注

	private Integer countryId;// 国家Id

	private Integer provinceId;// 省份Id

	private Integer cityId;// 城市

	private Integer areaId;// 地区Id

	private Integer level;// 等级

	private Integer vip; // VIP级别

	private Double balance=0.0; //用户余额


	/**
	 * appConfig
	 * balanceVersion
	* 余额加密版本
	 * 0 兼用老版本  balanceSafe 加密字段为空  取 balance 加密保存
	 * 1 新版 加密   balanceSafe 为空  余额为 0
	 **/

	// 用户余额安全加密值
	private byte[] balanceSafe=null;

	private Integer msgNum=0;//未读消息数量


	private Double totalRecharge=0.0;//充值总金额


	private Double totalConsume=0.0;//消费总金额


	private Integer friendsCount = 0;// 好友数


	private Integer fansCount = 0;// 粉丝数


	private Integer attCount = 0;// 关注数

	private Long createTime;// 注册时间

	private Long modifyTime;// 更新时间

	private String idcard;// 身份证号码

	private String idcardUrl;// 身份证图片地址

	private String msgBackGroundUrl;// 朋友圈背景URL

	private Integer isAuth = 0;// 是否认证 0:否  1:是  (该字段目前用于标示用户是否使用短信验证码注册--2018-10-11)

	private Integer status = 1;// 状态：1=正常, -1=禁用
	@Indexed
	private  Integer onlinestate=0;   //在线状态，默认离线0  在线 1

	private String payPassword;// 用户支付密码

	private String regInviteCode; //注册时填写的邀请码

	private String invitedUserId; //被xx用户id邀请来的

	private List<IpInfo> ipInfo;

	private Integer permitUserType = 1; // 0-普通会员 1-商务号 (用来区分是否可以主动添加会员)

	//********************引用字段********************


	private @Transient LoginLog loginLog;// 登录日志

	private UserSettings settings;// 用户设置



	private @Transient List<Integer> role;// 角色

	private @Transient String myInviteCode;//我的邀请码




	//创建房间次数
	private int num=0;

	//是否暂停 0：正常 1：暂停
	private int isPasuse;

	// 用户的地理位置
	private String area;

	@Transient
	private int walletUserNo = 0;// 是否在易宝开户

	private @Transient int isOpenResetPwd;// 开启端到端重置密码处理

	// ********************引用字段********************



	@Override
	public String toString() {
		return JSON.toJSONString(this);
	}



	/**
	 * 不是 本人 调用  设置 返回字段
	 * @param ReqUserId  请求者UserId
	 */
	public void buildNoSelfUserVo(int ReqUserId) {
		this.setPassword(null);
		this.setOpenid(null);
		this.setAliUserId(null);
		this.setAttCount(0);
		this.setFansCount(0);
		this.setFriendsCount(0);
		this.setMsgNum(0);
		this.setUserKey(null);
		this.setLoginLog(null);
		this.setOfflineNoPushMsg(null);
		this.setPayPassword(null);
		this.setTotalRecharge(0.0);
		this.setTotalConsume(0.0);
		//获取他人的用户信息,只返回对应用户的公钥,不返回私钥
		this.setDhMsgPrivateKey(null);
		this.setRsaMsgPrivateKey(null);

		//用户与请求者为好友关系
		/*if(this.getFriends()!=null && Friends.Status.Friends==this.getFriends().getStatus()) {
			this.getFriends().setDhMsgPublicKey(this.getDhMsgPublicKey());
			this.getFriends().setRsaMsgPublicKey(this.getRsaMsgPublicKey());
		}*/

		this.setDhMsgPublicKey(null);
		this.setRsaMsgPublicKey(null);
	}


	@Setter
	@Getter
	public static class LoginLog{


		private int isFirstLogin;
		private long loginTime;
		private String apiVersion;
		private String osVersion;
		private String model;
		private String serial;
		private double latitude;
		private double longitude;
		private String location;
		private String address;

		private long offlineTime;

		@Override
		public String toString() {
			return "LoginLog [isFirstLogin=" + isFirstLogin + ", loginTime=" + loginTime + ", apiVersion=" + apiVersion
					+ ", osVersion=" + osVersion + ", model=" + model + ", serial=" + serial + ", latitude=" + latitude
					+ ", longitude=" + longitude + ", location=" + location + ", address=" + address + ", offlineTime="
					+ offlineTime + "]";
		}


	}
	@Setter
	@Getter
	public static class DeviceInfo{

		private long loginTime;
		/**
		 * 设备号   android  ios  web
		 */
		private String deviceKey;

		private String adress;// 地区标识  例  CN HK

		private int online;//在线状态

		//ios 推送 用到的 appId
		private String appId;

		/**
		 * 推送平台厂商
		 * 华为 huawei
		 * 小米 xiaomi
		 * 百度 baidu
		 * apns ios
		 */
		private String pushServer;

		/**
		 * 推送平台的 token
		 */
		private String pushToken;

		/**
		 * VOip  推送 token
		 */
		private String voipToken;

		/**
		 * 同时使用多个推送平台的
		 */
		//private Map<String,String> pushMap;

		/**
		 * 下线时间
		 */
		private long offlineTime;



		@Override
		public String toString() {
			return JSON.toJSONString(this);
		}




	}

	@Document(value="userLoginLog")
	public static class UserLoginLog {

		@Id
		private Integer userId;
		/**
		 *
		* @Description: TODO(登陆日志信息)
		* 
		* @date 2018年8月18日
		 */
		private LoginLog loginLog;

		/**
		 * 登陆设备列表
		 * web DeviceInfo
		 * android  DeviceInfo
		 * ios DeviceInfo
		 */
		private Map<String,DeviceInfo> deviceMap;





		public UserLoginLog() {
			super();
		}
		public static LoginLog init(UserExample example, boolean isFirst) {
			LoginLog info = new LoginLog();
			info.setIsFirstLogin(isFirst ? 1 : 0);
			info.setLoginTime(DateUtil.currentTimeSeconds());
			info.setApiVersion(example.getApiVersion());
			info.setOsVersion(example.getOsVersion());

			info.setModel(example.getModel());
			info.setSerial(example.getSerial());
			info.setLatitude(example.getLatitude());
			info.setLongitude(example.getLongitude());
			info.setLocation(example.getLocation());
			info.setAddress(example.getAddress());
			info.setOfflineTime(0);

			return info;
		}
		public Integer getUserId() {
			return userId;
		}
		public void setUserId(Integer userId) {
			this.userId = userId;
		}
		public Map<String,DeviceInfo> getDeviceMap() {
			return deviceMap;
		}
		public void setDeviceMap(Map<String,DeviceInfo> deviceMap) {
			this.deviceMap = deviceMap;
		}
		public LoginLog getLoginLog() {
			return loginLog;
		}
		public void setLoginLog(LoginLog loginLog) {
			this.loginLog = loginLog;
		}

	}

	@Data
	@ApiModel("ip信息")
	public static class IpInfo {
		@ApiModelProperty("ip")
		private String ip;
		@ApiModelProperty("ip真实位置")
		private String ipLocation;
	}

	@Data
	@ApiModel("用户设置")
	public static class UserSettings {
		@ApiModelProperty("允许关注")
		private int allowAtt=1;// 允许关注
		@ApiModelProperty("允许打招呼")
		private int allowGreet=1;// 允许打招呼
		@ApiModelProperty("加好友需验证")
		private int friendsVerify=-1;// 加好友需验证
		@ApiModelProperty("是否开启客服模式")
		private int openService=-1;//是否开启客服模式
		@ApiModelProperty("是否振动   1：开启    0：关闭")
		private int isVibration=-1;// 是否振动   1：开启    0：关闭
		@ApiModelProperty("让对方知道我正在输入   1：开启       0：关闭")
		private int isTyping=-1;// 让对方知道我正在输入   1：开启       0：关闭
		@ApiModelProperty("使用google地图    1：开启   0：关闭")
		private int isUseGoogleMap=1;// 使用google地图    1：开启   0：关闭
		@ApiModelProperty("是否开启加密传输    1:开启    0:关闭")
		private int isEncrypt=-1;// 是否开启加密传输    1:开启    0:关闭
		@ApiModelProperty("是否开启多点登录   1:开启     0:关闭")
		private int multipleDevices=-1;// 是否开启多点登录   1:开启     0:关闭
		/**
		 * 关闭手机号搜索用户
		   关闭次选项 不用使用手机号搜索用户
		   0 开启    1 关闭
		   默认开启
		 */
		@ApiModelProperty("关闭手机号搜索用户")
		private int closeTelephoneFind=0;

		//聊天记录 销毁  时间   -1 0  永久   1 一天
		@ApiModelProperty("聊天记录 销毁  时间   -1 0  永久   1 一天")
		private String chatRecordTimeOut="0";
		@ApiModelProperty(" 聊天记录 最大 漫游时长    -1 永久  -2 不同步")
		private double chatSyncTimeLen=-1;//  聊天记录 最大 漫游时长    -1 永久  -2 不同步
		@ApiModelProperty("是否安卓后台常驻保活app 0：取消保活  1：保活")
		private Integer isKeepalive = 1;// 是否安卓后台常驻保活app 0：取消保活  1：保活
		@ApiModelProperty("显示上次上线时间   -1 所有人不显示 1所有人显示  2 所有好友显示   3 手机联系人显示")
		private Integer showLastLoginTime = -1;// 显示上次上线时间   -1 所有人不显示 1所有人显示  2 所有好友显示   3 手机联系人显示
		@ApiModelProperty("显示我的手机号码   -1 所有人不显示 1所有人显示  2 所有好友显示   3 手机联系人显示")
		private Integer showTelephone = -1;// 显示我的手机号码   -1 所有人不显示 1所有人显示  2 所有好友显示   3 手机联系人显示
		@ApiModelProperty("允许手机号搜索 1 允许 0 不允许")
		private Integer phoneSearch = 1;// 允许手机号搜索 1 允许 0 不允许
		@ApiModelProperty("允许昵称搜索  1 允许 0 不允许")
		private Integer nameSearch = 1;// 允许昵称搜索  1 允许 0 不允许
		@ApiModelProperty("通过什么方式添加我 0:系统添加好友 1:二维码 2：名片 3：群组 4： 手机号搜索 5： 昵称搜索")
		private String friendFromList = "1,2,3,4,5";// 通过什么方式添加我  0:系统添加好友 1:二维码 2：名片 3：群组 4： 手机号搜索 5： 昵称搜索


		/*屏蔽  不看某些人的  生活圈  和 短视频*/
		@ApiModelProperty("屏蔽  不看某些人的  生活圈  和 短视频")
		private Set<Integer> filterCircleUserIds;
		@ApiModelProperty("授权开关  1-需要授权   0-不需要授权")
		private Integer authSwitch = 0; //授权开关  1-需要授权   0-不需要授权		/*sync*/
		// 不让某些人看自己的生活圈和短视频
		@ApiModelProperty("不让某些人看自己的生活圈和短视频")
		private Set<Integer> notSeeFilterCircleUserIds;

		@ApiModelProperty("针对个人是否开启位置相关服务 0：开启 1：关闭")
		private int isOpenPrivacyPosition = 0;// 针对个人是否开启位置相关服务 1：开启 0：关闭

		@ApiModelProperty("客户端消息页侧滑删除是否删除服务器消息")
		private int isSkidRemoveHistoryMsg = 1 ; // 是否删除服务器消息 默认开启 1:开启 0：关闭

		@ApiModelProperty("显示消息阅读状态")
		private int isShowMsgState = 1 ; // 显示消息阅读状态 默认开启 1:开启 0：关闭

		public UserSettings() {
			super();
		}

		public UserSettings(int allowAtt, int allowGreet, int friendsVerify, int openService, int isVibration,
				int isTyping, int isUseGoogleMap, int isEncrypt, int multipleDevices,
				int closeTelephoneFind, String chatRecordTimeOut, double chatSyncTimeLen,int authSwitch) {
			super();
			this.allowAtt = allowAtt;
			this.allowGreet = allowGreet;
			this.friendsVerify = friendsVerify;
			this.openService = openService;
			this.isVibration = isVibration;
			this.isTyping = isTyping;
			this.isUseGoogleMap = isUseGoogleMap;
			this.isEncrypt = isEncrypt;
			this.multipleDevices = multipleDevices;
			this.closeTelephoneFind = closeTelephoneFind;
			this.chatRecordTimeOut = chatRecordTimeOut;
			this.chatSyncTimeLen = chatSyncTimeLen;
			this.authSwitch = authSwitch;
		}



		public UserSettings(int openService) {
			super();
			this.openService = openService;
		}

		public static org.bson.Document getDefault() {
			Config config = SKBeanUtils.getSystemConfig();
			org.bson.Document dbObj=new org.bson.Document();
			dbObj.put("allowAtt", 1);// 允许关注
			dbObj.put("isVibration",config.getIsVibration());// 是否开启振动
			dbObj.put("isTyping",config.getIsTyping());// 让对方知道正在输入
			dbObj.put("isUseGoogleMap",config.getIsUseGoogleMap()); // 使用Google地图
			dbObj.put("allowGreet", 1);// 允许打招呼
			dbObj.put("friendsVerify", config.getIsFriendsVerify());// 加好友需要验证
			dbObj.put("openService", 0); // 是否开启客服模式
			dbObj.put("closeTelephoneFind",config.getTelephoneSearchUser());// 手机号搜索用户
			dbObj.put("chatRecordTimeOut",config.getOutTimeDestroy());// 聊天记录销毁时长
			dbObj.put("chatSyncTimeLen", config.getRoamingTime());// 漫游时长
			dbObj.put("isEncrypt",config.getIsEncrypt());// 加密传输
			dbObj.put("multipleDevices", config.getIsMultiLogin());// 支持多点登录
			dbObj.put("isKeepalive", config.getIsKeepalive());// 安卓保活
			dbObj.put("phoneSearch", config.getPhoneSearch());// 是否允许手机号搜索
			dbObj.put("nameSearch", config.getNameSearch());// 是否允许昵称号搜索
			dbObj.put("showLastLoginTime", config.getShowLastLoginTime());// 显示上次上线时间   -1 所有人不显示 1所有人显示  2 所有好友显示   3 手机联系人显示
			dbObj.put("showTelephone", config.getShowTelephone());// 显示我的手机号码   -1 所有人不显示 1所有人显示  2 所有好友显示   3 手机联系人显示
			dbObj.put("friendFromList", "1,2,3,4,5");// 通过什么方式添加我  0:系统添加好友 1:二维码 2：名片 3：群组 4： 手机号搜索 5： 昵称搜索
			dbObj.put("authSwitch", config.getAuthSwitch()); //授权开关   0-需要授权   1-不需要授权
			dbObj.put("isOpenPrivacyPosition", 0); // 针对个人是否开启位置相关服务 1：开启 0：关闭
			dbObj.put("isSkidRemoveHistoryMsg",1);// 客户端消息页面侧滑删除消息是否删除服务器消息
			dbObj.put("isShowMsgState",config.getIsShowMsgState());// 显示消息阅读状态
			return dbObj;
		}

	}


	public static class Count {
		private int att;
		private int fans;
		private int friends;

		public int getAtt() {
			return att;
		}

		public int getFans() {
			return fans;
		}

		public int getFriends() {
			return friends;
		}

		public void setAtt(int att) {
			this.att = att;
		}

		public void setFans(int fans) {
			this.fans = fans;
		}

		public void setFriends(int friends) {
			this.friends = friends;
		}
	}
	/**
	 * 坐标
	 *
	 * 
	 *
	 */
	public static class Loc {
		public Loc() {
			super();
		}

		public Loc(double lng, double lat) {
			super();
			this.lng = lng;
			this.lat = lat;
		}

		private double lng;// longitude  经度
		private double lat;// latitude   纬度

		public double getLng() {
			return lng;
		}

		public void setLng(double lng) {
			this.lng = lng;
		}

		public double getLat() {
			return lat;
		}

		public void setLat(double lat) {
			this.lat = lat;
		}

	}


	@Getter
	@Setter
	public static class ThridPartyAccount {

		private long createTime;
		private long modifyTime;
		private int status;// 状态（0：解绑；1：绑定）
		private String tpAccount;// 账号
		private String tpName;// 帐号所属平台名字或代码
		private String tpUserId;// 账号唯一标识



	}

	/**
	 * 新建类
	 * 
	 *
	 */

	@Getter
	@Setter
	@Document("loginDevices")
	public static class LoginDevices{
		@Id
		private int userId;
		private long createTime;
		private long modifyTime;
		private Set<LoginDevice> deviceList = new HashSet<>();
		@Override
		public String toString() {
			return "LoginDevices [userId=" + userId + ", createTime=" + createTime + ", modifyTime=" + modifyTime
					+ ", deviceList=" + deviceList + "]";
		}


	}

	@Getter
	@Setter
	public static class LoginDevice{
		private String serial;
		private long authTime;
		private String deviceType;//ios ...
		private byte status;//0  -1
		private int oldDevice=0;//0-表示新设备  1-表示旧设备
	}


}
