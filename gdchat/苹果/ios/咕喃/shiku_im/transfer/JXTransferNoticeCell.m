//
//  JXTransferNoticeCell.m
//  shiku_im
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXTransferNoticeCell.h"
#import "JXTransferNoticeModel.h"
#import "JXTransferModel.h"
#import "JXTransferOpenPayModel.h"

@interface JXTransferNoticeCell ()
@property (nonatomic, strong) UIView *baseView;

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *moneyTit;
@property (nonatomic, strong) UILabel *moneyLab;
@property (nonatomic, strong) UILabel *payTit;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *noteTit;
@property (nonatomic, strong) UILabel *noteLab;


@property (nonatomic, strong) UILabel *backLab;
@property (nonatomic, strong) UILabel *backTime;
@property (nonatomic, strong) UILabel *sendLab;
@property (nonatomic, strong) UILabel *sendTime;

@end

@implementation JXTransferNoticeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        _baseView = [[UIView alloc] initWithFrame:CGRectMake(15, 15, JX_SCREEN_WIDTH-30, 200)];
        _baseView.backgroundColor = [UIColor whiteColor];
        _baseView.layer.masksToBounds = YES;
        _baseView.layer.cornerRadius = 7.f;
        [self.contentView addSubview:_baseView];
        
        _title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 200, 18)];
        _title.font = SYSFONT(16);
        [_baseView addSubview:_title];
        
        //收款金额
        _moneyTit = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_title.frame)+10, _baseView.frame.size.width, 18)];
        _moneyTit.textAlignment = NSTextAlignmentCenter;
        _moneyTit.textColor = HEXCOLOR(0x999999);
        [_baseView addSubview:_moneyTit];
        
        _moneyLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_moneyTit.frame)+10, _baseView.frame.size.width, 43)];
        _moneyLab.textAlignment = NSTextAlignmentCenter;
        _moneyLab.font = [UIFont boldSystemFontOfSize:40];
        [_baseView addSubview:_moneyLab];

        //第一行
        _payTit = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_moneyLab.frame)+20, 80, 18)];
        _payTit.textColor = HEXCOLOR(0x999999);
        _payTit.font = SYSFONT(16);
        [_baseView addSubview:_payTit];
        
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(95, _payTit.frame.origin.y, _baseView.frame.size.width-70, 18)];
        _nameLab.textColor = HEXCOLOR(0x999999);
        _nameLab.font = SYSFONT(16);
        [_baseView addSubview:_nameLab];
        
        //第二行
        _noteTit = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_payTit.frame)+10, 80, 18)];
        _noteTit.textColor = HEXCOLOR(0x999999);
        _noteTit.font = SYSFONT(16);
        [_baseView addSubview:_noteTit];
        
        _noteLab = [[UILabel alloc] initWithFrame:CGRectMake(95, _noteTit.frame.origin.y, _baseView.frame.size.width-70, 18)];
        _noteLab.textColor = HEXCOLOR(0x999999);
        _noteLab.font = SYSFONT(16);
        [_baseView addSubview:_noteLab];
        
        //第三行
        _backLab = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_noteTit.frame)+10, 80, 18)];
        _backLab.text = Localized(@"JX_ReturnTheTime");
        _backLab.textColor = HEXCOLOR(0x999999);
        _backLab.font = SYSFONT(16);
        [_baseView addSubview:_backLab];
        
        _backTime = [[UILabel alloc] initWithFrame:CGRectMake(95, _backLab.frame.origin.y, _baseView.frame.size.width-70, 18)];
        _backTime.textColor = HEXCOLOR(0x999999);
        _backTime.font = SYSFONT(16);
        [_baseView addSubview:_backTime];
        
        //第四行
        _sendLab = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_backLab.frame)+10, 80, 18)];
        _sendLab.text = Localized(@"JX_TransferTime");
        _sendLab.textColor = HEXCOLOR(0x999999);
        _sendLab.font = SYSFONT(16);
        [_baseView addSubview:_sendLab];
        
        _sendTime = [[UILabel alloc] initWithFrame:CGRectMake(95, _sendLab.frame.origin.y, _baseView.frame.size.width-70, 18)];
        _sendTime.textColor = HEXCOLOR(0x999999);
        _sendTime.font = SYSFONT(16);
        [_baseView addSubview:_sendTime];
    }
    return self;
}


