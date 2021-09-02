//
//  JXSearchChatLogVC.m
//  shiku_im
//
//  Created by p on 2018/6/25.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXSearchChatLogVC.h"
#import "JXCell.h"
#import "JXChatViewController.h"
#import "JXRoomPool.h"
#import "JXSearchFileLogVC.h"
#import "JXSearchImageLogVC.h"

@interface JXSearchChatLogVC () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *seekTextField;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic,strong) UIView *selectView;

@end

@implementation JXSearchChatLogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack = YES;
    self.isShowFooterPull = NO;
    self.isShowHeaderPull = NO;
    [self createHeadAndFoot];
    
    self.title = Localized(@"JX_FindChatContent");
    
    _array = [NSMutableArray array];
    
    //搜索输入框
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 55)];
//    backView.backgroundColor = HEXCOLOR(0xf0f0f0);
    [self.view addSubview:backView];
    
    _seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, backView.frame.size.width - 30, 35)];
    _seekTextField.placeholder = [NSString stringWithFormat:@"%@", Localized(@"JX_SearchChatLog")];
    _seekTextField.backgroundColor = HEXCOLOR(0xf0f0f0);
    [_seekTextField setFont:SYSFONT(14)];
    _seekTextField.backgroundColor = HEXCOLOR(0xf0f0f0);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_search"]];
    UIView *leftView = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 40, 30)];
    //    imageView.center = CGPointMake(leftView.frame.size.width/2, leftView.frame.size.height/2);
    imageView.frame = CGRectMake(15, 7.5, 15, 15);
    [leftView addSubview:imageView];
    _seekTextField.leftView = leftView;
    _seekTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
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
    
    [self createSelectView];
    
}


- (void)createSelectView {
    
    if (!_selectView) {
        _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, self.tableView.frame.size.width, self.tableView.frame.size.height - 50)];
        [self.tableView addSubview:_selectView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectViewTap:)];
        [_selectView addGestureRecognizer:tap];
        
        UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, _selectView.frame.size.width, 30)];
        tip.textAlignment = NSTextAlignmentCenter;
        tip.textColor = [UIColor lightGrayColor];
        tip.text = Localized(@"JX_SearchChatContentQuickly");
        tip.font = [UIFont systemFontOfSize:14.0];
        [_selectView addSubview:tip];
        
        NSMutableArray *items = @[Localized(@"JX_Image"), Localized(@"JX_Video"), Localized(@"JX_File"), Localized(@"JXLink"), Localized(@"JX_Trading")].mutableCopy;
        
        if (![g_config.enablePayModule boolValue]) {
            [items removeObject:Localized(@"JX_Trading")];
        }
        
        CGFloat itemW = 100;
        CGFloat itemH = 60;
        CGFloat marginX = (JX_SCREEN_WIDTH - (itemW * 3)) / 2;
        CGFloat itemX = marginX;
        CGFloat itemY = CGRectGetMaxY(tip.frame) + 10;
        
        UIButton *lastItem= nil;
        for (NSInteger i = 0; i < items.count; i ++) {
            
            if (i % 3 == 0) {
                itemX = marginX;
                if (lastItem) {
                    itemY = CGRectGetMaxY(lastItem.frame);
                }else {
                    itemY = CGRectGetMaxY(tip.frame) + 10;
                }
            }else {
                itemX = CGRectGetMaxX(lastItem.frame);
                itemY = lastItem.frame.origin.y;
                
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(itemX, ((itemH - 20) / 2) + itemY, LINE_WH, 20)];
                lineView.backgroundColor = THE_LINE_COLOR;
                [_selectView addSubview:lineView];
            }
            
            NSString *itemTitle = items[i];
            
            UIButton *item = [[UIButton alloc] initWithFrame:CGRectMake(itemX, itemY, itemW, itemH)];
            [item setTitle:itemTitle forState:UIControlStateNormal];
            [item setTitleColor:HEXCOLOR(0x576b95) forState:UIControlStateNormal];
            item.titleLabel.font = [UIFont systemFontOfSize:16.0];
            item.tag = i;
            [item addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
            [_selectView addSubview:item];
            
            lastItem = item;
        }
    }
}

- (void)itemAction:(UIButton *)btn {
    
    NSInteger type = 0;
    switch (btn.tag) {
        case 0:{
            JXSearchImageLogVC *vc = [[JXSearchImageLogVC alloc] init];
            vc.isImage = YES;
            vc.user = self.user;
            [g_navigation pushViewController:vc animated:YES];
            return;
        }
            break;
        case 1:{
            JXSearchImageLogVC *vc = [[JXSearchImageLogVC alloc] init];
            vc.isImage = NO;
            vc.user = self.user;
            [g_navigation pushViewController:vc animated:YES];
            return;
        }
            break;
        case 2:
            type = FileLogType_file;
            break;
        case 3:
            type = FileLogType_Link;
            break;
        case 4:
            type = FileLogType_transact;
            break;
            
        default:
            break;
    }
    JXSearchFileLogVC *vc = [[JXSearchFileLogVC alloc] init];
    vc.type = type;
    vc.user = self.user;
    vc.isGroup = YES;
    [g_navigation pushViewController:vc animated:YES];
}

