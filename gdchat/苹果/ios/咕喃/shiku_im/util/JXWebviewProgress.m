//
//  JXWebviewProgress.m
//  shiku_im
//
//  Created by 1 on 2019/4/8.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXWebviewProgress.h"

@implementation JXWebviewProgress

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)setLineColor:(UIColor *)lineColor{
    _lineColor = lineColor;
    self.backgroundColor = lineColor;
}

-(void)startLoadingAnimation{
    self.hidden = NO;
    __weak UIView *weakSelf = self;
    [UIView animateWithDuration:0.4 animations:^{
        [self getWidth:JX_SCREEN_WIDTH * 0.6 view:weakSelf];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1. animations:^{
            [self getWidth:JX_SCREEN_WIDTH * 0.8 view:weakSelf];
        }];
    }];
    
    
}

- (void)getWidth:(CGFloat)width view:(UIView *)view {
    CGRect frame = view.frame;
    frame.size.width = width;
    view.frame = frame;
}

-(void)endLoadingAnimation{
    __weak UIView *weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        [self getWidth:JX_SCREEN_WIDTH view:weakSelf];
    } completion:^(BOOL finished) {
        weakSelf.hidden = YES;
    }];
}

@end
