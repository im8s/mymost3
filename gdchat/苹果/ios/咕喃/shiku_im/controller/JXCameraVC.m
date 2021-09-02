//
//  JXCameraVC.m
//  shiku_im
//
//  Created by p on 2017/11/6.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXCameraVC.h"
#import "GPUImage.h"
#import "GPUImageBeautifyFilter.h"
#import "JXVideoPlayer.h"
#import "UIImage+Color.h"
#import "KKImageEditorViewController.h"

#define kCameraVideoPath [FileInfo getUUIDFileName:@"mp4"]

@interface JXCameraVC () <KKImageEditorDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) GPUImageStillCamera *stillCamera; // 拍照
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera; // 錄像
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter; // 存錄像

@property (nonatomic, strong) UIButton *photoCaptureButton;
@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic, strong) GPUImageBeautifyFilter *beautifyFilter;
@property (nonatomic, strong) NSArray *filterArray;
@property (nonatomic, strong) GPUImageFilterGroup *filterGroup;
@property (nonatomic, strong) GPUImageCropFilter *cropFilter;
@property (nonatomic, strong) NSMutableArray *photoStyleImages;

@property (nonatomic, strong) UILabel *noticeLabel;
@property (nonatomic, strong) UIImageView *timeBGView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, assign) NSInteger timerNum;
@property (nonatomic, assign) BOOL isRecording;

@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) JXVideoPlayer *player;

@property (nonatomic, strong) UIButton *beautyBtn;
@property (nonatomic, strong) GPUImageBrightnessFilter *normalFilter;

@property (nonatomic, assign) BOOL isNotPhoto; // 判断[self takePhoto]方法进入拍照还是视频录制

//美颜/滤镜属性
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIView *bigView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *bottomControlView;
@property (nonatomic, strong) UIButton *filterBtn;
@property (nonatomic, strong) UIButton *skinCareBtn;

@property (nonatomic, assign) BOOL isCreateFilter;
//// isRecoverHis = YES作用是 当前滤镜调整到正常后，要记录美颜中的磨皮和亮度的历史值
//@property (nonatomic, assign) BOOL isRecoverHis;
@property (nonatomic, strong) UISlider *bilateralSld;
@property (nonatomic, strong) UISlider *brightnessSld;

@property (nonatomic, assign) CGFloat bilHis;
@property (nonatomic, assign) CGFloat briHis;

@property (nonatomic, strong) GPUImageBilateralFilter *bilateralFilter;//  磨皮滤镜
@property (nonatomic, strong) GPUImageBrightnessFilter *brightnessFilter;// 美白滤镜
@property (nonatomic, strong) GPUImageToonFilter *toonfilter;
@property (nonatomic, strong) GPUImageFilter *filter;//滤镜

@end

@implementation JXCameraVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _photoStyleImages = [NSMutableArray array];
    _isRecording = NO;
    
    if([self cameraCount]<=0){
        [self performSelector:@selector(dismissViewControllerAnimated:completion:) withObject:nil afterDelay:0.5];
//        [self dismissViewControllerAnimated:YES completion:nil];
        [g_App performSelector:@selector(showAlert:) withObject:Localized(@"JXAlert_NoCenmar") afterDelay:1];
        return;
    }
    
    // Yes, I know I'm a caveman for doing all this by hand
    GPUImageView *primaryView = [[GPUImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    primaryView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchSkinCare)];
    [primaryView addGestureRecognizer:tap];
    // 添加上下两个地方的透明模板
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, THE_DEVICE_HAVE_HEAD ? 62 : 42)];
    UIView *botView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-90, JX_SCREEN_WIDTH, 90)];
    topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    botView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [primaryView addSubview:topView];
    [primaryView addSubview:botView];

    //中间录制按钮
    _photoCaptureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _photoCaptureButton.frame = CGRectMake(round(JX_SCREEN_WIDTH / 2.0 - 50.0 / 2.0), JX_SCREEN_HEIGHT - 70.0, 50.0, 50.0);
    [_photoCaptureButton setBackgroundImage:[UIImage imageNamed:_isPhoto ? @"start" : @"start_video"] forState:UIControlStateNormal];
