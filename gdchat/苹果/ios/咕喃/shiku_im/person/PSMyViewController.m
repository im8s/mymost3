//
//  myViewController.m
//  sjvodios
//
//  Created by  on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PSMyViewController.h"
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
#import "PSRegisterBaseVC.h"
#import "photosViewController.h"
#import "JXSettingVC.h"
#import "PSUpdateUserVC.h"
#import "OrganizTreeViewController.h"
#import "JXCourseListVC.h"
#import "JXMyMoneyViewController.h"
#import "JXNearVC.h"
#import "JXSelFriendVC.h"
#import "JXSelectFriendsVC.h"
#ifdef Meeting_Version
#import "JXAVCallViewController.h"
#endif

#ifdef Live_Version
#import "JXLiveViewController.h"
#endif

#import "JXFriendViewController.h"
#import "JXGroupViewController.h"
#import "UIImage+Color.h"
#import "JXScanQRViewController.h"
#import "JXMyWalletVC.h"
#import "UIView+Frame.h"
#define HEIGHT 55
#define MY_INSET  0  // 每行左右间隙
#define TOP_ADD_HEIGHT  400  // 顶部添加的高度，防止下拉顶部空白

@implementation PSMyViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.isRefresh = NO;
        self.title = Localized(@"JX_My");
        self.heightHeader = 0;
        self.heightFooter = JX_SCREEN_BOTTOM;

        [self createHeadAndFoot];
        self.tableBody.backgroundColor = RGB(237, 237, 237);

        int h=-20;
        int w=JX_SCREEN_WIDTH;
        
        float marginHei = 10;
        
        int H = 86;

        JXImageView* iv;
        iv = [self createHeadButtonclick:@selector(onResume)];
        _topImageVeiw = iv;
//        CGFloat height = THE_DEVICE_HAVE_HEAD ? 55 : 75;
//        if (THESIMPLESTYLE) {
//            iv.frame = CGRectMake(0, h-TOP_ADD_HEIGHT, w, 266+TOP_ADD_HEIGHT-H+55);
//            h+=iv.frame.size.height-TOP_ADD_HEIGHT;
//        }else {
//            iv.frame = CGRectMake(0, h-TOP_ADD_HEIGHT, w, 266+TOP_ADD_HEIGHT-H);
//            h+=iv.frame.size.height-TOP_ADD_HEIGHT+ height;
//        }
        CGFloat topheight = THE_DEVICE_HAVE_HEAD ? -TOP_ADD_HEIGHT- 44 : -TOP_ADD_HEIGHT-20;
        iv.frame = CGRectMake(0, topheight, w, 85+JX_SCREEN_TOP-topheight);
        h = THE_DEVICE_HAVE_HEAD ?93+JX_SCREEN_TOP:103+JX_SCREEN_TOP;
        
        if ([g_config.enablePayModule boolValue]) {
            iv = [self createButton:Localized(@"JX_MyWallet") drawTop:NO drawBottom:NO icon:THESIMPLESTYLE ? @"balance_recharge_simple" : @"balance_recharge" click:@selector(onRecharge)];
            iv.frame = CGRectMake(MY_INSET,h, w-MY_INSET*2, HEIGHT);
            
            h+=iv.frame.size.height+8;
        }
        
        iv = [self createButton:Localized(@"JX_MyDynamics") drawTop:NO drawBottom:YES icon:THESIMPLESTYLE ? @"my_space_simple" : @"my_space" click:@selector(onMyBlog)];
        iv.frame = CGRectMake(MY_INSET,h, w-MY_INSET*2, HEIGHT);
        h+=iv.frame.size.height;
        
        iv = [self createButton:Localized(@"JX_MyCollection") drawTop:NO drawBottom:YES icon:THESIMPLESTYLE ? @"collection_me_simple" : @"collection_me" click:@selector(onMyFavorite)];
        iv.frame = CGRectMake(MY_INSET,h, w-MY_INSET*2, HEIGHT);
        h+=iv.frame.size.height;
        
//        iv = [self createButton:Localized(@"PSMyViewController_MyAtt") drawTop:NO drawBottom:YES icon:@"my_attachment" click:@selector(onVideo)];
//        iv.frame = CGRectMake(0,h, w, HEIGHT);
//        h+=iv.frame.size.height;
        
        iv = [self createButton:Localized(@"JX_MyLecture") drawTop:NO drawBottom:NO icon:THESIMPLESTYLE ? @"my_lecture_simple" : @"my_lecture" click:@selector(onCourse)];
        iv.frame = CGRectMake(MY_INSET,h, w-MY_INSET*2, HEIGHT);
        h+=iv.frame.size.height + 8;
        
