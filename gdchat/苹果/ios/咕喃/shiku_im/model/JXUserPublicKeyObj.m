//
//  JXUserPublicKeyObj.m
//  shiku_im
//
//  Created by p on 2019/8/7.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXUserPublicKeyObj.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@interface JXUserPublicKeyObj()

@property (nonatomic, copy) NSString *tableName;

@end

@implementation JXUserPublicKeyObj

+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static JXUserPublicKeyObj *instance;
    dispatch_once(&onceToken, ^{
        instance = [[JXUserPublicKeyObj alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if ([super init]) {
        _tableName = @"PublicKey";
    }
    
    return self;
}

-(NSString*)getTableName{
    return @"PublicKey";
}

-(BOOL)checkTableCreatedInDb:(FMDatabase *)db
{
    NSString *createStr=[NSString stringWithFormat:@"CREATE  TABLE  IF NOT EXISTS '%@' ('userId' VARCHAR,'publicKey' VARCHAR,'keyCreateTime' DATETIME DEFAULT 0)",[self getTableName]];
    
    BOOL worked = [db executeUpdate:createStr];
    return worked;
}

//数据库增删改查
-(BOOL)insert {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString *insertStr=[NSString stringWithFormat:@"INSERT INTO '%@' ('userId','publicKey','keyCreateTime') VALUES (?,?,?)",[self getTableName]];
    BOOL worked = [db executeUpdate:insertStr,self.userId,self.publicKey,self.keyCreateTime];
    
    return worked;
}

-(BOOL)delete {
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where publicKey=?",[self getTableName]];
    BOOL worked=[db executeUpdate:sql,self.publicKey];
    return worked;
}

// 获取好友的公钥列表
- (NSMutableArray *)fetchPublicKeyWithUserId:(NSString *)userId {
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];

    NSString *sql = @"select * from PublicKey where userId = ? order by keyCreateTime desc";
    FMResultSet *rs=[db executeQuery:sql,userId];
    while ([rs next]) {
        JXUserPublicKeyObj *obj=[[JXUserPublicKeyObj alloc] init];
        obj.userId = [rs stringForColumn:@"userId"];
        obj.publicKey = [rs stringForColumn:@"publicKey"];
        obj.keyCreateTime = [rs dateForColumn:@"keyCreateTime"];
        [resultArr addObject:obj];
    }
    
    return resultArr;
}

// 删除好友的公钥列表
- (BOOL)deletePublicKeyWIthUserId:(NSString *)userId {
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where userId=?",[self getTableName]];
    BOOL worked=[db executeUpdate:sql,userId];
    return worked;
}


@end