//    [_photoCaptureButton addTarget:self action:@selector(singlePress:) forControlEvents:UIControlEventTouchUpInside];
    [_photoCaptureButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [primaryView addSubview:_photoCaptureButton];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singlePress:)];
    [_photoCaptureButton addGestureRecognizer:singleTap];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.5; //最小长按时间
    [_photoCaptureButton addGestureRecognizer:longPress];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, JX_SCREEN_HEIGHT - 60.0, 30, 30)];
    [cancelBtn setImage:[UIImage imageNamed:@"fork"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [primaryView addSubview:cancelBtn];
    
    UIButton *switchBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 45, JX_SCREEN_HEIGHT - 60.0, 30, 30)];
    [switchBtn setImage:[UIImage imageNamed:@"switch_cammer"] forState:UIControlStateNormal];
    [switchBtn addTarget:self action:@selector(switchBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [switchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [primaryView addSubview:switchBtn];
    
    self.view = primaryView;
    
    //    GPUImageGaussianBlurFilter * blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    //    blurFilter.blurRadiusInPixels = 2.0;
    
    dispatch_async(dispatch_get_global_queue(0, 0),^{
        // 处理耗时操作的代码块...
        if (self.isVideo) {
            [self initVideoCamera];
        }else if (self.isPhoto) {
            [self initPhotoCamera];
        }else {
    //        [self initPhotoCamera];
            _stillCamera = [[GPUImageStillCamera alloc] init];
            _videoCamera = _stillCamera;
            [self initVideoCamera];
        }
    });
    
    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
    if (_stillCamera.inputCamera.hasFlash || _videoCamera.inputCamera.hasFlash) {
        UIButton *flashBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, THE_DEVICE_HAVE_HEAD ? 32 : 12, 18, 18)];
        [flashBtn setImage:[UIImage imageNamed:@"automatic"] forState:UIControlStateNormal];
        [flashBtn addTarget:self action:@selector(flashBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [flashBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [primaryView addSubview:flashBtn];
    }
    // 显示美颜调整界面
    _beautyBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 30-18, THE_DEVICE_HAVE_HEAD ? 32 : 12, 18, 18)];
    _beautyBtn.selected = NO;
    [_beautyBtn setImage:[UIImage imageNamed:@"camra_beauty"] forState:UIControlStateNormal];
    [_beautyBtn addTarget:self action:@selector(beautyBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_beautyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [primaryView addSubview:_beautyBtn];
    
//    [self addPhotoStyle:primaryView];
    
    _iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
    _iv.backgroundColor = [UIColor blackColor];
    _iv.contentMode = UIViewContentModeScaleAspectFill;
    _iv.userInteractionEnabled = YES;
    _iv.hidden = YES;
    [primaryView addSubview:_iv];
    UIButton *cancelImageBtn = [self createButtonWithFrame:CGRectMake(20, JX_SCREEN_HEIGHT-20-80, 80, 80)  image:@"video_return" action:@selector(cancelImageBtnAction:)];
    [_iv addSubview:cancelImageBtn];
    
    UIButton *editBtn = [self createButtonWithFrame:CGRectMake(JX_SCREEN_WIDTH/2-40, JX_SCREEN_HEIGHT-20-80, 80, 80)  image:@"video_edit" action:@selector(editImageBtnAction:)];
    [_iv addSubview:editBtn];
    
    UIButton *confirmBtn = [self createButtonWithFrame:CGRectMake(JX_SCREEN_WIDTH-20-80, JX_SCREEN_HEIGHT-20-80, 80, 80) image:@"video_gou" action:@selector(confirmBtnAction:)];
    [_iv addSubview:confirmBtn];
    
    if (!self.isPhoto) {
        [self isVideoCustomView];
    }
}

- (void)initVideoCamera {
    if (self.isVideo) {
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    }
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [_videoCamera addAudioInputsAndOutputs];
    _videoCamera.horizontallyMirrorFrontFacingCamera = YES; // 镜像
//    [_videoCamera rotateCamera];

    if (THE_DEVICE_HAVE_HEAD) {
        _cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake((1.0 - (480.0/640.0 - 0.13)) / 2, 0.0, 480.0/640.0 - 0.13,1.0)];
    }else {
        _cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake((1.0 - 480.0/640.0) / 2, 0.0, 480.0/640.0 ,1.0)];
    }
    
    [self setFilterGroup];
    [_videoCamera addTarget:_filterGroup];
    
    [_videoCamera startCameraCapture];
    
    [_filter addTarget:_cropFilter];

    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
    if (_videoCamera.inputCamera.hasFlash) {
        [_videoCamera.inputCamera lockForConfiguration:nil];
        _videoCamera.inputCamera.flashMode = AVCaptureFlashModeAuto;
        [_videoCamera.inputCamera unlockForConfiguration];
    }
}

- (void)setFilterGroup {
    /// 滤镜分组
    _filterGroup = [[GPUImageFilterGroup alloc] init];
    
//    [self videoSetFilter];
    
    //  磨皮滤镜
    GPUImageBilateralFilter *bilateralFilter = [[GPUImageBilateralFilter alloc] init];
    [_filterGroup addFilter:bilateralFilter];
    _bilateralFilter = bilateralFilter;
    
    //  美白滤镜
    GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    [_filterGroup addFilter:brightnessFilter];
    [_bilateralFilter setDistanceNormalizationFactor:MAXFLOAT];
    _brightnessFilter = brightnessFilter;
    //  设置滤镜组链
    [bilateralFilter addTarget:brightnessFilter];
    [_filterGroup setInitialFilters:@[bilateralFilter]];
    _filterGroup.terminalFilter = brightnessFilter;

    // 添加滤镜
    GPUImageFilter*filter = [[GPUImageFilter alloc] init];
    [_filterGroup addTarget:filter];
    _filter = filter;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_filterGroup addTarget:(GPUImageView *)self.view];
    });
//    [_filterGroup addTarget:(GPUImageView *)self.view];
    
}

- (void)initPhotoCamera {
    if (!_stillCamera) {
        _stillCamera = [[GPUImageStillCamera alloc] init];
        _stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _stillCamera.horizontallyMirrorFrontFacingCamera = YES; // 镜像
        //    [_stillCamera addTarget:_beautifyFilter];
        //    GPUImageView *filterView = (GPUImageView *)self.view;
        //    [_beautifyFilter addTarget:filterView];
        [_stillCamera startCameraCapture];
    }
    
    [self setFilterGroup];
    
    [_stillCamera addTarget:_filterGroup];
    
    [_stillCamera startCameraCapture];

    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
    if (_stillCamera.inputCamera.hasFlash) {
        [_stillCamera.inputCamera lockForConfiguration:nil];
        _stillCamera.inputCamera.flashMode = AVCaptureFlashModeAuto;
        [_stillCamera.inputCamera unlockForConfiguration];
    }

}

#pragma mark - 单击拍照
- (void)singlePress:(UITapGestureRecognizer *)tap {
    if (self.isVideo) {
        return;
    }
    self.isNotPhoto = NO;
    [self takePhoto];
    [self hideTime];
}

