//
//  JXWebLoginVC.m
//  shiku_im
//
//  Created by p on 2019/5/28.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXWebLoginVC.h"

@interface JXWebLoginVC ()

@end

@implementation JXWebLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.heightFooter = 0;
    self.heightHeader = JX_SCREEN_TOP;

//    self.title = Localized(@"JX_Login");
    self.isGotoBack = NO;
    
    [self createHeadAndFoot];
    self.tableBody.backgroundColor = [UIColor whiteColor];

    //icon
    UIImageView * kuliaoIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"web_icon"]];
    kuliaoIconView.frame = CGRectMake((JX_SCREEN_WIDTH-104)/2, 50, 104, 91);
    [self.tableBody addSubview:kuliaoIconView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(kuliaoIconView.frame) + 20, JX_SCREEN_WIDTH, 18)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"web %@",Localized(@"JX_LoginConfirmation")];
    label.font = [UIFont systemFontOfSize:18.0];
    label.textColor = HEXCOLOR(0x333333);
    [self.tableBody addSubview:label];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(35, CGRectGetMaxY(label.frame)+50, JX_SCREEN_WIDTH-70, LINE_WH)];
    line.backgroundColor = THE_LINE_COLOR;
    [self.tableBody addSubview:line];

    
    label = [[UILabel alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(line.frame) + 37, 130, 16)];
    label.text = g_myself.userNickname;
    label.font = [UIFont systemFontOfSize:16.0];
    label.textColor = HEXCOLOR(0x333333);
    [self.tableBody addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(label.frame) + 20, 130, 14)];
    label.text = g_myself.telephone;
    label.font = [UIFont systemFontOfSize:14.0];
    label.textColor = HEXCOLOR(0x999999);
    [self.tableBody addSubview:label];
    
    UIImageView *userIcon = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 62-50, CGRectGetMaxY(line.frame) + 37, 50, 50)];
    userIcon.layer.cornerRadius = 50 / 2;
    userIcon.layer.masksToBounds = YES;
    [g_server getHeadImageLarge:g_myself.userId userName:g_myself.userNickname imageView:userIcon getHeadHandler:nil];
    [self.tableBody addSubview:userIcon];
    
    
    UIButton *btn = [UIFactory createCommonButton:Localized(@"JX_ConfirmTheLogin") target:self action:@selector(onLogin)];
//    [btn setBackgroundImage:nil forState:UIControlStateHighlighted];
    [btn setBackgroundImage:nil forState:UIControlStateNormal];
    btn.custom_acceptEventInterval = 1.f;
    btn.frame = CGRectMake(15,CGRectGetMaxY(label.frame) + 37, JX_SCREEN_WIDTH-30, 40);
    [btn.titleLabel setFont:SYSFONT(16)];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 7.f;
    btn.backgroundColor = THEMECOLOR;
    [self.tableBody addSubview:btn];
    
    //取消登录
    btn = [UIFactory createCommonButton:Localized(@"JX_CancelLogin") target:self action:@selector(quiteCurVC)];
    [btn setBackgroundImage:nil forState:UIControlStateHighlighted];
    [btn setBackgroundImage:nil forState:UIControlStateNormal];
    btn.custom_acceptEventInterval = 1.f;
    btn.frame = CGRectMake(JX_SCREEN_WIDTH/2-30,CGRectGetMaxY(label.frame) +37+40+ 32, 60, 30);
    [btn.titleLabel setFont:SYSFONT(14)];
    [btn setTitleColor:HEXCOLOR(0x999999) forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor clearColor];
    [self.tableBody addSubview:btn];

}

- (void)actionQuit {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)quiteCurVC {
    [super actionQuit];
}

- (void)onLogin {
    
    if (self.isQRLogin) {
        if ([self.delegate respondsToSelector:@selector(webLoginSuccess)]) {
            [self.delegate webLoginSuccess];
            [super actionQuit];
        }
    }else {
        NSString *url = [NSString stringWithFormat:@"%@?data=%@",self.callbackUrl,[self getData]];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSString *)getData {
    NSDictionary *dic = @{
                           @"accessToken" : g_server.access_token,
                           @"telephone" : g_myself.telephone,
                           @"password" : [g_default objectForKey:kMY_USER_PASSWORD]
                           };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *json =  [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *key = [g_server getMD5String:APIKEY];
    NSString *encrypted = [DESUtil encryptDESStr:json key:key];
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)encrypted,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return encodedString;
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