//        iv = [self createButton:Localized(@"JXNearVC_NearHere") drawTop:NO drawBottom:YES icon:@"nearby_normal" click:@selector(onNear)];
//        iv.frame = CGRectMake(0,h, w, HEIGHT);
//        h+=iv.frame.size.height;

//#ifdef Live_Version
//        iv = [self createButton:Localized(@"OrganizVC_Organiz") drawTop:NO drawBottom:YES icon:@"my_organizBook" click:@selector(onOrganiz)];
//        iv.frame = CGRectMake(0,h, w, HEIGHT);
//        h+=iv.frame.size.height;
//#endif
        
        
//        iv = [self createButton:@"收藏职位" drawTop:NO drawBottom:YES icon:@"set_collect" click:@selector(onMoney)];
//        iv.frame = CGRectMake(0,h, w, HEIGHT);
//        h+=iv.frame.size.height;
        BOOL isShowLine = NO;
#ifdef IS_SHOW_MENU
#else
#ifdef Meeting_Version
        isShowLine = YES;
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(iv.frame), JX_SCREEN_WIDTH, marginHei)];
        line1.backgroundColor = HEXCOLOR(0xF2F2F2);
        [_setBaseView addSubview:line1];
        iv = [self createButton:Localized(@"JXSettingVC_VideoMeeting") drawTop:NO drawBottom:YES icon:THESIMPLESTYLE ? @"videomeeting_simple" : @"videomeeting" click:@selector(onMeeting)];
        iv.frame = CGRectMake(0,h, w, HEIGHT);
        h+=iv.frame.size.height;
        isShowLine = NO;
#else
        isShowLine = YES;
#endif
        
#ifdef Live_Version
        if ([g_App.isShowRedPacket intValue] == 1 ) {
            if (!isShowLine) {
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(iv.frame), JX_SCREEN_WIDTH, marginHei)];
                line.backgroundColor = HEXCOLOR(0xF2F2F2);
                [_setBaseView addSubview:line];
            }
            
            UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(iv.frame), JX_SCREEN_WIDTH, marginHei)];
            line1.backgroundColor = HEXCOLOR(0xF2F2F2);
            [_setBaseView addSubview:line1];

            iv = [self createButton:Localized(@"JX_LiveDemonstration") drawTop:isShowLine drawBottom:NO icon:THESIMPLESTYLE ? @"videoshow_simple" : @"videoshow" click:@selector(onLive)];
            iv.frame = CGRectMake(0,h, w, HEIGHT);
            h+=iv.frame.size.height + marginHei;
        }
        isShowLine = YES;
#else
        isShowLine = NO;
#endif

#endif
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(iv.frame), JX_SCREEN_WIDTH, marginHei)];
        line.backgroundColor = HEXCOLOR(0xF2F2F2);
        [_setBaseView addSubview:line];

        iv = [self createButton:Localized(@"JXSettingVC_Set") drawTop:NO drawBottom:NO icon:THESIMPLESTYLE ? @"set_up_simple" : @"set_up" click:@selector(onSetting)];
        iv.frame = CGRectMake(MY_INSET,h, w-MY_INSET*2, HEIGHT);
//        h+=iv.frame.size.height;
        CGRect frame = _setBaseView.frame;
        frame.size.height = CGRectGetMaxY(iv.frame);
        _setBaseView.frame = frame;
        
        if ((h + HEIGHT + 20) > self.tableBody.frame.size.height) {
            self.tableBody.contentSize = CGSizeMake(self_width, CGRectGetMaxY(_setBaseView.frame) + 20);
        }
        
        [g_notify addObserver:self selector:@selector(doRefresh:) name:kUpdateUserNotifaction object:nil];
//        [g_notify addObserver:self selector:@selector(updateUserInfo:) name:kXMPPMessageUpadteUserInfoNotification object:nil];
        [g_notify addObserver:self selector:@selector(doRefresh:) name:kOfflineOperationUpdateUserSet object:nil];

        //获取用户余额
        [g_server getUserMoenyToView:self];
    }
    return self;
}

- (void)updateUserInfo:(NSNotification *)noti {
    [g_server getUser:g_server.myself.userId toView:self];
}

