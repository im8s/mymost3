//
//  JXMessageObject.h
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//  ?

#import <Foundation/Foundation.h>

#import "Message.pbobjc.h"

extern NSString* current_chat_userId;
extern NSString* current_meeting_no;

#define kMESSAGE_FROMID @"fromId"
#define kMESSAGE_TOID @"toId"
#define kMESSAGE_TYPE @"type"
#define kMESSAGE_FROM @"fromUserId"
#define kMESSAGE_FROM_NAME @"fromUserName"
#define kMESSAGE_TO @"toUserId"
#define kMESSAGE_TO_NAME @"toUserName"
#define kMESSAGE_CONTENT @"content"
#define kMESSAGE_DATE @"timeSend"
#define kMESSAGE_ID @"messageId"
#define kMESSAGE_No @"messageNo"
#define kMESSAGE_TIMESEND @"timeSend"
#define kMESSAGE_DELETETIME @"deleteTime"
#define kMESSAGE_TIMERECEIVE @"timeReceive"
#define kMESSAGE_FILEDATA @"fileData"
#define kMESSAGE_FILENAME @"fileName"
#define kMESSAGE_LOCATION_X @"location_x"
#define kMESSAGE_LOCATION_Y @"location_y"
#define kMESSAGE_TIMELEN @"timeLen"
#define kMESSAGE_FILETIME @"fileTime"
#define kMESSAGE_ISSEND @"isSend"
#define kMESSAGE_ISREAD @"isRead"
#define kMESSAGE_isUpload @"isUpload"
#define kMESSAGE_FILESIZE @"fileSize"
#define kMESSAGE_OBJECTID @"objectId"
#define kMESSAGE_isReadDel @"isReadDel"
#define kMESSAGE_readTime @"readTime"
#define kMESSAGE_readPersons @"readPersons"
#define kMESSAGE_chatMsgHeight  @"chatMsgHeight"
#define kMESSAGE_isShowTime @"isShowTime"
#define kMESSAGE_signature @"signature"
#define kMESSAGE_isVerifySignatureFailed    @"isVerifySignatureFailed"
#define kMESSAGE_generalMark @"generalMark"

#define kMESSAGE_imWidth @"imageWidth"
#define KMESSAGE_imHeight @"imageHeight"

//#define kMESSAGE_isMySend @"isMySend"
#define kMESSAGE_isReceive @"isReceive"
//#define kMESSAGE_ @""
#define kMESSAGE_isEncrypt @"isEncrypt"


#define CALL_CENTER_INT  10000//系统消息
#define FRIEND_CENTER_INT  10001//新朋友
#define BLOG_CENTER_INT  10002//商务圈

#define CALL_CENTER_USERID  @"10000"//系统消息
#define FRIEND_CENTER_USERID  @"10001"//新朋友
#define BLOG_CENTER_USERID  @"10002"//商务圈
#define SHIKU_TRANSFER  @"1100"//支付公众号

//多点登录多端数据同步(objectId)
#define SYNC_LOGIN_PASSWORD @"sync_login_password"  //修改密码
#define SYNC_PAY_PASSWORD @"sync_pay_password"  //首次设置支付密码
#define SYNC_PRIVATE_SETTINGS @"sync_private_settings"  //隐私设置
#define SYNC_LABEL @"sync_label"  //标签的增删改查
#define SYNC_YOP_OPEN @"sync_yop_open_account"  //多点登录下，开户通知

// 多端登录userId
#define PC_USERID [NSString stringWithFormat:@"%@_pc",g_myself.userId]
#define ANDROID_USERID [NSString stringWithFormat:@"%@_android",g_myself.userId]
#define MAC_USERID [NSString stringWithFormat:@"%@_mac",g_myself.userId]
#define WEB_USERID [NSString stringWithFormat:@"%@_web",g_myself.userId]
#define IOS_USERID [NSString stringWithFormat:@"%@_ios",g_myself.userId]
// 多点登陆其他设备
#define IS_OTHER_DEVICE(obj) [@[ANDROID_USERID, PC_USERID, MAC_USERID, WEB_USERID] containsObject:obj]
// 所有设备
#define IS_HAVE_DEVICE(obj) [@[ANDROID_USERID, PC_USERID, MAC_USERID, WEB_USERID,IOS_USERID] containsObject:obj]

