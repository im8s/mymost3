//
//  JXAudioPlayer.m
//  shiku_im
//
//  Created by flyeagleTang on 17/1/12.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXAudioPlayer.h"
#import "VoiceConverter.h"



@implementation JXAudioPlayer
@synthesize player=_player,delegate,timeLenView=_timeLenView;

- (id)initWithParent:(UIView*)value{
    self = [super init];
    if (self) {
        self.parent = value;
        [self reset];
        
        _pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        _pauseBtn.center = CGPointMake(_parent.frame.size.width/2,_parent.frame.size.height/2);
        [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"feeds_play_btn_u"] forState:UIControlStateNormal];
        [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"feeds_play_btn_h_u"] forState:UIControlStateSelected];
        [_pauseBtn addTarget:self action:@selector(switch) forControlEvents:UIControlEventTouchUpInside];
        [_parent addSubview:_pauseBtn];

        _wait = [[JXWaitView alloc] initWithParent:_parent];
    }
    return self;
}

-(id)init{
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (id)initWithParent:(UIView*)value frame:(CGRect)frame isLeft:(BOOL)isLeft{
    self = [super init];
    if (self) {
        self.parent = value;
        [self reset];

        _frame = frame;
        _voiceBtn = [[JXImageView alloc] initWithFrame:frame];
        _voiceBtn.userInteractionEnabled = YES;
        _voiceBtn.backgroundColor = [UIColor clearColor];
        _voiceBtn.layer.cornerRadius = 3;
        _voiceBtn.layer.masksToBounds = YES;
        _voiceBtn.didTouch = @selector(switch);
        _voiceBtn.delegate = self;
        [_parent addSubview:_voiceBtn];
        
        _voiceView = [[JXImageView alloc]init];
        _voiceView.animationDuration = 1;
        _voiceView.frame = CGRectMake(2, 1.5, 25, _voiceBtn.frame.size.height-3);
        [_voiceBtn addSubview:_voiceView];
        
        UIPanGestureRecognizer * tap = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gotoAudioTime:)];
        [_voiceBtn addGestureRecognizer:tap];

        _timeLenView = [[UILabel alloc] init];
        _timeLenView.backgroundColor = [UIColor clearColor];
        _timeLenView.textColor = HEXCOLOR(0x999999);
        _timeLenView.font = [UIFont systemFontOfSize:g_constant.chatFont];
        _timeLenView.userInteractionEnabled = NO;
        [_voiceBtn addSubview:_timeLenView];
        
        _showProgress = YES;
        _pgBGView = [[UIView alloc] init];
        [_voiceBtn addSubview:_pgBGView];
        
        _progressView = [[UIProgressView alloc] init];
        _progressView.progress = 0.0;
        [_pgBGView addSubview:_progressView];
        _pgBGView.hidden= YES;
        
        
        _wait = [[JXWaitView alloc] initWithParent:_voiceBtn];
        self.isLeft = isLeft;
    }
    return self;
}

-(void)gotoAudioTime:(UIPanGestureRecognizer *)tapGes{
    if (!self.isPlaying) {
        [self switch];
        
        return;
    }

    CGPoint touchPoint = [tapGes locationInView:tapGes.view];
    
    if (touchPoint.x >= tapGes.view.frame.size.width) {
        return;
    }
    
    float progress = touchPoint.x / tapGes.view.frame.size.width;
    if (progress >= 1) {
        progress = 1;
    }
    _progressView.progress = progress;
    NSLog(@"ddddd%f",_player.duration*progress);
    _player.currentTime = _player.duration*progress;

}

- (void)dealloc {
    NSLog(@"JXAudioPlayer.dealloc");
    self.parent = nil;
    [g_notify removeObserver:self];
    [self freeTimer];
    [self stop];
}

