//
//  JXRoomMemberVC.m
//  shiku_im
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXRoomMemberVC.h"
//#import "selectTreeVC.h"
#import "selectValueVC.h"
#import "selectProvinceVC.h"
#import "ImageResize.h"
#import "roomData.h"
#import "JXUserInfoVC.h"
#import "JXSelFriendVC.h"
#import "JXRoomObject.h"
#import "JXChatViewController.h"
#import "JXRoomObject.h"
#import "JXRoomRemind.h"
#import "JXInputValueVC.h"
#import "JXFileViewController.h"
#import "JXQRCodeViewController.h"
#import "JXGroupManagementVC.h"
#import "JXInputVC.h"
#import "JXRoomMemberListVC.h"
#import "JXSearchChatLogVC.h"
#import "JXSelectFriendsVC.h"
#import "JXReportUserVC.h"
#import "JXRoomPool.h"
#import "JXAnnounceViewController.h"
#import "JXSynTask.h"
#import "JXCameraVC.h"
#import "ImageResize.h"
#import "JXMsgViewController.h"
#import "JXGroupMemberCell.h"
#import "JXSetChatBackgroundVC.h"

#define HEIGHT 55
#define IMGSIZE 170
#define TAG_LABEL 1999


@interface JXRoomMemberVC ()<UITextFieldDelegate, UIPickerViewDelegate, JXRoomMemberListVCDelegate,JXCameraVCDelegate,JXActionSheetVCDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) JXImageView * unfoldView;
@property (nonatomic,strong) UIImageView * memberView;
@property (nonatomic,assign) BOOL          isMyRoom;
@property (nonatomic,strong) memberData  * currentMember;

@property (nonatomic, strong) NSMutableArray *selFriendUserIds;
@property (nonatomic, strong) NSMutableArray *selFriendUserNames;

@property (nonatomic, strong) JXUserObject *user;
@property (nonatomic, strong) NSNumber *updateType;

@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *pickerArr;
@property (nonatomic, strong) JXLabel *chatRecordTimeOutLabel;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSMutableArray *noticeArr; //群公告
@property (nonatomic, strong) NSString *setNickName;
@property (nonatomic, assign) int userSize;

@property (nonatomic, strong) UIImage *roomHead;
@property (nonatomic, assign) BOOL isChatTop;
@property (nonatomic, assign) BOOL isMsgFree;
@property (nonatomic, assign) BOOL isXmppUpadte;

@property (nonatomic, strong) UIButton *quiteRoomBtn;

@property (nonatomic, strong) UICollectionView *memberListView;//群组成员列表
@property (nonatomic, assign) float widthInset;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) unsigned long maxShow;
@property (nonatomic, strong) memberData *data;

@end

@implementation JXRoomMemberVC
@synthesize room,chatRoom;


- (id)init
{
    self = [super init];
    if (self) {
        _modifyType = 0;
        _images  = [[NSMutableArray alloc] init];
        _names   = [[NSMutableArray alloc] init];
        _deleteArr = [[NSMutableArray alloc] init];
        _noticeArr = [[NSMutableArray alloc] init];
        _delMode = NO;
        _allowEdit = YES;
        _delete = -1;
        memberData *data = [self.room getMember:g_myself.userId];
        _isAdmin = [data.role intValue] == 1 ? YES : NO;
//        _isAdmin = YES;
        _unfoldMode = YES;//默认收起
        _user = [[JXUserObject sharedInstance] getUserById:chatRoom.roomJid];
        if ([g_myself.userId longLongValue] == room.userId) {
            _isMyRoom = YES;
        }else{
            _isMyRoom = NO;
        }
        
        _pickerArr = @[Localized(@"JX_Forever"), Localized(@"JX_OneHour"), Localized(@"JX_OneDay"), Localized(@"JX_OneWeeks"), Localized(@"JX_OneMonth"), Localized(@"JX_OneQuarter"), Localized(@"JX_OneYear")];
        
        self.user = [[JXUserObject sharedInstance] getUserById:room.roomJid];

        self.isGotoBack   = YES;
        self.title = Localized(@"JXRoomMemberVC_RoomInfo");
        self.heightFooter = 0;
        self.heightHeader = JX_SCREEN_TOP;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self createHeadAndFoot];
        
        self.tableBody.scrollEnabled = YES;
        self.tableBody.contentSize = CGSizeMake(self_width, JX_SCREEN_HEIGHT*1.2);
        self.tableBody.showsVerticalScrollIndicator = YES;
        self.tableBody.delegate = self;
        int height = 0;

        self.iv = [[JXImageView alloc]init];
        self.iv.frame = self.tableBody.bounds;
        self.iv.backgroundColor = HEXCOLOR(0xF5F5F5);
//        iv.delegate = self;
//        iv.didTouch = @selector(hideKeyboard);
        [self.tableBody addSubview:self.iv];
//        [self.iv release];
        
//        if (_isAdmin || room.showMember) {
        
        height = [self createImages];
//        }
        
//        [self setDeleteMode:YES];
        height+=10;
        int membHei = [self createRoomMember:height];
        height += membHei;
        [self setRoomframeWithHeight:height];
        
        [g_notify addObserver:self selector:@selector(onReceiveRoomRemind:) name:kXMPPRoomNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(updateRoomSet:) name:kOfflineOperationUpdateUserSet object:nil];
        [g_notify addObserver:self selector:@selector(updateRoomSet:) name:kXMPPMessageUpadteGroupNotification object:nil];
        [self createPickerView];
        
        [g_server getRoom:self.roomId toView:self];
        
//        [g_notify addObserver:self selector:@selector(reSetData:) name:@"ReloadRoomInfo" object:nil];
    }
    return self;
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


- (void)updateRoomSet:(NSNotification *)noti {
    self.isXmppUpadte = YES;
    [g_server getRoom:self.roomId toView:self];
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
    room.chatRecordTimeOut = str;
//    [g_server updateRoom:room toView:self];
    [g_server updateRoom:room key:@"chatRecordTimeOut" value:str toView:self];
}

