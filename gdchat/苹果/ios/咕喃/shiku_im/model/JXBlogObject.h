//
//  JXBlogObject.h
//  shiku_im
//
//  Created by flyeagleTang on 14-5-31.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBLOG_UserID @"userId"
#define kBLOG_MsgID  @"msgId"
#define kBLOG_Time   @"time"

#define XMPP_TYPE_NEWCHAT 600  //
#define XMPP_TYPE_NEWGIFT 601  //
#define XMPP_TYPE_NEWPRIASE 602  //
#define XMPP_TYPE_NEWBLOG 603  //

@interface JXBlogObject : NSObject{
    NSString* _tableName;
}

@property (nonatomic,strong) NSString* userId;
@property (nonatomic,strong) NSString* msgId;
@property (nonatomic,strong) NSDate*   time;

//数据库增删改查
-(BOOL)insert;
-(BOOL)delete;
-(BOOL)update;

+(JXBlogObject*)sharedInstance;


//将对象转换为字典
-(NSDictionary*)toDictionary;
-(void)fromDataset:(JXBlogObject*)obj rs:(FMResultSet*)rs;
-(void)fromDictionary:(JXBlogObject*)obj dict:(NSDictionary*)aDic;
-(void)fromObject:(JXMessageObject*)message;
-(BOOL)checkTableCreatedInDb:(FMDatabase *)db;

@end
