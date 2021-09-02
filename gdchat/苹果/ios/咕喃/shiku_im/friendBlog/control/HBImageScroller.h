//
//  HBImageScroller.h
//  MyTest
//
//  Created by weqia on 13-7-31.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBImageScroller : UIScrollView
{
    UIImageView * _imageView;
    BOOL max;
    
    id _target;
    SEL _tapOnceAction;
    
    CGSize _beginSize;
    CGSize _beginImageSize;
    
    float _scale;
    float _imgScale;
   
}
@property(nonatomic,readonly) UIImageView * imageView;
@property(nonatomic,assign) UIViewController * controller;

-(id)initWithImage:(UIImage*)image andFrame:(CGRect)frame; //  根据图片,frame初始化

-(void) addTarget:(id)target  tapOnceAction:(SEL)action;  //添加单击事件的委托方法

-(void)setImage:(UIImage*)image;

-(void)setImageWithURL:(NSString*)url  andSmallImage:(UIImage*)image;


-(void)setImageWithURL:(NSString *)url ;

-(void)reset;  //还原

@end

typedef enum {
    RegionTopLeft=0,
    RegionBottomLeft,
    RegionTopRight,
    RegionBottomRight
} LocationRegion;
