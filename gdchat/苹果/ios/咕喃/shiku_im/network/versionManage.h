//
//  newVersion.h
//  sjvodios
//
//  Created by  on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface versionManage : NSObject{
    NSMutableDictionary* _msg;
}

@property(strong,nonatomic) NSString* ftpHost;//FTP主机
@property(strong,nonatomic) NSString* ftpUsername;//FTP用户名
@property(strong,nonatomic) NSString* ftpPassword;//FTP密码

@property(strong,nonatomic) NSString* aboutUrl;//关于界面Url
@property(strong,nonatomic) NSString* buyUrl;//促销Url
@property(strong,nonatomic) NSString* helpUrl;//使用帮助
@property(strong,nonatomic) NSString* softUrl;//新版本的下载Url，分苹果安卓
@property(strong,nonatomic) NSString* shareUrl;//分享后，访问的Url

@property(strong,nonatomic) NSString* website;//官方网址
@property(strong,nonatomic) NSString* backUrl;//后台api入口
@property(strong,nonatomic) NSString* apiUrl;//java api入口
@property(strong,nonatomic) NSString* uploadUrl;//上传文件的前缀
@property(strong,nonatomic) NSString* downloadUrl;//下载文件的前缀
@property(strong,nonatomic) NSString* downloadAvatarUrl;//下载头像的前缀

@property(strong,nonatomic) NSString* researchSwitch;//djk开关字段

@property(strong,nonatomic) NSString* XMPPDomain;//tigase的域名
@property(strong,nonatomic) NSString* XMPPHost;//tigase的域名
@property(assign,nonatomic) int XMPPTimeout;    //xmpp超时时间
@property(assign,nonatomic) int XMPPPingTime;    //xmpp ping时间间隔
@property(strong,nonatomic) NSString* isOpenSMSCode;//是否打开短信验证码
@property(strong,nonatomic) NSString *isOpenReceipt;// 是否开启发送回执
@property(strong,nonatomic) NSString *isOpenCluster;// 是否开启集群

@property(strong,nonatomic) NSString* meetingHost;//视频会议的主机
@property(strong,nonatomic) NSString *jitsiServer;//jitsi音视频

@property (nonatomic, strong) NSString *fileValidTime;

@property(strong,nonatomic) NSString* version;//目前版本
@property(nonatomic, strong) NSString *iosAppUrl; // 新版下载地址
@property(strong,nonatomic) NSString* theNewVersion;//最新版本
@property(strong,nonatomic) NSString* versionRemark;//新版本说明
@property(strong,nonatomic) NSString* disableVersion;//禁用版本列表
@property(strong,nonatomic) NSString* message;//通知
@property(strong,nonatomic) NSString* iosDisable;// 禁用以下版本号
@property(strong,nonatomic) NSString* appleId;// appleId 用于跳转App Store
@property (nonatomic, strong) NSNumber *hideSearchByFriends; // 是否隐藏好友搜索功能 0:隐藏 1：开启
@property(strong,nonatomic) NSString* companyName;// 公司名称
@property(strong,nonatomic) NSString* copyright;// appleId 版权信息
@property (nonatomic, strong) NSNumber *regeditPhoneOrName; // 0：使用手机号注册，1：使用用户名注册
@property (nonatomic, strong) NSNumber *registerInviteCode; //  注册邀请码   0：关闭,1:开启一对一邀请（一码一用，且必填），2:开启一对多邀请（一码多用，选填项）
@property (nonatomic, strong) NSNumber *nicknameSearchUser; //昵称搜索用户  0:关闭 1:精确搜索 2:模糊搜索   默认模糊搜索
@property (nonatomic, strong) NSNumber *videoLength;

@property (nonatomic, strong) NSNumber *isCommonFindFriends; // 普通用户是否能搜索好友 0:允许 1：不允许
@property (nonatomic, strong) NSNumber *isCommonCreateGroup; // 普通用户是否能建群 0:允许 1：不允许
@property (nonatomic, strong) NSNumber *isOpenPositionService; // 是否开启位置相关服务 0：开启 1：关闭
@property (nonatomic, strong) NSNumber *isOpenAPNSorJPUSH;// IOS推送平台 0：APNS  1：极光推送
@property (nonatomic, strong) NSNumber *isOpenRoomSearch;// 是否开启群组搜索 0：开启 1：关闭

@property (nonatomic, strong) NSNumber *isOpenOnlineStatus  ;// 是否开启显示在线状态 0：不显示  1：显示

@property (nonatomic, strong) NSString *headBackgroundImg;// (发现界面)头部导航背景图
@property (nonatomic, strong) NSString *privacyPolicyPrefix; // 隐私设置url 前缀


@property (nonatomic, strong) NSDictionary *popularAPP;  // 热门应用控制
@property (nonatomic, assign) BOOL isChina; // 判断当前是否在中国大陆  YES:中国大陆  NO:其他地区或国家

@property (nonatomic, strong) NSNumber *enableMpModule;  //启用公众号模块 1 启用 0 关闭
@property (nonatomic, strong) NSNumber *showContactsUser;   // 是否上传通讯录，1：上传 0：不上传

@property (nonatomic, strong) NSNumber *enablePayModule; // YES:开启支付模块 NO:隐藏支付模块

@property (nonatomic, strong) NSNumber *isOpenSecureChat;   // 是否开启端到端加密

@property (nonatomic, strong) NSNumber *isOpenManualPay;   // 是否开启扫码手动充值提现

@property (nonatomic, strong) NSNumber *isOpenCloudWallet; //是否开启云钱包 1:开启 0:关闭

@property (nonatomic, strong) NSNumber *isOpenAliPay; // 是否启用支付宝支付

@property (nonatomic, strong) NSNumber *isOpenWxPay; // 是否启用微信支付

@property (nonatomic, strong) NSNumber *maxRedpackAmount; //红包最大金额

@property (nonatomic, strong) NSNumber *maxRedpacktNumber;  //红包最大发送个数

@property (nonatomic, strong) NSNumber *isOpenAuthSwitch;// 是否开启旧设备登录授权 0：关闭 1：开启

@property(nonatomic)int videoMaxLen;//录像最大时长
@property(nonatomic)int audioMaxLen;//录音最大时长
@property(nonatomic)int money_login;//登录送多少
@property(nonatomic)int money_share;//分享送多少
@property(nonatomic)int money_intro;//推荐送多少
@property(nonatomic)int money_videoMeeting;//视频会议扣多少
@property(nonatomic)int money_audioMeeting;//音频会议扣多少
@property(nonatomic)BOOL isCanChange;//礼物能兑换
@property(strong,nonatomic) NSString* appUrlNew;//新版本AppStoreUrl
@property(nonatomic,copy) void (^block)(void);
-(void)getDefaultValue;
-(void)didReceive:(NSDictionary*)dict;
-(void)showDisableUse;

@end
