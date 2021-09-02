//
//  JXAddressBookVC.m
//  shiku_im
//
//  Created by p on 2018/8/30.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXAddressBookVC.h"
#import "BMChineseSort.h"
#import "JXAddressBookCell.h"
#import "JXUserInfoVC.h"
#import "JXNewRoomVC.h"
#import "JXSelectFriendsVC.h"
#import "JXRoomPool.h"
#import "JXInviteAddressBookVC.h"

@interface JXAddressBookVC ()<JXAddressBookCellDelegate, QCheckBoxDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) BOOL isShowSelect;
@property (nonatomic, assign) BOOL isAllSelect;

@property (nonatomic, strong) NSMutableArray *selectABs;
@property (nonatomic, strong) UIView *doneBtn;
@property (nonatomic, strong) UIButton *selectBtn;
@property (nonatomic, strong) NSDictionary *phoneNumDict;
@property (nonatomic, strong) NSMutableArray *headerCheckBoxs;
@property (nonatomic, strong) NSMutableArray *allAbArr;

@property (nonatomic, copy) NSString *selectUserIds;
@property (nonatomic, copy) NSString *selectUserNames;

@property (nonatomic, strong) JXUserObject *addressBookUser;

@end

@implementation JXAddressBookVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack   = YES;
    //self.view.frame = g_window.bounds;
    self.isShowFooterPull = NO;
    
    [self createHeadAndFoot];
    
    _phoneNumDict = [[JXAddressBook sharedInstance] getMyAddressBook];
    _headerCheckBoxs = [NSMutableArray array];
    
    self.title = Localized(@"JX_MobilePhoneContacts");
    
    _array = [NSMutableArray array];
    _indexArray = [NSMutableArray array];
    _letterResultArr = [NSMutableArray array];
    _selectABs = [NSMutableArray array];
    _allAbArr = [NSMutableArray array];
    
    self.isShowSelect = NO;
    
    
    CGSize size = [Localized(@"JX_BatchAddition") sizeWithAttributes:@{NSFontAttributeName:SYSFONT(15)}];
    
    _selectBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_selectBtn setTitle:Localized(@"JX_BatchAddition") forState:UIControlStateNormal];
    [_selectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _selectBtn.tintColor = [UIColor clearColor];
    _selectBtn.frame = CGRectMake(JX_SCREEN_WIDTH - size.width-15, JX_SCREEN_TOP - 30, size.width, 15);
    _selectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_selectBtn addTarget:self action:@selector(selectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableHeader addSubview:_selectBtn];
    
    _doneBtn = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - JX_SCREEN_BOTTOM, JX_SCREEN_WIDTH, JX_SCREEN_BOTTOM)];
    _doneBtn.backgroundColor = HEXCOLOR(0xf0f0f0);
    _doneBtn.hidden = YES;
    [self.view addSubview:_doneBtn];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 49)];
    [btn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    [btn setTitleColor:HEXCOLOR(0x55BEB8) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(doneBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = HEXCOLOR(0xf0f0f0);
    [_doneBtn addSubview:btn];
    
    [self getServerData];
    
    [self createTableHeadView];
    if (self.abUreadArr.count > 0) {
        [self createHeaderView:self.abUreadArr];
        
        NSMutableArray *arr = [[JXUserObject sharedInstance] fetchRoomsFromLocalWithCategory:[NSNumber numberWithInteger:510]];
        for (NSInteger i = 0; i < arr.count; i ++) {
            JXUserObject *user = arr[i];
            if ([user.createUserId isEqualToString:MY_USER_ID]) {
                self.addressBookUser = user;
                break;
            }
        }
        
        if (self.addressBookUser) {
            
            [g_App showAlert:Localized(@"JX_InviteJoinMobileContactGroup") delegate:self tag:2458 onlyConfirm:NO];
        }else {
            
            [g_App showAlert:Localized(@"JX_CreateMobileContactGroup") delegate:self tag:2457 onlyConfirm:NO];
        }
    }
}

- (void)createTableHeadView {
 
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 65)];
    [btn addTarget:self action:@selector(inviteFriend) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = btn;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(23, 23, 20, 20)];
    imageView.image = [UIImage imageNamed:@"ic_ct_msg_invite"];
    [btn addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, 0, 200, btn.frame.size.height)];
    label.text = Localized(@"JX_InviteFriends");
    [btn addSubview:label];
}

