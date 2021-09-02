package com.shiku.im.comm.constants;

import java.util.*;


/**
 * 常量
 * 
 * 
 * 
 */
public class KConstants {
	
	public static boolean isDebug=true;
	
	public static final String PAGE_INDEX = "0";
	public static final String PAGE_SIZE = "15";
	
	public static final byte MOENY_ADD = 1; //金钱增加
	
	public static final byte MOENY_REDUCE = 2; //金钱减少
	
	public static final double LBS_KM=111.01;
	
	public static final int LBS_DISTANCE=50;
	
	
	// 不经过普通接口校验,走特殊接口校验
	public static final Set<String> filterSet = new HashSet<String>(){{
		
		add("/redPacket/sendRedPacket");// 发送红包
		
		add("/redPacket/sendRedPacket/v1");// 发送红包新版
		
		add("/redPacket/openRedPacket");// 打开红包
		
		add("/user/recharge/getSign");// 充值
		
		add("/transfer/wx/pay");// 企业向个人支付转账
		
		add("/alipay/transfer");// 支付宝提现
		
		add("/skTransfer/sendTransfer");// 系统转账
		
		add("/skTransfer/receiveTransfer");// 接受转账
		
		add("/pay/codePayment");// 付款码支付
		
		add("/pay/codeReceipt");// 二维码收款
		
		add("/pay/passwordPayment");// 对外支付
		
		add("/open/authInterface");// 第三方校验权限

		add("/tigase/shiku_muc_msgs");// 获取群组消息漫游（用户微信公众号群聊）


	}};
	
	// 不需要校验的接口
	public static final Set<String> NO_CHECKAPI_SET = new HashSet<String>(){{

		add("/user/recharge/wxPayCallBack");

		add("/user/recharge/aliPayCallBack");

		add("/alipay/callBack");
		
		add("/open/authorization");
		
		add("/open/sendMsgByGroupHelper");
		
		add("/open/webAppCheck");

		add("/open/getHelperList");

		add("open/authInterface");

		add("/open/codeAuthorCheck");

		add("/user/checkReportUrl");// 校验URL合法性

		add("/user/wxUserOpenId");// 微信回调获取openId

		add("/user/getWxUser");// 获取微信对应的用户信息

		add("/open/code/oauth");// 第三方调用通过code拿到用户信息

		add("/yopPayCallBack/recharge");// 易宝充值回调

		add("/yopPayCallBack/sendRedPacket");// 易宝发送红包回调

		add("/yopPayCallBack/transfer");// 易宝转账回调

		add("/yopPayCallBack/withdraw");// 易宝提现回调
	}};

	
	/**
	 * 用户ID 起始值 
	 */
	public static final int MIN_USERID=100000;
	/**
	 * 数据库分表 取余  计算值
	 * 
	 *
	 */
	public interface DB_REMAINDER{
		/**
		 * 用户  联系人表  取余数
		 */
		public static final int ADDRESSBOOK=10000;
		/**
		 * 群成员
		 */
		public static final int MEMBER=10000;
		
		/**
		 * 好友
		 */
		public static final int FIRENDS=10000;
		
		/**
		 * 
		 */
		public static final int DEFAULT=10000;
	}
	/**
	* @Description: TODO(设备标识)
	* 
	* @date 2018年8月20日
	 */
	public interface DeviceKey{
		final List<String> RESOURCES=Arrays.asList("android","ios","pc","mac","web","youjob");
		public static final String Android= "android";
		public static final String IOS= "ios";
		public static final String WEB= "web";
		public static final String PC= "pc";
		public static final String MAC="mac";
	}
	/**
	* @Description: TODO(推送平台)
	* 
	* @date 2018年8月20日
	 */
	public interface PUSHSERVER{
		//apns 推送
		public static final String APNS= "apns";
		
