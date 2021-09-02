//
//  JXTalkViewController.m
//  lveliao_IM
//
//  Created by p on 2019/6/18.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXTalkViewController.h"
#import "UIImage+Color.h"
#import "JXTalkCell.h"
#import "JXTalkModel.h"
#import "JXTalkDetailView.h"

@interface JXTalkViewController ()<UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIImageView *headImage;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UIButton *talkBtn;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL isSpeak;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int timerNum;
@property (nonatomic, strong) NSTimer *pingTimer;
@property (nonatomic, assign) int pingTimerNum;
@property (nonatomic, copy) NSString *currentUserId;
@property (nonatomic, strong) NSMutableArray *talkArray;

@property (nonatomic, strong) UIImageView *idleImageView;
@property (nonatomic, strong) UIImageView *aniImageView;
@property (nonatomic, strong) UIImageView *freeIcon;
@property (nonatomic, strong) UIImageView *holdIcon;
@property (nonatomic, strong) UILabel *talkBtnLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) JXTalkDetailView *talkView;

@end

@implementation JXTalkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isGotoBack = YES;
    self.heightHeader = 0;
    self.heightFooter = 0;
    self.view.frame = g_window.bounds;
    [self createHeadAndFoot];
    
    self.talkArray = [NSMutableArray array];
    
    JXTalkModel *model = [[JXTalkModel alloc] init];
    model.userId = g_myself.userId;
    model.userName = g_myself.userNickname;
    model.lastTime = 0;
    model.talkTime = 0;
    [self.talkArray addObject:model];
    
    
    [self customView];
    
    [g_notify addObserver:self selector:@selector(newMsgCome:) name:kXMPPNewMsgNotifaction object:nil];
    [g_notify addObserver:self selector:@selector(refreshTalkList:) name:kRefreshTalkListNotification object:nil];
}

- (void)dealloc {
 
    [g_notify removeObserver:self];
    [_timer invalidate];
    _timer = nil;
    [_pingTimer invalidate];
    _pingTimer = nil;
}

- (JXTalkDetailView *)talkView {
 
    if (!_talkView) {
        _talkView = [[JXTalkDetailView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_talkView];
    }
    
    return _talkView;
}

- (void)refreshTalkList:(NSNotification *)notif {
    [_collectionView reloadData];
}

- (void)customView {
    
    self.tableBody.backgroundColor = [UIColor whiteColor];
    self.tableBody.contentSize = CGSizeMake(0, 0);
    
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 24, JX_SCREEN_WIDTH - 30, JX_SCREEN_HEIGHT - 48)];
    backImageView.image = [UIImage imageNamed:@"Talk_BackImage"];
    backImageView.userInteractionEnabled = YES;
    [self.tableBody addSubview:backImageView];
    
    
    UIButton *close = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 47, 24, 32, 32)];
    [close setImage:[UIImage imageNamed:@"Talk_sign_out_icon"] forState:UIControlStateNormal];
    [close addTarget:self action:@selector(talkClose) forControlEvents:UIControlEventTouchUpInside];
    [self.tableBody addSubview:close];
    
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(24, 118, backImageView.frame.size.width - 48, backImageView.frame.size.height - 271)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 20.0;
    contentView.layer.masksToBounds = YES;
    [backImageView addSubview:contentView];
    
    _aniImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 119, 119)];
    _aniImageView.center = CGPointMake(contentView.frame.size.width / 2, _aniImageView.center.y);
    _aniImageView.animationDuration = 1.5;
    _aniImageView.hidden = YES;
    [contentView addSubview:_aniImageView];
    NSMutableArray *aniArr = [[NSMutableArray alloc] init];
    [aniArr addObject:[UIImage imageNamed:@"Talk_Animation_1"]];
    [aniArr addObject:[UIImage imageNamed:@"Talk_Animation_2"]];
    [aniArr addObject:[UIImage imageNamed:@"Talk_Animation_3"]];
    _aniImageView.animationImages = aniArr;
    
    _idleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 54, 91, 91)];
    _idleImageView.center = CGPointMake(contentView.frame.size.width / 2, _idleImageView.center.y);
    _idleImageView.image = [UIImage imageNamed:@"Talk_Idle_circle"];
    _idleImageView.backgroundColor = [UIColor clearColor];
    [contentView addSubview:_idleImageView];
    
    _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 83, 83)];
    _headImage.image = [UIImage imageNamed:@"Talk_BackBtnImage"];
    _headImage.layer.cornerRadius = 5;
    _headImage.layer.masksToBounds = YES;
    [_idleImageView addSubview:_headImage];
    
    _freeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 19, 29, 29)];
    _freeIcon.center = CGPointMake(_idleImageView.frame.size.width / 2, _freeIcon.center.y);
    _freeIcon.image = [UIImage imageNamed:@"Talk_free"];
    [_idleImageView addSubview:_freeIcon];
    
    _name = [[UILabel alloc] initWithFrame:CGRectMake(4, 56, _headImage.frame.size.width, 13)];
    _name.font = [UIFont systemFontOfSize:13.0];
    _name.textColor = HEXCOLOR(0x333333);
    _name.text = Localized(@"JX_InterphoneIdle");
    _name.textAlignment = NSTextAlignmentCenter;
    [_idleImageView addSubview:_name];
    