#define transfer_status_yes 1 //传输成功
#define transfer_status_ing 0 //传输中
#define transfer_status_no  -2 //传输失败

// 消息类型
enum kWCMessageType {
//    kWCMessageTypeLoading = -1, //加载
    kWCMessageTypeNone = 0,//不显示的无用类型
    kWCMessageTypeText = 1,//文本
    kWCMessageTypeImage = 2,//图片
    kWCMessageTypeVoice = 3,//语音
    kWCMessageTypeLocation=4, //位置
    kWCMessageTypeGif=5,//动画
    kWCMessageTypeVideo=6,//视频
    kWCMessageTypeAudio=7,//音频
    kWCMessageTypeCard=8,//名片
    kWCMessageTypeFile=9, //文件
    kWCMessageTypeRemind=10, //提醒
    
    kWCMessageTypeIsRead = 26,//已读标志
    kWCMessageTypeRedPacket = 28, //发红包
    kWCMessageTypeTransfer = 29, //转账
    
    kWCMessageTypeManualPayRecharge = 78,   // 扫码手动充值
    kWCMessageTypeManualPayWithdraw = 79,   // 扫码手动提现
    
    kWCMessageTypeSystemImage1=80,  //单条图文消息
    kWCMessageTypeSystemImage2=81,  //多条图文消息
    kWCMessageTypeLink = 82, //链接
    kWCMessageTypeRedPacketReceive = 83, //领红包
    kWCMessageTypeShake = 84, // 戳一戳
    kWCMessageTypeMergeRelay = 85,   // 合并转发
    kWCMessageTypeRedPacketReturn = 86, // 红包退回
    kWCMessageTypeShare = 87, // 分享进鲸鱼的type
    kWCMessageTypeTransferReceive = 88, //转账已被领取
    kWCMessageTypeTransferBack = 89, //转账已被退回
    kWCMessageTypePaymentOut = 90, //付款码 已付款通知
    kWCMessageTypeReceiptOut = 92, //收款码 已付款通知
    kWCMessageTypePaymentGet = 91, //付款码 已到账通知
    kWCMessageTypeReceiptGet = 93, //收款码 已到账通知
    kWCMessageTypeReply=94, //回复
    kWCMessageTypeDelMsgScreenshots=95, // 阅后即焚情况下的截屏
    kWCMessageTypeDelMsgTwoSides=96, // 删除自己和对方的聊天记录
    kWCMessageTypeOpenPaySuccess = 97,  // 第三方应用调取IM支付成功通知
    
    kWCMessageTypeCloudRedPacket = 98, //银行卡红包支付完成(不存储，不处理)
    kWCMessageTypeCloudTransfer = 99, //银行卡转账支付完成(不存储，不处理)

    kWCMessageTypeEnterpriseJob=11, //企业发布的职位信息
    kWCMessageTypePersonJob=31, //个人发布的职位信息
    kWCMessageTypeResume=12, //简历信息
    kWCMessageTypePhoneAsk=13, //问交换手机
    kWCMessageTypePhoneAnswer=14, //答交换手机
    kWCMessageTypeResumeAsk=16, //问发送简历
    kWCMessageTypeResumeAnswer=17, //答发送简历
    kWCMessageTypeExamSend=19, //发起笔试题（暂无用）
    kWCMessageTypeExamAccept=20, //接受笔试题（暂无用）
    kWCMessageTypeExamEnd=21, //做完笔试题，显示结果（暂无用）

    kWCMessageTypeAudioChatAsk = 100, //询问是否准备好语音通话
    kWCMessageTypeAudioChatReady = 101, //已准备好语音通话
    kWCMessageTypeAudioChatAccept = 102, //接受语音通话
    kWCMessageTypeAudioChatCancel = 103, //拒绝语音通话 或 取消拔号
    kWCMessageTypeAudioChatEnd = 104, //结束语音通话

    kWCMessageTypeVideoChatAsk = 110, //询问是否准备好视频通话
    kWCMessageTypeVideoChatReady = 111, //已准备好视频通话
    kWCMessageTypeVideoChatAccept = 112, //接受视频通话
    kWCMessageTypeVideoChatCancel = 113, //拒绝视频通话 或 取消拔号
    kWCMessageTypeVideoChatEnd = 114, //结束视频通话
    kWCMessageTypeAVPing = 123, // 音视频ping包
    kWCMessageTypeAVBusy = 124, // 音视频忙线中

