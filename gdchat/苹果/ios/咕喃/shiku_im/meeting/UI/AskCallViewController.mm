//
//  AskCallViewController.m
//  lveliao_IM
//
//  Created by MacZ on 2017/8/7.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "AskCallViewController.h"
#import "JXCustomButton.h"
#ifdef Live_Version
#import "JXLiveJidManager.h"
#endif
#import "JXAVCallViewController.h"
@interface AskCallViewController ()
@property (strong, nonatomic) UIView *viewTop;
@property (strong, nonatomic) UIImageView *headerImage;
@property (strong, nonatomic) UILabel *labelStatus;
@property (strong, nonatomic) UILabel *labelRemoteParty;
@property (strong, nonatomic) UIView *viewCenter;

@property (strong, nonatomic) UIImageView *imageSecure;
@property (nonatomic, strong) UIImageView *animationImgV;

@property (strong, nonatomic) UIView *viewBottom;
@property (strong, nonatomic) UIButton *buttonHangup;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, assign) int timerNum;

@end

#define Button_Width 63
#define Button_Height 63
//#define BtnImage_big 56
//#define BtnImage_small 34
#define BtnImage_big 63
#define BtnImage_small 34

@implementation AskCallViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.isGotoBack = YES;
        self.heightHeader = 0;
        self.heightFooter = 0;
        self.view.frame = g_window.bounds;
        [self createHeadAndFoot];
        g_meeting.isMeeting = YES;
        
        [self customView];

        [g_notify addObserver:self selector:@selector(newMsgCome:) name:kXMPPNewMsgNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(onSendTimeout:) name:kXMPPSendTimeOutNotifaction object:nil];
        
        [g_meeting sendAsk:self.type toUserId:self.toUserId toUserName:self.toUserName meetUrl:self.meetUrl];
        _bAnswer = NO;
        //[self performSelector:@selector(checkAnswer) withObject:nil afterDelay:30];
//        [self performSelector:@selector(doCall) withObject:nil afterDelay:10];

        JXUserObject *user = [[JXUserObject sharedInstance] getUserById:self.toUserId];
        if ([user.offlineNoPushMsg intValue] != 1) {
            _player = [[JXAudioPlayer alloc]init];
            _player.isOpenProximityMonitoring = NO;
            _player.audioFile = [NSString stringWithFormat:@"%@Ring.mp3",imageFilePath];
            [_player open];
            [_player play];
            _player.player.numberOfLoops = 10000;
        }
    }
    return self;
}

- (void) customView {
    self.tableBody.backgroundColor = [UIColor whiteColor];
    
    
    _labelRemoteParty = [[UILabel alloc] init];
    _labelRemoteParty.frame = CGRectMake(0, 109, JX_SCREEN_WIDTH, 25);
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
    
    NSString *str;
    if (self.type == kWCMessageTypeAudioChatAsk) {
        str = @"等待语音接听...";
    }else if (self.type == kWCMessageTypeVideoChatAsk) {
        str = @"等待视频接听...";
    }
    _labelStatus.text = str;


    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 3; i ++) {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"Talk_Animation_%d",i]];
        [images addObject:img];
    }
    
    _animationImgV = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH-145)/2, (JX_SCREEN_HEIGHT-145)/2-30, 145, 145)];
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
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_animationImgV.frame) + 20, JX_SCREEN_WIDTH, 20)];
    _timeLabel.font = SYSFONT(16);
    _timeLabel.textColor = HEXCOLOR(0x333333);
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.text = [TimeUtil getTimeShort:_timerNum];
    [self.tableBody addSubview:_timeLabel];

    //viewHeader viewTop
//    _viewTop = [[UIView alloc] init];
//    _viewTop.frame = CGRectMake(0, 40, JX_SCREEN_WIDTH, 86);
//    _viewTop.userInteractionEnabled = YES;
//    _viewTop.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2 - 100);
//    [self.tableBody addSubview:_viewTop];
    
    
    //viewFooter viewBottom
//    _viewBottom = [[UIView alloc] init];
//    _viewBottom.frame = CGRectMake(0, JX_SCREEN_HEIGHT*3.2/5, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT/2);
//    _viewBottom.userInteractionEnabled = YES;
//    [self.tableBody addSubview:_viewBottom];
    
    _buttonHangup = [self createBottomButtonWithImage:@"hang_up" SelectedImg:nil selector:@selector(doCancel) btnWidth:Button_Width imageWidth:BtnImage_big];
    [_buttonHangup setTitle:Localized(@"JXMeeting_Hangup") forState:UIControlStateNormal];
    _buttonHangup.frame = CGRectMake((JX_SCREEN_WIDTH - Button_Width) / 2 , CGRectGetMaxY(_timeLabel.frame)+(JX_SCREEN_HEIGHT-CGRectGetMaxY(_timeLabel.frame)-Button_Height)/2-20, Button_Width, Button_Height);
    
    self.tableBody.contentSize = CGSizeMake(0, 0);

}

- (void)viewDidLoad {
    [super viewDidLoad];
    _timerNum = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
}

