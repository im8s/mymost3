//
//  JXLabelObject.m
//  shiku_im
//
//  Created by p on 2018/6/21.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXLabelObject.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@implementation JXLabelObject


static JXLabelObject *sharedLabel;

+(JXLabelObject*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLabel=[[JXLabelObject alloc]init];
    });
    return sharedLabel;
}

-(id)init{
    self = [super init];
    if(self){
        _tableName = @"label";
    }
    return self;
}

// 获取所有标签
-(NSMutableArray*)fetchAllLabelsFromLocal {
    NSString* sql = @"select * from label";
    
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        JXLabelObject *label=[[JXLabelObject alloc] init];
        [self labelFromDataset:label rs:rs];
        [resultArr addObject:label];
    }
    [rs close];

    return resultArr;
}

-(BOOL)checkTableCreatedInDb:(FMDatabase *)db
{
    NSString *createStr=[NSString stringWithFormat:@"CREATE  TABLE  IF NOT EXISTS '%@' ('groupId' VARCHAR PRIMARY KEY  NOT NULL  UNIQUE , 'userId' VARCHAR, 'groupName' VARCHAR, 'userIdList' VARCHAR)",_tableName];
    
    BOOL worked = [db executeUpdate:createStr];
    return worked;
}

-(void)labelFromDataset:(JXLabelObject*)obj rs:(FMResultSet*)rs{
    obj.userId=[rs stringForColumn:@"userId"];
    obj.groupId=[rs stringForColumn:@"groupId"];
    obj.groupName=[rs stringForColumn:@"groupName"];
    obj.userIdList=[rs stringForColumn:@"userIdList"];
    
}

//数据库增删改查
-(BOOL)insert {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];

    NSString *insertStr=[NSString stringWithFormat:@"INSERT INTO '%@' ('groupId','userId','groupName','userIdList') VALUES (?,?,?,?)",_tableName];
    
    BOOL worked = [db executeUpdate:insertStr,self.groupId,self.userId,self.groupName,self.userIdList];
    
    if(!worked)
        worked = [self update];
    return worked;
}

-(BOOL)delete {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where groupId=?",_tableName];
    BOOL worked=[db executeUpdate:sql,self.groupId];
    return worked;
}

-(BOOL)update {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set userId=?,groupName=?,userIdList=? where groupId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.userId,self.groupName,self.userIdList,self.groupId];
    return worked;
}

// 获取用户的所有标签
- (NSMutableArray *)fetchLabelsWithUserId:(NSString *)userId {
    NSString* sql = [NSString stringWithFormat:@"select * from label where userIdList = '%@'", userId];
    
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        JXLabelObject *label=[[JXLabelObject alloc] init];
        [self labelFromDataset:label rs:rs];
        [resultArr addObject:label];
    }
    [rs close];

    return resultArr;
}
    
@end
