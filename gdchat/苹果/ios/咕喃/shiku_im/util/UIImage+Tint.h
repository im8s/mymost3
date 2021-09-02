//
//  UIImage+Tint.h
//  shiku_im
//
//  Created by 1 on 17/3/6.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tint)


-(UIImage *) imageWithTintColor:(UIColor * )tintColor;
-(UIImage *) imageWithGradientTintColor:(UIColor *)tintColor;


// 控件绘制成图片
+ (UIImage *)imageWithView:(UIView *)view;

// 根据图片url获取网络图片尺寸
+ (CGSize)getImageSizeWithURL:(id)URL;


@end
