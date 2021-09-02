//
//  acceptCallViewController.h
//  lveliao_IM
//
//  Created by MacZ on 2017/8/7.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "admobViewController.h"
@class JXAudioPlayer;

@interface AskCallViewController : admobViewController{
    BOOL _bAnswer;
    JXAudioPlayer* _player;
}
@property (nonatomic, copy) NSString * toUserId;
@property (nonatomic, copy) NSString * toUserName;
@property (nonatomic, assign) int type;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, copy) NSString *meetUrl;

@end
