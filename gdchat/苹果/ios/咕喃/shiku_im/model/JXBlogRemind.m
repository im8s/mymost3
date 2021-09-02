//
//  JXBlogRemind.m
//  shiku_im
//
//  Created by p on 2017/7/3.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXBlogRemind.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@implementation JXBlogRemind

static JXBlogRemind *shared;

+(JXBlogRemind*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared=[[JXBlogRemind alloc] init];
    });
    return shared;
}

-(id)init{
    self = [super init];
    if(self){
        _tableName = @"remind_blog";
    }
    return self;
}

-(BOOL)insertObj {
    
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    // 取消点赞不存，重置点赞状态
    if (self.type == kWCMessageTypeWeiboCancelPraise) {
        _isRead = YES;
        // 更新点赞消息的内容
        [self updateOneMsgUnreadWithType:kWCMessageTypeWeiboPraise];
        return NO;
    }

    //点赞去重
    if (self.type == kWCMessageTypeWeiboPraise) {
        NSString *existStr = [NSString stringWithFormat:@"select * from %@ where objectId = '%@' and fromUserId = '%@' and type = %@", _tableName, self.objectId, self.fromUserId, [NSNumber numberWithInt:self.type]];
        BOOL isExist = NO;
        FMResultSet *rs = [db executeQuery:existStr];
        while ([rs next]) {
            isExist = YES;
            break;
        }
        if (isExist) {
            if (self.type == kWCMessageTypeWeiboPraise) {
                _isRead = NO;
                [self updateOneMsgUnreadWithType:self.type];
            }
            return NO;
        }
    }
    
    // 评论去重
    if (self.type == kWCMessageTypeWeiboComment || self.type == kWCMessageTypeWeiboRemind) {
        NSString *existStr = [NSString stringWithFormat:@"select * from %@ where messageId = '%@' and type = %@", _tableName, self.messageId, [NSNumber numberWithInt:self.type]];
        BOOL isExist = NO;
        FMResultSet *rs = [db executeQuery:existStr];
        while ([rs next]) {
            isExist = YES;
            break;
        }
        if (isExist) {
            return NO;
        }
    }
    
    NSString *insertStr=[NSString stringWithFormat:@"INSERT INTO '%@' ('objectId','fromUserId','fromUserName','messageId','url','toUserId','toUserName','content','type','msgType','timeSend','isRead') VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",_tableName];
    BOOL worked = [db executeUpdate:insertStr,self.objectId,self.fromUserId,self.fromUserName,self.messageId,self.url,self.toUserId,self.toUserName,self.content,[NSNumber numberWithInt:self.type],[NSNumber numberWithInt:self.msgType],self.timeSend,[NSNumber numberWithBool:_isRead]];
    //    FMDBQuickCheck(worked);
    
    if(!worked)
        worked = [self updateObj];
    return worked;
}

-(BOOL)deleteAllMsg{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    BOOL worked=[db executeUpdate:[NSString stringWithFormat:@"delete from %@",_tableName]];
    return worked;
}

-(BOOL)updateObj {
    return YES;
}

// 查询所有消息
-(NSMutableArray*)doFetch
{
    
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where type != 305", _tableName];
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        JXBlogRemind *obj=[[JXBlogRemind alloc] init];
        [self fromDataset:obj rs:rs];
        [resultArr addObject:obj];
    }
    [rs close];
    
    NSMutableArray *array = [NSMutableArray array];
    for(NSInteger i=resultArr.count - 1; i>=0;i--){
        [array addObject:[resultArr objectAtIndex:i]];
    }
    return array;
}

// 查询未读消息
-(NSMutableArray *)doFetchUnread {
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where isRead = 0 and type != 305", _tableName];
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        JXBlogRemind *obj=[[JXBlogRemind alloc] init];
        [self fromDataset:obj rs:rs];
        [resultArr addObject:obj];
    }
    [rs close];
    
    NSMutableArray *array = [NSMutableArray array];
    for(NSInteger i=resultArr.count - 1; i>=0;i--){
        [array addObject:[resultArr objectAtIndex:i]];
    }
    return array;
}