//    _headImage = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH - 150) /2, THE_DEVICE_HAVE_HEAD ? 40 : 20, 150, 150)];
//    _headImage.image = [UIImage imageNamed:@"Talk_BackBtnImage"];
//    _headImage.layer.cornerRadius = _headImage.frame.size.width / 2;
//    _headImage.layer.masksToBounds = YES;
//    [self.tableBody addSubview:_headImage];
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset =UIEdgeInsetsMake(0,0, 0, 0);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,199,contentView.frame.size.width,contentView.frame.size.height - 229) collectionViewLayout:layout];
    _collectionView.backgroundColor = UIColor.whiteColor;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = YES;
    [_collectionView registerClass:[JXTalkCell class] forCellWithReuseIdentifier:NSStringFromClass([JXTalkCell class])];
    [contentView addSubview:_collectionView];
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(backImageView.frame.origin.x - 24, backImageView.frame.origin.y - 118, backImageView.frame.size.width - 48, backImageView.frame.size.height - 170) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.layer.cornerRadius = 20;
    _tableView.layer.masksToBounds = YES;
    //    _tableView.tableHeaderView = headerView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
//    [self.tableBody addSubview:_tableView];
    
    
    _talkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, backImageView.frame.size.height - 91 - 31, 91, 91)];
    _talkBtn.center = CGPointMake(backImageView.frame.size.width / 2, _talkBtn.center.y);
    [_talkBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.2]] forState:UIControlStateNormal];
    [_talkBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:255/255.0 green:101/255.0 blue:101/255.0 alpha:0.2]] forState:UIControlStateHighlighted];
    [_talkBtn addTarget:self action:@selector(talkStart:) forControlEvents:UIControlEventTouchDown];
    [_talkBtn addTarget:self action:@selector(talkStop:) forControlEvents:UIControlEventTouchUpInside];
    [_talkBtn addTarget:self action:@selector(talkCancel:) forControlEvents:UIControlEventTouchUpOutside];
    _talkBtn.layer.cornerRadius = _talkBtn.frame.size.width / 2;
    _talkBtn.layer.masksToBounds = YES;
//    [_talkBtn setImage:[UIImage imageNamed:@"Talk_Idle_circle"] forState:UIControlStateNormal];
    [backImageView addSubview:_talkBtn];
    
    UIImageView *whiteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 83, 83)];
    whiteImageView.image = [UIImage imageNamed:@"Talk_BackBtnImage"];
    [_talkBtn addSubview:whiteImageView];
    
    _holdIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, 29, 29)];
    _holdIcon.center = CGPointMake(whiteImageView.frame.size.width / 2, _holdIcon.center.y);
    _holdIcon.image = [UIImage imageNamed:@"Talk_hold"];
    [whiteImageView addSubview:_holdIcon];
    
    _talkBtnLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 52, whiteImageView.frame.size.width, 13)];
    _talkBtnLabel.font = [UIFont systemFontOfSize:13.0];
    _talkBtnLabel.textColor = HEXCOLOR(0x333333);
    _talkBtnLabel.text = Localized(@"JXChatVC_TouchTalk");
    _talkBtnLabel.textAlignment = NSTextAlignmentCenter;
    [whiteImageView addSubview:_talkBtnLabel];
    
