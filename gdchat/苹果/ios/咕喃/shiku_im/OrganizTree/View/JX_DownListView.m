//
//  JX_DownListView.m
//  shiku_im
//
//  Created by 1 on 17/5/24.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JX_DownListView.h"

@interface JX_DownListView ()
@property (nonnull, strong) UIView *backgroundView;
@property (nonatomic, strong) DownListPopOptionBlock optionBlock;

@property (nonatomic, strong) UIImageView *backImgV;
@end


@implementation JX_DownListView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        self.alpha = 0.0f;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    }
    return self;
}

-(instancetype)downlistPopOption:(DownListPopOptionBlock)block whichFrame:(CGRect)frame animate:(BOOL)animate {
    
    self.optionBlock = block;
    [self setupParams:animate];
    
    if (self.maxWidth > 0) {
        if (self.maxWidth + 50 < self.frame.size.width*self.mutiple) {
            self.maxWidth = self.frame.size.width*self.mutiple - 30;
        }else {
            self.maxWidth = self.maxWidth + 20;
        }
    }else {
        for (NSInteger i = 0; i < self.listContents.count; i ++) {
            NSString *str = self.listContents[i];
            NSString *imageStr = self.listImages[i];
            CGSize size = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0]} context:nil].size;
            if (imageStr.length > 0) {
                if (size.width > self.maxWidth - 60) {
                    self.maxWidth = size.width + 35 + (self.lineHeight-23);
                }
            }else {
                if (size.width > self.maxWidth) {
                    self.maxWidth = size.width + 20;
                }
            }
        }
    }
    
    [self setupBackgourndview:frame];
    return self;
}


-(void)show {
    [UIView animateWithDuration:self.animateTime animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesturePressed)];
//        [self addGestureRecognizer:tapGesture];
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self tapGesturePressed];
}

#pragma mark - private
-(void) setupParams:(BOOL)animate {
    if (self.lineHeight == 0) {
        self.lineHeight = 40.0f;
    }
    if (self.mutiple == 0) {
        self.mutiple = 0.4f;
    }
    if (animate) {
        if (self.animateTime == 0) {
            self.animateTime = 0.2f;
        }
    } else {
        self.animateTime = 0;
    }
}

