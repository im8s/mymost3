//
//  JXMyMoneyViewController.m
//  shiku_im
//
//  Created by 1 on 17/10/27.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXMyMoneyViewController.h"
#import "UIImage+Color.h"
#import "JXCashWithDrawViewController.h"
#import "JXRechargeViewController.h"
#import "JXRecordCodeVC.h"
#import "JXMoneyMenuViewController.h"
#import "JXCheckCashWithdrawalVC.h"

@interface JXMyMoneyViewController ()

@property (nonatomic, strong) UIButton * listButton;

@property (nonatomic, strong) UIImageView * iconView;

@property (nonatomic, strong) UILabel * myMoneyLabel;
@property (nonatomic, strong) UILabel * balanceLabel;

@property (nonatomic, strong) UIButton * rechargeBtn;
@property (nonatomic, strong) UIButton * scanRechargeBtn;
@property (nonatomic, strong) UIButton * withdrawalsBtn;

//@property (nonatomic, strong) UIButton * problemBtn;

@end

@implementation JXMyMoneyViewController

-(instancetype)init{
    if (self = [super init]) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
        self.title = Localized(@"JXMoney_pocket");
        [g_notify addObserver:self selector:@selector(doRefresh:) name:kUpdateUserNotifaction object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createHeadAndFoot];
    
//    self.tableBody.backgroundColor = HEXCOLOR(0xefeff4);
    self.tableBody.alwaysBounceVertical = YES;
    
    [self.tableHeader addSubview:self.listButton];
    
    [self.tableBody addSubview:self.iconView];
    [self.tableBody addSubview:self.myMoneyLabel];
    [self.tableBody addSubview:self.balanceLabel];
    if (self.isCloud || [g_config.isOpenWxPay boolValue] || [g_config.isOpenAliPay boolValue]) {
        [self.tableBody addSubview:self.rechargeBtn];
    }
    if ([g_config.isOpenManualPay boolValue] && !self.isCloud) {
        [self.tableBody addSubview:self.scanRechargeBtn];
    }
    if (self.isCloud || [g_config.isOpenWxPay boolValue] || [g_config.isOpenAliPay boolValue] || [g_config.isOpenManualPay boolValue]) {
        [self.tableBody addSubview:self.withdrawalsBtn];
        if (!self.isCloud) {
            if ([g_config.isOpenManualPay boolValue] && ![g_config.isOpenWxPay boolValue] && ![g_config.isOpenAliPay boolValue]) {
                
                [self.withdrawalsBtn setTitle:Localized(@"JX_BackgroundAuditWithdrawal") forState:UIControlStateNormal];
            }
        }
    }
//    [self.tableBody addSubview:self.problemBtn];
    
//    [self updateBalanceLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isCloud) {
        [g_server queryAccountInfo:self];
    }else {
        [g_server getUserMoenyToView:self];
    }
}

-(void)dealloc{
    [g_notify removeObserver:self];
}

