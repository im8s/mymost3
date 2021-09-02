//
//  JXAccountBindingVC.m
//  shiku_im
//
//  Created by 1 on 2019/3/14.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXAccountBindingVC.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

#define HEIGHT 50
#define MY_INSET  0  // 每行左右间隙
#define TOP_ADD_HEIGHT  400  // 顶部添加的高度，防止下拉顶部空白

typedef NS_ENUM(NSInteger, JXBindType) {
    JXBindQQ = 1,          // QQ绑定
    JXBindWX,              // 微信绑定
};


@interface JXAccountBindingVC () <UIAlertViewDelegate,WXApiDelegate,WXApiManagerDelegate,TencentSessionDelegate,TencentLoginDelegate>
@property (nonatomic, strong) UIButton *wxBindStatus;
@property (nonatomic, strong) UIButton *qqBindStatus;

@property (nonatomic, retain)TencentOAuth *oauth;
@property (nonatomic, assign) JXBindType type;


@end

@implementation JXAccountBindingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localized(@"JX_AccountAndBindSettings");
    self.isGotoBack = YES;
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    [self createHeadAndFoot];
    [self getServerData];
    
    [self setupViews];
    // 微信登录回调
    [WXApiManager sharedManager].delegate = self;
    [g_notify addObserver:self selector:@selector(authRespNotification:) name:kWxSendAuthRespNotification object:nil];
}


- (void)getServerData {
    [g_server getBindInfo:self];
}

- (void)setupViews {
    self.tableBody.backgroundColor = HEXCOLOR(0xF2F2F2);
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, JX_SCREEN_WIDTH-20*2, 18)];
    title.text = Localized(@"JX_OtherLogin");
    title.font = [UIFont boldSystemFontOfSize:16];
    [self.tableBody addSubview:title];
    
    // 微信绑定
    JXImageView* wxIv = [self createButton:Localized(@"JX_WeChat") drawTop:YES drawBottom:YES icon:@"wechat_icon" click:@selector(bindWXAcount)];
    wxIv.frame = CGRectMake(MY_INSET,CGRectGetMaxY(title.frame)+20, JX_SCREEN_WIDTH, HEIGHT);
    
    self.wxBindStatus = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-20-100, 15, 100, 22)];
    [self.wxBindStatus setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.wxBindStatus.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.wxBindStatus.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.wxBindStatus setTitle:Localized(@"JX_Unbounded") forState:UIControlStateNormal];
    [self.wxBindStatus setTitle:Localized(@"JX_Binding") forState:UIControlStateSelected];
    self.wxBindStatus.userInteractionEnabled = NO;
    [wxIv addSubview:self.wxBindStatus];
    
    //QQ绑定
//    JXImageView* qqIv = [self createButton:@"QQ" drawTop:YES drawBottom:YES icon:@"qq_login" click:@selector(bindQQAcount)];
//    qqIv.frame = CGRectMake(MY_INSET,CGRectGetMaxY(wxIv.frame)+20, JX_SCREEN_WIDTH, HEIGHT);
//
//
//    self.qqBindStatus = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-20-100, 15, 100, 22)];
//    [self.qqBindStatus setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//    [self.qqBindStatus.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
//    [self.qqBindStatus.titleLabel setTextAlignment:NSTextAlignmentCenter];
//    [self.qqBindStatus setTitle:Localized(@"JX_Unbounded") forState:UIControlStateNormal];
//    [self.qqBindStatus setTitle:Localized(@"JX_Binding") forState:UIControlStateSelected];
//    self.qqBindStatus.userInteractionEnabled = NO;
//    [qqIv addSubview:self.qqBindStatus];

    [self updateBdindStatusFrame];
}

- (void)updateBdindStatusFrame {
    // 适配英文版本
    CGSize sizeUnbind = [Localized(@"JX_Unbounded") sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16]}];
    CGSize sizeBind = [Localized(@"JX_Binding") sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16]}];
    if (self.wxBindStatus.selected) {
        self.wxBindStatus.frame = CGRectMake(JX_SCREEN_WIDTH-20-sizeBind.width, self.wxBindStatus.frame.origin.y-1.5, sizeBind.width, self.wxBindStatus.frame.size.height);
    }else {
        self.wxBindStatus.frame = CGRectMake(JX_SCREEN_WIDTH-20-sizeUnbind.width, self.wxBindStatus.frame.origin.y-1.5, sizeUnbind.width, self.wxBindStatus.frame.size.height);
    }
    
//    if (self.qqBindStatus.selected) {
//        self.qqBindStatus.frame = CGRectMake(JX_SCREEN_WIDTH-20-sizeBind.width, self.qqBindStatus.frame.origin.y, sizeBind.width, self.qqBindStatus.frame.size.height);
//    }else {
//        self.qqBindStatus.frame = CGRectMake(JX_SCREEN_WIDTH-20-sizeUnbind.width, self.qqBindStatus.frame.origin.y, sizeUnbind.width, self.qqBindStatus.frame.size.height);
//    }

}

- (void)bindWXAcount {
    self.type = JXBindWX;
    if (self.wxBindStatus.selected) {
        [g_App showAlert:Localized(@"JX_UnbindWeChat?") delegate:self tag:1001 onlyConfirm:NO];
    }else {
        [g_App showAlert:Localized(@"JX_BindWeChat?") delegate:self tag:1002 onlyConfirm:NO];
    }
    
}

