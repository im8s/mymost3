//
//  QRImage.m
//  shiku_im
//
//  Created by 1 on 17/9/14.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "QRImage.h"

@implementation QRImage


//标准二维码
+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)Imagesize{
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];//通过kvo方式给一个字符串，生成二维码
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];//设置二维码的纠错水平，越高纠错水平越高，可以污损的范围越大
    CIImage *outPutImage = [filter outputImage];//拿到二维码图片
    return [[self alloc] createNonInterpolatedUIImageFormCIImage:outPutImage imageSize:Imagesize logoImage:nil logoImageSize:0];
}

//带中心头像二维码
+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)Imagesize logoImage:(UIImage *)logoImage logoImageSize:(CGFloat)logoImagesize{
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];//通过kvo方式给一个字符串，生成二维码
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];//设置二维码的纠错水平，越高纠错水平越高，可以污损的范围越大
    CIImage *outPutImage = [filter outputImage];//拿到二维码图片
    return [[self alloc] createNonInterpolatedUIImageFormCIImage:outPutImage imageSize:Imagesize logoImage:logoImage logoImageSize:logoImagesize];
}

/**
 *  生成条形码
 *
 *  @return 生成条形码的UIImage对象
 */
+ (UIImage *)barCodeWithString:(NSString *)text BCSize:(CGSize)size
{
    CIImage *image = [self generateBarCodeImage:text];
    
    return [self resizeCodeImage:image withSize:size];
}

+ (CIImage *)generateBarCodeImage:(NSString *)source
{
    // iOS 8.0以上的系统才支持条形码的生成，iOS8.0以下使用第三方控件生成
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 注意生成条形码的编码方式
        NSData *data = [source dataUsingEncoding: NSASCIIStringEncoding];
        CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
        [filter setValue:data forKey:@"inputMessage"];
        // 设置生成的条形码的上，下，左，右的margins的值
        [filter setValue:[NSNumber numberWithInteger:0] forKey:@"inputQuietSpace"];
        return filter.outputImage;
    }else{
        return nil;
    }
}

+ (UIImage *)resizeCodeImage:(CIImage *)image withSize:(CGSize)size
{
    if (image) {
        CGRect extent = CGRectIntegral(image.extent);
        CGFloat scaleWidth = size.width/CGRectGetWidth(extent);
        CGFloat scaleHeight = size.height/CGRectGetHeight(extent);
        size_t width = CGRectGetWidth(extent) * scaleWidth;
        size_t height = CGRectGetHeight(extent) * scaleHeight;
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
        CGContextRef contentRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef imageRef = [context createCGImage:image fromRect:extent];
        CGContextSetInterpolationQuality(contentRef, kCGInterpolationNone);
        CGContextScaleCTM(contentRef, scaleWidth, scaleHeight);
        CGContextDrawImage(contentRef, extent, imageRef);
        CGImageRef imageRefResized = CGBitmapContextCreateImage(contentRef);
        UIImage *barImage = [UIImage imageWithCGImage:imageRefResized];
        
        //Core Foundation 框架下内存泄露问题。
        CGContextRelease(contentRef);
        CGColorSpaceRelease(colorSpaceRef);
        CGImageRelease(imageRef);
        CGImageRelease(imageRefResized);
        return barImage;
    }else{
        return nil;
    }
}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image imageSize:(CGFloat)imageSize logoImage:(UIImage *)logoImage logoImageSize:(CGFloat)logoImagesize{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(imageSize/CGRectGetWidth(extent), imageSize/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    //创建一个DeviceGray颜色空间
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    //CGBitmapContextCreate(void * _Nullable data, size_t width, size_t height, size_t bitsPerComponent, size_t bytesPerRow, CGColorSpaceRef  _Nullable space, uint32_t bitmapInfo)
    //width：图片宽度像素
    //height：图片高度像素
    //bitsPerComponent：每个颜色的比特值，例如在rgba-32模式下为8
    //bitmapInfo：指定的位图应该包含一个alpha通道。
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    //创建CoreGraphics image
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef); CGImageRelease(bitmapImage);
    
    //原图
    UIImage *outputImage = [UIImage imageWithCGImage:scaledImage];
    //给二维码加 logo 图
    UIGraphicsBeginImageContextWithOptions(outputImage.size, NO, [[UIScreen mainScreen] scale]);
    [outputImage drawInRect:CGRectMake(0,0 , imageSize, imageSize)];

    if (logoImage) {
        logoImage = [self logoImage:logoImage withParam:logoImagesize/2];
        //把logo图画到生成的二维码图片上，注意尺寸不要太大（最大不超过二维码图片的%30），太大会造成扫不出来
        [logoImage drawInRect:CGRectMake((imageSize-logoImagesize)/2.0, (imageSize-logoImagesize)/2.0, logoImagesize, logoImagesize)];
    }
    
    outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}

- (UIImage *)logoImage:(UIImage *)image withParam:(CGFloat)inset {
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, inset*2, inset*2)];
    imageV.image = image;
    imageV.layer.cornerRadius = 5;
    imageV.layer.masksToBounds = YES;
    imageV.layer.borderColor = [UIColor whiteColor].CGColor;
    imageV.layer.borderWidth = 3.f;
    
    UIImage *newImage = [UIImage imageWithView:imageV];
    
    return newImage;
}


@end
