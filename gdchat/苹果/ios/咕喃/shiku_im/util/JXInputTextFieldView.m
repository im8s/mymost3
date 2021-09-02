//
//  JXInputTextFieldView.m
//  shiku_im
//
//  Created by p on 2019/11/27.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXInputTextFieldView.h"

#define RECT_INSET 24

@interface JXInputTextFieldView () <UITextFieldDelegate>
@property (nonatomic, strong) UIView *bigView;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *inputTitle;
@property (nonatomic, strong) UITextField *inputTextField;

@property (nonatomic, strong) NSString *btnTitle;

@property (nonatomic, strong) UIScrollView *scrollView;

@end
@implementation JXInputTextFieldView

- (instancetype)initWithFrame:(CGRect)frame sureBtnTitle:(NSString *)btnTitle {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.btnTitle = btnTitle;
        self.isShow = YES;
        [self setupReplayView];
    }
    
    return self;
}

- (void)setupReplayView {
    self.bigView = [[UIView alloc] initWithFrame:self.bounds];
    self.bigView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [self addSubview:self.bigView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.bigView addGestureRecognizer:tap];
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(40, JX_SCREEN_HEIGHT/4-.5, JX_SCREEN_WIDTH-80, 162.5)];
    self.baseView.backgroundColor = [UIColor whiteColor];
    self.baseView.layer.masksToBounds = YES;
    self. baseView.layer.cornerRadius = 4.0f;
    [self.bigView addSubview:self.baseView];
    int n = 20;
    _inputTitle = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, n, self.baseView.frame.size.width - INSETS*2, 20)];
    _inputTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    _inputTitle.textColor = HEXCOLOR(0x333333);
    _inputTitle.font = SYSFONT(16);
    _inputTitle.numberOfLines = 0;
    [self.baseView addSubview:_inputTitle];
    
    self.inputTextField = [self createTextField:self.baseView default:nil hint:nil];
    self.inputTextField.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    self.inputTextField.frame = CGRectMake(INSETS, CGRectGetMaxY(_inputTitle.frame)+RECT_INSET, self.baseView.frame.size.width - INSETS*2, 35.5);
    self.inputTextField.delegate = self;
    self.inputTextField.textColor = HEXCOLOR(0x595959);
    self.inputTextField.font = SYSFONT(16);
    self.inputTextField.placeholder = self.placeString;
    
    n = n + 54;
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.inputTextField.frame)+24, self.baseView.frame.size.width, 44)];
    [self.baseView addSubview:self.topView];
    [self.inputTextField becomeFirstResponder];
    
    // 两条线
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.baseView.frame.size.width, LINE_WH)];
    topLine.backgroundColor = THE_LINE_COLOR;
    [self.topView addSubview:topLine];
    UIView *botLine = [[UIView alloc] initWithFrame:CGRectMake(self.baseView.frame.size.width/2, 0, LINE_WH, self.topView.frame.size.height)];
    botLine.backgroundColor = THE_LINE_COLOR;
    [self.topView addSubview:botLine];
    
    // 取消
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topLine.frame), self.baseView.frame.size.width/2, botLine.frame.size.height)];
    [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:SYSFONT(15)];
    [cancelBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:cancelBtn];
    // 发送
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.baseView.frame.size.width/2, CGRectGetMaxY(topLine.frame), self.baseView.frame.size.width/2, botLine.frame.size.height)];
    [sureBtn setTitle:self.btnTitle forState:UIControlStateNormal];
    [sureBtn setTitleColor:HEXCOLOR(0x55BEB8) forState:UIControlStateNormal];
    [sureBtn.titleLabel setFont:SYSFONT(15)];
    [sureBtn addTarget:self action:@selector(onSend) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:sureBtn];
    
    
    self.baseView.frame = CGRectMake(40, JX_SCREEN_HEIGHT/4+35-self.inputTextField.frame.size.height, JX_SCREEN_WIDTH-80, CGRectGetMaxY(self.topView.frame));
    
}

- (NSString *)text {
    return self.inputTextField.text;
}

- (void)setPlaceString:(NSString *)placeString {
    _placeString = placeString;
    if (_placeString.length > 0) {
        self.inputTextField.placeholder = placeString;
    }
    
}

- (void)setIsInputPWD:(BOOL)isInputPWD {
    _isInputPWD = isInputPWD;
    
    self.inputTextField.secureTextEntry = isInputPWD;
    
}

- (void)onSend {
    if (self.delegate && [self.delegate respondsToSelector:self.onRelease]) {
        [self.delegate performSelectorOnMainThread:self.onRelease withObject:nil waitUntilDone:NO];
    }
}

- (void)hide {
    self.isShow = NO;
    [self removeFromSuperview];
}

- (void)hideKeyBoard {
    if (self.inputTextField.isFirstResponder) {
        [self.inputTextField resignFirstResponder];
    }
}

- (void)setBackColor:(UIColor *)backColor{
    _backColor = backColor;
    self.bigView.backgroundColor = backColor;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _inputTitle.text = title;
    CGSize size = [_inputTitle.text boundingRectWithSize:CGSizeMake(_inputTitle.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_inputTitle.font} context:nil].size;
    
    CGRect frame = _inputTitle.frame;
    frame.size = size;
    _inputTitle.frame = frame;
    
//    if (size.height > 30) {
//        [self textViewDidChange:self.inputTextField];
//    }
}

- (void)setIsTitleCenter:(BOOL)isTitleCenter {
    _isTitleCenter = isTitleCenter;
    if (isTitleCenter) {
        _inputTitle.center = CGPointMake(self.baseView.frame.size.width / 2, _inputTitle.center.y);
    }
}

-(UITextField*)createTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint{
    UITextField* p = [[UITextField alloc] initWithFrame:CGRectMake(0,INSETS,JX_SCREEN_WIDTH,54)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.textAlignment = NSTextAlignmentLeft;
    p.userInteractionEnabled = YES;
    p.backgroundColor = [UIColor whiteColor];
    p.text = s;
    p.font = g_factory.font16;
    p.secureTextEntry = self.isInputPWD;
    [parent addSubview:p];
    return p;
}

// 清空输入框
- (void)cleanText {
    self.inputTextField.text = nil;
}

@end
