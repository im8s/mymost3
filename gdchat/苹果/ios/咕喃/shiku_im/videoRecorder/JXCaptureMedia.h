#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

//@class AVAssetWriter;

#define kVideoRecordEndNotifaction @"kVideoRecordEndNotifaction"//退出程序时，保存未读消息

/*!
 @class	AVController 
 @author Benjamin Loulier
 
 @brief    Controller to demonstrate how we can have a direct access to the camera using the iPhone SDK 4
 */

@interface JXCaptureMedia : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate> {
	AVCaptureSession *_capSession;
	UIImageView *_imageView;
	CALayer *_customLayer;
	AVCaptureVideoPreviewLayer *_prevLayer;
    BOOL _isRecording;
    BOOL _isPaused;
    AVAssetWriter* _writer;
    AVAssetWriterInput* _audioInput;
    AVAssetWriterInput* _videoInput;
    AVCaptureVideoDataOutput *_captureVideo;
    AVCaptureAudioDataOutput *_captureAudio;
    AVCaptureDeviceInput *_deviceVideo;
    AVCaptureDeviceInput *_deviceAudio;
    int _writeVideoCount;
    int _writeAudioCount;
    CMTime  _startSessionTime;
    NSString* _lastShowTime;
//    NSString* _lastSaveFile;
    AVAssetWriterInputPixelBufferAdaptor *_adaptor;
    size_t _sampleWidth;
    size_t _sampleHeight;
    BOOL _isSendEnd;
    NSInteger _saveCount;
}


@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic, strong) UIImage* logoImage;//视频水印

@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

@property (nonatomic, strong) NSString* outputFileName;//输出的视频文件名

@property (nonatomic, strong) NSMutableArray* outputImageFiles;//截图的文件列表

@property (assign) CGRect logoRect;//水印范围

@property (assign) CGRect previewRect;//水印范围

@property (nonatomic, strong) UILabel* labelTime;//显示当前时间

@property (nonatomic, assign) BOOL isReciprocal;//显示倒计时

@property (assign) int saveVideoToImage;//每隔多少秒保存一张截图jpg

@property (assign) BOOL isOnlySaveFirstImage;//只保存第一张截图

@property (assign) BOOL isRecording;

@property (assign) BOOL isEditVideo;

@property (assign) BOOL isFrontFace;//是否前置自拍摄像头

@property (assign) BOOL isRecordAudio;//是否录音频

@property (assign) int videoWidth;//视频宽,默认为480

@property (assign) int videoHeight;//视频高,默认为320

@property (assign) int videoFrames;//视频压缩后帧率,默认为10

@property (assign) int videoEncodeBitRate;//视频压缩后码流,默认为200K

@property (assign) int audioEncodeBitRate;//音频压缩后码流,默认为24K

@property (assign) int audioSampleRate;//音频采样率，默认为22050

@property (assign) int audioChannels;//音频声道，默认为1

@property (assign,setter = setFlashMode:) AVCaptureFlashMode curFlashMode;//当前闪光灯模式

@property (readwrite) AVCaptureVideoOrientation referenceOrientation;

@property (readwrite) AVCaptureVideoOrientation videoOrientation;

@property(nonatomic,assign) NSInteger timeLen;//时长
@property(nonatomic,assign) int maxTime;//最大时长，自动停止


-(BOOL) createPreview:(UIView*)parentView;//传入视频预览窗口句柄
-(void) start;//开始录像
-(void) stop;//结束录像
-(BOOL) pause;
-(BOOL) play;
-(void) setFlashMode:(AVCaptureFlashMode)n;//开关闪光灯
-(BOOL) toggleCamera;//切换摄像头
-(void)clearTempFile;
-(NSUInteger) cameraCount;//摄像头数量
@end
