//
//  JXCommonService.m
//  shiku_im
//
//  Created by p on 2017/11/9.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXCommonService.h"

@interface JXCommonService()

@property (nonatomic, assign) NSInteger sendIndex;
@property (nonatomic, strong) NSArray *courseArray;
@property (nonatomic, assign) NSInteger timeIndex;
@property (nonatomic, strong) UILabel *sendLabel;
@property (nonatomic, assign) CGRect subWindowFrame;

@end

@implementation JXCommonService

// 发送课程
- (void)sendCourse:(JXMsgAndUserObject *)obj Array:(NSArray *)array {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        g_subWindow.frame = CGRectMake(JX_SCREEN_WIDTH - 80 - 10, 50, 80, 100);
        g_subWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        g_subWindow.layer.masksToBounds = YES;
        g_subWindow.layer.cornerRadius = 5.f;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [g_subWindow addGestureRecognizer:pan];
        
        self.sendLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, g_subWindow.frame.size.width, g_subWindow.frame.size.height - 20)];
        self.sendLabel.textColor = [UIColor whiteColor];
        self.sendLabel.font = g_factory.font12;
        self.sendLabel.numberOfLines = 0;
        self.sendLabel.textAlignment = NSTextAlignmentCenter;
        self.sendLabel.text = [NSString stringWithFormat:@"%@:\n1/%ld",Localized(@"JX_SendingCourses"),array.count];
        [g_subWindow addSubview:self.sendLabel];
        
        dispatch_semaphore_signal(sem);
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    _courseArray = array;
    _sendIndex = 0;
    _timeIndex = 0;
    _courseTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendCourseTimerAction:) userInfo:obj repeats:YES];
    [[NSRunLoop currentRunLoop] run];//已经将nstimer添加到NSRunloop中了
}

- (void)sendCourseTimerAction:(NSTimer *)timer {
    
    _timeIndex ++;
    JXMessageObject *msg= _courseArray[self.sendIndex];
    
    __block NSString *myUserName;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.sendLabel.text = [NSString stringWithFormat:@"%@:\n%ld/%ld",Localized(@"JX_SendingCourses"),self.sendIndex + 1,_courseArray.count];
        myUserName = g_myself.userNickname;
        dispatch_semaphore_signal(sem);
    });

    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    NSInteger index = 0;
    if ([msg.type integerValue] == kWCMessageTypeText) {
        
        index = msg.content.length / 2;
        
    }else if([msg.type integerValue] == kWCMessageTypeVoice) {
        
        index = [msg.timeLen integerValue];
        
    }else {
        index = 0;
    }
    index += 3;
    if (_timeIndex < index && self.sendIndex != 0) {
        return;
    }
    _timeIndex = 0;
    
//    NSInteger index = 0;
//    if ([msg.type integerValue] == kWCMessageTypeText) {
//
//        index = msg.content.length / 2;
//
//    }else if([msg.type integerValue] == kWCMessageTypeVoice) {
//
//        index = [msg.timeLen integerValue];
//
//    }else {
//        index = 0;
//    }
//    index += 3;
//    if (_timeIndex < index && self.sendIndex != 0) {
//        return;
//    }
//    _timeIndex = 0;
    
    JXMsgAndUserObject *obj = timer.userInfo;
    BOOL isRoom;
    if ([obj.user.roomFlag intValue] > 0  || obj.user.roomId.length > 0) {
        isRoom = YES;
    }else {
        isRoom = NO;
    }
    
    msg.messageId = nil;
    msg.timeSend     = [NSDate date];
    msg.fromId = nil;
    msg.fromUserId   = MY_USER_ID;
    if(isRoom){
        msg.toUserId = obj.user.userId;
        msg.isGroup = YES;
        msg.fromUserName = myUserName;
    }
    else{
        msg.toUserId     = obj.user.userId;
        msg.isGroup = NO;
    }
    //        msg.content      = relayMsg.content;
    //        msg.type         = relayMsg.type;
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isRead       = [NSNumber numberWithBool:NO];
    msg.isReadDel    = [NSNumber numberWithInt:NO];
    //发往哪里
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isRoom) {
            [msg insert:obj.user.userId];
            [g_xmpp sendMessage:msg roomName:obj.user.userId];//发送消息
        }else {
            [msg insert:nil];
            [g_xmpp sendMessage:msg roomName:nil];//发送消息
        }
        [g_notify postNotificationName:kSendCourseMsg object:msg];
    });

    self.sendIndex ++;
    if (_courseArray.count == self.sendIndex) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_courseTimer invalidate];
            _courseTimer = nil;
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                
            g_subWindow.hidden = YES;
    //        [g_subWindow resignKeyWindow];
            [g_subWindow removeFromSuperview];
            g_subWindow = nil;
            self.sendLabel = nil;
            
            [JXMyTools showTipView:Localized(@"JXAlert_SendOK")];
        });
    }
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.subWindowFrame = g_subWindow.frame;
    }
    CGPoint offset = [pan translationInView:g_App.window];
    CGPoint offset1 = [pan translationInView:g_subWindow];
    NSLog(@"pan - offset = %@, offset1 = %@", NSStringFromCGPoint(offset), NSStringFromCGPoint(offset1));
    
    CGRect frame = self.subWindowFrame;
    frame.origin.x += offset.x;
    frame.origin.y += offset.y;
    g_subWindow.frame = frame;
    
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        if (frame.origin.x <= JX_SCREEN_WIDTH / 2) {
            frame.origin.x = 10;
        }else {
            frame.origin.x = JX_SCREEN_WIDTH - frame.size.width - 10;
        }
        [UIView animateWithDuration:0.5 animations:^{
            
            g_subWindow.frame = frame;
        }];
    }
}

@end
