//
//  JXSearchVC.m
//  shiku_im
//
//  Created by IMAC on 2019/8/6.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXSearchVC.h"
#import "JXRoomMember.h"
#import "JXChatViewController.h"
#import "JXSearchListVC.h"
#import "JXSearchShowCell.h"
#import "JXSearchMoreCell.h"
#import "JXSearchRecordCell.h"
#import "JXClearAllRecordCell.h"
#import "JXXMPP.h"
#import "JXRoomPool.h"
#import "JXTransferNoticeVC.h"
@interface JXSearchVC ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,JXSearchListDelegate, JXSearchRecordCellDelegate>
{
    CGRect bounds;
    CGFloat cornerRadius;
}
@property (nonatomic,strong)UIView *baseView;
@property (nonatomic,strong)UITableView *searchRecordView;
@property (nonatomic,strong)UITableView *tableview;
@property (nonatomic,strong)UISearchBar *searchbar;
@property (nonatomic,strong)NSString *tableName;
@property (nonatomic,strong)NSMutableArray *sectionArray;//tableView模块数组
@property (nonatomic,strong)NSMutableDictionary *sectionDictonary;//tableView模块数据
@property (nonatomic,strong)NSMutableArray *contactsArray;//联系人
@property (nonatomic,strong)NSMutableArray *groupArray;//群组
@property (nonatomic,strong)NSMutableDictionary *groupDictionary;
@property (nonatomic,strong)NSMutableArray *publicArray;//公众号
@property (nonatomic,strong)NSMutableArray *recordArray;//聊天记录
@property (nonatomic,strong)NSMutableDictionary *msgDictionary;//消息字典
@property (nonatomic,strong)NSMutableArray *searchRecordArray;
//@property (nonatomic,strong)UIButton *cancelBtn;
@property (nonatomic,strong)UIButton *backbtn;
@property (nonatomic,strong)JXSearchListVC *searchListVC;
@property (nonatomic,assign)BOOL isShow;
@property (nonatomic,strong)ATMHud *wait;

@end

@implementation JXSearchVC
- (instancetype)initWithTable:(NSString *)table{
    self = [super init];
    if (self) {
        self.tableName = table;
        self.searchRecordArray = [[JXUserObject sharedInstance] fetchAllSearchRecordWithTable:self.tableName];
        _isShow = NO;
        _wait = [ATMHud sharedInstance];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatView];
    cornerRadius = 7;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!_isShow) {
        [self.searchbar becomeFirstResponder];
        _isShow = YES;
    }
}

#pragma mark -- 界面控件
- (void)creatView{
    UIView *stastusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, SCREEN_BAR)];
    if (THESIMPLESTYLE) {
        stastusBarView.backgroundColor = [UIColor whiteColor];
    }else{
        stastusBarView.backgroundColor = [g_theme themeColor];
    }
    [self.view addSubview:stastusBarView];
    //基础view
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_BAR, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-SCREEN_BAR)];
    self.baseView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.baseView];
    //导航栏
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 44)];
    if (THESIMPLESTYLE) {
        bar.barTintColor = [UIColor whiteColor];
    }else{
        bar.barTintColor = [g_theme themeColor];
    }
    bar.translucent = NO;
    //搜索框
//    self.searchbar = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 5, JX_SCREEN_WIDTH-20, 33)];
    self.searchbar = [[UISearchBar alloc] initWithFrame:CGRectMake(40, 5, JX_SCREEN_WIDTH-55, 33)];
    self.searchbar.delegate = self;
    self.searchbar.searchTextField.placeholder = SEARCH;
    self.searchbar.layer.cornerRadius = 33*0.5;
    self.searchbar.layer.masksToBounds = YES;
    [bar addSubview:self.searchbar];
