//
//  JXNewRoomVC.m
//  shiku_im
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXNewRoomVC.h"
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
#import "JXRoomPool.h"
#import "JXSelectFriendsVC.h"

#define HEIGHT 56
#define IMGSIZE 170


@interface JXNewRoomVC ()<UITextFieldDelegate,JXRoomObjectDelegate>

@property (nonatomic, assign) NSInteger roomNameLength;
@property (nonatomic, assign) NSInteger descLength;
@property (nonatomic, strong) JXImageView *GroupValidationBtn;
@property (nonatomic, strong) UISwitch *GroupValidationSwitch;
@property (nonatomic, strong) UISwitch *showGroupMembersSwitch;
@property (nonatomic, strong) UISwitch *sendCardSwitch;

@end

@implementation JXNewRoomVC
@synthesize chatRoom;


- (id)init
{
    self = [super init];
    if (self) {
        self.isGotoBack   = YES;
        self.title = Localized(@"JXNewRoomVC_CreatRoom");
        self.heightFooter = 0;
        self.heightHeader = JX_SCREEN_TOP;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self createHeadAndFoot];
        self.tableBody.backgroundColor = HEXCOLOR(0xF2F2F2);
        self.tableBody.scrollEnabled = YES;
        self.tableBody.showsVerticalScrollIndicator = YES;
        int h = 0;
        
        _room = [[roomData alloc] init];
        _room.maxCount = 10000;
        JXImageView* iv;
        iv = [[JXImageView alloc]init];
        iv.frame = self.tableBody.bounds;
        iv.delegate = self;
        iv.didTouch = @selector(hideKeyboard);
        [self.tableBody addSubview:iv];
//        [iv release];
        
        iv = [self createButton:Localized(@"JX_RoomName") drawTop:NO drawBottom:YES must:NO click:nil];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        _roomName = [self createTextField:iv default:_room.name hint:Localized(@"JX_InputRoomName") type:1];
        h+=iv.frame.size.height;
        
        iv = [self createButton:Localized(@"JX_RoomExplain") drawTop:NO drawBottom:YES must:NO click:nil];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        _desc = [self createTextField:iv default:_room.desc hint:Localized(@"JXNewRoomVC_InputExplain") type:0];
        h+=iv.frame.size.height;
        
        iv = [self createButton:Localized(@"JXRoomMemberVC_CreatPer") drawTop:NO drawBottom:NO must:NO click:nil];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        _userName = [self createLabel:iv default:g_myself.userNickname];
        h+=iv.frame.size.height;
       
#ifdef IS_MsgEncrypt
        if ([g_config.isOpenSecureChat boolValue]) {
            //是否开启私密群组
            iv = [self createButton:Localized(@"JX_WhetherToEnablePrivateGroups") drawTop:YES drawBottom:NO must:NO click:nil];
            iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
            _secretSwitch = [[UISwitch alloc] init];
            _secretSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-5-51,0,0,0);
            _secretSwitch.onTintColor = THEMECOLOR;
            _secretSwitch.center = CGPointMake(_secretSwitch.center.x, iv.frame.size.height/2);
            [_secretSwitch setOn:NO];
            [_secretSwitch addTarget:self action:@selector(secretSwitchAction:) forControlEvents:UIControlEventValueChanged];
            [iv addSubview:_secretSwitch];
            h+=iv.frame.size.height;
        }
        
#endif
        
//        iv = [self createButton:Localized(@"JXRoomMemberVC_PerCount") drawTop:NO drawBottom:YES must:NO click:nil];
//        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//        _size = [self createLabel:iv default:[NSString stringWithFormat:@"%ld/%d",_room.curCount,_room.maxCount]];
//        h+=iv.frame.size.height;
        
//        iv = [self createButton:Localized(@"JX_DisplayGroupMemberList") drawTop:NO drawBottom:YES must:NO click:nil];
//        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//        _showGroupMembersSwitch = [[UISwitch alloc] init];
//        _showGroupMembersSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-5-51,0,0,0);
//        _showGroupMembersSwitch.center = CGPointMake(_showGroupMembersSwitch.center.x, iv.frame.size.height/2);
//        [_showGroupMembersSwitch setOn:YES];
//        [iv addSubview:_showGroupMembersSwitch];
//        h+=iv.frame.size.height;
        
