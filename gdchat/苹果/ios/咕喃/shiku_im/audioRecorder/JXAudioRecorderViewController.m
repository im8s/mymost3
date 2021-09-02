//
//  JXAudioRecorderViewController.m
//  shiku_im
//
//  Created by Apple on 17/1/3.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXAudioRecorderViewController.h"

@interface JXAudioRecorderViewController ()

@end

@implementation JXAudioRecorderViewController{
    UIButton *_recordBtn;
    UILabel * _recorderNoticeLabel;
    UIButton *_confirmBtn;
    UIButton *_cancelBtn;
    UIButton *_deleteBtn;
    
    UIImageView *_timeBGView;
    UILabel *_timeLabel;
    UILabel *_noticeLabel;
    
    UIButton *_backBtn;
    NSTimer* _timer;
    unsigned int _timeCount;

}
@synthesize delegate;

-(void)dealloc{
    [self resume];
    NSLog(@"JXAudioRecorderViewController.dealloc");
//    [_audioRecorder release];
//    _audioRecorder = nil;
//    [super dealloc];
}

-(instancetype)init{
    self = [super init];
    if (self) {
        //self.view.frame = g_window.bounds;
        self.view.backgroundColor = HEXCOLOR(0x757575);
        [self initSubViews];
        [self recorderSetting];
        _timeCount = 0;
        _maxTime = 0;

        [g_notify postNotificationName:kAllAudioPlayerPauseNotifaction object:self userInfo:nil];
        [g_notify postNotificationName:kAllVideoPlayerPauseNotifaction object:self userInfo:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)initSubViews{
    //录制按钮
    _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _recordBtn.frame = CGRectMake((JX_SCREEN_WIDTH -98)/2, (JX_SCREEN_HEIGHT-33-18-22-98), 98, 98);
    [_recordBtn setImage:[UIImage imageNamed:@"tapToStartRecorderAudio"] forState:UIControlStateNormal];
    [_recordBtn setImage:[UIImage imageNamed:@"stopPlayAudio"] forState:UIControlStateSelected];
    
    [_recordBtn setBackgroundImage:[UIImage imageNamed:@"audio_record_normal"] forState:UIControlStateNormal];
    [_recordBtn setBackgroundImage:[UIImage imageNamed:@"complete_selected"] forState:UIControlStateSelected];
    
    _recordBtn.imageEdgeInsets = UIEdgeInsetsMake(19, 19, 19, 19);
    [_recordBtn addTarget:self action:@selector(audioRecorderClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_recordBtn];
    
    //录制提示
    _recorderNoticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(_recordBtn.frame)+20, _recordBtn.frame.size.width+85, 18)];
    CGFloat x = _recordBtn.center.x;
    _recorderNoticeLabel.center = CGPointMake(x, _recorderNoticeLabel.center.y);
//    _recorderNoticeLabel.text = Localized(@"JXAudioRecorderViewController_TapRecorder");
    _recorderNoticeLabel.text = Localized(@"JX_Recorder");
    _recorderNoticeLabel.textAlignment = NSTextAlignmentCenter;
    _recorderNoticeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    _recorderNoticeLabel.textColor = HEXCOLOR(0xeaf4f4);
    _recorderNoticeLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_recorderNoticeLabel];
//    [_recorderNoticeLabel release];
    
    
    
    //播放
//    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _playBtn.frame = _recordBtn.frame;
//    [_playBtn setImage:[UIImage imageNamed:@"playAudio"] forState:UIControlStateNormal];
//    [_playBtn setImage:[UIImage imageNamed:@"stopPlayAudio"] forState:UIControlStateSelected];
//    [_playBtn addTarget:self action:@selector(startPlayAudio:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_playBtn];
    
    //取消
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _cancelBtn.frame = CGRectMake(45, _recorderNoticeLabel.frame.origin.y, 60, 18);
    [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    [_cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateHighlighted];
    _cancelBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    _cancelBtn.titleLabel.textColor = HEXCOLOR(0xeaf4f4);
    [_cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelBtn];
    
    //上传
    _confirmBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _confirmBtn.frame = CGRectMake((JX_SCREEN_WIDTH-_cancelBtn.frame.size.width -_cancelBtn.frame.origin.x), _cancelBtn.frame.origin.y, _cancelBtn.frame.size.width, _cancelBtn.frame.size.height);
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_confirmBtn setTitle:Localized(@"JX_Send") forState:UIControlStateNormal];
    [_confirmBtn setTitle:Localized(@"JX_Send") forState:UIControlStateHighlighted];
    _confirmBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    _confirmBtn.titleLabel.textColor = HEXCOLOR(0xeaf4f4);
    [_confirmBtn addTarget:self action:@selector(confirmAudio:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_confirmBtn];
    
    
    //提示语
    _noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH*(1-1/1.4)/2, 150, JX_SCREEN_WIDTH/1.2, JX_SCREEN_HEIGHT/3)];
    _noticeLabel.text = [NSString stringWithFormat:@"%@\r\n%@\r\n%@\r\n%@",Localized(@"JXAudioRecorder_RecorderTip1"),Localized(@"JXAudioRecorder_RecorderTip2"),Localized(@"JXAudioRecorder_RecorderTip3"),Localized(@"JXAudioRecorder_RecorderTip4")];
    
    _noticeLabel.textColor = [UIColor whiteColor];
    _noticeLabel.numberOfLines = 0;
    _noticeLabel.textAlignment = NSTextAlignmentLeft;
    _noticeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_noticeLabel];
