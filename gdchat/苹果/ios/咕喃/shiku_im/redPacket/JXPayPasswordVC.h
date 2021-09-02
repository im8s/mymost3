//
//  JXPayPasswordVC.h
//  shiku_im
//
//  Created by 1 on 2018/9/18.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "admobViewController.h"

typedef NS_OPTIONS(NSInteger, JXPayType) {
    JXPayTypeSetupPassword,     //设置密码
    JXPayTypeRepeatPassword,    //重复密码
    JXPayTypeInputPassword,     //输入密码,确认身份
};


/**
*   新控制器进入密码设置按钮需要添加新的Type，处理界面返回（不然会出现界面无法返回的情况）
*/
typedef NS_OPTIONS(NSInteger, JXEnterType) {
    JXEnterTypeDefault,            //默认，我的钱包进入
    JXEnterTypeWithdrawal,         //提现进入
    JXEnterTypeSendRedPacket,      //发红包进入
    JXEnterTypeTransfer,           //转账进入
    JXEnterTypeQr,                 //扫码付款进入
    JXEnterTypeSkPay,              //视酷支付进入
    JXEnterTypePayQr,               //付款码进入
};

@protocol JXPayPasswordVCDelegate <NSObject>

- (void)updatePayPasswordSuccess:(NSString *)payPassword;

@end

@interface JXPayPasswordVC : admobViewController
@property (nonatomic, assign) JXPayType type;
@property (nonatomic, assign) JXEnterType enterType;
@property (nonatomic, strong) NSString *lastPsw;
@property (nonatomic, strong) NSString *oldPsw;
@property (nonatomic, weak) id<JXPayPasswordVCDelegate> delegate;

@end
