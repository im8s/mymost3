//
//  JXServer.h
//  sjvodios
//
//  Created by  on 12-5-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ATMHud.h"
#import <AddressBook/AddressBook.h>
#import "JXAddressBook.h"

@class AppDelegate;
@class JXConnection;
@class JXImageView;
@class McDownload;
@class WeiboReplyData;
@class jobData;
@class JXExam;
@class companyData;
@class searchData;
@class roomData;
@class memberData;
@class JXLocation;

#define jx_page_size 12
#define jx_login_view -5100001
#define jx_connect_timeout 15
#define jx_did_yes 0
#define jx_did_no 1
#define jx_showImage_time 2.0
#define kWBSDKDemoAppKey @"2267464530" //设置sina appkey
#define kWBSDKDemoAppSecret @"07f47bc3c75fdcdd243ce92a48624e80"

#define show_error 1
#define hide_error 0

#define act_Register @"user/register" //注册
#define act_RegisterV1 @"user/register/v1" //注册(新)
#define act_UserLogin @"user/login" //登录
#define act_UserLoginV1 @"user/login/v1" //登录
#define act_UserLogout @"user/logout" //登出
#define act_UserSMSLogin @"user/smsLogin" // 验证码登录
#define act_UserDeviceIsAuth  @"user/deviceIsAuth" //请求授权
#define act_UserAffirmAuth  @"user/affirmDeviceAuth"  //确认授权

#define act_OutTime @"user/outtime" //进入后台，纪录数据
#define act_getCurrentTime @"getCurrentTime" //获取当前服务器时间

#define act_userLoginAuto @"user/login/auto" //自动登录
#define act_userLoginAutoV1 @"user/login/auto/v1" //自动登录
#define act_UserSearch @"user/query" //搜索用户
#define act_PublicSearch @"public/search/list" //搜索公众号列表
#define act_GetDiscoveryWebList    @"general/friendsterWebsiteList"      //djk获取朋友圈Web列表

#define act_UserGet @"user/get"
#define act_UserUpdate @"user/update"
#define act_PKPushSetToken @"user/apns/setToken"
#define act_jPushSetToken @"user/jPush/setJPushIOSRegId"

#define act_BindUser @"user/acct/add" //绑定用户
#define act_UnBindUser @"user/acct/delete" //解绑用户
#define act_UpdatePrivacy @"user/privacy/modify" //隐私修改
#define act_GetPrivacy @"user/privacy/get" //获取隐私
#define act_PhotoAdd @"user/photo/add" //添加照片
#define act_PhotoDel @"user/photo/delete" //删除照片
#define act_PhotoMod @"user/photo/update" //更新照片
#define act_PhotoList @"user/photo/list" //照片列表
#define act_SetHeadImage @"avatar/set" //设置头像
#define act_PwdUpdate @"user/password/update" //密码修改
#define act_PwdUpdateV1 @"user/password/update/v1" //密码修改(新)
#define act_PwdReset @"user/password/reset" //忘记密码
#define act_PwdResetV1 @"user/password/reset/v1" //忘记密码(新)
#define act_Report @"user/report" //举报用户
#define act_ResumeGet @"resume/wap" //看简历

#define act_UploadFile @"upload/UploadServlet" //上传文件
#define act_UploadVoiceServlet @"upload/UploadVoiceServlet" //上传音频文件
#define act_UploadHeadImage @"upload/UploadAvatarServlet" //上传头像
#define act_SetGroupAvatarServlet @"upload/GroupAvatarServlet" //上传群组头像
#define act_CheckPhone @"verify/telephone" //检测手机号
#define act_GetCode @"getImgCode" //获取图片验证码
#define act_SendSMS @"basic/randcode/sendSms" //发送短信
#define act_Config @"config"

#define act_FriendAdd @"friends/add" //加朋友
#define act_FriendDel @"friends/delete" //删除朋友
#define act_FriendList @"friends/list" //朋友列表
#define act_FansList @"friends/fans/list" //粉丝列表
#define act_AttentionAdd @"friends/attention/add" //加关注
#define act_AttentionDel @"friends/attention/delete" //取消关注
#define act_FriendsUpdate @"friends/update" // 更新朋友的聊天消息过期时间

#define act_SettingsUpdate @"user/settings/update" //更改好友验证设置
#define act_Settings @"user/settings" //获取设置

#define act_offlineOperation @"user/offlineOperation" //离线期间调用的接口

#define act_AttentionList @"friends/attention/list" //关注列表
#define act_BlacklistAdd @"friends/blacklist/add" //加入黑名单
#define act_BlacklistDel @"friends/blacklist/delete" //取消黑名单
#define act_BlacklistList @"friends/blacklist" //黑名单列表
#define act_FriendRemark @"friends/remark" //备注好友名

#define act_MsgGet @"b/circle/msg/get" //获取单条商务圈
#define act_MsgList @"b/circle/msg/list" //获取商务圈列表
#define act_MsgAdd @"b/circle/msg/add" //加商务圈
#define act_Msgforward @"b/circle/msg/forwarding" //转发商务圈
#define act_MsgDel @"b/circle/msg/delete" //删除商务圈
#define act_PraiseList @"b/circle/msg/praise/list" //赞列表
#define act_PraiseAdd @"b/circle/msg/praise/add" //加赞
#define act_PraiseDel @"b/circle/msg/praise/delete" //取消赞
#define act_ForwardAdd @"b/circle/msg/forward/add" //转发成功
#define act_PlayAmountAdd @"b/circle/msg/playAmount/add" //观看数
#define act_CommentList @"b/circle/msg/comment/list" //评论列表
#define act_CommentAdd @"b/circle/msg/comment/add" //评论
#define act_CommentDel @"b/circle/msg/comment/delete" //取消评论
#define act_GiftAdd @"b/circle/msg/gift/add" //送礼
#define act_GiftList @"b/circle/msg/gift/list" //礼物列表
#define act_MsgListNew @"b/circle/msg/square"//最新商务圈
#define act_MsgListUser @"b/circle/msg/user"//个人主页
#define act_WeiboDeleteCollect @"b/circle/msg/deleteCollect"//朋友圈取消收藏
#define act_filterUserCircle @"user/filterUserCircle"//不看他(她)生活圈和视频

#define act_resumeDelete @"resume/delete"
#define act_resumeUpdate @"resume/update"
#define act_resumeGet @"resume/get"
#define act_resumeAdd @"resume/add"
#define act_resumeListName @"resume/name/list"
#define act_resumeList @"resume/list"
#define act_resumeUpdateE @"resume/e/update"
#define act_resumeUpdateW @"resume/w/update"
#define act_resumeUpdateP @"resume/projectList/update"

#define act_payList @"pay_goods/list" //充值方式列表
#define act_payBuy @"pay_goods/buy" //下单
#define act_bizList @"biz_goods/list" //商品列表
#define act_bizBuy @"biz_goods/buy" //下单

#define act_nearbyUser @"nearby/user"
#define act_nearNewUser @"nearby/newUser"//附近新用户

#define act_roomAdd @"room/add"//创建群组
#define act_roomJoin @"room/join" // 加群（暂用于扫码加群）
#define act_roomDel @"room/delete"//删除
#define act_roomGet @"room/get"//获取
#define act_roomSet @"room/update"//设置
#define act_roomList @"room/list"//获取群主列表
#define act_roomListHis @"room/list/his"//
#define act_roomGetRoom @"room/getRoom" // 获取群组信息
#define act_roomMemberGetMemberListByPage @"room/member/getMemberListByPage"    // 群成员分页获取
#define act_updateNotice @"room/updateNotice" // 修改群公告

#define act_roomMemberList @"room/member/list"//获取成员列表
#define act_roomMemberGet @"room/member/get"//获取群成员
#define act_roomMemberDel @"room/member/delete"//删除群成员
#define act_roomMemberSet @"room/member/update"//设置群成员
#define act_roomSetAdmin @"room/set/admin"//设置管理员
#define act_roomSetInvisibleGuardian @"room/setInvisibleGuardian"//设置隐身人、监控人
#define act_roomTransfer    @"room/transfer"    // 群主转让
#define act_roomDeleteNotice    @"room/notice/delete"    // 删除群组公告

