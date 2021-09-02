//
//  JXMainViewController.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXMainViewController.h"
#import "JXTabMenuView.h"
#import "JXMsgViewController.h"
#import "JXFriendViewController.h"
#import "AppDelegate.h"
#import "JXNewFriendViewController.h"
#import "JXFriendObject.h"
#import "PSMyViewController.h"
#ifdef Live_Version
#import "JXLiveViewController.h"
#endif

#import "WeiboViewControlle.h"
#import "JXSquareViewController.h"
#import "JXProgressVC.h"
#import "JXGroupViewController.h"
#import "OrganizTreeViewController.h"
#import "JXLabelObject.h"
#import "JXBlogRemind.h"
#import "JXRoomPool.h"
#import "JXDeviceAuthController.h"
#import "loginVC.h"
#import "JKWebViewController.h"


@implementation JXMainViewController
@synthesize tb=_tb;

@synthesize btn=_btn,mainView=_mainView;
@synthesize IS_HR_MODE;

@synthesize psMyviewVC=_psMyviewVC;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.isLoadFriendAndGroup = [g_server.myself fetchAllFriends].count < 6;
        
        self.view.backgroundColor = [UIColor clearColor];

//        g_navigation.lastVC = nil;
//        [g_navigation.subViews removeAllObjects];
//        [g_navigation pushViewController:self animated:YES];
//        
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_TOP)];
        //        [self.view addSubview:_topView];
//        [_topView release];
        
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM)];
        [self.view addSubview:_mainView];
//        [_mainView release];
        
        _bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM, JX_SCREEN_WIDTH, JX_SCREEN_BOTTOM)];
        _bottomView.userInteractionEnabled = YES;
        _bottomView.backgroundColor = HEXCOLOR(0xF1F1F1);
        [self.view addSubview:_bottomView];
//        [_bottomView release];
        
        [self buildTop];
        

#ifdef IS_SHOW_MENU
        _squareVC = [[JXSquareViewController alloc] init];
#else
        _weiboVC = [WeiboViewControlle alloc];
        _weiboVC.user = g_server.myself;
        _weiboVC = [_weiboVC init];
#endif

        if (g_server.isManualLogin && self.isLoadFriendAndGroup) {
            
            _groupVC = [JXGroupViewController alloc];
            [_groupVC scrollToPageUp];
        }
        _msgVc = [[JXMsgViewController alloc] init];
        _friendVC = [[JXFriendViewController alloc] init];
        _psMyviewVC = [[PSMyViewController alloc] init];
        _jkWebVC = [[JKWebViewController alloc] init];
        
//#ifdef Live_Version
//        _liveVC = [[JXLiveViewController alloc]init];
//#else
//        _organizVC = [[OrganizTreeViewController alloc] init];
//#endif
//
        
        [self doSelected:0];
        [self adjustStatusBar];
        
        [g_notify addObserver:self selector:@selector(loginSynchronizeFriends:) name:kXmppClickLoginNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(appDidEnterForeground) name:kApplicationWillEnterForeground object:nil];
        [g_notify addObserver:self selector:@selector(getUserInfo:) name:kXMPPMessageUpadteUserInfoNotification object:nil];
        [g_notify addObserver:self selector:@selector(getRoomSet:) name:kXMPPMessageUpadteGroupNotification object:nil];
        [g_notify addObserver:self selector:@selector(onXmppLoginChanged:) name:kXmppLoginNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(hasLoginOther:) name:kXMPPLoginOtherNotification object:nil];
        [g_notify addObserver:self selector:@selector(showDeviceAuth:) name:kDeviceAuthNotification object:nil];
        [g_notify addObserver:self selector:@selector(lockUser) name:kLockUserNotification object:nil];
//        [g_notify addObserver:self selector:@selector(adjustStatusBar) name:kUIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (void)lockUser {
    [g_default setObject:nil forKey:kMY_USER_PrivateKey_DH];
    [g_default setObject:nil forKey:kMY_USER_PrivateKey_RSA];
    [g_notify postNotificationName:kCallEndNotification object:nil];
    [self doSwitch];
    //此账号已被锁定
    [g_App showAlert:Localized(@"JX_ThisAccountLocked")];
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