- (void)cancelBtnAction:(UIButton *)btn {
    _selectView.hidden = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _selectView.hidden = YES;
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

-(void)dealloc{
//    NSLog(@"JXRoomMemberVC.dealloc");
    [g_notify removeObserver:self name:kXMPPRoomNotifaction object:nil];
    [g_notify removeObserver:self name:kOfflineOperationUpdateUserSet object:nil];
    [_names removeAllObjects];
//    [_names release];
    [_deleteArr removeAllObjects];
//    [_deleteArr release];
    [_images removeAllObjects];
//    [_images release];
//    [_user release];
    chatRoom.delegate = nil;
//    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
        return YES;
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:act_UserGet] ){
        JXUserObject* user = [[JXUserObject alloc]init];
        [user getDataFromDict:dict];
        [room setNickNameForUser:user];
        
//        JXUserInfoVC* vc = [JXUserInfoVC alloc];
//        vc.user       = user;
//        vc = [vc init];
////        [g_window addSubview:vc.view];
//        [g_navigation pushViewController:vc animated:YES];
//        [user release];
    }
    if( [aDownload.action isEqualToString:act_roomSet] ){
        
        JXUserObject * user = [[JXUserObject alloc]init];
        user = [user getUserById:room.roomJid];
        user.showRead = [NSNumber numberWithBool:_readSwitch.on];
        user.showMember = [NSNumber numberWithBool:room.showMember];
        user.allowSendCard = [NSNumber numberWithBool:room.allowSendCard];
        user.chatRecordTimeOut = room.chatRecordTimeOut;
        user.talkTime = [NSNumber numberWithLong:room.talkTime];
        user.allowInviteFriend = [NSNumber numberWithBool:room.allowInviteFriend];
        user.allowUploadFile = [NSNumber numberWithBool:room.allowUploadFile];
        user.allowConference = [NSNumber numberWithBool:room.allowConference];
        user.allowSpeakCourse = [NSNumber numberWithBool:room.allowSpeakCourse];
        user.isNeedVerify = [NSNumber numberWithBool:room.isNeedVerify];
        [user update];
        
        NSString *alertStr = nil;
        if ([self.updateType intValue] == kRoomRemind_ShowRead || [self.updateType intValue] == kRoomRemind_ShowMember || [self.updateType intValue] == kRoomRemind_allowSendCard || [self.updateType intValue] == kRoomRemind_RoomAllBanned) {
            
            JXRoomRemind* p = [[JXRoomRemind alloc] init];
            p.objectId = room.roomJid;
            switch ([self.updateType intValue]) {
                case kRoomRemind_ShowRead: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_ShowRead];
                    p.content = [NSString stringWithFormat:@"%d",_readSwitch.on];
                    if (_readSwitch.on) {
                        alertStr = Localized(@"JX_EnabledShowRead");
                    }else {
                        alertStr = Localized(@"JX_DisabledShowRead");
                    }
    
                }
                    
                    break;
                    
                case kRoomRemind_ShowMember: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_ShowMember];
                    p.content = [NSString stringWithFormat:@"%d",room.showMember];
                    if (room.showMember) {
                        alertStr = Localized(@"JX_EnabledShowIcon");
                    }else {
                        alertStr = Localized(@"JX_DisabledShowIcon");
                    }
                }
                    
                    break;
                    
                case kRoomRemind_allowSendCard: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_allowSendCard];
                    p.content = [NSString stringWithFormat:@"%d",room.allowSendCard];
                    if (room.allowSendCard) {
                        alertStr = Localized(@"JX_EnabledShowCard");
                    }else {
                        alertStr = Localized(@"JX_DisabledShowCard");
                    }
                }
                    
                    break;
                case kRoomRemind_RoomAllBanned: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_RoomAllBanned];
                    p.content = [NSString stringWithFormat:@"%d",room.allowSendCard];
                    if (room.talkTime > 0) {
                        alertStr = Localized(@"JX_EnabledAllBanned");
                    }else {
                        alertStr = Localized(@"JX_DisabledAllBanned");
                    }
                }
                    
                    break;
                default:
                    break;
            }
            [p notify];
        }
        
        if ([self.updateType intValue] == kRoomRemind_NeedVerify) {
            if (room.isNeedVerify) {
                alertStr = Localized(@"JX_EnabledIntoGroup");
            }else {
                alertStr = Localized(@"JX_DisabledIntoGroup");
            }
            
        }else if ([self.updateType intValue] == 2457) {
            if (room.isLook) {
                alertStr = Localized(@"JX_EnabledSearch");
            }else {
                alertStr = Localized(@"JX_DisabledSearch");
            }
        }else {
            
            _roomName.text = room.name;
            _note.text = room.note ? room.note : Localized(@"JX_NotAch");
            _desc.text = room.desc;
            _roomNum.text = [NSString stringWithFormat:@"%d",room.maxCount];
            alertStr = Localized(@"JXAlert_UpdateOK");
        }
        
        [g_App showAlert:alertStr];
    }
    if( [aDownload.action isEqualToString:act_roomMemberSet] ){
        if(_modifyType == kRoomRemind_NickName){
//            [self sendSelfMsg:_modifyType content:_content];
            [self createImages];
            [g_notify postNotificationName:kRefreshChatLogNotif object:nil];
        }
        
        [g_App showAlert:Localized(@"JXAlert_SetOK")];
    }
    if( [aDownload.action isEqualToString:act_roomDel] ){
        [JXUserObject deleteUserAndMsg:room.roomJid];
        chatRoom.delegate = self;
        [g_notify postNotificationName:kUpdateUserNotifaction object:nil];
        
        [g_notify postNotificationName:kQuitRoomNotifaction object:chatRoom userInfo:nil];
        [self actionQuit];
        
    }
    if ([aDownload.action isEqualToString:act_roomMemberList]) {
        [room.members removeAllObjects];
        
        for (int i = 0; i < [array1 count]; i++) {
            roomData * rData = [[roomData alloc]init];
            [rData getDataFromDict:array1[i]];
            [room.members addObject:rData];
//            [rData release];
        }

        [self createImages];
        _memberCount.text = [NSString stringWithFormat:@"%d/2000",[_memberCount.text intValue] +1];
    }


    //
    if( [aDownload.action isEqualToString:act_roomMemberDel] ){
        memberData* member=nil;
        if(_delete == -1){
            chatRoom.delegate = self;
            [chatRoom leave];
            member = [room getMember:MY_USER_ID];
        }else{
            if (_delete == -2) {
                return;
            }
            member = [room.members objectAtIndex:_delete];
        }
        //在xmpp中删除成员
//        [chatRoom removeUser:member];
        [room.members removeObject:member];
        [member remove];
        [self createImages];

        //通知自己界面
        [self onAfterDelMember:member];
        member = nil;
        
        [g_notify postNotificationName:kUpdateUserNotifaction object:nil];
        
        if (_delete == -1) {
            [g_notify postNotificationName:kQuitRoomNotifaction object:chatRoom userInfo:nil];
            [self actionQuit];
        }
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
//        [_currentMember update];
        [g_server showMsg:str];
    }
    
    if ([aDownload.action isEqualToString:act_roomMemberSetOfflineNoPushMsg]) {
        if (self.isMsgFree) {
            self.isMsgFree = NO;
            self.user.offlineNoPushMsg = [NSNumber numberWithBool:_messageFreeSwitch.isOn];
            [self.user updateOfflineNoPushMsg];
            [g_notify postNotificationName:kChatViewDisappear object:nil];
            [g_App showAlert:Localized(@"JXAlert_SetOK")];
        }else if (self.isChatTop) {
            self.isChatTop = NO;
            if (_topSwitch.isOn) {
                self.user.topTime = [NSDate date];
            }else {
                self.user.topTime = nil;
            }
            
            [self.user updateTopTime];
            [g_notify postNotificationName:kChatViewDisappear object:nil];
        }
    }
    
    if([aDownload.action isEqualToString:act_Report]){
        [_wait stop];
        [g_App showAlert:Localized(@"JXUserInfoVC_ReportSuccess")];
    }
    if([aDownload.action isEqualToString:act_SetGroupAvatarServlet]){
        [_wait stop];
        
        int hashCode = [self gethashCode:self.room.roomJid];
        int a = abs(hashCode % 10000);
        int b = abs(hashCode % 20000);
        // 删除sdwebimage 缓存
        NSString *urlStr = [NSString stringWithFormat:@"%@avatar/o/%d/%d/%@.jpg",g_config.downloadAvatarUrl,a,b,self.room.roomJid];
        [[SDImageCache sharedImageCache] removeImageForKey:urlStr withCompletion:^{
            [g_server showMsg:Localized(@"JX_GroupAvatarUpdatedSuccessfully") delay:0.5];
        }];
//        NSDictionary * groupDict = @{@"groupHeadImage":self.roomHead,@"roomJid":self.room.roomJid,@"setUpdate":@1};
//        [g_notify postNotificationName:kGroupHeadImageModifyNotifaction object:groupDict];
    }

    if( [aDownload.action isEqualToString:act_roomGet] ){
        memberData *memberD  = [[memberData alloc] init];
        memberD.roomId = self.room.roomId;
        [memberD deleteRoomMemeber];
        
        self.noticeArr = [dict objectForKey:@"notices"];
        JXUserObject* user = [[JXUserObject alloc]init];
        [user getDataFromDict:dict];
        
        NSDictionary * groupDict = [user toDictionary];
        roomData * roomdata = [[roomData alloc] init];
        [roomdata getDataFromDict:groupDict];
        
        [roomdata getDataFromDict:dict];
        
        if (self.isXmppUpadte) {
            self.isXmppUpadte = NO;
            [_topSwitch setOn:[user.topTime timeIntervalSince1970] > 0];
            [_messageFreeSwitch setOn:[user.offlineNoPushMsg boolValue]];
            JXUserObject *user1 = [[JXUserObject sharedInstance] getUserById:roomdata.roomJid];
            NSLog(@"user.status = %@", user1.status);
            [_notMsgSwitch setOn:[user1.status intValue] == friend_status_black];
            
            return;
        }
        
        
        self.chatRoom   = [[JXXMPP sharedInstance].roomPool joinRoom:roomdata.roomJid title:roomdata.name lastDate:nil isNew:NO];
        self.room       = roomdata;
        
        memberData *data = [self.room getMember:g_myself.userId];
        _isAdmin = [data.role intValue] == 1 ? YES : NO;
        _user = [[JXUserObject sharedInstance] getUserById:chatRoom.roomJid];
        if ([g_myself.userId longLongValue] == room.userId) {
            _isMyRoom = YES;
        }else{
            _isMyRoom = NO;
        }

        self.user = [[JXUserObject sharedInstance] getUserById:room.roomJid];
        self.userSize = [dict[@"userSize"] intValue];
        
        NSDictionary *member = [dict objectForKey:@"member"];
#ifdef IS_MsgEncrypt
        if ([g_config.isOpenSecureChat boolValue]) {
            if ([member objectForKey:@"chatKeyGroup"]) {
                
                if (![self.user.isLostChatKeyGroup boolValue]) {
                    SecKeyRef priKey = [g_securityUtil getRSAKeyWithBase64Str:g_msgUtil.rsaPrivateKey isPrivateKey:YES];
                    NSString *chatKeyGroup = [member objectForKey:@"chatKeyGroup"];
                    if (priKey) {NSData *chatKeyData = [[NSData alloc] initWithBase64EncodedString:chatKeyGroup options:NSDataBase64DecodingIgnoreUnknownCharacters];
                        NSData *deData = [g_securityUtil decryptMessageRSA:chatKeyData withPrivateKey:priKey];
                        chatKeyGroup = [[NSString alloc] initWithData:deData encoding:NSUTF8StringEncoding];
                    }else {
                        chatKeyGroup = nil;
                    }
                    
                    // 解密秘钥失败，群组置为丢失秘钥状态，并发送804消息，请求秘钥
                    if (!chatKeyGroup || chatKeyGroup.length <= 0) {
                        
                        if (![self.user.isLostChatKeyGroup boolValue]) {
                            
                            self.user.isLostChatKeyGroup = [NSNumber numberWithBool:YES];
                            [self.user updateLostChatKeyGroup];
                            
                            JXMessageObject *msg = [[JXMessageObject alloc] init];
                            msg.fromUserId = g_myself.userId;
                            msg.fromUserName = g_myself.userNickname;
                            msg.toUserId = user.userId;
                            msg.objectId = user.userId;
                            msg.timeSend = [NSDate date];
                            msg.type = [NSNumber numberWithInt:kWCMessageTypeChatKeyGroupRequest];
                            SecKeyRef priKey = [g_securityUtil getRSAKeyWithBase64Str:g_msgUtil.rsaPrivateKey isPrivateKey:YES];
                            msg.content = [g_securityUtil getSignWithRSA:self.user.userId withPriKey:priKey];
                            [msg insert:user.userId];
                            [msg updateLastSend:UpdateLastSendType_None];
                            [g_xmpp sendMessage:msg roomName:self.user.userId];
                            
                        }
                        
                    }else {
                        
                        NSString *enKey = [g_msgUtil encryptRoomMsgKey:user.roomId randomKey:chatKeyGroup];
                        if (enKey && enKey.length > 0) {
                            self.user.chatKeyGroup = enKey;
                            // 更新最新的群组秘钥
                            [self.user updateChatKeyGroup];
                        }
                    }
                }
                
            }
        }
#endif
        
        
        int height = 0;
        height = [self createImages];
        //        }
        
        //        [self setDeleteMode:YES];
        height+=10;
        int membHei = [self createRoomMember:height];
        height += membHei;
        [self setRoomframeWithHeight:height];
        
        [g_notify postNotificationName:kRoomMembersRefresh object:[NSNumber numberWithInt:self.userSize]];
        
        
        
    }
}

- (void)onAfterDelMember:(memberData *)member{
    _modifyType = kRoomRemind_DelMember;
    _toUserId = [NSString stringWithFormat:@"%ld",member.userId];
    _toUserName = member.userNickName;
//    [self sendSelfMsg:_modifyType content:nil];
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

-(JXImageView*)createButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom must:(BOOL)must click:(SEL)click ParentView:(UIView *)parent{
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    if(click)
        btn.didTouch = click;
    else
        btn.didTouch = @selector(hideKeyboard);
    btn.delegate = self;
    [parent addSubview:btn];
//    [btn release];
    
    if(must){
        UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, 5, 20, HEIGHT-5)];
        p.text = @"*";
        p.font = g_factory.font18;
        p.backgroundColor = [UIColor clearColor];
        p.textColor = [UIColor redColor];
        p.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:p];
//        [p release];
    }
    //前面的说明label
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(20, 0, 250, HEIGHT)];
    p.text = title;
    p.font = [UIFont boldSystemFontOfSize:16];
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    p.tag = TAG_LABEL;
    [btn addSubview:p];
//    [p release];
    //分割线
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
    //这个选择器仅用于判断，之后会修改为不可点击
    SEL check = @selector(switchAction:);
    //创建switch
    if(click == check){
        UISwitch * switchView = [[UISwitch alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-51, 13, 20, 20)];
        if ([title isEqualToString:Localized(@"JXRoomMemberVC_NotTalk")]) {
            switchView.tag = 15460;
            switchView.on =NO;
        }else if ([title isEqualToString:Localized(@"JXRoomMemberVC_NotMessage")]) {
            if ([_user.status intValue] == friend_status_black) {
                switchView.on = YES;
            }else{
                switchView.on = NO;
            }
        }else if ([title isEqualToString:Localized(@"JX_TotalSilence")]) {
            switchView.tag = 15461;
            switchView.on = room.talkTime > 0 ? YES : NO;
        }
        
        switchView.onTintColor = THEMECOLOR;
        [switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        
        [btn addSubview:switchView];
        //取消调用switchAction
        btn.didTouch = @selector(hideKeyboard);
        
    }else if(click){
        btn.frame = CGRectMake(btn.frame.origin.x -20, btn.frame.origin.y, btn.frame.size.width, btn.frame.size.height);
        
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15-7, (HEIGHT-13)/2, 7, 13)];
        iv.image = [UIImage imageNamed:@"new_icon_>"];
        [btn addSubview:iv];

    }
    return btn;
}

