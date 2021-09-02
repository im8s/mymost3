
//
//  JXSelectGroupSendVC.m
//  shiku_im
//
//  Created by IMAC on 2019/8/14.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXSelectGroupSendVC.h"
#import "QCheckBox.h"
#import "JXCell.h"
@interface JXSelectGroupSendVC ()
@property (nonatomic,strong)NSMutableArray *groupArray;
@property (nonatomic,strong)NSMutableArray *checkBoxArr;
@end

@implementation JXSelectGroupSendVC
- (instancetype)initWithTitle:(NSString *)title{
    self = [super init];
    if (self) {
        self.titleString = title;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.titleString;
    
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack   = YES;
    self.isShowFooterPull = NO;
    self.isShowHeaderPull = NO;
    [self createHeadAndFoot];
    UIButton *allSelect = [UIButton buttonWithType:UIButtonTypeSystem];
    [allSelect setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    if (THESIMPLESTYLE) {
        [allSelect setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else{
        [allSelect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    allSelect.tintColor = [UIColor clearColor];
    allSelect.frame = CGRectMake(JX_SCREEN_WIDTH - 70, JX_SCREEN_TOP - 34, 60, 24);
    [allSelect addTarget:self action:@selector(confirmBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableHeader addSubview:allSelect];
    
    _checkBoxArr = [NSMutableArray array];
    
    //群组获取
    if ([self.titleString isEqualToString:SELECTGroup]) {
        self.groupArray = [NSMutableArray arrayWithArray:[[JXUserObject sharedInstance] fetchAllRoomsFromLocal]];
    }
    
    //通讯录好友获取
    if ([self.titleString isEqualToString:SELECTMaillist]) {
        NSMutableArray *mailListArr = [[JXAddressBook sharedInstance] fetchAllAddressBook];
        NSMutableArray *allUserArr = [[JXUserObject sharedInstance] fetchAllUserFromLocal];
        NSDictionary *phoneNumDict = [[JXAddressBook sharedInstance] getMyAddressBook];
        self.groupArray = [NSMutableArray array];
        for (JXAddressBook *maillist in mailListArr) {
            if (phoneNumDict[maillist.toTelephone]) {
                for (JXUserObject *user in allUserArr) {
                    if ([maillist.toUserId isEqualToString:user.userId]) {
                        [self.groupArray addObject:user];
                    }
                }
            }
        }
    }
}

- (void)confirmBtnAction:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(selectVC:selectArray:)]) {
        [self.delegate selectVC:self selectArray:_seletedArray];
    }
    [self actionQuit];
}
- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked{
    if ([self.titleString isEqualToString:SELECTGroup]) {
        JXUserObject *groupObj = _groupArray[checkbox.tag - 10086];
        if ([groupObj.isLostChatKeyGroup boolValue]) {
            checkbox.selected = NO;
            [g_server showMsg:Localized(@"JX_LostKeyCannotSelRoom") delay:1.5];
            return;
        }
        if(checked){
            [_seletedArray addObject:groupObj];
        }
        else{
            NSInteger index = -1;
            for (NSInteger i = 0; i < _seletedArray.count; i ++) {
                JXUserObject *selGroup = _seletedArray[i];
                if ([selGroup.roomId isEqualToString:groupObj.roomId]) {
                    index = i;
                    break;
                }
            }
            if (index >= 0) {
                [_seletedArray removeObjectAtIndex:index];
            }
        }
    }
    if ([self.titleString isEqualToString:SELECTMaillist]) {
        JXUserObject *groupObj = _groupArray[checkbox.tag - 10086];
        if(checked){
            [_seletedArray addObject:groupObj];
        }
        else{
            NSInteger index = -1;
            for (NSInteger i = 0; i < _seletedArray.count; i ++) {
                JXUserObject *selGroup = _seletedArray[i];
                if ([selGroup.userId isEqualToString:groupObj.userId]) {
                    index = i;
                    break;
                }
            }
            if (index >= 0) {
                [_seletedArray removeObjectAtIndex:index];
            }
        }
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _groupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JXUserObject *user = _groupArray[indexPath.row];
    NSString *userId = user.userId;
    NSString *userName = user.userNickname;
    JXCell *cell = nil;
    cell = [[JXCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SendCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    QCheckBox* btn = [[QCheckBox alloc] initWithDelegate:self];
    btn.frame = CGRectMake(20, 15, 25, 25);
    [cell addSubview:btn];
    cell.title = userName;
    cell.userId = userId;
    cell.isSmall = YES;
    if (user.roomId) {
        [cell headImageViewImageWithUserId:userId roomId:user.roomId];
    }else{
        [cell headImageViewImageWithUserId:nil roomId:nil];
    }
    cell.headImageView.frame = CGRectMake(cell.headImageView.frame.origin.x + 50, cell.headImageView.frame.origin.y, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height);
    cell.lbTitle.frame = CGRectMake(cell.lbTitle.frame.origin.x + 50, cell.lbTitle.frame.origin.y, cell.lbTitle.frame.size.width, cell.lbTitle.frame.size.height);
    cell.lineView.frame = CGRectMake(cell.lbTitle.frame.origin.x, cell.lineView.frame.origin.y, JX_SCREEN_WIDTH-cell.lbTitle.frame.origin.x, cell.lineView.frame.size.height);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    BOOL flag = NO;
    for (NSInteger i = 0; i < _seletedArray.count; i ++) {
        JXUserObject *userObj = _seletedArray[i];
        if ([userObj.userId isEqualToString:userId]) {
            flag = YES;
            break;
        }
    }
    btn.tag = 10086 + indexPath.row;
    btn.selected = flag;
    [_checkBoxArr addObject:btn];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JXCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    QCheckBox *checkBox = [cell viewWithTag:10086 + indexPath.row];
    
    checkBox.selected = !checkBox.selected;
    [self didSelectedCheckBox:checkBox checked:checkBox.selected];
}
@end
