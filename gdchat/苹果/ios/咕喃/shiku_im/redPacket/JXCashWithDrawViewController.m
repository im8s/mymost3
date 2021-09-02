//
//  JXCashWithDrawViewController.m
//  shiku_im
//
//  Created by 1 on 17/10/27.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXCashWithDrawViewController.h"
#import "UIImage+Color.h"
#import "WXApi.h"
#import "WXApiManager.h"
#import "JXVerifyPayVC.h"
#import "JXPayPasswordVC.h"
#import <AlipaySDK/AlipaySDK.h>
#import "JXCheckCashWithdrawalVC.h"

#define drawMarginX 20
#define bgWidth JX_SCREEN_WIDTH-15*2
#define drawHei 60

@interface JXCashWithDrawViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UIButton * helpButton;

@property (nonatomic, strong) UIControl * hideControl;
@property (nonatomic, strong) UIControl * bgView;
@property (nonatomic, strong) UIView * targetView;
@property (nonatomic, strong) UIView * inputView;
@property (nonatomic, strong) UIView * balanceView;

@property (nonatomic, strong) UIButton * cardButton;
@property (nonatomic, strong) UITextField * countTextField;

@property (nonatomic, strong) UILabel * balanceLabel;
@property (nonatomic, strong) UIButton * drawAllBtn;
@property (nonatomic, strong) UIButton * withdrawalsBtn;
@property (nonatomic, strong) UIButton * aliwithdrawalsBtn;

@property (nonatomic, strong) UIButton * checkWithdrawalsBtn;

@property (nonatomic, strong) UIButton * clouddrawalsBtn;


@property (nonatomic, strong) ATMHud *loading;
@property (nonatomic, strong) JXVerifyPayVC *verVC;
@property (nonatomic, strong) NSString *payPassword;
@property (nonatomic, assign) BOOL isAlipay;
@property (nonatomic, strong) NSString *aliUserId;

@property (nonatomic, strong) UIButton *curWithdrawalBtn;
@property (nonatomic, strong) UIButton *hoursWithdrawalBtn;
@property (nonatomic, strong) UIButton *dayWithdrawalBtn;

@property (nonatomic, assign) int cloudType;


@end

@implementation JXCashWithDrawViewController

-(instancetype)init{
    if (self = [super init]) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
        self.title = Localized(@"JXMoney_withdrawals");
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    
    [self createHeadAndFoot];
    self.tableBody.backgroundColor = HEXCOLOR(0xF2F2F2);
    
//    [self.tableHeader addSubview:self.helpButton];
    
    [self.tableBody addSubview:self.hideControl];
    [self.tableBody addSubview:self.bgView];
    
//    [self.bgView addSubview:self.targetView];
    [self.bgView addSubview:self.inputView];
    [self.bgView addSubview:self.balanceView];
    self.bgView.frame = CGRectMake(15, 20, bgWidth, CGRectGetMaxY(_balanceView.frame));
    
    _loading = [[ATMHud alloc] init];
    
    [g_notify addObserver:self selector:@selector(authRespNotification:) name:kWxSendAuthRespNotification object:nil];
}