#define act_shareAdd @"room/add/share"//添加共享文件
#define act_shareList @"room/share/find"//获取文件列表
#define act_shareGet @"room/share/get"//下载单个文件
#define act_shareDelete @"room/share/delete"//删除文件

#define act_setPushChannelId @"user/channelId/set"
#define act_getUserMoeny @"user/getUserMoeny"//获取余额
#define act_getSign @"user/recharge/getSign" //获取签名
#define act_getAliPayAuthInfo @"user/bind/getAliPayAuthInfo" //获取支付宝授权authInfo
#define act_aliPayUserId @"user/bind/aliPayUserId" //保存支付宝用户Id
#define act_aliPayUserIdV1 @"user/bind/aliPayUserId/v1" //保存支付宝用户Id(新)
#define act_alipayTransfer @"alipay/transfer" //支付宝提现
#define act_alipayTransferV1 @"alipay/transfer/v1" //支付宝提现(新)

#define act_userRechagrge @"user/Recharge" //直接充值
#define act_codePayment @"pay/codePayment"//二维码支付
#define act_codePaymentV1 @"pay/codePayment/v1"//二维码支付(新)
#define act_payGetQrKey @"pay/getQrKey" // 获取生成付款码的qrKey
#define act_payVerifyQrKey  @"pay/verifyQrKey"  //验证qrKey过期
#define act_codeReceipt @"pay/codeReceipt"//二维码收款
#define act_codeReceiptV1 @"pay/codeReceipt/v1"//二维码收款(新)
#define act_receiveTransfer @"skTransfer/receiveTransfer"//接受转账
#define act_getTransferInfo @"skTransfer/getTransferInfo" //获取转账信息
#define act_getConsumeRecordList @"friend/consumeRecordList" //好友交易记录明细
#define act_sendTransfer @"skTransfer/sendTransfer" //转账
#define act_sendTransferV1 @"skTransfer/sendTransfer/v1" //转账(新)
#define act_sendRedPacket @"redPacket/sendRedPacket"//发红包
#define act_sendRedPacketV1 @"redPacket/sendRedPacket/v1"//发红包(新)
#define act_sendRedPacketV2 @"redPacket/sendRedPacket/v2"//发红包(新2)
#define act_getRedPacket @"redPacket/getRedPacket"//获取红包详情
#define act_openRedPacket @"redPacket/openRedPacket"//领取红包
#define act_redPacketGetSendRedPacketList @"redPacket/getSendRedPacketList"// 获取发送的红包
#define act_redPacketGetRedReceiveList @"redPacket/getRedReceiveList"   // 收到的红包
#define act_redPacketReply @"redPacket/reply"   // 红包回复

#define get_NewVersion @"getNewVersion" //获取最新版本号
#define act_consumeRecord @"user/consumeRecord/list"//交易记录
#define act_readDelMsg @"tigase/deleteMsg"//阅后即焚
#define act_creatCompany @"org/company/create"//创建公司
#define act_setManager @"org/setManager"//指定管理员
#define act_getCompany @"org/company/getByUserId"//自动查找公司
#define act_managerList @"org/company/managerList"//管理员列表
#define act_updataCompanyName @"org/company/modify"//修改公司名
#define act_changeNotice @"org/company/changeNotice"//更改公司公告
#define act_seachCompany @"org/company/search"//查找公司
#define act_deleteCompany @"org/company/delete"//删除公司
#define act_createDepartment @"org/department/create"//创建部门
#define act_updataDepartmentName @"org/department/modify"//修改部门名称
#define act_deleteDepartment @"org/department/delete"//删除部门
#define act_addEmployee @"org/employee/add"//添加员工
#define act_deleteEmployee @"org/employee/delete"//删除员工
#define act_modifyDpart @"org/employee/modifyDpart"//更改员工部门
#define act_empList @"org/departmemt/empList"//部门员工列表
#define act_modifyRole @"org/employee/modifyRole"//更改员工角色
#define act_modifyPosition @"org/employee/modifyPosition"//更改员工职位(头衔）
#define act_companyList @"org/company/list"//公司列表
#define act_departmentList @"org/department/list"//部门列表
#define act_employeeList @"org/employee/list"//员工列表
#define act_companyInfo @"org/company/get"//公司详情
#define act_employeeInfo @"org/employee/get"//员工详情
#define act_dpartmentInfo @"org/department/get"//部门详情
#define act_companyNum @"org/company/empNum"//公司员工人数
#define act_dpartmentNum @"org/department/empNum"//部门员工数量
#define act_companyQuit @"org/company/quit"//退出公司/解散公司

#define act_tigaseGetLastChatList   @"tigase/getLastChatList"   //  获取首页的最近一条的聊天记录列表
#define act_tigaseMsgs @"tigase/shiku_msgs" // 获取单聊漫游聊天记录
#define act_tigaseMucMsgs @"tigase/shiku_muc_msgs"  // 获取群聊漫游聊天记录

#define act_publicMenuList @"public/menu/list"  // 公众号菜单

#define act_getHelperList @"open/getHelperList"  // 获取所有群助手列表
#define act_queryGroupHelper @"room/queryGroupHelper"  // 查询房间群助手接口
#define act_addGroupHelper @"room/addGroupHelper"  // 添加群助手接口
#define act_deleteGroupHelper @"room/deleteGroupHelper"  // 移除群助手接口
#define act_addAutoResponse @"room/addAutoResponse"  // 添加自动回复关键字
#define act_deleteAutoResponse @"room/deleteAutoResponse"  // 删除自动回复关键字接口

#define act_tigaseDeleteMsg @"tigase/deleteMsg" // 撤回&删除聊天记录
#define act_EmptyMsg    @"tigase/emptyMyMsg" // 清空聊天记录
#define act_friendsUpdateOfflineNoPushMsg @"friends/update/OfflineNoPushMsg"    // 消息免打扰

#define act_userEmojiAdd @"user/emoji/add"  // 收藏表情
#define act_userEmojiDelete @"user/emoji/delete"    // 取消收藏
#define act_userEmojiList @"user/emoji/list"   // 收藏表情列表
#define act_userCollectionList @"user/collection/list"   // 收藏列表

#define act_userCourseAdd       @"user/course/add"      // 添加课程
#define act_userCourseList      @"user/course/list"     // 查询课程
#define act_userCourseUpdate    @"user/course/update"   // 修改课程
#define act_userCourseDelete    @"user/course/delete"   // 删除课程
#define act_userCourseGet       @"user/course/get"      // 课程详情

#define act_userChangeMsgNum    @"user/changeMsgNum"     // 更新角标
#define act_roomMemberSetOfflineNoPushMsg   @"room/member/setOfflineNoPushMsg"  // 设置群消息免打扰

// 标签
#define act_FriendGroupAdd      @"/friendGroup/add" // 添加标签
#define act_FriendGroupUpdateGroupUserList  @"/friendGroup/updateGroupUserList"// 修改好友标签
#define act_FriendGroupUpdate   @"/friendGroup/update"  // 更新标签名
#define act_FriendGroupDelete   @"/friendGroup/delete"  // 删除标签
#define act_FriendGroupList     @"/friendGroup/list"    // 标签列表
#define act_FriendGroupUpdateFriend     @"/friendGroup/updateFriend"// 修改好友的  分组Id列表

#define act_UploadCopyFileServlet @"upload/copyFile" // 拷贝文件
#define act_copyRoom @"room/copyRoom" // 群组复制

// 通讯录
#define act_AddressBookUpload @"addressBook/upload" // 上传本地联系人
#define act_AddressBookGetAll @"addressBook/getAll" // 查询通讯录好友
#define act_FriendsAttentionBatchAdd    @"friends/attention/batchAdd"   // 联系人内加好友 不需要验证