#pragma mark - 长按录像
- (void)longPress:(UILongPressGestureRecognizer *)tap {
    if (self.isPhoto) {
        return;
    }
    if (tap.state == UIGestureRecognizerStateBegan) {
        self.isNotPhoto = YES;
        _isRecording = NO;
        [self takePhoto];
        [self showTime];
    }else if(tap.state == UIGestureRecognizerStateEnded) {
        self.isNotPhoto = YES;
        _isRecording = YES;
        [self takePhoto];
    }
}

#pragma mark - 拍照、录像事件处理
- (void)takePhoto {
    if (self.isNotPhoto) {
        
        if (!_isRecording) {
            [self.scrollView setHidden:YES];
            [_photoCaptureButton setBackgroundImage:[UIImage imageNamed:_isPhoto ? @"stop" :@"stop_video"] forState:UIControlStateNormal];
            _isRecording = YES;
            [self startPhoto];
            _recordTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordTimerAction:) userInfo:nil repeats:YES];
            //            [self noticnoticeLabelHiddeneLabelHidden:YES textType:1];
        }else {
            //            [self.scrollView setHidden:NO];
            
//            if (_timerNum <= 0) {
//                return;
//            }
            [_photoCaptureButton setBackgroundImage:[UIImage imageNamed:_isPhoto ? @"start" : @"start_video"] forState:UIControlStateNormal];
            _isRecording = NO;
            [_recordTimer invalidate];
            _recordTimer = nil;
            [self endRecording];
            
            _timerNum = 0;
            _timeLabel.text = @"00:00";
            
            _playerView = [[UIView alloc] initWithFrame:self.view.bounds];
            [self.view addSubview:_playerView];
            _player= [JXVideoPlayer alloc];
            _player.type = JXVideoTypePreview;
            _player.isShowHide = YES; //播放中点击播放器便销毁播放器
            _player.didSendBtn = @selector(didSendBtn:);
            _player.didExitBtn = @selector(didExitBtn:);
            _player.isStartFullScreenPlay = YES; //全屏播放
            _player.isPreview = YES; // 这是预览
            _player.delegate = self;
//            _player = [_player initWithParent:_playerView];
//            _player.parent = _playerView;
            _player.videoFile = self.outputFileName;
    
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _player = [_player initWithParent:_playerView];
                _player.parent = _playerView;
                [_player switch];
            });
            
            //            [self dismissViewControllerAnimated:YES completion:^{
            //
            //                if ([self.cameraDelegate respondsToSelector:@selector(cameraVC:didFinishWithVideoPath:timeLen:)]) {
            //                    [self.cameraDelegate cameraVC:self didFinishWithVideoPath:self.outputFileName timeLen:self.timerNum];
            //                }
            //
            //                _timerNum = 0;
            //            }];
            
        }
        
    }else{
        [_photoCaptureButton setEnabled:NO];
//        if (_beautyBtn.selected) {
//            [_stillCamera capturePhotoAsJPEGProcessedUpToFilter:_normalFilter withCompletionHandler:^(NSData *processedJPEG, NSError *error){
//
//                [_photoCaptureButton setEnabled:YES];
//                UIImage *image = [UIImage imageWithData:processedJPEG];
//                CGFloat scale = JX_SCREEN_WIDTH / JX_SCREEN_HEIGHT;
//                CGFloat width = image.size.height * scale;
//                image = [self getImageByCuttingImage:image Rect:CGRectMake((image.size.width - width) / 2, 0, width, image.size.height)];
//                _iv.image = image;
//                _iv.hidden = NO;
//
//            }];
//        }else {
            [_stillCamera capturePhotoAsJPEGProcessedUpToFilter:self.filter withCompletionHandler:^(NSData *processedJPEG, NSError *error){

                [_photoCaptureButton setEnabled:YES];
                UIImage *image = [UIImage imageWithData:processedJPEG];
                CGFloat scale = JX_SCREEN_WIDTH / JX_SCREEN_HEIGHT;
                CGFloat width = image.size.height * scale;
                image = [self getImageByCuttingImage:image Rect:CGRectMake((image.size.width - width) / 2, 0, width, image.size.height)];
                _iv.image = image;
                _iv.hidden = NO;
            }];
//        }
    }
}


// 随时切换模式
- (void)switchSkinCare {
    self.scrollView.hidden = !self.scrollView.hidden;
    
}

#pragma mark Device Counts
- (NSUInteger) cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 进入后隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 离开时显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self hideTime];
}

- (void)hideTime {
    _noticeLabel.hidden = YES;
    _timeLabel.hidden = YES;
    _timeBGView.hidden = YES;
}
- (void)showTime {
    _noticeLabel.hidden = NO;
    _timeLabel.hidden = NO;
    _timeBGView.hidden = NO;
}


// 录制视频专有UI
- (void) isVideoCustomView{
    _noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, JX_SCREEN_WIDTH-45*2, 45)];
    _noticeLabel.center = self.view.center;
    _noticeLabel.textColor = [UIColor whiteColor];
    _noticeLabel.font = SYSFONT(15);
    _noticeLabel.numberOfLines = 2;
    _noticeLabel.backgroundColor = [UIColor clearColor];
    _noticeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_noticeLabel];
    //    [_noticeLabel release];
//    [self noticeLabelHidden:NO textType:1];
    
    //时间
    _timerNum = 0;
    _timeBGView = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH-210)/2,  THE_DEVICE_HAVE_HEAD ? JX_SCREEN_TOP/2+5 : JX_SCREEN_TOP/2-15, 210, 2)];
