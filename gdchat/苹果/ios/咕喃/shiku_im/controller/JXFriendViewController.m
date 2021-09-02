//
//  JXFriendViewController.h.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXFriendViewController.h"
#import "JXChatViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "JXImageView.h"
#import "JXCell.h"
#import "JXRoomPool.h"
#import "JXTableView.h"
#import "JXNewFriendViewController.h"
#import "menuImageView.h"
#import "FMDatabase.h"
#import "JXProgressVC.h"
#import "JXTopSiftJobView.h"
#import "JXUserInfoVC.h"
#import "BMChineseSort.h"
#import "JXGroupViewController.h"
#import "OrganizTreeViewController.h"
#import "JXTabMenuView.h"
#import "JXPublicNumberVC.h"
#import "JXBlackFriendVC.h"
#import "JX_DownListView.h"
#import "JXNewRoomVC.h"
#import "JXNearVC.h"
#import "JXSearchUserVC.h"
#import "JXScanQRViewController.h"
#import "JXLabelVC.h"
#import "JXAddressBookVC.h"
#import "JXSearchVC.h"
#import "JXLabelObject.h"
#import "UIView+Frame.h"
#import "JXPayViewController.h"
#import "JXFaceCreateRoomVC.h"
#import "JXFriendTableViewCell.h"
#define HEIGHT 57
#define IMAGE_HEIGHT  45  // 图片宽高
#define INSET_HEIGHT  10  // 图片文字间距


@interface JXFriendViewController ()<UITextFieldDelegate,JXSelectMenuViewDelegate>
{
    NSInteger JKNum;
}
@property (nonatomic, strong) JXUserObject * currentUser;
//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;


@property (nonatomic, strong) UITextField *seekTextField;
@property (nonatomic, strong) NSMutableArray *searchArray;

@property (nonatomic, strong) UILabel *friendNewMsgNum;
@property (nonatomic, strong) UILabel *abNewMsgNum;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UIView *menuView;

@property (nonatomic, assign) CGFloat btnHeight;  // 按钮的真实高度
@property (nonatomic, strong)NSArray *iconArray;
@property (nonatomic, strong)NSArray *titleArray;
@property (nonatomic, strong)NSArray *subTitleArray;

@end

@implementation JXFriendViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.isOneInit = YES;
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = JX_SCREEN_BOTTOM;
        if (_isMyGoIn) {
            self.isGotoBack   = YES;
            self.heightFooter = 0;
        }
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
//        self.view.frame = g_window.bounds;
        [self createHeadAndFoot];
        [self buildTop];
//        CGRect frame = self.tableView.frame;
//        frame.origin.y += 40;
//        frame.size.height -= 40;
//        self.tableView.frame = frame;
        [self customView];
        [self.tableView registerNib:[UINib nibWithNibName:@"JXFriendTableViewCell" bundle:nil] forCellReuseIdentifier:@"JXFriend"];
        self.iconArray = @[@"friend_newFriend",@"friend_public",@"friend_group_list",@"friend_device",@"friend_label"];
        self.titleArray = @[Localized(@"JXNewFriendVC_NewFirend"), Localized(@"JX_PublicNumber"),Localized(@"JX_ManyPerChat"),Localized(@"JX_MyDevices"),Localized(@"JX_Label")];
        
        self.subTitleArray = @[@"通过新的朋友添加搜索好友",@"关注知名公众号和搜索热门公众号",@"自己建立群组和已经加入的群组",@"自己的设备管理",@"可以标记好友的分类标签"];
        _selMenu = 0;
//        self.title = Localized(@"JXInputVC_Friend");
//        self.title = Localized(@"JX_MailList");
        [g_notify  addObserver:self selector:@selector(newFriend:) name:kXMPPNewFriendNotifaction object:nil];
        
        [g_notify addObserver:self selector:@selector(newRequest:) name:kXMPPNewRequestNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(newReceipt:) name:kXMPPReceiptNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(onSendTimeout:) name:kXMPPSendTimeOutNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(friendRemarkNotif:) name:kFriendRemark object:nil];
        
        [g_notify  addObserver:self selector:@selector(newMsgCome:) name:kXMPPNewMsgNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(friendListRefresh:) name:kFriendListRefresh object:nil];
        [g_notify addObserver:self selector:@selector(refreshABNewMsgCount:) name:kRefreshAddressBookNotif object:nil];
        [g_notify addObserver:self selector:@selector(contactRegisterNotif:) name:kMsgComeContactRegister object:nil];
        [g_notify addObserver:self selector:@selector(newRequest:) name:kFriendPassNotif object:nil];
        [g_notify addObserver:self selector:@selector(refresh) name:kOfflineOperationUpdateUserSet object:nil];
        [g_notify addObserver:self selector:@selector(updateLabels:) name:kXMPPMessageUpadtePasswordNotification object:nil];
    }
    return self;
}

- (void)updateLabels:(NSNotification *)noti {
    JXMessageObject *msg = noti.object;
    if ([msg.objectId isEqualToString:SYNC_LABEL]) {
        // 同步标签
        [g_server friendGroupListToView:self];
    }
}

- (void)friendListRefresh:(NSNotification *)notif {
    
    [self refresh];
}

- (void)contactRegisterNotif:(NSNotification *)notif {
    JXMessageObject *msg = notif.object;
    
    NSDictionary *dict = (NSDictionary *)msg.content;
    if ([msg.content isKindOfClass:[NSString class]]) {
        SBJsonParser * resultParser = [[SBJsonParser alloc] init] ;
        dict = [resultParser objectWithString:msg.content];
    }
    JXAddressBook *addressBook = [[JXAddressBook alloc] init];
    addressBook.toUserId = [NSString stringWithFormat:@"%@",dict[@"toUserId"]];
    addressBook.toUserName = dict[@"toUserName"];
    addressBook.toTelephone = dict[@"toTelephone"];
    addressBook.telephone = dict[@"telephone"];
    addressBook.registerEd = dict[@"registerEd"];
    addressBook.registerTime = [NSDate dateWithTimeIntervalSince1970:[dict[@"registerTime"] longLongValue]];
    addressBook.isRead = [NSNumber numberWithBool:0];
    [addressBook insert];
    
    [self refreshABNewMsgCount:nil];
}

- (void)refreshABNewMsgCount:(NSNotification *)notif {
    [self refresh];
    JXMsgAndUserObject* newobj = [[JXMsgAndUserObject alloc]init];
    newobj.user = [[JXUserObject sharedInstance] getUserById:FRIEND_CENTER_USERID];
    [self showNewMsgCount:[newobj.user.msgsNew integerValue]];
}

