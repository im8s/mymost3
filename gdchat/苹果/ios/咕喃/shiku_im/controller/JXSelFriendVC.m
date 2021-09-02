//
//  JXSelFriendVC.h.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXSelFriendVC.h"
#import "JXChatViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "JXImageView.h"
#import "JXCell.h"
#import "JXRoomPool.h"
#import "JXTableView.h"
#import "JXNewFriendViewController.h"
#import "menuImageView.h"
#import "QCheckBox.h"
#import "JXRoomObject.h"
#import "NSString+ContainStr.h"
#import "JXMessageObject.h"
#import "BMChineseSort.h"


@interface JXSelFriendVC ()<UITextFieldDelegate, UIAlertViewDelegate,JXRoomObjectDelegate>
@property (nonatomic, strong) UITextField *seekTextField;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) UIButton* finishBtn;
@property (nonatomic, strong) memberData *transferMember;


//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;

@end

@implementation JXSelFriendVC
@synthesize chatRoom,room,isNewRoom,set,array=_array;

- (id)init
{
    self = [super init];
    if (self) {
        
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack   = YES;
        //self.view.frame = g_window.bounds;
        self.isShowFooterPull = NO;
        _searchArray = [NSMutableArray array];
        _userIds = [NSMutableArray array];
        _userNames = [NSMutableArray array];
        set   = [[NSMutableSet alloc] init];
        _selMenu = 0;
        
        [g_notify addObserver:self selector:@selector(newReceipt:) name:kXMPPReceiptNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(onSendTimeout:) name:kXMPPSendTimeOutNotifaction object:nil];
        
        [g_notify addObserver:self selector:@selector(refreshNotif:) name:kLabelVCRefreshNotif object:nil];
    }
    return self;
}

- (void)refreshNotif:(NSNotification *)notif {
    [self actionQuit];
}

-(void)dealloc{
    //移除监听
    [g_notify removeObserver:self];
    [set removeAllObjects];
    [_array removeAllObjects];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createHeadAndFoot];
    if (_type == JXSelUserTypeGroupAT ||_type == JXSelUserTypeSpecifyAdmin || _type == JXSelUserTypeRoomTransfer || _type == JXSelUserTypeRoomInvisibleMan ||_type == JXSelUserTypeRoomMonitorPeople) {
        
    }else{
        
        _finishBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_finishBtn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
        [_finishBtn setTitle:Localized(@"JX_Confirm") forState:UIControlStateHighlighted];
        [_finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _finishBtn.layer.masksToBounds = YES;
        _finishBtn.layer.cornerRadius = 3.f;
        [_finishBtn setBackgroundColor:THEMECOLOR];
        UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
        [_finishBtn setBackgroundImage:img forState:UIControlStateHighlighted];
        [_finishBtn.titleLabel setFont:SYSFONT(15)];
        _finishBtn.frame = CGRectMake(JX_SCREEN_WIDTH - 51 - 15, JX_SCREEN_TOP - 8 - 29, 51, 29);
        [_finishBtn addTarget:self action:@selector(onAdd:) forControlEvents:UIControlEventTouchUpInside];
        [self.tableHeader addSubview:_finishBtn];
    }
    [self customSearchTextField];
    
    [self getDataArrayByType];
}

-(void)getDataArrayByType{
    self.isShowFooterPull = NO;
    self.isShowHeaderPull = NO;

    if (_type == JXSelUserTypeGroupAT || _type == JXSelUserTypeSelMembers || _type == JXSelUserTypeRoomTransfer) {
        if(_type == JXSelUserTypeSelMembers){
            self.title = Localized(@"JXSip_invite");
            [self getSelUserTypeSelMembersArray];
        }else{
            self.title = Localized(@"JX_GroupAtMember");
            if (_type == JXSelUserTypeRoomTransfer) {
                self.title = Localized(@"JX_SelectNewGroupManager");
            }
            [self getGroupATRoomMembersArray];
        }
        [_table reloadData];
    }else if(_type == JXSelUserTypeSpecifyAdmin || _type == JXSelUserTypeRoomInvisibleMan || _type == JXSelUserTypeRoomMonitorPeople){
        if (_type == JXSelUserTypeSpecifyAdmin) {
            self.title = Localized(@"JXRoomMemberVC_SetAdministrator");
        }else if (_type == JXSelUserTypeRoomInvisibleMan){
            self.title = Localized(@"JXDesignatedStealthMan");
        }else {
            self.title = Localized(@"JXDesignatedMonitor");
        }
        [self getRoomMembersArray];
        [_table reloadData];
    }else if (_type == JXSelUserTypeCustomArray) {
//        self.title
        [_table reloadData];
    }
    else{
        self.title = Localized(@"JXSelFriendVC_SelFriend");
        _array=[[NSMutableArray alloc] init];
        [self refresh];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)customSearchTextField{
    
    //搜索输入框
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 55)];
//    backView.backgroundColor = HEXCOLOR(0xf0f0f0);
    [self.view addSubview:backView];
    
