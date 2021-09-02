//
//  JXSendRedPacketViewController.m
//  lveliao_IM
//
//  Created by 1 on 17/8/14.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXSendRedPacketViewController.h"
#import "JXTopSiftJobView.h"
#import "JXRedInputView.h"
#import "JXRechargeViewController.h"
#import "JXVerifyPayVC.h"
#import "JXPayPasswordVC.h"
#import "JXPayServer.h"

#define TopHeight 40

@interface JXSendRedPacketViewController ()<UITextFieldDelegate,UIScrollViewDelegate,RechargeDelegate>
@property (nonatomic, strong) JXTopSiftJobView * topSiftView;

@property (nonatomic, strong) JXRedInputView * luckyView;
@property (nonatomic, strong) JXRedInputView * nomalView;
@property (nonatomic, strong) JXRedInputView * orderView;
@property (nonatomic, strong) JXVerifyPayVC * verVC;


@property (nonatomic, copy) NSString * moneyText;
@property (nonatomic, copy) NSString * countText;
@property (nonatomic, copy) NSString * greetText;

@property (nonatomic, assign) NSInteger indexInt;


@end

@implementation JXSendRedPacketViewController

-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.heightFooter = 0;
    self.heightHeader = 0;
    [self createHeadAndFoot];

    [self createHeaderView];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endEdit:)];
    [self.tableBody addGestureRecognizer:tap];

    if (_isRoom) {
        self.tableBody.contentSize = CGSizeMake(JX_SCREEN_WIDTH *3, self.tableBody.frame.size.height);
    }else{
        self.tableBody.contentSize = CGSizeMake(JX_SCREEN_WIDTH *2, self.tableBody.frame.size.height);
    }
    
    self.tableBody.delegate = self;
    self.tableBody.pagingEnabled = YES;
    self.tableBody.showsHorizontalScrollIndicator = NO;
    self.tableBody.backgroundColor = HEXCOLOR(0xEFEFEF);
    
    [self.view addSubview:self.topSiftView];
    
    if(_isRoom){
        [self.tableBody addSubview:self.luckyView];
        [_luckyView.sendButton addTarget:self action:@selector(sendRedPacket:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.tableBody addSubview:self.nomalView];
    [self.tableBody addSubview:self.orderView];
    
    [_nomalView.sendButton addTarget:self action:@selector(sendRedPacket:) forControlEvents:UIControlEventTouchUpInside];
    [_orderView.sendButton addTarget:self action:@selector(sendRedPacket:) forControlEvents:UIControlEventTouchUpInside];
}


-(void)createHeaderView{
    int heightHeader = JX_SCREEN_TOP;
    
    UIView *  tableHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, heightHeader)];
    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, heightHeader)];
    iv.image = [[UIImage imageNamed:@"navBarBackground"] imageWithTintColor:HEXCOLOR(0xFA585E)];
    iv.userInteractionEnabled = YES;
    [tableHeader addSubview:iv];
    
    JXLabel* p = [[JXLabel alloc]initWithFrame:CGRectMake(60, JX_SCREEN_TOP -15- 17, JX_SCREEN_WIDTH-60*2, 20)];
    p.center = CGPointMake(tableHeader.center.x, p.center.y);
    p.backgroundColor = [UIColor clearColor];
    p.textAlignment   = NSTextAlignmentCenter;
    p.textColor       = [UIColor whiteColor];
    p.font = [UIFont systemFontOfSize:18.0];
    p.text = Localized(@"JX_SendGift");
    p.userInteractionEnabled = YES;
    p.didTouch = @selector(actionTitle:);
    p.delegate = self;
    p.changeAlpha = NO;
    [tableHeader addSubview:p];
        
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP - 46, 46, 46)];
    [btn setBackgroundImage:[[UIImage imageNamed:@"title_back_black_big"] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
    [tableHeader addSubview:btn];

    
    [self.view addSubview:tableHeader];
}



-(JXRedInputView *)luckyView{
    if (!_luckyView) {
        _luckyView = [[JXRedInputView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP+50, JX_SCREEN_WIDTH, self.tableBody.contentSize.height-JX_SCREEN_TOP-50) type:2 isRoom:_isRoom delegate:self];
    }
    return _luckyView;
}
-(JXRedInputView *)nomalView{
    if (!_nomalView) {
        _nomalView = [[JXRedInputView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_luckyView.frame), JX_SCREEN_TOP+50, JX_SCREEN_WIDTH, self.tableBody.contentSize.height-JX_SCREEN_TOP-50) type:1 isRoom:_isRoom delegate:self];
    }
    return _nomalView;
}
-(JXRedInputView *)orderView{
    if (!_orderView) {
        _orderView = [[JXRedInputView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_nomalView.frame), JX_SCREEN_TOP+50, JX_SCREEN_WIDTH, self.tableBody.contentSize.height-JX_SCREEN_TOP-50) type:3 isRoom:_isRoom delegate:self];
    }
    return _orderView;
}
-(JXTopSiftJobView *)topSiftView{
    if (!_topSiftView) {
        _topSiftView = [[JXTopSiftJobView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 50)];
        _topSiftView.delegate = self;
        _topSiftView.isShowMoreParaBtn = NO;
        _topSiftView.preferred = 0;
        _topSiftView.backgroundColor = HEXCOLOR(0xFA585E);
        _topSiftView.titleNormalColor = HEXCOLOR(0xFCB3B4);
        _topSiftView.titleSelectedColor = [UIColor whiteColor];
        _topSiftView.isShowBottomLine = NO;
        
        NSArray * itemsArray;
        if (_isRoom) {
            itemsArray = [[NSArray alloc] initWithObjects:Localized(@"JX_LuckGift"),Localized(@"JX_UsualGift"),Localized(@"JX_MesGift"), nil];
        }else{
            itemsArray = [[NSArray alloc] initWithObjects:Localized(@"JX_UsualGift"),Localized(@"JX_MesGift"), nil];
        }
        _topSiftView.dataArray = itemsArray;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 50 - LINE_WH, JX_SCREEN_WIDTH, LINE_WH)];
        line.backgroundColor = HEXCOLOR(0xFC1454);
        [_topSiftView addSubview:line];
    }
    return _topSiftView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)topItemBtnClick:(UIButton *)btn{
    [self checkAfterScroll:(btn.tag-100)];
}