-(UIButton *)listButton{
    if(!_listButton){
        _listButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _listButton.frame = CGRectMake(JX_SCREEN_WIDTH-24-15, JX_SCREEN_TOP - 35, 24, 24);
//        [_listButton setTitle:Localized(@"JXMoney_list") forState:UIControlStateNormal];
//        [_listButton setTitle:Localized(@"JXMoney_list") forState:UIControlStateHighlighted];
//        _listButton.titleLabel.font = g_factory.font14;
        [_listButton setImage:THESIMPLESTYLE ? [UIImage imageNamed:@"money_menu_black"] : [UIImage imageNamed:@"money_menu"] forState:UIControlStateNormal];
        _listButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_listButton addTarget:self action:@selector(listButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _listButton;
}


//-(UIImageView *)iconView{
//    if (!_iconView) {
//        _iconView = [[UIImageView alloc] init];
//        _iconView.frame = CGRectMake(0, 65, 90, 90);
//        _iconView.center = CGPointMake(JX_SCREEN_WIDTH/2, _iconView.center.y);
//        _iconView.image = [UIImage imageNamed:@"weixinpayyue"];
//
//    }
//    return _iconView;
//}

-(UILabel *)myMoneyLabel{
    if (!_myMoneyLabel) {
        _myMoneyLabel = [UIFactory createLabelWith:CGRectZero text:Localized(@"JXMoney_myPocket") font:g_factory.font16 textColor:[UIColor blackColor] backgroundColor:nil];
        _myMoneyLabel.textAlignment = NSTextAlignmentCenter;
        _myMoneyLabel.frame = CGRectMake(0, 99, JX_SCREEN_WIDTH, 20);
    }
    return _myMoneyLabel;
}

-(UILabel *)balanceLabel{
    if (!_balanceLabel) {
        NSString * moneyStr = [NSString stringWithFormat:@"¥%.2f",self.isCloud ? g_App.myCloudMoney : g_App.myMoney];
        _balanceLabel = [UIFactory createLabelWith:CGRectZero text:moneyStr font:g_factory.font28 textColor:[UIColor blackColor] backgroundColor:nil];
        _balanceLabel.textAlignment = NSTextAlignmentCenter;
        _balanceLabel.font = SYSFONT(40);
        _balanceLabel.frame = CGRectMake(0, CGRectGetMaxY(_myMoneyLabel.frame)+23, JX_SCREEN_WIDTH, 40);
    }
    return _balanceLabel;
}

-(UIButton *)rechargeBtn{
    if (!_rechargeBtn) {
        _rechargeBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXLiveVC_Recharge") titleFont:g_factory.font16 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(rechargeBtnAction:) target:self];
        _rechargeBtn.frame = CGRectMake(15, CGRectGetMaxY(_balanceLabel.frame)+60, JX_SCREEN_WIDTH-15*2, 40);
        [_rechargeBtn setBackgroundImage:[UIImage createImageWithColor:THEMECOLOR] forState:UIControlStateNormal];
        UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
        [_rechargeBtn setBackgroundImage:img forState:UIControlStateHighlighted];
        _rechargeBtn.layer.cornerRadius = 7;
        _rechargeBtn.clipsToBounds = YES;
    }
    return _rechargeBtn;
}

// 扫码充值
- (UIButton *)scanRechargeBtn {
    
    if (!_scanRechargeBtn) {
        _scanRechargeBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JX_ScanRecharge") titleFont:g_factory.font16  titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(scanRechargeBtnAction:) target:self];
        if (_rechargeBtn) {
            _scanRechargeBtn.frame = CGRectMake(15, CGRectGetMaxY(_rechargeBtn.frame)+20, CGRectGetWidth(_rechargeBtn.frame), CGRectGetHeight(_rechargeBtn.frame));
        }else {
            _scanRechargeBtn.frame = CGRectMake(15, CGRectGetMaxY(_balanceLabel.frame)+60, JX_SCREEN_WIDTH-15*2, 40);
        }
        [_scanRechargeBtn setBackgroundImage:[UIImage createImageWithColor:THEMECOLOR] forState:UIControlStateNormal];
        UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
        [_scanRechargeBtn setBackgroundImage:img forState:UIControlStateHighlighted];
        _scanRechargeBtn.layer.cornerRadius = 7;
        _scanRechargeBtn.clipsToBounds = YES;
    }
    return _scanRechargeBtn;
}

-(UIButton *)withdrawalsBtn{
    if (!_withdrawalsBtn) {
        _withdrawalsBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXMoney_withdrawals") titleFont:g_factory.font16  titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(withdrawalsBtnAction:) target:self];
        if (_scanRechargeBtn) {
            _withdrawalsBtn.frame = CGRectMake(15, CGRectGetMaxY(_scanRechargeBtn.frame)+20, CGRectGetWidth(_scanRechargeBtn.frame), CGRectGetHeight(_scanRechargeBtn.frame));
        }else {
            _withdrawalsBtn.frame = CGRectMake(15, CGRectGetMaxY(_rechargeBtn.frame)+20, CGRectGetWidth(_rechargeBtn.frame), CGRectGetHeight(_rechargeBtn.frame));
        }
        [_withdrawalsBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
        [_withdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[UIColor whiteColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
        [_withdrawalsBtn setBackgroundImage:img forState:UIControlStateHighlighted];
        _withdrawalsBtn.layer.cornerRadius = 7;
        _withdrawalsBtn.clipsToBounds = YES;
        _withdrawalsBtn.layer.borderColor = THEMECOLOR.CGColor;
        _withdrawalsBtn.layer.borderWidth = 1.f;
    }
    return _withdrawalsBtn;
}

//-(UIButton *)problemBtn{
//    if (!_problemBtn) {
//        _problemBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXMoney_FAQ") titleFont:g_factory.font14 titleColor:HEXCOLOR(0x576b95) normal:nil selected:nil selector:@selector(problemBtnAction) target:self];
//        CGFloat drawWidth = [_problemBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_problemBtn.titleLabel.font}].width;
//        _problemBtn.frame = CGRectMake(0, self.tableBody.frame.size.height-72, drawWidth, 25);
//        _problemBtn.center = CGPointMake(JX_SCREEN_WIDTH/2, _problemBtn.center.y);
//    }
//    return _problemBtn;
//}


-(void)updateBalanceLabel{
    NSString * moneyStr = [NSString stringWithFormat:@"¥%.2f",self.isCloud ? g_App.myCloudMoney : g_App.myMoney];
    self.balanceLabel.text = moneyStr;
    CGFloat Width = [self.balanceLabel.text sizeWithAttributes:@{NSFontAttributeName:self.balanceLabel.font}].width;
    CGRect frame = self.balanceLabel.frame;
    frame.size.width = Width;
    self.balanceLabel.frame = frame;
    self.balanceLabel.center = CGPointMake(self.iconView.center.x, self.balanceLabel.center.y);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Action

-(void)listButtonAction{
    _listButton.enabled = NO;
    [self performSelector:@selector(delayButtonReset) withObject:nil afterDelay:0.5];
    JXMoneyMenuViewController *monVC = [[JXMoneyMenuViewController alloc] init];
    monVC.isCloud = self.isCloud;
    [g_navigation pushViewController:monVC animated:YES];
//    JXRecordCodeVC * recordVC = [[JXRecordCodeVC alloc]init];
////    [g_window addSubview:recordVC.view];
//    [g_navigation pushViewController:recordVC animated:YES];
}
-(void)rechargeBtnAction:(UIButton *)button{
    _rechargeBtn.enabled = NO;
    [self performSelector:@selector(delayButtonReset) withObject:nil afterDelay:0.5];
    
    JXRechargeViewController * rechargeVC = [[JXRechargeViewController alloc] init];
    rechargeVC.isCloud = self.isCloud;
//    [g_window addSubview:rechargeVC.view];
    [g_navigation pushViewController:rechargeVC animated:YES];
}

- (void)scanRechargeBtnAction:(UIButton *)btn {
    _scanRechargeBtn.enabled = NO;
    [self performSelector:@selector(delayButtonReset) withObject:nil afterDelay:0.5];
    
    JXRechargeViewController * rechargeVC = [[JXRechargeViewController alloc] init];
    rechargeVC.isScanRecharge = YES;
    //    [g_window addSubview:rechargeVC.view];
    [g_navigation pushViewController:rechargeVC animated:YES];
}

-(void)withdrawalsBtnAction:(UIButton *)button{
    _withdrawalsBtn.enabled = NO;
    [self performSelector:@selector(delayButtonReset) withObject:nil afterDelay:0.5];
    
    if (!self.isCloud) {
        if ([g_config.isOpenManualPay boolValue] && ![g_config.isOpenWxPay boolValue] && ![g_config.isOpenAliPay boolValue]) {
            
            JXCheckCashWithdrawalVC *vc = [[JXCheckCashWithdrawalVC alloc] init];
            [g_navigation pushViewController:vc animated:YES];
            
            return;
        }
    }
    
    JXCashWithDrawViewController * cashWithVC = [[JXCashWithDrawViewController alloc] init];
    cashWithVC.isCloud = self.isCloud;
//    [g_window addSubview:cashWithVC.view];
    [g_navigation pushViewController:cashWithVC animated:YES];
}

-(void)problemBtnAction{
//    _problemBtn.enabled = NO;
    [self performSelector:@selector(delayButtonReset) withObject:nil afterDelay:0.5];
    
}

-(void)delayButtonReset{
    _rechargeBtn.enabled = YES;
    _withdrawalsBtn.enabled = YES;
//    _problemBtn.enabled = YES;
    _listButton.enabled = YES;
    _scanRechargeBtn.enabled = YES;
}

-(void)doRefresh:(NSNotification *)notifacation{
    _balanceLabel.text = [NSString stringWithFormat:@"¥%.2f",self.isCloud ? g_App.myCloudMoney : g_App.myMoney];
}
//服务端返回数据
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];

    if ([aDownload.action isEqualToString:act_getUserMoeny]) {
        g_App.myMoney = [dict[@"balance"] doubleValue];
        NSString * moneyStr = [NSString stringWithFormat:@"¥%.2f",g_App.myMoney];
        _balanceLabel.text = moneyStr;
    }
    if ([aDownload.action isEqualToString:act_queryAccountInfo]) {
        g_App.myCloudMoney = [dict[@"balance"] doubleValue];
        NSString * moneyStr = [NSString stringWithFormat:@"¥%.2f",g_App.myCloudMoney];
        _balanceLabel.text = moneyStr;
    }
    
}

@end
