//
//  JXDidPushObj.m
//  shiku_im
//
//  Created by p on 2019/5/14.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXDidPushObj.h"
#import "WeiboViewControlle.h"
#import "JXNewFriendViewController.h"
#import "JXMsgViewController.h"
#import "JXTransferNoticeVC.h"
#import "JXChatViewController.h"
#import "JXRoomPool.h"
#import "JXFriendViewController.h"

@implementation JXDidPushObj

static JXDidPushObj *shared;

+(JXDidPushObj*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared=[[JXDidPushObj alloc]init];
    });
    return shared;
}

- (instancetype)init {
    if ([super init]) {
        
        [g_notify addObserver:self selector:@selector(onLoginChanged:) name:kXmppLoginNotifaction object:nil];//登录状态变化了
    }
    return self;
}
-(void)onLoginChanged:(NSNotification *)notifacation{
    
    switch ([JXXMPP sharedInstance].isLogined){
        case login_status_ing:{

        }
            break;
        case login_status_no:{

        }
            break;
        case login_status_yes:{
            [self didReceiveRemoteNotif];
        }
            
            break;
    }
}

// 点击推送
- (void)didReceiveRemoteNotif {
    
    NSString *jsonStr = [g_default objectForKey:kDidReceiveRemoteDic];
    
    SBJsonParser *json = [[SBJsonParser alloc] init];
    NSDictionary *dict = [json objectWithString:jsonStr];
    
    if (!dict) {
        return;
    }
    
    [g_default setObject:nil forKey:kDidReceiveRemoteDic];
    [g_default synchronize];
    
    
    NSString *url = [dict objectForKey:@"url"];
    if (url.length > 0) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];  
        
        return;
    }
    
    
    [g_navigation popToRootViewController];
    
    if ([[dict objectForKey:@"messageType"] intValue] == kWCMessageTypeWeiboPraise || [[dict objectForKey:@"messageType"] intValue] == kWCMessageTypeWeiboComment || [[dict objectForKey:@"messageType"] intValue] == kWCMessageTypeWeiboRemind) {
        
        [g_mainVC doSelected:2];
        
        WeiboViewControlle *weiboVC = [WeiboViewControlle alloc];
        weiboVC.user = g_server.myself;
        weiboVC = [weiboVC init];
        [g_navigation pushViewController:weiboVC animated:YES];
        
        return;
    }
    
    if ([[dict objectForKey:@"messageType"] intValue]/100==5) {
        
        [g_mainVC doSelected:1];
        // 清空角标
        JXMsgAndUserObject* newobj = [[JXMsgAndUserObject alloc]init];
        newobj.user = [[JXUserObject sharedInstance] getUserById:FRIEND_CENTER_USERID];
        newobj.message = [[JXMessageObject alloc] init];
        newobj.message.toUserId = FRIEND_CENTER_USERID;
        newobj.user.msgsNew = [NSNumber numberWithInt:0];
        [newobj.message updateNewMsgsTo0];
        
        NSArray *friends = [[JXFriendObject sharedInstance] fetchAllFriendsFromLocal];
        for (NSInteger i = 0; i < friends.count; i ++) {
            JXFriendObject *friend = friends[i];
            if ([friend.msgsNew integerValue] > 0) {
                [friend updateNewMsgUserId:friend.userId num:0];
                [friend updateNewFriendLastContent];
            }
        }
        
        [g_mainVC.friendVC showNewMsgCount:0];
        
        JXNewFriendViewController* vc = [[JXNewFriendViewController alloc]init];
        [g_navigation pushViewController:vc animated:YES];
        
        return;
    }
    
    
    [g_mainVC doSelected:0];
    
    
    //    NSDictionary *dict = notif.object;
    
    NSString *userId = [dict objectForKey:@"from"];
    
    if ([userId intValue] <= 0) {
        return;
    }

    if ([dict objectForKey:@"roomJid"]) {
        userId = [dict objectForKey:@"roomJid"];
    }
    
    [g_notify postNotificationName:kAVPlayerStopNotification object:nil];
    JXUserObject *user = [[JXUserObject sharedInstance] getUserById:userId];
    if (user) {
        [self jumpToChatViewVC:user];
    }else {
        if ([dict objectForKey:@"roomJid"]) {
            NSString *roomId = [dict objectForKey:@"roomId"];
            [g_server getRoom:roomId toView:self];
        }else {
            [g_server getUser:userId toView:self];
        }
    }
    
}