//    self.searchbar.showsCancelButton = YES;
    /*
    //搜索框样式
    UITextField  *seachTextFild;;
#ifdef XCode11
    if (@available(iOS 13.0, *)) {
        seachTextFild = self.searchbar.searchTextField;
    }else{
        seachTextFild = [self.searchbar valueForKey:@"_searchField"];
    }
#else
    seachTextFild = [self.searchbar valueForKey:@"_searchField"];
#endif
    seachTextFild.tintColor = [g_theme themeColor];
    seachTextFild.backgroundColor = HEXCOLOR(0xf2f2f2);
    
    UIView *backView =  [self subViewOfClassName:@"_UISearchBarSearchFieldBackgroundView" toView:self.searchbar];
    backView.layer.cornerRadius = 5;
    backView.layer.masksToBounds = YES;
    backView.backgroundColor = HEXCOLOR(0xf2f2f2);
    
    seachTextFild.tintColor = [g_theme themeColor];
    seachTextFild.backgroundColor = HEXCOLOR(0xf0f0f0);
    seachTextFild.textColor = [UIColor blackColor];
    [seachTextFild setFont:SYSFONT(14)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_search"]];
    UIView *leftView = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 30, 30)];
    imageView.center = leftView.center;
    [leftView addSubview:imageView];
    seachTextFild.leftView = leftView;
    seachTextFild.clearButtonMode = UITextFieldViewModeWhileEditing;
    seachTextFild.leftViewMode = UITextFieldViewModeAlways;
    seachTextFild.borderStyle = UITextBorderStyleNone;
    seachTextFild.layer.masksToBounds = YES;
    seachTextFild.layer.cornerRadius = 5;
    seachTextFild.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    [seachTextFild mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.searchbar);
//    }];
//    //自定义取消按钮样式
//    self.cancelBtn = [self.searchbar valueForKey:@"_cancelButton"];
//    [self.cancelBtn  setTitle:CANCEL forState:UIControlStateNormal];
//    if (THESIMPLESTYLE) {
//        [self.cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    }else{
//        [self.cancelBtn  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    }
*/
    self.backbtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 11, 20, 20)];
    if (THESIMPLESTYLE) {
        [self.backbtn setBackgroundImage:[UIImage imageNamed:@"title_back_black"] forState:UIControlStateNormal];
    }else{
        [self.backbtn setBackgroundImage:[UIImage imageNamed:@"title_back"] forState:UIControlStateNormal];
        
    }
    [self.backbtn addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    [bar addSubview:self.backbtn];
    [self.baseView addSubview:bar];
    //关键字查询信息的tableView
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-SCREEN_VIEW)];
    self.tableview.tag = 1;
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    self.tableview.backgroundColor = HEXCOLOR(0xf2f2f2);
    UIView *tableHead = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 8)];
    tableHead.backgroundColor = HEXCOLOR(0xf2f2f2);
    self.tableview.tableHeaderView = tableHead;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 8)];
    view.backgroundColor = HEXCOLOR(0xf2f2f2);
    self.tableview.tableFooterView = view;
    self.tableview.separatorColor = HEXCOLOR(0xd9d9d9);
    [self.baseView addSubview:self.tableview];
    //指定内容查找
    self.searchRecordView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-SCREEN_VIEW)];
    self.searchRecordView.tag = 2;
    self.searchRecordView.delegate = self;
    self.searchRecordView.dataSource = self;
    self.searchRecordView.backgroundColor = HEXCOLOR(0xf2f2f2);
    self.searchRecordView.separatorColor = HEXCOLOR(0xd9d9d9);
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 8)];
    view2.backgroundColor = HEXCOLOR(0xf2f2f2);
    self.searchRecordView.tableFooterView = view2;
    
    [self.baseView addSubview:self.searchRecordView];

}
- (UIView*)subViewOfClassName:(NSString*)className toView:(UIView *)view{
    for (UIView* subView in view.subviews) {
        if ([NSStringFromClass(subView.class) isEqualToString:className]) {
            return subView;
        }
        UIView* resultFound = [self subViewOfClassName:className toView:subView];
        if (resultFound) {
            return resultFound;
        }
    }
    return nil;
}

