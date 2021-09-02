//
//  JXGroupManagementVC.m
//  shiku_im
//
//  Created by p on 2018/5/28.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXGroupManagementVC.h"
#import "JXRoomRemind.h"
#import "JXSelFriendVC.h"
#import "JXMsgViewController.h"
#import "JXCopyRoomVC.h"

#define HEIGHT 50
#define IMGSIZE 170
#define TAG_LABEL 1999

@interface JXGroupManagementVC ()<JXActionSheetVCDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) memberData  * currentMember;
@property (nonatomic, strong) JXImageView *GroupValidationBtn;
@property (nonatomic, strong) UISwitch *GroupValidationSwitch;
@property (nonatomic, strong) NSNumber *updateType;
@property (nonatomic, assign) BOOL isMonitorPeople;  //  YES：监控人  NO: 隐身人

@property (nonatomic, strong) JXLabel *encryptLabel;
@property (nonatomic, strong) NSArray *encryptTitles;

@property (nonatomic, assign) NSInteger encryptIndex;

@end

@implementation JXGroupManagementVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack = YES;
    self.title = Localized(@"JX_GroupManagement");
    [self createHeadAndFoot];
    self.tableBody.backgroundColor = HEXCOLOR(0xF2F2F2);
    
    int membHeight = 0;
    
    JXImageView *iv;
    UILabel *label;
    // 群主管理权转让
    iv = [self createButton:Localized(@"JX_ManagerAreTransferred") drawTop:NO drawBottom:NO must:NO click:@selector(roomTransferAction)];
    iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    membHeight = CGRectGetMaxY(iv.frame);

    // 设置管理员
    iv = [self createButton:Localized(@"JXRoomMemberVC_SetAdministrator") drawTop:YES drawBottom:NO must:NO click:@selector(specifyAdministrator)];
    iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    membHeight = CGRectGetMaxY(iv.frame);
    // 设置隐身人
//    iv = [self createButton:Localized(@"JXDesignatedStealthMan") drawTop:YES drawBottom:NO must:NO click:@selector(specifyInvisibleMan)];
//    iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
//    membHeight = CGRectGetMaxY(iv.frame);

    // 设置监控人
//    iv = [self createButton:@"指定监控人" drawTop:NO drawBottom:YES must:NO click:@selector(specifyMonitorPeople)];
//    iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
//    membHeight = CGRectGetMaxY(iv.frame) + 10;
    
    if (!self.room.isSecretGroup) {
        if (self.room.userId == [MY_USER_ID intValue]) {
            //群复制
            iv = [self createButton:Localized(@"JX_One-clickReplicationNewGroups" ) drawTop:YES drawBottom:NO must:NO click:@selector(onCopyRoom)];
            iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
            membHeight = CGRectGetMaxY(iv.frame) + 10;
        }
    }
    
#ifdef IS_MsgEncrypt
    if ([g_config.isOpenSecureChat boolValue]) {
        if (!self.room.isSecretGroup) {
            iv = [self createButton:Localized(@"JX_MsgTransmissionMethod") drawTop:NO drawBottom:NO must:NO click:@selector(encryptAction:)];
            iv.frame = CGRectMake(0,membHeight, JX_SCREEN_WIDTH, HEIGHT);
            membHeight = CGRectGetMaxY(iv.frame) + 10;
            
            if (!self.encryptTitles) {
                self.encryptTitles = @[Localized(@"JX_Message3DES"),Localized(@"JX_MessageClear")];
            }
            _encryptLabel = [self createLabel:iv default:self.encryptTitles[self.encryptTitles.count -[self.user.encryptType integerValue] - 1] isClick:YES];
        }else {
            iv = [self createButton:Localized(@"JX_ResetGroupKey") drawTop:YES drawBottom:NO must:NO click:@selector(resetKeyAction:)];
            iv.frame = CGRectMake(0,membHeight, JX_SCREEN_WIDTH, HEIGHT);
            membHeight = CGRectGetMaxY(iv.frame) + 10;
        }
    }else {
        iv = [self createButton:Localized(@"JX_MsgTransmissionMethod") drawTop:NO drawBottom:NO must:NO click:@selector(encryptAction:)];
        iv.frame = CGRectMake(0,membHeight, JX_SCREEN_WIDTH, HEIGHT);
        membHeight = CGRectGetMaxY(iv.frame) + 10;
        
        if (!self.encryptTitles) {
            self.encryptTitles = @[Localized(@"JX_Message3DES"),Localized(@"JX_MessageClear")];
        }
        _encryptLabel = [self createLabel:iv default:self.encryptTitles[self.encryptTitles.count -[self.user.encryptType integerValue] - 1] isClick:YES];
    }