#define act_UserBindWXCode @"user/bind/wxcode" // 用户绑定微信code，获取openid
#define act_UserBindWXCodeV1 @"user/bind/wxcode/v1" // 用户绑定微信code，获取openid(新)
#define act_UserBindWXAccount @"user/bindWxAccount" // 登陆后绑定微信号
#define act_TransferWXPay @"transfer/wx/pay" // 余额微信提现
#define act_TransferWXPayV1 @"transfer/wx/pay/v1" // 余额微信提现(新)
#define act_CheckPayPassword @"/user/checkPayPassword" // 检查支付密码是否是否正确
#define act_UpdatePayPassword @"/user/update/payPassword" // 更新支付密码

#define act_UserOpenMeet @"user/openMeet"   // 获取音视频域名

#define act_CircleMsgPureVideo  @"/b/circle/msg/pureVideo"  // 朋友圈纯视频接口
#define act_MusicList @"/music/list"    // 获取音乐接口

#define act_OpenAuthInterface   @"open/authInterface"  // 第三方权限认证


#define act_GetWxOpenId   @"user/getWxOpenId"  // 第三方登录获取openid
#define act_sdkLogin    @"user/sdkLogin"  // 第三方登录接口
#define act_sdkLoginV1    @"user/sdkLogin/v1"  // 第三方登录接口(新)
#define act_thirdLogin    @"user/bindingTelephone" //第三方登录绑定手机号码
#define act_thirdLoginV1    @"user/bindingTelephone/v1" //第三方登录绑定手机号码(新)
#define act_registerSDK    @"user/registerSDK" //第三方登录接口注册
#define act_registerSDKV1    @"user/registerSDK/v1" //第三方登录接口注册(新)

#define act_openCodeAuthorCheck     @"open/codeAuthorCheck" //网页第三方认证
#define act_userCheckReportUrl  @"user/checkReportUrl" //检查网址是不是被锁定
#define act_getBindInfo     @"user/getBindInfo" //第三方绑定
#define act_unbind    @"user/unbind" //第三方解绑

#define act_userVerifyPassword  @"user/verify/password" // 验证密码

// 面对面建群
#define act_RoomLocationQuery @"room/location/query"   // 面对面建群查询
#define act_RoomLocationJoin  @"room/location/join"    // 面对面建群加入
#define act_RoomLocationExit  @"room/location/exit"    // 面对面建群退出

// 视酷支付
#define act_PayGetOrderInfo @"pay/getOrderInfo"     //接口获取订单信息
#define act_PayPasswordPayment  @"pay/passwordPayment"  //输入密码后支付接口
#define act_PayPasswordPaymentV1  @"pay/passwordPayment/v1"  //输入密码后支付接口(新)

// web扫描二维码登录
#define act_UserQrCodeLogin @"/user/qrCodeLogin"    //web扫描二维码登录

#define act_UserGetByAccount @"user/getByAccount"  // 根据通讯号获取用户资料

//支付加密
#define act_AuthkeysGetPayPrivateKey    @"authkeys/getPayPrivateKey"    // 获取加密私钥
#define act_AuthkeysUploadPayKey   @"authkeys/uploadPayKey" // 上传RSA公私钥
#define act_TransactionGetCode  @"transaction/getCode"  // 获取加固临时密码
#define act_AuthkeysResetPayPassword    @"authkeys/resetPayPassword"    // 重置支付密码

// 登录加密
#define act_AuthkeysGetLoginPrivateKey  @"authkeys/getLoginPrivateKey"  // 获取登录加密私钥
#define act_AuthkeysUploadLoginKey  @"authkeys/uploadLoginKey"  // 登录上传公私钥
#define act_AuthGetLoginCode    @"auth/getLoginCode"    // 登录获取临时加固密码

// 消息加密
#define act_AuthkeysGetDHMsgKeyList @"authkeys/getDHMsgKeyList" // 获取好友DH公钥表
#define act_UserGetRandomStr    @"user/getRandomStr"    // 获取校验码，修改登录密码验签用
#define act_FriendsModifyEncryptType  @"friends/modify/encryptType" // 修改针对好友的加密方式
#define act_RoomUpdateEncryptType    @"room/updateEncryptType"  // 修改针对群组的加密方式
#define act_RoomGetAllMemberRsaPublicKey    @"room/getAllMemberRsaPublicKey"    // 获取所有群成员RSA公钥
#define act_RoomGetMemberRsaPublicKey   @"room/getMemberRsaPublicKey"   // 获取单个群成员RSA公钥
#define act_RoomResetGroupChatKey   @"room/resetGroupChatKey"   // 重置群组通信密钥
#define act_RoomUpdateGroupChatKey  @"room/updateGroupChatKey"  // 修改自己群组通信秘钥

// 扫码充值提现
#define act_ManualPayGetReceiveAccount  @"manual/pay/getReceiveAccount" // 获取转账人信息
#define act_ManualPayRecharge   @"manual/pay/recharge"  // 提交充值申请
#define act_ManualPayAddWithdrawAccount @"manual/pay/addWithdrawAccount"    // 添加提现账户
#define act_ManualPayGetWithdrawAccountList @"manual/pay/getWithdrawAccountList"    // 获取提现账户列表
#define act_ManualPayDeleteWithdrawAccount   @"manual/pay/deleteWithdrawAccount"  // 删除提现账户
#define act_ManualPayUpdateWithdrawAccount   @"manual/pay/updateWithdrawAccount"  // 修改提现账户
#define act_ManualPayWithdraw   @"manual/pay/withdraw"  // 提交提现申请

//银行卡支付接口
#define act_openAccount    @"yopPay/openAccount"  //用户开户
#define act_queryAccountInfo    @"yopPay/queryAccountInfo"  //查询钱包账户信息
#define act_recharge   @"yopPay/recharge"  //充值
#define act_queryCard   @"yopPay/queryCard"  //查询绑定银行卡
#define act_managePassword   @"yopPay/managePassword"  //安全设置（用于用户修改或重新设置钱包支付密码）
#define act_queryRecharge   @"yopPay/queryRecharge"  //充值结果查询
#define act_yopPaySendRedPacket   @"yopPay/sendRedPacket"  //发红包
#define act_queryRedPacketPayment   @"yopPay/queryRedPacketPayment"  //红包支付结果查询（如果回调不成功时,可调用）
#define act_yopPayOpenRedPacket   @"yopPay/openRedPacket"  //打开红包
#define act_yopPayTransfer   @"yopPay/transfer"  //转账
#define act_yopPayQueryTransfer   @"yopPay/queryTransfer"  //转账支付结果查询（如果回调不成功）
#define act_yopPayReceiveTransfer   @"yopPay/receiveTransfer"  //接收转账
#define act_yopPayWithdraw   @"yopPay/withdraw"  //提现
#define act_yopPayQueryWithdraw  @"yopPay/queryWithdraw"  //提现查询
#define act_getYopWalletBill  @"yopPay/getYopWalletBill"  //获取账单列表
#define act_yopPaySendSms  @"yopPay/randcode/sendSms"  //发送短信
#define act_queryConsumeRecordCount @"consumeRecord/queryConsumeRecordCount"  // 按月查询消费记录



@protocol JXServerResult;
@class AlixPayResult;
@class loginViewController;
@class TencentOAuth;
@class WBEngine;


@interface JXServer : NSObject<CLLocationManagerDelegate>{
    NSMutableDictionary* _dictWaitViews;
    
//    CLLocationManager *_location;
    int               _locationCount;
    BOOL              _bAlreadyAutoLogin;
    
    NSMutableArray*      _arrayConnections;
    NSMutableDictionary* _dictSingers;
    int _imgSongIndex;
    ATMHud* _hud;
}

// 通用接口请求，只是单纯的请求接口，不做其他操作
- (void)requestWithUrl:(NSString *)url toView:(id)toView;

-(JXConnection*)addTask:(NSString*)action param:(NSString*)param toView:(id)toView;
-(void)stopConnection:(id)toView;
-(NSString*)getString:(NSString*)s;

-(void)waitStart:(UIView*)view;
-(void)waitEnd:(UIView*)view;
-(void)waitFree:(UIView*)sender;
-(void)showMsg:(NSString*)s;
-(void)showMsg:(NSString*)s delay:(float)delay;
- (BOOL)checkCameraLimits;  // 检测摄像头
//-(void)doError:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array resultMsg:(NSString*)string errorMsg:(NSString*)errorMsg;

