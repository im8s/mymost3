//
//  JXGroupMessagesSelectFriendVC.m
//  shiku_im
//
//  Created by p on 2018/5/25.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXGroupMessagesSelectFriendVC.h"
#import "JXCell.h"
#import "UIImage+Color.h"
#import "QCheckBox.h"
#import "JXChatViewController.h"
#import "JXSelectLabelsVC.h"
#import "JXLabelObject.h"
#import "BMChineseSort.h"

#import "JXSelectGroupSendVC.h"
#import "OrganizeSelectVC.h"
#import "EmployeObject.h"

@interface JXGroupMessagesSelectFriendVC () <UITextFieldDelegate, JXSelectLabelsVCDelegate, JXSelectGroupSendVCDelegate, OrganizeSelectVCDelegate>
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) UITextField *seekTextField;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) NSSet * existSet;
@property (nonatomic, strong) NSMutableArray *selUserIdArray;
@property (nonatomic, strong) NSMutableArray *selUserNameArray;
@property (nonatomic, strong) UIButton *nextBtn;

@property (nonatomic, strong) UIView *tableHeadView;
@property (nonatomic, strong) UILabel *selectLabelTip;
@property (nonatomic, strong) UILabel *selectGroupTip;
@property (nonatomic, strong) UILabel *selectColleagueTip;
@property (nonatomic, strong) UILabel *selectMaillistTip;

@property (nonatomic, strong) UILabel *selectLabels;
@property (nonatomic, strong) UILabel *selectGroups;
@property (nonatomic, strong) UILabel *selectColleagues;
@property (nonatomic, strong) UILabel *selectMaillists;

@property (nonatomic, strong) NSMutableArray *selLabelsArr;
@property (nonatomic, strong) NSMutableArray *selGroupsArr;
@property (nonatomic, strong) NSMutableArray *selColleaguesArr;
@property (nonatomic, strong) NSMutableArray *selMailistArr;

//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;
@property (nonatomic, strong) NSMutableArray *checkBoxArr;

@end

@implementation JXGroupMessagesSelectFriendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = JX_SCREEN_BOTTOM;
    self.isGotoBack   = YES;
    //self.view.frame = g_window.bounds;
    self.isShowFooterPull = NO;
    [self createHeadAndFoot];
    
    _array = [NSMutableArray array];
    _searchArray = [NSMutableArray array];
    _selUserIdArray = [NSMutableArray array];
    _selUserNameArray = [NSMutableArray array];
    _selLabelsArr = [NSMutableArray array];
    _checkBoxArr = [NSMutableArray array];
    self.title = Localized(@"JX_SelectReceiver");
    
    CGSize size = [Localized(@"JX_CheckAll") sizeWithAttributes:@{NSFontAttributeName:SYSFONT(15)}];

    UIButton *allSelect = [[UIButton alloc] init];
    [allSelect setTitle:Localized(@"JX_CheckAll") forState:UIControlStateNormal];
    [allSelect setTitle:Localized(@"JX_Cencal") forState:UIControlStateSelected];
    [allSelect setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [allSelect.titleLabel setFont:SYSFONT(15)];
    allSelect.frame = CGRectMake(JX_SCREEN_WIDTH - 15-size.width, JX_SCREEN_TOP - 33, size.width, 24);
    [allSelect addTarget:self action:@selector(allSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableHeader addSubview:allSelect];
    
    self.nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.tableFooter.frame.size.width, 48)];
    self.nextBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.nextBtn setTitle:Localized(@"JX_NextStep") forState:UIControlStateNormal];
    [self.nextBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [self.nextBtn addTarget:self action:@selector(nextBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableFooter addSubview:self.nextBtn];
    
    
    //搜索输入框
    _tableHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 55)];
//    backView.backgroundColor = HEXCOLOR(0xf0f0f0);
    [self.view addSubview:_tableHeadView];
    
