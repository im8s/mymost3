//
//  JXLocationCell.h
//  shiku_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXBaseChatCell.h"
@interface JXLocationCell : JXBaseChatCell
@property (nonatomic,strong) UIImageView * imageBackground;
@property (nonatomic,strong) UIImageView * mapImageView;
//@property (nonatomic,strong) UILabel * titleLabel;
@property (nonatomic,strong) UILabel * addressLabel;
@end