//    [_noticeLabel release];
    
    //时间
    _timeBGView = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH-200)/2, (JX_SCREEN_HEIGHT -_recordBtn.frame.size.height -100-2), 200, 2)];
    _timeBGView.image = [UIImage imageNamed:@"timeBG"];
    [self.view addSubview:_timeBGView];
//    [_timeBGView release];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    _timeLabel.center = _timeBGView.center;
    _timeLabel.text = @"0:00";
    _timeLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_timeLabel];
//    [_timeLabel release];
    
    //返回上页
    _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP - 46, 46, 46)];
    [_backBtn setBackgroundImage:[[UIImage imageNamed:@"title_back_black_big"] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backBtn];
    
    //中止录制返回录制初始界面
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteBtn.frame = _backBtn.frame;
    [_deleteBtn setImage:[UIImage imageNamed:@"deleteAudio"] forState:UIControlStateNormal];
    [_deleteBtn setImage:[UIImage imageNamed:@"deleteAudio"] forState:UIControlStateSelected];
    [_deleteBtn addTarget:self action:@selector(stopAndReset:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deleteBtn];
    [self doShowBtn];
}

- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                } else {
                    bCanRecord = NO;
                }
            }];
        }
    }
    return bCanRecord;
}

-(void)recorderSetting{
    if (![self canRecord]) {
        [g_App performSelector:@selector(showAlert:) withObject:Localized(@"JX_CanNotOpenMicr") afterDelay:0];
        return;
    }
    _isRecording = NO;
    
    NSDictionary *settings=[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithFloat:8000],AVSampleRateKey,
                            [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                            [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                            [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                            nil];
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSURL *url = [NSURL fileURLWithPath:[FileInfo getUUIDFileName:@"wav"]];
    _pathURL = url;
    
    NSError *error;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:_pathURL settings:settings error:&error];
    _audioRecorder.delegate = self;
    
    [_audioRecorder prepareToRecord];
    [_audioRecorder setMeteringEnabled:YES];
    [_audioRecorder peakPowerForChannel:0];
    
}


-(void)doShowBtn{
    if (!_recordBtn.selected) {
        _recordBtn.hidden = NO;
//        _playBtn.hidden = YES;
        _cancelBtn.hidden = YES;
        _confirmBtn.hidden = YES;
        _timeBGView.hidden = YES;
        _timeLabel.hidden = YES;
        _noticeLabel.hidden = NO;
        _backBtn.hidden = NO;
        _deleteBtn.hidden = YES;
        //_recorder麦克风
        [_recordBtn setImage:[UIImage imageNamed:@"tapToStartRecorderAudio"] forState:UIControlStateNormal];
        _recorderNoticeLabel.text = Localized(@"JX_Recorder");
        _timeCount = 0;
        _timeLabel.text = @"0:00";
        
    } else {
        if (!_audioRecorder.isRecording) {//不在录制状态，暂停中
            _recordBtn.hidden = NO;
//            _playBtn.hidden = YES;
            _cancelBtn.hidden = YES;
            _confirmBtn.hidden = YES;
            _timeBGView.hidden = NO;
            _timeLabel.hidden = NO;
            _noticeLabel.hidden = NO;
            _backBtn.hidden = YES;
            _deleteBtn.hidden = NO;
            //_recorderBtn方块
            [_recordBtn setImage:[UIImage imageNamed:@"stopPlayAudio"] forState:UIControlStateSelected];
            _recorderNoticeLabel.text = Localized(@"JXAudioRecorder_PauseRecorder");
        }else{
            _recordBtn.hidden = NO;
//            _playBtn.hidden = NO;
            _cancelBtn.hidden = NO;
            _confirmBtn.hidden = NO;
            _timeBGView.hidden = YES;
            _timeLabel.hidden = NO;
            _noticeLabel.hidden = YES;
            _backBtn.hidden = YES;
            _deleteBtn.hidden = YES;
            //_recorderBtn三角
            [_recordBtn setImage:[UIImage imageNamed:@"playAudio"] forState:UIControlStateSelected];
            _recorderNoticeLabel.text = Localized(@"JXAudioRecorder_ContinueRecorder");
        }
    }
}

-(void)audioRecorderClick:(UIButton *)sender{
    if (![self canRecord]) {
        [g_App showAlert:Localized(@"JX_CanNotOpenMicr")];
        return;
    }
    if(!_recordBtn.selected){//初次进入
        if (!_audioRecorder.isRecording) {
            _recordBtn.selected = YES;
            _timeCount = 0;
        }
    }
    if (_audioRecorder.isRecording) {
        [self doShowBtn];
        [self freeTimer];
        [_audioRecorder pause];
    }else{
        [self doShowBtn];
        [self freeTimer];
        if([_audioRecorder record]){
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self  selector:@selector(updateTimerCount:) userInfo:nil repeats: YES];
        }
    }
}

