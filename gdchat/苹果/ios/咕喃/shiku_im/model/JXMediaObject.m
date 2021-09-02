//
//  JXMediaObject.m
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "JXMediaObject.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "AppDelegate.h"
#import "JXMessageObject.h"

@implementation JXMediaObject

@synthesize userId;
@synthesize fileName;
@synthesize name;
@synthesize remark;
@synthesize isVideo;
@synthesize timeLen;
@synthesize createTime;
@synthesize url;


static JXMediaObject *shared;

+(JXMediaObject*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared=[[JXMediaObject alloc] init];
    });
    return shared;
}

-(id)init{
    self = [super init];
    if(self){
        _tableName = @"media";
        self.userId = nil;
        self.isDelete = [NSNumber numberWithBool:NO];
    }
    return self;
}

-(void)dealloc{
    //    NSLog(@"JXMediaObject.dealloc");
    self.userId = nil;
    self.fileName = nil;
    self.photoPath = nil;
    self.name = nil;
    self.remark = nil;
    self.isVideo = nil;
    self.isDelete = nil;
    self.timeLen = nil;
    self.createTime = nil;
    self.url = nil;
//    [super dealloc];
}

-(BOOL)insert
{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    if (!self.createTime) {
        self.createTime   = [NSDate date];
    }
    NSString *sql=[NSString stringWithFormat:@"INSERT INTO '%@' (userId,fileName,createTime,name,remark,timeLen,isVideo,url,photoPath,isDelete) VALUES (?,?,?,?,?,?,?,?,?,?)",_tableName];
    BOOL worked = [db executeUpdate:sql,self.userId,self.fileName,self.createTime,self.name,self.remark,self.timeLen,self.isVideo,self.url,self.photoPath,self.isDelete];
    //    FMDBQuickCheck(worked);
    
    if(!worked)
        worked = [self update];
    return worked;
}

-(BOOL)update
{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString *sql=[NSString stringWithFormat:@"update '%@' set url=?,name=?,remark=? where mediaId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.url,self.name,self.remark,self.mediaId];
    //    FMDBQuickCheck(worked);
    
    return worked;
}

-(BOOL)delete
{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    if (self.photoPath.length > 0) { // 当是手机中的视频时，更新isDelete = YES，以便删除时不显示
        self.isDelete = [NSNumber numberWithBool:YES];
        BOOL worked=[db executeUpdate:[NSString stringWithFormat:@"update '%@' set isDelete=? where mediaId=?",_tableName],self.isDelete,self.mediaId];
        return worked;
    }
    
    BOOL worked=[db executeUpdate:[NSString stringWithFormat:@"delete from %@ where mediaId=?",_tableName],self.mediaId];
    return worked;
}

// 清除缓存后删除所有
-(BOOL)deleteAll {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    BOOL worked=[db executeUpdate:[NSString stringWithFormat:@"delete from %@",_tableName]];
    return worked;
}

-(void)fromDataset:(JXMediaObject*)obj rs:(FMResultSet*)rs{
    obj.userId=[rs stringForColumn:kMedia_userId];
    obj.fileName=[rs stringForColumn:kMedia_FileName];
    obj.photoPath=[rs stringForColumn:kMedia_PhotoPath];
    obj.remark=[rs stringForColumn:kMedia_Remark];
    obj.name=[rs stringForColumn:kMedia_Name];
    obj.url=[rs stringForColumn:kMedia_url];
    obj.timeLen=[rs objectForColumnName:kMedia_timeLen];
    obj.createTime=[rs dateForColumn:kMedia_Time];
    obj.isVideo=[rs objectForColumnName:kMedia_IsVideo];
    obj.isDelete=[rs objectForColumnName:kMedia_IsDelete];
    obj.mediaId=[rs objectForColumnName:kMedia_ID];
}

-(void)fromDictionary:(JXMediaObject*)obj dict:(NSDictionary*)aDic
{
    //    obj.userId = [aDic objectForKey:kUSER_ID];
}

-(NSDictionary*)toDictionary
{
//    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:userId,kUSER_ID,msgId,kMedia_MsgID,time,kMedia_Time, nil];
//    return dic;
    return nil;
}

-(BOOL)checkTableCreatedInDb:(FMDatabase *)db
{
    NSString *createStr=[NSString stringWithFormat:@"CREATE  TABLE  IF NOT EXISTS '%@' ('mediaId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL  UNIQUE ,'userId' VARCHAR,'createTime' DATETIME,'name' VARCHAR,'remark' VARCHAR,'fileName' VARCHAR,'url' VARCHAR,'isVideo' INTEGER,'timeLen' INTEGER,'photoPath' INTEGER,'isDelete' INTEGER)",_tableName];
    
    BOOL worked = [db executeUpdate:createStr];
    //    FMDBQuickCheck(worked);
    return worked;
}

-(NSMutableArray*)fetch
{
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString *sql=[NSString stringWithFormat:@"select * from media where isDelete<>1 order by mediaId desc"];
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        JXMediaObject *user=[[JXMediaObject alloc] init];
        [self fromDataset:user rs:rs];
        [resultArr addObject:user];
//        [user release];
    }
    [rs close];
//    if([resultArr count]==0){
////        [resultArr release];
//        resultArr = nil;
//    }
    return resultArr;
}

- (BOOL)haveTheMediaWithPhotoPath:(NSString *)photoPath {
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString *sql=[NSString stringWithFormat:@"select * from media where photoPath=?"];
    FMResultSet *rs=[db executeQuery:sql,photoPath];
    while ([rs next]) {
        return YES;
    }

    return NO;
}

@end
