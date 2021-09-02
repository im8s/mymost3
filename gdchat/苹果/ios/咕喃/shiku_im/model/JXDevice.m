//
//  JXDevice.m
//  shiku_im
//
//  Created by p on 2018/6/6.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXDevice.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@implementation JXDevice

static JXDevice *sharedUser;
+(JXDevice*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUser=[[JXDevice alloc]init];
    });
    return sharedUser;
}

-(id)init{
    self = [super init];
    if(self){
        
    }
    return self;
}

// 更新其他端isOnLine
- (BOOL) updateIsOnLine:(NSNumber *)isOnLine userId:(NSString *)userId {
    NSString* myUserId = g_myself.userId;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set isOnLine=? where userId=?",@"friend"];
    BOOL worked = [db executeUpdate:sql,isOnLine,userId];
    return worked;
}

// 更新其他端isSendRecipt
- (BOOL) updateIsSendRecipt:(NSNumber *)isSendRecipt userId:(NSString *)userId {
    NSString* myUserId = g_myself.userId;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set isSendRecipt=? where userId=?",@"friend"];
    BOOL worked = [db executeUpdate:sql,isSendRecipt,userId];
    return worked;
}

// 查找我的设备
-(NSMutableArray*)fetchAllDeviceFromLocal {
    NSString* sql = @"select * from friend where isDevice = 1";
    return [self doFetch:sql];
}

-(NSMutableArray*)doFetch:(NSString*)sql
{
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    NSString* myUserId = g_myself.userId;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [super checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        JXDevice *user=[[JXDevice alloc] init];
        [self userFromDataset:user rs:rs];
        //        [self userFromDataset:rs];
        [resultArr addObject:user];
        //        [user release];
    }
    [rs close];
    if([resultArr count]==0){
        //        [resultArr release];
        resultArr = nil;
    }
    return resultArr;
}

@end