-(UITextField*)createTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint{
    UITextField* p = [[UITextField alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2,INSETS,JX_SCREEN_WIDTH/2,HEIGHT-INSETS*2)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.borderStyle = UITextBorderStyleNone;
    p.returnKeyType = UIReturnKeyDone;
    p.clearButtonMode = UITextFieldViewModeAlways;
    p.textAlignment = NSTextAlignmentRight;
    p.userInteractionEnabled = YES;
    p.text = s;
    p.textColor = [UIColor lightGrayColor];
    p.placeholder = hint;
    p.font = g_factory.font15;
    [parent addSubview:p];

    return p;
}

-(JXLabel*)createLabel:(UIView*)parent default:(NSString*)s isClick:(BOOL) boo{
    JXLabel * p;
    if (boo) {
        p = [[JXLabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2 - 15-7-10,INSETS,JX_SCREEN_WIDTH/2,HEIGHT-INSETS*2)];
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

-(void)onUpdate{
    if(![self getInputValue])
        return;
}

-(BOOL)getInputValue{
    if([_roomName.text length]<=0){
        [g_App showAlert:Localized(@"JX_InputName")];
        return NO;
    }
    return  YES;
}

-(BOOL)hideKeyboard{
//    BOOL b = _roomName.editing || _desc.editing || _userName.editing;
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

-(void)createUserList{
    JXImageView* q=[[JXImageView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, HEIGHT)];
    q.userInteractionEnabled = YES;
    if(_isAdmin){
        q.delegate = self;
        q.didTouch = @selector(onNewNote);
    }
    [_heads addSubview:q];
    
    [_images addObject:q];
    
    memberData *data = [self.room getMember:g_myself.userId];

    BOOL isHide = ([data.role intValue] != 1 && [data.role intValue] != 2) && !self.room.allowSendCard;
        
    JXImageView *p = [self createButton:Localized(@"JX_GroupChatMembers") drawTop:NO drawBottom:NO must:NO click:isHide ? nil : @selector(onShowMembers) ParentView:q];
    p.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, HEIGHT);
    [_images addObject:p];
    
    if (!isHide) {
        _userNum = [self createLabel:p default:[NSString stringWithFormat:Localized(@"JX_Have%dPeople"),self.userSize] isClick:YES];
        _userNum.textColor = HEXCOLOR(0x333333);
        [_images addObject:_userNum];
    }
    
//    [q release];
//    JXLabel* p=[[JXLabel alloc]initWithFrame:CGRectMake(20, 0, 60, 75)];
//    p.backgroundColor = [UIColor whiteColor];
//    p.textAlignment = NSTextAlignmentRight;
//    p.font = g_factory.font13;
//    p.textColor = [UIColor blackColor];
//    p.text = Localized(@"JXRoomMemberVC_RoomAdv");
//    p.userInteractionEnabled = NO;
//    [q addSubview:p];
//    [p release];
//    [_images addObject:p];
    
//    _note=[[UILabel alloc]initWithFrame:CGRectMake(95, 0, JX_SCREEN_WIDTH-105, 75)];
//    _note.backgroundColor = [UIColor whiteColor];
//    _note.numberOfLines = 0;
////    _note.lineBreakMode = UILineBreakModeWordWrap;
//    _note.font = g_factory.font13;
////    _note.offset = -15;
//    _note.text = room.note;
//    _note.textColor = [UIColor blackColor];
//    _note.userInteractionEnabled = NO;
//    [q addSubview:_note];
//    [_note release];
//    [_images addObject:_note];

//    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,_note.frame.size.height,JX_SCREEN_WIDTH,0.5)];
//    line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
//    [q addSubview:line];
////    [line release];
//    [_images addObject:line];
}

// 显示群成员
- (void)onShowMembers {
    
    JXRoomMemberListVC *vc = [[JXRoomMemberListVC alloc] init];
    vc.title = Localized(@"JX_GroupMembers");
    vc.room = self.room;
    vc.type = Type_Default;
    [g_navigation pushViewController:vc animated:YES];
}

-(int)createRoomMember:(int) height{
    self.tableBody.backgroundColor = HEXCOLOR(0xF2F2F2);
    
    [_memberView removeFromSuperview];
    [_quiteRoomBtn removeFromSuperview];
    
    _memberView = [[UIImageView alloc] initWithFrame:CGRectMake(0, height, JX_SCREEN_WIDTH, 0)];
    _memberView.userInteractionEnabled = YES;
    _memberView.backgroundColor = [UIColor clearColor];
    [self.tableBody addSubview:_memberView];
    
    memberData *data = [self.room getMember:g_myself.userId];
    
    int membHeight = 0;
    
    self.iv = [self createButton:Localized(@"JX_RoomName") drawTop:NO drawBottom:YES must:NO click:@selector(onRoomName) ParentView:_memberView];
    self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    _roomName = [self createLabel:self.iv default:room.name isClick:YES];
    membHeight+=self.iv.frame.size.height;
    
    self.iv = [self createButton:Localized(@"JX_RoomExplain") drawTop:NO drawBottom:YES must:NO click:@selector(onRoomDesc) ParentView:_memberView];
    self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    _desc = [self createLabel:self.iv default:room.desc isClick:YES];
    membHeight+=self.iv.frame.size.height;
    
    if (([data.role intValue] == 1 || [data.role intValue] == 2) && ([MY_USER_ROLE containsObject:@5] || [MY_USER_ROLE containsObject:@6])) {
        self.iv = [self createButton:Localized(@"JX_MaximumPeople") drawTop:NO drawBottom:YES must:NO click:@selector(onRoomNumber) ParentView:_memberView];
        self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
        _roomNum = [self createLabel:self.iv default:[NSString stringWithFormat:@"%d",room.maxCount] isClick:YES];
        membHeight+=self.iv.frame.size.height;
    }
    
    self.iv = [self createButton:Localized(@"JXRoomMemberVC_RoomAdv") drawTop:NO drawBottom:YES must:NO click:@selector(onNewNote) ParentView:_memberView];
    self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    _note = [self createLabel:self.iv default:room.note ? room.note : Localized(@"JX_NotAch") isClick:YES];
    membHeight+=self.iv.frame.size.height;
    
    NSDictionary *notiDict = self.noticeArr.firstObject; // 这四行代码为避免当公告为空时，进入群设置列表群公告显示存在公告
    NSString *notiText = [notiDict objectForKey:@"text"];
    _note.text = notiText ? notiText : Localized(@"JX_NotAch");
    room.note = notiText ? notiText : Localized(@"JX_NotAch");
    
    
    if (!(self.user.chatKeyGroup && self.user.chatKeyGroup.length > 0)) {
        
        self.iv = [self createButton:Localized(@"JXQR_QRImage") drawTop:NO drawBottom:YES must:NO click:@selector(showUserQRCode) ParentView:_memberView];
        self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
        UIImageView * qrView = [[UIImageView alloc] init];
        qrView.frame = CGRectMake(JX_SCREEN_WIDTH-15-7-9-16, (HEIGHT-16)/2, 16, 16);
        qrView.image = [UIImage imageNamed:@"qrcodeImage"];
        [self.iv addSubview:qrView];
        membHeight+=self.iv.frame.size.height;
    }
    
    NSString *btnTitle = _isAdmin ? Localized(@"JX_ModifyFullNickname") : Localized(@"JXRoomMemberVC_NickName");
    self.iv = [self createButton:btnTitle drawTop:NO drawBottom:NO must:NO click:@selector(onNickName) ParentView:_memberView];
    self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    if (!_isAdmin) {
        _userName = [self createLabel:self.iv default:[room getNickNameInRoom] isClick:YES];
    }
    membHeight+=self.iv.frame.size.height;
    membHeight+=INSETS;
    
//    self.iv = [self createButton:Localized(@"JXRoomMemberVC_PerCount") drawTop:NO drawBottom:YES must:NO click:nil ParentView:_memberView];
//    self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
//    _memberCount = [self createLabel:self.iv default:[NSString stringWithFormat:@"%ld/%d",room.curCount,room.maxCount] isClick:NO];
//    membHeight+=self.iv.frame.size.height;
//
//    self.iv = [self createButton:Localized(@"JXRoomMemberVC_CreatPer") drawTop:NO drawBottom:YES must:NO click:nil ParentView:_memberView];
//    self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
//    _size = [self createLabel:self.iv default:room.userNickName isClick:NO];
//    membHeight+=self.iv.frame.size.height;
//
//    self.iv = [self createButton:Localized(@"JXRoomMemberVC_CreatTime") drawTop:NO drawBottom:YES must:NO click:nil ParentView:_memberView];
//    self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
//    _size = [self createLabel:self.iv default:[TimeUtil formatDate:[NSDate dateWithTimeIntervalSince1970:room.createTime] format:@"yyyy-MM-dd HH:mm"] isClick:NO];
//    membHeight+=self.iv.frame.size.height;
//    membHeight += INSETS;

    if ([data.role intValue] == 1 || [data.role intValue] == 2) {
        //设置群头像
        self.iv = [self createButton:Localized(@"JX_SetGroupAvatar") drawTop:NO drawBottom:YES must:NO click:@selector(settingRoomIcon) ParentView:_memberView];
        self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
        //    _userName = [self createLabel:self.iv default:[room getNickNameInRoom] isClick:YES];
        membHeight+=self.iv.frame.size.height;
    }

    //群文件
    self.iv = [self createButton:Localized(@"JXRoomMemberVC_ShareFile") drawTop:NO drawBottom:NO must:NO click:@selector(shareFileAction) ParentView:_memberView];
    self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    //    _userName = [self createLabel:self.iv default:[room getNickNameInRoom] isClick:YES];
    membHeight+=self.iv.frame.size.height;
    membHeight+=INSETS;
    
    self.iv = [self createButton:Localized(@"JX_ChatAtTheTop") drawTop:NO drawBottom:YES must:NO click:nil ParentView:_memberView];
    self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    _topSwitch = [[UISwitch alloc] init];
    _topSwitch.onTintColor = THEMECOLOR;
    _topSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-51, 6, 0, 0);
    _topSwitch.center = CGPointMake(_topSwitch.center.x, self.iv.frame.size.height/2);
    [_topSwitch addTarget:self action:@selector(topSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    [_topSwitch setOn:self.user.topTime];
    [self.iv addSubview:_topSwitch];
    membHeight+=self.iv.frame.size.height;
    
    self.iv = [self createButton:Localized(@"JX_MessageFree") drawTop:NO drawBottom:YES must:NO click:nil ParentView:_memberView];
    self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    _messageFreeSwitch = [[UISwitch alloc] init];
    _messageFreeSwitch.onTintColor = THEMECOLOR;
    _messageFreeSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-51, 6, 0, 0);
    _messageFreeSwitch.center = CGPointMake(_messageFreeSwitch.center.x, self.iv.frame.size.height/2);
    [_messageFreeSwitch addTarget:self action:@selector(messageFreeSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.iv addSubview:_messageFreeSwitch];
    membHeight+=self.iv.frame.size.height;
    
    for (memberData *data in room.members) {
        
        if ([[NSString stringWithFormat:@"%ld",data.userId] isEqualToString: MY_USER_ID]) {
            [_messageFreeSwitch setOn:data.offlineNoPushMsg > 0 ? YES : NO];
            
            break;
        }
    }
    
    NSString * s = Localized(@"JXRoomMemberVC_NotMessage");
    self.iv = [self createButton:s drawTop:NO drawBottom:NO must:NO click:nil ParentView:_memberView];
    self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    _notMsgSwitch = [[UISwitch alloc] init];
    _notMsgSwitch.onTintColor = THEMECOLOR;
    _notMsgSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-51, 6, 0, 0);
    _notMsgSwitch.center = CGPointMake(_messageFreeSwitch.center.x, self.iv.frame.size.height/2);
    _notMsgSwitch.on = [_user.status intValue] == friend_status_black;
    [_notMsgSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.iv addSubview:_notMsgSwitch];

    membHeight+=self.iv.frame.size.height;
    _blackBtn = self.iv;
    
    membHeight += INSETS;

    self.iv = [self createButton:Localized(@"JX_ChatBackground") drawTop:NO drawBottom:NO must:NO click:@selector(chatBackGroundImage) ParentView:_memberView];
    self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    membHeight+=self.iv.frame.size.height;

    
    membHeight += INSETS;
    
    if(_isAdmin){
        self.iv = [self createButton:Localized(@"JX_MessageAutoDestroyed") drawTop:NO drawBottom:YES must:NO click:@selector(chatRecordTimeOutAction) ParentView:_memberView];
        self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
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
        _chatRecordTimeOutLabel = [self createLabel:self.iv default:str isClick:YES];
        membHeight+=self.iv.frame.size.height;
    }
    
    self.iv = [self createButton:Localized(@"JX_LookupChatRecords") drawTop:NO drawBottom:YES must:NO click:@selector(searchChatLog) ParentView:_memberView];
    self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    //    _userName = [self createLabel:self.iv default:[room getNickNameInRoom] isClick:YES];
    membHeight+=self.iv.frame.size.height;
    
    
    self.iv = [self createButton:Localized(@"JX_EmptyChatRecords") drawTop:NO drawBottom:NO must:NO click:@selector(cleanMessageLog) ParentView:_memberView];
    self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    membHeight+=self.iv.frame.size.height;
    
    if ([data.role intValue] == 1 || [data.role intValue] == 2) {
        
        membHeight+=INSETS;
        self.iv = [self createButton:Localized(@"JXRoomMemberVC_NotTalk") drawTop:NO drawBottom:YES must:NO click:@selector(notTalkAction) ParentView:_memberView];
        self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
        membHeight+=self.iv.frame.size.height;
        
        self.iv = [self createButton:Localized(@"JX_TotalSilence") drawTop:NO drawBottom:NO must:NO click:@selector(switchAction:) ParentView:_memberView];
        self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
        membHeight+=self.iv.frame.size.height;
    }
    
    if(_isAdmin){
        membHeight += INSETS;
        
        self.iv = [self createButton:Localized(@"JX_GroupManagement") drawTop:NO drawBottom:NO must:NO click:@selector(groupManagement) ParentView:_memberView];
        self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
        membHeight+=self.iv.frame.size.height;
    }
    
    membHeight += INSETS;
    self.iv = [self createButton:Localized(@"JXUserInfoVC_Report") drawTop:NO drawBottom:NO must:NO click:@selector(reportUserView) ParentView:_memberView];
    self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
    membHeight+=self.iv.frame.size.height;
    
    if(_isAdmin){
        
        
//        self.iv = [self createButton:Localized(@"JX_RoomShowRead") drawTop:NO drawBottom:YES must:NO click:nil ParentView:_memberView];
//        self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
//        _readSwitch = [[UISwitch alloc] init];
//        _readSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-51, 6, 0, 0);
//        _readSwitch.center = CGPointMake(_readSwitch.center.x, self.iv.frame.size.height/2);
//        [_readSwitch addTarget:self action:@selector(readSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
//        [self.iv addSubview:_readSwitch];
//        membHeight+=self.iv.frame.size.height;
//
//        _readSwitch.on = room.showRead;
//
//        self.iv = [self createButton:Localized(@"JX_PublicGroups") drawTop:NO drawBottom:YES must:NO click:nil ParentView:_memberView];
//        self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
//        UISwitch *lookSwitch = [[UISwitch alloc] init];
//        lookSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-51, 6, 0, 0);
//        lookSwitch.center = CGPointMake(lookSwitch.center.x, self.iv.frame.size.height/2);
//        [lookSwitch addTarget:self action:@selector(lookSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
//        [lookSwitch setOn:!room.isLook];
//        [self.iv addSubview:lookSwitch];
//        membHeight+=self.iv.frame.size.height;
//
//        self.iv = [self createButton:Localized(@"JX_OpenGroupValidation") drawTop:NO drawBottom:YES must:NO click:nil ParentView:_memberView];
//        self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
//        UISwitch *needVerifySwitch = [[UISwitch alloc] init];
//        needVerifySwitch.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-51, 6, 0, 0);
//        needVerifySwitch.center = CGPointMake(needVerifySwitch.center.x, self.iv.frame.size.height/2);
//        [needVerifySwitch addTarget:self action:@selector(needVerifySwitchAction:) forControlEvents:UIControlEventTouchUpInside];
//        [needVerifySwitch setOn:room.isNeedVerify];
//        [self.iv addSubview:needVerifySwitch];
//        membHeight+=self.iv.frame.size.height;
//
//        self.iv = [self createButton:Localized(@"JX_DisplayGroupMemberList") drawTop:NO drawBottom:YES must:NO click:nil ParentView:_memberView];
//        self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
//        UISwitch *showMemberSwitch = [[UISwitch alloc] init];
//        showMemberSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-51, 6, 0, 0);
//        showMemberSwitch.center = CGPointMake(_readSwitch.center.x, self.iv.frame.size.height/2);
//        [showMemberSwitch addTarget:self action:@selector(showMemberSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
//        [self.iv addSubview:showMemberSwitch];
//        [showMemberSwitch setOn:room.showMember];
//        membHeight+=self.iv.frame.size.height;
//
//        self.iv = [self createButton:@"允许群成员在群组内发送名片" drawTop:NO drawBottom:YES must:NO click:nil ParentView:_memberView];
//        self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
//        UISwitch *allowSendCardSwitch = [[UISwitch alloc] init];
//        allowSendCardSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-51, 6, 0, 0);
//        allowSendCardSwitch.center = CGPointMake(allowSendCardSwitch.center.x, self.iv.frame.size.height/2);
//        [allowSendCardSwitch addTarget:self action:@selector(allowSendCardSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
//        [allowSendCardSwitch setOn:room.allowSendCard];
//        [self.iv addSubview:allowSendCardSwitch];
//        membHeight+=self.iv.frame.size.height;
    }
    
    
    membHeight+=INSETS;
    
    CGRect memFrame = _memberView.frame;
    memFrame.size.height = membHeight;
    _memberView.frame = memFrame;
    
//    if (!_quiteRoomBtn) {
        if(_isMyRoom)
            _quiteRoomBtn = [UIFactory createCommonButton:Localized(@"JX_DeleteRoom") target:self action:@selector(onDelRoom)];
        else
            _quiteRoomBtn = [UIFactory createCommonButton:Localized(@"JXRoomMemberVC_OutPutRoom") target:self action:@selector(onQuitRoom)];
        [_quiteRoomBtn setBackgroundImage:nil forState:UIControlStateNormal];
//        [_quiteRoomBtn setBackgroundImage:nil forState:UIControlStateHighlighted];
        //    _btn.backgroundColor = HEXCOLOR(0xF45860);
        _quiteRoomBtn.custom_acceptEventInterval = 1.f;
        _quiteRoomBtn.layer.masksToBounds = YES;
        _quiteRoomBtn.layer.cornerRadius = 7.f;
        _quiteRoomBtn.backgroundColor = THEMECOLOR;
        //    _h += HEIGHT;
        
        [self.tableBody addSubview:_quiteRoomBtn];
//    }
    _quiteRoomBtn.frame = CGRectMake(15, CGRectGetMaxY(_memberView.frame)+18, JX_SCREEN_WIDTH-15*2, 40);
    
    return membHeight;
}

- (void)settingRoomIcon {
    JXActionSheetVC *actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:@[Localized(@"JX_ChoosePhoto"),Localized(@"JX_TakePhoto")]];
    actionVC.delegate = self;
    [self presentViewController:actionVC animated:NO completion:nil];
}

- (void)actionSheet:(JXActionSheetVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    if (index == 0) {
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        ipc.delegate = self;
        ipc.allowsEditing = YES;
        //选择图片模式
        ipc.modalPresentationStyle = UIModalPresentationCurrentContext;
        //    [g_window addSubview:ipc.view];
        if (IS_PAD) {
            UIPopoverController *pop =  [[UIPopoverController alloc] initWithContentViewController:ipc];
            [pop presentPopoverFromRect:CGRectMake((self.view.frame.size.width - 320) / 2, 0, 300, 300) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }else {
            [self presentViewController:ipc animated:YES completion:nil];
        }
        
    }else {
        JXCameraVC *vc = [JXCameraVC alloc];
        vc.cameraDelegate = self;
        vc.isPhoto = YES;
        vc = [vc init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)cameraVC:(JXCameraVC *)vc didFinishWithImage:(UIImage *)image {
    self.roomHead = [ImageResize image:image fillSize:CGSizeMake(640, 640)];
    [g_server setGroupAvatarServlet:self.chatRoom.roomJid image:self.roomHead toView:self];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.roomHead = [ImageResize image:[info objectForKey:@"UIImagePickerControllerEditedImage"] fillSize:CGSizeMake(640, 640)];
    [g_server setGroupAvatarServlet:self.chatRoom.roomJid image:self.roomHead toView:self];

    [picker dismissViewControllerAnimated:YES completion:nil];
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [picker dismissViewControllerAnimated:YES completion:nil];
}


-(void)setRoomframeWithHeight:(int)height{
    CGRect memFrame = _memberView.frame;
    memFrame.origin.y = height - CGRectGetHeight(_memberView.frame);
    _memberView.frame = memFrame;
    
    //设置scrollview的content大小
    if(height+96 > JX_SCREEN_HEIGHT){
        self.tableBody.contentSize = CGSizeMake(JX_SCREEN_WIDTH, height+96);
    }else{
        self.tableBody.contentSize = CGSizeMake(JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT +1);
    }
}
-(int)createImages{
    
    for (NSInteger i = 0; i < room.members.count; i ++) {
        memberData *data1 = room.members[i];
            for (NSInteger j = i + 1; j < room.members.count; j ++) {
                memberData *data2 = room.members[j];
                
                if ([data2.role intValue] < [data1.role intValue]) {
                    memberData *temp = data1;
                    data1 = data2;
                    room.members[i] = data2;
                    room.members[j] = temp;
                }
        }
    }
//    self.userSize = (int)room.members.count;
    _userNum.text = [NSString stringWithFormat:Localized(@"JX_Have%dPeople"),self.userSize];
    
    _data = [self.room getMember:g_myself.userId];
    _isShow = NO;
    if ([_data.role intValue] == 1 || [_data.role intValue] == 2 || room.showMember){
        _isShow = YES;
    }
    
//    for(NSInteger i=[_images count]-1;i>=0;i--){
//        UIView* iv = [_images objectAtIndex:i];
//        [iv removeFromSuperview];
//        iv = nil;
//    }
    [_images removeAllObjects];
    [_names removeAllObjects];
    [_deleteArr removeAllObjects];
    
    [_heads removeFromSuperview];
    _heads = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 52)];
    _heads.backgroundColor = [UIColor whiteColor];
    [self.tableBody addSubview:_heads];
//    [_heads release];
    [_images addObject:_heads];
    
    
    if (_isShow) {
        //创建公告
        [self createUserList];
    }
    
    //动态分配行数，且居中
    int screenWidth = JX_SCREEN_WIDTH;
    //+126让间隙变大，更美观
    _widthInset = (screenWidth%52 +126)/(screenWidth/52.0);
    
    float x = _widthInset;
    int y = HEIGHT+10;
    if (!_isShow) {
        y = 10;
    }
    
    //收起状态显示两行10个+两个系统图标
    _maxShow = ([room.members count]>8 && _unfoldMode) ? 8 : [room.members count];
    if (!_isShow) {
        _maxShow = 2;
    }
    
    float collectViewHeight = 0.0;
    if (_maxShow < 4) {
        collectViewHeight = 10 + 70*1 + _widthInset*0;
    }else if(_maxShow < 9){
        collectViewHeight = 10 + 70*2 + _widthInset*1;
    }else{
        if (_unfoldMode) {
            collectViewHeight = 10 + 70*2 + _widthInset*1;
        }else{
            if (_maxShow < 14) {
                collectViewHeight = 10 + 70*3 + _widthInset*2;
            }else{
                collectViewHeight = 10 + 70*4 + _widthInset*3;
            }
        }
    }
    [_heads addSubview:self.memberListView];
    self.memberListView.frame = CGRectMake(0, y, JX_SCREEN_WIDTH, collectViewHeight);
    
//    for(int i=0;i<_maxShow+2;i++){
//        //用于判断创建是头像还是系统图标
//        long n ;
//        memberData* user = nil;
//        if(i<_maxShow){
//            user = [room.members objectAtIndex:i];
//            n = user.userId;
//        }
//        if (!_isShow && i < _maxShow) {
//            if (![[NSString stringWithFormat:@"%ld",user.userId] isEqualToString:MY_USER_ID] && ![[NSString stringWithFormat:@"%ld",user.userId] isEqualToString:[NSString stringWithFormat:@"%ld",self.room.userId]]) {
//                continue;
//            }
//        }
//        if(i==_maxShow)
//            n = 0;
//        if(i>_maxShow)
//            n = -1;
//        JXImageView* p = [self createImage:n index:i name:user.userNickName];
//        if(p){
//
//            if(x +52 >= JX_SCREEN_WIDTH){
//                y += 72+10;
//                x = _widthInset;
//            }
//
//            p.frame = CGRectMake(x, y, 52, 52);
//            if (n != 0 && n != -1) {
//                [g_server getHeadImageSmall:[NSString stringWithFormat:@"%ld",n] userName:user.userNickName imageView:p];
//            }
//            x = x+52+_widthInset;
//            if(n>0){
//                JXLabel* b = [[JXLabel alloc]initWithFrame:CGRectMake( p.frame.origin.x, p.frame.origin.y+p.frame.size.height+3, 52, 15)];
//
//                NSString *name = [NSString string];
//                JXUserObject *allUser = [[JXUserObject alloc] init];
//                allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",user.userId]];
//                if (_isAdmin) {
//                    name = user.lordRemarkName.length > 0  ? user.lordRemarkName : allUser.remarkName.length > 0  ? allUser.remarkName : user.userNickName;
//                }else {
//                    name = allUser.remarkName.length > 0  ? allUser.remarkName : user.userNickName;
//                }
//                if (!self.room.allowSendCard && [_data.role intValue] != 1 && [_data.role intValue] != 2) {
//                    name = [name substringToIndex:[name length]-1];
//                    name = [name stringByAppendingString:@"*"];
//                }
//
//                b.text = name;
//                b.font = g_factory.font12;
//                b.textColor = HEXCOLOR(0x333333);
//                b.textAlignment = NSTextAlignmentCenter;
//                [_heads addSubview:b];
////                [b release];
//                [_names addObject:b];
//            }
//        }
//
//        memberData *data = [self.room getMember:g_myself.userId];
//        BOOL flag = NO;
//        if ([data.role intValue] == 1) {
//            flag = [user.role intValue] != 1;
//        }else if([data.role intValue] == 2){
//            flag = [user.role intValue] != 1 && [user.role intValue] != 2;
//        }
//        if(n != [g_myself.userId intValue] && n>0 && flag){
//            JXImageView* iv = [[JXImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(p.frame) - 15, p.frame.origin.y - 5, 20, 20)];
//            iv.didTouch = @selector(onDelete:);
//            iv.delegate = self;
//            iv.tag = i;
//            iv.image = [UIImage imageNamed:@"delete"];
//            iv.hidden = !_delMode;
//            [_heads addSubview:iv];
//            //        [iv release];
//
//            [_deleteArr addObject:iv];
//        }
//
//        user = nil;
//    }
    //换行后添加高度
    float n = y + collectViewHeight;

    
    if (room.members.count > 8 && _isShow) {
        _unfoldView = [[JXImageView alloc] initWithFrame:CGRectMake(0, n-5, 25, 25)];
        _unfoldView.center = CGPointMake(screenWidth/2, _unfoldView.center.y);
        if (_unfoldMode) {
            _unfoldView.image = [UIImage imageNamed:@"room_unfold"];
        }else{
            _unfoldView.image = [UIImage imageNamed:@"pack_up_1"];
        }
        _unfoldView.delegate = self;
        _unfoldView.didTouch = @selector(unfoldViewAction);
        [_heads addSubview:_unfoldView];

        n+=20;//收起箭头
    }
    _heads.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, n);
    
    [self setRoomframeWithHeight:n + 10 + CGRectGetHeight(_memberView.frame)];
    _quiteRoomBtn.frame = CGRectMake(15, CGRectGetMaxY(_memberView.frame)+18, JX_SCREEN_WIDTH-15*2, 40);
    [self.memberListView reloadData];
   return n;
}


-(JXImageView*)createImage:(long)userId index:(int)index name:(NSString*)name{
//    memberData *data = [self.room getMember:g_myself.userId];
//    if(userId == -1){
//        if(!([data.role intValue] == 1 || [data.role intValue] == 2))
//            return nil;
//    }
//    if (userId == 0) {
//        if ([data.role intValue] == 4) {
//            return nil;
//        }
//    }
    JXImageView* p = [[JXImageView alloc]init];
    p.didTouch = @selector(onImage:);
    p.delegate = self;
    p.layer.cornerRadius = 26;
    p.layer.masksToBounds = YES;
    p.tag = index;
    switch (userId) {
        case 0:
            p.image = [UIImage imageNamed:@"add"];
            p.didTouch = @selector(onShowAdd);
            break;
        case -1:
            p.image = [UIImage imageNamed:@"lose"];
            p.didTouch = @selector(onShowDel);
            break;
        default:{
            p.didTouch = @selector(onUser:);

            break;
        }
    }
    [_heads addSubview:p];
//    [p release];
    
    [_images addObject:p];
    return p;
}

- (void)onImage:(JXImageView *)imageView {
    memberData *data = [self.room getMember:g_myself.userId];
    if (([data.role intValue] != 1 && [data.role intValue] != 2)) {
        [g_App showAlert:Localized(@"JX_OnlyManagerSeeInfo")];
        return;
    }
    memberData *user = room.members[imageView.tag];
    JXUserInfoVC* vc = [JXUserInfoVC alloc];
    vc.userId       = [NSString stringWithFormat:@"%ld", user.userId];
    vc.fromAddType = 3;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}

// 置顶
- (void)topSwitchAction:(UISwitch *)topSwitch {
    self.isChatTop = YES;
    [g_server roomMemberSetOfflineNoPushMsg:room.roomId userId:MY_USER_ID type:1 offlineNoPushMsg:topSwitch.isOn toView:self];

}

// 消息免打扰
- (void)messageFreeSwitchAction:(UISwitch *)messageFreeSwitch {
    self.isMsgFree = YES;
    [g_server roomMemberSetOfflineNoPushMsg:room.roomId userId:MY_USER_ID type:0 offlineNoPushMsg:messageFreeSwitch.isOn toView:self];
}

// 聊天背景
- (void)chatBackGroundImage {
    JXSetChatBackgroundVC *vc = [[JXSetChatBackgroundVC alloc] init];
    vc.userId = self.room.roomJid;
    [g_navigation pushViewController:vc animated:YES];
}


// 公开群组
- (void)lookSwitchAction:(UISwitch *)lookSwitch {
    memberData *data = [self.room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"JXRoomMemberVC_NotGroupMarsterCannotDoThis")];
        [lookSwitch setOn:!lookSwitch.isOn];
        return;
    }
    self.updateType = [NSNumber numberWithInt:2457];
    room.isLook = lookSwitch.on;
    [g_server updateRoomShowRead:room key:@"isLook" value:room.isLook toView:self];
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
    room.isNeedVerify = needVerifySwitch.on;
    [g_server updateRoomShowRead:room key:@"isNeedVerify" value:room.isNeedVerify toView:self];
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
    room.showMember = showMemberSwitch.on;
    [g_server updateRoomShowRead:room key:@"showMember" value:room.showMember toView:self];
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
    room.allowSendCard = allowSendCardSwitch.on;
    [g_server updateRoomShowRead:room key:@"allowSendCard" value:room.allowSendCard toView:self];
}

