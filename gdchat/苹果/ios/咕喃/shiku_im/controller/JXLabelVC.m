//
//  JXLabelVC.m
//  shiku_im
//
//  Created by p on 2018/6/21.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXLabelVC.h"
#import "JXLabelObject.h"
#import "JXNewLabelVC.h"
#import "QBPopupMenu.h"

#define HEIGHT 60
@interface JXLabelVC ()
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) JXLabelObject *currentLabelObj;

@property (nonatomic, strong) QBPopupMenu *popupMenu;
@end

@implementation JXLabelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = Localized(@"JX_Label");
    
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack   = YES;
//    self.isShowFooterPull = NO;
    
    [self createHeadAndFoot];
    
    _array = [NSMutableArray array];
    _array = [[JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
    if (_array <= 0) {
//        [self scrollToPageUp];
    }
//    for (JXLabelObject *labelObj in _array) {
//        NSString *userIdStr = labelObj.userIdList;
//        NSArray *userIds = [userIdStr componentsSeparatedByString:@","];
//        if (userIdStr.length <= 0) {
//            userIds = nil;
//        }
//
//        NSMutableArray *newUserIds = [userIds mutableCopy];
//        for (NSInteger i = 0; i < userIds.count; i ++) {
//            NSString *userId = userIds[i];
//            NSString *userName = [JXUserObject getUserNameWithUserId:userId];
//
//            if (!userName || userName.length <= 0) {
//                [newUserIds removeObject:userId];
//            }
//
//        }
//        NSString *string = [newUserIds componentsJoinedByString:@","];
//
//        labelObj.userIdList = string;
//        [labelObj update];
//    }
//    [self.tableView reloadData];
    
//    if (!_array || _array.count <= 0) {
//        [self.view insertSubview:self.emptyView aboveSubview:self.tableView];
//        self.emptyView.hidden = NO;
//    }else {
//        self.emptyView.hidden = YES;
//    }
    
    NSMutableArray *items = [NSMutableArray array];
    
    
    QBPopupMenuItem *item1 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"   %@   ", Localized(@"JX_Delete")] target:self action:@selector(deleteAction)];
    [items addObject:item1];
    
    QBPopupMenu *popupMenu = [[QBPopupMenu alloc] initWithItems:items];
    popupMenu.highlightedColor = [UIColor lightGrayColor];
    popupMenu.height = 35;
    self.popupMenu = popupMenu;

    
    [self customView];
    
    [g_notify addObserver:self selector:@selector(refreshNotif:) name:kLabelVCRefreshNotif object:nil];
//    [g_notify addObserver:self selector:@selector(updateLabels:) name:kXMPPMessageUpadtePasswordNotification object:nil];
    [g_notify addObserver:self selector:@selector(refreshNotif:) name:kOfflineOperationUpdateLabelList object:nil];
}

//- (void)updateLabels:(NSNotification *)noti {
//    JXMessageObject *msg = noti.object;
//    if ([msg.objectId isEqualToString:SYNC_LABEL]) {
//        // 同步标签
//        [g_server friendGroupListToView:self];
//    }
//}

//- (void)scrollToPageUp {
//    [self stopLoading];
//    [self refreshNotif:nil];
//}

#pragma mark langPress 长按手势事件
-(void)longPress:(UILongPressGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIView *view = sender.view;
        _currentLabelObj = _array[view.tag];
        [self.popupMenu showInView:self.tableBody targetRect:CGRectMake(view.frame.origin.x, view.frame.origin.y, 60, 35) animated:YES];
    }
}

- (void)deleteAction {
    [g_server friendGroupDelete:_currentLabelObj.groupId toView:self];
}

