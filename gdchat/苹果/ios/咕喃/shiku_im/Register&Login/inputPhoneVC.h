//
//  inputPhoneVC.h
//  shiku_im
//
//  Created by flyeagleTang on 14-6-7.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "admobViewController.h"

@interface inputPhoneVC : admobViewController{
    UITextField* _area;
    UITextField* _phone;
    UITextField* _code;
    UITextField* _pwd;
    UITextField* _inviteCode;
    UIButton* _send;
    NSString* _smsCode;
    NSString* _imgCodeStr;
    NSString* _phoneStr;
    int _seconds;
}

@property (nonatomic, assign) BOOL isThirdLogin;
@property (nonatomic, assign) int type;


@end
