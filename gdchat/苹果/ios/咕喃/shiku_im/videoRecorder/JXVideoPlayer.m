//
//  JXVideoPlayer.m
//  shiku_im
//
//  Created by flyeagleTang on 17/1/12.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXVideoPlayer.h"
#import "UIImage+Color.h"

@implementation JXVideoPlayer
@synthesize parent=_parent,videoFile=_videoFile,player=_player;

- (id)initWithParent:(UIView*)value{
    self = [super init];
    if (self) {
        _player = nil;
        if (self.isShowHide == YES) { // 只能作聊天界面进入后的判断
            self.isScreenPlay = YES;
        }
        
        self.parent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, value.bounds.size.width, value.bounds.size.height)];
        self.parent.backgroundColor = [UIColor clearColor];
        [value addSubview:self.parent];
        
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self.parent addGestureRecognizer:longPress];

        UIScreenEdgePanGestureRecognizer *screenPan = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(screenPanAction:)];
        screenPan.edges = UIRectEdgeLeft;
        [self.parent addGestureRecognizer:screenPan];
        
//        self.parent = value;
        self.isPlaying = NO;
        // 添加上下两个地方的透明模板
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, THE_DEVICE_HAVE_HEAD ? 62 : 42)];
        _botView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-90, JX_SCREEN_WIDTH, 90)];
        [self setupView:_topView colors:@[(__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor,(__bridge id)[UIColor clearColor].CGColor]];
        [self setupView:_botView colors:@[(__bridge id)[UIColor clearColor].CGColor,(__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor]];
        _topView.hidden = YES;
        _botView.hidden = YES;
        [_parent addSubview:_topView];
        [_parent addSubview:_botView];
        [_parent bringSubviewToFront:_topView];
        [_parent bringSubviewToFront:_botView];

        _pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, _botView.frame.size.height-57, 26, 26)];
        [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
        [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateSelected];
        [_pauseBtn addTarget:self action:@selector(switch) forControlEvents:UIControlEventTouchUpInside];
        _pauseBtn.hidden = YES;
        [_botView addSubview:_pauseBtn];
//        [_parent bringSubviewToFront:_pauseBtn];

        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(60, _botView.frame.size.height-52, 40, 13)];
        _timeLab.textAlignment = NSTextAlignmentCenter;
        _timeLab.font = [UIFont systemFontOfSize:10];
        _timeLab.textColor = [UIColor whiteColor];
        [_botView addSubview:_timeLab];
//        [_parent bringSubviewToFront:_timeLab];
        
        _timeEnd = [[UILabel alloc] initWithFrame:CGRectMake(_botView.frame.size.width-50, _botView.frame.size.height-52, 40, 13)];
        _timeEnd.textAlignment = NSTextAlignmentCenter;
        _timeEnd.font = [UIFont systemFontOfSize:10];
        _timeEnd.textColor = [UIColor whiteColor];
        [_botView addSubview:_timeEnd];
//        [_parent bringSubviewToFront:_timeEnd];
        
//        _outBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
//        [_outBtn setImage:[UIImage imageNamed:@"playvideo"] forState:UIControlStateNormal];
//        _outBtn.center = CGPointMake(_parent.frame.size.width/2,_parent.frame.size.height/2);
//        [_outBtn addTarget:self action:@selector(switch) forControlEvents:UIControlEventTouchUpInside];
//        if (self.isShowHide == YES) _outBtn.hidden = YES; // 只能作聊天界面进入后的判断
//        [_parent addSubview:_outBtn];
//        [_parent bringSubviewToFront:_outBtn];
        
        //进度条
        _movieTimeControl = [[UISlider alloc] initWithFrame:CGRectMake(100, _botView.frame.size.height-50, _botView.frame.size.width-160, 10)];
        _movieTimeControl.maximumTrackTintColor = [UIColor lightGrayColor];
        _movieTimeControl.minimumTrackTintColor = [UIColor whiteColor];
        _movieTimeControl.continuous = YES;
        _movieTimeControl.minimumValue = 0;
        _movieTimeControl.maximumValue = _timeLen;
        
        [_movieTimeControl setThumbImage:[UIImage scaleToSize:[UIImage imageNamed:@"circular"] size:CGSizeMake(14, 14)] forState:UIControlStateNormal];
        [_botView addSubview:_movieTimeControl];