- (void)inviteFriend {
    
    JXInviteAddressBookVC *vc = [[JXInviteAddressBookVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (alertView.tag == 2457) {
            if ([g_config.isCommonCreateGroup intValue] == 1) {
                [g_App showAlert:Localized(@"JX_NotCreateNewRoom")];
                return;
            }
            JXNewRoomVC *vc = [[JXNewRoomVC alloc] init];
            vc.isAddressBook = YES;
            vc.addressBookArr = [_allAbArr mutableCopy];
            vc.roomName.text = [NSString stringWithFormat:@"%@%@",g_server.myself.userNickname,Localized(@"JX_MyCellPhoneContactGroup")];
            [g_navigation pushViewController:vc animated:YES];
        }
        if (alertView.tag == 2458) {
            
            JXSelectFriendsVC* vc = [JXSelectFriendsVC alloc];
            vc.isNewRoom = NO;
            vc.chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:self.addressBookUser.userId title:self.addressBookUser.userNickname lastDate:nil isNew:NO];
            NSDictionary * groupDict = [self.addressBookUser toDictionary];
            roomData * roomdata = [[roomData alloc] init];
            [roomdata getDataFromDict:groupDict];
            vc.room = roomdata;
            vc.delegate = self;
            vc.didSelect = @selector(onAfterAddMember:);
            
            NSMutableArray *arr = [NSMutableArray array];
            NSMutableSet *existSet = [NSMutableSet set];
            for (NSInteger i = 0; i < self.abUreadArr.count; i ++) {
                JXAddressBook *ab = self.abUreadArr[i];
                JXUserObject *user = [[JXUserObject alloc] init];
                user.userId = ab.toUserId;
                user.userNickname = ab.toUserName;
                [arr addObject:user];
                [existSet addObject:ab.toUserId];
            }
            vc.existSet = [existSet copy];
            vc.addressBookArr = arr;
            
            vc = [vc init];
            
            [g_navigation pushViewController:vc animated:YES];
        }
    }
}

-(void)onAfterAddMember:(JXSelectFriendsVC*)vc{

    [JXMyTools showTipView:Localized(@"JX_InvitingSuccess")];
}
- (void)createHeaderView:(NSMutableArray *)abUread {
    [_headerCheckBoxs removeAllObjects];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, (abUread.count + 1) * 64 + 30)];
    headerView.backgroundColor = HEXCOLOR(0xF2F2F2);
    self.tableView.tableHeaderView = headerView;
    
    UIButton *inviteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 65)];
    [inviteBtn addTarget:self action:@selector(inviteFriend) forControlEvents:UIControlEventTouchUpInside];
    inviteBtn.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:inviteBtn];
    
    UIImageView *inviteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 25, 25)];
    inviteImageView.image = [UIImage imageNamed:@"ic_ct_msg_invite"];
    [inviteBtn addSubview:inviteImageView];
    
    UILabel *inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(inviteImageView.frame) + 10, 0, 200, inviteBtn.frame.size.height)];
    inviteLabel.text = Localized(@"JX_InviteFriends");
    [inviteBtn addSubview:inviteLabel];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(inviteBtn.frame), JX_SCREEN_WIDTH, 30)];
    view.backgroundColor = HEXCOLOR(0xF2F2F2);
    [headerView addSubview:view];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, JX_SCREEN_WIDTH, 30)];
