//
//  EICheckBox.h
//  EInsure
//
//  Created by ivan on 13-7-9.
//  Copyright (c) 2013年 ivan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QCheckBoxDelegate;

@interface QCheckBox : UIButton {
//    id<QCheckBoxDelegate> _delegate;
//    BOOL _checked;
//    id _userInfo;
}

@property(nonatomic, weak) id<QCheckBoxDelegate> delegate;
@property(nonatomic, assign)BOOL checked;
@property(nonatomic, strong)id userInfo;
// 重新赋值选中颜色，特殊处理，如果需要圆角，记得放在frame之前
@property(nonatomic, strong) UIColor *colorSelected;

- (id)initWithDelegate:(id)delegate;

@end

@protocol QCheckBoxDelegate <NSObject>

@optional

- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked;

@end
