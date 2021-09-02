//
//  JXServer+Live.h
//  shiku_im
//
//  Created by 1 on 17/6/14.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXServer.h"


#define act_liveRoomList @"liveRoom/list"//获取直播间列表
#define act_liveRoomCreate @"liveRoom/create"//创建直播间
#define act_liveRoomGet @"liveRoom/get"//直播间详情
#define act_liveRoomMemberList @"liveRoom/memberList"//直播间成员列表
#define act_liveRoomEnter @"liveRoom/enterInto"//加入直播间
#define act_liveRoomQuit @"liveRoom/quit"//退出直播间
#define act_liveRoomStart @"liveRoom/start"//开启直播/关闭直播
#define act_liveRoomGetMember @"liveRoom/get/member"//获取身份信息
#define act_liveRoomGetLiveRoom @"/liveRoom/getLiveRoom"    //获取直播间

#define act_liveRoomSetManager @"liveRoom/setmanage"//设置管理员
#define act_liveRoomUpdate @"liveRoom/update"//修改
#define act_liveRoomDelete @"liveRoom/delete"//删除直播间
#define act_liveRoomShutUP @"liveRoom/shutup"//禁言/取消禁言
#define act_liveRoomKick @"liveRoom/kick"//踢人

#define act_liveRoomBarrage @"liveRoom/barrage"//发送弹幕
#define act_liveRoomGiftList @"liveRoom/giftlist"//获取礼物列表
#define act_liveRoomGive @"liveRoom/give"//发送礼物
#define act_liveRoomPraise @"liveRoom/praise"//发送爱心
#define act_liveRoomAnchorGiftList @"liveRoom/getList"//主播获取送礼物详情

@interface JXServer (Live)


/**
 直播列表
 @param status status=1为获取正在直播列表
 */
-(void)listLiveRoom:(int)page status:(NSInteger)status toView:(id)toView;
-(void)createLiveRoom:(NSString*)userId nickName:(NSString*)nickName roomName:(NSString*)roomName notice:(NSString*)notice jid:(NSString *)jid toView:(id)toView;
-(void)getLiveRoom:(NSString*)liveRoomId toView:(id)toView;
-(void)liveRoomMembers:(NSString*)liveRoomId toView:(id)toView;
-(void)enterLiveRoom:(NSString*)liveRoomId toView:(id)toView;
-(void)quitLiveRoom:(NSString*)liveRoomId toView:(id)toView;

-(void)updateLiveRoom:(NSString*)liveRoomId nickName:(NSString*)nickName name:(NSString*)name notice:(NSString*)notice toView:(id)toView;
-(void)deleteLiveRoom:(NSString*)liveRoomId toView:(id)toView;

/**
 获取身份信息
 */
-(void)getLiveRoomMember:(NSString*)userId liveRoomId:(NSString*)liveRoomId toView:(id)toView;
/**
 设置管理员
 */
-(void)liveRoomSetManager:(NSString*)userId liveRoomId:(NSString*)liveRoomId type:(int)type toView:(id)toView;
/**
 禁言/取消禁言
 @param type 类型(1为禁言，0为取消禁言)
 */
-(void)liveRoomShutUPMember:(NSString*)userId liveRoomId:(NSString*)liveRoomId state:(NSInteger)state talkTime:(long)talkTime toView:(id)toView;
/**
 踢人
 */
-(void)liveRoomKickMember:(NSString*)userId liveRoomId:(NSString*)liveRoomId toView:(id)toView;
/**
 发送爱心
 */
-(void)liveRoomPraise:(NSString*)liveRoomId toView:(id)toView;

/**
 发送弹幕
 */
-(void)liveRoomBarrage:(NSString *)text roomId:(NSString *)roomId toView:(id)toView;
/**
 获取礼物列表
 */
-(void)liveRoomGiftList:(NSString *)roomId toView:(id)toView;
/**
 发送礼物
 */
-(void)liveRoomGiveGift:(NSString *)roomId anchorUserId:(NSString *)anchorUserId giftId:(NSString *)giftId price:(NSString *)price count:(NSInteger)count toView:(id)toView;

/**
 主播获取送礼物详情
 */
-(void)liveRoomGiveList:(NSString *)userId toView:(id)toView;

/**
 开启直播/关闭直播
 @param status (1为开始直播,0为关闭直播)
 */
-(void)liveRoomStatus:(NSInteger)status roomId:(NSString *)roomId toView:(id)toView;

// 获取直播间
-(void)liveRoomGetLiveRoom:(NSInteger)userId toView:(id)toView;

@end