#pragma mark -- 数据的计算
//tavleview模块的行数
- (NSInteger)displayCount:(NSMutableDictionary *)dic withArray:(NSMutableArray *)array withNumber:(NSInteger )i{
    if ([self arrayFromDictionary:dic forKey:array[i]].count == 0) {
        return 0;
    }
    if ([self arrayFromDictionary:dic forKey:array[i]].count != 0 && [self arrayFromDictionary:dic forKey:array[i]].count < 4) {
        return [self arrayFromDictionary:dic forKey:array[i]].count +1;
    }
    return  5;
}
//
- (NSMutableArray *)arrayFromDictionary:(NSMutableDictionary *)dic forKey:(NSString *)key{
    NSMutableArray *array = [dic objectForKey:key];
    return array;
}
//读取某用户或群组对象
- (JXUserObject *)readFromDictionary:(NSMutableDictionary *)dic withArray:(NSMutableArray *)array withNumber1:(NSInteger )i number2:(NSInteger )j{
    NSMutableArray* array1 = [dic objectForKey:array[i]];
    JXUserObject *user = array1[j];
    return user;
}
//添加显示的模块数和模块名
- (void)displaySection{
    [self.sectionArray removeAllObjects];
    [self updateSectionWithContentArray:self.contactsArray withString:CONTACT];
    [self updateSectionWithContentArray:self.groupArray withString:GROUP];
    [self updateSectionWithContentArray:self.publicArray withString:PUBLIC];
    [self updateSectionWithContentArray:self.recordArray withString:RECORD];
}
//更新搜索到的数据
- (void)updateSectionWithContentArray:(NSMutableArray *)array2 withString:(NSString *)str{
    if (array2.count !=0) {
        [self.sectionArray addObject:str];
        [self.sectionDictonary setObject:array2 forKey:str];
    }
}
#pragma mark -- 获取数据
//获取联系人数据
- (void)getContactsWithText:(NSString *)text limit:(BOOL )limit withArray:(NSMutableArray *)dataArray{
    [dataArray addObjectsFromArray:[[JXUserObject sharedInstance] searchContacts:text limit:limit]];
}
//获取群聊数据
- (void)getGroupWithText:(NSString *)text limit:(BOOL )limit withArray:(NSMutableArray *)dataArray withDictionary:(NSMutableDictionary *)dataDic{
    if (limit) {
        NSMutableArray *array1 = [[JXUserObject sharedInstance] searchGroup:text limit:YES];
        if (array1.count > 3) {
            [dataArray addObjectsFromArray:array1];
            return;
        }
        NSMutableArray *array2;
        if (limit) {
            array2 = [[JXUserObject sharedInstance] searchGroupMember:text limit:YES];
        }else{
            array2 = [[JXUserObject sharedInstance] searchGroupMember:text limit:NO];
        }
        if (array1.count != 0) {
            [dataArray addObjectsFromArray:array1];
            NSMutableArray *roomArray = [NSMutableArray array];
            for (JXUserObject *user2 in dataArray) {
                [roomArray addObject:user2.roomId];
            }
            for (memberData *member in array2) {
               JXUserObject *user = [[JXUserObject sharedInstance] groupForRoomId:member.roomId];
                if (![roomArray containsObject:user.roomId]) {
                    [dataArray addObject:user];
                    [dataDic setValue:member.userNickName forKey:user.roomId];
                }
            }
        }else{
            for (memberData *member in array2) {
                JXUserObject *user = [[JXUserObject sharedInstance] groupForRoomId:member.roomId];
                [dataArray addObject:user];
                [dataDic setValue:member.userNickName forKey:user.roomId];
            
            }
        }
    }else{
        NSMutableArray *array1 = [[JXUserObject sharedInstance] searchGroup:text limit:NO];
        NSMutableArray *array2 = [[JXUserObject sharedInstance] searchGroupMember:text limit:NO];
        if (array1.count != 0) {
            [dataArray addObjectsFromArray:array1];
            NSMutableArray *roomArray = [NSMutableArray array];
            for (JXUserObject *user2 in dataArray) {
                [roomArray addObject:user2.roomId];
            }
            for (memberData *member in array2) {
               JXUserObject *user = [[JXUserObject sharedInstance] groupForRoomId:member.roomId];
                if (![roomArray containsObject:user.roomId]) {
                    [dataArray addObject:user];
                    [dataDic setValue:member.userNickName forKey:user.roomId];
                }
            }
        }else{
            for (memberData *member in array2) {
                JXUserObject *user = [[JXUserObject sharedInstance] groupForRoomId:member.roomId];
                [dataArray addObject:user];
                [dataDic setValue:member.userNickName forKey:user.roomId];
            
            }
        }
    }
}
//获取公众号数据
- (void)getPublicWithText:(NSString *)text limit:(BOOL )limit withArray:(NSMutableArray *)dataArray{
    [dataArray addObjectsFromArray:[[JXUserObject sharedInstance] searchPublic:text limit:limit]];
}
//获取聊天记录数据
- (void)getChatRecordWithText:(NSString *)text limit:(BOOL )limit withArray:(NSMutableArray *)dataArray withDictionary:(NSMutableDictionary *)dataDic{
    [dataDic addEntriesFromDictionary:[[JXUserObject sharedInstance] getAllContactsAndGroupHaveChatRecordWithText:text limit:limit]];
    for (NSInteger i = 0; i < dataDic.allKeys.count; i++) {
        NSString *userId = dataDic.allKeys[i];
        JXUserObject *user = [[JXUserObject sharedInstance] getUserById:userId];
        [dataArray addObject:user];
    }
}