//        [_parent bringSubviewToFront:_movieTimeControl];
        
        //显示第一帧图片
        _firstBaseView = [[UIView alloc] initWithFrame:_parent.bounds];
        _firstBaseView.backgroundColor = [UIColor blackColor];
        [_parent addSubview:_firstBaseView];
        CGRect frame = THE_DEVICE_HAVE_HEAD ? CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_TOP-JX_SCREEN_BOTTOM) : _firstBaseView.bounds;
//        CGRect frame = _firstBaseView.bounds;
        _videoFirst = [[UIImageView alloc] initWithFrame:frame];
        [_firstBaseView addSubview:_videoFirst];
        [FileInfo getFullFirstImageFromVideo:_videoFile imageView:_videoFirst];
        
        _wait = [[JXWaitView alloc] initWithParent:_firstBaseView];
        [_wait start];

//        [g_notify addObserver:self selector:@selector(playerStop:) name:kAllVideoPlayerStopNotifaction object:nil];//开始录音
//        [g_notify addObserver:self selector:@selector(playerPause:) name:kAllVideoPlayerPauseNotifaction object:nil];//开始录音
        [g_notify addObserver:self selector:@selector(AVPlayerStopNotif:) name:kAVPlayerStopNotification object:nil];
        [g_notify addObserver:self selector:@selector(EnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [g_notify addObserver:self selector:@selector(EnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        
        [self performSelector:@selector(firstBaseViewAddTap) withObject:nil afterDelay:1];
    }
    return self;
}

- (void)AVPlayerStopNotif:(NSNotification *)notif {
    
    [self stop];
}

- (void)firstBaseViewAddTap {
    if (_firstBaseView) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(firstViewAction:)];
        [_firstBaseView addGestureRecognizer:tap];
    }
}

- (void)firstViewAction:(UITapGestureRecognizer *)tap {
    if (self.type != JXVideoTypePreview) {  // 如果不是预览界面
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
#ifdef IS_SHOW_MENU
#else
    g_mainVC.bottomView.hidden = NO;
#endif
    [_topView removeFromSuperview];
    [_botView removeFromSuperview];
    [_parent removeFromSuperview];
    [_videoFirst removeFromSuperview];
    [_firstBaseView removeFromSuperview];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stop];
        [_player.view removeFromSuperview];
        _player.view = nil;
        _player = nil;
    });
    _parent = nil;
}

// 进入后台
-(void)EnterBackground{
    if(_player.isOpened){
        // 调用暂停
        [self pause];
    }
}
//进入前台
-(void)EnterForeground{
    if(_player.isOpened){
        //播放
        [self play];
    }
}

// 长按
- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (self.isReadDel) {
        return;
    }
    JXActionSheetVC *actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:@[Localized(@"JX_SaveVideo")]];
    actionVC.delegate = self;
    [g_navigation.subViews.lastObject presentViewController:actionVC animated:NO completion:nil];
}
-(void)screenPanAction:(UIScreenEdgePanGestureRecognizer *)screenPan
{
    
}

- (void)actionSheet:(JXActionSheetVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    
    if ([_videoFile rangeOfString:@"http"].location != NSNotFound) {
        
        [self playerDownload:_videoFile];
    }else {
        [self saveVideo:_videoFile];
    }
    
}

//-----下载视频--
- (void)playerDownload:(NSString *)url{
   
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString  *fullPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"jaibaili.mp4"];
    NSURL *urlNew = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlNew];
    NSURLSessionDownloadTask *task =
    [manager downloadTaskWithRequest:request
                            progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                return [NSURL fileURLWithPath:fullPath];
                            }
                   completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                       [self saveVideo:fullPath];
                   }];
    [task resume];
    
}