//    label.backgroundColor = HEXCOLOR(0xf0eff4);
    label.text = Localized(@"JX_LatestContacts");
    label.font = [UIFont systemFontOfSize:16.0];
    [view addSubview:label];
    
    CGFloat y = CGRectGetMaxY(view.frame);
    
    for (NSInteger i = 0; i < abUread.count; i ++) {
        JXAddressBook *ab = abUread[i];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, y, JX_SCREEN_WIDTH, 64)];
        btn.backgroundColor = [UIColor whiteColor];
        btn.tag = i;
        [btn addTarget:self action:@selector(headerBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:btn];
        
        QCheckBox *checkBox ;
        if (self.isShowSelect) {
            checkBox = [[QCheckBox alloc] initWithDelegate:self];
            checkBox.frame = CGRectMake(15, 22, 20, 20);
            checkBox.tag = i;
            checkBox.selected = self.isAllSelect;
            checkBox.delegate = self;
            [btn addSubview:checkBox];
            [_headerCheckBoxs addObject:checkBox];
        }
        [self addressBookCell:nil checkBoxSelectIndexNum:btn.tag isSelect:checkBox.selected];

        CGFloat headImageX;
        if (checkBox) {
            headImageX = CGRectGetMaxX(checkBox.frame) + 10;
        }else {
            headImageX = 15;
        }
        
        JXImageView *headImage = [[JXImageView alloc]init];
        headImage.userInteractionEnabled = NO;
        headImage.tag = i;
//        headImage.delegate = self;
//        headImage.didTouch = @selector(headImageDidTouch);
        headImage.frame = CGRectMake(headImageX,5,52,52);
        headImage.layer.cornerRadius = 26;
        headImage.layer.masksToBounds = YES;
        headImage.layer.borderColor = [UIColor darkGrayColor].CGColor;
        [g_server getHeadImageLarge:ab.toUserId userName:ab.toUserName imageView:headImage getHeadHandler:nil];
        [btn addSubview:headImage];
        
        UILabel *nickName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(headImage.frame) + 10, 10, 300, 20)];
        nickName.textColor = HEXCOLOR(0x323232);
        nickName.userInteractionEnabled = NO;
        nickName.text = ab.addressBookName;
        nickName.backgroundColor = [UIColor clearColor];
        nickName.font = [UIFont systemFontOfSize:16];
        nickName.tag = i;
        [btn addSubview:nickName];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(headImage.frame) + 10, CGRectGetMaxY(nickName.frame) + 5, 300, 20)];
        name.textColor = [UIColor lightGrayColor];
        name.userInteractionEnabled = NO;
        name.text = [NSString stringWithFormat:@"%@:%@",APP_NAME,ab.toUserName];
        name.backgroundColor = [UIColor clearColor];
        name.font = [UIFont systemFontOfSize:14];
        name.tag = i;
        [btn addSubview:name];
        
        UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-70, 20, 50, 24)];
        [addBtn setBackgroundColor:HEXCOLOR(0x4FC557)];
        [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addBtn setTitleColor:HEXCOLOR(0xdcdcdc) forState:UIControlStateDisabled];
        addBtn.titleLabel.textColor = [UIColor whiteColor];
        addBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [addBtn setTitle:Localized(@"JX_Add") forState:UIControlStateNormal];
        [addBtn setTitle:Localized(@"JX_AlreadyAdded") forState:UIControlStateDisabled];
        [addBtn addTarget:self action:@selector(addBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        addBtn.layer.cornerRadius = 3.0;
        addBtn.layer.masksToBounds = YES;
        addBtn.tag = i;
        [btn addSubview:addBtn];
        JXUserObject *user = [[JXUserObject sharedInstance] getUserById:ab.toUserId];
        if ([user.status intValue] == 2) {
            addBtn.enabled = NO;
            checkBox.hidden = YES;
            addBtn.backgroundColor = [UIColor clearColor];
        }else {
            addBtn.enabled = YES;
            checkBox.hidden = NO;
            addBtn.backgroundColor = HEXCOLOR(0x4FC557);
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 63.5, JX_SCREEN_WIDTH, LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
        y += 64;
    }
}

- (void)headerBtnAction:(UIButton *)btn {
    JXAddressBook *ad = self.abUreadArr[btn.tag];
    if (self.isShowSelect) {
        JXUserObject *user = [[JXUserObject sharedInstance] getUserById:ad.toUserId];
        if ([user.status intValue] != 2) {
            QCheckBox *selCheckBox;
            for (NSInteger i = 0; i < _headerCheckBoxs.count; i ++) {
                QCheckBox *checkBox = _headerCheckBoxs[i];
                if (checkBox.tag == btn.tag) {
                    selCheckBox = checkBox;
                    break;
                }
            }
            selCheckBox.selected = !selCheckBox.selected;
            [self addressBookCell:nil checkBoxSelectIndexNum:btn.tag isSelect:selCheckBox.selected];
        }
    }else {
        JXUserInfoVC* vc = [JXUserInfoVC alloc];
        vc.userId       = ad.toUserId;
        vc.fromAddType = 6;
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
    }
}

- (void)addBtnAction:(UIButton *)btn {
    JXAddressBook *ab = self.abUreadArr[btn.tag];
    [self addressBookCell:nil addBtnAction:ab];
    
}

- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked{
        [self addressBookCell:nil checkBoxSelectIndexNum:checkbox.tag isSelect:checked];
}

- (void)selectBtnAction:(UIButton *)btn {
    self.isShowSelect = YES;
    
    if (self.doneBtn.hidden == YES) {
        self.doneBtn.hidden = NO;
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - JX_SCREEN_BOTTOM);
//        [self.gotoBackBtn setFrame:CGRectMake(self.gotoBackBtn.frame.origin.x, self.gotoBackBtn.frame.origin.y, self.gotoBackBtn.frame.size.width+20, self.gotoBackBtn.frame.size.height)];
        [self.gotoBackBtn setBackgroundImage:nil forState:UIControlStateNormal];
        [self.gotoBackBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
        
        CGSize size = [Localized(@"JX_Cencal") sizeWithAttributes:@{NSFontAttributeName:SYSFONT(15)}];
        
        self.gotoBackBtn.frame = CGRectMake(self.gotoBackBtn.frame.origin.x, self.gotoBackBtn.frame.origin.y, size.width+18, self.gotoBackBtn.frame.size.height);
        
        [btn setTitle:Localized(@"JX_CheckAll") forState:UIControlStateNormal];
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
    }else {
        self.isAllSelect = !self.isAllSelect;
        if (self.isAllSelect) {
            for (int i = 0 ; i < self.letterResultArr.count; i++) {
                NSArray *arr = [self.letterResultArr objectAtIndex:i];
                if (arr.count > 1) {
                    for (JXAddressBook *ad in arr) {
                        JXUserObject *user = [[JXUserObject sharedInstance] getUserById:ad.toUserId];
                        if ([user.status intValue] != 2 && [user.status intValue] != -1) {
                            [_selectABs addObject:ad];
                        }
                    }
                }else {
                    
                    JXAddressBook *ad = [arr firstObject];
                    JXUserObject *user = [[JXUserObject sharedInstance] getUserById:ad.toUserId];
                    if ([user.status intValue] != 2 && [user.status intValue] != -1) {
                        [_selectABs addObject:ad];
                    }
                }
            }
        }else {
            [_selectABs removeAllObjects];
        }
    }

    [self.tableView reloadData];
//    self.isShowSelect = !self.isShowSelect;
//    [self.tableView reloadData];
//    if (self.isShowSelect) {
//        [btn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
//        self.doneBtn.hidden = NO;
//        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - JX_SCREEN_BOTTOM);
//    }else {
//        [btn setTitle:Localized(@"JX_BatchAddition") forState:UIControlStateNormal];
//        [_selectABs removeAllObjects];
//        self.doneBtn.hidden = YES;
//        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self_height-self.heightHeader-self.heightFooter);
//    }
    
    if (self.abUreadArr.count > 0) {
        [self createHeaderView:self.abUreadArr];
    }
}

- (void)actionQuit {
    if (self.isShowSelect) {
        [self resetViwe];
        return;
    }
    
    [super actionQuit];
}

- (void)resetViwe {
    self.isShowSelect = NO;
    self.isAllSelect = NO;
    [_selectABs removeAllObjects];
    
    [_selectBtn setTitle:Localized(@"JX_BatchInvite") forState:UIControlStateNormal];
    _selectBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.gotoBackBtn setTitle:nil forState:UIControlStateNormal];
//    [self.gotoBackBtn setFrame:CGRectMake(self.gotoBackBtn.frame.origin.x, self.gotoBackBtn.frame.origin.y, self.gotoBackBtn.frame.size.width-20, self.gotoBackBtn.frame.size.height)];
    [self.gotoBackBtn setBackgroundImage:[UIImage imageNamed:@"title_back_black_big"] forState:UIControlStateNormal];
    self.gotoBackBtn.frame = CGRectMake(self.gotoBackBtn.frame.origin.x, self.gotoBackBtn.frame.origin.y, 46, self.gotoBackBtn.frame.size.height);

    [_selectABs removeAllObjects];
    self.doneBtn.hidden = YES;
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self_height-self.heightHeader-self.heightFooter);
    [self.tableView reloadData];

}

