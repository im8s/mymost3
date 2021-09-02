//
//  downloadTasks.m
//  sjvodios
//
//  Created by  on 11-11-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "versionManage.h"
#import "AppDelegate.h"
#import "JXConnection.h"
#define AppURL @"https://itunes.apple.com/cn/app/%E8%A7%86%E9%85%B7im/id1160132242?mt=8"

@implementation versionManage

//remark = [NSString stringWithContentsOfFile:file encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000) error:nil];//改变乱码为中文


@synthesize ftpHost;
@synthesize ftpUsername;
@synthesize ftpPassword;

@synthesize buyUrl;
@synthesize helpUrl;
@synthesize softUrl;
@synthesize shareUrl;
@synthesize aboutUrl;

@synthesize version;
@synthesize theNewVersion;
@synthesize versionRemark;
@synthesize disableVersion;
@synthesize message;

@synthesize website;
@synthesize backUrl;
@synthesize apiUrl;
@synthesize uploadUrl;
@synthesize downloadUrl;
@synthesize downloadAvatarUrl;
@synthesize researchSwitch;
@synthesize XMPPDomain;
@synthesize meetingHost;

@synthesize money_login;
@synthesize money_share;
@synthesize money_intro;
@synthesize money_videoMeeting;
@synthesize money_audioMeeting;
@synthesize isCanChange;

@synthesize videoMaxLen;
@synthesize audioMaxLen;


-(id)init{
    self = [super init];
    [self getDefaultValue];
    return self;
}

-(void)dealloc{
    self.apiUrl = nil;
    self.uploadUrl = nil;
    self.downloadAvatarUrl = nil;
    self.downloadUrl = nil;
    self.version   = nil;
    self.ftpHost = nil;
    self.ftpUsername = nil;
    self.ftpPassword = nil;
    self.shareUrl = nil;
    self.buyUrl = nil;
    self.helpUrl = nil;
    self.aboutUrl = nil;
    self.XMPPDomain = nil;
    self.meetingHost = nil;
    self.buyUrl = nil;
    self.helpUrl = nil;
    self.website = nil;
    self.jitsiServer = nil;
    self.fileValidTime = nil;
    //    [super dealloc];
}

