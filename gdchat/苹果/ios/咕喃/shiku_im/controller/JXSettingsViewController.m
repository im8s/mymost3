//
//  JXSettingsViewController.m
//  shiku_im
//
//  Created by Apple on 16/5/6.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXSettingsViewController.h"
#import "UIImage+Tint.h"
#import "loginVC.h"
#import "JXMoreSelectVC.h"
#import "JXActionSheetVC.h"

#define HEIGHT 50

typedef enum : NSUInteger {
    Type_chatRecordTimeOut = 1,
    Type_chatSyncTimeLen,
    Type_groupChatSyncTimeLen,
} PickerViewType;

@interface JXSettingsViewController ()<UIAlertViewDelegate, UIPickerViewDelegate,JXMoreSelectVCDelegate,JXActionSheetVCDelegate>{
    ATMHud* _wait;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topCon;
@property (nonatomic, strong) UILabel *timeOutLabel;
@property (nonatomic, strong) UILabel *syncTimeLenLabel;
@property (nonatomic, strong) UILabel *groupSyncTimeLenLabel;

@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *pickerArr;
@property (nonatomic, assign) PickerViewType selType;

@property (nonatomic, strong) JXMoreSelectVC *moreVC;

@property (nonatomic, strong) NSString *indexStr;
@property (nonatomic, strong) UILabel *addMeTypeLab;
@property (nonatomic, strong) UILabel *seeTimeTypeLab;
@property (nonatomic, strong) UILabel *seeNumTypeLab;
@property (nonatomic, strong) NSArray *loginTimeArr;
@property (nonatomic, assign) BOOL isShowNum;


@end

@implementation JXSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    [self createHeaderView];
    
    self.topCon.constant = JX_SCREEN_TOP;
    
    //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    
//    self.dataSorce = [[NSDictionary alloc]init];
//    [self getData];
    
    //获取服务器的好友状态
    [self changeSettingsNum];
    
    _pickerArr = @[Localized(@"JX_OutOfSync"),Localized(@"JX_OneHour"), Localized(@"JX_OneDay"), Localized(@"JX_OneWeeks"), Localized(@"JX_OneMonth"), Localized(@"JX_OneQuarter"), Localized(@"JX_OneYear"),Localized(@"JX_Forever")];
    _loginTimeArr = @[Localized(@"JX_SetContactYES"),Localized(@"JX_SetAllFriendYES"),Localized(@"JX_SetAllYES"),Localized(@"JX_SetAllNO")];

    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 130)];
    headView.backgroundColor = HEXCOLOR(0xF2F2F2);
    [self.myTableView addSubview:headView];
    
    CGFloat y = 0;
