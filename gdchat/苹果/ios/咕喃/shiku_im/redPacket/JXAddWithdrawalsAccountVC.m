//
//  JXAddWithdrawalsAccountVC.m
//  shiku_im
//
//  Created by p on 2019/12/10.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXAddWithdrawalsAccountVC.h"

#define ItemH 50
@interface JXAddWithdrawalsAccountVC ()

@property (nonatomic, strong) UITextField *aliName;    // 支付宝姓名
@property (nonatomic, strong) UITextField *aliAccount; // 支付宝账号
@property (nonatomic, strong) UITextField *cardName;    // 持卡人姓名
@property (nonatomic, strong) UITextField *cardAccount; // 持卡卡号
@property (nonatomic, strong) UITextField *bankName; // 银行名
@property (nonatomic, strong) UITextField *subBankName; // 支行名
@property (nonatomic, strong) UITextField *remark; // 备注

@end

@implementation JXAddWithdrawalsAccountVC

-(instancetype)init{
    if (self = [super init]) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    
    [self createHeadAndFoot];
    self.tableBody.backgroundColor = HEXCOLOR(0xF4F5FA);
    
    if (self.addType == AddType_Ali) {
        self.title = Localized(@"JX_AddAlipayAccount");
    }else {
        self.title = Localized(@"JX_AddBankCardAccount");
    }
    [self customView];
}

