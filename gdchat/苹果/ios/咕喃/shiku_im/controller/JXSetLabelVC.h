//
//  JXSetLabelVC.h
//  shiku_im
//
//  Created by p on 2018/6/26.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "admobViewController.h"

@interface JXSetLabelVC : admobViewController
@property (nonatomic, strong) JXUserObject *user;

@property (nonatomic, strong) NSMutableArray *array;    // 已选择标签
@property (nonatomic, strong) NSMutableArray *allArray; // 所有标签

@property(nonatomic,weak) id delegate;
@property(assign) SEL didSelect;

@end
