//
//  JXShareViewController.m
//  share
//
//  Created by 1 on 2019/3/20.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXShareViewController.h"
#import "JXHttpRequet.h"

@interface JXShareViewController () <UITextViewDelegate>

@end

@implementation JXShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
    baseView.backgroundColor = HEXCOLOR(0xF2F2F2);
    [self.view addSubview:baseView];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_TOP)];
    headView.backgroundColor = [UIColor whiteColor];
    [baseView addSubview:headView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(8, JX_SCREEN_TOP - 40, 31, 31)];
    [btn setImage:[UIImage imageNamed:@"share_back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:btn];

    UIButton *send = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 60, JX_SCREEN_TOP - 35, 40, 20)];
    [send setTitle:@"发送" forState:UIControlStateNormal];
    [send setTitleColor:HEXCOLOR(0x31AD2A) forState:UIControlStateNormal];
    [send addTarget:self action:@selector(onSend) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:send];
    
    UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(60, JX_SCREEN_TOP - 35, JX_SCREEN_WIDTH-60*2, 20)];
    p.backgroundColor = [UIColor clearColor];
    p.textAlignment   = NSTextAlignmentCenter;
    p.text = @"分享给社交圈";
    p.font = [UIFont boldSystemFontOfSize:18.0];
    [headView addSubview:p];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP-LINE_WH, JX_SCREEN_WIDTH, LINE_WH)];
    line.backgroundColor = [UIColor lightGrayColor];
    [headView addSubview:line];
    
    UIView *bigView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 300)];
    bigView.backgroundColor = [UIColor whiteColor];
    [baseView addSubview:bigView];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 10, JX_SCREEN_WIDTH-40, 100)];
    self.textView.delegate = self;
    self.textView.textColor = [UIColor lightGrayColor];
    self.textView.font = SYSFONT(17);
    self.textView.text = @"这一刻的想法..";
    [bigView addSubview:self.textView];
    
    
    CGFloat b = self.image.size.height/self.image.size.width;
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.textView.frame)+20, JX_SCREEN_WIDTH/5, JX_SCREEN_WIDTH/5*b)];
    imageV.image = self.image;
    [bigView addSubview:imageV];
    
    CGRect frame = bigView.frame;
    frame.size.height = CGRectGetMaxY(imageV.frame)+20;
    bigView.frame = frame;
}

- (void)onSend {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendToLifeCircleSucces:)]) {
        [self.delegate sendToLifeCircleSucces:self];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self actionQuit];
        });
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    //如果是提示内容，光标放置开始位置
    if (textView.textColor==[UIColor lightGrayColor]) {
        NSRange range;
        range.location = 0;
        range.length = 0;
        textView.selectedRange = range;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //如果不是delete响应,当前是提示信息，修改其属性
    if (![text isEqualToString:@""] && textView.textColor == [UIColor lightGrayColor]) {
        textView.text = @"";//置空
        textView.textColor = HEXCOLOR(0x595959);
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    static CGFloat maxHeight =100.0f;
    
    
    //防止输入时在中文后输入英文过长直接中文和英文换行
    if ([textView.text isEqualToString:@""]) {
        textView.textColor = [UIColor lightGrayColor];
        textView.text = @"这一刻的想法..";
    }
    
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(JX_SCREEN_WIDTH-40, MAXFLOAT);
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
    
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
}

- (void)actionQuit {
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
