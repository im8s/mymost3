//
//  JXBlogObject.m
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "JXBlogObject.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "AppDelegate.h"
#import "JXMessageObject.h"

@implementation JXBlogObject
@synthesize userId,msgId,time;

static JXBlogObject *shared;

+(JXBlogObject*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared=[[JXBlogObject alloc] init];
    });
    return shared;
}

-(id)init{
    self = [super init];
    if(self){
        _tableName = @"friend_blog";
        self.userId = nil;
        self.msgId = nil;
        self.time  = nil;
    }
    return self;
}

-(void)dealloc{
    //    NSLog(@"JXBlogObject.dealloc");
    self.userId = nil;
    self.msgId = nil;
    self.time  = nil;
//    [super dealloc];
}

-(BOOL)insert
{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    self.time   = [NSDate date];
    NSString *insertStr=[NSString stringWithFormat:@"INSERT INTO '%@' ('userId','msgId','time') VALUES (?,?,?)",_tableName];
    BOOL worked = [db executeUpdate:insertStr,self.userId,self.msgId,self.time];
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
    
    BOOL worked=[db executeUpdate:[NSString stringWithFormat:@"delete from %@ where userId=? and msgId=?",_tableName],self.userId,self.msgId];
    return worked;
}

-(BOOL)deleteAllMsg:(NSString*)userId{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    BOOL worked=[db executeUpdate:[NSString stringWithFormat:@"delete from %@ where userId=?",_tableName],self.userId];
    return worked;
}

-(void)fromObject:(JXMessageObject*)message{
    self.userId=message.fromUserId;
    self.msgId=message.objectId;
    self.time=message.timeSend;
}

-(void)fromDataset:(JXBlogObject*)obj rs:(FMResultSet*)rs{
    obj.userId=[rs stringForColumn:kBLOG_UserID];
    obj.msgId=[rs stringForColumn:kBLOG_MsgID];
    obj.time=[rs dateForColumn:kBLOG_Time];
}

-(void)fromDictionary:(JXBlogObject*)obj dict:(NSDictionary*)aDic
{
//    obj.userId = [aDic objectForKey:kUSER_ID];
}

-(NSDictionary*)toDictionary
{
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:userId,kUSER_ID,msgId,kBLOG_MsgID,time,kBLOG_Time, nil];
    return dic;
}

-(BOOL)checkTableCreatedInDb:(FMDatabase *)db
{
    NSString *createStr=[NSString stringWithFormat:@"CREATE  TABLE  IF NOT EXISTS '%@' ('msgId' VARCHAR , 'userId' VARCHAR,'time' DATETIME)",_tableName];
    
    BOOL worked = [db executeUpdate:createStr];
    //    FMDBQuickCheck(worked);
    return worked;
}

-(NSMutableArray*)getBlogIds:(int)pageIndex;
{
    NSString *sql=[NSString stringWithFormat:@"select * from %@ order by time desc limit ?*%d,%d",_tableName,PAGE_SHOW_COUNT,PAGE_SHOW_COUNT];
    NSMutableArray *resultArr=[[NSMutableArray alloc] init];
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:sql,[NSNumber numberWithInt:pageIndex]];
    while ([rs next]) {
        JXBlogObject *p=[[JXBlogObject alloc] init];
        [self fromDataset:p rs:rs];
        [resultArr addObject:p];
//        [p release];
    }
    [rs close];
    if([resultArr count]==0){
//        [resultArr release];
        resultArr = nil;
    }
    return resultArr;
}

@end