//    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(backView.frame.size.width-5-45, 5, 45, 30)];
//    [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
//    [cancelBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
//    [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    cancelBtn.titleLabel.font = SYSFONT(14);
//    [backView addSubview:cancelBtn];
    
    
    _seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, _tableHeadView.frame.size.width - 30, 35)];
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
    [_tableHeadView addSubview:_seekTextField];
    [_seekTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, JX_SCREEN_WIDTH, .5)];
    lineView.backgroundColor = HEXCOLOR(0xdcdcdc);
    [_tableHeadView addSubview:lineView];
    
    //选择标签群发
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_seekTextField.frame)+8, JX_SCREEN_WIDTH, 54)];
    [btn addTarget:self action:@selector(selectLabels:) forControlEvents:UIControlEventTouchUpInside];
    [_tableHeadView addSubview:btn];
    
    _selectLabelTip = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, btn.frame.size.width, btn.frame.size.height)];
    _selectLabelTip.font = [UIFont boldSystemFontOfSize:16.0];
    _selectLabelTip.text = Localized(@"JX_SelectTagGroup");
    [btn addSubview:_selectLabelTip];
    
    _selectLabels = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_selectLabelTip.frame), btn.frame.size.width, btn.frame.size.height - CGRectGetMaxY(_selectLabelTip.frame))];
    _selectLabels.font = [UIFont boldSystemFontOfSize:16.0];
    _selectLabels.text = @"[标签1，标签2]";
    _selectLabels.textColor = [UIColor lightGrayColor];
    [btn addSubview:_selectLabels];

    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btn.frame) + 4.5, JX_SCREEN_WIDTH, .5)];
    lineView.backgroundColor = HEXCOLOR(0xdcdcdc);
    [_tableHeadView addSubview:lineView];
    //选择群组群发
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), JX_SCREEN_WIDTH, 54)];
    [_tableHeadView addSubview:btn2];
    [btn2 addTarget:self action:@selector(selectorGroup:) forControlEvents:UIControlEventTouchUpInside];
    _selectGroupTip = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, btn2.frame.size.width, btn2.frame.size.height)];
    _selectGroupTip.font = [UIFont boldSystemFontOfSize:16.0];
    _selectGroupTip.text = Localized(@"JX_SelectGroupGroupSending");
    [btn2 addSubview:_selectGroupTip];
    
    _selectGroups = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_selectGroupTip.frame), btn2.frame.size.width, btn2.frame.size.height - CGRectGetMaxY(_selectGroupTip.frame))];
    _selectGroups.font = [UIFont boldSystemFontOfSize:16.0];
    _selectGroups.text = @"[群组1，群组2]";
    _selectGroups.textColor = [UIColor lightGrayColor];
    [btn2 addSubview:_selectGroups];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btn2.frame) + 4.5, JX_SCREEN_WIDTH, .5)];
    lineView.backgroundColor = HEXCOLOR(0xdcdcdc);
    [_tableHeadView addSubview:lineView];
    //选择同事群发
    UIButton *btn3 = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), JX_SCREEN_WIDTH, 54)];
    [_tableHeadView addSubview:btn3];
    [btn3 addTarget:self action:@selector(selectorColleague:) forControlEvents:UIControlEventTouchUpInside];
    _selectColleagueTip = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, btn3.frame.size.width, btn3.frame.size.height)];
    _selectColleagueTip.font = [UIFont boldSystemFontOfSize:16.0];
    _selectColleagueTip.text = Localized(@"JX_SelectAGroupOfColleagues");
    [btn3 addSubview:_selectColleagueTip];
    
    _selectColleagues = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_selectColleagueTip.frame), btn3.frame.size.width, btn3.frame.size.height - CGRectGetMaxY(_selectColleagueTip.frame))];
    _selectColleagues.font = [UIFont boldSystemFontOfSize:16.0];
    _selectColleagues.text = @"[同事1，同事2]";
    _selectColleagues.textColor = [UIColor lightGrayColor];
    [btn3 addSubview:_selectColleagues];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btn3.frame) + 4.5, JX_SCREEN_WIDTH, .5)];
    lineView.backgroundColor = HEXCOLOR(0xdcdcdc);
    [_tableHeadView addSubview:lineView];
    
    //选择通讯录群发
