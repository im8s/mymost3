//
//  JXSearchChatLogVC.h
//  shiku_im
//
//  Created by p on 2018/6/25.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXTableViewController.h"

@interface JXSearchChatLogVC : JXTableViewController

@property (nonatomic, strong) JXUserObject *user;
@property (nonatomic, assign) BOOL isGroup;

@end
