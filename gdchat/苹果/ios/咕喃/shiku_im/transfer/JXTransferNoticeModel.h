//
//  JXTransferNoticeModel.h
//  shiku_im
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JXTransferNoticeModel : NSObject
@property (nonatomic, strong) NSString *userId;     // 码的所有人id
@property (nonatomic, strong) NSString *userName;   // 码的所有人名字
@property (nonatomic, strong) NSString *toUserId;   // 扫码的人id
@property (nonatomic, strong) NSString *toUserName; // 扫码的人名字
@property (nonatomic, assign) double money;         // 金额
@property (nonatomic, assign) int type;             // 1.付款码  2. 二维码收款
@property (nonatomic, strong) NSString *createTime; // 交易时间

@property (nonatomic, assign) int *status;  // 扫码审核状态

- (void)getTransferNoticeWithDict:(NSDictionary *)dict;

@end

