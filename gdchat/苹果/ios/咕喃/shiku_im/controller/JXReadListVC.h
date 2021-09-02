//
//  JXReadListVC.h
//  shiku_im
//
//  Created by p on 2017/9/2.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXTableViewController.h"

@class roomData;

@interface JXReadListVC : JXTableViewController

@property (nonatomic, strong) JXMessageObject *msg;
@property (nonatomic, strong) roomData *room;

@end