//-(void)addAnimation:(UIView*)iv time:(int)nTime;
//-(void)addAnimationPage:(UIView*)iv time:(int)nTime;
-(void)locate;
-(void)showLogin;
- (void)otherUpdatePassword;
-(void)doLoginOK:(NSDictionary*)dict user:(JXUserObject*)user;
-(void)doSaveUser:(NSDictionary*)dict;
- (void)getCurrentTimeToView:(id)toView;
-(void)login:(JXUserObject*)user toView:(id)toView;
-(void)loginV1:(NSString *)userId salt:(NSString *)salt data:(NSString *)data toView:(id)toView;
-(void)logout:(NSString *)areaCode toView:(id)toView;
//短信登录
- (void)userSMSLogin:(NSString *)areaCode account:(NSString *)account salt:(NSString *)salt data:(NSString *)data toView:(id)toView;
- (void)loginIsAuthKey:(NSString *)authKey toView:(id )toView;
- (void)agreeAuthLogin:(NSString *)authKey toView:(id )toView;

-(void)outTime:(id)toView;

-(BOOL)autoLogin:(id)toView;
-(void)autoLoginV1:(NSString *)loginToken salt:(NSString *)salt data:(NSString *)data toView:(id)toView;
-(void)checkPhone:(NSString*)phone areaCode:(NSString *)areaCode verifyType:(int)verifyType toView:(id)toView;
-(void)resetPwd:(NSString*)telephone areaCode:(NSString *)areaCode randcode:(NSString*)randcode newPwd:(NSString*)newPassword toView:(id)toView;
-(void)updatePwd:(NSString*)telephone areaCode:(NSString *)areaCode oldPwd:(NSString*)oldPassword newPwd:(NSString*)newPassword checkCode:(NSString *)checkCode toView:(id)toView;
-(void)sendSMS:(NSString*)telephone areaCode:(NSString *)areaCode isRegister:(BOOL)isRegister imgCode:(NSString *)imgCode toView:(id)toView;

-(void)checkPhone:(NSString*)phone toView:(id)toView;
-(NSString *)getImgCode:(NSString*)telephone areaCode:(NSString *)areaCode;
-(void)registerUser:(JXUserObject*)user inviteCode:(NSString *)inviteCode workexp:(int)workexp diploma:(int)diploma isSmsRegister:(BOOL)isSmsRegister toView:(id)toView;
// 注册（新）
-(void)registerUser:(NSString *)salt data:(NSString *)data toView:(id)toView;
-(void)updateUser:(JXUserObject*)user toView:(id)toView;
-(void)updateShikuNum:(JXUserObject*)user toView:(id)toView;
-(void)getUser:(NSString*)theUserId toView:()toView;
-(void)searchUser:(JXUserObject*)user minAge:(int)minAge maxAge:(int)maxAge page:(int)page toView:(id)toView;
// 搜索公众号列表
- (void)searchPublicWithKeyWorld:(NSString *)keyWorld limit:(int)limit page:(int)page toView:(id)toView;
-(void)reportUser:(NSString *)toUserId roomId:(NSString *)roomId webUrl:(NSString *)webUrl reasonId:(NSNumber *)reasonId toView:(id)toView;

-(void)addPhoto:(NSString*)photos toView:(id)toView;
-(void)delPhoto:(NSString*)photoId toView:(id)toView;
-(void)updatePhoto:(NSString*)photoId oUrl:(NSString*)oUrl tUrl:(NSString*)tUrl toView:(id)toView;
-(void)listPhoto:(NSString*)theUserId toView:(id)toView;
-(NSString *) getPhotoLocalPath:(NSString*)s;

//-(void)listMessage:(int)type page:(int)page toView:(id)toView;//type：0=所有；1=文字消息；2=图文消息；3=语音消息；4=视频消息；5=分享消息；
-(void)getMessage:(NSString*)messageId toView:(id)toView;
-(void)listMessage:(int)type messageId:(NSString*)messageId toView:(id)toView;
-(void)addMessage:(NSString*)text type:(int)type data:(NSDictionary*)dict flag:(int)flag visible:(int)visible lookArray:(NSArray *)lookArray coor:(CLLocationCoordinate2D)coor location:(NSString *)location remindArray:(NSArray *)remindArray lable:(NSString *)lable isAllowComment:(int)isAllowComment toView:(id)toView;
//-(void)addMessage:(NSString*)text type:(int)type images:(NSString*)images audios:(NSString*)audios vidoes:(NSString*)videos flag:(int)flag toView:(id)toView;
-(void)forwardMessage:(NSString*)text messageId:(NSString*)messageId toView:(id)toView;
-(void)delMessage:(NSString*)messageId toView:(id)toView;
-(void)getNewMessage:(NSString*)messageId toView:(id)toView;
-(void)getUserMessage:(NSString*)userId messageId:(NSString*)messageId toView:(id)toView;
// 朋友圈评论列表
-(void)listComment:(NSString*)messageId pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize commentId:(NSString*)commentId  toView:(id)toView;
// 朋友圈点赞列表
-(void)listPraise:(NSString*)messageId pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize praiseId:(NSString*)praiseId toView:(id)toView;
-(void)listGift:(NSString*)messageId giftId:(NSString*)giftId toView:(id)toView;
-(void)addPraise:(NSString*)messageId toView:(id)toView;
-(void)delPraise:(NSString*)messageId toView:(id)toView;
- (void)addForward:(NSString *)messageId toView:(id)toView;
- (void)addPlayAmount:(NSString *)messageId toView:(id)toView;
-(void)addGift:(NSString*)messageId gifts:(NSString*)gifts toView:(id)toView;
-(void)addComment:(WeiboReplyData*)reply toView:(id)toView;
-(void)delComment:(NSString*)messageId commentId:(NSString*)commentId toView:(id)toView;

-(void)addFriend:(NSString*)toUserId fromAddType:(int)fromAddType toView:(id)toView;
-(void)delFriend:(NSString*)toUserId toView:(id)toView;
-(void)listFriend:(int)page userId:(NSString*)userId toView:(id)toView;
-(void)listFans:(int)page userId:(NSString*)userId toView:(id)toView;
-(void)addAttention:(NSString*)toUserId fromAddType:(int)fromAddType toView:(id)toView;
-(void)delAttention:(NSString*)toUserId toView:(id)toView;
-(void)addBlacklist:(NSString*)toUserId toView:(id)toView;
-(void)delBlacklist:(NSString*)toUserId toView:(id)toView;
-(void)listBlacklist:(int)page toView:(id)toView;
-(void)setFriendName:(NSString*)toUserId noteName:(NSString*)noteName describe:(NSString *)describe toView:(id)toView;
// 修改好友的聊天记录过期时间
-(void)friendsUpdate:(NSString *)toUserId chatRecordTimeOut:(NSString *)chatRecordTimeOut toView:(id)toView;

