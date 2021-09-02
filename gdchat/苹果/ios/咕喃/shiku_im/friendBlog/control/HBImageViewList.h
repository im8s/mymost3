//
//  HBImageViewList.h
//  MyTest
//
//  Created by weqia on 13-7-31.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBImageScroller.h"

@interface HBImageViewList : UIScrollView<UIScrollViewDelegate>
{
    NSArray *_images;
    NSMutableArray *_imageViews;
    
    UIImage * _showImage;
    
    UIPageControl * _pageControl;
    
    int _prePage;
    
    id _target;
    
    SEL _tapOnceAction;
}

@property(nonatomic,readonly) NSArray * imageViews;

-(void)addImages:(NSArray*)images;          //添加图片

-(void)addImagesURL:(NSArray*)urls withSmallImage:(NSArray*)images;

-(void)addImagesURL:(NSArray *)urls;

-(void)setImage:(UIImage *)image;        //设置初始图片

-(void)setIndex:(int) index;

-(void)addTarget:(id)target tapOnceAction:(SEL)action; //添加单击事件的委托

@end
