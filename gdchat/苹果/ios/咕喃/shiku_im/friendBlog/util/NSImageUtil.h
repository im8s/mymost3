//
//  NSImageUtil.h
//  wq
//
//  Created by weqia on 13-7-25.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {

    THUMB_NOTIC_BIG=1,      //公告原图
    THUMB_NOTIC_MIDDLE=2,    //公告中图
    THUMB_NOTIC_SMALL_1=3,   //公告小图
    THUMB_WEIBO_BIG=6,    // 分享原图
    THUMB_WEIBO_MIDDLE=7,  //分享中图
    THUMB_WEIBO_SMALL_1=8,   //分享小图
    THUMB_WEIBO_SMALL_2=9,  //分享小图
    THUMB_TASK_BIG=11,   //任务原图
    THUMB_TASK_MIDDLE=12,  //任务中图
    THUMB_TASK_SMALL_1=13,  //任务小图
    THUMB_TALK_BIG=16,  //聊天原图
    THUMB_TALK_MIDDLE=17,  //聊天中图
    THUMB_TALK_SMALL_1=18,  //聊天小图
    
    THUMB_AVATAR_BIG=21 ,  //头像原图
    THUMB_AVATAR_SMALL_2=22,  //头像小图
    
    THUMB_LOGO_BIG=26,  //logo原图（企业）
    THUMB_LOGO_SMALL_2=27   //logo小图（企业）

} ImageThumbType;



@interface NSImageUtil : NSObject
{
    UIImage * _image;
    UIView * _backView;
    UIImageView *_imageView;
}

+(UIImage*)getClickImage:(UIImage*)originaLimage  withSize:(CGSize)size;
+(UIImage*)limitSizeImage:(UIImage*)originaImage withSize:(CGSize)size;
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;
-(void) showBigImage:(UIImage*)image fromView:(UIImageView*)fromView  complete:(void(^)(UIView *bacView))complete;

-(void) showBigImageWithUrl:(NSString *)url fromView:(UIImageView *)fromView complete:(void (^)(UIView *))complete;

-(void) goBackToView:(UIImageView*)toView withImage:(UIImage*)image;

-(void) goBackToView:(UIImageView *)toView withImageUrl:(NSString *)url;

@end