//    _timeBGView = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH-210)/2, (JX_SCREEN_HEIGHT-JX_SCREEN_WIDTH)/2-35, 210, 2)];
    _timeBGView.image = [UIImage imageNamed:@"time_axis"];
    [self.view addSubview:_timeBGView];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 55, 30)];
    _timeLabel.center = _timeBGView.center;
    _timeLabel.text = @"00:00";
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.shadowColor  = [UIColor blackColor];
    _timeLabel.shadowOffset = CGSizeMake(1, 1);
    _timeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_timeLabel];
}

// 设置提示label
//-(void)noticeLabelHidden:(BOOL)hide textType:(int)type{
//    _noticeLabel.hidden = hide;
//    NSString * showStr = nil;
//    switch (type) {
//        case 1:
//            showStr = [NSString stringWithFormat:@"%@%d%@",Localized(@"recordVideoVC_Show1"),_maxTime,Localized(@"recordVideoVC_Show2")];
//            break;
//        case 2:
//            showStr = [NSString stringWithFormat:@"%@%ds",Localized(@"recordVideoViewController_LessThan"),_minTime];
//            break;
//        default:
//            break;
//    }
//    _noticeLabel.text = showStr;
//}

// 录制视频计时
- (void)recordTimerAction:(NSTimer *)timer {
    _timerNum ++;
    NSInteger m = _timerNum/60;
    NSInteger n = _timerNum%60;
    NSString * labelTimeStr;
    labelTimeStr = [NSString stringWithFormat:@"%.2ld:%.2ld",m,n];
    _timeLabel.text = labelTimeStr;
    
//    if (_timerNum >= _maxTime) {
//        [_recordTimer invalidate];
//        _recordTimer = nil;
//        [self endRecording];
//        [self dismissViewControllerAnimated:YES completion:^{
//
//            if ([self.cameraDelegate respondsToSelector:@selector(cameraVC:didFinishWithVideoPath:timeLen:)]) {
//                [self.cameraDelegate cameraVC:self didFinishWithVideoPath:self.outputFileName timeLen:self.timerNum];
//            }
//
//            _timerNum = 0;
//        }];
//    }
}

// 设置录制视频filter
- (void)videoSetFilter{
//    [_cropFilter addTarget:_beautifyFilter];
    
    [_filterGroup addTarget:_cropFilter];
    
//    [_filterGroup addTarget:_beautifyFilter];
    
    [_filterGroup setInitialFilters:[NSArray arrayWithObject:_cropFilter]];
    
//    [_filterGroup setTerminalFilter:_beautifyFilter];
    
    [_filterGroup forceProcessingAtSize:self.view.frame.size];
    
    [_filterGroup useNextFrameForImageCapture];
    
    [_videoCamera addTarget:_filterGroup];
    
    [_filterGroup addTarget:(GPUImageView *)self.view];
}

#pragma mark - 美颜 & 滤镜
- (void) addPhotoStyle:(UIView *)parentView{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, JX_SCREEN_WIDTH, 60)];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [parentView addSubview:_scrollView];
    
//    NSArray *nameArray = @[Localized(@"JX_Standard"),Localized(@"JX_Pale"),Localized(@"JX_Dark"),Localized(@"JX_Morning"),Localized(@"JX_Dusk"),Localized(@"JX_Natural"),Localized(@"JX_Highlight")];
//
//    _filterArray = @[
//                     @{@"x":@1.1, @"y":@1.1},
//                     @{@"x":@1.1, @"y":@0.5},
//                     @{@"x":@0.9, @"y":@1.1},
//                     @{@"x":@1.1, @"y":@1.3},
//                     @{@"x":@1.1, @"y":@1.5},
//                     @{@"x":@1.3, @"y":@1.1},
//                     @{@"x":@1.5, @"y":@1.1},
//                       ];
    //美颜
    GPUImageBeautifyFilter *BeautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    //哈哈镜效果
    GPUImageStretchDistortionFilter *stretchDistortionFilter = [[GPUImageStretchDistortionFilter alloc] init];
    //黑白
    GPUImageGrayscaleFilter *GrayscaleFilter = [[GPUImageGrayscaleFilter alloc] init];
    //高斯模糊
    GPUImageGaussianBlurFilter  *GaussianBlurFilter = [[GPUImageGaussianBlurFilter  alloc] init];
    //边缘检测
    GPUImageXYDerivativeFilter *XYDerivativeFilter = [[GPUImageXYDerivativeFilter alloc] init];
    //怀旧
    GPUImageSepiaFilter *sepiaFilter = [[GPUImageSepiaFilter alloc] init];
    //反色
    GPUImageColorInvertFilter *invertFilter = [[GPUImageColorInvertFilter alloc] init];
    //饱和度
    GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
    // 亮度阈值
    GPUImageLuminanceThresholdFilter *LuminanceThresholdFilter = [[GPUImageLuminanceThresholdFilter alloc] init];
    //去雾
    GPUImageHazeFilter *HazeFilter = [[GPUImageHazeFilter alloc] init];
    //初始化滤镜数组
    self.filterArray = @[BeautifyFilter,stretchDistortionFilter,GrayscaleFilter,GaussianBlurFilter,XYDerivativeFilter,sepiaFilter,invertFilter,saturationFilter,LuminanceThresholdFilter,HazeFilter];

    NSArray *nameArray = @[Localized(@"JX_CameraDefault"),Localized(@"JX_CameraSkinCare"),Localized(@"JX_CameraDistortingMirror"),Localized(@"JX_CameraBlackAndWhite"),Localized(@"JX_CameraGaussianBlur"),Localized(@"JX_CameraEdgeDetection"),Localized(@"JX_CameraNostalgia"),Localized(@"JX_CameraContrary"),Localized(@"JX_CameraSaturation"),Localized(@"JX_CameraThreshold"),Localized(@"JX_CameraFog")];
    UIImageView *lastImageView;
    for (NSInteger i = 0; i < nameArray.count; i ++) {
//        NSDictionary *dict = _filterArray[i];
        UIImage *inputImage = [UIImage imageNamed:@"zhang"];
        
//        GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
        
//        GPUImageHSBFilter *hsbFilter = [[GPUImageHSBFilter alloc] init];
//        [hsbFilter adjustBrightness:[dict[@"x"] floatValue]];
//        [hsbFilter adjustSaturation:[dict[@"y"] floatValue]];
        
//        [stillImageSource addTarget:hsbFilter];
//        [hsbFilter useNextFrameForImageCapture];
//        [stillImageSource processImage];
        
//        UIImage *image = [hsbFilter imageFromCurrentFramebuffer];
        
        if (i > 0) {
            [self.filterArray[i-1] useNextFrameForImageCapture];
            //获取数据源
            GPUImagePicture *stillImageSource=[[GPUImagePicture alloc]initWithImage:inputImage];
            [stillImageSource addTarget:self.filterArray[i-1]];
            //开始渲染
            [stillImageSource processImage];
            inputImage = [self.filterArray[i-1] imageFromCurrentFramebuffer];
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lastImageView.frame) + 4, 0, 50, 60)];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPhotoStyle:)];
        [imageView addGestureRecognizer:tap];
        
        imageView.image = inputImage;
        [_scrollView addSubview:imageView];
        lastImageView = imageView;
        
        if (i == 0) {
            imageView.layer.borderWidth = 2.0;
            imageView.layer.borderColor = [[UIColor yellowColor] CGColor];
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.size.height - 15, imageView.frame.size.width, 15)];
        label.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        label.text = nameArray[i];
        label.font = g_factory.font12;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        [imageView addSubview:label];
        
        [_photoStyleImages addObject:imageView];
    }
    _scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastImageView.frame) + 10, 0);
}

