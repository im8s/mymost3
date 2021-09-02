#import "JXMeetingObject.h"
// #import "MessagesViewController.h"
//#import "ChatViewController.h"
//#import "ContactsViewController.h"
#import "AppDelegate.h"
#import "versionManage.h"
#import "acceptCallViewController.h"
#import "JXAVCallViewController.h"
#import "JXTalkModel.h"
#ifdef Live_Version
#import "JXLiveJidManager.h"
#endif
#undef TAG
#define kTAG @"AppDelegate///: "
#define TAG kTAG
#define kTabBarIndex_Favorites	0
#define kTabBarIndex_Recents	1
#define kTabBarIndex_Contacts	2
#define kTabBarIndex_Numpad		3
#define kTabBarIndex_Messages	4

#define kNotifKey									@"key"
#define kNotifKey_IncomingCall						@"icall"
#define kNotifKey_IncomingMsg						@"imsg"
#define kNotifIncomingCall_SessionId				@"sid"

#define kNetworkAlertMsgThreedGNotEnabled  Localized(@"JXMeetingObject_3GNetWork")
#define kNetworkAlertMsgNotReachable				Localized(@"JXMeetingObject_NoNetWork")
#define kNewMessageAlertText						Localized(@"JXMeetingObject_NewMessage")
#define kAlertMsgButtonOkText						Localized(@"JX_Confirm")
#define kAlertMsgButtonCancelText					Localized(@"JX_Cencal")


static UIBackgroundTaskIdentifier sBackgroundTask = UIBackgroundTaskInvalid;
static dispatch_block_t sExpirationHandler = nil;

@interface JXMeetingObject()

@property (nonatomic, assign) BOOL isInCall;
@property (nonatomic, copy) NSString *meetUrl;

@end

@implementation JXMeetingObject

-(id)init{
    self = [super init];
    _count = 0;
    _lastConnectTime = 0;
    _showConnResult = NO;
    _checkCount = 0;
    
    [g_notify  addObserver:self selector:@selector(newMsgCome:) name:kXMPPNewMsgNotifaction object:nil];
    [g_notify addObserver:self selector:@selector(callAnswerNotification:) name:kCallAnswerNotification object:nil];
    return self;
}

-(void)dealloc{
    [g_notify removeObserver:self];
}
-(void)callAnswerNotification:(NSNotification *)notifacation{
    self.hasAnswer = YES;
}

-(void)onOtherEvent:(NSNotification*)notification {
    NSLog(@"onOtherEvent:  %@",notification.name);
}

-(NSString*)getVideoSize{
    NSString* s = [[NSUserDefaults standardUserDefaults] objectForKey:@"chatVideoSize"];
    if(s==nil)
        s = @"1";
    switch ([s intValue]) {
        case 0:
            s = @"11";
            break;
        case 1:
            s = @"9";
            break;
        case 2:
            s = @"5";
            break;
        case 3:
            s = @"2";
            break;
        default:
            s = @"5";
            break;
    }
    return s;
}

-(void)startMeeting{
    
    multitaskingSupported = [[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)] && [[UIDevice currentDevice] isMultitaskingSupported];
//    sBackgroundTask = UIBackgroundTaskInvalid;
//    UIApplication* app = [UIApplication sharedApplication];
//    //sExpirationHandler = ^{//老代码
//    sBackgroundTask = [app beginBackgroundTaskWithExpirationHandler:^{
//        //NSLog(@"Background task completed");
//        [app endBackgroundTask:sBackgroundTask];
//        sBackgroundTask = UIBackgroundTaskInvalid;
//    }];
    
    if(multitaskingSupported){
        //		NgnNSLog(TAG, @"Multitasking IS supported");
    }
    
    // Set media parameters if you want
//    MediaSessionMgr::defaultsSetAudioGain(0, 0);
    // Set some codec priorities
    /*int prio = 0;
     SipStack::setCodecPriority(tdav_codec_id_g722, prio++);
     SipStack::setCodecPriority(tdav_codec_id_speex_wb, prio++);
     SipStack::setCodecPriority(tdav_codec_id_pcma, prio++);
     SipStack::setCodecPriority(tdav_codec_id_pcmu, prio++);
     SipStack::setCodecPriority(tdav_codec_id_h264_bp, prio++);
     SipStack::setCodecPriority(tdav_codec_id_h264_mp, prio++);
     SipStack::setCodecPriority(tdav_codec_id_vp8, prio++);*/
    //...etc etc etc
    
    //    [self changeLanguage];
    
    [self MicrophoneCheck];
}