-(UIButton *)helpButton{
    if(!_helpButton){
        _helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _helpButton.frame = CGRectMake(JX_SCREEN_WIDTH -15-18, JX_SCREEN_TOP -15-18, 18, 18);
        NSString *image = THESIMPLESTYLE ? @"im_003_more_button_black" : @"im_003_more_button_normal";
        [_helpButton setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
        [_helpButton setImage:[UIImage imageNamed:image] forState:UIControlStateHighlighted];
        [_helpButton addTarget:self action:@selector(helpButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _helpButton;
}

-(UIControl *)hideControl{
    if (!_hideControl) {
        _hideControl = [[UIControl alloc] init];
        _hideControl.frame = self.tableBody.bounds;
        [_hideControl addTarget:self action:@selector(hideControlAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hideControl;
}

-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIControl alloc] init];
        _bgView.frame = CGRectMake(15, 20, bgWidth, 400);
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 5;
        _bgView.clipsToBounds = YES;
    }
    return _bgView;
}

-(UIView *)targetView{
    if (!_targetView) {
        _targetView = [[UIView alloc] init];
        _targetView.frame = CGRectMake(0, 0, bgWidth, drawHei);
        _targetView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];
        
        UILabel * targetLabel = [UIFactory createLabelWith:CGRectMake(drawMarginX, 0, 120, drawHei) text:Localized(@"JXMoney_withDrawalsTarget")];
        [_targetView addSubview:targetLabel];
        
        CGRect btnFrame = CGRectMake(CGRectGetMaxX(targetLabel.frame)+20, 0, bgWidth-CGRectGetMaxX(targetLabel.frame)-20-drawMarginX, drawHei);
        _cardButton = [UIFactory createButtonWithRect:btnFrame title:@"微信号(8868)" titleFont:g_factory.font15 titleColor:HEXCOLOR(0x576b95) normal:nil selected:nil selector:@selector(cardButtonAction:) target:self];
        [_targetView addSubview:_cardButton];
    }
    return _targetView;
}

-(UIView *)inputView{
    if (!_inputView) {
        _inputView = [[UIView alloc] init];
        _inputView.frame = CGRectMake(0, 0, bgWidth, 126);
        _inputView.backgroundColor = [UIColor whiteColor];
        
        UILabel * cashTitle = [UIFactory createLabelWith:CGRectMake(drawMarginX, drawMarginX, 120, 15) text:Localized(@"JXMoney_withDAmount")];
        cashTitle.font = SYSFONT(15);
        cashTitle.textColor = HEXCOLOR(0x999999);
        [_inputView addSubview:cashTitle];
        
        UILabel * rmbLabel = [UIFactory createLabelWith:CGRectMake(drawMarginX, CGRectGetMaxY(cashTitle.frame)+36, 18, 30) text:@"¥"];
        rmbLabel.font = SYSFONT(30);
        rmbLabel.textAlignment = NSTextAlignmentLeft;
        [_inputView addSubview:rmbLabel];
        
        _countTextField = [UIFactory createTextFieldWithRect:CGRectMake(CGRectGetMaxX(rmbLabel.frame)+15, CGRectGetMaxY(cashTitle.frame)+31, bgWidth-CGRectGetMaxX(rmbLabel.frame)-drawMarginX-15, 40) keyboardType:UIKeyboardTypeDecimalPad secure:NO placeholder:nil font:[UIFont boldSystemFontOfSize:40] color:[UIColor blackColor] delegate:self];
        _countTextField.borderStyle = UITextBorderStyleNone;
        [_inputView addSubview:_countTextField];
        
        UIView * line = [[UIView alloc] init];
        line.frame = CGRectMake(drawMarginX, CGRectGetMaxY(_countTextField.frame)+15, bgWidth-drawMarginX*2, LINE_WH);
        line.backgroundColor = THE_LINE_COLOR;
        [_inputView addSubview:line];
        
    }
    return _inputView;
}

-(UIView *)balanceView{
    if (!_balanceView) {
        _balanceView = [[UIView alloc] init];
        _balanceView.frame = CGRectMake(0, CGRectGetMaxY(_inputView.frame), bgWidth, 216);
        _balanceView.backgroundColor = [UIColor whiteColor];
    
//        _balanceLabel = [UIFactory createLabelWith:CGRectZero text:moneyStr font:g_factory.font14 textColor:[UIColor lightGrayColor] backgroundColor:nil];
//        CGFloat blanceWidth = [moneyStr sizeWithAttributes:@{NSFontAttributeName:_balanceLabel.font}].width;
//        _balanceLabel.frame = CGRectMake(drawMarginX, drawMarginX, blanceWidth, 14);
//        [_balanceView addSubview:_balanceLabel];
//
//        _drawAllBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXMoney_withDAll") titleFont:_balanceLabel.font titleColor:HEXCOLOR(0x576b95) normal:nil selected:nil selector:@selector(drawAllBtnAction) target:self];
//        CGFloat drawWidth = [_drawAllBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_drawAllBtn.titleLabel.font}].width;
//        _drawAllBtn.frame = CGRectMake(CGRectGetMaxX(_balanceLabel.frame)+10, CGRectGetMinY(_balanceLabel.frame), drawWidth, 14);
//        [_balanceView addSubview:_drawAllBtn];
//
//        _withdrawalsBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXMoney_wechatWithdrawals") titleFont:g_factory.font16 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(withdrawalsBtnAction:) target:self];
//        _withdrawalsBtn.tag = 1000;
//        _withdrawalsBtn.frame = CGRectMake(drawMarginX, CGRectGetMaxY(_balanceLabel.frame)+30, bgWidth-drawMarginX*2, 40);
//        [_withdrawalsBtn setImage:[UIImage imageNamed:@"withdrawal_weixin"] forState:UIControlStateNormal];
//        [_withdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x22CC06)] forState:UIControlStateNormal];
////        [_withdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x22CC06)] forState:UIControlStateDisabled];
//        _withdrawalsBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
//        _withdrawalsBtn.layer.cornerRadius = 7;
//        _withdrawalsBtn.clipsToBounds = YES;
//
//        [_balanceView addSubview:_withdrawalsBtn];
//
//
//        _aliwithdrawalsBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXMoney_Aliwithdrawals") titleFont:g_factory.font16 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(withdrawalsBtnAction:) target:self];
//        _aliwithdrawalsBtn.tag = 1011;
//        _aliwithdrawalsBtn.frame = CGRectMake(drawMarginX, CGRectGetMaxY(_withdrawalsBtn.frame)+20, bgWidth-drawMarginX*2, 40);
//        [_aliwithdrawalsBtn setImage:[UIImage imageNamed:@"withdrawal_aliPay"] forState:UIControlStateNormal];
//        [_aliwithdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x3E98FF)] forState:UIControlStateNormal];
////        [_aliwithdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x3E98FF)] forState:UIControlStateDisabled];
//        _aliwithdrawalsBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
//        _aliwithdrawalsBtn.layer.cornerRadius = 7;
//        _aliwithdrawalsBtn.clipsToBounds = YES;
//
//        [_balanceView addSubview:_aliwithdrawalsBtn];
        

//        UILabel *noticeLabel = [UIFactory createLabelWith:CGRectMake(drawMarginX, CGRectGetMaxY(_checkWithdrawalsBtn.frame)+20, bgWidth-drawMarginX*2, 13) text:Localized(@"JXMoney_withDNotice") font:g_factory.font13 textColor:HEXCOLOR(0x999999) backgroundColor:nil];
//        noticeLabel.textAlignment = NSTextAlignmentCenter;
//        [_balanceView addSubview:noticeLabel];
        
        if (self.isCloud) {
            self.curWithdrawalBtn = [self createButtonWithFrame:CGRectMake(drawMarginX, drawMarginX, bgWidth-drawMarginX*2, 0) title:nil detail:Localized(@"JX_RealTimeArrival")];
            self.curWithdrawalBtn.tag = -1;
            [_balanceView addSubview:self.curWithdrawalBtn];
            
            
            self.hoursWithdrawalBtn = [self createButtonWithFrame:CGRectMake(drawMarginX, CGRectGetMaxY(self.curWithdrawalBtn.frame)+20, bgWidth-drawMarginX*2, 0) title:nil detail:Localized(@"JX_2HoursToAccount")];
            self.hoursWithdrawalBtn.tag = 1;
            [_balanceView addSubview:self.hoursWithdrawalBtn];
            
            self.dayWithdrawalBtn = [self createButtonWithFrame:CGRectMake(drawMarginX, CGRectGetMaxY(self.hoursWithdrawalBtn.frame)+20, bgWidth-drawMarginX*2, 0) title:nil detail:Localized(@"JX_TheNextDay")];
            self.dayWithdrawalBtn.tag = 2;
            [_balanceView addSubview:self.dayWithdrawalBtn];
            
            _clouddrawalsBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXMoney_withdrawals") titleFont:g_factory.font16 titleColor:THEMECOLOR normal:nil selected:nil selector:@selector(withdrawalsBtnAction:) target:self];
            _clouddrawalsBtn.tag = 1013;
            _clouddrawalsBtn.frame = CGRectMake(drawMarginX, CGRectGetMaxY(_dayWithdrawalBtn.frame)+20, bgWidth-drawMarginX*2, 40);
            _clouddrawalsBtn.layer.cornerRadius = 7;
            _clouddrawalsBtn.clipsToBounds = YES;
            _clouddrawalsBtn.layer.borderColor = THEMECOLOR.CGColor;
            _clouddrawalsBtn.layer.borderWidth = 0.5;
            
            [_balanceView addSubview:_clouddrawalsBtn];
            
            UILabel *tintLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_clouddrawalsBtn.frame)+15, _balanceView.frame.size.width, 15)];
            tintLab.textColor = [UIColor lightGrayColor];
            tintLab.text = Localized(@"JX_CommissionDeductedBalance");
            tintLab.textAlignment = NSTextAlignmentCenter;
            tintLab.font = SYSFONT(13);
            [_balanceView addSubview:tintLab];
            
            CGRect frame = _balanceView.frame;
            frame.size.height = CGRectGetMaxY(tintLab.frame)+15;
            _balanceView.frame = frame;
            
            UIButton *btn = [self.curWithdrawalBtn viewWithTag:1001];
            btn.selected = YES;
            
        }else {
            NSString * moneyStr = [NSString stringWithFormat:@"%@¥%.2f，",Localized(@"JXMoney_blance"),g_App.myMoney];
            
            _balanceLabel = [UIFactory createLabelWith:CGRectZero text:moneyStr font:g_factory.font14 textColor:[UIColor lightGrayColor] backgroundColor:nil];
            CGFloat blanceWidth = [moneyStr sizeWithAttributes:@{NSFontAttributeName:_balanceLabel.font}].width;
            _balanceLabel.frame = CGRectMake(drawMarginX, drawMarginX, blanceWidth, 14);
            [_balanceView addSubview:_balanceLabel];
            
            _drawAllBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXMoney_withDAll") titleFont:_balanceLabel.font titleColor:HEXCOLOR(0x576b95) normal:nil selected:nil selector:@selector(drawAllBtnAction) target:self];
            CGFloat drawWidth = [_drawAllBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_drawAllBtn.titleLabel.font}].width;
            _drawAllBtn.frame = CGRectMake(CGRectGetMaxX(_balanceLabel.frame)+10, CGRectGetMinY(_balanceLabel.frame), drawWidth, 14);
            [_balanceView addSubview:_drawAllBtn];
            
            CGFloat y = CGRectGetMaxY(_balanceLabel.frame)+30;
            
            if ([g_config.isOpenWxPay boolValue]) {
                _withdrawalsBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXMoney_wechatWithdrawals") titleFont:g_factory.font16 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(withdrawalsBtnAction:) target:self];
                _withdrawalsBtn.tag = 1000;
                _withdrawalsBtn.frame = CGRectMake(drawMarginX, y, bgWidth-drawMarginX*2, 40);
                [_withdrawalsBtn setImage:[UIImage imageNamed:@"withdrawal_weixin"] forState:UIControlStateNormal];
                [_withdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x22CC06)] forState:UIControlStateNormal];
                //        [_withdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x22CC06)] forState:UIControlStateDisabled];
                _withdrawalsBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
                _withdrawalsBtn.layer.cornerRadius = 7;
                _withdrawalsBtn.clipsToBounds = YES;
                
                [_balanceView addSubview:_withdrawalsBtn];
                
                y = CGRectGetMaxY(_withdrawalsBtn.frame)+20;
            }
            
            if ([g_config.isOpenAliPay boolValue]) {
                _aliwithdrawalsBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXMoney_Aliwithdrawals") titleFont:g_factory.font16 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(withdrawalsBtnAction:) target:self];
                _aliwithdrawalsBtn.tag = 1011;
                _aliwithdrawalsBtn.frame = CGRectMake(drawMarginX, y, bgWidth-drawMarginX*2, 40);
                [_aliwithdrawalsBtn setImage:[UIImage imageNamed:@"withdrawal_aliPay"] forState:UIControlStateNormal];
                [_aliwithdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x3E98FF)] forState:UIControlStateNormal];
                //        [_aliwithdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x3E98FF)] forState:UIControlStateDisabled];
                _aliwithdrawalsBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
                _aliwithdrawalsBtn.layer.cornerRadius = 7;
                _aliwithdrawalsBtn.clipsToBounds = YES;
                
                [_balanceView addSubview:_aliwithdrawalsBtn];
                
                y = CGRectGetMaxY(_aliwithdrawalsBtn.frame)+20;
            }
            
            if ([g_config.isOpenManualPay boolValue]) {
                _checkWithdrawalsBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JX_BackgroundAuditWithdrawal") titleFont:g_factory.font16 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(withdrawalsBtnAction:) target:self];
                _checkWithdrawalsBtn.tag = 1012;
                _checkWithdrawalsBtn.frame = CGRectMake(drawMarginX, y, bgWidth-drawMarginX*2, 40);
                //        [_checkWithdrawalsBtn setImage:[UIImage imageNamed:@"withdrawal_aliPay"] forState:UIControlStateNormal];
                [_checkWithdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x48C0B8)] forState:UIControlStateNormal];
                //        [_aliwithdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x3E98FF)] forState:UIControlStateDisabled];
                _checkWithdrawalsBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
                _checkWithdrawalsBtn.layer.cornerRadius = 7;
                _checkWithdrawalsBtn.clipsToBounds = YES;
                
                [_balanceView addSubview:_checkWithdrawalsBtn];
                
                y = CGRectGetMaxY(_checkWithdrawalsBtn.frame)+20;
            }
            
            
            UILabel *noticeLabel = [UIFactory createLabelWith:CGRectMake(drawMarginX, y, bgWidth-drawMarginX*2, 13) text:Localized(@"JXMoney_withDNotice") font:g_factory.font13 textColor:HEXCOLOR(0x999999) backgroundColor:nil];
            noticeLabel.textAlignment = NSTextAlignmentCenter;
            [_balanceView addSubview:noticeLabel];
            
            
            _balanceView.frame = CGRectMake(_balanceView.frame.origin.x, _balanceView.frame.origin.y, _balanceView.frame.size.width, CGRectGetMaxY(noticeLabel.frame) + 20);
        }
        
    }
    return _balanceView;
}

