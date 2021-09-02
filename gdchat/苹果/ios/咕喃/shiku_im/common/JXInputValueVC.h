//
//  JXInputValueVC.h
//  shiku_im
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "admobViewController.h"
@class searchData;

@interface JXInputValueVC : admobViewController{
    UITextView* _name;
}

@property(nonatomic,weak) id delegate;
@property(nonatomic,strong) NSString* value;
@property(assign) SEL didSelect;
@property (nonatomic, assign) BOOL isLimit;
@property (nonatomic, assign) NSInteger limitLen;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) BOOL isRoomNum;

@end
