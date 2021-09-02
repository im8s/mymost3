//
//  JXRemindCell.h
//  shiku_im
//
//  Created by Apple on 16/10/11.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXBaseChatCell.h"
@interface JXRemindCell : JXBaseChatCell
@property (nonatomic,strong) UILabel* messageRemind;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UIView *baseView;

@end
