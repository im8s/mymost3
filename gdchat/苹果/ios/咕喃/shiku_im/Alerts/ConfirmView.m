//
//  ConfirmView.m
//  HuaweiMeeting
//
//  Created by imac on 12-10-15.
//  Copyright (c) 2012年 Twin-Fish. All rights reserved.
//

#import "ConfirmView.h"
#import "UIFactory.h"
#import "QuartzCore/QuartzCore.h"

@implementation ConfirmView

@synthesize temp_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)show
{    
    temp_delegate = self.delegate;
    self.delegate = self;
    [super show];
    
}

//- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
//{
//    [super dismissWithClickedButtonIndex:buttonIndex animated:NO];
//    [[self class] setAnimationsEnabled:YES];
//}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view.layer setCornerRadius:8];
            [view.layer setMasksToBounds:YES];
            ((UIImageView *)view).image = nil;
            [view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"com_repeat_paper"]]];
        } else if ([view isKindOfClass:[UIButton class]]) {
            CGFloat buttonHeight = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 33.0f : 33.0f;
            CGRect buttonFrame = view.frame;
            buttonFrame.origin.y += CGRectGetHeight(buttonFrame) - buttonHeight;
            buttonFrame.size.height = buttonHeight;
            view.frame = buttonFrame;
            UIImage *normalImage = [UIFactory resizableImageWithSize:CGSizeMake(4.0f, 0.0f) image:[UIImage imageNamed:@"com_button1_normal"]];
            UIImage *clickImage = [UIFactory resizableImageWithSize:CGSizeMake(4.0f, 0.0f) image:[UIImage imageNamed:@"com_button1_click"]];
            [((UIButton *)view) setBackgroundImage:normalImage forState:UIControlStateNormal];
            [((UIButton *)view) setBackgroundImage:clickImage forState:UIControlStateHighlighted];
            [((UIButton *)view).titleLabel setFont:[UIFont systemFontOfSize:16]];
            [((UIButton *)view) setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
            [((UIButton *)view) setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
            [((UIButton *)view) setTitleColor:[UIColor colorWithRed:82.0/255 green:30.0/255 blue:4.0/255 alpha:1.0]
                                     forState:UIControlStateNormal];
            [((UIButton *)view) setTitleColor:[UIColor colorWithRed:82.0/255 green:30.0/255 blue:4.0/255 alpha:1.0]
                                     forState:UIControlStateHighlighted];
        } else if ([view isKindOfClass:[UILabel class]]) {
            ((UILabel *)view).textColor = [UIColor blackColor];
            ((UILabel *)view).shadowColor = [UIColor clearColor];
        }
    }
    
    self.delegate = temp_delegate;
}


@end
