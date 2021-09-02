//
//  JXMultipleLogin.h
//  shiku_im
//
//  Created by p on 2018/5/22.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JXMultipleLogin : NSObject

@property (nonatomic, strong) NSMutableArray *deviceArr;


+(JXMultipleLogin*)sharedInstance;

// 发送上线消息，通知其他端自己上线
- (void)sendOnlineMessage;
// 发送下线消息，通知其他端自己下线
- (void)sendOfflineMessage;

// 收到登录验证回执或收到200消息,判断其他端是否在线
- (void)upDateOtherOnline:(XMPPMessage *)message isOnLine:(NSNumber *)isOnLine;

// isOnline统一全部置状态
- (void)upDateAllDeviceOnline:(NSNumber *)isOnline;

// 转发消息给其他端
- (void) relaySendMessage:(XMPPMessage *)message msg:(JXMessageObject *)msg;

// 其他端在线状态更新
- (void)upDateOtherOnlineWithResources:(NSArray *)resources;

@end
