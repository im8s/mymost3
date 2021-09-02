//
//  JXWaitView.m
//  shiku_im
//
//  Created by flyeagleTang on 17/1/13.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXWaitView.h"

@implementation JXWaitView

-(id)initWithParent:(UIView*)value{
    self = [super init];
    if(self){
        if(value != nil)
            _parent = value;
        else
            _parent = [UIApplication sharedApplication].keyWindow;
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self adjust];
//        [_parent addSubview:self];
    }
    return self;
}

-(void)dealloc{
//    [super dealloc];
}

-(void)start{
    [self startAnimating];
    self.hidden = NO;
}

-(void)stop{
    [self stopAnimating];
    self.hidden = YES;
}

-(void)adjust{
    if(_parent==nil)
        return;
    [_parent addSubview:self];
    self.center = CGPointMake(_parent.frame.size.width/2, _parent.frame.size.height/2);
}

-(void)setParent:(UIView *)value{
    [self adjust];
    if([_parent isEqual:value])
        return;
//    [_parent release];
//    _parent = [value retain];
    _parent = value;
    [self adjust];
}

@end