-(void)dealloc{
    NSLog(@"PSMyViewController.dealloc");
    [g_notify removeObserver:self name:kUpdateUserNotifaction object:nil];
    [g_notify removeObserver:self name:kXMPPMessageUpadteUserInfoNotification object:nil];
    [g_notify removeObserver:self name:kOfflineOperationUpdateUserSet object:nil];
//    [_image release];
//    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

//设置状态栏颜色
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self doRefresh:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if (_friendLabel) {
         NSArray *friends = [[JXUserObject sharedInstance] fetchAllUserFromLocal];
        _friendLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)friends.count];
    }
    if (_groupLabel) {
        NSArray *groups = [[JXUserObject sharedInstance] fetchAllRoomsFromLocal];
        _groupLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)groups.count];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
#ifdef XCode11
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
#else
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.isRefresh) {
        self.isRefresh = NO;
    }else{
        [super viewDidAppear:animated];
        
    }

}

-(void)doRefresh:(NSNotification *)notifacation{
    _head.image = nil;
     __weak typeof(self) weakSelf = self;
//    [g_server getHeadImageSmall:g_server.myself.userId userName:g_server.myself.userNickname imageView:_head getHeadHandler:^(BOOL isRoom, UIImage *image, NSError *error) {
//           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            weakSelf.head.image = image;
//        });
//    }];
    //获取用户余额
//    [g_server getUserMoenyToView:self];
    _userName.text = g_server.myself.userNickname;
    _userDesc.text = [NSString stringWithFormat:@"通讯号:%@",g_server.myself.account];
    [g_server getUser:g_server.myself.userId toView:self];
//    _moneyLabel.text = [NSString stringWithFormat:@"%.2f%@",g_App.myMoney,Localized(@"JX_ChinaMoney")];
}

//-(void)refreshUserDetail{
//    _moneyLabel.text = [NSString stringWithFormat:@"%.2f%@",g_App.myMoney,Localized(@"JX_ChinaMoney")];
//}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//服务端返回数据
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
        [_wait hide];
    
    if( [aDownload.action isEqualToString:act_resumeList] ){
    }
    if( [aDownload.action isEqualToString:act_UserGet] ){
        JXUserObject* user = [[JXUserObject alloc]init];
        [user getDataFromDict:dict];
        
        g_server.myself.userNickname = user.userNickname;
        NSRange range = [user.telephone rangeOfString:@"86"];
        if (range.location != NSNotFound) {
            g_server.myself.telephone = [user.telephone substringFromIndex:range.location + range.length];
        }
        
        if (self.isGetUser) {
            self.isGetUser = NO;
            PSUpdateUserVC* vc = [PSUpdateUserVC alloc];
            vc.headImage = [_head.image copy];
            vc.user = user;
            vc = [vc init];
            [g_navigation pushViewController:vc animated:YES];
            return;
        }
        
        _userName.text = user.userNickname;
        [g_server delHeadImage:g_server.myself.userId];
        self.head.image = nil;
         __weak typeof(self) weakSelf = self;
        [g_server getHeadImageSmall:g_server.myself.userId userName:g_server.myself.userNickname imageView:_head getHeadHandler:^(BOOL isRoom, UIImage *image, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.head.image = image;
            });
            
        }];

    }
    if ([aDownload.action isEqualToString:act_getUserMoeny]) {
        g_App.myMoney = [dict[@"balance"] doubleValue];
        _moneyLabel.text = [NSString stringWithFormat:@"%.2f%@",g_App.myMoney,Localized(@"JX_ChinaMoney")];
    }
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    if( [aDownload.action isEqualToString:act_UserGet] ){
        if (!self.isGetUser) {
            PSUpdateUserVC* vc = [PSUpdateUserVC alloc];
            vc.headImage = [_head.image copy];
            vc.user = g_server.myself;
            vc = [vc init];
            [g_navigation pushViewController:vc animated:YES];
        }
        
    }
    return hide_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    if( [aDownload.action isEqualToString:act_UserGet] ){
        if (!self.isGetUser) {
            PSUpdateUserVC* vc = [PSUpdateUserVC alloc];
            vc.headImage = [_head.image copy];
            vc.user = g_server.myself;
            vc = [vc init];
            [g_navigation pushViewController:vc animated:YES];
        }
    }

    return hide_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
//    [_wait start];
}

-(void)actionClear{
    [_wait start:Localized(@"PSMyViewController_Clearing") delay:100];
}

