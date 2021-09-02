//
//  myViewController.m
//  sjvodios
//
//  Created by  on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JXSettingVC.h"
#import "JXImageView.h"
#import "JXLabel.h"
#import "AppDelegate.h"
#import "JXServer.h"
#import "JXConnection.h"
#import "UIFactory.h"
#import "JXTableView.h"
#import "JXFriendViewController.h"
#import "ImageResize.h"
#import "userWeiboVC.h"
#import "myMediaVC.h"
#import "webpageVC.h"
#import "loginVC.h"
#import "JXNewFriendViewController.h"
#import "forgetPwdVC.h"
#import "JXSelectorVC.h"
#import "JXSetChatBackgroundVC.h"
#import "JXSetChatTextFontVC.h"

#import "PSRegisterBaseVC.h"
#import "photosViewController.h"
#import "JXAboutVC.h"
#import "JXMessageObject.h"
#import "JXMediaObject.h"
#import <StoreKit/StoreKit.h>
#import "JXGroupMessagesSelectFriendVC.h"
#import "JXAccountBindingVC.h"
#import "JXSecuritySettingVC.h"
#import "JXChatLogMoveVC.h"
#import "JXSelThemeColorsVC.h"
#import "JXBlackFriendVC.h"

#define HEIGHT 56

@interface JXSettingVC ()<JXSelectorVCDelegate,SKStoreProductViewControllerDelegate>
@property (nonatomic, assign) NSInteger currentLanguageIndex;
@property (nonatomic, assign) NSInteger currentSkin;
@property (atomic,assign) BOOL reLogin;
@property (nonatomic, strong) UILabel *fileSizelab;

@property (nonatomic, strong) UIView *baseView;

@end

@implementation JXSettingVC

- (id)init
{
    self = [super init];
    if (self) {

        self.isGotoBack = YES;
        self.title = Localized(@"JXSettingVC_Set");
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self createHeadAndFoot];
        self.tableBody.backgroundColor = HEXCOLOR(0xF2F2F2);
        self.tableBody.scrollEnabled = YES;
        
        self.baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 0)];
        self.baseView.backgroundColor = [UIColor clearColor];
        [self.tableBody addSubview:self.baseView];
        
        UIButton* btn;
        int h=0;
        int w=JX_SCREEN_WIDTH;
        
        JXImageView* iv;
        iv = [self createButton:Localized(@"JXSettingVC_ClearCache") drawTop:NO drawBottom:YES icon:nil click:@selector(onClear)];
        iv.frame = CGRectMake(0,h, w, HEIGHT);
        
        self.fileSizelab = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2 - 35, (HEIGHT-20)/2, JX_SCREEN_WIDTH / 2, 20)];
        self.fileSizelab.textColor = HEXCOLOR(0x999999);
        self.fileSizelab.font = SYSFONT(15);
        self.fileSizelab.textAlignment = NSTextAlignmentRight;
        self.fileSizelab.text = [self folderSizeAtPath:tempFilePath];
        [iv addSubview:self.fileSizelab];
        
        h+=iv.frame.size.height;
        
        iv = [self createButton:Localized(@"JX_ClearAllChatRecords") drawTop:NO drawBottom:YES icon:nil click:@selector(onClearChatLog)];
        iv.frame = CGRectMake(0,h, w, HEIGHT);
        h+=iv.frame.size.height;
        
        iv = [self createButton:Localized(@"JX_ChatLogMove") drawTop:NO drawBottom:NO icon:nil click:@selector(onChatLogMove)];
        iv.frame = CGRectMake(0, h, w, HEIGHT);
        h += iv.frame.size.height+8;
        
        iv = [self createButton:Localized(@"JX_UpdatePassWord") drawTop:NO drawBottom:YES icon:nil click:@selector(onForgetPassWord)];
        iv.frame = CGRectMake(0, h, w, HEIGHT);
        h+=iv.frame.size.height;
        
        iv = [self createButton:@"黑名单" drawTop:NO drawBottom:NO icon:nil click:@selector(blackFriendAction)];
        iv.frame = CGRectMake(0, h, w, HEIGHT);
        h += iv.frame.size.height+8;
        