//    JXImageView *iv = [self createButton:Localized(@"JX_SetTheChatMsgSaveTime") drawTop:NO drawBottom:YES must:NO click:@selector(chatTimeOut:) superView:headView];
//    iv.frame = CGRectMake(0,0, JX_SCREEN_WIDTH, HEIGHT);
//    _timeOutLabel = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-135,11,100,30)];
//    _timeOutLabel.textAlignment = NSTextAlignmentRight;
//    _timeOutLabel.userInteractionEnabled = NO;
//    _timeOutLabel.font = g_factory.font15;
//    double outTime = [[self.dataSorce objectForKey:@"chatRecordTimeOut"] doubleValue];
//    _timeOutLabel.text = [self getPickerContentWithDay:outTime];
//    [iv addSubview:_timeOutLabel];
//    y = CGRectGetMaxY(iv.frame);
    
    JXImageView *iv = [self createButtonWithFrame:CGRectMake(0,y, JX_SCREEN_WIDTH, HEIGHT) title:Localized(@"JX_SingleRoamTime") drawTop:NO drawBottom:NO must:NO click:@selector(syncTimeLen:) superView:headView];
    _syncTimeLenLabel = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-135,11,100,30)];
    _syncTimeLenLabel.textAlignment = NSTextAlignmentRight;
    _syncTimeLenLabel.userInteractionEnabled = NO;
    _syncTimeLenLabel.font = [UIFont boldSystemFontOfSize:16];
    double syncTimeLen = [[self.dataSorce objectForKey:@"chatSyncTimeLen"] doubleValue];
    _syncTimeLenLabel.text = [self getPickerContentWithDay:syncTimeLen];
    [iv addSubview:_syncTimeLenLabel];
    y = CGRectGetMaxY(iv.frame);
    
    y += 10;
    //谁可以看到我的上线时间
    iv = [self createButtonWithFrame:CGRectMake(0,y, JX_SCREEN_WIDTH, 68) title:Localized(@"JX_WhoCanSeeMyOnlineTime") drawTop:NO drawBottom:YES must:YES click:@selector(showLastLoginTime) superView:headView];
    
    self.seeNumTypeLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 37, 300, 20)];
    self.seeNumTypeLab.textColor = [UIColor grayColor];
    self.seeNumTypeLab.font = SYSFONT(14);
    self.seeNumTypeLab.text = [self getSeeLgoinLastTime:[self.dataSorce objectForKey:@"showLastLoginTime"]];
    [iv addSubview:self.seeNumTypeLab];
    
    if ([g_config.regeditPhoneOrName intValue] == 0) {
        //谁可以看到我的手机号码
        y += iv.frame.size.height;
        iv = [self createButtonWithFrame:CGRectMake(0,y, JX_SCREEN_WIDTH, 68) title:Localized(@"JX_WhoCanSeeMyNo.") drawTop:NO drawBottom:NO must:YES click:@selector(showNumber) superView:headView];
        
        self.seeTimeTypeLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 37, 300, 20)];
        self.seeTimeTypeLab.textColor = [UIColor grayColor];
        self.seeTimeTypeLab.font = SYSFONT(14);
        self.seeTimeTypeLab.text = [self getSeeLgoinLastTime:[self.dataSorce objectForKey:@"showTelephone"]];
        [iv addSubview:self.seeTimeTypeLab];
    }


    //允许加我的方式
    y += iv.frame.size.height;
    iv = [self createButtonWithFrame:CGRectMake(0,y, JX_SCREEN_WIDTH, 68) title:Localized(@"JX_AddMeToWay") drawTop:YES drawBottom:NO must:YES click:@selector(selectAddMeType) superView:headView];
    
    self.addMeTypeLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 37, JX_SCREEN_WIDTH-15*2-7, 20)];
    self.addMeTypeLab.textColor = [UIColor grayColor];
    self.addMeTypeLab.font = SYSFONT(14);
    self.addMeTypeLab.text = [self getaddMeTypeText:[self.dataSorce objectForKey:@"friendFromList"]];
    [iv addSubview:self.addMeTypeLab];
//    iv = [self createButton:Localized(@"JX_GroupRoamTime") drawTop:NO drawBottom:YES must:NO click:@selector(groupSyncTimeLen:) superView:headView];
//    iv.frame = CGRectMake(0,y, JX_SCREEN_WIDTH, HEIGHT);
//    _groupSyncTimeLenLabel = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-135,11,100,30)];
//    _groupSyncTimeLenLabel.textAlignment = NSTextAlignmentRight;
//    _groupSyncTimeLenLabel.userInteractionEnabled = NO;
//    _groupSyncTimeLenLabel.font = g_factory.font15;
//    double groupSyncTimeLen = [[self.dataSorce objectForKey:@"groupChatSyncTimeLen"] doubleValue];
//    _groupSyncTimeLenLabel.text = [self getPickerContentWithDay:groupSyncTimeLen];
//    [iv addSubview:_groupSyncTimeLenLabel];

    
    headView.frame = CGRectMake(headView.frame.origin.x, headView.frame.origin.y, headView.frame.size.width, CGRectGetMaxY(iv.frame)+10);
    
    self.myTableView.backgroundColor = HEXCOLOR(0xF2F2F2);
    self.myTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.tableHeaderView = headView;
    [self.myTableView reloadData];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
//    [self.myTableView addGestureRecognizer:tap];
    
    
    
    _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_TOP)];
    _selectView.backgroundColor = [UIColor clearColor];
    _selectView.hidden = YES;
    [self.view addSubview:_selectView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelBtnAction)];
    [_selectView addGestureRecognizer:tap];
    
    UIView *selV = [[UIView alloc] initWithFrame:CGRectMake(0, _selectView.frame.size.height - 220, JX_SCREEN_WIDTH, 220)];
    selV.backgroundColor = HEXCOLOR(0xF2F2F2);
    [_selectView addSubview:selV];

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(selV.frame.size.width - 80, 20, 60, 20)];
    [btn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [selV addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 50, 20)];
    [btn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [selV addSubview:btn];
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, selV.frame.size.width, selV.frame.size.height - 40)];
    _pickerView.delegate = self;

//    [_pickerView selectRow:index inComponent:0 animated:NO];
    [selV addSubview:_pickerView];
    
    _pSelf = self;
    [g_notify addObserver:self selector:@selector(updateCurData:) name:kXMPPMessageUpadtePasswordNotification object:nil];

}

