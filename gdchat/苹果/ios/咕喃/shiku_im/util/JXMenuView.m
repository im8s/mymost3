//
//  JXMenuView.m
//  shiku_im
//
//  Created by 1 on 2018/9/6.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXMenuView.h"
#import "UIImage+Color.h"

#define HEIGHT           38     // 点赞评论控件整体高
#define INSET            16     // 点赞评论控件左右间距
#define TEXT_FONT   SYSFONT(14) // 字体大小

@interface JXMenuView ()

@property (nonatomic, strong) NSArray *images;
//@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, assign) CGFloat w;

@property (nonatomic, assign) CGPoint point;


@end

@implementation JXMenuView

//  Point (.x 暂时无效)
- (instancetype)initWithPoint:(CGPoint)point Title:(NSArray *)titles Images:(NSArray *)images {
    self = [super init];
    if (self) {
        self.point = point;
        self.images = images;
        self.titles = titles;
        [self setupViews];
    }
    return self;
}



- (void)setupViews {
    self.backgroundColor = HEXCOLOR(0x3B4042);
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4.0f;
    NSInteger w = 0;
    UIButton *cellView;
    for (int i = 0; i < self.titles.count; i++) {
        NSString *str = self.titles[i];
        CGSize size = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:TEXT_FONT} context:nil].size;
        cellView = [[UIButton alloc] init];
        UIImageView *imgV;
        
        if (self.images.count > 0 && i < self.images.count) {
            CGFloat H = 14.f;
            cellView.frame = CGRectMake(w, 0, INSET*2+H+size.width, HEIGHT);
            imgV = [[UIImageView alloc] initWithFrame:CGRectMake(INSET, (HEIGHT-H)/2, H, H)];
            imgV.image = [UIImage imageNamed:self.images[i]];
            [cellView addSubview:imgV];
        } else {
            cellView.frame = CGRectMake(w, 0, INSET*2+size.width, HEIGHT);
        }
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.font = TEXT_FONT;
        textLabel.text = str;
        textLabel.textColor = [UIColor whiteColor];
        if (i < self.images.count) {
            textLabel.frame = CGRectMake(CGRectGetMaxX(imgV.frame)+4, (HEIGHT-size.height)/2, size.width, size.height);
        }else {
            textLabel.frame = CGRectMake(0, (HEIGHT-size.height)/2, cellView.frame.size.width, size.height);
            textLabel.textAlignment = NSTextAlignmentCenter;
        }
        [cellView addSubview:textLabel];
        cellView.backgroundColor = [UIColor clearColor];
        cellView.tag = i;
        [cellView setImage:[UIImage createImageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [cellView setImage:[UIImage createImageWithColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
        [cellView addTarget:self action:@selector(didCellView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cellView];
        if (i > 0) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 0.5, HEIGHT-10)];
            line.backgroundColor = HEXCOLOR(0x292D2F);
            [cellView addSubview:line];
        }
        w += cellView.frame.size.width;
    }
    
    _w = w;
    // 获取 回复按钮的Point (.x 暂时无效)
    CGRect frame = self.frame;
    frame.origin = self.point;
//    self.frame = CGRectMake(frame.origin.x+_w, frame.origin.y, 0, HEIGHT);
//    [UIView animateWithDuration:.1f animations:^{
//        self.frame = CGRectMake(frame.origin.x, frame.origin.y, w, HEIGHT);
//    }];
    self.frame = CGRectMake(JX_SCREEN_WIDTH-44, frame.origin.y, 0, HEIGHT);
    [UIView animateWithDuration:.1f animations:^{
        self.frame = CGRectMake(JX_SCREEN_WIDTH-_w-44, frame.origin.y, w, HEIGHT);
    }];

}


- (void)didCellView:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didMenuView:WithButtonIndex:)]) {
        [self dismissBaseView];
        [self.delegate didMenuView:self WithButtonIndex:button.tag];
    }
    
}


- (void)dismissBaseView {
    
    if (self) {
        [UIView animateWithDuration:.08f animations:^{
            self.frame = CGRectMake(self.frame.origin.x+_w, self.frame.origin.y, 0, HEIGHT);
        } completion:^(BOOL finished) {
            UIView *view = self;
            [view removeFromSuperview];
            view = nil;
        }];
    }
}


@end