-(void)stopMeeting{
    
}

-(void)meetingDidEnterBackground:(UIApplication *)application {

}


- (void)meetingWillEnterForeground:(UIApplication *)application {
    
    // check native contacts changed while app was runnig on background
    if(self->nativeABChangedWhileInBackground){
        // trigger refresh
        self->nativeABChangedWhileInBackground = NO;
    }
}

- (void) MicrophoneCheck{
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                // Microphone enabled code
                //                NSLog(@"Microphone is enabled..");
            }
            else {
                // Microphone disabled code
                //                NSLog(@"Microphone is disabled..");
                
                // We're in a background thread here, so jump to main thread to do UI work.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [g_App showAlert:Localized(@"JX_CanNotOpenMicr")];
                });
            }
        }];
    }
}

-(ChatViewController *)chatViewController{
    if(!_chatViewController){
        //        _chatViewController = [[ChatViewController alloc] initWithNibName: @"ChatView" bundle:nil];
    }
    return _chatViewController;
}


- (void)doTerminate{
    [g_notify removeObserver:self];
}

- (void)clearMemory{
}

/*没用：
 - (void)setSettingToNgn:(NSDictionary*)dict{
 
 NSArray* itemArray = [dict objectForKey:@"PreferenceSpecifiers"];
 for(int i = 0; i < [itemArray count]; i++)
 {
 NSDictionary* identityItemDictionary = (NSDictionary*)[itemArray objectAtIndex:i];
 NSString* strType = (NSString*)[identityItemDictionary objectForKey:@"Type"];
 NSString* strKey = (NSString*)[identityItemDictionary objectForKey:@"Key"];
 NSString* strValue = (NSString*)[identityItemDictionary objectForKey:@"DefaultValue"];
 if([strType isEqualToString:@"PSTextFieldSpecifier"])
 [[NgnEngine sharedInstance].configurationService setStringWithKey:strKey andValue:strValue];
 if([strType isEqualToString:@"PSToggleSwitchSpecifier"])
 [[NgnEngine sharedInstance].configurationService setBoolWithKey:strKey andValue:[strValue isEqualToString:@"YES"]];
 }
 }*/

-(void)loadSeeting{
    /*
     [[CSetting sharedInstance] loadSetting];
     NSDictionary* p = [[[CSetting sharedInstance].identityDict objectForKey:@"PreferenceSpecifiers"] objectAtIndex:2];
     NSString* userId = [p objectForKey:@"DefaultValue"];
     if([userId isEqualToString:g_server.myself.userId]){//如果已保存则赋值
     [self setSettingToNgn:[CSetting sharedInstance].identityDict];
     [self setSettingToNgn:[CSetting sharedInstance].networkDict];
     [self setSettingToNgn:[CSetting sharedInstance].traversalDict];
     [self setSettingToNgn:[CSetting sharedInstance].mediaDict];
     [self setSettingToNgn:[CSetting sharedInstance].codecsDict];
     }
     else
     [self saveMeetingId:g_server.myself];//如果未保存则保存
     */
}

//SIP掉线后提示
- (void) showAutoConnect{
    if(_alert)
        return;
    _alert = [[UIAlertView alloc] initWithTitle:Localized(@"JXMeeting_offline") message:Localized(@"JXMeeting_reConnect") delegate:self cancelButtonTitle:Localized(@"JX_Cencal") otherButtonTitles:Localized(@"JX_Confirm"), nil];
    _alert.tag = 10000;
    [_alert show];
    _showConnResult = YES;
}

#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if (alertView.tag == 10000) { //SIP掉线
            [JXMyTools showTipView:Localized(@"JX_Connection")];
            [self connect];
            //            [self performSelector:@selector(checkAutoConnect) withObject:nil afterDelay:60];
        }
    }
    _alert = nil;
}