- (void)getData {
    //获取服务器的好友状态
    [self changeSettingsNum];
    
    
    double syncTimeLen = [[self.dataSorce objectForKey:@"chatSyncTimeLen"] doubleValue];
    _syncTimeLenLabel.text = [self getPickerContentWithDay:syncTimeLen];
    
    self.seeNumTypeLab.text = [self getSeeLgoinLastTime:[self.dataSorce objectForKey:@"showLastLoginTime"]];

    self.seeTimeTypeLab.text = [self getSeeLgoinLastTime:[self.dataSorce objectForKey:@"showTelephone"]];
    self.addMeTypeLab.text = [self getaddMeTypeText:[self.dataSorce objectForKey:@"friendFromList"]];
    [self.myTableView reloadData];
}

- (void)updateCurData:(NSNotification *)noti {
    JXMessageObject *msg = noti.object;
    if ([msg.objectId isEqualToString:SYNC_PRIVATE_SETTINGS]) {
        [g_server getFriendSettings:g_myself.userId toView:self];
    }
}

- (void)showNumber {
    self.isShowNum = YES;
    JXActionSheetVC *actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:self.loginTimeArr];
    actionVC.delegate = self;
    [self presentViewController:actionVC animated:NO completion:nil];
}

- (void)showLastLoginTime {
    self.isShowNum = NO;
    JXActionSheetVC *actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:self.loginTimeArr];
    actionVC.delegate = self;
    [self presentViewController:actionVC animated:NO completion:nil];
}

- (void)actionSheet:(JXActionSheetVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    NSNumber *timeIndex = 0;
    if (index == 0) {
        timeIndex = @3;
    }
    else if (index == 1) {
        timeIndex = @2;
    }
    else if (index == 2) {
        timeIndex = @1;
    }
    else if (index == 3) {
        timeIndex = @-1;
    }
    NSString *key = [NSString string];
    if (self.isShowNum) {
        key = @"showTelephone";
        self.seeTimeTypeLab.text = self.loginTimeArr[index];
    }else {
        key = @"showLastLoginTime";
        self.seeNumTypeLab.text = self.loginTimeArr[index];
    }
    [g_server changeFriendSetting:nil allowAtt:nil allowGreet:nil key:key value:[NSString stringWithFormat:@"%@",timeIndex] toView:self];
}

- (NSString *)getSeeLgoinLastTime:(NSNumber *)str {
    NSDictionary *type =@{@"-1":Localized(@"JX_SetAllNO"),@"1":Localized(@"JX_SetAllYES"),@"2":Localized(@"JX_SetAllFriendYES"),@"3":Localized(@"JX_SetContactYES")};
    return [type objectForKey:[NSString stringWithFormat:@"%@",str]];
}

- (NSString *)getaddMeTypeText:(NSString *)indexStr {
    NSArray *type = @[Localized(@"JXQR_QRImage"),Localized(@"JX_Card"),Localized(@"JX_ManyPerChat"),Localized(@"JX_MobileSearch"),Localized(@"JX_NicknameSearch"),Localized(@"OTHER")];
    NSMutableArray *indexArr = [NSMutableArray arrayWithArray:[indexStr componentsSeparatedByString:@","]];
    NSMutableArray *typeArr = [NSMutableArray array];
    [indexArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj intValue] == 0) {
            [indexArr removeObject:obj];
        }else {
            [typeArr addObject:[type objectAtIndex:[obj intValue]-1]];
        }
    }];
    
    if (indexArr.count <= 0) {
        return Localized(@"JX_SetAllNO");
    }else if (indexArr.count >= type.count){
        return Localized(@"JX_SetAllYES");
    }

    return [typeArr componentsJoinedByString:@","];
}

- (void)selectAddMeType {
    self.moreVC = [[JXMoreSelectVC alloc] initWithTitle:Localized(@"JX_AddMeToWay") dataArray:@[Localized(@"JXQR_QRImage"),Localized(@"JX_Card"),Localized(@"JX_ManyPerChat"),Localized(@"JX_MobileSearch"),Localized(@"JX_NicknameSearch"),Localized(@"OTHER")]];
    self.moreVC.indexStr = self.indexStr.length > 0 ? self.indexStr : [NSString stringWithFormat:@"%@",[self.dataSorce objectForKey:@"friendFromList"]];
    self.moreVC.delegate = self;
    [self.view addSubview:self.moreVC.view];
}