- (void)removeAllLastSearchResult{
    [self.contactsArray removeAllObjects];
    [self.groupArray removeAllObjects];
    [self.groupDictionary removeAllObjects];
    [self.publicArray removeAllObjects];
    [self.recordArray removeAllObjects];
    [self.msgDictionary removeAllObjects];
    [self.sectionArray removeAllObjects];
    [self.sectionDictonary removeAllObjects];
}

- (NSInteger)getMsgCountWithUserId:(NSString *)userId{
    NSMutableArray *array = [self.msgDictionary objectForKey:userId];
    return array.count;
}
//判断哪个模块
- (BOOL)compareSectionSring:(NSString *)str withIndexPath:(NSIndexPath *)indexPath{
    return [self arrayFromDictionary:self.sectionDictonary forKey:str].count != 0 && [self.sectionArray indexOfObject:str] == indexPath.section;
}
//返回标记搜索查找的字符串
- (NSMutableAttributedString *)showSearchTextColor:(NSString *)str{
    NSRange range = [str rangeOfString:self.searchbar.text options:NSCaseInsensitiveSearch];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:str];
    if (range.location != NSNotFound) {
        [string addAttribute:NSForegroundColorAttributeName value:[g_theme themeColor] range:range];
    }
    return string;
}

- (void)getAllSearchResult:(NSString *)searchText{
    [self removeAllLastSearchResult];
    [self getContactsWithText:searchText limit:YES withArray:self.contactsArray];
    [self getGroupWithText:searchText limit:YES withArray:self.groupArray withDictionary:self.groupDictionary];
    [self getPublicWithText:searchText limit:YES withArray:self.publicArray];
    [self getChatRecordWithText:searchText limit:YES withArray:self.recordArray withDictionary:self.msgDictionary];
    [self displaySection];
}