-(void) uploadFile:(NSArray*)files audio:(NSString*)audio video:(NSString*)video file:(NSString*)file type:(int)type validTime:(NSString *)validTime timeLen:(int)timeLen toView:(id)toView gifDic:(NSDictionary *)gifDic;
// 上传文件（传路径）
-(void)uploadFile:(NSString*)file validTime:(NSString *)validTime messageId:(NSString *)messageId toView:(id)toView;
// 上传音频文件
-(void)UploadVoiceServlet:(NSString*)file validTime:(NSString *)validTime messageId:(NSString *)messageId toView:(id)toView;
// 上传文件（传data）
-(void)uploadFileData:(NSData*)data key:(NSString *)key toView:(id)toView;
-(void)setHeadImage:(NSString*)photoId toView:(id)toView;//弃用
-(void)getImage:(NSString*)url imageView:(UIImageView*)iv;//从URL得到图像
-(NSString*)getHeadImageOUrl:(NSString*)userId;//得到大头像URL
-(NSString*)getHeadImageTUrl:(NSString*)userId;//得到小头像URL
//-(void)getNewVersion:(NSString*)phoneVersion  toView:(id)toView;
-(void)setGroupAvatarServlet:(NSString*)roomId image:(UIImage *)image toView:(id)toView;// 上传群组头像
-(void)getHeadImageLarge:(NSString*)userId userName:(NSString *)userName imageView:(UIImageView*)iv;
-(void)uploadHeadImage:(NSString*)userId image:(UIImage*)image toView:(id)toView;//上传头像
-(void)delHeadImage:(NSString*)userId;//删除头像
// 根据Url获取SDWebimage缓存的图片
- (UIImage *)getSDCacheImage:(NSURL *)url;
- (void)getSign:(NSString *)price payType:(NSInteger)payType toView:(id)toView;//获取支付签名
- (void)getAliPayAuthInfoToView:(id)toView;//获取支付宝授权authInfo
- (void)aliPayUserId:(NSString *)aliUserId toView:(id)toView;//保存支付宝用户Id
- (void)alipayTransfer:(NSString *)amount secret:(NSString *)secret time:(NSNumber *)time toView:(id)toView;//支付宝提现
- (void)codePayment:(NSString *)paymentCode money:(NSString *)money time:(long)time desc:(NSString *)desc secret:(NSString *)secret toView:(id)toView;//二维码支付
//二维码支付(新)
- (void)codePaymentV1:(NSString *)paymentCode money:(NSString *)money desc:(NSString *)desc toView:(id)toView;
- (void)codeReceipt:(NSString *)toUserId money:(NSString *)money time:(long)time desc:(NSString *)desc secret:(NSString *)secret toView:(id)toView;//二维码收款
// 验证付款码qrKey
- (void)payVerifyQrKeyWithSalt:(NSString *)salt mac:(NSString *)mac toView:(id)toView;
- (void)getTransfer:(NSString *)transferId toView:(id)toView;//接受转账
- (void)transferDetail:(NSString *)transferId toView:(id)toView;//获取转账信息
- (void)getConsumeRecordList:(NSString *)toUserId pageIndex:(int)pageIndex pageSize:(int)pageSize toView:(id)toView;//好友交易记录明细
- (void)transferUserId:(NSString *)toUserId money:(NSString *)money remark:(NSString *)remark time:(long)time secret:(NSString *)secret toView:(id)toView;
- (void)nearbyNewUser:(searchData*)search nearOnly:(BOOL)bNearOnly page:(int)page toView:(id)toView;//新用户

-(void)listPays:(id)toView;
-(void)order:(int)goodId count:(int)count type:(int)rechargeType toView:(id)toView;
-(void)listBizs:(id)toView;
-(void)buy:(int)goodId count:(int)count toView:(id)toView;
-(void)getSetting:(id)toView;
-(void)showWebPage:(NSString*)url title:(NSString*)s;
-(void)updateResume:(NSString*)resumeId nodeName:(NSString*)nodeName text:(NSString*)text toView:(id)toView;

-(void)nearbyUser:(searchData*)search nearOnly:(BOOL)nearOnly lat:(double)lat lng:(double)lng page:(int)page toView:(id)toView;
-(void)addRoom:(roomData*)room isPublic:(BOOL)isPublic isNeedVerify:(BOOL)isNeedVerify category:(NSInteger)category toView:(id)toView;
-(void)roomJoin:(NSString*)roomId userId:(NSString*)userId nickName:(NSString*)nickName toView:(id)toView;
-(void)delRoom:(NSString*)roomId toView:(id)toView;
-(void)getRoom:(NSString*)roomId toView:(id)toView;
//-(void)updateRoom:(NSString*)roomId sub:(int)sub talkTime:(NSTimeInterval)talkTime toView:(id)toView;
-(void)updateRoom:(roomData*)room toView:(id)toView;
-(void)updateRoomShowRead:(roomData*)room key:(NSString *)key value:(BOOL)value toView:(id)toView;
- (void)updateRoom:(roomData *)room key:(NSString *)key value:(NSString *)value toView:(id)toView;
-(void)updateRoomDesc:(roomData*)room toView:(id)toView;
-(void)updateRoomMaxUserSize:(roomData*)room toView:(id)toView;
-(void)updateRoomNotify:(roomData*)room toView:(id)toView;
-(void)updateNotice:(NSString*)roomId noticeId:(NSString *)noticeId noticeContent:(NSString *)noticeContent toView:(id)toView;
-(void)listRoom:(int)page roomName:(NSString *)roomName toView:(id)toView;
-(void)listHisRoom:(int)page pageSize:(int)pageSize toView:(id)toView;

-(void)listAttention:(int)page userId:(NSString*)userId toView:(id)toView;

-(void)listRoomMember:(NSString*)roomId page:(int)page toView:(id)toView;
-(void)getRoomMember:(NSString*)roomId userId:(long)userId toView:(id)toView;
-(void)delRoomMember:(NSString*)roomId userId:(long)userId toView:(id)toView;
-(void)setRoomMember:(NSString*)roomId member:(memberData*)member toView:(id)toView;
-(void)addRoomMember:(NSString*)roomId userId:(NSString*)userId nickName:(NSString*)nickName toView:(id)toView;
-(void)addRoomMember:(NSString*)roomId userArray:(NSArray*)array toView:(id)toView;
-(void)setDisableSay:(NSString*)roomId member:(memberData*)member toView:(id)toView;
-(void)setRoomAdmin:(NSString*)roomId userId:(NSString*)userId type:(int)type  toView:(id)toView;
// 指定监控人、隐身人
-(void)setRoomInvisibleGuardian:(NSString*)roomId userId:(NSString*)userId type:(int)type toView:(id)toView;
// 转让群主
- (void)roomTransfer:(NSString *)roomId toUserId:(NSString *)toUserId toView:(id)toView;
// 群成员分页获取
- (void)roomMemberGetMemberListByPageWithRoomId:(NSString *)roomId joinTime:(long)joinTime toView:(id)toView;


/**
 添加共享文件

 @param roomId 房间id
 @param fileUrl 已上传文件的网络地址
 @param size 文件大小kb
 @param type 类型1：图片  2：音频	3：视频   4：ppt	   5：excel	 6：word
 7：zip    8：txt   9：其他
 @param toView 代理控制器
 */
-(void)roomShareAddRoomId:(NSString *)roomId url:(NSString *)fileUrl fileName:(NSString *)fileName size:(NSNumber *)size type:(NSInteger)type toView:(id)toView;
/**
 获取文件列表
 */
-(void)roomShareListRoomId:(NSString *)roomId userId:(NSString *)userId pageSize:(int)pageSize pageIndex:(int)pageIndex toView:(id)toView;
/**
 获取单个文件信息
 */
-(void)roomShareGetRoomId:(NSString *)roomId shareId:(NSString *)shareId toView:(id)toView;
/**
 删除文件
 */
-(void)roomShareDeleteRoomId:(NSString *)roomId shareId:(NSString *)shareId toView:(id)toView;

-(void)saveImageToFile:(UIImage*)image file:(NSString*)file isOriginal:(BOOL)isOriginal;// isOriginal 是否原图
-(void)saveDataToFile:(NSData*)data file:(NSString*)file;
-(NSString*)getMD5String:(NSString*)s;
//-(NSString*)jsonFromObject:(id)obj;

-(double)getLocation:(double)latitude1 longitude:(double)longitude1;
//好友验证
- (void)getFriendSettings:(NSString *)userID toView:(id)toView;
//离线期间调用的接口
- (void)offlineOperation:(double)offlineTime toView:(id)toView;
-(void)changeFriendSetting:(NSString *)friendsVerify allowAtt:(NSString *)allowAtt allowGreet:(NSString*)allowGreet key:(NSString *)key value:(NSString *)value toView:(id)toView;
- (void)readDeleteMsg:(JXMessageObject *)msg toView:(id)toView;//阅后即焚

