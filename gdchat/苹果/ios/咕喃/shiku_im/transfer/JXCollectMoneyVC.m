//
//  JXCollectMoneyVC.m
//  shiku_im
//
//  Created by 1 on 2019/3/6.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXCollectMoneyVC.h"
#import "QRImage.h"
#import "JXInputMoneyVC.h"

@interface JXCollectMoneyVC ()
@property (nonatomic, strong) NSString *money;
@property (nonatomic, strong) NSString *desStr;
@property (nonatomic, strong) UIImageView *getQrCode;
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rigLabel;
@property (nonatomic, strong) UIView *baseView;

@property (nonatomic, strong) UILabel *moneyLab;
@property (nonatomic, strong) UILabel *descLab;
@property (nonatomic, strong) UILabel *barCodeLab;

@end

@implementation JXCollectMoneyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.heightHeader = 0;
    self.heightFooter = 0;
    [self createHeadAndFoot];
    [self setupViews];
    [self setupNav];
    
    [g_notify addObserver:self selector:@selector(notifyPaymentGet:) name:kXMPPMessageQrPaymentNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)notifyPaymentGet:(NSNotification *)noti {
    JXMessageObject *msg = noti.object;
    if ([msg.type intValue] == kWCMessageTypeReceiptGet) {
        [g_server showMsg:Localized(@"JX_PaymentReceived")];
        [self updateQr];
    }
}

- (void)setupNav {
    UIView *nav = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_TOP)];
//    nav.backgroundColor = HEXCOLOR(0x449ad4);
    [self.view addSubview:nav];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(8, JX_SCREEN_TOP - 38, 31, 31)];
    [btn setBackgroundImage:[UIImage imageNamed:@"title_back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
    [nav addSubview:btn];
    
    UILabel *p = [[UILabel alloc]initWithFrame:CGRectMake(40, JX_SCREEN_TOP - 32, JX_SCREEN_WIDTH-40*2, 20)];
    p.backgroundColor = [UIColor clearColor];
    p.textAlignment   = NSTextAlignmentCenter;
    p.textColor       = [UIColor whiteColor];
    p.text = Localized(@"JX_QrCodeCollection");
    [nav addSubview:p];
}

- (void)setupViews {
//    self.tableBody.backgroundColor = HEXCOLOR(0x449ad4);
    [self setupView:self.view colors:@[(__bridge id)HEXCOLOR(0x449ad4).CGColor,(__bridge id)HEXCOLOR(0x1953AF).CGColor]];

    
    _baseView = [[UIView alloc] initWithFrame:CGRectMake(20, JX_SCREEN_TOP+20, JX_SCREEN_WIDTH-40, JX_SCREEN_WIDTH-40)];
    _baseView.backgroundColor = [UIColor whiteColor];
    _baseView.layer.masksToBounds = YES;
    _baseView.layer.cornerRadius = 3.f;
    [self.view addSubview:_baseView];
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
    img.image = [UIImage imageNamed:@"pay_wallet_blue"];
    [_baseView addSubview:img];
    
    UILabel *payLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(img.frame)+10, 13, 100, 18)];
    payLabel.text = Localized(@"JX_QrCodeCollection");
    payLabel.textColor = HEXCOLOR(0x449ad4);
    [_baseView addSubview:payLabel];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(payLabel.frame)+13, _baseView.frame.size.width, LINE_WH)];
    line.backgroundColor = THE_LINE_COLOR;
    [_baseView addSubview:line];
    
    _barCodeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame)+30, _baseView.frame.size.width, 15)];
    _barCodeLab.text = Localized(@"JX_ScanQrCodeToPayMe");
    _barCodeLab.textColor = [UIColor lightGrayColor];
    _barCodeLab.font = SYSFONT(14);
    _barCodeLab.textAlignment = NSTextAlignmentCenter;
    [_baseView addSubview:_barCodeLab];
    
    //金额
    _moneyLab = [[UILabel alloc] init];
    _moneyLab.font = SYSFONT(20);
    _moneyLab.textAlignment = NSTextAlignmentCenter;
    [_baseView addSubview:_moneyLab];
    //说明
    _descLab = [[UILabel alloc] init];
    _descLab.font = SYSFONT(14);
    _descLab.textColor = [UIColor lightGrayColor];
    _descLab.textAlignment = NSTextAlignmentCenter;
    [_baseView addSubview:_descLab];

    // 二维码
    _getQrCode = [[UIImageView alloc] init];
    [_baseView addSubview:_getQrCode];
    
    // 设置金额
    _leftLabel = [[UILabel alloc] init];
    _leftLabel.font = SYSFONT(14);
    _leftLabel.textColor = HEXCOLOR(0x383893);
    _leftLabel.userInteractionEnabled = YES;
    _leftLabel.textAlignment = NSTextAlignmentCenter;
    [_baseView addSubview:_leftLabel];
    UITapGestureRecognizer *tapL = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setMoneyCount)];
    [_leftLabel addGestureRecognizer:tapL];

    UIView *botLine = [[UIView alloc] initWithFrame:CGRectMake(_leftLabel.frame.size.width-LINE_WH, -5, LINE_WH, 25)];
    botLine.backgroundColor = THE_LINE_COLOR;
    [_leftLabel addSubview:botLine];
    
    // 保存收款码
    _rigLabel = [[UILabel alloc] init];
    _rigLabel.text = Localized(@"JX_SaveCollectionCode");
    _rigLabel.font = SYSFONT(14);
    _rigLabel.textColor = HEXCOLOR(0x383893);
    _rigLabel.userInteractionEnabled = YES;
    _rigLabel.textAlignment = NSTextAlignmentCenter;
    [_baseView addSubview:_rigLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveQr)];
    [_rigLabel addGestureRecognizer:tap];

    [self updateViews];
}