- (void)setDataWithMsg:(JXMessageObject *)msg model:(id)tModel {
    if ([msg.type intValue] == kWCMessageTypeTransferBack) {
        JXTransferModel *model = (JXTransferModel *)tModel;
        _moneyTit.text = Localized(@"JX_Refunds");
        _payTit.text = Localized(@"JX_TheRefundWay");
        _nameLab.text = Localized(@"JX_ReturnedToTheChange");
        _noteTit.text = Localized(@"JX_ReturnReason");
        [self hideTime:0];
        _moneyLab.text = [NSString stringWithFormat:@"¥%.2f",model.money];
        _backTime.text = model.outTime;
        _sendTime.text = model.createTime;
        _baseView.frame = CGRectMake(10, 10, JX_SCREEN_WIDTH-20, 200+56);
    }
    else if ([msg.type intValue] == kWCMessageTypeOpenPaySuccess) {
        JXTransferOpenPayModel *model = (JXTransferOpenPayModel *)tModel;
        _noteTit.text = Localized(@"JX_Note");
        _payTit.text = Localized(@"JX_Payee");
        _nameLab.text = model.name;;
        [self hideTime:YES];
        _moneyLab.text = [NSString stringWithFormat:@"¥%.2f",model.money];
        _baseView.frame = CGRectMake(10, 10, JX_SCREEN_WIDTH-20, 200);
    }
    
    else if ([msg.type intValue] == kWCMessageTypeManualPayRecharge) {
        
        JXTransferNoticeModel *model = (JXTransferNoticeModel *)tModel;
        _noteTit.text = Localized(@"JX_Note");
        _moneyTit.text = Localized(@"JX_RechargeAmount");
        _moneyLab.text = [NSString stringWithFormat:@"¥%.2f",model.money];
        
        [self hideTime:1];
        _backLab.text = Localized(@"JX_RechargeTime");
        _backTime.text = model.createTime;
        _baseView.frame = CGRectMake(10, 10, JX_SCREEN_WIDTH-20, 200 + 28);
        
    }
    else if ([msg.type intValue] == kWCMessageTypeManualPayWithdraw) {
        
        JXTransferNoticeModel *model = (JXTransferNoticeModel *)tModel;
        _noteTit.text = Localized(@"JX_Note");
        _moneyTit.text = Localized(@"JXMoney_withDAmount");
        _moneyLab.text = [NSString stringWithFormat:@"¥%.2f",model.money];
        
        _backLab.text = Localized(@"JX_WithdrawalTime");
        _backTime.text = model.createTime;
        [self hideTime:1];
        _baseView.frame = CGRectMake(10, 10, JX_SCREEN_WIDTH-20, 200 + 28);
    }
    else {
        JXTransferNoticeModel *model = (JXTransferNoticeModel *)tModel;
        _noteTit.text = Localized(@"JX_Note");
        // 我付款，对方收款（使用付款码付款）
        if (model.type == 1 && [model.userId intValue] == [MY_USER_ID intValue]) {
            _payTit.text = Localized(@"JX_Payee");
            _nameLab.text = model.toUserName;
            _moneyTit.text = Localized(@"JX_PaymentAmount");
            
            _backLab.text = Localized(@"JX_PaymentTime");
            _backTime.text = model.createTime;
            [self hideTime:1];
        }
        // 对方付款，我收款（使用付款码付款）
        else if (model.type == 1 && [model.userId intValue] != [MY_USER_ID intValue]) {
            _payTit.text = Localized(@"JX_Drawee");
            _nameLab.text = model.userName;
            _moneyTit.text = Localized(@"JX_GetMoney");
            
            _backLab.text = Localized(@"JX_ArrivedPaymentTime");
            _backTime.text = model.createTime;
            [self hideTime:1];
        }
        // 我收款，对方付款（使用收款码收款）
        else if (model.type == 2 && [model.userId intValue] == [MY_USER_ID intValue]) {
            _payTit.text = Localized(@"JX_Drawee");
            _nameLab.text = model.toUserName;
            _moneyTit.text = Localized(@"JX_GetMoney");
            
            _backLab.text = Localized(@"JX_ArrivedPaymentTime");
            _backTime.text = model.createTime;
            [self hideTime:1];
        }
        // 我付款，对方收款（使用收款码收款）
        else if (model.type == 2 && [model.userId intValue] != [MY_USER_ID intValue]){
            _payTit.text = Localized(@"JX_Payee");
            _nameLab.text = model.userName;
            _moneyTit.text = Localized(@"JX_PaymentAmount");
            
            _backLab.text = Localized(@"JX_PaymentTime");
            _backTime.text = model.createTime;
            [self hideTime:1];
        }
        
        _moneyLab.text = [NSString stringWithFormat:@"¥%.2f",model.money];
        _baseView.frame = CGRectMake(10, 10, JX_SCREEN_WIDTH-20, 200 + 28);
    }
    
    
    _title.text = [self getTitle:[msg.type intValue]];
    _noteLab.text = [self getNote:msg];
}

