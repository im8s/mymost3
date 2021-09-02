//
//  JXVerifyDetailVC.h
//  shiku_im
//
//  Created by p on 2018/5/29.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "admobViewController.h"
#import "JXChatViewController.h"


@interface JXVerifyDetailVC : admobViewController
@property (nonatomic, strong) JXMessageObject *msg;
@property (nonatomic,strong) roomData * room;
@property (nonatomic, weak) JXChatViewController *chatVC;

@end