#pragma mark -- searchBar的代理

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length == 0) {
        [self.searchRecordView reloadData];
        if (![self.baseView.subviews.lastObject isEqual:self.searchRecordView]) {
            [self.baseView bringSubviewToFront:self.searchRecordView];
        }
    }else{
        if (![self.baseView.subviews.lastObject isEqual:self.tableview]) {
            [self.baseView bringSubviewToFront:self.tableview];;
        }
        [self getAllSearchResult:searchText];
        if (self.sectionArray.count == 0) {
            self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        }else{
            self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        }
        [self.tableview reloadData];
    }
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [g_navigation dismissViewController:self animated:YES];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self.searchbar becomeFirstResponder];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchbar resignFirstResponder];
//    [self.cancelBtn setEnabled:YES];
}
#pragma mark -- tableView的代理和数据源
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchbar resignFirstResponder];
//    [self.cancelBtn setEnabled:YES];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 1) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sectionNameCell"];
            cell.textLabel.text = self.sectionArray[indexPath.section];
            cell.textLabel.textColor = HEXCOLOR(0x999999);
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.center = cell.center;
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 8, 0, 8)];
            cell.userInteractionEnabled = NO;
            return cell;
        }
        if (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3) {
            JXSearchShowCell *cell = [[JXSearchShowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatCell" withNewStyle:JXSearchShowCellStyleUser];
            JXUserObject *user = [self readFromDictionary:self.sectionDictonary withArray:self.sectionArray withNumber1:indexPath.section number2:indexPath.row-1];
            NSMutableAttributedString *nameAString = [self showSearchTextColor:user.userNickname];
            if ([self compareSectionSring:CONTACT withIndexPath:indexPath]) {
                if ([user.userNickname localizedCaseInsensitiveContainsString:self.searchbar.text]) {
                    cell.aboveAttributedText = nameAString;
                }else{
                    cell.aboveText = user.userNickname;
                    NSMutableAttributedString *string1 = [self showSearchTextColor:user.userId];
                    NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:",USERNUMBER]];
                    [string2 appendAttributedString:string1];
                    cell.belowAttributedText = string2;
                }
                [g_server getHeadImageSmall:user.userId userName:user.userNickname imageView:cell.headImgView getHeadHandler:nil];
            }
            if ([self compareSectionSring:GROUP withIndexPath:indexPath]) {
                NSString *str = user.roomId;
                NSString *containString = [self.groupDictionary objectForKey:str];
                if (![containString localizedStandardContainsString:self.searchbar.text]) {
                    cell.aboveAttributedText = nameAString;
                }else{
                    cell.aboveText = user.userNickname;
                    NSMutableAttributedString *string3 = [self showSearchTextColor:containString];
                    NSMutableAttributedString *string4 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ",CONTAIN]];
                    [string4 appendAttributedString:string3];
                    cell.belowAttributedText = string4;
                }
                [g_server getRoomHeadImageSmall:user.userId roomId:user.roomId imageView:cell.headImgView getHeadHandler:nil];
            }
            if ([self compareSectionSring:PUBLIC withIndexPath:indexPath]){
                cell.aboveAttributedText = nameAString;
                [g_server getHeadImageSmall:user.userId userName:user.userNickname imageView:cell.headImgView getHeadHandler:nil];
            }
            if ([self compareSectionSring:RECORD withIndexPath:indexPath]) {
                cell.aboveText = user.userNickname;
                NSInteger i = [self getMsgCountWithUserId:user.userId];
                NSString *str = [NSString stringWithFormat:@"%ld%@",(long)i,RECORDNUMBERS];
                cell.belowText = str;
                if (user.roomId) {
                    [g_server getRoomHeadImageSmall:user.userId roomId:user.roomId imageView:cell.headImgView getHeadHandler:nil];
                }else{
                    [g_server getHeadImageSmall:user.userId userName:user.userNickname imageView:cell.headImgView getHeadHandler:nil];
                }
            }
            
            if (indexPath.row == 3) {
                [cell setSeparatorInset:UIEdgeInsetsMake(0, 8, 0, 8)];
            }
            return cell;
        }
        if (indexPath.row == 4) {
            JXSearchMoreCell *cell = [[JXSearchMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"moreSearchCell"];
            cell.imgName = @"search_icon";
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new_icon_>"]];
            cell.moreName = [NSString stringWithFormat:@"%@%@",MORE,self.sectionArray[indexPath.section]];
            return cell;
        }
    }
    if (indexPath.row == 0) {
        JXClearAllRecordCell *cell = [[JXClearAllRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"historycell" withTitle:@"history"];
        cell.imageView.image = [UIImage imageNamed:@"the_historical_record"];
        cell.textLabel.text = Localized(@"JX_HistoryRecord");
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = HEXCOLOR(0x999999);
        cell.userInteractionEnabled = NO;
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 0)];
        return cell;
    }
    if (indexPath.row == _searchRecordArray.count + 1) {
        JXClearAllRecordCell *cell = [[JXClearAllRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"deleteallcell"];
        cell.textLabel.text = Localized(@"JX_ClearAllRecords");
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = HEXCOLOR(0xda4434);
        return cell;
    }
    JXSearchRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchRecirdCell"];
    if (!cell) {
        cell = [[JXSearchRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchRecirdCell"];
    }
    cell.delegate = self;
    cell.textLabel.text = self.searchRecordArray[indexPath.row - 1];
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 1) {
        cell.backgroundColor = UIColor.clearColor;
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        bounds = CGRectInset(cell.bounds, 8, 0);
        if (indexPath.row == 0) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
        }
        if (indexPath.row > 0 && indexPath.row != [tableView numberOfRowsInSection:indexPath.section] - 1) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), 0);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), 0);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
        }
        if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            
            if ([cell isKindOfClass:[JXSearchShowCell class]]) {
                [((JXSearchShowCell *)cell) cutSelectedView];
            }
        }
        layer.path = pathRef;
        CFRelease(pathRef);
        layer.fillColor = [UIColor whiteColor].CGColor;
        UIView *backView = [[UIView alloc] initWithFrame:bounds];
        [backView.layer addSublayer:layer];
        backView.backgroundColor = [UIColor clearColor];
        cell.backgroundView = backView;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView.tag == 1) {
        return self.sectionArray.count;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 1) {
         return [self displayCount:self.sectionDictonary withArray:self.sectionArray withNumber:section];
    }
    if (self.searchRecordArray.count == 0) {
        return 0;
    }
    return self.searchRecordArray.count + 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 1) {
        if (indexPath.row == 0) {
            return 44;
        }
        if (indexPath.row == 4) {
            return 50;
        }
        return 60;
    }