#pragma mark  接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation
{
    JXMessageObject *msg = notifacation.object;
    if (![msg isAddFriendMsg]) {
        return;
    }
    
    NSString* s;
    s = [msg getTableName];
    JXMsgAndUserObject* newobj = [[JXMsgAndUserObject alloc]init];
    newobj.user = [[JXUserObject sharedInstance] getUserById:s];
    [self showNewMsgCount:[newobj.user.msgsNew integerValue]];
    
}

- (void) showNewMsgCount:(NSInteger)friendNewMsgNum {
    if (friendNewMsgNum >= 10 && friendNewMsgNum <= 99) {
        self.friendNewMsgNum.font = SYSFONT(12);
    }else if (friendNewMsgNum > 0 && friendNewMsgNum < 10) {
        self.friendNewMsgNum.font = SYSFONT(13);
    }else if(friendNewMsgNum > 99){
        self.friendNewMsgNum.font = SYSFONT(9);
    }

    self.friendNewMsgNum.text = [NSString stringWithFormat:@"%ld",friendNewMsgNum];
    
    if (friendNewMsgNum <= 0) {
        self.friendNewMsgNum.hidden = YES;
    }else{
        self.friendNewMsgNum.hidden = NO;
    }
    
    NSMutableArray *abUread = [[JXAddressBook sharedInstance] doFetchUnread];
    if (abUread.count >= 10 && abUread.count <= 99) {
        self.friendNewMsgNum.font = SYSFONT(12);
    }else if (abUread.count > 0 && abUread.count < 10) {
        self.friendNewMsgNum.font = SYSFONT(13);
    }else if(abUread.count > 99){
        self.friendNewMsgNum.font = SYSFONT(9);
    }

    self.abNewMsgNum.text = [NSString stringWithFormat:@"%ld",abUread.count];
    if (abUread.count <= 0) {
        self.abNewMsgNum.hidden = YES;
    }else {
        self.abNewMsgNum.hidden = NO;
    }
    
    NSInteger num = friendNewMsgNum + abUread.count;
    if (num <= 0) {
        [g_mainVC.tb setBadge:1 title:@"0"];
    }else {
        [g_mainVC.tb setBadge:1 title:[NSString stringWithFormat:@"%ld", num]];
    }
    [self.tableView reloadRow:0 section:0];
}

-(void)newRequest:(NSNotification *)notifacation
{
    [self getFriend];
}

- (void)scrollToPageUp {
    [self getFriend];
}

-(void)buildTop{
    //刷新好友列表
//    UIButton * getFriendBtn = [[UIButton alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-35, JX_SCREEN_TOP - 34, 30, 30)];
//    getFriendBtn.custom_acceptEventInterval = .25f;
//    [getFriendBtn addTarget:self action:@selector(getFriend) forControlEvents:UIControlEventTouchUpInside];
////    [getFriendBtn setImage:[UIImage imageNamed:@"synchro_friends"] forState:UIControlStateNormal];
//    [getFriendBtn setBackgroundImage:[UIImage imageNamed:@"synchro_friends"] forState:UIControlStateNormal];
//    [self.tableHeader addSubview:getFriendBtn];
    
    NSInteger statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    UILabel *titleL = [[UILabel alloc]initWithFrame:CGRectMake(16, statusHeight, JX_SCREEN_WIDTH*0.5, 44)];
    titleL.text = @"通讯录";
    titleL.font = [UIFont boldSystemFontOfSize:22];
    [self.tableHeader addSubview: titleL];
    
    self.moreBtn = [UIFactory createButtonWithImage:@"im_003_more_button_black"
                                          highlight:nil
                                             target:self
                                           selector:@selector(onMore:)];
    self.moreBtn.custom_acceptEventInterval = 1.0f;
    self.moreBtn.frame = CGRectMake(JX_SCREEN_WIDTH - 25 -16, JX_SCREEN_TOP-34 , 25, 25);;
    [self.tableHeader addSubview:self.moreBtn];
}

- (void) customView {
    //顶部筛选控件
//    _topSiftView = [[JXTopSiftJobView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 40)];
//    _topSiftView.delegate = self;
//    _topSiftView.isShowMoreParaBtn = NO;
//    _topSiftView.dataArray = [[NSArray alloc] initWithObjects:Localized(@"JXInputVC_FriendList"),Localized(@"JX_BlackList"), nil];
//    //    _topSiftView.searchForType = SearchForPos;
//    [self.view addSubview:_topSiftView];
    
    //搜索输入框
    
        backView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 50)];
        backView.backgroundColor = [UIColor whiteColor];
        
//
//        [self createButton:nil superView:backView];
//        backView.clipsToBounds= YES;
        self.tableView.tableHeaderView = backView;
    //    [seekImgView release];
    
//    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(backView.frame.size.width-5-45, 5, 45, 30)];
//    [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
//    [cancelBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
//    [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    cancelBtn.titleLabel.font = SYSFONT(14.0);
//    [backView addSubview:cancelBtn];
    
    
    _seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, JX_SCREEN_WIDTH - 30, 35)];
    _seekTextField.placeholder = Localized(@"JX_Seach");
    _seekTextField.textColor = [UIColor blackColor];
    [_seekTextField setFont:SYSFONT(14)];
    _seekTextField.backgroundColor = RGB(239, 239, 239);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_search"]];
    UIView *leftView = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 40, 30)];
    imageView.frame = CGRectMake(15, 7.5, 15, 15);
    [leftView addSubview:imageView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(intoSearchView)];
    leftView.userInteractionEnabled = YES;
    [leftView addGestureRecognizer:tap];
    _seekTextField.leftView = leftView;
    _seekTextField.leftViewMode = UITextFieldViewModeAlways;
    _seekTextField.borderStyle = UITextBorderStyleNone;
    _seekTextField.layer.masksToBounds = YES;
    _seekTextField.layer.cornerRadius = 17.5;
    _seekTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _seekTextField.delegate = self;
    _seekTextField.returnKeyType = UIReturnKeyGoogle;
    [backView addSubview:_seekTextField];
    [_seekTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        JXMsgAndUserObject* newobj = [[JXMsgAndUserObject alloc]init];
        newobj.user = [[JXUserObject sharedInstance] getUserById:FRIEND_CENTER_USERID];
        [self showNewMsgCount:[newobj.user.msgsNew integerValue]];
        NSLog(@"------%ld",[newobj.user.msgsNew integerValue]);

        JKNum =[newobj.user.msgsNew integerValue];
        [self.tableView reloadData];

    });
//    _btnHeight = button.frame.size.height;
//    [self showMenuView];
    if (_isMyGoIn) {
        [self hideMenuView];
    }
    
    [self setFooterView];
    
}

