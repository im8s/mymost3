//
//  JXTransferDeatilVC.m
//  shiku_im
//
//  Created by 1 on 2019/3/2.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXTransferDeatilVC.h"
#import "JXTransferModel.h"
#import "JXMyMoneyViewController.h"

typedef NS_ENUM(NSInteger, JXTransferDeatilType) {
    JXTransferDeatilTypeMySend,        // 我发送的转账
    JXTransferDeatilTypeWait,          // 待确定收款
    JXTransferDeatilTypeComplete,      // 完成收款
    JXTransferDeatilTypeOverdue,       // 过期
};

@interface JXTransferDeatilVC () <UIAlertViewDelegate>

@property (nonatomic, assign) JXTransferDeatilType type;
@property (nonatomic, strong) JXTransferModel *model;
@property (nonatomic, strong) UIImageView *imgV;
@property (nonatomic, strong) UILabel *hintLab;
@property (nonatomic, strong) UILabel *moneyLabel;
@property (nonatomic, strong) UILabel *oneDayLabel;
@property (nonatomic, strong) UILabel *clickLab;
@property (nonatomic, strong) UIButton *completeBtn;

@property (nonatomic, strong) UILabel *transferTime;
@property (nonatomic, strong) UILabel *getTime;

@end

@implementation JXTransferDeatilVC

- (instancetype)init {
    if (self = [super init]) {
        self.heightHeader = 0;
        self.heightFooter = 0;
        [self createHeadAndFoot];
        self.model = [[JXTransferModel alloc] init];
        
        [self setupViews];
        
        [g_notify addObserver:self selector:@selector(transferReceive:) name:kXMPPMessageTransferReceiveNotification object:nil]; // 已领取转账
        [g_notify addObserver:self selector:@selector(transferBack:) name:kXMPPMessageTransferBackNotification object:nil]; // 转账过期
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getServerData];
}

- (void)setupViews {
    self.tableBody.backgroundColor = HEXCOLOR(0xF2F2F2);

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP - 46, 46, 46)];
    [btn setBackgroundImage:[UIImage imageNamed:@"title_back_black_big"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // 顶部图标
    _imgV = [[UIImageView alloc] init];
    [self.tableBody addSubview:_imgV];
    // 等待提示语
    _hintLab = [[UILabel alloc] init];
    _hintLab.font = SYSFONT(14);
    [self.tableBody addSubview:_hintLab];
    
    //金额
    _moneyLabel = [[UILabel alloc] init];
    _moneyLabel.font = SYSFONT(30);
    _moneyLabel.textAlignment = NSTextAlignmentCenter;
    [self.tableBody addSubview:_moneyLabel];

    _oneDayLabel = [[UILabel alloc] init];
    _oneDayLabel.textColor = [UIColor lightGrayColor];
    _oneDayLabel.font = SYSFONT(14);
    [self.tableBody addSubview:_oneDayLabel];
    
    _clickLab = [[UILabel alloc] init];
    _clickLab.font = SYSFONT(14);
    _clickLab.textColor = HEXCOLOR(0x383893);
    _clickLab.userInteractionEnabled = YES;
    [self.tableBody addSubview:_clickLab];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickLab)];
    [_clickLab addGestureRecognizer:tap];

    _completeBtn = [[UIButton alloc] init];
    _completeBtn.layer.masksToBounds = YES;
    _completeBtn.layer.cornerRadius = 3.f;
    [_completeBtn setTitle:Localized(@"JX_ConfirmReceipt") forState:UIControlStateNormal];
    [_completeBtn setBackgroundColor:HEXCOLOR(0x1aad19)];
    [_completeBtn addTarget:self action:@selector(clickCompleteBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.tableBody addSubview:_completeBtn];
    
    
    _transferTime = [[UILabel alloc] init];
    _transferTime.textColor = [UIColor lightGrayColor];
    _transferTime.font = SYSFONT(14);
    [self.tableBody addSubview:_transferTime];
    
    _getTime = [[UILabel alloc] init];
    _getTime.textColor = [UIColor lightGrayColor];
    _getTime.font = SYSFONT(14);
    [self.tableBody addSubview:_getTime];
}

