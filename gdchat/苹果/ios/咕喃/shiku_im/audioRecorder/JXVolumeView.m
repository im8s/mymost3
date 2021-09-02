//
//  JXVolumeView.m
//  shiku_im
//
//  Created by flyeagleTang on 14-7-24.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXVolumeView.h"
#import "UIImage-Extensions.h"

@interface JXVolumeView ()
@property (nonatomic, strong) UIImageView *voiceImgV;
@property (nonatomic, strong) UILabel *tintLabel;

@property (nonatomic, strong) UIImageView *cancelImgV;

@end

@implementation JXVolumeView
@synthesize volume;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
        
        UIView* v = [[UIView alloc]initWithFrame:self.bounds];
        v.backgroundColor = [UIColor blackColor];
        v.alpha = 0.6;
        [self addSubview:v];
        
        //椭圆下方的托架
        _volume = [[JXImageView alloc]initWithFrame:CGRectMake(20, 20, 120/2, 180/2)];
        _volume.image = [UIImage imageNamed:@"pub_recorder"];
        [self addSubview:_volume];
//        [_volume release];
        
//        //椭圆白色背景
//        JXImageView * inputBackground = [[JXImageView alloc]initWithFrame:CGRectMake(9, 1, 34, 66)];//20,1,66,132
//        inputBackground.image = [UIImage imageNamed:@"pub_microphone_volumeBg"];
//        inputBackground.layer.cornerRadius = 17;
//        inputBackground.clipsToBounds = YES;
//        [_volume addSubview:inputBackground];
////        [inputBackground release];
//
//        //椭圆红色背景
//        _input = [[JXImageView alloc]initWithFrame:CGRectMake(-0.2, 0, 34, 70)];
//        _input.image = [UIImage imageNamed:@"pub_microphone_volume"];
//        [inputBackground addSubview:_input];
        
        
        _cancelImgV = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-240/2)/2, 20, 240/2, 180/2)];
        _cancelImgV.image = [UIImage imageNamed:@"voice_cancel"];
        _cancelImgV.hidden = YES;
        [self addSubview:_cancelImgV];

        _voiceImgV = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_volume.frame)+15, 20, _volume.frame.size.width, _volume.frame.size.height)];
        _voiceImgV.image = [UIImage imageNamed:@"v1"];
        [self addSubview:_voiceImgV];

        _tintLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.height-13-15, frame.size.width, 13)];
        _tintLabel.text = Localized(@"JXVolumeView_CancelSend");
        _tintLabel.font = SYSFONT(13);
        _tintLabel.textColor = [UIColor whiteColor];
        _tintLabel.numberOfLines = 0;
        _tintLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_tintLabel];
    }
    return self;
}

- (void)setIsWillCancel:(BOOL)isWillCancel {
    _isWillCancel = isWillCancel;
    if (_isWillCancel) {
        _cancelImgV.hidden = NO;
        _volume.hidden = YES;
        _voiceImgV.hidden = YES;
        _tintLabel.text = Localized(@"JX_CancelSending");
    }else {
        _cancelImgV.hidden = YES;
        _volume.hidden = NO;
        _voiceImgV.hidden = NO;
        _tintLabel.text = Localized(@"JXVolumeView_CancelSend");
    }
}



-(void)setVolume:(double)value{
    volume = value;
    float n = value;
    float m = 1.0-n;
    
    _input.frame  =  CGRectMake(-0.2, 70*m -5 , 34, 70);
    _input.image = [UIImage imageNamed:@"pub_microphone_volume"];
    NSLog(@"---n:%f  m:%f",n,m);
    
    int g = n*10+1 > 7 ? 7 : n*10+1;
    
    _voiceImgV.image = [UIImage imageNamed:[NSString stringWithFormat:@"v%d", g]];
}

//截取部分图像,无用
-(UIImage*)getSubImage:(CGRect)rect
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(_input.image.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return smallImage;
}

-(void)show{
    [g_window addSubview:self];
}

-(void)hide{
    [self removeFromSuperview];
}

@end
