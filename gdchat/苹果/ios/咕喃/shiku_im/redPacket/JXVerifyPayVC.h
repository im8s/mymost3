//
//  JXVerifyPayVC.h
//  shiku_im
//
//  Created by 1 on 2018/9/18.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "admobViewController.h"

typedef NS_OPTIONS(NSInteger, JXVerifyType) {
    JXVerifyTypeWithdrawal,         // 提现验证
    JXVerifyTypeSendReadPacket,     // 发红包验证
    JXVerifyTypeTransfer,           // 转账
    JXVerifyTypeQr,                 // 扫码支付
    JXVerifyTypeSkPay,              // 视酷支付
    JXVerifyTypePaymentCode,        // 验证付款码
};

@interface JXVerifyPayVC : admobViewController

@property (nonatomic, assign) JXVerifyType type;
@property (nonatomic, strong) NSString *RMB;
@property (nonatomic, strong) NSString *titleStr;

@property (nonatomic, assign) SEL didDismissVC;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL didVerifyPay;


/**
 *  清除密码
 */
- (void)clearUpPassword;

/**
 *  输入密码后
 *  获取密码(MD5加密)
 */
- (NSString *)getMD5Password;

@end