//        iv = [self createButton:Localized(@"JXSettingVC_Help") drawTop:NO drawBottom:YES icon:nil click:@selector(onHelp)];
//        iv.frame = CGRectMake(0,h, w, HEIGHT);
//        h+=iv.frame.size.height;
        
        //语言切换
        NSString *lang = g_constant.sysLanguage;
        NSString *currentLanguage;
//        if ([lang isEqualToString:@"zh"]) {
//            currentLanguage = @"简体中文";
//            _currentLanguageIndex = 0;
//
//        }else if ([lang isEqualToString:@"big5"]) {
//            currentLanguage = @"繁體中文(香港)";
//            _currentLanguageIndex = 1;
//        }
////        else if ([lang isEqualToString:@"malay"]) {
////            currentLanguage = @"Bahasa Melayu";
////            _currentLanguageIndex = 3;
////        }else if ([lang isEqualToString:@"th"]) {
////            currentLanguage = @"ภาษาไทย";
////            _currentLanguageIndex = 4;
////        }
//        else {
//            currentLanguage = @"English";
//            _currentLanguageIndex = 2;
//        }
        currentLanguage = [@{@"zh":@"简体中文", @"big5":@"繁體中文(香港)", @"en":@"English",
//                             @"ja":@"日本語",@"ko":@"한국어",
                             @"idy":@"Indonesia",@"vi":@"ViệtName",
//                             @"ms":@"Melayu",
                             @"fy":@"Pilipino"} objectForKey:lang];

        
        iv = [self createButton:Localized(@"JX_LanguageSwitching") drawTop:NO drawBottom:YES icon:nil click:@selector(languageSwitch)];
        
        UILabel *arrTitle = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2 - 35, (HEIGHT-20)/2, JX_SCREEN_WIDTH / 2, 20)];
        arrTitle.text = currentLanguage;
        arrTitle.textColor = HEXCOLOR(0x999999);
        arrTitle.font = SYSFONT(15);
        arrTitle.textAlignment = NSTextAlignmentRight;
        [iv addSubview:arrTitle];
        
        iv.frame = CGRectMake(0,h, w, HEIGHT);
        h+=iv.frame.size.height;
        
        
        iv = [self createButton:Localized(@"JXTheme_switch") drawTop:NO drawBottom:NO icon:nil click:@selector(changeSkin)];
        UILabel *skinTitle = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2 - 35, (HEIGHT-20)/2, JX_SCREEN_WIDTH / 2, 20)];
        skinTitle.text = g_theme.themeName;
        skinTitle.textColor = HEXCOLOR(0x999999);
        skinTitle.font = SYSFONT(15);
        skinTitle.textAlignment = NSTextAlignmentRight;
        [iv addSubview:skinTitle];
        iv.frame = CGRectMake(0, h, w, HEIGHT);
        h+=iv.frame.size.height+8;
        
        
        iv = [self createButton:Localized(@"JX_ChatFonts") drawTop:NO drawBottom:NO icon:nil click:@selector(setChatTextFont)];
        iv.frame = CGRectMake(0, h, w, HEIGHT);
        h += iv.frame.size.height;
        
        iv = [self createButton:Localized(@"JXGroupMessages") drawTop:YES drawBottom:NO icon:nil click:@selector(groupMessages)];
        iv.frame = CGRectMake(0,h, w, HEIGHT);
        h+=iv.frame.size.height+8;
        
        iv = [self createButton:Localized(@"JX_PrivacySettings") drawTop:NO drawBottom:YES icon:nil click:@selector(onSet)];
        iv.frame = CGRectMake(0,h, w, HEIGHT);
        h+=iv.frame.size.height;
        
        iv = [self createButton:Localized(@"JX_SecuritySettings") drawTop:NO drawBottom:YES icon:nil click:@selector(onSecuritySetting)];
        iv.frame = CGRectMake(0,h, w, HEIGHT);
        h+=iv.frame.size.height;

        
        iv = [self createButton:Localized(@"JX_SettingUpChatBackground") drawTop:NO drawBottom:YES icon:nil click:@selector(setChatBackground)];
        iv.frame = CGRectMake(0, h, w, HEIGHT);
        h += iv.frame.size.height;
        
        iv = [self createButton:Localized(@"JX_AccountAndBindSettings") drawTop:NO drawBottom:NO icon:nil click:@selector(setAccountBinding)];
        iv.frame = CGRectMake(0, h, w, HEIGHT);
        h += iv.frame.size.height+8;
        
