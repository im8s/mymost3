//
//  JXRechargeViewController.h
//  shiku_im
//
//  Created by 1 on 17/10/30.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXTableViewController.h"

@protocol RechargeDelegate <NSObject>

-(void)rechargeSuccessed;

@end

@interface JXRechargeViewController : admobViewController

@property (nonatomic, weak) id<RechargeDelegate> rechargeDelegate;

@property (nonatomic,assign) BOOL isQuitAfterSuccess;
@property (nonatomic, assign) BOOL isCloud;

// 是否是扫码充值
@property (nonatomic, assign) BOOL isScanRecharge;

@end
