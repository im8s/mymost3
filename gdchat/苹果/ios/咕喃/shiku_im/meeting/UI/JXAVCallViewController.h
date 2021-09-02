//
//  JXAVCallViewController.h
//  lveliao_IM
//
//  Created by p on 2017/12/26.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JitsiMeet/JitsiMeet.h>

@interface JXAVCallViewController : UIViewController<JitsiMeetViewDelegate>

@property (nonatomic, strong) JXAVCallViewController *pSelf;
@property (nonatomic, copy) NSString *roomNum;
@property (nonatomic, assign) BOOL isAudio;
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, assign) BOOL isTalk;
@property (nonatomic, strong) NSString *toUserId;
@property (nonatomic, strong) NSString *toUserName;
@property (nonatomic, copy) NSString *meetUrl;

@end
