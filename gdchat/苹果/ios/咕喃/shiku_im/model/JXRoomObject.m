//
//  JXRoomObject.m
//  BaseProject
//
//  Created by Huan Cho on 13-8-3.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "JXRoomObject.h"
//#import "Statics.h"
//#import "KKMessageCell.h"
#import "JXMessageObject.h"
#import "JXXMPP.h"
#import "JXChatViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "JXImageView.h"
//#import "JXCell.h"
#import "roomData.h"
#import "JXRoomPool.h"

#define padding 20

@implementation JXRoomObject

@synthesize roomName,roomTitle,storage,nickName,fullJid,isConnected,delegate,roomJid,roomId;

#pragma mark - life circle

-(id)init{
    self = [super init];
    _isNew = NO;
    isConnected = NO;
    delegate = nil;
    return self;
}

- (void)dealloc {
//    NSLog(@"JXRoomObject.dealloc");
    self.fullJid = nil;
    self.roomName = nil;
    self.roomTitle = nil;
    self.storage = nil;
    self.delegate = nil;
    self.roomJid = nil;
    self.roomId = nil;
    
//    [_xmppRoom deactivate];
//    [_xmppRoom release];
//    [super dealloc];
}


//成员加入群组
-(void)joinRoom:(bool)isNew{
//    NSXMLElement *p = [NSXMLElement elementWithName:@"history"];
//    int n = 0;
//    if(g_server.lastOfflineTime>0&&!isNew){
//        NSArray *arr = [[JXMessageObject sharedInstance] fetchMessageListWithUser:self.roomJid byAllNum:0 pageCount:20 startTime:[NSDate dateWithTimeIntervalSince1970:0]];
//        // 最后一条消息
//        JXMessageObject *lastMsg = nil;
//        for (NSInteger i = 0; i < arr.count; i ++) {
//            JXMessageObject *firstMsg = arr[i];
//            if ([firstMsg.type integerValue] != kWCMessageTypeRemind) {
//                lastMsg = firstMsg;
//                break;
//            }
//        }
//        if (lastMsg.timeSend) {
//
//            n = [[NSDate date] timeIntervalSince1970]-[lastMsg.timeSend timeIntervalSince1970] + 30;
//        }else {
//
//            n = [[NSDate date] timeIntervalSince1970]-g_server.lastOfflineTime;
//        }
//    }
//    [p addAttributeWithName:@"seconds" stringValue:[NSString stringWithFormat:@"%d",n]];

    _isNew = NO;
    self.fullJid = [NSString stringWithFormat:@"%@",self.roomJid];
//    NSLog(@"xmpp -- fullJid-%@, n-%d",self.fullJid,n);
//    _xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:storage jid:[XMPPJID jidWithString:self.fullJid] dispatchQueue:dispatch_get_global_queue(1, 0)];
//    [_xmppRoom activate:[JXXMPP sharedInstance].stream];
//    [_xmppRoom joinRoomUsingNickname:nickName history:p];
//    [_xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [g_xmpp addRoomWithJid:self.fullJid delegate:self];
    
//    p = nil;
}

//群主创建一个群组
-(void)createRoom{
    /*
    NSXMLElement *p = [NSXMLElement elementWithName:@"history"];
    int n = 0;
    if(g_server.lastOfflineTime>0)
        n = [[NSDate date] timeIntervalSince1970]-g_server.lastOfflineTime;
    [p addAttributeWithName:@"seconds" stringValue:[NSString stringWithFormat:@"%d",n]];
    */

    _isNew = YES;
    self.fullJid = [NSString stringWithFormat:@"%@",self.roomJid];
//    _xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:storage jid:[XMPPJID jidWithString:self.fullJid] dispatchQueue:dispatch_get_main_queue()];
//    [_xmppRoom activate:[JXXMPP sharedInstance].stream];
//    [_xmppRoom joinRoomUsingNickname:nickName history:nil];
//    [_xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
//
//    [self configNewRoom];
    
    [g_xmpp addRoomWithJid:self.fullJid delegate:self];
    
    
//    isConnected = YES;
//    if(delegate != nil && [delegate respondsToSelector:@selector(xmppRoomDidCreate:)])
//        [delegate xmppRoomDidCreate:_xmppRoom];
    
}

//- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(DDXMLElement *)configForm
//{
////    NSLog(@"config : %@", configForm);
//    NSXMLElement *newConfig = [configForm copy];
//    NSArray* fields = [newConfig elementsForName:@"field"];
//    for (NSXMLElement *field in fields) {
//        NSString *var = [field attributeStringValueForName:@"var"];
//        if ([var isEqualToString:@"muc#roomconfig_persistentroom"]) {
//            [field removeChildAtIndex:0];
//            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
//        }
//    }
//    [sender configureRoomUsingOptions:newConfig];
//}

#pragma mark - XMPPRoom delegate
//创建结果
-(void)xmppRoomDidCreate{
//    NSLog(@"xmppRoomDidCreate");
    
    isConnected = YES;
//    [_xmppRoom changeRoomSubject:self.roomTitle];
    
    if(delegate != nil && [delegate respondsToSelector:@selector(xmppRoomDidCreate)])
        [delegate xmppRoomDidCreate];
}

