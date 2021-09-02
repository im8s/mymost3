//
//  JXChatSettingVC.m
//  shiku_im
//
//  Created by p on 2018/5/19.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXChatSettingVC.h"
#import "JXUserInfoVC.h"
#import "JXSelFriendVC.h"
#import "JXSetChatBackgroundVC.h"
#import "JXInputValueVC.h"
#import "JXSearchChatLogVC.h"
#import "JXLabelObject.h"
#import "JXSetLabelVC.h"
#import "JXSelectFriendsVC.h"
#import "JXTransferRecordTableVC.h"
#import "JXSetNoteAndLabelVC.h"

@interface JXChatSettingVC () <UIPickerViewDelegate,UIAlertViewDelegate,JXActionSheetVCDelegate>
@property (nonatomic, strong) JXImageView *head;
@property (nonatomic, strong) UILabel *userName;
@property (nonatomic, strong) UILabel *userDesc;

@property (nonatomic, strong) JXLabel *remarksLabel;
@property (nonatomic, strong) JXLabel *encryptLabel;
@property (nonatomic, strong) JXLabel *chatRecordTimeOutLabel;
@property (nonatomic, strong) JXLabel *labelLabel;
@property (nonatomic, strong) UISwitch *messageFreeSwitch;
@property (nonatomic, strong) UISwitch *chatTopSwitch;
@property (nonatomic, strong) UISwitch *readDeleteSwitch;

@property (nonatomic, assign) BOOL isMsgFree;
@property (nonatomic, assign) BOOL isChatTop;
@property (nonatomic, assign) BOOL isReadDel;

@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *pickerArr;

@property (nonatomic, strong) UILabel *describe;
@property (nonatomic, assign) BOOL isOtherUpdate;

@property (nonatomic, strong) NSArray *encryptTitles;
@property (nonatomic, assign) NSInteger encryptIndex;

@end

#define HEIGHT 55
@implementation JXChatSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack = YES;
    [self createHeadAndFoot];
    self.tableBody.backgroundColor = HEXCOLOR(0xF2F2F2);
    self.title = Localized(@"JX_ChatSettings");
    
    
    _pickerArr = @[Localized(@"JX_Forever"), Localized(@"JX_OneHour"), Localized(@"JX_OneDay"), Localized(@"JX_OneWeeks"), Localized(@"JX_OneMonth"), Localized(@"JX_OneQuarter"), Localized(@"JX_OneYear")];
    
    int h=0;
    int w=JX_SCREEN_WIDTH;
    
    [g_notify addObserver:self selector:@selector(actionQuitChatVC:) name:kActionRelayQuitVC object:nil];
    [g_notify addObserver:self selector:@selector(updateChatSetting) name:kXMPPMessageUpadteUserInfoNotification object:nil];
    [g_notify addObserver:self selector:@selector(updateChatSetting) name:kOfflineOperationUpdateUserSet object:nil];
    
    
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 0)];
    baseView.backgroundColor = HEXCOLOR(0xF2F2F2);
    [self.tableBody addSubview:baseView];
    
    float marginHei = 10;
    
    JXImageView* iv;
    iv = [self createHeadButtonclick:nil];
    iv.frame = CGRectMake(0, h, w, 90);
    h+=iv.frame.size.height + marginHei;
    
