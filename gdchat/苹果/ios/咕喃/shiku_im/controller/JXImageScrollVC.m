//
//  JXImageScrollVC.m
//  shiku_im
//
//  Created by Apple on 16/3/14.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXImageScrollVC.h"
#import "JXImageView.h"
@interface JXImageScrollVC () <UIScrollViewDelegate,UIGestureRecognizerDelegate>

@end

@implementation JXImageScrollVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self createScrollView];
    
    [self setScrollViewProperty];
    
    [self addTapGR];
}



- (void)createScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    
    //给ScrollView添加子视图，
    [self.scrollView addSubview:self.iv];
    
    //设置ScrollView内容的大小
    self.scrollView.contentSize = self.imageSize;
    

    [self.view addSubview:self.scrollView];
    
}




//调整ScrollView的property
- (void)setScrollViewProperty
{
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = YES;
    //设置代理
    self.scrollView.delegate = self;
    
    //指定scrollView的最大缩放倍率
    self.scrollView.maximumZoomScale = 5.0;
    //指定scrollView的最小缩放倍率
    self.scrollView.minimumZoomScale = 1.0;
    //scrollView内容距离上下的边界边距
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return scrollView.subviews[0];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{

}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    
    //目前contentsize的width是否大于原scrollview的contentsize，如果大于，设置imageview中心x点为contentsize的一半，以固定imageview在该contentsize中心。如果不大于说明图像的宽还没有超出屏幕范围，可继续让中心x点为屏幕中点，此种情况确保图像在屏幕中心。
    
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
    
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
    [self.iv setCenter:CGPointMake(xcenter, ycenter)];
}

- (void)addTapGR
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapStart:)];
    
    tap.delegate = self;
    
    [self.scrollView addGestureRecognizer:tap];
    
}

- (void)tapStart:(UITapGestureRecognizer*)tap
{
//    [UIView animateWithDuration:0.3 animations:^{
//        self.iv.frame = CGRectMake(0, 0, 0, 0);
//        self.iv.center = self.view.center;
//        self.view.alpha = 0;
//    } completion:^(BOOL finished) {
//        [self.view removeFromSuperview];
        [self dismissViewControllerAnimated:YES completion:nil];
//    }];
    
}


@end


