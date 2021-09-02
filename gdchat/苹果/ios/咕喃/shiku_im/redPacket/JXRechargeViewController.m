//
//  JXRechargeViewController.m
//  shiku_im
//
//  Created by 1 on 17/10/30.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXRechargeViewController.h"
#import "JXRechargeCell.h"
#import "UIImage+Color.h"
#import <AlipaySDK/AlipaySDK.h>
#import "JXRechargeQRCodeView.h"
#import "webpageVC.h"

@interface JXRechargeViewController ()<UIAlertViewDelegate,UITextFieldDelegate,JXRechargeQRCodeViewDelegate>
@property (nonatomic, assign) NSInteger checkIndex;
@property (atomic, assign) NSInteger payType;


//@property (nonatomic, strong) NSArray * rechargeArray;
@property (nonatomic, strong) NSArray * rechargeMoneyArray;


@property (nonatomic, strong) UILabel * totalMoney;
@property (nonatomic, strong) UIButton * wxPayBtn;
@property (nonatomic, strong) UIButton * aliPayBtn;
@property (nonatomic, strong) UIButton * bankCardBtn;

@property (nonatomic, strong) UIButton * cloudPayBtn;

@property (atomic, assign) NSInteger btnIndex;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UITextField *moneyTextField;

@property (nonatomic, strong) NSString *rechargeQRCodeViewMoney;
@property (nonatomic, assign) NSInteger rechargeQRCodeViewType;
@property (nonatomic, strong) JXRechargeQRCodeView *currentRechargeQRCodeView;
@end

static NSString * JXRechargeCellID = @"JXRechargeCellID";

@implementation JXRechargeViewController

-(instancetype)init{
    if (self = [super init]) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
        self.title = Localized(@"JXLiveVC_Recharge");
        self.rechargeMoneyArray = @[@10,
                                    @20,
                                    @50,
                                    @100,
                                    @200,
                                    @500];
        _checkIndex = -1;
        
        [g_notify addObserver:self selector:@selector(receiveWXPayFinishNotification:) name:kWxPayFinishNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createHeadAndFoot];
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH,56*2)];
    [self.tableBody addSubview:self.baseView];
    
    [self setupViews];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.baseView.frame)+20, JX_SCREEN_WIDTH-30, LINE_WH)];
    line.backgroundColor = THE_LINE_COLOR;
    [self.tableBody addSubview:line];
    
    UILabel *tinLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(line.frame)+20, JX_SCREEN_WIDTH-30, 18)];
    tinLabel.textColor = HEXCOLOR(0x999999);
    tinLabel.font = SYSFONT(14);
    tinLabel.text = Localized(@"JX_PleaseSelectRechargeMethod");
    [self.tableBody addSubview:tinLabel];
    
    
    UILabel *leftLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48, 16)];
    leftLab.font = SYSFONT(16);
    leftLab.text = Localized(@"JX_Total:");
    
    
    CGSize size = [Localized(@"JX_ChinaMoney") sizeWithAttributes:@{NSFontAttributeName:SYSFONT(24)}];
    
    UILabel *rigLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, 24)];
    rigLab.font = SYSFONT(24);
    rigLab.textColor = THEMECOLOR;
    rigLab.text = Localized(@"JX_ChinaMoney");

    self.moneyTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(tinLabel.frame)+24, JX_SCREEN_WIDTH-30, 24)];
    self.moneyTextField.placeholder = Localized(@"JX_PleaseEnterAmount");
    self.moneyTextField.textColor = THEMECOLOR;
    self.moneyTextField.font = SYSFONT(24);
    self.moneyTextField.leftView = leftLab;
    self.moneyTextField.leftViewMode = UITextFieldViewModeAlways;
    self.moneyTextField.rightView = rigLab;
    self.moneyTextField.rightViewMode = UITextFieldViewModeAlways;
    self.moneyTextField.delegate = self;
    self.moneyTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.moneyTextField.text = [NSString stringWithFormat:@"%.2f",[self.rechargeMoneyArray[self.btnIndex] doubleValue]];
    [self.moneyTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.tableBody addSubview:self.moneyTextField];
    
    [self setTextFieldWidth:self.moneyTextField.text];

    if (self.isCloud) {
        self.cloudPayBtn = [self payTypeBtn:CGRectMake(0, CGRectGetMaxY(self.moneyTextField.frame)+30, JX_SCREEN_WIDTH, 56) title:Localized(@"JXLiveVC_Recharge") image:nil drawTop:NO drawBottom:YES action:@selector(cloudPayBtnAction:)];
    }else {
        CGFloat y = CGRectGetMaxY(self.moneyTextField.frame)+30;
        if ([g_config.isOpenWxPay boolValue] || self.isScanRecharge) {
            self.wxPayBtn = [self payTypeBtn:CGRectMake(0, y, JX_SCREEN_WIDTH, 56) title:Localized(@"JXMoney_wxPay") image:@"weixin_logo" drawTop:NO drawBottom:YES action:@selector(wxPayBtnAction:)];
            y = CGRectGetMaxY(self.wxPayBtn.frame);
        }
        
        if ([g_config.isOpenAliPay boolValue] || self.isScanRecharge) {
            self.aliPayBtn = [self payTypeBtn:CGRectMake(0, y, JX_SCREEN_WIDTH, 56) title:Localized(@"JXMoney_aliPay") image:@"aliPay_logo" drawTop:NO drawBottom:NO action:@selector(aliPayBtnAction:)];
            y = CGRectGetMaxY(self.aliPayBtn.frame);
        }
        
        if (self.isScanRecharge) {
            self.bankCardBtn = [self payTypeBtn:CGRectMake(0, y, JX_SCREEN_WIDTH, 56) title:Localized(@"JX_BankTransfer") image:@"yinlian" drawTop:YES drawBottom:NO action:@selector(bankCardBtnAction:)];
        }
    }

