//
//  JXShareManage.m
//  shiku_im
//
//  Created by p on 2018/11/1.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXShareManage.h"
#import "JXRelayVC.h"
#ifdef Meeting_Version
#import "JXAVCallViewController.h"
#endif
#import "JXSkPayVC.h"
#import "JXVerifyPayVC.h"
#import "JXPayPasswordVC.h"
#import "JXWebLoginVC.h"

@interface JXShareManage ()<JXSkPayVCDelegate>

@property (nonatomic, assign) BOOL isAuth;
@property (nonatomic, assign) BOOL isShare;
@property (nonatomic, assign) BOOL isMeet;
@property (nonatomic, assign) BOOL isSkPay;
@property (nonatomic, assign) BOOL isSkShare;
@property (nonatomic, assign) BOOL isWebLogin;
@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, strong) JXAuthViewController *authVC;
@property (nonatomic, strong) JXRelayVC *relayVC;
@property (nonatomic, strong) JXWebLoginVC *webLoginVC;

@property (nonatomic, assign) BOOL isWebAuth;
@property (nonatomic, strong) NSDictionary *orderDic;
@property (nonatomic, strong) JXVerifyPayVC * verVC;
@property (nonatomic, strong) NSDictionary *skPayDic;
@property (nonatomic, strong) NSDictionary *skShareDic;

@end

@implementation JXShareManage

