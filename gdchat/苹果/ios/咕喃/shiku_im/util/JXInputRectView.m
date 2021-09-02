//
//  JXInputRectView.m
//  shiku_im
//
//  Created by 1 on 2019/9/24.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXInputRectView.h"



#define RECT_INSET 24

@interface JXInputRectView () <UITextViewDelegate>
@property (nonatomic, strong) UIView *bigView;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *replayTitle;
@property (nonatomic, strong) UITextView *replayTextView;

@property (nonatomic, strong) NSString *btnTitle;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *placeLabel;

@end


@implementation JXInputRectView


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
    _replayTitle = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, n, self.baseView.frame.size.width - INSETS*2, 20)];
    _replayTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    _replayTitle.textColor = HEXCOLOR(0x333333);
    _replayTitle.font = SYSFONT(16);
    _replayTitle.numberOfLines = 0;
    [self.baseView addSubview:_replayTitle];
    
    self.replayTextView = [self createTextField:self.baseView default:nil hint:nil];
    self.replayTextView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    self.replayTextView.frame = CGRectMake(INSETS, CGRectGetMaxY(_replayTitle.frame)+RECT_INSET, self.baseView.frame.size.width - INSETS*2, 35.5);
    self.replayTextView.delegate = self;
    self.replayTextView.textColor = HEXCOLOR(0x595959);
    self.replayTextView.font = SYSFONT(16);
    
    n = n + 54;
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, n, self.baseView.frame.size.width, 44)];
    [self.baseView addSubview:self.topView];
    [self.replayTextView becomeFirstResponder];

    
    // 水印
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 8, self.replayTextView.frame.size.width-10, self.replayTextView.frame.size.height)];
    self.scrollView.hidden = YES;
    [self.replayTextView addSubview:self.scrollView];
    
    UITapGestureRecognizer *tapScr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inputTextView)];
    [self.scrollView addGestureRecognizer:tapScr];

    
    self.placeLabel = [[UILabel alloc] initWithFrame:self.scrollView.bounds];
    self.placeLabel.textColor = HEXCOLOR(0x999999);
    self.placeLabel.numberOfLines = 0;
    self.placeLabel.font = SYSFONT(16);
    [self.scrollView addSubview:self.placeLabel];

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
    
    self.placeString = @"";
}

- (void)setPlaceString:(NSString *)placeString {
    _placeString = placeString;
    if (_placeString.length > 0) {
        self.scrollView.hidden = NO;
        self.placeLabel.text = placeString;
        
    }else {
        self.scrollView.hidden = YES;
    }
    
    CGSize size = [placeString boundingRectWithSize:CGSizeMake(self.placeLabel.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.placeLabel.font} context:nil].size;
    if (size.height < 19) {
        size.height = 19;
    }
    
    [self setViewFrameWithSize:size.height];

}

- (void)setViewFrameWithSize:(CGFloat)height; {
    
    self.scrollView.contentSize = CGSizeMake(0, height);
    self.placeLabel.frame = CGRectMake(self.placeLabel.frame.origin.x, self.placeLabel.frame.origin.y, self.placeLabel.frame.size.width, height);

    if (height > 66) {
        height = 66;
    }
    self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, height);
    self.replayTextView.frame = CGRectMake(self.replayTextView.frame.origin.x, CGRectGetMaxY(self.replayTitle.frame)+RECT_INSET, self.replayTextView.frame.size.width, height+16);
    
    self.topView.frame = CGRectMake(0, CGRectGetMaxY(self.replayTextView.frame)+24, self.baseView.frame.size.width, self.topView.frame.size.height);
    
    self.baseView.frame = CGRectMake(40, JX_SCREEN_HEIGHT/4+35-self.replayTextView.frame.size.height, JX_SCREEN_WIDTH-80, CGRectGetMaxY(self.topView.frame));

}


- (void)textViewDidChange:(UITextView *)textView {
    
    if (textView.text.length > 0) {
        self.scrollView.hidden = YES;
    }else {
        self.scrollView.hidden = NO;
        CGSize size = [self.placeLabel.text boundingRectWithSize:CGSizeMake(self.placeLabel.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.placeLabel.font} context:nil].size;
        [self setViewFrameWithSize:size.height];
        
        return;
    }

    
    static CGFloat maxHeight =66.0f;
    
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(JX_SCREEN_WIDTH-80-INSETS*2, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    
    if (size.height >= maxHeight)
    {
        size.height = maxHeight;
        textView.scrollEnabled = YES;   // 允许滚动
    }
    else
    {
        textView.scrollEnabled = NO;    // 不允许滚动
    }
    
//    [self setViewFrameWithSize:size.height];

    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
    NSLog(@"--------%@",NSStringFromCGRect(self.baseView.frame));
    
    self.topView.frame = CGRectMake(0, CGRectGetMaxY(textView.frame)+24, self.baseView.frame.size.width, self.topView.frame.size.height);
    
    self.baseView.frame = CGRectMake(40, JX_SCREEN_HEIGHT/4+35-size.height, JX_SCREEN_WIDTH-80, CGRectGetMaxY(self.topView.frame));
}


- (NSString *)text {
    return self.replayTextView.text;
}

- (void)inputTextView {
    if (![self.replayTextView isFirstResponder]) {
        [self.replayTextView becomeFirstResponder];
    }
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

- (void)dealloc {
}

- (void)hideKeyBoard {
    if (self.replayTextView.isFirstResponder) {
        [self.replayTextView resignFirstResponder];
    }
}

- (void)setBackColor:(UIColor *)backColor{
    _backColor = backColor;
    self.bigView.backgroundColor = backColor;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _replayTitle.text = title;
    CGSize size = [_replayTitle.text boundingRectWithSize:CGSizeMake(_replayTitle.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_replayTitle.font} context:nil].size;
    
    CGRect frame = _replayTitle.frame;
    frame.size = size;
    _replayTitle.frame = frame;
    
    if (size.height > 30) {
        [self textViewDidChange:self.replayTextView];
    }
}

- (void)setIsTitleCenter:(BOOL)isTitleCenter {
    _isTitleCenter = isTitleCenter;
    if (isTitleCenter) {
        _replayTitle.center = CGPointMake(self.baseView.frame.size.width / 2, _replayTitle.center.y);
    }
}

-(UITextView*)createTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint{
    UITextView* p = [[UITextView alloc] initWithFrame:CGRectMake(0,INSETS,JX_SCREEN_WIDTH,54)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.scrollEnabled = NO;
    p.showsVerticalScrollIndicator = NO;
    p.showsHorizontalScrollIndicator = NO;
    p.textAlignment = NSTextAlignmentLeft;
    p.userInteractionEnabled = YES;
    p.backgroundColor = [UIColor whiteColor];
    p.text = s;
    p.font = g_factory.font16;
    [parent addSubview:p];
    return p;
}

// 清空输入框
- (void)cleanText {
    self.replayTextView.text = nil;
}

@end
