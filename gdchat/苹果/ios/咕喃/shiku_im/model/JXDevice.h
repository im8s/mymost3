//
//  JXDevice.h
//  shiku_im
//
//  Created by p on 2018/6/6.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXUserObject.h"

@interface JXDevice : JXUserObject

// 每个端有一个监控定时器
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int timerNum;

+(JXDevice*)sharedInstance;

// 更新其他端isOnLine
- (BOOL) updateIsOnLine:(NSNumber *)isOnLine userId:(NSString *)userId;
// 更新其他端isOnLine
- (BOOL) updateIsSendRecipt:(NSNumber *)isSendRecipt userId:(NSString *)userId;
// 查找我的设备
-(NSMutableArray*)fetchAllDeviceFromLocal;

@end