//    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(backView.frame.size.width-5-45, 5, 45, 30)];
//    [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
//    [cancelBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
//    [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    cancelBtn.titleLabel.font = SYSFONT(14);
//    [backView addSubview:cancelBtn];
    
    
    _seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, backView.frame.size.width - 30, 35)];
    _seekTextField.placeholder = Localized(@"JX_EnterKeyword");
    [_seekTextField setFont:SYSFONT(14)];
    _seekTextField.backgroundColor = HEXCOLOR(0xf0f0f0);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_search"]];
    UIView *leftView = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 40, 30)];
    //    imageView.center = CGPointMake(leftView.frame.size.width/2, leftView.frame.size.height/2);
    imageView.frame = CGRectMake(15, 7.5, 15, 15);
    [leftView addSubview:imageView];
    _seekTextField.leftView = leftView;
    _seekTextField.leftViewMode = UITextFieldViewModeAlways;
    _seekTextField.borderStyle = UITextBorderStyleNone;
    _seekTextField.layer.masksToBounds = YES;
    _seekTextField.layer.cornerRadius = 17.5f;
    _seekTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _seekTextField.delegate = self;
    _seekTextField.returnKeyType = UIReturnKeyGoogle;
    [backView addSubview:_seekTextField];
    [_seekTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    
    self.tableView.tableHeaderView = backView;
    
}

- (void) textFieldDidChange:(UITextField *)textField {
    
    if (textField.text.length <= 0) {
        [self getDataArrayByType];
        return;
    }

    [_searchArray removeAllObjects];
//    NSMutableArray *arr = [_array mutableCopy];
//    for (NSInteger i = 0; i < arr.count; i ++) {
//        
//        NSString * nameStr = nil;
//        NSString * cardNameStr = nil;
//        NSString * nickNameStr = nil;
//        if ([arr[i] isMemberOfClass:[memberData class]]) {
//            memberData *obj = arr[i];
//            nameStr = obj.userName;
//            cardNameStr = obj.cardName;
//            nickNameStr = obj.userNickName;
//        }else if ([arr[i] isMemberOfClass:[JXUserObject class]]) {
//            JXUserObject * obj = arr[i];
//            nameStr = obj.userNickname;
//        }
//        nameStr = !nameStr ? @"" : nameStr;
//        cardNameStr = !cardNameStr ? @"" : cardNameStr;
//        nickNameStr = !nickNameStr ? @"" : nickNameStr;
//        NSString * allStr = [NSString stringWithFormat:@"%@%@%@",nameStr,cardNameStr,nickNameStr];
//        if ([[allStr lowercaseString] containsMyString:[textField.text lowercaseString]]) {
//            [_searchArray addObject:arr[i]];
//        }
//        
//    }
    
    if (_type == JXSelUserTypeGroupAT || _type == JXSelUserTypeSelMembers || _type == JXSelUserTypeSpecifyAdmin || _type == JXSelUserTypeRoomTransfer) {
        
//        _searchArray = [memberData searchMemberByFilter:textField.text room:room.roomId];
        for (NSInteger i = 0; i < _array.count; i ++) {
            memberData *data = _array[i];
            memberData *data1 = [self.room getMember:g_myself.userId];
            JXUserObject *allUser = [[JXUserObject alloc] init];
            allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",data.userId]];
            NSString *name = [NSString string];
            if ([data1.role intValue] == 1) {
                name = data.lordRemarkName.length > 0  ? data.lordRemarkName : allUser.remarkName.length > 0  ? allUser.remarkName : data.userNickName;
            }else {
                name = allUser.remarkName.length > 0  ? allUser.remarkName : data.userNickName;
            }
            
            NSString *userStr = [name lowercaseString];
            NSString *textStr = [textField.text lowercaseString];
            if ([userStr rangeOfString:textStr].location != NSNotFound) {
                [_searchArray addObject:data];
            }
        }

    }else{
        for (NSInteger i = 0; i < _array.count; i ++) {
            id user = _array[i];
            
            NSString *userStr;
            if ([user isKindOfClass:[JXUserObject class]]) {
                
                JXUserObject *newUser = user;
                
                userStr = [newUser.userNickname lowercaseString];
            }
            else if ([user isKindOfClass:[memberData class]]){
                memberData *newMem = user;
                
                userStr = [newMem.userNickName lowercaseString];
            }
            
            NSString *textStr = [textField.text lowercaseString];
            if ([userStr rangeOfString:textStr].location != NSNotFound) {
                [_searchArray addObject:user];
            }
        }
    }
    
//    _searchArray = [memberData searchMemberByFilter:textField.text room:room.roomId];
    
    [self.tableView reloadData];
}