// 清除聊天记录
- (void)cleanMessageLog {
    [g_App showAlert:Localized(@"JX_ConfirmDeleteGroupChatMsg") delegate:self];
}

// 禁言
- (void)notTalkAction {
    
    JXRoomMemberListVC *vc = [[JXRoomMemberListVC alloc] init];
    vc.title = Localized(@"JX_SilenceOfGroupMembers");
    vc.room = self.room;
    vc.type = Type_NotTalk;
    [g_navigation pushViewController:vc animated:YES];
    
}

-(void)unfoldViewAction{
    if (!_unfoldMode) {
        _memberListView.contentOffset = CGPointZero;
    }
    _unfoldMode = !_unfoldMode;
    int height = [self createImages];
    height+=10;
    height += CGRectGetHeight(_memberView.frame);
    
    [UIView animateWithDuration:0.4 animations:^{
        [self setRoomframeWithHeight:height];
    }];
}

-(void)setDeleteMode:(BOOL)b{
    if(!_isAdmin)
        return;
    for(int i=0;i<[_deleteArr count];i++){
        JXImageView* iv = [_deleteArr objectAtIndex:i];
        iv.didTouch = @selector(onDelete:);
        iv.hidden = !b;
        iv = nil;
    }
}

-(void)setDisableMode:(BOOL)b{
    for(int i=0;i<[_deleteArr count];i++){
        JXImageView* iv = [_deleteArr objectAtIndex:i];
        iv.didTouch = @selector(onDisableSay:);
        iv.hidden = !b;
        iv = nil;
    }
}