//    UIButton *btn4 = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), JX_SCREEN_WIDTH, 54)];
//    [_tableHeadView addSubview:btn4];
//    [btn4 addTarget:self action:@selector(selectorMaillist:) forControlEvents:UIControlEventTouchUpInside];
//    _selectMaillistTip = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, btn4.frame.size.width, btn4.frame.size.height)];
//    _selectMaillistTip.font = [UIFont boldSystemFontOfSize:16.0];
//    _selectMaillistTip.text = Localized(@"JX_SelectMobilePhoneToContactTheCrowd");
//    [btn4 addSubview:_selectMaillistTip];
//
//    _selectMaillists = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_selectMaillistTip.frame), btn4.frame.size.width, btn4.frame.size.height - CGRectGetMaxY(_selectMaillistTip.frame))];
//    _selectMaillists.font = [UIFont boldSystemFontOfSize:16.0];
//    _selectMaillists.text = @"[通讯录]";
//    _selectMaillists.textColor = [UIColor lightGrayColor];
//    [btn4 addSubview:_selectMaillists];
    
    _tableHeadView.frame = CGRectMake(_tableHeadView.frame.origin.x, _tableHeadView.frame.origin.y, _tableHeadView.frame.size.width, CGRectGetMaxY(btn3.frame));
    self.tableView.tableHeaderView = _tableHeadView;
    
    [self getArrayData];
    
}

- (void)selectLabels:(UIButton *)btn {
    
    JXSelectLabelsVC *vc = [[JXSelectLabelsVC alloc] init];
    vc.delegate = self;
    vc.selLabels = [NSMutableArray arrayWithArray:_selLabelsArr];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)selectorGroup:(UIButton *)btn{
    JXSelectGroupSendVC *vc = [[JXSelectGroupSendVC alloc] initWithTitle:SELECTGroup];
    vc.delegate = self;
    vc.seletedArray = [NSMutableArray arrayWithArray:_selGroupsArr];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)selectorColleague:(UIButton *)btn{
    OrganizeSelectVC *vc = [[OrganizeSelectVC alloc] init];
    vc.delegate = self;
    vc.seletedArray = [NSMutableArray arrayWithArray:_selColleaguesArr];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)selectorMaillist:(UIButton *)btn{
    JXSelectGroupSendVC *vc = [[JXSelectGroupSendVC alloc] initWithTitle:SELECTMaillist];
    vc.delegate = self;
    vc.seletedArray = [NSMutableArray arrayWithArray:_selMailistArr];
    [g_navigation pushViewController:vc animated:YES];
}
- (void)selectLabelsVC:(JXSelectLabelsVC *)selectLabelsVC selectLabelsArray:(NSMutableArray *)array {
    _selLabelsArr = [NSMutableArray arrayWithArray:array];
    
    NSMutableString *nameStr = [NSMutableString string];
    for (NSInteger i = 0; i < array.count; i ++) {
        JXLabelObject *labelObj = array[i];
        if (i == 0) {
            [nameStr appendFormat:@"[\"%@",labelObj.groupName];
        }else if (i == array.count - 1) {
            [nameStr appendFormat:@",%@\"]",labelObj.groupName];
        }else {
            [nameStr appendFormat:@",%@",labelObj.groupName];
        }
        if (array.count == 1) {
            [nameStr appendString:@"\"]"];
        }
    }
    
    self.selectLabels.text = nameStr;
    if (nameStr.length > 0) {
        self.selectLabelTip.frame = CGRectMake(self.selectLabelTip.frame.origin.x, self.selectLabelTip.frame.origin.y, self.selectLabelTip.frame.size.width, 27);
        self.selectLabels.frame = CGRectMake(self.selectLabels.frame.origin.x, CGRectGetMaxY(_selectLabelTip.frame), self.selectLabels.frame.size.width, 27);
    }else {
        self.selectLabelTip.frame = CGRectMake(self.selectLabelTip.frame.origin.x, self.selectLabelTip.frame.origin.y, self.selectLabelTip.frame.size.width, 54);
        self.selectLabels.frame = CGRectMake(self.selectLabels.frame.origin.x, CGRectGetMaxY(_selectLabelTip.frame), self.selectLabels.frame.size.width, 0);
    }
}