//    iv = [self createRoomButtonClick:@selector(createRoom)];
//    iv.frame = CGRectMake(0, h, w, HEIGHT);
//    h += iv.frame.size.height + marginHei;
    if ([self.user.userId intValue]>10100 || [self.user.userId intValue]<10000) {
        
        iv = [self createButton:_user.describe.length > 0 ? Localized(@"JX_UserInfoDescribe") : Localized(@"JX_MemoName") drawTop:NO drawBottom:YES icon:nil click:@selector(setLabel)];
        iv.frame = CGRectMake(0,h, w, HEIGHT);
        h+=iv.frame.size.height;
        _remarksLabel = [self createLabel:iv default:_user.describe.length > 0 ? _user.describe : _user.remarkName isClick:YES];
        
        iv = [self createButton:Localized(@"JX_Label") drawTop:NO drawBottom:NO icon:nil click:@selector(setLabel)];
        iv.frame = CGRectMake(0,h, w, HEIGHT);
        h+=iv.frame.size.height + marginHei;
        NSMutableArray *array = [[JXLabelObject sharedInstance] fetchLabelsWithUserId:self.user.userId];
        NSMutableString *labelsName = [NSMutableString string];
        for (NSInteger i = 0; i < array.count; i ++) {
            JXLabelObject *labelObj = array[i];
            if (i == 0) {
                [labelsName appendString:labelObj.groupName];
            }else {
                [labelsName appendFormat:@",%@",labelObj.groupName];
            }
        }
        _labelLabel = [self createLabel:iv default:labelsName isClick:YES];
        _labelLabel.textColor = HEXCOLOR(0x999999);
    }
    
    iv = [self createButton:Localized(@"JX_LookupChatRecords") drawTop:NO drawBottom:NO icon:nil click:@selector(searchChatLog)];
    iv.frame = CGRectMake(0,h, w, HEIGHT);

    if ([g_config.enablePayModule boolValue]) {
        h+=iv.frame.size.height;

        iv = [self createButton:Localized(@"JX_ViewTransferRecords") drawTop:YES drawBottom:NO icon:nil click:@selector(checkTransfer)];
        iv.frame = CGRectMake(0,h, w, HEIGHT);
    }
    h+=iv.frame.size.height + marginHei;

    
    iv = [self createButton:Localized(@"JX_ReadDelete") drawTop:NO drawBottom:NO icon:nil click:nil];
    iv.frame = CGRectMake(0,h, w, HEIGHT);
    h+=iv.frame.size.height;
    _readDeleteSwitch = [self createSwitch:iv defaule:[self.user.isOpenReadDel intValue] == 1 click:@selector(readDelAction:)];
    
    iv = [self createButton:Localized(@"JX_ChatAtTheTop") drawTop:YES drawBottom:NO icon:nil click:nil];
    iv.frame = CGRectMake(0,h, w, HEIGHT);
    h+=iv.frame.size.height;
    _chatTopSwitch = [self createSwitch:iv defaule:[self.user.topTime timeIntervalSince1970] > 0 click:@selector(topChatAction:)];
    
    iv = [self createButton:Localized(@"JX_MessageFree") drawTop:YES drawBottom:NO icon:nil click:nil];
    iv.frame = CGRectMake(0,h, w, HEIGHT);
    h+=iv.frame.size.height + marginHei;

    _messageFreeSwitch = [self createSwitch:iv defaule:[self.user.offlineNoPushMsg intValue] == 1 click:@selector(messageFreeAction:)];
    
//#ifdef IS_MsgEncrypt
    iv = [self createButton:Localized(@"JX_MsgTransmissionMethod") drawTop:NO drawBottom:NO icon:nil click:@selector(encryptAction:)];
    iv.frame = CGRectMake(0,h, w, HEIGHT);
    h+=iv.frame.size.height + marginHei;
#ifdef IS_MsgEncrypt
    if ([g_config.isOpenSecureChat boolValue]) {
        if (!self.encryptTitles) {
            if (!g_msgUtil.dhPrivateKey || !self.user.publicKeyRSARoom || self.user.publicKeyRSARoom.length <= 0) {
                self.encryptTitles = @[Localized(@"JX_Message3DES"),Localized(@"JX_MessageClear")];
            }else {
                self.encryptTitles = @[Localized(@"JX_MessageEnd-to-end"), Localized(@"JX_MessageAES"), Localized(@"JX_Message3DES"),Localized(@"JX_MessageClear")];
            }
        }
    }else {
        if (!self.encryptTitles) {
            self.encryptTitles = @[Localized(@"JX_Message3DES"),Localized(@"JX_MessageClear")];
        }
    }
#else
    if (!self.encryptTitles) {
        self.encryptTitles = @[Localized(@"JX_Message3DES"),Localized(@"JX_MessageClear")];
    }
#endif
    if ([self.user.encryptType integerValue] > (self.encryptTitles.count - 1)) {
        
        NSInteger index = self.encryptTitles.count - 1;
        self.encryptLabel.text = self.encryptTitles[index];
        self.encryptIndex = self.encryptTitles.count - index - 1;
        [g_server friendsModifyEncryptType:[NSNumber numberWithInteger:self.encryptIndex] toUserId:self.user.userId toView:self];
        _encryptLabel = [self createLabel:iv default:self.encryptTitles[0] isClick:YES];
    }else {
        _encryptLabel = [self createLabel:iv default:self.encryptTitles[self.encryptTitles.count -[self.user.encryptType integerValue] - 1] isClick:YES];
    }
