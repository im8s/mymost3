//
//  JXAudioRecorderViewController.h
//  shiku_im
//
//  Created by Apple on 17/1/3.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "admobViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceConverter.h"
#import "ChatCacheFileUtil.h"


@interface JXAudioRecorderViewController : admobViewController<AVAudioRecorderDelegate,AVAudioPlayerDelegate>{
    BOOL _isRecording;
//    NSTimer *_peakTimer;
    
    AVAudioRecorder *_audioRecorder;
    NSURL *_pathURL;
    NSString* _lastRecordFile;
}

@property (nonatomic,weak) id delegate;
@property(nonatomic,assign) int maxTime;
@property(nonatomic,assign) int minTime;

@end

@protocol JXAudioRecorderDelegate <NSObject>

- (void)JXaudioRecorderDidFinish:(NSString *)filePath TimeLen:(int)timenlen;

@end