- (void)checkAfterScroll:(CGFloat)offsetX{
    [self.tableBody setContentOffset:CGPointMake(offsetX*JX_SCREEN_WIDTH, 0) animated:YES];
    [self endEdit:nil];
}

-(void)endEdit:(UIGestureRecognizer *)ges{
    [_luckyView stopEdit];
    [_nomalView stopEdit];
    [_orderView stopEdit];
}

#pragma mark -------------ScrollDelegate----------------

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self endEdit:nil];
    int page = (int)(scrollView.contentOffset.x/JX_SCREEN_WIDTH);
    switch (page) {
        case 0:
            [_topSiftView resetItemBtnWith:0];
            [_topSiftView moveBottomSlideLine:0];
            break;
        case 1:
            [_topSiftView resetItemBtnWith:JX_SCREEN_WIDTH];
            [_topSiftView moveBottomSlideLine:JX_SCREEN_WIDTH];
            break;
        case 2:
            [_topSiftView resetItemBtnWith:JX_SCREEN_WIDTH*2];
            [_topSiftView moveBottomSlideLine:JX_SCREEN_WIDTH*2];
            break;
            
        default:
            break;
    }
}

-(void)sendRedPacket:(UIButton *)button{
    //1是普通红包，2是手气红包，3是口令红包
    if (button.tag == 1) {
        _moneyText = _nomalView.moneyTextField.text;
        _countText = _nomalView.countTextField.text;
        _greetText = _nomalView.greetTextField.text;
    }else if(button.tag == 2){
        _moneyText = _luckyView.moneyTextField.text;
        _countText = _luckyView.countTextField.text;
        _greetText = _luckyView.greetTextField.text;
    }else if(button.tag == 3){
        _moneyText = _orderView.moneyTextField.text;
        _countText = _orderView.countTextField.text;
        _greetText = _orderView.greetTextField.text;//口令
    }
    if (_moneyText == nil || [_moneyText isEqualToString:@""]) {
        [g_App showAlert:Localized(@"JX_InputGiftCount")];
        return;
    }
    
    if (!_isRoom) {
        _countText = @"1";
    }
    
    if (_isRoom && (_countText == nil|| [_countText isEqualToString:@""] || [_countText intValue] <= 0)) {
        [g_App showAlert:Localized(@"JXGiftForRoomVC_InputGiftCount")];
        return;
    }
    
    if (([_moneyText doubleValue]/[_countText intValue]) < 0.01) {
        [g_App showAlert:Localized(@"JXRedPaket_001")];
        return;
    }
//    if ([_moneyText doubleValue] > g_App.myMoney) {
//        [g_App showAlert:Localized(@"JX_NotEnough") delegate:self tag:2000 onlyConfirm:NO];
//        return;
//    }
    NSInteger money = 0;
    if (_isRoom) {
        money = 200*[_countText integerValue];
    }else{
        money = 200;
    }
    
    if (money >= [_moneyText floatValue]&&[_moneyText floatValue] > 0) {
        
        if (button.tag == 3) {
            if ([_greetText isEqualToString:@""]) {
                [g_App showAlert:Localized(@"JXGiftForRoomVC_InputGiftWord")];
                return;
            }
            
            _greetText = [_greetText stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([_greetText isEqualToString:@""]) {
                [JXMyTools showTipView:@"请输入有效口令"];
                return;
            }
            
        }

        if (button.tag == 1) {
            if ((int)([_moneyText floatValue] * 100) % [_countText integerValue] != 0) {
                [JXMyTools showTipView:@"普通红包需要均分金额"];
                return;
            }
        }

        //祝福语
        if ([_greetText isEqualToString:@""]) {
            _greetText = Localized(@"JX_GiftText");
        }
        self.indexInt = button.tag;
        if ([g_server.myself.isPayPassword boolValue]) {
            self.verVC = [JXVerifyPayVC alloc];
            self.verVC.type = JXVerifyTypeSendReadPacket;
            self.verVC.RMB = _moneyText;
            self.verVC.delegate = self;
            self.verVC.didDismissVC = @selector(dismissVerifyPayVC);
            self.verVC.didVerifyPay = @selector(didVerifyPay:);
            self.verVC = [self.verVC init];
            
            [self.view addSubview:self.verVC.view];
        } else {
            JXPayPasswordVC *payPswVC = [JXPayPasswordVC alloc];
            payPswVC.type = JXPayTypeSetupPassword;
            payPswVC.enterType = JXEnterTypeSendRedPacket;
            payPswVC = [payPswVC init];
            [g_navigation pushViewController:payPswVC animated:YES];
        }
    }else{
        NSString *str = [NSString stringWithFormat:@"请输入0~%ld元",(long)money];
        [g_App showAlert:str];
    }
    
}

- (void)didVerifyPay:(NSString *)sender {
    long time = (long)[[NSDate date] timeIntervalSince1970];
    time = (time *1000 + g_server.timeDifference)/1000;
    NSString *secret = [self getSecretWithText:sender time:time];
//    [g_server sendRedPacketV1:[_moneyText doubleValue] type:(int)self.indexInt count:[_countText intValue] greetings:_greetText roomJid:self.roomJid toUserId:self.toUserId time:time secret:secret toView:self];
    // 参数顺序不能变,先放key再放value
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"type",[NSString stringWithFormat:@"%ld",self.indexInt],@"moneyStr",_moneyText,@"count",_countText,@"greetings",_greetText, nil];
    
    if (self.roomJid.length > 0) {
//        [dict setObject:self.roomJid forKey:@"roomJid"];
        [arr addObject:@"roomJid"];
        [arr addObject:self.roomJid];
    }else {
//        [dict setObject:self.toUserId forKey:@"toUserId"];
        [arr addObject:@"toUserId"];
        [arr addObject:self.toUserId];
    }
    [g_payServer payServerWithAction:act_sendRedPacketV2 param:arr payPassword:sender time:time toView:self];
    
//    [g_server sendRedPacketV2:_moneyText type:(int)self.indexInt count:[_countText intValue] greetings:_greetText roomJid:self.roomJid toUserId:self.toUserId time:time secret:secret payPassword:sender toView:self];

}