- (void) setFooterView {
    
    if (_array.count > 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 44)];
        label.textColor = HEXCOLOR(0x999999);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = SYSFONT(16);
        label.text = [NSString stringWithFormat:@"%ld%@",_array.count,Localized(@"JX_ContactsNumber")];
        
        self.tableView.tableFooterView = label;
    }else {
        self.tableView.tableFooterView = nil;
    }
}

- (void)showMenuView { // 显示菜单栏
    _menuView.hidden = NO;
    CGRect backFrame = backView.frame;
    backFrame.size.height = _btnHeight*2 + 20 + 55;
    backView.frame = backFrame;
    
    CGRect menuFrame = _menuView.frame;
    menuFrame.size.height = _btnHeight*2 + 20;
    _menuView.frame = menuFrame;
    self.tableView.tableHeaderView = backView;
}

- (void)hideMenuView { // 隐藏菜单栏
    _menuView.hidden = YES;
    CGRect backFrame = backView.frame;
    backFrame.size.height = 55;
    backView.frame = backFrame;
    self.tableView.tableHeaderView = backView;
}

- (void)intoSearchView{
    [self textFieldDidBeginEditing:_seekTextField];
}

#pragma mark 右上角更多
-(void)onMore:(UIButton *)sender{
        
        NSMutableArray *titles = [NSMutableArray arrayWithArray:@[Localized(@"JX_LaunchGroupChat"),Localized(@"JX_FaceToFaceGroup"), Localized(@"JX_AddFriends"), Localized(@"JX_Scan"), Localized(@"JX_Receiving")]];
        NSMutableArray *images = [NSMutableArray arrayWithArray:@[@"message_creat_group_black", @"message_face_group", @"message_add_friend_black", @"messaeg_scnning_black", @"message_near_receiving"]];
        NSMutableArray *sels = [NSMutableArray arrayWithArray:@[@"onNewRoom", @"onFaceCreateRoom", @"onSearch", @"showScanViewController", @"onReceiving"]];

        NSArray *role = MY_USER_ROLE;
        if ([g_App.config.hideSearchByFriends intValue] == 1 && ([g_App.config.isCommonFindFriends intValue] == 0 || role.count > 0)) {
        }else {
            [titles removeObject:Localized(@"JX_AddFriends")];
            [images removeObject:@"message_add_friend_black"];
            [sels removeObject:@"onSearch"];
        }
        if ([g_App.config.isCommonCreateGroup intValue] == 1 && role.count <= 0) {
            [titles removeObject:Localized(@"JX_LaunchGroupChat")];
            [images removeObject:@"message_creat_group_black"];
            [sels removeObject:@"onNewRoom"];
        }
        if ([g_App.config.isOpenPositionService intValue] == 1) {
            [titles removeObject:Localized(@"JXNearVC_NearPer")];
            [images removeObject:@"message_near_person_black"];
            [sels removeObject:@"onNear"];
        }
        if (![g_config.enablePayModule boolValue]) {
            [titles removeObject:Localized(@"JX_Receiving")];
            [images removeObject:@"message_near_receiving"];
            [sels removeObject:@"onReceiving"];
        }
        if (![g_App.config.enableMpModule boolValue]) {
            [titles removeObject:Localized(@"JX_SearchPublicNumber")];
            [images removeObject:@"message_search_publicNumber"];
            [sels removeObject:@"searchPublicNumber"];
        }

        JX_SelectMenuView *menuView = [[JX_SelectMenuView alloc] initWithTitle:titles image:images cellHeight:44];
        menuView.sels = sels;
        menuView.delegate = self;
        [g_App.window addSubview:menuView];
    //    JX_DownListView * downListView = [[JX_DownListView alloc] initWithFrame:self.view.bounds];
    //    downListView.listContents = @[Localized(@"JX_LaunchGroupChat"), Localized(@"JX_AddFriends"), Localized(@"JX_Scan"), Localized(@"JXNearVC_NearPer")];
    //    downListView.listImages = @[@"message_creat_group_black", @"message_add_friend_black", @"messaeg_scnning_black", @"message_near_person_black"];
    //
    //    __weak typeof(self) weakSelf = self;
    //    [downListView downlistPopOption:^(NSInteger index, NSString *content) {
    //
    //        [weakSelf moreListActionWithIndex:index];
    //
    //    } whichFrame:moreFrame animate:YES];
    //    [downListView show];
        
        //    self.treeView.editing = !self.treeView.editing;
    }
    /*
    NSArray *role = MY_USER_ROLE;
    if ([g_App.config.hideSearchByFriends intValue] == 1 && ([g_App.config.isCommonFindFriends intValue] == 0 || role.count > 0)) {
        [self onSearch];
    }else {
        NSMutableArray *titles = [NSMutableArray arrayWithArray:@[Localized(@"JX_LaunchGroupChat"), Localized(@"JX_Scan"), Localized(@"JXNearVC_NearPer"),Localized(@"JX_SearchPublicNumber")]];
        NSMutableArray *images = [NSMutableArray arrayWithArray:@[@"message_creat_group_black", @"messaeg_scnning_black", @"message_near_person_black",@"message_search_publicNumber"]];
        NSMutableArray *sels = [NSMutableArray arrayWithArray:@[@"onNewRoom", @"showScanViewController", @"onNear",@"searchPublicNumber"]];
        if ([g_App.config.isCommonCreateGroup intValue] == 1 && role.count <= 0) {
            [titles removeObject:Localized(@"JX_LaunchGroupChat")];
            [images removeObject:@"message_creat_group_black"];
            [sels removeObject:@"onNewRoom"];
        }
        if ([g_App.config.isOpenPositionService intValue] == 1) {
            [titles removeObject:Localized(@"JXNearVC_NearPer")];
            [images removeObject:@"message_near_person_black"];
            [sels removeObject:@"onNear"];
        }
        if (![g_App.config.enableMpModule boolValue]) {
            [titles removeObject:Localized(@"JX_SearchPublicNumber")];
            [images removeObject:@"message_search_publicNumber"];
            [sels removeObject:@"searchPublicNumber"];
        }
        
        JX_SelectMenuView *menuView = [[JX_SelectMenuView alloc] initWithTitle:titles image:images cellHeight:44];
        menuView.sels = sels;
        menuView.delegate = self;
        [g_App.window addSubview:menuView];
    }

    //    _control.hidden = YES;
//    UIWindow *window = [[UIApplication sharedApplication].delegate window];
//    CGRect moreFrame = [self.tableHeader convertRect:self.moreBtn.frame toView:window];
//    
//    JX_SelectMenuView *menuView = [[JX_SelectMenuView alloc] initWithTitle:@[Localized(@"JX_LaunchGroupChat"), Localized(@"JX_AddFriends"), Localized(@"JX_Scan"), Localized(@"JXNearVC_NearPer")] image:@[@"message_creat_group_black", @"message_add_friend_black", @"messaeg_scnning_black", @"message_near_person_black"] cellHeight:45];
//    menuView.delegate = self;
//    [g_App.window addSubview:menuView];
    
//    JX_DownListView * downListView = [[JX_DownListView alloc] initWithFrame:self.view.bounds];
//    downListView.listContents = @[Localized(@"JX_LaunchGroupChat"), Localized(@"JX_AddFriends"), Localized(@"JX_Scan"), Localized(@"JXNearVC_NearPer")];
//    downListView.listImages = @[@"message_creat_group_black", @"message_add_friend_black", @"messaeg_scnning_black", @"message_near_person_black"];
//
//    __weak typeof(self) weakSelf = self;
//    [downListView downlistPopOption:^(NSInteger index, NSString *content) {
//
//        [weakSelf moreListActionWithIndex:index];
//
//    } whichFrame:moreFrame animate:YES];
//    [downListView show];
    
    //    self.treeView.editing = !self.treeView.editing;
*/