//    UILabel *talkBtnLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _talkBtn.frame.size.width, 60)];
//    talkBtnLabel.textColor = [UIColor whiteColor];
//    talkBtnLabel.textAlignment = NSTextAlignmentCenter;
//    talkBtnLabel.text = Localized(@"JXChatVC_TouchTalk");
//    [_talkBtn addSubview:talkBtnLabel];
//
//    UIImageView *talkBtnImage = [[UIImageView alloc] initWithFrame:CGRectMake((_talkBtn.frame.size.width - 50) / 2, CGRectGetMaxY(talkBtnLabel.frame), 50, 50)];
//    talkBtnImage.image = [UIImage imageNamed:@"talk_microphone"];
//    [_talkBtn addSubview:talkBtnImage];
    
    
//    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_name.frame), JX_SCREEN_WIDTH, 40)];
//    tipView.backgroundColor = HEXCOLOR(0xCBE2FF);
//    [self.tableBody addSubview:tipView];
//
//    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, tipView.frame.size.width - 20, tipView.frame.size.height)];
//    tipLabel.text = Localized(@"JX_ConversationPersonnel");
//    [tipView addSubview:tipLabel];
    
}

- (void)talkStart:(UIButton *)btn {
    
    if (!self.isSpeak) {
        if ([self.delegate respondsToSelector:@selector(talkVCTalkStart)]) {
            [self.delegate talkVCTalkStart];
        }
        
        NSInteger index = 0;
        JXTalkModel *talkModel = [[JXTalkModel alloc] init];
        for (NSInteger i = 0; i < self.talkArray.count; i ++) {
            JXTalkModel *model = self.talkArray[i];
            if ([model.userId isEqualToString:g_myself.userId]) {
                index = i;
                talkModel.userId = model.userId;
                talkModel.userName = model.userName;
                talkModel.lastTime = model.lastTime;
                talkModel.talkTime = model.talkTime;
                break;
            }
        }
        
        [self.talkArray removeObjectAtIndex:index];
        [self.talkArray insertObject:talkModel atIndex:0];
        [_collectionView reloadData];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [g_server getHeadImageLarge:g_myself.userId userName:g_myself.userNickname imageView:_headImage];
            _name.hidden = YES;
            _freeIcon.hidden = YES;
            _idleImageView.image = nil;
            _aniImageView.hidden = NO;
            [_aniImageView startAnimating];
            
            _talkBtnLabel.textColor = HEXCOLOR(0xFF6565);
            _holdIcon.image = [UIImage imageNamed:@"Talk_hold_h"];
            [g_notify postNotificationName:@"TalkActionNotfi" object:@{@"type":@"1", @"userId":g_myself.userId}];
        });
        
        [self sendSetSpeakerMsg];
        [self sendOnlineMsg:nil];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onlineTimerAction:) userInfo:nil repeats:YES];
    }
    
}

- (void)onlineTimerAction:(NSTimer *)timer {
    self.timerNum ++;
    if (self.timerNum % 5 == 0) {
        [self sendOnlineMsg:nil];
    }
}

- (void)talkStop:(UIButton *)btn {
    
    if ([self.delegate respondsToSelector:@selector(talkVCTalkStop)]) {
        [self.delegate talkVCTalkStop];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _headImage.image = [UIImage imageNamed:@"Talk_BackBtnImage"];
        _name.hidden = NO;
        _freeIcon.hidden = NO;
        [_aniImageView stopAnimating];
        _aniImageView.hidden = YES;
        _idleImageView.image = [UIImage imageNamed:@"Talk_Idle_circle"];
        
        _talkBtnLabel.textColor = HEXCOLOR(0x333333);
        _holdIcon.image = [UIImage imageNamed:@"Talk_hold"];
        [g_notify postNotificationName:@"TalkActionNotfi" object:@{@"type":@"0", @"userId":g_myself.userId}];
    });
   
    [self sendAllSpeakerMsg];
    [_timer invalidate];
    _timer = nil;
}

- (void)talkCancel:(UIButton *)btn {
    
    [self talkStop:btn];
//    _talkBtn.state = UIControlStateNormal;
}

- (void)sendOnlineMsg:(JXMessageObject *)msg1 {
    JXMessageObject *msg=[[JXMessageObject alloc]init];
    msg.content      = nil;
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    msg.fromUserName = MY_USER_NAME;
    msg.toUserId     = self.roomNum;
    msg.isGroup = YES;
    msg.type         = [NSNumber numberWithInt:kWCMessageTypeTalkOnline];
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isRead       = [NSNumber numberWithBool:NO];
    msg.isReadDel    = [NSNumber numberWithInt:NO];
    msg.sendCount    = 1;
    msg.objectId = self.roomNum;
    [msg insert:nil];
    [g_xmpp sendMessage:msg roomName:self.roomNum];//发送消息
}