- (void) cancelBtnAction {
    _seekTextField.text = nil;
    [_seekTextField resignFirstResponder];
    [self getDataArrayByType];
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
        return 1;
    }
    return [self.indexArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_seekTextField.text.length > 0) {
        return Localized(@"JXFriend_searchTitle");
    }
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
    if (_seekTextField.text.length > 0) {
        return _searchArray.count;
    }
    return [(NSArray *)[self.letterResultArr objectAtIndex:section] count];
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
//    NSArray * tempArray;
//
//    if (_seekTextField.text.length > 0) {
//        tempArray = _searchArray;
//    }else{
//        tempArray = _array;
//    }
    
    JXCell *cell=nil;
    NSString* cellName = [NSString stringWithFormat:@"selVC_%d_%d",_refreshCount,(int)indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if (!cell) {
        cell = [[JXCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    
//    if(cell==nil){
        if (_type == JXSelUserTypeGroupAT || _type == JXSelUserTypeSpecifyAdmin ||  _type == JXSelUserTypeSelMembers || _type == JXSelUserTypeRoomTransfer|| _type == JXSelUserTypeRoomInvisibleMan|| _type == JXSelUserTypeRoomMonitorPeople) {
            memberData * member;
            if (_seekTextField.text.length > 0) {
                member = _searchArray[indexPath.row];
            }else{
                member = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            }
//            cell = [[JXCell alloc] init];
            [_table addToPool:cell];
            NSString *name = [NSString string];
            memberData *data = [self.room getMember:g_myself.userId];
            JXUserObject *allUser = [[JXUserObject alloc] init];
            allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",member.userId]];
            if ([data.role intValue] == 1) {
                name = member.lordRemarkName ? member.lordRemarkName : allUser.remarkName.length > 0  ? allUser.remarkName : member.userNickName;
            }else {
                name = allUser.remarkName.length > 0  ? allUser.remarkName : member.userNickName;
            }
            if (!self.room.allowSendCard && [data.role intValue] != 1 && [data.role intValue] != 2 && member.userId > 0) {
                name = [name substringToIndex:[name length]-1];
                name = [name stringByAppendingString:@"*"];
            }

            cell.title = name;
            cell.positionTitle = [self positionStrRole:[member.role integerValue]];
            if(!member.idStr){//所有人不显示
//                cell.subtitle = [NSString stringWithFormat:@"%ld",member.userId];
            }else{
                cell.headImage = @"groupImage";
            }
//            cell.bottomTitle = [TimeUtil formatDate:user.timeCreate format:@"MM-dd HH:mm"];
            cell.userId = [NSString stringWithFormat:@"%ld",member.userId];
//            [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            cell.isSmall = YES;
            [cell headImageViewImageWithUserId:nil roomId:nil];
            
            if (_type == JXSelUserTypeGroupAT) {
                if(member.idStr){
                    if (room.roomId != nil) {
//                        NSString *groupImagePath = [NSString stringWithFormat:@"%@%@/%@.%@",NSTemporaryDirectory(),g_myself.userId,room.roomId,@"jpg"];
//                        if (groupImagePath && [[NSFileManager defaultManager] fileExistsAtPath:groupImagePath]) {
//                            cell.headImageView.image = [UIImage imageWithContentsOfFile:groupImagePath];
//                        }else{
//                            [roomData roomHeadImageRoomId:room.roomId toView:cell.headImageView];
//                        }
                        [g_server getRoomHeadImageSmall:room.roomJid roomId:room.roomId imageView:cell.headImageView getHeadHandler:nil];
                    }
                }
            }
            
            if(_type == JXSelUserTypeSelMembers){
                QCheckBox* btn = [[QCheckBox alloc] initWithDelegate:self];
                btn.frame = CGRectMake(JX_SCREEN_WIDTH-40, 15, 25, 25);
                btn.tag = indexPath.row;
                BOOL b = NO;
                NSString* s = [NSString stringWithFormat:@"%ld",member.userId];
                b = [_existSet containsObject:s];
                btn.selected = b;
                btn.userInteractionEnabled = !b;
                [cell addSubview:btn];
            }

        }else if (_type == JXSelUserTypeCustomArray || _type == JXSelUserTypeDisAble) {
            JXUserObject *user;
            if (_seekTextField.text.length > 0) {
                user = _searchArray[indexPath.row];
            }else{
                user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            }
            [_table addToPool:cell];
            cell.title = user.userNickname;
//            cell.subtitle = user.userId;
//            cell.bottomTitle = [TimeUtil formatDate:user.timeCreate format:@"MM-dd HH:mm"];
            cell.userId = user.userId;
            cell.isSmall = YES;
            [cell headImageViewImageWithUserId:nil roomId:nil];
            //        cell.headImage   = user.userHead;
            //            [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            
            QCheckBox* btn = [[QCheckBox alloc] initWithDelegate:self];
            btn.frame = CGRectMake(JX_SCREEN_WIDTH-40, 15, 25, 25);
            btn.tag = indexPath.row;
            
            if (self.disableSet) {
                btn.enabled = ![_disableSet containsObject:user.userId];
            }else{
                btn.enabled = YES;
            }
            
            [cell addSubview:btn];
        }else{
            JXUserObject *user;
            if (_seekTextField.text.length > 0) {
                user = _searchArray[indexPath.row];
            }else{
                user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            }
//            cell = [[JXCell alloc] init];
            [_table addToPool:cell];
            cell.title = user.userNickname;
//            cell.subtitle = user.userId;
            cell.bottomTitle = [TimeUtil formatDate:user.timeCreate format:@"MM-dd HH:mm"];
            cell.userId = user.userId;
            cell.isSmall = YES;
            [cell headImageViewImageWithUserId:nil roomId:nil];
            //        cell.headImage   = user.userHead;
//            [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            
            QCheckBox* btn = [[QCheckBox alloc] initWithDelegate:self];
            btn.frame = CGRectMake(JX_SCREEN_WIDTH-40, 15, 25, 25);
            btn.tag = indexPath.section * 1000 + indexPath.row;
            BOOL b = NO;
            if (room){
                b = [room isMember:user.userId];
                btn.selected = b;
                btn.userInteractionEnabled = !b;
            }else{
                
                b = [_existSet containsObject:user.userId];
                if (_type == JXSelUserTypeSelFriends) {
                    btn.selected = b;
                }else {
                    btn.enabled = !b;
                }
                
            }
            
            [cell addSubview:btn];
        }
    if (indexPath.row == [(NSArray *)[self.letterResultArr objectAtIndex:indexPath.section] count]-1) {
        cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width,0);
    }else {
        cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width,LINE_WH);
    }

//    }
//    else{
//        
//        NSLog(cellName);
//    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_type == JXSelUserTypeGroupAT) {
        memberData * member;
        if (_seekTextField.text.length > 0) {
            member = _searchArray[indexPath.row];
        }else{
            member = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        }
        if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelect])
            [self.delegate performSelectorOnMainThread:self.didSelect withObject:member waitUntilDone:YES];
        
        [self actionQuit];
