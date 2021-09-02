//
//  JXFaceCreateRoomVC.m
//  shiku_im
//
//  Created by p on 2019/4/16.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXFaceCreateRoomVC.h"
#import "HWTFCodeView.h"
#import "JXChatViewController.h"
#import "JXRoomPool.h"
#import "JXUserObject.h"

#define HEIGHT 50
@interface JXFaceCreateRoomVC ()<HWTFCodeViewDelegate>

@property (nonatomic, strong) UILabel *tip;
@property (nonatomic, strong) UILabel *joinTip;
@property (nonatomic, strong) HWTFCodeView *codeView;
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *usersView;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, copy) NSString *jid;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) NSDictionary *roomDic;

@end

@implementation JXFaceCreateRoomVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = HEXCOLOR(0x181E1F);
    _array = [NSMutableArray array];
    
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP - 46, 46, 46)];
    [closeBtn setBackgroundImage:[[UIImage imageNamed:@"title_back_black_big"] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    JXLabel* title = [[JXLabel alloc]initWithFrame:CGRectMake(60, JX_SCREEN_TOP - 32, JX_SCREEN_WIDTH-60*2, 20)];
    title.backgroundColor = [UIColor clearColor];
    title.textAlignment   = NSTextAlignmentCenter;
    title.textColor       = [UIColor whiteColor];
    title.text = Localized(@"JX_FaceToFaceGroup");
    title.font = [UIFont systemFontOfSize:18.0];
    title.userInteractionEnabled = YES;
    title.didTouch = @selector(actionTitle:);
    title.delegate = self;
    title.changeAlpha = NO;
    [self.view addSubview:title];
    
    
    _tip = [[UILabel alloc] initWithFrame:CGRectMake(50, JX_SCREEN_TOP + 50, JX_SCREEN_WIDTH - 100, 50)];
    _tip.textAlignment = NSTextAlignmentCenter;
    _tip.numberOfLines = 0;
    _tip.textColor = [UIColor lightGrayColor];
    _tip.font = [UIFont systemFontOfSize:15.0];
    _tip.text = Localized(@"JX_IntoSameGroup");
    [self.view addSubview:_tip];
    
    
    HWTFCodeView *code1View = [[HWTFCodeView alloc] initWithCount:4 margin:10];
    code1View.frame = CGRectMake((JX_SCREEN_WIDTH - 150) / 2, CGRectGetMaxY(_tip.frame) + 20, 150, 30);
    code1View.delegate = self;
    [self.view addSubview:code1View];
    self.codeView = code1View;
    
    _joinTip = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(code1View.frame) + 10, JX_SCREEN_WIDTH, 30)];
    _joinTip.textAlignment = NSTextAlignmentCenter;
    _joinTip.numberOfLines = 0;
    _joinTip.textColor = [UIColor lightGrayColor];
    _joinTip.font = [UIFont systemFontOfSize:15.0];
    _joinTip.text = Localized(@"JX_TheseFriendsWillAlsoJoinGroup");
    _joinTip.hidden = YES;
    [self.view addSubview:_joinTip];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_joinTip.frame) + 10, JX_SCREEN_WIDTH - 30, LINE_WH)];
    _lineView.backgroundColor = THE_LINE_COLOR;
    _lineView.hidden = YES;
    [self.view addSubview:_lineView];
    
    _btn = [UIFactory createCommonButton:Localized(@"JX_AccessToGroup") target:self action:@selector(onJoin)];
    _btn.custom_acceptEventInterval = 1.0f;
    _btn.frame = CGRectMake(15, self.view.frame.size.height - HEIGHT - 50-20, JX_SCREEN_WIDTH-30, 40);
    _btn.titleLabel.font = SYSFONT(16);
    _btn.layer.masksToBounds = YES;
    _btn.layer.cornerRadius = 7.f;
    _btn.hidden = YES;
    [self.view addSubview:_btn];
    
    [g_notify addObserver:self selector:@selector(msgRoomFaceNotif:) name:kMsgRoomFaceNotif object:nil];//收到了群控制消息
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
#ifdef XCode11
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
#else
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
#endif
}

-(void)msgRoomFaceNotif:(NSNotification *)notifacation {
    
    [g_server roomLocationQueryWithIsQuery:1 password:self.password toView:self];
}

- (void)createUsers {
    
    CGFloat w = 50;
    CGFloat h = 50;
    int count = 5;
    CGFloat space = 20;
    CGFloat margin = (JX_SCREEN_WIDTH - (w * count) - ((count - 1) * space)) / 2;
    
    if (!_usersView){
        _usersView = [[UIView alloc] init];
        [self.view addSubview:_usersView];
    }
    
    [_usersView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _usersView.frame = CGRectMake(margin, CGRectGetMaxY(_lineView.frame) + 10, JX_SCREEN_WIDTH - margin*2, 0);
    
    CGFloat usersH = 0;
    for (NSInteger i = 0; i < _array.count; i ++) {
        NSDictionary *dict = _array[i];
        CGFloat x = (i % 5) * (w + space);
        CGFloat y = (i / 5) * (w + 30);
        
        UIImageView *head = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        head.layer.cornerRadius = 5;
        head.layer.masksToBounds = YES;
        [g_server getHeadImageLarge:dict[@"userId"] userName:dict[@"nickname"] imageView:head getHeadHandler:nil];
        [_usersView addSubview:head];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(head.frame.origin.x, CGRectGetMaxY(head.frame), head.frame.size.width, 20)];
        name.textAlignment = NSTextAlignmentCenter;
        name.textColor = [UIColor lightGrayColor];
        name.font = [UIFont systemFontOfSize:14.0];
        name.text = dict[@"nickname"];
        [_usersView addSubview:name];
        
        usersH = CGRectGetMaxY(name.frame);
    }
    
    _usersView.frame = CGRectMake(_usersView.frame.origin.x, _usersView.frame.origin.y, _usersView.frame.size.width, usersH);
}

