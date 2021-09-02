//
//  JXGetPacketList.m
//  shiku_im
//
//  Created by Apple on 16/8/30.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXGetPacketList.h"

@implementation JXGetPacketList

+ (NSArray*)getPackList:(NSDictionary*)dataDict{
    NSArray * array = dataDict[@"data"][@"list"];
    if (array == nil) {
        array = dataDict[@"list"];
    }
    NSMutableArray * packetList = [[NSMutableArray alloc]init];
    
    for (NSDictionary * dict in array) {
        JXGetPacketList * packet = [[JXGetPacketList alloc]init];
        packet.recodeId = dict[@"id"];
        packet.money = [dict[@"money"] floatValue];
        packet.redId = dict[@"redId"];
        packet.time = [dict[@"time"] longValue];
        packet.userId = dict[@"userId"];
        packet.userName = dict[@"userName"];
        packet.reply = dict[@"reply"];
        [packetList addObject:packet];
//        [packet release];
    }
    return packetList;
}
@end