//#endif
    
    iv = [self createButton:Localized(@"JX_ChatBackground") drawTop:NO drawBottom:NO icon:nil click:@selector(chatBackGroundImage)];
    iv.frame = CGRectMake(0,h, w, HEIGHT);
    h+=iv.frame.size.height + marginHei;
    
    iv = [self createButton:Localized(@"JX_MessageAutoDestroyed") drawTop:NO drawBottom:YES icon:nil click:@selector(chatRecordTimeOutAction)];
    iv.frame = CGRectMake(0,h, w, HEIGHT);
    h+=iv.frame.size.height;
    
    _chatRecordTimeOutLabel = [self createLabel:iv default:[self setChatRecordTimeOutLabelText] isClick:YES];
    
    iv = [self createButton:Localized(@"JX_EmptyChatRecords") drawTop:NO drawBottom:YES icon:nil click:@selector(cleanMessageLog)];
    iv.frame = CGRectMake(0,h, w, HEIGHT);
    h+=iv.frame.size.height;
    
    iv = [self createButton:Localized(@"JX_DelMsgTwoSides") drawTop:NO drawBottom:NO icon:nil click:@selector(cleanTwoSidesMessageLog)];
    iv.frame = CGRectMake(0,h, w, HEIGHT);
    h+=iv.frame.size.height;

    CGRect frame = baseView.frame;
    frame.size.height = h;
    baseView.frame = frame;
    
    if ((h + HEIGHT + 20) > self.tableBody.frame.size.height) {
        self.tableBody.contentSize = CGSizeMake(self_width, h + HEIGHT + 20);
    }
    
    [g_server getUser:self.user.userId toView:self];
    
    [self createPickerView];
}

- (NSString *)setChatRecordTimeOutLabelText {
    double outTime = [self.user.chatRecordTimeOut doubleValue];
    NSString *str;
    if (outTime <= 0) {
        str = _pickerArr[0];
    }else if (outTime == 0.04) {
        str = _pickerArr[1];
    }else if (outTime == 1) {
        str = _pickerArr[2];
    }else if (outTime == 7) {
        str = _pickerArr[3];
    }else if (outTime == 30) {
        str = _pickerArr[4];
    }else if (outTime == 90) {
        str = _pickerArr[5];
    }else{
        str = _pickerArr[6];
    }
    return str;
}

- (void)updateChatSetting {
    self.isOtherUpdate = YES;
    [g_server getUser:self.user.userId toView:self];
}

- (void)createPickerView {
    _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 220, JX_SCREEN_WIDTH, 220)];
    _selectView.backgroundColor = HEXCOLOR(0xF2F2F2);
    _selectView.hidden = YES;
    [self.view addSubview:_selectView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(_selectView.frame.size.width - 80, 20, 60, 20)];
    [btn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_selectView addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 50, 20)];
    [btn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_selectView addSubview:btn];
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, _selectView.frame.size.width, _selectView.frame.size.height - 40)];
    _pickerView.delegate = self;
    double outTime = [self.user.chatRecordTimeOut doubleValue];
    NSInteger index = 0;
    if (outTime <= 0) {
        index = 0;
    }else if (outTime == 0.04) {
        index = 1;
    }else if (outTime == 1) {
        index = 2;
    }else if (outTime == 7) {
        index = 3;
    }else if (outTime == 30) {
        index = 4;
    }else if (outTime == 90) {
        index = 5;
    }else{
        index = 6;
    }
    
    [_pickerView selectRow:index inComponent:0 animated:NO];
    [_selectView addSubview:_pickerView];
}

- (void)btnAction:(UIButton *)btn {
    _selectView.hidden = YES;
    NSInteger row = [_pickerView selectedRowInComponent:0];
    _chatRecordTimeOutLabel.text = _pickerArr[row];
    
    NSString *str = [NSString stringWithFormat:@"%ld",row];
    switch (row) {
        case 0:
            str = @"-1";
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
            
        default:
            break;
    }
    self.user.chatRecordTimeOut = str;
    [self.user updateUserChatRecordTimeOut];
    [g_server friendsUpdate:self.user.userId chatRecordTimeOut:str toView:self];
}