//        _pSelf = nil;
    }else if (_type == JXSelUserTypeRoomTransfer) {
        memberData * member;
        if (_seekTextField.text.length > 0) {
            member = _searchArray[indexPath.row];
        }else{
            member = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        }
        _transferMember = member;
        [g_App showAlert:[NSString stringWithFormat:Localized(@"JX_GroupUpdateManagerStatus"),member.userNickName] delegate:self tag:2458 onlyConfirm:NO];
    }
    
    else if (_type == JXSelUserTypeSpecifyAdmin || _type == JXSelUserTypeRoomInvisibleMan || _type == JXSelUserTypeRoomMonitorPeople) {
        
        memberData * member;
        if (_seekTextField.text.length > 0) {
            member = _searchArray[indexPath.row];
        }else{
            member = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        }
        if (_type == JXSelUserTypeSpecifyAdmin) {
            if ([member.role intValue] == 1) {
                [g_App showAlert:Localized(@"JXGroup_CantSetSelf")];
                return;
            }
            if ([member.role intValue] == 5) {
                [g_App showAlert:Localized(@"JX_MonitorCannotAdministrator")];
                return;
            }
            if ([member.role intValue] == 4) {
                [g_App showAlert:Localized(@"JX_InvisibleCannotAdministrator")];
                return;
            }
        }else {
            if ([member.role intValue] == 1 || [member.role intValue] == 2) {
                [g_App showAlert:Localized(@"JX_UnableSetGroupManagerAndAdministrator")];
                return;
            }
            if (_type == JXSelUserTypeRoomInvisibleMan){
                if ([member.role intValue] == 5) {
                    [g_App showAlert:Localized(@"JX_YouCannotSetMonitor")];
                    return;
                }
            }else {
                if ([member.role intValue] == 4) {
                    [g_App showAlert:Localized(@"JX_YouCannotSetInvisible")];
                    return;
                }
            }
        }
        if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelect])
            [self.delegate performSelectorOnMainThread:self.didSelect withObject:member waitUntilDone:YES];
        
        [self actionQuit];

    }else {
        JXCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        QCheckBox *btn = (QCheckBox *)[cell viewWithTag:indexPath.row];
        btn.selected = !btn.selected;
        if(btn.selected){
            [set addObject:[NSNumber numberWithInteger:btn.tag]];
        }
        else{
            [set removeObject:[NSNumber numberWithInteger:btn.tag]];
        }
    }
}