#pragma mark - 更新界面
- (void)updateViews {
    //金额
    CGSize mSize  = [self.money sizeWithAttributes:@{NSFontAttributeName:SYSFONT(20)}];
    _moneyLab.text = [NSString stringWithFormat:@"¥%.2f",[self.money doubleValue]];
    _moneyLab.frame = CGRectMake(0, CGRectGetMaxY(_barCodeLab.frame)+10, _baseView.frame.size.width, mSize.height);
    //说明
    CGSize dSize  = [self.desStr sizeWithAttributes:@{NSFontAttributeName:SYSFONT(14)}];
    _descLab.text = self.desStr;
    _descLab.frame = CGRectMake(0, CGRectGetMaxY(_moneyLab.frame)+10, _baseView.frame.size.width, dSize.height);
    //二维码
    _getQrCode.frame = CGRectMake((_baseView.frame.size.width - 140)/2, CGRectGetMaxY(_descLab.frame)+10, 140, 140);
    //设置金额
    _leftLabel.text = self.money.length > 0 ? Localized(@"JX_RemoveTheAmount") : Localized(@"JX_SetTheAmount");
    _leftLabel.frame = CGRectMake(0, CGRectGetMaxY(_getQrCode.frame)+30, _baseView.frame.size.width*0.5, 15);
    // 保存收款码
    _rigLabel.frame = CGRectMake(CGRectGetMaxX(_leftLabel.frame), _leftLabel.frame.origin.y, _baseView.frame.size.width*0.5, 15);
    
    _baseView.frame = CGRectMake(20, JX_SCREEN_TOP+20, JX_SCREEN_WIDTH-40, CGRectGetMaxY(_leftLabel.frame)+30);
    
    [self updateQr];

}

- (void)setMoneyCount {
    if (self.money.length > 0) {
        self.money = nil;
        self.desStr = nil;
        [self updateViews];
        return;
    }
    JXInputMoneyVC *inputVC = [[JXInputMoneyVC alloc] init];
    inputVC.type = JXInputMoneyTypeSetMoney;
    inputVC.delegate = self;
    inputVC.onInputMoney = @selector(onInputMoney:);
    [g_navigation pushViewController:inputVC animated:YES];
}

- (void)onInputMoney:(NSDictionary *)dict {
    if ([dict objectForKey:@"money"]) {
        self.money = [dict objectForKey:@"money"];
    }
    if ([dict objectForKey:@"desc"]) {
        self.desStr = [dict objectForKey:@"desc"];
    }
    [self updateViews];
}

#pragma mark - 保存二维码到相册
- (void)saveQr {
    UIImageWriteToSavedPhotosAlbum(self.getQrCode.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if(error){
        [g_server showMsg:Localized(@"ImageBrowser_saveFaild")];
    }else{
        [g_server showMsg:Localized(@"ImageBrowser_saveSuccess")];
    }
}


#pragma mark - 更新二维码
- (void)updateQr {
    UIImageView *imageView = [[UIImageView alloc] init];
    [g_server getHeadImageLarge:MY_USER_ID userName:MY_USER_NAME imageView:imageView getHeadHandler:nil];
    
    _getQrCode.image = [QRImage qrImageForString:[self getQrCodeStr] imageSize:_getQrCode.frame.size.width logoImage:imageView.image logoImageSize:30];
}

- (NSString *)getQrCodeStr {
    NSMutableDictionary *dict = @{@"userId":MY_USER_ID,@"userName":MY_USER_NAME}.mutableCopy;
    if (self.money.length > 0) {
        [dict addEntriesFromDictionary:@{@"money":self.money}];
    }
    if (self.desStr.length > 0) {
        [dict addEntriesFromDictionary:@{@"description":self.desStr}];
    }
    
    SBJsonWriter * OderJsonwriter = [SBJsonWriter new];
    NSString * jsonString = [OderJsonwriter stringWithObject:dict];

    
    return jsonString;
}


- (void)setupView:(UIView *)view colors:(NSArray *)colors {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, THE_DEVICE_HAVE_HEAD ? -44 : -20, JX_SCREEN_WIDTH, THE_DEVICE_HAVE_HEAD ? JX_SCREEN_HEIGHT+44 : JX_SCREEN_HEIGHT+20);  // 设置显示的frame
    gradientLayer.colors = colors;  // 设置渐变颜色
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    [view.layer addSublayer:gradientLayer];
}


@end