- (void)onYopPayWithdraw:(UIButton *)button {
    if ([self.countTextField isFirstResponder]) {
        [self.countTextField resignFirstResponder];
    }
    
    self.cloudType = (int)button.tag;
    
    UIButton *btn = [self.curWithdrawalBtn viewWithTag:1001];
    btn.selected = button == self.curWithdrawalBtn;
    UIButton *btn1 = [self.hoursWithdrawalBtn viewWithTag:1001];
    btn1.selected = button == self.hoursWithdrawalBtn;
    UIButton *btn2 = [self.dayWithdrawalBtn viewWithTag:1001];
    btn2.selected = button == self.dayWithdrawalBtn;
    
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

#pragma mark TextField Delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _countTextField) {
        NSString *toString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (toString.length > 0) {
            NSString *stringRegex = @"(([0]|(0[.]\\d{0,2}))|([1-9]\\d{0,4}(([.]\\d{0,2})?)))?";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringRegex];
            if (![predicate evaluateWithObject:toString]) {
                return NO;
            }
        }
    }
    return YES;
}


#pragma mark Action

-(void)cardButtonAction:(UIButton *)button{
    
}

-(void)drawAllBtnAction{
    NSString * allMoney = [NSString stringWithFormat:@"%.2f",g_App.myMoney];
    _countTextField.text = allMoney;
}