    kWCMessageTypeVideoMeetingInvite = 115, //邀请加入视频会议
    kWCMessageTypeVideoMeetingJoin = 116, //加入视频会议
    kWCMessageTypeVideoMeetingQuit = 117, //退出视频会议
    kWCMessageTypeVideoMeetingKick = 118, //踢出视频会议

    kWCMessageTypeAudioMeetingInvite = 120, //邀请加入语音会议
    kWCMessageTypeAudioMeetingJoin = 121, //加入语音会议
    kWCMessageTypeAudioMeetingQuit = 122, //退出语音会议
//    kWCMessageTypeAudioMeetingKick = 123, //踢出语音会议
//    kWCMessageTypeAudioMeetingSetSpeaker = 124, //轮麦
//    kWCMessageTypeAudioMeetingAllSpeaker = 125, //取消轮麦
    
    kWCMessageTypeTalkInvite = 130, // 邀请进行对讲机
    kWCMessageTypeTalkJoin = 131, // 加入对讲机
    kWCMessageTypeTalkQuit = 132, // 退出对讲机
    kWCMessageTypeAudioMeetingSetSpeaker = 133, // 轮麦
    kWCMessageTypeAudioMeetingAllSpeaker = 134, // 取消轮麦
    kWCMessageTypeTalkOnline = 135, // 广播在线
    kWCMessageTypeTalkOut = 136, // 踢出对讲机
    
    kWCMessageTypeScreenShareAsk = 140,  //发起屏幕共享
    kWCMessageTypeScreenShareAccept = 142,  //接受屏幕共享
    kWCMessageTypeScreenShareCancel = 143,  //取消屏幕共享
    kWCMessageTypeScreenShareEnd = 144,  //结束屏幕共享
    kWCMessageTypeScreenShareMeetingInvite = 145,  //屏幕共享会议邀请

    kWCMessageTypeMultipleLogin = 200,  // 多点登录验证在线
    kWCMessageTypeRelay = 201, // 正在输入
    kWCMessageTypeWithdraw = 202, // 消息撤回
    
    kWCMessageTypeWeiboPraise = 301, // 朋友圈点赞
    kWCMessageTypeWeiboComment = 302, // 朋友圈评论
    kWCMessageTypeWeiboCancelPraise = 303, // 朋友圈取消点赞
    kWCMessageTypeWeiboRemind = 304, // 朋友圈提醒谁看
    kWCMessageTypeWeiboNew = 305,   //朋友圈更新提醒
    
    kWCMessageTypeGroupFileUpload = 401, //上传群文件
    kWCMessageTypeGroupFileDelete = 402, //删除群文件
    kWCMessageTypeGroupFileDownload = 403, //下载群文件

    kWCMessageTypeUpadtePassword = 800, //修改密码/首次设置支付密码/隐私设置/标签的增删改查
    //对好友进行备注、消息免打扰、阅后即焚、置顶聊天
    kWCMessageTypeUpadteUserInfo = 801, //编辑自己的基本资料/用户
    kWCMessageTypeUpadteGroup = 802, //群组
    
    kWCMessageTypeUpdateFriendPublicKey = 803, // 好友更换公钥通知
    kWCMessageTypeChatKeyGroupRequest = 804, // 通信秘钥丢失，向其他群成员请求秘钥（群聊）
    kWCMessageTypeChatKeyGroupSend = 805, // 向丢失秘钥的群成员发送秘钥（单聊,群聊各发一条）
    kWCMessageTypeUpdateChatKeyGroup = 806, // 群组重置通信秘钥
    KWCMessageTypeAuthLogin = 810, //授权登录
    KWCMessageTypeLockUser = 811,   // 锁定用户
    
};

// 聊天类型
enum kWCChatType {
    
    kWCChatTypeUnknow = 0,   //无效
    kWCChatTypeChat = 1, // 单聊
    kWCChatTypeGroupChat = 2,    // 群聊
    kWCChatTypeAll = 3,  // 广播
    kWCChatTypeAuth = 5, // 授权登录
    kWCChatTypePing = 9, // 心跳消息
    kWCChatTypeResult = 10,  // 返回结果
    kWCChatTypeReceipt = 11, // 消息回执
    
};