- (void)didSureBtn:(JXMoreSelectVC *)moreSelectVC indexStr:(NSString *)indexStr {
    self.indexStr = indexStr; // 记录一下历史选项
    self.addMeTypeLab.text = [self getaddMeTypeText:indexStr];
    [g_server changeFriendSetting:nil allowAtt:nil allowGreet:nil key:@"friendFromList" value:indexStr toView:self];
}

- (NSString *)getPickerContentWithDay:(double)day{
    NSString *str;
    if (day == -2) {
        str = _pickerArr[0];
        
    }else if (day == 0 || day == -1) {
        str = _pickerArr[7];
        
    }else if (day == 0.04) {
        str = _pickerArr[1];
        
    }else if (day == 1) {
        str = _pickerArr[2];
        
    }else if (day == 7) {
        str = _pickerArr[3];
        
    }else if (day == 30) {
        str = _pickerArr[4];
        
    }else if (day == 90) {
        str = _pickerArr[5];
        
    }else{
        str = _pickerArr[6];
    }
    
    return str;
}

- (NSInteger)getPickerIndexWithDay:(double)day {
    NSInteger index;
    if (day == -2) {
        index = 0;
    }else if (day == 0 || day == -1) {
        index = 7;
    }else if (day == 0.04) {
        index = 1;
    }else if (day == 1) {
        index = 2;
    }else if (day == 7) {
        index = 3;
    }else if (day == 30) {
        index = 4;
    }else if (day == 90) {
        index = 5;
    }else{
        index = 6;
    }
    return index;
}

- (void)chatTimeOut:(JXImageView *)imageView {
    self.selType = Type_chatRecordTimeOut;
    double outTime = [[self.dataSorce objectForKey:@"chatRecordTimeOut"] doubleValue];
    NSInteger index = [self getPickerIndexWithDay:outTime];
    [_pickerView selectRow:index inComponent:0 animated:NO];
    _selectView.hidden = NO;
}

- (void)syncTimeLen:(JXImageView *)imageView {
    self.selType = Type_chatSyncTimeLen;
    double chatSyncTimeLen = [[self.dataSorce objectForKey:@"chatSyncTimeLen"] doubleValue];
    NSInteger index = [self getPickerIndexWithDay:chatSyncTimeLen];
    [_pickerView selectRow:index inComponent:0 animated:NO];
    _selectView.hidden = NO;
}

- (void)groupSyncTimeLen:(JXImageView *)imageView {
    self.selType = Type_groupChatSyncTimeLen;
    double groupChatSyncTimeLen = [[self.dataSorce objectForKey:@"groupChatSyncTimeLen"] doubleValue];
    NSInteger index = [self getPickerIndexWithDay:groupChatSyncTimeLen];
    [_pickerView selectRow:index inComponent:0 animated:NO];
    _selectView.hidden = NO;
}

- (void)btnAction:(UIButton *)btn {
    _selectView.hidden = YES;
    NSInteger row = [_pickerView selectedRowInComponent:0];
    
    NSString *str = [NSString stringWithFormat:@"%ld", row];
    switch (row) {
        case 0:
            str = @"-2";
            break;
        case 1:
            str = @"0.04";
            break;
        case 2:
            str = @"1";
            break;
        case 3:
            str = @"7";
            break;
        case 4:
            str = @"30";
            break;
        case 5:
            str = @"90";
            break;
        case 6:
            str = @"365";
            break;
        case 7:
            str = @"-1";
            break;
        default:
            break;
    }
    NSString *key;
    switch (self.selType) {
        case Type_chatRecordTimeOut: {
            key = @"chatRecordTimeOut";
            g_myself.chatRecordTimeOut = str;
            _timeOutLabel.text = _pickerArr[row];
        }
            break;
            
        case Type_chatSyncTimeLen: {
            key = @"chatSyncTimeLen";
            g_myself.chatSyncTimeLen = str;
            _syncTimeLenLabel.text = _pickerArr[row];
        }
            break;
            
        case Type_groupChatSyncTimeLen: {
            key = @"groupChatSyncTimeLen";
            g_myself.groupChatSyncTimeLen = str;
            _groupSyncTimeLenLabel.text = _pickerArr[row];
        }
            break;
            
        default:
            break;
    }
    
    [g_server changeFriendSetting:nil allowAtt:nil allowGreet:nil key:key value:str toView:self];
}

