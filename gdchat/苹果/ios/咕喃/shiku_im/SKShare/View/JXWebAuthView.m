//
//  JXWebAuthView.m
//  shiku_im
//
//  Created by p on 2019/3/4.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXWebAuthView.h"


@interface JXWebAuthView ()


@end

@implementation JXWebAuthView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)init {
    
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
        
        [self customView];
    }
    
    return self;
    
}

- (void)customView {
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH - 100, JX_SCREEN_WIDTH - 100)];
    contentView.center = g_window.center;
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 3.0;
    contentView.layer.masksToBounds = YES;
    [self addSubview:contentView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, 50)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:17.0];
    titleLabel.text = [NSString stringWithFormat:@"%@%@",APP_NAME,Localized(@"JX_Login")];
    [contentView addSubview:titleLabel];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), contentView.frame.size.width, .5)];
    line.backgroundColor = HEXCOLOR(0xdcdcdc);
    [contentView addSubview:line];
    
    self.headImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame) + 10, 50, 50)];
    self.headImage.center = CGPointMake(contentView.frame.size.width / 2, self.headImage.center.y);
    self.headImage.layer.cornerRadius = self.headImage.frame.size.width / 2;
    self.headImage.layer.masksToBounds = YES;
    [contentView addSubview:self.headImage];
    
    self.tipTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.headImage.frame) + 10, contentView.frame.size.width - 40, 20)];
    self.tipTitle.textColor = [UIColor blackColor];
    self.tipTitle.font = [UIFont systemFontOfSize:15.0];
    self.tipTitle.text = [NSString stringWithFormat:@"%@%@:",APP_NAME,Localized(@"JX_ApplyFollowingPermissions")];
    [contentView addSubview:self.tipTitle];
    
    UIView *point = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.tipTitle.frame) + 20, 10, 10)];
    point.backgroundColor = HEXCOLOR(0xf0f0f0);
    point.layer.cornerRadius = point.frame.size.width / 2;
    [contentView addSubview:point];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(point.frame) + 10, CGRectGetMaxY(self.tipTitle.frame) + 10, contentView.frame.size.width - CGRectGetMaxX(point.frame) - 30, 35)];
    tipLabel.textColor = [UIColor grayColor];
    tipLabel.numberOfLines = 0;
    tipLabel.font = [UIFont systemFontOfSize:14.0];
    tipLabel.text = Localized(@"JX_GetPublicInformation");
    [contentView addSubview:tipLabel];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tipLabel.frame) + 10, contentView.frame.size.width, .5)];
    line.backgroundColor = HEXCOLOR(0xdcdcdc);
    [contentView addSubview:line];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame), contentView.frame.size.width / 2, 40)];
    [cancelBtn setTitle:Localized(@"JX_WebRefused") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:cancelBtn];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cancelBtn.frame), CGRectGetMaxY(line.frame), .5, cancelBtn.frame.size.height)];
    line.backgroundColor = HEXCOLOR(0xdcdcdc);
    [contentView addSubview:line];
    
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(line.frame), cancelBtn.frame.origin.y, contentView.frame.size.width / 2, 40)];
    [confirmBtn setTitle:Localized(@"JX_WebAllow") forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:confirmBtn];
    
    contentView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH - 100, CGRectGetMaxY(confirmBtn.frame));
    contentView.center = g_window.center;
    
}

- (void)confirmBtnAction {
    
    if ([self.delegate respondsToSelector:@selector(webAuthViewConfirmBtnAction)]) {
        [self.delegate webAuthViewConfirmBtnAction];
    }
    [self removeFromSuperview];
}

- (void)cancelBtnAction {
    [self removeFromSuperview];
}

@end
