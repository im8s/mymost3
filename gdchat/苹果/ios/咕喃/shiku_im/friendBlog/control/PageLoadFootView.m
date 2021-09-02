//
//  PageLoadFootView.m
//  wq
//
//  Created by weqia on 13-7-22.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//

#import "PageLoadFootView.h"

@implementation PageLoadFootView

@synthesize delegate;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isLoading=NO;
        
        self.frame=CGRectMake(0, 0, JX_SCREEN_WIDTH, 40);
        image=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialog_load"]];
        image.frame=CGRectMake(120, 23, 15, 15);
        
        [self addSubview:image];
        
        UILabel * label=[[UILabel alloc]initWithFrame:CGRectMake(140, 20, 60, 20)];
        label.backgroundColor=[UIColor clearColor];
        label.textAlignment=NSTextAlignmentCenter;
        label.textColor=[UIColor grayColor];
        label.text=Localized(@"PageLoadFootView_Loading");
        label.font=[UIFont systemFontOfSize:12];
        loadText=label;
        [self addSubview:label];
        
        label=[[UILabel alloc]initWithFrame:CGRectMake(130, 20, 60, 20)];
        label.backgroundColor=[UIColor clearColor];
        label.textAlignment=NSTextAlignmentCenter;
        label.textColor=[UIColor grayColor];
        label.text=Localized(@"PageLoadFootView_LoadOK");
        label.font=[UIFont systemFontOfSize:12];
        finishText=label;
        [label setHidden:YES];
    //    [self addSubview:label];
        
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
        rotationAnimation.duration = 1;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = MAXFLOAT;
        
        [image.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        
    }
    return self;
}

-(void) animmation
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    
    [image.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float h=scrollView.contentSize.height-scrollView.frame.size.height-20;
    if(scrollView.contentOffset.y>=h&&!isLoading&&scrollView.contentOffset.y>50)
    {
        
        [self begin];
        isLoading=YES;
        if(delegate&&[delegate respondsToSelector:@selector(footViewBeginLoad:)])
            [delegate footViewBeginLoad:self];
        
    }
}

-(void) loadFinish
{
    isLoading=NO;
    [self end];
}

-(void)begin
{
    [image setHidden:NO];
    [loadText setHidden:NO];
    [finishText setHidden:YES];
}
-(void)end
{
    [image setHidden:YES];
    [loadText setHidden:YES];
    [finishText setHidden:NO];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