- (void)selectVC:(JXSelectGroupSendVC *)selectLabelsVC selectArray:(NSMutableArray *)array{
    if ([selectLabelsVC.titleString isEqualToString:SELECTGroup]) {
        _selGroupsArr = [NSMutableArray arrayWithArray:array];
        NSMutableString *groupsName = [NSMutableString string];
        for (NSInteger i = 0; i < array.count; i++) {
            JXUserObject *user = array[i];
            if (i == 0) {
                [groupsName appendFormat:@"[\"%@",user.userNickname];
            }else if (i == array.count - 1){
                [groupsName appendFormat:@",%@\"]",user.userNickname];
            }else{
                [groupsName appendFormat:@",%@",user.userNickname];
            }
            if (array.count == 1) {
                [groupsName appendString:@"\"]"];
            }
        }
        self.selectGroups.text = groupsName;
        if (groupsName.length > 0) {
            self.selectGroupTip.frame = CGRectMake(self.selectGroupTip.frame.origin.x, self.selectGroupTip.frame.origin.y, self.selectGroupTip.frame.size.width, 27);
            self.selectGroups.frame = CGRectMake(self.selectGroups.frame.origin.x, CGRectGetMaxY(_selectGroupTip.frame), self.selectGroups.frame.size.width, 27);
        }else {
            self.selectGroupTip.frame = CGRectMake(self.selectGroupTip.frame.origin.x, self.selectGroupTip.frame.origin.y, self.selectGroupTip.frame.size.width, 54);
            self.selectGroups.frame = CGRectMake(self.selectGroups.frame.origin.x, CGRectGetMaxY(_selectGroupTip.frame), self.selectGroups.frame.size.width, 0);
        }
    }

    if ([selectLabelsVC.titleString isEqualToString:SELECTMaillist]) {
        {
            _selMailistArr = [NSMutableArray arrayWithArray:array];
            NSMutableString *groupsName = [NSMutableString string];
            for (NSInteger i = 0; i < array.count; i++) {
                JXUserObject *user = array[i];
                if (i == 0) {
                    [groupsName appendFormat:@"[\"%@",user.userNickname];
                }else if (i == array.count - 1){
                    [groupsName appendFormat:@",%@\"]",user.userNickname];
                }else{
                    [groupsName appendFormat:@",%@",user.userNickname];
                }
                if (array.count == 1) {
                    [groupsName appendString:@"\"]"];
                }
            }
            self.selectMaillists.text = groupsName;
            if (groupsName.length > 0) {
                self.selectMaillistTip.frame = CGRectMake(self.selectMaillistTip.frame.origin.x, self.selectMaillistTip.frame.origin.y, self.selectMaillistTip.frame.size.width, 27);
                self.selectMaillists.frame = CGRectMake(self.selectMaillists.frame.origin.x, CGRectGetMaxY(_selectMaillistTip.frame), self.selectMaillists.frame.size.width, 27);
            }else {
                self.selectMaillistTip.frame = CGRectMake(self.selectMaillistTip.frame.origin.x, self.selectMaillistTip.frame.origin.y, self.selectMaillistTip.frame.size.width, 54);
                self.selectMaillists.frame = CGRectMake(self.selectMaillists.frame.origin.x, CGRectGetMaxY(_selectMaillistTip.frame), self.selectMaillists.frame.size.width, 0);
            }
        }
    }
}
- (void)selectOrganizeVC:(OrganizeSelectVC *)selectVC selectArray:(NSMutableArray *)array{
    _selColleaguesArr = [NSMutableArray arrayWithArray:array];
    NSMutableString *colleaguesName = [NSMutableString string];
    for (NSInteger i = 0; i < array.count; i++) {
        EmployeObject *employe = array[i];
        if (i == 0) {
            [colleaguesName appendFormat:@"[\"%@",employe.nickName];
        }else if (i == array.count - 1){
            [colleaguesName appendFormat:@",%@\"]",employe.nickName];
        }else{
            [colleaguesName appendFormat:@",%@",employe.nickName];
        }
        if (array.count == 1) {
            [colleaguesName appendString:@"\"]"];
        }
    }
    self.selectColleagues.text = colleaguesName;
    if (colleaguesName.length > 0) {
        self.selectColleagueTip.frame = CGRectMake( self.selectColleagueTip.frame.origin.x,  self.selectColleagueTip.frame.origin.y, self.selectMaillistTip.frame.size.width, 27);
        self.selectColleagues.frame = CGRectMake( self.selectColleagueTip.frame.origin.x, CGRectGetMaxY(_selectColleagueTip.frame),  self.selectColleagues.frame.size.width, 27);
    }else {
        self.selectColleagueTip.frame = CGRectMake( self.selectColleagueTip.frame.origin.x,  self.selectColleagueTip.frame.origin.y,  self.selectColleagueTip.frame.size.width, 54);
        self.selectColleagues.frame = CGRectMake(self.selectColleagues.frame.origin.x, CGRectGetMaxY(_selectColleagueTip.frame),  self.selectColleagues.frame.size.width, 0);
    }
}
- (void)allSelect:(UIButton *)btn {
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        CGSize size = [Localized(@"JX_Cencal") sizeWithAttributes:@{NSFontAttributeName:SYSFONT(15)}];
        btn.frame = CGRectMake(JX_SCREEN_WIDTH-size.width-15, btn.frame.origin.y, size.width, btn.frame.size.height);
    }else {
        CGSize size = [Localized(@"JX_CheckAll") sizeWithAttributes:@{NSFontAttributeName:SYSFONT(15)}];
        btn.frame = CGRectMake(JX_SCREEN_WIDTH-size.width-15, btn.frame.origin.y, size.width, btn.frame.size.height);
    }

    
    [_selUserIdArray removeAllObjects];
    [_selUserNameArray removeAllObjects];
    if (btn.selected) {
        NSArray *array;
        if (_seekTextField.text.length > 0) {
            array = _searchArray;
        }else {
            array = _array;
        }
        for (JXUserObject *user in array) {
            [_selUserIdArray addObject:user.userId];
            [_selUserNameArray addObject:user.userNickname];
        }
    }
    
    [self.nextBtn setTitle:[NSString stringWithFormat:@"%@(%ld)",Localized(@"JX_NextStep"),_selUserIdArray.count] forState:UIControlStateNormal];
    [_checkBoxArr removeAllObjects];
    [self.tableView reloadData];
}

