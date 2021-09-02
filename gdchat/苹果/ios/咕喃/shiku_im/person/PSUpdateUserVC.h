//
//  PSUpdateUserVC.h
//  shiku_im
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "admobViewController.h"

@interface PSUpdateUserVC : admobViewController{
    UITextField* _pwd;
    UITextField* _repeat;
    UITextField* _name;
    UILabel* _workexp;
    UILabel* _city;
    UILabel* _dip;
    UISegmentedControl* _sex;
    UITextField* _birthday;
    JXDatePicker* _date;
    
    UIImage* _image;
    JXImageView* _head;
    UILabel *_inviteCode;
}

@property (nonatomic,strong) JXUserObject* user;
@property (nonatomic,assign) BOOL isRegister;
@property (nonatomic, strong) UIImage *headImage;

@end