//是否已经加入房间
-(void)xmppRoomDidJoin{
    if (isConnected) {
        return;
    }
    
    isConnected = YES;
//    NSLog(@"xmppRoomDidJoin");
    //    [_xmppRoom chageNickname:@"fuck"];
    //    [_xmppRoom changeRoomSubject:@"聊天室主题名"];
    //    [_xmppRoom changeToMember:self.roomJid nickName:@"tjx"];

//    if(_isNew){
//        [self configNewRoom];
//    }
//    else{
//        [_xmppRoom configureRoomUsingOptions:nil];
//        [_xmppRoom fetchConfigurationForm];
//    }
    
    if(delegate != nil && [delegate respondsToSelector:@selector(xmppRoomDidJoin)])
        [delegate xmppRoomDidJoin];
}

//是否已经离开
-(void)xmppRoomDidLeave{
    isConnected = NO;
//    NSLog(@"xmppRoomDidLeave");
    
    if(delegate != nil && [delegate respondsToSelector:@selector(xmppRoomDidLeave)])
        [delegate xmppRoomDidLeave];
}



//是否已经离开
-(void)xmppRoomDidDestroy{
    isConnected = NO;
//    NSLog(@"xmppRoomDidDestroy");
    
    if(delegate != nil && [delegate respondsToSelector:@selector(xmppRoomDidDestroy)])
        [delegate xmppRoomDidDestroy];
}


//收到群聊消息
//-(void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID{
//    return;
//}

//房间人员加入
//- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
////    NSLog(@"occupantDidJoin");
////    NSString *jid = occupantJID.user;
////    NSString *domain = occupantJID.domain;
////    NSString *resource = occupantJID.resource;
//    NSString *presenceType = [presence type];
//    NSString *userId = [sender myRoomJID].user;
//    NSString *presenceFromUser = [[presence from] user];
//
////    NSLog(@"occupantDidJoin----jid=%@,domain=%@,resource=%@,当前用户:%@ ,出席用户:%@,presenceType:%@",jid,domain,resource,userId,presenceFromUser,presenceType);
//
//    if (![presenceFromUser isEqualToString:userId]) {
//        //对收到的用户的在线状态的判断在线状态
//
//        //在线用户
//        if ([presenceType isEqualToString:@"available"]) {
////            NSString *buddy = [NSString stringWithFormat:@"%@@%@", presenceFromUser, g_config.XMPPDomain];
//            //            [chatDelegate newBuddyOnline:buddy];//用户列表委托
//        }
//
//        //用户下线
//        else if ([presenceType isEqualToString:@"unavailable"]) {
//            //            [chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, OpenFireHostName]];//用户列表委托
//        }
//    }
//}

//房间人员离开
//-(void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
///*
//    NSString *jid = occupantJID.user;
//    NSString *domain = occupantJID.domain;
//    NSString *resource = occupantJID.resource;
//    NSString *presenceType = [presence type];
//    NSString *userId = [sender myRoomJID].user;
//    NSString *presenceFromUser = [[presence from] user];
//    NSLog(@"occupantDidLeave----jid=%@,domain=%@,resource=%@,当前用户:%@ ,出席用户:%@,presenceType:%@",jid,domain,resource,userId,presenceFromUser,presenceType);*/
//}

//房间人员加入
//-(void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
///*
//    NSString *jid = occupantJID.user;
//    NSString *domain = occupantJID.domain;
//    NSString *resource = occupantJID.resource;
//    NSString *presenceType = [presence type];
//    NSString *userId = [sender myRoomJID].user;
//    NSString *presenceFromUser = [[presence from] user];
//    NSLog(@"occupantDidUpdate----jid=%@,domain=%@,resource=%@,当前用户:%@ ,出席用户:%@,presenceType:%@",jid,domain,resource,userId,presenceFromUser,presenceType);*/
//}

//- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items{
//    NSLog(@"didFetchMembersList");
//}
//
//- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items{
//    NSLog(@"didFetchModeratorsList");
//}

//- (void)noSendHistory
//{
////    <presence
////    from='hag66@shakespeare.lit/pda'
////    to='darkcave@chat.shakespeare.lit/thirdwitch'>
////    <x xmlns='http://jabber.org/protocol/muc'>
////    <history since='1970-01-01T00:00:00Z'/>
////    </x>
////    </presence>
//
//    XMPPPresence* y = [[XMPPPresence alloc] initWithType:@"" to:[XMPPJID jidWithString:self.fullJid]];
//    NSString *myJID = MY_USER_ID;
//    [y addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@",myJID,g_config.XMPPDomain]];
//    [y removeAttributeForName:@"type"];
//
//    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc"];
//    NSXMLElement *p = [NSXMLElement elementWithName:@"history"];
//    [p addAttributeWithName:@"maxchars" stringValue:@"0"];
//
//    NSDate* d = [NSDate dateWithTimeIntervalSince1970:g_server.lastOfflineTime];
//    NSString* s = [TimeUtil formatDate:d format:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
////    [p addAttributeWithName:@"since" stringValue:s];
//    d = nil;
//    s = nil;
//
//    [x addChild:p];
//    [y addChild:x];
//    [[JXXMPP sharedInstance].stream sendElement:y];
////    [y release];
//}