		public static final String APNS_VOIP= "apns_voip";
		//百度 推送
		public static final String BAIDU= "baidu";
		//小米 推送
		public static final String XIAOMI= "xiaomi";
		//华为 推送
		public static final String HUAWEI= "huawei";
		//极光 推送
		public static final String JPUSH= "Jpush";
		// google fcm推送
		public static final String FCM = "fcm";
		// 魅族 推送
		public static final String MEIZU = "meizu";
		// VIVO 推送
		public static final String VIVO = "vivo";
		// OPPO 推送
		public static final String OPPO = "oppo";
	}
	
	// 消费类型 
	public interface ConsumeType {
		public static final int USER_RECHARGE = 1;// 用户充值
		public static final int PUT_RAISE_CASH = 2;// 用户提现
		public static final int SYSTEM_RECHARGE = 3;// 后台充值
		public static final int SEND_REDPACKET = 4;// 发红包
		public static final int RECEIVE_REDPACKET = 5;// 领取红包
		public static final int REFUND_REDPACKET = 6;// 红包退款
		public static final int SEND_TRANSFER = 7;// 转账
		public static final int RECEIVE_TRANSFER = 8;// 接受转账
		public static final int REFUND_TRANSFER = 9;// 转账退回
		public static final int SEND_PAYMENTCODE = 10;// 付款码付款
		public static final int RECEIVE_PAYMENTCODE = 11;// 付款码收款
		public static final int SEND_QRCODE = 12;// 二维码收款 付款方
		public static final int RECEIVE_QRCODE = 13;// 二维码收款 收款方
		public static final int LIVE_GIVE = 14;// 直播送礼物
		public static final int LIVE_RECEIVE=15;// 直播收到礼物
		public static final int SYSTEM_HANDCASH=16;// 后台手工提现
		public static final int SDKTRANSFR_PAY=17;// 第三方调用支付
		public static final int MANUALPAYRECHARGE=18;// 扫码手动充值
		public static final int MANUALPAYWITHDRAW=19;// 扫码手动提现

	}
	
	public interface Room_Role{
		/**
		 * 群组 创建者
		 */
		public static final byte CREATOR=1;
		/**
		 * 管理员
		 */
		public static final byte ADMIN=2;
		/**
		 * 群成员
		 */
		public static final byte MEMBER=3;
		
		/**
		 * 隐身人
		 */
		public static final byte INVISIBLE=4;
		
		/**
		 * 监护人（暂时没用）
		 */
		public static final byte GUARDIAN=5;
		
	}
	
	// 后台角色权限
	public interface Admin_Role{
		// 游客  没有系统账单访问权限，没有财务人员访问权限，没有压测的访问权限，其他所有后台功能没有操作权限，只提供数据浏览
		public static final byte TOURIST = 1;
		// 公众号
		public static final byte PUBLIC = 2;
		// 机器人账号
		public static final byte ROBOT = 3;
		// 客服  提供用户，群组，相关聊天记录，朋友圈相关 的数据浏览
		public static final byte CUSTOMER = 4;
		// 管理员 除了 没有系统配置的操作权限，没有系统账单访问权限，没有财务人员访问权限，其他功能同超级管理员
		public static final byte ADMIN = 5;
		// 超级管理员 所有权限
		public static final byte SUPER_ADMIN = 6;
		// 财务  提供用户，群组，相关聊天记录，系统账单，红包,直播相关 的数据浏览   和账单相关的操作
		public static final byte FINANCE = 7;
	}
	
	// 集群配置标识
	public interface CLUSTERKEY{
		public static final int XMPP=1;// xmpp服务器
		public static final int HTTP=2;// http服务器
		public static final int VIDEO=3;// 视频服务器
		public static final int LIVE=4;// 直播服务器
	}
	
	//订单状态
	public interface OrderStatus {
		public static final int CREATE = 0;// 创建
		public static final int END = 1;// 成功
		public static final int DELETE = -1;// 删除
	}
	//支付方式
	public interface PayType {
		public static final int ALIPAY = 1;// 支付宝支付
		public static final int WXPAY = 2;// 微信支付
		public static final int BALANCEAY = 3;// 余额支付
		public static final int SYSTEMPAY = 4;// 系统支付
		public static final int BANKCARD = 5;// 有银行卡支付
	}
	public interface Key {
		public static final String RANDCODE = "KSMSService:randcode:%s";
		public static final String IMGCODE = "KSMSService:imgcode:%s";
	}

