//
//  JXPayPasswordVC.m
//  shiku_im
//
//  Created by 1 on 2018/9/18.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXPayPasswordVC.h"
#import "UIImage+Color.h"
#import "JXMoneyMenuViewController.h"
#import "JXTextField.h"
#import "JXUserObject.h"
#import "JXSendRedPacketViewController.h"
#import "JXCashWithDrawViewController.h"
#import "JXTransferViewController.h"
#import "JXInputMoneyVC.h"
#import "webpageVC.h"
#import "JXPayViewController.h"

#define kDotSize CGSizeMake (10, 10) //密码点的大小
#define kDotCount 6  //密码个数
#define K_Field_Height 45  //每一个输入框的高度

@interface JXPayPasswordVC () <UITextFieldDelegate>
@property (nonatomic, strong) JXTextField *textField;
@property (nonatomic, strong) NSMutableArray *dotArray; //用于存放黑色的点点
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *detailLab;
@property (nonatomic, strong) UIButton *nextBtn;

@end

@implementation JXPayPasswordVC

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        [self setupViews];
        [self initPwdTextField];
        [self setupTitle];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //页面出现时让键盘弹出
    [self.textField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
#ifdef XCode11
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
#else
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
#endif
}


- (void)setupViews {
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP - 46, 46, 46)];
    [btn setBackgroundImage:[UIImage imageNamed:@"title_back_black_big"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(didDissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

    self.titleLab.frame = CGRectMake(0, 160, JX_SCREEN_WIDTH, 20);
    self.detailLab.frame = CGRectMake(0, CGRectGetMaxY(self.titleLab.frame)+30, JX_SCREEN_WIDTH, 17);
    self.textField.frame = CGRectMake(30, CGRectGetMaxY(self.detailLab.frame)+70, JX_SCREEN_WIDTH - 30*2, K_Field_Height);
    
    self.nextBtn.frame = CGRectMake(self.textField.frame.origin.x, CGRectGetMaxY(self.textField.frame)+25, JX_SCREEN_WIDTH-30*2, 40);
    [self.view addSubview:self.textField];
    [self.view addSubview:self.titleLab];
    [self.view addSubview:self.detailLab];
    [self.view addSubview:self.nextBtn];
    
}

- (void)didDissVC {
    if (self.type == JXPayTypeInputPassword) {
        [self goBackToVC];
    }else {
        [g_App showAlert:Localized(@"JX_CancelPayPsw") delegate:self];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self goBackToVC];
    }
}


- (void)setupTitle {
    if (self.type == JXPayTypeSetupPassword) {  // 第一次设置密码
        [self.nextBtn setHidden:YES];
        self.titleLab.text = Localized(@"JX_SetPayPsw");
        self.detailLab.text = Localized(@"JX_SetPayPswNo.1");
    } else if (self.type == JXPayTypeRepeatPassword) { // 第二次设置密码
        [self.nextBtn setHidden:NO];
        self.titleLab.text = Localized(@"JX_SetPayPsw");
        self.detailLab.text = Localized(@"JX_SetPayPswNo.2");
    } else if (self.type == JXPayTypeInputPassword) { // 如果有密码，进入需要确认密码
        [self.nextBtn setHidden:YES];
        self.titleLab.text = Localized(@"JX_UpdatePassWord");
        self.detailLab.text = Localized(@"JX_EnterToVerify");
    }
}


- (void)didNextButton {
    if ([self.textField.text length] < 6) {
        [g_App showAlert:Localized(@"JX_PswError")];
        [self clearUpPassword];
        return;
    }
    if (![self.textField.text isEqualToString:self.lastPsw]) {
        [g_App showAlert:Localized(@"JX_NotMatch")];
        [self goToSetupTypeVCWithOld:NO];
        return;
    }
    if ([self.textField.text isEqualToString:self.oldPsw]) {
        [g_App showAlert:Localized(@"JX_NewEqualOld")];
        [self goToSetupTypeVCWithOld:NO];
        return;
    }
    if(self.type == JXPayTypeRepeatPassword) {
        JXUserObject *user = [[JXUserObject alloc] init];
        user.payPassword = self.textField.text;
        user.oldPayPassword = self.oldPsw;
        [g_server updatePayPasswordWithUser:user toView:self];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initPwdTextField {
    //每个密码输入框的宽度
    CGFloat width = (JX_SCREEN_WIDTH - 30*2) / kDotCount;
    
    //生成分割线
    for (int i = 0; i < kDotCount - 1; i++) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.textField.frame) + (i + 1) * width, CGRectGetMinY(self.textField.frame), 0.5, K_Field_Height)];
        lineView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:lineView];
    }
    
    self.dotArray = [[NSMutableArray alloc] init];
    //生成中间的点
    for (int i = 0; i < kDotCount; i++) {
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.textField.frame) + (width - kDotCount) / 2 + i * width, CGRectGetMinY(self.textField.frame) + (K_Field_Height - kDotSize.height) / 2, kDotSize.width, kDotSize.height)];
        dotView.backgroundColor = [UIColor blackColor];
        dotView.layer.cornerRadius = kDotSize.width / 2.0f;
        dotView.clipsToBounds = YES;
        dotView.hidden = YES; //先隐藏
        [self.view addSubview:dotView];
        //把创建的黑色点加入到数组中
        [self.dotArray addObject:dotView];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([string isEqualToString:@"\n"]) {
        //按回车关闭键盘
        [textField resignFirstResponder];
        return NO;
    } else if(string.length == 0) {
        //判断是不是删除键
        return YES;
    }
    else if(textField.text.length >= kDotCount) {
        //输入的字符个数大于6，则无法继续输入，返回NO表示禁止输入
        return NO;
    } else {
        return YES;
    }
}