-(void)onShowDel{
    memberData *data = [self.room getMember:g_myself.userId];
    if (([data.role intValue] == 1 || [data.role intValue] == 2)) {
//        _delMode = !_delMode;
//        [self setDeleteMode:_delMode];
        
        JXRoomMemberListVC *vc = [[JXRoomMemberListVC alloc] init];
        vc.title = Localized(@"JX_DeleteGroupMemebers");
        vc.room = self.room;
        vc.delegate = self;
        vc.type = Type_DelMember;
        [g_navigation pushViewController:vc animated:YES];
        
        return;
    }
    //不是管理员
    [g_App showAlert:Localized(@"JXRoomMemberVC_NotAdminCannotDoThis")];
}

- (void)roomMemberList:(JXRoomMemberListVC *)vc delMember:(memberData *)member {
    
    self.userSize -= 1;
    [self createImages];
    
    //通知自己界面
    [self onAfterDelMember:member];
}

-(void)onUser:(JXImageView*)sender{
    
    memberData *data = [self.room getMember:g_myself.userId];
    if (([data.role intValue] != 1 && [data.role intValue] != 2) && !self.room.allowSendCard) {
        [g_App showAlert:Localized(@"JX_NotAllowMembersSeeInfo")];
        return;
    }
    
    if(sender.tag >= [room.members count])
        return;
    memberData* member = [room.members objectAtIndex:sender.tag];
    [g_server getUser:[NSString stringWithFormat:@"%ld",member.userId] toView:self];
    JXUserInfoVC* vc = [JXUserInfoVC alloc];
    vc.userId       = [NSString stringWithFormat:@"%ld",member.userId];
    vc.fromAddType = 3;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    
    member = nil;
    
}

