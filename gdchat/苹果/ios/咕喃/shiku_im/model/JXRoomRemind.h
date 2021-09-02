//
//  JXRoomRemind.h
//  shiku_im
//
//  Created by flyeagleTang on 14-5-31.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRoomRemind_UserID @"userId"
#define kRoomRemind_ToUserID @"toUserId"
#define kRoomRemind_ObjectId  @"objectId"
#define kRoomRemind_Time   @"time"
#define kRoomRemind_Type   @"type"
#define kRoomRemind_Content @"content"

#define kRoomRemind_RoomName 902
#define kRoomRemind_NickName 901
#define kRoomRemind_DelRoom 903
#define kRoomRemind_DelMember 904
#define kRoomRemind_NewNotice 905
#define kRoomRemind_editNotice 934
#define kRoomRemind_DisableSay 906
#define kRoomRemind_AddMember 907
#define kRoomRemind_SetManage 913   // 设置管理员
#define kRoomRemind_ShowRead 915        // 显示已读
#define kRoomRemind_NeedVerify  916     // 邀请进群需验证
#define kRoomRemind_IsLook 917      // 群组是否公开
#define kRoomRemind_ShowMember 918  // 显示群成员
#define kRoomRemind_allowSendCard 919 // 允许发送名片

#define kRoomRemind_RoomAllBanned   920 // 群组全员禁言
#define kRoomRemind_RoomAllowInviteFriend   921 // 群组允许成员邀请好友
#define kRoomRemind_RoomAllowUploadFile     922 // 群组允许成员上传群共享文件
#define kRoomRemind_RoomAllowConference     923 // 群组允许成员召开会议
#define kRoomRemind_RoomAllowSpeakCourse    924 // 群组允许成员开启讲课
#define kRoomRemind_RoomTransfer            925 // 转让群主
#define kRoomRemind_SetInvisible    930 // 设置隐身人、监控人
#define kRoomRemind_RoomDisable     931 // 禁用群组
#define kRoomRemind_SetRecordTimeOut        932 // 设置聊天记录超时设置
#define kRoomRemind_FaceRoomSearch          933 // 面对面建群查询

// 直播协议
#define kRoomRemind_LiveBarrage     910 // 直播弹幕
#define kRoomRemind_LiveGift        911 // 直播礼物
#define kRoomRemind_LivePraise      912 // 直播点赞
#define kRoomRemind_EnterLiveRoom   914 // 加入直播间
#define kLiveRemind_RoomDisable     926 // 禁用直播间
#define kLiveRemind_ExitRoom        927 // 退出、被踢出直播间
#define kLiveRemind_ShatUp          928 // 直播禁言/取消禁言
#define kLiveRemind_SetManager      929 // 直播设置/取消管理员
#define kRoomRemind_LiveQuit        936 // 直播掉线退出


@interface JXRoomRemind : NSObject{ //房间控制消息，用于发通知，并不保存到数据库
    NSString* _tableName;
}

@property (nonatomic,strong) NSString* toUserId;//目标userId
@property (nonatomic,strong) NSString* toUserName;//目标name
@property (nonatomic,strong) NSString* content;//内容
@property (nonatomic,strong) NSString* userId;//源UserId
@property (nonatomic,strong) NSString* fromUserName;//源name
@property (nonatomic,strong) NSString* fromUserId;
@property (nonatomic,strong) NSString* objectId;//房间Jid
@property (nonatomic,strong) NSString* roomId;//房间Id
@property (nonatomic,strong) NSNumber* fileSize;
@property (nonatomic, copy) NSString *other;    // 群组其他一些设置
@property (nonatomic,strong) NSDate*   time;//时间
@property (nonatomic,strong) NSNumber* type;//类型
@property (nonatomic, assign) BOOL isGroup;

-(void)fromObject:(JXMessageObject*)message;
-(void)notify;

//数据库增删改查
/*
-(BOOL)insert;
-(BOOL)delete;
-(BOOL)update;
-(BOOL)deleteAll:(int)n;

+(JXRoomRemind*)sharedInstance;
+(void)createAndNotifyNewObj:(NSString*)objectId toUserId:(NSString*)toUserId type:(int)type;


//将对象转换为字典
-(NSDictionary*)toDictionary;
-(void)fromDataset:(JXRoomRemind*)obj rs:(FMResultSet*)rs;
-(void)fromDictionary:(JXRoomRemind*)obj dict:(NSDictionary*)aDic;
-(BOOL)checkTableCreatedInDb:(FMDatabase *)db;

-(NSMutableArray*)fetch:(int)n;
-(NSMutableArray*)doFetch:(NSString*)sql;
-(void)addToArray:(NSMutableArray*)array;
-(void)addContentToArray:(NSMutableArray*)array;
*/

@end
