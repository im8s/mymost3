//
//  JXRecordCodeVC.h
//  shiku_im
//
//  Created by Apple on 16/9/18.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXTableViewController.h"

@interface JXRecordCodeVC : JXTableViewController
@property (strong, nonatomic) NSMutableArray * dataArr;//数据源
@property (nonatomic,strong) NSMutableArray * dataObjArray;//消息记录对象数组

@property (nonatomic, assign) BOOL isCloud;


@end