//红包
-(void)getUserMoenyToView:(id)toView;
- (void)userRecharge:(NSString *)price toView:(id)toView;
- (void)sendRedPacket:(double)money type:(int)type count:(int)count greetings:(NSString *)greet roomJid:(NSString*)roomJid toUserId:(NSString *)toUserId time:(long)time secret:(NSString *)secret toView:(id)toView;
//发红包(新版)
- (void)sendRedPacketV1:(double)money type:(int)type count:(int)count greetings:(NSString *)greet roomJid:(NSString*)roomJid toUserId:(NSString *)toUserId time:(long)time secret:(NSString *)secret toView:(id)toView;
- (void)getRedPacket:(NSString *)redPacketId toView:(id)toView;
- (void)openRedPacket:(NSString *)redPacketId toView:(id)toView;
- (void)getConsumeRecord:(int)pageIndex toView:(id)toView;
// 获得发送的红包
- (void)redPacketGetSendRedPacketListIndex:(NSInteger)index toView:(id)toView;
// 获得接收的红包
- (void)redPacketGetRedReceiveListIndex:(NSInteger)index toView:(id)toView;
// 红包回复
- (void)redPacketReply:(NSString *)redPacketId content:(NSString *)content toView:(id)toView;
//组织
- (void)createCompany:(NSString *)companyName toView:(id)toView;//创建公司
- (void)quitCompany:(NSString *)companyId toView:(id)toView;//退出公司/解散公司
- (void)getCompanyAuto:(id)toView;//自动获取公司
- (void)setManager:(NSString *)userId toView:(id)toView;//指定管理员
- (void)getCompanyManager:(NSString *)companyId toView:(id)toView;//管理员列表
- (void)updataCompanyName:(NSString *)companyName noticeContent:(NSString *)noticeContent companyId:(NSString *)companyId toView:(id)toView;//修改公司名
- (void)changeCompanyNotice:(NSString *)noticeContent companyId:(NSString *)companyId toView:(id)toView;//更换公司公告
- (void)seachCompany:(NSString *)keyworld toView:(id)toView;//查找公司
- (void)deleteCompany:(NSString *)companyId userId:(NSString *)userId toView:(id)toView;//删除公司
- (void)createDepartment:(NSString *)companyId parentId:(NSString *)parentId departName:(NSString *)departName createUserId:(NSString *)createUserId toView:(id)toView;//创建部门
- (void)updataDepartmentName:(NSString *)departmentName departmentId:(NSString *)departmentId toView:(id)toView;//修改部门名
- (void)deleteDepartment:(NSString *)departmentId toView:(id)toView;//删除部门
- (void)addEmployee:(NSArray *)userIdArray companyId:(NSString *)companyId departmentId:(NSString *)departmentId roleArray:(NSArray *)roleArray toView:(id)toView;//添加员工
- (void)deleteEmployee:(NSString *)departmentId userId:(NSString *)userId toView:(id)toView;//删除员工
- (void)modifyDpart:(NSString *)userId companyId:(NSString *)companyId newDepartmentId:(NSString *)newDepartmentId toView:(id)toView;//更改员工部门
- (void)empList:(NSString *)departmentId toView:(id)toView;//部门员工列表
- (void)modifyRole:(NSString *)userId companyId:(NSString *)companyId role:(NSNumber *)role toView:(id)toView;//更改员工角色
- (void)modifyPosition:(NSString *)position companyId:(NSString *)companyId userId:(NSString *)userId toView:(id)toView;//更改员工职位(头衔)
- (void)companyListPage:(NSNumber *)pageIndex toView:(id)toView;//公司列表
- (void)departmentListPage:(NSNumber *)pageIndex companyId:(NSString *)companyId toView:(id)toView;//部门列表
- (void)employeeListPage:(NSNumber *)pageIndex companyId:(NSString *)companyId toView:(id)toView;//员工列表
- (void)getCompanyInfo:(NSString *)companyId toView:(id)toView;//获取公司详情
- (void)getEmployeeInfo:(NSString *)userId toView:(id)toView;//员工详情
- (void)getDepartmentInfo:(NSString *)departmentId toView:(id)toView;//部门详情
- (void)getCompanyCount:(NSString *)companyId toView:(id)toView;//公司员工数
- (void)getDepartmentCount:(NSString *)departmentId toView:(id)toView;//部门员工数

//  获取首页的最近一条的聊天记录列表
- (void)getLastChatListStartTime:(NSNumber *)startTime toView:(id)toView;
// 获取单聊漫游聊天记录
- (void)tigaseMsgsWithReceiver:(NSString *)receiver StartTime:(long)startTime EndTime:(long)endTime PageIndex:(int)pageIndex toView:(id)toView;
// 获取群聊漫游聊天记录
- (void)tigaseMucMsgsWithRoomId:(NSString *)roomId StartTime:(long)startTime EndTime:(long)endTime PageIndex:(int)pageIndex PageSize:(int)pageSize toView:(id)toView;

// 公众号菜单
- (void)getPublicMenuListWithUserId:(NSString *)userId toView:(id)toView;
// 获取所有群助手列表
- (void)getHelperList:(int)pageIndex pageSize:(int)pageSize toView:(id)toView;
// 查询房间群助手接口
- (void)queryGroupHelper:(NSString *)roomId toView:(id)toView;
// 添加群助手接口
- (void)addGroupHelper:(NSString *)roomId roomJid:(NSString *)roomJid helperId:(NSString *)helperId toView:(id)toView;
// 移除群助手接口
- (void)deleteGroupHelper:(NSString *)groupHelperId toView:(id)toView;
// 添加自动回复关键字
- (void)addAutoResponse:(NSString *)roomId helperId:(NSString *)helperId keyword:(NSString *)keyword value:(NSString *)value toView:(id)toView;
// 删除自动回复关键字接口
- (void)deleteAutoResponse:(NSString *)groupHelperId keyWordId:(NSString *)keyWordId toView:(id)toView;
// 删除&撤回聊天记录
- (void)tigaseDeleteMsgWithMessageId:(NSString *)msgId type:(int)type deleteType:(int)deleteType roomJid:(NSString *)roomJid toView:(id)toView;
// 消息免打扰
- (void)friendsUpdateOfflineNoPushMsgUserId:(NSString *)userId toUserId:(NSString *)toUserId offlineNoPushMsg:(int)offlineNoPushMsg type:(int)type toView:(id)toView;

-(void)pkpushSetToken:(NSString *)token deviceId:(NSString *)deviceId isVoip:(int)isVoip toView:(id)toView;
-(void)jPushSetToken:(NSString *)token toView:(id)toView;

//收藏
-(void)addFavoriteWithEmoji:(NSMutableArray *)emoji toView:(id)toView;
//-(void)addFavoriteWithContent:(NSString *)contentStr type:(int)type toView:(id)toView;
// 收藏表情
//- (void)userEmojiAddWithUrl:(NSString *)url toView:(id)toView;
// 取消收藏
- (void)userEmojiDeleteWithId:(NSString *)emojiId toView:(id)toView;
// 朋友圈里面取消收藏
- (void)userWeiboEmojiDeleteWithId:(NSString *)messageId toView:(id)toView;
// 不看他(她)生活圈和视频    toUserId : 对方用户Id    type : 1 屏蔽   -1  取消屏蔽
//shieldType 屏蔽类型 -1  屏蔽某人的生活圈短视频，取消屏蔽某人的生活圈，短视频 1  不让某人看我的生活圈短视频,取消某人不让看我的生活圈短视频
- (void)filterUserCircle:(NSString *)toUserId shieldType:(NSNumber *)shieldType type:(NSNumber *)type toView:(id)toView;
// 收藏列表
-(void)userCollectionListWithType:(int)type pageIndex:(int)pageIndex toView:(id)toView;
//收藏的表情列表
- (void)userEmojiListWithPageIndex:(int)pageIndex toView:(id)toView;

// 添加课程
- (void)userCourseAddWithMessageIds:(NSString *)messageIds CourseName:(NSString *)courseName RoomJid:(NSString *)roomJid toView:(id)toView;
// 查询课程
- (void)userCourseList:(id)toView;
// 修改课程
- (void)userCourseUpdateWithCourseId:(NSString *)courseId MessageIds:(NSString *)messageIds CourseName:(NSString *)courseName CourseMessageId:(NSString *)courseMessageId toView:(id)toView;
// 删除课程
- (void)userCourseDeleteWithCourseId:(NSString *)courseId toView:(id)toView;
// 课程详情
- (void)userCourseGetWithCourseId:(NSString *)courseId toView:(id)toView;

