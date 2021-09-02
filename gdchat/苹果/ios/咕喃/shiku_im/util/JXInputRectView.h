//
//  JXInputRectView.h
//  shiku_im
//
//  Created by 1 on 2019/9/24.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXInputRectView : UIView

// 背景颜色
@property (nonatomic, strong) UIColor *backColor;

// 发送/确定按钮事件
@property (nonatomic, assign) SEL onRelease;

// 标题
@property (nonatomic, strong) NSString *title;

// 水印文字
@property (nonatomic, strong) NSString *placeString;

@property (weak, nonatomic) id delegate;

// 获取textView.text
@property (nonatomic, strong, readonly) NSString *text;

@property (nonatomic, assign) BOOL isShow;

@property (nonatomic, assign) BOOL isTitleCenter;


- (instancetype)initWithFrame:(CGRect)frame sureBtnTitle:(NSString *)btnTitle;

// 隐藏
- (void)hide;

// 清空输入框
- (void)cleanText;

@end

NS_ASSUME_NONNULL_END
