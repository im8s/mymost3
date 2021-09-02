#include <CoreFoundation/CoreFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "MixerHostAudio.h"
#import "recordAudioVC.h"
#import "UIImage-Extensions.h"

/*
void audioRouteChangeListenerCallback1 ( void   *inUserData,  AudioSessionPropertyID  inPropertyID,  UInt32 inPropertyValueSize,  const void  *inPropertyValue ){
    if(inUserData == nil)
        return;
    recordViewController *jxrecorder = (recordViewController *) inUserData;
    if(!jxrecorder.view.userInteractionEnabled)
        return;
    
    CFDictionaryRef       routeChangeDictionary = inPropertyValue;
    CFNumberRef routeChangeReasonRef = CFDictionaryGetValue (routeChangeDictionary,CFSTR (kAudioSession_AudioRouteChangeKey_Reason));
    
    SInt32 routeChangeReason;
    CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    
    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable)
    {
        [jxrecorder pause:nil];
        
        BOOL b = [jxrecorder getHeadsetMode];
        jxrecorder.isHeadsetTrue = b;
        [jxrecorder headsetChanged:b];
    }
    if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable)
    {
        // Headset is plugged in..
        BOOL b = [jxrecorder getHeadsetMode];
        jxrecorder.isHeadsetTrue = b;
        [jxrecorder headsetChanged:b];
    }
    jxrecorder = nil;
}*/

@implementation recordAudioVC
@synthesize delegate;
@synthesize didRecord;
@synthesize timeLen;
@synthesize outputFileName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self  = [super initWithNibName:nil bundle:nil];
    //self.view.frame = g_window.bounds;
    self.view.backgroundColor = [UIColor blackColor];
    [self build];
    [self prepareToRecord];
    _pSelf = self;
    return self;
}

-(void)dealloc{
    [self stop:nil];
//    [_mixRecorder release];
//    NSLog(@"recordAudioVC.dealloc");
//    [super dealloc];
}

-(void)build{
    _iv = [[JXImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-200)];
    _iv.userInteractionEnabled = YES;
    [self.view addSubview:_iv];
//    [_iv release];
    
    _effectType = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _iv.frame.size.height, JX_SCREEN_WIDTH, 80)];
    _effectType.backgroundColor = HEXCOLOR(0x111111);
    [self.view addSubview:_effectType];
//    [_effectType release];

    UIView* bottom = [[UIView alloc] initWithFrame:CGRectMake(0, _iv.frame.size.height+80, JX_SCREEN_WIDTH, 120)];
    bottom.backgroundColor = HEXCOLOR(0x111111);
    [self.view addSubview:bottom];
//    [bottom release];

    int n = 5;
    _effectType.contentSize = CGSizeMake((n+1) * 80, _effectType.frame.size.height);
    for(int i=0;i<n;i++){
        JXImageView* iv = [[JXImageView alloc]initWithFrame:CGRectMake(i*70+5, 2, 65, 65)];
        iv.delegate = self;
        iv.userInteractionEnabled = YES;
        iv.layer.cornerRadius = 6;
        iv.layer.masksToBounds = YES;
        iv.didTouch = @selector(onType);
        iv.animationType = JXImageView_Animation_Line;
        iv.tag = i;
        iv.image = [UIImage imageNamed:@"Accelerate_Audio"];
        [_effectType addSubview:iv];
//        [iv release];
    }

    _volume = [[JXImageView alloc]initWithFrame:CGRectMake(0, 0, 106/2, 192/2)];
    _volume.center = _iv.center;
    _volume.image = [UIImage imageNamed:@"pub_recorder"];
    [_iv addSubview:_volume];
//    [_volume release];
    
    _input = [[JXImageView alloc]initWithFrame:CGRectMake(9, 1, 34, 66)];//20,1,66,132
    _input.image = [UIImage imageNamed:@"pub_microphone_volume"];
    [_volume addSubview:_input];
