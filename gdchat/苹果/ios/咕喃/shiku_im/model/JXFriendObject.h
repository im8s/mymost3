//
//  JXFriendObject.h
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JXUserBaseObj.h"

#define XMPP_TYPE_SAYHELLO 500  //打招呼
#define XMPP_TYPE_PASS 501 //验证通过
#define XMPP_TYPE_FEEDBACK 502 //回话
#define XMPP_TYPE_NEWSEE 503 //新关注
#define XMPP_TYPE_DELSEE 504 //删除关注
#define XMPP_TYPE_DELALL 505 //彻底删除
#define XMPP_TYPE_RECOMMEND 506 //新推荐
#define XMPP_TYPE_BLACK 507 //黑名单
#define XMPP_TYPE_FRIEND 508 //无验证加好友
#define XMPP_TYPE_NOBLACK 509 //取消黑名单
#define XMPP_TYPE_CONTACTFRIEND 510 // 对方通过手机联系人添加我，直接成为好友
#define XMPP_TYPE_CONTACTREGISTER 511 // 我之前上传给服务端的联系人表内有人注册了，更新手机联系人
#define XMPP_TYPE_SEVERDEL 512  //  服务器删除用户
#define XMPP_TYPE_SEVERBLACK 513    // 服务器拉黑
#define XMPP_TYPE_SEVERNOBLACK 514    // 服务器取消拉黑
#define XMPP_TYPE_SEVERDELFRIEND 515    // 服务器删除好友


@interface JXFriendObject : JXUserBaseObj{//新朋友表
    
}
+(JXFriendObject*)sharedInstance;

-(NSMutableArray*)fetchAllFriendsFromLocal;
-(void)notifyNewRequest;
-(void)doSaveUser;
-(void)doDelUser;
-(NSString*)doMsgForNewUser;
-(void)doWriteDb;
-(void)onSendRequest;
-(void)onReceiveRequest;
-(void)loadFromMessageObj:(JXMessageObject*)msg;
-(NSString*)getLastContent:(NSString *)userId;

-(JXFriendObject*)getFriendById:(NSString*)userId;

// 更新新消息
- (BOOL)updateNewMsgUserId:(NSString *)userId num:(int)num;
// 更新新朋友列表最后一条消息
- (void)updateNewFriendLastContent;

@end