-(void)cancelBtnClick:(UIButton *)sender{
    [self freeTimer];
    [self back];
}

-(void)confirmAudio:(UIButton *)sender{
    
    if (_timeCount <= 0) {
        [g_server showMsg:Localized(@"JX_RecordingTooShort")];
        return;
    }
    
    [self freeTimer];
    [_audioRecorder stop];
    
    NSString *amrPath = [VoiceConverter wavToAmr:_pathURL.path];
    [[ChatCacheFileUtil sharedInstance] deleteWithContentPath:_pathURL.path];
    _lastRecordFile = [amrPath copy];
    
    NSLog(@"音频文件路径:%@\n%@",_pathURL.path,amrPath);
    
    if(amrPath == nil){
        [g_App showAlert:Localized(@"JXAudioRecorder_NotRecorder")];
        return;
    }
    if (delegate && [delegate respondsToSelector:@selector(JXaudioRecorderDidFinish:TimeLen:)] ) {
        if (_timeCount < 1) {
            _timeCount = 1;
        }
        [delegate JXaudioRecorderDidFinish:_lastRecordFile TimeLen:_timeCount];
    }
    [super actionQuit];
}

-(void)back{
    [self freeTimer];
    [_audioRecorder stop];
    [_audioRecorder deleteRecording];
    
    [super actionQuit];
}

-(void)stopAndReset:(UIButton *)sender{
    [self freeTimer];
    [_audioRecorder stop];
    [_audioRecorder deleteRecording];
    _recordBtn.selected = NO;
    [self doShowBtn];
}

-(void)updateTimerCount:(NSTimer *) timer{
    _timeCount += 1;
    int n;
    if(_maxTime>0)
        n = _maxTime - _timeCount;
    else
        n = _timeCount;
    int min = n / 60;
    int second = n - min*60;
    NSString * timeString = [NSString stringWithFormat:@"%d:%02d",min,second];
    _timeLabel.text = timeString;
    
    if(_maxTime>0)
        if(n<=0)
            [self confirmAudio:nil];
}

-(void)freeTimer{
    [_timer invalidate];
    _timer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)resume{
    //默认情况下扬声器播放
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    audioSession = nil;
}

@end
