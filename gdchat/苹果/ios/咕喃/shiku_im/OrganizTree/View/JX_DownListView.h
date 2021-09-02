//
//  JX_DownListView.h
//  shiku_im
//
//  Created by 1 on 17/5/24.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DownListView_ShowDown = 0,   // 默认显示在指定控件下方
    DownListView_ShowUp,
    DownListView_Center,
} JX_DownListViewShowType;

typedef void(^DownListPopOptionBlock)(NSInteger index, NSString *content);

@interface JX_DownListView : UIView


@property (nonatomic, strong) NSArray <NSString *>*listContents;   // 内容数组 必要
@property (nonatomic, strong) NSArray <NSString *>*listImages;     // 图片数组 非必要
@property (nonatomic, strong) NSArray <NSNumber *>*listEnables;     // 可用数组 非必要
@property (nonatomic, strong) UIColor *color;   // 背景色
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat  lineHeight;       // 行高   如果不设置默认为40.0f
@property (nonatomic, assign) CGFloat  mutiple;          // 宽度比 如果不设置默认为0.35f
@property (nonatomic ,assign) float    animateTime;      // 设置动画时长 如果不设置默认0.2f秒 如果设置为0为没有动画
@property (nonatomic, assign) JX_DownListViewShowType showType; // 显示在控件的上方或下方type，默认下方

@property (nonatomic, strong) UIColor *textColor;   // 字体颜色

-(instancetype)downlistPopOption:(DownListPopOptionBlock)block whichFrame:(CGRect)frame animate:(BOOL)animate;

-(void)show;

@end