#else
    iv = [self createButton:Localized(@"JX_MsgTransmissionMethod") drawTop:NO drawBottom:NO must:NO click:@selector(encryptAction:)];
    iv.frame = CGRectMake(0,membHeight, JX_SCREEN_WIDTH, HEIGHT);
    membHeight = CGRectGetMaxY(iv.frame) + 10;
    
    if (!self.encryptTitles) {
        self.encryptTitles = @[Localized(@"JX_Message3DES"),Localized(@"JX_MessageClear")];
    }
    _encryptLabel = [self createLabel:iv default:self.encryptTitles[self.encryptTitles.count -[self.user.encryptType integerValue] - 1] isClick:YES];

#endif

    if (![g_config.isOpenRoomSearch boolValue] && !self.room.isSecretGroup) {
        // 私密群组
        iv = [self createButton:Localized(@"JX_PublicGroups") drawTop:NO drawBottom:NO must:NO click:nil];
        iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
        [self createSwitchWithParent:iv tag:2457 isOn:!self.room.isLook];
        label = [self createLabelWithParent:self.tableBody frameY:CGRectGetMaxY(iv.frame) + 10 text:Localized(@"JX_CannotBeSearched")];
        membHeight = CGRectGetMaxY(label.frame) + 10;
    }
    
    // 显示已读人数
    iv = [self createButton:Localized(@"JX_RoomShowRead") drawTop:NO drawBottom:NO must:NO click:nil];
    iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    [self createSwitchWithParent:iv tag:2456 isOn:self.room.showRead];
    label = [self createLabelWithParent:self.tableBody frameY:CGRectGetMaxY(iv.frame) + 10 text:Localized(@"JX_ReadPeopleList")];
    membHeight = CGRectGetMaxY(label.frame) + 10;
    
    // 群验证
    iv = [self createButton:Localized(@"JX_GroupInvitationConfirmation") drawTop:NO drawBottom:NO must:NO click:nil];
    iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    [self createSwitchWithParent:iv tag:2458 isOn:self.room.isNeedVerify];
    label =[self createLabelWithParent:self.tableBody frameY:CGRectGetMaxY(iv.frame) + 10 text:Localized(@"JX_IntoGroupNeedManager")];
    membHeight = CGRectGetMaxY(label.frame) + 10;
    
    // 显示群成员列表
    iv = [self createButton:Localized(@"JX_DisplayGroupMemberList") drawTop:NO drawBottom:NO must:NO click:nil];
    iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    [self createSwitchWithParent:iv tag:2459 isOn:self.room.showMember];
    label =[self createLabelWithParent:self.tableBody frameY:CGRectGetMaxY(iv.frame) + 10 text:Localized(@"JX_OnlyShowManager")];
    membHeight = CGRectGetMaxY(label.frame) + 10;
    
    // 允许普通成员私聊
    iv = [self createButton:Localized(@"JX_AllowMemberChat") drawTop:NO drawBottom:NO must:NO click:nil];
    iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    [self createSwitchWithParent:iv tag:2460 isOn:self.room.allowSendCard];
    label =[self createLabelWithParent:self.tableBody frameY:CGRectGetMaxY(iv.frame) + 10 text:Localized(@"JX_ShowDefaultIcon")];
    membHeight = CGRectGetMaxY(label.frame) + 10;
    
    // 允许普通群成员邀请好友
    iv = [self createButton:Localized(@"JX_AllowInviteFriend") drawTop:NO drawBottom:NO must:NO click:nil];
    iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    [self createSwitchWithParent:iv tag:2461 isOn:self.room.allowInviteFriend];
    label =[self createLabelWithParent:self.tableBody frameY:CGRectGetMaxY(iv.frame) + 10 text:Localized(@"JX_NotInviteFunction")];
    membHeight = CGRectGetMaxY(label.frame) + 10;
    
    // 允许普通群成员上传文件
    iv = [self createButton:Localized(@"JX_AllowMemberToUpload") drawTop:NO drawBottom:NO must:NO click:nil];
    iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    [self createSwitchWithParent:iv tag:2462 isOn:self.room.allowUploadFile];
    label =[self createLabelWithParent:self.tableBody frameY:CGRectGetMaxY(iv.frame) + 10 text:Localized(@"JX_AllowMemberNotUpload")];
    membHeight = CGRectGetMaxY(label.frame) + 10;
    
    
    // 允许普通群成员召开会议
    iv = [self createButton:Localized(@"JX_InitiateMeeting") drawTop:NO drawBottom:NO must:NO click:nil];
    iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    [self createSwitchWithParent:iv tag:2463 isOn:self.room.allowConference];
    label =[self createLabelWithParent:self.tableBody frameY:CGRectGetMaxY(iv.frame) + 10 text:Localized(@"JX_NotInitiateMeeting")];
    membHeight = CGRectGetMaxY(label.frame) + 10;
    
    // 允许普通群成员发起讲课
    iv = [self createButton:Localized(@"JX_InitiateLectures") drawTop:NO drawBottom:NO must:NO click:nil];
    iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    [self createSwitchWithParent:iv tag:2464 isOn:self.room.allowSpeakCourse];
    label =[self createLabelWithParent:self.tableBody frameY:CGRectGetMaxY(iv.frame) + 10 text:Localized(@"JX_NotInitiateLectures")];
    membHeight = CGRectGetMaxY(label.frame) + 10;
    
    
    // 群组减员发送通知
    iv = [self createButton:Localized(@"JX_GroupReduction") drawTop:NO drawBottom:NO must:NO click:nil];
    iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    [self createSwitchWithParent:iv tag:2465 isOn:self.room.isAttritionNotice];
    label =[self createLabelWithParent:self.tableBody frameY:CGRectGetMaxY(iv.frame) + 10 text:Localized(@"JX_NotGroupReduction")];
    membHeight = CGRectGetMaxY(label.frame) + 10;
    
    self.tableBody.contentSize = CGSizeMake(0, CGRectGetMaxY(label.frame) + 10);
    
}


