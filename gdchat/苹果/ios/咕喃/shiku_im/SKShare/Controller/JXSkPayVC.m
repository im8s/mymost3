//
//  JXSkPayVC.m
//  shiku_im
//
//  Created by p on 2019/5/16.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXSkPayVC.h"

@interface JXSkPayVC ()

@property (nonatomic, strong) UIView *contentView;

@end

@implementation JXSkPayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5];
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 300, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - 300)];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_contentView];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    [cancelBtn setImage:[UIImage imageNamed:@"pay_cha"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:cancelBtn];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, JX_SCREEN_WIDTH, 20)];
    title.font = [UIFont systemFontOfSize:16.0];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = Localized(@"JX_ConfirmPayment");
    [_contentView addSubview:title];
    
    UILabel *RMBLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(title.frame)+40, JX_SCREEN_WIDTH, 50)];
    RMBLab.textAlignment = NSTextAlignmentCenter;
    RMBLab.font = SYSFONT(46);
    RMBLab.text = [NSString stringWithFormat:@"¥%.2f",[[self.payDic objectForKey:@"money"] doubleValue]];
    [_contentView addSubview:RMBLab];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(RMBLab.frame) + 40, 200, 30)];
    label.textColor = [UIColor lightGrayColor];
    label.text = Localized(@"JX_OrderInfo");
    [_contentView addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(RMBLab.frame) + 25, JX_SCREEN_WIDTH - 15, 30)];
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = [UIColor lightGrayColor];
    label.text = [self.payDic objectForKey:@"desc"];
    [_contentView addSubview:label];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(label.frame) + 20, JX_SCREEN_WIDTH - 15, .5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [_contentView addSubview:lineView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(lineView.frame) + 20, 200, 30)];
    label.textColor = [UIColor lightGrayColor];
    label.text = Localized(@"JX_PayType");
    [_contentView addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame) + 10, JX_SCREEN_WIDTH - 15, 30)];
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = [UIColor lightGrayColor];
    label.text = Localized(@"JX_PayBalance");
    [_contentView addSubview:label];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(label.frame) + 20, JX_SCREEN_WIDTH - 15, .5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [_contentView addSubview:lineView];
    
    UIButton *btn = [UIFactory createCommonButton:Localized(@"JX_SKPayConfirm") target:self action:@selector(onPay)];
//    [btn setBackgroundImage:nil forState:UIControlStateHighlighted];
    btn.custom_acceptEventInterval = 1.f;
    btn.frame = CGRectMake(INSETS,_contentView.frame.size.height - 100, WIDTH, 50);
    [btn setBackgroundImage:nil forState:UIControlStateNormal];
    btn.backgroundColor = THEMECOLOR;
    [_contentView addSubview:btn];
}

- (void)onPay {
    
    if ([self.delegate respondsToSelector:@selector(skPayVC:payBtnAction:)]) {
        [self.delegate skPayVC:self payBtnAction:self.payDic];
    }
    [self cancelBtnAction];
    
}

- (void)cancelBtnAction {
 
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