-(void)reset{
    _isOpened = NO;
    self.isPlaying = NO;
    _array=[[NSMutableArray alloc] init];

    [g_notify addObserver:self selector:@selector(playerPause:) name:kAllAudioPlayerPauseNotifaction object:nil];//开始录音
    [g_notify addObserver:self selector:@selector(playerStop:) name:kAllAudioPlayerStopNotifaction object:nil];//开始录音
    [g_notify addObserver:self selector:@selector(EnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [g_notify addObserver:self selector:@selector(AVPlayerStopNotif:) name:kAVPlayerStopNotification object:nil];
    [self setHardware];
}

- (void)AVPlayerStopNotif:(NSNotification *)notif {
    
    [self stop];
}

-(void)setHardware{
//    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    //初始化播放器的时候如下设置,添加监听
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    //默认播放
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    if (self.isChatAudio) {
        
        BOOL flag = [g_default boolForKey:kChatVCMessageAudioIsNotPlayback];
        if (flag) {
            
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        }else {
            
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        }
        
    }else {
        
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    }

    [audioSession setActive:YES error:nil];
//    audioSession = nil;
}
//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    
    BOOL flag = [g_default boolForKey:kChatVCMessageAudioIsNotPlayback];
    if (self.isChatAudio) {
        if (flag) {
            return;
        }
    }
    
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        if(!self.isPlaying)//正在播放才影响
            return;
        
        if(![[AVAudioSession sharedInstance].category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
            NSLog(@"切换到听筒模式");
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        }
    }
    else
    {
        if(![[AVAudioSession sharedInstance].category isEqualToString:AVAudioSessionCategoryPlayback]) {
            NSLog(@"切换到免提模式");
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        }
        if (!self.isPlaying) {
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            [g_notify removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
        }else {
            if (self.isOpenProximityMonitoring) {
                [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
            }
        }
    }
}

-(void)open{
    
    if (!_audioFile) {
        return;
    }
    
    NSString* file;
    file = [myTempFilePath stringByAppendingString:[_audioFile lastPathComponent]];
    
    if([_audioFile rangeOfString:@"://"].location != NSNotFound){
        if(![[NSFileManager defaultManager]fileExistsAtPath:file]){
            [self downloadFile:_audioFile];
            return;
        }
    }else
        file = _audioFile;
    
    if([[[_audioFile pathExtension] uppercaseString] isEqualToString:@"AMR"])
        file = [VoiceConverter amrToWav:file];
    if(file==nil)
        return;
    if(_player)
        [self stop];
    
    _player = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:file] error:nil];
    _player.delegate = self;
    _player.volume = 10;
    _isOpened = YES;
    
     if(_player.prepareToPlay)
        [self doAudioOpen];
}

-(void)switch{
    if(_player.prepareToPlay){
        if(_player.isPlaying){
            [self pause];
        }
        else{
            [self play];
        }
    }else{
        [self open];
        [self play];
    }
}

-(void)play{
    if(!_player.prepareToPlay)
        return;
    if (!self.isNotStopLast) {
        [g_notify postNotificationName:kAllAudioPlayerPauseNotifaction object:self userInfo:nil];
        [g_notify postNotificationName:kAllVideoPlayerPauseNotifaction object:self userInfo:nil];
    }
    
    if (self.isChatAudio) {
        
        BOOL flag = [g_default boolForKey:kChatVCMessageAudioIsNotPlayback];
        if (flag) {
            
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        }else {
            
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        }
        
    }else {
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    
    [_player play];
    [self doPlayBegin];
}

-(void)pause{
    [self doPause];
    [_player pause];
}

-(void)stop{
    if(_player==nil)
        return;
    [self doPause];
    [_player stop];
//    [_player release];
    _player = nil;
    _isOpened = NO;
}

-(void)setParent:(UIView *)value{
    [self adjust];
    if([_parent isEqual:value])
        return;
//    [_parent release];
//    _parent = [value retain];
    _parent = value;
    [self adjust];
}

-(void)setAudioFile:(NSString *)value{
    if([_audioFile isEqual:value])
        return;
//    [_audioFile release];
//    _audioFile = [value retain];
    _audioFile = value;
    
    [self stop];
}

-(void)playerStop:(NSNotification*)notification{
    if([notification.object isEqual:self])
        return;
    [self stop];
}

-(void)playerPause:(NSNotification*)notification{
    if([notification.object isEqual:self])
        return;
    [self pause];
}

- (void)downloadFile:(NSString *)fileUrl{
    if([fileUrl length]<=0)
        return;
    NSString *filepath = [myTempFilePath stringByAppendingPathComponent:[fileUrl lastPathComponent]];
    
    if( ![[NSFileManager defaultManager] fileExistsAtPath:filepath])
        [g_server addTask:fileUrl param:nil toView:self];
}

- (void)didServerResultSucces:(JXConnection *)aDownload dict:(NSDictionary *)dict array:(NSArray *)array1{
    [_wait stop];
    self.audioFile = aDownload.downloadFile;
    [self open];
//    [_player play];
    [self play];
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    return hide_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{
    [_wait stop];
    return hide_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player1 successfully:(BOOL)flag{
    [self doPlayEnd];
}

-(void)adjust{
    if(_parent==nil)
        return;
    
    [_parent addSubview:_voiceBtn];
    [_parent addSubview:_pauseBtn];
    _voiceBtn.frame = _frame;
    _pauseBtn.center = CGPointMake(_parent.frame.size.width/2,_parent.frame.size.height/2);
    if(_voiceBtn)
        _wait.parent = _voiceBtn;
    else
        _wait.parent = _parent;
    [_wait adjust];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player{
    [self doPause];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    //NSLog(@"");
}

-(void)doAudioOpen{
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didAudioOpen])
        [self.delegate performSelectorOnMainThread:self.didAudioOpen withObject:self waitUntilDone:NO];
}

-(void)doPlayEnd{
    self.isPlaying = NO;
    
    if ([[UIDevice currentDevice] proximityState] == NO) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO]; //播放结束设置NO，结束红外感应
        [g_notify removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    }
    

    _pauseBtn.selected = NO;
    [_voiceView stopAnimating];
    _progressView.progress = 0.0;
    _pgBGView.hidden = YES;
    [self freeTimer];
    if (!_parent) return;
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didAudioPlayEnd])
        [self.delegate performSelectorOnMainThread:self.didAudioPlayEnd withObject:self waitUntilDone:NO];
}

