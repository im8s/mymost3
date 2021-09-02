//
//  acceptCallViewController.m
//  lveliao_IM
//
//  Created by MacZ on 2017/8/7.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "acceptCallViewController.h"
#import "JXCustomButton.h"
#import "JXAVCallViewController.h"
#import "JXChatViewController.h"
@interface acceptCallViewController ()<JXActionSheetVCDelegate>
@property (strong, nonatomic) UIView *viewTop;
@property (strong, nonatomic) UIImageView *headerImage;
@property (strong, nonatomic) UILabel *labelStatus;
@property (strong, nonatomic) UILabel *labelRemoteParty;
@property (strong, nonatomic) UIView *viewCenter;

@property (strong, nonatomic) UIImageView *imageSecure;
@property (nonatomic, strong) UIImageView *animationImgV;

@property (strong, nonatomic) UIView *viewBottom;
@property (strong, nonatomic) UIButton *buttonHangup;
@property (strong, nonatomic) UIButton *buttonSendmsg;
@property (strong, nonatomic) UIButton *buttonChangeaccept;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int timerNum;

@property (nonatomic, strong) JXActionSheetVC *callSendMsgView;
@property (nonatomic, strong) NSMutableArray *msgArray;

@end

#define Button_Width 63
#define Button_Height 63
#define BtnImage_big 63
#define BtnImage_small 34


@implementation acceptCallViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.isGotoBack = YES;
        self.heightHeader = 0;
        self.heightFooter = 0;
        self.view.frame = g_window.bounds;
        [self createHeadAndFoot];
        [self customView];
        JXUserObject *user = [[JXUserObject sharedInstance] getUserById:self.toUserId];
        if ([user.offlineNoPushMsg intValue] != 1) {
            _player = [[JXAudioPlayer alloc]init];
            _player.isOpenProximityMonitoring = NO;
            _player.audioFile = [NSString stringWithFormat:@"%@Ring.mp3",imageFilePath];
            [_player open];
            [_player play];
            _player.player.numberOfLoops = 10000;
        }
        self.msgArray = [NSMutableArray arrayWithObjects:Localized(@"JX_Customize"), Localized(@"JX_NoTimePleaseContactMeLater"),Localized(@"JX_MeetingPleaseContactMeLater"),Localized(@"JX_InconvenientTextContact") ,nil];
        g_meeting.isMeeting = YES;
        [g_notify addObserver:self selector:@selector(newMsgCome:) name:kXMPPNewMsgNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(callAnswerNotification:) name:kCallAnswerNotification object:nil];
        [g_notify addObserver:self selector:@selector(callEndNotification:) name:kCallEndNotification object:nil];
        
    }
    return self;
}

-(void)callAnswerNotification:(NSNotification *)notifacation{
    [self doInCall];
}

- (void)doInCall {
    NSLog(@"callAnswer - callView");
    if (g_meeting.hasAnswer) {
        g_meeting.hasAnswer = NO;
        JXAVCallViewController *avVC = [[JXAVCallViewController alloc] init];
        if([self.type intValue] == kWCMessageTypeAudioMeetingInvite || [self.type intValue] == kWCMessageTypeAudioChatAsk){
            avVC.isAudio = YES;
            
        }
        
        if([self.type intValue] == kWCMessageTypeAudioMeetingInvite || [self.type intValue] == kWCMessageTypeVideoMeetingInvite){
            avVC.isGroup = YES;
            avVC.roomNum = self.roomNum;
        }else if ([self.type intValue] == kWCMessageTypeAudioChatAsk) {
            
            avVC.roomNum = self.roomNum;
            [g_meeting sendAccept:kWCMessageTypeAudioChatAccept toUserId:self.toUserId toUserName:self.toUserName objectId:self.roomNum];
        }else if ([self.type intValue] == kWCMessageTypeVideoChatAsk) {
            
            avVC.roomNum = self.roomNum;
            [g_meeting sendAccept:kWCMessageTypeVideoChatAccept toUserId:self.toUserId toUserName:self.toUserName objectId:self.roomNum];
        }
        avVC.toUserId = self.toUserId;
        avVC.toUserName = self.toUserName;
        avVC.view.frame = [UIScreen mainScreen].bounds;
        
        [g_window addSubview:avVC.view];
        
        
        [_player stop];
        _player = nil;
        [self actionQuit];
    }
}


