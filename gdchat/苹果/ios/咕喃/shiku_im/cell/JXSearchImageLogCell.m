//
//  JXSearchImageLogCell.m
//  shiku_im
//
//  Created by p on 2019/4/9.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXSearchImageLogCell.h"

@interface JXSearchImageLogCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *pauseBtn;

@end

@implementation JXSearchImageLogCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self customViewWithFrame:frame];
    }
    
    return self;
}


- (void)customViewWithFrame:(CGRect)frame{
    self.contentView.clipsToBounds = YES;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.contentView addSubview:self.imageView];
    
    _pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    _pauseBtn.center = CGPointMake(self.imageView.frame.size.width/2,self.imageView.frame.size.height/2);
    [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"playvideo"] forState:UIControlStateNormal];
    //    [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"pausevideo"] forState:UIControlStateSelected];
//    [_pauseBtn addTarget:self action:@selector(showTheVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:_pauseBtn];
}

- (void)setMsg:(JXMessageObject *)msg {
    _msg = msg;
    
    if ([msg.type integerValue] == kWCMessageTypeImage) {
        self.pauseBtn.hidden = YES;
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:msg.content] placeholderImage:[UIImage imageNamed:@"avatar_normal"]];
    }else {
        self.pauseBtn.hidden = NO;
        if([self.msg.content rangeOfString:@"http://"].location == NSNotFound && [self.msg.content rangeOfString:@"https://"].location == NSNotFound) {
            [FileInfo getFirstImageFromVideo:self.msg.fileName imageView:self.imageView];
        }else {
            [FileInfo getFirstImageFromVideo:self.msg.content imageView:self.imageView];
        }
    }
    
}

- (void)showTheVideo {
   
}

@end
