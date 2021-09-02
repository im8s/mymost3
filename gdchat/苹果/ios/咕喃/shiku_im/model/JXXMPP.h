//
//  JXXMPPManager.h
//  WeChat
//
//  Created by Reese on 13-8-10.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h> 
#import "JXRoomObject.h"

#define login_status_yes 1  //登录成功
#define login_status_ing 0  //登录中
#define login_status_no  -1 //登录失败


// 消息密令码
enum kWCCommandType {
    
    kWCCommandTypeUnknow = 0,   //无效
    kWCCommandTypeHandShakeReq = 1, // 握手请求
    kWCCommandTypeHandShakeResp = 2,    // 握手响应
    kWCCommandTypeAuthReq = 5,  // 登录消息请求
    kWCCommandTypeAuthResp = 6, // 登录消息结果
    kWCCommandTypeClose = 7, // 关闭请求
    kWCCommandTypeChat = 10,  // 聊天请求
    kWCCommandTypeReceipt = 11, // 消息回执
    kWCCommandTypeRecordReq = 12,   // 拉取漫游消息记录
    kWCCommandTypeRecordResp = 13,  // 拉取漫游消息结果
    kWCCommandTypePullMessageReq = 14,  // 批量拉取群组离线消息
    kWCCommandTypePullMessageResp = 15, // 批量拉取群组离线消息结果
    kWCCommandTypeError = -1,   // 失败错误
    kWCCommandTypeLoginConflict = -3,   // 登录被挤下线
    kWCCommandTypeJoinGroupReq = 20,    // 加入群组
    kWCCommandTypeExitGroupReq = 21,    // 退出群组
    kWCCommandTypeRoomRequestResult = 22,    // 群组请求结果
    kWCCommandTypePingReq = 99, // 心跳消息
    kWCCommandTypeTypeSuccess = 100,    // 成功请求
    
};

@class JXMessageObject;
@class JXRoomPool;
@class XMPPMessage,XMPPRoster,XMPPRosterCoreDataStorage,FMDatabase,emojiViewController;

@interface JXXMPP : NSObject <UIApplicationDelegate>

{
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    
    int pingTimeoutCount;
    
   	NSString *password;
	
	BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	
	BOOL isXmppConnected;
    FMDatabase* _db;
    NSString* _userIdOld;
}

- (NSManagedObjectContext *)managedObjectContext_roster;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (assign, nonatomic) int isLogined;
@property (strong, nonatomic) JXRoomPool* roomPool;
@property (strong, nonatomic) NSMutableDictionary * poolSend;
@property (strong, nonatomic) NSMutableArray * poolSendRead;
@property (strong, nonatomic) NSMutableSet * blackList;
@property (strong, nonatomic) NSMutableArray * chatingUserIds;
//@property (assign, nonatomic) BOOL isEncryptAll;
@property (assign, nonatomic) int  newMsgAfterLogin;//刚连线时，收到的新消息总数量（刚连线时，此值为0,在一定时间内收完所有新消息后，才发通知更新界面，避免重复刷新UI；之后有一条消息，就累加1)
@property (assign, nonatomic) NSTimeInterval lastNewMsgTime;//最近一条新消息的时间

@property (nonatomic, assign) BOOL isReconnect;
@property (nonatomic, strong) NSTimer *reconnectTimer;

// 是否弹登录状态提示
@property (nonatomic, assign) BOOL isShowLoginChange;

// 是否关闭流
@property (nonatomic, assign) BOOL isCloseStream;

// XMPP密码是否错误
@property (nonatomic, assign) BOOL isPasswordError;

// 是否是消息记录迁移，如果在迁移就暂时不跳转到登录页面
@property (nonatomic, assign) BOOL isChatLogMove;

@property (nonatomic, strong) dispatch_source_t msgTimer;
@property (nonatomic, assign) float lastMsgTime;

/*
原理就是2秒之内没有新消息到达，则认为收取完毕，一次性刷新
连线收消息时，批量收消息，刷新界面只刷一次：
1.声明2个变量：新消息数量A（刚连线时，此值为0;收完所有消息并刷新后再有新消息，此值累加)；最近一条消息的收到时间B
2.收到消息时，A=0,则B=Now，并在2秒后执行C函数；A>0,则A++,并刷新单条消息
3.C判断Now-B>2,则A=1,并刷新全部消息；
*/


//- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (BOOL)connect;
- (void)disconnect;
//- (FMDatabase*)getDatabase;
- (FMDatabase*)openUserDb:(NSString*)userId;




+(JXXMPP*)sharedInstance;


#pragma mark -------配置XML流-----------

- (void)setupStream;
- (void)teardownStream;

// 关闭流
-(void)applicationWillTerminate;

#pragma mark ----------收发信息------------
- (void)goOnline;
- (void)goOffline;

- (void)login;
- (void)logout;

- (void)sendMessageInvite:(JXMessageObject *)msg;
- (void)sendMessage:(JXMessageObject*)msg roomName:(NSString*)roomName;
#pragma  mark ------------多点登录转发发消息------------
- (void)relaySendMessage:(JXMessageObject*)msg relayUserId:(NSString *)relayUserId roomName:(NSString*)roomName;

-(void)notifyNewMsg;

#pragma mark ---------文件传输-----------
//-(void)sendFile:(NSData*)aData toJID:(XMPPJID*)aJID;

// XMPP没连上时弹框询问是否重连
- (void) showXmppOfflineAlert;

-(BOOL)deleteMessageWithUserId:(NSString *)userId messageId:(NSString *)msgId;//删除一条聊天记录
-(JXMessageObject*)findMessageWithUserId:(NSString *)userId messageId:(NSString *)msgId;//搜索一条记录



#pragma  mark ------------新版socket------------
// 加入群组
- (void)addRoomWithJid:(NSString *)jid delegate:(JXRoomObject *)delegate;
// 退出群组
- (void)exitRoomWithJid:(NSString *)jid delegate:(JXRoomObject *)delegate;

// 获取群离线消息
- (void)pullBatchGroupMessageReqWithJidListArray:(NSMutableArray *)listArr;


@end
