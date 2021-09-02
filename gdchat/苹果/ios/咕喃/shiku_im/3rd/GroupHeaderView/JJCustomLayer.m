//
//  JJCustomLayer.m
//  QQHeader
//
//  Created by lijunjie on 15/12/28.
//  Copyright © 2015年 ljj. All rights reserved.
//

#import "JJCustomLayer.h"
#import "JJHeadersConfig.h"

static inline float radians(double degrees) { return degrees * M_PI / 180; }

@interface JJCustomLayer ()

@property (nonatomic, assign) NSInteger degrees;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL isClip;

@end

@implementation JJCustomLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _degrees = 0;
        _isClip = YES;
    }
    return self;
}

+ (JJCustomLayer *)createWithImage:(UIImage *)image degrees:(NSInteger)degrees isClip:(BOOL)isClip
{
    JJCustomLayer *res = [JJCustomLayer layer];
    [res updateWithImage:image degrees:degrees isClip:isClip];
    return res;
}

- (void)updateWithImage:(UIImage *)image degrees:(NSInteger)degrees isClip:(BOOL)isClip
{
    _degrees = degrees;
    _image = image;
    _isClip = isClip;
    self.contentsScale = [UIScreen mainScreen].scale;
}

- (void)drawInContext:(CGContextRef)context
{
    [super drawInContext:context];
       UIBezierPath *path =  [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:0];
         CGContextAddPath(context,path.CGPath);

    //    scale 由于输出的图不会进行缩放，所以缩放因子等于屏幕的scale即可
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0);
    
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithCGPath:path.CGPath];
        [bezierPath closePath];
        [bezierPath addClip];
        [_image drawInRect:self.bounds];
        UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIGraphicsPushContext( context );
        [maskedImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        UIGraphicsPopContext();
}

@end