//        iv = [self createButton:@"允许群成员在群组内发送名片" drawTop:NO drawBottom:YES must:NO click:nil];
//        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//        _sendCardSwitch = [[UISwitch alloc] init];
//        _sendCardSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-5-51,0,0,0);
//        _sendCardSwitch.center = CGPointMake(_sendCardSwitch.center.x, iv.frame.size.height/2);
//        [_sendCardSwitch setOn:YES];
//        [iv addSubview:_sendCardSwitch];
//        h+=iv.frame.size.height;
        
//        iv = [self createButton:Localized(@"JX_RoomShowRead") drawTop:NO drawBottom:YES must:NO click:nil];
//        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//        _readSwitch = [[UISwitch alloc] init];
//        _readSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-5-51,0,0,0);
//        _readSwitch.center = CGPointMake(_readSwitch.center.x, iv.frame.size.height/2);
//        [iv addSubview:_readSwitch];
//        h+=iv.frame.size.height;
        
//        if ([g_config.isOpenRoomSearch boolValue]) {
//            iv = [self createButton:Localized(@"JX_PrivateGroups") drawTop:NO drawBottom:YES must:NO click:nil];
//            iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//            _publicSwitch = [[UISwitch alloc] init];
//            _publicSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-5-51,0,0,0);
//            _publicSwitch.onTintColor = THEMECOLOR;
//            _publicSwitch.center = CGPointMake(_publicSwitch.center.x, iv.frame.size.height/2);
//            [_publicSwitch setOn:YES];
//            //        _publicSwitch.userInteractionEnabled = NO;
//            [_publicSwitch addTarget:self action:@selector(publicSwitchAction:) forControlEvents:UIControlEventValueChanged];
//            [iv addSubview:_publicSwitch];
//            h+=iv.frame.size.height;
//        }
        
//        self.GroupValidationBtn = [self createButton:Localized(@"JX_OpenGroupValidation") drawTop:NO drawBottom:YES must:NO click:nil];
//        self.GroupValidationBtn.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//        self.GroupValidationSwitch = [[UISwitch alloc] init];
//        self.GroupValidationSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-5-51,0,0,0);
//        self.GroupValidationSwitch.center = CGPointMake(self.GroupValidationSwitch.center.x, self.GroupValidationBtn.frame.size.height/2);
//        [self.GroupValidationBtn addSubview:self.GroupValidationSwitch];
//        h+=self.GroupValidationBtn.frame.size.height;
        
        h+=20;
        
        UIButton* _btn;
        _btn = [UIFactory createCommonButton:Localized(@"JXNewRoomVC_CreatRoom") target:self action:@selector(onInsert)];
        _btn.custom_acceptEventInterval = .25f;
        _btn.layer.cornerRadius = 7;
        _btn.clipsToBounds = YES;
        _btn.frame = CGRectMake(15,h,JX_SCREEN_WIDTH-30,40);
        [self.tableBody addSubview:_btn];
    }
    return self;
}

-(void)dealloc{
//    NSLog(@"JXNewRoomVC.dealloc");
//    [_room release];
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
        p.font = g_factory.font16;
        p.backgroundColor = [UIColor clearColor];
        p.textColor = [UIColor redColor];
        p.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:p];
    }
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(15, 0, 280, HEIGHT)];
    p.text = title;
    p.font = g_factory.font16;
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