- (void)onCopyRoom {
    JXCopyRoomVC *vc = [[JXCopyRoomVC alloc] init];
    vc.room = self.room;
    [g_navigation pushViewController:vc animated:YES];
}


-(JXImageView*)createButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom must:(BOOL)must click:(SEL)click{
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    if(click)
        btn.didTouch = click;
    else
        btn.didTouch = @selector(hideKeyboard);
    btn.delegate = self;
    [self.tableBody addSubview:btn];
    
    if(must){
        UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, 5, 20, HEIGHT-5)];
        p.text = @"*";
        p.font = g_factory.font18;
        p.backgroundColor = [UIColor clearColor];
        p.textColor = [UIColor redColor];
        p.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:p];
    }

    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(15, 0, JX_SCREEN_WIDTH-51-15*2, HEIGHT)];
    p.text = title;
    p.font = [UIFont boldSystemFontOfSize:15];
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    
    [btn addSubview:p];
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(15,0,JX_SCREEN_WIDTH-15,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(15,HEIGHT-LINE_WH,JX_SCREEN_WIDTH-15,LINE_WH)];
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

- (UISwitch *)createSwitchWithParent:(UIView *)parent tag:(NSInteger)tag isOn:(BOOL)isOn{
    UISwitch *switchView = [[UISwitch alloc] init];
    switchView.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-51,0,0,0);
    switchView.center = CGPointMake(switchView.center.x, parent.frame.size.height/2);
    switchView.tag = tag;
    switchView.on = isOn;
    switchView.onTintColor = THEMECOLOR;
    [switchView addTarget:self action:@selector(switchViewAction:) forControlEvents:UIControlEventValueChanged];
    [parent addSubview:switchView];
    
    return switchView;
}

