//
//  JXMediaObject.h
//  shiku_im
//
//  Created by flyeagleTang on 14-5-31.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMedia_ID       @"mediaId"
#define kMedia_FileName @"fileName"
#define kMedia_PhotoPath @"photoPath"
#define kMedia_IsVideo  @"isVideo"
#define kMedia_IsDelete  @"isDelete"
#define kMedia_Time     @"createTime"
#define kMedia_Remark   @"remark"
#define kMedia_Name     @"name"
#define kMedia_url      @"url"
#define kMedia_userId   @"userId"
#define kMedia_timeLen   @"timeLen"

@interface JXMediaObject : NSObject{
    NSString* _tableName;
}

@property (nonatomic,strong) NSString* userId;
@property (nonatomic,strong) NSString* fileName;
@property (nonatomic,strong) NSString* photoPath;
@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSString* remark;
@property (nonatomic,strong) NSString* url;
@property (nonatomic,strong) NSNumber* mediaId;
@property (nonatomic,strong) NSNumber* isVideo;
@property (nonatomic,strong) NSNumber* timeLen;
@property (nonatomic,strong) NSNumber* isDelete;
@property (nonatomic,strong) NSDate*   createTime;

//数据库增删改查
-(BOOL)insert;
-(BOOL)delete;
-(BOOL)update;

// 清除缓存后删除所有
-(BOOL)deleteAll;

+(JXMediaObject*)sharedInstance;

// 当前URL是不是手机视频
- (BOOL)haveTheMediaWithPhotoPath:(NSString *)photoPath;

//将对象转换为字典
-(NSDictionary*)toDictionary;
-(void)fromDataset:(JXMediaObject*)obj rs:(FMResultSet*)rs;
-(void)fromDictionary:(JXMediaObject*)obj dict:(NSDictionary*)aDic;
-(BOOL)checkTableCreatedInDb:(FMDatabase *)db;
-(NSMutableArray*)fetch;
@end