@class FMResultSet;
@class JXImageView;

typedef enum {
    UpdateLastSendType_Dec = -1,    // 新消息数量-1
    UpdateLastSendType_None = 0,    // 新消息数量不变
    UpdateLastSendType_Add = 1,     // 新消息数量+1
} UpdateLastSendType;

@interface JXMessageObject : NSObject<NSCopying>
//以下字段用于通讯,message里：
@property (nonatomic,strong) NSString*  messageId;//消息标识号，字符串,UUID <message>里
@property (nonatomic,strong) NSString*  fromId;//发送ID <message>里
@property (nonatomic,strong) NSString*  toId;//目标ID <message>里
//以下字段用于通讯，Body里：
@property (nonatomic,strong) NSNumber*  type;//消息类型 <body>里
@property (nonatomic,strong) NSString*  fromUserId;//源
@property (nonatomic,strong) NSString*  fromUserName;//源
@property (nonatomic,strong) NSString*  toUserId;//目标
@property (nonatomic,strong) NSString*  toUserName;//目标
@property (nonatomic,strong) NSString*  content;//内容,或URL,或祝福语
@property (nonatomic,strong) NSString*  fileName;//文件名，发送方的本地文件名
@property (nonatomic,strong) NSString*  objectId;//对象ID，一般用来存roomJid
@property (nonatomic,strong) NSNumber*  fileSize;//文件尺寸,或红包领取状态
@property (nonatomic,strong) NSNumber*  timeLen;//录音时长，秒
@property (nonatomic,strong) NSNumber*  location_x;//位置经度，或图片宽，或视频宽
@property (nonatomic,strong) NSNumber*  location_y;//位置纬度，或图片高，或视频高
@property (nonatomic,strong) NSNumber*  isReadDel;//是否阅后即焚,0或1
//是否加密信息,0：明文传输 1：3DES加密 2：AES加密 3：端到端加密
@property (nonatomic,strong) NSNumber*  isEncrypt;
@property (nonatomic,strong) NSDate*    timeSend;//发送的时间，发送前赋当前机器时间
@property (nonatomic, strong) NSDate *deleteTime;  // 消息过期时间

//以下字段并不参与通讯，只是数据库变量
@property (nonatomic,strong) NSNumber*  messageNo;//序列号，数值型，保存在数据库，并不通讯
@property (nonatomic,strong) NSNumber*  isSend;//是否已送达
@property (nonatomic,strong) NSNumber*  isRead;//是否已被对方阅读
@property (nonatomic,strong) NSNumber*  isReceive;//是否下载成功
@property (nonatomic,strong) NSNumber*  isUpload;//是否上传完成
@property (nonatomic,strong) NSDate*    timeReceive;//收到回执的时间，接收后赋当前机器时间
@property (nonatomic,strong) NSData*    fileData;//文件内容，字节内容
@property (nonatomic,strong) NSNumber*  readPersons;  // 已读人数
@property (nonatomic,strong) NSDate*    readTime; // 已读时间
@property (nonatomic, strong) NSString *chatMsgHeight;  // 聊天消息行高
@property (nonatomic, assign) BOOL isNotUpdateHeight;   // 是否不更新行高
@property (nonatomic, copy) NSString *signature;    // 消息验签字段
@property (nonatomic,strong) NSNumber *isVerifySignatureFailed;   // 表明是否为验签失败的消息
@property (nonatomic,strong) NSNumber *generalMark;   // 本地通用标志位


//以下只是内存变量，计算赋值，不传输也不保存:
//@property (nonatomic,strong) NSString*  roomJid;//房间JId
@property (nonatomic,getter=getIsMySend) BOOL       isMySend;//是否是自己发送
@property (nonatomic,getter=getIsGroup)  BOOL       isGroup;//是否群聊，发送前赋值
@property (nonatomic,assign) BOOL       isShowTime;//是否展示时间
@property (nonatomic,assign) BOOL       isDelay;//是否离线消息，单聊有意义，群聊好像都返回YES
@property (nonatomic,assign) NSNumber*  imageWidth;//聊天图片的长度
@property (nonatomic,assign) NSNumber*  imageHeight;//聊天图片的高度
@property (nonatomic,strong) NSMutableDictionary*  dictionary;
@property (nonatomic,assign) float      progress;
@property (nonatomic,assign) int        index;
@property (nonatomic,assign) int        sendCount;//未收到回执时，重发次数
@property (nonatomic,assign) BOOL       updateLastContent;//更新Friend表的最后聊天内容
@property (nonatomic,assign) BOOL       showRead;//显示已读人数
@property (nonatomic,copy) NSString *other; // 其他的一些群设置