- (void)updateViews {
    UIImage *image;
    NSString *hintStr;
    NSString *oneDayStr;
    NSString *clickLabStr;
    NSString *botTimeStr;
    NSString *botTime;
    if (self.type == JXTransferDeatilTypeMySend) {
        image = [UIImage imageNamed:@"ic_ts_status2"];
        hintStr = [NSString stringWithFormat:Localized(@"JX_ReceiptConfirmedBy%@"),self.model.userName];
        oneDayStr = Localized(@"JX_FriendNotConfirm1Day");
        clickLabStr = Localized(@"JX_ResendTransferMessage");
    }else if (self.type == JXTransferDeatilTypeWait) {
        image = [UIImage imageNamed:@"ic_ts_status2"];
        hintStr = Localized(@"JX_PaymentConfirmed");
        oneDayStr = Localized(@"JX_SelfNotConfirm1Day");
    }else if (self.type == JXTransferDeatilTypeComplete) {
        image = [UIImage imageNamed:@"ic_ts_status1"];
        clickLabStr = Localized(@"JX_LookAtTheChange");
        botTimeStr = Localized(@"JX_CollectMoneyTime");
        botTime = self.model.receiptTime;
    }else if (self.type == JXTransferDeatilTypeOverdue) {
        image = [UIImage imageNamed:@"ic_ts_status3"];
        hintStr = Localized(@"JX_Returned(expired)");
        botTimeStr = Localized(@"JX_ExpirationTime");
        oneDayStr = Localized(@"JX_TheChangeHasBeenRefunded");
        clickLabStr = Localized(@"JX_LookAtTheChange");
        botTime = self.model.outTime;
    }
    // 顶部图标
    _imgV.frame = CGRectMake((JX_SCREEN_WIDTH-40)/2, JX_SCREEN_TOP+20, 40, 40);
    _imgV.image = image;
    
    // 等待提示语
    CGSize size = [hintStr sizeWithAttributes:@{NSFontAttributeName:SYSFONT(14)}];
    _hintLab.frame = CGRectMake((JX_SCREEN_WIDTH-size.width)/2, CGRectGetMaxY(_imgV.frame)+20, size.width, size.height);
    _hintLab.text = hintStr;
    
    //金额
    _moneyLabel.frame = CGRectMake(0, CGRectGetMaxY(_hintLab.frame)+18, JX_SCREEN_WIDTH, 30);
    _moneyLabel.text = [NSString stringWithFormat:@"¥%.2f",self.model.money];
    
    // 1天内朋友未确认，将退还给你 ||  已退款到零钱，
    CGSize oneDaySize = [oneDayStr sizeWithAttributes:@{NSFontAttributeName:SYSFONT(14)}];
    CGSize clickLabSize = [clickLabStr sizeWithAttributes:@{NSFontAttributeName:SYSFONT(14)}];
    _oneDayLabel.frame = CGRectMake((JX_SCREEN_WIDTH-oneDaySize.width-clickLabSize.width)/2, CGRectGetMaxY(_moneyLabel.frame)+20, oneDaySize.width, oneDaySize.height);
    _oneDayLabel.text = oneDayStr;
    
    // 查看零钱 || 重发转账消息
    _clickLab.frame = CGRectMake(CGRectGetMaxX(_oneDayLabel.frame), _oneDayLabel.frame.origin.y, clickLabSize.width, clickLabSize.height);
    _clickLab.hidden = clickLabStr.length <= 0;
    _clickLab.text = clickLabStr;

    // 确认收款按钮
    _completeBtn.frame = CGRectMake(100, CGRectGetMaxY(_oneDayLabel.frame)+40, JX_SCREEN_WIDTH-100*2, 40);
    _completeBtn.hidden = self.type != JXTransferDeatilTypeWait;

    //转账时间
    NSString *tranStr = [NSString stringWithFormat:@"%@:%@",Localized(@"JX_TransferTime"),self.model.createTime];
    CGSize trSize = [tranStr sizeWithAttributes:@{NSFontAttributeName:SYSFONT(14)}];
    _transferTime.frame = CGRectMake((JX_SCREEN_WIDTH-trSize.width)/2, JX_SCREEN_HEIGHT-130, trSize.width, 20);
    _transferTime.text = tranStr;
    
    //收款 || 过期  时间
    NSString *getStr = [NSString stringWithFormat:@"%@:%@",botTimeStr,botTime];
    CGSize getSize = [getStr sizeWithAttributes:@{NSFontAttributeName:SYSFONT(14)}];
    _getTime.frame = CGRectMake(_transferTime.frame.origin.x, JX_SCREEN_HEIGHT-100, getSize.width, 20);
    _getTime.text = getStr;
    _getTime.hidden = self.type != JXTransferDeatilTypeComplete && self.type != JXTransferDeatilTypeOverdue;
}

- (void)clickCompleteBtn {
    if (self.model.isCloudTransfer) {
        [g_server yopPayReceiveTransfer:self.msg.objectId toView:self];
    }else {
        [g_server getTransfer:self.msg.objectId toView:self];
    }
}