- (void)nextBtnAction:(UIButton *)btn {
    
    NSMutableArray *selUserIdArray = [NSMutableArray array];
    NSMutableArray *selUserNameArray = [NSMutableArray array];
    
    [selUserIdArray addObjectsFromArray:_selUserIdArray];
    [selUserNameArray addObjectsFromArray:_selUserNameArray];
    for (NSInteger i = 0; i < self.selLabelsArr.count; i ++) {
        JXLabelObject *labelObj = self.selLabelsArr[i];
        NSArray *labelUserIds = [labelObj.userIdList componentsSeparatedByString:@","];
        for (NSInteger j = 0; j < labelUserIds.count; j ++) {
            NSString *labelUserId = labelUserIds[j];
            NSString *labelUserName = [JXUserObject getUserNameWithUserId:labelUserId];
            BOOL flag = NO;
            NSMutableArray *array = [NSMutableArray arrayWithArray:selUserIdArray];
            for (NSInteger m = 0; m < array.count; m ++) {
                NSString *selUserId = array[m];
                if ([labelUserId isEqualToString:selUserId]) {
                    flag = YES;
                    break;
                }
            }
            
            if (!flag) {
                [selUserIdArray addObject:labelUserId];
                [selUserNameArray addObject:labelUserName];
            }
        }
    }
    for (NSInteger i = 0; i < self.selGroupsArr.count; i++) {
        JXUserObject *group = self.selGroupsArr[i];
        [selUserIdArray addObject:group.userId];
        [selUserNameArray addObject:group.userNickname];
    }
    for (NSInteger i = 0; i < self.selMailistArr.count; i++) {
        JXUserObject *user = self.selMailistArr[i];
        [selUserIdArray addObject:user.userId];
        [selUserNameArray addObject:user.userNickname];
    }
    for (NSInteger i = 0; i < self.selColleaguesArr.count; i++) {
        EmployeObject *employe = self.selColleaguesArr[i];
        [selUserIdArray addObject:employe.userId];
        [selUserNameArray addObject:employe.nickName];
    }
    
    if (!selUserIdArray.count) {
        [g_App showAlert:Localized(@"JX_SelectGroupUsers")];
        return;
    }
    
    JXChatViewController *vc = [[JXChatViewController alloc] init];
    vc.userIds = selUserIdArray;
    vc.userNames = selUserNameArray;
    vc.isGroupMessages = YES;
    [g_navigation pushViewController:vc animated:YES];
}