//    self.isShowHeaderPull = NO;
//    self.isShowFooterPull = NO;
//    _table.backgroundColor = HEXCOLOR(0xefeff4);
//    [_table registerClass:[JXRechargeCell class] forCellReuseIdentifier:JXRechargeCellID];
//    _table.showsVerticalScrollIndicator = NO;
//    _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}


- (void)textFieldDidChange:(UITextField *)textField {
    if (textField == self.moneyTextField) {
        if ([textField.text doubleValue] >= 10000) {
            textField.text = @"10000";
        }
    }
    [self setTextFieldWidth:textField.text];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.moneyTextField) {
        // 首位不能输入 .
        if (IsStringNull(textField.text) && [string isEqualToString:@"."]) {
            return NO;
        }
        //限制.后面最多有两位，且不能再输入.
        if ([textField.text rangeOfString:@"."].location != NSNotFound) {
            //有.了 且.后面输入了两位  停止输入
            if (toBeString.length > [toBeString rangeOfString:@"."].location+3) {
                return NO;
            }
            //有.了，不允许再输入.
            if ([string isEqualToString:@"."]) {
                return NO;
            }
        }
        //限制首位0，后面只能输入. 和 删除
        if ([textField.text isEqualToString:@"0"]) {
            if (![string isEqualToString:@"."] && ![string isEqualToString:@""]) {
                return NO;
            }
        }
        //限制只能输入：1234567890.
        NSCharacterSet * characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890."] invertedSet];
        NSString * filtered = [[string componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
    return YES;
}

- (void)setupViews {
    UIButton *btn;
    CGFloat w = 89;
    int inset = (JX_SCREEN_WIDTH-w*3)/4;
    for (int i = 0; i < self.rechargeMoneyArray.count; i++) {
        CGFloat x = (w+inset)*(i % 3)+inset;
        int m = i / 3;
        btn = [self createButtonWihtFrame:CGRectMake(x, m*41+(15 * (m +1)), w, 41) title:[NSString stringWithFormat:@"%.2f%@",[self.rechargeMoneyArray[i] doubleValue],Localized(@"JX_ChinaMoney")] index:i];
    }
}



- (void)onDidMoney:(UIButton *)button {
    if ([self.moneyTextField isFirstResponder]) {
        [self.moneyTextField resignFirstResponder];
    }
    self.btnIndex = button.tag;
    
    self.moneyTextField.text = [NSString stringWithFormat:@"%.2f",[self.rechargeMoneyArray[self.btnIndex] doubleValue]];
    [self setTextFieldWidth:self.moneyTextField.text];
    
    for (UIView *view in self.baseView.subviews) {
        [view removeFromSuperview];
    }
    [self setupViews];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.btnIndex = self.rechargeMoneyArray.count+1;
    textField.text = @"";
    [self setTextFieldWidth:textField.text];
    
    for (UIView *view in self.baseView.subviews) {
        [view removeFromSuperview];
    }
    [self setupViews];

    return YES;
}

- (void)setTextFieldWidth:(NSString *)s {
    CGSize size = [s sizeWithAttributes:@{NSFontAttributeName:SYSFONT(24)}];
    CGSize size1 = [Localized(@"JX_ChinaMoney") sizeWithAttributes:@{NSFontAttributeName:SYSFONT(24)}];
    
    CGRect frame = self.moneyTextField.frame;
    if (s.length > 0) {
        frame.size.width = size.width+55+size1.width;
    }else {
        frame.size.width = 130+55+size1.width;
    }
    self.moneyTextField.frame = frame;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([textField.text doubleValue] > 0) {
        self.moneyTextField.text = [NSString stringWithFormat:@"%.2f",[textField.text doubleValue]];
        [self setTextFieldWidth:textField.text];
    }
    return YES;
}

-(void)dealloc{
    [g_notify removeObserver:self];
}

//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return _rechargeMoneyArray.count;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 65;
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    JXRechargeCell * cell = [tableView dequeueReusableCellWithIdentifier:JXRechargeCellID forIndexPath:indexPath];
//    NSString * money = [NSString stringWithFormat:@"%@%@",_rechargeMoneyArray[indexPath.row],Localized(@"JX_ChinaMoney")];
//    cell.textLabel.text = money;
//    if(_checkIndex == indexPath.row){
//        cell.checkButton.selected = YES;
//    }
//    return cell;
//}
//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    _checkIndex = indexPath.row;
//    NSString * money = [NSString stringWithFormat:@"%@",_rechargeMoneyArray[indexPath.row]];
//    [self setTotalMoneyText:money];
//    NSArray * cellArray = [tableView visibleCells];
//    for (JXRechargeCell * cell in cellArray) {
//        cell.checkButton.selected = NO;
//    }
//
//    JXRechargeCell * selCell = [tableView cellForRowAtIndexPath:indexPath];
//    selCell.checkButton.selected = YES;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 200;
//}
//
//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    UIView * paySelView = [[UIView alloc] init];
//    paySelView.backgroundColor = HEXCOLOR(0xefeff4);
//    UILabel * payStyleLabel = [UIFactory createLabelWith:CGRectMake(20, 0, JX_SCREEN_WIDTH-20*2, 40) text:Localized(@"JXMoney_choosePayType") font:g_factory.font14 textColor:[UIColor lightGrayColor] backgroundColor:[UIColor clearColor]];
//    [paySelView addSubview:payStyleLabel];
//
//    UIView * whiteView = [[UIView alloc] init];
//    whiteView.backgroundColor = [UIColor whiteColor];
//    whiteView.frame = CGRectMake(0, CGRectGetMaxY(payStyleLabel.frame), JX_SCREEN_WIDTH, 200-CGRectGetMaxY(payStyleLabel.frame));
//    [paySelView addSubview:whiteView];
//
//    UILabel * totalTitle = [UIFactory createLabelWith:CGRectZero text:nil font:g_factory.font14 textColor:[UIColor lightGrayColor] backgroundColor:[UIColor clearColor]];
//    NSString * totalStr = Localized(@"JXMoney_total");
//    CGFloat totalWidth = [totalStr sizeWithAttributes:@{NSFontAttributeName:totalTitle.font}].width;
//    totalTitle.frame = CGRectMake(20, 20, totalWidth+5, 18);
//    totalTitle.text = totalStr;
//    [whiteView addSubview:totalTitle];
//
//
//    _totalMoney = [UIFactory createLabelWith:CGRectZero text:nil font:g_factory.font20 textColor:[UIColor lightGrayColor] backgroundColor:[UIColor clearColor]];
//    NSString * totalMoneyStr = @"¥--";
//    CGFloat moneyWidth = [totalMoneyStr sizeWithAttributes:@{NSFontAttributeName:_totalMoney.font}].width;
//    _totalMoney.frame = CGRectMake(CGRectGetMaxX(totalTitle.frame), 20, moneyWidth+5, 18);
//    _totalMoney.text = totalMoneyStr;
//    _totalMoney.textColor = [UIColor redColor];
//    [whiteView addSubview:_totalMoney];
//
//    _wxPayBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXMoney_wxPay") titleFont:g_factory.font17 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(wxPayBtnAction:) target:self];
//    _wxPayBtn.frame = CGRectMake(20, CGRectGetMaxY(_totalMoney.frame)+20, JX_SCREEN_WIDTH-20*2, 40);
//    [_wxPayBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x1aad19)] forState:UIControlStateNormal];
//    [_wxPayBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xa2dea3)] forState:UIControlStateDisabled];
//    _wxPayBtn.layer.cornerRadius = 5;
//    _wxPayBtn.clipsToBounds = YES;
//    [whiteView addSubview:_wxPayBtn];
//
//
//    _aliPayBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXMoney_aliPay") titleFont:g_factory.font17 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(aliPayBtnAction:) target:self];
//    _aliPayBtn.frame = CGRectMake(20, CGRectGetMaxY(_wxPayBtn.frame)+15, JX_SCREEN_WIDTH-20*2, 40);
//    [_aliPayBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x1aad19)] forState:UIControlStateNormal];
//    [_aliPayBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xa2dea3)] forState:UIControlStateDisabled];
//    _aliPayBtn.layer.cornerRadius = 5;
//    _aliPayBtn.clipsToBounds = YES;
//    [whiteView addSubview:_aliPayBtn];
//
//
//    return paySelView;
//}

-(void)setTotalMoneyText:(NSString *)money{
    NSString * totalMoneyStr = [NSString stringWithFormat:@"¥%@",money];
    CGFloat moneyWidth = [totalMoneyStr sizeWithAttributes:@{NSFontAttributeName:_totalMoney.font}].width;
    CGRect frame = _totalMoney.frame;
    frame.size.width = moneyWidth;
    _totalMoney.frame = frame;
    _totalMoney.text = totalMoneyStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)cloudPayBtnAction:(UIButton *)button{
    if ([self.moneyTextField.text doubleValue] <= 0) {
        [JXMyTools showTipView:Localized(@"JX_PleaseEnterRechargeAmount")];
        return;
    }
    [g_server rechargeAmount:self.moneyTextField.text toView:self];
}


#pragma mark Action

-(void)wxPayBtnAction:(UIButton *)button{
//    if (_checkIndex >=0 && _checkIndex <_rechargeMoneyArray.count) {
//        NSString * money = [NSString stringWithFormat:@"%@",_rechargeMoneyArray[_checkIndex]];
//        _payType = 2;
//        [g_server getSign:money payType:2 toView:self];
//    }
    [self.view endEditing:YES];
    
    _payType = 2;
    
    if (self.isScanRecharge) {
        
        [g_server manualPayGetReceiveAccountWithType:@"1" toView:self];
        return;
    }
    
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"wechat://"]] ) {
        // 没有安装微信
        [JXMyTools showTipView:[NSString stringWithFormat:@"%@ %@",Localized(@"JX_NotInstalled"),Localized(@"JX_WeChat")]];
        
        return;
    }
    
    if ([self.moneyTextField.text doubleValue] > 0) {
        [g_server getSign:self.moneyTextField.text payType:2 toView:self];
    }else {
        [JXMyTools showTipView:Localized(@"JX_PleaseEnterRechargeAmount")];

    }
}