-(void)onDelete:(JXImageView*)sender{
    if(!_isAdmin)
        return;
    if(sender.tag >= [room.members count])
        return;
    _delete = (int)sender.tag;

    memberData* member = [room.members objectAtIndex:sender.tag];
    
    [g_server delRoomMember:room.roomId userId:member.userId toView:self];
    member = nil;
}

-(void)onShowAdd{
    memberData *data = [self.room getMember:g_myself.userId];
    BOOL flag = [data.role intValue] == 1 || [data.role intValue] == 2;
    if (!flag && !self.room.allowInviteFriend) {
        [g_App showAlert:Localized(@"JX_DisabledInviteFriends")];
        return;
    }
    if([data.role intValue] == 4) {
        [g_App showAlert:Localized(@"JX_InvisibleCan'tInviteMembers")];
        return;
    }
    if ([self.user.isLostChatKeyGroup boolValue]) {
        [g_App showAlert:Localized(@"JX_YouLostKeyCannotInviteFriends")];
        return;
    }
    
    JXSelectFriendsVC* vc = [JXSelectFriendsVC alloc];
    vc.isNewRoom = NO;
    vc.maxSize = room.maxCount - (int)room.curCount;
    vc.chatRoom = chatRoom;
    vc.room = room;
    vc.delegate = self;
    vc.didSelect = @selector(onAfterAddMember:);
    vc = [vc init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)xmppRoomDidDestroy{
//    [g_notify postNotificationName:kQuitRoomNotifaction object:chatRoom userInfo:nil];
//    [self actionQuit];
}

-(void)onDelRoom{
    [g_server delRoom:room.roomId toView:self];
}

-(void)onQuitRoom{
    _delete = -1;
    [JXUserObject deleteUserAndMsg:room.roomJid];
    [g_server delRoomMember:room.roomId userId:[g_myself.userId intValue] toView:self];
}

- (void)xmppRoomDidLeave{
//    [g_notify postNotificationName:kQuitRoomNotifaction object:chatRoom userInfo:nil];
//    [self actionQuit];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return _allowEdit;
}

-(void)actionQuit{
    _allowEdit = NO;
    self.room.curCount = self.userSize;
    [self.view endEditing:YES];
    if (g_mainVC.msgVc.array.count > 0) {
        [g_mainVC.msgVc.tableView reloadRow:self.rowIndex section:0];
    }

    [super actionQuit];
}

-(void)onReceiveRoomRemind:(NSNotification *)notifacation//退出房间
{
    JXRoomRemind* p     = (JXRoomRemind *)notifacation.object;
    if([p.objectId isEqualToString:room.roomJid]){
        if([p.type intValue] == kRoomRemind_RoomName){
//            _userName.text = p.content;
            room.name = p.content;
        }
        if([p.type intValue] == kRoomRemind_NickName){
            for(int i=0;i<[room.members count];i++){
                memberData* m = [room.members objectAtIndex:i];
                if(m.userId == [p.toUserId intValue]){
                    m.userNickName = p.content;
                    if (_names.count > i) {
                        UILabel* b = [_names objectAtIndex:i];
                        b.text = p.content;
                    }
                    if([p.toUserId isEqualToString:MY_USER_ID])
                        _userName.text = p.content;
                    break;
                }
                m = nil;
            }
        }
        if([p.type intValue] == kRoomRemind_DelMember){
            for(int i=0;i<[room.members count];i++){
                memberData* m = [room.members objectAtIndex:i];
                if(m.userId == [p.toUserId intValue]){
                    _delete = -2;
//                    [chatRoom removeUser:m];
                    [room.members removeObjectAtIndex:i];
                    [m remove];
                    _memberCount.text = [NSString stringWithFormat:@"%d/2000",[_memberCount.text intValue] -1];
                    [self createImages];
                    //通知自己界面
                    [self onAfterDelMember:m];
                    break;
                }
                if([p.toUserId isEqualToString:MY_USER_ID]){
                    [g_notify postNotificationName:kQuitRoomNotifaction object:chatRoom userInfo:nil];
                    [self actionQuit];
                }
                m = nil;
            }
        }
        if([p.type intValue] == kRoomRemind_DelRoom){
            if([p.toUserId isEqualToString:MY_USER_ID])
                [self actionQuit];
        }
        if([p.type intValue] == kRoomRemind_NewNotice){
//            _note.text = p.content ? p.content : Localized(@"JX_NotAch");
//            room.note = p.content ? p.content : Localized(@"JX_NotAch");
            [g_server getRoom:self.roomId toView:self];
        }
        if([p.type intValue] == kRoomRemind_AddMember){
#ifndef IS_MsgEncrypt
            if ([self.user.isSecretGroup boolValue]) {
                return;
            }
#else
           if (![g_config.isOpenSecureChat boolValue]) {
               if ([self.user.isSecretGroup boolValue]) {
                   return;
               }
           }
#endif
             [g_server setRoomMember:room.roomId member:_currentMember toView:self];
            
        }
        
        if ([p.type intValue] == kRoomRemind_RoomTransfer) {
//            if ([p.fromUserId isEqualToString:MY_USER_ID]) {
////                [self actionQuit];
//            }
        }
        
        if ([p.type intValue] == kRoomRemind_NeedVerify) {
            if ([p.content isEqualToString:@"1"]) {
                self.room.isNeedVerify = YES;
            }else {
                self.room.isNeedVerify = NO;
            }
        }
    }
}

-(void)onNewNote{
    memberData *data = [self.room getMember:g_myself.userId];
//    if (([data.role intValue] != 1 && [data.role intValue] != 2)) {
//        //不是管理员
//        [g_App showAlert:Localized(@"JXRoomMemberVC_NotAdminCannotDoThis")];
//        return;
//    }
    JXAnnounceViewController* vc = [JXAnnounceViewController alloc];
//    vc.value = room.note;
//    vc.dataArray = [[NSMutableArray alloc] init];
    vc.dataArray = self.noticeArr;
    vc.delegate  = self;
    if (([data.role intValue] == 1 || [data.role intValue] == 2)) {
        vc.isAdmin = YES; // 是群主和管理
    }else {
        vc.isAdmin = NO;  // 不是群主和管理
    }
    vc.room = room;
    vc.title = Localized(@"JXRoomMemberVC_UpdateAdv");
    vc.didSelect = @selector(onSaveNote:);
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];

//    JXInputValueVC* vc = [JXInputValueVC alloc];
//    vc.value = room.note;
//    vc.delegate  = self;
//    vc.title = Localized(@"JXRoomMemberVC_UpdateAdv");
//    vc.didSelect = @selector(onSaveNote:);
//    vc = [vc init];
////    [g_window addSubview:vc.view];
//    [g_navigation pushViewController:vc animated:YES];
}

-(void)onSaveNote:(JXAnnounceViewController*)vc{
    _modifyType = kRoomRemind_NewNotice;
    _content = vc.value;
    room.note = vc.value ? vc.value : Localized(@"JX_NotAch");
    _note.text = room.note ? room.note : Localized(@"JX_NotAch");
    
////    _content = vc.value;
////    room.note = vc.value;
//    if (vc.isDelete == NO) {
//        [g_server updateRoomNotify:room toView:self];
//    }
}