- (void)selectViewTap:(UITapGestureRecognizer *)tap {
 
    [self.view endEditing:YES];
}

- (void) textFieldDidChange:(UITextField *)textField {
    
    [_array removeAllObjects];
    if (textField.text.length <= 0) {
        _selectView.hidden = NO;
        [self.tableView reloadData];
        return;
    }
    
    _selectView.hidden = YES;
    NSArray * resultArray = [[JXMessageObject sharedInstance] fetchSearchMessageWithUserId:self.user.userId String:textField.text];
    
    for (JXMessageObject *msg in resultArray) {
        if(msg.content.length > 0) {
            JXMsgAndUserObject *searchObj = [[JXMsgAndUserObject alloc] init];
            searchObj.user = self.user;
            searchObj.message = msg;
            [_array addObject:searchObj];
        }
    }

    [self.tableView reloadData];
}


#pragma mark   ---------tableView协议----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellName = [NSString stringWithFormat:@"msg"];
    
    JXCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];

    JXMsgAndUserObject * dict = (JXMsgAndUserObject*) [_array objectAtIndex:indexPath.row];
    
    if(cell==nil){
        cell = [[JXCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];;
        [_table addToPool:cell];
    }
    cell.delegate = self;
    cell.didTouch = @selector(onHeadImage:);
    cell.didDragout=@selector(onDrag:);
    //    [cell msgCellDataSet:dict indexPath:indexPath];
    cell.title = dict.user.userNickname;
    
    cell.userId = dict.user.userId;
    cell.bage = [NSString stringWithFormat:@"%d",[dict.user.msgsNew intValue]];
    cell.index = (int)indexPath.row;
    cell.bottomTitle  = [TimeUtil getTimeStrStyle1:[dict.message.timeSend timeIntervalSince1970]];
    
    cell.headImageView.tag = (int)indexPath.row;
    cell.headImageView.delegate = cell.delegate;
    cell.headImageView.didTouch = cell.didTouch;
    
    [cell.lbTitle setText:cell.title];
    cell.lbTitle.tag = cell.index;
    
    if(dict.user.lastInput.length > 0) {
        NSString *str = Localized(@"JX_Draft");
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",str, dict.user.lastInput]];
        NSRange range = [[NSString stringWithFormat:@"%@%@",str, dict.user.lastInput] rangeOfString:str];
        [attr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
        cell.lbSubTitle.attributedText = attr;
        
    }else {
        [cell setSubtitle:[dict.message getLastContent]];
    }
    
    [cell.timeLabel setText:cell.bottomTitle];
    cell.bageNumber.delegate = cell.delegate;
    cell.bageNumber.didDragout = cell.didDragout;
    cell.bage = cell.bage;
    if ([dict.user.userId isEqualToString:FRIEND_CENTER_USERID]) {
        cell.bageNumber.lb.hidden = YES;
        CGRect frame = cell.bageNumber.frame;
        frame.size = CGSizeMake(10, 10);
        cell.bageNumber.frame = frame;
    }else {
        cell.bageNumber.lb.hidden = NO;
        CGRect frame = cell.bageNumber.frame;
        frame.size = CGSizeMake(18, 18);
        cell.bageNumber.frame = frame;
    }
    NSString * roomIdStr = dict.user.roomId;
    cell.roomId = roomIdStr;
    cell.isSmall = NO;
    [cell headImageViewImageWithUserId:dict.user.userId roomId:roomIdStr];
    [self doAutoScroll:indexPath];
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (dict.user.topTime) {
        cell.contentView.backgroundColor = HEXCOLOR(0xF0F1F2);
    }else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == [_array count]-1) {
        cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width,0);
    }else {
        cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width,LINE_WH);
    }
    
    
    return cell;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JXMsgAndUserObject *p=[_array objectAtIndex:indexPath.row];
    
    int lineNum = 0;
    if (_seekTextField.text.length > 0) {
        lineNum = [p.message getLineNumWithUserId:p.user.userId];
    }

    
    JXChatViewController *sendView=[JXChatViewController alloc];
    
    sendView.scrollLine = lineNum;
    sendView.title = p.user.userNickname;
    if([p.user.roomFlag intValue] > 0 || p.user.roomId.length > 0){
        if(g_xmpp.isLogined != 1){
            // 掉线后点击title重连
            [g_xmpp showXmppOfflineAlert];
            return;
        }
        sendView.roomJid = p.user.userId;
        sendView.roomId   = p.user.roomId;
        sendView.groupStatus = p.user.groupStatus;
        if ([p.user.groupStatus intValue] == 0) {
            
            sendView.chatRoom  = [[JXXMPP sharedInstance].roomPool joinRoom:p.user.userId title:p.user.userNickname lastDate:nil isNew:NO];
        }
        
        if (p.user.roomFlag) {
            NSDictionary * groupDict = [p.user toDictionary];
            roomData * roomdata = [[roomData alloc] init];
            [roomdata getDataFromDict:groupDict];
            
            sendView.room = roomdata;
        }
        
    }
    sendView.lastMsg = p.message;
    sendView.chatPerson = p.user;
    sendView = [sendView init];
    //    [g_App.window addSubview:sendView.view];
    [g_navigation pushViewController:sendView animated:YES];
    sendView.view.hidden = NO;

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
