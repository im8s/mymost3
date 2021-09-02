//
//  JXCheckCashWithdrawalVC.m
//  shiku_im
//
//  Created by p on 2019/12/9.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXCheckCashWithdrawalVC.h"
#import "JXSelectCashWithdrawalVC.h"
#import "JXVerifyPayVC.h"
#import "JXPayPasswordVC.h"

#define drawMarginX 20
#define bgWidth JX_SCREEN_WIDTH-15*2
#define drawHei 60

@interface JXCheckCashWithdrawalVC ()<JXSelectCashWithdrawalVCDelegate>

@property (nonatomic, strong) UIControl * hideControl;
@property (nonatomic, strong) UIControl * bgView;
@property (nonatomic, strong) UIView * targetView;
@property (nonatomic, strong) UIView * inputView;
@property (nonatomic, strong) UIView * balanceView;
@property (nonatomic, strong) UIView * toCashView;

@property (nonatomic, strong) UIButton * cardButton;
@property (nonatomic, strong) UITextField * countTextField;

@property (nonatomic, strong) UILabel * balanceLabel;
@property (nonatomic, strong) UIButton * drawAllBtn;
@property (nonatomic, strong) ATMHud *loading;
@property (nonatomic, strong) JXVerifyPayVC *verVC;
@property (nonatomic, strong) NSString *payPassword;
@property (nonatomic, assign) BOOL isAlipay;
@property (nonatomic, strong) NSString *aliUserId;

@property (nonatomic, strong) UIButton *selectBtn;
@property (nonatomic, strong) UIImageView *selectBtnImage;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) NSDictionary *data;

@end

@implementation JXCheckCashWithdrawalVC

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
    self.tableBody.backgroundColor = HEXCOLOR(0xF4F5FA);
    
    //    [self.tableHeader addSubview:self.helpButton];
    
    [self.tableBody addSubview:self.hideControl];
    [self.tableBody addSubview:self.bgView];
    
    //    [self.bgView addSubview:self.targetView];
    [self.bgView addSubview:self.inputView];
    [self.bgView addSubview:self.balanceView];
    self.bgView.frame = CGRectMake(15, 20, bgWidth, CGRectGetMaxY(_balanceView.frame));
    
    [self.tableBody addSubview:self.toCashView];
    [self.tableBody addSubview:self.doneBtn];
    [self.tableBody addSubview:self.tipLabel];
    _loading = [[ATMHud alloc] init];
    
    [g_notify addObserver:self selector:@selector(authRespNotification:) name:kWxSendAuthRespNotification object:nil];
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

-(UIView *)inputView{
    if (!_inputView) {
        _inputView = [[UIView alloc] init];
        _inputView.frame = CGRectMake(0, 0, bgWidth, 126);
        _inputView.backgroundColor = [UIColor whiteColor];
        
        UILabel * cashTitle = [UIFactory createLabelWith:CGRectMake(drawMarginX, drawMarginX, 120, 15) text:Localized(@"JXMoney_withDAmount")];
        cashTitle.font = SYSFONT(15);
//        cashTitle.textColor = HEXCOLOR(0x999999);
        [_inputView addSubview:cashTitle];
        
        UILabel * rmbLabel = [UIFactory createLabelWith:CGRectMake(drawMarginX, CGRectGetMaxY(cashTitle.frame)+36, 18, 30) text:@"¥"];
        rmbLabel.font = SYSFONT(30);
        rmbLabel.textAlignment = NSTextAlignmentLeft;
        [_inputView addSubview:rmbLabel];
        
        _countTextField = [UIFactory createTextFieldWithRect:CGRectMake(CGRectGetMaxX(rmbLabel.frame)+15, CGRectGetMaxY(cashTitle.frame)+31, bgWidth-CGRectGetMaxX(rmbLabel.frame)-drawMarginX-15, 40) keyboardType:UIKeyboardTypeDecimalPad secure:NO placeholder:nil font:[UIFont boldSystemFontOfSize:40] color:[UIColor blackColor] delegate:self];
        _countTextField.borderStyle = UITextBorderStyleNone;
        if (_money) {
            _countTextField.text = _money;
        }
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
        
        NSString * moneyStr = [NSString stringWithFormat:@"%@¥%.2f",Localized(@"JXMoney_blance"),g_App.myMoney];
        
        _balanceLabel = [UIFactory createLabelWith:CGRectZero text:moneyStr font:g_factory.font14 textColor:[UIColor lightGrayColor] backgroundColor:nil];
        CGFloat blanceWidth = [moneyStr sizeWithAttributes:@{NSFontAttributeName:_balanceLabel.font}].width;
        _balanceLabel.frame = CGRectMake(drawMarginX, drawMarginX, blanceWidth, 14);
        [_balanceView addSubview:_balanceLabel];
        
        _drawAllBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXMoney_withDAll") titleFont:_balanceLabel.font titleColor:HEXCOLOR(0x576b95) normal:nil selected:nil selector:@selector(drawAllBtnAction) target:self];
        CGFloat drawWidth = [_drawAllBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_drawAllBtn.titleLabel.font}].width;
        _drawAllBtn.frame = CGRectMake(CGRectGetMaxX(_balanceLabel.frame)+10, CGRectGetMinY(_balanceLabel.frame), drawWidth, 14);
        [_balanceView addSubview:_drawAllBtn];
        

        
        
//        UILabel *noticeLabel = [UIFactory createLabelWith:CGRectMake(drawMarginX, CGRectGetMaxY(_drawAllBtn.frame)+20, bgWidth-drawMarginX*2, 13) text:Localized(@"JXMoney_withDNotice") font:g_factory.font13 textColor:HEXCOLOR(0x999999) backgroundColor:nil];
//        noticeLabel.textAlignment = NSTextAlignmentCenter;
//        [_balanceView addSubview:noticeLabel];
        
        _balanceView.frame = CGRectMake(_balanceView.frame.origin.x, _balanceView.frame.origin.y, _balanceView.frame.size.width, CGRectGetMaxY(_drawAllBtn.frame) + 20);
    }
    return _balanceView;
}