-(void)withdrawalsBtnAction:(UIButton *)button{
    
//    if ([_countTextField.text doubleValue] > g_App.myMoney) {
//        [g_App showAlert:Localized(@"CREDIT_LOW")];
//        return;
//    }
    

    
    if (button.tag == 1012) {
        JXCheckCashWithdrawalVC *vc = [[JXCheckCashWithdrawalVC alloc] init];
        if (_countTextField.text.length > 0) {
            vc.money = _countTextField.text;
        }
        [g_navigation pushViewController:vc animated:YES];
        return;
    }
    
    if ([_countTextField.text doubleValue] < 1) {
        [g_App showAlert:Localized(@"JX_Least1")];
        return;
    }
    
    if (button.tag == 1013) {
        int type = 0;
        if (self.cloudType != -1) {
            type = self.cloudType;
        }
        [g_server yopPayWithdraw:self.countTextField.text withdrawType:type toView:self];
    }else {
        //    if ([_countTextField.text doubleValue] > g_App.myMoney) {
        //        [g_App showAlert:Localized(@"CREDIT_LOW")];
        //        return;
        //    }
        if ([g_server.myself.isPayPassword boolValue]) {
            self.isAlipay = button.tag == 1011;
            self.verVC = [JXVerifyPayVC alloc];
            self.verVC.type = JXVerifyTypeWithdrawal;
            self.verVC.RMB = self.countTextField.text;
            self.verVC.delegate = self;
            self.verVC.didDismissVC = @selector(dismissVerifyPayVC);
            self.verVC.didVerifyPay = @selector(didVerifyPay:);
            self.verVC = [self.verVC init];
            
            [self.view addSubview:self.verVC.view];
        } else {
            JXPayPasswordVC *payPswVC = [JXPayPasswordVC alloc];
            payPswVC.type = JXPayTypeSetupPassword;
            payPswVC.enterType = JXEnterTypeWithdrawal;
            payPswVC = [payPswVC init];
            [g_navigation pushViewController:payPswVC animated:YES];
        }
        //    // 绑定微信
        //    SendAuthReq* req = [[SendAuthReq alloc] init];
        //    req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
        //    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        //    // app名称
        //    NSString *titleStr = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        //    req.state = titleStr;
        //    req.openID = AppleId;
        //
        //    [WXApi sendAuthReq:req
        //        viewController:self
        //              delegate:[WXApiManager sharedManager]];
        
    }
    
}