- (void)didMenuView:(JX_SelectMenuView *)MenuView WithIndex:(NSInteger)index {
    
    
    NSString *method = MenuView.sels[index];
    SEL _selector = NSSelectorFromString(method);
    [self performSelectorOnMainThread:_selector withObject:nil waitUntilDone:YES];
    
//    NSArray *role = MY_USER_ROLE;
//    // 显示搜索好友
//    BOOL isShowSearch = [g_App.config.hideSearchByFriends boolValue] && (![g_App.config.isCommonFindFriends boolValue] || role.count > 0);
//    //显示创建房间
//    BOOL isShowRoom = [g_App.config.isCommonCreateGroup intValue] == 0 || role.count > 0;
//    //显示附近的人
//    BOOL isShowPosition = [g_App.config.isOpenPositionService intValue] == 0;
//    switch (index) {
//        case 0:
//            if (isShowRoom) {
//                [self onNewRoom];
//            }else {
//                if (isShowSearch) {
//                    [self onSearch];
//                }else {
//                    [self showScanViewController];
//                }
//            }
//            break;
//        case 1:
//            if (isShowRoom && isShowSearch) {
//                [self onSearch];
//            }else {
//                if ((isShowRoom && !isShowSearch) || (!isShowRoom && isShowSearch)) {
//                    [self showScanViewController];
//                }else if (!isShowRoom && !isShowSearch) {
//                    if (isShowPosition) {
//                        [self onNear];
//                    }else {
//                        [self searchPublicNumber];
//                    }
//                }
//            }
//            break;
//        case 2:
//            if (isShowSearch && isShowRoom) {
//                [self showScanViewController];
//            }else {
//                if ((isShowRoom && !isShowSearch) || (!isShowRoom && isShowSearch)) {
//                    if (isShowPosition) {
//                        [self onNear];
//                    }else {
//                        [self searchPublicNumber];
//                    }
//                }
//            }
//            break;
//        case 3:
//            if (isShowPosition) {
//                [self onNear];
//            }else {
//                [self searchPublicNumber];
//            }
//            break;
//        case 4:
//            [self searchPublicNumber];
//            break;
//        default:
//            break;
//    }
}

// 搜索公众号
- (void)searchPublicNumber {
    JXSearchUserVC *searchUserVC = [JXSearchUserVC alloc];
    searchUserVC.type = JXSearchTypePublicNumber;
    searchUserVC = [searchUserVC init];
    [g_navigation pushViewController:searchUserVC animated:YES];
}


- (void) moreListActionWithIndex:(NSInteger)index {
    
}

// 创建群组
-(void)onNewRoom{
    JXNewRoomVC* vc = [[JXNewRoomVC alloc]init];
    [g_navigation pushViewController:vc animated:YES];
}
// 附近的人
-(void)onNear{
    JXNearVC * nearVc = [[JXNearVC alloc] init];
    [g_navigation pushViewController:nearVc animated:YES];
}
//搜索好友
-(void)onSearch{
    JXSearchUserVC* vc = [JXSearchUserVC alloc];
    vc.delegate  = self;
    vc.didSelect = @selector(doSearch:);
    vc.type = JXSearchTypeUser;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    
    [self cancelBtnAction];
}
-(void)doSearch:(searchData*)p{
    
    JXNearVC *nearVC = [[JXNearVC alloc]init];
    nearVC.isSearch = YES;
    [g_navigation pushViewController:nearVC animated:YES];
    [nearVC doSearch:p];
}
// 扫一扫
-(void)showScanViewController{
//    button.enabled = NO;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        button.enabled = YES;
//    });
    
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        [g_server showMsg:Localized(@"JX_CanNotopenCenmar")];
        return;
    }
    
    JXScanQRViewController * scanVC = [[JXScanQRViewController alloc] init];
    
    //    [g_window addSubview:scanVC.view];
    [g_navigation pushViewController:scanVC animated:YES];
}