-(void)showNewVersion{
    NSString *currentVersion = [self getVersion:version];
    if(theNewVersion != nil){
        if( [theNewVersion floatValue]> [currentVersion floatValue]){//发现新版本
            NSString* s=Localized(@"versionManage_Find");
            NSString *newVersion = [NSString stringWithFormat:@"%@",theNewVersion];
            NSString *temp = nil;
            NSMutableArray *array = [NSMutableArray array];
            for(int i =0; i < [newVersion length]; i++) {
                temp = [newVersion substringWithRange:NSMakeRange(i, 1)];
                [array addObject:temp];
            }
            newVersion = [array componentsJoinedByString:@"."];
            s = [NSString stringWithFormat:@"%@:%@",Localized(@"versionManage_Find"),newVersion];
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:Localized(@"versionManage_Find") message:s preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * action = [UIAlertAction actionWithTitle:Localized(@"JX_Update") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if (self.appleId.length > 0 || self.iosAppUrl.length > 0) {
                    //转跳升级
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.iosAppUrl.length > 0 ? self.iosAppUrl : [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/%%E8%%A7%86%E9%85%B7im/id%@?mt=8",self.appleId]]];
                }else {
                    if(g_config.block)
                        g_config.block();
                }
            }];
            UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:Localized(@"JX_Cencal") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if(g_config.block)
                    g_config.block();
                
            }];
            
            [alert addAction:action];
            [alert addAction:actionCancel];
            
            [g_App.window.rootViewController  presentViewController:alert animated:YES completion:nil];
        }else{
            if(g_config.block)
                g_config.block();
        }
    }
    
}
//版本已被禁用
-(void)showDisableUse{
//    NSString* s=[NSString stringWithFormat:@"%@;",version];
//    if(disableVersion)
//        if( [disableVersion rangeOfString:s].location != NSNotFound )
//            [g_App showAlert:Localized(@"versionManage_Sorry")];
    NSString *banVer = [g_default objectForKey:@"ban_current_version"];
    if (!banVer || ![self.iosDisable isEqualToString:banVer]) {
        [g_default setObject:self.iosDisable forKey:@"ban_current_version"];
    }
    
    NSString *curVersion = [self.version stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *banVersion = [self.iosDisable stringByReplacingOccurrencesOfString:@"." withString:@""];
    if ([curVersion intValue] <= [banVersion intValue]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:Localized(@"versionManage_Find") message:Localized(@"JX_BanUserCurrentVersion") preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *action = [UIAlertAction actionWithTitle:Localized(@"JX_Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            //转跳升级
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppURL]];
//        }];
//        [alert addAction:action];
        [g_App.window.rootViewController  presentViewController:alert animated:NO completion:nil];

    }
}

-(void)showServerMsg{
    //    message = @"通知：新版本";
    if([message length]<=0)
        return;
    NSString* s=[docFilePath stringByAppendingPathComponent:@"messages.txt"];
    @try {
        if([[NSFileManager defaultManager]fileExistsAtPath:s])
            _msg = [[NSMutableDictionary alloc] initWithContentsOfFile:s];
        if(_msg == nil)
            _msg = [[NSMutableDictionary alloc]init];
        
        if([_msg objectForKey:message]==nil){
            [g_App showAlert:message];
            [_msg setObject:@"1" forKey:message];
            [_msg writeToFile:s atomically:YES];
        }
        //        [_msg release];
    }
    @catch (NSException *exception) {
    }
}

- (void)getDataWithDict:(NSDictionary *)dict {
    g_App.isShowRedPacket = [dict objectForKey:@"displayRedPacket"];
    //        g_App.isShowRedPacket = [NSString stringWithFormat:@"0"];
    NSDictionary* p = [dict objectForKey:@"ios"];
    
    self.theNewVersion = [dict objectForKey:@"iosVersion"];
    self.versionRemark = [p objectForKey:@"versionRemark"];
    self.disableVersion = [p objectForKey:@"disableVersion"];
    self.message = [p objectForKey:@"message"];
    
    p = [dict objectForKey:@"money"];
    self.money_audioMeeting = [[p objectForKey:@"audioMeeting"] intValue];
    self.money_videoMeeting = [[p objectForKey:@"videoMeeting"] intValue];
    self.money_intro = [[p objectForKey:@"intro"] intValue];
    self.money_login = [[p objectForKey:@"login"] intValue];
    self.money_share = [[p objectForKey:@"share"] intValue];
    self.videoMaxLen = [[p objectForKey:@"videoMaxLen"] intValue];
    self.audioMaxLen = [[p objectForKey:@"audioMaxLen"] intValue];
    self.isCanChange = [[p objectForKey:@"isCanChange"] boolValue];
    p = dict;
    
    if([p objectForKey:@"ftpHost"])
        self.ftpHost = [p objectForKey:@"ftpHost"];
    if([p objectForKey:@"ftpUsername"])
        self.ftpUsername = [p objectForKey:@"ftpUsername"];
    if([p objectForKey:@"ftpPassword"])
        self.ftpPassword = [p objectForKey:@"ftpPassword"];
    if([p objectForKey:@"backUrl"])
        self.backUrl = [p objectForKey:@"resumeBaseUrl"];
    if([p objectForKey:@"buyUrl"])
        self.buyUrl = [p objectForKey:@"buyUrl"];
    if([p objectForKey:@"helpUrl"])
        self.helpUrl = [p objectForKey:@"helpUrl"];
    if([p objectForKey:@"softUrl"])
        self.softUrl = [p objectForKey:@"softUrl"];
    if([p objectForKey:@"shareUrl"])
        self.shareUrl = [p objectForKey:@"shareUrl"];
    if([p objectForKey:@"uploadUrl"]) {
        self.uploadUrl = [p objectForKey:@"uploadUrl"];
        [share_defaults setObject:self.uploadUrl forKey:kUploadUrl];
    }
    if([p objectForKey:@"downloadUrl"])
        self.downloadUrl = [p objectForKey:@"downloadUrl"];
    if([p objectForKey:@"downloadAvatarUrl"]) {
        self.downloadAvatarUrl = [p objectForKey:@"downloadAvatarUrl"];
        [share_defaults setObject:self.downloadAvatarUrl forKey:kDownloadAvatarUrl];
    }
    if([p objectForKey:@"XMPPDomain"]){
        self.XMPPDomain = [p objectForKey:@"XMPPDomain"];
    }
    if([p objectForKey:@"researchSwitch"]){
        self.researchSwitch = [p objectForKey:@"researchSwitch"];
        NSLog(@"--获取开关打印%@",self.researchSwitch);
        //djk获取开关打印
    }
    
    if([p objectForKey:@"XMPPHost"]){
        self.XMPPHost = [p objectForKey:@"XMPPHost"];
    }
    if([p objectForKey:@"meetingHost"]){
        self.meetingHost = [p objectForKey:@"meetingHost"];
    }
    if([p objectForKey:@"website"])
        self.website = [p objectForKey:@"website"];
    if ([p objectForKey:@"jitsiServer"]) {
        self.jitsiServer = [p objectForKey:@"jitsiServer"];
    }
    if ([p objectForKey:@"fileValidTime"]) {
        self.fileValidTime = [p objectForKey:@"fileValidTime"];
    }
    if ([p objectForKey:@"XMPPTimeout"]) {
        self.XMPPTimeout = [[p objectForKey:@"XMPPTimeout"] intValue];
    }
    if ([p objectForKey:@"xmppPingTime"]) {
        self.XMPPPingTime = [[p objectForKey:@"xmppPingTime"] intValue];
    }
    if ([p objectForKey:@"isOpenSMSCode"]) {
        self.isOpenSMSCode = [p objectForKey:@"isOpenSMSCode"];
    }
    if ([p objectForKey:@"isOpenReceipt"]) {
        self.isOpenReceipt = [p objectForKey:@"isOpenReceipt"];
    }
    if ([p objectForKey:@"iosDisable"]) {
        self.iosDisable = [p objectForKey:@"iosDisable"];
    }
    if ([p objectForKey:@"isOpenCluster"]) {
        self.isOpenCluster = [p objectForKey:@"isOpenCluster"];
    }
    if ([p objectForKey:@"appleId"]) {
        self.appleId = [p objectForKey:@"appleId"];
    }
    if ([p objectForKey:@"companyName"]) {
        self.companyName = [p objectForKey:@"companyName"];
    }
    if ([p objectForKey:@"copyright"]) {
        self.copyright = [p objectForKey:@"copyright"];
    }
    if ([p objectForKey:@"hideSearchByFriends"]) {
        self.hideSearchByFriends = [p objectForKey:@"hideSearchByFriends"];
    }
    if ([p objectForKey:@"nicknameSearchUser"]) {
        self.nicknameSearchUser = [p objectForKey:@"nicknameSearchUser"];
    }
    if ([p objectForKey:@"regeditPhoneOrName"]) {
        self.regeditPhoneOrName = [p objectForKey:@"regeditPhoneOrName"];
    }
    if ([p objectForKey:@"registerInviteCode"]) {
        self.registerInviteCode = [p objectForKey:@"registerInviteCode"];
    }
    if ([p objectForKey:@"isCommonFindFriends"]) {
        self.isCommonFindFriends = [p objectForKey:@"isCommonFindFriends"];
    }
    if ([p objectForKey:@"isCommonCreateGroup"]) {
        self.isCommonCreateGroup = [p objectForKey:@"isCommonCreateGroup"];
    }
    if ([p objectForKey:@"isOpenPositionService"]) {
        self.isOpenPositionService = [p objectForKey:@"isOpenPositionService"];
    }
    //        [self performSelectorOnMainThread:@selector(showNewVersion) withObject:nil waitUntilDone:NO];
    if ([p objectForKey:@"headBackgroundImg"]) {
        self.headBackgroundImg = [p objectForKey:@"headBackgroundImg"];
    }
    if ([p objectForKey:@"isOpenAPNSorJPUSH"]) {
        self.isOpenAPNSorJPUSH = [p objectForKey:@"isOpenAPNSorJPUSH"];
    }
    if ([p objectForKey:@"privacyPolicyPrefix"]) {
        self.privacyPolicyPrefix = [p objectForKey:@"privacyPolicyPrefix"];
    }
    if ([p objectForKey:@"iosAppUrl"]) {
        self.iosAppUrl = [p objectForKey:@"iosAppUrl"];
    }
    if ([p objectForKey:@"isOpenRoomSearch"]) {
        self.isOpenRoomSearch = [p objectForKey:@"isOpenRoomSearch"];
    }
    // 热门应用
    if ([p objectForKey:@"popularAPP"]) {
        SBJsonParser * resultParser = [[SBJsonParser alloc] init] ;
        id resultObject = [resultParser objectWithString:[p objectForKey:@"popularAPP"]];
        self.popularAPP = (NSDictionary *)resultObject;
    }
    if ([p objectForKey:@"address"]) {
        self.isChina = [[p objectForKey:@"address"] isEqualToString:@"CN"];
    }
    
    if ([p objectForKey:@"isOpenOnlineStatus"]) {
        self.isOpenOnlineStatus = [p objectForKey:@"isOpenOnlineStatus"];
    }
    if ([p objectForKey:@"videoLength"]) {
        self.videoLength = [p objectForKey:@"videoLength"];
    }
    if ([p objectForKey:@"enableMpModule"]) {
        self.enableMpModule = [p objectForKey:@"enableMpModule"];
    }
    if ([p objectForKey:@"showContactsUser"]) {
        self.showContactsUser = [p objectForKey:@"showContactsUser"];
    }
    if ([p objectForKey:@"enablePayModule"]) {
        self.enablePayModule = [p objectForKey:@"enablePayModule"];
    }
    if ([p objectForKey:@"isOpenSecureChat"]) {
        self.isOpenSecureChat = [p objectForKey:@"isOpenSecureChat"];
    }
    if ([p objectForKey:@"isOpenManualPay"]) {
        self.isOpenManualPay = [p objectForKey:@"isOpenManualPay"];
    }
    if ([p objectForKey:@"isOpenCloudWallet"]) {
        self.isOpenCloudWallet = [p objectForKey:@"isOpenCloudWallet"];
    }
    if ([p objectForKey:@"enableAliPay"]) {
        self.isOpenAliPay = [p objectForKey:@"enableAliPay"];
    }
    if ([p objectForKey:@"enableWxPay"]) {
        self.isOpenWxPay = [p objectForKey:@"enableWxPay"];
    }
    if ([p objectForKey:@"maxRedpacktAmount"]){
        self.maxRedpackAmount = [p objectForKey:@"maxRedpacktAmount"];
    }
    if ([p objectForKey:@"maxRedpacktNumber"]) {
        self.maxRedpacktNumber = [p objectForKey:@"maxRedpacktNumber"];
    }
    if ([p objectForKey:@"isOpenAuthSwitch"]){
        self.isOpenAuthSwitch = [p objectForKey:@"isOpenAuthSwitch"];
    }
}

-(void)didReceive:(NSDictionary*)dict{
    @try {
        // 默认值赋值时，getDataWithDict方法中不赋值apiUrl
        if([dict objectForKey:@"apiUrl"]){
            self.apiUrl = [dict objectForKey:@"apiUrl"];
            [share_defaults setObject:self.apiUrl forKey:kApiUrl];
        }
        [self getDataWithDict:dict];
        [self showDisableUse];
        [self showServerMsg];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self showNewVersion];
        });
        //[self getNewVersion:version];
        
        // 保存这一次成功的IP
        [g_default setObject:self.apiUrl forKey:kLastApiUrl];
        [g_default synchronize];
    }
    @catch (NSException *exception){
    }
    @finally {
    }
}
//转换格式进行对比
- (NSString *)getVersion:(NSString *) phoneVersion{
    NSArray * numberArr = [phoneVersion componentsSeparatedByString:@"."];
    NSString * numberVersion = [numberArr componentsJoinedByString:@""];
//    version = [numberVersion substringToIndex:3];
    return [numberVersion substringToIndex:numberVersion.length];
}