- (UILabel *)createLabelWithParent:(UIView *)parent frameY:(CGFloat)framey text:(NSString *)text {
    CGSize size = [text boundingRectWithSize:CGSizeMake(JX_SCREEN_WIDTH - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0]} context:nil].size;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, framey, JX_SCREEN_WIDTH - 20, size.height)];
    label.font = [UIFont systemFontOfSize:13.0];
    label.textColor = [UIColor lightGrayColor];
    label.numberOfLines = 0;
    label.text = text;
    [parent addSubview:label];
    
    return label;
}

-(JXLabel*)createLabel:(UIView*)parent default:(NSString*)s isClick:(BOOL) boo{
    JXLabel * p;
    if (boo) {
        p = [[JXLabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15-7-120,INSETS,110,HEIGHT-INSETS*2)];
    }else{
        p = [[JXLabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2 ,INSETS,JX_SCREEN_WIDTH/2 - INSETS,HEIGHT-INSETS*2)];
    }
    
    p.userInteractionEnabled = NO;
    p.text = s;
    p.textColor = HEXCOLOR(0x999999);
    p.font = g_factory.font16;
    p.textAlignment = NSTextAlignmentRight;
    [parent addSubview:p];
    
    return p;
}


//#ifdef IS_MsgEncrypt

// 消息加密传输
- (void)encryptAction:(UIButton *)btn {
    JXActionSheetVC *actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:self.encryptTitles];
    actionVC.delegate = self;
    [self presentViewController:actionVC animated:NO completion:nil];
}


- (void)resetKeyAction:(UIButton *)btn {
    [g_App showAlert:Localized(@"JX_ResetRoomKey,ChatHistoryDel") delegate:self tag:2457 onlyConfirm:NO];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

#ifdef IS_MsgEncrypt
    if ([g_config.isOpenSecureChat boolValue]) {
        if (alertView.tag == 2457) {
            if (buttonIndex == 1) {
                
                NSString *g = [NSUUID UUID].UUIDString;
                g = [[g stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
                _room.chatKeyGroup = g;
                self.user.chatKeyGroup = [g_msgUtil encryptRoomMsgKey:_room.roomId randomKey:_room.chatKeyGroup];
                [self.user updateChatKeyGroup];
                self.user.isLostChatKeyGroup = [NSNumber numberWithBool:NO];
                [self.user updateLostChatKeyGroup];
                
                [g_server roomGetAllMemberRsaPublicKeyWithRoomId:self.room.roomId toView:self];
            }
        }
    }
#endif
}


- (void)actionSheet:(JXActionSheetVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    
    self.encryptLabel.text = self.encryptTitles[index];
    self.encryptIndex = self.encryptTitles.count - index - 1;
    [g_server roomUpdateEncryptType:[NSNumber numberWithInteger:self.encryptIndex] roomId:self.room.roomId toView:self];
}

//#endif

// 设置管理员
-(void)specifyAdministrator{
    [self setManagerWithType:JXSelUserTypeSpecifyAdmin];
}
//设置隐身人
- (void)specifyInvisibleMan {
    [self setManagerWithType:JXSelUserTypeRoomInvisibleMan];
}

// 设置监控人
- (void)specifyMonitorPeople {
    [self setManagerWithType:JXSelUserTypeRoomMonitorPeople];
}

- (void)setManagerWithType:(JXSelUserType)type {
    memberData *data = [self.room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"JXRoomMemberVC_NotGroupMarsterCannotDoThis")];
        return;
    }
    
    JXSelFriendVC * selVC = [[JXSelFriendVC alloc] init];
    selVC.type = type;
    selVC.room = self.room;
    selVC.delegate = self;
    if (type == JXSelUserTypeSpecifyAdmin) {
        selVC.didSelect = @selector(specifyAdministratorDelegate:);
    }else if(type == JXSelUserTypeRoomInvisibleMan) {
        selVC.didSelect = @selector(specifyInvisibleManDelegate:);
    }else {
        selVC.didSelect = @selector(specifyMonitorPeopleDelegate:);
    }
    [g_navigation pushViewController:selVC animated:YES];
}

