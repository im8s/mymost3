//
//  JXRecordModel.h
//  shiku_im
//
//  Created by 1 on 2019/4/20.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXRecordModel : NSObject
@property (nonatomic, assign) double money;
@property (nonatomic, strong) NSString *desc;// 说明
@property (nonatomic, assign) int payType;
@property (nonatomic, assign) long time;
@property (nonatomic, assign) int status;
@property (nonatomic, assign) int type; // 支出|收入判断


@property (nonatomic, assign) double payMoney;//该月总支出
@property (nonatomic, assign) double getMoney;//该月总收入

- (void)getDataWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