- (void)doneBtnAction:(UIButton *)btn {
    NSMutableString *userIds = [NSMutableString string];
    NSMutableString *userNames = [NSMutableString string];
    if (_selectABs.count <= 0) {
        [g_App showAlert:Localized(@"JX_PleaseSelectContacts")];
        return;
    }
    for (NSInteger i = 0; i < _selectABs.count; i ++) {
        JXAddressBook *ab = _selectABs[i];
        JXUserObject *user = [[JXUserObject alloc] init];
        user.userId = ab.toUserId;
        user.userNickname = ab.toUserName;
        user.status = [NSNumber numberWithInt:2];
        
        user.userType = [NSNumber numberWithInt:0];
        user.roomFlag = [NSNumber numberWithInt:0];
        user.content = nil;
        user.timeSend = [NSDate date];
        user.chatRecordTimeOut = g_myself.chatRecordTimeOut;
        [user insert];
        if (i == 0) {
            [userIds appendString:user.userId];
            [userNames appendString:ab.addressBookName];
        }else {
            [userIds appendFormat:@",%@",user.userId];
            [userNames appendFormat:@",%@",ab.addressBookName];
        }
    }
    _selectUserIds = [userIds copy];
    _selectUserNames = [userNames copy];
    [g_server friendsAttentionBatchAddToUserIds:userIds toView:self];
}