//        if (THE_APP_OUR) {
//            iv = [self createButton:Localized(@"JXSettingViewController_Evaluate") drawTop:NO drawBottom:YES icon:nil click:@selector(webAppStoreBtnAction)];
//            iv.frame = CGRectMake(0,h, w, HEIGHT);
//            h+=iv.frame.size.height;
            
            iv = [self createButton:Localized(@"JXAboutVC_AboutUS") drawTop:NO drawBottom:NO icon:nil click:@selector(onAbout)];
            iv.frame = CGRectMake(0,h, w, HEIGHT);
            h+=iv.frame.size.height+8;
//        }
        
        CGRect frame = self.baseView.frame;
        frame.size.height = h;
        self.baseView.frame = frame;
        
        btn = [UIFactory createCommonButton:Localized(@"JXSettingVC_LogOut") target:self action:@selector(onLogout)];
//        [btn setBackgroundImage:nil forState:UIControlStateHighlighted];
        btn.custom_acceptEventInterval = 1.f;
        btn.frame = CGRectMake(15,CGRectGetMaxY(self.baseView.frame)+20, JX_SCREEN_WIDTH-30, 40);
        [btn setBackgroundImage:nil forState:UIControlStateNormal];
        btn.backgroundColor = THEMECOLOR;
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 7.f;
        [self.tableBody addSubview:btn];
        
        if (self.tableBody.frame.size.height < CGRectGetMaxY(btn.frame)+51) {
            self.tableBody.contentSize = CGSizeMake(0, CGRectGetMaxY(btn.frame)+51);
        }
    }
    return self;
}

-(void)dealloc{
//    NSLog(@"JXSettingVC.dealloc");
//    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)actionLogout{
    [self.view endEditing:YES];
    [_wait stop];
    [g_server stopConnection:self];
    
//    if ([self.delegate respondsToSelector:@selector(admobDidQuit)]) {
//        [self.delegate admobDidQuit];
//    }
    [self actionQuit];
//    [self.view removeFromSuperview];
//    _pSelf = nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    if( [aDownload.action isEqualToString:act_UserLogout] ){
        [g_default setObject:nil forKey:kMY_USER_PrivateKey_DH];
        [g_default setObject:nil forKey:kMY_USER_PrivateKey_RSA];
        if (self.reLogin) {
//            [g_notify postNotificationName:kLogOutNotifaction object:nil];
//            [g_default setObject:nil forKey:kMY_USER_TOKEN];
//            g_server.access_token = nil;
            self.reLogin = NO;
            [self relogin];
//            g_mainVC = nil;

//            [JXMyTools showTipView:Localized(@"SignOuted")];
//            
//            [[JXXMPP sharedInstance] logout];
//            [self actionLogout];
//            [self admobDidQuit];
            return;
        }
        [g_notify postNotificationName:kCallEndNotification object:nil];
        [self performSelector:@selector(doSwitch) withObject:nil afterDelay:1];
        
    }else if ([aDownload.action isEqualToString:act_Settings]){
        
        //跳转新的页面
        JXSettingsViewController* vc = [[JXSettingsViewController alloc]init];
        vc.dataSorce = dict;
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
        [_wait stop];
    }
    if ([aDownload.action isEqualToString:act_EmptyMsg]){
        [g_App showAlert:Localized(@"JX_ClearSuccess")];
    }

}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    if( [aDownload.action isEqualToString:act_UserLogout] ){
        [self performSelector:@selector(doSwitch) withObject:nil afterDelay:1];
    }
    return hide_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
}

-(void)onClear{
    [g_App showAlert:Localized(@"JX_ConfirmClearData") delegate:self tag:1345 onlyConfirm:NO];
}
// 黑名单
- (void)blackFriendAction{
    JXBlackFriendVC *vc = [[JXBlackFriendVC alloc] init];
    vc.title = Localized(@"JX_BlackList");
    [g_navigation pushViewController:vc animated:YES];
}
// 清除所有聊天记录
- (void) onClearChatLog {
    [g_App showAlert:Localized(@"JX_ConfirmClearAllLogs") delegate:self tag:1134 onlyConfirm:NO];
}