- (void)cancelBtnAction:(UIButton *)btn {
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

- (void)dealloc {
    [g_notify removeObserver:self];
}

- (void)checkTransfer {
    JXTransferRecordTableVC *vc = [[JXTransferRecordTableVC alloc] init];
    vc.userId = self.user.userId;
    [g_navigation pushViewController:vc animated:YES];
}

// 发起群聊
- (JXImageView *)createRoomButtonClick:(SEL)click {
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.delegate = self;
    [self.tableBody addSubview:btn];
    
    JXImageView *add = [[JXImageView alloc] initWithFrame:CGRectMake(20, 15, 20, 20)];
    add.image = [UIImage imageNamed:@"person_add"];
    [btn addSubview:add];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(add.frame) + 20, 0, 200, HEIGHT)];
    label.font = [UIFont systemFontOfSize:15.0];
    label.textColor = HEXCOLOR(0xff3db4ff);
    label.text = Localized(@"JX_LaunchGroupChat");
    [btn addSubview:label];
    
    return btn;
}

- (void)remarkAction {
    JXInputValueVC* vc = [JXInputValueVC alloc];
    vc.value = self.user.remarkName.length > 0  ? self.user.remarkName : self.user.userNickname;
    vc.title = Localized(@"JXUserInfoVC_SetName");
    vc.delegate  = self;
    vc.isLimit = YES;
    vc.didSelect = @selector(onSaveNickName:);
    vc = [vc init];
    //    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}
-(void)onSaveNickName:(JXInputValueVC*)vc{
    _remarksLabel.text = vc.value;
    self.user.remarkName = vc.value;
    [g_server setFriendName:self.user.userId noteName:vc.value describe:nil toView:self];
}

// 标签
- (void)setLabel {
    
    JXSetNoteAndLabelVC *vc = [[JXSetNoteAndLabelVC alloc] init];
    vc.title = Localized(@"JX_SetNotesAndLabels");
    vc.delegate = self;
    vc.didSelect = @selector(refreshLabel:);
    vc.user = self.user;
    [g_navigation pushViewController:vc animated:YES];
}

- (void)refreshLabel:(JXUserObject *)user {
    
    NSMutableArray *array = [[JXLabelObject sharedInstance] fetchLabelsWithUserId:self.user.userId];
    NSMutableString *labelsName = [NSMutableString string];
    for (NSInteger i = 0; i < array.count; i ++) {
        JXLabelObject *labelObj = array[i];
        if (i == 0) {
            [labelsName appendString:labelObj.groupName];
        }else {
            [labelsName appendFormat:@",%@",labelObj.groupName];
        }
    }
    _labelLabel.text = labelsName;
    
    if (user.describe.length > 0) {
        _describe.text = Localized(@"JX_UserInfoDescribe");
        _remarksLabel.text = user.describe;
    }else {
        _describe.text = Localized(@"JX_MemoName");
        _remarksLabel.text = user.remarkName;
    }
    self.user.remarkName = user.remarkName;
    self.user.describe = user.describe;
    [g_server setFriendName:self.user.userId noteName:user.remarkName describe:user.describe toView:self];

}

// 查找聊天内容
- (void)searchChatLog {
    
    JXSearchChatLogVC *vc = [[JXSearchChatLogVC alloc] init];
    vc.user = self.user;
    [g_navigation pushViewController:vc animated:YES];
}

// 阅后即焚
- (void)readDelAction:(UISwitch *)switchView {
    int readDel = switchView.isOn;
    
    self.isReadDel = YES;
    
    [g_server friendsUpdateOfflineNoPushMsgUserId:g_myself.userId toUserId:self.user.userId offlineNoPushMsg:readDel type:1 toView:self];
}

// 置顶聊天
- (void)topChatAction:(UISwitch *)switchView {
    int topChat = switchView.isOn;
    
    self.isChatTop = YES;
    
    [g_server friendsUpdateOfflineNoPushMsgUserId:g_myself.userId toUserId:self.user.userId offlineNoPushMsg:topChat  type:2 toView:self];

}

//#ifdef IS_MsgEncrypt
// 消息加密传输
- (void)encryptAction:(UIButton *)btn {
    JXActionSheetVC *actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:self.encryptTitles];
    actionVC.delegate = self;
    [self presentViewController:actionVC animated:NO completion:nil];
}

- (void)actionSheet:(JXActionSheetVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    
    self.encryptLabel.text = self.encryptTitles[index];
    self.encryptIndex = self.encryptTitles.count - index - 1;
    [g_server friendsModifyEncryptType:[NSNumber numberWithInteger:self.encryptIndex] toUserId:self.user.userId toView:self];
}

//#endif