- (void)getServerData {
    [_array removeAllObjects];
    [_allAbArr removeAllObjects];
    NSMutableArray *arr = [[JXAddressBook sharedInstance] fetchAllAddressBook];
    for (NSInteger i = 0; i < arr.count; i ++) {
        JXAddressBook *ab = arr[i];
        if (_phoneNumDict[ab.toTelephone]) {
            [_allAbArr addObject:ab];
            BOOL flag = NO;
            for (NSInteger j = 0; j < self.abUreadArr.count; j ++) {
                JXAddressBook *abUread = self.abUreadArr[j];
                if ([abUread.toUserId isEqualToString:ab.toUserId]) {
                    flag = YES;
                    break;
                }
            }
            if (!flag) {
                [_array addObject:ab];
            }
        }
    }
    //选择拼音 转换的 方法
    BMChineseSortSetting.share.sortMode = 2; // 1或2
    //排序 Person对象
    [BMChineseSort sortAndGroup:_array key:@"addressBookName" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
        if (isSuccess) {
            self.indexArray = sectionTitleArr;
            self.letterResultArr = sortedObjArr;
            [_table reloadData];
        }
    }];

//    //根据Person对象的 name 属性 按中文 对 Person数组 排序
//    self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"addressBookName"];
//    self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"addressBookName"];
}
#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return [self.indexArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return [self.indexArray objectAtIndex:section];
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.tintColor = HEXCOLOR(0xF2F2F2);
    [header.textLabel setTextColor:HEXCOLOR(0x999999)];
    [header.textLabel setFont:SYSFONT(15)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 27;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)[self.letterResultArr objectAtIndex:section] count];
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{

    return self.indexArray;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"JXAddressBookCell";
    JXAddressBookCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    JXAddressBook *addressBook = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (!cell) {
        cell = [[JXAddressBookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.delegate = self;
    cell.index = indexPath.section * 1000 + indexPath.row;
//    cell.isShowSelect = self.isShowSelect;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.isAllSelect) {
        cell.isShowSelect = YES;
        cell.checkBox.selected = YES;
    }else {
        cell.isShowSelect = self.isShowSelect;
        if ([_selectABs containsObject:addressBook]) {
            cell.checkBox.selected = YES;
        }else {
            cell.checkBox.selected = NO;
        }
    }

    cell.addressBook = addressBook;
    cell.headImage.userInteractionEnabled = NO;
    
    if (indexPath.row == [(NSArray *)[self.letterResultArr objectAtIndex:indexPath.section] count]-1) {
        cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width,0);
    }else {
        cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width,LINE_WH);
    }

    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JXAddressBookCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.isShowSelect) {
        JXUserObject *user = [[JXUserObject sharedInstance] getUserById:cell.addressBook.toUserId];
        if ([user.status intValue] != 2) {
            cell.checkBox.selected = !cell.checkBox.selected;
            [self addressBookCell:cell checkBoxSelectIndexNum:cell.index isSelect:cell.checkBox.selected];
        }
    }else {
        JXUserInfoVC* vc = [JXUserInfoVC alloc];
        vc.userId       = cell.addressBook.toUserId;
        vc.fromAddType = 6;
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
    }
}

