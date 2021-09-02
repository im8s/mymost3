//
//  JXSearchUserVC.h
//  shiku_im
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "admobViewController.h"
@class searchData;


typedef NS_ENUM(NSInteger, JXSearchType) {
    JXSearchTypeUser,           // 好友
    JXSearchTypePublicNumber,   // 公众号
};


@interface JXSearchUserVC : admobViewController{
    UITextField* _name;
    UITextField* _minAge;
    UITextField* _maxAge;
    UILabel* _date;
    UILabel* _sex;
    UILabel* _industry;
    UILabel* _function;
    
    UIImage* _image;
    JXImageView* _head;
    
    NSMutableArray* _values;
    NSMutableArray* _numbers;
}

@property (nonatomic, assign) JXSearchType type;
@property (nonatomic,strong) searchData* job;
@property(nonatomic,weak) id delegate;
@property(assign) SEL didSelect;


@end