//videoPath为视频下载到本地之后的本地路径
- (void)saveVideo:(NSString *)videoPath{
    
    if (videoPath) {
        NSURL *url = [NSURL URLWithString:videoPath];
        BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([url path]);
        if (compatible)
        {
            //保存相册核心代码
            UISaveVideoAtPathToSavedPhotosAlbum([url path], self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}


//保存视频完成之后的回调
- (void) savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    if (error) {
        NSLog(@"保存视频失败%@", error.localizedDescription);
        
        [g_server showMsg:Localized(@"JX_SaveFiled") delay:.5];
    }
    else {
        NSLog(@"保存视频成功");
        [g_server showMsg:Localized(@"JX_SaveSuessed") delay:.5];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString  *fullPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"jaibaili.mp4"];
    
    [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
}


- (void)dealloc {
    NSLog(@"JXVideoPlayer.dealloc");
    self.parent = nil;
    self.videoFile = nil;
//    [_pauseBtn release];
    [g_notify removeObserver:self];
    [self stop];
//    [super dealloc];
}

- (void)exitVideoPlayer {
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didExitBtn])
        [self.delegate performSelectorOnMainThread:self.didExitBtn withObject:self waitUntilDone:NO];
    [self doPlayEnd];
    [self stop];
    if (self.type != JXVideoTypePreview) {  // 如果不是预览界面
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
#ifdef IS_SHOW_MENU
#else
    g_mainVC.bottomView.hidden = NO;
#endif
    [_topView removeFromSuperview];
    [_botView removeFromSuperview];
    [_parent removeFromSuperview];
    [_videoFirst removeFromSuperview];
    [_firstBaseView removeFromSuperview];
    [_player.view removeFromSuperview];
    _player.view = nil;
    _parent = nil;
}

-(void)stop{
    if(_player == nil)
        return;
    [_player stop];
    [_player.view removeFromSuperview];
//    [_player release];
    _player = nil;
}

- (void)switch{
    
#ifdef IS_SHOW_MENU
#else
    if(self.type == JXVideoTypeWeibo) {
        g_mainVC.bottomView.hidden = YES;
    }
#endif
    _pauseBtn.hidden = NO;
    if(_player.isOpened){
        if(_player.isPlaying)
            [self pause];
        else
            [self play];
    }else{
        [self start];
        [self play];
    }
}

-(void)play{
    [g_notify postNotificationName:kAllVideoPlayerPauseNotifaction object:self userInfo:nil];
    [g_notify postNotificationName:kAllAudioPlayerPauseNotifaction object:self userInfo:nil];
    if (self.isShowHide) { // 聊天界面全屏播放隐藏状态栏
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    if (self.isStartFullScreenPlay) {
        [self actionFullScreen];
    }
    if(_player.isOpened){
        if(!_player.isPlaying){
            [_player play:nil];
            [self doPlayBegin];
        }
    }
    _exitBtn.hidden = NO;
}

-(void)pause{
    if(_player.isOpened)
        if(_player.isPlaying){
            [_player pause:nil];
            [self doPause];
        }
}

//显示播放器
- (void)start{
    _player = [[JXVideoPlayerVC alloc] init];
    _player.isVideo = self.isVideo;
    _player.pauseButton = _pauseBtn;
    _player.delegate = self;
    _player.parent = _parent;
    _player.timeCur = _timeLab;
    _player.timeEnd = _timeEnd;
    _player.movieTimeControl = _movieTimeControl;
    _player.didClick = @selector(onClickVideo:);
    _player.didPlayNext = @selector(didPlayEnd);
    _player.didOpen = @selector(doVideoOpen);
    

    NSString *filePath = [NSString stringWithFormat:@"%@%@",myTempFilePath,[self.videoFile lastPathComponent]];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        [_player open:filePath];
    else
        [_player open:self.videoFile];
    
    [_player setFrame:_parent.bounds];
    
    // 添加左上角叉
    _exitBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [_exitBtn addTarget:self action:@selector(exitVideoPlayer) forControlEvents:UIControlEventTouchUpInside];
    if (!self.isPlaying) _exitBtn.hidden = YES;  // 如果没在播放就隐藏
    _exitBtn.hidden = YES;
    [_topView addSubview:_exitBtn];
    [_topView bringSubviewToFront:_exitBtn];
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(25, 25, 16, 16)];
    imgV.image = [UIImage imageNamed:@"fork_white"];
    [_exitBtn addSubview:imgV];

    _timeEnd.text = [self formatTime:_timeLen];
    if (_isPreview) {  // 预览界面处理
        _timeEnd.hidden = YES;
        _player.movieTimeControl.hidden = YES;
        _pauseBtn.hidden = YES;
        _exitBtn.hidden = YES;
        _timeLab.hidden = YES;
        _exitBtn.hidden = YES;
        _disBtn = [self createButtonWithFrame:CGRectMake(20, JX_SCREEN_HEIGHT-20-80, 80, 80) image:@"video_return" action:@selector(exitVideoPlayer)];
        _sendBtn = [self createButtonWithFrame:CGRectMake(JX_SCREEN_WIDTH-20-80, JX_SCREEN_HEIGHT-20-80, 80, 80) image:@"video_gou" action:@selector(didButtonWithSendVideo)];
        
        [_player.view addSubview:_disBtn];
        [_player.view addSubview:_sendBtn];

    }

}

//播放视频被点击
- (void)onClickVideo:(id)sender{
    if (self.type == JXVideoTypePreview) {
        return;
    }
    _topView.hidden = !_topView.hidden;
    _botView.hidden = !_botView.hidden;
//    if (_player.isPlaying && _isShowHide == NO) {
//        [self actionFullScreen];
//    }
}

- (void)dismissVideoPlayer {
    if (self.type == JXVideoTypeChat) {
        _topView.hidden = NO;
        _botView.hidden = NO;
    }

}

- (void)didPlayEnd{
    self.isEndPlay = YES;
    if (!_isPreview) {
        [self dismissVideoPlayer];
    }
    [self doPlayEnd];
    if (_player.isFullScreen) {
        [self actionFullScreen];
    }
}

//全屏播放
- (void)actionFullScreen{
    if (_isShowHide == YES) {
        return;
    }
    if (_player.isVideo) {
        if (_player.isFullScreen) {
//            [_player setFrame:_parent.bounds];
//            [_parent addSubview:_player.view];
//            [self adjust];
        }else{
            [_player setFrame:g_window.bounds];
            [self.parent addSubview:_player.view];
            [self.parent bringSubviewToFront:_player.view];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            [_player.view addSubview:_topView];
            [_player.view addSubview:_botView];
            [_exitBtn addTarget:self action:@selector(nowExitVideoPlayer) forControlEvents:UIControlEventTouchUpInside];
        }
        _player.isFullScreen = !_player.isFullScreen;
//        [_player setSliderHidden:_player.isFullScreen];
        [_player set90];
    }
}

- (void)nowExitVideoPlayer {
    _isEndPlay = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [_player stop];
    [_player setFrame:_parent.bounds];
    [_parent addSubview:_player.view];
    [self adjust];
    _exitBtn.hidden = YES;
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

-(void)adjust{
    [_player.view removeFromSuperview];
    if(_parent==nil)
        return;
    [_parent addSubview:_player.view];
    [_player setFrame:_parent.bounds];
//    if (_isScreenPlay == NO || !_isStartFullScreenPlay) {
//        _outBtn.center = CGPointMake(_parent.frame.size.width/2,_parent.frame.size.height/2);
//    }
    
    [_parent addSubview:_topView];
    [_parent addSubview:_botView];
    [_parent bringSubviewToFront:_topView];
    [_parent bringSubviewToFront:_botView];

//    [_parent addSubview:_outBtn];
//    [_parent bringSubviewToFront:_outBtn];
//
//    [_parent addSubview:_pauseBtn];
//    [_parent bringSubviewToFront:_pauseBtn];
//
//    [_parent addSubview:_timeLab];
//    [_parent bringSubviewToFront:_timeEnd];
//
//    [_parent addSubview:_timeEnd];
//    [_parent bringSubviewToFront:_timeLab];
//
//    [_parent addSubview:_movieTimeControl];
//    [_parent bringSubviewToFront:_movieTimeControl];
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

-(void)setVideoFile:(NSString *)value{
    [self adjust];
    [_player stop];
    if([_videoFile isEqual:value])
        return;
    NSLog(@"vidoe:%@",value);
//    [_videoFile release];
//    _videoFile = [value retain];
    _videoFile = value;
    NSString* s = [_videoFile lowercaseString];
    self.isVideo = [s rangeOfString:@".mp4"].location != NSNotFound
                || [s rangeOfString:@".qt"].location != NSNotFound
                || [s rangeOfString:@".mpg"].location != NSNotFound
                || [s rangeOfString:@".mov"].location != NSNotFound
                || [s rangeOfString:@".avi"].location != NSNotFound;
}

-(void)setIsVideo:(BOOL)value{
    _isVideo = value;
    if(self.isVideo){
        [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
        [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateSelected];
    }else{
        [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"feeds_play_btn_u"] forState:UIControlStateNormal];
        [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"feeds_play_btn_h_u"] forState:UIControlStateSelected];
    }
}


-(void)doVideoOpen{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self adjust];
        [_wait stop];
    });
    self.isPlaying = NO;
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didVideoOpen])
        [self.delegate performSelectorOnMainThread:self.didVideoOpen withObject:self waitUntilDone:NO];
    if (_isPreview) _pauseBtn.hidden = YES;  //预览界面 隐藏暂停按钮
}

