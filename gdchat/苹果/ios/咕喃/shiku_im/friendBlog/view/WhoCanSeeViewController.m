//
//  WhoCanSeeViewController.m
//  shiku_im
//
//  Created by 1 on 17/11/7.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "WhoCanSeeViewController.h"
#import "JXSelFriendVC.h"
#import "JXLabelObject.h"
#import "JXWhoCanSeeCell.h"
#import "JXNewLabelVC.h"
#import "JXSelectFriendsVC.h"
#import "BMChineseSort.h"

@interface WhoCanSeeViewController ()<UITableViewDelegate,UITableViewDataSource, JXWhoCanSeeCellDelegate>

@property (nonatomic, strong) NSArray * titleArray;
@property (nonatomic, strong) NSArray * subTitleArray;
@property (nonatomic, strong) UITableView * table;
@property (nonatomic, strong) UIButton * finishBtn;
@property (nonatomic, assign) int checkIndex;
@property (nonatomic, strong) NSMutableArray *labelsArray;

@property (nonatomic, strong) NSMutableArray * selArray;

@property (nonatomic, strong) JXLabelObject *editLabel;


@end

@implementation WhoCanSeeViewController

-(void)setType:(int)type{
    _type = type;
    _checkIndex = type - 1;
}

-(instancetype)init{
    if (self = [super init]) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
        _titleArray = [NSArray arrayWithObjects:Localized(@"JXBlogVisibel_public"), Localized(@"JXBlogVisibel_private"), Localized(@"JXBlogVisibel_see"), Localized(@"JXBlogVisibel_nonSee"), nil];
        _subTitleArray = [NSArray arrayWithObjects:Localized(@"JXBlogVisibelDes_public"), Localized(@"JXBlogVisibelDes_private"), Localized(@"JXBlogVisibelDes_see"), Localized(@"JXBlogVisibelDes_nonsee"), nil];
//        _labelsArray = [[JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
        _selLabelsArray = [NSMutableArray array];
        _selArray = [NSMutableArray array];
        _mailListUserArray = [NSMutableArray array];
        _checkIndex = 0;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createHeadAndFoot];
    [self.tableHeader addSubview:self.finishBtn];
    [self.view addSubview:self.table];
    
    [g_notify addObserver:self selector:@selector(refreshNotif:) name:kLabelVCRefreshNotif object:nil];
    
}

- (void)dealloc {
    [g_notify removeObserver:self];
    [g_notify removeObserver:self name:kLabelVCRefreshNotif object:nil];
}