- (void)addressBookCell:(JXAddressBookCell *)abCell checkBoxSelectIndexNum:(NSInteger)indexNum isSelect:(BOOL)isSelect {
    
    JXAddressBook *ab;
    if (abCell) {
        ab = [[self.letterResultArr objectAtIndex:abCell.index / 1000] objectAtIndex:abCell.index % 1000];
    }else {
        ab = self.abUreadArr[indexNum];
    }
    if (isSelect) {
        [_selectABs addObject:ab];
    }else {
        [_selectABs removeObject:ab];
    }
}

- (void)addressBookCell:(JXAddressBookCell *)abCell addBtnAction:(JXAddressBook *)addressBook {
    
    JXMessageObject* p = [[JXMessageObject alloc] init];
    
    p.fromUserId     = MY_USER_ID;
    p.toUserId   = addressBook.toUserId;
    p.isMySend    = YES;
    p.content      = Localized(@"JX_AddYouByPhone");
    
    p.type         = [NSNumber numberWithInt:kWCMessageTypeText];
    p.isSend       = [NSNumber numberWithInt:transfer_status_yes];
    p.isRead       = [NSNumber numberWithInt:1];
    p.timeSend     = [NSDate date];
    [p insert:nil];
    [p notifyNewMsg];
    
    JXUserObject *user = [[JXUserObject alloc] init];
    user.userId = addressBook.toUserId;
    user.userNickname = addressBook.toUserName;
    user.status = [NSNumber numberWithInt:2];
    
    user.userType = [NSNumber numberWithInt:0];
    user.roomFlag = [NSNumber numberWithInt:0];
    user.content = p.content;
    user.timeSend = [NSDate date];
    user.chatRecordTimeOut = g_myself.chatRecordTimeOut;
    [user insert];

    _selectUserIds = [addressBook.toUserId copy];
    _selectUserNames = [addressBook.addressBookName copy];
    [g_server friendsAttentionBatchAddToUserIds:addressBook.toUserId toView:self];
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:act_FriendsAttentionBatchAdd] ){
        [g_notify postNotificationName:kFriendListRefresh object:nil];
        
//        self.isShowSelect = NO;
//        [_selectBtn setTitle:Localized(@"JX_BatchAddition") forState:UIControlStateNormal];
//        [_selectABs removeAllObjects];
//        self.doneBtn.hidden = YES;
//        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self_height-self.heightHeader-self.heightFooter);
        [self resetViwe];
        [self getServerData];
        
        if (self.abUreadArr.count > 0) {
            [self createHeaderView:self.abUreadArr];
        }
        [g_App showAlert:Localized(@"JX_AddSuccess")];
        
        [self updateNewFriend];
    }
    
}

- (void)updateNewFriend {
    
    NSArray *arr = [_selectUserIds componentsSeparatedByString:@","];
    NSArray *nameArr = [_selectUserNames componentsSeparatedByString:@","];
    
    for (NSInteger i = 0; i < arr.count; i ++) {
        NSString *userId = arr[i];
        NSString *userName = nameArr[i];
        JXMessageObject* p = [[JXMessageObject alloc] init];
        p.fromUserId   = MY_USER_ID;
        p.fromUserName = MY_USER_NAME;
        p.toUserId     = userId;
        p.toUserName   = userName;
        p.type         = [NSNumber numberWithInt:XMPP_TYPE_CONTACTFRIEND];
        p.timeSend     = [NSDate date];
        p.isSend       = [NSNumber numberWithInt:transfer_status_ing];
        [p setMsgId];
        
        JXFriendObject* friend = [[JXFriendObject alloc]init];
        [friend loadFromMessageObj:p];
        [friend doWriteDb];
        [friend notifyNewRequest];
    }
}


-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
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
