//
//  JXMyWalletVC.m
//  shiku_im
//
//  Created by 1 on 2019/11/12.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXMyWalletVC.h"
#import "JXIdCardVC.h"
#import "JXMyMoneyViewController.h"

#define HEIGHT 55

@interface JXMyWalletVC ()

@end

@implementation JXMyWalletVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = Localized(@"JX_Wallet");
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    
    self.isGotoBack = YES;
    [self createHeadAndFoot];
    

    self.tableBody.backgroundColor = HEXCOLOR(0xF2F2F2);
    
    CGFloat h = 0;
    CGFloat inset = 8;

    JXImageView* iv;

    iv = [self createButton:Localized(@"JX_MyBalance") drawTop:NO drawBottom:NO icon:@"wallet_change_icon" click:@selector(onRecharge)];
    iv.frame = CGRectMake(0,0, JX_SCREEN_WIDTH, HEIGHT);
    
    h+=iv.frame.size.height+inset;
    iv = [self createButton:Localized(@"JX_MyCloudWallet") drawTop:NO drawBottom:YES icon:@"wallet_cloud_icon" click:@selector(onCloudWallet)];
    iv.frame = CGRectMake(0,h, JX_SCREEN_WIDTH, HEIGHT);
    
    h+=iv.frame.size.height;
    iv = [self createButton:Localized(@"JX_BankCard") drawTop:NO drawBottom:NO icon:@"wallet_bank_card" click:@selector(onBankCard)];
    iv.frame = CGRectMake(0,h, JX_SCREEN_WIDTH, HEIGHT);
}

- (void)onRecharge {
    JXMyMoneyViewController * moneyVC = [[JXMyMoneyViewController alloc] init];
    [g_navigation pushViewController:moneyVC animated:YES];
}

- (void)onCloudWallet {
    if ([g_server.myself.walletUserNo boolValue]) {
        // 已开户
        JXMyMoneyViewController * moneyVC = [[JXMyMoneyViewController alloc] init];
        moneyVC.isCloud = YES;
        [g_navigation pushViewController:moneyVC animated:YES];
    }else {
        // 未开户
        JXIdCardVC *vc = [[JXIdCardVC alloc] init];
        [g_navigation pushViewController:vc animated:YES];
    }

}

- (void)onBankCard {
    [g_server queryCard:self];
}

- (void)didServerResultSucces:(JXConnection *)aDownload dict:(NSDictionary *)dict array:(NSArray *)array1{
    [_wait stop];
    if ([aDownload.action isEqualToString:act_queryCard]) {
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



-(JXImageView*)createButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom icon:(NSString*)icon click:(SEL)click{
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.delegate = self;
    [self.tableBody addSubview:btn];
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(53, 0, self_width-35-20-5, HEIGHT)];
    p.text = title;
    p.font = g_factory.font16;
    p.backgroundColor = [UIColor clearColor];
    p.textColor = HEXCOLOR(0x323232);
    [btn addSubview:p];
    
    if(icon){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(15, (HEIGHT-23)/2, 23, 23)];
        iv.image = [UIImage imageNamed:icon];
        [btn addSubview:iv];
    }
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(53,0,JX_SCREEN_WIDTH-53,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(53,HEIGHT-0.3,JX_SCREEN_WIDTH-53,LINE_WH)];
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
