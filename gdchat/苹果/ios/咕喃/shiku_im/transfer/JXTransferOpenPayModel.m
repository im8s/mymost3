//
//  JXTransferOpenPayModel.m
//  shiku_im
//
//  Created by p on 2019/5/29.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXTransferOpenPayModel.h"

@implementation JXTransferOpenPayModel
- (void)getTransferDataWithDict:(NSDictionary *)dict {
    self.money = [[dict objectForKey:@"money"] doubleValue];
    self.orderId = [dict objectForKey:@"orderId"];
    self.icon = [dict objectForKey:@"icon"];
    self.name = [dict objectForKey:@"name"];
}

@end
