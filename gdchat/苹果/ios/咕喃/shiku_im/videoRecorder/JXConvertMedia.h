//
//  JXConvertMedia.h
//  MyAVController
//
//  Created by imac on 13-3-8.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

@interface JXConvertMedia : NSObject{
    AVAssetWriter* _writer;
    AVAssetWriterInput* _audioInput;
    AVAssetWriterInput* _videoInput;
    AVCaptureVideoDataOutput *_captureVideo;
    AVCaptureAudioDataOutput *_captureAudio;
    AVCaptureDeviceInput *_deviceVideo;
    AVCaptureDeviceInput *_deviceAudio;
    int _writeVideoCount;
    int _writeAudioCount1;
    int _writeAudioCount2;
    CMTime _time;
    CMTime _timeLast;

    CMTimeRange _audiotimeRange1;
    CMTimeRange _audiotimeRange2;
    AVAssetReader * _audioReader2;
    AVAssetReader * _audioReader1;
    AVAssetReader * _videoReader;
    AVURLAsset * _asset;
    
    NSString* _lastSaveFile;
}

@property (nonatomic, strong) NSString* inputVideoFile;

@property (nonatomic, strong) NSString* inputAudioFile1;

@property (nonatomic, strong) NSString* inputAudioFile2;

@property (nonatomic, strong) NSString* outputFileName;

@property (nonatomic, strong) UIImage* logoImage;//视频水印

@property (assign) CGRect logoRect;//水印范围

@property (assign) CGSize rotateSize;

@property (assign) int saveVideoToImage;//每隔多少秒保存一张截图jpg

@property (assign) int videoWidth;//视频宽,默认为480

@property (assign) int videoHeight;//视频高,默认为JX_SCREEN_WIDTH

@property (assign) int videoFrames;//视频压缩后帧率,默认为15

@property (assign) int videoEncodeBitRate;//视频压缩后码流,默认为200K

@property (assign) int audioEncodeBitRate;//音频压缩后码流,默认为24K

@property (assign) int audioSampleRate;//音频采样率，默认为22050

@property (assign) int audioChannels;//音频声道，默认为1

@property (nonatomic, assign) SEL		onFinish;

@property (nonatomic, weak) NSObject* delegate;

@property (nonatomic, strong) UIProgressView* progress;

@property (nonatomic, strong) UILabel*  progressText;

-(void)openMedia:(NSString*)video audio1:(NSString*)audio1 audio2:(NSString*)audio2;
-(void) convert;

@end