- (void)customView {
    for (UIView *subV in self.tableBody.subviews) {
        [subV removeFromSuperview];
    }
    
    UIButton *btn;
    CGFloat w = 108;
    CGFloat h = 40;
    int inset = (JX_SCREEN_WIDTH-w*3)/4;
    for (int i = 0; i < _array.count+1; i++) {
        CGFloat x = (w+inset)*(i % 3)+inset;
        int m = i / 3;
        NSString *title;
        if (i < _array.count) {
            JXLabelObject *label = _array[i];
            NSString *userIdStr = label.userIdList;
            NSArray *userIds = [userIdStr componentsSeparatedByString:@","];
            if (userIdStr.length <= 0) {
                userIds = nil;
            }

            title = [NSString stringWithFormat:@"%@ (%ld)",label.groupName, userIds.count];
        }
        btn = [self createButtonWihtFrame:CGRectMake(x, m*41+(15 * (m +1)), w, h) title:title index:i];
    }
    
    
    


    self.tableBody.contentSize = CGSizeMake(0, CGRectGetMaxY(btn.frame)+10);
    
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, HEIGHT)];
//    [btn setBackgroundColor:[UIColor whiteColor]];
//    [btn addTarget:self action:@selector(createLabelAction) forControlEvents:UIControlEventTouchUpInside];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 15, 15)];
//    imageView.center = CGPointMake(imageView.center.x, HEIGHT / 2);
//    imageView.image = [[UIImage imageNamed:@"person_add_green"] imageWithTintColor:THEMECOLOR];
//    [btn addSubview:imageView];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, 0, btn.frame.size.width, btn.frame.size.height)];
//    label.textColor = THEMECOLOR;
//    label.text = Localized(@"JX_NewLabel");
//    label.font = [UIFont systemFontOfSize:16.0];
//    [btn addSubview:label];
//
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT - .5, JX_SCREEN_WIDTH, .5)];
//    line.backgroundColor = HEXCOLOR(0xdcdcdc);
//    [btn addSubview:line];
    
//    self.tableView.tableHeaderView = btn;
}

- (void)refreshNotif:(NSNotification *)notif {
    
    // 同步标签
    [g_server friendGroupListToView:self];
    
}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _emptyView.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, JX_SCREEN_WIDTH, 20)];
        label.font = [UIFont systemFontOfSize:16.0];
        label.textColor = [UIColor grayColor];
        label.text = Localized(@"JX_NoLabel");
        label.textAlignment = NSTextAlignmentCenter;
        [_emptyView addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame) + 10, JX_SCREEN_WIDTH, 20)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.text = Localized(@"JX_LabelFindContacts");
        label.textAlignment = NSTextAlignmentCenter;
        [_emptyView addSubview:label];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(label.frame) + 150, JX_SCREEN_WIDTH - 40, 50)];
        [btn setTitle:Localized(@"JX_NewLabel") forState:UIControlStateNormal];
        [btn setBackgroundColor:THEMECOLOR];
        UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
        [btn setBackgroundImage:img forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 3.0;
        btn.layer.masksToBounds = 0;
        [btn addTarget:self action:@selector(createLabelAction) forControlEvents:UIControlEventTouchUpInside];
        [_emptyView addSubview:btn];
        
    }
    
    return _emptyView;
}

- (void)createLabelAction {
    
    JXNewLabelVC *vc = [[JXNewLabelVC alloc] init];
    vc.title = Localized(@"JX_NewLabel");
    [g_navigation pushViewController:vc animated:YES];
}


//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return _array.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    JXLabelObject *label = _array[indexPath.row];
//    NSString *userIdStr = label.userIdList;
//    NSArray *userIds = [userIdStr componentsSeparatedByString:@","];
//    if (userIdStr.length <= 0) {
//        userIds = nil;
//    }
//
//    NSMutableString *userNameStr = [NSMutableString string];
//    for (NSInteger i = 0; i < userIds.count; i ++) {
//        NSString *userId = userIds[i];
//        NSString *userName = [JXUserObject getUserNameWithUserId:userId];
//        if (i == 0) {
//            [userNameStr appendFormat:@"%@", userName];
//        }else {
//            [userNameStr appendFormat:@", %@", userName];
//        }
//
//    }
//
//    UITableViewCell *cell=nil;
//    NSString* cellName = @"labelCell";
//    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
//
//    if(cell==nil){
//
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
//        [_table addToPool:cell];
//
//    }
//
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)",label.groupName, userIds.count];
//    cell.textLabel.textColor = [UIColor blackColor];
//    cell.textLabel.font = [UIFont systemFontOfSize:16.0];
//
//    cell.detailTextLabel.text = userNameStr;
//    cell.detailTextLabel.textColor = [UIColor grayColor];
//    cell.detailTextLabel.font= [UIFont systemFontOfSize:14.0];
//
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT - .5, JX_SCREEN_WIDTH, .5)];
//    view.backgroundColor = HEXCOLOR(0xdcdcdc);
//    [cell addSubview:view];
//
//    return cell;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return HEIGHT;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    JXLabelObject *label = _array[indexPath.row];
//    JXNewLabelVC *vc = [[JXNewLabelVC alloc] init];
//    vc.title = Localized(@"JX_SettingLabel");
//    vc.labelObj = label;
//    [g_navigation pushViewController:vc animated:YES];
//}
//
//
//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    return YES;
//}
//
//- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    UITableViewRowAction *deleteBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Localized(@"JX_Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        JXLabelObject *labelObj = _array[indexPath.row];
//        _currentLabelObj = labelObj;
//        [g_server friendGroupDelete:labelObj.groupId toView:self];
//    }];
//
//    return @[deleteBtn];
//
//}