- (void)cancelBtnAction {
    _selectView.hidden = YES;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerArr.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerArr[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"CurrentController = %@",[self class]);
//    UIView *view = g_window.subviews.lastObject;
//    //NSLog(@"lastObject = %@",g_window.subviews.lastObject);
//    [UIView animateWithDuration:0.3 animations:^{
//        view.frame = CGRectMake(-85, 0, JX_SCREEN_WIDTH, self.view.frame.size.height);
//    }];
    [self resetViewFrame];
    
}
-(void)createHeaderView{
    int heightHeader = JX_SCREEN_TOP;
    
    UIView *  tableHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, heightHeader)];
    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, heightHeader)];
    if (THESIMPLESTYLE) {
        iv.image = [[UIImage imageNamed:@"navBarBackground"] imageWithTintColor:[UIColor whiteColor]];
    }else {
        iv.image = [g_theme themeTintImage:@"navBarBackground"];//[UIImage imageNamed:@"navBarBackground"];
    }
    iv.userInteractionEnabled = YES;
    [tableHeader addSubview:iv];
//    [iv release];
    
    JXLabel* p = [[JXLabel alloc]initWithFrame:CGRectMake(40, JX_SCREEN_TOP - 32, self_width-40*2, 16)];
    p.center = CGPointMake(tableHeader.center.x, p.center.y);
    p.backgroundColor = [UIColor clearColor];
    p.textAlignment   = NSTextAlignmentCenter;
    p.textColor       = THESIMPLESTYLE ? [UIColor blackColor] : [UIColor whiteColor];
    p.text = Localized(@"JX_PrivacySettings");
    p.userInteractionEnabled = YES;
    p.didTouch = @selector(actionTitle:);
    p.delegate = self;
    p.changeAlpha = NO;
    [tableHeader addSubview:p];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP - 46, 46, 46)];
    [btn setBackgroundImage:[UIImage imageNamed:@"title_back_black_big"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(actionQuitSet) forControlEvents:UIControlEventTouchUpInside];
//    btn.showsTouchWhenHighlighted = YES;
    [tableHeader addSubview:btn];

    [self.view addSubview:tableHeader];
}

-(JXImageView*)createButtonWithFrame:(CGRect)frame title:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom must:(BOOL)must click:(SEL)click superView:(UIView *)superView{
    JXImageView* btn = [[JXImageView alloc] init];
    btn.frame = frame;
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    if(click)
        btn.didTouch = click;
    else
        btn.didTouch = @selector(hideKeyboard);
    btn.delegate = self;
    [superView addSubview:btn];
    
    JXLabel* p = [[JXLabel alloc] init];
    p.text = title;
    p.font = [UIFont boldSystemFontOfSize:16];
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    [btn addSubview:p];
    
    if(must){
        p.frame = CGRectMake(15, 14, JX_SCREEN_WIDTH-15*2-7, 20);
    }else {
        p.frame = CGRectMake(15, (HEIGHT-20)/2, JX_SCREEN_WIDTH-15*2-7, 20);
    }
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(15,0,JX_SCREEN_WIDTH-15,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(15,frame.size.height-LINE_WH,JX_SCREEN_WIDTH-15,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15-7, (HEIGHT-13)/2, 7, 13)];
        iv.image = [UIImage imageNamed:@"new_icon_>"];
        [btn addSubview:iv];
        if (must) {
            iv.frame = CGRectMake(JX_SCREEN_WIDTH-15-6, (68-12)/2, 6, 12);
        }
    }
    return btn;
}

-(void)actionQuitSet{
    [_wait stop];
    [g_server stopConnection:self];
    
    [g_navigation dismissViewController:self animated:YES];
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [UIView beginAnimations:nil context:context];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIView setAnimationDuration:0.2];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(actionQuit)];
//    
//    self.view.frame = CGRectMake (JX_SCREEN_WIDTH, 0, self_width, self.view.frame.size.height);
//    UIView *view = g_window.subviews[g_window.subviews.count - 2];
//    view.frame = CGRectMake (0, 0, self_width, self.view.frame.size.height);
//    
//    [UIView commitAnimations];
}
-(void)actionQuit{
    [self.view removeFromSuperview];
    _pSelf = nil;
}