// 群主转让
- (void)roomTransferAction {
    JXSelFriendVC * selVC = [[JXSelFriendVC alloc] init];
    selVC.room = _room;
    selVC.type = JXSelUserTypeRoomTransfer;
    selVC.delegate = self;
    selVC.didSelect = @selector(atSelectMemberDelegate:);

    [g_navigation pushViewController:selVC animated:YES];
}

-(void)atSelectMemberDelegate:(memberData *)member{
    _currentMember = member;
    [g_server roomTransfer:_room.roomId toUserId:[NSString stringWithFormat:@"%ld",member.userId] toView:self];
    
    // 更新数据库
    JXUserObject *user = [[JXUserObject alloc] init];
    user.userId = [NSString stringWithFormat:@"%ld",_room.userId];
    user.createUserId = [NSString stringWithFormat:@"%ld",member.userId];
    [user updateCreateUser];
}

// 指定管理员回调
-(void)specifyAdministratorDelegate:(memberData *)member{
    
    _currentMember = member;
    int type;
    if ([member.role intValue] == 2) {
        type = 3;
    }else {
        type = 2;
    }
    
    [g_server setRoomAdmin:member.roomId userId:[NSString stringWithFormat:@"%ld",member.userId] type:type toView:self];
}
// 指定隐身人回调
- (void)specifyInvisibleManDelegate:(memberData *)member {
    _currentMember = member;
    int type;
    if ([member.role intValue] == 3) {
        type = 4;
    }else {
        type = -1;
    }
    self.isMonitorPeople = NO;
    [g_server setRoomInvisibleGuardian:member.roomId userId:[NSString stringWithFormat:@"%ld",member.userId] type:type toView:self];
}
//指定监控人回调
- (void)specifyMonitorPeopleDelegate:(memberData *)member {
    _currentMember = member;
    int type;
    if ([member.role intValue] == 3) {
        type = 5;
    }else {
        type = 0;
    }
    self.isMonitorPeople = YES;
    [g_server setRoomInvisibleGuardian:member.roomId userId:[NSString stringWithFormat:@"%ld",member.userId] type:type toView:self];
}
- (void)switchViewAction:(UISwitch *)switchView {
    switch (switchView.tag) {
        case 2456:
            [self readSwitchAction:switchView];
            break;
        case 2457:
            [self lookSwitchAction:switchView];
            break;
        case 2458:
            [self needVerifySwitchAction:switchView];
            break;
        case 2459:
            [self showMemberSwitchAction:switchView];
            break;
        case 2460:
            [self allowSendCardSwitchAction:switchView];
            break;
        case 2461:
            [self allowInviteFriendSwitchAction:switchView];
            break;
        case 2462:
            [self allowUploadFileSwitchAction:switchView];
            break;
        case 2463:
            [self allowConferenceSwitchAction:switchView];
            break;
        case 2464:
            [self allowSpeakCourseSwitchAction:switchView];
            break;
        case 2465:
            [self isAttritionNoticeSwitchAction:switchView];
            break;
        default:
            break;
    }
}