- (UIView *)toCashView {
    
    if (!_toCashView) {
        _toCashView = [[UIControl alloc] init];
        _toCashView.frame = CGRectMake(15, CGRectGetMaxY(_bgView.frame) + 20, bgWidth, 400);
        _toCashView.backgroundColor = [UIColor whiteColor];
        _toCashView.layer.cornerRadius = 5;
        _toCashView.clipsToBounds = YES;
        
        UILabel * toCashTitle = [UIFactory createLabelWith:CGRectMake(drawMarginX, drawMarginX, 120, 15) text:Localized(@"JX_WithdrawTo")];
        toCashTitle.font = SYSFONT(15);
//        toCashTitle.textColor = HEXCOLOR(0x999999);
        [_toCashView addSubview:toCashTitle];
        
        _selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(drawMarginX, CGRectGetMaxY(toCashTitle.frame) + 20, _toCashView.frame.size.width - 20, 50)];
        [_selectBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_selectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_selectBtn setTitle:Localized(@"JX_PleaseSelectWithdrawalAccount") forState:UIControlStateNormal];
        _selectBtn.titleLabel.font = SYSFONT(15);
        _selectBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        [_selectBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
        [_selectBtn addTarget:self action:@selector(selectBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_toCashView addSubview:_selectBtn];
        
        _selectBtnImage = [[UIImageView alloc] init];
        _selectBtnImage.frame = CGRectMake(0, 15, 20, 20);
        [_selectBtn addSubview:_selectBtnImage];
        _selectBtnImage.hidden = YES;
        
        UIImageView * arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(_selectBtn.frame.size.width-15-7, 21.5, 7, 13)];
        arrowView.image = [UIImage imageNamed:@"new_icon_>"];
        [_selectBtn addSubview:arrowView];
        
        _toCashView.frame = CGRectMake(_toCashView.frame.origin.x, _toCashView.frame.origin.y, _toCashView.frame.size.width, CGRectGetMaxY(_selectBtn.frame));
    }
    
    return _toCashView;
}

