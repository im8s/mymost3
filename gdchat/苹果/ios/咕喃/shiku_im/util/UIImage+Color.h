//
//  UIImage+Color.h
//  shiku_im
//
//  Created by 1 on 17/10/27.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)

+(UIImage*) createImageWithColor:(UIColor*) color;

// 图片缩小
+(UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

@end
