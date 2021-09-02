//
//  JXPacketObject.m
//  shiku_im
//
//  Created by Apple on 16/8/30.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXPacketObject.h"

@implementation JXPacketObject

+ (JXPacketObject*)getPacketObject:(NSDictionary *)dataDict{
    NSDictionary * dictPocket = dataDict[@"data"][@"packet"];
    if (dictPocket == nil) {
        dictPocket = dataDict[@"packet"];
    }
    if (dictPocket) {
        JXPacketObject * obj = [[JXPacketObject alloc]init];
        obj.count = [dictPocket[@"count"] longValue];
        obj.greetings = dictPocket[@"greetings"];
        obj.packetId = dictPocket[@"id"];
        obj.money = [dictPocket[@"money"] floatValue];
        obj.outTime = [dictPocket[@"outTime"] longValue];
        obj.over = [dictPocket[@"over"] floatValue];
        obj.receiveCount = [dictPocket[@"receiveCount"] longValue];
        obj.sendTime = [dictPocket[@"sendTime"] longValue];
        obj.status = [dictPocket[@"status"] longValue];
        obj.type = [dictPocket[@"type"] longValue];
        obj.userId = dictPocket[@"userId"];
        obj.userIds = dictPocket[@"userIds"];
        obj.userName = dictPocket[@"userName"];
        return obj;
    }
    return nil;
}
@end