@property (nonatomic, assign) int changeMySend;    // 0:不改变  1: 强行改变isMySend为NO 2:强行改变isMySend为YES
@property (nonatomic, assign) BOOL isRepeat;    // 是否是重复推送的消息
@property (nonatomic, assign) BOOL isMultipleRelay; // 是否是多点登录转发的消息
@property (nonatomic, assign) BOOL isShowWait;

@property (nonatomic, assign) int chatType; // 聊天类型

@property (nonatomic, assign) BOOL isShowRemind;    // 单聊需显示的控制消息
@property (nonatomic,strong) NSNumber*  remindType; // 控制消息类型

@property (nonatomic, assign) BOOL isGroupSend; //是否群发消息
@property (nonatomic, assign) BOOL isLastGroupSend; //是否最后一条群发消息

@property (nonatomic, assign) BOOL isNoEncrypt; // 不需要加密

+(JXMessageObject*)sharedInstance;
+(void)msgWithFriendStatus:(NSString*)userId status:(int)status;
-(CGPoint)getLocation;

- (JXMessageObject *)getMsgWithMsgId:(NSString *)msgId;
- (JXMessageObject *)getMsgWithMsgId:(NSString *)msgId toUserId:(NSString *)toUserId;

-(NSDictionary*)toDictionary;//将对象转换为字典
-(void)fromDictionary:(NSDictionary*)p;//从字典转换为对象
// 单聊
- (void)fromXmlDict:(NSDictionary *)xmlDict;
// 群聊
-(void)fromGroupXmlDict:(NSDictionary *)xmlDict;

//数据库增删改查
-(BOOL)insert:(NSString*)room;
-(BOOL)update;
-(BOOL)delete;
-(BOOL)deleteAll;
-(BOOL)deleteWithFromUser:(NSString*)userId roomId:(NSString*)roomId;

-(BOOL)doInsertMsg:(NSString*)dbName tableName:(NSString*)tableName;
//-(BOOL)deleteMessageWithUserId:(NSString *)userId messageId:(NSString *)msgId;// 删除一条聊天记录
//-(BOOL)findMessageWithUserId:(NSString *)userId messageId:(NSString *)msgId;
-(BOOL)updateNewMsgsTo0;

-(NSMutableArray*)fetchImageMessageListWithUser:(NSString *)userId;
//获取某联系人聊天记录
-(NSMutableArray *)fetchMessageListWithUser:(NSString *)userId byAllNum:(NSInteger)num pageCount:(int)pageCount startTime:(NSDate *)startTime;
//获取某联系人所有聊天记录
-(NSMutableArray*)fetchAllMessageListWithUser:(NSString *)userId;
//获取某联系人某个type的所有聊天记录
-(NSMutableArray*)fetchAllMessageListWithUser:(NSString *)userId withTypes:(NSArray *)types;
// 获取某个时间段聊天记录
- (NSMutableArray *) fetchMessageListUserId:(NSString *)userId StartTime:(NSDate *)startTime endTime:(NSDate *)endTime;
// 搜索聊天记录
-(NSArray <JXMessageObject *>*)fetchSearchMessageWithUserId:(NSString *)userId String:(NSString *)str;
// 获取所有对方发的阅后即焚消息
-(NSArray <JXMessageObject *>*)fetchDelMessageWithUserId:(NSString *)userId;

// 获取验签成功的最后一条聊天记录
- (JXMessageObject *)fetchNotVerifySignatureFailedLastMsgWithUserId:(NSString *)userId;

// 根据content获取最新行
- (int) getLineNumWithUserId:(NSString *)userId;
//获取最近联系人
-(NSMutableArray *)fetchRecentChatByPage:(int)pageIndex;
-(NSMutableArray *)fetchRecentChat;
-(NSMutableArray *)getSystemChatByPage:(int)pageIndex types:(NSString*)types;