-(void)doPlayBegin{
    self.isPlaying = YES;
    if (self.isOpenProximityMonitoring) {
        [g_notify addObserver:self selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];

        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES]; //播放之前设置yes，开启红外感应
    }
    _pauseBtn.selected = YES;
    [_voiceView startAnimating];
    
    _pgBGView.hidden = (_timeLen >= 10 && _showProgress) ? NO : YES;
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    }

    if(self.delegate != nil && [self.delegate respondsToSelector:self.didAudioPlayBegin])
        [self.delegate performSelectorOnMainThread:self.didAudioPlayBegin withObject:self waitUntilDone:NO];
}

-(void)doPause{
    self.isPlaying = NO;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO]; //播放结束设置NO，结束红外感应
    _pauseBtn.selected = NO;
    [_voiceView stopAnimating];
    _pgBGView.hidden = YES;
    [self freeTimer];

    if(self.delegate != nil && [self.delegate respondsToSelector:self.didAudioPause])
        [self.delegate performSelectorOnMainThread:self.didAudioPause withObject:self waitUntilDone:NO];
}
-(void)freeTimer{
    [_timer invalidate];
    _timer = nil;
}
-(void)EnterForeground{
    if(_player.prepareToPlay){
        [self performSelector:@selector(pause) withObject:nil afterDelay:0.1];
    }
}

-(void)setIsLeft:(BOOL)value{
    _isLeft = value;
    self.timeLen = _timeLen;

    [_array removeAllObjects];
    NSString* file,*s;
    if(!_isLeft)
        file = @"voice_paly_right_";
    else
        file = @"voice_paly_left_";
    for(int i=1;i<=3;i++){
        s = [NSString stringWithFormat:@"%@%d",file,i];
        [_array addObject:[UIImage imageNamed:s]];
    }
    _voiceView.animationImages = _array;
    _voiceView.image = [_array objectAtIndex:[_array count]-1];
}


-(void)setTimeLen:(int)value{
    _timeLen = value;
    if(_timeLen <= 0)
        _timeLen = 1;
    int w = (JX_SCREEN_WIDTH-HEAD_SIZE-INSETS*2-70)/30;
    w = 70+w*self.timeLen;
    if(w<70)
        w = 70;
    if(w>200)
        w = 200;
    if(w>_frame.size.width)
        w = _frame.size.width;
    
    _timeLenView.text = [NSString stringWithFormat:@"%d''",_timeLen];

    CGSize size = [_timeLenView.text sizeWithAttributes:@{NSFontAttributeName:SYSFONT(g_constant.chatFont)}];
    
    if(_isLeft){
        _voiceView.frame = CGRectMake(INSETS, (_frame.size.height-24)/2, 24, 24);
        _timeLenView.frame = CGRectMake(w-size.width-10, (_frame.size.height-24)/2, size.width, 24);
        _timeLenView.textAlignment = NSTextAlignmentRight;
        _pgBGView.frame = CGRectMake(CGRectGetMaxX(_voiceView.frame), 0, CGRectGetMinX(_timeLenView.frame)-CGRectGetMaxX(_voiceView.frame)-5, _frame.size.height);
    }
    else{
        _voiceView.frame = CGRectMake(w-INSETS-24, (_frame.size.height-24)/2, 24, 24);
        _timeLenView.frame = CGRectMake(8, (_frame.size.height-24)/2, size.width, 24);
        _timeLenView.textAlignment = NSTextAlignmentLeft;
        _pgBGView.frame = CGRectMake(CGRectGetMaxX(_timeLenView.frame), 0, CGRectGetMinX(_voiceView.frame)-CGRectGetMaxX(_timeLenView.frame), _frame.size.height);
    }
    _progressView.transform = CGAffineTransformIdentity;
    _progressView.frame = CGRectMake(0, (CGRectGetHeight(_pgBGView.frame)-2)/2, CGRectGetWidth(_pgBGView.frame), 2);
    _progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
}

-(void)setHidden:(BOOL)value{
    _pauseBtn.hidden = value;
    _voiceBtn.hidden = value;
}

-(void)setFrame:(CGRect)value{
    _frame = value;
    [self adjust];
    self.isLeft = _isLeft;
}

-(void)updateProgress{
    [_progressView setProgress:(_player.currentTime/_player.duration) animated:YES];
//    NSLog(@"player_%f,%f",_player.currentTime,_player.duration);
}



@end
