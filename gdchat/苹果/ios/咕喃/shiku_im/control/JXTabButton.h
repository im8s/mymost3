//
//  JXTabButton.h
//  shiku_im
//
//  Created by flyeagleTang on 14-5-17.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JXBadgeView;

@interface JXTabButton : UIButton{
    UIImageView* _icon;
    UILabel* _lbTitle;
}
@property (nonatomic, strong) NSString *iconName;

@property (nonatomic, strong) NSString *selectedIconName;

@property (nonatomic, strong) NSString *backgroundImageName;

@property (nonatomic, strong) NSString *selectedBackgroundImageName;

@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) UIColor *selectedTextColor;

@property (nonatomic, strong) NSString *bage;

@property (nonatomic, assign) BOOL      isTabMenu;

@property (nonatomic, assign) SEL		onDragout;

@property (nonatomic, weak) NSObject* delegate;

@property (nonatomic, strong) JXBadgeView *lbBage;

- (void)show;

-(void)updateBage:(NSString *)s  isSmall:(BOOL )isSmall;
@end
