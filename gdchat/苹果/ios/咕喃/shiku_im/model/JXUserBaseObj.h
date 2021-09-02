//
//  JXUserBaseObj.h
//  shiku_im
//
//  Created by flyeagleTang on 14-5-31.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUSER_ID @"userId"
#define kROOM_ID @"roomId"
#define kUSER_NICKNAME @"userNickname"
#define kUSER_REMARKNAME @"remarkName"
#define kUSER_DESCRIBE @"describe"
#define kUSER_ROLE @"role"
#define kUSER_CREATEUSER_ID @"createUserId"
#define kUSER_DESCRIPTION @"userDescription"
#define kUSER_USERHEAD @"userHead"
#define kUSER_ROOM_FLAG @"roomFlag"
#define kUSER_ROOM_CATEGORY @"category"
#define kUSER_NEW_MSGS @"newMsgs"
#define kUSER_TIME_CREATE @"timeCreate"
#define kUSER_TIME_SEND @"timeSend"
#define kUSER_DownloadTime @"downloadTime"
#define kUSER_CHATRECORDTIMEOUT @"chatRecordTimeOut"
#define kUSER_TALKTIME @"talkTime"
#define kUSER_STATUS @"status"
#define kUSER_USERTYPE @"userType"
#define kUSER_TYPE @"type"
#define kUSER_COMPANY_ID @"companyId"
#define kUSER_CONTENT @"content"
#define kUSER_isMySend @"isMySend"
#define kUSER_lastInput @"lastInput"
#define kUSER_CALL @"call"
#define kUSER_showRead @"showRead"
#define kUSER_showMember @"showMember"
#define kUSER_allowSendCard @"allowSendCard"
#define kUSER_allowInviteFriend @"allowInviteFriend"
#define kUSER_allowUploadFile @"allowUploadFile"
#define kUSER_allowConference @"allowConference"
#define kUSER_allowSpeakCourse @"allowSpeakCourse"
#define kUSER_isNeedVerify @"isNeedVerify"
#define kUSER_TOPTIME @"topTime"
#define kUSER_encryptType @"encryptType"
#define kUSER_GROUPSTATUS @"groupStatus"
#define kUSER_isOnLine @"isOnLine"
#define kUSER_isOpenReadDel @"isOpenReadDel"
#define kUSER_offlineNoPushMsg  @"offlineNoPushMsg"
#define kUSER_isAtMe @"isAtMe"
#define kUSER_isSendRecipt @"isSendRecipt"
#define kUSER_isDevice @"isDevice"
#define kUSER_joinTime  @"joinTime"
#define kUSER_publicKeyDH  @"publicKeyDH"
#define kUSER_publicKeyRSARoom  @"publicKeyRSARoom"
#define kUSER_chatKeyGroup  @"chatKeyGroup"
#define kUSER_isSecretGroup @"isSecretGroup"
#define kUSER_isLostChatKeyGroup @"isLostChatKeyGroup"

@interface JXUserBaseObj : NSObject{
    NSString* _tableName;
}

#define friend_status_hisAddFriend -4// 他添加我为好友
#define friend_status_addFriend -3// 我添加他为好友
#define friend_status_hisBlack  -2//他拉黑我
#define friend_status_black  -1//我拉黑他
#define friend_status_none   0 //陌生人
#define friend_status_see    1 //单方关注
#define friend_status_friend 2 //互为好友
#define friend_status_white  7 //白名单
#define friend_status_system 8 //系统号
#define friend_status_hide   9 //非显示系统号