-(UITextField*)createTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint type:(BOOL)name{
    UITextField* p = [[UITextField alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2-15 - 30,INSETS,JX_SCREEN_WIDTH/2 + 30,HEIGHT-INSETS*2)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.borderStyle = UITextBorderStyleNone;
    p.returnKeyType = UIReturnKeyDone;
//    p.clearButtonMode = UITextFieldViewModeAlways;
    p.textAlignment = NSTextAlignmentRight;
    p.userInteractionEnabled = YES;
    p.text = s;
    p.placeholder = hint;
    p.font = g_factory.font16;
    
    if (name) {
        [p addTarget:self action:@selector(textLong12:) forControlEvents:UIControlEventEditingChanged];
    }else{
        [p addTarget:self action:@selector(textLong32:) forControlEvents:UIControlEventEditingChanged];
    }
    [parent addSubview:p];
//    [p release];
    return p;
}

- (void)textLong12:(UITextField *)textField
{
    NSInteger length = [self getTextLength:textField.text];
    
    if (length > 20) {
        textField.text = [textField.text substringToIndex:_roomNameLength];
        [JXMyTools showTipView:Localized(@"JX_CannotEnterMore")];
    }
    _roomNameLength = textField.text.length;
}

- (void)textLong32:(UITextField *)textField
{
    NSInteger length = [self getTextLength:textField.text];
    if (length > 100) {
        textField.text = [textField.text substringToIndex:_descLength];
        [JXMyTools showTipView:Localized(@"JX_CannotEnterMore")];
    }
    _descLength = textField.text.length;
}

- (NSInteger) getTextLength:(NSString *)text {
    NSInteger length = [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSInteger num = (length - text.length) / 2;
    length = length - num;
    
    return length;
}

-(UILabel*)createLabel:(UIView*)parent default:(NSString*)s{
    UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2,INSETS,JX_SCREEN_WIDTH/2 - 15,HEIGHT-INSETS*2)];
    p.userInteractionEnabled = NO;
    p.text = s;
    p.font = g_factory.font16;
    p.textAlignment = NSTextAlignmentRight;
    [parent addSubview:p];
//    [p release];
    return p;
}

