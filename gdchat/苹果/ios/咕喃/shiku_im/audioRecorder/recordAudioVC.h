//
//  recordAudioVC.h
//  shiku_im
//
//  Created by flyeagleTang on 14-6-24.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "admobViewController.h"
#import "JXAudioPlayer.h"
@class MixerHostAudio;
@class mediaOutput;

@interface recordAudioVC : UIViewController{
    MixerHostAudio* _mixRecorder;
    mediaOutput* outputer;
    IBOutlet UISegmentedControl* mFxType;

    BOOL _startOutput;
   
    JXImageView* _input;
    JXImageView* _volume;
    JXImageView* _btnPlay;
    JXImageView* _btnRecord;
    JXImageView* _btnBack;
    JXImageView* _btnDel;
    JXImageView* _btnEnter;
    JXImageView* _iv;
    UIScrollView* _effectType;
    UILabel* _lb;
    NSTimer* _timer;
    JXAudioPlayer* _player;
    recordAudioVC* _pSelf;
}
@property(nonatomic,assign) int timeLen;
@property(nonatomic,weak) id delegate;
@property(assign) SEL didRecord;
@property (nonatomic, strong) NSString* outputFileName;

@end
