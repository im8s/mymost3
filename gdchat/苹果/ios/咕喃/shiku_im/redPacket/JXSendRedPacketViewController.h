//
//  JXSendRedPacketViewController.h
//  shiku_im
//
//  Created by 1 on 17/8/14.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "admobViewController.h"

@protocol SendRedPacketVCDelegate <NSObject>

-(void)sendRedPacketDelegate:(NSDictionary *)redpacketDict;

@end


@interface JXSendRedPacketViewController : admobViewController

@property (nonatomic, assign) BOOL isRoom;
@property (nonatomic,strong) NSString* roomJid;//相当于RoomJid
@property (nonatomic, strong) NSString *toUserId;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, weak) id<SendRedPacketVCDelegate> delegate;

@end
