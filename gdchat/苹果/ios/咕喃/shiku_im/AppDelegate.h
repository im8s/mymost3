//#define SERVER_URL @"http://pull99.a8.com/live/1484986711488827.flv?ikHost=ws&ikOp=1&CodecInfo=8192"


//
//  AppDelegate.h
//
//  Created by Reese on 13-8-10.
//  Copyright (c) 2013年 Reese. All rights reserved.
#import <UIKit/UIKit.h>
#import <PushKit/PushKit.h>
#import <CallKit/CallKit.h>
#import "JXNavigation.h"
#import "JXDidPushObj.h"
// 引入 JPush 功能所需头文件
#import "JPUSHService.h"

@class emojiViewController;
@class JXMainViewController;
@class JXGroupViewController;
@class leftViewController;
@class JXServer;
@class versionManage;
@class JXConstant;
@class JXUserObject;
@class JXMeetingObject;
@class JXCommonService;
@class NumLockViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,PKPushRegistryDelegate,CXProviderDelegate,JPUSHRegisterDelegate>{
}

@property (strong, nonatomic) UIWindow *window;

// 可用于view显示在最上层,不受底下页面干扰
@property (strong, nonatomic) UIView *subWindow;

@property (nonatomic, strong) NumLockViewController *numLockVC;
//QQ登录appId
@property (nonatomic, strong) NSString *QQ_LOGIN_APPID;


#if TAR_IM
#ifdef Meeting_Version
@property (nonatomic,strong)  JXMeetingObject* jxMeeting;
@property (nonatomic, strong) CXProvider * provider;
@property (nonatomic, strong) CXCallController * cxCallController;
@property (nonatomic, readonly) CXProviderConfiguration * providerConfig;
@property (nonatomic, strong) NSUUID * uuid;
#endif
#endif

@property (nonatomic,strong)  JXServer* jxServer;
@property (nonatomic,strong)  JXConstant* jxConstant;
@property (nonatomic, strong) versionManage* config;
@property (strong, nonatomic) emojiViewController* faceView;
@property (strong, nonatomic) JXMainViewController *mainVc;

@property (strong, nonatomic) NSString * isShowRedPacket;
@property (assign, nonatomic) double myMoney;
@property (assign, nonatomic) double myCloudMoney;

@property (nonatomic, strong) JXCommonService *commonService;

@property (nonatomic, strong) JXNavigation *navigation;
@property (nonatomic, assign) BOOL isShowDeviceLock;

@property (nonatomic, strong) JXDidPushObj *didPushObj;

@property (nonatomic, strong) JXSecurityUtil *securityUtil;
@property (nonatomic, strong) JXPayServer *payServer;
@property (nonatomic, strong) JXLoginServer *loginServer;
#ifdef IS_MsgEncrypt
@property (nonatomic, strong) JXMsgUtil *msgUtil;
#endif

-(void) showAlert: (NSString *) message;
- (void)showAlert:(NSString *)title message:(NSString *)message;
-(UIAlertView *) showAlert: (NSString *) message delegate:(id)delegate;
- (UIAlertView *) showAlert: (NSString *) message delegate:(id)delegate tag:(NSUInteger)tag onlyConfirm:(BOOL)onlyConfirm;

- (void)copyDbWithUserId:(NSString *)userId;

-(void)showMainUI;
-(void)showLoginUI;

-(void)endCall;

@end
