//
//  UIImage+HBClass.m
//  MyTest
//
//  Created by weqia on 13-7-30.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import "UIImage+HBClass.h"

@implementation UIImage (HBClass)
-(UIImage*) getLimitImage:(CGSize) size
{
    // 排错
    if(size.width==0||size.height==0)
        return self;
    CGSize imgSize=self.size;
    float scale=size.height/size.width;
    float imgScale=imgSize.height/imgSize.width;
    float width=0.0f,height=0.0f;
    if(imgScale<scale&&imgSize.width>size.width){
        width=size.width;
        height=width*imgScale;
    }else if(imgScale>scale&&imgSize.height>size.height){
        height=size.height;
        width=height/imgScale;
    }
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [self drawInRect:CGRectMake(0, 0, width, height)];
    UIImage * image= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIImage*) getClickImage:(CGSize) size
{
    // 排错
    if(size.width==0||size.height==0)
        return self;
    CGSize imgSize=self.size;
    UIImageOrientation  orientation=self.imageOrientation;
    CGRect rect;
    if(size.height>=imgSize.height&&size.width>=imgSize.width)
        return self;
    else if(size.height>=imgSize.height&&size.width<imgSize.width)
         rect=CGRectMake((imgSize.width-size.width)/2, 0, size.width, imgSize.height);
    else if(size.height<imgSize.height&&size.width>=imgSize.width)
         rect=CGRectMake(0, (imgSize.height-size.height)/2, imgSize.width, size.height);
    else
         rect=CGRectMake((imgSize.width-size.width)/2,(imgSize.height-size.height)/2, size.width, size.height);
    CGImageRef imgRef=CGImageCreateWithImageInRect(self.CGImage, rect);
    return [UIImage imageWithCGImage:imgRef scale:1 orientation:orientation];
}

@end