- (void)hideTime:(NSInteger )number {
    if (number == 0) {
        _backLab.hidden = NO;
        _backTime.hidden = NO;
        _sendLab.hidden = NO;
        _sendTime.hidden = NO;
    }else if (number == 1){
        _backLab.hidden = NO;
        _backTime.hidden = NO;
        _sendLab.hidden = YES;
        _sendTime.hidden = YES;
    }else{
        _backLab.hidden = YES;
        _backTime.hidden = YES;
        _sendLab.hidden = YES;
        _sendTime.hidden = YES;
    }
    
}


- (NSString *)getTitle:(int)type {
    
    NSString *string;
    // 过期退还
    if (type == kWCMessageTypeTransferBack) {
        string = Localized(@"JX_RefundNoticeOfOverdueTransfer");
    }
    // 支付通知
    else if (type == kWCMessageTypePaymentOut || type == kWCMessageTypeReceiptOut) {
        string = Localized(@"JX_PaymentNotice");
    }
    // 收款通知
    else if (type == kWCMessageTypePaymentGet || type == kWCMessageTypeReceiptGet) {
        string = Localized(@"JX_ReceiptNotice");
    }
    // 扫码充值审核通知
    else if (type == kWCMessageTypeManualPayRecharge) {
        string = Localized(@"JX_ScanCodeRechargeReviewNotice");
    }
    // 扫码提现审核通知
    else if (type == kWCMessageTypeManualPayWithdraw) {
        string = Localized(@"JX_ScanningCodeWithdrawalReviewNotice");
    }
    // 第三方调用IM支付
    if (type == kWCMessageTypeOpenPaySuccess) {
        string = Localized(@"JX_PaymentVoucher");
    }

    return string;
}

- (NSString *)getNote:(JXMessageObject *)msg {
    
     NSDictionary *dict = [self dictionaryWithJsonString:msg.content];
    
    NSString *string;
    // 过期退还
    if ([msg.type intValue] == kWCMessageTypeTransferBack) {
        string = Localized(@"JX_TransferIsOverdueAndTheChange");
    }
    // 支付通知
    else if ([msg.type intValue] == kWCMessageTypePaymentOut || [msg.type intValue] == kWCMessageTypeReceiptOut) {
        string = Localized(@"JX_PaymentToFriend");
    }
    // 收款通知
    else if ([msg.type intValue] == kWCMessageTypePaymentGet || [msg.type intValue] == kWCMessageTypeReceiptGet) {
        string = Localized(@"JX_PaymentReceived");
    }
    // 转账退款通知
    else if ([msg.type intValue] == kWCMessageTypeTransferBack) {
        string = [NSString stringWithFormat:@"%@%@",msg.toUserName,Localized(@"JX_NotReceive24Hours")];
    }
    
    else if ([msg.type intValue] == kWCMessageTypeManualPayRecharge) {
        if ([[dict objectForKey:@"status"] intValue] == 2) {
            //扫码充值审核通过
            string = Localized(@"JX_ScanCodeRechargeApproval");
        }else {
            //扫码充值审核被驳回
            string = Localized(@"JX_ScanCodeRechargeReviewWasRejected");
        }
    }
    
    else if ([msg.type intValue] == kWCMessageTypeManualPayWithdraw) {
        if ([[dict objectForKey:@"status"] intValue] == 2) {
            //扫码提现审核通过
            string = Localized(@"JX_ScanningCodeWithdrawalApproval");
        }else {
            //扫码提现审核被驳回
            string = Localized(@"JX_ScanCodeWithdrawalReviewRejected");
        }
    }
    
    // 第三方调用IM支付通知
    if ([msg.type intValue] == kWCMessageTypeOpenPaySuccess) {
        string = Localized(@"JX_PaymentToFriend");
    }
    
    return string;
}

+ (float)getChatCellHeight:(JXMessageObject *)msg {
    if ([msg.type intValue] == kWCMessageTypeTransferBack) {
        return 220+56;
    }else {
        return 220 + 28;
    }
    return 0;
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end