//- (void) setFilterStyle:(GPUImageOutput<GPUImageInput> *)filter{
//    
//    if ([filter isKindOfClass:[GPUImageSaturationFilter class]]) {
//        [(GPUImageSaturationFilter *)filter setSaturation:0.0];
//    }
//    if ([filter isKindOfClass:[GPUImageRGBFilter class]]) {
//        [(GPUImageRGBFilter *)filter setGreen:1.3];
//    }
//    if ([filter isKindOfClass:[GPUImageBrightnessFilter class]]) {
//        [(GPUImageBrightnessFilter *)filter setBrightness:.3];
//    }
//}

#pragma mark -  选择滤镜风格
- (void) selectPhotoStyle:(UIGestureRecognizer *)tap{
    
    if (_isRecording) {
        [JXMyTools showTipView:Localized(@"JX_CannotSwitchDuringRecording")];
        return;
    }
    
    if (_beautyBtn.selected) {
        [JXMyTools showTipView:Localized(@"JX_PleaseOpenBeauty")];
        return;
    }
    UIView *view = tap.view;
    self.isCreateFilter = YES;

    if (view == _photoStyleImages[1]) {
        [self recoverFilterGroup];
        [_bilateralSld setValue:self.bilHis > 0 ? self.bilHis : 4.2];
        [_brightnessSld setValue:self.briHis> 0 ? self.briHis : 0.07];
        [_bilateralFilter setDistanceNormalizationFactor:[self getBilValue:self.bilHis > 0 ? self.bilHis : 4.2]];
        _brightnessFilter.brightness = self.briHis> 0 ? self.briHis : 0.07;
        return;
    }else {
        [_bilateralSld setValue:0];
        [_brightnessSld setValue:0];
    }
    
    for (UIImageView *imageView in _photoStyleImages) {
        if (view == imageView) {
            imageView.layer.borderWidth = 2.0;
            imageView.layer.borderColor = [[UIColor yellowColor] CGColor];
        }else {
            imageView.layer.borderWidth = 0.0;
        }
    }
    [self.videoCamera removeAllTargets];
    [_stillCamera removeAllTargets];
    if (view.tag > 1) {
        // 只处理正常和滤镜
        GPUImageFilter *filter = self.filterArray[view.tag-1];
        [filter addTarget:(GPUImageView *)self.view];
        if (self.isPhoto) {
            [_stillCamera addTarget:filter];
        }else {
            [self.videoCamera addTarget:filter];
            [filter addTarget:_cropFilter];
        }
        self.filter = filter;
    }else {
        if (self.isPhoto) {
            [self initPhotoCamera];
        }else {
            [self initVideoCamera];
        }
    }

    
//    [_beautifyFilter removeAllTargets];
//    
//    _beautifyFilter = [GPUImageBeautifyFilter alloc];
//
//    _beautifyFilter.dict = _filterArray[view.tag];
//
//    _beautifyFilter = [_beautifyFilter init];
    
//    if (self.isVideo) {
//        [self videoBeautyStyle];
//    }else if (self.isPhoto){
//        [self photoBeautyStyle];
//    }else {
//        [self videoBeautyStyle];
////        [self photoBeautyStyle];
//    }

//    GPUImageOutput<GPUImageInput> *filter = _filterArray[view.tag];
//    [_stillCamera addTarget:filter];
//    GPUImageView *filterView = (GPUImageView *)self.view;
//    [filter addTarget:filterView];
    
//    self.filter = filter;
}

- (void)videoBeautyStyle {
    [_videoCamera removeAllTargets];
    [_cropFilter removeAllTargets];
    [_filterGroup removeAllTargets];
    [self videoSetFilter];
}
- (void)photoBeautyStyle {
    [_stillCamera removeAllTargets];
    [_stillCamera addTarget:_beautifyFilter];
    GPUImageView *filterView = (GPUImageView *)self.view;
    [_beautifyFilter addTarget:filterView];
}