-(void)aliPayBtnAction:(UIButton *)button{
//    if (_checkIndex >=0 && _checkIndex <_rechargeMoneyArray.count) {
//        NSString * money = [NSString stringWithFormat:@"%@",_rechargeMoneyArray[_checkIndex]];
//        _payType = 1;
//        [g_server getSign:money payType:1 toView:self];
//    }
    
    [self.view endEditing:YES];
    

    
    _payType = 1;
    if (self.isScanRecharge) {
        
        [g_server manualPayGetReceiveAccountWithType:@"2" toView:self];
        return;
    }
    
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipay://"]] ) {
        // 没有安装支付宝
        [JXMyTools showTipView:[NSString stringWithFormat:@"%@ %@",Localized(@"JX_NotInstalled"),Localized(@"JX_Alipay")]];
        
        return;
    }
    
    if ([self.moneyTextField.text doubleValue] > 0) {
        [g_server getSign:self.moneyTextField.text payType:1 toView:self];
    }else {
        [JXMyTools showTipView:Localized(@"JX_PleaseEnterRechargeAmount")];
    }
}

- (void)bankCardBtnAction:(UIButton *)button {
    
    [self.view endEditing:YES];
    _payType = 3;
    if (self.isScanRecharge) {
        
        [g_server manualPayGetReceiveAccountWithType:@"3" toView:self];
    }
}

