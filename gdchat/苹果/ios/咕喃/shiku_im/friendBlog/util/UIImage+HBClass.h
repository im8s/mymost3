//
//  UIImage+HBClass.h
//  MyTest
//
//  Created by weqia on 13-7-30.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (HBClass)

//按原图比例返回限定大小的图片 （未剪切）
-(UIImage*) getLimitImage:(CGSize) size;

// 按原图比例返回限定大小的图片（剪切）
-(UIImage*) getClickImage:(CGSize) size;

@end