- (void)dismissVerifyPayVC {
    [self.verVC.view removeFromSuperview];
}

//服务端返回数据
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if ([aDownload.action isEqualToString:act_getUserMoeny]) {
        g_App.myMoney = [dict[@"balance"] doubleValue];
        if (g_App.myMoney <= 0) {
            [g_App showAlert:Localized(@"JX_NotEnough") delegate:self tag:2000 onlyConfirm:NO];
        }
    }
    if ([aDownload.action isEqualToString:act_sendRedPacket] || [aDownload.action isEqualToString:act_sendRedPacketV2]) {
        NSMutableDictionary * muDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        [muDict setObject:_greetText forKey:@"greet"];
        [self dismissVerifyPayVC];  // 销毁支付密码界面
        //成功创建红包，发送一条含红包Id的消息
        if (_delegate && [_delegate respondsToSelector:@selector(sendRedPacketDelegate:)]) {
            [_delegate performSelector:@selector(sendRedPacketDelegate:) withObject:muDict];
        }
        [self actionQuit];
    }
}
-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    if ([aDownload.action isEqualToString:act_sendRedPacket] || [aDownload.action isEqualToString:act_sendRedPacketV2] || [aDownload.action isEqualToString:act_TransactionGetCode]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.verVC clearUpPassword];
        });
    }

    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return show_error;
}
-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
}

