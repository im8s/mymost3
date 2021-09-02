//
//  JXBlackFriendVC.m
//  shiku_im
//
//  Created by p on 2018/6/4.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXBlackFriendVC.h"
#import "BMChineseSort.h"
#import "JXCell.h"
#import "JXUserInfoVC.h"
#import "JXChatViewController.h"
#import "JXRoomPool.h"
#import "JXDevice.h"

@interface JXBlackFriendVC ()<UITextFieldDelegate>

//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) UITextField *seekTextField;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) JXUserObject * currentUser;

@end

@implementation JXBlackFriendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack   = YES;
    self.isShowFooterPull = NO;
    _array = [NSMutableArray array];
    [self createHeadAndFoot];
    [g_notify addObserver:self selector:@selector(newReceipt:) name:kXMPPReceiptNotifaction object:nil];
    if (self.isDevice) {
        self.isShowHeaderPull = NO;
        [g_notify addObserver:self selector:@selector(updateIsOnLineMultipointLogin) name:kUpdateIsOnLineMultipointLogin object:nil];// 多点登录在线离线状态更新
    }
    if (!self.isDevice) {
        [self customView];
    }
    [self getArrayData];
}

- (void)scrollToPageUp {
    
    if (!self.isDevice) {
        
        [g_server listBlacklist:0 toView:self];
    }
}

- (void)customView {
    //搜索输入框
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 55)];
//    backView.backgroundColor = HEXCOLOR(0xf0f0f0);
    [self.view addSubview:backView];
    
    //    [seekImgView release];
    
    //    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(backView.frame.size.width-5-45, 5, 45, 30)];
    //    [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    //    [cancelBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    //    [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    //    cancelBtn.titleLabel.font = SYSFONT(14.0);
    //    [backView addSubview:cancelBtn];
    
    
    _seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, backView.frame.size.width - 30, 35)];
    _seekTextField.placeholder = [NSString stringWithFormat:@"%@",Localized(@"JX_EnterKeyword")];
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
    _seekTextField.layer.cornerRadius = 17.4f;
    _seekTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _seekTextField.delegate = self;
    _seekTextField.returnKeyType = UIReturnKeyGoogle;
    [backView addSubview:_seekTextField];
    [_seekTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    
    self.tableView.tableHeaderView = backView;
}

- (void)getArrayData {
    [self.array removeAllObjects];
    //获取黑名單列表
    
    if (self.isDevice) {
        _array = [[JXDevice sharedInstance] fetchAllDeviceFromLocal];
        self.isShowHeaderPull = NO;
        self.isShowFooterPull = NO;
    }else {
        //从数据库获取好友staus为-1的
        _array=[[JXUserObject sharedInstance] fetchAllBlackFromLocal];
        if (_array.count <= 0) {
            [self scrollToPageUp];
        }
    }
    //选择拼音 转换的 方法
    BMChineseSortSetting.share.sortMode = 2; // 1或2
    //排序 Person对象
    [BMChineseSort sortAndGroup:_array key:@"userNickname" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
        if (isSuccess) {
            self.indexArray = sectionTitleArr;
            self.letterResultArr = sortedObjArr;
            [self.tableView reloadData];
        }
    }];

//    //根据Person对象的 name 属性 按中文 对 Person数组 排序
//    self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickname"];
//    self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickname"];
//
//    [self.tableView reloadData];
}

- (void)updateIsOnLineMultipointLogin {
    [self getArrayData];

    [_table reloadData];
}