// 消息免打扰
- (void)messageFreeAction:(UISwitch *)switchView {
    int offlineNoPushMsg = switchView.isOn;
    self.isMsgFree = YES;
    [g_server friendsUpdateOfflineNoPushMsgUserId:g_myself.userId toUserId:self.user.userId offlineNoPushMsg:offlineNoPushMsg  type:0 toView:self];
}

- (void)chatRecordTimeOutAction {
    double outTime = [self.user.chatRecordTimeOut doubleValue];
    NSInteger index = 0;
    if (outTime <= 0) {
        index = 0;
    }else if (outTime == 0.04) {
        index = 1;
    }else if (outTime == 1) {
        index = 2;
    }else if (outTime == 7) {
        index = 3;
    }else if (outTime == 30) {
        index = 4;
    }else if (outTime == 90) {
        index = 5;
    }else{
        index = 6;
    }
    [_pickerView selectRow:index inComponent:0 animated:NO];
    _selectView.hidden = NO;
}

// 清除聊天记录
- (void)cleanMessageLog {
    [g_App showAlert:Localized(@"JX_ConfirmDeleteChat") delegate:self tag:1111 onlyConfirm:NO];

}

//清空双方的聊天记录
- (void)cleanTwoSidesMessageLog {
    [g_App showAlert:Localized(@"JX_ConfirmDelMsgTwoSides?") delegate:self tag:2222 onlyConfirm:NO];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1 && (alertView.tag == 1111 || alertView.tag == 2222)) {
        if (alertView.tag == 2222) {
            JXMessageObject *msg = [[JXMessageObject alloc] init];
            msg.timeSend = [NSDate date];
            msg.type = [NSNumber numberWithInt:kWCMessageTypeDelMsgTwoSides];
            msg.fromUserId = MY_USER_ID;
            msg.toUserId = self.user.userId;
            [g_xmpp sendMessage:msg roomName:nil];
        }
        JXMessageObject *msg = [[JXMessageObject alloc] init];
        msg.toUserId = self.user.userId;
        [msg deleteAll];
        msg.type = [NSNumber numberWithInt:1];
        msg.content = @" ";
        [msg updateLastSend:UpdateLastSendType_None];
        [msg notifyMyLastSend];
        [g_server emptyMsgWithTouserId:self.user.userId type:[NSNumber numberWithInt:0] toView:self];
//        [g_notify postNotificationName:kRefreshChatLogNotif object:nil];

    }
}

-(JXImageView*)createHeadButtonclick:(SEL)click{
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.delegate = self;
    [self.tableBody addSubview:btn];
    
    _head = [[JXImageView alloc]initWithFrame:CGRectMake(20, 10, 50, 50)];
    _head.layer.cornerRadius = 5;
    _head.layer.masksToBounds = YES;
//    _head.didTouch = @selector(onHeadImage);
    _head.delegate = self;
    _head.didTouch = @selector(onResume);
    [g_server getHeadImageLarge:self.user.userId userName:self.user.userNickname imageView:_head getHeadHandler:nil];
    [btn addSubview:_head];
    //        [_head release];
    
    if ([self.user.userType intValue] != 2) {
        JXImageView *add = [[JXImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_head.frame) + 20, _head.frame.origin.y, _head.frame.size.width, _head.frame.size.height)];
        add.delegate = self;
        add.didTouch = @selector(createRoom);
        add.image = [UIImage imageNamed:@"add"];
        [btn addSubview:add];
    }
    
    //名字Label
    UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(_head.frame.origin.x, CGRectGetMaxY(_head.frame), _head.frame.size.width, 20)];
    p.font = g_factory.font13;
    p.text = g_server.myself.userNickname;
    p.textAlignment = NSTextAlignmentCenter;
    p.backgroundColor = [UIColor clearColor];
    [btn addSubview:p];
    _userName = p;
    _userName.text = self.user.remarkName.length > 0  ? self.user.remarkName : self.user.userNickname;
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15-7, (HEIGHT-13)/2, 7, 13)];
        iv.image = [UIImage imageNamed:@"new_icon_>"];
        iv.center = CGPointMake(iv.center.x, CGRectGetMidY(_head.frame));
        [btn addSubview:iv];
    }
    
//    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,90-0.5,JX_SCREEN_WIDTH,0.5)];
//    line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
//    [btn addSubview:line];

    return btn;
}

