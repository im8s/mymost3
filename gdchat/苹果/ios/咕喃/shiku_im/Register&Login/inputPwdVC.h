//
//  inputPwdVC.h
//  shiku_im
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "admobViewController.h"

@interface inputPwdVC : admobViewController{
    UITextField* _pwd;
    UITextField* _repeat;
}
@property (nonatomic,strong) NSString *area;
@property (nonatomic,strong) NSString* telephone;
@property (nonatomic,assign) BOOL isCompany;

@end
