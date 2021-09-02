//
//  JXSynchronizationTask.m
//  shiku_im
//
//  Created by p on 2018/8/18.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXSynTask.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@implementation JXSynTask

static JXSynTask *sharedUser;

+(JXSynTask*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUser=[[JXSynTask alloc]init];
    });
    return sharedUser;
}

-(id)init{
    self = [super init];
    if(self){
        _tableName = @"synTask";
    }
    return self;
}

-(NSString*)getTableName{
    
//    NSString* tableName = [NSString stringWithFormat:@"task_%@",self.userId];

    return @"synTask";
}

-(BOOL)checkTableCreatedInDb:(FMDatabase *)db
{
    NSString *createStr=[NSString stringWithFormat:@"CREATE  TABLE  IF NOT EXISTS '%@' ('taskId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL  UNIQUE ,'startTime' DATETIME DEFAULT 0,'endTime' DATETIME,'lastTime' DATETIME,'startMsgId' VARCHAR,'endMsgId' VARCHAR,'userId' VARCHAR,'roomId' VARCHAR,'isLoading' INTEGER, 'isFinish' INTEGER)",[self getTableName]];
    
    BOOL worked = [db executeUpdate:createStr];
    return worked;
}

//数据库增删改查
-(BOOL)insert {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];

    if (!self.startTime) {
        self.startTime = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    NSString *insertStr=[NSString stringWithFormat:@"INSERT INTO '%@' ('startTime','endTime','lastTime','startMsgId','endMsgId','userId','roomId','isLoading','isFinish') VALUES (?,?,?,?,?,?,?,?,?)",[self getTableName]];
    BOOL worked = [db executeUpdate:insertStr,self.startTime,self.endTime,self.lastTime,self.startMsgId,self.endMsgId,self.userId,self.roomId,self.isLoading,self.isFinish];
    
    return worked;
}


-(BOOL)update {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set startTime=?,endTime=?,lastTime=?,startMsgId=?,endMsgId=?,userId=?,roomId=?,isLoading=?,isFinish=? where taskId=?",[self getTableName]];
    BOOL worked = [db executeUpdate:sql,self.startTime,self.endTime,self.lastTime,self.startMsgId,self.endMsgId,self.userId,self.roomId,self.isLoading,self.isFinish,self.taskId];
    return worked;
}

-(BOOL)delete {
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where taskId=?",[self getTableName]];
    BOOL worked=[db executeUpdate:sql,self.taskId];
    return worked;
}

- (BOOL)deleteTaskWithRoomId:(NSString *)roomId {
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where roomId=?",[self getTableName]];
    BOOL worked=[db executeUpdate:sql,roomId];
    return worked;
}

// 更新起始时间
- (BOOL)updateStartTime {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set startTime=? where taskId=?",[self getTableName]];
    BOOL worked = [db executeUpdate:sql,self.startTime,self.taskId];
    return worked;
}

// 更新结束时间
- (BOOL)updateEndTime {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set endTime=? where taskId=?",[self getTableName]];
    BOOL worked = [db executeUpdate:sql,self.endTime,self.taskId];
    return worked;
}

// 获取单个群的任务列表
- (NSMutableArray *)getTaskWithUserId:(NSString *)userId {
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString *sql = @"select * from synTask where userId = ? order by startTime desc";
    FMResultSet *rs=[db executeQuery:sql,userId];
    while ([rs next]) {
        JXSynTask *task=[[JXSynTask alloc] init];
        [self taskFromDataset:task rs:rs];
        [resultArr addObject:task];
    }

    return resultArr;
}



-(void)taskFromDataset:(JXSynTask*)obj rs:(FMResultSet*)rs{
    obj.userId = [rs stringForColumn:@"userId"];
    obj.roomId = [rs stringForColumn:@"roomId"];
    obj.taskId = [rs stringForColumn:@"taskId"];
    obj.startTime = [rs dateForColumn:@"startTime"];
    obj.endTime = [rs dateForColumn:@"endTime"];
    obj.lastTime = [rs dateForColumn:@"lastTime"];
    obj.startMsgId = [rs stringForColumn:@"startMsgId"];
    obj.endMsgId = [rs stringForColumn:@"endMsgId"];
    obj.isLoading = [rs objectForColumnName:@"isLoading"];
    obj.isFinish = [rs objectForColumnName:@"isFinish"];
}

@end