-(JXImageView*)createButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom icon:(NSString*)icon click:(SEL)click{
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.delegate = self;
    [self.tableBody addSubview:btn];
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(15, 0, JX_SCREEN_WIDTH-100, HEIGHT)];
    p.text = title;
    p.font = [UIFont boldSystemFontOfSize:16];
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    p.delegate = self;
    p.didTouch = click;
    [btn addSubview:p];
    if ([title isEqualToString:Localized(@"JX_UserInfoDescribe")] || [title isEqualToString:Localized(@"JX_MemoName")]) {
        _describe = p;
    }
    
    if(icon){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(10, (HEIGHT-20)/2, 20, 20)];
        iv.image = [UIImage imageNamed:icon];
        [btn addSubview:iv];
    }
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(15,0,JX_SCREEN_WIDTH-15,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(15,HEIGHT-LINE_WH,JX_SCREEN_WIDTH,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15-7, (HEIGHT-13)/2, 7, 13)];
        iv.image = [UIImage imageNamed:@"new_icon_>"];
        [btn addSubview:iv];
    }
    
    return btn;
}


-(JXLabel*)createLabel:(UIView*)parent default:(NSString*)s isClick:(BOOL) boo{
    JXLabel * p;
    if (boo) {
        p = [[JXLabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-120-15-7-10,INSETS,120,HEIGHT-INSETS*2)];
    }else{
        p = [[JXLabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2 ,INSETS,JX_SCREEN_WIDTH/2 - INSETS,HEIGHT-INSETS*2)];
    }
    
    p.userInteractionEnabled = NO;
    p.text = s;
    p.textColor = [UIColor lightGrayColor];
    p.font = g_factory.font15;
    p.textAlignment = NSTextAlignmentRight;
    [parent addSubview:p];
    //    [p release];
    return p;
}

- (UISwitch *)createSwitch:(UIView *)parent defaule:(BOOL)isOn click:(SEL)click {
    UISwitch *switchView = [[UISwitch alloc] init];
    switchView.frame = CGRectMake(JX_SCREEN_WIDTH -INSETS - 51, 10, 0, 0);
    [switchView addTarget:self action:click forControlEvents:UIControlEventValueChanged];
    switchView.onTintColor = THEMECOLOR;
    [switchView setOn:isOn];
    [parent addSubview:switchView];
    return switchView;
}

