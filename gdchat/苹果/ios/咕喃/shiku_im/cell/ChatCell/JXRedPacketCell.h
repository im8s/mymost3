//
//  JXRedPacketCell.h
//  shiku_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXBaseChatCell.h"
@class JXChatViewController;
@interface JXRedPacketCell : JXBaseChatCell

@property (nonatomic, strong) JXImageView* imageBackground;
@property (nonatomic,strong) JXEmoji * redPacketGreet;

@end

