//
//  JXMoneyMenuViewController.m
//  shiku_im
//
//  Created by 1 on 2018/9/18.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXMoneyMenuViewController.h"
#import "JXRecordCodeVC.h"
#import "JXRecordCloudCodeVC.h"
#import "JXPayPasswordVC.h"
#import "forgetPwdVC.h"


#define HEIGHT 56

@interface JXMoneyMenuViewController ()<forgetPwdVCDelegate>

@end

@implementation JXMoneyMenuViewController


- (instancetype)init {
    self = [super init];
    if (self) {
        //        self.tableBody.backgroundColor = HEXCOLOR(0xf0eff4);
        
        
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localized(@"JX_PayCenter");
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack = YES;
    [self createHeadAndFoot];
    
    int h=0;
    int w=JX_SCREEN_WIDTH;
    JXImageView* iv;
    
    if (self.isCloud) {
        iv = [self createButton:Localized(@"JX_Bill") drawTop:NO drawBottom:YES click:@selector(onBill)];
        iv.frame = CGRectMake(0,h, w, HEIGHT);
        h+=iv.frame.size.height;
        
        iv = [self createButton:Localized(@"JX_BindBankCard") drawTop:NO drawBottom:YES click:@selector(onBindBankCard)];
        iv.frame = CGRectMake(0,h, w, HEIGHT);
        h+=iv.frame.size.height;
        
        iv = [self createButton:Localized(@"JX_SecuritySettings") drawTop:NO drawBottom:YES  click:@selector(onSecuritySettings)];
        iv.frame = CGRectMake(0,h, w, HEIGHT);
        h+=iv.frame.size.height;
    }else {
        iv = [self createButton:Localized(@"JX_Bill") drawTop:NO drawBottom:YES click:@selector(onBill)];
        iv.frame = CGRectMake(0,h, w, HEIGHT);
        h+=iv.frame.size.height;
        
        iv = [self createButton:Localized(@"JX_SetPayPsw") drawTop:NO drawBottom:YES  click:@selector(onPayThePassword)];
        iv.frame = CGRectMake(0,h, w, HEIGHT);
        h+=iv.frame.size.height;
        
        iv = [self createButton:Localized(@"JX_ForgottenPassword") drawTop:NO drawBottom:NO  click:@selector(onForgetPassWord)];
        iv.frame = CGRectMake(0,h, w, HEIGHT);
        h+=iv.frame.size.height;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)onBindBankCard {
    [g_server queryCard:self];
}

- (void)onSecuritySettings {
    [g_server managePassword:self];
}

- (void)onBill {
    if (self.isCloud) {
        JXRecordCloudCodeVC *vc = [[JXRecordCloudCodeVC alloc] init];
        vc.isCloud = YES;
        [g_navigation pushViewController:vc animated:YES];
    }else {
        JXRecordCodeVC * recordVC = [[JXRecordCodeVC alloc]init];
        recordVC.isCloud = NO;
        [g_navigation pushViewController:recordVC animated:YES];
    }
}


- (void)onPayThePassword {
    JXPayPasswordVC * PayVC = [JXPayPasswordVC alloc];
    if ([g_server.myself.isPayPassword boolValue]) {
        PayVC.type = JXPayTypeInputPassword;
    }else {
        PayVC.type = JXPayTypeSetupPassword;
    }
    PayVC.enterType = JXEnterTypeDefault;
    PayVC = [PayVC init];
    [g_navigation pushViewController:PayVC animated:YES];
}

- (void)onForgetPassWord {
    
    forgetPwdVC* vc = [[forgetPwdVC alloc] init];
    vc.delegate = self;
    vc.isPayPWD = YES;
    vc.isModify = NO;
    //    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)forgetPwdSuccess {
    g_server.myself.isPayPassword = nil;
    [self onPayThePassword];
}

- (void)didServerResultSucces:(JXConnection *)aDownload dict:(NSDictionary *)dict array:(NSArray *)array1{
    [_wait stop];
    if ([aDownload.action isEqualToString:act_queryCard] || [aDownload.action isEqualToString:act_managePassword]) {
        NSString *urlStr =[dict objectForKey:@"url"];
        
        webpageVC *webVC = [webpageVC alloc];
        webVC.isGotoBack= YES;
        webVC.url = urlStr;
        webVC.isCloud = YES;
        webVC = [webVC init];
        [g_navigation.navigationView addSubview:webVC.view];
        
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

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
}



-(JXImageView*)createButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom click:(SEL)click{
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.delegate = self;
    [self.tableBody addSubview:btn];
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(15, 0, self_width-15, HEIGHT)];
    p.text = title;
    p.font = g_factory.font17;
    p.backgroundColor = [UIColor clearColor];
    p.textColor = HEXCOLOR(0x323232);
    [btn addSubview:p];
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(15,0,JX_SCREEN_WIDTH-20,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(15,HEIGHT-LINE_WH,JX_SCREEN_WIDTH-15,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15-7, (HEIGHT-13)/2, 7, 13)];
        iv.image = [UIImage imageNamed:@"new_icon_>"];
        [btn addSubview:iv];
        
    }
    return btn;
}



@end