- (NSString *)getConfigDefault:(NSString *)url {
    NSString *configUrlStr = [NSString string];
    // 获取config默认值 （先网页上调config 接口获取值后，到http://www.bejson.com/ 转译json，则获取configUrlStr）
    
    return configUrlStr;
}


-(void)getDefaultValue{
    self.version   = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:SERVER_LIST_DATA];
    if (array.firstObject) {
        self.apiUrl = array.firstObject;
    }else {
//        self.apiUrl = @"https://47.110.246.176:8092/config"; //djk端口
        self.apiUrl = @"http://47.243.24.20:8092/config"; //djk端口

        //@"http://154.92.22.217:8092/config"
//        self.apiUrl = @"http://101.37.90.183:8094/config";
        //接口前缀URL,一般改这句即可，其他配置从服务器读取，在服务器改    蒲公英打包

        array = [[NSMutableArray alloc] initWithObjects:self.apiUrl, nil];
        [array writeToFile:SERVER_LIST_DATA atomically:YES];
        
        
        //保存一次默认apiUrl
        [g_default setObject:self.apiUrl forKey:kLastApiUrl];
        [g_default synchronize];
        
    }

    NSString *configUrlStr = [self getConfigDefault:self.apiUrl];
    
    // json 转 字典
    SBJsonParser *json = [[SBJsonParser alloc] init];
    NSDictionary *dict = [json objectWithString:configUrlStr];
    
    // 设置默认值
    [self getDataWithDict:[dict objectForKey:@"data"]];
    
    self.XMPPTimeout = 180;  //xmpp超时时间 默认值180
    self.XMPPPingTime = 72; //xmpp ping时间间隔 默认值72
    self.maxRedpacktNumber = @100;
    self.maxRedpackAmount = @200;
    self.isOpenAliPay = @1;
    self.isOpenWxPay = @1;
    
}

@end
