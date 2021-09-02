//
//  JXShareCell.h
//  shiku_im
//
//  Created by p on 2018/11/3.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXBaseChatCell.h"

@interface JXShareCell : JXBaseChatCell

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *subTitle;
@property (nonatomic, strong) UIImageView *shareImage;
@property (nonatomic, strong) UIImageView *skIcon;
@property (nonatomic, strong) UILabel *skLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIImageView * imageBackground;

@end
