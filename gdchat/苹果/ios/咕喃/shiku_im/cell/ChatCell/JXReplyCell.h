//
//  JXReplyCell.h
//  shiku_im
//
//  Created by 1 on 2019/3/30.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JXBaseChatCell.h"
//添加Cell被长按的处理
#import "QBPlasticPopupMenu.h"

NS_ASSUME_NONNULL_BEGIN

@interface JXReplyCell : JXBaseChatCell

@property (nonatomic,strong) JXEmoji * messageConent;
@property (nonatomic,strong) JXEmoji * replyConent;
@property (nonatomic, strong) UILabel *timeIndexLabel;
@property (nonatomic, assign) NSInteger timerIndex;
@property (nonatomic, strong) NSTimer *readDelTimer;

@property (nonatomic, assign) BOOL isDidMsgCell;

- (void)deleteMsg:(JXMessageObject *)msg;

@end

NS_ASSUME_NONNULL_END