/**
 *  清除密码
 */
- (void)clearUpPassword {
    self.textField.text = @"";
    [self textFieldDidChange:self.textField];
}

/**
 *  重置显示的点
 */
- (void)textFieldDidChange:(UITextField *)textField {
    for (UIView *dotView in self.dotArray) {
        dotView.hidden = YES;
    }
    for (int i = 0; i < textField.text.length; i++) {
        ((UIView *)[self.dotArray objectAtIndex:i]).hidden = NO;
    }
    if (textField.text.length >= kDotCount) {
        if (self.type == JXPayTypeSetupPassword) {
            JXPayPasswordVC *payVC = [JXPayPasswordVC alloc];
            payVC.delegate = self.delegate;
            payVC.type = JXPayTypeRepeatPassword;
            payVC.enterType = self.enterType;
            payVC.lastPsw = self.textField.text;
            payVC.oldPsw = self.oldPsw;
            payVC = [payVC init];
            [g_navigation pushViewController:payVC animated:YES];
        }else if(self.type == JXPayTypeRepeatPassword) {
            [self.nextBtn setUserInteractionEnabled:YES];
            [_nextBtn setBackgroundColor:THEMECOLOR];
        } else if(self.type == JXPayTypeInputPassword) {
            JXUserObject *user = [[JXUserObject alloc] init];
            user.payPassword = self.textField.text;
            [g_server checkPayPasswordWithUser:user toView:self];
        }
    }else {
        [self.nextBtn setUserInteractionEnabled:NO];
        [_nextBtn setBackgroundColor:[THEMECOLOR colorWithAlphaComponent:0.5]];
    }
}


-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if([aDownload.action isEqualToString:act_UpdatePayPassword]){
        [self.textField resignFirstResponder];
        if ([self.delegate respondsToSelector:@selector(updatePayPasswordSuccess:)]) {
            [self.delegate updatePayPasswordSuccess:self.textField.text];
        }
        [self clearUpPassword];
        [g_App showAlert:Localized(@"JX_SetUpSuccess")];
        g_server.myself.isPayPassword = [dict objectForKey:@"payPassword"];
        [self goBackToVC];
    }
    if([aDownload.action isEqualToString:act_CheckPayPassword]){
        [self goToSetupTypeVCWithOld:YES];
    }

}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
}


- (void)goBackToVC {
    if (self.enterType == JXEnterTypeDefault) {
        [g_navigation popToViewController:[JXMoneyMenuViewController class] animated:YES];
    }
    else if (self.enterType == JXEnterTypeWithdrawal){
        [g_navigation popToViewController:[JXCashWithDrawViewController class] animated:YES];
    }
    else if (self.enterType == JXEnterTypeTransfer){
        [g_navigation popToViewController:[JXTransferViewController class] animated:YES];
    }
    else if (self.enterType == JXEnterTypeQr){
        [g_navigation popToViewController:[JXInputMoneyVC class] animated:YES];
    }
    else if (self.enterType == JXEnterTypeSkPay){
        [g_navigation popToViewController:[webpageVC class] animated:YES];
    }
    else if (self.enterType == JXEnterTypePayQr){
        [g_navigation popToViewController:[JXPayViewController class] animated:YES];
    }
    else {
        [g_navigation popToViewController:[JXSendRedPacketViewController class] animated:YES];
    }

}

- (void)goToSetupTypeVCWithOld:(BOOL)isOld {
    JXPayPasswordVC *payVC = [JXPayPasswordVC alloc];
    payVC.delegate = self.delegate;
    payVC.type = JXPayTypeSetupPassword;
    payVC.enterType = self.enterType;
    payVC.lastPsw = self.textField.text;
    // 这个是记录旧密码的
    payVC.oldPsw = isOld ? self.textField.text : self.oldPsw;
    payVC = [payVC init];
    [g_navigation pushViewController:payVC animated:YES];
}

#pragma mark - init

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[JXTextField alloc] init];
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.textColor = [UIColor whiteColor];
        _textField.tintColor = [UIColor whiteColor];
        _textField.delegate = self;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.keyboardType = UIKeyboardTypeNumberPad;
        _textField.layer.borderColor = [[UIColor blackColor] CGColor];
        _textField.layer.borderWidth = 0.5;
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}


- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.font = SYSFONT(26);
    }
    return _titleLab;
}

- (UILabel *)detailLab {
    if (!_detailLab) {
        _detailLab = [[UILabel alloc] init];
        _detailLab.textAlignment = NSTextAlignmentCenter;
    }
    return _detailLab;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [[UIButton alloc] init];
        [_nextBtn setTitle:Localized(@"JX_Finish") forState:UIControlStateNormal];
        [_nextBtn setBackgroundColor:[THEMECOLOR colorWithAlphaComponent:0.6]];
        _nextBtn.userInteractionEnabled = NO;
        _nextBtn.layer.masksToBounds = YES;
        _nextBtn.layer.cornerRadius = 4.f;
        [self.nextBtn setHidden:YES];
        [_nextBtn addTarget:self action:@selector(didNextButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}


@end