-(void)getGroupATRoomMembersArray{
//    _array = (NSMutableArray *)[memberData fetchAllMembers:room.roomId sortByName:YES];
    _array = (NSMutableArray *)[memberData fetchAllMembersAndHideMonitor:room.roomId sortByName:YES];
    memberData *roomOwner = [memberData searchGroupOwner:room.roomId];
    if (_type == JXSelUserTypeGroupAT && [[NSString stringWithFormat:@"%ld",roomOwner.userId] isEqualToString:MY_USER_ID] ) {
        memberData * mem = [[memberData alloc] init];
        mem.userId = 0;
        mem.idStr = room.roomJid;
        mem.roomId = room.roomId;
        mem.userNickName = Localized(@"JX_AtALL");
        mem.cardName = Localized(@"JX_AtALL");
        mem.role = [NSNumber numberWithInt:10];
        //    mem.createTime = [[rs objectForColumnName:@"createTime"] longLongValue];
        
        [_array insertObject:mem atIndex:0];
    }
    
    [self reomveExistsSet];
    //选择拼音 转换的 方法
    BMChineseSortSetting.share.sortMode = 2; // 1或2
    //排序 Person对象
    [BMChineseSort sortAndGroup:_array key:@"userNickName" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
        if (isSuccess) {
            self.indexArray = sectionTitleArr;
            self.letterResultArr = sortedObjArr;
            [_table reloadData];
        }
    }];

//    //根据Person对象的 name 属性 按中文 对 Person数组 排序
//    self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickName"];
//    self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickName"];
}

-(void)getSelUserTypeSelMembersArray{
//    _array = (NSMutableArray *)[memberData fetchAllMembers:room.roomId sortByName:YES];
    if ([[NSString stringWithFormat:@"%ld",self.room.userId] isEqualToString:MY_USER_ID]) {
        _array = (NSMutableArray *)[memberData fetchAllMembers:room.roomId sortByName:YES];
    }else {
        _array = (NSMutableArray *)[memberData fetchAllMembersAndHideMonitor:room.roomId sortByName:YES];
    }

    [self reomveExistsSet];
    //选择拼音 转换的 方法
    BMChineseSortSetting.share.sortMode = 2; // 1或2
    //排序 Person对象
    [BMChineseSort sortAndGroup:_array key:@"userNickName" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
        if (isSuccess) {
            self.indexArray = sectionTitleArr;
            self.letterResultArr = sortedObjArr;
            [_table reloadData];
        }
    }];

//    //根据Person对象的 name 属性 按中文 对 Person数组 排序
//    self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickName"];
//    self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickName"];
}