//    if (indexPath.row == 0) {
//        return 30;
//    }
//    if (indexPath.row == _searchRecordArray.count + 1) {
//        return 30;
//    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (tableView.tag == 1) {
        if (section == _sectionArray.count - 1) {
            return 0;
        }
        return 10;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (tableView.tag == 1) {
        if (section == _sectionArray.count - 1) {
            return nil;
        }
        UITableViewHeaderFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"tableHeaderFooter"];
        if (!footer) {
            footer = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"tableHeaderFooter"];
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 10)];
            view.backgroundColor = HEXCOLOR(0xf2f2f2);
            [footer addSubview:view];
        }
        return footer;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 1) {
        if (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3){
            if ([self compareSectionSring:CONTACT withIndexPath:indexPath] || [self compareSectionSring:PUBLIC withIndexPath:indexPath]){
                JXUserObject *user = [self readFromDictionary:self.sectionDictonary withArray:self.sectionArray withNumber1:indexPath.section number2:indexPath.row-1];
                
                if ([user.userId intValue] == [SHIKU_TRANSFER intValue]) {
                    JXTransferNoticeVC *noticeVC = [[JXTransferNoticeVC alloc] init];
                    [g_navigation pushViewController:noticeVC animated:YES];
                    return;
                }
                
                JXChatViewController *chatView = [[JXChatViewController alloc] init];
                chatView.chatPerson = user;
                [self.tableview deselectRowAtIndexPath:indexPath animated:YES];
                [g_navigation pushViewController:chatView animated:YES];
            }
            if ([self compareSectionSring:GROUP withIndexPath:indexPath]) {
                JXUserObject *user = [self readFromDictionary:self.sectionDictonary withArray:self.sectionArray withNumber1:indexPath.section number2:indexPath.row-1];
                roomData * roomdata = [[roomData alloc] init];
                [roomdata getDataFromDict:[user toDictionary]];
                JXChatViewController *chatView = [JXChatViewController alloc];
                if ([user.groupStatus intValue] == 0) {
                    chatView.chatRoom  = [[JXXMPP sharedInstance].roomPool joinRoom:user.userId title:user.userNickname lastDate:nil isNew:NO];
                }
                chatView.title = user.userNickname;
                chatView.roomJid = user.userId;
                chatView.roomId = user.roomId;
                chatView.groupStatus = user.groupStatus;
                chatView.room = roomdata;
                chatView.chatPerson = user;
                chatView = [chatView init];
                [g_navigation pushViewController:chatView animated:YES];
                [self.tableview deselectRowAtIndexPath:indexPath animated:YES];
            }
            if ([self compareSectionSring:RECORD withIndexPath:indexPath]) {
                self.searchListVC = [[JXSearchListVC alloc] initWithLable:RECORD withSearchText:self.searchbar.text withUserArray:nil withGroupDictionary:nil withMsgDictionary:self.msgDictionary  isChatRecord:YES enterChatRecord:YES withPeople:self.recordArray[indexPath.row-1]];
                [self showListView:indexPath];
            }
            //        [self.cancelBtn setEnabled:YES];
        }
        if (indexPath.row == 4) {
            if ([self compareSectionSring:CONTACT withIndexPath:indexPath]) {
                NSMutableArray *contactsArray = [NSMutableArray array];
                [self getContactsWithText:self.searchbar.text limit:NO withArray:contactsArray];
                self.searchListVC = [[JXSearchListVC alloc] initWithLable:CONTACT withSearchText:self.searchbar.text withUserArray:contactsArray withGroupDictionary:nil withMsgDictionary:nil isChatRecord:NO enterChatRecord:NO withPeople:nil];
                [self showListView:indexPath];
            }
            if ([self compareSectionSring:GROUP withIndexPath:indexPath]) {
                NSMutableArray *groupArray = [NSMutableArray array];
                NSMutableDictionary *groupDictionary = [NSMutableDictionary dictionary];
                [self getGroupWithText:self.searchbar.text limit:NO withArray:groupArray withDictionary:groupDictionary];
                self.searchListVC = [[JXSearchListVC alloc] initWithLable:GROUP withSearchText:self.searchbar.text withUserArray:groupArray withGroupDictionary:groupDictionary withMsgDictionary:nil  isChatRecord:NO enterChatRecord:NO withPeople:nil];
                [self showListView:indexPath];
            }
            if ([self compareSectionSring:PUBLIC withIndexPath:indexPath]) {
                NSMutableArray *publicArray = [NSMutableArray array];
                [self getPublicWithText:self.searchbar.text limit:NO withArray:publicArray];
                self.searchListVC = [[JXSearchListVC alloc] initWithLable:PUBLIC withSearchText:self.searchbar.text withUserArray:publicArray withGroupDictionary:nil withMsgDictionary:nil  isChatRecord:NO enterChatRecord:NO withPeople:nil];
                [self showListView:indexPath];
            }
            if ([self compareSectionSring:RECORD withIndexPath:indexPath]) {
                NSMutableArray *recordArray = [NSMutableArray array];
                NSMutableDictionary *msgDictionary = [NSMutableDictionary dictionary];
                [self getChatRecordWithText:self.searchbar.text limit:NO withArray:recordArray withDictionary:msgDictionary];
                self.searchListVC = [[JXSearchListVC alloc] initWithLable:RECORD withSearchText:self.searchbar.text withUserArray:recordArray  withGroupDictionary:nil withMsgDictionary:msgDictionary  isChatRecord:YES enterChatRecord:NO withPeople:nil];
                [self showListView:indexPath];
            }
        }
        BOOL saveSuccess = [[JXUserObject sharedInstance] insertSearchRecord:self.searchbar.text withTable:self.tableName];
        if (!saveSuccess) {
            NSLog(@"保存搜索记录失败");
        }
        [_searchRecordArray removeAllObjects];
        _searchRecordArray = [[JXUserObject sharedInstance] fetchAllSearchRecordWithTable:self.tableName];
    }
    if (tableView.tag == 2) {
        if (indexPath.row == _searchRecordArray.count + 1) {
            UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"" message:Localized(@"JX_WhetherToClearTheSearchHistory") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Localized(@"JX_Cencal") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:Localized(@"JX_Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [_searchRecordArray removeAllObjects];
                [[JXUserObject sharedInstance] deleteAllSearchRecordWithTable:self.tableName];
                [_searchRecordView reloadData];
            }];
            [alertCon addAction:sureAction];
            [alertCon addAction:cancelAction];
            [self presentViewController:alertCon animated:YES completion:nil];
        }else{
            self.searchbar.text = _searchRecordArray[indexPath.row - 1];
            [self searchBar:self.searchbar textDidChange:self.searchbar.text];
        }
        [self.searchRecordView deselectRowAtIndexPath:indexPath animated:YES];
    }
}
- (void)showListView:(NSIndexPath *)indexPath{
    self.searchListVC.view.backgroundColor = [UIColor clearColor];
    [self.tableview deselectRowAtIndexPath:indexPath animated:YES];
    self.searchListVC.delegate = self;
    [self addChildViewController:self.searchListVC];
    [self.view addSubview:self.searchListVC.view];
    [self.searchbar resignFirstResponder];
//    [self.cancelBtn setEnabled:YES];
}