- (void) textFieldDidChange:(UITextField *)textField {
    
    if (textField.text.length <= 0) {
        [self getArrayData];
        [self.tableView reloadData];
        return;
    }
    
    [_searchArray removeAllObjects];
    _searchArray = [[JXUserObject sharedInstance] fetchBlackFromLocalWhereLike:textField.text];
    
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

#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_seekTextField.text.length > 0) {
        return 1;
    }
    return [self.indexArray count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.isDevice) {
        return nil;
    }
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_seekTextField.text.length > 0) {
        return _searchArray.count;
    }
    return [(NSArray *)[self.letterResultArr objectAtIndex:section] count];
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (_seekTextField.text.length > 0 || self.isDevice) {
        return nil;
    }
    return self.indexArray;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JXUserObject *user;
    if (_seekTextField.text.length > 0) {
        user = _searchArray[indexPath.row];
    }else{
        user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    
    
    JXCell *cell=nil;
    NSString* cellName = @"JXCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if(cell==nil){
        
        cell = [[JXCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        [_table addToPool:cell];
        
        //        cell.headImage   = user.userHead;
        //        user = nil;
    }
    
    if (self.isDevice) {
        cell.title = [self multipleLoginIsOnlineTitle:user];
    }else {
        cell.title = user.remarkName.length > 0 ? user.remarkName : user.userNickname;
    }
    //    cell.subtitle = user.userId;
    cell.index = (int)indexPath.row;
    cell.delegate = self;
    if (!self.isDevice) {
        cell.didTouch = @selector(onHeadImage:);
    }
    //    cell.bottomTitle = [TimeUtil formatDate:user.timeCreate format:@"MM-dd HH:mm"];
    [cell setForTimeLabel:[TimeUtil formatDate:user.timeCreate format:@"MM-dd HH:mm"]];
    cell.timeLabel.frame = CGRectMake(JX_SCREEN_WIDTH - 115-15, 19.5, 115, 20);
    cell.userId = user.userId;
    [cell.lbTitle setText:cell.title];
    
    cell.dataObj = user;
    //    cell.headImageView.tag = (int)indexPath.row;
    //    cell.headImageView.delegate = cell.delegate;
    //    cell.headImageView.didTouch = cell.didTouch;
    
    cell.isSmall = YES;
    [cell headImageViewImageWithUserId:nil roomId:nil];
    
    if (self.isDevice) {
        cell.headImageView.frame = CGRectMake(6, 8, 40, 40);
        cell.lbTitle.frame = CGRectMake(CGRectGetMaxX(cell.headImageView.frame)+4, 19.5, 230, 20);
        cell.lineView.frame = CGRectMake(CGRectGetMaxX(cell.headImageView.frame)+4, 58.5, JX_SCREEN_WIDTH-CGRectGetMaxX(cell.headImageView.frame)-4, LINE_WH);
    }
    
    if (indexPath.row == [(NSArray *)[self.letterResultArr objectAtIndex:indexPath.section] count]-1) {
        cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width,0);
    }else {
        cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width,LINE_WH);
    }

    return cell;
}

- (NSString *)multipleLoginIsOnlineTitle:(JXUserObject *)user {
    NSString *isOnline;
    if ([user.isOnLine intValue] == 1) {
        isOnline = [NSString stringWithFormat:@"(%@)", Localized(@"JX_OnLine")];
    }else {
        isOnline = [NSString stringWithFormat:@"(%@)", Localized(@"JX_OffLine")];
    }
    NSString *title = user.userNickname;
    title = [title stringByAppendingString:isOnline];
    return title;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JXUserObject *user;
    if (_seekTextField.text.length > 0) {
        user = _searchArray[indexPath.row];
    }else{
        user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }

    if (self.isDevice) {
        JXCell * cell = [_table cellForRowAtIndexPath:indexPath];
        cell.selected = NO;
        
        
        JXChatViewController *sendView=[JXChatViewController alloc];
        if([user.roomFlag intValue] > 0  || user.roomId.length > 0){
            sendView.roomJid = user.userId;
            sendView.roomId = user.roomId;
            [[JXXMPP sharedInstance].roomPool joinRoom:user.userId title:user.userNickname lastDate:nil isNew:NO];
        }
        sendView.title = user.userNickname;
        sendView.chatPerson = user;
        sendView = [sendView init];
        //    [g_App.window addSubview:sendView.view];
        [g_navigation pushViewController:sendView animated:YES];
    }else {
        _currentUser = user;
        JXUserInfoVC *userVC = [JXUserInfoVC alloc];
        userVC.userId = user.userId;
        userVC.fromAddType = 6;
        userVC = [userVC init];
        [g_navigation pushViewController:userVC animated:YES];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.isDevice) {
        return NO;
    }

    if (_seekTextField.text.length <= 0){

        return YES;
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
    UITableViewRowAction *cancelBlackBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Localized(@"REMOVE") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        JXUserObject *user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        _currentUser = user;
        [g_server delBlacklist:user.userId toView:self];
    }];
    
    return @[cancelBlackBtn];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 59;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

