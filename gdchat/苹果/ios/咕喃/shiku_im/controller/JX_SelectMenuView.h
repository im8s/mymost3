//
//  JX_SelectMenuView.h
//  shiku_im
//
//  Created by Apple on 16/9/12.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JX_SelectMenuView;

@protocol JXSelectMenuViewDelegate <NSObject>

- (void)didMenuView:(JX_SelectMenuView *)MenuView WithIndex:(NSInteger)index;

@end

@interface JX_SelectMenuView : UIView

@property (nonatomic, weak) id<JXSelectMenuViewDelegate>delegate;
@property (nonatomic, strong) NSMutableArray *sels;

- (instancetype)initWithTitle:(NSArray *)titleArr image:(NSArray *)images cellHeight:(int)height;


// 隐藏
- (void)hide;

@end