-(void)doPlayEnd{
    if (_isPreview || self.type == JXVideoTypeWeibo) {
        [self switch];
        return;
    }
    self.isPlaying = NO;
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didVideoPlayEnd])
        [self.delegate performSelectorOnMainThread:self.didVideoPlayEnd withObject:self waitUntilDone:NO];
}

-(void)doPlayBegin{
    self.isPlaying = YES;
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didVideoPlayBegin])
        [self.delegate performSelectorOnMainThread:self.didVideoPlayBegin withObject:self waitUntilDone:NO];
}

-(void)doPause{
    self.isPlaying = NO;
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didVideoPause])
        [self.delegate performSelectorOnMainThread:self.didVideoPause withObject:self waitUntilDone:NO];
}

-(void)setHidden:(BOOL)value{
    _pauseBtn.hidden = value;
    _timeLab.hidden = value;
}

-(void)setTimeLen:(int)value{
    _timeLen = value;
    _timeLab.text = [self formatTime:value];
}

- (NSString *) formatTime:(NSTimeInterval)num
{
    int n = num;
    int secs = n % 60;
    int min = n / 60;
    if (num < 60) return [NSString stringWithFormat:@"0:%02d", n];
    return	[NSString stringWithFormat:@"%d:%02d", min, secs];
}


- (void)didButtonWithSendVideo {
    if (self.delegate && [self.delegate respondsToSelector:self.didSendBtn]) {
        [_player stop];
        [self.delegate performSelectorOnMainThread:self.didSendBtn withObject:self waitUntilDone:NO];
    }
}


- (UIButton *)createButtonWithFrame:(CGRect)frame image:(NSString *)image action:(SEL)action {
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    button.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = button.frame.size.width/2;
    [button setImage:[UIImage scaleToSize:[UIImage imageNamed:image] size:CGSizeMake(32, 32)] forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}


- (void)setupView:(UIView *)view colors:(NSArray *)colors {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 100);  // 设置显示的frame
    gradientLayer.colors = colors;  // 设置渐变颜色
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    [view.layer addSublayer:gradientLayer];
}

@end
