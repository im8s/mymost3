//
//  selectCountryVC.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXTableViewController.h"
#import <UIKit/UIKit.h>
@class menuImageView;

@interface selectCountryVC: JXTableViewController{
    NSMutableDictionary* _array;
    int _refreshCount;
}
@property(nonatomic,assign) BOOL showProvince;
@property(nonatomic,assign) BOOL showArea;
@property(nonatomic,assign) int selected;
@property(nonatomic,strong) NSString* selValue;
@property(nonatomic,weak) id delegate;
@property(nonatomic,assign) SEL didSelect;
@property(nonatomic,assign) int provinceId;
@property(nonatomic,assign) int cityId;
@property(nonatomic,assign) int areaId;

@end