- (void)refreshNotif:(NSNotification *)notif {
    _labelsArray = [[JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
    for (JXLabelObject *labelObj in _labelsArray) {
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
    
    [_selLabelsArray removeObject:self.editLabel];
    for (JXLabelObject *label in _labelsArray) {
        if ([label.groupName isEqualToString:self.editLabel.groupName]) {
            [_selLabelsArray addObject:label];
            break;
        }
    }
    [self.table reloadData];
}

-(UIButton *)finishBtn{
    if (!_finishBtn) {
        
        CGSize size = [Localized(@"JX_Finish") sizeWithAttributes:@{NSFontAttributeName:SYSFONT(15)}];
        
        _finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishBtn.frame = CGRectMake(JX_SCREEN_WIDTH-size.width-15, JX_SCREEN_TOP - 30, size.width, 15);
        [_finishBtn setTitle:Localized(@"JX_Finish") forState:UIControlStateNormal];
        [_finishBtn.titleLabel setFont:SYSFONT(15)];
        [_finishBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_finishBtn addTarget:self action:@selector(finishBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishBtn;
}

-(UITableView *)table{
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_TOP) style:UITableViewStylePlain];
        _table.dataSource = self;
        _table.delegate = self;
        _table.tableFooterView = [[UIView alloc] init];
        [_table registerClass:[JXWhoCanSeeCell class] forCellReuseIdentifier:@"JXWhoCanSeeCell"];
    }
    return _table;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 60)];
    view.tag = section;
    [view addTarget:self action:@selector(headerBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 10, 10)];
    imageView.image = [UIImage imageNamed:@"ic_selected_done_2"];
    [view addSubview:imageView];
    imageView.hidden = YES;
    if (section == _checkIndex) {
        imageView.hidden = NO;
    }
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(30, 6, self_width-30-30, 20)];
    p.text = _titleArray[section];
    p.font = g_factory.font16;
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    [view addSubview:p];
    
    JXLabel* detail = [[JXLabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(p.frame)+6, self_width-30-30, 17)];
    detail.text = _subTitleArray[section];
    detail.font = g_factory.font15;
    detail.backgroundColor = [UIColor clearColor];
    detail.textColor = [UIColor grayColor];
    [view addSubview:detail];
    
    UIImageView *showImageView = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 40, 15, 20, 20)];
    showImageView.image = [UIImage imageNamed:@"ic_selected_done_2"];
    [view addSubview:showImageView];
    showImageView.hidden = YES;
    if (section == 2 || section == 3) {
        showImageView.hidden = NO;
    }
    if (_labelsArray.count > 0) {
        if (section == _checkIndex) {
            showImageView.image = [UIImage imageNamed:@"pack_up_1"];
        }else {
            showImageView.image = [UIImage imageNamed:@"room_unfold"];
        }
    }else {
        showImageView.image = [UIImage imageNamed:@"room_unfold"];
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60 - LINE_WH, JX_SCREEN_WIDTH, LINE_WH)];
    lineView.backgroundColor = THE_LINE_COLOR;
    [view addSubview:lineView];
    
    return view;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 2 || section == 3) {
        if (_checkIndex == section) {
            if (_labelsArray.count > 0) {
                return _labelsArray.count + 1;
            }else {
                return 0;
            }
        }
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == _labelsArray.count) {
        UITableViewCell *tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tableViewCell"];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 6, JX_SCREEN_WIDTH-60-30, 20)];
        label.text = Localized(@"JX_FromTheAddressBookSelection");
        label.font = [UIFont systemFontOfSize:16.0];
        label.textColor = HEXCOLOR(0x576b95);
        [tableViewCell.contentView addSubview:label];
        
        NSMutableString *nameStr = [NSMutableString string];
        for (NSInteger i = 0; i < _mailListUserArray.count; i ++) {
            JXUserObject *user = _mailListUserArray[i];
            if (i == 0) {
                [nameStr appendString:user.userNickname];
            }else {
                [nameStr appendFormat:@",%@", user.userNickname];
            }
        }
        label = [[UILabel alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(label.frame)+6, JX_SCREEN_WIDTH-60-30, 17)];
        label.text = nameStr;
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = HEXCOLOR(0x4FC557);
        
        [tableViewCell.contentView addSubview:label];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60 - LINE_WH, JX_SCREEN_WIDTH, LINE_WH)];
        lineView.backgroundColor = THE_LINE_COLOR;
        [tableViewCell.contentView addSubview:lineView];
        
        return tableViewCell;
    }
    
    
    JXWhoCanSeeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JXWhoCanSeeCell" forIndexPath:indexPath];
    
    
    JXLabelObject *labelObj = _labelsArray[indexPath.row];
    cell.title.text = labelObj.groupName;
    cell.index = indexPath.row;
    cell.delegate = self;
    
    BOOL flag = NO;
    for (NSInteger i = 0; i < _selLabelsArray.count; i ++) {
        JXLabelObject *label = _selLabelsArray[i];
        if ([labelObj.groupName isEqualToString:label.groupName]) {
            flag = YES;
            break;
        }
    }
    
    if (flag) {
        cell.contentBtn.selected = YES;
        cell.selImageView.image = [UIImage imageNamed:@"sel_check_wx2"];
    }else {
        cell.contentBtn.selected = NO;
        cell.selImageView.image = [UIImage imageNamed:@"sel_nor_wx2"];
    }
    NSString *userIdStr = labelObj.userIdList;
    NSArray *userIds = [userIdStr componentsSeparatedByString:@","];
    if (userIdStr.length <= 0) {
        userIds = nil;
    }
    NSMutableString *userNameStr = [NSMutableString string];
    for (NSInteger i = 0; i < userIds.count; i ++) {
        NSString *userId = userIds[i];
        NSString *userName = [JXUserObject getUserNameWithUserId:userId];
        if (i == 0) {
            [userNameStr appendFormat:@"%@", userName];
        }else {
            [userNameStr appendFormat:@", %@", userName];
        }
        
    }
    cell.userNames.text = userNameStr;
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == _labelsArray.count) {
        JXSelectFriendsVC *vc = [[JXSelectFriendsVC alloc] init];
        vc.type = JXSelUserTypeSelFriends;
        vc.isShowAlert = YES;
        vc.alertAction = @selector(selectFriendsAlertAction:);
        vc.delegate = self;
        vc.didSelect = @selector(selectFriendsDelegate:);
        
        NSMutableSet *set = [NSMutableSet set];
        for (NSInteger i = 0; i < self.mailListUserArray.count; i ++) {
            JXUserObject *user = self.mailListUserArray[i];
            [set addObject:user.userId];
        }
        
        NSMutableArray *friends = [[JXUserObject sharedInstance] fetchAllUserFromLocal];
        __block NSMutableArray *letterResultArr = [NSMutableArray array];
        //排序 Person对象
        [BMChineseSort sortAndGroup:friends key:@"userNickname" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
            if (isSuccess) {
                letterResultArr = unGroupArr;
            }
        }];
