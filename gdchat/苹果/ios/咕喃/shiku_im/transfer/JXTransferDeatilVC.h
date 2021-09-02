//
//  JXTransferDeatilVC.h
//  shiku_im
//
//  Created by 1 on 2019/3/2.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "admobViewController.h"



@interface JXTransferDeatilVC : admobViewController

@property (nonatomic, strong) JXUserObject *user;
@property (nonatomic, strong) JXMessageObject *msg;

@property (assign) SEL onResend; // 重发消息
@property (weak, nonatomic) id delegate;


@end

