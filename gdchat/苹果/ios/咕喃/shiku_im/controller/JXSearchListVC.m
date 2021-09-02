//
//  JXSearchListVC.m
//  shiku_im
//
//  Created by IMAC on 2019/8/9.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXSearchListVC.h"
#import "JXChatViewController.h"
#import "JXSearchShowCell.h"
#import "JXXMPP.h"
#import "JXRoomPool.h"

#define FINDSEARCH Localized(@"JX_Find")
#define WHOSERECORD Localized(@"JX_Recording")

@interface JXSearchListVC ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UIView *baseView;
@property (nonatomic,strong)NSString *titleString;
@property (nonatomic,strong)NSString *seachText;
@property (nonatomic,strong)NSArray *userArray;
@property (nonatomic,strong)NSDictionary *userDictionary;
@property (nonatomic,strong)NSDictionary *groupDictionary;
@property (nonatomic,strong)NSDictionary *msgDictionary;
@property (nonatomic,assign)BOOL isChatRecord;//init时传入是否建立聊天记录tableview
@property (nonatomic,assign)BOOL enterChatRecord;//是否直接从SearchVC进入指定聊天记录
@property (nonatomic,assign)BOOL inChatRecord;//是否在聊天记录列表中进入指定聊天记录
@property (nonatomic,strong)JXUserObject *chatUser;
//@property (nonatomic,strong)UIButton *cancelBtn;
@property (nonatomic,strong)NSMutableArray *lastUserArray;
@property (nonatomic,strong)NSMutableDictionary *lastGroupDictonary;
@property (nonatomic,strong)NSMutableDictionary *lastMsgDictionary;
@property (nonatomic,assign)NSInteger num;
@end

@implementation JXSearchListVC
- (instancetype)initWithLable:(NSString *)lable withSearchText:(NSString *)searchtext withUserArray:(nullable NSMutableArray *)array withGroupDictionary:(nullable NSMutableDictionary *)groupdic withMsgDictionary:(nullable NSMutableDictionary *)msgDic isChatRecord:(BOOL )isChatRecord enterChatRecord:(BOOL )enterChatRecord withPeople:(nullable JXUserObject *)people{
    self = [super init];
    if (self) {
        self.titleString = lable;
        self.seachText = searchtext;
        if (array) {
            self.userArray = [[NSArray alloc] initWithArray:array];
            self.lastUserArray = [[NSMutableArray alloc] initWithArray:array];
        }
        if (groupdic) {
            self.groupDictionary = [[NSDictionary alloc] initWithDictionary:groupdic];
            self.lastGroupDictonary = [[NSMutableDictionary alloc] initWithDictionary:groupdic];
        }
        if (msgDic) {
            self.msgDictionary = [[NSDictionary alloc] initWithDictionary:msgDic];
            self.lastMsgDictionary = [[NSMutableDictionary alloc] initWithDictionary:msgDic];
        }
        self.isChatRecord = isChatRecord;
        self.enterChatRecord = enterChatRecord;
        if (people) {
            self.chatUser = people;
        }
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatView];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:NO];
    if ([self.delegate respondsToSelector:@selector(listDidAppear:)]) {
        [self.delegate listDidAppear:_enterChatRecord];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:NO];
    [self.searchbar resignFirstResponder];
//    [self.cancelBtn setEnabled:YES];
    if ([self.delegate respondsToSelector:@selector(listWillDisappear:)]) {
        [self.delegate listWillDisappear:_enterChatRecord];
    }
}
- (void)creatView{
    UIView *stastusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, SCREEN_BAR)];
    if (THESIMPLESTYLE) {
        stastusBarView.backgroundColor = [UIColor whiteColor];
    }else{
        stastusBarView.backgroundColor = [g_theme themeColor];
    }
    [self.view addSubview:stastusBarView];
    //基础view
    self.view.backgroundColor = [UIColor clearColor];
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_BAR, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-SCREEN_BAR)];
    self.baseView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.baseView];
    //导航栏
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 44)];
    if (THESIMPLESTYLE) {
        bar.barTintColor = [UIColor whiteColor];
    }else{
        bar.barTintColor = [g_theme themeColor];
    }
    [bar setShadowImage:[[UIImage alloc] init]];
    bar.translucent = NO;
    //搜索框