////获取设置状态
//- (void)getData{
//    
//    [g_server getFriendSettings:[NSString stringWithFormat:@"%ld",g_server.user_id] toView:self];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onSettings:(UISwitch *)switchButton{
//    if (switchButton.isOn) {
////        if (switchButton.tag == 0) {//
////            self.att = @"1";
////        }else if (switchButton.tag == 1){//
////            self.greet = @"1";
////        }else
//            if (switchButton.tag == 0){
//            self.friends = @"1";
//        }else if (switchButton.tag == 1){
//            self.isEncrypt = YES;
//            g_xmpp.isEncryptAll = YES;
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMESSAGE_isEncrypt];
//
//        }
//    }else{
////        if (switchButton.tag == 0) {//
////            self.att = @"0";
////        }else if (switchButton.tag == 1){//
////            self.greet = @"0";
////        }else
//            if (switchButton.tag == 0){
//            self.friends = @"0";
//        }else if (switchButton.tag == 1){
//            self.isEncrypt = NO;
//            g_xmpp.isEncryptAll = NO;
//            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kMESSAGE_isEncrypt];
//        }
//    }
    int row = 0;
    if (switchButton.tag == row) {
        self.friends = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
        g_myself.friendsVerify = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
        [g_server changeFriendSetting:self.friends allowAtt:self.att allowGreet:self.greet key:nil value:nil toView:self];
    }
    if ([g_config.isOpenPositionService intValue] == 0) {
        row += 1;
        if (switchButton.tag == row) { // 允许其他人查看我的位置
            g_myself.isOpenPrivacyPosition = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
            [g_server changeFriendSetting:nil allowAtt:nil allowGreet:nil key:@"isOpenPrivacyPosition" value:g_myself.isOpenPrivacyPosition toView:self];
        }
    }
    row += 1;
    if (switchButton.tag == row) { // 允许手机号搜索我
        g_myself.phoneSearch = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
        [g_server changeFriendSetting:nil allowAtt:nil allowGreet:nil key:@"phoneSearch" value:g_myself.phoneSearch toView:self];
    }
    row += 1;
    if (switchButton.tag == row) {// 允许昵称搜索我
        g_myself.nameSearch = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
        [g_server changeFriendSetting:nil allowAtt:nil allowGreet:nil key:@"nameSearch" value:g_myself.nameSearch toView:self];
    }

    row += 1;
    if (switchButton.tag == row) {
        g_myself.isTyping = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
        [g_server changeFriendSetting:nil allowAtt:nil allowGreet:nil key:@"isTyping" value:g_myself.isTyping toView:self];
//        [g_default setBool:switchButton.isOn forKey:kStartEnteringStatus];
//        [g_default synchronize];
    }
    row += 1;
    if (switchButton.tag == row) {//是否振动
        g_myself.isVibration = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
        [g_server changeFriendSetting:nil allowAtt:nil allowGreet:nil key:@"isVibration" value:g_myself.isVibration toView:self];
//        [g_default setBool:switchButton.isOn forKey:kMsgComeVibration];
//        [g_default synchronize];
    }
    row += 1;
    if (switchButton.tag == row) {//是否多点登录
        g_myself.multipleDevices = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
        [g_server changeFriendSetting:nil allowAtt:nil allowGreet:nil key:@"multipleDevices" value:g_myself.multipleDevices toView:self];
        
//        [g_default setBool:switchButton.isOn forKey:kISMultipleLogin];
//        [g_default synchronize];
//        if (switchButton.isOn) {
//            g_myself.isMultipleLogin = [NSNumber numberWithLong:1];
//        }else {
//
//            g_myself.isMultipleLogin = [NSNumber numberWithLong:0];
//        }
    }
    if ([g_config.isOpenAuthSwitch intValue] == 1) {
        row += 1;
        if (switchButton.tag == row){//新设备登录是否需要授权
            g_myself.authSwitch = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
            [g_server changeFriendSetting:nil allowAtt:nil allowGreet:nil key:@"authSwitch" value:g_myself.authSwitch toView:self];
        }
    }
    row += 1;
    if (switchButton.tag == row){//侧滑是否删除服务器记录
        g_myself.isSkidRemoveHistoryMsg = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
        [g_server changeFriendSetting:nil allowAtt:nil allowGreet:nil key:@"isSkidRemoveHistoryMsg" value:g_myself.isSkidRemoveHistoryMsg toView:self];
    }
    row += 1;
    if (switchButton.tag == row){//显示消息阅读状态
        g_myself.isShowMsgState = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
        [g_server changeFriendSetting:nil allowAtt:nil allowGreet:nil key:@"isShowMsgState" value:g_myself.isShowMsgState toView:self];
    }
    
    //else if (switchButton.tag == 7) {//是否使用Google地图
//
//        g_myself.isUseGoogleMap = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
//        [g_server changeFriendSetting:nil allowAtt:nil allowGreet:nil key:@"isUseGoogleMap" value:g_myself.isUseGoogleMap toView:self];
//
////            BOOL isShowGooMap = NO;
////            if (switchButton.isOn) {
////                isShowGooMap = YES;
////            }else {
////                isShowGooMap = NO;
////            }
////            [g_default setBool:isShowGooMap forKey:kUseGoogleMap];
//
//    }
//    else{
//       [g_server changeFriendSetting:self.friends allowAtt:self.att allowGreet:self.greet key:nil value:nil toView:self];
//    }
    
}

