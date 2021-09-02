//
//  JXAudioPlayer.h
//  shiku_im
//
//  Created by flyeagleTang on 17/1/12.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JXWaitView.h"
#define kAllAudioPlayerStopNotifaction @"kAllAudioPlayerStopNotifaction"//退出程序时，保存未读消息
#define kAllAudioPlayerPauseNotifaction @"kAllAudioPlayerPauseNotifaction"//退出程序时，保存未读消息

@interface JXAudioPlayer : NSObject<AVAudioPlayerDelegate>{
    AVAudioPlayer *_player;
    BOOL _isOpened;
    JXWaitView* _wait;
    JXImageView * _voiceView;
    UILabel* _timeLenView;
    NSMutableArray* _array;
}
@property (nonatomic, strong, setter=setAudioFile:)NSString* audioFile;//可动态改变文件
@property (nonatomic, strong, setter=setParent:) UIView* parent;//可动态改变父亲
@property (nonatomic, strong) UIButton* pauseBtn;

@property (nonatomic, strong) AVAudioPlayer* player;
@property (nonatomic, strong) JXImageView * voiceBtn;
@property (nonatomic, strong) UILabel* timeLenView;
@property (nonatomic, strong) UIProgressView * progressView;
@property (nonatomic, strong) UIView* pgBGView; //进度条背景

@property (nonatomic, strong) id delegate;
@property (nonatomic, assign) SEL didAudioOpen;//打开音频
@property (nonatomic, assign) SEL didAudioPlayEnd;//播放结束
@property (nonatomic, assign) SEL didAudioPlayBegin;//点击播放
@property (nonatomic, assign) SEL didAudioPause;//播放暂停

@property (nonatomic, assign) BOOL isPlaying;//播放中
@property (nonatomic, assign, setter=setTimeLen:) int timeLen;
@property (nonatomic, assign, setter=setIsLeft:) BOOL isLeft;
@property (nonatomic, assign,setter=setHidden:) BOOL hidden;
@property (nonatomic, assign, setter=setFrame:) CGRect frame;
@property (nonatomic, assign) BOOL showProgress;//长于10s的音频默认启用进度条,设NO不显示
@property (nonatomic, strong) NSTimer * timer;

@property (nonatomic, assign) BOOL isNotStopLast;
@property (nonatomic, assign) BOOL isOpenProximityMonitoring;   // 是否开启贴脸检测
@property (nonatomic, assign) BOOL isChatAudio;


-(id)initWithParent:(UIView*)parent;//指定父亲建立，显示播放暂停按钮
-(id)initWithParent:(UIView*)parent frame:(CGRect)frame isLeft:(BOOL)isLeft;//指定父亲、frame、方向建立动画播放view
-(id)init;//不可视
-(void)open;
-(void)play;
-(void)pause;
-(void)stop;
-(void)switch;

//-(void)wavToamr:(NSString*)source target:(NSString*)target;
//-(void)amrTowav:(NSString*)source target:(NSString*)target;
@end
