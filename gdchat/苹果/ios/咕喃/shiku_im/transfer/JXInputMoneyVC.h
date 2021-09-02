//
//  JXInputMoneyVC.h
//  shiku_im
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "admobViewController.h"

typedef NS_ENUM(NSInteger, JXInputMoneyType) {
    JXInputMoneyTypeSetMoney,        // 设置金额
    JXInputMoneyTypeCollection,      // 收款
    JXInputMoneyTypePayment,         // 付款
};

@interface JXInputMoneyVC : admobViewController

@property (nonatomic, assign) JXInputMoneyType type;

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *money;
@property (nonatomic, strong) NSString *desStr;
// 二维码付款用string
@property (nonatomic, strong) NSString *paymentCode;

@property (weak, nonatomic) id delegate;
@property (nonatomic, assign) SEL onInputMoney;



@end