-(void)callEndNotification:(NSNotification *)notifacation{
    
    [self onCancel];
}

- (void) customView {
    self.tableBody.backgroundColor = [UIColor whiteColor];
    
    
    _labelRemoteParty = [[UILabel alloc] init];
    _labelRemoteParty.frame = CGRectMake(0, 129, JX_SCREEN_WIDTH, 25);
    _labelRemoteParty.textColor = HEXCOLOR(0x333333);
    _labelRemoteParty.font = [UIFont systemFontOfSize:24];
    _labelRemoteParty.textAlignment = NSTextAlignmentCenter;
    _labelRemoteParty.text = self.toUserName;
    [self.tableBody addSubview:_labelRemoteParty];

    _labelStatus = [[UILabel alloc] init];
    _labelStatus.frame = CGRectMake(0, CGRectGetMaxY(_labelRemoteParty.frame) + 20, JX_SCREEN_WIDTH, 18);
    _labelStatus.textColor = HEXCOLOR(0x333333);
    _labelStatus.font = [UIFont systemFontOfSize:17];
    _labelStatus.textAlignment = NSTextAlignmentCenter;
    [self.tableBody addSubview:_labelStatus];
    
//    NSString *str;
//    if ([self.type intValue] == kWCMessageTypeAudioChatAsk) {
//        str = @"邀请您语音通话...";
//    }else if ([self.type intValue] == kWCMessageTypeVideoChatAsk) {
//        str = @"邀请您视频通话...";
//    }
    _labelStatus.text = self.title;

    //viewHeader viewTop
//    _viewTop = [[UIView alloc] init];
//    _viewTop.frame = CGRectMake(0, 40, JX_SCREEN_WIDTH, 67);
//    _viewTop.userInteractionEnabled = YES;
//    _viewTop.center = CGPointMake(self.view.frame.size.width / 2, 0);
//    [self.tableBody addSubview:_viewTop];
    

    //viewFooter viewBottom
//    _viewBottom = [[UIView alloc] init];
//    _viewBottom.frame = CGRectMake(0,CGRectGetMaxY(_labelStatus.frame), JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - CGRectGetMaxY(_labelStatus.frame));
//    _viewBottom.userInteractionEnabled = YES;
//    [self.tableBody addSubview:_viewBottom];
    
//    CGFloat margX = 20;
//    CGFloat margWidth = (JX_SCREEN_WIDTH-(4*Button_Width+margX*2))/3;
    
    CGFloat y = (JX_SCREEN_HEIGHT - CGRectGetMaxY(_labelStatus.frame)-63*2-175)/2;
    // 发消息
    _buttonSendmsg = [self createBottomButtonWithImage:@"sendmsg" SelectedImg:nil selector:@selector(onSendmsg) btnWidth:Button_Width imageWidth:BtnImage_big];
    [_buttonSendmsg setTitle:Localized(@"JX_SendMessage") forState:UIControlStateNormal];
    _buttonSendmsg.frame = CGRectMake(48, CGRectGetMaxY(_labelStatus.frame)+y, Button_Width, Button_Height);
    
    // 切换语音/视频
    if ([self.type intValue] == kWCMessageTypeVideoChatAsk) {
        _buttonChangeaccept = [self createBottomButtonWithImage:@"changeaccept" SelectedImg:nil selector:@selector(onChangeaccept) btnWidth:Button_Width imageWidth:BtnImage_big];
        [_buttonChangeaccept setTitle:Localized(@"JX_SwitchVoiceCall") forState:UIControlStateNormal];
    }else{
        _buttonChangeaccept = [self createBottomButtonWithImage:@"switch_video_calls" SelectedImg:nil selector:@selector(onChangeaccept) btnWidth:Button_Width imageWidth:BtnImage_big];
        [_buttonChangeaccept setTitle:Localized(@"JX_SwitchVideoCall") forState:UIControlStateNormal];
    }
    _buttonChangeaccept.frame = CGRectMake(JX_SCREEN_WIDTH-Button_Width-48, _buttonSendmsg.frame.origin.y, Button_Width, Button_Height);
    if (self.isGroup) {
        [self hiddenSendmsgAndChangeaccept];
    }
    
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 3; i ++) {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"Talk_Animation_%d",i]];
        [images addObject:img];
    }
    
    _animationImgV = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH-145)/2, CGRectGetMaxY(_buttonSendmsg.frame)+15, 145, 145)];
    _animationImgV.animationImages = images;
    _animationImgV.animationDuration = 1.5f;
    [self.tableBody addSubview:_animationImgV];
    [_animationImgV startAnimating];
    
    _headerImage = [[UIImageView alloc] init];
    _headerImage.frame = CGRectMake((_animationImgV.frame.size.width-100)/2, (_animationImgV.frame.size.height-100)/2, 100, 100);
    _headerImage.userInteractionEnabled = YES;
    _headerImage.layer.cornerRadius = 50;
    _headerImage.layer.masksToBounds = YES;
    [g_server getHeadImageLarge:self.toUserId userName:self.toUserName imageView:_headerImage];
    [_animationImgV addSubview:_headerImage];

    
    // 挂断
    _buttonHangup = [self createBottomButtonWithImage:@"hang_up" SelectedImg:nil selector:@selector(onCancel) btnWidth:Button_Width imageWidth:BtnImage_big];
    [_buttonHangup setTitle:Localized(@"JXMeeting_Hangup") forState:UIControlStateNormal];
    _buttonHangup.frame = CGRectMake(48, CGRectGetMaxY(_buttonSendmsg.frame) + 175, Button_Width, Button_Height);
    
    // 接听
    _buttonAccept = [self createBottomButtonWithImage:@"answer_icon" SelectedImg:nil selector:@selector(onAcceptCall) btnWidth:Button_Width imageWidth:BtnImage_big];
    [_buttonAccept setTitle:Localized(@"JXMeeting_Accept") forState:UIControlStateNormal];
    _buttonAccept.frame = CGRectMake(JX_SCREEN_WIDTH-Button_Width-48, _buttonHangup.frame.origin.y, Button_Width, Button_Height);
    
    self.tableBody.contentSize = CGSizeMake(0, 0);
}