#ifdef Live_Version
// 直播
- (void)onLive {
    JXLiveViewController *vc = [[JXLiveViewController alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}
#endif

#ifdef Meeting_Version
// 视频会议
- (void)onMeeting {
    if(g_xmpp.isLogined != 1){
        [g_xmpp showXmppOfflineAlert];
        return;
    }
    
    NSString *str1;
    NSString *str2;

    str1 = Localized(@"JXSettingVC_VideoMeeting");
    str2 = Localized(@"JX_Meeting");

    JXActionSheetVC *actionVC = [[JXActionSheetVC alloc] initWithImages:@[@"meeting_tel",@"meeting_video"] names:@[str2,str1]];
    actionVC.delegate = self;
    [self presentViewController:actionVC animated:NO completion:nil];
}

- (void)actionSheet:(JXActionSheetVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    if (index == 0) {
        [self onGroupAudioMeeting:nil];
    }else if(index == 1){
        [self onGroupVideoMeeting:nil];
    }
}
-(void)onGroupAudioMeeting:(JXMessageObject*)msg{

    self.isAudioMeeting = 0;
    [self onInvite];
    //    [g_meeting startAudioMeeting:no roomJid:s];
}

-(void)onGroupVideoMeeting:(JXMessageObject*)msg{

    self.isAudioMeeting = 1;
    [self onInvite];
    //    [g_meeting startVideoMeeting:no roomJid:s];
}
-(void)onInvite{

    
    NSMutableSet* p = [[NSMutableSet alloc]init];
    
    JXSelectFriendsVC* vc = [JXSelectFriendsVC alloc];
    vc.isNewRoom = NO;
    vc.isShowMySelf = NO;
    vc.type = JXSelUserTypeSelFriends;
//    vc.room = _room;
    vc.existSet = p;
    vc.delegate = self;
    vc.didSelect = @selector(meetingAddMember:);
    vc = [vc init];
    //    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}
-(void)meetingAddMember:(JXSelectFriendsVC*)vc{
    int type;
    if (self.isAudioMeeting == 0) {
        type = kWCMessageTypeAudioMeetingInvite;
    }else if (self.isAudioMeeting == 1){
        type = kWCMessageTypeVideoMeetingInvite;
    }else{
        
    }
    for(NSNumber* n in vc.set){
        JXUserObject *user;
        if ([n intValue] / 1000000 == 9) {
            user = vc.searchArray[[n intValue] % 9000000-1];
        }else{
            user = [[vc.letterResultArr objectAtIndex:[n intValue] / 100000-1] objectAtIndex:[n intValue] % 100000-1];
        }
        NSString* s = [NSString stringWithFormat:@"%@",user.userId];
        [g_meeting sendMeetingInvite:s toUserName:user.userNickname roomJid:MY_USER_ID callId:nil type:type];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (g_meeting.isMeeting) {
            return;
        }
        JXAVCallViewController *avVC = [[JXAVCallViewController alloc] init];
        avVC.roomNum = MY_USER_ID;
        avVC.isAudio = self.isAudioMeeting;
        avVC.isGroup = YES;
        avVC.toUserName = MY_USER_NAME;
        avVC.view.frame = [UIScreen mainScreen].bounds;
        [g_window addSubview:avVC.view];
        
    });
    
}
#endif


-(void)onMyBlog{
    userWeiboVC* vc = [userWeiboVC alloc];
    vc.user = g_myself;
    vc.isGotoBack = YES;
    vc = [vc init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];

}
-(void)onNear{
    JXNearVC * nearVc = [[JXNearVC alloc] init];
//    [g_window addSubview:nearVc.view];
    [g_navigation pushViewController:nearVc animated:YES];
}
-(void)onFriend{
    JXFriendViewController* vc = [[JXFriendViewController alloc]init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onResume{
    self.isGetUser = YES;
    [g_server getUser:MY_USER_ID toView:self];
}

-(void)onSpace{
//    mySpaceViewController* vc = [[mySpaceViewController alloc]init];
//    [g_window addSubview:vc.view];
}

-(void)onVideo{
    myMediaVC* vc = [[myMediaVC alloc] init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}
-(void)onMyFavorite{
    WeiboViewControlle * collection = [[WeiboViewControlle alloc] initCollection];
    
//    [g_window addSubview:collection.view];
    [g_navigation pushViewController:collection animated:YES];
}

- (void)onCourse {
    JXCourseListVC *vc = [[JXCourseListVC alloc] init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onRecharge{
    if ([g_config.isOpenCloudWallet intValue] == 0) {
        JXMyMoneyViewController * moneyVC = [[JXMyMoneyViewController alloc] init];
        [g_navigation pushViewController:moneyVC animated:YES];
    }else{
        JXMyWalletVC * moneyVC = [[JXMyWalletVC alloc] init];
    //    [g_window addSubview:moneyVC.view];
        [g_navigation pushViewController:moneyVC animated:YES];
    }
}

-(void)onOrganiz{
    OrganizTreeViewController * organizVC = [[OrganizTreeViewController alloc] init];
//    [g_window addSubview:organizVC.view];
    [g_navigation pushViewController:organizVC animated:YES];
}
-(void)onMyLove{
    
}

-(void)onMoney{
}

-(void)onSetting{
    JXSettingVC* vc = [[JXSettingVC alloc]init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)onAdd {
    JX_SelectMenuView *menuView = [[JX_SelectMenuView alloc] initWithTitle:@[Localized(@"JX_SendImage"),Localized(@"JX_SendVoice"),Localized(@"JX_SendVideo"),Localized(@"JX_SendFile")]image:@[@"menu_add_msg",@"menu_add_voice",@"menu_add_video",@"menu_add_file",@"menu_add_reply"]cellHeight:45];
    menuView.delegate = self;
    [g_App.window addSubview:menuView];
}

- (void)didMenuView:(JX_SelectMenuView *)MenuView WithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        case 1:
        case 2:
        case 3:{
            addMsgVC* vc = [[addMsgVC alloc] init];
            vc.dataType = (int)index + 2;
            [g_navigation pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}


-(JXImageView*)createHeadButtonclick:(SEL)click{
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.delegate = self;
    [self.tableBody addSubview:btn];

    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, TOP_ADD_HEIGHT, JX_SCREEN_WIDTH, 115+JX_SCREEN_TOP)];
    baseView.backgroundColor = [UIColor whiteColor];
    [btn addSubview:baseView];
    
//    // 头像阴影
//    JXImageView *shadow = [[JXImageView alloc]initWithFrame:CGRectMake(13, (baseView.frame.size.height-84)/2-5, 100, 100)];
//    shadow.image = [UIImage imageNamed:@"my_icon_shadow"];
//    shadow.didTouch = @selector(onResume);
//    shadow.delegate = self;
//    [baseView addSubview:shadow];
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-20-18, THE_DEVICE_HAVE_HEAD ? 59-20+38 : 35-20+38, 20, 16)];
    [addBtn setImage:[UIImage imageNamed:@"my_camera"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(onAdd) forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:addBtn];

    //头像
    _head = [[JXImageView alloc]initWithFrame:CGRectMake(20, JX_SCREEN_TOP + 32, 60, 60)];
    _head.layer.cornerRadius = 5;
    _head.layer.masksToBounds = YES;
//    _head.layer.borderWidth = 3.f;
//    _head.layer.borderColor = [UIColor whiteColor].CGColor;
//    _head.didTouch = @selector(onResume);
    _head.delegate = self;
    [baseView addSubview:_head];
    

    //名字Label
    UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_head.frame)+20, CGRectGetMinY(_head.frame)+3, 150, 22)];
    p.font = [UIFont systemFontOfSize:22 weight:UIFontWeightMedium];
    p.text = MY_USER_NAME;
    p.textColor = RGB(20, 20, 20);
    p.backgroundColor = [UIColor clearColor];
    [baseView addSubview:p];
    _userName = p;
    
    //电话Label
    p = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(p.frame), CGRectGetMaxY(p.frame)+12, 200, 14)];
    p.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
    p.text = [NSString stringWithFormat:@"通讯号:%@",g_server.myself.account];
    p.textColor = RGB(117, 117, 117);
    p.backgroundColor = [UIColor clearColor];
    [baseView addSubview:p];
    _userDesc = p;
    
    UIImageView* qrImgV = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-20-35, _userDesc.top+0.5, 13, 13)];
    qrImgV.image = [UIImage imageNamed:@"qrcodeImage"];
    [baseView addSubview:qrImgV];

    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15-6, qrImgV.top, 7, 13)];
    iv.image = [UIImage imageNamed:@"new_icon_>"];
    [baseView addSubview:iv];
    
    return btn;
}