#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 2000){
        if (buttonIndex == 1) {
            [self rechargeButtonAction];
        }
    }
}
-(void)rechargeButtonAction{
    JXRechargeViewController * rechargeVC = [[JXRechargeViewController alloc]init];
    rechargeVC.rechargeDelegate = self;
    rechargeVC.isQuitAfterSuccess = YES;
//    [g_window addSubview:rechargeVC.view];
    [g_navigation pushViewController:rechargeVC animated:YES];
}

#pragma mark - RechargeDelegate
-(void)rechargeSuccessed{
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    JXRedInputView * inputView = (JXRedInputView *)textField.superview.superview;
    if (textField.returnKeyType == UIReturnKeyDone) {
        [inputView stopEdit];
    }
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@""]) {//删除
        return YES;
    }
    
    JXRedInputView * inputView = (JXRedInputView *)textField.superview.superview;
    if (textField == inputView.countTextField && [textField.text intValue] > 1000) {
        return NO;
    }
//    if (textField == inputView.moneyTextField) {
//        NSString * moneyStr = [textField.text stringByAppendingString:string];
//        if ([moneyStr floatValue] > 500.0f) {
//            return NO;
//        }
//    }

    if (textField == inputView.greetTextField && textField.text.length >= 20) {
        
        return NO;
    }
    
    if (textField == inputView.moneyTextField) {
        
        NSRange range = [textField.text rangeOfString:@"."];
        
        if (range.location != NSNotFound) {
            
            NSString *firstStr = [textField.text substringFromIndex:range.location + 1];
            if (firstStr.length > 1) {
                return NO;
            }
            
        }
    }
    
    if (textField == inputView.countTextField) {
        if ([textField.text rangeOfString:@"."].location != NSNotFound) {
            return NO;
        }
        NSMutableString *str = [NSMutableString string];
        [str appendString:textField.text];
        [str appendString:string];
        if ([str integerValue] > self.size) {
            textField.text = [NSString stringWithFormat:@"%ld", self.size];
            [JXMyTools showTipView:@"红包个数不能超过群人数"];
            return NO;
        }
    }

    return YES;
}

- (NSString *)getSecretWithText:(NSString *)text time:(long)time {
    NSMutableString *str1 = [NSMutableString string];
    [str1 appendString:APIKEY];
    [str1 appendString:[NSString stringWithFormat:@"%ld",time]];
    [str1 appendString:[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[_moneyText doubleValue]]]];
    str1 = [[g_server getMD5String:str1] mutableCopy];
    
    [str1 appendString:g_myself.userId];
    [str1 appendString:g_server.access_token];
    NSMutableString *str2 = [NSMutableString string];
    str2 = [[g_server getMD5String:text] mutableCopy];
    [str1 appendString:str2];
    str1 = [[g_server getMD5String:str1] mutableCopy];
    
    return [str1 copy];

}

@end