// 截图
- (UIImage *)getImageByCuttingImage:(UIImage *)image Rect:(CGRect)rect{
    
    //大图bigImage
    
    //定义myImageRect，截图的区域
    
    CGRect myImageRect = rect;
    
    UIImage* bigImage= image;
    
    CGImageRef imageRef = bigImage.CGImage;
    
    imageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    
    CGSize size;
    
    size.width = rect.size.width;
    
    size.height = rect.size.height;
    
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawImage(context, myImageRect, imageRef);
    
    UIImage* smallImage = [UIImage imageWithCGImage:imageRef];
    
    UIGraphicsEndImageContext();
    
    CFRelease(imageRef);
    
    return smallImage;
    
}
- (void)didSendBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
        if ([self.cameraDelegate respondsToSelector:@selector(cameraVC:didFinishWithVideoPath:timeLen:)]) {
            
            [self.cameraDelegate cameraVC:self didFinishWithVideoPath:self.outputFileName timeLen:self.timerNum];
        }
        
        _playerView = nil;
        _player = nil;
    }];
}

- (void)didExitBtn:(id)sender {
    _playerView = nil;
    _player = nil;
    [self hideTime];
}

// X
- (void)cancelBtnAction:(UIButton *)btn {
    _isRecording = NO;
    [_recordTimer invalidate];
    _recordTimer = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
    }];
}

// 转换摄像头
- (void)switchBtnAction:(UIButton *)btn {
    if (self.isVideo) {
        [_videoCamera rotateCamera];
    }else if (self.isPhoto) {
        [_stillCamera rotateCamera];

    }else {
        [_videoCamera rotateCamera];
//        [_stillCamera rotateCamera];
    }
}