-(void)showConnectFailed{
    [JXMyTools showTipView:[NSString stringWithFormat:@"%@%@",Localized(@"JXMeeting_connect"),Localized(@"JX_Failed")]];
    _showConnResult = NO;
}

-(void)showConnectSuccess{
    [JXMyTools showTipView:[NSString stringWithFormat:@"%@%@",Localized(@"JXMeeting_connect"),Localized(@"JX_Success")]];
    _showConnResult = NO;
}

-(void)checkAutoConnect{
    if(!self.connected)
        [self showAutoConnect];
}

-(BOOL)isConnected{
}

-(void)sendAsk:(int)type toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName meetUrl:(NSString *)meetUrl{
    NSString* content=nil;
    self.meetUrl = meetUrl;
    [self doSendMsg:type content:content toUserId:toUserId toUserName:toUserName timeLen:0 objectId:nil];
}

-(void)sendReady:(int)type toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName{
    NSString* content=nil;
    [self doSendMsg:type content:content toUserId:toUserId toUserName:toUserName timeLen:0 objectId:nil];
}

-(void)sendAccept:(int)type toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName objectId:(NSString *)objectId{
    NSString* content=nil;
    [self doSendMsg:type content:content toUserId:toUserId toUserName:toUserName timeLen:0 objectId:objectId];
}

-(void)sendCancel:(int)type toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName{
    NSString* content=nil;
    [self doSendMsg:type content:content toUserId:toUserId toUserName:toUserName timeLen:0 objectId:nil];
}

-(void)sendNoAnswer:(int)type toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName{
    NSString* content=nil;
    [self doSendMsg:type content:content toUserId:toUserId toUserName:toUserName timeLen:1 objectId:nil];
}

-(void)sendEnd:(int)type toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName timeLen:(int)timeLen{
    NSString* content=nil;
    [self doSendMsg:type content:content toUserId:toUserId toUserName:toUserName timeLen:timeLen objectId:nil];
}

-(void)sendMeetingInvite:(NSString*)toUserId toUserName:(NSString*)toUserName roomJid:(NSString*)roomJid callId:(NSString*)callId type:(int)type{
    JXMessageObject *msg=[[JXMessageObject alloc]init];
    if(type == kWCMessageTypeVideoMeetingInvite)
        msg.content      = Localized(@"JXMeeting_InviteVideoMeeting");
    else
        msg.content      = Localized(@"JXMeeting_InviteAudioMeeting");
    if (type == kWCMessageTypeTalkInvite) {
        msg.content = Localized(@"JX_InviteJoinWalkieTalkie");
    }
    msg.fileName     = callId;
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    msg.fromUserName = MY_USER_NAME;
    msg.toUserId     = toUserId;
    msg.toUserName   = toUserName;
    msg.objectId     = roomJid;
    msg.isGroup      = NO;
    msg.type         = [NSNumber numberWithInt:type];
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isRead       = [NSNumber numberWithBool:NO];
    msg.isReadDel    = [NSNumber numberWithInt:NO];
    msg.sendCount    = 1;
    [msg insert:nil];
    [g_xmpp sendMessage:msg roomName:nil];//发送消息
    [g_notify postNotificationName:kXMPPShowMsgNotifaction object:msg];//显示出来
}

-(void)doSendMsg:(int)type content:(NSString*)content toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName timeLen:(int)timeLen objectId:(NSString *)objectId{
    JXMessageObject *msg=[[JXMessageObject alloc]init];
    msg.content      = content;
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    msg.fromUserName = MY_USER_NAME;
    msg.toUserId     = toUserId;
    msg.toUserName   = toUserName;
    msg.isGroup = NO;
    msg.type         = [NSNumber numberWithInt:type];
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isRead       = [NSNumber numberWithBool:NO];
    msg.isReadDel    = [NSNumber numberWithInt:NO];
    msg.timeLen      = [NSNumber numberWithInt:timeLen];//对方无应答标志或通话时长
    msg.sendCount    = 1;
    msg.objectId = objectId;
    if (type == kWCMessageTypeAudioChatAsk || type == kWCMessageTypeVideoChatAsk) {
        msg.fileName = self.meetUrl;
    }
    [msg insert:nil];
    [g_xmpp sendMessage:msg roomName:nil];//发送消息
    [g_notify postNotificationName:kXMPPShowMsgNotifaction object:msg];//显示出来
}