-(void)tuningWxWith:(NSDictionary *)dict{
    PayReq *req = [[PayReq alloc] init];
    req.partnerId = [dict objectForKey:@"partnerId"];
    req.prepayId = [dict objectForKey:@"prepayId"];
    req.nonceStr = [dict objectForKey:@"nonceStr"];
    req.timeStamp = [[dict objectForKey:@"timeStamp"] intValue];
    req.package = @"Sign=WXPay";//[dict objectForKey:@"package"];
    req.sign = [dict objectForKey:@"sign"];
    [WXApi sendReq:req];
}

- (void)tuningAlipayWithOrder:(NSString *)signedString {
    // NOTE: 如果加签成功，则继续执行支付
    if (signedString != nil) {
        //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
        NSString *appScheme = @"Schemes";
        // NOTE: 调用支付结果开始支付
        [[AlipaySDK defaultService] payOrder:signedString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            
            SBJsonParser * resultParser = [[SBJsonParser alloc] init] ;
            NSDictionary *resultObject = [resultParser objectWithString:resultDic[@"result"]];
            NSDictionary *response = [resultObject objectForKey:@"alipay_trade_app_pay_response"];
            if ([response[@"msg"] isEqualToString:@"Success"]) {
                
                [g_App showAlert:Localized(@"JX_AddMoneyOK") delegate:self tag:1001 onlyConfirm:YES];
            }else {
                
                [g_App showAlert:Localized(@"JX_RechargeFailed") delegate:self tag:1001 onlyConfirm:YES];
            }
            [self actionQuit];
            NSLog(@"reslut = %@",resultDic);
        }];
    }

}

