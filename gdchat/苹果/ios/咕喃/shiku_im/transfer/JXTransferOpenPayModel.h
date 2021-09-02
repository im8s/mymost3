//
//  JXTransferOpenPayModel.h
//  shiku_im
//
//  Created by p on 2019/5/29.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXTransferOpenPayModel : NSObject

@property (nonatomic, assign) double money;         // 金额
@property (nonatomic,copy) NSString *orderId;       // 订单id
@property (nonatomic,copy) NSString *icon;          // 头像
@property (nonatomic,copy) NSString *name;          // 收款方名字

- (void)getTransferDataWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