- (UIButton *)doneBtn {
 
    if (!_doneBtn) {
        _doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_toCashView.frame) + 20, JX_SCREEN_WIDTH - 30, 40)];
        UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
        [_doneBtn setBackgroundImage:[UIImage createImageWithColor:THEMECOLOR] forState:UIControlStateNormal];
        [_doneBtn setBackgroundImage:img forState:UIControlStateHighlighted];

        [_doneBtn setTitle:Localized(@"JX_ConfirmWithdrawal") forState:UIControlStateNormal];
        [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _doneBtn.layer.cornerRadius = 5.0;
        _doneBtn.layer.masksToBounds = YES;
        [_doneBtn addTarget:self action:@selector(doneBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _doneBtn;
}

- (void)doneBtnAction {
    if ([_countTextField.text doubleValue] < 1) {
        [g_App showAlert:Localized(@"JX_Least1")];
        return;
    }
    if (!_selectBtn.selected) {
        [JXMyTools showTipView:Localized(@"JX_PleaseSelectWithdrawalMethod")];
        
        return;
    }
    
    if ([g_server.myself.isPayPassword boolValue]) {
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
    
}

- (UILabel *)tipLabel {
 
    if (!_tipLabel) {
        
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_doneBtn.frame) + 10, JX_SCREEN_WIDTH - 30, 0)];
        _tipLabel.font = SYSFONT(13.0);
        _tipLabel.textColor = [UIColor lightGrayColor];
        _tipLabel.textAlignment = NSTextAlignmentLeft;
        _tipLabel.numberOfLines = 0;
        _tipLabel.text = [NSString stringWithFormat:@"%@：\n%@\n%@\n%@\n%@",Localized(@"JX_WithdrawalInstructions"),Localized(@"JX_WithdrawalInstructions1"),Localized(@"JX_WithdrawalInstructions2"),Localized(@"JX_WithdrawalInstructions3"),Localized(@"JX_WithdrawalInstructions4")];
        CGSize size = [_tipLabel.text boundingRectWithSize:CGSizeMake(_tipLabel.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_tipLabel.font} context:nil].size;
        _tipLabel.frame = CGRectMake(_tipLabel.frame.origin.x, _tipLabel.frame.origin.y, _tipLabel.frame.size.width, size.height);
    }
    
    return _tipLabel;
}

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

-(void)drawAllBtnAction{
    NSString * allMoney = [NSString stringWithFormat:@"%.2f",g_App.myMoney];
    _countTextField.text = allMoney;
}

- (void)selectBtnAction {
    JXSelectCashWithdrawalVC *vc = [[JXSelectCashWithdrawalVC alloc] init];
    vc.delegate = self;
    [g_navigation pushViewController:vc animated:YES];
}

- (void)selectCashWithdrawalWithData:(NSDictionary *)data {
    
    _data = data;
    
    _selectBtn.selected = YES;
    
    _selectBtnImage.hidden = NO;
    if ([[data objectForKey:@"type"] intValue] == 1) {
        _selectBtnImage.image = [UIImage imageNamed:@"withdrawal_aliPay"];
        [_selectBtn setTitle:[data objectForKey:@"aliPayName"] forState:UIControlStateSelected];
    }else {
        _selectBtnImage.image = [UIImage imageNamed:@"yinlian"];
        NSString *bankCardNo = [data objectForKey:@"bankCardNo"];
        NSString *last4Num = [bankCardNo substringFromIndex:bankCardNo.length - 4];
        NSString *str = [NSString stringWithFormat:@"%@ (%@)",[data objectForKey:@"bankName"],last4Num];
        [_selectBtn setTitle:str forState:UIControlStateSelected];
    }
    
    [_selectBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, _selectBtnImage.frame.size.width + 10, 0, 0)];
}

- (void)didVerifyPay:(NSString *)sender {
    self.payPassword = [NSString stringWithString:sender];
    
    NSString *amount = _countTextField.text;
    long time = (long)[[NSDate date] timeIntervalSince1970];
    time = (time *1000 + g_server.timeDifference)/1000;
    // 参数顺序不能变,先放key再放value
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"amount",amount,@"withdrawAccountId",[self.data objectForKey:@"id"], nil];
    
    [g_payServer payServerWithAction:act_ManualPayWithdraw param:arr payPassword:self.payPassword time:time toView:self];
}

- (void)dismissVerifyPayVC {
    [self.verVC.view removeFromSuperview];
}


-(void)hideControlAction{
    [_countTextField resignFirstResponder];
}

-(void)actionQuit{
    [_countTextField resignFirstResponder];
    [super actionQuit];
}

- (void)didServerResultSucces:(JXConnection *)aDownload dict:(NSDictionary *)dict array:(NSArray *)array1{
    [_wait stop];
    if ([aDownload.action isEqualToString:act_ManualPayWithdraw]) {
        
        [self.verVC.view removeFromSuperview];
        [g_server showMsg:Localized(@"JX_ApplicationSubmitted")];
    }
}

- (int)didServerResultFailed:(JXConnection *)aDownload dict:(NSDictionary *)dict{
    [_wait stop];
    
    return show_error;
}

- (int)didServerConnectError:(JXConnection *)aDownload error:(NSError *)error{
    [_wait stop];
    return show_error;
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
