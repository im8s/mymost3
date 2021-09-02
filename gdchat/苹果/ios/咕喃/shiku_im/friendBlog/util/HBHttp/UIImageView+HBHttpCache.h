//
//  UIImageView+HBHttpCache.h
//  MyTest
//
//  Created by weqia on 13-8-22.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBHttpImageDownloader.h"

typedef enum {
    UIImageViewLayoutNone=0,
    UIImageViewLayoutClick,
    UIImageViewLayoutLimit
}UIImageViewLayoutType;


@interface UIImageView (HBHttpCache)

-(void) setImageWithURL:(NSString*)url;


-(void) setImageWithURL:(NSString*)url
                 layout:(UIImageViewLayoutType)layout;


-(void) setImageWithURL:(NSString *)url
                 layout:(UIImageViewLayoutType)layout
       placeholderImage:(UIImage*)placeholderImage;


-(void) setImageWithURL:(NSString *)url
                 layout:(UIImageViewLayoutType)layout
       placeholderImage:(UIImage*)placeholderImage
                process:(HBHttpImageDownloaderProcessBlock) process
               complete:(HBHttpImageDownloaderCompleteBlock)complete;


-(void) setImageWithURL:(NSString *)url
                 layout:(UIImageViewLayoutType)layout
       placeholderImage:(UIImage*)placeholderImage
                process:(HBHttpImageDownloaderProcessBlock)process
               complete:(HBHttpImageDownloaderCompleteBlock)complete
                 option:(HBHttpImageDownloaderOption)option;

-(void) setImageWithIndirectURL:(NSString *)indirectURL;


-(void) setImageWithIndirectURL:(NSString *)indirectURL
                         layout:(UIImageViewLayoutType)layout;


-(void) setImageWithIndirectURL:(NSString *)indirectURL
                         layout:(UIImageViewLayoutType)layout
               placeholderImage:(UIImage *)placeholderImage;


-(void) setImageWithIndirectURL:(NSString *)indirectURL
                         layout:(UIImageViewLayoutType)layout
               placeholderImage:(UIImage *)placeholderImage
                        process:(HBHttpImageDownloaderProcessBlock)process
                       complete:(HBHttpImageDownloaderCompleteBlock)complete;


-(void) setImageWithIndirectURL:(NSString *)indirectURL
                         layout:(UIImageViewLayoutType)layout
               placeholderImage:(UIImage *)placeholderImage
                        process:(HBHttpImageDownloaderProcessBlock)process
                       complete:(HBHttpImageDownloaderCompleteBlock)complete
                         option:(HBHttpImageDownloaderOption)option;

-(void) setImageWithCacheKey:(NSString *)key layout:(UIImageViewLayoutType)layout
            placeholderImage:(UIImage *)placeholderImage;

@end