// 查询新朋友圈未读消息
-(NSMutableArray *)doFetchNewMsgUnread {
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where isRead = 0 and type = 305", _tableName];
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        JXBlogRemind *obj=[[JXBlogRemind alloc] init];
        [self fromDataset:obj rs:rs];
        [resultArr addObject:obj];
    }
    [rs close];
    
    NSMutableArray *array = [NSMutableArray array];
    for(NSInteger i=resultArr.count - 1; i>=0;i--){
        [array addObject:[resultArr objectAtIndex:i]];
    }
    return array;
}

// 将未读消息设置为已读
- (BOOL)updateUnread {
    
    NSString *sql = [NSString stringWithFormat:@"update %@ set isRead = ? where isRead = 0", _tableName];
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    BOOL worked = [db executeUpdate:sql,[NSNumber numberWithBool:YES]];
    
    return worked;
}

// 将某条消息设置为已读/未读
- (BOOL)updateOneMsgUnreadWithType:(int)type {
    
    NSString *sql = [NSString stringWithFormat:@"update %@ set isRead = ? where fromUserId = ? and objectId = ? and type = ?", _tableName];

    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    BOOL worked = [db executeUpdate:sql,[NSNumber numberWithBool:self.isRead],self.fromUserId,self.objectId,[NSNumber numberWithInt:type]];
    
    return worked;
}

// 将新朋友圈未读消息设置为已读
- (BOOL)updateNewMsgRead {
    
    NSString *sql = [NSString stringWithFormat:@"update %@ set isRead = 1 where isRead = 0 and type = 305", _tableName];
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    BOOL worked = [db executeUpdate:sql,[NSNumber numberWithBool:YES]];
    
    return worked;
}

-(BOOL)checkTableCreatedInDb:(FMDatabase *)db
{
    NSString *createStr=[NSString stringWithFormat:@"CREATE  TABLE  IF NOT EXISTS '%@' ('objectId' VARCHAR ,'fromUserId' VARCHAR , 'fromUserName' VARCHAR, 'messageId' VARCHAR ,'url' VARCHAR ,'toUserId' VARCHAR ,'toUserName' VARCHAR ,'content' VARCHAR ,'type' INTEGER ,'msgType' INTEGER ,'timeSend' DATETIME ,'isRead' INTEGER)",_tableName];
    
    BOOL worked = [db executeUpdate:createStr];
    //    FMDBQuickCheck(worked);
    return worked;
}

-(void)fromObject:(JXMessageObject*)message{
    self.fromUserId=message.fromUserId;
    self.fromUserName=message.fromUserName;
    self.type = [message.type intValue];
    NSString *objId = message.objectId;
    NSArray *arr = [objId componentsSeparatedByString:@","];
    self.objectId = arr.firstObject;
    self.messageId = message.messageId;
    if (arr.count > 1) {
        self.msgType = [arr[1] intValue];
    }
    self.url = arr.lastObject;
    self.toUserId = message.toUserId;
    self.toUserName = message.toUserName;
    self.content = message.content;
    self.timeSend = message.timeSend;
    self.isRead = NO;
    
}

-(void)fromDataset:(JXBlogRemind*)obj rs:(FMResultSet*)rs {
    obj.objectId = [rs stringForColumn:@"objectId"];
    obj.fromUserId=[rs stringForColumn:@"fromUserId"];
    obj.fromUserName=[rs stringForColumn:@"fromUserName"];
    obj.type = [rs intForColumn:@"type"];
    obj.messageId = [rs stringForColumn:@"messageId"];
    obj.msgType = [rs intForColumn:@"msgType"];
    obj.url = [rs stringForColumn:@"url"];
    obj.toUserId = [rs stringForColumn:@"toUserId"];
    obj.toUserName = [rs stringForColumn:@"toUserName"];
    obj.content = [rs stringForColumn:@"content"];
    obj.timeSend = [rs dateForColumn:@"timeSend"];
    obj.isRead = [rs boolForColumn:@"isRead"];
}

@end