- (void)talkClose {
    
    if ([self.delegate respondsToSelector:@selector(talkVCCloseBtnAction)]) {
        [self.delegate talkVCCloseBtnAction];
    }
    [self sendQuitTalkMsg];
    
    JXTalkModel *model = self.talkArray.firstObject;
    model.lastTime = 0;
    model.talkTime = 0;
}

// 发送轮麦消息
- (void)sendSetSpeakerMsg {
    JXMessageObject *msg = [[JXMessageObject alloc] init];
    msg.content      = nil;
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    msg.fromUserName = MY_USER_NAME;
    msg.toUserId     = self.roomNum;
    msg.isGroup = YES;
    msg.type         = [NSNumber numberWithInt:kWCMessageTypeAudioMeetingSetSpeaker];
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isRead       = [NSNumber numberWithBool:NO];
    msg.isReadDel    = [NSNumber numberWithInt:NO];
    msg.sendCount    = 1;
    msg.objectId = self.roomNum;
    [msg insert:nil];
    [g_xmpp sendMessage:msg roomName:self.roomNum];//发送消息
}

// 发送取消轮麦消息
- (void)sendAllSpeakerMsg {
    JXMessageObject *msg = [[JXMessageObject alloc] init];
    msg.content      = nil;
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    msg.fromUserName = MY_USER_NAME;
    msg.toUserId     = self.roomNum;
    msg.isGroup = YES;
    msg.type         = [NSNumber numberWithInt:kWCMessageTypeAudioMeetingAllSpeaker];
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isRead       = [NSNumber numberWithBool:NO];
    msg.isReadDel    = [NSNumber numberWithInt:NO];
    msg.sendCount    = 1;
    msg.objectId = self.roomNum;
    [msg insert:nil];
    [g_xmpp sendMessage:msg roomName:self.roomNum];//发送消息
}

- (void)newMsgCome:(NSNotification *)notif {
    
    JXMessageObject *msg = notif.object;
    if ([msg.fromUserId isEqualToString:g_myself.userId]) {
        return;
    }
    if ([msg.type intValue] == kWCMessageTypeAudioMeetingSetSpeaker) {
        if (!self.isSpeak) {
            self.isSpeak = YES;
            _talkBtn.enabled = NO;
            _currentUserId = msg.fromUserId;
            NSInteger index = 0;
            JXTalkModel *talkModel = [[JXTalkModel alloc] init];
            for (NSInteger i = 0; i < self.talkArray.count; i ++) {
                JXTalkModel *model = self.talkArray[i];
                if ([model.userId isEqualToString:msg.fromUserId]) {
                    index = i;
                    talkModel.userId = model.userId;
                    talkModel.userName = model.userName;
                    talkModel.lastTime = model.lastTime;
                    talkModel.talkTime = model.talkTime;
                    break;
                }
            }
            
            [self.talkArray removeObjectAtIndex:index];
            [self.talkArray insertObject:talkModel atIndex:0];
            [_collectionView reloadData];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                [g_server getHeadImageLarge:msg.fromUserId userName:msg.fromUserName imageView:_headImage];
                _name.hidden = YES;
                _freeIcon.hidden = YES;
                _idleImageView.image = nil;
                _aniImageView.hidden = NO;
                [_aniImageView startAnimating];
                
                [g_notify postNotificationName:@"TalkActionNotfi" object:@{@"type":@"1", @"userId":msg.fromUserId}];
            });
            
            _pingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(pingTimerAction:) userInfo:nil repeats:YES];
        }
    }
    
    if ([msg.type intValue] == kWCMessageTypeAudioMeetingAllSpeaker) {
        self.isSpeak = NO;
        _talkBtn.enabled = YES;
        _headImage.image = [UIImage imageNamed:@"Talk_BackBtnImage"];
        _name.hidden = NO;
        _freeIcon.hidden = NO;
        [_aniImageView stopAnimating];
        _aniImageView.hidden = YES;
        _idleImageView.image = [UIImage imageNamed:@"Talk_Idle_circle"];
        
        [g_notify postNotificationName:@"TalkActionNotfi" object:@{@"type":@"0", @"userId":msg.fromUserId}];
        [_pingTimer invalidate];
        _pingTimer = nil;
    }
    
    
    if ([msg.type intValue] == kWCMessageTypeTalkJoin || [msg.type intValue] == kWCMessageTypeTalkOnline) {
        
        BOOL flag = NO;
        for (JXTalkModel *model in self.talkArray) {
            if ([model.userId isEqualToString:msg.fromUserId]) {
                flag = YES;
                break;
            }
        }
        
        if (!flag) {
            JXTalkModel *model = [[JXTalkModel alloc] init];
            model.userId = msg.fromUserId;
            model.userName = msg.fromUserName;
            model.lastTime = 0;
            model.talkTime = 0;
            [self.talkArray addObject:model];
            [_collectionView reloadData];
        }
        
        if ([msg.type intValue] == kWCMessageTypeTalkOnline) {
            self.pingTimerNum = 0;
        }
        
        
        if ([msg.type intValue] == kWCMessageTypeTalkJoin) {
            [self sendOnlineMsg:msg];
        }
    }
    
    if ([msg.type intValue] == kWCMessageTypeTalkQuit) {
        NSInteger index = -1;
        for (NSInteger i = 0; i < self.talkArray.count; i ++) {
            JXTalkModel *model = self.talkArray[i];
            if ([model.userId isEqualToString:msg.fromUserId]) {
                index = i;
                break;
            }
        }
        
        
        if (index >= 0) {
            [self.talkArray removeObjectAtIndex:index];
            [_collectionView reloadData];
        }
    }
}

