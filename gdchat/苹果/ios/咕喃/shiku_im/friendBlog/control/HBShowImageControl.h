//
//  HBShowImageControl.h
//  MyTest
//
//  Created by weqia on 13-8-8.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSImageUtil.h"
#import "HBImageViewList.h"

#define MAX_WIDTH  200.0
#define MAX_HEIGHT 150.0
#define IMAGE_SIZE (JX_SCREEN_WIDTH-69*2-IMAGE_SPACE*2)/3
#define IMAGE_SPACE 5

@class HBShowImageControl;

@protocol HBShowImageControlDelegate <NSObject>
@optional
-(void)showImageControlFinishLoad:(HBShowImageControl*)control;

-(void)lookImageAction:(HBShowImageControl*)control;

-(void)lookFileAction:(HBShowImageControl*)control files:(NSArray*)files;

@end

@interface HBShowImageControl : UIView
{
    NSMutableArray * _imageViews;
    NSMutableArray * _images;
    NSMutableArray * _bigUrls;

    NSArray * _files;
    NSArray * _imgurls;
    
    
    NSImageUtil *_util;
    HBImageViewList *_imageList;
}
@property(nonatomic,weak) id<HBShowImageControlDelegate> delegate;
@property(nonatomic,weak) UIViewController * controller;
@property(nonatomic,strong) NSMutableArray * larges;
@property BOOL bFirstSmall;
@property(nonatomic) int smallTag;
@property(nonatomic) int bigTag;



+(float)heightForFiles:(NSArray*)files;
-(void)setImagesFileStr:(NSString*)fileStr;
-(void)setImagesWithFiles:(NSArray*)files;
+(float)heightForFileStr:(NSString*)fileStr;


@end