- (void)hiddenSendmsgAndChangeaccept{
    _buttonSendmsg.hidden = YES;
    _buttonChangeaccept.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self doInCall];
    });
}

// 30秒无响应 自动挂断
- (void)timerAction:(NSTimer *)timer {
    _timerNum ++;
    NSLog(@"timerNum = %d", _timerNum);
    if (_timerNum > 30) {
        [_animationImgV stopAnimating];
        [timer invalidate];
        timer = nil;
        _timerNum = 0;
        [self onCancel];
    }
}

-(JXCustomButton *)createBottomButtonWithImage:(NSString *)Image SelectedImg:(NSString *)selectedImage selector:(SEL)selector btnWidth:(CGFloat)btnWidth imageWidth:(CGFloat)imageWidth{
    JXCustomButton * button = [JXCustomButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:Image] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
    
    [button.titleLabel setFont:g_factory.font12];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    button.titleRect = CGRectMake(0, imageWidth+(btnWidth-imageWidth)/2, btnWidth, 20);
    button.imageRect = CGRectMake((btnWidth-imageWidth)/2, 0, imageWidth, imageWidth);
    if (selector)
        [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.tableBody addSubview:button];
    return button;
}

#pragma mark  接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation{
    
    JXMessageObject *msg = (JXMessageObject *)notifacation.object;
    if ([msg.type intValue] == kWCMessageTypeAudioChatCancel || [msg.type intValue] == kWCMessageTypeVideoChatCancel || [msg.type intValue] == kWCMessageTypeVideoChatEnd || [msg.type intValue] == kWCMessageTypeAudioChatEnd) {
        [_player stop];
        _player = nil;
        g_meeting.isMeeting = NO;
        [self actionQuit];
        [g_App endCall];
    }
    
    
    // 多点登录处理
    if ([msg.fromUserId isEqualToString:MY_USER_ID]) {
        if([msg.type intValue] == kWCMessageTypeAudioChatAccept){
            [_player stop];
            _player = nil;
            g_meeting.isMeeting = NO;
            [self actionQuit];
            [g_App endCall];
            
        }else if ([msg.type intValue] == kWCMessageTypeVideoChatAccept) {
            [_player stop];
            _player = nil;
            g_meeting.isMeeting = NO;
            [self actionQuit];
            [g_App endCall];
        }
        
        if ([msg.type intValue] == kWCMessageTypeAudioChatCancel || [msg.type intValue] == kWCMessageTypeVideoChatCancel) {
            [_player stop];
            _player = nil;
            g_meeting.isMeeting = NO;
            [self actionQuit];
            [g_App endCall];
        }
    }
    
    
}

