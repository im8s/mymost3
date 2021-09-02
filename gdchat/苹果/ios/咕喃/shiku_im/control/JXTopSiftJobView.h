//
//  JXTopSiftJobView.h
//  shiku_im
//
//  Created by MacZ on 16/5/19.
//  Copyright (c) 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXTopSiftJobView : UIView{
    NSArray *_paraDataArray;
    
    UIView *_bottomSlideLine;
    UIView *_moreParaView;
    NSInteger _paraSelIndex;
}

/**
 默认选项,要在dataArray前赋值
 */
@property (nonatomic, assign) NSUInteger preferred;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic,weak) id delegate;
@property (nonatomic, assign) BOOL isShowMoreParaBtn;
//非选中状态文字颜色，默认：[UIColor lightGrayColor]
@property (nonatomic, strong) UIColor *titleNormalColor;
//选中状态文字颜色，默认：[UIColor grayColor]
@property (nonatomic, strong) UIColor *titleSelectedColor;
// YES:显示下划线 NO:不显示
@property (nonatomic, assign) BOOL isShowBottomLine;


- (void)showMoreParaView:(BOOL)show;
- (void)moveBottomSlideLine:(CGFloat)offsetX; //移动顶部下划线
- (void)resetItemBtnWith:(CGFloat)offsetX; //scrollView滑动结束，改变顶部item按钮选中状态
- (void)resetSelParaBtnTransform;  //参数按钮图片旋转角度归零
- (void)resetWithIndex:(NSInteger)index itemId:(int)itemId itemValue:(NSString *)value; //选中经验、公司规模
- (void)resetWithIndex:(NSInteger)index min:(NSInteger)min max:(NSInteger)max; //选中薪水
- (void)resetAllParaBtn;

- (void)resetBottomLineIndex:(NSUInteger)index;

@end
