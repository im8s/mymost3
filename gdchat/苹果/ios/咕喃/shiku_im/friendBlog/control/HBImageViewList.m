//
//  HBImageViewList.m
//  MyTest
//
//  Created by weqia on 13-7-31.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import "HBImageViewList.h"

@implementation HBImageViewList
@synthesize imageViews=_imageViews;

#pragma -mark 覆盖父类的方法
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor=[UIColor blackColor];
        self.pagingEnabled=YES;
        self.delegate=self;
        _prePage=0;
        _tapOnceAction=nil;
        _target=nil;
        
        self.showsHorizontalScrollIndicator=NO;
        self.showsVerticalScrollIndicator=NO;
        
        _pageControl=[[UIPageControl alloc]initWithFrame:CGRectZero];
        
        _pageControl.pageIndicatorTintColor=[UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor=[UIColor whiteColor];
        _pageControl.hidesForSinglePage=YES;
        
        [_pageControl addTarget:self action:@selector(pageChangeAction) forControlEvents:UIControlEventValueChanged];
         
    }
    return self;
}
-(void)didMoveToSuperview
{
    [_pageControl sizeToFit];
    CGRect frame=_pageControl.frame;
    frame.origin.x=(self.frame.size.width-frame.size.width)/2;
    frame.origin.y= JX_SCREEN_HEIGHT - 100;
    _pageControl.frame=frame;
    [self.superview addSubview:_pageControl];
}
-(void)didMoveToWindow
{
    [_pageControl removeFromSuperview];
}

#pragma -mark 接口方法

-(void)addImages:(NSArray *)images
{
    _images=images;
    _imageViews=[NSMutableArray array];
    NSInteger count=[_images count];
    self.contentSize=CGSizeMake(self.frame.size.width*count, self.frame.size.height);
    for(int i=0;i<count;i++)
    {
        HBImageScroller * scroll=[[HBImageScroller alloc]initWithFrame:CGRectMake(self.frame.size.width*i,0 , self.bounds.size.width,self.bounds.size.height)];
        [self addSubview:scroll];
        [scroll setImage:[_images objectAtIndex:i]];
        [_imageViews addObject:scroll];
        [scroll addTarget:self tapOnceAction:@selector(tapImageAction:)];
    }
    _pageControl.numberOfPages=count;

}

-(void)addImagesURL:(NSArray*)urls withSmallImage:(NSArray*)images
{
    _imageViews=[NSMutableArray array];
    NSInteger count=[urls count];
    self.contentSize=CGSizeMake(self.frame.size.width*count, self.frame.size.height);
    for(int i=0;i<count;i++)
    {
        HBImageScroller * scroll=[[HBImageScroller alloc]initWithFrame:CGRectMake(self.frame.size.width*i,0 , self.bounds.size.width,self.bounds.size.height)];
        [self addSubview:scroll];
        UIImage *image= nil;
        if(i<[images count])
            image=[images objectAtIndex:i];
        ObjUrlData* p = [urls objectAtIndex:i];
        [scroll setImageWithURL:p.url  andSmallImage:image];
        p = nil;
        [_imageViews addObject:scroll];
        [scroll addTarget:self tapOnceAction:@selector(tapImageAction:)];
        
    }
    _pageControl.numberOfPages=count;
}

-(void)setImage:(UIImage *)image
{
    int offset=0;
    NSInteger count= [_images count];
    for(int i=0;i<count;i++)
        if([_images objectAtIndex:i]==image)
        {
            offset=i;
            break;
        }
    self.contentOffset=CGPointMake(JX_SCREEN_WIDTH*offset, 0);
    _prePage=offset;
    _pageControl.currentPage=offset;
}
-(void)addTarget:(id)target tapOnceAction:(SEL)action
{
    _target=target;
    _tapOnceAction=action;
}
-(void)addImagesURL:(NSArray *)urls
{
    [self addImagesURL:urls withSmallImage:nil];
}
-(void)setIndex:(int) index
{
    self.contentOffset=CGPointMake(JX_SCREEN_WIDTH*index, 0);
    _prePage=index;
    _pageControl.currentPage=index;
}
#pragma -mark 实现委托方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page= scrollView.contentOffset.x/self.frame.size.width;
    if(_prePage!=page)
    {
        HBImageScroller* scroll=[ _imageViews objectAtIndex:_prePage];
        [scroll reset];
    }
    _prePage=page;
    _pageControl.currentPage=page;
}

#pragma -mark 事件响应方法
-(void)tapImageAction:(UIImageView*)view
{
    if(_tapOnceAction&&_target&&[_target respondsToSelector:_tapOnceAction])
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_target performSelector:_tapOnceAction withObject:view];
    
#pragma clang diagnostic pop
}

-(void) pageChangeAction
{
    NSInteger page=_pageControl.currentPage;
    [self scrollRectToVisible:CGRectMake(page*self.frame.size.width, 0, self.frame.size.width, self.frame.size.height) animated:YES];
}


@end