- (void)bindQQAcount {
    self.type = JXBindQQ;
    if (self.qqBindStatus.selected) {
        //是否确认解绑QQ
        [g_App showAlert:Localized(@"JX_WhetherToConfirmUnbindingQQ") delegate:self tag:1003 onlyConfirm:NO];
    }else {
        //是否确认绑定QQ
        [g_App showAlert:Localized(@"JX_WhetherToConfirmBindingQQ") delegate:self tag:1004 onlyConfirm:NO];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (alertView.tag == 1001) {
            [g_server setAccountUnbind:2 toView:self];
        }
        if (alertView.tag == 1002) {
            SendAuthReq* req = [[SendAuthReq alloc] init];
            req.scope = @"snsapi_userinfo"; // @"post_timeline,sns"
            req.state = @"login";
            req.openID = @"";
            
            [WXApi sendAuthReq:req
                viewController:self
                      delegate:[WXApiManager sharedManager]];
        }
        
        if (alertView.tag == 1003) {
            [g_server setAccountUnbind:1 toView:self];
        }
        if (alertView.tag == 1004) {
            NSString *appid = g_App.QQ_LOGIN_APPID;
            _oauth = [[TencentOAuth alloc] initWithAppId:appid
                                             andDelegate:self];
            
            _oauth.authMode = kAuthModeClientSideToken;
            [_oauth authorize:[self getPermissions] inSafari:NO];
        }

    }
}

- (void)authRespNotification:(NSNotification *)notif {
    SendAuthResp *response = notif.object;
    NSString *strMsg = [NSString stringWithFormat:@"Auth结果 code:%@,state:%@,errcode:%d", response.code, response.state, response.errCode];
    NSLog(@"-------%@",strMsg);
    [g_server getWxOpenId:response.code toView:self];
}
// QQ登录成功回调
- (void)tencentDidLogin {
    NSString *qqOpenId = _oauth.openId;
    g_server.openId = qqOpenId;
    
    if (qqOpenId.length > 0) {
        [self bindTel];
    }
}

- (NSMutableArray *)getPermissions {
    NSMutableArray * g_permissions = [[NSMutableArray alloc] initWithObjects:kOPEN_PERMISSION_GET_USER_INFO,
                                      kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                                      kOPEN_PERMISSION_ADD_ALBUM,
                                      kOPEN_PERMISSION_ADD_TOPIC,
                                      kOPEN_PERMISSION_CHECK_PAGE_FANS,
                                      kOPEN_PERMISSION_GET_INFO,
                                      kOPEN_PERMISSION_GET_OTHER_INFO,
                                      kOPEN_PERMISSION_LIST_ALBUM,
                                      kOPEN_PERMISSION_UPLOAD_PIC,
                                      kOPEN_PERMISSION_GET_VIP_INFO,
                                      kOPEN_PERMISSION_GET_VIP_RICH_INFO, nil];
    return g_permissions;
}

- (void)bindTel {
    JXUserObject *user = [[JXUserObject alloc] init];
    if ([g_default objectForKey:kMY_USER_PASSWORD]) {
        user.password = [g_default objectForKey:kMY_USER_PASSWORD];
    }
    NSString *areaCode = [g_default objectForKey:kMY_USER_AREACODE];
    user.areaCode = areaCode.length > 0 ? areaCode : @"86";
    if ([g_default objectForKey:kMY_USER_LoginName]) {
        user.telephone = [g_default objectForKey:kMY_USER_LoginName];
    }
    
    
    //        [g_server thirdLogin:user type:2 openId:g_server.openId isLogin:YES toView:self];
    [g_server userBindWXAccount:user type:self.type openId:g_server.openId isLogin:YES toView:self];

}


-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if([aDownload.action isEqualToString:act_unbind]){
        if (self.type == JXBindWX) {
            self.wxBindStatus.selected = NO;
        }else {
            self.qqBindStatus.selected = NO;
        }
        [g_server showMsg:Localized(@"JX_UnboundSuccessfully")];
        
        [self updateBdindStatusFrame];

    }
    if ([aDownload.action isEqualToString:act_UserBindWXAccount]) {
        g_server.openId = nil;
        if (self.type == JXBindWX) {
            self.wxBindStatus.selected = YES;
        }else {
            self.qqBindStatus.selected = YES;
        }
        [g_server showMsg:Localized(@"JX_BindingSuccessfully")];
        
        [self updateBdindStatusFrame];

    }
    if ([aDownload.action isEqualToString:act_GetWxOpenId]) {
        
        g_server.openId = [dict objectForKey:@"openid"];
        [self bindTel];
    }
    if( [aDownload.action isEqualToString:act_getBindInfo] ){
        if (array1.count > 0) {
            for (NSDictionary *dict in array1) {
                if ([[dict objectForKey:@"type"] intValue] == 2) {
                    //微信绑定
                    self.wxBindStatus.selected = YES;
                }
                if ([[dict objectForKey:@"type"] intValue] == 1) {
                    //QQ绑定
                    self.qqBindStatus.selected = YES;
                }
            }
        }
        [self updateBdindStatusFrame];

    }
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    if ([aDownload.action isEqualToString:act_UserBindWXAccount]) {
        g_server.openId = nil;
    }
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    if ([aDownload.action isEqualToString:act_UserBindWXAccount]) {
        g_server.openId = nil;
    }
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
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(20*2+20, 0, self_width-35-20-5, HEIGHT)];
    p.text = title;
    p.font = [UIFont boldSystemFontOfSize:16];
    p.backgroundColor = [UIColor clearColor];
    p.textColor = HEXCOLOR(0x323232);
    [btn addSubview:p];
    
    if(icon){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, (HEIGHT-20)/2, 21, 21)];
        iv.image = [UIImage imageNamed:icon];
        [btn addSubview:iv];
    }
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,HEIGHT-0.3,JX_SCREEN_WIDTH,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
//    if(click){
//        UIImageView* iv;
//        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3-MY_INSET, 16, 20, 20)];
//        iv.image = [UIImage imageNamed:@"set_list_next"];
//        [btn addSubview:iv];
//
//    }
    return btn;
}


@end
