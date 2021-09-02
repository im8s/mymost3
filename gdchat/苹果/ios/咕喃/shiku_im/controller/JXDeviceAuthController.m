//
//  JXDeviceAuthController.m
//  shiku_im
//
//  Created by IMAC on 2019/8/21.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXDeviceAuthController.h"
#define JX_SCREEN_BAR (THE_DEVICE_HAVE_HEAD ? 34 : 0)
@interface JXDeviceAuthController ()
@property (nonatomic, strong)UIView *baseView;
@property (nonatomic, strong)NSString *str;
@property (nonatomic, assign)BOOL disSynchronizedMessage;
@property (nonatomic, strong)JXMessageObject *msg;
@end

@implementation JXDeviceAuthController

- (instancetype)initWithMsg:(JXMessageObject *)msg{
    self = [super init];
    if (self) {
        self.msg = msg;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatView];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.5 animations:^{
        self.view.backgroundColor = [UIColor whiteColor];
        self.baseView.frame = CGRectMake(0, JX_SCREEN_BAR, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_BAR);
    }];
}
- (void)viewWillDisappear:(BOOL)animated{
    
}
- (void)creatView{
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT+JX_SCREEN_BAR, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_BAR)];
    self.baseView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.baseView];
    
    UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ALOGO_120"]];
    imgV.frame = CGRectMake(0, 0, 87, 87);
    imgV.center = CGPointMake(JX_SCREEN_WIDTH/2, 124 + 87/2);
    [self.baseView addSubview:imgV];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imgV.frame) + 10, JX_SCREEN_WIDTH, 40)];
    [lab setText:g_appName];
    [lab setFont:[UIFont systemFontOfSize:20]];
    [lab setTextAlignment:NSTextAlignmentCenter];
    [lab setTextColor:[UIColor blackColor]];
    [lab setBackgroundColor:[UIColor whiteColor]];
    [self.baseView addSubview:lab];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.frame = CGRectMake(35, CGRectGetMaxY(lab.frame) + 40, JX_SCREEN_WIDTH - 35*2, 0.3);
    lineView.backgroundColor = HEXCOLOR(0xD9D9D9);
    [self.baseView addSubview:lineView];
    
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(lineView.frame) + 35, 120, 25)];
    nameLab.backgroundColor = [UIColor whiteColor];
    nameLab.font = [UIFont systemFontOfSize:16];
    nameLab.text = MY_USER_NAME;
    nameLab.textColor = [UIColor blackColor];
    nameLab.textAlignment = NSTextAlignmentLeft;
    [self.baseView addSubview:nameLab];
    
    UILabel *idLab = [[UILabel alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(nameLab.frame) + 10, 120, 25)];
    idLab.backgroundColor = [UIColor whiteColor];
    idLab.font = [UIFont systemFontOfSize:14];
    idLab.text = MY_USER_ID;
    idLab.textColor = HEXCOLOR(0x999999);
    idLab.textAlignment = NSTextAlignmentLeft;
    [self.baseView addSubview:idLab];
    
    UIImageView *headImgV = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 62 - 50, CGRectGetMaxY(lineView.frame) + 37, 50, 50)];
    headImgV.clipsToBounds = YES;
    headImgV.layer.cornerRadius = 25;
    [g_server getHeadImageLarge:MY_USER_ID userName:MY_USER_NAME imageView:headImgV getHeadHandler:nil];
    [self.baseView addSubview:headImgV];
    
    UIButton *btn = [UIFactory createCommonButton:Localized(@"JX_ConfirmTheLogin") target:self action:@selector(agreeLogin)];
    btn.frame = CGRectMake(15, CGRectGetMaxY(headImgV.frame) + 35, JX_SCREEN_WIDTH - 15*2, 40);
    btn.backgroundColor = [g_theme themeColor];
    [btn.titleLabel setFont:g_factory.font16];
    btn.titleLabel.textColor = [UIColor whiteColor];
    btn.clipsToBounds = YES;
    btn.layer.cornerRadius = 7;
    [self.baseView addSubview:btn];
    
    UIButton *btn2 = [[UIButton alloc] init];
    btn2.frame = CGRectMake(15, CGRectGetMaxY(btn.frame) + 30, JX_SCREEN_WIDTH - 15*2, 40);
    btn2.backgroundColor = [UIColor whiteColor];
    [btn2 setTitle:Localized(@"JX_CancelLogin") forState:UIControlStateNormal];
    [btn2.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btn2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(cancelLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:btn2];
    
}


- (void)agreeLogin{
    [g_server agreeAuthLogin:self.msg.content toView:self];
    [self dismissViewController];
}


- (void)cancelLogin{
    [self dismissViewController];
}

- (void)dismissViewController {
    [UIView animateWithDuration:0.5 animations:^{
        self.baseView.frame = CGRectMake(0, JX_SCREEN_HEIGHT+JX_SCREEN_BAR, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:YES completion:nil];
        if (self) {
            [self.view removeFromSuperview];
        }
    }];
}

- (void)dealloc{
    
}


@end