// 群发消息
- (void)groupMessages {
    
    JXGroupMessagesSelectFriendVC *vc = [[JXGroupMessagesSelectFriendVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

//切换皮肤主题
-(void)changeSkin{
    JXSelThemeColorsVC *vc = [[JXSelThemeColorsVC alloc] init];
    vc.title = Localized(@"JXTheme_choose");
    vc.array = g_theme.skinNameList;
    vc.selectIndex = g_theme.themeIndex;
    [g_navigation pushViewController:vc animated:YES];
}

// 设置聊天背景
- (void)setChatBackground{
    
    JXSetChatBackgroundVC *vc = [[JXSetChatBackgroundVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 账号和绑定设置
- (void)setAccountBinding {
    JXAccountBindingVC *bindVC = [[JXAccountBindingVC alloc] init];
    [g_navigation pushViewController:bindVC animated:YES];
}

// 聊天字体
- (void)setChatTextFont {
    JXSetChatTextFontVC *vc = [[JXSetChatTextFontVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 切换语言
- (void)languageSwitch {
    NSString *lang = g_constant.sysLanguage;

//    if ([lang isEqualToString:@"zh"]) {
//        _currentLanguageIndex = 0;
//    }else if ([lang isEqualToString:@"big5"]) {
//        _currentLanguageIndex = 1;
//    }else {
//        _currentLanguageIndex = 2;
//    }
    
    _currentLanguageIndex = [@[@"zh",@"big5",@"en",
//                               @"ja",@"ko",
                               @"idy",@"vi",
//                               @"ms",
                               @"fy"] indexOfObject:lang];
    
    JXSelectorVC *vc = [[JXSelectorVC alloc] init];
    vc.title = Localized(@"JX_SelectLanguage");
    vc.array = @[@"简体中文", @"繁體中文(香港)", @"English",
//                 @"日本語",@"한국어",
                 @"Indonesia",@"ViệtName",
//                 @"Melayu"
                 @"Pilipino"];
//    vc.array = @[@"简体中文", @"繁體中文(香港)", @"English",@"Bahasa Melayu",@"ภาษาไทย"];
    vc.selectIndex = _currentLanguageIndex;
    vc.selectorDelegate = self;
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}
- (void)selector:(JXSelectorVC *)selector selectorAction:(NSInteger)selectIndex {
 
    if ([selector.title isEqualToString:Localized(@"JX_SelectLanguage")]) {
        self.currentLanguageIndex = selectIndex;
        [g_App showAlert:Localized(@"JX_SwitchLanguageNeed") delegate:self tag:3333 onlyConfirm:NO];
    }else{
        self.currentSkin = selectIndex;
        [g_App showAlert:Localized(@"JXTheme_confirm") delegate:self tag:4444 onlyConfirm:NO];
    }

    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 3333 && buttonIndex == 1) {
        
        NSString *currentLanguage;
        
        switch (self.currentLanguageIndex) {
            case 0:
                
                currentLanguage = @"zh";
                break;
            case 1:
                
                currentLanguage = @"big5";
                break;
            case 2:
                
                currentLanguage = @"en";
                break;
//            case 3:
//
//                currentLanguage = @"ja";
//                break;
//            case 4:
//
//                currentLanguage = @"ko";
//                break;
            case 3:

                currentLanguage = @"idy";
                break;
            case 4:
                
                currentLanguage = @"vi";
                break;
//            case 7:
//
//                currentLanguage = @"ms";
//                break;
            case 5:
                
                currentLanguage = @"fy";
                break;

            default:
                break;
        }
        
        [g_default setObject:currentLanguage forKey:kLocalLanguage];
        [g_default synchronize];
        [g_constant resetlocalized];
        
        self.reLogin = NO;
//        // 更新系统好友的显示
        [[JXUserObject sharedInstance] createSystemFriend];
//        [[JXUserObject sharedInstance] createAddressBookFriend];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
//            [g_server logout:self];
            [self doLogout];
        });
    }else if (alertView.tag == 4444 && buttonIndex == 1) {
        [g_theme switchSkinIndex:self.currentSkin];
        [g_mainVC.view removeFromSuperview];
        g_mainVC = nil;
        [self.view removeFromSuperview];
        self.view = nil;
        g_navigation.lastVC = nil;
        [g_navigation.subViews removeAllObjects];
        [g_App showMainUI];
    }else if (alertView.tag == 1134 && buttonIndex == 1) {
        NSMutableArray* p = [[JXMessageObject sharedInstance] fetchRecentChat];
        for (NSInteger i = 0; i < p.count; i ++) {
            JXMsgAndUserObject *obj = p[i];
            if ([obj.user.userId isEqualToString:@"10000"] || [obj.user.userId isEqualToString:FRIEND_CENTER_USERID]) {
                continue;
            }
            [obj.user reset];
            [obj.message deleteAll];
        }
        [g_server emptyMsgWithTouserId:nil type:[NSNumber numberWithInt:1] toView:self];
        [g_notify postNotificationName:kDeleteAllChatLog object:nil];
    }else if (alertView.tag == 1345 && buttonIndex == 1) {
        [_wait start:Localized(@"JXAlert_ClearCache")];
        [FileInfo deleleFileAndDir:tempFilePath];
        // 录制的视频也会被清除，所以要清除视频记录表
        [[JXMediaObject sharedInstance] deleteAll];
        self.fileSizelab.text = [self folderSizeAtPath:tempFilePath];
        [_wait performSelector:@selector(stop) withObject:nil afterDelay:1];
    }

}

- (NSString *)folderSizeAtPath:(NSString *)folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil)
    {
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return [NSString stringWithFormat:@"%.2fM",folderSize/(1024.0*1024.0)];
}

- (long long)fileSizeAtPath:(NSString*)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}


#pragma mark-----修改密码
- (void)onForgetPassWord{
    forgetPwdVC *forgetVC = [[forgetPwdVC alloc]init];
    forgetVC.isModify = YES;
//    [g_App.window addSubview:forgetVC.view];
    [g_navigation pushViewController:forgetVC animated:YES];
}

// 聊天记录迁移
- (void)onChatLogMove {
    
    JXChatLogMoveVC *vc = [[JXChatLogMoveVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)onSet{
    
    // 获取设置状态
    [g_server getFriendSettings:[NSString stringWithFormat:@"%ld",g_server.user_id] toView:self];
    
}

- (void)onSecuritySetting {
    
    JXSecuritySettingVC *vc = [[JXSecuritySettingVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onLogout{
    [g_App showAlert:Localized(@"JXAlert_LoginOut") delegate:self];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 3333){
        
    }else if(alertView.tag == 4444){
        
    }else if(alertView.tag == 1134){
        
    }else if(alertView.tag == 1345){
        
    }else if(buttonIndex==1){
        //保存未读消息条数
        //        [g_notify postNotificationName:kSaveBadgeNotifaction object:nil];
        [self doLogout];
    }
}

-(void)doLogout{
    JXUserObject *user = [JXUserObject sharedInstance];
    [g_server logout:user.areaCode toView:self];

}

-(void)relogin{
//    [g_default removeObjectForKey:kMY_USER_PASSWORD];
//    [g_default setObject:nil forKey:kMY_USER_TOKEN];
    g_server.access_token = nil;
    
    [g_notify postNotificationName:kSystemLogoutNotifaction object:nil];
    [[JXXMPP sharedInstance] logout];
    NSLog(@"XMPP ---- jxsettingVC relogin");

    loginVC* vc = [loginVC alloc];
    vc.isAutoLogin = NO;
    vc.isSwitchUser= NO;
    vc = [vc init];
    [g_mainVC.view removeFromSuperview];
    g_mainVC = nil;
    [self.view removeFromSuperview];
    self.view = nil;
    
    g_navigation.rootViewController = vc;
//    g_navigation.lastVC = nil;
//    [g_navigation.subViews removeAllObjects];
//    [g_navigation pushViewController:vc];
//    g_App.window.rootViewController = vc;
//    [g_App.window makeKeyAndVisible];
    
//    loginVC* vc = [loginVC alloc];
//    vc.isAutoLogin = NO;
//    vc.isSwitchUser= NO;
//    vc = [vc init];
//    [g_window addSubview:vc.view];
//    [self actionQuit];
    //    [_wait performSelector:@selector(stop) withObject:nil afterDelay:1];
    [_wait stop];
#if TAR_IM
#ifdef Meeting_Version
    [g_meeting stopMeeting];
#endif
#endif
}

-(void)doSwitch{
    [g_default removeObjectForKey:kMY_USER_PASSWORD];
    [g_default removeObjectForKey:kMY_USER_TOKEN];
    [g_notify postNotificationName:kSystemLogoutNotifaction object:nil];
    g_xmpp.isReconnect = NO;
    [[JXXMPP sharedInstance] logout];
    NSLog(@"XMPP ---- jxsettingVC doSwitch");
    // 退出登录到登陆界面 隐藏悬浮窗
    g_App.subWindow.hidden = YES;
    
    loginVC* vc = [loginVC alloc];
    vc.isAutoLogin = NO;
    vc.isSwitchUser= NO;
    vc = [vc init];
    [g_mainVC.view removeFromSuperview];
    g_mainVC = nil;
    [self.view removeFromSuperview];
    self.view = nil;
    g_navigation.rootViewController = vc;
//    g_navigation.lastVC = nil;
//    [g_navigation.subViews removeAllObjects];
//    [g_navigation pushViewController:vc];
//    g_App.window.rootViewController = vc;
//    [g_App.window makeKeyAndVisible];

//    loginVC* vc = [loginVC alloc];
//    vc.isAutoLogin = NO;
//    vc.isSwitchUser= YES;
//    vc = [vc init];
//    [g_navigation.subViews removeAllObjects];
////    [g_window addSubview:vc.view];
//    [g_navigation pushViewController:vc];
//    [self actionQuit];
//    [_wait performSelector:@selector(stop) withObject:nil afterDelay:1];
//    [_wait stop];
#if TAR_IM
#ifdef Meeting_Version
    [g_meeting stopMeeting];
#endif
#endif
}

// 去评价
-(void)webAppStoreBtnAction {
    if (g_App.config.appleId.length > 0) {
        [_wait start];
        SKStoreProductViewController *vc = [[SKStoreProductViewController alloc] init];
        vc.delegate = self;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        //加载App Store视图展示
        [vc loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:g_App.config.appleId} completionBlock:^(BOOL result, NSError * _Nullable error) {
            [_wait stop];
            if (!error) {
                [self presentViewController:vc animated:YES completion:nil];
            }
        }];
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onAbout{
    JXAboutVC* vc = [[JXAboutVC alloc]init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onHelp{
    [g_server showWebPage:g_config.helpUrl title:Localized(@"JXSettingVC_Help")];
}

-(JXImageView*)createButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom icon:(NSString*)icon click:(SEL)click{
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.delegate = self;
    [self.baseView addSubview:btn];
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(15, 0, JX_SCREEN_WIDTH-100, HEIGHT)];
    p.text = title;
    p.font = [UIFont boldSystemFontOfSize:16];
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    p.delegate = self;
    p.didTouch = click;
    [btn addSubview:p];
    
    if(icon){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(10, (HEIGHT-20)/2, 20, 20)];
        iv.image = [UIImage imageNamed:icon];
        [btn addSubview:iv];
    }
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(15,0,JX_SCREEN_WIDTH-15,LINE_WH)];
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

-(void)onVideoSize{
    NSString* s = [[NSUserDefaults standardUserDefaults] objectForKey:@"chatVideoSize"];
    if(s==nil)
        s = @"1";

    JXSelectorVC* vc = [[JXSelectorVC alloc]init];
    vc.title = Localized(@"JX_ChatVideoSize");
    vc.array = @[@"1920*1080", @"1280*720", @"640*480",@"320*240"];
    vc.selectIndex = [s intValue];
    vc.delegate = self;
    vc.didSelected = @selector(didSelected:);
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)didSelected:(JXSelectorVC*)vc{
    [g_default setObject:[NSString stringWithFormat:@"%ld",vc.selectIndex] forKey:@"chatVideoSize"];
}

@end