- (void) cancelBtnAction {
    _seekTextField.text = nil;
    [_seekTextField resignFirstResponder];
    [self getArrayData];
}

- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked{
    JXUserObject *user;
    if (_seekTextField.text.length > 0) {
        user = _searchArray[checkbox.tag % 9000000-1];
    }else{
        user = [[self.letterResultArr objectAtIndex:checkbox.tag / 100000-1] objectAtIndex:checkbox.tag % 100000-1];
    }
    
    if(checked){
        BOOL flag = NO;
        for (NSInteger i = 0; i < _selUserIdArray.count; i ++) {
            NSString *selUserId = _selUserIdArray[i];
            if ([selUserId isEqualToString:user.userId]) {
                flag = YES;
                return;
            }
        }
        [_selUserIdArray addObject:user.userId];
        [_selUserNameArray addObject:user.userNickname];
    }
    else{
        [_selUserIdArray removeObject:user.userId];
        [_selUserNameArray removeObject:user.userNickname];
    }
    if (_selUserIdArray.count <= 0) {
        [self.nextBtn setTitle:[NSString stringWithFormat:@"%@",Localized(@"JX_NextStep")] forState:UIControlStateNormal];
    }else {
        [self.nextBtn setTitle:[NSString stringWithFormat:@"%@(%ld)",Localized(@"JX_NextStep"),_selUserIdArray.count] forState:UIControlStateNormal];
    }
}

- (void) textFieldDidChange:(UITextField *)textField {
    
    if (textField.text.length <= 0) {
        [self getArrayData];
        return;
    }
    
    [_searchArray removeAllObjects];

    for (NSInteger i = 0; i < _array.count; i ++) {
        JXUserObject * user = _array[i];
        NSString *userStr = [user.userNickname lowercaseString];
        NSString *textStr = [textField.text lowercaseString];
        if ([userStr rangeOfString:textStr].location != NSNotFound) {
            [_searchArray addObject:user];
        }
    }
    
    [_checkBoxArr removeAllObjects];
    [self.tableView reloadData];
}

-(void)getArrayData{
    _array=[[JXUserObject sharedInstance] fetchAllUserFromLocal];
    //选择拼音 转换的 方法
    BMChineseSortSetting.share.sortMode = 2; // 1或2
    //排序 Person对象
    [BMChineseSort sortAndGroup:_array key:@"userNickname" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
        if (isSuccess) {
            self.indexArray = sectionTitleArr;
            self.letterResultArr = sortedObjArr;
            [_checkBoxArr removeAllObjects];
            [self.tableView reloadData];
        }
    }];