-(void)doSendGroupMsg:(int)type content:(NSString*)content toUserId:(NSString*)toUserId{
    JXMessageObject *msg=[[JXMessageObject alloc]init];
    msg.content      = content;
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    msg.fromUserName = MY_USER_NAME;
    msg.toUserId     = toUserId;
    msg.objectId     = toUserId;
    msg.isGroup      = YES;
    msg.type         = [NSNumber numberWithInt:type];
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isRead       = [NSNumber numberWithBool:NO];
    msg.isReadDel    = [NSNumber numberWithInt:NO];
    msg.sendCount    = 3;
    [g_xmpp sendMessage:msg roomName:toUserId];//发送消息
}

#pragma mark  接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation
{
    JXMessageObject *msg = notifacation.object;
    
    if ([msg.fromUserId isEqualToString:MY_USER_ID]) {
        if ([msg.type intValue] == kWCMessageTypeAudioChatAsk || [msg.type intValue] == kWCMessageTypeVideoChatAsk || [msg.type intValue] == kWCMessageTypeVideoMeetingInvite || [msg.type intValue] == kWCMessageTypeAudioMeetingInvite || [msg.type intValue] == kWCMessageTypeAudioChatAccept || [msg.type intValue] == kWCMessageTypeVideoChatAccept || [msg.type intValue] == kWCMessageTypeTalkInvite) {
            return;
        }
    }
    
    if(msg==nil)
        return;
#ifdef Live_Version
    if([[JXLiveJidManager shareArray] contains:msg.toUserId] || [[JXLiveJidManager shareArray] contains:msg.fromUserId])
        return;
#endif
    
    if([msg.toUserId isEqualToString:MY_USER_ID]){
        if([msg.type intValue] == kWCMessageTypeVideoChatAsk || [msg.type intValue] == kWCMessageTypeAudioChatAsk){
            if(g_meeting.isMeeting && ![self.roomNum isEqualToString:msg.fromUserId]){ //如果有别的通话 不弹出界面
                if (!msg.isMultipleRelay) {
                    [self sendAVBusy:msg];
                }
                return; //如果有别的通话 不弹出界面
            }
                
            int n = ([[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000))-[msg.timeSend timeIntervalSince1970];
            if(n>30)//如果时间差超过30秒，则放弃
                return;
            self.isInCall = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                if(g_meeting.isMeeting && ![self.roomNum isEqualToString:msg.fromUserId]){
                    if (!msg.isMultipleRelay) {
                        [self sendAVBusy:msg];
                    }
                    return; //如果有别的通话 不弹出界面
                }
                if (self.isInCall) {
                    self.meetUrl = msg.fileName;
                    acceptCallViewController* vc = [acceptCallViewController alloc];
                    vc.toUserName = msg.fromUserName;
                    vc.toUserId = msg.fromUserId;
                    vc.type = msg.type;
                    vc.roomNum = msg.fromUserId;
                    NSString* s;
                    if([msg.type intValue] == kWCMessageTypeAudioChatAsk)
                        s = Localized(@"JXMeeting_AudioCall_title");
                    else
                        s = Localized(@"JXMeeting_VideoCall_title");
                    vc.title = s;
                    vc.delegate = self;
                    vc.didTouch = @selector(doAudioVideoMeeting:);
                    vc.changeVideo = @selector(doVideoMeeting:);
                    vc.changeAudio = @selector(doAudioMeeting:);
                    vc = [vc init];
                    //                    [g_window addSubview:vc.view];
                    [g_navigation pushViewController:vc animated:NO];
                    _msg = msg;
                }
                
            });
            
//            if(self.isConnected){
//                [self sendReadyMsg:msg];//如果连接成功，则发ready消息
//            }else{
//                _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(checkMediaServer:) userInfo:msg repeats:YES];
//                [self connect];//如果不成功，则开定时器检查
//            }
            return;
        }
        if([msg.type intValue] == kWCMessageTypeAudioMeetingInvite || [msg.type intValue] == kWCMessageTypeVideoMeetingInvite || [msg.type intValue] == kWCMessageTypeTalkInvite){
//            if (msg.isDelay) {  // 离线的会议音视频邀请不接收
//                return;
//            }
            int n = ([[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000))-[msg.timeSend timeIntervalSince1970];
            if(self.isMeeting) return; //如果有别的通话 不弹出界面
            if(n<=30){//如果时间差超过30秒，则放弃
                if(![current_meeting_no isEqualToString:msg.fileName]){//如果正在开会，则不弹框
                    NSString* s;
                    BOOL isTalk = NO;
                    if([msg.type intValue] == kWCMessageTypeVideoMeetingInvite)
                        s = @"邀请您视频通话...";
                    else if ([msg.type intValue] == kWCMessageTypeTalkInvite) {
                            s = Localized(@"JX_InviteJoinWalkieTalkie");
                        isTalk = YES;
                    }
                    else
                        s = @"邀请您语音通话...";
                    acceptCallViewController* vc = [acceptCallViewController alloc];
                    vc.isGroup = YES;
                    vc.isTalk = isTalk;
                    vc.toUserName = msg.fromUserName;
                    vc.toUserId = msg.fromUserId;
                    vc.roomNum = msg.objectId;
                    vc.type = msg.type;
                    vc.title = s;
                    vc.delegate = self;
                    vc.didTouch = @selector(doAudioVideoMeeting:);
                    vc = [vc init];
//                    [g_window addSubview:vc.view];
                    [g_navigation pushViewController:vc animated:NO];
                    _msg = msg;
                }
            }
        }
    }
    
    if ([msg.type intValue] == kWCMessageTypeAudioChatCancel || [msg.type intValue] == kWCMessageTypeVideoChatCancel) {
        self.isInCall = NO;
        [g_App endCall];
    }
    
    
    msg = nil;
}

