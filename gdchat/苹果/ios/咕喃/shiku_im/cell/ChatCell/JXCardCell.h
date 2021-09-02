//
//  JXCardCell.h
//  shiku_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXBaseChatCell.h"
@class JXChatViewController;
@interface JXCardCell : JXBaseChatCell

@property (nonatomic,strong) UIImageView * imageBackground;
@property (nonatomic,strong) UILabel * nameLabel;
@property (nonatomic,strong) UIImageView * cardHeadImage;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *title;

@end