//        NSMutableArray *letterResultArr = [BMChineseSort sortObjectArray:friends Key:@"userNickname"];
        NSMutableSet *numSet = [NSMutableSet set];
        for (NSInteger i = 0; i < letterResultArr.count; i ++) {
            NSMutableArray *arr = letterResultArr[i];
            for (NSInteger j = 0; j < arr.count; j ++) {
                JXUserObject *user = arr[j];
                if ([set containsObject:user.userId]) {
                    [numSet addObject:[NSNumber numberWithInteger:i * 1000 + j]];
                }
            }
            
        }
        if (numSet.count > 0) {
            vc.set = numSet;
        }
        vc.existSet = set;
        
        
        [g_navigation pushViewController:vc animated:YES];
    }
    
//    NSArray * cellArray = [_table visibleCells];
//    for (UITableViewCell * cell in cellArray) {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
//    _checkIndex = (int)indexPath.row;
//    UITableViewCell * cell = [_table cellForRowAtIndexPath:indexPath];
//    cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    cell.selected = NO;
//
//    if (indexPath.row == 2 || indexPath.row == 3) {
//        JXSelFriendVC * selVC = [[JXSelFriendVC alloc] init];
//        selVC.delegate = self;
//        selVC.didSelect = @selector(selFriendsDelegate:);
//
//        if (indexPath.row == 2) {
//
//        }else if (indexPath.row == 3) {
//
//        }
////        [g_window addSubview:selVC.view];
//        [g_navigation pushViewController:selVC animated:YES];
//    }
}

- (void)selectFriendsDelegate:(JXSelFriendVC *)vc {
    
    [_mailListUserArray removeAllObjects];
    
    for (NSInteger i = 0; i < vc.userIds.count; i ++) {
        JXUserObject *user = [[JXUserObject alloc] init];
        user.userId = vc.userIds[i];
        user.userNickname = vc.userNames[i];
        
        [_mailListUserArray addObject:user];
    }

    [self.table reloadData];
}

- (void)selectFriendsAlertAction:(JXSelFriendVC *)selFriendVC {
    JXLabelObject *label = [[JXLabelObject alloc] init];
    label.userIdList = [selFriendVC.userIds componentsJoinedByString:@","];
    JXNewLabelVC *vc = [[JXNewLabelVC alloc] init];
    vc.title = Localized(@"JX_SettingLabel");
    vc.labelObj = label;
    [g_navigation pushViewController:vc animated:YES];
}