//服务器返回数据
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    [_wait stop];
    [self stopLoading];
//    //更新本地好友
//    if ([aDownload.action isEqualToString:act_AttentionList]) {
//        [_wait stop];
//        JXProgressVC * pv = [JXProgressVC alloc];
//        // 服务端不会返回新朋友 ， 减去新朋友
//        pv.dbFriends = (long)[_array count] - 1;
//        pv.dataArray = array1;
//        pv = [pv init];
//        //        [g_window addSubview:pv.view];
//    }
    
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
    
    
    
    if ([aDownload.action isEqualToString:act_BlacklistList]) {
        
        [[JXUserObject sharedInstance] deleteAllBlackUser];
        
        for (int i = 0; i< [array1 count]; i++) {
            NSDictionary * dict = array1[i];
            JXUserObject * user = [[JXUserObject alloc]init];
            //数据转为一个好友对象
            [user getDataFromDictSmall:dict];
            //访问数据库是否存在改好友，没有则写入数据库
            if (user.userId.length > 5) {
                [user insertFriend];
            }
        }
        if (array1.count > 0) {
            [self getArrayData];
        }
    }
}



-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    [self stopLoading];
    
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    [self stopLoading];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
}

-(void)newFriend:(NSObject*)sender{
    [self getArrayData];
}

-(void)onHeadImage:(id)dataObj{
    
    JXUserObject *p = (JXUserObject *)dataObj;
    if([p.userId isEqualToString:FRIEND_CENTER_USERID] || [p.userId isEqualToString:CALL_CENTER_USERID])
        return;
    
    _currentUser = p;
//    [g_server getUser:p.userId toView:self];
    
    JXUserInfoVC* vc = [JXUserInfoVC alloc];
    vc.userId       = p.userId;
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
    [JXMyTools showTipView:Localized(@"JXAlert_SendFilad")];
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
            [g_App showAlert:Localized(@"JXAlert_DeleteFirend")];
        }
    }
    
    if([msg.type intValue] == XMPP_TYPE_BLACK){//拉黑
        
        [_array removeObject:_currentUser];
        
        //选择拼音 转换的 方法
        BMChineseSortSetting.share.sortMode = 2; // 1或2
        //排序 Person对象
        [BMChineseSort sortAndGroup:_array key:@"userNickname" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
            if (isSuccess) {
                self.indexArray = sectionTitleArr;
                self.letterResultArr = sortedObjArr;
                [self.tableView reloadData];
            }
        }];

//        //根据Person对象的 name 属性 按中文 对 Person数组 排序
//        self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickname"];
//        self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickname"];
//        [self.tableView reloadData];
    }
    
    if([msg.type intValue] == XMPP_TYPE_NOBLACK){
        //        _currentUser.status = [NSNumber numberWithInt:friend_status_friend];
        //        int status = [_currentUser.status intValue];
        //        [_currentUser update];
        
        if ([[JXXMPP sharedInstance].blackList containsObject:_currentUser.userId]) {
            [[JXXMPP sharedInstance].blackList removeObject:_currentUser.userId];
        }
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
}

- (void)friendRemarkNotif:(NSNotification *)notif {
    
    JXUserObject *user = notif.object;
    for (int i = 0; i < _array.count; i ++) {
        JXUserObject *user1 = _array[i];
        if ([user.userId isEqualToString:user1.userId]) {
            user1.userNickname = user.userNickname;
            [_table reloadData];
            break;
        }
    }
}
- (void)dealloc {
    [g_notify removeObserver:self];
    //    [_table release];
    [_array removeAllObjects];
    //    [_array release];
    //    [super dealloc];
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
