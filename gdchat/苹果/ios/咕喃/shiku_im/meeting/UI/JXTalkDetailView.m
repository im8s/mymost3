//
//  JXTalkDetailView.m
//  lveliao_IM
//
//  Created by p on 2019/8/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXTalkDetailView.h"

@implementation JXTalkDetailView

- (instancetype)initWithFrame:(CGRect)frame {
 
    if ([super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.2];
        [self customView];
    }
    
    return self;
}

- (void)customView {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchUpInside:)];
    [self addGestureRecognizer:tap];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 228, 176)];
    contentView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height /2);
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 10.0;
    contentView.layer.masksToBounds = YES;
    [self addSubview:contentView];
    
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 52, 52)];
    _headImageView.center = CGPointMake(contentView.frame.size.width / 2, _headImageView.center.y);
    _headImageView.layer.cornerRadius = 5;
    _headImageView.layer.masksToBounds = YES;
    [contentView addSubview:_headImageView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headImageView.frame) + 10, contentView.frame.size.width, 16)];
    _nameLabel.textColor = HEXCOLOR(0x333333);
    _nameLabel.font = [UIFont systemFontOfSize:16.0];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:_nameLabel];
    
    _lastLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_nameLabel.frame) + 20, contentView.frame.size.width, 14)];
    _lastLabel.textColor = HEXCOLOR(0x999999);
    _lastLabel.font = [UIFont systemFontOfSize:14.0];
    _lastLabel.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:_lastLabel];
    
    _talkLable = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_lastLabel.frame) + 10, contentView.frame.size.width, 14)];
    _talkLable.textColor = HEXCOLOR(0x999999);
    _talkLable.font = [UIFont systemFontOfSize:14.0];
    _talkLable.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:_talkLable];
}

- (void)touchUpInside:(id)sender {
    self.hidden = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