-(void)onRoomName{
    memberData *data = [self.room getMember:g_myself.userId];
    if (([data.role intValue] != 1 && [data.role intValue] != 2)) {
        [g_App showAlert:Localized(@"JXRoomMemberVC_NotAdminCannotDoThis")];
        return;
    }
    JXInputValueVC* vc = [JXInputValueVC alloc];
    vc.value = room.name;
    vc.title = Localized(@"JXRoomMemberVC_UpdateRoomName");
    vc.delegate  = self;
    vc.didSelect = @selector(onSaveRoomName:);
    vc.isLimit = YES;
    vc = [vc init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onSaveRoomName:(JXInputValueVC*)vc{
    _modifyType = kRoomRemind_RoomName;
    _content = vc.value;

    room.name = vc.value;
    
    [g_server updateRoom:room key:@"roomName" value:room.name toView:self];
//    [g_server updateRoom:room toView:self];
}

-(void)onRoomDesc{
    memberData *data = [self.room getMember:g_myself.userId];
    if (([data.role intValue] != 1 && [data.role intValue] != 2)) {
        [g_App showAlert:Localized(@"JXRoomMemberVC_NotAdminCannotDoThis")];
        return;
    }
    JXInputValueVC* vc = [JXInputValueVC alloc];
    vc.value = room.desc;
    vc.title = Localized(@"JXRoomMemberVC_UpdateExplain");
    vc.delegate  = self;
    vc.didSelect = @selector(onSaveRoomDesc:);
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onSaveRoomDesc:(JXInputValueVC*)vc{
    room.desc = vc.value;
    [g_server updateRoomDesc:room toView:self];
}

- (void)onRoomNumber {
    memberData *data = [self.room getMember:g_myself.userId];
    if (([data.role intValue] == 1 || [data.role intValue] == 2) && ([MY_USER_ROLE containsObject:@5] || [MY_USER_ROLE containsObject:@6])) {
        JXInputValueVC* vc = [JXInputValueVC alloc];
        vc.value = [NSString stringWithFormat:@"%ld",room.maxCount];
        vc.title = Localized(@"JX_MaximumPeople");
        vc.isRoomNum = YES;
        vc.delegate  = self;
        vc.didSelect = @selector(onSetupRoomNumber:);
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
        return;
    }
    [g_App showAlert:Localized(@"JXRoomMemberVC_NotAdminCannotDoThis")];
}

- (void)onSetupRoomNumber:(JXInputValueVC*)vc {
    room.maxCount = [vc.value intValue];
    [g_server updateRoomMaxUserSize:room toView:self];
}

-(void)onNickName{
    if (self.isMyRoom) {
        JXRoomMemberListVC *listVC = [[JXRoomMemberListVC alloc] init];
        listVC.type = Type_AddNotes;
        listVC.room = self.room;
        listVC.delegate = self;
        [g_navigation pushViewController:listVC animated:YES];
    } else {
        
        memberData *data = [self.room getMember:g_myself.userId];
        if ([data.role integerValue] == 4) {
            //隐身人不能修改群内昵称
            [JXMyTools showTipView:Localized(@"JX_InvisiblePeopleCannotModifyGroupNickname")];
            return;
        }
        
        JXInputValueVC* vc = [JXInputValueVC alloc];
        vc.value = [room getNickNameInRoom];
        vc.title = Localized(@"JXRoomMemberVC_UpdateNickName");
        vc.delegate  = self;
        vc.didSelect = @selector(onSaveNickName:);
        vc.isLimit = YES;
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
    }

}

-(void)shareFileAction{
    JXFileViewController * fileVC  = [[JXFileViewController alloc] init];
    fileVC.room = room;
//    [g_window addSubview:fileVC.view];
    [g_navigation pushViewController:fileVC animated:YES];
}

// 查找聊天内容
- (void)searchChatLog {
    
    JXSearchChatLogVC *vc = [[JXSearchChatLogVC alloc] init];
    vc.user = self.user;
    vc.isGroup = YES;
    [g_navigation pushViewController:vc animated:YES];
}

- (void)roomMemberList:(JXRoomMemberListVC *)selfVC addNotesVC:(JXInputValueVC *)vc {
    _modifyType = kRoomRemind_NickName;
//    _content = vc.value;
    
    _setNickName = vc.value;
    memberData* p = [room getMember:vc.userId];
    if ([p.role intValue] == 1) {
        p.userNickName = vc.value;
        if ([self.delegate respondsToSelector:@selector(setNickName:)]) {
            [self.delegate setNickName:vc.value];
        }
    }else {
        p.lordRemarkName = vc.value;
    }
    
    [g_server setRoomMember:room.roomId member:p toView:self];
    [p update];
    p = nil;
}

-(void)onSaveNickName:(JXInputValueVC*)vc{
    _modifyType = kRoomRemind_NickName;
    _content = vc.value;
    
    _userName.text = vc.value;
    memberData* p = [room getMember:g_myself.userId];
    p.userNickName = vc.value;
    
    if ([self.delegate respondsToSelector:@selector(setNickName:)]) {
        [self.delegate setNickName:vc.value];
    }

    [g_server setRoomMember:room.roomId member:p toView:self];
    p = nil;
}

-(void)onAfterAddMember:(JXSelectFriendsVC*)vc{
    if (self.room.isNeedVerify && self.room.userId != [g_myself.userId longLongValue]) {
        self.selFriendUserIds = vc.userIds;
        self.selFriendUserNames = vc.userNames;
        JXInputVC* vc = [JXInputVC alloc];
        vc.delegate = self;
        vc.didTouch = @selector(onInputHello:);
        vc.inputTitle = Localized(@"JX_GroupOwnersHaveEnabled");
        vc.titleColor = [UIColor lightGrayColor];
        vc.titleFont = [UIFont systemFontOfSize:13.0];
        vc.inputHint = Localized(@"JX_PleaseEnterTheReason");
//        vc.inputText = Localized(@"JXNewFriendVC_Iam");
        vc = [vc init];
        [g_window addSubview:vc.view];
    }else {
        _delMode = NO;
        self.userSize += vc.userIds.count;
        [self createImages];
    }

//    _modifyType = kRoomRemind_AddMember;
//    _toUserId = [NSString stringWithFormat:@"%ld",vc.member.userId];
//    _toUserName = vc.member.userNickName;
//    _currentMember = vc.member;
//    [self sendSelfMsg:_modifyType content:nil];
}

-(void)onInputHello:(JXInputVC*)sender{
    
    JXMessageObject *msg = [[JXMessageObject alloc] init];
    msg.fromUserId = MY_USER_ID;
    msg.toUserId = [NSString stringWithFormat:@"%ld", room.userId];
    msg.fromUserName = MY_USER_NAME;
    msg.toUserName = room.userNickName;
    msg.timeSend = [NSDate date];
    msg.type = [NSNumber numberWithInt:kRoomRemind_NeedVerify];
    NSString *userIds = [self.selFriendUserIds componentsJoinedByString:@","];
    NSString *userNames = [self.selFriendUserNames componentsJoinedByString:@","];
    NSDictionary *dict = @{
                           @"userIds" : userIds,
                           @"userNames" : userNames,
                           @"roomJid" : room.roomJid,
                           @"reason" : sender.inputText,
                           @"isInvite" : [NSNumber numberWithBool:NO]
                           };
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    msg.objectId = jsonStr;
    [g_xmpp sendMessage:msg roomName:nil];
    
    msg.fromUserId = room.roomJid;
    msg.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
    msg.content = Localized(@"JX_WaitGroupConfirm");
    [msg insert:room.roomJid];
    if ([self.delegate respondsToSelector:@selector(needVerify:)]) {
        [self.delegate needVerify:msg];
    }
}

-(void)onDisableSay{
    _disableMode = !_disableMode;
    [self setDisableMode:_disableMode];
    if (_disableMode) {
        [self.tableBody setContentOffset:CGPointMake(0, 0)];
        [g_App showAlert:Localized(@"JXAlert_GagLong")];
    }
}

-(void)onDisableSay:(JXImageView*)sender{
    if(sender.tag >= [room.members count])
        return;
    _disable = (int)sender.tag;

    LXActionSheet* _menu = [[LXActionSheet alloc]
                            initWithTitle:nil
                            delegate:self
                            cancelButtonTitle:nil
                            destructiveButtonTitle:Localized(@"JX_Cencal")
                            otherButtonTitles:@[Localized(@"JXAlert_NotGag"),Localized(@"JXAlert_GagTenMinute"),Localized(@"JXAlert_GagOneHour"),Localized(@"JXAlert_GagOne"),Localized(@"JXAlert_GagThere"),Localized(@"JXAlert_GagOneWeek"),Localized(@"JXAlert_GagOver")]];
    [g_window addSubview:_menu];
//    [_menu release];
    
}

- (void)didClickOnButtonIndex:(LXActionSheet*)sender buttonIndex:(int)buttonIndex{
    if(buttonIndex==0)
        return;
    NSTimeInterval n = [[NSDate date] timeIntervalSince1970];
    memberData* member = [room.members objectAtIndex:_disable];
    switch (buttonIndex) {
        case 1:
            member.talkTime = 0;
            break;
        case 2:
            member.talkTime = 10*60+n;
            break;
        case 3:
            member.talkTime = 1*3600+n;
            break;
        case 4:
            member.talkTime = 24*3600+n;
            break;
        case 5:
            member.talkTime = 3*24*3600+n;
            break;
        case 6:
            member.talkTime = 7*24*3600+n;
            break;
        case 7:
            member.talkTime = 3000*24*3600+n;
            break;
    }
    [g_server setDisableSay:room.roomId member:member toView:self];

    _modifyType = kRoomRemind_DisableSay;
    _toUserId = [NSString stringWithFormat:@"%ld",member.userId];
    _toUserName = member.userNickName;
//    [self sendSelfMsg:_modifyType content:[NSString stringWithFormat:@"%f",member.talkTime]];

    member = nil;
}
-(void)switchAction:(id) sender{
//    UILabel* p = (UILabel*)[_blackBtn viewWithTag:TAG_LABEL];
    UISwitch *switchButton = (UISwitch*)sender;
    if ((switchButton.tag == 15460)) {  //禁言
        
        memberData *data = [self.room getMember:g_myself.userId];
        if (([data.role intValue] == 1 || [data.role intValue] == 2)) {
            [self onDisableSay];
            return;
        }
        if (switchButton.on) {
            [sender setOn:NO];
            //不是管理员
            [g_App showAlert:Localized(@"JXRoomMemberVC_NotAdminCannotDoThis")];
        }
        
    }else if (switchButton.tag == 15461) {  // 全部禁言
        
        NSTimeInterval n = [[NSDate date] timeIntervalSince1970];
        if (switchButton.on) {
            room.talkTime = 15*24*3600+n;
        }else {
            room.talkTime = 0;
        }
        
        self.user.talkTime = [NSNumber numberWithLong:room.talkTime];
        [self.user updateGroupTalkTime];
        
        self.updateType = [NSNumber numberWithInt:kRoomRemind_RoomAllBanned];
//        [g_server updateRoom:room toView:self];
        [g_server updateRoom:room key:@"talkTime" value:[NSString stringWithFormat:@"%lld",room.talkTime] toView:self];
    }else{
        //    BOOL isButtonOn = [switchButton isOn];
        if ([_user.status intValue] == friend_status_black) {
            _user.status = [NSNumber numberWithInt:friend_status_friend];
            [[JXXMPP sharedInstance].blackList removeObject:_user.userId];
            //        [g_App showAlert:@"开启接收群消息"];
            
        }else {
            _user.status = [NSNumber numberWithInt:friend_status_black];
            [[JXXMPP sharedInstance].blackList addObject:_user.userId];
            //        [g_App showAlert:@"已屏蔽群消息"];
            [_messageFreeSwitch setOn:YES];
            [self messageFreeSwitchAction:_messageFreeSwitch];
        }
        
        //    p = nil;
        [_user update];
        [JXMessageObject msgWithFriendStatus:_user.userId status:[_user.status intValue]];
    }

}
//弃用
-(void)onBlacklist{
    UILabel* p = (UILabel*)[_blackBtn viewWithTag:TAG_LABEL];
    if([_user.status intValue] == friend_status_black){
        _user.status = [NSNumber numberWithInt:friend_status_friend];
        [[JXXMPP sharedInstance].blackList removeObject:_user.userId];
        p.text = Localized(@"JXRoomMemberVC_NotMessage");
    }
    else{
        _user.status = [NSNumber numberWithInt:friend_status_black];
        [[JXXMPP sharedInstance].blackList addObject:_user.userId];
        p.text = Localized(@"JXRoomMemberVC_Accept");
    }
    p = nil;
    [_user update];
    [JXMessageObject msgWithFriendStatus:_user.userId status:[_user.status intValue]];
}

-(void)sendSelfMsg:(int)type content:(NSString*)content{
    if(_modifyType<=0)
        return;
    JXMessageObject* p = [[JXMessageObject alloc]init];
    p.fromUserId = MY_USER_ID;
    p.fromUserName = MY_USER_NAME;
    p.objectId = self.room.roomJid;
    p.fromId = MY_USER_ID;
    p.type = [NSNumber numberWithInt:type];
    p.content = content;
    p.toUserId = _toUserId;
    p.toUserName = _toUserName;
    p.timeSend = [NSDate date];
    [p insert:p.fromId];
    [p notifyNewMsg];
    
    _toUserId = nil;
    _toUserName = nil;
    _modifyType = 0;
}

-(void)specifyAdministrator{
    
    memberData *data = [self.room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"JXRoomMemberVC_NotGroupMarsterCannotDoThis")];
        return;
    }
    
    JXSelFriendVC * selVC = [[JXSelFriendVC alloc] init];
    selVC.type = JXSelUserTypeSpecifyAdmin;
    selVC.room = room;
    selVC.delegate = self;
    selVC.didSelect = @selector(specifyAdministratorDelegate:);
//    [g_window addSubview:selVC.view];
    [g_navigation pushViewController:selVC animated:YES];
}

// 群管理
- (void)groupManagement {
    memberData *data = [self.room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"JXRoomMemberVC_NotGroupMarsterCannotDoThis")];
        return;
    }
    
    JXGroupManagementVC *vc = [[JXGroupManagementVC alloc] init];
    vc.room = self.room;
    vc.user = self.user;
    [g_navigation pushViewController:vc animated:YES];
}

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

