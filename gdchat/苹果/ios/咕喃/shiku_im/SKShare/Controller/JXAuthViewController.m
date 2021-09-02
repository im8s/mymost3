//
//  JXAuthViewController.m
//  shiku_im
//
//  Created by p on 2018/11/2.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXAuthViewController.h"

@interface JXAuthViewController ()

@end

@implementation JXAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isGotoBack   = NO;
//    self.title = [NSString stringWithFormat:@"%@%@",APP_NAME,Localized(@"JX_Login")];
    self.heightFooter = 0;
    self.heightHeader = JX_SCREEN_TOP;
    
    [self createHeadAndFoot];
    
    JXImageView *icon = [[JXImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2-85/2, 81, 85, 85)];
    icon.image = [UIImage imageNamed:@"ALOGO_120"];
    [self.tableBody addSubview:icon];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(icon.frame) + 21, JX_SCREEN_WIDTH, 18)];
    label.font = [UIFont systemFontOfSize:18.0];
    label.textColor = HEXCOLOR(0x333333);
    label.text = [NSString stringWithFormat:@"%@",APP_NAME];
    label.textAlignment = NSTextAlignmentCenter;
    [self.tableBody addSubview:label];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(35, CGRectGetMaxY(label.frame)+50, JX_SCREEN_WIDTH-70, LINE_WH)];
    line.backgroundColor = THE_LINE_COLOR;
    [self.tableBody addSubview:line];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame) + 25, JX_SCREEN_WIDTH, 16)];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = HEXCOLOR(0x333333);
    label.text = Localized(@"JX_AfterLogin");
    label.textAlignment = NSTextAlignmentCenter;
    [self.tableBody addSubview:label];
    
    
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake((JX_SCREEN_WIDTH-13-6-246)/2,CGRectGetMaxY(label.frame) + 17,13,13);
    view.backgroundColor = HEXCOLOR(0xD8D8D8);
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = view.frame.size.width/2;
    [self.tableBody addSubview:view];

    label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(view.frame)+6, CGRectGetMaxY(label.frame) + 16, 246, 15)];
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = HEXCOLOR(0x999999);
    label.textAlignment = NSTextAlignmentCenter;
    label.text = Localized(@"JX_GetPublicInformation");
    [self.tableBody addSubview:label];
    
    UIButton *btn = [UIFactory createCommonButton:Localized(@"JX_ConfirmTheLogin") target:self action:@selector(loginBtnAction:)];
    btn.frame = CGRectMake(15, CGRectGetMaxY(label.frame) + 50, JX_SCREEN_WIDTH - 30, 40);
    [btn.titleLabel setFont:SYSFONT(16)];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 7.f;
    [self.tableBody addSubview:btn];
    
    //取消登录
    btn = [UIFactory createCommonButton:Localized(@"JX_CancelLogin") target:self action:@selector(quiteCurVC)];
    [btn setBackgroundImage:nil forState:UIControlStateHighlighted];
    [btn setBackgroundImage:nil forState:UIControlStateNormal];
    btn.custom_acceptEventInterval = 1.f;
    btn.frame = CGRectMake(JX_SCREEN_WIDTH/2-30,CGRectGetMaxY(label.frame) +50+40+ 32, 60, 30);
    [btn.titleLabel setFont:SYSFONT(14)];
    [btn setTitleColor:HEXCOLOR(0x999999) forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor clearColor];
    [self.tableBody addSubview:btn];

}

- (void)quiteCurVC {
    [self actionQuit];
}

- (void)loginBtnAction:(UIButton *)btn {
    
    if (self.isWebAuth) {
        
        [g_server openCodeAuthorCheckAppId:self.appId state:g_server.access_token callbackUrl:self.callbackUrl toView:self];
    }else {
     
        [g_server openOpenAuthInterfaceWithUserId:g_myself.userId appId:self.appId appSecret:self.appSecret type:1 toView:self];
    }
    
}
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    
    if([aDownload.action isEqualToString:act_OpenAuthInterface]){
        
        if ([dict[@"flag"] intValue] != 1) {
            
            [g_App showAlert:Localized(@"JX_NoCertification")];
            
            return;
        }
        
        NSString* s = g_server.myself.userId;
        
        if([s length]<=0)
            return;

        NSString* dir  = [NSString stringWithFormat:@"%d",[s intValue] % 10000];
        NSString* url  = [NSString stringWithFormat:@"%@avatar/t/%@/%@.jpg",g_config.downloadAvatarUrl,dir,s];
        //djkmmm
        
        NSString *str = [NSString stringWithFormat:@"%@://type=%@,userId=%@,nickName=%@,avatarUrl=%@,birthday=%@,sex=%@",self.urlSchemes,@"Auth",dict[@"userId"],g_myself.userNickname,url,[NSString stringWithFormat:@"%@",g_myself.birthday],[NSString stringWithFormat:@"%@",g_myself.sex]];

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] options:nil completionHandler:^(BOOL success) {
        }];
        
        [self actionQuit];
    }
    
    
    if ([aDownload.action isEqualToString:act_openCodeAuthorCheck]) {
        NSString *callbackUrl = [dict objectForKey:@"callbackUrl"];
        callbackUrl = [callbackUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString *url;
        if ([callbackUrl rangeOfString:@"?"].location != NSNotFound) {
            url = [NSString stringWithFormat:@"%@&code=%@",callbackUrl,[dict objectForKey:@"code"]];
        }else {
            url = [NSString stringWithFormat:@"%@?code=%@",callbackUrl,[dict objectForKey:@"code"]];
        }
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        
        [self actionQuit];
    }
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
}
- (void)actionQuit {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