// 闪光灯
- (void)flashBtnAction:(UIButton *)btn {
//    if (self.isVideo) {
//        [_videoCamera.inputCamera lockForConfiguration:nil];
//        switch (_videoCamera.inputCamera.flashMode) {
//            case AVCaptureFlashModeAuto:
//                _videoCamera.inputCamera.flashMode = AVCaptureFlashModeOn;
//                [btn setImage:[UIImage imageNamed:@"flash_on"] forState:UIControlStateNormal];
//                break;
//            case AVCaptureFlashModeOn:
//                _videoCamera.inputCamera.flashMode = AVCaptureFlashModeOff;
//                [btn setImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
//                break;
//            case AVCaptureFlashModeOff:
//                _videoCamera.inputCamera.flashMode = AVCaptureFlashModeAuto;
//                [btn setImage:[UIImage imageNamed:@"automatic"] forState:UIControlStateNormal];
//                break;
//
//            default:
//                break;
//        }
//
//        [_videoCamera.inputCamera unlockForConfiguration];
//    }else {
        [_stillCamera.inputCamera lockForConfiguration:nil];
        switch (_stillCamera.inputCamera.flashMode) {
            case AVCaptureFlashModeAuto:
                _stillCamera.inputCamera.flashMode = AVCaptureFlashModeOn;
                [btn setImage:[UIImage imageNamed:@"flash_on"] forState:UIControlStateNormal];
                break;
            case AVCaptureFlashModeOn:
                _stillCamera.inputCamera.flashMode = AVCaptureFlashModeOff;
                [btn setImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
                break;
            case AVCaptureFlashModeOff:
                _stillCamera.inputCamera.flashMode = AVCaptureFlashModeAuto;
                [btn setImage:[UIImage imageNamed:@"automatic"] forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
        
        [_stillCamera.inputCamera unlockForConfiguration];
//    }
    
}

// 重新拍照
- (void) cancelImageBtnAction:(UIButton *)btn {
    _iv.hidden = YES;
    _iv.image = nil;
    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
}

// 编辑照片
- (void) editImageBtnAction:(UIButton *)btn {
    KKImageEditorViewController *editor = [[KKImageEditorViewController alloc] initWithImage:_iv.image delegate:self];
    
    UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:editor];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark- 照片编辑后的回调
- (void)imageDidFinishEdittingWithImage:(UIImage *)image asset:(PHAsset *)asset
{
    _iv.image = image;
}

// 确定此照片
- (void) confirmBtnAction:(UIButton *)btn {
    [self dismissViewControllerAnimated:YES completion:^{
        
        if ([self.cameraDelegate respondsToSelector:@selector(cameraVC:didFinishWithImage:)]) {
            [self.cameraDelegate cameraVC:self didFinishWithImage:_iv.image];
        }
    }];

}

#pragma mark - 美颜按鈕
- (void) beautyBtnAction:(UIButton *)btn {
    if (!_baseView) {
        [self showBaseView];
    }
    [self setupBeautyView:YES];
//    if (_isRecording) {
//        [JXMyTools showTipView:Localized(@"JX_CannotSwitchDuringRecording")];
//        return;
//    }
//
//    btn.selected = !btn.selected;
//
//    if (btn.selected) {
//        [btn setImage:[UIImage imageNamed:@"camra_beauty_close"] forState:UIControlStateNormal];
//        if (self.isVideo) {
//            [self videoSkinCare];
//        }else if (self.isPhoto){
//            [self photoSkinCare];
//        } else {
//            [self videoSkinCare];
////            [self photoSkinCare];
//        }
//
//    }else {
//        [btn setImage:[UIImage imageNamed:@"camra_beauty"] forState:UIControlStateNormal];
//
//        [_beautifyFilter removeAllTargets];
//        if (self.isVideo) {
//            [self videoCancelSkinCare];
//        }else if (self.isPhoto){
//            [self photoCancelSkinCare];
//        }else {
//            [self videoCancelSkinCare];
////            [self photoCancelSkinCare];
//        }
//    }
}

// 开启美颜
- (void)videoSkinCare {
    [_videoCamera removeAllTargets];
    [_beautifyFilter removeAllTargets];
    [_filterGroup removeAllTargets];
    [_cropFilter removeAllTargets];
    [_videoCamera addTarget:_cropFilter];
    [_cropFilter addTarget:(GPUImageView *)self.view];
}
- (void)photoSkinCare {
    [_stillCamera removeAllTargets];
    [_beautifyFilter removeAllTargets];
//    _normalFilter = [[GPUImageBrightnessFilter alloc] init];
//    [_stillCamera addTarget:_normalFilter];
//    [_normalFilter addTarget:(GPUImageView *)self.view];
}

//取消美颜
- (void)videoCancelSkinCare {
    [_videoCamera removeAllTargets];
    [_cropFilter removeAllTargets];
    [_filterGroup removeAllTargets];
    [self videoSetFilter];
}
- (void)photoCancelSkinCare {
    [_stillCamera removeAllTargets];
    [_stillCamera addTarget:_beautifyFilter];
    GPUImageView *filterView = (GPUImageView *)self.view;
    [_beautifyFilter addTarget:filterView];
}


#pragma mark - 开始录制视频
- (void)startPhoto {
    
    ///录制的视频会存储到该路径下 唯一
    
    NSString *pathToMovie = kCameraVideoPath;
    _outputFileName = pathToMovie;
    
//    [videoArray addObject:pathToMovie];
    
    NSLog(@"%@",pathToMovie);
    
    unlink([pathToMovie UTF8String]);
    
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
//    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720, 720) fileType:AVFileTypeQuickTimeMovie outputSettings:nil];
    
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(((int)JX_SCREEN_WIDTH/16)*16, ((int)JX_SCREEN_HEIGHT/16)*16) fileType:AVFileTypeQuickTimeMovie outputSettings:nil];
    
    AudioChannelLayout channelLayout;
    
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    
    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   
                                   [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,//制定编码算法
                                   [ NSNumber numberWithInt: 2 ], AVNumberOfChannelsKey,//声道
                                   [ NSNumber numberWithFloat: 16000.0 ], AVSampleRateKey,//采样率
                                   [ NSData dataWithBytes:&channelLayout length: sizeof( AudioChannelLayout ) ], AVChannelLayoutKey,
                                   [ NSNumber numberWithInt: 32000 ], AVEncoderBitRateKey,//编码率
                                   
                                   nil];
    
    [_movieWriter setHasAudioTrack:YES audioSettings:audioSettings];
    _movieWriter.hasAudioTrack = YES;
    
    _movieWriter.encodingLiveVideo = YES;
    _movieWriter.shouldPassthroughAudio = YES;
//    [_filterGroup addTarget:_movieWriter];
    
    [_videoCamera addAudioInputsAndOutputs];
    
    _videoCamera.audioEncodingTarget = _movieWriter;
    
//    if (_filterGroup.targets.count <= 0) {
//        [_cropFilter addTarget:_movieWriter];
//    }
//    else {
//        [_filterGroup addTarget:_movieWriter];
//    }
    [_cropFilter addTarget:_movieWriter];
    [_movieWriter startRecording];
    
}

///完成录制
- (void)endRecording {
    
    [_movieWriter finishRecording];
    
    [_cropFilter removeTarget:_movieWriter];
    
    [_beautifyFilter removeTarget:_movieWriter];
    
    [_filterGroup removeTarget:_movieWriter];
    
    _videoCamera.audioEncodingTarget = nil;
    
    //    [self savePhotoCmare:videoArray.lastObject];
    
}

- (void)dealloc {
    NSLog(@"cameraVC dealloc");
    [_stillCamera stopCameraCapture];
    [_videoCamera stopCameraCapture];
    [_movieWriter encodingLiveVideo];
    [_movieWriter cancelRecording];
    [_beautifyFilter removeAllTargets];
    [_filterGroup removeAllTargets];
    [_cropFilter removeAllTargets];
    [_normalFilter removeAllTargets];
    [_player stop];
    [_recordTimer invalidate];
    _recordTimer = nil;
    
    _stillCamera = nil;
    _videoCamera = nil;
    _movieWriter = nil;
    _beautifyFilter = nil;
    _filterGroup = nil;
    _cropFilter = nil;
    _normalFilter = nil;
    _player = nil;
}

- (UIButton *)createButtonWithFrame:(CGRect)frame image:(NSString *)image action:(SEL)action {
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    button.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = button.frame.size.width/2;
    [button setImage:[UIImage scaleToSize:[UIImage imageNamed:image] size:CGSizeMake(32, 32)] forState:UIControlStateNormal];
    if (action == @selector(editImageBtnAction:)) { // 编辑图片有点大，要单独处理下
        [button setImage:[UIImage scaleToSize:[UIImage imageNamed:image] size:CGSizeMake(21, 21)] forState:UIControlStateNormal];
    }
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}


- (void)showBaseView {
    self.baseView  = [[UIView alloc] initWithFrame:self.view.bounds];
    self.baseView.backgroundColor = [UIColor clearColor];
    self.baseView.hidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBaseView)];
    [self.baseView addGestureRecognizer:tap];
    
    [self.view addSubview:self.baseView];
    
    self.bigView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-100-JX_SCREEN_BOTTOM, JX_SCREEN_WIDTH, 100+JX_SCREEN_BOTTOM)];
    self.bigView.backgroundColor = HEXCOLOR(0x323232);
    [self.baseView addSubview:self.bigView];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBigView)];
    [self.bigView addGestureRecognizer:tap1];

    [self addPhotoStyle:self.bigView];
    [self initBottomView:self.bigView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_scrollView.frame)+20, JX_SCREEN_WIDTH, LINE_WH)];
    line.backgroundColor = THE_LINE_COLOR;
    [self.bigView addSubview:line];
    
    
    //滤镜
    self.filterBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_scrollView.frame)+20, JX_SCREEN_WIDTH/2, JX_SCREEN_BOTTOM)];
    [self.filterBtn setTitle:Localized(@"JX_CameraFilter") forState:UIControlStateNormal];
    [self.filterBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.filterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.filterBtn.titleLabel setFont:SYSFONT(15)];
    [self.filterBtn addTarget:self action:@selector(didFilterBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.bigView addSubview:self.filterBtn];
    
    UIView *lineF = [[UIView alloc] initWithFrame:CGRectMake(self.filterBtn.frame.size.width-LINE_WH, 12, LINE_WH, 49-12*2)];
    lineF.backgroundColor = THE_LINE_COLOR;
    [self.filterBtn addSubview:lineF];
    
    //美颜
    self.skinCareBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2, self.filterBtn.frame.origin.y, JX_SCREEN_WIDTH/2, self.filterBtn.frame.size.height)];
    [self.skinCareBtn setTitle:Localized(@"JX_CameraSkinCare") forState:UIControlStateNormal];
    [self.skinCareBtn.titleLabel setFont:SYSFONT(15)];
    [self.skinCareBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.skinCareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.skinCareBtn addTarget:self action:@selector(didBeautyBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.bigView addSubview:self.skinCareBtn];

}