-(void)receiveWXPayFinishNotification:(NSNotification *)notifi{
    PayResp *resp = notifi.object;
    switch (resp.errCode) {
        case WXSuccess:{
            [g_App showAlert:Localized(@"JXMoney_PaySuccess") delegate:self tag:1001 onlyConfirm:YES];
            if (self.rechargeDelegate && [self.rechargeDelegate respondsToSelector:@selector(rechargeSuccessed)]) {
                [self.rechargeDelegate performSelector:@selector(rechargeSuccessed)];
            }
            if (_isQuitAfterSuccess) {
                [self actionQuit];
            }
            break;
        }
        case WXErrCodeUserCancel:{
            //取消了支付
            break;
        }
        default:{
            //支付错误
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"支付失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            break;
        }
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1001) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [g_server getUserMoenyToView:self];
        });
    }else if (alertView.tag == 25555){
        if (buttonIndex == 1) {
            [_currentRechargeQRCodeView removeFromSuperview];
            [g_server manualPayRechargeWithType:[NSString stringWithFormat:@"%ld",(long)_rechargeQRCodeViewType] money:_rechargeQRCodeViewMoney toView:self];
        }
    }
}


- (void)didServerResultSucces:(JXConnection *)aDownload dict:(NSDictionary *)dict array:(NSArray *)array1{
    [_wait stop];
    if ([aDownload.action isEqualToString:act_getSign]) {
        if ([[dict objectForKey:@"package"] isEqualToString:@"Sign=WXPay"]) {
            [self tuningWxWith:dict];
        }else {
            [self tuningAlipayWithOrder:[dict objectForKey:@"orderInfo"]];
        }
    }
    if ([aDownload.action isEqualToString:act_getUserMoeny]) {
        g_App.myMoney = [dict[@"balance"] doubleValue];
        [g_notify postNotificationName:kUpdateUserNotifaction object:nil];
        [self actionQuit];
    }
    if ([aDownload.action isEqualToString:act_ManualPayGetReceiveAccount]) {
        
        JXRechargeQRCodeView *view = [[JXRechargeQRCodeView alloc] initWithFrame:g_navigation.navigationView.frame];
        if (_payType == 1) {
            view.type = RechargeType_Alipay;
        }else if(_payType == 2) {
            view.type = RechargeType_Wechat;
        }else if(_payType == 3) {
            view.type = RechargeType_BankCard;
        }
        view.delegate = self;
        view.money = self.moneyTextField.text;
        view.bankCard = [dict objectForKey:@"bankCard"];
        view.bankName = [dict objectForKey:@"bankName"];
        view.name = [dict objectForKey:@"name"];
        view.qrUrl = [dict objectForKey:@"url"];
        [g_navigation.navigationView addSubview:view];
    }
    if ([aDownload.action isEqualToString:act_recharge]) {
        //返回需要跳转的url
        NSString *urlStr =[dict objectForKey:@"url"];
        // 订单号
        NSString *tradeNo =[dict objectForKey:@"tradeNo"];
        
        webpageVC *webVC = [webpageVC alloc];
        webVC.isGotoBack= YES;
        webVC.url = urlStr;
        webVC.tradeNo = tradeNo;
        webVC = [webVC init];
        [g_navigation.navigationView addSubview:webVC.view];
        
    }
    if ([aDownload.action isEqualToString:act_ManualPayRecharge]) {
        [JXMyTools showTipView:Localized(@"JX_RequestSendWaiting")];
    }

}