- (void)customView {
    
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(15, 20, JX_SCREEN_WIDTH - 30, 0)];
    baseView.backgroundColor = [UIColor whiteColor];
    baseView.layer.cornerRadius = 5.0;
    [self.tableBody addSubview:baseView];
    
    CGFloat viewY = 0;
    UIView *item;
    if (self.addType == AddType_Ali) {
        // 名字
        item = [self createItemWithType:0 name:Localized(@"JX_AlipayName") placeholder:Localized(@"JX_FirstName") isMust:YES isDrawTop:NO isDrawBottom:NO viewY:viewY parentView:baseView];
        viewY += ItemH;
        // 账号
        item = [self createItemWithType:1 name:Localized(@"JX_AlipayAccount") placeholder:Localized(@"JX_AccountNumber") isMust:YES isDrawTop:YES isDrawBottom:NO viewY:viewY parentView:baseView];
        if (self.data) {
            self.aliName.text = [self.data objectForKey:@"aliPayName"];
            self.aliAccount.text = [self.data objectForKey:@"aliPayAccount"];
        }
    }else {
        // 名字
        item = [self createItemWithType:2 name:Localized(@"JX_Cardholder'sName") placeholder:Localized(@"JX_FirstName") isMust:YES isDrawTop:NO isDrawBottom:NO viewY:viewY parentView:baseView];
        viewY += ItemH;
        // 账号
        item = [self createItemWithType:3 name:Localized(@"JX_CardholderCardNumber") placeholder:Localized(@"JX_AccountNumber") isMust:YES isDrawTop:YES isDrawBottom:NO viewY:viewY parentView:baseView];
        viewY += ItemH;
        // 银行名称
        item = [self createItemWithType:4 name:Localized(@"JX_BankName") placeholder:Localized(@"JX_Bank") isMust:YES isDrawTop:YES isDrawBottom:NO viewY:viewY parentView:baseView];
        viewY += ItemH;
        // 支行名称
        item = [self createItemWithType:5 name:Localized(@"JX_BranchName") placeholder:Localized(@"JX_Sub-branch") isMust:NO isDrawTop:YES isDrawBottom:NO viewY:viewY parentView:baseView];
        viewY += ItemH;
        // 备注
        item = [self createItemWithType:6 name:Localized(@"JX_RemarkInformation") placeholder:Localized(@"JX_Note") isMust:NO isDrawTop:YES isDrawBottom:NO viewY:viewY parentView:baseView];
        
        if (self.data) {
            self.cardName.text = [self.data objectForKey:@"cardName"];
            self.cardAccount.text = [self.data objectForKey:@"bankCardNo"];
            self.bankName.text = [self.data objectForKey:@"bankName"];
            self.subBankName.text = [self.data objectForKey:@"bankBranchName"];
            self.remark.text = [self.data objectForKey:@"desc"];
        }
    }
    
    baseView.frame = CGRectMake(baseView.frame.origin.x, baseView.frame.origin.y, baseView.frame.size.width, CGRectGetMaxY(item.frame));
    
    UIButton *bindBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(baseView.frame) + 20, JX_SCREEN_WIDTH - 30, 40)];
    [bindBtn setBackgroundImage:[UIImage createImageWithColor:THEMECOLOR] forState:UIControlStateNormal];
    UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
    [bindBtn setBackgroundImage:img forState:UIControlStateHighlighted];
    if (self.data) {
        [bindBtn setTitle:Localized(@"JX_Update") forState:UIControlStateNormal];
    }else {
        [bindBtn setTitle:Localized(@"JX_Bind") forState:UIControlStateNormal];
    }
    [bindBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    bindBtn.layer.cornerRadius = 5.0;
    bindBtn.layer.masksToBounds = YES;
    [bindBtn addTarget:self action:@selector(bindBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.tableBody addSubview:bindBtn];
}

- (void)bindBtnAction {
    NSString *type;
    if (self.addType == AddType_Ali) {
        type = @"1";
    }else {
        type = @"2";
    }
    [_wait start];
    
    if (self.data) {
        [g_server manualPayUpdateWithdrawAccountWithId:[self.data objectForKey:@"id"] aliPayName:self.aliName.text aliPayAccount:self.aliAccount.text cardName:self.cardName.text bankCardNo:self.cardAccount.text bankName:self.bankName.text bankBranchName:self.subBankName.text desc:self.remark.text toView:self];
    }else {
        [g_server manualPayAddWithdrawAccountWithType:type aliPayName:self.aliName.text aliPayAccount:self.aliAccount.text cardName:self.cardName.text bankCardNo:self.cardAccount.text bankName:self.bankName.text bankBranchName:self.subBankName.text desc:self.remark.text toView:self];
    }
}

- (UIView *)createItemWithType:(NSInteger)type name:(NSString *)name placeholder:(NSString *)placeholder isMust:(BOOL)isMust isDrawTop:(BOOL)isDrawTop isDrawBottom:(BOOL)isDrawBottom viewY:(CGFloat)viewY parentView:(UIView *)parentView {
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, parentView.frame.size.width, ItemH)];
    [parentView addSubview:view];
    //    [btn release];
    
    if(isMust){
        UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, 5, 20, ItemH-5)];
        p.text = @"*";
        p.font = g_factory.font18;
        p.backgroundColor = [UIColor clearColor];
        p.textColor = [UIColor redColor];
        p.textAlignment = NSTextAlignmentCenter;
        [view addSubview:p];
        //        [p release];
    }
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(28, 0, 80, ItemH)];
    p.text = name;
    p.font = g_factory.font15;
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    
    [view addSubview:p];
    //    [p release];
    
    if(isDrawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,view.frame.size.width,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [view addSubview:line];
        //        [line release];
    }
    
    if(isDrawBottom){
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,ItemH-0.5,view.frame.size.width,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [view addSubview:line];
        //        [line release];
    }
    
    UITextField *t = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(p.frame) + 10, 0, parentView.frame.size.width - CGRectGetMaxX(p.frame) - 10, ItemH)];
    t.placeholder = placeholder;
    t.font = g_factory.font15;
    [view addSubview:t];
    
    switch (type) {
        case 0:
            self.aliName = t;
            break;
        case 1:
            self.aliAccount = t;
            break;
        case 2:
            self.cardName = t;
            break;
        case 3:
            self.cardAccount = t;
            break;
        case 4:
            self.bankName = t;
            break;
        case 5:
            self.subBankName = t;
            break;
        case 6:
            self.remark = t;
            break;
            
        default:
            break;
    }
    
    return view;
}

- (void)didServerResultSucces:(JXConnection *)aDownload dict:(NSDictionary *)dict array:(NSArray *)array1{
        [_wait stop];
    if ([aDownload.action isEqualToString:act_ManualPayAddWithdrawAccount] || [aDownload.action isEqualToString:act_ManualPayUpdateWithdrawAccount]) {
        
        if ([self.delegate respondsToSelector:@selector(addWithdrawalsAccountBindSuccess)]) {
            [self.delegate addWithdrawalsAccountBindSuccess];
            [self actionQuit];
        }
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