//    //根据Person对象的 name 属性 按中文 对 Person数组 排序
//    self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickname"];
//    self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickname"];
//    [self.tableView reloadData];
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
    NSArray * tempArray;
    
    if (_seekTextField.text.length > 0) {
        tempArray = _searchArray;
    }else{
        tempArray = [self.letterResultArr objectAtIndex:indexPath.section];
    }
    
    JXCell *cell=nil;
    NSString* cellName = [NSString stringWithFormat:@"selVC_%d",(int)indexPath.row];
//    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
//    QCheckBox* btn;
//    if (!cell) {
        cell = [[JXCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        QCheckBox* btn = [[QCheckBox alloc] initWithDelegate:self];
        btn.frame = CGRectMake(13, 18.5, 22, 22);
        [cell addSubview:btn];
//    }
    
    JXUserObject *user=tempArray[indexPath.row];
    
    if (_seekTextField.text.length > 0) {
        btn.tag = (indexPath.section + 1) * 9000000 + (indexPath.row + 1);
    }else {
        btn.tag = (indexPath.section + 1) * 100000 + (indexPath.row + 1);
    }
    BOOL flag = NO;
    for (NSInteger i = 0; i < _selUserIdArray.count; i ++) {
        NSString *selUserId = _selUserIdArray [i];
        if ([user.userId isEqualToString:selUserId]) {
            flag = YES;
            break;
        }
    }
    btn.checked = flag;
    
    [_checkBoxArr addObject:btn];
    //            cell = [[JXCell alloc] init];
    [_table addToPool:cell];
    cell.title = user.userNickname;
    //            cell.subtitle = user.userId;
    cell.bottomTitle = [TimeUtil formatDate:user.timeCreate format:@"MM-dd HH:mm"];
    cell.userId = user.userId;
    cell.isSmall = YES;
    [cell headImageViewImageWithUserId:nil roomId:nil];
    
    
    CGFloat headX = 13*2+22;
    
    cell.headImageView.frame = CGRectMake(headX,9.5,40,40);
    cell.headImageView.layer.cornerRadius = cell.headImageView.frame.size.width / 2;
    cell.lbTitle.frame = CGRectMake(CGRectGetMaxX(cell.headImageView.frame)+15, 21.5, JX_SCREEN_WIDTH - 115 -CGRectGetMaxX(cell.headImageView.frame)-14, 16);
    cell.lbSubTitle.frame = CGRectMake(CGRectGetMaxX(cell.headImageView.frame)+15, cell.lbSubTitle.frame.origin.y, JX_SCREEN_WIDTH - 55 -CGRectGetMaxX(cell.headImageView.frame)-14, cell.lbSubTitle.frame.size.height);
    cell.lineView.frame = CGRectMake(CGRectGetMaxX(cell.headImageView.frame)+15,59-LINE_WH,JX_SCREEN_WIDTH,LINE_WH);

    if (indexPath.row == [(NSArray *)[self.letterResultArr objectAtIndex:indexPath.section] count]-1) {
        cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width,0);
    }else {
        cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width,LINE_WH);
    }

//    cell.headImageView.frame = CGRectMake(cell.headImageView.frame.origin.x + 50, cell.headImageView.frame.origin.y, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height);
//    cell.lbTitle.frame = CGRectMake(cell.lbTitle.frame.origin.x + 50, cell.lbTitle.frame.origin.y, cell.lbTitle.frame.size.width, cell.lbTitle.frame.size.height);
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    QCheckBox *checkBox = nil;
//    for (NSInteger i = 0; i < _checkBoxArr.count; i ++) {
//        QCheckBox *btn = _checkBoxArr[i];
//        if (btn.tag / 10000 == indexPath.section && btn.tag % 10000 == indexPath.row) {
//            checkBox = btn;
//            break;
//        }
//    }
    
    JXCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    QCheckBox *checkBox = [cell viewWithTag:(indexPath.section + 1) * 100000 + (indexPath.row + 1)];
    
    checkBox.selected = !checkBox.selected;
    [self didSelectedCheckBox:checkBox checked:checkBox.selected];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 59;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
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