- (void)setupBeautyView:(BOOL)isFilter {
    self.baseView.hidden = NO;
    _scrollView.hidden = !isFilter;
    _bottomControlView.hidden = isFilter;
    [self.filterBtn setSelected:isFilter];
    [self.skinCareBtn setSelected:!isFilter];
}


- (void)initBottomView:(UIView *)parentView
{
    _bottomControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, JX_SCREEN_WIDTH, 60)];
    [parentView addSubview:_bottomControlView];
    
    
    //磨皮
    UILabel *bilateralL = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 40, 25)];
    bilateralL.text = Localized(@"JX_CameraExfoliating");
    bilateralL.font = [UIFont systemFontOfSize:14];
    bilateralL.textColor = [UIColor whiteColor];
    [_bottomControlView addSubview:bilateralL];
    
    UISlider *bilateralSld  = [[UISlider alloc] initWithFrame:CGRectMake(50, 0, JX_SCREEN_WIDTH-100, 30)
                               ];
    bilateralSld.maximumValue = 6;
    [bilateralSld addTarget:self action:@selector(bilateralFilter:) forControlEvents:UIControlEventValueChanged];
    [_bottomControlView addSubview:bilateralSld];
    _bilateralSld = bilateralSld;

    //美白
    UILabel *brightnessL = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 40, 25)];
    brightnessL.text = Localized(@"JX_CameraWhitening");
    brightnessL.font = [UIFont systemFontOfSize:14];
    brightnessL.textColor = [UIColor whiteColor];
    [_bottomControlView addSubview:brightnessL];
    
    UISlider *brightnessSld  = [[UISlider alloc] initWithFrame:CGRectMake(50, 40, JX_SCREEN_WIDTH-100, 30)
                                ];
    brightnessSld.minimumValue = 0;
    brightnessSld.maximumValue = 0.1;
    [brightnessSld addTarget:self action:@selector(brightnessFilter:) forControlEvents:UIControlEventValueChanged];
    [_bottomControlView addSubview:brightnessSld];
    _brightnessSld = brightnessSld;
}

//点击滤镜
- (void)didFilterBtn {
    [self setupBeautyView:YES];
}
//点击美颜
- (void)didBeautyBtn {
    [self setupBeautyView:NO];
}

#pragma mark - 调整磨皮
- (void)bilateralFilter:(UISlider *)slider {
    [self recoverFilterGroup];
    //值越小，磨皮效果越好
    [_bilateralFilter setDistanceNormalizationFactor:[self getBilValue:slider.value]];
    self.bilHis = slider.value;
    NSLog(@"------调整磨皮 = %f - %f - %f",[self getBilValue:slider.value],(ldexp(slider.value, 10)),slider.value);
}

#pragma mark - 调整亮度
- (void)brightnessFilter:(UISlider *)slider {
    [self recoverFilterGroup];
    _brightnessFilter.brightness = slider.value;
    self.briHis = slider.value;
    NSLog(@"------调整亮度 = %f",slider.value);
}

// 恢复调整状态下的磨皮和亮度
- (void)recoverFilterGroup {
    
    if (self.isCreateFilter) {
        if (self.isPhoto) {
            [_stillCamera removeAllTargets];
            [self setFilterGroup];

            [_stillCamera addTarget:_filterGroup];
            [_stillCamera startCameraCapture];
        }else {
            [_videoCamera removeAllTargets];
            [self setFilterGroup];

            [_videoCamera addTarget:_filterGroup];
            [_videoCamera startCameraCapture];
        }
        
        self.isCreateFilter = NO;
        UIView *view = _photoStyleImages[1];
        for (UIImageView *imageView in _photoStyleImages) {
            if (view == imageView) {
                imageView.layer.borderWidth = 2.0;
                imageView.layer.borderColor = [[UIColor yellowColor] CGColor];
            }else {
                imageView.layer.borderWidth = 0.0;
            }
        }

    }
}


- (CGFloat)getBilValue:(CGFloat)value {
    CGFloat maxValue = 10;
    CGFloat va = maxValue - value;
    va = 60000 / (ldexp(value, 10));
    return va;
}

- (void)hideBaseView {
    self.baseView.hidden = YES;
}

- (void)clickBigView {}

@end