- (void)onResume {
    
//    [g_server getUser:self.user.userId toView:self];
    
    JXUserInfoVC* vc = [JXUserInfoVC alloc];
    vc.userId       = self.user.userId;
    vc.user = self.user;
    vc.fromAddType = 6;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)createRoom {
    if ([g_config.isCommonCreateGroup intValue] == 1) {
        [g_App showAlert:Localized(@"JX_NotCreateNewRoom")];
        return;
    }
    memberData *member = [[memberData alloc] init];
    member.userId = [g_myself.userId longLongValue];
    member.userNickName = MY_USER_NAME;
    member.role = @1;
    [_room.members addObject:member];

    JXSelectFriendsVC* vc = [JXSelectFriendsVC alloc];
//    vc.chatRoom = _chatRoom;
    vc.room = _room;
    vc.isNewRoom = YES;
    vc.isForRoom = YES;
    vc.forRoomUser = self.user;
    vc = [vc init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)actionQuitChatVC:(NSNotification *)notif {
    [self actionQuit];
}

- (void)chatBackGroundImage {
    JXSetChatBackgroundVC *vc = [[JXSetChatBackgroundVC alloc] init];
    vc.userId = self.user.userId;
    [g_navigation pushViewController:vc animated:YES];
}


//服务端返回数据
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    
//    if( [aDownload.action isEqualToString:act_UserGet] ){
//        JXUserObject* user = [[JXUserObject alloc]init];
//        [user getDataFromDict:dict];
//
//        JXUserInfoVC* vc = [JXUserInfoVC alloc];
//        vc.user       = user;
//        vc = [vc init];
//        //        [g_window addSubview:vc.view];
//        [g_navigation pushViewController:vc animated:YES];
//    }
    if( [aDownload.action isEqualToString:act_UploadFile] ){
        NSDictionary* p = nil;
        if([(NSArray *)[dict objectForKey:@"audios"] count]>0)
            p = [[dict objectForKey:@"audios"] objectAtIndex:0];
        if([(NSArray *)[dict objectForKey:@"images"] count]>0)
            p = [[dict objectForKey:@"images"] objectAtIndex:0];
        if([(NSArray *)[dict objectForKey:@"videos"] count]>0)
            p = [[dict objectForKey:@"videos"] objectAtIndex:0];
        if(p==nil)
            p = [(NSArray *)[dict objectForKey:@"others"] objectAtIndex:0];
        
        NSString* url = [p objectForKey:@"oUrl"];
        [g_constant.userBackGroundImage setObject:url forKey:self.user.userId];
        BOOL isSuccess = [g_constant.userBackGroundImage writeToFile:backImage atomically:YES];
        if (isSuccess) {
            [g_App showAlert:Localized(@"JX_SetUpSuccess")];
        }else {
            [g_App showAlert:Localized(@"JX_SettingFailure")];
        }
    }
    
    if([aDownload.action isEqualToString:act_FriendRemark]){
        [_wait stop];
        _userName.text = self.user.remarkName.length > 0  ? self.user.remarkName : self.user.userNickname;

        JXUserObject* user1 = [[JXUserObject sharedInstance] getUserById:self.user.userId];
        user1.remarkName = self.user.remarkName;
        user1.describe = self.user.describe;
        // 修改备注后实时刷新
        [g_notify postNotificationName:kFriendRemark object:user1];
        [user1 update];
        [g_App showAlert:Localized(@"JXAlert_SetOK")];
    }
    
    if([aDownload.action isEqualToString:act_friendsUpdateOfflineNoPushMsg]){
        [_wait stop];
        if (self.isMsgFree) {
            self.isMsgFree = NO;
            self.user.offlineNoPushMsg = [NSNumber numberWithBool:_messageFreeSwitch.isOn];
            [self.user updateOfflineNoPushMsg];
            [g_App showAlert:Localized(@"JXAlert_SetOK")];
        }
        else if (self.isChatTop) {
            self.isChatTop = NO;
            long long time = [[dict objectForKey:@"openTopChatTime"] longLongValue];
            self.user.topTime = [NSDate dateWithTimeIntervalSince1970:time];
            if (!_chatTopSwitch.isOn) {
                self.user.topTime = nil;
            }

            [self.user updateTopTime];
            [g_notify postNotificationName:kFriendListRefresh object:nil];
            [g_notify postNotificationName:kChatViewDisappear object:nil];
        }
        else if (self.isReadDel) {
            self.isReadDel = NO;
            if (_readDeleteSwitch.isOn) {
                [g_App showAlert:Localized(@"JX_ReadDeleteTip")];
            }
        
            self.user.isOpenReadDel = [NSNumber numberWithBool:_readDeleteSwitch.isOn];
            [self.user updateIsOpenReadDel];
            [g_notify postNotificationName:kOpenReadDelNotif object:self.user.isOpenReadDel];
        }
    }
    
    if( [aDownload.action isEqualToString:act_UserGet] ){
        [self.user getDataFromDict:dict];
        
        _remarksLabel.text = _user.describe.length > 0 ? _user.describe : _user.remarkName;
        [_readDeleteSwitch setOn:[self.user.isOpenReadDel boolValue]];
        [_chatTopSwitch setOn:[self.user.topTime timeIntervalSince1970] > 0];
        [_messageFreeSwitch setOn:[self.user.offlineNoPushMsg intValue] == 1];
        _chatRecordTimeOutLabel.text = [self setChatRecordTimeOutLabelText];
        
        [g_notify postNotificationName:kOpenReadDelNotif object:self.user.isOpenReadDel];
    }
    
    
    if( [aDownload.action isEqualToString:act_EmptyMsg] ){
        
        // 清除聊天记
        JXMessageObject *msg = [[JXMessageObject alloc] init];
        msg.isGroup = YES;
        msg.toUserId = self.user.userId;
        [msg deleteAll];
        msg.type = [NSNumber numberWithInt:1];
        msg.content = @" ";
        [msg updateLastSend:UpdateLastSendType_None];
        [msg notifyMyLastSend];
        //        [g_notify postNotificationName:kRefreshChatLogNotif object:nil];
        
        [g_notify postNotificationName:kChatVCReloadNotif object:nil];
        
        [g_App showAlert:Localized(@"JXAlert_DeleteOK")];
    }
    
    
    if ([aDownload.action isEqualToString:act_FriendsModifyEncryptType]) {
        
        self.user.encryptType = [NSNumber numberWithInteger:self.encryptIndex];
        [self.user updateEncryptType];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