- (void)deleteCell:(JXSearchRecordCell *)cell{
    NSString *msg = cell.textLabel.text;
    [[JXUserObject sharedInstance] deleteOneSearchRecord:msg withTable:self.tableName];
    [_searchRecordArray removeAllObjects];
    _searchRecordArray = [[JXUserObject sharedInstance] fetchAllSearchRecordWithTable:self.tableName];
    [self.searchRecordView reloadData];
}

- (void)dismissView{
    [g_navigation dismissViewController:self animated:YES];
}

#pragma mark -- ListView代理
- (void)saveSearchRecord:(NSString *)searchRecord{
    BOOL saveSuccess = [[JXUserObject sharedInstance] insertSearchRecord:searchRecord withTable:self.tableName];
    if (!saveSuccess) {
        NSLog(@"保存搜索记录失败");
    }
    [_searchRecordArray removeAllObjects];
    _searchRecordArray = [[JXUserObject sharedInstance] fetchAllSearchRecordWithTable:self.tableName];
}

- (void)tapSearchCancelBtn{
    [self.searchListVC removeFromParentViewController];
    [self.searchListVC.view removeFromSuperview];
    [g_navigation dismissViewController:self animated:YES];
}
- (void)tapBackBtn:(BOOL )hasRecord{
    if (hasRecord) {
//        self.searchListVC.backbtn.frame = CGRectMake(-20, 11, 20, 20);
//        self.searchListVC.searchbar.frame = CGRectMake(10, 5, JX_SCREEN_WIDTH-20, 33);
        [UIView animateWithDuration:0.3 animations:^{
            self.searchListVC.recordtableview.frame = CGRectMake(JX_SCREEN_WIDTH, 44, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-SCREEN_VIEW);
        } completion:^(BOOL finished) {
            [self.searchListVC removeFromParentViewController];
            [self.searchListVC.view removeFromSuperview];
        }];
    }else{
//        self.searchListVC.backbtn.frame = CGRectMake(-20, 11, 20, 20);
//        self.searchListVC.searchbar.frame = CGRectMake(10, 5, JX_SCREEN_WIDTH-20, 33);
        [UIView animateWithDuration:0.3 animations:^{
            self.searchListVC.tableview.frame = CGRectMake(JX_SCREEN_WIDTH, 44, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-SCREEN_VIEW);
        } completion:^(BOOL finished) {
            [self.searchListVC removeFromParentViewController];
            [self.searchListVC.view removeFromSuperview];
        }];
    }
}
- (void)listDidAppear:(BOOL )hasRecord{
    if (hasRecord) {
//        self.searchListVC.searchbar.frame = CGRectMake(40, 5, JX_SCREEN_WIDTH-50, 33);
//        self.searchListVC.backbtn.frame = CGRectMake(10, 11, 20, 20);
        [UIView animateWithDuration:0.3 animations:^{
            self.searchListVC.recordtableview.frame = CGRectMake(0, 44, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-SCREEN_VIEW);
        }];
    }else{
//        self.searchListVC.searchbar.frame = CGRectMake(40, 5, JX_SCREEN_WIDTH-50, 33);
//        self.searchListVC.backbtn.frame = CGRectMake(10, 11, 20, 20);
        [UIView animateWithDuration:0.3 animations:^{
            self.searchListVC.tableview.frame = CGRectMake(0, 44, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-SCREEN_VIEW);
        }];
    }
}