	//public static final KServiceException InternalException = new KServiceException(KConstants.ErrCode.InternalException,KConstants.ResultMsg.InternalException);

	public interface Expire {
		
		static final int DAY1 = 86400;
		static final int DAY7 = 604800;
		static final int HOUR12 = 43200;
		static final int HOUR=3600;
		static final int HALF_AN_HOUR=1800;
		static final int MINUTE=60;
	}

	
	public interface SystemNo{
		static final int System=10000;//系统号码
		static final int NewKFriend=10001;//新朋友
		static final int Circle=10002;//商务圈
		static final int AddressBook=10003;//通讯录
		static final int Notice=10006;//系统通知
		
	}
	/**
	* @Description: TODO(举报原因)
	* 
	* @date 2018年8月9日
	 */
	public interface ReportReason{
		static final Map<Integer,String> reasonMap=new HashMap<Integer, String>() {
            {
                put(100, "发布不适当内容对我造成骚扰");
                put(101, "发布色情内容对我造成骚扰");
                put(102, "发布违法违禁内容对我造成骚扰");
                put(103, "发布赌博内容对我造成骚扰");
                put(104, "发布政治造谣内容对我造成骚扰");
                put(105, "发布暴恐血腥内容对我造成骚扰");
                put(106, "发布其他违规内容对我造成骚扰");
                
                put(120, "存在欺诈骗钱行为");
                put(130, "此账号可能被盗用了");
                put(140, "存在侵权行为");
                put(150, "发布仿冒品信息");
                
                put(200, "群成员存在赌博行为");
                put(210, "群成员存在欺诈骗钱行为");
                put(220, "群成员发布不适当内容对我造成骚扰");
                put(230, "群成员传播谣言信息");
                
                put(300, "网页包含欺诈信息(如：假红包)");
                put(301, "网页包含色情信息");
                put(302, "网页包含暴力恐怖信息");
                put(303, "网页包含政治敏感信息");
                put(304, "网页在收集个人隐私信息(如：钓鱼链接)");
                put(305, "网页包含诱导分享/关注性质的内容");
                put(306, "网页可能包含谣言信息");
                put(307, "网页包含赌博信息");
            }
        };
		
	}


	public interface ResultCode {
	
		//接口调用成功
		static final int Success = 1;
		
		//接口调用失败
		static final int Failure = 0;

		//服务器繁忙
		static final int SystemIsBusy = 10001;

		//功能未开放
		static final int FUNCTION_NOTOPEN=10002;

		//请升级更新最新版本
		static final int PleaseUpgradeLatestVersion=10003;

		/*
		 * 有数据不能删除
		 * */
		static final int HaveDataCanNotDelete = 10101;

		// 数据不存在或已删除
		static final int DataNotExists = 10102;


		//权限验证失败
		static final int AUTH_FAILED = 10110;

		// 权限不足
		static final int NO_PERMISSION = 10111;



		//请求参数验证失败，缺少必填参数或参数错误
		static final int ParamsAuthFail = 1010101;
		
		//缺少请求参数：
		static final int ParamsLack = 1010102;
		
		//接口内部异常
		static final int InternalException = 1020101;
		
		//链接已失效
		static final int Link_Expired = 1020102;
		
		//缺少访问令牌
		static final int TokenEillegal = 1030101;
		
		//访问令牌过期或无效
		static final int TokenInvalid = 1030102;


		/**
		 *登陆信息已失效
		 */
		static final int LoginTokenInvalid = 1030112;

		
		//帐号不存在
		static final int AccountNotExist = 1040101;
		
		//帐号或密码错误
		static final int AccountOrPasswordIncorrect = 1040102;
		
		//原密码错误
		static final int OldPasswordIsWrong = 1040103;
		
		//短信验证码错误或已过期
		static final int VerifyCodeErrOrExpired = 1040104;
		