- (void)didVerifyPay:(NSString *)sender {
    self.payPassword = [NSString stringWithString:sender];

    if (self.isAlipay) {
        [g_server getAliPayAuthInfoToView:self];
    }else {
        // 绑定微信
        SendAuthReq* req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        // app名称
        NSString *titleStr = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        req.state = titleStr;
        req.openID = g_App.config.appleId;

        [WXApi sendAuthReq:req
            viewController:self
                  delegate:[WXApiManager sharedManager]];
    }
}

- (void)dismissVerifyPayVC {
    [self.verVC.view removeFromSuperview];
}

- (void)authRespNotification:(NSNotification *)notif {
    SendAuthResp *resp = notif.object;
    [self getWeChatTokenThenGetUserInfoWithCode:resp.code];
}

// 用户绑定微信，获取openid
- (void)getWeChatTokenThenGetUserInfoWithCode:(NSString *)code {

//    [_loading start];
    long time = (long)[[NSDate date] timeIntervalSince1970];
    time = (time *1000 + g_server.timeDifference)/1000;
    // 参数顺序不能变,先放key再放value
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"code",code, nil];
    [g_payServer payServerWithAction:act_UserBindWXCodeV1 param:arr payPassword:self.payPassword time:time toView:self];
//    [g_server userBindWXCodeWithCode:code toView:self];
}

