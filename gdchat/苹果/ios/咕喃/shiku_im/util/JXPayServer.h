//
//  JXPayServer.h
//  shiku_im
//
//  Created by p on 2019/7/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXPayServer : NSObject

@property (nonatomic, assign) int randNum;

+ (instancetype)sharedManager;

// 获取接口加密参数
- (NSString *)getParamStringWithParamDic:(NSMutableArray *)param time:(long)time payPassword:(NSString *)payPassword code:(NSString *)code;

// 支付通用接口方法
- (void)payServerWithAction:(NSString *)action param:(NSMutableArray *)param payPassword:(NSString *)payPassword time:(long)time toView:(id)toView;

// 获取qrCode
- (NSString *) getQrCode;

@end

NS_ASSUME_NONNULL_END
