//
//  acceptCallViewController.h
//  lveliao_IM
//
//  Created by MacZ on 2017/8/7.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "admobViewController.h"

#define UpdateAcceptCallMsg @"UpdateAcceptCallMsg"

@class JXAudioPlayer;

@interface acceptCallViewController : admobViewController{
    UIButton* _buttonHangup;
    UIButton* _buttonAccept;
    JXAudioPlayer* _player;
}
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, assign) BOOL isTalk;
@property (nonatomic, copy) NSString * toUserId;
@property (nonatomic, copy) NSString * toUserName;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, copy) NSString * roomNum;
@property (nonatomic, weak) NSObject* delegate;
@property (nonatomic, assign) SEL		didTouch;
@property (nonatomic, assign) SEL   changeAudio;
@property (nonatomic, assign) SEL   changeVideo;

@end