// 显示已读人数
-(void)readSwitchAction:(UISwitch *)readswitch{
    memberData *data = [self.room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"JXRoomMemberVC_NotGroupMarsterCannotDoThis")];
        [readswitch setOn:!readswitch.isOn];
        return;
    }
    self.updateType = [NSNumber numberWithInt:kRoomRemind_ShowRead];
    self.room.showRead = readswitch.on;
    [g_server updateRoomShowRead:self.room key:@"showRead" value:self.room.showRead toView:self];
}
// 进群验证
- (void)needVerifySwitchAction:(UISwitch *)needVerifySwitch {
    memberData *data = [self.room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"JXRoomMemberVC_NotGroupMarsterCannotDoThis")];
        [needVerifySwitch setOn:!needVerifySwitch.isOn];
        return;
    }
    self.updateType = [NSNumber numberWithInt:kRoomRemind_NeedVerify];
    self.room.isNeedVerify = needVerifySwitch.on;
    [g_server updateRoomShowRead:self.room key:@"isNeedVerify" value:self.room.isNeedVerify toView:self];
}

// 私密群组群组
- (void)lookSwitchAction:(UISwitch *)lookSwitch {
    memberData *data = [self.room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"JXRoomMemberVC_NotGroupMarsterCannotDoThis")];
        [lookSwitch setOn:!lookSwitch.isOn];
        return;
    }
    self.updateType = [NSNumber numberWithInt:2457];
    self.room.isLook = !lookSwitch.on;
    [g_server updateRoomShowRead:self.room key:@"isLook" value:self.room.isLook toView:self];
}


// 显示群成员列表
- (void)showMemberSwitchAction:(UISwitch *)showMemberSwitch {
    memberData *data = [self.room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"JXRoomMemberVC_NotGroupMarsterCannotDoThis")];
        [showMemberSwitch setOn:!showMemberSwitch.isOn];
        return;
    }
    self.updateType = [NSNumber numberWithInt:kRoomRemind_ShowMember];
    self.room.showMember = showMemberSwitch.on;
    [g_server updateRoomShowRead:self.room key:@"showMember" value:self.room.showMember toView:self];
}

// 允许发送名片
- (void)allowSendCardSwitchAction:(UISwitch *)allowSendCardSwitch {
    memberData *data = [self.room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"JXRoomMemberVC_NotGroupMarsterCannotDoThis")];
        [allowSendCardSwitch setOn:!allowSendCardSwitch.isOn];
        return;
    }
    
    self.updateType = [NSNumber numberWithInt:kRoomRemind_allowSendCard];
    self.room.allowSendCard = allowSendCardSwitch.on;
    [g_server updateRoomShowRead:self.room key:@"allowSendCard" value:self.room.allowSendCard toView:self];
}

// 允许普通成员邀请好友
- (void)allowInviteFriendSwitchAction:(UISwitch *)switchView {
    self.updateType = [NSNumber numberWithInt:kRoomRemind_RoomAllowInviteFriend];
    self.room.allowInviteFriend = switchView.on;
    [g_server updateRoomShowRead:self.room key:@"allowInviteFriend" value:self.room.allowInviteFriend toView:self];
}

// 允许普通成员上传文件
- (void)allowUploadFileSwitchAction:(UISwitch *)switchView {
    self.updateType = [NSNumber numberWithInt:kRoomRemind_RoomAllowUploadFile];
    self.room.allowUploadFile = switchView.on;
    [g_server updateRoomShowRead:self.room key:@"allowUploadFile" value:self.room.allowUploadFile toView:self];
}

