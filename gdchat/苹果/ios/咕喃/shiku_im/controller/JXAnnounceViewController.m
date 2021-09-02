//
//  JXAnnounceViewController.m
//  shiku_im
//
//  Created by 1 on 2018/8/17.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXAnnounceViewController.h"
#import "selectProvinceVC.h"
#import "selectValueVC.h"
#import "ImageResize.h"
#import "searchData.h"
#import "JXAnnounceCell.h"

#define HEIGHT 54
#define STARTTIME_TAG 1
#define IMGSIZE 100

@interface JXAnnounceViewController ()<UITextViewDelegate>
@property(nonatomic, assign) BOOL isShow;
@property(nonatomic, assign) BOOL isEdit;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIView *bigView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) JXLabel* relLabel;

@property (nonatomic, strong) NSIndexPath *editImageIndex;

@end

@implementation JXAnnounceViewController
@synthesize delegate,didSelect,value;

- (id)init
{
    self = [super init];
    if (self) {
        self.isGotoBack   = YES;
        self.heightFooter = 0;
        self.heightHeader = JX_SCREEN_TOP;
        [self createHeadAndFoot];
        self.isShowHeaderPull = NO;
        self.isShowFooterPull = NO;
        self.tableView.backgroundColor = HEXCOLOR(0xF2F2F2);
        int height = 44;
        self.bigView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.bigView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        self.bigView.hidden = YES;
        [self.tableView addSubview:self.bigView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
        [self.bigView addGestureRecognizer:tap];
        
        self.baseView = [[UIView alloc] initWithFrame:CGRectMake(40, JX_SCREEN_HEIGHT/4-.5, JX_SCREEN_WIDTH-80, 162)];
        self.baseView.backgroundColor = [UIColor whiteColor];
        self.baseView.layer.masksToBounds = YES;
        self. baseView.layer.cornerRadius = 4.0f;
        [self.bigView addSubview:self.baseView];
        int n = 20;
        UILabel *titLabel = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, n, self.bigView.frame.size.width - INSETS*2, 20)];
        titLabel.textColor = HEXCOLOR(0x333333);
        titLabel.text = Localized(@"JX_Announcement");
        titLabel.font = SYSFONT(16);
        [self.baseView addSubview:titLabel];
        
        n = n + height;
        self.name = [self createTextField:self.baseView default:self.value hint:nil];
        self.name.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
//        _name.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
//        CGRect frame = self.name.frame;
//        CGSize constraintSize = CGSizeMake(frame.size.width - 20, MAXFLOAT);
//        CGSize size = [self.name sizeThatFits:constraintSize];
        self.name.textColor = HEXCOLOR(0x595959);
        self.name.frame = CGRectMake(10, n, self.baseView.frame.size.width - INSETS*2, 35.5);
        self.name.delegate = self;
        
        n = n + INSETS + height;
        self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, n, self.baseView.frame.size.width, 44)];
        [self.baseView addSubview:self.topView];

        // 两条线
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.baseView.frame.size.width, LINE_WH)];
        topLine.backgroundColor = THE_LINE_COLOR;
        [self.topView addSubview:topLine];
        UIView *botLine = [[UIView alloc] initWithFrame:CGRectMake(self.baseView.frame.size.width/2, 0, LINE_WH, self.topView.frame.size.height)];
        botLine.backgroundColor = THE_LINE_COLOR;
        [self.topView addSubview:botLine];
        
        // 取消
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topLine.frame), self.baseView.frame.size.width/2, botLine.frame.size.height)];
        [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelBtn.titleLabel setFont:SYSFONT(15)];
        [cancelBtn addTarget:self action:@selector(hideBigView) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:cancelBtn];
        // 确定
        UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.baseView.frame.size.width/2, CGRectGetMaxY(topLine.frame), self.baseView.frame.size.width/2, botLine.frame.size.height)];
        [sureBtn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
        [sureBtn setTitleColor:HEXCOLOR(0x55BEB8) forState:UIControlStateNormal];
        [sureBtn.titleLabel setFont:SYSFONT(15)];
        [sureBtn addTarget:self action:@selector(onRelease) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:sureBtn];
        
        CGSize size = [Localized(@"JX_Publish") sizeWithAttributes:@{NSFontAttributeName:SYSFONT(15)}];
        // 发布
        self.relLabel = [self createLabel:self.tableHeader default:Localized(@"JX_Publish") selector:@selector(onSave)];
        self.relLabel.textColor = [UIColor blackColor];
        self.relLabel.font = SYSFONT(15);
        self.relLabel.textAlignment = NSTextAlignmentRight;
        self.relLabel.frame =  CGRectMake(JX_SCREEN_WIDTH -size.width-15, JX_SCREEN_TOP-30, size.width, 15);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mark - tableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict = self.dataArray[indexPath.row];
    CGSize size = [dict[@"text"] boundingRectWithSize:CGSizeMake(JX_SCREEN_WIDTH-INSETS*2-15*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:g_factory.font16} context:nil].size;
    
    return 116 + size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"JXAnnounceCell";
    JXAnnounceCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[JXAnnounceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.dataArray.count > 0) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict = self.dataArray[indexPath.row];
        [g_server getHeadImageSmall:[NSString stringWithFormat:@"%@",dict[@"userId"]] userName:dict[@"nickname"] imageView:cell.icon getHeadHandler:nil];
        cell.name.text = [NSString stringWithFormat:@"%@",dict[@"nickname"]];
        NSTimeInterval startTime = [dict[@"time"] longLongValue];
        cell.time.text = [TimeUtil getTimeStrStyle1:startTime];
        cell.content.text = dict[@"text"];
        [cell setCellHeightWithText:dict[@"text"]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}



- (NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    // delete action
    if (self.isAdmin) { // 是群主或管理员添加删除功能
        //Localized(@"JX_Edit")
        UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:nil handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
              {
                  [tableView setEditing:NO animated:YES];  // 退出编辑模式，隐藏左滑菜单
                  self.index = indexPath.row;
                  
                  self.isEdit = YES;
                  self.bigView.hidden = NO;
                  self.relLabel.userInteractionEnabled = NO;
                  
                  self.name.text = self.dataArray[indexPath.row][@"text"];
                  [self.name becomeFirstResponder];
                  [self textViewDidChange:self.name];
              }];
        editAction.backgroundColor = self.tableView.backgroundColor;   // 编辑按钮颜色
        //Localized(@"JX_Delete")
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:nil handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                {
                    [tableView setEditing:NO animated:YES];  // 退出编辑模式，隐藏左滑菜单
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    dict = self.dataArray[indexPath.row];
                    NSString *roomId = [NSString stringWithFormat:@"%@",dict[@"roomId"]];
                    NSString *noticeId = [NSString stringWithFormat:@"%@",dict[@"id"]];
                    self.index = indexPath.row;
                    [g_server roomDeleteNotice:roomId noticeId:noticeId ToView:self];
                }];
        deleteAction.backgroundColor = self.tableView.backgroundColor;   // 删除按钮颜色

    return @[deleteAction,editAction];
    }
    return @[];
}

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath*)indexPath{
    self.editImageIndex= indexPath;
    [self.view setNeedsLayout];
    
}


