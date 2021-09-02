#import <UIKit/UIKit.h>
#import "ImageSelectorViewController.h"
#import "JXVideoPlayer.h"

@class JXCaptureMedia;
@class JXLabel;
@class JXImageView;

@interface recordVideoViewController : UIViewController <ImageSelectorViewDelegate>{
    JXCaptureMedia* _capture;

    UIView* preview;
    UIImageView *_timeBGView;
    UILabel *_timeLabel;
    JXImageView* _flash;
    JXImageView* _flashOn;
    JXImageView* _flashOff;
    JXImageView* _cammer;
    UIButton* _recrod;
    JXImageView* _close;
    JXImageView* _save;
//    UIImageView *_noticeView;
    UILabel *_noticeLabel;
    UILabel * _recordLabel;
    UIView *_bottomView;
    recordVideoViewController* _pSelf;
}

//- (IBAction)doFileConvert;

@property(nonatomic,assign) BOOL isReciprocal;//是否倒计时,为该参赋值一定也要给mixTime赋值
@property(nonatomic,assign) int maxTime;
@property(nonatomic,assign) int minTime;
@property(nonatomic,assign) BOOL isShowSaveImage;//是否显示选择保存截图界面
@property(nonatomic,assign) int timeLen;
@property(nonatomic,weak) id delegate;
@property(assign) SEL didRecord;
@property (nonatomic,strong) NSString* outputFileName;//返回的video
@property (nonatomic,strong) NSString* outputImage;//返回的截图
@property (nonatomic,strong) JXCaptureMedia* recorder;


@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) JXVideoPlayer *player;

@end