- (void)pingTimerAction:(NSTimer *)timer {
    
    self.pingTimerNum ++;
    
    if (self.pingTimerNum > 10) {
        _name.text = Localized(@"JX_NetWorkError");
    }
    
    if (self.pingTimerNum > 15) {
        self.isSpeak = NO;
        _talkBtn.enabled = YES;
        _headImage.image = [UIImage imageNamed:@"avatar_normal"];
        _name.text = Localized(@"JX_InterphoneIdle");
        [g_notify postNotificationName:@"TalkActionNotfi" object:@{@"type":@"0", @"userId":_currentUserId}];
        [_pingTimer invalidate];
        _pingTimer = nil;
    }
    
}

- (void)sendQuitTalkMsg {
    JXMessageObject *msg=[[JXMessageObject alloc]init];
    msg.content      = nil;
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    msg.fromUserName = MY_USER_NAME;
    msg.toUserId     = self.roomNum;
    msg.isGroup = YES;
    msg.type         = [NSNumber numberWithInt:kWCMessageTypeTalkQuit];
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isRead       = [NSNumber numberWithBool:NO];
    msg.isReadDel    = [NSNumber numberWithInt:NO];
    msg.sendCount    = 1;
    msg.objectId = self.roomNum;
    [msg insert:nil];
    [g_xmpp sendMessage:msg roomName:self.roomNum];//发送消息
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//
//    return self.talkArray.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    JXTalkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JXTalkCell"];
//
//    if (!cell) {
//        cell = [[JXTalkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JXTalkCell"];
//    }
//    JXTalkModel *model = [self.talkArray objectAtIndex:indexPath.row];
//    cell.talkModel = model;
//    return cell;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    return 60;
//}


#pragma mark UICollectionView delegate
#pragma mark-----多少组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
#pragma mark-----多少个
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.talkArray.count;
}
#pragma mark-----每一个的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(92, 93);
}
#pragma mark-----每一个边缘留白
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
#pragma mark-----最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
#pragma mark-----最小竖间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
#pragma mark-----返回每个单元格是否可以被选择
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
#pragma mark-----创建单元格
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    JXTalkCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([JXTalkCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    JXTalkModel *model = [self.talkArray objectAtIndex:indexPath.row];
    cell.talkModel = model;
    
    return cell;
    
}
#pragma mark-----点击单元格
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    JXTalkModel *model = [self.talkArray objectAtIndex:indexPath.row];
    
    self.talkView.hidden = NO;
    [g_server getHeadImageLarge:model.userId userName:model.userName imageView:self.talkView.headImageView];
    self.talkView.nameLabel.text = model.userName;
    if (model.lastTime > 0) {
        self.talkView.lastLabel.text = [NSString stringWithFormat:@"上次抢麦：%@", [TimeUtil formatDate:[NSDate dateWithTimeIntervalSince1970:model.lastTime] format:@"HH:mm:ss"]];
    }else {
        self.talkView.lastLabel.text = [NSString stringWithFormat:@"上次抢麦："];
    }
    
    if (model.talkTime > 0) {
        self.talkView.talkLable.text = [NSString stringWithFormat:@"发言时间：%@",[TimeUtil getTimeShort1:model.talkTime]];
    }else {
        self.talkView.talkLable.text = [NSString stringWithFormat:@"发言时间："];
    }
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
