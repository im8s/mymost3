//
//  JXRoomMemberListVC.m
//  shiku_im
//
//  Created by p on 2018/7/3.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXRoomMemberListVC.h"
#import "roomData.h"
#import "JXRoomMemberListCell.h"
#import "BMChineseSort.h"
#import "JXUserInfoVC.h"
#import "JXActionSheetVC.h"
#import "JXInputValueVC.h"

@interface JXRoomMemberListVC ()<UITextFieldDelegate,LXActionSheetDelegate, UIAlertViewDelegate,JXActionSheetVCDelegate>

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) UITextField *seekTextField;


//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;

@property (nonatomic, strong) memberData *currentMember;

@property (nonatomic, strong) JXUserObject *user;

@end

@implementation JXRoomMemberListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack   = YES;
    //self.view.frame = g_window.bounds;
//    self.isShowFooterPull = NO;
    
    [self createHeadAndFoot];
    


    _searchArray = [NSMutableArray array];
    
    [self.tableView registerClass:[JXRoomMemberListCell class] forCellReuseIdentifier:@"JXRoomMemberListCell"];
    [self customSearchTextField];
    
    self.user = [[JXUserObject sharedInstance] getUserById:self.room.roomJid];
    
    _array = (NSMutableArray *)[memberData fetchAllMembers:self.room.roomId sortByName:NO];
    if (_array.count > 0) {
        
        if ([self.user.joinTime timeIntervalSince1970] <= 0) {
            
            memberData *member = _array.lastObject;
            self.user.joinTime = [NSDate dateWithTimeIntervalSince1970:member.createTime];
        }
        
        [self refresh];
    }else {
        self.user.joinTime = [NSDate dateWithTimeIntervalSince1970:0];
        [self getServerData];
    }
}

- (void)scrollToPageUp {
    self.user.joinTime = [NSDate dateWithTimeIntervalSince1970:0];
    [self getServerData];
}
- (void)scrollToPageDown {
    [self getServerData];
}

- (void)getServerData {
    
    [g_server roomMemberGetMemberListByPageWithRoomId:self.room.roomId joinTime:[self.user.joinTime timeIntervalSince1970] toView:self];
}

- (void)refresh {
 
    _array = (NSMutableArray *)[memberData fetchAllMembers:self.room.roomId sortByName:NO];
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
}

- (void)customSearchTextField{
    
    //搜索输入框
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 55)];
//    backView.backgroundColor = HEXCOLOR(0xf0f0f0);
    [self.view addSubview:backView];
    
    
    _seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, backView.frame.size.width - 30, 35)];
    _seekTextField.placeholder = Localized(@"JX_EnterKeyword");
    _seekTextField.textColor = [UIColor blackColor];
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
    _seekTextField.layer.cornerRadius = 35*0.5;
    _seekTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _seekTextField.delegate = self;
    _seekTextField.returnKeyType = UIReturnKeyGoogle;
    [backView addSubview:_seekTextField];
    [_seekTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
    self.tableView.tableHeaderView = backView;
    
}