-(void)fromRs:(FMResultSet*)rs;

//-(void)downloadFile:(JXImageView*)iv;//下载文件
-(BOOL)updateIsReceive:(int)n;//更新已下载标志
//-(BOOL)updateIsRead:(BOOL)b;//单聊更新已读标志，弃用
-(BOOL)updateIsSend:(int)n;//更新已发送标志
-(BOOL)updateIsRead:(NSDate *)time msgId:(NSString*)msgId;//更新已读时间
-(void)updateIsReadWithContent;//更新已读类型消息的Content即MsgId指向的消息的已读
-(BOOL)updateReadPersons:(NSString*)msgId;//更新群聊已读人数
-(BOOL)updateIsUpload:(BOOL)b;
//-(BOOL)updateFileName:(NSString*)s;//更新URL
-(void)setMsgId;

-(NSString*)getTypeName;
-(NSString*)getLastContent;

-(void)notifyNewMsg;//通知有新消息
-(void)notifyReceipt;//通知有回执
-(void)notifyTimeout;//通知发送失败
-(void)notifyMyLastSend;//通知UI更新显示最新发送的那一条

-(int)getMaxWaitTime;//获得发送等待时长
/*
 更新最近发送的content及新数量
 newMsgType = 1 : 数量 + 1
 newMsgType = 2 : 数量 = 0
 newMsgType = 3 : 数量 不变
 */
-(void)updateLastSend:(UpdateLastSendType)newMsgType;
// 更新新消息数量
-(void)updateNewMsgCount:(int)count withUserId:(NSString *)userId;
-(NSString*)getTableName;//获取本userId所操作的表名
//-(void)doReceiveFriendRequest;

-(void)doGroupFileMsg;
-(BOOL)doNewRemindMsg;
-(void)copy:(JXMessageObject*)p;

-(NSString*)getContentValue:(NSString*)key;
-(NSString*)getContentValue:(NSString*)key subKey:(NSString*)subKey;
-(NSString*)getContentValue:(NSString*)key index:(int)i;

-(void)sendAlreadyReadMsg;//发送“已读”消息

-(BOOL)queryIsRead;
-(NSTimeInterval)queryReadTime;

// 获取已读列表
- (NSMutableArray *)fetchReadList;

-(BOOL)isVisible;//消息是否会显示在屏幕
-(BOOL)isRoomControlMsg;//房间控制消息
-(BOOL)isAudioMeetingMsg;//语音会议消息
-(BOOL)isPinbaMsg;//是否聘吧相关消息
-(BOOL)isAddFriendMsg;
-(BOOL)isAtMe;
-(BOOL)isNoEncryptMsg;  // 不加密消息

-(void)getHistory:(NSArray*)array userId:(NSString*)userId isGroup:(BOOL)isGroup;//获取聊天历史记录

// 更新群昵称
- (BOOL)updateFromUserName;

- (BOOL)haveTheMessage;

- (BOOL)updateFileName;
// 更新邀请群好友验证文件名，用于判断是否已确认验证
- (BOOL)updateNeedVerifyFileName;
// 更新消息行高
- (BOOL)updateChatMsgHeight;
// 更新所有消息行高
- (BOOL)updateAllChatMsgHeight;
// 更新是否显示时间
- (BOOL)updateIsShowTime;

// 删除过期聊天记录
- (BOOL)deleteTimeOutMsg:(NSString *)userId chatRecordTimeOut:(NSString *)ChatRecordTimeOut;

// Message.pbobjc 转 JXMessageObject
+ (JXMessageObject *)getMsgObjWithPbobjc:(ChatMessage *)message;

// JXMessageObject 转 Message.pbobjc
- (ChatMessage *)getPbobjcObjWithMsg:(JXMessageObject *)msg;

// 根据objectId获取消息
- (NSMutableArray *)getMsgWithObjectId:(NSString *)objectId;

- (BOOL)updateFileSize;

// 更新公用标志位
- (BOOL)updateGeneralMark;

// 更新验签失败标志位
- (BOOL)updateVerifySignatureFailed;

// 获取验签失败的消息
- (NSMutableArray *) fetchVerifySignatureFailedMessageListUserId:(NSString *)userId;

// 控制消息lastContent
- (BOOL)setRemindMsg:(JXMessageObject *)msg;
@end
