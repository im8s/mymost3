//
//  JXAnnounceViewController.h
//  shiku_im
//
//  Created by 1 on 2018/8/17.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXTableViewController.h"


@class searchData;

@interface JXAnnounceViewController : JXTableViewController

@property(nonatomic,weak) id delegate;
@property(nonatomic,strong) NSString* value;
@property(assign) SEL didSelect;
@property (nonatomic, assign) BOOL isLimit;
@property (nonatomic, assign) NSInteger limitLen;
@property (nonatomic, strong) UITextView *name;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL isAdmin;
@property (nonatomic,strong) roomData *room;

@end