//-(void)configNewRoom{
//    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
//    NSXMLElement *p;
//    p = [NSXMLElement elementWithName:@"field" ];
//    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];//永久房间
//    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
//    [x addChild:p];
//
//    p = [NSXMLElement elementWithName:@"field" ];
//    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_maxusers"];//最大用户
//    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1000"]];
//    [x addChild:p];
//
//    p = [NSXMLElement elementWithName:@"field" ];
//    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_changesubject"];//允许改变主题
//    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
//    [x addChild:p];
//
//    p = [NSXMLElement elementWithName:@"field" ];
//    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_publicroom"];//公共房间
//    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
//    [x addChild:p];
//
//    p = [NSXMLElement elementWithName:@"field" ];
//    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_allowinvites"];//允许邀请
//    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
//    [x addChild:p];
//
//    /*
//    p = [NSXMLElement elementWithName:@"field" ];
//    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomname"];//房间名称
//    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:self.roomTitle]];
//    [x addChild:p];
//
//    p = [NSXMLElement elementWithName:@"field" ];
//    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_enablelogging"];//允许登录对话
//    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]];
//    [x addChild:p];
//    */
//
//    [_xmppRoom configureRoomUsingOptions:x];
//}

//-(void)reconnect{
//    if(!isConnected){
//        NSXMLElement *p = [NSXMLElement elementWithName:@"history"];
//        int n = 0;
//        if(g_server.lastOfflineTime>0){
//            n = [[NSDate date] timeIntervalSince1970]-g_server.lastOfflineTime;
//
//        }
//        [p addAttributeWithName:@"seconds" stringValue:[NSString stringWithFormat:@"%d",n]];
//        [_xmppRoom joinRoomUsingNickname:nickName history:p];
//    }
//
//}

//-(void)reconnect:(bool)isNew{
//    int n = 0;
//    if(!isNew&&!isConnected){
//
//        NSXMLElement *p = [NSXMLElement elementWithName:@"history"];
//
//        if(g_server.lastOfflineTime>0){
//            n = [[NSDate date] timeIntervalSince1970]-g_server.lastOfflineTime;
//
//        }
//        [p addAttributeWithName:@"seconds" stringValue:[NSString stringWithFormat:@"%d",n]];
//        [_xmppRoom joinRoomUsingNickname:nickName history:p];
//    }
//}


//-(void)removeUser:(memberData*)user{
//    NSXMLElement* query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/muc#admin"];
//    NSXMLElement* sub = [NSXMLElement elementWithName:@"item" ];
//    [sub addAttributeWithName:@"nick" stringValue:[NSString stringWithFormat:@"%ld",user.userId]];
//    [sub addAttributeWithName:@"role" stringValue:@"none"];
//    [sub addChild:[NSXMLElement elementWithName:@"reason" stringValue:@"Avaunt, you cullion!"]];
//    [query addChild:sub];
//
//    NSString* to = [NSString stringWithFormat:@"%@@muc.%@",roomJid,g_config.XMPPDomain];
//    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:[XMPPJID jidWithString:to] elementID:nil child:query];
//    NSString* from = [NSString stringWithFormat:@"%@@%@",MY_USER_ID,g_config.XMPPDomain];
//    [iq addAttributeWithName:@"from" stringValue:from];
//    [iq addAttributeWithName:@"id" stringValue:@"kick1"];
//
//    [[JXXMPP sharedInstance].stream sendElement:iq];
//}

-(void)insertRoom{//无用
    JXUserObject* user = [[JXUserObject alloc]init];
    user.userNickname = self.roomName;
    user.userId = self.roomJid;
    user.roomId = self.roomId;
    user.userDescription = self.roomTitle;
    [user insertRoom];
//    [user release];
}

-(void)leave{
    if(isConnected) {
        
        [g_xmpp exitRoomWithJid:self.fullJid delegate:self];
    }
}


// 群组请求结果
- (void)roomRequestResultWithStatus:(int)status isExit:(BOOL)isExit roomJid:(NSString *)roomJid {
    if (isExit) {
        
        if (status == 1) {
            
            isConnected = NO;
            if(delegate != nil && [delegate respondsToSelector:@selector(xmppRoomDidLeave)])
                [delegate xmppRoomDidLeave];
            
        }else {
            
        }
        
    }else {
        if (status == 1) {
            
            isConnected = YES;
            JXUserObject *room = [[JXUserObject sharedInstance] getUserById:roomJid];
            
            if ([room.groupStatus intValue] == 0) {
                [g_xmpp.roomPool setRoomPool:room.userId title:room.userNickname];
            }
            if(delegate != nil && [delegate respondsToSelector:@selector(xmppRoomDidJoin)])
                [delegate xmppRoomDidJoin];
        }else {
            
        }
    }
}

@end