- (void)onClickLab {
    if (self.type == JXTransferDeatilTypeComplete || self.type == JXTransferDeatilTypeOverdue) {
        JXMyMoneyViewController *moneyVC = [[JXMyMoneyViewController alloc] init];
        moneyVC.isCloud = self.model.isCloudTransfer;
        [g_navigation pushViewController:moneyVC animated:YES];
    }else if (self.type == JXTransferDeatilTypeMySend) {
        [g_App showAlert:Localized(@"JX_ResendTransferMessage") delegate:self];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        int time = (int)([[NSDate date] timeIntervalSince1970] - [self.msg.timeSend timeIntervalSince1970]) / 60 % 60;
        if (time >= 5) {            
            if (self.delegate && [self.delegate respondsToSelector:self.onResend]) {
                [self.delegate performSelectorOnMainThread:self.onResend withObject:self.msg waitUntilDone:NO];
                [self actionQuit];
            }
        }else {
            [g_App showAlert:[NSString stringWithFormat:Localized(@"JX_ Again%dMinutesLater"),5-time]];
        }
    }
}


- (void)transferReceive:(NSNotification *)noti {
//    JXMessageObject *msg = noti.object;
    // 收到收钱消息，获取当前时间并刷新界面
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", time];
    self.model.receiptTime = [self getTime:timeString];
    self.type = JXTransferDeatilTypeComplete;
    
    [self updateViews];
}

- (void)transferBack:(NSNotification *)noti {
    // 收到过期消息，获取当前时间并刷新界面
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", time];
    self.model.outTime = [self getTime:timeString];
    self.type = JXTransferDeatilTypeOverdue;
    
    [self updateViews];
}

- (void)getServerData {
    [g_server transferDetail:self.msg.objectId toView:self];
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if([aDownload.action isEqualToString:act_getTransferInfo]){
        [self.model getTransferDataWithDict:dict];
        if (self.model.status == 1) {
            if (self.model.userId == [[NSString stringWithFormat:@"%@",MY_USER_ID] longLongValue]) {
                self.type = JXTransferDeatilTypeMySend;
            }else {
                self.type = JXTransferDeatilTypeWait;
            }
        }
        else if (self.model.status == 2) {
            self.type = JXTransferDeatilTypeComplete;
            [g_notify postNotificationName:kUpdateTransferMsgFileSize object:[(NSDictionary *)dict[@"data"] objectForKey:@"id"]];
        }
        else if (self.model.status == -1) {
            self.type = JXTransferDeatilTypeOverdue;
            [g_notify postNotificationName:kUpdateTransferMsgFileSize object:[(NSDictionary *)dict[@"data"] objectForKey:@"id"]];
        }
        [self updateViews];
    }
    if([aDownload.action isEqualToString:act_receiveTransfer] || [aDownload.action isEqualToString:act_yopPayReceiveTransfer]){
        self.model.receiptTime = [self getTime:dict[@"time"]];
        self.type = JXTransferDeatilTypeComplete;
        
        [self updateViews];

        [g_notify postNotificationName:kUpdateTransferMsgFileSize object:dict[@"transferId"]];
    }

}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    
    if([aDownload.action isEqualToString:act_getTransferInfo]){
        
        if ([[dict objectForKey:@"resultCode"] intValue] == 100301 || [[dict objectForKey:@"resultCode"] intValue] == 100302) {
            NSDictionary *data = [dict objectForKey:@"data"];
            [self.model getTransferDataWithDict:data];
            if (self.model.status == 1) {
                if (self.model.userId == [[NSString stringWithFormat:@"%@",MY_USER_ID] longLongValue]) {
                    self.type = JXTransferDeatilTypeMySend;
                }else {
                    self.type = JXTransferDeatilTypeWait;
                }
            }
            else if (self.model.status == 2) {
                self.type = JXTransferDeatilTypeComplete;
                [g_notify postNotificationName:kUpdateTransferMsgFileSize object:[(NSDictionary *)dict[@"data"] objectForKey:@"id"]];
            }
            else if (self.model.status == -1) {
                self.type = JXTransferDeatilTypeOverdue;
                [g_notify postNotificationName:kUpdateTransferMsgFileSize object:[(NSDictionary *)dict[@"data"] objectForKey:@"id"]];
            }
            [self updateViews];
            
            
            return hide_error;
        }
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

// 时间戳转换时间
- (NSString *)getTime:(NSString *)time {
    NSTimeInterval interval    = [time doubleValue];
    NSDate *date               = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString*currentDateStr = [formatter stringFromDate: date];
    
    return currentDateStr;
}

@end
