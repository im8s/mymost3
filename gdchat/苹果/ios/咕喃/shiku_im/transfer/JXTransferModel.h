//
//  JXTransferModel.h
//  shiku_im
//
//  Created by 1 on 2019/3/2.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JXTransferModel : NSObject

@property (nonatomic, assign) long userId;     // 发送者id
@property (nonatomic, assign) long toUserId;   // 接收者id
@property (nonatomic, strong) NSString *userName;   // 发送者昵称
@property (nonatomic, strong) NSString *reamrk;     // 转账说明
@property (nonatomic, strong) NSString *createTime; // 转账时间
@property (nonatomic, assign) double money;         // 金额
@property (nonatomic, strong) NSString *outTime;    // 过期时间
@property (nonatomic, assign) int status; // 1.发出  2. 已收款  -1.已退款
@property (nonatomic, strong) NSString *receiptTime; //收款时间
@property (nonatomic, assign) BOOL isCloudTransfer;

- (void)getTransferDataWithDict:(NSDictionary *)dict;

@end