- (void)sendOnlineMsg:(JXMessageObject *)msg1 {
    JXMessageObject *msg=[[JXMessageObject alloc]init];
    msg.content      = nil;
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    msg.fromUserName = MY_USER_NAME;
    msg.toUserId     = msg1.objectId;
    msg.isGroup = YES;
    msg.type         = [NSNumber numberWithInt:kWCMessageTypeTalkOnline];
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isRead       = [NSNumber numberWithBool:NO];
    msg.isReadDel    = [NSNumber numberWithInt:NO];
    msg.sendCount    = 1;
    msg.objectId = msg1.objectId;
    [msg insert:nil];
    [g_xmpp sendMessage:msg roomName:msg1.objectId];//发送消息
}

- (void)sendAVBusy:(JXMessageObject *)meetingMsg {
    JXMessageObject *msg=[[JXMessageObject alloc]init];
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    msg.fromUserName = MY_USER_NAME;
    msg.toUserId     = meetingMsg.fromUserId;
    msg.isGroup = NO;
    msg.type         = [NSNumber numberWithInt:kWCMessageTypeAVBusy];
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isRead       = [NSNumber numberWithBool:NO];
    if ([meetingMsg.type intValue] == kWCMessageTypeVideoChatAsk) {
        msg.objectId = @"1";
    }else {
        msg.objectId = @"0";
    }
    [g_xmpp sendMessage:msg roomName:nil];//发送消息
    [msg insert:nil];
    
}

-(void)checkMediaServer:(NSTimer*)sender{
    _checkCount++;
    if(self.isConnected){
        JXMessageObject* msg = (JXMessageObject*)[sender userInfo];
        [self sendReadyMsg:msg];//如果连接成功，则发ready消息
        [_timer invalidate];
        _checkCount = 0;
    }
    if(_checkCount>30){//检查30次，每秒一次
        [_timer invalidate];
        _checkCount = 0;
    }
}

-(void)sendReadyMsg:(JXMessageObject*)msg{//发送准备好音视频通话的消息
    int n = [[NSDate date] timeIntervalSince1970]-[msg.timeSend timeIntervalSince1970];
    if(n>30)//如果时间差超过30秒，则放弃
        return;
    int k;
    if([msg.type intValue] == kWCMessageTypeVideoChatAsk)
        k = kWCMessageTypeVideoChatReady;
    else
        k = kWCMessageTypeAudioChatReady;
    [self sendReady:k toUserId:msg.fromUserId toUserName:msg.fromUserName];
}