-(void)getRoomMembersArray{
    if ([[NSString stringWithFormat:@"%ld",self.room.userId] isEqualToString:MY_USER_ID]) {
        _array = (NSMutableArray *)[memberData fetchAllMembers:room.roomId sortByName:NO];
    }else {
        _array = (NSMutableArray *)[memberData fetchAllMembersAndHideMonitor:room.roomId sortByName:NO];
    }
    
    [self reomveExistsSet];
    //选择拼音 转换的 方法
    BMChineseSortSetting.share.sortMode = 2; // 1或2
    //排序 Person对象
    [BMChineseSort sortAndGroup:_array key:@"userNickName" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
        if (isSuccess) {
            self.indexArray = sectionTitleArr;
            self.letterResultArr = sortedObjArr;
            [_table reloadData];
        }
    }];

//    //根据Person对象的 name 属性 按中文 对 Person数组 排序
//    self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickName"];
//    self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickName"];
}

-(void)reomveExistsSet{
    for(NSInteger i=[_array count]-1;i>=0;i--){
        memberData* p = [_array objectAtIndex:i];
        if([self.existSet containsObject:[NSString stringWithFormat:@"%ld",p.userId]]>0)
            [_array removeObjectAtIndex:i];
    }
}

-(void)getArrayData{
    _array=[[JXUserObject sharedInstance] fetchAllUserFromLocal];
    if (self.isShowMySelf) {
        JXUserObject *mySelf = [[JXUserObject alloc] init];
        mySelf.userId = g_myself.userId;
        mySelf.userNickname = g_myself.userNickname;
        [_array insertObject:mySelf atIndex:0];
    }
    
    for(NSInteger i=[_array count]-1;i>=0;i--){
        JXUserObject* u = [_array objectAtIndex:i];
        for (int j=0; j<[room.members count]; j++) {
            memberData* p = [room.members objectAtIndex:j];
            if(p.userId == [u.userId intValue]){
                [_array removeObjectAtIndex:i];
                break;
            }
        }
        
        if (self.isForRoom) {
            if([self.forRoomUser.userId isEqualToString:u.userId]){
                [_array removeObjectAtIndex:i];
            }
        }
    }
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

//    //根据Person对象的 name 属性 按中文 对 Person数组 排序
//    self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickname"];
//    self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickname"];
    if(isNewRoom && [_array count]<=0)//没有好友时
        [self performSelector:@selector(onAdd:) withObject:nil afterDelay:0.1];
}

