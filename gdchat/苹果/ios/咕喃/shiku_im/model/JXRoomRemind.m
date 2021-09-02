//
//  JXRoomRemind.m
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "JXRoomRemind.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "AppDelegate.h"
#import "JXMessageObject.h"

@implementation JXRoomRemind
@synthesize userId,objectId,time,type,roomId,fromUserName;

static JXRoomRemind *shared;


-(id)init{
    self = [super init];
    if(self){
        _tableName = @"roomRemind";
        self.userId = nil;
        self.fromUserName = nil;
        self.objectId = nil;
        self.time  = nil;
        self.toUserId = nil;
        self.content = nil;
        self.type = nil;
        self.fileSize = nil;
    }
    return self;
}

-(void)dealloc{
//    NSLog(@"JXRoomRemind.dealloc");
    self.userId = nil;
    self.fromUserName = nil;
    self.objectId = nil;
    self.time  = nil;
    self.toUserId = nil;
    self.content = nil;
    self.type = nil;
//    [super dealloc];
}

-(void)notify{
    //发送全局通知
    [g_notify postNotificationName:kXMPPRoomNotifaction object:self userInfo:nil];
}

-(void)fromObject:(JXMessageObject*)message{
    self.userId=message.fromUserId;
    self.fromUserName=message.fromUserName;
    self.fromUserId = message.fromUserId;
    self.objectId=message.objectId;
    self.time=message.timeSend;
    self.toUserId = message.toUserId;
    self.content = message.content;
    self.type = message.type;
    self.roomId = message.fileName;
    self.fileSize = message.fileSize;
    self.other = message.other;
    self.toUserName = message.toUserName;
    self.isGroup = message.isGroup;
}


/*
 //+(JXRoomRemind*)sharedInstance{
 //    static dispatch_once_t onceToken;
 //    dispatch_once(&onceToken, ^{
 //        shared=[[JXRoomRemind alloc] init];
 //    });
 //    return shared;
 //}

 -(BOOL)insert
{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    self.time   = [NSDate date];
    NSString *insertStr=[NSString stringWithFormat:@"INSERT INTO '%@' ('userId','objectId','time','toUserId','content',type) VALUES (?,?,?,?,?,?)",_tableName];
    BOOL worked = [db executeUpdate:insertStr,self.userId,self.objectId,self.time,self.toUserId,self.content,self.type];
    //    FMDBQuickCheck(worked);
    
    if(!worked)
        worked = [self update];
    return worked;
}

-(BOOL)update
{
    return YES;
}

-(BOOL)delete
{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    BOOL worked=[db executeUpdate:[NSString stringWithFormat:@"delete from %@ where toUserId=? and objectId=? and type=?",_tableName],self.toUserId,self.objectId,self.type];
    return worked;
}

-(BOOL)deleteAll:(int)n{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    BOOL worked=[db executeUpdate:[NSString stringWithFormat:@"delete from %@ where toUserId=? and type=%d",_tableName,n],self.toUserId];
    return worked;
}

-(void)fromDataset:(JXRoomRemind*)obj rs:(FMResultSet*)rs{
    obj.userId=[rs stringForColumn:kRoomRemind_UserID];
    obj.toUserId=[rs stringForColumn:kRoomRemind_ToUserID];
    obj.content=[rs stringForColumn:kRoomRemind_Content];
    obj.objectId=[rs stringForColumn:kRoomRemind_ObjectId];
    obj.time=[rs objectForColumnName:kRoomRemind_Time];
    obj.type=[rs objectForColumnName:kRoomRemind_Type];
}

-(void)fromDictionary:(JXRoomRemind*)obj dict:(NSDictionary*)aDic
{
    //    obj.userId = [aDic objectForKey:kUSER_ID];
}

-(NSDictionary*)toDictionary
{
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:userId,kUSER_ID,objectId,kRoomRemind_ObjectId,time,kRoomRemind_Time, nil];
    return dic;
}

-(BOOL)checkTableCreatedInDb:(FMDatabase *)db
{
    NSString *createStr=[NSString stringWithFormat:@"CREATE  TABLE  IF NOT EXISTS '%@' ('objectId' VARCHAR , 'userId' VARCHAR,'toUserId' VARCHAR,'content' VARCHAR,'time' DATETIME,type INTEGER)",_tableName];
    
    BOOL worked = [db executeUpdate:createStr];
    //    FMDBQuickCheck(worked);
    return worked;
}

-(NSMutableArray*)fetch:(int)n{
    NSString* sql = [NSString stringWithFormat:@"select objectId from %@ where type=%d and toUserId='%@' group by objectId",_tableName,n,g_myself.userId];
    return [self doFetch:sql];
}

-(NSMutableArray*)doFetch:(NSString*)sql
{
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        [resultArr addObject:[rs stringForColumn:kRoomRemind_ObjectId]];
    }
    [rs close];
    return resultArr;
}


-(void)addToArray:(NSMutableArray*)array{
    if([self.objectId length]<=0)
        return;
    if([array indexOfObject:self.objectId] == NSNotFound)
        [array addObject:self.objectId];
}

-(void)addContentToArray:(NSMutableArray*)array{
    if([self.content length]<=0)
        return;
    if([array indexOfObject:self.content] == NSNotFound)
        [array addObject:self.content];
}

+(void)createAndNotifyNewObj:(NSString*)objectId toUserId:(NSString*)toUserId type:(int)type{
    if(!objectId)
        return;
    JXRoomRemind* p = [[JXRoomRemind alloc]init];
    p.toUserId = MY_USER_ID;
    p.userId = toUserId;
    p.objectId = objectId;
    p.type = [NSNumber numberWithInt:type];
    p.time = [NSDate date];
    [p insert];
    [p notify];
//    [p release];
}
*/

@end