-(void)hideControlAction{
    [_countTextField resignFirstResponder];
}

-(void)actionQuit{
    [_countTextField resignFirstResponder];
    [super actionQuit];
}
-(void)helpButtonAction{
    
}


- (void)alipayGetUserId:(NSNotification *)noti {
    long time = (long)[[NSDate date] timeIntervalSince1970];
    time = (time *1000 + g_server.timeDifference)/1000;
    // 参数顺序不能变,先放key再放value
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"aliUserId",noti.object, nil];
    
    [g_payServer payServerWithAction:act_aliPayUserIdV1 param:arr payPassword:self.payPassword time:time toView:self];
//    [g_server aliPayUserId:noti.object toView:self];
}


- (void)didServerResultSucces:(JXConnection *)aDownload dict:(NSDictionary *)dict array:(NSArray *)array1{
//    [_wait stop];
    if ([aDownload.action isEqualToString:act_UserBindWXCode] || [aDownload.action isEqualToString:act_UserBindWXCodeV1]) {
        
//        NSString *amount = [NSString stringWithFormat:@"%d",(int)([_countTextField.text doubleValue] * 100)];
        NSString *amount = _countTextField.text;
        long time = (long)[[NSDate date] timeIntervalSince1970];
        time = (time *1000 + g_server.timeDifference)/1000;
        NSString *secret = [self secretEncryption:dict[@"openid"] amount:amount time:time payPassword:self.payPassword];
        // 参数顺序不能变,先放key再放value
        NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"amount",amount, nil];
        
        [g_payServer payServerWithAction:act_TransferWXPayV1 param:arr payPassword:self.payPassword time:time toView:self];
//        [g_server transferWXPayWithAmount:amount secret:secret time:[NSNumber numberWithLong:time] toView:self];

    }else if ([aDownload.action isEqualToString:act_TransferWXPay] || [aDownload.action isEqualToString:act_TransferWXPayV1]) {
        [_loading stop];
        [self dismissVerifyPayVC];  // 销毁支付密码界面
        [g_App showAlert:Localized(@"JX_WithdrawalSuccess")];
        _countTextField.text = nil;
        [g_server getUserMoenyToView:self];
    }
    if ([aDownload.action isEqualToString:act_getUserMoeny]) {
        g_App.myMoney = [dict[@"balance"] doubleValue];
        _balanceLabel.text = [NSString stringWithFormat:@"%@¥%.2f，",Localized(@"JXMoney_blance"),g_App.myMoney];
        [g_notify postNotificationName:kUpdateUserNotifaction object:nil];
    }
    if ([aDownload.action isEqualToString:act_aliPayUserId] || [aDownload.action isEqualToString:act_aliPayUserIdV1]) {
        long time = (long)[[NSDate date] timeIntervalSince1970];
        time = (time *1000 + g_server.timeDifference)/1000;
        NSString *secret = [self secretEncryption:self.aliUserId amount:_countTextField.text time:time payPassword:self.payPassword];
        // 参数顺序不能变,先放key再放value
        NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"amount",self.countTextField.text, nil];
        
        [g_payServer payServerWithAction:act_alipayTransferV1 param:arr payPassword:self.payPassword time:time toView:self];