-(void)dealloc{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)onAcceptCall{
    [_player stop];
    _player = nil;
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didTouch])
        [self.delegate performSelectorOnMainThread:self.didTouch withObject:self waitUntilDone:NO];
    [self actionQuit];
}

-(void)onCancel{
    [_player stop];
    _player = nil;
    g_meeting.hasAnswer = NO;
    g_meeting.isMeeting = NO;
    [g_App endCall];
    if (self.isGroup) {
        [self actionQuit];
        return;
    }
    
    int n;
    if([self.type intValue] == kWCMessageTypeAudioChatAsk)
        n = kWCMessageTypeAudioChatCancel;
    else
        n = kWCMessageTypeVideoChatCancel;
    [g_meeting sendNoAnswer:n toUserId:self.toUserId toUserName:self.toUserName];
    [self actionQuit];
}

- (void)onSendmsg{
    
    self.callSendMsgView = [[JXActionSheetVC alloc] initWithImages:nil names:self.msgArray];
    self.callSendMsgView.delegate = self;
    [self presentViewController:self.callSendMsgView animated:YES completion:nil];
}

- (void)onChangeaccept{
    if ([self.type intValue] == kWCMessageTypeVideoChatAsk) {
        [_player stop];
        _player = nil;
        if(self.delegate != nil && [self.delegate respondsToSelector:self.changeAudio])
            [self.delegate performSelectorOnMainThread:self.changeAudio withObject:self waitUntilDone:NO];
        [self actionQuit];
    }else{
        [_player stop];
        _player = nil;
        if(self.delegate != nil && [self.delegate respondsToSelector:self.changeVideo])
            [self.delegate performSelectorOnMainThread:self.changeVideo withObject:self waitUntilDone:NO];
        [self actionQuit];
    }
}

- (void)actionSheet:(JXActionSheetVC *)actionSheet didButtonWithIndex:(NSInteger)index{
    if (index == 0) {
        [self sendCustomMsg];
    }else{
        NSString *msg = self.msgArray[index];
        [self sendMsg:msg];
    }
}
- (void)sendMsg:(NSString *)Msg{
    [self onCancel];
    JXMessageObject *message = [[JXMessageObject alloc] init];
    message.fromUserId = MY_USER_ID;
    message.fromUserName = MY_USER_NAME;
    message.toUserId = self.toUserId;
    message.toUserName = self.toUserName;
    message.timeSend = [NSDate date];
    message.type = [NSNumber numberWithInt:kWCMessageTypeText];
    message.isSend = [NSNumber numberWithInt:transfer_status_ing];
    message.isRead = [NSNumber numberWithBool:NO];
    message.content = Msg;
    message.isGroup = NO;
    message.isReadDel = [NSNumber numberWithBool:NO];
    [message insert:message.toUserId];
    if ([message.toUserId isEqualToString:current_chat_userId]) {
        [g_notify postNotificationName:UpdateAcceptCallMsg object:message];
    }else{
        [g_xmpp sendMessage:message roomName:nil];
    }
    
}

- (void)sendCustomMsg{
    [self onCancel];
    JXUserObject *user = [[JXUserObject alloc] init];
    user.userId = self.toUserId;
    if ([user.userId isEqualToString:current_chat_userId]) {
        
    }else{
        JXChatViewController *chatView = [[JXChatViewController alloc] init];
        chatView.chatPerson = user;
        [g_navigation pushViewController:chatView animated:YES];
    }
}

-(void)actionQuit{
    [g_notify removeObserver:self];//移除监听
    [_timer invalidate];
    _timer = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [super actionQuit];
    });
}

@end
