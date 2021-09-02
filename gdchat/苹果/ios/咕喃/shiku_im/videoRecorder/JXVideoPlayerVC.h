#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "JXWaitView.h"

@class AVPlayer;
@class AVPlayerItem;
@class MyPlayerLayerView;
@class JXImageView;
@class AppDelegate;
@class JXLabel;

@interface JXVideoPlayerVC : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate> {
    NSString *kTracksKey;
    NSString *kPlayableKey;
    NSString *kStatusKey;
    NSString *kRateKey;
    NSString *kCurrentItemKey;
    NSString *kDurationKey;
    NSString *kTimedMetadataKey;
    
    AVPlayer *_player;
    AVPlayerItem * mPlayerItem;
    AVURLAsset *_asset;
    
    MyPlayerLayerView *playerLayerView;
    UISlider *movieTimeControl;
    UILabel* isPlayingAdText;
    
    BOOL _isIniting;
    BOOL isSeeking;
    BOOL _isNeed90;
    BOOL seekToZeroBeforePlay;
    float restoreAfterScrubbingRate;
    id timeObserver;
    
    NSTimer* timerShowPeak;
    NSArray *adList;
    JXWaitView* _wait;
    UITapGestureRecognizer* _singleTap;
    UIProgressView *_progressView;
    CGFloat  _curProFloat;  // 当前进度条总进度 progress 值
    CGFloat  _n;    // 进度条走了多少 
}

@property (nonatomic, strong,setter=setPauseBtn:) UIButton* pauseButton;
@property (nonatomic, strong) UISlider *movieTimeControl;
@property (nonatomic, strong) MyPlayerLayerView *playerLayerView;
@property (nonatomic, strong) JXLabel *playStatus;
@property (nonatomic, strong) UILabel* timeCur;
@property (nonatomic, strong) UILabel* timeEnd;
@property (nonatomic, strong) UIView* parent;

@property (nonatomic, strong) NSString* filepath;
@property (nonatomic, strong) NSURL *movieURL;
@property (nonatomic, weak) id delegate;
@property (assign) SEL didClick;
@property (assign) SEL didPlayNext;
@property (assign) SEL didOpen;
@property (assign) BOOL isVideo;
@property (assign) BOOL isPause;
@property (nonatomic,assign,setter=setIsOpened:)BOOL isOpened;
@property (assign) BOOL isUserPause;
@property (assign) BOOL isFullScreen;
@property (assign) long long  timeLen;

-(void)open:(NSString*)filePath;
-(void)prepareToPlayItemWithURL:(NSURL *)newMovieURL;

- (IBAction)beginScrubbing:(id)sender;
- (IBAction)scrub:(id)sender;
- (IBAction)endScrubbing:(id)sender;

- (void)stop;
- (void)play:(id)sender;
- (void)pause:(id)sender;
- (BOOL)isPlaying;
- (void)setSliderHidden:(BOOL)b;
- (void)set90;
-(void)setFrame:(CGRect)frame;

@end