// 允许普通成员召开会议
- (void)allowConferenceSwitchAction:(UISwitch *)switchView {
    self.updateType = [NSNumber numberWithInt:kRoomRemind_RoomAllowConference];
    self.room.allowConference = switchView.on;
    [g_server updateRoomShowRead:self.room key:@"allowConference" value:self.room.allowConference toView:self];
}
// 允许普通成员开启讲课
- (void)allowSpeakCourseSwitchAction:(UISwitch *)switchView {
    self.updateType = [NSNumber numberWithInt:kRoomRemind_RoomAllowSpeakCourse];
    self.room.allowSpeakCourse = switchView.on;
    [g_server updateRoomShowRead:self.room key:@"allowSpeakCourse" value:self.room.allowSpeakCourse toView:self];
}

// 群减员通知
- (void)isAttritionNoticeSwitchAction:(UISwitch *)switchView {
//    self.updateType = [NSNumber numberWithInt:kRoomRemind_RoomAllowSpeakCourse];
    self.room.isAttritionNotice = switchView.on;
    [g_server updateRoomShowRead:self.room key:@"isAttritionNotice" value:self.room.isAttritionNotice toView:self];
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:act_UserGet] ){
        JXUserObject* user = [[JXUserObject alloc]init];
        [user getDataFromDict:dict];
        [self.room setNickNameForUser:user];
        
        //        JXUserInfoVC* vc = [JXUserInfoVC alloc];
        //        vc.user       = user;
        //        vc = [vc init];
        ////        [g_window addSubview:vc.view];
        //        [g_navigation pushViewController:vc animated:YES];
        //        [user release];
    }
    if( [aDownload.action isEqualToString:act_roomSet] ){
        
        JXUserObject * user = [[JXUserObject alloc]init];
        user = [user getUserById:self.room.roomJid];
        user.showRead = [NSNumber numberWithBool:self.room.showRead];
        user.showMember = [NSNumber numberWithBool:self.room.showMember];
        user.allowSendCard = [NSNumber numberWithBool:self.room.allowSendCard];
        user.chatRecordTimeOut = self.room.chatRecordTimeOut;
        user.talkTime = [NSNumber numberWithLong:self.room.talkTime];
        user.allowInviteFriend = [NSNumber numberWithBool:self.room.allowInviteFriend];
        user.allowUploadFile = [NSNumber numberWithBool:self.room.allowUploadFile];
        user.allowConference = [NSNumber numberWithBool:self.room.allowConference];
        user.allowSpeakCourse = [NSNumber numberWithBool:self.room.allowSpeakCourse];
        user.isNeedVerify = [NSNumber numberWithBool:self.room.isNeedVerify];
        [user update];
        
        if ([self.updateType intValue] == kRoomRemind_ShowRead || [self.updateType intValue] == kRoomRemind_ShowMember || [self.updateType intValue] == kRoomRemind_allowSendCard || [self.updateType intValue] == kRoomRemind_RoomAllowInviteFriend || [self.updateType intValue] == kRoomRemind_RoomAllowUploadFile || [self.updateType intValue] == kRoomRemind_RoomAllowConference || [self.updateType intValue] == kRoomRemind_RoomAllowSpeakCourse) {
            
            JXRoomRemind* p = [[JXRoomRemind alloc] init];
            p.objectId = self.room.roomJid;
            switch ([self.updateType intValue]) {
                case kRoomRemind_ShowRead: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_ShowRead];
                    p.content = [NSString stringWithFormat:@"%d",self.room.showRead];
                }
                    break;
                    
                case kRoomRemind_ShowMember: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_ShowMember];
                    p.content = [NSString stringWithFormat:@"%d",self.room.showMember];
                }
                    break;
                    
                case kRoomRemind_allowSendCard: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_allowSendCard];
                    p.content = [NSString stringWithFormat:@"%d",self.room.allowSendCard];
                }
                    break;
                case kRoomRemind_RoomAllowInviteFriend: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_RoomAllowInviteFriend];
                    p.content = [NSString stringWithFormat:@"%d",self.room.allowInviteFriend];
                }
                    break;
                case kRoomRemind_RoomAllowUploadFile: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_RoomAllowUploadFile];
                    p.content = [NSString stringWithFormat:@"%d",self.room.allowUploadFile];
                }
                    break;
                case kRoomRemind_RoomAllowConference: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_RoomAllowConference];
                    p.content = [NSString stringWithFormat:@"%d",self.room.allowConference];
                }
                    break;
                case kRoomRemind_RoomAllowSpeakCourse: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_RoomAllowSpeakCourse];
                    p.content = [NSString stringWithFormat:@"%d",self.room.allowSpeakCourse];
                }
                    break;
                    
                default:
                    break;
            }
            [p notify];
        }
        
        [g_App showAlert:Localized(@"JXAlert_UpdateOK")];
    }
    
    if ([aDownload.action isEqualToString:act_roomSetAdmin]) {
        //设置群组管理员
        NSString *str;
        if ([_currentMember.role intValue] == 2) {
            _currentMember.role = [NSNumber numberWithInt:3];
            str = Localized(@"JXRoomMemberVC_CancelAdministratorSuccess");
        }else {
            _currentMember.role = [NSNumber numberWithInt:2];
            str = Localized(@"JXRoomMemberVC_SetAdministratorSuccess");
        }
//        [_currentMember updateRole];
        [g_server showMsg:str];
    }
    
    if ([aDownload.action isEqualToString:act_roomSetInvisibleGuardian]) {
        //设置群组隐身人、监控人
        NSString *str;
        if (self.isMonitorPeople) {
            if ([_currentMember.role intValue] == 3){
                _currentMember.role = [NSNumber numberWithInt:5];
                str = @"指定监控人成功";
            }else {
                _currentMember.role = [NSNumber numberWithInt:3];
                str = @"取消监控人成功";
            }
        }else {
            if ([_currentMember.role intValue] == 3) {
                _currentMember.role = [NSNumber numberWithInt:4];
                str = Localized(@"JX_SetInvisibleSuccessfully");
            }else{
                _currentMember.role = [NSNumber numberWithInt:3];
                str = Localized(@"JX_CancelInvisibleSuccessfully");
            }
        }
        [_currentMember updateRole];
        [g_server showMsg:str];
    }
   
    if ([aDownload.action isEqualToString:act_roomTransfer]) {
        //转让群主
        
        memberData *groupOwner = [memberData searchGroupOwner:self.room.roomId];
        groupOwner.role = [NSNumber numberWithInt:3];
        _currentMember.role = [NSNumber numberWithInt:1];
        
        [g_server showMsg:Localized(@"JX_ManagerAssignment")];
        [g_navigation popToRootViewController];
    }
    
    if ([aDownload.action isEqualToString:act_RoomUpdateEncryptType]) {
        
        self.user.encryptType = [NSNumber numberWithInteger:self.encryptIndex];
        [self.user updateEncryptType];
    }
    
    if ([aDownload.action isEqualToString:act_RoomGetAllMemberRsaPublicKey]) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (NSString *key in dict.allKeys) {
            
            NSString *pubStr = dict[key];
            SecKeyRef pubKey = [g_securityUtil getRSAKeyWithBase64Str:pubStr isPrivateKey:NO];
            NSData *enData = [g_securityUtil encryptMessageRSA:[_room.chatKeyGroup dataUsingEncoding:NSUTF8StringEncoding] withPublicKey:pubKey];
            NSString *enStr = [enData base64EncodedStringWithOptions:0];
            [dic setValue:enStr forKey:key];
        }
        
        SBJsonWriter * OderJsonwriter = [SBJsonWriter new];
        NSString * keys = [OderJsonwriter stringWithObject:dic];
        
        [g_server roomResetGroupChatKeyWithRoomId:self.room.roomId keys:keys toView:self];
    }
    
    if ([aDownload.action isEqualToString:act_RoomResetGroupChatKey]) {
        [JXMyTools showTipView:Localized(@"JX_ResetSucceeded")];
    }
    
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
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
