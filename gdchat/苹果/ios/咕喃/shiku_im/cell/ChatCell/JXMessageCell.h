//
//  JXMessageCell.h
//  shiku_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXBaseChatCell.h"
//添加Cell被长按的处理
#import "QBPlasticPopupMenu.h"

@interface JXMessageCell : JXBaseChatCell{
    
}
@property (nonatomic,strong) JXEmoji * messageConent;
@property (nonatomic, strong) UILabel *timeIndexLabel;
@property (nonatomic, assign) NSInteger timerIndex;
@property (nonatomic, strong) NSTimer *readDelTimer;

@property (nonatomic, assign) BOOL isDidMsgCell;

- (void)deleteMsg:(JXMessageObject *)msg;

@end