+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static JXShareManage *instance;
    dispatch_once(&onceToken, ^{
        instance = [[JXShareManage alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if ([super init]) {
        
        [g_notify addObserver:self selector:@selector(systemLoginNotif:) name:kSystemLoginNotifaction object:nil];
        
        [g_notify addObserver:self selector:@selector(onXmppLoginChanged:) name:kXmppLoginNotifaction object:nil];
    }
    
    return self;
}

- (void)systemLoginNotif:(NSNotification *)notif {
    
    if (self.isAuth) {
        self.isAuth = NO;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NSString *urlSchemes = [self subString:self.urlStr withString:@"urlSchemes"];
            NSString *appId = [self subString:self.urlStr withString:@"appId"];
            NSString *appSecret = [self subString:self.urlStr withString:@"appSecret"];
            NSString *callbackUrl = [self subString:self.urlStr withString:@"callbackUrl"];
            
            callbackUrl = [callbackUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            self.authVC = [[JXAuthViewController alloc] init];
            self.authVC.urlSchemes = urlSchemes;
            self.authVC.appId = appId;
            self.authVC.isWebAuth = self.isWebAuth;
            self.authVC.callbackUrl = callbackUrl;
            self.authVC.appSecret = appSecret;
            UIViewController *lastVC = (UIViewController *)g_navigation.subViews.lastObject;
            self.authVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [lastVC presentViewController:self.authVC animated:YES completion:nil];
        });
    }else if (self.isShare){
        [g_server openOpenAuthInterfaceWithUserId:g_myself.userId appId:[self subString:self.urlStr withString:@"appId"] appSecret:[self subString:self.urlStr withString:@"appSecret"] type:2 toView:self];
    }
    if (self.isSkPay) {
        
        [g_server payGetOrderInfoWithAppId:[self.orderDic objectForKey:@"appId"] prepayId:[self.orderDic objectForKey:@"prepayId"] toView:self];
    }
    
    if (self.isWebLogin) {
        
        self.webLoginVC = [[JXWebLoginVC alloc] init];
        NSString *callbackUrl = [self subString:self.urlStr withString:@"callbackUrl"];
        self.webLoginVC.callbackUrl = callbackUrl;
        UIViewController *lastVC = (UIViewController *)g_navigation.subViews.lastObject;
        self.webLoginVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [lastVC presentViewController:self.webLoginVC animated:YES completion:nil];
    }
    
}

-(void)onXmppLoginChanged:(NSNumber*)isLogin{
    if([JXXMPP sharedInstance].isLogined == login_status_yes){

        if (self.isShare) {
            self.isShare = NO;
            
            NSString *shareType = [self subString:self.urlStr withString:@"shareType"];
            
            JXMessageObject *msg = [[JXMessageObject alloc] init];
            switch ([shareType integerValue]) {
                case 2:{
                    msg.type = [NSNumber numberWithInt:kWCMessageTypeText];
                    msg.content =  [self subString:self.urlStr withString:@"title"];
                }
                    break;
                case 1:{
                    
                    msg.type = [NSNumber numberWithInt:kWCMessageTypeImage];
                    msg.content =  [self subString:self.urlStr withString:@"imageUrl"];
                    
                    CGSize size = [UIImage getImageSizeWithURL:msg.content];
                    msg.location_x = @(size.width);
                    msg.location_y = @(size.height);
                }
                    break;
                default: {
                    
                    msg.type = [NSNumber numberWithInt:kWCMessageTypeShare];
                    msg.content = Localized(@"JX_[Link]");
                    NSDictionary *dict = @{
                                           @"url" : [self subString:self.urlStr withString:@"url"],
                                           @"downloadUrl" : [self subString:self.urlStr withString:@"downloadUrl"],
                                           @"title" : [self subString:self.urlStr withString:@"title"],
                                           @"subTitle" : [self subString:self.urlStr withString:@"subTitle"],
                                           @"imageUrl" : [self subString:self.urlStr withString:@"imageUrl"],
                                           @"appName" : [self subString:self.urlStr withString:@"appName"],
                                           @"appIcon" : [self subString:self.urlStr withString:@"appIcon"],
                                           @"urlSchemes" : [self subString:self.urlStr withString:@"urlSchemes"]
                                           };
                    
                    SBJsonWriter * OderJsonwriter = [SBJsonWriter new];
                    NSString * jsonString = [OderJsonwriter stringWithObject:dict];
                    
                    msg.objectId = jsonString;
                }
                    break;
            }
            
            self.relayVC = [[JXRelayVC alloc] init];
            self.relayVC.isShare = YES;
            self.relayVC.shareType = [shareType intValue];
            self.relayVC.shareSchemes = [self subString:self.urlStr withString:@"urlSchemes"];
            NSMutableArray *array = [NSMutableArray arrayWithObject:msg];
            self.relayVC.relayMsgArray = array;
            UIViewController *lastVC = (UIViewController *)g_navigation.subViews.lastObject;
            self.relayVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [lastVC presentViewController:self.relayVC animated:YES completion:nil];
        }
        
        
        // 网页拉起音视频会议
        if (self.isMeet) {
            self.isMeet = NO;
            NSString *type = [self subString:self.urlStr withString:@"type"];
            NSString *room = [self subString:self.urlStr withString:@"room"];
            int isAudio;
            if ([type isEqualToString:@"video"]) {
                isAudio = 1;
            }else{
                isAudio = 0;
            }
            [self startMeetWithIsAudio:isAudio roomNum:room];
        }
        
        // 网页分享
        if (self.isSkShare) {
            [self skShareAction];
        }
    }
}

- (void)startMeetWithIsAudio:(int)isAudio roomNum:(NSString *)roomNum {
    
#ifdef Meeting_Version
    JXAVCallViewController *avVC = [[JXAVCallViewController alloc] init];
    avVC.roomNum = roomNum;
    avVC.isAudio = isAudio;
    avVC.isGroup = YES;
//    avVC.toUserName = MY_USER_NAME;
    avVC.view.frame = [UIScreen mainScreen].bounds;
    [g_window addSubview:avVC.view];

#endif
    
}

// 第三方APP 跳转回调
-(BOOL) handleOpenURL:(NSURL *) url delegate:(id) delegate {
    
    [self.authVC dismissViewControllerAnimated:YES completion:nil];
    [self.relayVC dismissViewControllerAnimated:YES completion:nil];
    
    NSRange range = [[url absoluteString] rangeOfString:@"www.shikuios.com"];
    if (range.location != NSNotFound && range.length > 0) {
        self.urlStr = [url absoluteString];
    }else {
        NSString *urlStr = [url absoluteString];
        urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.urlStr = urlStr;
    }
    
    NSString *type = [self subString:self.urlStr withString:@"type"];
    
    
    // 网页拉起音视频会议
    NSRange meetRange = [self.urlStr rangeOfString:@"meet.youjob.co"];
    if (meetRange.location != NSNotFound && meetRange.length > 0) {
        
        if ([JXXMPP sharedInstance].isLogined == login_status_yes) {
            self.isMeet = NO;
            NSString *room = [self subString:self.urlStr withString:@"room"];
            int isAudio;
            if ([type isEqualToString:@"video"]) {
                isAudio = 1;
            }else{
                isAudio = 0;
            }
            [self startMeetWithIsAudio:isAudio roomNum:room];
            
            return YES;
        }else {
            
            self.isMeet = YES;
            return NO;
        }
    }
    
    
    // 网页支付
    NSRange skPayRange = [self.urlStr rangeOfString:@"skPay"];
    if (skPayRange.location != NSNotFound && skPayRange.length > 0) {
        
        self.orderDic = @{
                          @"appId" : [self subString:self.urlStr withString:@"appId"],
                          @"prepayId" : [self subString:self.urlStr withString:@"prepayId"],
                          @"sign" : [self subString:self.urlStr withString:@"sign"]
                          };
        
        if (!g_server.isLogin) {
            
            self.isSkPay = YES;
            return NO;
        }else {
            
            [g_server payGetOrderInfoWithAppId:[self.orderDic objectForKey:@"appId"] prepayId:[self.orderDic objectForKey:@"prepayId"] toView:self];
            return YES;
        }
    }
    
    // 网页分享
    NSRange skShareRange = [self.urlStr rangeOfString:@"skShare"];
    if (skShareRange.location != NSNotFound && skShareRange.length > 0) {
        
        self.skShareDic = @{
                          @"appId" : [self subString:self.urlStr withString:@"appId"],
                          @"appName" : [self subString:self.urlStr withString:@"appName"],
                          @"appIcon" : [self subString:self.urlStr withString:@"appIcon"],
                          @"title" : [self subString:self.urlStr withString:@"title"],
                          @"subTitle" : [self subString:self.urlStr withString:@"subTitle"],
                          @"url" : [self subString:self.urlStr withString:@"url"],
                          @"downloadUrl" : [self subString:self.urlStr withString:@"downloadUrl"],
                          @"imageUrl" : [self subString:self.urlStr withString:@"imageUrl"]
                          };
        
        if (g_xmpp.isLogined != login_status_yes) {
            
            self.isSkShare = YES;
            return NO;
        }else {
            [self skShareAction];
            return YES;
        }
    }
    
    
    // h5一键登录
    NSRange h5Range = [self.urlStr rangeOfString:@"H5login"];
    if (h5Range.location != NSNotFound && h5Range.length > 0) {
        
        if (g_server.isLogin) {
            
            self.webLoginVC = [[JXWebLoginVC alloc] init];
            NSString *callback = [self subString:self.urlStr withString:@"callback"];
            SBJsonParser *resultParser = [[SBJsonParser alloc] init] ;
            NSDictionary *resultObject = [resultParser objectWithString:callback];
            self.webLoginVC.callbackUrl = [resultObject objectForKey:@"callbackUrl"];
            UIViewController *lastVC = (UIViewController *)g_navigation.subViews.lastObject;
            self.webLoginVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [lastVC presentViewController:self.webLoginVC animated:YES completion:nil];
            
        }else {
            self.isWebLogin = YES;
        }
        
        return YES;
    }
    

    // 网页第三方认证
    range = [self.urlStr rangeOfString:@"www.shikuios.com"];
    if (range.location != NSNotFound && range.length > 0) {
        
        self.isWebAuth = YES;
        type = @"Auth";
    }else {
        self.isWebAuth = NO;
    }
    
    if (!type) {
        return NO;
    }
    if ([type isEqualToString:@"Auth"]) {
        
        if (!g_server.isLogin) {
            
            self.isAuth = YES;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (!g_server.isLogin) {
                
                self.isAuth = YES;
            }else {
                NSString *urlSchemes = [self subString:self.urlStr withString:@"urlSchemes"];
                NSString *appId = [self subString:self.urlStr withString:@"appId"];
                NSString *appSecret = [self subString:self.urlStr withString:@"appSecret"];
                NSString *callbackUrl = [self subString:self.urlStr withString:@"callbackUrl"];
                
                callbackUrl = [callbackUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

                
                self.authVC = [[JXAuthViewController alloc] init];
                self.authVC.urlSchemes = urlSchemes;
                self.authVC.appId = appId;
                self.authVC.isWebAuth = self.isWebAuth;
                self.authVC.callbackUrl = callbackUrl;
                self.authVC.appSecret = appSecret;
                UIViewController *lastVC = (UIViewController *)g_navigation.subViews.lastObject;
                self.authVC.modalPresentationStyle = UIModalPresentationFullScreen;
                [lastVC presentViewController:self.authVC animated:YES completion:nil];
            }
            
        });
        
    }else {
        if (g_server.isLogin) {
            [g_server openOpenAuthInterfaceWithUserId:g_myself.userId appId:[self subString:self.urlStr withString:@"appId"] appSecret:[self subString:self.urlStr withString:@"appSecret"] type:2 toView:self];
        }else {
            self.isShare = YES;
        }
        
    }
    return YES;
}

- (void)skShareAction {
    
    NSString *shareType = [self subString:self.urlStr withString:@"shareType"];
    
    JXMessageObject *msg = [[JXMessageObject alloc] init];
    switch ([shareType integerValue]) {
        case 2:{
            msg.type = [NSNumber numberWithInt:kWCMessageTypeText];
            msg.content =  [self subString:self.urlStr withString:@"title"];
        }
            break;
        case 1:{
            
            msg.type = [NSNumber numberWithInt:kWCMessageTypeImage];
            msg.content =  [self subString:self.urlStr withString:@"imageUrl"];
            
            CGSize size = [UIImage getImageSizeWithURL:msg.content];
            msg.location_x = @(size.width);
            msg.location_y = @(size.height);
        }
            break;
        default: {
            
            msg.type = [NSNumber numberWithInt:kWCMessageTypeShare];
            msg.content = Localized(@"JX_[Link]");
        
            SBJsonWriter * OderJsonwriter = [SBJsonWriter new];
            NSString * jsonString = [OderJsonwriter stringWithObject:self.skShareDic];
            
            msg.objectId = jsonString;
        }
            break;
    }
    
    self.relayVC = [[JXRelayVC alloc] init];
    self.relayVC.isShare = YES;
    self.relayVC.shareType = [shareType intValue];
    self.relayVC.shareSchemes = nil;
    NSMutableArray *array = [NSMutableArray arrayWithObject:msg];
    self.relayVC.relayMsgArray = array;
    UIViewController *lastVC = (UIViewController *)g_navigation.subViews.lastObject;
    self.relayVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [lastVC presentViewController:self.relayVC animated:YES completion:nil];
}

- (NSString *)subString:(NSString *)url withString:(NSString *)str {
    NSString *urlStr = [url copy];
    
    NSRange range = [urlStr rangeOfString:@"//"];
    urlStr = [urlStr substringFromIndex:range.location + range.length];
    
    range = [urlStr rangeOfString:[NSString stringWithFormat:@"%@=",str]];
    if (range.location == NSNotFound) {
        return nil;
    }
    urlStr = [urlStr substringFromIndex:range.location + range.length];
    
    range = [urlStr rangeOfString:@","];
    if (range.location != NSNotFound) {
        urlStr = [urlStr substringToIndex:range.location];
    }else {
        range = [urlStr rangeOfString:@"&"];
        if (range.location != NSNotFound) {
            urlStr = [urlStr substringToIndex:range.location];
        }
    }
    
    return urlStr;
}

- (void)skPayVC:(JXSkPayVC *)skPayVC payBtnAction:(NSDictionary *)payDic {
    if ([g_server.myself.isPayPassword boolValue]) {
        self.verVC = [JXVerifyPayVC alloc];
        self.verVC.type = JXVerifyTypeSkPay;
        self.verVC.RMB = [payDic objectForKey:@"money"];
        self.verVC.titleStr = [payDic objectForKey:@"desc"];
        self.verVC.delegate = self;
        self.verVC.didDismissVC = @selector(dismissVerifyPayVC);
        self.verVC.didVerifyPay = @selector(didVerifyPay:);
        self.verVC = [self.verVC init];
        
        UIViewController *lastVC = (UIViewController *)g_navigation.subViews.lastObject;
        [lastVC.view addSubview:self.verVC.view];
    } else {
        JXPayPasswordVC *payPswVC = [JXPayPasswordVC alloc];
        payPswVC.type = JXPayTypeSetupPassword;
        payPswVC.enterType = JXVerifyTypeSkPay;
        payPswVC = [payPswVC init];
        [g_navigation pushViewController:payPswVC animated:YES];
    }
}

- (void)didVerifyPay:(NSString *)sender {
    long time = (long)[[NSDate date] timeIntervalSince1970];
    time = (time *1000 + g_server.timeDifference)/1000;
    NSString *appId = [self.orderDic objectForKey:@"appId"];
    NSString *prepayId = [self.orderDic objectForKey:@"prepayId"];
    NSString *sign = [self.orderDic objectForKey:@"sign"];
    NSString *secret = [self getSecretWithPassword:sender time:time];
    // 参数顺序不能变,先放key再放value
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"appId",appId,@"prepayId",prepayId,@"sign",sign,@"money",self.skPayDic[@"money"], nil];
    
    [g_payServer payServerWithAction:act_PayPasswordPaymentV1 param:arr payPassword:sender time:time toView:self];
//    [g_server payPasswordPaymentWithAppId:appId prepayId:prepayId sign:sign time:[NSString stringWithFormat:@"%ld",time] secret:secret toView:self];
}

- (NSString *)getSecretWithPassword:(NSString *)password time:(long)time {
    NSMutableString *str1 = [NSMutableString string];
    [str1 appendString:g_myself.userId];
    [str1 appendString:g_server.access_token];
    
    NSMutableString *str2 = [NSMutableString string];
    [str2 appendString:APIKEY];
    [str2 appendString:[NSString stringWithFormat:@"%ld",time]];
    [str2 appendString:[g_server getMD5String:password]];
    str2 = [[g_server getMD5String:str2] mutableCopy];
    
    [str1 appendString:str2];
    str1 = [[g_server getMD5String:str1] mutableCopy];
    
    return [str1 copy];
}

- (void)dismissVerifyPayVC {
    [self.verVC.view removeFromSuperview];
}


-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    if([aDownload.action isEqualToString:act_OpenAuthInterface]){
        
        NSString *shareType = [self subString:self.urlStr withString:@"shareType"];
        
        JXMessageObject *msg = [[JXMessageObject alloc] init];
        switch ([shareType integerValue]) {
            case 2:{
                msg.type = [NSNumber numberWithInt:kWCMessageTypeText];
                msg.content =  [self subString:self.urlStr withString:@"title"];
            }
                break;
            case 1:{
                
                msg.type = [NSNumber numberWithInt:kWCMessageTypeImage];
                msg.content =  [self subString:self.urlStr withString:@"imageUrl"];
                
                CGSize size = [UIImage getImageSizeWithURL:msg.content];
                msg.location_x = @(size.width);
                msg.location_y = @(size.height);
            }
                break;
            default: {
                
                msg.type = [NSNumber numberWithInt:kWCMessageTypeShare];
                msg.content = Localized(@"JX_[Link]");
                NSDictionary *dict = @{
                                       @"url" : [self subString:self.urlStr withString:@"url"],
                                       @"downloadUrl" : [self subString:self.urlStr withString:@"downloadUrl"],
                                       @"title" : [self subString:self.urlStr withString:@"title"],
                                       @"subTitle" : [self subString:self.urlStr withString:@"subTitle"],
                                       @"imageUrl" : [self subString:self.urlStr withString:@"imageUrl"],
                                       @"appName" : [self subString:self.urlStr withString:@"appName"],
                                       @"appIcon" : [self subString:self.urlStr withString:@"appIcon"],
                                       @"urlSchemes" : [self subString:self.urlStr withString:@"urlSchemes"]
                                       };
                
                SBJsonWriter * OderJsonwriter = [SBJsonWriter new];
                NSString * jsonString = [OderJsonwriter stringWithObject:dict];
                
                msg.objectId = jsonString;
            }
                break;
        }
        
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (g_xmpp.isLogined != login_status_yes) {
                
                self.isShare = YES;
            }else {
                self.relayVC = [[JXRelayVC alloc] init];
                self.relayVC.isShare = YES;
                self.relayVC.shareType = [shareType intValue];
                self.relayVC.shareSchemes = [self subString:self.urlStr withString:@"urlSchemes"];
                NSMutableArray *array = [NSMutableArray arrayWithObject:msg];
                self.relayVC.relayMsgArray = array;
                UIViewController *lastVC = (UIViewController *)g_navigation.subViews.lastObject;
                self.relayVC.modalPresentationStyle = UIModalPresentationFullScreen;
                [lastVC presentViewController:self.relayVC animated:YES completion:nil];
            }
            
        });
        
    }
    
    if ([aDownload.action isEqualToString:act_PayGetOrderInfo]) {
        
        self.skPayDic = [dict copy];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            JXSkPayVC *vc = [[JXSkPayVC alloc] init];
            vc.payDic = [dict copy];
            vc.delegate = self;
            UIViewController *lastVC = (UIViewController *)g_navigation.subViews.lastObject;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [lastVC presentViewController:vc animated:YES completion:nil];
//        });
    }
    
    if ([aDownload.action isEqualToString:act_PayPasswordPayment] || [aDownload.action isEqualToString:act_PayPasswordPaymentV1]) {
        
        [self dismissVerifyPayVC];
        [g_server showMsg:Localized(@"JXMoney_PaySuccess") delay:.5];
    }
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时

    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{

}

@end