-(void)refresh{
    [self stopLoading];
    _refreshCount++;
    [_array removeAllObjects];

    [self getArrayData];
    [_table reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 59;
}

-(void)scrollToPageUp{
    [self refresh];
}

- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked{
    if(checked){
        [set addObject:[NSNumber numberWithInteger:checkbox.tag]];
    }
    else{
        [set removeObject:[NSNumber numberWithInteger:checkbox.tag]];
    }
}

-(void)onAdd:(UIButton *)btn{
    btn.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        btn.enabled = YES;
    });
    
    if(_type == JXSelUserTypeSelFriends || chatRoom || self.isForRoom){
        
        [_userIds removeAllObjects];
        [_userNames removeAllObjects];
        
        if (self.isForRoom) {
            [_userIds addObject:self.forRoomUser.userId];
            [_userNames addObject:self.forRoomUser.userNickname];
        }
        
        for(NSNumber* n in set){
            //获取选中的好友
            JXUserObject *user;
            if (_seekTextField.text.length > 0) {
                user = _searchArray[[n intValue] % 1000];
            }else{
                user = [[self.letterResultArr objectAtIndex:[n intValue] / 1000] objectAtIndex:[n intValue] % 1000];
            }
            [_userIds addObject:user.userId];
            [_userNames addObject:user.userNickname];
            
            /*
             JXMessageObject* m = [[JXMessageObject alloc] init];
             m.messageId = [[[XMPPStream generateUUID] stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
             m.fromUserId = MY_USER_ID;
             m.fromUserName = kMY_USER_NICKNAME;
             m.toUserId = user.userId;
             m.toUserName = user.userNickname;
             m.type = [NSNumber numberWithInt:kWCMessageTypeInvite];
             m.isRead = [NSNumber numberWithBool:NO];
             m.isSend = [NSNumber numberWithBool:NO];
             m.timeSend     = [NSDate date];
             m.content = [room roomDataToNSString];
             m.isGroup = 0;
             [g_xmpp sendMessageInvite:m];
             
             //xmpp邀请加入房间，取消调用此协议
             NSString* to = [NSString stringWithFormat:@"%@@%@",user.userId,g_config.XMPPDomain];
             [chatRoom.xmppRoom inviteUser:[XMPPJID jidWithString:to] withMessage:[room roomDataToNSString] msgId:m.messageId];
             */
            
            /*邀请协议DEMO:
             <message to="3029b12761bb4476bd06f801f51e9f5d@muc.192.168.0.168" id="12348c13c51d0925b4815678" xmlns="jabber:client" from="10005629@192.168.0.168/youjob">
             <x xmlns="http://jabber.org/protocol/muc#user">
             <invite to="10005598@192.168.0.168"><reason>{"desc":"","id":"59858c13c51d0925b481ce1a","jid":"3029b12761bb4476bd06f801f51e9f5d","name":"陈叔叔","timeSend":1501925454,"userId":"10005629"}</reason></invite>
             </x></message>
             */
            
            user = nil;
        }
        if(self.isForRoom){
            
            NSString* s = [NSUUID UUID].UUIDString;
            s = [[s stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
            
            NSString *roomName = [NSString stringWithFormat:@"%@、%@",MY_USER_NAME,[_userNames componentsJoinedByString:@"、"]];
            
            room.roomJid= s;
            room.name   = roomName;
            room.desc   = nil;
            room.userId = [g_myself.userId longLongValue];
            room.userNickName = MY_USER_NAME;
            room.showRead = NO;
            room.showMember = YES;
            room.allowSendCard = YES;
            room.isLook = YES;
            room.isNeedVerify = NO;
            room.allowInviteFriend = YES;
            room.allowUploadFile = YES;
            room.allowConference = YES;
            room.allowSpeakCourse = YES;
            
            chatRoom = [[JXXMPP sharedInstance].roomPool createRoom:s title:roomName];
            chatRoom.delegate = self;
            
            [_wait start:Localized(@"JXAlert_CreatRoomIng") delay:30];
            return;
        }
        if ((self.room.isNeedVerify && self.room.userId != [g_myself.userId longLongValue]) || _type == JXSelUserTypeSelFriends) {
            
            if (self.isShowAlert) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localized(@"JX_SaveLabelNextTime") message:nil delegate:self cancelButtonTitle:Localized(@"JX_DepositAsLabel") otherButtonTitles:Localized(@"JX_Ignore"), nil];
                alert.tag = 2457;
                [alert show];
                return;
            }
            
            
            if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelect])
                [self.delegate performSelectorOnMainThread:self.didSelect withObject:self waitUntilDone:YES];
            [self actionQuit];
        }else {
            [g_server addRoomMember:room.roomId userArray:_userIds toView:self];//用接口即可
        }
        if(isNewRoom){
            [self onNewRoom];
            [self actionQuit];
        }
        return;
    }
    if (_type == JXSelUserTypeGroupAT || _type == JXSelUserTypeRoomTransfer)
        return;
    if (_type == JXSelUserTypeSpecifyAdmin || _type == JXSelUserTypeRoomInvisibleMan || _type == JXSelUserTypeRoomMonitorPeople)
        return;
    if (_type == JXSelUserTypeSelMembers){
    }
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelect])
        [self.delegate performSelectorOnMainThread:self.didSelect withObject:self waitUntilDone:YES];
    
    [self actionQuit];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2457) {
        if (buttonIndex == 0) {
            if ([self.delegate respondsToSelector:self.alertAction]) {
                [self.delegate performSelectorOnMainThread:self.alertAction withObject:self waitUntilDone:YES];
            }
        }else {
            if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelect])
                [self.delegate performSelectorOnMainThread:self.didSelect withObject:self waitUntilDone:YES];
            [self actionQuit];
        }
    }
    if (alertView.tag == 2458) {
        if (buttonIndex == 1) {
            if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelect])
                [self.delegate performSelectorOnMainThread:self.didSelect withObject:_transferMember waitUntilDone:YES];
            [self actionQuit];
        }
    }
    
}

-(void)xmppRoomDidCreate{
    [g_server addRoom:room isPublic:YES isNeedVerify:NO category:0 toView:self];
    chatRoom.delegate = nil;
}