#pragma mark － tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int number = 10;
    if ([g_config.isOpenPositionService intValue] == 1) {
        number -= 1;
    }
    if ([g_config.isOpenAuthSwitch intValue] == 0) {
        number -= 1;
    }
    
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    JXSettingsCell * cell = [tableView dequeueReusableCellWithIdentifier:@"JXSC"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"JXSettingsCell" owner:self options:nil][0];
        
        cell.mySwitch = [[UISwitch alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH -70, 10, 0, 0)];
        
        [cell.mySwitch addTarget:self action:@selector(onSettings:) forControlEvents:UIControlEventValueChanged];

        cell.mySwitch.tag = indexPath.row;
        cell.mySwitch.onTintColor = THEMECOLOR;
        cell.inTableView = self;
        
        [cell addSubview:cell.mySwitch];
        int number = 10;
        if ([g_config.isOpenPositionService intValue] == 1) {
            number -= 1;
        }
        if ([g_config.isOpenAuthSwitch intValue] == 0) {
            number -= 1;
        }
        if (indexPath.row != number-1) {
            cell.line = [[UIView alloc] initWithFrame:CGRectMake(15, 56-LINE_WH, JX_SCREEN_WIDTH-15, LINE_WH)];
            cell.line.backgroundColor = THE_LINE_COLOR;
            [cell addSubview:cell.line];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //从服务器获取数据后，改变switch的状态
//    if (indexPath.row == 0) {
//        cell.myLabel.text = Localized(@"JXSettings_AllowFollow");
//        if([[self.dataSorce objectForKey:@"allowAtt"] integerValue] == 1){
//
//            cell.mySwitch.on = YES;
//        }else{
//
//            cell.mySwitch.on = NO;
//        }
//        
//    }else if(indexPath.row == 1){
//        cell.myLabel.text = Localized(@"JXSettings_AllowSayHi");
//        if([[self.dataSorce objectForKey:@"allowGreet"] integerValue] == 1){
//
//            cell.mySwitch.on = YES;
//        }else{
//
//            cell.mySwitch.on = NO;
//        }
//    }else
    int row = 0;
    if(indexPath.row == row){
        cell.myLabel.text = Localized(@"JXSettings_FirendVerify");
        if([[self.dataSorce objectForKey:@"friendsVerify"] integerValue] == 1){

            cell.mySwitch.on = YES;
        }else{

            cell.mySwitch.on = NO;
        }
    }
    if ([g_config.isOpenPositionService intValue] == 0) {
        row += 1;
        if(indexPath.row == row){
            cell.myLabel.text = Localized(@"JX_AllowOthersSeeMyLocation");
            if([[self.dataSorce objectForKey:@"isOpenPrivacyPosition"] integerValue] == 1){
                
                cell.mySwitch.on = YES;
            }else{
                
                cell.mySwitch.on = NO;
            }
        }
    }
    row += 1;
    if(indexPath.row == row){
        cell.myLabel.text = Localized(@"JX_AllowMeToSearchByNO.");
        if([[self.dataSorce objectForKey:@"phoneSearch"] integerValue] == 1){
            
            cell.mySwitch.on = YES;
        }else{
            
            cell.mySwitch.on = NO;
        }
    }
    row += 1;
    if(indexPath.row == row){
        cell.myLabel.text = Localized(@"JX_AllowMeToSearchByNickname");
        if([[self.dataSorce objectForKey:@"nameSearch"] integerValue] == 1){
            
            cell.mySwitch.on = YES;
        }else{
            
            cell.mySwitch.on = NO;
        }
    }

    row += 1;
    if(indexPath.row == row){
        cell.myLabel.text = Localized(@"JX_StartEntering");
        if([[self.dataSorce objectForKey:@"isTyping"] integerValue] == 1){
            
            cell.mySwitch.on = YES;
        }else{
            
            cell.mySwitch.on = NO;
        }
    }
    row += 1;
    if(indexPath.row == row){
        cell.myLabel.text = Localized(@"JX_Vibration");
        if([[self.dataSorce objectForKey:@"isVibration"] integerValue] == 1){
            
            cell.mySwitch.on = YES;
        }else{
            
            cell.mySwitch.on = NO;
        }
    }
    row += 1;
    if(indexPath.row == row){
        cell.myLabel.text = Localized(@"JX_OpenMultipointLogin");
        if([[self.dataSorce objectForKey:@"multipleDevices"] integerValue] == 1){
            
            cell.mySwitch.on = YES;
        }else{
            
            cell.mySwitch.on = NO;
        }
    }
    if ([g_config.isOpenAuthSwitch intValue] == 1) {
        row += 1;
        if(indexPath.row == row){
            cell.myLabel.text = Localized(@"JX_LoginRequiresDeviceAuthorization");
            if ([[self.dataSorce objectForKey:@"authSwitch"] integerValue] == 1) {
                cell.mySwitch.on = YES;
            }else{
                cell.mySwitch.on = NO;
            }
        }
    }
    row += 1;
    if(indexPath.row == row){
        cell.myLabel.text = Localized(@"JX_HomepageDelChatHistory");
        if ([[self.dataSorce objectForKey:@"isSkidRemoveHistoryMsg"] integerValue] == 1) {
            cell.mySwitch.on = YES;
        }else{
            cell.mySwitch.on = NO;
        }
    }
    row += 1;
    if(indexPath.row == row){
        cell.myLabel.text = Localized(@"JX_ShowMsgReadStatus");
        if ([[self.dataSorce objectForKey:@"isShowMsgState"] integerValue] == 1) {
            cell.mySwitch.on = YES;
        }else{
            cell.mySwitch.on = NO;
        }
    }
//    else if(indexPath.row == 7){
//        cell.myLabel.text = Localized(@"JX_UseGoogleMap");
//        if([[self.dataSorce objectForKey:@"isUseGoogleMap"] integerValue] == 1){
//            
//            cell.mySwitch.on = YES;
//        }else{
//            
//            cell.mySwitch.on = NO;
//        }
//    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}

- (void)changeSettingsNum{
    if([[self.dataSorce objectForKey:@"allowAtt"] integerValue] == 1){
        self.att = @"1";
    }else{
        self.att = @"0";
    }
    
    if([[self.dataSorce objectForKey:@"allowGreet"] integerValue] == 1){
        self.greet = @"1";
    }else{
        self.greet = @"0";
    }

    if([[self.dataSorce objectForKey:@"friendsVerify"] integerValue] == 1){
        self.friends = @"1";
    }else{
        self.friends = @"0";
    }
    if ([[self.dataSorce objectForKey:@"isEncrypt"] integerValue] == 1) {
        self.isEncrypt = YES;
    }else{
        self.isEncrypt = NO;
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self doLogout];
    });
}