// 更新角标
- (void)userChangeMsgNum:(NSInteger)num toView:(id)toView;
//是否打开网页
- (void)researchSwitch:(NSString *)keyWorld limit:(int)limit page:(int)page toView:(id)toView;

// 设置群消息免打扰
- (void)roomMemberSetOfflineNoPushMsg:(NSString *)roomId userId:(NSString *)userId type:(int)type offlineNoPushMsg:(int)offlineNoPushMsg toView:(id)toView;

// 添加标签
- (void)friendGroupAdd:(NSString *)groupName toView:(id)toView;
// 修改好友标签
- (void)friendGroupUpdateGroupUserList:(NSString *)groupId userIdListStr:(NSString *)userIdListStr toView:(id)toView;
// 更新标签名
- (void)friendGroupUpdate:(NSString *)groupId groupName:(NSString *)groupName toView:(id)toView;
// 删除标签
- (void)friendGroupDelete:(NSString *)groupId toView:(id)toView;
// 标签列表
- (void)friendGroupListToView:(id)toView;
// 修改好友的分组列表
- (void)friendGroupUpdateFriendToUserId:(NSString *)toUserId groupIdStr:(NSString *)groupIdStr toView:(id)toView;

// 删除群组公告
- (void)roomDeleteNotice:(NSString *)roomId noticeId:(NSString *)noticeId ToView:(id)toView;

// 拷贝文件
- (void)uploadCopyFileServlet:(NSString *)paths validTime:(NSString *)validTime toView:(id)toView;
// 群组复制
- (void)copyRoom:(NSString *)roomId toView:(id)toView;
// 清空聊天记录
- (void)emptyMsgWithTouserId:(NSString *)toUserId type:(NSNumber *)type toView:(id)toView;

// 获取通讯录所有号码
- (void)getAddressBookAll:(id)toView;
// 上传通讯录
- (void)uploadAddressBookUploadStr:(NSString *)uploadStr toView:(id)toView;
// 添加手机联系人好友
- (void)friendsAttentionBatchAddToUserIds:(NSString *)toUserIds toView:(id)toView;

// 用户绑定微信code，获取openid
- (void)userBindWXCodeWithCode:(NSString *)code toView:(id)toView;

// 登录后绑定微信号
- (void)userBindWXAccount:(JXUserObject*)user type:(NSInteger)type openId:(NSString *)openId isLogin:(BOOL)isLogin toView:(id)toView;

// 验证登录密码
- (void)userVerifyPassword:(NSString *)password toView:(id)toView;

// 获取群组信息
- (void)roomGetRoom:(NSString *)roomId toView:(id)toView;

/**
 * 余额微信提现
 * amout -- 提现金额，0.3=30，单位为分，最少0.5
 * secret -- 提现秘钥
 * time -- 请求时间，服务器检查，允许5分钟时差
 */
- (void)transferWXPayWithAmount:(NSString *)amount secret:(NSString *)secret time:(NSNumber *)time toView:(id)toView;

// 检查支付密码是否正确
- (void)checkPayPasswordWithUser:(JXUserObject *)user toView:(id)toView;

// 更新支付密码
- (void)updatePayPasswordWithUser:(JXUserObject *)user toView:(id)toView;

// 获取集群音视频服务地址
- (void)userOpenMeetWithToUserId:(NSString *)toUserId toView:(id)toView;

// 朋友圈纯视频接口
- (void)circleMsgPureVideoPageIndex:(NSInteger)pageIndex lable:(NSString *)lable toView:(id)toView;
// 获取音乐列表
- (void)musicListPageIndex:(NSInteger)pageIndex keyword:(NSString *)keyword toView:(id)toView;

// 第三方认证
- (void)openOpenAuthInterfaceWithUserId:(NSString *)userId appId:(NSString *)appId appSecret:(NSString *)appSecret type:(NSInteger)type toView:(id)toView;

// 获取微信登录openid
- (void)getWxOpenId:(NSString *)code toView:(id)toView;

- (void)wxSdkLogin:(JXUserObject *)user type:(NSInteger)type openId:(NSString *)openId toView:(id)toView;
// 微信登录（新）
- (void)wxSdkLoginV1:(NSString *)salt data:(NSString *)data toView:(id)toView;
// 第三方绑定手机号
-(void)thirdLogin:(JXUserObject*)user type:(NSInteger)type openId:(NSString *)openId isLogin:(BOOL)isLogin toView:(id)toView;
// 第三方绑定手机号(新)
-(void)thirdLoginV1:(NSString*)userId salt:(NSString *)salt data:(NSString *)data toView:(id)toView;

// 第三方网页授权
- (void)openCodeAuthorCheckAppId:(NSString *)appId state:(NSString *)state callbackUrl:(NSString *)callbackUrl toView:(id)toView;
// 检查网址是否被锁定
- (void)userCheckReportUrl:(NSString *)webUrl toView:(id)toView;
// 第三方解绑   type  第三方登录类型  1: QQ  2: 微信
- (void)setAccountUnbind:(int)type toView:(id)toView;
// 获取用户绑定信息接口
- (void)getBindInfo:(id)toView;

// 面对面建群
//面对面建群查询
- (void)roomLocationQueryWithIsQuery:(int)isQuery password:(NSString *)password toView:(id)toView;
//面对面建群加入
- (void)roomLocationJoinWithJid:(NSString *)jid toView:(id)toView;
//面对面建群退出
- (void)roomLocationExitWithJid:(NSString *)jid toView:(id)toView;

// 视酷支付
// 接口获取订单信息
- (void)payGetOrderInfoWithAppId:(NSString *)appId prepayId:(NSString *)prepayId toView:(id)toView;
// 输入密码后支付接口
- (void)payPasswordPaymentWithAppId:(NSString *)appId prepayId:(NSString *)prepayId sign:(NSString *)sign time:(NSString *)time secret:(NSString *)secret toView:(id)toView;

// weba扫描二维码登录
- (void)userQrCodeLoginWithQRCodeKey:(NSString *)qrCodeKey type:(NSString *)type toView:(id)toView;

// 根据通讯号获取用户资料
- (void)userGetByAccountWithAccount:(NSString *)account toView:(id)toView;

// 支付加密
// 获取加密私钥
- (void)authkeysGetPayPrivateKey:(id)toView;
// 上传RSA公私钥
- (void)authkeysUploadPayKeyWithPrivateKey:(NSString *)privateKey publicKey:(NSString *)publicKey mac:(NSString *)mac toView:(id)toView;
// 获取加固临时密码
- (void)transactionGetCodeWithSalt:(NSString *)salt mac:(NSString *)mac toView:(id)toView;
// 支付通用接口
- (void)payCommonWithAction:(NSString *)action code:(NSString *)code codeId:(NSString *)codeId param:(NSMutableArray *)arr time:(long)time payPassword:(NSString *)payPassword data:(NSString *)data toView:(id)toView;
// 重置支付密码
- (void)authkeysResetPayPasswordWithSalt:(NSString *)salt mac:(NSString *)mac toView:(id)toView;

// 登录加密
// 获取登录加密私钥
- (void)authkeysGetLoginPrivateKeyWithUserId:(NSString *)userId salt:(NSString *)salt mac:(NSString *)mac toView:(id)toView;
// 登录上传公私钥
- (void)authkeysUploadLoginKeyWithUserId:(NSString *)userId salt:(NSString *)salt privateKey:(NSString *)privateKey publicKey:(NSString *)publicKey mac:(NSString *)mac toView:(id)toView;
// 登录获取临时加固密码
- (void)authGetLoginCodeWithAreaCode:(NSString *)areaCode account:(NSString *)account salt:(NSString *)salt deviceId:(NSString *)deviceId mac:(NSString *)mac toView:(id)toView;