- (void)codeView:(HWTFCodeView *)codeView inputFnish:(NSString *)text {
 
    _codeView.userInteractionEnabled = NO;
    self.password = text;
    [g_server roomLocationQueryWithIsQuery:0 password:text toView:self];
    
}

- (void)onJoin {
    [g_server roomLocationJoinWithJid:self.jid toView:self];
}

- (void)cancelAction {
 
    [self actionQuit];
    
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:act_RoomLocationQuery] ){
        
        [_array removeAllObjects];
        [_array addObjectsFromArray:[dict objectForKey:@"members"]];
        
        self.jid = [dict objectForKey:@"jid"];
        self.roomDic = dict;
        
        if (!_tip.hidden) {
            [UIView animateWithDuration:0.5 animations:^{
                _tip.frame = CGRectMake(_tip.frame.origin.x, _tip.frame.origin.y - 50, _tip.frame.size.width, _tip.frame.size.height);
                _codeView.frame = CGRectMake(_codeView.frame.origin.x, _codeView.frame.origin.y - 50, _codeView.frame.size.width, _codeView.frame.size.height);
            } completion:^(BOOL finished) {
                _joinTip.frame = CGRectMake(_joinTip.frame.origin.x, CGRectGetMaxY(_codeView.frame) + 10, _joinTip.frame.size.width, _joinTip.frame.size.height);
                _lineView.frame = CGRectMake(_lineView.frame.origin.x, CGRectGetMaxY(_joinTip.frame) + 10, _lineView.frame.size.width, _lineView.frame.size.height);
                _tip.hidden = YES;
                _joinTip.hidden = NO;
                _lineView.hidden = NO;
                _btn.hidden = NO;
                [self createUsers];
                
            }];
        }else {
            [self createUsers];
        }
        
    }
    
    if ([aDownload.action isEqualToString:act_RoomLocationJoin]) {
        [self insertRoom:dict];
        
        [self actionQuit];
    }
    
}

-(void)insertRoom:(NSDictionary *)dict{
    JXUserObject* user = [[JXUserObject alloc]init];
    user.userNickname = dict[@"name"];
    user.userId = dict[@"jid"];
    user.userDescription = @"";
    user.roomId = dict[@"id"];
    user.content = Localized(@"JX_WelcomeGroupChat");
    user.showRead =  [NSNumber numberWithBool:[dict[@"showRead"] boolValue]];
    user.showMember = [NSNumber numberWithBool:[dict[@"showMember"] boolValue]];
    user.allowSendCard = [NSNumber numberWithBool:[dict[@"allowSendCard"] boolValue]];
    user.allowInviteFriend = [NSNumber numberWithBool:[dict[@"allowInviteFriend"] boolValue]];
    user.allowUploadFile = [NSNumber numberWithBool:[dict[@"allowUploadFile"] boolValue]];
    user.allowSpeakCourse = [NSNumber numberWithBool:[dict[@"allowSpeakCourse"] boolValue]];
    user.isNeedVerify = [NSNumber numberWithBool:[dict[@"isNeedVerify"] boolValue]];
    user.createUserId = dict[@"userId"];
    [user insertRoom];
    
    [self onNewRoom:user createName:dict[@"nickname"]];
}

-(void)onNewRoom:(JXUserObject *)user createName:(NSString *)createName{
    JXChatViewController *sendView=[JXChatViewController alloc];
    sendView.title = user.userNickname;
    sendView.roomJid = user.userId;
    sendView.roomId = user.roomId;
    sendView.chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:user.userId title:user.userNickname lastDate:nil isNew:YES];
    
    roomData *room = [[roomData alloc] init];
    room.roomJid= user.userId;
    room.roomId = user.roomId;
    room.name   = user.userNickname;
    room.desc   = @"";
    room.userId = [g_myself.userId longLongValue];
    room.userNickName = createName;
    room.showRead = NO;
    room.showMember = YES;
    room.allowSendCard = YES;
    room.isNeedVerify = NO;
    room.allowInviteFriend = YES;
    room.allowUploadFile = YES;
    room.allowConference = YES;
    room.allowSpeakCourse = YES;
    
    sendView.room = room;
    
    sendView.chatPerson = user;
    
    sendView = [sendView init];
    //    [g_App.window addSubview:sendView.view];
    [g_navigation pushViewController:sendView animated:YES];
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


- (void)actionQuit {
    
    [g_server roomLocationExitWithJid:self.jid toView:self];
    [super actionQuit];
    
}

- (void)dealloc {
 
    [g_notify removeObserver:self];
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