-(void)onNewRoom{
    JXChatViewController *sendView=[JXChatViewController alloc];
    sendView.title = chatRoom.roomTitle;
    sendView.roomJid = chatRoom.roomJid;
    sendView.roomId = room.roomId;
    sendView.chatRoom = chatRoom;
    
    JXUserObject * user = [[JXUserObject alloc]init];
    user = [user getUserById:chatRoom.roomJid];
    sendView.chatPerson = user;

    sendView = [sendView init];
//    [g_App.window addSubview:sendView.view];
    [g_navigation pushViewController:sendView animated:YES];
}

-(NSString *)positionStrRole:(NSInteger)role{
    if (_type == JXSelUserTypeSpecifyAdmin || _type == JXSelUserTypeRoomInvisibleMan || _type == JXSelUserTypeRoomMonitorPeople) {
        NSString * roleStr = nil;
        switch (role) {
            case 1://创建者
                roleStr = Localized(@"JXGroup_Owner");
                break;
            case 2://管理员
                roleStr = Localized(@"JXGroup_Admin");
                break;
            case 3://普通成员
                roleStr = Localized(@"JXGroup_RoleNormal");
                break;
            case 4://隐身人
                roleStr = Localized(@"JXInvisibleMan");
                break;
            case 5://监控人
                roleStr = Localized(@"JXMonitorPerson");
                break;
            default:
                roleStr = Localized(@"JXGroup_RoleNormal");
                break;
        }
        return roleStr;
    }
    return nil;
}

-(void)onSendTimeout:(NSNotification *)notifacation//超时未收到回执
{
//    [_wait stop];
//    JXMessageObject *msg     = (JXMessageObject *)notifacation.object;
//    if([msg.type intValue] == kWCMessageTypeInvite)
//        [g_App showAlert:[NSString stringWithFormat:@"邀请：%@失败，请重新邀请",msg.toUserName]];
}

-(void)newReceipt:(NSNotification *)notifacation{//新回执
//    [_wait stop];
//    JXMessageObject *msg     = (JXMessageObject *)notifacation.object;
//    if([msg.type intValue] == kWCMessageTypeInvite)
//        [g_server addRoomMember:room.roomId userId:msg.toUserId nickName:msg.toUserName toView:self];
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:act_roomMemberSet] ){
        for (int i=0;i<[_userIds count];i++) {
            NSString *userId=[_userIds objectAtIndex:i];

            memberData* p = [[memberData alloc] init];
            p.userId = [userId intValue];
            p.userNickName = [_userNames objectAtIndex:i];
            p.role = [NSNumber numberWithInt:3];
            [room.members addObject:p];
        }
        if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelect])
            [self.delegate performSelectorOnMainThread:self.didSelect withObject:self waitUntilDone:YES];
        
        [_userIds removeAllObjects];
        [_userNames removeAllObjects];
        [self actionQuit];
//        _pSelf = nil;
    }
    
    if( [aDownload.action isEqualToString:act_roomAdd] ){
        room.roomId = [dict objectForKey:@"id"];
        //        _room.call = [NSString stringWithFormat:@"%@",[dict objectForKey:@"call"]];
        [self insertRoom];
        [g_notify postNotificationName:kUpdateUserNotifaction object:nil];
        [g_notify postNotificationName:kActionRelayQuitVC object:nil];
        [g_server addRoomMember:room.roomId userArray:_userIds toView:self];//用接口即可
        if(isNewRoom){
            [self onNewRoom];
        }
    }
}
-(void)insertRoom{
    JXUserObject* user = [[JXUserObject alloc]init];
    user.userNickname = room.name;
    user.userId = room.roomJid;
    user.userDescription = room.desc;
    user.roomId = room.roomId;
    user.showRead =  [NSNumber numberWithBool:room.showRead];
    user.showMember = [NSNumber numberWithBool:room.showMember];
    user.allowSendCard = [NSNumber numberWithBool:room.allowSendCard];
    user.chatRecordTimeOut = room.chatRecordTimeOut;
    user.talkTime = [NSNumber numberWithLong:room.talkTime];
    user.allowInviteFriend = [NSNumber numberWithBool:room.allowInviteFriend];
    user.allowUploadFile = [NSNumber numberWithBool:room.allowUploadFile];
    user.allowConference = [NSNumber numberWithBool:room.allowConference];
    user.allowSpeakCourse = [NSNumber numberWithBool:room.allowSpeakCourse];
    user.isNeedVerify = [NSNumber numberWithBool:room.isNeedVerify];
    
    [user insertRoom];
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

@end