- (void)adjustStatusBar {
    if (STATUS_BAR_BIGGER_THAN_20) {
        _bottomView.frame = CGRectMake(0, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM-20, JX_SCREEN_WIDTH, JX_SCREEN_BOTTOM);
    }else {
        _bottomView.frame = CGRectMake(0, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM, JX_SCREEN_WIDTH, JX_SCREEN_BOTTOM);
    }
}

- (void)appEnterForegroundNotif:(NSNotification *)noti {
}

- (void)getUserInfo:(NSNotification *)noti {
    JXMessageObject *msg = noti.object;
    [g_server getUser:msg.toUserId toView:self];
}

- (void)getRoomSet:(NSNotification *)noti {
    JXMessageObject *msg = noti.object;
    [g_server getRoom:msg.toUserId toView:self];
}

-(void)dealloc{
//    [_psMyviewVC.view release];
//    [_msgVc.view release];
    [g_notify removeObserver:self name:kXmppLoginNotifaction object:nil];
    [g_notify removeObserver:self name:kSystemLoginNotifaction object:nil];
    [g_notify removeObserver:self name:kXmppClickLoginNotifaction object:nil];
    [g_notify removeObserver:self name:kXMPPLoginOtherNotification object:nil];
    [g_notify removeObserver:self name:kApplicationWillEnterForeground object:nil];
    [g_notify removeObserver:self name:kXMPPMessageUpadteUserInfoNotification object:nil];
    [g_notify removeObserver:self name:kDeviceAuthNotification object:nil];
//    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (g_server.isManualLogin) {
        if (self.isLoadFriendAndGroup) {
            NSArray *array = [[JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
            if (array.count <= 0) {
                // 同步标签
                [g_server friendGroupListToView:self];
            }
        }
    }
    
    // 获取服务器时间
    [g_server getCurrentTimeToView:self];
    // 获取自己的用户信息
    [g_server getUser:g_myself.userId toView:self];
}


- (void)appDidEnterForeground {
    // 获取服务器时间
    [g_server getCurrentTimeToView:self];
}

- (void)loginSynchronizeFriends:(NSNotification*)notification{

        //判断服务器好友数量是否与本地一致
//        _friendArray = [g_server.myself fetchAllFriendsOrNotFromLocal];
        //    NSLog(@"%d -------%ld",[g_server.myself.friendCount intValue] , [_friendArray count]);
        //    if ([g_server.myself.friendCount intValue] > [_friendArray count] && [g_server.myself.friendCount intValue] >0) {
        //        [g_App showAlert:Localized(@"JXAlert_SynchFirendOK") delegate:self];
        if (self.isLoadFriendAndGroup) {
            [g_server listAttention:0 userId:MY_USER_ID toView:self];
        }else{
            
#ifdef IS_MsgEncrypt
        
            if (g_server.isManualLogin) {
                [g_server listAttention:0 userId:MY_USER_ID toView:self];
            }
#endif

            [[JXXMPP sharedInstance] performSelector:@selector(login) withObject:nil afterDelay:2];//2秒后执行xmpp登录
        }
        
        [[JXXMPP sharedInstance] performSelector:@selector(login) withObject:nil afterDelay:2];//2秒后执行xmpp登录
    
    //    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 10002) {
        [g_server performSelector:@selector(showLogin) withObject:nil afterDelay:0.5];
        return;
    }else if (buttonIndex == 1) {
        [g_server listAttention:0 userId:MY_USER_ID toView:self];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)buildTop{
    _tb = [JXTabMenuView alloc];
//    NSString * thirdSrt;
//    NSString * thirdImgStr;
//    NSString * thiidSelectImgSrt;
//#ifdef Live_Version
//    thirdSrt = Localized(@"JXLiveVC_Live");
//    thirdImgStr = @"live_normal";
//    thiidSelectImgSrt = @"live_press";
//#else
//    thirdSrt = Localized(@"JX_Colleague");
//    thirdImgStr = @"my_organizBook";
//    thiidSelectImgSrt = @"my_organizBook_press";
//#endif
   
//    if () {
//        _tb.items = [NSArray arrayWithObjects:Localized(@"JXMainViewController_Message"),Localized(@"JX_MailList"),@"鲸鱼",@"探索",Localized(@"JX_My"),nil];
//
//        _tb.imagesNormal = [NSArray arrayWithObjects:@"news_normal",@"group_chat_normal",@"ALOGO_120",@"find_normal",@"me_normal",nil];
//        _tb.imagesSelect = [NSArray arrayWithObjects:@"news_press_gray",@"group_chat_press_gray",@"ALOGO_120",@"find_press_gray",@"me_press_gray",nil];
//    }else{
    
    //djkmark

    
          NSString * tempstr = g_config.researchSwitch;
    BOOL isOpen = [tempstr boolValue];
    NSLog(@"----%d",isOpen);
    
    if (isOpen) {
        _tb.items = [NSArray arrayWithObjects:Localized(@"JXMainViewController_Message"),Localized(@"JX_MailList"),@"鲸鱼",@"探索",Localized(@"JX_My"),nil];
        
        _tb.imagesNormal = [NSArray arrayWithObjects:@"news_normal",@"group_chat_normal",@"jktab_mormal",@"find_normal",@"me_normal",nil];
        _tb.imagesSelect = [NSArray arrayWithObjects:@"news_press_gray",@"group_chat_press_gray",@"jktab_select",@"find_press_gray",@"me_press_gray",nil];

    }else{
        _tb.items = [NSArray arrayWithObjects:Localized(@"JXMainViewController_Message"),Localized(@"JX_MailList"),@"探索",Localized(@"JX_My"),nil];
        
        _tb.imagesNormal = [NSArray arrayWithObjects:@"news_normal",@"group_chat_normal",@"find_normal",@"me_normal",nil];
        _tb.imagesSelect = [NSArray arrayWithObjects:@"news_press_gray",@"group_chat_press_gray",@"find_press_gray",@"me_press_gray",nil];

    }
//    }

    
    _tb.delegate  = self;
    _tb.onDragout = @selector(onDragout:);
    [_tb setBackgroundImageName:@"MessageListCellBkg"];
    _tb.onClick  = @selector(actionSegment:);
    _tb = [_tb initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_BOTTOM)];
    [_bottomView addSubview:_tb];
    
    
    NSMutableArray *remindArray = [[JXBlogRemind sharedInstance] doFetchUnread];
    [_tb setBadge:2 title:[NSString stringWithFormat:@"%lu",(unsigned long)remindArray.count]];
}