-(void)doAudioVideoMeeting:(acceptCallViewController*)vc{
    JXAVCallViewController *avVC = [[JXAVCallViewController alloc] init];
    avVC.isTalk = vc.isTalk;
    
    if([_msg.type intValue] == kWCMessageTypeAudioMeetingInvite || [_msg.type intValue] == kWCMessageTypeAudioChatAsk){
        avVC.isAudio = YES;
        
    }
    
    if([_msg.type intValue] == kWCMessageTypeAudioMeetingInvite || [_msg.type intValue] == kWCMessageTypeVideoMeetingInvite){
        avVC.isGroup = YES;
        avVC.roomNum = _msg.objectId;
    }else if ([_msg.type intValue] == kWCMessageTypeAudioChatAsk) {
        
        avVC.roomNum = _msg.fromUserId;
        avVC.meetUrl = self.meetUrl;
        [g_meeting sendAccept:kWCMessageTypeAudioChatAccept toUserId:_msg.fromUserId toUserName:_msg.fromUserName objectId:_msg.objectId];
    }else if ([_msg.type intValue] == kWCMessageTypeVideoChatAsk) {
        
        avVC.roomNum = _msg.fromUserId;
        avVC.meetUrl = self.meetUrl;
        [g_meeting sendAccept:kWCMessageTypeVideoChatAccept toUserId:_msg.fromUserId toUserName:_msg.fromUserName objectId:_msg.objectId];
    }else if ([_msg.type intValue] == kWCMessageTypeTalkInvite){
        avVC.isGroup = YES;
        avVC.roomNum = _msg.objectId;

    }
    avVC.toUserId = _msg.fromUserId;
    avVC.toUserName = _msg.fromUserName;
    avVC.view.frame = [UIScreen mainScreen].bounds;
    
//        [self startVideoMeeting:_msg.fileName roomJid:_msg.objectId];
//    else
//        [self startAudioMeeting:_msg.fileName roomJid:_msg.objectId];
//    UIViewController *lastVC = (UIViewController *)g_navigation.lastVC;
//    [lastVC presentViewController:avVC animated:NO completion:nil];
    [g_window addSubview:avVC.view];
    _msg = nil;
}


- (void)doAudioMeeting:(acceptCallViewController *)vc{
    JXAVCallViewController *avVC = [[JXAVCallViewController alloc] init];
    avVC.isTalk = vc.isTalk;
    avVC.isAudio = YES;
    avVC.roomNum = _msg.fromUserId;
    avVC.meetUrl = self.meetUrl;
    [g_meeting sendAccept:kWCMessageTypeAudioChatAccept toUserId:_msg.fromUserId toUserName:_msg.fromUserName objectId:_msg.objectId];
    avVC.toUserId = _msg.fromUserId;
    avVC.toUserName = _msg.fromUserName;
    avVC.view.frame = [UIScreen mainScreen].bounds;
    [g_window addSubview:avVC.view];
    _msg = nil;
}
- (void)doVideoMeeting:(acceptCallViewController *)vc{
    JXAVCallViewController *avVC = [[JXAVCallViewController alloc] init];
    avVC.isTalk = vc.isTalk;
    avVC.roomNum = _msg.fromUserId;
    avVC.meetUrl = self.meetUrl;
    [g_meeting sendAccept:kWCMessageTypeVideoChatAccept toUserId:_msg.fromUserId toUserName:_msg.fromUserName objectId:_msg.objectId];
    avVC.toUserId = _msg.fromUserId;
    avVC.toUserName = _msg.fromUserName;
    avVC.view.frame = [UIScreen mainScreen].bounds;
    [g_window addSubview:avVC.view];
    _msg = nil;
}

/*
-(BOOL)isMeeting{
//    return self.audioCallController.sessionId>0 || self.videoCallController.sessionId>0;
    return self.audioCallController || self.videoCallController;
}
*/

@end