//        [g_server alipayTransfer:self.countTextField.text secret:secret time:@(time) toView:self];
    }
    if ([aDownload.action isEqualToString:act_alipayTransfer] || [aDownload.action isEqualToString:act_alipayTransferV1]) {
        [g_server showMsg:Localized(@"JX_WithdrawalSuccess")];
        [g_navigation dismissViewController:self animated:YES];
    }

    if ([aDownload.action isEqualToString:act_getAliPayAuthInfo]) {
        NSString *aliId = [dict objectForKey:@"aliUserId"];
        NSString *authInfo = [dict objectForKey:@"authInfo"];
        if (IsStringNull(aliId)) {
            NSString *appScheme = @"Schemes";
            [[AlipaySDK defaultService] auth_V2WithInfo:authInfo
                                             fromScheme:appScheme
                                               callback:^(NSDictionary *resultDic) {
                                                   NSLog(@"result = %@",resultDic);
                                                   // 解析 auth code
                                                   NSString *result = resultDic[@"result"];
                                                   if (result.length>0) {
                                                       NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                                                       for (NSString *subResult in resultArr) {
                                                           if (subResult.length > 10 && [subResult hasPrefix:@"user_id="]) {
                                                               self.aliUserId = [subResult substringFromIndex:8];
                                                               long time = (long)[[NSDate date] timeIntervalSince1970];
                                                               time = (time *1000 + g_server.timeDifference)/1000;
                                                               // 参数顺序不能变,先放key再放value
                                                               NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"aliUserId",self.aliUserId, nil];
                                                               
                                                               [g_payServer payServerWithAction:act_aliPayUserIdV1 param:arr payPassword:self.payPassword time:time toView:self];
//                                                               [g_server aliPayUserId:self.aliUserId toView:self];
                                                               break;
                                                           }
                                                       }
                                                   }
                                               }];

        }else {
            long time = (long)[[NSDate date] timeIntervalSince1970];
            time = (time *1000 + g_server.timeDifference)/1000;
            NSString *secret = [self secretEncryption:aliId amount:_countTextField.text time:time payPassword:self.payPassword];
            // 参数顺序不能变,先放key再放value
            NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"amount",self.countTextField.text, nil];
            
            [g_payServer payServerWithAction:act_alipayTransferV1 param:arr payPassword:self.payPassword time:time toView:self];