-(void)actionSegment:(UIButton*)sender{
    [self doSelected:(int)sender.tag];
}

//djkmark
-(void)doSelected:(int)n{
    [_selectVC.view removeFromSuperview];
    
    NSString * tempstr = g_config.researchSwitch;
BOOL isOpen = [tempstr boolValue];
NSLog(@"----%d",isOpen);

if (isOpen) {
    switch (n){
            //djk判断
            
            
        case 0:
            _selectVC = _msgVc;
            break;
        case 1:
            _selectVC = _friendVC;
            break;
        case 2:
            _selectVC = _jkWebVC;
            break;
        case 3:
#ifdef IS_SHOW_MENU
            _selectVC = _squareVC;
#else
            _selectVC = _weiboVC;
#endif
            break;
        case 4:
            _selectVC = _psMyviewVC;
            break;
   
    }
}else{
    switch (n){
            //djk判断
            
            
        case 0:
            _selectVC = _msgVc;
            break;
        case 1:
            _selectVC = _friendVC;
            break;
        case 2:
#ifdef IS_SHOW_MENU
            _selectVC = _squareVC;
#else
            _selectVC = _weiboVC;
#endif
            break;
        case 3:
            _selectVC = _psMyviewVC;
            break;
   
    }
}

    [_tb selectOne:n];
    [_mainView addSubview:_selectVC.view];
}

-(void)onXmppLoginChanged:(NSNumber*)isLogin{
    if([JXXMPP sharedInstance].isLogined == login_status_yes){
        // 获取离线调用接口列表
        [g_server offlineOperation:(g_server.lastOfflineTime *1000 + g_server.timeDifference)/1000 toView:self];
        [self onAfterLogin];
        
    }
    switch (_tb.selected){
        case 0:
            _btn.hidden = [JXXMPP sharedInstance].isLogined;
            break;
        case 1:
            _btn.hidden = ![JXXMPP sharedInstance].isLogined;
            break;
        case 2:
            _btn.hidden = NO;
            break;
        case 3:
            _btn.hidden = ![JXXMPP sharedInstance].isLogined;
            break;
    }
}

