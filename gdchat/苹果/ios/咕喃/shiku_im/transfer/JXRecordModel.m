//
//  JXRecordModel.m
//  shiku_im
//
//  Created by 1 on 2019/4/20.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXRecordModel.h"

@implementation JXRecordModel

- (void)getDataWithDict:(NSDictionary *)dict {
    self.money = [[dict objectForKey:@"money"] doubleValue];
    self.desc = [dict objectForKey:@"desc"];
    self.payType = [[dict objectForKey:@"payType"] intValue];
    self.time = [[dict objectForKey:@"time"] longValue];
    self.status = [[dict objectForKey:@"status"] intValue];
    self.type = [[dict objectForKey:@"type"] intValue];
}

@end
