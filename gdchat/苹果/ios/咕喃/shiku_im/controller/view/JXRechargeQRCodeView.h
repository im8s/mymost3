//
//  JXRechargeQRCodeView.h
//  shiku_im
//
//  Created by p on 2019/12/5.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    RechargeType_Wechat = 1,    // 微信
    RechargeType_Alipay,        // 支付宝
    RechargeType_BankCard,      // 银行卡
} RechargeType;

@class JXRechargeQRCodeView;

@protocol JXRechargeQRCodeViewDelegate <NSObject>

// 确定按钮点击
- (void)rechargeQRCodeView:(JXRechargeQRCodeView *)view doneBtnActionWithMoney:(NSString *)money type:(NSInteger)type;

@end

@interface JXRechargeQRCodeView : UIView

@property (nonatomic, strong) UIImageView *qrImageView;
@property (nonatomic,copy) NSString *qrUrl;
@property (nonatomic,copy) NSString *money;
@property (nonatomic,copy) NSString *bankName;
@property (nonatomic,copy) NSString *bankCard;
@property (nonatomic,copy) NSString *name;
@property (nonatomic, assign) RechargeType type;
@property (nonatomic, weak) id<JXRechargeQRCodeViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