//    [_input release];

    _btnPlay = [[JXImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    _btnPlay.center = _iv.center;
    _btnPlay.image = [UIImage imageNamed:@"rss_post_play"];
    _btnPlay.didTouch = @selector(onPlay);
    _btnPlay.delegate = self;
    [_iv addSubview:_btnPlay];
//    [_btnPlay release];
    _player = [[JXAudioPlayer alloc]initWithParent:_btnPlay];
    _player.isOpenProximityMonitoring = NO;
    
    _btnBack = [[JXImageView alloc]initWithFrame:CGRectMake(40, 30, 40, 40)];
    _btnBack.image = [UIImage imageNamed:@"navi_arrow_left_white"];
    _btnBack.didTouch = @selector(onBack);
    _btnBack.delegate = self;
    [bottom addSubview:_btnBack];
//    [_btnBack release];
    
    _btnDel = [[JXImageView alloc]initWithFrame:CGRectMake(40, 30, 40, 40)];
    _btnDel.image = [UIImage imageNamed:@"shareactivity_delete"];
    _btnDel.didTouch = @selector(onDel);
    _btnDel.delegate = self;
    [bottom addSubview:_btnDel];
//    [_btnDel release];
    
    _btnEnter = [[JXImageView alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-80, 30, 60, 60)];
    _btnEnter.image = [UIImage imageNamed:@"alert_tick"];
    _btnEnter.didTouch = @selector(onEnter);
    _btnEnter.delegate = self;
    [bottom addSubview:_btnEnter];
//    [_btnEnter release];
    
    _btnRecord = [[JXImageView alloc]initWithFrame:CGRectMake((JX_SCREEN_WIDTH-68)/2, 20, 68, 69)];
    _btnRecord.image = [UIImage imageNamed:@"publish_toolbar_record_normal"];
    _btnRecord.didTouch = @selector(onRecord);
    _btnRecord.delegate = self;
    [bottom addSubview:_btnRecord];
//    [_btnRecord release];

    _lb = [[UILabel alloc]initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-20, JX_SCREEN_WIDTH, 20)];
    _lb.text = @"";
    _lb.font = g_UIFactory.font11;
    _lb.backgroundColor = [UIColor clearColor];
    _lb.textColor = [UIColor whiteColor];
    [bottom addSubview:_lb];
//    [_lb release];

    [self doShowBtn];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showVolPeak:(NSTimer *) timer {
    if(![_mixRecorder isPlaying])
        return;
    float n = [_mixRecorder displayInputLevelLeft]-0.13;
    float m = 1-n;
    _input.frame  =  CGRectMake(9, 1+66*m, 34, 66*n);
    _input.image = [UIImage imageNamed:@"pub_microphone_volume"];
    _input.image = [_input.image imageAtRect:CGRectMake(0, _input.image.size.height*m, _input.image.size.width, _input.image.size.height*n)];
}

- (IBAction) micFxSelectorChanged: (UISegmentedControl *) sender {
    NSInteger n = mFxType.selectedSegmentIndex;
    switch (n) {
        case 0:
            _mixRecorder.isEffecter = NO;
//            if(sender)
//                [self showMessage:@"本色演出，录音将不做特效处理" wait:3];
            break;
        case 1:
            _mixRecorder.isEffecter = YES;
            _mixRecorder.micFxType = 1;
            _mixRecorder.micFxControl = 0.8;
//            if(sender)
//                [self showMessage:@"录音将变化成女声，萌吗" wait:3];
            break;
        case 2:
            _mixRecorder.isEffecter = YES;
            _mixRecorder.micFxType = 2;
            _mixRecorder.micFxControl = 0.2;
//            if(sender)
//                [self showMessage:@"混响很小，模拟录音棚滋润音色" wait:3];
            break;
        case 3:
            _mixRecorder.isEffecter = YES;
            _mixRecorder.micFxType = 3;
//            if(sender)
//                [self showMessage:@"混响中等，模拟KTV大包房效果" wait:3];
            break;
        case 4:
            _mixRecorder.isEffecter = YES;
            _mixRecorder.micFxType = 4;
//            if(sender)
//                [self showMessage:@"混响较强，模拟演唱会的大空间和效果" wait:3];
            break;
    }
}

- (void)pause:(id)sender
{
    if(_startOutput)
        return;
    [_mixRecorder pause];
}

/* Display AVMetadataCommonKeyTitle and AVMetadataCommonKeyCopyrights metadata. */
- (void)stop:(id)sender
{
	if ([_mixRecorder isPlaying])
        [_mixRecorder pause];
    [_mixRecorder stop];
}

-(void)prepareToRecord{
    _mixRecorder = [[MixerHostAudio alloc] init];
    _mixRecorder.isPlayer   = NO;
    _mixRecorder.isIOS5     = YES;
    _mixRecorder.isIOS6     = YES;
    _mixRecorder.isRecorder = YES;
    _mixRecorder.isEffecter = YES;
    _mixRecorder.isMixSave  = NO;
    _mixRecorder.isOutputer = YES;
    _mixRecorder.delegate   = self;
    _mixRecorder.isPlayMic  = NO;
    _mixRecorder.isReadFileToMemory = NO;
    [_mixRecorder setup];
    _mixRecorder.isEffecter = NO;
    
//    NSLog(@"%d,%d,%@",_mixRecorder.isPlayer,_mixRecorder.isMixSave,_mixRecorder.importAudioFile);
    [self micFxSelectorChanged:mFxType];
    
    _mixRecorder.outputAudioFile = [FileInfo getUUIDFileName:@"mp3"];
    _mixRecorder.volumeRecorder = 1;//必须在暂停前面
    [_mixRecorder pause];
    [_mixRecorder start];
}

-(NSString*)getHardwareId{
    char s[100]={0},t[100]={0};
    [g_macAddress getCString:s];
    int j=0;
    for(int i=0;i<strlen(s);i++){
        if(s[i] == ':')
            continue;
        else{
            t[j] = s[i];
            j++;
        }
    }
    return [NSString stringWithCString:t];
}

-(void)onDel{
    [_mixRecorder stop];
    [_mixRecorder delete];
    [_mixRecorder pause];
    [_mixRecorder start];
}

-(void)onPlay{
//    NSURL* url = [[NSURL alloc] initFileURLWithPath:_mixRecorder.outputAudioFile];
    _player.audioFile = _mixRecorder.outputAudioFile;
}

-(void)onBack{
    //返回前移除
    [self freeTimer];
    [_mixRecorder stop];
    [_mixRecorder delete];
//    [self.view removeFromSuperview];
    [g_navigation dismissViewController:self animated:YES];
    _pSelf = nil;
//    [self release];
}

-(void)doShowBtn{
        if(_btnRecord.selected){
            _volume.hidden  = NO;
            _input.hidden   = NO;
            _btnBack.hidden = YES;
            _btnDel.hidden  = NO;
            _btnPlay.hidden = YES;
            _btnEnter.enabled = NO;
        }
        else{
            _volume.hidden  = YES;
            _input.hidden   = YES;
            _btnBack.hidden = NO;
            _btnDel.hidden  = YES;
            _btnPlay.hidden = NO;
            _btnEnter.enabled = YES;
        }
}

-(void)onRecord{
    _btnRecord.selected = !_btnRecord.selected;
    [self doShowBtn];
    if(!_btnRecord.selected){
        _btnRecord.image = [UIImage imageNamed:@"publish_toolbar_record_normal"];
        [self freeTimer];
        [_mixRecorder pause];
    }
    else{
        _btnRecord.image = [UIImage imageNamed:@"pub_record_button_4i_h"];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self  selector:@selector(showVolPeak:) userInfo:nil repeats: YES];
        [_mixRecorder play];
    }
}

-(void)onEnter{
    [self freeTimer];
    [_mixRecorder stop];
    self.outputFileName = _mixRecorder.outputAudioFile;
    self.timeLen = _mixRecorder.timeLenRecord;
    if (delegate && [delegate respondsToSelector:didRecord])
//		[delegate performSelector:didRecord withObject:self];
        [delegate performSelectorOnMainThread:didRecord withObject:self waitUntilDone:NO];
//    [g_notify postNotificationName:kNewAudioNotifaction object:_mixRecorder.outputAudioFile userInfo:nil];
    [self.view removeFromSuperview];
    _pSelf = nil;
}

-(void)freeTimer{
    [_timer invalidate];
    _timer = nil;

}

@end