- (void)jumpToChatViewVC:(JXUserObject *)user {
    JXMessageObject *p=[[JXMessageObject alloc]init];
    //        [p fromRs:rs];
    p.content = user.content;
    p.type = user.type;
    p.timeSend = user.timeSend;
    p.fromUserId = user.userId;
    p.toUserId = MY_USER_ID;
    
    //    JXMsgAndUserObject *p=[array objectAtIndex:indexPath.row];
    if (![user.userId isEqualToString:FRIEND_CENTER_USERID]) {
        g_mainVC.msgVc.msgTotal -= [user.msgsNew intValue];
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber - [user.msgsNew intValue];
//    [g_server userChangeMsgNum:[UIApplication sharedApplication].applicationIconBadgeNumber toView:self];
    
    if([user.userId isEqualToString:FRIEND_CENTER_USERID]){
        JXNewFriendViewController* vc = [[JXNewFriendViewController alloc]init];
        //        [g_App.window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
        return;
    }
    if ([user.userId intValue] == [SHIKU_TRANSFER intValue]) {
        JXTransferNoticeVC *noticeVC = [[JXTransferNoticeVC alloc] init];
        [g_navigation pushViewController:noticeVC animated:YES];
        user.msgsNew = [NSNumber numberWithInt:0];
        [p updateNewMsgsTo0];
        [g_mainVC.msgVc getTotalNewMsgCount];
        return;
    }
    
    JXChatViewController *sendView=[JXChatViewController alloc];
    
    //    sendView.scrollLine = lineNum;
    sendView.title = user.remarkName.length > 0 ? user.remarkName : user.userNickname;
    if([user.roomFlag intValue] > 0 || user.roomId.length > 0){
        //        if(g_xmpp.isLogined != 1){
        //            // 掉线后点击title重连
        //            [g_xmpp showXmppOfflineAlert];
        //            return;
        //        }
        
        sendView.roomJid = user.userId;
        sendView.roomId   = user.roomId;
        sendView.groupStatus = user.groupStatus;
        if ([user.groupStatus intValue] == 0) {
            
            sendView.chatRoom  = [[JXXMPP sharedInstance].roomPool joinRoom:user.userId title:user.userNickname lastDate:nil isNew:NO];
        }
        
        if (user.roomFlag || user.roomId.length > 0) {
            NSDictionary * groupDict = [user toDictionary];
            roomData * roomdata = [[roomData alloc] init];
            [roomdata getDataFromDict:groupDict];
            sendView.room = roomdata;
            sendView.newMsgCount = [user.msgsNew intValue];
            
            
            user.isAtMe = [NSNumber numberWithInt:0];
            [user updateIsAtMe];
        }
        
    }
    //    sendView.rowIndex = indexPath.row;
    sendView.lastMsg = p;
    sendView.chatPerson = user;
    sendView = [sendView init];
    //    [g_App.window addSubview:sendView.view];
    [g_navigation pushViewController:sendView animated:YES];
    sendView.view.hidden = NO;
    
    user.msgsNew = [NSNumber numberWithInt:0];
    [p updateNewMsgsTo0];
    
    [g_mainVC.msgVc cancelBtnAction];
    
    [g_mainVC.msgVc getTotalNewMsgCount];
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    if([aDownload.action isEqualToString:act_roomGet]){
        JXUserObject* user = [[JXUserObject alloc]init];
        user.userNickname = [dict objectForKey:@"name"];
        user.userId = [dict objectForKey:@"jid"];
        user.userDescription = [dict objectForKey:@"desc"];
        user.roomId = [dict objectForKey:@"id"];
        user.showRead = [dict objectForKey:@"showRead"];
        user.showMember = [dict objectForKey:@"showMember"];
        user.allowSendCard = [dict objectForKey:@"allowSendCard"];
        user.chatRecordTimeOut = [NSString stringWithFormat:@"%@", [dict objectForKey:@"chatRecordTimeOut"]];
        user.offlineNoPushMsg = [(NSDictionary *)[dict objectForKey:@"member"] objectForKey:@"offlineNoPushMsg"];
        user.talkTime = [dict objectForKey:@"talkTime"];
        user.allowInviteFriend = [dict objectForKey:@"allowInviteFriend"];
        user.allowUploadFile = [dict objectForKey:@"allowUploadFile"];
        user.allowConference = [dict objectForKey:@"allowConference"];
        user.allowSpeakCourse = [dict objectForKey:@"allowSpeakCourse"];
        user.category = [dict objectForKey:@"category"];
        user.createUserId = [dict objectForKey:@"userId"];
        user.timeCreate = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"createTime"] longLongValue]];
        user.isNeedVerify = [dict objectForKey:@"isNeedVerify"];
        user.roomFlag= [NSNumber numberWithInt:1];
        user.companyId= [NSNumber numberWithInt:0];
        user.status= [NSNumber numberWithInt:2];
        user.offlineNoPushMsg = [NSNumber numberWithInt:0];
        user.isAtMe = [NSNumber numberWithInt:0];
        if(!user.timeCreate)
            user.timeCreate = [NSDate date];
        if(!user.timeSend)
            user.timeSend   = [NSDate date];
        [self jumpToChatViewVC:user];
    }
    
    if( [aDownload.action isEqualToString:act_UserGet] ){
        JXUserObject* user = [[JXUserObject alloc]init];
        [user getDataFromDict:dict];
        [self jumpToChatViewVC:user];
    }
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{

    return hide_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时

    return hide_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    
}

@end
