//
//  JXLoginServer.h
//  shiku_im
//
//  Created by p on 2019/7/23.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXLoginServer : NSObject

+ (instancetype)sharedManager;

// 登录接口方法
- (void)loginWithUser:(JXUserObject *)user password:(NSString *)password areaCode:(NSString *)areaCode account:(NSString *)account toView:(id)toView;

// 自动登录
- (void)autoLoginWithToView:(id)toView;

// 短信登录接口
- (void)smsLoginWithUser:(JXUserObject *)user areaCode:(NSString *)areaCode account:(NSString *)account toView:(id)toView;
// 第三方绑定手机号
-(void)thirdLoginV1:(JXUserObject*)user password:(NSString *)password type:(NSInteger)type openId:(NSString *)openId isLogin:(BOOL)isLogin toView:(id)toView;
// 微信登录
- (void)wxSdkLoginV1:(JXUserObject *)user type:(NSInteger)type openId:(NSString *)openId toView:(id)toView;
// 注册
-(void)registerUserV1:(JXUserObject*)user type:(int)type inviteCode:(NSString *)inviteCode workexp:(int)workexp diploma:(int)diploma isSmsRegister:(BOOL)isSmsRegister smsCode:(NSString *)smsCode password:(NSString *)password toView:(id)toView;

// 获取修改密码和忘记密码验签
- (NSString *)getUpdatePWDMacWithValue:(NSString *)value password:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
