//
//  JXServer+Live.m
//  shiku_im
//
//  Created by 1 on 17/6/14.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXServer+Live.h"

@implementation JXServer (Live)


-(void)listLiveRoom:(int)page status:(NSInteger)status toView:(id)toView{
    JXConnection* p = [self addTask:act_liveRoomList param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:[NSNumber numberWithInt:jx_page_size] forKey:@"pageSize"];
    [p setPostValue:[NSNumber numberWithInt:page] forKey:@"pageIndex"];
    if (status)
        [p setPostValue:[NSNumber numberWithInteger:status] forKey:@"status"];
    [p go];
}

-(void)createLiveRoom:(NSString*)userId nickName:(NSString*)nickName roomName:(NSString*)roomName notice:(NSString*)notice jid:(NSString *)jid toView:(id)toView{
    JXConnection* p = [self addTask:act_liveRoomCreate param:nil toView:toView];
    [p setPostValue:roomName forKey:@"name"];
    [p setPostValue:nickName forKey:@"nickName"];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:notice forKey:@"notice"];
    [p setPostValue:jid forKey:@"jid"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

-(void)getLiveRoom:(NSString*)liveRoomId toView:(id)toView{
    JXConnection* p = [self addTask:act_liveRoomGet param:nil toView:toView];
    [p setPostValue:liveRoomId forKey:@"roomId"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

-(void)updateLiveRoom:(NSString*)liveRoomId nickName:(NSString*)nickName name:(NSString*)name notice:(NSString*)notice toView:(id)toView{
    JXConnection* p = [self addTask:act_liveRoomUpdate param:nil toView:toView];
    [p setPostValue:name forKey:@"name"];
    [p setPostValue:nickName forKey:@"nickName"];
    [p setPostValue:liveRoomId forKey:@"roomId"];
    //    [p setPostValue:url forKey:@"url"];
    [p setPostValue:notice forKey:@"notice"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

-(void)deleteLiveRoom:(NSString*)liveRoomId toView:(id)toView{
    JXConnection* p = [self addTask:act_liveRoomDelete param:nil toView:toView];
    [p setPostValue:liveRoomId forKey:@"roomId"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

-(void)liveRoomMembers:(NSString*)liveRoomId toView:(id)toView{
    JXConnection* p = [self addTask:act_liveRoomMemberList param:nil toView:toView];
    [p setPostValue:liveRoomId forKey:@"roomId"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

-(void)enterLiveRoom:(NSString*)liveRoomId toView:(id)toView{
    JXConnection* p = [self addTask:act_liveRoomEnter param:nil toView:toView];
    [p setPostValue:liveRoomId forKey:@"roomId"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

-(void)quitLiveRoom:(NSString*)liveRoomId toView:(id)toView{
    JXConnection* p = [self addTask:act_liveRoomQuit param:nil toView:toView];
    [p setPostValue:liveRoomId forKey:@"roomId"];
    [p setPostValue:g_myself.userId forKey:@"userId"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}


-(void)getLiveRoomMember:(NSString*)userId liveRoomId:(NSString*)liveRoomId toView:(id)toView{
    JXConnection* p = [self addTask:act_liveRoomGetMember param:nil toView:toView];
    [p setPostValue:liveRoomId forKey:@"roomId"];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

-(void)liveRoomSetManager:(NSString*)userId liveRoomId:(NSString*)liveRoomId type:(int)type toView:(id)toView{
    JXConnection* p = [self addTask:act_liveRoomSetManager param:nil toView:toView];
    [p setPostValue:liveRoomId forKey:@"roomId"];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:[NSNumber numberWithInt:type] forKey:@"type"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

-(void)liveRoomShutUPMember:(NSString*)userId liveRoomId:(NSString*)liveRoomId state:(NSInteger)state talkTime:(long)talkTime toView:(id)toView{
    JXConnection* p = [self addTask:act_liveRoomShutUP param:nil toView:toView];
    [p setPostValue:liveRoomId forKey:@"roomId"];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:[NSNumber numberWithInteger:state] forKey:@"state"];
    [p setPostValue:[NSNumber numberWithLong:talkTime] forKey:@"talkTime"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

-(void)liveRoomKickMember:(NSString*)userId liveRoomId:(NSString*)liveRoomId toView:(id)toView{
    JXConnection* p = [self addTask:act_liveRoomKick param:nil toView:toView];
    [p setPostValue:liveRoomId forKey:@"roomId"];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

-(void)liveRoomPraise:(NSString*)liveRoomId toView:(id)toView{
    JXConnection* p = [self addTask:act_liveRoomPraise param:nil toView:toView];
    [p setPostValue:liveRoomId forKey:@"roomId"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}




/**
 发送弹幕
 */
-(void)liveRoomBarrage:(NSString *)text roomId:(NSString *)roomId toView:(id)toView{
    JXConnection* p = [self addTask:act_liveRoomBarrage param:nil toView:toView];
    [p setPostValue:text forKey:@"text"];
    [p setPostValue:g_myself.userId forKey:@"userId"];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}
/**
 获取礼物列表
 */
-(void)liveRoomGiftList:(NSString *)roomId toView:(id)toView{
    JXConnection* p = [self addTask:act_liveRoomGiftList param:nil toView:toView];
//    pageIndex
    [p setPostValue:[NSNumber numberWithInt:50] forKey:@"pageSize"];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}
/**
 发送礼物
 */
-(void)liveRoomGiveGift:(NSString *)roomId anchorUserId:(NSString *)anchorUserId giftId:(NSString *)giftId price:(NSString *)price count:(NSInteger)count toView:(id)toView{
    JXConnection* p = [self addTask:act_liveRoomGive param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:g_myself.userId forKey:@"userId"];
    [p setPostValue:anchorUserId forKey:@"toUserId"];
    [p setPostValue:giftId forKey:@"giftId"];
    [p setPostValue:price forKey:@"price"];
    [p setPostValue:[NSNumber numberWithInteger:count] forKey:@"count"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}
/**
 主播获取送礼物详情
 */
-(void)liveRoomGiveList:(NSString *)userId toView:(id)toView{
    JXConnection *p = [self addTask:act_liveRoomAnchorGiftList param:nil toView:toView];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

/**
 开始直播/关闭直播
 */
-(void)liveRoomStatus:(NSInteger)status roomId:(NSString *)roomId toView:(id)toView{
    JXConnection* p = [self addTask:act_liveRoomStart param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:[NSNumber numberWithInteger:status] forKey:@"status"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

// 获取直播间
-(void)liveRoomGetLiveRoom:(NSInteger)userId toView:(id)toView {
    JXConnection* p = [self addTask:act_liveRoomGetLiveRoom param:nil toView:toView];
    [p setPostValue:[NSNumber numberWithInteger:userId] forKey:@"userId"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

@end