-(void)doLogout{
    JXUserObject *user = [JXUserObject sharedInstance];
    [g_server logout:user.areaCode toView:self];
    
}


-(void)relogin{
    
    g_server.access_token = nil;
    
    [g_notify postNotificationName:kSystemLogoutNotifaction object:nil];
    [[JXXMPP sharedInstance] logout];
    
    NSLog(@"XMPP --- jxsettingsVC");
    
    loginVC* vc = [loginVC alloc];
    vc.isAutoLogin = NO;
    vc.isSwitchUser= NO;
    vc = [vc init];
    [g_mainVC.view removeFromSuperview];
    g_mainVC = nil;
    [self.view removeFromSuperview];
    self.view = nil;
    
    g_navigation.rootViewController = vc;
    [_wait stop];
#if TAR_IM
#ifdef Meeting_Version
    [g_meeting stopMeeting];
#endif
#endif
}

#pragma  mark - 返回数据

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    if ([aDownload.action isEqualToString:act_SettingsUpdate]) {//更改了好友验证
        
        self.dataSorce = [dict objectForKey:@"settings"];
        
        [self changeSettingsNum];
        
        
    }
    if ([aDownload.action isEqualToString:act_UserUpdate]) {
        [g_App showAlert:Localized(@"JX_ModifiedMultipointLogonNeedsToBeLoggedIn") delegate:self tag:3333 onlyConfirm:YES];
    }
    
    if( [aDownload.action isEqualToString:act_UserLogout] ){

        [self relogin];
    }
    if ([aDownload.action isEqualToString:act_Settings]){
//        [g_server showMsg:@"其他端修改了隐私设置，已更新"];
        self.dataSorce = dict;
        [self getData];
    }
}



-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    if( [aDownload.action isEqualToString:act_UserLogout] ){
        [self performSelector:@selector(doSwitch) withObject:nil afterDelay:1];
    }
    return hide_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
//    [_myTableView release];
//    [_myView release];
//    [super dealloc];
    [g_notify removeObserver:self];
}
//归位
- (void)resetViewFrame{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, self.view.frame.size.height);
    }];
}
@end