// 30秒无响应 自动挂断
- (void)timerAction:(NSTimer *)timer {
    _timerNum ++;
    NSLog(@"timerNum = %d", _timerNum);
    if (_timerNum > 32) {
        [_animationImgV stopAnimating];
        [timer invalidate];
        timer = nil;
        _timerNum = 0;
        [self doCancel];
    }
    _timeLabel.text = [TimeUtil getTimeShort:_timerNum];
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

-(void)dealloc{
    //移除监听
    [g_notify removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation{
    JXMessageObject *msg = (JXMessageObject *)notifacation.object;
    if(msg==nil)
        return;
    
    if ([msg.type integerValue] == kWCMessageTypeAVBusy) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            g_meeting.isMeeting = NO;
            [g_App endCall];
            [self actionQuit];
            [g_server showMsg:Localized(@"JX_TheOtherBusy")];
        });
        return;
    }
    
#ifdef Live_Version
    if([[JXLiveJidManager shareArray] contains:msg.toUserId] || [[JXLiveJidManager shareArray] contains:msg.fromUserId])
        return;
#endif
    if([msg.type intValue] == kWCMessageTypeAudioChatAccept){
        JXAVCallViewController *avVC = [[JXAVCallViewController alloc] init];
        avVC.isAudio = YES;
        avVC.isGroup = NO;
        avVC.toUserId = msg.fromUserId;
        avVC.toUserName = msg.fromUserName;
        avVC.meetUrl = self.meetUrl;
        avVC.roomNum = MY_USER_ID;
        avVC.view.frame = [UIScreen mainScreen].bounds;
        [g_window addSubview:avVC.view];
        [self actionQuit];
//        UIViewController *lastVC = (UIViewController *)g_navigation.lastVC;
//        [lastVC presentViewController:avVC animated:NO completion:nil];
        
        
    }else if ([msg.type intValue] == kWCMessageTypeVideoChatAccept) {
        JXAVCallViewController *avVC = [[JXAVCallViewController alloc] init];
        avVC.isAudio = NO;
        avVC.isGroup = NO;
        avVC.toUserId = msg.fromUserId;
        avVC.toUserName = msg.fromUserName;
        avVC.meetUrl = self.meetUrl;
        avVC.roomNum = MY_USER_ID;
        avVC.view.frame = [UIScreen mainScreen].bounds;
        [g_window addSubview:avVC.view];
        [self actionQuit];
//        UIViewController *lastVC = (UIViewController *)g_navigation.lastVC;
//        [lastVC presentViewController:avVC animated:NO completion:nil];
    }
    
    if ([msg.type intValue] == kWCMessageTypeAudioChatCancel || [msg.type intValue] == kWCMessageTypeVideoChatCancel) {
        g_meeting.isMeeting = NO;
        [self actionQuit];
        [g_App endCall];
    }
    
    // 多点登录
    if ([msg.fromUserId isEqualToString:MY_USER_ID]) {
        if ([msg.type intValue] == kWCMessageTypeAudioChatCancel || [msg.type intValue] == kWCMessageTypeVideoChatCancel || [msg.type intValue] == kWCMessageTypeVideoChatEnd || [msg.type intValue] == kWCMessageTypeAudioChatEnd) {
            [_player stop];
            _player = nil;
            g_meeting.isMeeting = NO;
            [self actionQuit];
            [g_App endCall];
        }
    }
    
//    if([msg.type intValue] == kWCMessageTypeAudioChatReady || [msg.type intValue] == kWCMessageTypeVideoChatReady){
//        if([msg.fromUserId isEqualToString:self.toUserId]){
//                [self doCall];
//        }
//    }
}

-(void)onSendTimeout:(NSNotification *)notifacation//超时未收到回执
{
    JXMessageObject *msg     = (JXMessageObject *)notifacation.object;
    if(msg==nil)
        return;
    if([msg.type intValue] == kWCMessageTypeAudioChatAsk || [msg.type intValue] == kWCMessageTypeVideoChatAsk){
//        [g_App showAlert:@"网络不好，无法送达"];
        [self doNoAnswer:[msg.type intValue]];
        return;
    }
}

-(void)doCancel{
    _bAnswer = YES;
    int n;
    if(self.type == kWCMessageTypeAudioChatAsk)
        n = kWCMessageTypeAudioChatCancel;
    else
        n = kWCMessageTypeVideoChatCancel;
    [g_meeting sendCancel:n toUserId:self.toUserId toUserName:self.toUserName];
    g_meeting.isMeeting = NO;
    [g_App endCall];
    [self actionQuit];
}

-(void)checkAnswer{
    if(!_bAnswer)
        [self doNoAnswer:self.type];
}

-(void)doNoAnswer:(int)type{
    int n;
    if(type == kWCMessageTypeAudioChatAsk)
        n = kWCMessageTypeAudioChatCancel;
    else
        n = kWCMessageTypeVideoChatCancel;
    [g_meeting sendNoAnswer:n toUserId:self.toUserId toUserName:self.toUserName];
    g_meeting.isMeeting = NO;
    [g_App endCall];
    [self actionQuit];
}

-(void)actionQuit{
    [_player stop];
    _player = nil;
    [_timer invalidate];
    _timer = nil;
    [super actionQuit];
}

@end