// 创建背景
- (void) setupBackgourndview:(CGRect)whichFrame {
    self.backgroundView = [UIView new];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.backgroundView.layer.cornerRadius = 5;
    self.backgroundView.layer.masksToBounds = YES;
//    self.backgroundView.layer.borderWidth = 0.5;
//    self.backgroundView.layer.borderColor = [HEXCOLOR(0xd8d8d8) CGColor];
    [self addSubview:self.backgroundView];
    
    //背景图片
    self.backImgV = [[UIImageView alloc]init];
    UIImage *image = [[UIImage imageNamed:@"Haircircleoffriends_white"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 25, 10) resizingMode:UIImageResizingModeStretch];
    self.backImgV.image = image;
    [self.backgroundView addSubview:self.backImgV];

    
    [self tochangeBackgroudViewFrame:whichFrame];
    [self setupOptionButton];
}
- (void) setupOptionButton {
    if ((self.listContents&&self.listContents.count>0)) {
        for (NSInteger i = 0; i < self.listContents.count; i++) {
            UIButton *optionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            int addY = 10;
            if (self.showType == DownListView_ShowUp || self.showType == DownListView_Center) {
                addY = 0;
            }
            optionButton.frame = CGRectMake(0,
                                            self.lineHeight*i + addY,
                                            self.maxWidth,
                                            self.lineHeight);
            if (_color) {
                [optionButton setBackgroundColor:[UIColor clearColor]];
            }
            
            optionButton.tag = i;
            BOOL unEnable = NO;
            if (self.listEnables && self.listEnables.count > 0) {
                BOOL enable = [self.listEnables[optionButton.tag] boolValue];
                //                optionButton.enabled = enable;
                if (!enable){
                    unEnable = YES;
                    [optionButton addTarget:self action:@selector(noPermission:) forControlEvents:UIControlEventTouchUpInside];
                }else{
                    [optionButton addTarget:self action:@selector(buttonSelectPressed:)
                           forControlEvents:UIControlEventTouchUpInside];
                }
            }else{
                [optionButton addTarget:self action:@selector(buttonSelectPressed:)
                       forControlEvents:UIControlEventTouchUpInside];
            }
            
            [optionButton addTarget:self action:@selector(buttonSelectDown:)
                   forControlEvents:UIControlEventTouchDown];
            [optionButton addTarget:self action:@selector(buttonSelectOutside:)
                   forControlEvents:UIControlEventTouchUpOutside];
            [self.backgroundView addSubview:optionButton];
            
            [self setupOptionContent:optionButton enable:unEnable];
        }
    }
}
- (void) setupOptionContent:(UIButton *)optionButton enable:(BOOL)enable{
    if(self.listImages && self.listImages.count>0) {
        
        UIImageView *headImageView = [UIImageView new];
        headImageView.frame = CGRectMake(12, 11.5, self.lineHeight-23, self.lineHeight-23);
        headImageView.image = [UIImage imageNamed:self.listImages[optionButton.tag]];
        [optionButton addSubview:headImageView];
        
        UILabel *contentLabel = [UILabel new];
        contentLabel.frame = CGRectMake(CGRectGetMaxX(headImageView.frame)+11,
                                        0,
                                        self.frame.size.width-(CGRectGetMaxX(headImageView.frame)+11),
                                        self.lineHeight);
        contentLabel.text = self.listContents[optionButton.tag];
        if (self.textColor) {
            contentLabel.textColor = self.textColor;
        }else {
            contentLabel.textColor = [UIColor blackColor];
        }
        contentLabel.font = [UIFont systemFontOfSize:15];
        if (enable) {
            contentLabel.textColor = [UIColor grayColor];
            headImageView.image = [[UIImage imageNamed:self.listImages[optionButton.tag]] imageWithTintColor:[UIColor grayColor]];
        }
        [optionButton addSubview:contentLabel];
    } else {
        UILabel *contentLabel = [UILabel new];
        [optionButton addSubview:contentLabel];
        contentLabel.frame = optionButton.bounds;
        contentLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.text = self.listContents[optionButton.tag];
        if (self.textColor) {
            contentLabel.textColor = self.textColor;
        }else {
            contentLabel.textColor = [UIColor blackColor];
        }
        contentLabel.font = [UIFont systemFontOfSize:15];
        if (enable) {
            contentLabel.textColor = [UIColor grayColor];
        }
    }
                               
    if(optionButton.tag != 0) {
        UIView *lineView = [UIView new];
        lineView.backgroundColor = [HEXCOLOR(0xd8d8d8) colorWithAlphaComponent:0.1];
        lineView.frame = CGRectMake(0,
                                    0,
                                    self.maxWidth,
                                    .5);
        [optionButton addSubview:lineView];
    }
    
}
- (void) tochangeBackgroudViewFrame:(CGRect)whichFrame {
    CGFloat self_w = self.frame.size.width;
    
    CGFloat which_x = whichFrame.origin.x;
    CGFloat which_w = whichFrame.size.width;
    CGFloat which_h = whichFrame.size.height;
    
    CGFloat background_x = which_x-((self.maxWidth/2)-which_w/2);
    CGFloat background_w = self.maxWidth;
    CGFloat background_h = self.lineHeight*self.listContents.count+10;
    CGFloat background_y;
    if (self.showType == DownListView_ShowUp || self.showType == DownListView_Center) {
        background_y = whichFrame.origin.y - background_h;
    }else {
        background_y = whichFrame.origin.y+which_h;
        if ((background_y + background_h) > JX_SCREEN_HEIGHT) {
            background_y = whichFrame.origin.y - background_h;
            self.showType = DownListView_ShowUp;
        }
    }
    
    
    if (background_x < 10) {
        background_x = 10;
    }
//    if (self_w-(which_x+which_w)<=10||
//        ((self_w*self.mutiple/2)-which_w/2>=(self_w-(which_x+which_w)))) {
//        background_x = self_w-(self_w*self.mutiple)-10;
//    }
    
    if ((background_x + background_w + 10) > self_w) {
        background_x = self_w-(self.maxWidth)-10;
    }
    
    self.backgroundView.frame = CGRectMake(background_x, background_y, background_w, background_h);
    
    self.backImgV.frame = self.backgroundView.bounds;
    
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"downlistSelect_Black"] imageWithTintColor:self.color]];
//    [self addSubview:imageView];
    
//    imageView.frame = CGRectMake(which_x+which_w/2-10,
//                                 background_y-15,
//                                 20,
//                                 15);
    if (self.showType == DownListView_ShowUp) {
        self.backImgV.image = [UIImage imageNamed:@"Haircircleoffriends_up"];
//        imageView.image = [UIImage imageNamed:@"ic_public_menu"];
//        imageView.frame = CGRectMake(imageView.frame.origin.x, background_y + background_h - 6, imageView.frame.size.width, imageView.frame.size.height);
    }else if (self.showType == DownListView_Center) {
        self.backImgV.image = [UIImage imageNamed:@"Haircircleoffriends_center"];
    }
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}
// 点击消失
- (void) tapGesturePressed {
    [UIView animateWithDuration:self.animateTime animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:self.animateTime animations:^{
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
}


#pragma mark - inside outside down

- (void) buttonSelectPressed:(UIButton *)button {
    self.optionBlock(button.tag, self.listContents[button.tag]);
    button.backgroundColor = [UIColor whiteColor];
    [self tapGesturePressed];
}
-(void) noPermission:(UIButton *)button{
    [g_App showAlert:Localized(@"OrgaVC_PermissionDenied")];
    [self tapGesturePressed];
}
- (void) buttonSelectDown:(UIButton *)button {
    button.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
}
- (void) buttonSelectOutside:(UIButton *)button {
    button.backgroundColor = [UIColor whiteColor];
}


#pragma mark - dealloc

- (void)dealloc {
    self.optionBlock = nil;
}

@end