- (void)whoCanSeeCell:(JXWhoCanSeeCell *)whoCanSeeCell selectAction:(NSInteger)index {
    
    JXLabelObject *labelObj = _labelsArray[index];
    JXLabelObject *selObj;
    for (JXLabelObject *obj in _selLabelsArray) {
        if ([labelObj.groupName isEqualToString:obj.groupName]) {
            selObj = obj;
            break;
        }
    }
    
    if (whoCanSeeCell.contentBtn.selected) {
        [_selLabelsArray addObject:labelObj];
    }else {
        [_selLabelsArray removeObject:selObj];
    }
}

- (void)whoCanSeeCell:(JXWhoCanSeeCell *)whoCanSeeCell editBtnAction:(NSInteger)index {
    JXLabelObject *label = _labelsArray[index];
    self.editLabel = label;
    JXNewLabelVC *vc = [[JXNewLabelVC alloc] init];
    vc.title = Localized(@"JX_SettingLabel");
    vc.labelObj = label;
    [g_navigation pushViewController:vc animated:YES];
}


- (void) headerBtnAction:(UIButton *)btn {
    btn.selected = !btn.selected;

    if (_labelsArray.count > 0) {
        _labelsArray = nil;
    }else {
        _labelsArray = [[JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
    }
    if (_checkIndex != btn.tag) {
        _checkIndex = (int)btn.tag;
        _labelsArray = [[JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
        [_selLabelsArray removeAllObjects];
        [_mailListUserArray removeAllObjects];
    }else {
        
    }
    for (JXLabelObject *labelObj in _labelsArray) {
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
    [_table reloadData];
}

-(void)finishBtnAction{
    
    [_selArray removeAllObjects];
    for (NSInteger i = 0; i < _selLabelsArray.count; i ++) {
        JXLabelObject *labelObj = _selLabelsArray[i];
        NSArray *arr = [labelObj.userIdList componentsSeparatedByString:@","];
        for (NSInteger j = 0; j < arr.count; j ++) {
            NSString *userId = arr[j];
            JXUserObject *user = [[JXUserObject alloc] init];
            user.userId = userId;
            
            BOOL flag = NO;
            for (NSInteger m = 0; m < _selArray.count; m ++) {
                JXUserObject *selUser = _selArray[m];
                if ([userId isEqualToString:selUser.userId]) {
                    flag = YES;
                    break;
                }
            }
            
            if (!flag) {
                [_selArray addObject:user];
            }
        }
    }
    
    for (NSInteger i = 0; i < self.mailListUserArray.count; i ++) {
        JXUserObject *user = self.mailListUserArray[i];
        BOOL flag = NO;
        for (NSInteger m = 0; m < _selArray.count; m ++) {
            JXUserObject *selUser = _selArray[m];
            if ([user.userId isEqualToString:selUser.userId]) {
                flag = YES;
                break;
            }
        }
        
        if (!flag) {
            [_selArray addObject:user];
        }
        
    }
    
    if (self.visibelDelegate && [self.visibelDelegate respondsToSelector:@selector(seeVisibel:userArray:selLabelsArray:mailListArray:)]) {
        [self.visibelDelegate seeVisibel:_checkIndex userArray:_selArray selLabelsArray:_selLabelsArray mailListArray:_mailListUserArray];
    }
    [self actionQuit];
}

-(void)selFriendsDelegate:(JXSelFriendVC*)vc{
    NSArray * allArr = vc.array;
    NSArray * indexArr = [vc.set allObjects];
    NSMutableArray * adduserArr = [NSMutableArray array];
    for (NSNumber * index in indexArr) {
        JXUserObject * selUser = allArr[[index intValue]];
        [adduserArr addObject:selUser];
    }
    _selArray = [NSMutableArray arrayWithArray:adduserArr];
}

- (void)actionQuit {
 
    if (self.isAddWindow) {
        [self.view removeFromSuperview];
        self.view = nil;
    }else {
        [super actionQuit];
    }
}

@end
