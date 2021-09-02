//
//  PSRegisterBaseVC.h
//  shiku_im
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "admobViewController.h"

@interface PSRegisterBaseVC : admobViewController{
    UITextField* _pwd;
    UITextField* _repeat;
    UITextField* _name;
    UILabel* _workexp;
    UILabel* _city;
    UILabel* _dip;
    UISegmentedControl* _sex;
    UITextField* _birthday;
//    UITextField *_inviteCode;   //邀请码
    JXDatePicker* _date;
    
    UIImage* _image;
    JXImageView* _head;
}

@property (nonatomic,strong) NSString* resumeId;
@property (nonatomic,strong) NSString* password;
@property (nonatomic,assign) BOOL isRegister;
@property (nonatomic,strong) resumeBaseData* resume;
@property (nonatomic,strong) JXUserObject* user;
@property (nonatomic,assign) BOOL isSmsRegister;

@property (nonatomic,copy) NSString *inviteCodeStr; // 邀请码
@property (nonatomic,copy) NSString *smsCode; // 短信验证码

@property (nonatomic, assign) int type;

@end
