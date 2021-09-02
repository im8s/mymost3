//
//  roomData.h
//  shiku_im
//
//  Created by flyeagleTang on 15-2-6.
//  Copyright (c) 2015年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
@class memberData;

@interface roomData : NSObject{
    NSString* _tableName;
}
@property(nonatomic,assign) int countryId;//国家
@property(nonatomic,assign) int provinceId;//省份
@property(nonatomic,assign) int cityId;//城市
@property(nonatomic,assign) int areaId;//区域

@property(nonatomic,assign) int category;//类别
@property(nonatomic,assign) int maxCount;//最大成员数
@property(nonatomic,assign) NSInteger curCount;//当前成员数

@property(nonatomic,assign) NSTimeInterval createTime;//建立时间
@property(nonatomic,assign) NSTimeInterval updateTime;//修改时间
@property(nonatomic,assign) long updateUserId;//修改人

@property(nonatomic,strong) NSString* roomJid;//ID
@property(nonatomic,strong) NSString* roomId;//ID
@property(nonatomic,strong) NSString* name;//名字
@property(nonatomic,strong) NSString* desc;//说明
@property(nonatomic,strong) NSString* subject;//主题
@property(nonatomic,strong) NSString* note;//公告
@property(nonatomic,assign) long userId;//建立人
@property(nonatomic,strong) NSString* userNickName;//建立人昵称
@property (nonatomic, strong) NSString * lordRemarkName;  // 群主修改的昵称
@property(nonatomic,assign) BOOL showRead; //群内消息是否发送已读 回执 显示数量 0不显示 1要求显示
//@property (nonatomic,strong) NSString* call;//群音频会议号码
@property (nonatomic, assign) BOOL isLook; // 是否公开 0：公开  1：不公开
@property (nonatomic, assign) BOOL isNeedVerify; // 邀请进群是否需要验证，1：需要  0：不需要  默认不需要
@property (nonatomic, assign) BOOL showMember; // 显示群成员给普通用户，1：显示  0：不显示 默认显示
@property (nonatomic, assign) BOOL allowSendCard; // 允许私聊，1：允许  0：不允许  默认允许
@property (nonatomic, assign) BOOL allowHostUpdate; // 允许群主修改群属性  1：允许  0：不允许  默认允许
@property (nonatomic, assign) BOOL allowInviteFriend; // 允许普通成员邀请好友，1：允许  0：不允许  默认允许
@property (nonatomic, assign) BOOL allowUploadFile; // 允许群成员上传群共享文件，1：允许  0：不允许  默认允许
@property (nonatomic, assign) BOOL allowConference; // 允许成员召开会议，1：允许  0：不允许  默认允许
@property (nonatomic, assign) BOOL allowSpeakCourse; // 允许群成员发起讲课，1：允许  0：不允许  默认允许
@property (nonatomic, assign) BOOL isAttritionNotice; // 群组减员通知，1：开启通知  0：不通知  默认通知
@property (nonatomic, assign) long long talkTime;   // 全员禁言时间

@property (nonatomic,assign) BOOL   isOpenTopChat; // 是否置顶
@property (nonatomic,assign) BOOL offlineNoPushMsg;// 是否消息免打扰
@property (nonatomic,assign) BOOL isSecretGroup;// 是否为私密群组
@property (nonatomic, copy) NSString *chatKeyGroup; // 群组消息秘钥

@property (nonatomic,strong) NSString*   chatRecordTimeOut; // 消息保留天数

@property(nonatomic,assign) double longitude;
@property(nonatomic,assign) double latitude;
@property(nonatomic,strong) NSMutableArray* members;    //房间成员列表

-(void)getDataFromDict:(NSDictionary*)dict;
-(BOOL)isMember:(NSString*)theUserId;
-(NSString*)getNickNameInRoom;
-(memberData*)getMember:(NSString*)theUserId;
-(void)setNickNameForUser:(JXUserObject*)user;
-(void)setRole:(int)role withUserId:(NSString *)userId;
-(NSString *)roomDataToNSString;


/**
 群头像,多个成员头像拼接
 */
-(void)roomHeadImageToView:(UIImageView *)toView;
+(void)roomHeadImageRoomId:(NSString *)roomId toView:(UIImageView *)toView;

@end

@interface memberData : NSObject{
    
}
@property(nonatomic,assign) NSTimeInterval createTime;//建立时间
@property(nonatomic,assign) NSTimeInterval updateTime;//修改时间
@property(nonatomic,assign) NSTimeInterval active;//最后一次互动时间
@property(nonatomic,assign) NSTimeInterval talkTime;//禁言结束时间

@property (nonatomic, assign) int offlineNoPushMsg;// 是否消息免打扰 1=是，0=否

@property(nonatomic,assign) int sub;//是否屏bi

@property(nonatomic,assign) long userId;//成员id
@property(nonatomic,strong) NSString* userNickName;//成员昵称

@property (nonatomic, strong) NSString * roomId;
//@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSString * userName;
@property (nonatomic, strong) NSString * cardName;
@property (nonatomic, strong) NSString * lordRemarkName;  // 群主修改的昵称
@property (nonatomic, strong) NSNumber * role; //角色 1创建者,2管理员,3成员,4隐身人,5监控人
@property (nonatomic, strong) NSString * idStr;

-(void)getDataFromDict:(NSDictionary*)dict;

-(BOOL)checkTableCreatedInDb:(NSString *)queryRoomId;

-(BOOL)insert;

-(BOOL)remove;

-(BOOL)update;

//删除房间成员列表
-(BOOL)deleteRoomMemeber;

+(NSArray <memberData *>*)fetchAllMembers:(NSString *)queryRoomId;

/**
 返回排过序的群组成员列表

 @param queryRoomId 群组roomId
 @param sortByName 排序类型,YES只按cardName排序,NO先按role再按cardName排序
 @return 成员列表
 */
+(NSArray <memberData *>*)fetchAllMembers:(NSString *)queryRoomId sortByName:(BOOL)sortByName;
/**
 返回排过序的非隐身人和监控人的群组成员列表
 
 @param queryRoomId 群组roomId
 @param sortByName 排序类型,YES只按cardName排序,NO先按role再按cardName排序
 @return 成员列表
 */
+(NSArray <memberData *>*)fetchAllMembersAndHideMonitor:(NSString *)queryRoomId sortByName:(BOOL)sortByName;
-(memberData *)searchMemberByName:(NSString *)cardName;

// 查找群主
+ (memberData *)searchGroupOwner:(NSString *)roomId;
// 获取群昵称
- (memberData*)getCardNameById:(NSString*)aUserId;

// 更新身份
- (BOOL)updateRole;

// 更新群昵称
- (BOOL)updateCardName;

// 更新群昵称
- (BOOL)updateUserNickName;

+(NSMutableArray *)searchMemberByFilter:(NSString *)filter room:(NSString *)roomId;

//获取搜索的成员列表数据
+(memberData *)fetchMembersWithText:(NSString *)text withRoomId:(NSString *)roomId;
//查找一个群成员
-(memberData *)doFetchOneMember:(NSString*)sql roomId:(NSString *)roomId;
@end