//            [g_server alipayTransfer:self.countTextField.text secret:secret time:@(time) toView:self];
        }
    }
    if ([aDownload.action isEqualToString:act_yopPayWithdraw]) {
        //返回需要跳转的url
        NSString *urlStr =[dict objectForKey:@"url"];
        NSString *withdrawalNo =[dict objectForKey:@"tradeNo"];
        
        webpageVC *webVC = [webpageVC alloc];
        webVC.isGotoBack= YES;
        webVC.url = urlStr;
        webVC.withdrawalNo = withdrawalNo;
        webVC = [webVC init];
        [g_navigation.navigationView addSubview:webVC.view];
    }
}

- (int)didServerResultFailed:(JXConnection *)aDownload dict:(NSDictionary *)dict{
    [_loading stop];
    if ([aDownload.action isEqualToString:act_alipayTransfer] || [aDownload.action isEqualToString:act_alipayTransferV1]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.verVC clearUpPassword];
        });
    }
    return show_error;
}

- (int)didServerConnectError:(JXConnection *)aDownload error:(NSError *)error{
    [_loading stop];
    return hide_error;
}

- (NSString *)secretEncryption:(NSString *)openId amount:(NSString *)amount time:(long)time payPassword:(NSString *)payPassword {
    NSString *secret = [NSString string];
    
    NSMutableString *str1 = [NSMutableString string];
    [str1 appendString:APIKEY];
    [str1 appendString:openId];
    [str1 appendString:MY_USER_ID];
    
    NSMutableString *str2 = [NSMutableString string];
    [str2 appendString:g_server.access_token];
    [str2 appendString:amount];
    [str2 appendString:[NSString stringWithFormat:@"%ld",time]];
    str2 = [[g_server getMD5String:str2] mutableCopy];
    
    [str1 appendString:str2];
    NSMutableString *str3 = [NSMutableString string];
    str3 = [[g_server getMD5String:payPassword] mutableCopy];
    [str1 appendString:str3];
    
    secret = [g_server getMD5String:str1];
    
    return secret;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
//    [_wait start];
}


- (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title detail:(NSString *)detail {
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button addTarget:self action:@selector(onYopPayWithdraw:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *selBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [selBtn setBackgroundImage:[UIImage imageNamed:@"sel_nor_wx2"] forState:UIControlStateNormal];
    [selBtn setBackgroundImage:[UIImage imageNamed:@"sel_check_wx2"] forState:UIControlStateSelected];
    selBtn.userInteractionEnabled = NO;
    selBtn.tag = 1001;
    [button addSubview:selBtn];
    
    CGSize titSize = [title sizeWithAttributes:@{NSFontAttributeName:SYSFONT(14)}];
    
    UILabel *titLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(selBtn.frame)+10, 0, titSize.width, titSize.height)];
    titLabel.text = title;
    titLabel.font =SYSFONT(14);
    [button addSubview:titLabel];
    
    CGSize detSize = [detail boundingRectWithSize:CGSizeMake(frame.size.width-CGRectGetMaxX(selBtn.frame)-10, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYSFONT(14)} context:nil].size;
    
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(selBtn.frame)+10, CGRectGetMaxY(titLabel.frame), detSize.width, detSize.height)];
    detailLabel.text = detail;
    detailLabel.numberOfLines = 0;
    detailLabel.font =SYSFONT(14);
    [button addSubview:detailLabel];
    
    CGRect btnFrame = button.frame;
    btnFrame.size.height = detSize.height + titSize.height;
    button.frame = btnFrame;
    
    selBtn.center = CGPointMake(selBtn.center.x, btnFrame.size.height/2);
    
    return button;
}


@end
