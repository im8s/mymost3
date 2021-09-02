//
//  loginVC.h
//  shiku_im
//
//  Created by flyeagleTang on 14-6-7.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "admobViewController.h"


typedef NS_ENUM(NSInteger, JXLoginType) {
    JXLoginQQ = 1,          // QQ登录
    JXLoginWX,               // 微信登录
};

@interface loginVC : admobViewController{
    UITextField* _pwd;
    UITextField* _phone;
    JXUserObject* _user;
}
@property(assign)BOOL isAutoLogin;
@property(assign)BOOL isSwitchUser;
@property (nonatomic, strong) UIImageView *launchImageView;
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) JXLocation *location;

@property (nonatomic, assign) BOOL isThirdLogin;
@property (nonatomic, assign) BOOL isSMSLogin;

@property (nonatomic, assign) JXLoginType type;

@end
