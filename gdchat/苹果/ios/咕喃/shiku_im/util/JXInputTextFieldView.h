//
//  JXInputTextFieldView.h
//  shiku_im
//
//  Created by p on 2019/11/27.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXInputTextFieldView : UIView

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

// 是否是输入密码
@property (nonatomic, assign) BOOL isInputPWD;


- (instancetype)initWithFrame:(CGRect)frame sureBtnTitle:(NSString *)btnTitle;

// 隐藏
- (void)hide;

// 清空输入框
- (void)cleanText;

@end

NS_ASSUME_NONNULL_END
