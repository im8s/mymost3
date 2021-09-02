//
//  QRImage.h
//  shiku_im
//
//  Created by 1 on 17/9/14.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QRImage : NSObject

/**
 标准二维码

 @param string 二维码内容
 @param Imagesize 生成的二维码大小
 @return 返回标准二维码
 */
+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)Imagesize;


/**
 带中心头像二维码

 @param string 二维码内容
 @param Imagesize 生成的二维码大小
 @param logoImage logo图片
 @param logoImagesize logo图片大小.默认正方形
 @return 返回带中心头像二维码
 */
+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)Imagesize logoImage:(UIImage *)logoImage logoImageSize:(CGFloat)logoImagesize;


/**
 *  生成条形码
 *
 *  @return 生成条形码的UIImage对象
 */
+ (UIImage *)barCodeWithString:(NSString *)text BCSize:(CGSize)size;



@end