@property (nonatomic,strong) NSString* userId;//房间时，等于roomJid
@property (nonatomic,strong) NSString* roomId;//接口的roomId
@property (nonatomic,strong) NSString* userNickname;
@property (nonatomic,strong) NSString* remarkName;  // 备注
@property (nonatomic,strong) NSString *describe; // 描述
@property (nonatomic,strong) NSString* createUserId;  // 创建者userId
@property (nonatomic,strong) NSArray* role; // 身份  1=游客（用于后台浏览数据）；2=公众号 ；3=机器账号，由系统自动生成；4=客服账号;5=管理员；6=超级管理员；7=财务；
@property (nonatomic,strong) NSString* userDescription;
@property (nonatomic,strong) NSString* userHead;
@property (nonatomic,strong) NSNumber* type;
@property (nonatomic,strong) NSString* content;
@property (nonatomic,strong) NSDate*   timeSend;
@property (nonatomic,strong) NSDate*   downloadTime;
@property (nonatomic,strong) NSString*   chatRecordTimeOut; // 消息保留天数
@property (nonatomic,strong) NSString *groupChatSyncTimeLen;    // 群聊聊天记录 同步时长
@property (nonatomic,strong) NSNumber*   talkTime; // 群组全员禁言时间
@property (nonatomic,strong) NSDate*   timeCreate;
@property (nonatomic,strong) NSNumber* roomFlag;//0：朋友；1:永久房间；2:临时房间
@property (nonatomic,strong) NSNumber* msgsNew; // 新消息数量
@property (nonatomic,strong) NSNumber* status;//-1://黑名单；0：陌生人；1:单方关注；2:互为好友；8:系统号；9:非显示系统号  10:本账号的其他端
@property (nonatomic,strong) NSNumber* userType;// 2 :公众号
@property (nonatomic,strong) NSNumber* companyId;
@property (nonatomic,strong) NSNumber* isMySend;
@property (nonatomic,strong) NSNumber* showRead;//显示已读模式
@property (nonatomic,strong) NSNumber* showMember;//显示群成员列表
@property (nonatomic,strong) NSNumber* allowSendCard;//允许发送名片
@property (nonatomic,strong) NSNumber* maxCount;// 最大群人数

@property (nonatomic, strong) NSNumber* allowInviteFriend; // 允许普通成员邀请好友，1：允许  0：不允许  默认允许
@property (nonatomic, strong) NSNumber* allowUploadFile; // 允许群成员上传群共享文件，1：允许  0：不允许  默认允许
@property (nonatomic, strong) NSNumber* allowConference; // 允许成员召开会议，1：允许  0：不允许  默认允许
@property (nonatomic, strong) NSNumber* allowSpeakCourse; // 允许群成员发起讲课，1：允许  0：不允许  默认允许
@property (nonatomic, strong) NSNumber* isNeedVerify; // 群组邀请确认

@property (nonatomic,strong) NSDate*   topTime; // 置顶时间

@property (nonatomic, strong) NSNumber *encryptType;    // 加密方式 0：明文传输 1：3DES加密 2：AES加密 3：端到端DH加密

@property (nonatomic, strong) NSString *lastInput;  //记录输入框中最后输入的字符串，下次进入自动填入

@property (nonatomic, strong) NSNumber *groupStatus;   //0:正常  1：被踢出  2：房间被删除

@property (nonatomic, strong) NSNumber *isupdate;  // 是否同步好友

@property (nonatomic,strong) NSNumber* isOpenReadDel;// 是否开启阅后即焚


@property (nonatomic,strong) NSNumber* offlineNoPushMsg;// 是否消息免打扰

@property (nonatomic,strong) NSNumber* isAtMe;// 群组里面是否有@我的消息

// isOnLine isSendRecipt isDevice 只用于多点登录，本账号的其他设备user
@property (nonatomic, strong) NSNumber *isOnLine;
@property (nonatomic, strong) NSNumber *isSendRecipt;
@property (nonatomic, strong) NSNumber *isDevice;

@property (nonatomic, strong) NSNumber *category;   // 群组类型 510:手机联系人群组
@property (nonatomic,strong) NSDate*   joinTime; // 群组分页获取群成员，最后一个成员加入时间

@property (nonatomic, copy) NSString *publicKeyDH;  //好友对称秘钥DH
@property (nonatomic, copy) NSString *publicKeyRSARoom;  //群组RSA公钥
@property (nonatomic, copy) NSString *chatKeyGroup; // 群组消息秘钥
@property (nonatomic, strong) NSNumber *isSecretGroup;  // 是否是私密群组
@property (nonatomic, strong) NSNumber *isLostChatKeyGroup; // 群组秘钥是否丢失

//数据库增删改查
-(BOOL)insert;
-(BOOL)delete;
-(BOOL)update;
-(BOOL)reset;

+(JXUserBaseObj*)sharedInstance;


//将对象转换为字典
-(BOOL)haveTheUser;
-(NSDictionary*)toDictionary;
-(void)userFromDataset:(JXUserBaseObj*)obj rs:(FMResultSet*)rs;
-(void)userFromDictionary:(JXUserBaseObj*)obj dict:(NSDictionary*)aDic;
-(BOOL)checkTableCreatedInDb:(FMDatabase *)db;
-(NSString*)doSendMsg:(int)aType content:(NSString*)aContent;
-(void)loadFromObject:(JXUserBaseObj*)user;

-(void)notifyDelFriend;
-(void)notifyNewFriend;

@end
