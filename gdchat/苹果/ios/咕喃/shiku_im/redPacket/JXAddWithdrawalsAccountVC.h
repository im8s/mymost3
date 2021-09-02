//
//  JXAddWithdrawalsAccountVC.h
//  shiku_im
//
//  Created by p on 2019/12/10.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "admobViewController.h"

typedef enum : NSUInteger {
    AddType_Ali = 0,    // 支付宝
    AddType_Card,   // 银行卡
} AddType;

@protocol JXAddWithdrawalsAccountVCDelegate <NSObject>

- (void)addWithdrawalsAccountBindSuccess;

@end

NS_ASSUME_NONNULL_BEGIN

@interface JXAddWithdrawalsAccountVC : admobViewController

@property (nonatomic, assign) AddType addType;  // 添加方式
@property (nonatomic, weak) id<JXAddWithdrawalsAccountVCDelegate> delegate;
@property (nonatomic, strong) NSDictionary *data;

@end

NS_ASSUME_NONNULL_END