// 画圆角
- (void)setPartRoundWithView:(UIView *)view corners:(UIRectCorner)corners cornerRadius:(float)cornerRadius {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)].CGPath;
    view.layer.mask = shapeLayer;
}


- (void)onColleagues:(UITapGestureRecognizer *)tap {
    // 防止好友、群组同时调用
    if (_isSelected)
        return;
    _isSelected = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _isSelected = NO;
    });
    switch (tap.view.tag) {
        case 0:{
            JXFriendViewController *friendVC = [JXFriendViewController alloc];
            friendVC.isMyGoIn = YES;
            friendVC = [friendVC  init];
            [g_navigation pushViewController:friendVC animated:YES];
        }
            break;
        case 1:{
            JXGroupViewController *groupVC = [[JXGroupViewController alloc] init];
            [g_navigation pushViewController:groupVC animated:YES];
        }
            break;
        default:
            break;
    }

}

- (UIButton *)createViewWithFrame:(CGRect)frame title:(NSString *)title icon:(NSString *)icon index:(CGFloat)index showLine:(BOOL)isShow{
    UIButton *view = [[UIButton alloc] init];
    [view setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [view setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xF6F5FA)] forState:UIControlStateHighlighted];
    view.frame = frame;
    view.tag = index;
    [self.tableBody addSubview:view];

    int imgH = 40.5;
    UIImageView *imgV = [[UIImageView alloc] init];
    imgV.frame = CGRectMake((view.frame.size.width-imgH)/2, (view.frame.size.height-imgH-15-3)/2, imgH, imgH);
    imgV.image = [UIImage imageNamed:icon];
    [view addSubview:imgV];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, CGRectGetMaxY(imgV.frame)+3, view.frame.size.width, 15);
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = SYSFONT(15);
    label.textColor = HEXCOLOR(0x323232);
    [view addSubview:label];
    if (index == 0) {
        _friendLabel = label;
    }else {
        _groupLabel = label;
    }
    if (isShow) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(view.frame.size.width-LINE_WH, (view.frame.size.height-24)/2, LINE_WH, 24)];
        line.backgroundColor = THE_LINE_COLOR;
        [view addSubview:line];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onColleagues:)];
    [view addGestureRecognizer:tap];
    
    return view;
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
    p.font = [UIFont boldSystemFontOfSize:16];
    p.backgroundColor = [UIColor clearColor];
    p.textColor = RGB(20, 20, 20);
    [btn addSubview:p];

    if(icon){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(15, (HEIGHT-25)/2, 25, 25)];
        iv.image = [UIImage imageNamed:icon];
        [btn addSubview:iv];
    }
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(53,0,JX_SCREEN_WIDTH-53,1)];
        line.backgroundColor = RGB(237, 237, 237);
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(53,HEIGHT-1,JX_SCREEN_WIDTH-53,1)];
        line.backgroundColor = RGB(237, 237, 237);
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
//内存泄漏，为啥？
-(void)onHeadImage{
    [g_server delHeadImage:g_myself.userId];
    
    JXImageScrollVC * imageVC = [[JXImageScrollVC alloc]init];
    
    imageVC.imageSize = CGSizeMake(JX_SCREEN_WIDTH, JX_SCREEN_WIDTH);
    
    imageVC.iv = [[JXImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_WIDTH)];
    
    imageVC.iv.center = imageVC.view.center;
    
    [g_server getHeadImageLarge:g_myself.userId userName:g_myself.userNickname imageView:imageVC.iv getHeadHandler:nil];
    
    [self addTransition:imageVC];
    
    imageVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:imageVC animated:YES completion:^{
        self.isRefresh = YES;
    
    }];
    
//    [imageVC release];
    
    

}

- (void)setupView:(UIView *)view colors:(NSArray *)colors {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 266+TOP_ADD_HEIGHT-86);  // 设置显示的frame
    gradientLayer.colors = colors;  // 设置渐变颜色
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 0);
    [view.layer addSublayer:gradientLayer];
}


//添加VC转场动画
- (void) addTransition:(JXImageScrollVC *) siv
{
    self.scaleTransition = [[DMScaleTransition alloc]init];
    [siv setTransitioningDelegate:self.scaleTransition];
    
}

//-(void)onSearch{
//    JXNearVC* vc = [[JXNearVC alloc] init];
//    [g_window addSubview:vc.view];
//    [vc onSearch];
//}

@end