// 消息加密
// 获取好友DH公钥表
- (void)authkeysGetDHMsgKeyListWithUserId:(NSString *)userId toView:(id)toView;
//获取校验码，修改登录密码验签用
- (void)userGetRandomStr:(id)toView;
//用户开户
- (void)openAccount:(NSString *)name certificateNo:(NSString *)certificateNo mobile:(NSString *)mobile areaCode:(NSString *)areaCode smsCode:(NSString *)smsCode toView:(id)toView;
//查询钱包账户信息
- (void)queryAccountInfo:(id)toView;
//充值
- (void)rechargeAmount:(NSString *)amount toView:(id)toView;
//查询绑定银行卡
- (void)queryCard:(id)toView;
//安全设置（用于用户修改或重新设置钱包支付密码）
- (void)managePassword:(id)toView;
// 充值结果查询
- (void)queryRechargeTradeNo:(NSString *)tradeNo toView:(id)toView;
// 充值结果查询
- (void)yopPaySendRedPacketUserId:(NSString *)userId moneyStr:(NSString *)moneyStr type:(int)type count:(NSString *)count greetings:(NSString *)greetings roomJid:(NSString *)roomJid toUserId:(NSString *)toUserId toView:(id)toView;
// 红包支付结果查询（如果回调不成功时,可调用）
- (void)queryRedPacketPayment:(NSString *)redPacketId toView:(id)toView;
// 打开红包
- (void)yopPayOpenRedPacket:(NSString *)redPacketId toView:(id)toView;
// 转账
- (void)yopPayTransferToUserId:(NSString *)toUserId remark:(NSString *)remark amount:(NSString *)amount toView:(id)toView;
// 转账支付结果查询（如果回调不成功时,可调用）
- (void)yopPayQueryTransfer:(NSString *)transferId toView:(id)toView;
// 接收转账
- (void)yopPayReceiveTransfer:(NSString *)transferId toView:(id)toView;
// 接收转账(提现类型0：实时到账（如果不传默认走实时到账） 1：2小时到账 2：次日)
- (void)yopPayWithdraw:(NSString *)amount withdrawType:(int)withdrawType toView:(id)toView;
// 提现查询
- (void)yopPayQueryWithdraw:(NSString *)tradeNo toView:(id)toView;
// 获取银行卡账单列表
- (void)getYopWalletBill:(int)pageIndex toView:(id)toView;
// 修改针对好友的加密方式
- (void)friendsModifyEncryptType:(NSNumber *)encryptType toUserId:(NSString *)toUserId toView:(id)toView;
// 修改针对群组的加密方式
- (void)roomUpdateEncryptType:(NSNumber *)encryptType roomId:(NSString *)roomId toView:(id)toView;
// 获取所有群成员rsa公钥
- (void)roomGetAllMemberRsaPublicKeyWithRoomId:(NSString *)roomId toView:(id)toView;
// 获取单个群成员RSA公钥
- (void)roomGetMemberRsaPublicKeyWithRoomId:(NSString *)roomId userId:(NSString *)userId toView:(id)toView;
// 重置群组通信密钥
- (void)roomResetGroupChatKeyWithRoomId:(NSString *)roomId keys:(NSString *)keys toView:(id)toView;
// 修改自己群组通信秘钥
- (void)roomUpdateGroupChatKeyWithRoomId:(NSString *)roomId key:(NSString *)key toView:(id)toView;

- (void)getDiscoverWebList:(NSString *)secret toView:(id)toView;

// 扫码充值提现
// 获取转账人信息
- (void)manualPayGetReceiveAccountWithType:(NSString *)type toView:(id)toView;
// 提交充值申请
- (void)manualPayRechargeWithType:(NSString *)type money:(NSString *)money toView:(id)toView;
// 添加提现账户
- (void)manualPayAddWithdrawAccountWithType:(NSString *)type aliPayName:(NSString *)aliPayName aliPayAccount:(NSString *)aliPayAccount cardName:(NSString *)cardName bankCardNo:(NSString *)bankCardNo bankName:(NSString *)bankName bankBranchName:(NSString *)bankBranchName desc:(NSString *)desc toView:(id)toView;
// 获取提现账户列表
- (void)manualPayGetWithdrawAccountListWithPageIndex:(NSInteger)pageIndex toView:(id)toView;
// 删除提现账户
- (void)manualPayDeleteWithdrawAccountWithId:(NSString *)accountId toView:(id)toView;
// 修改提现账户
- (void)manualPayUpdateWithdrawAccountWithId:(NSString *)accountId aliPayName:(NSString *)aliPayName aliPayAccount:(NSString *)aliPayAccount cardName:(NSString *)cardName bankCardNo:(NSString *)bankCardNo bankName:(NSString *)bankName bankBranchName:(NSString *)bankBranchName desc:(NSString *)desc toView:(id)toView;
// 提交提现申请
- (void)manualPayWithdrawWithMoney:(NSString *)money withdrawAccountId:(NSString *)withdrawAccountId toView:(id)toView;
// 银行卡功能发送短信
- (void)yopPaySendSms:(NSString *)telephone areaCode:(NSString *)areaCode imgCode:(NSString *)imgCode toView:(id)toView;

// 按月查询消费记录
- (void)queryConsumeRecordCountWithStartTime:(NSString *)startTime endTime:(NSString *)endTime needCount:(BOOL)needCount isNext:(BOOL)isNext pageSize:(int)pageSize toView:(id)toView;


@property(nonatomic) long user_id;
@property(nonatomic) long user_type;
@property(nonatomic) long count_money;
@property(nonatomic,strong) NSString* access_token;
@property(nonatomic,strong) NSString* loginToken;
@property(nonatomic,strong) NSString* loginKey;
@property(nonatomic,strong) NSString* httpKey;
@property(nonatomic,strong) NSString* messageKey;
@property(nonatomic,strong) NSString* payKey;

@property(nonatomic,strong) JXUserObject* myself;
@property (nonatomic, strong) JXMultipleLogin *multipleLogin;
@property(assign) double latitude;
@property(assign) double longitude;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString * countryCode;
@property (nonatomic,strong) NSString * cityName;
@property (nonatomic,assign) int cityId;

@property(nonatomic,strong) NSString * locationAddress;
@property(nonatomic,strong) NSString* locationCity;

@property (nonatomic, strong) JXAddressBook *addressBook;
@property (nonatomic, strong) JXLocation *location;

@property(assign) BOOL isLoginWeibo;
@property(assign) BOOL isLogin;
@property(assign) BOOL isManualLogin;       // 是否是手动登录
@property(assign) NSTimeInterval lastOfflineTime;

@property(nonatomic,strong) NSString* openId;
@property (nonatomic, assign) NSInteger thirdType;

@property (nonatomic,copy) NSString *temporaryPWD;  // 临时的明文密码

// 服务器当前时间
@property (nonatomic,assign)  NSTimeInterval serverCurrentTime;
// 服务器时间与本地时间的时间差
@property (nonatomic,assign)  NSTimeInterval timeDifference;

@property (nonatomic, strong) NSMutableDictionary *saltDic;

//获取头像后的回调
typedef void(^JXHeadGetImage)(BOOL isRoom,UIImage *image, NSError *error);
@property (nonatomic, copy) JXHeadGetImage getHeadHandler;

-(void)getHeadImageSmall:(NSString*)userId userName:(NSString *)userName imageView:(UIImageView*)iv getHeadHandler:(JXHeadGetImage)getHeadHandler;//得到小头像
-(void)getHeadImageLarge:(NSString*)userId userName:(NSString *)userName imageView:(UIImageView*)iv getHeadHandler:(JXHeadGetImage)getHeadHandler;//得到大头像
-(void)getRoomHeadImageSmall:(NSString*)userId roomId:(NSString *)roomId imageView:(UIImageView*)iv getHeadHandler:(JXHeadGetImage)getHeadHandler;
-(UIImage *)roomHeadImage:(NSString *)userId roomId:(NSString *)roomId getHeadHandler:(JXHeadGetImage)getHeadHandler;

@end

@protocol JXServerResult <NSObject>
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1;
-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict;
-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error;//error为空时，代表超时
-(void) didServerConnectStart:(JXConnection*)aDownload;
@end