- (int)didServerResultFailed:(JXConnection *)aDownload dict:(NSDictionary *)dict{
    [_wait stop];
    return show_error;
}

- (int)didServerConnectError:(JXConnection *)aDownload error:(NSError *)error{
    [_wait stop];
    return hide_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
}


- (UIButton *)createButtonWihtFrame:(CGRect)frame title:(NSString *)title index:(NSInteger)index {
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    [btn setTag:index];

    UIImageView *imgV = [[UIImageView alloc] initWithFrame:btn.bounds];
    imgV.image = [[UIImage imageNamed:@"Recharge_normal"] imageWithTintColor:THEMECOLOR];
    [btn addSubview:imgV];
    
    UILabel *label = [[UILabel alloc] initWithFrame:btn.bounds];
    label.text = title;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = THEMECOLOR;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = SYSFONT(14);
    [btn addSubview:label];
    if (self.btnIndex == index) {
        imgV.image = [[UIImage imageNamed:@"Recharge_seleted"] imageWithTintColor:THEMECOLOR];
        label.textColor = [UIColor whiteColor];
    }

    [btn addTarget:self action:@selector(onDidMoney:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.baseView addSubview:btn];
    
    return btn;
}


- (UIButton *)payTypeBtn:(CGRect)frame title:(NSString *)title image:(NSString *)image drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom action:(SEL)action {
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-19-36, (frame.size.height-19)/2, 19, 19)];
    imgV.image = [UIImage imageNamed:image];
    [btn addSubview:imgV];
    if (action == @selector(wxPayBtnAction:)) {
        imgV.frame = CGRectMake(frame.size.width-20-36, (frame.size.height-16)/2, 20, 16);
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, frame.size.height)];
    label.text = title;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = HEXCOLOR(0x222222);
    label.font = SYSFONT(16);
    [btn addSubview:label];
    
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    [self.tableBody addSubview:btn];
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(15,0,JX_SCREEN_WIDTH-15,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(15, frame.size.height-LINE_WH,JX_SCREEN_WIDTH-15,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15-7, frame.size.height/2-13/2, 7, 13)];
    iv.image = [UIImage imageNamed:@"new_icon_>"];
    [btn addSubview:iv];
    
    return btn;
}

- (void)rechargeQRCodeView:(JXRechargeQRCodeView *)view doneBtnActionWithMoney:(NSString *)money type:(NSInteger)type {
    _rechargeQRCodeViewMoney = money;
    _rechargeQRCodeViewType = type;
    _currentRechargeQRCodeView = view;
    [self showAlert:Localized(@"JX_WhethePaymentCompleted") delegate:self tag:25555];
}

- (UIAlertView *) showAlert: (NSString *) message delegate:(id)delegate tag:(NSUInteger)tag
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:APP_NAME message:message delegate:delegate cancelButtonTitle:Localized(@"JX_Cencal") otherButtonTitles:Localized(@"JX_Paid"), nil];
    av.tag = tag;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [av show];
        [g_navigation resetVCFrame];
    });
    return av;
}

@end