// 面对面建群
- (void)onFaceCreateRoom {
    
    JXFaceCreateRoomVC *vc = [[JXFaceCreateRoomVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}
// 新朋友
- (void)newFriendAction:(JXImageView *)imageView {
    // 清空角标
    JXMsgAndUserObject* newobj = [[JXMsgAndUserObject alloc]init];
    newobj.user = [[JXUserObject sharedInstance] getUserById:FRIEND_CENTER_USERID];
    newobj.message = [[JXMessageObject alloc] init];
    newobj.message.toUserId = FRIEND_CENTER_USERID;
    newobj.user.msgsNew = [NSNumber numberWithInt:0];
    [newobj.message updateNewMsgsTo0];
    
    NSArray *friends = [[JXFriendObject sharedInstance] fetchAllFriendsFromLocal];
    for (NSInteger i = 0; i < friends.count; i ++) {
        JXFriendObject *friend = friends[i];
        if ([friend.msgsNew integerValue] > 0) {
            [friend updateNewMsgUserId:friend.userId num:0];
            [friend updateNewFriendLastContent];
        }
    }
    
    [self showNewMsgCount:0];
    JKNum = 0;

    JXNewFriendViewController* vc = [[JXNewFriendViewController alloc]init];
    [g_navigation pushViewController:vc animated:YES];
    
}

// 群组
- (void)myGroupAction:(JXImageView *)imageView {
    JXGroupViewController *vc = [[JXGroupViewController alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 我的同事
- (void)myColleaguesAction:(JXImageView *)imageView {
    OrganizTreeViewController *vc = [[OrganizTreeViewController alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 公众号
- (void)publicNumberAction:(JXImageView *)imageView {
    JXPublicNumberVC *vc = [[JXPublicNumberVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 黑名单
- (void)blackFriendAction:(JXImageView *)imageView {
    JXBlackFriendVC *vc = [[JXBlackFriendVC alloc] init];
    vc.title = Localized(@"JX_BlackList");
    [g_navigation pushViewController:vc animated:YES];
}

// 我的设备
- (void)myDeviceAction:(JXImageView *)imageView {
    JXBlackFriendVC *vc = [[JXBlackFriendVC alloc] init];
    vc.isDevice = YES;
    vc.title = Localized(@"JX_MyDevices");
    [g_navigation pushViewController:vc animated:YES];
}

// 标签
- (void)labelAction:(JXImageView *)imageView {
    
    JXLabelVC *vc = [[JXLabelVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 手机通讯录
- (void)addressBookAction:(JXImageView *)imageView {
    
    JXAddressBookVC *vc = [[JXAddressBookVC alloc] init];
    NSMutableArray *arr = [[JXAddressBook sharedInstance] doFetchUnread];
    vc.abUreadArr = arr;
    [g_navigation pushViewController:vc animated:YES];
    [[JXAddressBook sharedInstance] updateUnread];
    
    JXMsgAndUserObject* newobj = [[JXMsgAndUserObject alloc]init];
    newobj.user = [[JXUserObject sharedInstance] getUserById:FRIEND_CENTER_USERID];
    [self showNewMsgCount:[newobj.user.msgsNew integerValue]];
}

-(JXImageView*)createButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom icon:(NSString*)icon click:(SEL)click superView:(UIView *)superView{
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.delegate = self;
    [superView addSubview:btn];
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(42 + 14 + 14, 0, 200, HEIGHT)];
    p.text = title;
    p.font = g_factory.font16;
    p.backgroundColor = [UIColor clearColor];
    p.textColor = HEXCOLOR(0x323232);
    //    p.delegate = self;
    //    p.didTouch = click;
    [btn addSubview:p];
    
    if(icon){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(14, (HEIGHT-42)/2, 42, 42)];
        iv.image = [UIImage imageNamed:icon];
        iv.layer.cornerRadius = iv.frame.size.width / 2;
        iv.layer.masksToBounds = YES;
        [btn addSubview:iv];
    }
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,HEIGHT-LINE_WH,JX_SCREEN_WIDTH,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
//    if(click){
//        UIImageView* iv;
//        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3, 16, 20, 20)];
//        iv.image = [UIImage imageNamed:@"set_list_next"];
//        [btn addSubview:iv];
//
//    }
    return btn;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    JXSearchVC *vc = [[JXSearchVC alloc] initWithTable:@"friendsearchrecord"];
    [g_navigation pushViewController:vc animated:YES];
}

- (void) textFieldDidChange:(UITextField *)textField {
    
    if (textField.text.length <= 0) {
        if (!self.isMyGoIn) {
            [self showMenuView];
        }
        [self getArrayData];
        [self.tableView reloadData];
        return;
    }else {
        [self hideMenuView];
    }
    
    [_searchArray removeAllObjects];
    if (_selMenu == 0) {
        _searchArray = [[JXUserObject sharedInstance] fetchFriendsFromLocalWhereLike:textField.text];
    }else if (_selMenu == 1){
        _searchArray = [[JXUserObject sharedInstance] fetchBlackFromLocalWhereLike:textField.text];
    }
    
    [self.tableView reloadData];
}

- (void) cancelBtnAction {
    if (_seekTextField.text.length > 0) {
        _seekTextField.text = nil;
        [self getArrayData];
    }
    [_seekTextField resignFirstResponder];
    [self.tableView reloadData];
}

-(void)onClick:(UIButton*)sender{
}

//筛选点击
- (void)topItemBtnClick:(UIButton *)btn{
    [self checkAfterScroll:(btn.tag-100)];
    [_topSiftView resetAllParaBtn];
}

- (void)checkAfterScroll:(CGFloat)offsetX{
    if (offsetX == 0) {
        _selMenu = 0;
    }else {
        _selMenu = 1;
    }
    [self scrollToPageUp];
}

- (void)getFriend{
    [g_server listAttention:0 userId:MY_USER_ID toView:self];
}

//-(void)actionSegment:(UISegmentedControl*)sender{
//    _selMenu = (int)sender.selectedSegmentIndex;
//    [self refresh];
//}
// 收付款
- (void)onReceiving {
    JXPayViewController *payVC = [[JXPayViewController alloc] init];
    [g_navigation pushViewController:payVC animated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _array=[[NSMutableArray alloc] init];
    [self refresh];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 离开时重置_isMyGoIn
    if (_isMyGoIn) {
        _isMyGoIn = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_seekTextField.text.length > 0) {
        return 2;
    }
    return [self.indexArray count]+1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    if (_seekTextField.text.length > 0) {
        return Localized(@"JXFriend_searchTitle");
    }
    return [self.indexArray objectAtIndex:section-1];
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    if (section == 0) {
        return;
    }
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.tintColor = HEXCOLOR(0xF2F2F2);
    [header.textLabel setTextColor:HEXCOLOR(0x999999)];
    [header.textLabel setFont:SYSFONT(15)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 27;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 5;
    }
    if (_seekTextField.text.length > 0) {
        return _searchArray.count;
    }
    return [(NSArray *)[self.letterResultArr objectAtIndex:section-1] count];
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (_seekTextField.text.length > 0) {
        return nil;
    }
    return self.indexArray;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        JXFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JXFriend" forIndexPath:indexPath];
        cell.imgView.image = [UIImage imageNamed:self.iconArray[indexPath.row]];
        cell.titleL.text = self.titleArray[indexPath.row];
        cell.subTitleL.text = self.subTitleArray[indexPath.row];
        
        if (indexPath.row == 0) {
            if (JKNum == 0) {
                cell.FriendNewCountL.hidden = 1;
            }else{
                cell.FriendNewCountL.hidden = 0;
                cell.FriendNewCountL.text = [NSString stringWithFormat:@"%ld",JKNum];
            }

        }else{
            cell.FriendNewCountL.hidden = YES;
        }

        
        return cell;
    }
    JXUserObject *user;
    if (_seekTextField.text.length > 0) {
        user = _searchArray[indexPath.row];
    }else{
        user = [[self.letterResultArr objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
    }
    
	JXCell *cell=nil;
    NSString* cellName = [NSString stringWithFormat:@"msg_%d_%ld",_refreshCount,indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if(cell==nil){
        
        cell = [[JXCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        [_table addToPool:cell];
        
//        cell.headImage   = user.userHead;
//        user = nil;
    }
    
//    cell.title = user.userNickname;
    cell.title = [self multipleLoginIsOnlineTitle:user];
//    cell.subtitle = user.userId;
    cell.index = (int)indexPath.row;
    cell.delegate = self;
    cell.didTouch = @selector(onHeadImage:);
//    cell.bottomTitle = [TimeUtil formatDate:user.timeCreate format:@"MM-dd HH:mm"];
//    [cell setForTimeLabel:[TimeUtil formatDate:user.timeCreate format:@"MM-dd HH:mm"]];
    cell.timeLabel.frame = CGRectMake(JX_SCREEN_WIDTH - 120-20, 9, 115, 20);
    cell.userId = user.userId;
    [cell.lbTitle setText:cell.title];
    
    cell.dataObj = user;
//    cell.headImageView.tag = (int)indexPath.row;
//    cell.headImageView.delegate = cell.delegate;
//    cell.headImageView.didTouch = cell.didTouch;
    
    cell.isSmall = YES;
    [cell headImageViewImageWithUserId:user.userId roomId:nil];
    
//    if (indexPath.section-1 == self.letterResultArr.count-1 && indexPath.row == [(NSArray *)[self.letterResultArr objectAtIndex:indexPath.section-1] count]-1) {
//        cell.lineView.frame = CGRectMake(0, cell.lineView.frame.origin.y, JX_SCREEN_WIDTH, cell.lineView.frame.size.height);
//    }else if (indexPath.row == [(NSArray *)[self.letterResultArr objectAtIndex:indexPath.section-1] count]-1) {
//        cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width,0);
//    }else {
//        cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width,LINE_WH);
//    }
    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    if (_seekTextField.text.length > 0 || section != self.letterResultArr.count-1) {
//        return 0;
//    }
//    return 0;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    if (_seekTextField.text.length > 0 || section != self.letterResultArr.count-1) {
//        return nil;
//    }
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 44)];
//    label.textColor = HEXCOLOR(0x999999);
//    label.textAlignment = NSTextAlignmentCenter;
//    label.font = SYSFONT(16);
//    label.text = [NSString stringWithFormat:@"%ld位联系人",_array.count];
//
//    return label;
//}

- (NSString *)multipleLoginIsOnlineTitle:(JXUserObject *)user {
    NSString *isOnline;
    if ([user.isOnLine intValue] == 1) {
        isOnline = [NSString stringWithFormat:@"(%@)", Localized(@"JX_OnLine")];
    }else {
        isOnline = [NSString stringWithFormat:@"(%@)", Localized(@"JX_OffLine")];
    }
    NSString *title = user.remarkName.length > 0 ? user.remarkName : user.userNickname;
    if ([user.userId isEqualToString:ANDROID_USERID] || [user.userId isEqualToString:PC_USERID] || [user.userId isEqualToString:MAC_USERID]) {
        title = [title stringByAppendingString:isOnline];
    }
    return title;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        
        JXFriendTableViewCell * cell = [_table cellForRowAtIndexPath:indexPath];
        cell.selected = NO;
        switch (indexPath.row) {
            case 0:
            {
                [self newFriendAction:nil];
                self.friendNewMsgNum = [[UILabel alloc] initWithFrame:CGRectMake(43, 3, 15, 15)];
                self.friendNewMsgNum.backgroundColor = [UIColor redColor];
                self.friendNewMsgNum.font = [UIFont systemFontOfSize:11.0];
                self.friendNewMsgNum.textAlignment = NSTextAlignmentCenter;
                self.friendNewMsgNum.layer.cornerRadius = self.friendNewMsgNum.frame.size.width / 2;
                self.friendNewMsgNum.layer.masksToBounds = YES;
                self.friendNewMsgNum.textColor = [UIColor whiteColor];
                self.friendNewMsgNum.text = @"99";
            
               
            }
                break;

            case 1:
            {
                [self publicNumberAction:nil];
            }
                break;
            case 2:
            {
                [self myGroupAction:nil];
            }
                break;

            case 3:
            {
                [self myDeviceAction:nil];
            }
                break;
            case 4:
            {
                [self labelAction:nil];
            }
                break;
            default:
                break;
        }
        return;
    }
    JXCell * cell = [_table cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    // 黑名单列表不能点击
    if (_selMenu == 1) {
        return;
    }
    
    JXUserObject *user;
    if (_seekTextField.text.length > 0) {
        user = _searchArray[indexPath.row];
    }else{
        user = [[self.letterResultArr objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
    }
    
    
    if([user.userId isEqualToString:FRIEND_CENTER_USERID]){
        JXNewFriendViewController* vc = [[JXNewFriendViewController alloc]init];
//        [g_App.window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
//        [vc release];
        return;
    }
    
    JXChatViewController *sendView=[JXChatViewController alloc];
    if([user.roomFlag intValue] > 0  || user.roomId.length > 0){
        sendView.roomJid = user.userId;
        sendView.roomId = user.roomId;
        [[JXXMPP sharedInstance].roomPool joinRoom:user.userId title:user.userNickname lastDate:nil isNew:NO];
    }
    sendView.title = user.remarkName.length > 0  ? user.remarkName : user.userNickname;
    sendView.chatPerson = user;
    sendView = [sendView init];
//    [g_App.window addSubview:sendView.view];
    [g_navigation pushViewController:sendView animated:YES];
    
    JXMessageObject *msg = [[JXMessageObject alloc] init];
    msg.toUserId = user.userId;
    [msg updateNewMsgsTo0];
    [g_notify postNotificationName:kChatViewDisappear object:nil];
    
//    [sendView release];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        return NO;
    }
    if (_seekTextField.text.length <= 0){
        if (_selMenu == 0) {
            JXUserObject *user = [[self.letterResultArr objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
            if (user.userId.length <= 5) {
                return NO;
            }else{
                return YES;
            }
        }else{
            return YES;
        }
    }else{
        return NO;
    }
}

//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (_selMenu == 0) {
//        return UITableViewCellEditingStyleDelete;
//    }else{
//        return UITableViewCellEditingStyleNone;
//    }
//}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_selMenu == 0) {
        UITableViewRowAction *deleteBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Localized(@"JX_Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            JXUserObject *user = [[self.letterResultArr objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
            _currentUser = user;
            [g_server delFriend:user.userId toView:self];
        }];
        
        return @[deleteBtn];
    }
    else {
        UITableViewRowAction *cancelBlackBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Localized(@"REMOVE") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            JXUserObject *user = [[self.letterResultArr objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
            _currentUser = user;
            [g_server delBlacklist:user.userId toView:self];
        }];
        
        return @[cancelBlackBtn];
    }
   
}

//-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (_selMenu == 0 && editingStyle == UITableViewCellEditingStyleDelete) {
//        JXUserObject *user=_array[indexPath.row];
//        _currentUser = user;
//        [g_server delFriend:user.userId toView:self];
//    }
//}

- (void)dealloc {
    [g_notify removeObserver:self];
//    [_table release];
    [_array removeAllObjects];
//    [_array release];
//    [super dealloc];
}

-(void)getArrayData{
    switch (_selMenu) {
        case 0:{
            //获取好友列表
//            if (self.isOneInit) {//是否新建
//                [g_server listAttention:0 userId:MY_USER_ID toView:self];
//                self.isOneInit = NO;
//            }
            
            //从数据库获取好友staus为2且不是room的
            _array=[[JXUserObject sharedInstance] fetchAllFriendsFromLocal];
            //选择拼音 转换的 方法
            BMChineseSortSetting.share.sortMode = 2; // 1或2
            //排序 Person对象
            [BMChineseSort sortAndGroup:_array key:@"userNickname" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
                if (isSuccess) {
                    self.indexArray = sectionTitleArr;
                    self.letterResultArr = sortedObjArr;
                    [_table reloadData];
                }
            }];

//            //根据Person对象的 name 属性 按中文 对 Person数组 排序
//            self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickname"];
//            self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickname"];
//
            self.isShowFooterPull = NO;
        }
            break;
        case 1:{
            //获取黑名單列表
            
            //从数据库获取好友staus为-1的
            _array=[[JXUserObject sharedInstance] fetchAllBlackFromLocal];
            //选择拼音 转换的 方法
            BMChineseSortSetting.share.sortMode = 2; // 1或2
            //排序 Person对象
            [BMChineseSort sortAndGroup:_array key:@"userNickname" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
                if (isSuccess) {
                    self.indexArray = sectionTitleArr;
                    self.letterResultArr = sortedObjArr;
                    [_table reloadData];
                }
            }];
            //根据Person对象的 name 属性 按中文 对 Person数组 排序
//            self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickname"];
//            self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickname"];
        }
            break;
        case 2:{
            _array=[[JXUserObject sharedInstance] fetchAllRoomsFromLocal];
            //选择拼音 转换的 方法
            BMChineseSortSetting.share.sortMode = 2; // 1或2
            //排序 Person对象
            [BMChineseSort sortAndGroup:_array key:@"userNickname" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
                if (isSuccess) {
                    self.indexArray = sectionTitleArr;
                    self.letterResultArr = sortedObjArr;
                    [_table reloadData];
                }
            }];
        }
//            //根据Person对象的 name 属性 按中文 对 Person数组 排序
//            self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickname"];
//            self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickname"];
            break;
    }
    
    [self setFooterView];
}
//服务器返回数据
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    //更新本地好友
    if ([aDownload.action isEqualToString:act_AttentionList]) {
        [_wait stop];
        [self stopLoading];
        JXProgressVC * pv = [JXProgressVC alloc];
        // 服务端不会返回新朋友 ， 减去新朋友
        pv.dbFriends = (long)[_array count] - 1;
        pv.dataArray = array1;
        pv = [pv init];
//        [g_window addSubview:pv.view];
    }
    
    if ([aDownload.action isEqualToString:act_FriendDel]) {
        [_currentUser doSendMsg:XMPP_TYPE_DELALL content:nil];
    }
    
    if([aDownload.action isEqualToString:act_BlacklistDel]){
        [_currentUser doSendMsg:XMPP_TYPE_NOBLACK content:nil];
    }
    
    if( [aDownload.action isEqualToString:act_UserGet] ){
        [_wait stop];
        
        JXUserObject* user = [[JXUserObject alloc]init];
        [user getDataFromDict:dict];
        
        JXUserInfoVC* vc = [JXUserInfoVC alloc];
        vc.user       = user;
        vc.fromAddType = 6;
        vc = [vc init];
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
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
        
        
        _array = [[JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
        for (JXLabelObject *labelObj in _array) {
            NSString *userIdStr = labelObj.userIdList;
            NSArray *userIds = [userIdStr componentsSeparatedByString:@","];
            if (userIdStr.length <= 0) {
                userIds = nil;
            }
            
            NSMutableArray *newUserIds = [userIds mutableCopy];
            for (NSInteger i = 0; i < userIds.count; i ++) {
                NSString *userId = userIds[i];
                NSString *userName = [JXUserObject getUserNameWithUserId:userId];
                
                if (!userName || userName.length <= 0) {
                    [newUserIds removeObject:userId];
                }
                
            }
            
            NSString *string = [newUserIds componentsJoinedByString:@","];
            
            labelObj.userIdList = string;
            
            [labelObj update];
        }
    }

}



-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    
    [self stopLoading];
    return hide_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    [self stopLoading];
    return hide_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
//    [_wait start];
}

-(void)refresh{
    [self stopLoading];
    _refreshCount++;
    [_array removeAllObjects];
//    [_array release];
    [self getArrayData];
    _friendArray = [g_server.myself fetchAllFriendsOrNotFromLocal];
    [_table reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 59;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

//-(void)scrollToPageUp{
//    [self refresh];
//}

-(void)newFriend:(NSObject*)sender{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refresh];
    });
}

-(void)onHeadImage:(id)dataObj{

    JXUserObject *p = (JXUserObject *)dataObj;
    if([p.userId isEqualToString:FRIEND_CENTER_USERID] || [p.userId isEqualToString:CALL_CENTER_USERID])
        return;
    
    _currentUser = p;
//    [g_server getUser:p.userId toView:self];
    
    JXUserInfoVC* vc = [JXUserInfoVC alloc];
    vc.userId       = p.userId;
    vc.user = p;
    vc.fromAddType = 6;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];

    p = nil;
}

-(void)onSendTimeout:(NSNotification *)notifacation//超时未收到回执
{
    //    NSLog(@"onSendTimeout");
    [_wait stop];
//    [g_App showAlert:Localized(@"JXAlert_SendFilad")];
//    [JXMyTools showTipView:Localized(@"JXAlert_SendFilad")];
}

-(void)newReceipt:(NSNotification *)notifacation{//新回执
    //    NSLog(@"newReceipt");
    JXMessageObject *msg     = (JXMessageObject *)notifacation.object;
    if(msg == nil)
        return;
    if(![msg isAddFriendMsg])
        return;
    [_wait stop];
    if([msg.type intValue] == XMPP_TYPE_DELALL){
        if([msg.toUserId isEqualToString:_currentUser.userId] || [msg.fromUserId isEqualToString:_currentUser.userId]){
            [_array removeObject:_currentUser];
            _currentUser = nil;
            [self getArrayData];
            [_table reloadData];
//            [g_App showAlert:Localized(@"JXAlert_DeleteFirend")];
        }
    }
    
    if([msg.type intValue] == XMPP_TYPE_BLACK){//拉黑
        for (JXUserObject *obj in _array) {
            if ([obj.userId isEqualToString:_currentUser.userId]) {
                [_array removeObject:obj];
                break;
            }
        }
        
        [self getArrayData];
        [self.tableView reloadData];
    }
    
    if([msg.type intValue] == XMPP_TYPE_NOBLACK){
//        _currentUser.status = [NSNumber numberWithInt:friend_status_friend];
//        int status = [_currentUser.status intValue];
//        [_currentUser update];
        
        if (!_currentUser) {
            return;
        }
        [[JXXMPP sharedInstance].blackList removeObject:_currentUser.userId];
        [JXMessageObject msgWithFriendStatus:_currentUser.userId status:friend_status_friend];
        for (JXUserObject *obj in _array) {
            if ([obj.userId isEqualToString:_currentUser.userId]) {
                [_array removeObject:obj];
                break;
            }
        }
    
        [self getArrayData];
        [self.tableView reloadData];
//        [g_App showAlert:Localized(@"JXAlert_MoveBlackList")];
    }
    
    if([msg.type intValue] == XMPP_TYPE_PASS){//通过
        [self getFriend];
    }
}

- (void)friendRemarkNotif:(NSNotification *)notif {
    
    JXUserObject *user = notif.object;
    for (int i = 0; i < _array.count; i ++) {
        JXUserObject *user1 = _array[i];
        if ([user.userId isEqualToString:user1.userId]) {
            user1.userNickname = user.remarkName.length > 0 ? user.remarkName : user.userNickname;
            user1.remarkName = user.remarkName.length > 0 ? user.remarkName : user.userNickname;
            [_table reloadData];
            break;
        }
    }
}

- (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title icon:(NSString *)iconName  action:(SEL)action {
    UIButton *button = [[UIButton alloc] init];
    button.frame = frame;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imgV = [[UIImageView alloc] init];
    imgV.frame = CGRectMake((button.frame.size.width-IMAGE_HEIGHT)/2, 20, IMAGE_HEIGHT, IMAGE_HEIGHT);
    imgV.image = [UIImage imageNamed:iconName];
    [button addSubview:imgV];
    
    CGSize size = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYSFONT(14)} context:nil].size;
    UILabel *lab = [[UILabel alloc] init];
    lab.text = title;
    lab.font = SYSFONT(14);
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = HEXCOLOR(0x323232);
    if (size.width >= button.frame.size.width) {
        size.width = button.frame.size.width-20;
    }
    lab.frame = CGRectMake(0, CGRectGetMaxY(imgV.frame)+INSET_HEIGHT, size.width, size.height);
    CGPoint center = lab.center;
    center.x = imgV.center.x;
    lab.center = center;
    
    CGRect btnFrame = button.frame;
    btnFrame.size.height = CGRectGetMaxY(imgV.frame)+INSET_HEIGHT+size.height;
    button.frame = btnFrame;
    
    [button addSubview:lab];
    
    return button;
}
-(void)createButton:(SEL)click superView:(UIView *)superView{
//    JXImageView* btn = [[JXImageView alloc] init];
//    btn.backgroundColor = [UIColor whiteColor];
//    btn.userInteractionEnabled = YES;
//    btn.didTouch = click;
//    btn.delegate = self;
//    [superView addSubview:btn];
    

    NSArray *iconArray = @[@"friend_newFriend",@"friend_public",@"friend_group_list",@"friend_device",@"friend_label"];
    NSArray *titleArray = @[Localized(@"JXNewFriendVC_NewFirend"), Localized(@"JX_PublicNumber"),Localized(@"JX_ManyPerChat"),Localized(@"JX_MyDevices"),Localized(@"JX_Label")];
    
    NSArray *subTitleArray = @[@"通过新的朋友添加搜索好友",@"关注知名公众号和搜索热门公众号",@"自己建立群组和已经加入的群组",@"自己的设备管理",@"可以标记好友的分类标签"];
    NSInteger height = HEIGHT;
    for (int i=0; i<titleArray.count; i++) {
        
        UIView * btnView = [[UIView  alloc]initWithFrame:CGRectMake(0, height, JX_SCREEN_WIDTH, HEIGHT)];
        btnView.userInteractionEnabled = YES;
        btnView.tag = i;
        
        UIImageView * icon = [[UIImageView alloc]initWithFrame:CGRectMake(15, (HEIGHT-40)*0.5, 40, 40)];
        icon.image = [UIImage imageNamed:iconArray[i]];
        icon.layer.cornerRadius=5;
        icon.layer.masksToBounds = YES;
        [btnView addSubview:icon];
        
        UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(icon.right+15, 9, JX_SCREEN_WIDTH-icon.right-15, 16)];
        titleLabel.text = titleArray[i];
        titleLabel.textColor = HEXCOLOR(0x333333);
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [btnView addSubview:titleLabel];
        [superView addSubview:btnView];
        
        UILabel * subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(icon.right+15, titleLabel.bottom+8, JX_SCREEN_WIDTH-icon.right-15, 14)];
        subTitleLabel.text = subTitleArray[i];
        subTitleLabel.textColor = HEXCOLOR(0x9c9c9c);
        subTitleLabel.font = [UIFont systemFontOfSize:13];
        subTitleLabel.textAlignment = NSTextAlignmentLeft;
        [btnView addSubview:subTitleLabel];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(titleLabel.left, HEIGHT-0.5, JX_SCREEN_WIDTH-titleLabel.left, 0.5)];
        lineView.backgroundColor = RGB(240, 240, 240);
        [btnView addSubview:lineView];
        
        height = height+HEIGHT;
        switch (btnView.tag) {
            case 0:
            {

               
            }
                break;

//            case 1:
//            {
//
//                UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addressBookAction:)];
//                [btnView addGestureRecognizer:tap];
//            }
//                break;
            case 1:
            {
                
                UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(publicNumberAction:)];
                [btnView addGestureRecognizer:tap];
            }
                break;
            case 2:
            {
                
                UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myGroupAction:)];
                [btnView addGestureRecognizer:tap];
            }
                break;

            case 3:
            {
                
                UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myDeviceAction:)];
                [btnView addGestureRecognizer:tap];
            }
                break;
            case 4:
            {
                
                UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelAction:)];
                [btnView addGestureRecognizer:tap];
            }
                break;
            default:
                break;
        }
        
    }
 

}


@end