- (void)listWillDisappear:(BOOL)hasRecord {
    
}

#pragma mark -- 懒加载
- (NSMutableArray *)contactsArray{
    if (!_contactsArray) {
        _contactsArray = [NSMutableArray array];
    }
    return _contactsArray;
}

- (NSMutableArray *)groupArray{
    if (!_groupArray) {
        _groupArray = [NSMutableArray array];
    }
    return _groupArray;
}

- (NSMutableDictionary *)groupDictionary{
    if (!_groupDictionary) {
        _groupDictionary = [NSMutableDictionary dictionary];
    }
    return _groupDictionary;
}

- (NSMutableArray *)publicArray{
    if (!_publicArray) {
        _publicArray = [NSMutableArray array];
    }
    return _publicArray;
}

- (NSMutableArray *)recordArray{
    if (!_recordArray) {
        _recordArray = [NSMutableArray array];
    }
    return _recordArray;
}

- (NSMutableDictionary *)msgDictionary{
    if (!_msgDictionary) {
        _msgDictionary = [NSMutableDictionary dictionary];
    }
    return _msgDictionary;
}

- (NSMutableArray *)sectionArray{
    if (!_sectionArray) {
        _sectionArray = [NSMutableArray array];
    }
    return _sectionArray;
}

- (NSMutableDictionary *)sectionDictonary{
    if (!_sectionDictonary) {
        _sectionDictonary = [NSMutableDictionary dictionary];
    }
    return _sectionDictonary;
}

@end