- (void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
    
    [self configSwipeButtons];
    
}

- (void)configSwipeButtons {
    
    // 获取选项按钮的reference
    if (SYSTEM_VERSION_GRETER_THAN(@"13.0")) {
        for (UIView *subview in self.tableView.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"_UITableViewCellSwipeContainerView")]) {
                for (UIView *sView in subview.subviews) {
                    if ([sView isKindOfClass:NSClassFromString(@"UISwipeActionPullView")] && [sView.subviews count] >= 2) {
                        // 和iOS 10的按钮顺序相反
                        UIButton*deleteButton = sView.subviews[0];
                        [deleteButton setImage:[UIImage imageNamed:@"announce_translate_icon"] forState:UIControlStateNormal];
                        UIButton*readButton = sView.subviews[1];
                        [readButton setImage:[UIImage imageNamed:@"announce_delete_icon"] forState:UIControlStateNormal];
                    }

                }
            }
        }
    }
    else if (SYSTEM_VERSION_GRETER_THAN(@"11.0")) {
        // iOS 11层级 : UITableView -> UISwipeActionPullView
        for (UIView *subview in self.tableView.subviews) {
            //这里写大于等于2是因为我这里需要两个action
            if ([subview isKindOfClass:NSClassFromString(@"UISwipeActionPullView")] && [subview.subviews count] >= 2) {
                // 和iOS 10的按钮顺序相反
                UIButton*deleteButton = subview.subviews[0];
                [deleteButton setImage:[UIImage imageNamed:@"announce_translate_icon"] forState:UIControlStateNormal];
                UIButton*readButton = subview.subviews[1];
                [readButton setImage:[UIImage imageNamed:@"announce_delete_icon"] forState:UIControlStateNormal];
            }
        }
    }
    else {
        // iOS 8-10层级: UITableView -> UITableViewCell -> UITableViewCellDeleteConfirmationView
        JXAnnounceCell *cell = [self.tableView cellForRowAtIndexPath:self.editImageIndex];
        for(UIView*subview in cell.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")] && [subview.subviews count] >= 2) {
                UIButton*deleteButton = subview.subviews[0];
                [deleteButton setImage:[UIImage imageNamed:@"announce_translate_icon"] forState:UIControlStateNormal];
                UIButton*readButton = subview.subviews[1];
                [readButton setImage:[UIImage imageNamed:@"announce_delete_icon"] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)hideBigView {
    [self hideKeyBoard];
    self.bigView.hidden = YES;
    self.relLabel.userInteractionEnabled = YES;
    [self resetBigView];
}

- (void)hideKeyBoard {
    if ([self.name isFirstResponder]) {
        [self.name resignFirstResponder];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.isLimit) {
        if (self.limitLen <= 0) {
            self.limitLen = 15;
        }
        if(textView.text.length > self.limitLen && ![text isEqualToString:@""]){
            if (!self.isShow) {
                self.isShow = YES;
                [g_App showAlert:Localized(@"JX_InputLimit")];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.isShow = NO;
                });
            }
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView {
    
    int maxHeight = 66.f;
    
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(JX_SCREEN_WIDTH-80-INSETS*2, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height >= maxHeight)
    {
        size.height = maxHeight;
        textView.scrollEnabled = YES;   // 允许滚动
    }
    else
    {
        textView.scrollEnabled = NO;    // 不允许滚动
    }
    
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
    self.baseView.frame = CGRectMake(40, JX_SCREEN_HEIGHT/4+35-size.height, JX_SCREEN_WIDTH-80, 162-35+size.height);
    self.topView.frame = CGRectMake(0, 118-35+size.height, self.baseView.frame.size.width, 40);

}

-(UITextView*)createTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint{
    UITextView* p = [[UITextView alloc] initWithFrame:CGRectMake(0,INSETS,JX_SCREEN_WIDTH,HEIGHT)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.scrollEnabled = NO;
    //    p.borderStyle = UITextBorderStyleNone;
    p.returnKeyType = UIReturnKeyDone;
    p.showsVerticalScrollIndicator = NO;
    p.showsHorizontalScrollIndicator = NO;
    //    p.clearButtonMode = UITextFieldViewModeAlways;
    p.textAlignment = NSTextAlignmentLeft;
    p.userInteractionEnabled = YES;
    p.backgroundColor = [UIColor whiteColor];
    p.text = s;
    //    p.placeholder = hint;
    //    p.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, HEIGHT-INSETS*2)];
    //    p.leftViewMode = UITextFieldViewModeAlways;
    p.font = g_factory.font16;
    [parent addSubview:p];
    return p;
}

-(JXLabel*)createLabel:(UIView*)parent default:(NSString*)s selector:(SEL)selector{
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2,INSETS,JX_SCREEN_WIDTH/2 -20,HEIGHT-INSETS*2)];
    p.userInteractionEnabled = NO;
    p.text = s;
    p.font = g_factory.font14;
    p.textAlignment = NSTextAlignmentLeft;
    p.didTouch = selector;
    p.delegate = self;
    [parent addSubview:p];
    return p;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (void)onRelease {
    if([_name.text isEqualToString:@""]){
        [g_App showAlert:Localized(@"JX_AnnouncementNoNull")];
        return;
    }
    [self hideBigView];
    if (self.isEdit) {

        NSString *roomId = [NSString stringWithFormat:@"%@",self.dataArray[self.index][@"roomId"]];
        NSString *noticeId = [NSString stringWithFormat:@"%@",self.dataArray[self.index][@"id"]];
        [g_server updateNotice:roomId noticeId:noticeId noticeContent:self.name.text toView:self];
    }else {
        self.room.note = _name.text;
        [g_server updateRoomNotify:self.room toView:self];
    }
}


-(void)onSave{
    if (!self.isAdmin) {
        [g_App showAlert:Localized(@"JXRoomMemberVC_NotAdminCannotDoThis")];
        return;
    }
    self.isEdit = NO;
    self.name.text = nil;
    self.bigView.hidden = NO;
    self.relLabel.userInteractionEnabled = NO;
    [self.name becomeFirstResponder];
}

- (void)resetBigView {
    self.name.frame = CGRectMake(10, 64, self.baseView.frame.size.width - INSETS*2, 35.5);
    self.baseView.frame = CGRectMake(40, JX_SCREEN_HEIGHT/4-.5, JX_SCREEN_WIDTH-80, 162);
    self.topView.frame = CGRectMake(0, 118, self.baseView.frame.size.width, 40);
}

-(void)didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:act_roomDeleteNotice]){
        [self.dataArray removeObjectAtIndex:self.index];
        [self.tableView reloadData];
        self.value = [(NSDictionary *)self.dataArray.firstObject objectForKey:@"text"];
        if (delegate && [self.delegate respondsToSelector:didSelect]) {
            [delegate performSelectorOnMainThread:didSelect withObject:self waitUntilDone:NO];
        }
    }
    if( [aDownload.action isEqualToString:act_roomSet]){
        NSMutableDictionary *noticeDict = [[NSMutableDictionary alloc] init];
        NSNumber *time = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        [noticeDict setObject:self.room.roomId forKey:@"roomId"];
        [noticeDict setObject:self.room.roomId forKey:@"id"];
        [noticeDict setObject:MY_USER_ID forKey:@"userId"];
        [noticeDict setObject:self.name.text forKey:@"text"];
        [noticeDict setObject:time forKey:@"time"];
        [noticeDict setObject:MY_USER_NAME forKey:@"nickname"];
        [noticeDict setObject:[dict objectForKey:@"noticeId"] forKey:@"id"];
        [self.dataArray insertObject:noticeDict atIndex:0];
        [self.tableView reloadData];
        
//        [g_server getRoom:self.room.roomId toView:self];
        if (delegate && [self.delegate respondsToSelector:didSelect]) {
            [delegate performSelectorOnMainThread:didSelect withObject:self waitUntilDone:NO];
        }
    }
    if( [aDownload.action isEqualToString:act_roomGet]){
//        [self.dataArray removeAllObjects];
//        NSArray *arr = [dict objectForKey:@"notices"];
//        [self.dataArray addObjectsFromArray:arr];
//        [self.tableView reloadData];
    }
    if ([aDownload.action isEqualToString:act_updateNotice]) {
        [self.dataArray[self.index] setValue:self.name.text forKey:@"text"];
        self.value = self.name.text;
        [g_server showMsg:Localized(@"JXAlert_UpdateOK")];
        [self.tableView reloadData];
        if (delegate && [self.delegate respondsToSelector:didSelect]) {
            [delegate performSelectorOnMainThread:didSelect withObject:self waitUntilDone:NO];
        }
    }
}

-(int)didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    return show_error;
}

-(int)didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{
    [_wait stop];
    return show_error;
}

-(void)didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
}


@end