//    self.searchbar = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 5, JX_SCREEN_WIDTH-20, 33)];
    self.searchbar = [[UISearchBar alloc] initWithFrame:CGRectMake(40, 5, JX_SCREEN_WIDTH-55, 33)];
    self.searchbar.delegate = self;
    self.searchbar.placeholder = [FINDSEARCH stringByAppendingString:self.titleString];
    self.searchbar.backgroundColor = HEXCOLOR(0xf0f0f0);
    self.searchbar.layer.cornerRadius = 33*0.5;
    self.searchbar.layer.masksToBounds = YES;
//    self.searchbar.showsCancelButton = YES;
    self.searchbar.text = self.seachText;
    //搜索框样式
//    UITextField *seachTextFild;
//#ifdef XCode11
//    if (@available(iOS 13.0, *)) {
//        seachTextFild = self.searchbar.searchTextField;
//    }else{
//        seachTextFild = [self.searchbar valueForKey:@"_searchField"];
//    }
//#else
//    seachTextFild = [self.searchbar valueForKey:@"_searchField"];
//#endif
//    seachTextFild.tintColor = [g_theme themeColor];
//    seachTextFild.backgroundColor = HEXCOLOR(0xf2f2f2);
    UIView *backView =  [self subViewOfClassName:@"_UISearchBarSearchFieldBackgroundView" toView:self.searchbar];
    backView.layer.cornerRadius = 5;
    backView.layer.masksToBounds = YES;
    backView.backgroundColor = HEXCOLOR(0xf2f2f2);
    
//    seachTextFild.tintColor = [g_theme themeColor];
//    seachTextFild.backgroundColor = HEXCOLOR(0xf0f0f0);
//    seachTextFild.textColor = [UIColor blackColor];
//    [seachTextFild setFont:SYSFONT(14)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_search"]];
    UIView *leftView = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 30, 30)];
    imageView.center = leftView.center;
    [leftView addSubview:imageView];
    
//    seachTextFild.leftView = leftView;
//    seachTextFild.clearButtonMode = UITextFieldViewModeWhileEditing;
//    seachTextFild.leftViewMode = UITextFieldViewModeAlways;
//    seachTextFild.borderStyle = UITextBorderStyleNone;
//    seachTextFild.layer.masksToBounds = YES;
//    seachTextFild.layer.cornerRadius = 5;
//    seachTextFild.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

