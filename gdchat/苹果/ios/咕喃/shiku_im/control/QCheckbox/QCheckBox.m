//
//  EICheckBox.m
//  EInsure
//
//  Created by ivan on 13-7-9.
//  Copyright (c) 2013年 ivan. All rights reserved.
//

#import "QCheckBox.h"

#define Q_CHECK_ICON_WH                    (18.0)
#define Q_ICON_TITLE_MARGIN                (5.0)

@implementation QCheckBox

//@synthesize delegate = _delegate;
//@synthesize checked = _checked;
//@synthesize userInfo = _userInfo;

- (id)initWithDelegate:(id)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        
        self.exclusiveTouch = YES;
        [self setBackgroundImage:[UIImage imageNamed:@"sel_nor_wx2"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"sel_check_wx2"] forState:UIControlStateSelected];
        [self setBackgroundImage:[UIImage imageNamed:@"unableCheck_wx2"] forState:UIControlStateDisabled];
        [self addTarget:self action:@selector(checkboxBtnChecked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setColorSelected:(UIColor *)colorSelected {
    _colorSelected = colorSelected;
    [self setBackgroundImage:[UIImage createImageWithColor:colorSelected] forState:UIControlStateSelected];
}

- (void)setChecked:(BOOL)checked {
    if (_checked == checked) {
        return;
    }
    
    _checked = checked;
    self.selected = checked;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectedCheckBox:checked:)]) {
        [_delegate didSelectedCheckBox:self checked:self.selected];
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (self.colorSelected) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = frame.size.width/2;
    }
}

- (void)checkboxBtnChecked {
    self.selected = !self.selected;
    _checked = self.selected;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectedCheckBox:checked:)]) {
        [_delegate didSelectedCheckBox:self checked:self.selected];
    }
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0, (CGRectGetHeight(contentRect) - Q_CHECK_ICON_WH)/2.0, Q_CHECK_ICON_WH, Q_CHECK_ICON_WH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(Q_CHECK_ICON_WH + Q_ICON_TITLE_MARGIN, 0,
                      CGRectGetWidth(contentRect) - Q_CHECK_ICON_WH - Q_ICON_TITLE_MARGIN,
                      CGRectGetHeight(contentRect));
}

- (void)dealloc {
//    [_userInfo release];
//    _delegate = nil;
//    [super dealloc];
}

@end
