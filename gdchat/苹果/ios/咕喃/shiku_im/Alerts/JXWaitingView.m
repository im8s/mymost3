//  shiku_im
//
//  Created by flyeagleTang on 14-5-31.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXWaitingView.h"
#import "UIFactory.h"

@implementation JXWaitingView
@synthesize isShowing;

static JXWaitingView *shared;

+(JXWaitingView*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared=[[JXWaitingView alloc]initWithTitle:nil];
    });
    return shared;
}

- (id)initWithTitle:(NSString*)s
{
    self = [super initWithFrame:g_window.bounds];
    if (self) {
        UIView* view = [[UIView alloc] initWithFrame:g_window.bounds];
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.3;
        [self addSubview:view];
//        [view release];
        
        CGRect r = CGRectMake(60, (JX_SCREEN_HEIGHT-200)/2, 200, 200);
        _iv = [[UIImageView alloc]initWithFrame:r];
        _iv.image = [UIImage imageNamed:@"alertView-bg"];
        _iv.alpha = 1;
        [self addSubview:_iv];
//        [_iv release];

        r = CGRectMake(0, 160, _iv.frame.size.width, 20);
        _title = [UIFactory createLabelWith:r text:s font:nil textColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor]];
        [_iv addSubview:_title];
        _title.textAlignment = NSTextAlignmentCenter;

        _aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        int n = 38;
        _aiv.frame = CGRectMake((_iv.frame.size.width-n)/2, (_iv.frame.size.height-n)/2, n, n);
        [_iv addSubview:_aiv];
//        [_aiv release];
        isShowing = NO;
    }
    return self;
}

-(void)dealloc{
//    [super dealloc];
}

-(void)start:(NSString*)s{
    isShowing = YES;
    if(s)
        _title.text = s;
    else
        _title.text = Localized(@"JX_Loading");
    [g_window addSubview:self];
    self.hidden = NO;
    [_aiv startAnimating];
}

-(void)stop{
    isShowing = NO;
    [self removeFromSuperview];
    self.hidden = YES;
    [_aiv stopAnimating];
}

@end