-(void)readSwitchAction:(UISwitch *)readswitch{
    memberData *data = [self.room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"JXRoomMemberVC_NotGroupMarsterCannotDoThis")];
        [readswitch setOn:!readswitch.isOn];
        return;
    }
    self.updateType = [NSNumber numberWithInt:kRoomRemind_ShowRead];
    room.showRead = _readSwitch.on;
    [g_server updateRoomShowRead:room key:@"showRead" value:room.showRead toView:self];
}


-(void)showUserQRCode{
    
    JXQRCodeViewController * qrVC = [[JXQRCodeViewController alloc] init];
    qrVC.type = QRGroupType;
    qrVC.userId = room.roomId;
    qrVC.nickName = room.name;
    qrVC.roomJId = room.roomJid;
    qrVC.account = room.roomId;
    
//    [g_window addSubview:qrVC.view];
    [g_navigation pushViewController:qrVC animated:YES];
}

-(void)reportUserView{
    JXReportUserVC * reportVC = [[JXReportUserVC alloc] init];
    reportVC.user = self.user;
    reportVC.delegate = self;
    [g_navigation pushViewController:reportVC animated:YES];
    
}

- (void)report:(JXUserObject *)reportUser reasonId:(NSNumber *)reasonId {
    [g_server reportUser:nil roomId:reportUser.roomId webUrl:nil reasonId:reasonId toView:self];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        JXUserObject *user = [[JXUserObject sharedInstance] getUserById:self.user.userId];
        // 清除聊天记
        JXMessageObject *msg = [[JXMessageObject alloc] init];
        msg.isGroup = YES;
        msg.toUserId = self.user.userId;
        [msg deleteAll];
        msg.type = [NSNumber numberWithInt:1];
        msg.content = @" ";
        msg.timeSend = user.timeSend;
        [msg updateLastSend:UpdateLastSendType_None];
        [msg notifyMyLastSend];
        [g_server showMsg:Localized(@"JXAlert_DeleteOK") delay:.5];
        [g_notify postNotificationName:kChatVCReloadNotif object:nil];
        
        // 清除本群所有任务
        [[JXSynTask sharedInstance] deleteTaskWithRoomId:self.roomId];
    }
}



-(int)gethashCode:(NSString *)str {
    // 字符串转hash
    int hash = 0;
    for (int i = 0; i<[str length]; i++) {
        NSString *s = [str substringWithRange:NSMakeRange(i, 1)];
        char *unicode = (char *)[s cStringUsingEncoding:NSUnicodeStringEncoding];
        int charactorUnicode = 0;
        size_t length = strlen(unicode);
        for (int n = 0; n < length; n ++) {
            charactorUnicode += (int)((unicode[n] & 0xff) << (n * sizeof(char) * 8));
        }
        hash = hash * 31 + charactorUnicode;
    }
    return hash;
}

#pragma mark - UICollectionViewDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(52, 70);
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//    if (_isShow) {
//        return CGSizeMake(JX_SCREEN_WIDTH, HEIGHT);
//    }
//    return CGSizeZero;
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
//    if (room.members.count > 8 && _isShow) {
//        return CGSizeMake(JX_SCREEN_WIDTH, 25);
//    }
//    return CGSizeZero;
//}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {

    return 20;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return _widthInset;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {

    return UIEdgeInsetsMake(0, _widthInset, 20, _widthInset);
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _maxShow + 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    JXGroupMemberCell *cell = (JXGroupMemberCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    memberData* user = nil;
    if(indexPath.row < _maxShow){
        if (!_isShow && indexPath.row == 1) {
            for (memberData *member in room.members) {
                NSString *userId = [NSString stringWithFormat:@"%ld",member.userId];
                if ([userId isEqualToString:MY_USER_ID]) {
                    user = member;
                    break;
                }
            }
        }else{
            user = [room.members objectAtIndex:indexPath.row];
        }
    }
    [cell buildNewImageview];
    if(indexPath.row == _maxShow){
        cell.imageView.image = [UIImage imageNamed:@"add"];
    }else if(indexPath.row > _maxShow){
        cell.imageView.image = [UIImage imageNamed:@"lose"];
    }else{
        [g_server getHeadImageSmall:[NSString stringWithFormat:@"%ld",user.userId] userName:user.userNickName imageView:cell.imageView getHeadHandler:nil];
    }
    NSString *name = [NSString string];
    JXUserObject *allUser = [[JXUserObject alloc] init];
    allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",user.userId]];
    if (_isAdmin) {
        name = user.lordRemarkName.length > 0  ? user.lordRemarkName : allUser.remarkName.length > 0  ? allUser.remarkName : user.userNickName;
    }else {
        name = allUser.remarkName.length > 0  ? allUser.remarkName : user.userNickName;
    }
    if (!self.room.allowSendCard && [_data.role intValue] != 1 && [_data.role intValue] != 2) {
        name = [name substringToIndex:[name length]-1];
        name = [name stringByAppendingString:@"*"];
    }
    cell.label.text = name;
    return cell;
}


//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
//        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerView" forIndexPath:indexPath];
//        footerView.backgroundColor = [UIColor whiteColor];
//        _unfoldView = [[JXImageView alloc] initWithFrame:CGRectMake(0, 5, 25, 25)];
//        _unfoldView.center = CGPointMake(JX_SCREEN_WIDTH/2, _unfoldView.center.y);
//        if (_unfoldMode) {
//            _unfoldView.image = [UIImage imageNamed:@"room_unfold"];
//        }else{
//            _unfoldView.image = [UIImage imageNamed:@"pack_up_1"];
//        }
//        _unfoldView.delegate = self;
//        _unfoldView.didTouch = @selector(unfoldViewAction);
//        [_heads addSubview:_unfoldView];
//        return footerView;
//    }else if ([kind isEqualToString:UICollectionElementKindSectionHeader]){
//        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"headerView" forIndexPath:indexPath];
//        headerView.backgroundColor = [UIColor whiteColor];
//        JXImageView* q=[[JXImageView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, HEIGHT)];
//        q.userInteractionEnabled = YES;
//        if(_isAdmin){
//            q.delegate = self;
//            q.didTouch = @selector(onNewNote);
//        }
//        [headerView addSubview:q];
//
//        [_images addObject:q];
//
//
//        JXImageView *p = [self createButton:Localized(@"JX_GroupChatMembers") drawTop:NO drawBottom:NO must:NO click:@selector(onShowMembers) ParentView:q];
//        p.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, HEIGHT);
//        _userNum = [self createLabel:p default:[NSString stringWithFormat:Localized(@"JX_Have%dPeople"),self.userSize] isClick:YES];
//        _userNum.textColor = HEXCOLOR(0x333333);
//        [_images addObject:p];
//        [_images addObject:_userNum];
//    }
//    return nil;
//}

#pragma mark -- UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _maxShow) {
        [self onShowAdd];
    }else if(indexPath.row == _maxShow + 1){
        [self onShowDel];
    }else{
        memberData *data = [self.room getMember:g_myself.userId];

        if ([data.role intValue] != 1 && [data.role intValue] != 2 && !self.room.allowSendCard) {
            [g_App showAlert:Localized(@"JX_OnlyManagerSeeInfo")];
            return;
        }
        memberData *user = nil;
        if (!_isShow && indexPath.row == 1) {
            for (memberData *member in room.members) {
                NSString *userId = [NSString stringWithFormat:@"%ld",member.userId];
                if ([userId isEqualToString:MY_USER_ID]) {
                    user = member;
                    break;
                }
            }
        }else{
            user = room.members[indexPath.row];
        }
        JXUserInfoVC* vc = [JXUserInfoVC alloc];
        vc.userId = [NSString stringWithFormat:@"%ld", user.userId];
        vc.fromAddType = 3;
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
    }
}

- (UICollectionView *)memberListView{
    if (!_memberListView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _memberListView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _memberListView.backgroundColor = [UIColor whiteColor];
        _memberListView.delegate = self;
        _memberListView.dataSource = self;
        [_memberListView registerClass:[JXGroupMemberCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _memberListView;
}
@end
