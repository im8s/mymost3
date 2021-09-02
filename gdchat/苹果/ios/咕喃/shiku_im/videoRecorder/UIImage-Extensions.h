//
//  UIImage-Extensions.h
//  CutPicetureDemo
//
//  Created by yang kong on 12-6-27.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (CS_Extensions)
- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;   //按尺寸缩放
- (UIImage *)imageByScalingToScale:(CGFloat)toScale;    //按比例缩放
- (UIImage *)cutImageBy:(CGSize)oSize;                  //切图
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end;