		//发送验证码失败,请重发!
		static final int SedMsgFail = 1040105;
		
		//请不要频繁请求短信验证码，等待{0}秒后再次请求
		static final int ManySedMsg = 1040106;
		
		//手机号码已注册!
		static final int PhoneRegistered = 1040107;
		



		//请输入图形验证码
		static final int NullImgCode=1040215;
		
		//图形验证码错误
		static final int ImgCodeError=1040216;


		
		//账号被锁定
		static final int ACCOUNT_IS_LOCKED = 1040304;
		
		// 第三方登录未绑定手机号码
		static final int UNBindingTelephone = 1040305;
		
		// 第三方登录提示账号不存在
		static final int SdkLoginNotExist = 1040306;

		// 二维码未被扫取
		static final int QRCodeNotScanned = 1040307;
		//二维码已扫码未登录
		static final int QRCodeScannedNotLogin = 1040308;
		//二维码已扫码登陆
		static final int QRCodeScannedLoginEd = 1040309;
		
		//二维码已失效
		static final int QRCode_TimeOut = 1040310;

		/*
		 * 微信等第三方账号已绑定
		 * */
		static final int ThirdPartyAlreadyBound = 1040316;


// --------------------------------- 华丽分割线------------------------------------------------------

		// 请填写手机号
		static final int PleaseFallTelephone = 100107;
		// 手机号未注册
		static final int PthoneIsNotRegistered = 100108;





		/**
		 *
		 * 好友相关
		 *
		 * 1005**
		 *
		 */
		//FriendsController 不能添加自己
		static final int NotAddSelf = 100501;
		//FriendsController 添加好友失败
		static final int AddFriendsFailure = 100502; 
		// 用户禁止二维码添加好友
		static final int NotQRCodeAddFriends = 100503;
		// 用户禁止名片添加好友
		static final int NotCardAddFriends = 100504;
		// 用户禁止从群组中添加好友
		static final int NotFromGroupAddFriends = 100505;
		// 用户禁止手机号搜索添加好友
		static final int NotTelephoneAddFriends = 100506;
		// 用户禁止昵称搜索添加好友
		static final int NotNickNameAddFriends = 100507;
		// 不能操作自己
		static final int NotOperateSelf = 100508;
		// 不能重复操作
		static final int NotRepeatOperation = 100509;
		// 对方已经是你的好友
		static final int FriendsIsExist = 100512;
		// 好友不存在
		static final int FriendsNotExist = 100511;
		// 好友不在我的黑名单中
		static final int NotOnMyBlackList = 100513;
		// 对方不是你的好友
		static final int NotYourFriends = 100510;
		// 关注成功
		static final int AttentionSuccess = 100514;
		// 关注成功已互为好友
		static final int AttentionSuccessAndFriends = 100515;
		// 关注失败
		static final int AttentionFailure = 100516;
		// 已被对方添加到黑名单
		static final int WasAddBlacklist = 100517;
		// 添加失败,该用户禁止添加好友
		static final int ProhibitAddFriends = 100518;

		// 没有通讯录好友
		static final int NotAdressBookFriends = 100520;

		//FriendGroupController 分组名称已存在
		static final int GroupNameExist = 100701;

		//用户不能添加好友
		static final int NotAddFriend = 100521;


		/**
		 * 群标识码 相关
		 */
		//LabelController 群标识码名已被使用
		static final int LabelNameIsUse = 100801;
		// 群标识码已添加
		static final int LabelIsExist = 100802;
		// 添加失败
		static final int AddFailure = 100803;
		// 群标识码名不能为空
		static final int NotLabelName = 100804;
		// 群标识码不存在
		static final int LabelNameNotExist = 100805;

		/**
		 * 直播间相关
		 * 1009**
		 */
		//liveRoomController 
		// 您的直播间已被锁住
		static final int LiveRoomLock = 100901;
		// 用户不在该房间
		static final int UserNotInLiveRoom = 100902;
		// 该直播间尚未开播，请刷新再试
		static final int LiveRoomNotStart = 100903;
		// 您已被踢出直播间
		static final int KickedLiveRoom = 100904;
		// 暂无礼物
		static final int NotHaveGift = 100905;
		// 不能设置主播为管理员
		static final int NotSetAnchorIsAdmin = 100906;
		// 该用户已经是管理员
		static final int UserIsAdmin = 100907;
		