- (void) textFieldDidChange:(UITextField *)textField {
    
    if (textField.text.length <= 0) {
        
        [self.tableView reloadData];
        return;
    }
    
    [_searchArray removeAllObjects];

    for (NSInteger i = 0; i < _array.count; i ++) {
        memberData *data = _array[i];
        JXUserObject *allUser = [[JXUserObject alloc] init];
        allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",data.userId]];
        NSString *name = [NSString string];
        if ([[NSString stringWithFormat:@"%ld",_room.userId] isEqualToString:MY_USER_ID]) {
            name = data.lordRemarkName ? data.lordRemarkName : allUser.remarkName.length > 0  ? allUser.remarkName : data.userNickName;
        }else {
            name = allUser.remarkName.length > 0  ? allUser.remarkName : data.userNickName;
        }

        NSString *userStr = [name lowercaseString];
        NSString *textStr = [textField.text lowercaseString];
        if ([userStr rangeOfString:textStr].location != NSNotFound) {
            [_searchArray addObject:data];
        }
    }
    [self.tableView reloadData];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 59;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    JXRoomMemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JXRoomMemberListCell" forIndexPath:indexPath];
    cell.curManager = [NSString stringWithFormat:@"%ld",_room.userId];
    memberData *data;
    if (_seekTextField.text.length > 0) {
        data = _searchArray[indexPath.row];
    }else{
        data = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
//    memberData *d = [self.room getMember:[NSString stringWithFormat:@"%ld",data.userId]];
    cell.room = self.room;
    cell.role = [data.role intValue];
    cell.data = data;
    
    [self doAutoScroll:indexPath];
    
    if (indexPath.row == [(NSArray *)[self.letterResultArr objectAtIndex:indexPath.section] count]-1) {
        cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width,0);
    }else {
        cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width,LINE_WH);
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    memberData *data = [self.room getMember:g_myself.userId];
    if (([data.role intValue] != 1 && [data.role intValue] != 2) && !self.room.allowSendCard) {
        [g_App showAlert:Localized(@"JX_NotAllowMembersSeeInfo")];
        return;
    }

    memberData * member;
    if (_seekTextField.text.length > 0) {
        member = _searchArray[indexPath.row];
    }else{
        member = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    switch (self.type) {
        case Type_Default:{
            JXUserInfoVC* userVC = [JXUserInfoVC alloc];
            userVC.userId = [NSString stringWithFormat:@"%ld",member.userId];
            userVC.fromAddType = 3;
            userVC = [userVC init];
            
            [g_navigation pushViewController:userVC animated:YES];
        }
            break;
        case Type_NotTalk:{
//            memberData *selfData = [self.room getMember:MY_USER_ID];
//            memberData *d = [self.room getMember:[NSString stringWithFormat:@"%ld",member.userId]];
            memberData *mem = [[memberData alloc] init];
            mem.roomId = self.room.roomId;
            
            memberData *selfData = [mem getCardNameById:MY_USER_ID];
            memberData *d = [mem getCardNameById:[NSString stringWithFormat:@"%ld",member.userId]];
            
            if ([selfData.role intValue] == 1) {
                if ([d.role intValue] == 1) {
                    [g_App showAlert:Localized(@"JX_Can'tSilenceTheOwner")];
                    return;
                }
            }else {
                if ([d.role intValue] == 1 || [d.role intValue] == 2) {
                    [g_App showAlert:Localized(@"JX_Can'tBanManager")];
                    return;
                }
            }
            
            if ([d.role intValue] == 4) {
                [g_App showAlert:Localized(@"JX_YouCan'tKeepYourMouthShut")];
                return;
            }
            if ([d.role intValue] == 5) {
                [g_App showAlert:@"不能禁言监控人"];
                return;
            }
            _currentMember = member;
            [self onDisableSay:nil];
        }
            break;
        case Type_DelMember:{
            
            
            memberData *data = [self.room getMember:g_myself.userId];
            if ([data.role intValue] == 1) {
                if ([member.role intValue] == 1) {
                    
                    [g_App showAlert:Localized(@"JX_Can'tDeleteManager")];
                    return;
                }
            }
            
            
            if ([data.role intValue] == 2) {
                if ([member.role intValue] == 1 || [member.role intValue] == 2) {
                    
                    [g_App showAlert:Localized(@"JX_Can'tDeleteManager")];
                    return;
                }
            }
            
            _currentMember = member;
            
            JXUserObject *allUser = [[JXUserObject alloc] init];
            allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",member.userId]];
            NSString *name;
            if ([[NSString stringWithFormat:@"%ld",_room.userId] isEqualToString:MY_USER_ID]) {
                name = member.lordRemarkName.length > 0  ? member.lordRemarkName : allUser.remarkName.length > 0  ? allUser.remarkName : member.userNickName;
            }else {
                name = allUser.remarkName.length > 0  ? allUser.remarkName : member.userNickName;
            }
            
            
            [g_App showAlert:[NSString stringWithFormat:@"%@ %@",Localized(@"JX_DetermineToDelete"),name] delegate:self tag:2457 onlyConfirm:NO];
        }
            break;
        case Type_AddNotes:{
            JXUserObject *allUser = [[JXUserObject alloc] init];
            allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",member.userId]];
            NSString *name = [NSString string];
            if ([[NSString stringWithFormat:@"%ld",_room.userId] isEqualToString:MY_USER_ID]) {
                name = member.lordRemarkName ? member.lordRemarkName : allUser.remarkName.length > 0  ? allUser.remarkName : member.userNickName;
            }else {
                name = allUser.remarkName.length > 0  ? allUser.remarkName : member.userNickName;
            }
            JXInputValueVC* vc = [JXInputValueVC alloc];
            vc.value = name;
            vc.userId = [NSString stringWithFormat:@"%ld",member.userId];
            vc.title = Localized(@"JXRoomMemberVC_UpdateNickName");
            vc.delegate  = self;
            vc.didSelect = @selector(onSaveNickName:);
            vc.isLimit = YES;
            vc = [vc init];
            [g_navigation pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

-(void)onSaveNickName:(JXInputValueVC*)vc{
    if (self.delegate && [self.delegate respondsToSelector:@selector(roomMemberList:addNotesVC:)]) {
        memberData* p = [_room getMember:vc.userId];
        if ([p.role intValue] == 1) {
            p.userNickName = vc.value;
        }else {
            p.lordRemarkName = vc.value;
        }
        [p update];
        
        _array = (NSMutableArray *)[memberData fetchAllMembers:self.room.roomId sortByName:NO];
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

//        //根据Person对象的 name 属性 按中文 对 Person数组 排序
//        self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickName"];
//        self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickName"];

        [self.delegate roomMemberList:self addNotesVC:vc];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2457) {
        if (buttonIndex == 1) {
            
            [self onDelete:nil];
        }
    }
}

-(void)onDisableSay:(JXImageView*)sender{

//    _disable = (int)sender.tag;
    
//    LXActionSheet* _menu = [[LXActionSheet alloc]
//                            initWithTitle:nil
//                            delegate:self
//                            cancelButtonTitle:nil
//                            destructiveButtonTitle:Localized(@"JX_Cencal")
//                            otherButtonTitles:@[Localized(@"JXAlert_NotGag"),Localized(@"JXAlert_GagTenMinute"),Localized(@"JXAlert_GagOneHour"),Localized(@"JXAlert_GagOne"),Localized(@"JXAlert_GagThere"),Localized(@"JXAlert_GagOneWeek"),Localized(@"JXAlert_GagOver")]];
//    [g_window addSubview:_menu];
    JXActionSheetVC *actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:@[Localized(@"JXAlert_NotGag"),Localized(@"JXAlert_GagTenMinute"),Localized(@"JXAlert_GagOneHour"),Localized(@"JXAlert_GagOne"),Localized(@"JXAlert_GagThere"),Localized(@"JXAlert_GagOneWeek"),Localized(@"JXAlert_GagFifteen")]];
    actionVC.delegate = self;
    [self presentViewController:actionVC animated:NO completion:nil];

}

- (void)actionSheet:(JXActionSheetVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    NSTimeInterval n = [[NSDate date] timeIntervalSince1970];
    memberData* member = _currentMember;
    switch (index) {
        case 0:
            member.talkTime = 0;
            break;
        case 1:
            member.talkTime = 10*60+n;
            break;
        case 2:
            member.talkTime = 1*3600+n;
            break;
        case 3:
            member.talkTime = 24*3600+n;
            break;
        case 4:
            member.talkTime = 3*24*3600+n;
            break;
        case 5:
            member.talkTime = 7*24*3600+n;
            break;
        case 6:
            member.talkTime = 15*24*3600+n;
            break;
        default:
            break;
    }
    
    [g_server setDisableSay:self.room.roomId member:member toView:self];
    member = nil;
}

//- (void)didClickOnButtonIndex:(LXActionSheet*)sender buttonIndex:(int)buttonIndex{
//    if(buttonIndex==0)
//        return;
//    NSTimeInterval n = [[NSDate date] timeIntervalSince1970];
//    memberData* member = _currentMember;
//    switch (buttonIndex) {
//        case 1:
//            member.talkTime = 0;
//            break;
//        case 2:
//            member.talkTime = 10*60+n;
//            break;
//        case 3:
//            member.talkTime = 1*3600+n;
//            break;
//        case 4:
//            member.talkTime = 24*3600+n;
//            break;
//        case 5:
//            member.talkTime = 3*24*3600+n;
//            break;
//        case 6:
//            member.talkTime = 7*24*3600+n;
//            break;
//        case 7:
//            member.talkTime = 3000*24*3600+n;
//            break;
//    }
//    [g_server setDisableSay:self.room.roomId member:member toView:self];
//    
////    _modifyType = kRoomRemind_DisableSay;
////    _toUserId = [NSString stringWithFormat:@"%ld",member.userId];
////    _toUserName = member.userNickName;
//    
//    
//    member = nil;
//}

-(void)onDelete:(JXImageView*)sender{
    
    [g_server delRoomMember:self.room.roomId userId:_currentMember.userId toView:self];

}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:act_roomMemberSet] ){
        
        [g_App showAlert:Localized(@"JXAlert_SetOK")];
    }
    
    if( [aDownload.action isEqualToString:act_roomMemberDel] ){

        //在xmpp中删除成员
//        [self.chatRoom removeUser:_currentMember];
        [self.room.members removeObject:_currentMember];
        [_currentMember remove];
        if ([self.delegate respondsToSelector:@selector(roomMemberList:delMember:)]) {
            [self.delegate roomMemberList:self delMember:_currentMember];
        }
        
        _array = (NSMutableArray *)[memberData fetchAllMembers:self.room.roomId sortByName:NO];
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
//        //根据Person对象的 name 属性 按中文 对 Person数组 排序
//        self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickName"];
//        self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickName"];

        [g_App showAlert:Localized(@"JXAlert_DeleteOK")];
        
    }

    if ([aDownload.action isEqualToString:act_roomMemberGetMemberListByPage]) {
        
        [self stopLoading];
        
        if (array1.count < kRoomMemberListNum) {
            self.isShowFooterPull = NO;
        }
        
        NSDictionary *lastDict = array1.lastObject;
        self.user.joinTime = [NSDate dateWithTimeIntervalSince1970:[lastDict[@"createTime"] longValue]];
        [self.user updateJoinTime];
        
        for (NSDictionary *member in array1) {
            memberData* option = [[memberData alloc] init];
            [option getDataFromDict:member];
            option.roomId = self.room.roomId;
            [option insert];
        }
        [self refresh];
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