//    //自定义取消按钮样式
//    self.cancelBtn = [self.searchbar valueForKey:@"_cancelButton"];
//    [self.cancelBtn setTitle:CANCEL forState:UIControlStateNormal];
//    if (THESIMPLESTYLE) {
//        [self.cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    }else{
//        [self.cancelBtn  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    }
//    [self.cancelBtn setEnabled:YES];
    [bar addSubview:self.searchbar];
    self.backbtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 11, 20, 20)];
    if (THESIMPLESTYLE) {
        [self.backbtn setBackgroundImage:[UIImage imageNamed:@"title_back_black"] forState:UIControlStateNormal];
    }else{
        [self.backbtn setBackgroundImage:[UIImage imageNamed:@"title_back"] forState:UIControlStateNormal];
        
    }
    [self.backbtn addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    [bar addSubview:self.backbtn];
    [self.baseView addSubview:bar];
    if (!_enterChatRecord) {
        self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH, 44, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-SCREEN_VIEW)];
        self.tableview.tag = 1;
        self.tableview.dataSource = self;
        self.tableview.delegate = self;
        self.tableview.backgroundColor = HEXCOLOR(0xf2f2f2);
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 0.1)];
        view.backgroundColor = HEXCOLOR(0xf2f2f2);
        self.tableview.tableFooterView = view;
        self.tableview.separatorColor = HEXCOLOR(0xd9d9d9);
        [self.baseView addSubview:self.tableview];
    }
    if (_isChatRecord) {
        self.recordtableview = [[UITableView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH, 44, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-SCREEN_VIEW)];
        self.recordtableview.tag = 2;
        self.recordtableview.dataSource = self;
        self.recordtableview.delegate = self;
        self.recordtableview.backgroundColor = HEXCOLOR(0xf2f2f2);
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 0.1)];
        view.backgroundColor = HEXCOLOR(0xf2f2f2);
        self.recordtableview.tableFooterView = view;
        self.recordtableview.separatorColor = HEXCOLOR(0xd9d9d9);
        [self.baseView addSubview:self.recordtableview];
    }
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
//更新查找的tableview中的内容
- (void)updataSearchContent{
    [self.lastUserArray removeAllObjects];
    if ([self.titleString isEqualToString:CONTACT]) {
        for (JXUserObject *user in self.userArray) {
            if ([user.userNickname containsString:self.searchbar.text] && ![self.lastUserArray containsObject:user]) {
                [self.lastUserArray addObject:user];
            }
            if (![user.userNickname containsString:self.searchbar.text] && [user.userId containsString:self.searchbar.text] && ![self.lastUserArray containsObject:user]) {
                [self.lastUserArray addObject:user];
            }
        }
    }
    if ([self.titleString isEqualToString:GROUP]) {
        [self.lastGroupDictonary removeAllObjects];
        for (JXUserObject *user in self.userArray) {
            NSString *str = user.roomId;
            NSString *contain = [self.groupDictionary objectForKey:str];
            if ([user.userNickname localizedCaseInsensitiveContainsString:self.searchbar.text] && ![self.lastUserArray containsObject:user]) {
                [self.lastUserArray addObject:user];
            }
            if (![user.userNickname localizedCaseInsensitiveContainsString:self.searchbar.text] && [contain localizedCaseInsensitiveContainsString:self.searchbar.text] && ![self.lastUserArray containsObject:user]) {
                [self.lastUserArray addObject:user];
                [self.lastGroupDictonary setObject:contain forKey:str];
            }
        }
    }
    if ([self.titleString isEqualToString:PUBLIC]) {
        for (JXUserObject *user in self.userArray) {
            if ([user.userNickname localizedCaseInsensitiveContainsString:self.searchbar.text] && ![self.lastUserArray containsObject:user]) {
                [self.lastUserArray addObject:user];
            }
        }
    }
    if ([self.titleString isEqualToString:RECORD]) {
        for (JXUserObject *user in self.userArray) {
            NSMutableArray *array = [self.msgDictionary objectForKey:user.userId];
            NSMutableArray *array2 = [NSMutableArray array];
            for (JXMessageObject *msg in array) {
                if ([msg.content localizedCaseInsensitiveContainsString:self.searchbar.text]) {
                    [array2 addObject:msg];
                }
            }
            [self.lastMsgDictionary setObject:array2 forKey:user.userId];
            if (array2.count != 0) {
                [self.lastUserArray addObject:user];
            }
        }
    }
}
//更新查找中的recordtableview的内容
- (void)updateRecordContent{
        NSMutableArray *array = [self.msgDictionary objectForKey:self.chatUser.userId];
        NSMutableArray *array2 = [NSMutableArray array];
        for (JXMessageObject *msg in array) {
            NSString *message = msg.content;
            NSMutableArray *conArray = [NSMutableArray array];
            [self getMessageRange:message :conArray];
            NSMutableArray *contentArray = [NSMutableArray array];
            _num = 0;
            [self splicingString:conArray inArray:contentArray];
            for (NSString *object in contentArray) {
                if ([object hasSuffix:@"]"]&&[object hasPrefix:@"["]) {
                    
                }else{
                    if ([object localizedCaseInsensitiveContainsString:self.searchbar.text]) {
                        [array2 addObject:msg];
                        break;
                    }
                }
            }
        }
        [self.lastMsgDictionary setObject:array2 forKey:self.chatUser.userId];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (!_enterChatRecord) {
        if (!_inChatRecord) {
            if (self.searchbar.text.length == 0) {
                [self.lastUserArray removeAllObjects];
                [self.tableview reloadData];
            }else{
                [self updataSearchContent];
                [self.tableview reloadData];
            }
        }else{
            [self updateRecordContent];
            [self.recordtableview reloadData];
        }
    }else{
            [self updateRecordContent];
            [self.recordtableview reloadData];
    }
    
}