		// 不能重复创建直播间
		static final int NotCreateRepeat = 100908;
		// 该成员不在当前直播间中
		static final int NotInLiveRoom = 100909;

		//MsgController 评论内容不能为空
		static final int CommentNotNull = 101001;
		// 内容不存 或已被删除
		static final int ContenNoExist = 101002;
		// 该朋友圈禁止评论
		static final int NotComment = 101003;
		// 消息缓存解析失败
		static final int MsgCacheParsingFaliure = 101004;


		/**
		 * 群组相关
		 * 1004**
		 */
		// RoomController
		// 该群组已被后台锁定
		static final int RoomIsLock = 100401;
		// 群成员上限不能低于当前群成员人数
		static final int NotLowerGroupMember = 100402;
		// 请指定新群主
		static final int SpecifyNewOwner = 100403;
		// 不能转让群组给自己
		static final int NotTransferToSelf = 100404;
		// 对方不是群成员不能转让
		static final int NotGroupMember = 100405;
		// 不能禁言群主
		static final int NotBannedGroupOwner = 100406;
		// 邀请群成员 需要群主同意
		static final int InviteNeedAgree = 100421;
		// 不是好友不能邀请
		static final int NotFriendNoInvite = 100407;
		// 隐身人不可以邀请用户加群
		static final int NotInviteInvisible = 100408;
		
		// 群人数已达到上限，加入人数过多
		static final int RoomMemberAchieveMax = 100423;
		// 设置群人数不得超过10000
		static final int MaxCrowdNumber = 100425;
		// 禁止对隐身人禁言处理（隐身人不能发言）
		static final int NotChatInvisible = 100426;
		// 新建群最大人数超出群最大人数
		static final int PassRoomMax = 100427;

		// 红包类型错误，领取异常
		static final int ReceiveRedPackError = 100428;

		// 触发日发送限额
		static final int SendVerificationCodeErrorByUpper = 100429;
		// 非法手机号
		static final int SendVerificationCodeErrorByIllegalPhone = 100430;
		// 业务限流
		static final int SendVerificationCodeErrorByRequest = 100431;

		// 该成员不在群组中
		static final int MemberNotInGroup = 100409;
		// 该后台管理员状态异常
		static final int BackAdminStatusError = 100422;
		// 不能移出群主
		static final int NotRemoveOwner = 100410;

		// 超过房间最大人数，加入房间失败
//		static final int MoreMaxPeople = 100411;
		// 房间不存在
		static final int NotRoom = 100411;
		// 群主不能设置为管理员
		static final int RoomOwnerNotSetAdmin = 100412;
		// 该成员不是隐身人
		static final int MemberNotInvisible = 100413;
		// 该成员不是监控人
		static final int MemberNotMonitor = 100414;
		// 群组已过期失效
		static final int RoomTimeOut = 100415;
		// 群助手已存在
		static final int GroupHelperExist = 100416;
		// 群助手不存在
		static final int GroupHelperNotExist = 100417;
		// 关键字已存在
		static final int KeyWordIsExist =100418;
		// 关键字不存在
		static final int KeyWordNotExist = 100419;
		// 删除失败
		static final int DeleteFailure = 100420;
		// 不能转让群组给隐身人
		static final int NotTransferToInvisible = 100424;


		// 该网页地址已被举报
		static final int WEBURLISREPORTED = 100203;