-(void)onAfterLogin{
//    [_msgVc scrollToPageUp];
}

-(void)hasLoginOther:(NSNotification *)notifcation{
    // 自动登录失败后要清除token ，不然会影响到手动登录
    g_server.access_token = nil;
    [g_default removeObjectForKey:kMY_USER_TOKEN];
    [share_defaults removeObjectForKey:kMY_ShareExtensionToken];

    [g_App showAlert:Localized(@"JXXMPP_Other") delegate:self tag:10002 onlyConfirm:YES];
}

- (void)showDeviceAuth:(NSNotification *)notification{
    JXMessageObject *msg = notification.object;
    JXDeviceAuthController *authCon = [[JXDeviceAuthController alloc] initWithMsg:msg];
//    [self presentViewController:authCon animated:YES completion:nil];
    UIViewController *lastVC = (UIViewController *)g_navigation.subViews.lastObject;
    authCon.modalPresentationStyle = UIModalPresentationFullScreen;
    [lastVC presentViewController:authCon animated:YES completion:nil];
}


-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    //更新本地好友
    if ([aDownload.action isEqualToString:act_AttentionList]) {
        JXProgressVC * pv = [JXProgressVC alloc];
        pv.dbFriends = (long)[_friendArray count];
        pv.dataArray = array1;
        pv = [pv init];
        if (array1.count > 300) {
            [g_navigation pushViewController:pv animated:YES];
        }
//        [self.view addSubview:pv.view];
        
    }
    
    // 同步标签
    if ([aDownload.action isEqualToString:act_FriendGroupList]) {
        
        for (NSInteger i = 0; i < array1.count; i ++) {
            NSDictionary *dict = array1[i];
            JXLabelObject *labelObj = [[JXLabelObject alloc] init];
            labelObj.groupId = dict[@"groupId"];
            labelObj.groupName = dict[@"groupName"];
            labelObj.userId = dict[@"userId"];
            
            NSArray *userIdList = dict[@"userIdList"];
            NSString *userIdListStr = [userIdList componentsJoinedByString:@","];
            if (userIdListStr.length > 0) {
                labelObj.userIdList = [NSString stringWithFormat:@"%@", userIdListStr];
            }
            [labelObj insert];
        }
        
        // 删除服务器上已经删除的
        NSArray *arr = [[JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
        for (NSInteger i = 0; i < arr.count; i ++) {
            JXLabelObject *locLabel = arr[i];
            BOOL flag = NO;
            for (NSInteger j = 0; j < array1.count; j ++) {
                NSDictionary * dict = array1[j];
               
                if ([locLabel.groupId isEqualToString:dict[@"groupId"]]) {
                    flag = YES;
                    break;
                }
            }
            
            if (!flag) {
                [locLabel delete];
            }
        }
    }
    if ([aDownload.action isEqualToString:act_offlineOperation]) {
        for (NSDictionary *dict in array1) {
            if ([[dict objectForKey:@"tag"] isEqualToString:@"label"]) {
                [g_notify postNotificationName:kOfflineOperationUpdateLabelList object:nil];
            }
            else if ([[dict objectForKey:@"tag"] isEqualToString:@"friend"]) {
                [g_server getUser:[dict objectForKey:@"friendId"] toView:self];
            }
            else if ([[dict objectForKey:@"tag"] isEqualToString:@"room"]) {
                [g_server getRoom:[dict objectForKey:@"friendId"] toView:self];
            }
        }
    }
    if ([aDownload.action isEqualToString:act_UserGet]) {
        JXUserObject *user = [[JXUserObject alloc] init];
        [user getDataFromDict:dict];
        
        if ([user.userId intValue] == [g_myself.userId intValue]) {
            [g_server doSaveUser:dict];
        }else {
            JXUserObject *user1 = [[JXUserObject sharedInstance] getUserById:user.userId];
            user.content = user1.content;
            user.timeSend = user1.timeSend;
            user.publicKeyDH = user1.publicKeyDH;
            user.publicKeyRSARoom = user1.publicKeyRSARoom;
            user.chatKeyGroup = user1.chatKeyGroup;
            user.isSecretGroup = user1.isSecretGroup;
            user.isLostChatKeyGroup = user1.isLostChatKeyGroup;
            user.msgsNew = user1.msgsNew;
            [user update];
        }
        
        [g_notify postNotificationName:kOfflineOperationUpdateUserSet object:user];
        
        [self loginSynchronizeFriends:nil];
    }
    if ([aDownload.action isEqualToString:act_roomGet]) {
        JXUserObject *user = [[JXUserObject alloc] init];
        [user getDataFromDict:dict];
        user.userId = [dict objectForKey:@"jid"];
        user.roomId = [dict objectForKey:@"id"];
        user.userNickname = [dict objectForKey:@"name"];

        NSDictionary *member = [dict objectForKey:@"member"];

        if(![user haveTheUser]){
            user.userDescription = [dict objectForKey:@"desc"];
            user.showRead = [dict objectForKey:@"showRead"];
            user.showMember = [dict objectForKey:@"showMember"];
            user.allowSendCard = [dict objectForKey:@"allowSendCard"];
            user.chatRecordTimeOut = [dict objectForKey:@"chatRecordTimeOut"];
            user.talkTime = [dict objectForKey:@"talkTime"];
            user.allowInviteFriend = [dict objectForKey:@"allowInviteFriend"];
            user.allowUploadFile = [dict objectForKey:@"allowUploadFile"];
            user.allowConference = [dict objectForKey:@"allowConference"];
            user.allowSpeakCourse = [dict objectForKey:@"allowSpeakCourse"];
            
            user.offlineNoPushMsg = [(NSDictionary *)[dict objectForKey:@"member"] objectForKey:@"offlineNoPushMsg"];
        
            user.isNeedVerify = [dict objectForKey:@"isNeedVerify"];
            user.createUserId = [dict objectForKey:@"userId"];
            user.content = @" ";
            user.topTime = nil;
            
#ifdef IS_MsgEncrypt
            if ([g_config.isOpenSecureChat boolValue]) {
                if ([member objectForKey:@"chatKeyGroup"]) {
                    
                    if (![user.isLostChatKeyGroup boolValue]) {
                        SecKeyRef priKey = [g_securityUtil getRSAKeyWithBase64Str:g_msgUtil.rsaPrivateKey isPrivateKey:YES];
                        NSString *chatKeyGroup = [member objectForKey:@"chatKeyGroup"];
                        if (priKey) {NSData *chatKeyData = [[NSData alloc] initWithBase64EncodedString:chatKeyGroup options:NSDataBase64DecodingIgnoreUnknownCharacters];
                            NSData *deData = [g_securityUtil decryptMessageRSA:chatKeyData withPrivateKey:priKey];
                            chatKeyGroup = [[NSString alloc] initWithData:deData encoding:NSUTF8StringEncoding];
                        }else {
                            chatKeyGroup = nil;
                        }
                        
                        // 解密秘钥失败，群组置为丢失秘钥状态，并发送804消息，请求秘钥
                        if (!chatKeyGroup || chatKeyGroup.length <= 0) {
                            
                            if (![user.isLostChatKeyGroup boolValue]) {
                                
                                user.isLostChatKeyGroup = [NSNumber numberWithBool:YES];
                                [user updateLostChatKeyGroup];
                                
                                JXMessageObject *msg = [[JXMessageObject alloc] init];
                                msg.fromUserId = g_myself.userId;
                                msg.fromUserName = g_myself.userNickname;
                                msg.toUserId = user.userId;
                                msg.objectId = user.userId;
                                msg.timeSend = [NSDate date];
                                msg.type = [NSNumber numberWithInt:kWCMessageTypeChatKeyGroupRequest];
                                SecKeyRef priKey = [g_securityUtil getRSAKeyWithBase64Str:g_msgUtil.rsaPrivateKey isPrivateKey:YES];
                                msg.content = [g_securityUtil getSignWithRSA:user.userId withPriKey:priKey];
                                [msg insert:user.userId];
                                [msg updateLastSend:UpdateLastSendType_None];
                                [g_xmpp sendMessage:msg roomName:user.userId];
                                
                            }
                            
                        }else {
                            
                            NSString *enKey = [g_msgUtil encryptRoomMsgKey:user.roomId randomKey:chatKeyGroup];
                            if (enKey && enKey.length > 0) {
                                user.chatKeyGroup = enKey;
                                // 更新最新的群组秘钥
                                [user updateChatKeyGroup];
                            }
                        }
                    }
                    
                }
            }
#endif
            
            
            [user insertRoom];
            [g_xmpp.roomPool joinRoom:user.userId title:user.userNickname lastDate:nil isNew:NO];
        }else {
            
            NSDictionary * groupDict = [user toDictionary];
            roomData * roomdata = [[roomData alloc] init];
            [roomdata getDataFromDict:groupDict];
            [roomdata getDataFromDict:dict];

            JXUserObject *user1 = [[JXUserObject sharedInstance] getUserById:roomdata.roomJid];
            user.content = user1.content;
            user.timeSend = user1.timeSend;
            user.status = user1.status;
            user.type = user1.type;
            user.offlineNoPushMsg = [NSNumber numberWithBool:roomdata.offlineNoPushMsg];
            user.msgsNew = user1.msgsNew;
            user.encryptType = user1.encryptType;
            user.isLostChatKeyGroup = user1.isLostChatKeyGroup;

            [user update];
            
            if (![g_xmpp.roomPool getRoom:user.userId]) {
                
                [g_xmpp.roomPool joinRoom:user.userId title:user.userNickname lastDate:nil isNew:NO];
            }
#ifdef IS_MsgEncrypt
            if ([g_config.isOpenSecureChat boolValue]) {
                if ([member objectForKey:@"chatKeyGroup"]) {
                    
                    if (![user.isLostChatKeyGroup boolValue]) {
                        SecKeyRef priKey = [g_securityUtil getRSAKeyWithBase64Str:g_msgUtil.rsaPrivateKey isPrivateKey:YES];
                        NSString *chatKeyGroup = [member objectForKey:@"chatKeyGroup"];
                        if (priKey) {NSData *chatKeyData = [[NSData alloc] initWithBase64EncodedString:chatKeyGroup options:NSDataBase64DecodingIgnoreUnknownCharacters];
                            NSData *deData = [g_securityUtil decryptMessageRSA:chatKeyData withPrivateKey:priKey];
                            chatKeyGroup = [[NSString alloc] initWithData:deData encoding:NSUTF8StringEncoding];
                        }else {
                            chatKeyGroup = nil;
                        }
                        
                        // 解密秘钥失败，群组置为丢失秘钥状态，并发送804消息，请求秘钥
                        if (!chatKeyGroup || chatKeyGroup.length <= 0) {
                            
                            if (![user.isLostChatKeyGroup boolValue]) {
                                
                                user.isLostChatKeyGroup = [NSNumber numberWithBool:YES];
                                [user updateLostChatKeyGroup];
                                
                                JXMessageObject *msg = [[JXMessageObject alloc] init];
                                msg.fromUserId = g_myself.userId;
                                msg.fromUserName = g_myself.userNickname;
                                msg.toUserId = user.userId;
                                msg.objectId = user.userId;
                                msg.timeSend = [NSDate date];
                                msg.type = [NSNumber numberWithInt:kWCMessageTypeChatKeyGroupRequest];
                                SecKeyRef priKey = [g_securityUtil getRSAKeyWithBase64Str:g_msgUtil.rsaPrivateKey isPrivateKey:YES];
                                msg.content = [g_securityUtil getSignWithRSA:user.userId withPriKey:priKey];
                                [msg insert:user.userId];
                                [msg updateLastSend:UpdateLastSendType_None];
                                [g_xmpp sendMessage:msg roomName:user.userId];
                                
                            }
                            
                        }else {
                            
                            NSString *enKey = [g_msgUtil encryptRoomMsgKey:user.roomId randomKey:chatKeyGroup];
                            if (enKey && enKey.length > 0) {
                                user.chatKeyGroup = enKey;
                                // 更新最新的群组秘钥
                                [user updateChatKeyGroup];
                            }
                        }
                    }
                    
                }
            }
#endif
            
        }
        
        [g_notify postNotificationName:kOfflineOperationUpdateUserSet object:user];
    }

}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    if ([aDownload.action isEqualToString:act_UserGet]) {
        
        [self loginSynchronizeFriends:nil];
    }
    return hide_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    if ([aDownload.action isEqualToString:act_UserGet]) {
        
        [self loginSynchronizeFriends:nil];
    }
    return hide_error;
}

@end