//排除表情包
- (void)getMessageRange:(NSString*)message :(NSMutableArray*)array {
    
    NSRange range=[message rangeOfString: @"["];
    
    NSRange range1=[message rangeOfString: @"]"];
    
    
    // 动画过滤
    if ([message isEqualToString:[NSString stringWithFormat:@"[%@]",Localized(@"emojiVC_Emoji")]]) {
        [array addObject:message];
        return;
    }
    
    
    //判断当前字符串是否还有表情的标志。
    
    if (range.length>0 && range1.length>0 && range1.location > range.location) {
        
        if (range.location > 0) {
            
            NSString *str = [message substringToIndex:range.location];
            
            NSString *str1 = [message substringFromIndex:range.location];
            
            [array addObject:str];
            
            [self getMessageRange:str1 :array];
            
        }else {
            
            NSString *emojiString = [message substringWithRange:NSMakeRange(range.location + 1, range1.location - 1)];
            BOOL isEmoji = NO;
            NSString *str;
            NSString *str1;
            for (NSMutableDictionary *dic in g_constant.emojiArray) {
                NSString *emoji = [dic objectForKey:@"english"];
                if ([emoji isEqualToString:emojiString]) {
                    isEmoji = YES;
                    break;
                }
            }
            if (isEmoji) {
                str = [message substringWithRange:NSMakeRange(range.location, range1.location + 1)];
                str1 = [message substringFromIndex:range1.location + 1];
                [array addObject:str];
            }else{
                NSString *posString = [message substringWithRange:NSMakeRange(range.location + 1, range1.location)];
                NSRange posRange = [posString rangeOfString:@"["];
                if (posRange.location != NSNotFound) {
                    str = [message substringToIndex:posRange.location + 1];
                    str1 = [message substringFromIndex:posRange.location + 1];
                    [array addObject:str];
                }else{
                    str = [message substringToIndex:range.location + 1];
                    str1 = [message substringFromIndex:range.location + 1];
                    [array addObject:str];
                }
            }
            [self getMessageRange:str1 :array];
        }
        
    }else if (range.length>0 && range1.length>0 && range1.location < range.location){
        NSString *str = [message substringToIndex:range1.location + 1];
        NSString *str1 = [message substringFromIndex:range1.location + 1];
        [array addObject:str];
        [self getMessageRange:str1 :array];
    }else if (message != nil) {
        
        [array addObject:message];
        
    }
    
}
//拼接字符串
- (void)splicingString:(NSMutableArray *)array inArray:(NSMutableArray *)contentArray{
    if (_num >= array.count) {
        return;
    }
    NSString *str = [NSString string];
    for (NSInteger i = _num; i < array.count; i++) {
        NSString *object = array[i];
        if ([object hasSuffix:@"]"]&&[object hasPrefix:@"["]) {
            [contentArray addObject:str];
            [contentArray addObject:object];
            _num = i + 1;
            break;
        }else{
            _num = i + 1;
            str = [str stringByAppendingString:object];
            if (_num >= array.count) {
                [contentArray addObject:str];
                return;
            }
        }
    }
    [self splicingString:array inArray:contentArray];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    if ([self.delegate respondsToSelector:@selector(tapSearchCancelBtn)]) {
        [self dismissViewControllerAnimated:NO completion:nil];
        [self.delegate tapSearchCancelBtn];
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchbar resignFirstResponder];
//    [self.cancelBtn setEnabled:YES];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchbar resignFirstResponder];
//    [self.cancelBtn setEnabled:YES];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 1) {
        if (self.lastUserArray.count == 0) {
            return 0;
        }else{
            return self.lastUserArray.count+1;
        }
    }
    if (self.searchbar.text.length == 0) {
        return 1;
    }
    NSArray *array = [self.lastMsgDictionary objectForKey:self.chatUser.userId];
    return array.count+1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 1) {
        if (indexPath.row == 0) {
            return 33;
        }
        return 60;
    }
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 1) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sectionNameCell"];
            cell.textLabel.text = self.titleString;
            cell.textLabel.textColor = HEXCOLOR(0x999999);
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.userInteractionEnabled = NO;
            return cell;
        }else{
            JXUserObject *user = self.lastUserArray[indexPath.row-1];
            NSString *nickName = user.userNickname;
            NSString *userId = user.userId;
            JXSearchShowCell *cell = [[JXSearchShowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatCell" withNewStyle:JXSearchShowCellStyleUser];
            if ([self.titleString isEqualToString:CONTACT]) {
                if ([nickName localizedCaseInsensitiveContainsString:self.searchbar.text]) {
                    NSMutableAttributedString *string1 = [self showSearchTextColor:nickName];
                    cell.aboveAttributedText = string1;
                    
                }else{
                    cell.aboveText = nickName;
                    if ([userId localizedCaseInsensitiveContainsString:self.searchbar.text]) {
                        NSMutableAttributedString *string2 = [self showSearchTextColor:userId];
                        NSMutableAttributedString *string3 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:",USERNUMBER]];
                        [string3 appendAttributedString:string2];
                        cell.belowAttributedText = string3;
                    }
                }
                [g_server getHeadImageSmall:userId userName:nickName imageView:cell.headImgView getHeadHandler:nil];
            }
            if ([self.titleString isEqualToString:GROUP]) {
                NSString *str = user.roomId;
                if ([nickName localizedStandardContainsString:self.searchbar.text]) {
                    NSMutableAttributedString *string1 = [self showSearchTextColor:nickName];
                    cell.aboveAttributedText = string1;
                }else{
                    cell.aboveText = nickName;
                    NSString *containString = [self.lastGroupDictonary objectForKey:str];
                    NSMutableAttributedString *string2 = [self showSearchTextColor:containString];
                    NSMutableAttributedString *string3 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ",CONTAIN]];
                    [string3 appendAttributedString:string2];
                    cell.belowAttributedText = string3;
                }
                [g_server getRoomHeadImageSmall:userId roomId:str imageView:cell.headImgView getHeadHandler:nil];
            }
            if ([self.titleString isEqualToString:PUBLIC]) {
                NSMutableAttributedString *string = [self showSearchTextColor:nickName];
                cell.textLabel.attributedText = string;
                [g_server getHeadImageSmall:userId userName:nickName imageView:cell.headImgView getHeadHandler:nil];
            }
            if ([self.titleString isEqualToString:RECORD]) {
                cell.aboveText = nickName;
                NSInteger i = [self getMsgCountWithUserId:userId];
                NSString *str = [NSString stringWithFormat:@"%ld%@",(long)i,RECORDNUMBERS];
                cell.belowText = str;
                if (user.roomId) {
                    [g_server getRoomHeadImageSmall:userId roomId:user.roomId imageView:cell.headImgView getHeadHandler:nil];
                }else{
                    [g_server getHeadImageSmall:userId userName:nickName imageView:cell.headImgView getHeadHandler:nil];
                }
            }
            return cell;
        }
    }
    if (tableView.tag == 2){
        NSString *nickName = self.chatUser.userNickname;
        NSString *userId = self.chatUser.userId;
        if (indexPath.row == 0) {
            JXSearchShowCell *cell = [[JXSearchShowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"recordNameCell" withNewStyle:JXSearchShowCellStyleUser];
            [g_server getHeadImageSmall:userId userName:nickName imageView:cell.headImgView getHeadHandler:nil];
            cell.aboveText = [NSString stringWithFormat:@"\"%@\"%@",nickName,WHOSERECORD];
            [cell setUserInteractionEnabled:NO];
            [cell setSeparatorInset:UIEdgeInsetsZero];
            return cell;
        }else{
            JXSearchShowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchRecordCell"];
            if (!cell) {
                cell = [[JXSearchShowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchRecordCell" withNewStyle:JXSearchShowCellStyleRecord];
            }
            NSMutableArray *msgArray = [self.lastMsgDictionary objectForKey:userId];
            JXMessageObject *msg = msgArray[indexPath.row-1];
            NSString *from = msg.fromUserId;
            NSString *name = msg.fromUserName;
            NSString *content = msg.content;
            NSString *msgTime = [TimeUtil getTimeStrStyle1:[msg.timeSend timeIntervalSince1970]];
            [g_server getHeadImageSmall:from userName:name imageView:cell.headImgView getHeadHandler:nil];
            cell.aboveText = name;
//            NSMutableAttributedString *string = [self showSearchTextColor:content];
//            cell.belowAttributedText = string;
            cell.searchText = self.searchbar.text;
            cell.belowText = content;
            cell.rightText = msgTime;
            return cell;
        }
    }
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 1) {
        JXUserObject *user = self.lastUserArray[indexPath.row - 1];
        if ([self.titleString isEqualToString:CONTACT] || [self.titleString isEqualToString:PUBLIC]) {
            JXChatViewController *chatView = [[JXChatViewController alloc] init];
            chatView.chatPerson = user;
            [g_navigation pushViewController:chatView animated:YES];
            [self.tableview deselectRowAtIndexPath:indexPath animated:YES];
        }
        if ([self.titleString isEqualToString:GROUP]) {
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
        if ([self.titleString isEqualToString:RECORD]) {
            self.chatUser = user;
            [self.recordtableview reloadData];
            [UIView animateWithDuration:0.3 animations:^{
                self.recordtableview.frame = CGRectMake(0, 44, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-SCREEN_VIEW);
            }];
            _inChatRecord = YES;
            [self.tableview deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    if (tableView.tag == 2) {
        JXUserObject *user = self.chatUser;
        NSMutableArray *msgArray = [self.lastMsgDictionary objectForKey:user.userId];
        JXMessageObject *msg = msgArray[indexPath.row-1];
        [self.recordtableview deselectRowAtIndexPath:indexPath animated:YES];
        int lineNum = 0;
        lineNum = [msg getLineNumWithUserId:user.userId];
        JXChatViewController *chatView = [JXChatViewController alloc];
        chatView.scrollLine = lineNum;
        chatView.title = user.userNickname;
        if([user.roomFlag intValue] > 0 || user.roomId.length > 0){
            if(g_xmpp.isLogined != 1){
                [g_xmpp showXmppOfflineAlert];
                return;
            }
            chatView.roomJid = user.userId;
            chatView.roomId = user.roomId;
            chatView.groupStatus = user.groupStatus;
            if ([user.groupStatus intValue] == 0) {
                chatView.chatRoom  = [[JXXMPP sharedInstance].roomPool joinRoom:user.userId title:user.userNickname lastDate:nil isNew:NO];
            }
            
            if (user.roomFlag) {
                NSDictionary * groupDict = [user toDictionary];
                roomData * roomdata = [[roomData alloc] init];
                [roomdata getDataFromDict:groupDict];
                chatView.room = roomdata;
            }
            
        }
        chatView.lastMsg = msg;
        chatView.chatPerson = user;
        chatView = [chatView init];
        [g_navigation pushViewController:chatView animated:YES];
        chatView.view.hidden = NO;
    }
    if ([self.delegate respondsToSelector:@selector(saveSearchRecord:)]) {
        [self.delegate saveSearchRecord:self.searchbar.text];
    }
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

- (NSInteger)getMsgCountWithUserId:(NSString *)userId{
    NSMutableArray *array = [self.lastMsgDictionary objectForKey:userId];
    return array.count;
}
- (void)dismissView{
    if (_inChatRecord) {
        _inChatRecord = NO;
        [self.recordtableview setContentOffset:CGPointMake(0,0) animated:NO];
        self.searchbar.text = self.seachText;
        [self.searchbar resignFirstResponder];
//        [self.cancelBtn setEnabled:YES];
        [UIView animateWithDuration:0.3 animations:^{
            self.recordtableview.frame = CGRectMake(JX_SCREEN_WIDTH, 44, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-SCREEN_VIEW);
        }];
    }else{
        if ([self.delegate respondsToSelector:@selector(tapBackBtn:)]) {
            [self.delegate tapBackBtn:_enterChatRecord];
        }
    }
    
}
@end