		//UserController 手机号已注册
		static final int TelephoneIsRegister = 100205;
		// 用户注册失败
		static final int FailedRegist = 100206;
		// 获取用户信息失败
		static final int FailedGetUserId = 100207;
		// 绑定关系不存在
		static final int NoBind = 100208;
		// 新旧密码一致,请重新输入
		static final int NewAndOldPwdConsistent = 100209;
		// 设置免打扰失败
		static final int SetDNDFailure = 100210;
		// 该用户不存在
		static final int UserNotExist = 100211;
		// 缺少通讯号
		static final int NotAccount = 100212;
		// 通讯号错误
		static final int ErrAccount = 100213;
		// 缺少code
		static final int NotCode = 100214;
		// 获取openid失败
		static final int GetOpenIdFailure = 100215;
		// 短信验证码不能为空
		static final int SMSCanNotEmpty = 100216;
		// 获取支付宝授权authInfo失败
		static final int GetAliAuthInfoFailure = 100217;

        // 禁止访问对方朋友圈
        static final int DontVisitFriendsMsg = 100219;
		//用户密钥不存在
		static final int USER_KEYPAIR_NOTEXIST=100220;

		// 核验密码失败
		static final int VERIFYPASSWORDFAIL=100222;
		// 没有权限打开地址位置相关设置
		static final int NOAUTHORITYOPENPOSITION=100224;

		// 该群组不支持退群
		static final int NO_SUPPORT_QUIT_ROOM=100225;
		// --------------------------------- 华丽分割线------------------------------------------------------
		//授权失败
		static final int NO_AUTO = 101988;	
		//授权成功
		static final int SUCCESS_AUTO = 101987;	
		//登入超时
		static final int Login_OverTime = 101986;
		//设备序列化为空
		static final int DeviceSerial_NULL = 101985;
		//设备版本类型为空
		static final int DeviceType_NULL = 101984;
		//无设备号
		static final int NOFACILITY = 101983;
		//授权码失效
		static final int LOSEEFFECTIVENESS_AUTH = 101982;

		// --------------------------------- 华丽分割线------------------------------------------------------
		//申请公众号失败
		static final int NO_PASS = 101981;
		//用户已存在
		static final int USEREXITS = 101980;


		/**
		 * 收藏相关
		 * 105***
		 */

		/**
		 *消息不支持收藏
		 */
		static final int NOTSUPPORT_COLLECT= 105002;

		// 当前设置不保存单聊聊天记录,暂不支持收藏
		static final int NOSAVEMSGAND = 105003;

		//未开通支付相关功能
		static final int CLOSEPAY = 106001;
	}





	// 多点登录下操作类型
	public interface MultipointLogin {
		static final String SYNC_LOGIN_PASSWORD = "sync_login_password";// 修改密码
		static final String SYNC_PAY_PASSWORD = "sync_pay_password";// 支付密码
		static final String SYNC_PRIVATE_SETTINGS = "sync_private_settings";// 隐私设置
		static final String SYNC_LABEL = "sync_label";// 好友标签
		static final String SYNC_YOP_OPEN_ACCOUNT = "sync_yop_open_account";// 易宝支付账户设置

		static final String TAG_FRIEND = "friend";// 好友相关
		static final String TAG_ROOM = "room";// 群组标签相关
		static final String TAG_LABLE = "label";// 好友分组操作相关
	}
	

	
	// 系统账号
	public interface systemAccount {
		static final int ADMIN_CONSOLE_ACCOUNT = 1000;// 后台超级管理员
		static final int AMOUNT_ACCOUNT = 1100;// 金额通知相关
		static final int CUSTOMER_ACCOUNT  = 10000;// 系统客服公众号
	}

	//易宝
	public interface YopPayType{
		public static final int RECHARGE = 1;// 易宝充值
		public static final int WITHDRAW = 2;// 易宝提现
		public static final int TRANSFER = 3;// 易宝转账
		public static final int RECEIVETRANSFER = 4;// 易宝接收转账
		public static final int SENDONEREDPACKET = 5;// 易宝一对一发红包
		public static final int SENDGROUPREDPACKET = 6;// 发群普通红包
		public static final int SENDRANDOMREDPACKET = 7;// 发拼手气红包
		public static final int RECEIVEREDPACKET = 8;// 接收红包
		public static final int USERFEE = 9 ;// 手续费
	}


	
}