- (void)onDidLabel:(UIButton *)button {
    if (button.tag == _array.count) {
        JXNewLabelVC *vc = [[JXNewLabelVC alloc] init];
        vc.title = Localized(@"JX_NewLabel");
        [g_navigation pushViewController:vc animated:YES];
    }else {
        JXLabelObject *label = _array[button.tag];
        JXNewLabelVC *vc = [[JXNewLabelVC alloc] init];
        vc.title = Localized(@"JX_SettingLabel");
        vc.labelObj = label;
        [g_navigation pushViewController:vc animated:YES];
    }
}


//服务器返回数据
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    
    if ([aDownload.action isEqualToString:act_FriendGroupDelete]) {
        
        [_currentLabelObj delete];
        [_array removeObject:_currentLabelObj];
        
        [self customView];
//        [self.tableView reloadData];
    }
    
    // 同步标签
    if ([aDownload.action isEqualToString:act_FriendGroupList]) {
        
        for (NSInteger i = 0; i < array1.count; i ++) {
            NSDictionary *dict = array1[i];
            JXLabelObject *labelObj = [[JXLabelObject alloc] init];
            labelObj.groupId = dict[@"groupId"];
            labelObj.groupName = dict[@"groupName"];
            labelObj.userId = dict[@"userId"];
            
            NSArray *userIdList = dict[@"userIdList"];
            NSString *userIdListStr = [userIdList componentsJoinedByString:@","];
            if (userIdListStr.length > 0) {
                labelObj.userIdList = [NSString stringWithFormat:@"%@", userIdListStr];
            }
            [labelObj insert];
        }
        
        // 删除服务器上已经删除的
        NSArray *arr = [[JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
        for (NSInteger i = 0; i < arr.count; i ++) {
            JXLabelObject *locLabel = arr[i];
            BOOL flag = NO;
            for (NSInteger j = 0; j < array1.count; j ++) {
                NSDictionary * dict = array1[j];
                
                if ([locLabel.groupId isEqualToString:dict[@"groupId"]]) {
                    flag = YES;
                    break;
                }
            }
            
            if (!flag) {
                [locLabel delete];
            }
        }
        
        
        _array = [[JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
//        for (JXLabelObject *labelObj in _array) {
//            NSString *userIdStr = labelObj.userIdList;
//            NSArray *userIds = [userIdStr componentsSeparatedByString:@","];
//            if (userIdStr.length <= 0) {
//                userIds = nil;
//            }
//
//            NSMutableArray *newUserIds = [userIds mutableCopy];
//            for (NSInteger i = 0; i < userIds.count; i ++) {
//                NSString *userId = userIds[i];
//                NSString *userName = [JXUserObject getUserNameWithUserId:userId];
//
//                if (!userName || userName.length <= 0) {
//                    [newUserIds removeObject:userId];
//                }
//
//            }
//
//            NSString *string = [newUserIds componentsJoinedByString:@","];
//
//            labelObj.userIdList = string;
//
//            [labelObj update];
//        }
        
        [self customView];
//        if (!_array || _array.count <= 0) {
//            self.emptyView.hidden = NO;
//        }else {
//            self.emptyView.hidden = YES;
//        }
//        [self.tableView reloadData];
    }
    
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)createButtonWihtFrame:(CGRect)frame title:(NSString *)title index:(NSInteger)index {
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    [btn setTag:index];
    btn.layer.cornerRadius = 7.f;
    btn.layer.masksToBounds = YES;
    btn.layer.borderColor = THEMECOLOR.CGColor;
    btn.layer.borderWidth = 1.f;
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, btn.frame.size.width-20, btn.frame.size.height)];
    label.text = title;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = HEXCOLOR(0x333333);
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByTruncatingMiddle;
    label.font = SYSFONT(15);
    [btn addSubview:label];
    
    if (index == _array.count) {
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2-17/2, frame.size.height/2-17/2, 17, 17)];
        imgV.image = [[UIImage imageNamed:@"groupHelper_add"] imageWithTintColor:HEXCOLOR(0x333333)];
        [btn addSubview:imgV];
    }else {
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        press.minimumPressDuration = 1;
        [btn addGestureRecognizer:press];
    }
    
    [btn addTarget:self action:@selector(onDidLabel:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tableBody addSubview:btn];
    
    return btn;
}



@end