- (void)publicSwitchAction:(UISwitch *)publicSwitch {
    
//    if (publicSwitch.on) {
//        self.GroupValidationBtn.hidden = YES;
//        self.GroupValidationSwitch.on = NO;
//    }else {
//        self.GroupValidationBtn.hidden = NO;
//    }
}
         
 - (void)secretSwitchAction:(UISwitch *)secretSwitch {
     
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
    BOOL b = _roomName.editing || _desc.editing;
    [self.view endEditing:YES];
    return b;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

-(void)onInsert{
    
    if ([_roomName.text isEqualToString:@""]) {
        [g_App showAlert:Localized(@"JX_InputRoomName")];
    }
//    else if ([_desc.text isEqualToString:@""]){
//        [g_App showAlert:Localized(@"JXNewRoomVC_InputExplain")];
//    }
    else{
        
#ifdef IS_MsgEncrypt
        if ([g_config.isOpenSecureChat boolValue]) {
            if (!g_msgUtil.rsaPublicKey || g_msgUtil.rsaPublicKey.length <= 0) {
                
                if (_secretSwitch.isOn) {
                    //不支持创建私密群组
                    [JXMyTools showTipView:Localized(@"JX_DoesNotSupportCreatingPrivateGroups")];
                    
                    return;
                }
                
            }
        }
#endif
        
        _roomName.text = [_roomName.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (_roomName.text.length <= 0) {
            //请输入有效的群组名称
            [JXMyTools showTipView:Localized(@"JX_PleaseEnterValidGroupName")];
            return;
        }

        NSString* s = [NSUUID UUID].UUIDString;
        s = [[s stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        
        _room.roomJid= s;
        _room.name   = _roomName.text;
        _room.desc   = _desc.text;
        _room.userId = [g_myself.userId longLongValue];
        _room.userNickName = _userName.text;
        _room.showRead = NO;
        _room.showMember = YES;
        _room.allowSendCard = YES;
        _room.isNeedVerify = NO;
        _room.allowInviteFriend = YES;
        _room.allowUploadFile = YES;
        _room.allowConference = YES;
        _room.allowSpeakCourse = YES;
        _room.isSecretGroup = _secretSwitch.isOn;
        
        NSInteger category = 0;
        if (self.isAddressBook) {
            category = 510;
        }
        
        _chatRoom = [[JXXMPP sharedInstance].roomPool createRoom:s title:_roomName.text];
        _chatRoom.delegate = self;
        
        if (_room.isSecretGroup) {
            
            NSString *g = [NSUUID UUID].UUIDString;
            g = [[g stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
            _room.chatKeyGroup = g;
        }
        [g_server addRoom:_room isPublic:_publicSwitch.on isNeedVerify:self.GroupValidationSwitch.on category:category toView:self];
        
//
//        _chatRoom = [[JXXMPP sharedInstance].roomPool createRoom:s title:_roomName.text];
//        _chatRoom.delegate = self;
        
        [_wait start:Localized(@"JXAlert_CreatRoomIng") delay:30];
    }
    
}

-(void)xmppRoomDidCreate{
    
    NSInteger category = 0;
    if (self.isAddressBook) {
        category = 510;
    }
    
    if (_room.isSecretGroup) {
        
        NSString *g = [NSUUID UUID].UUIDString;
        g = [[g stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        _room.chatKeyGroup = g;
    }
    
    [g_server addRoom:_room isPublic:_publicSwitch.on isNeedVerify:self.GroupValidationSwitch.on category:category toView:self];
    _chatRoom.delegate = nil;
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:act_roomAdd] ){
        
        _chatRoom = [[JXXMPP sharedInstance].roomPool createRoom:_room.roomJid title:_roomName.text];
        _chatRoom.delegate = self;
        
        
        _room.roomId = [dict objectForKey:@"id"];
//        _room.call = [NSString stringWithFormat:@"%@",[dict objectForKey:@"call"]];
        [self insertRoom];
        
        memberData *member = [[memberData alloc] init];
        member.userId = [g_myself.userId longLongValue];
        member.userNickName = MY_USER_NAME;
        member.role = @1;
        [_room.members addObject:member];
        
        JXSelectFriendsVC *vc = [JXSelectFriendsVC alloc];
        vc.chatRoom = _chatRoom;
        vc.room = _room;
        vc.isNewRoom = YES;
        vc.maxSize = [[dict objectForKey:@"maxUserSize"] intValue] - 1;
        if (self.isAddressBook) {
            NSMutableArray *arr = [NSMutableArray array];
            NSMutableSet *existSet = [NSMutableSet set];
            for (NSInteger i = 0; i < self.addressBookArr.count; i ++) {
                JXAddressBook *ab = self.addressBookArr[i];
                JXUserObject *user = [[JXUserObject alloc] init];
                user.userId = ab.toUserId;
                user.userNickname = ab.toUserName;
                [arr addObject:user];
                [existSet addObject:ab.toUserId];
            }
            if (!_room.chatKeyGroup || _room.chatKeyGroup <= 0) {
                
                vc.existSet = [existSet copy];
            }
            vc.addressBookArr = arr;
        }
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
        
//        JXSelFriendVC* vc = [JXSelFriendVC alloc];
//        vc.chatRoom = _chatRoom;
//        vc.room = _room;
//        vc.isNewRoom = YES;
//        vc = [vc init];
////        [g_window addSubview:vc.view];
//        [g_navigation pushViewController:vc animated:YES];
        [g_notify postNotificationName:kUpdateUserNotifaction object:nil];
        [self actionQuit];
//        _pSelf = nil;
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

-(void)insertRoom{
    JXUserObject* user = [[JXUserObject alloc]init];
    user.userNickname = _room.name;
    user.userId = _room.roomJid;
    user.userDescription = _room.desc;
    user.roomId = _room.roomId;
    user.content = Localized(@"JX_WelcomeGroupChat");
    user.showRead =  [NSNumber numberWithBool:_room.showRead];
    user.showMember = [NSNumber numberWithBool:_room.showMember];
    user.allowSendCard = [NSNumber numberWithBool:_room.allowSendCard];
    user.allowInviteFriend = [NSNumber numberWithBool:_room.allowInviteFriend];
    user.allowUploadFile = [NSNumber numberWithBool:_room.allowUploadFile];
    user.allowSpeakCourse = [NSNumber numberWithBool:_room.allowSpeakCourse];
    user.isNeedVerify = [NSNumber numberWithBool:_room.isNeedVerify];
    user.createUserId = [NSString stringWithFormat:@"%ld",_room.userId];
    if (self.isAddressBook) {
        user.category = [NSNumber numberWithInteger:510];
    }
#ifdef IS_MsgEncrypt
    if ([g_config.isOpenSecureChat boolValue]) {
        user.isSecretGroup = [NSNumber numberWithBool:_secretSwitch.isOn];
        if (_room.chatKeyGroup && _room.chatKeyGroup.length > 0) {
            user.chatKeyGroup = [g_msgUtil encryptRoomMsgKey:_room.roomId randomKey:_room.chatKeyGroup];
        }
    }
#endif
    [user insertRoom];
}

@end
