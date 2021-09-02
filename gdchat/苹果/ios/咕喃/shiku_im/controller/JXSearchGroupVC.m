//
//  JXSearchGroupVC.m
//  shiku_im
//
//  Created by p on 2019/4/1.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXSearchGroupVC.h"
#import "JXCell.h"
#import "JXRoomPool.h"
#import "JXRoomObject.h"
#import "JXRoomRemind.h"
#import "JXChatViewController.h"

@interface JXSearchGroupVC ()

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) JXRoomObject *chatRoom;
@property (assign,nonatomic) NSInteger sel;

@property (nonatomic, copy) NSString *roomJid;
@property (nonatomic, copy) NSString *roomUserId;
@property (nonatomic, copy) NSString *roomUserName;

@property (nonatomic, strong) JXInputRectView *inputRectView;


@end

@implementation JXSearchGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.title = Localized(@"JX_ManyPerChat");
    //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM);
    self.isGotoBack = YES;
    [self createHeadAndFoot];
    
    _array = [NSMutableArray array];
    
    _page=0;
    [self getServerData];
}

-(void)getServerData{
    
    [g_server listRoom:_page roomName:self.searchName toView:self];
    
}
#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellName = [NSString stringWithFormat:@"groupJXCell"];
    JXCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    NSDictionary *dataDict = _array[indexPath.row];
    if(cell==nil){
        cell = [[JXCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];;
        [_table addToPool:cell];
    }
    cell.delegate = self;
//    cell.didTouch = @selector(onHeadImage:);
    //    [cell groupCellDataSet:dict indexPath:indexPath];
    
    NSTimeInterval t = [[dataDict objectForKey:@"createTime"] longLongValue];
    NSDate* d = [NSDate dateWithTimeIntervalSince1970:t];
    
    cell.index = (int)indexPath.row;
    //    if (_selMenu == 0) {
    //        cell.title = dataDict[@"name"];
    //    }else
    cell.title = [NSString stringWithFormat:@"%@(%@%@)",dataDict[@"name"],dataDict[@"userSize"],Localized(@"JXLiveVC_countPeople")];
    //    }
    cell.subtitle = [dataDict objectForKey:@"desc"];
    cell.bottomTitle = [TimeUtil formatDate:d format:@"MM-dd HH:mm"];
    cell.userId = [dataDict objectForKey:@"userId"];
    
    cell.headImageView.tag = (int)indexPath.row;
    cell.headImageView.delegate = self;
//    cell.headImageView.didTouch = @selector(onHeadImage:);
    
    [cell.lbTitle setText:cell.title];
    cell.lbTitle.tag = cell.index;
    
    [cell.lbSubTitle setText:cell.subtitle];
    [cell.timeLabel setText:cell.bottomTitle];
    cell.bageNumber.delegate = self;
    //    bageNumber.didDragout = self.didDragout;
    cell.bage = cell.bage;
    
    NSString * roomIdStr = dataDict[@"id"];
    cell.roomId = roomIdStr;
    [cell headImageViewImageWithUserId:[dataDict objectForKey:@"roomId"] roomId:roomIdStr];
    cell.isSmall = NO;
    
    [self doAutoScroll:indexPath];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if(g_xmpp.isLogined != 1){
        // 掉线后点击title重连
        // 判断XMPP是否在线  不在线重连
        [g_xmpp showXmppOfflineAlert];
        return;
    }
    _sel = indexPath.row;
    NSDictionary *dict = _array[indexPath.row];
    
    JXUserObject *user = [[JXUserObject sharedInstance] getUserById:[dict objectForKey:@"jid"]];
    
    if(user && [user.groupStatus intValue] == 0){
        
        _chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] lastDate:nil isNew:YES];
        //老房间:
        [self showChatView];
    }else{
        
        BOOL isNeedVerify = [dict[@"isNeedVerify"] boolValue];
        long userId = [dict[@"userId"] longLongValue];
        if (isNeedVerify && userId != [g_myself.userId longLongValue]) {
            
            self.roomJid = [dict objectForKey:@"jid"];
            self.roomUserName = [dict objectForKey:@"nickname"];
            self.roomUserId = [dict objectForKey:@"userId"];            
            
            self.inputRectView = [[JXInputRectView alloc] initWithFrame:self.view.bounds sureBtnTitle:Localized(@"JX_Send")];
            self.inputRectView.title = Localized(@"JX_GroupOwnersHaveEnabled");
            self.inputRectView.placeString = Localized(@"JX_PleaseEnterTheReason");
            self.inputRectView.delegate = self;
            self.inputRectView.onRelease = @selector(onInputHello);
            
            [g_window addSubview:self.inputRectView];
            
        }else {
            
            _chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] lastDate:nil isNew:YES];
            [_wait start:Localized(@"JXAlert_AddRoomIng") delay:30];
            //新房间:
            _chatRoom.delegate = self;
            [_chatRoom joinRoom:YES];
        }
    }
    dict = nil;
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

-(void)onInputHello{
    [self.inputRectView hide];
    
    JXMessageObject *msg = [[JXMessageObject alloc] init];
    msg.fromUserId = MY_USER_ID;
    msg.toUserId = [NSString stringWithFormat:@"%@", self.roomUserId];
    msg.fromUserName = MY_USER_NAME;
    msg.toUserName = self.roomUserName;
    msg.timeSend = [NSDate date];
    msg.type = [NSNumber numberWithInt:kRoomRemind_NeedVerify];
    msg.content = @"";
    NSString *userIds = g_myself.userId;
    NSString *userNames = g_myself.userNickname;
    NSDictionary *dict = @{
                           @"userIds" : userIds,
                           @"userNames" : userNames,
                           @"roomJid" : self.roomJid,
                           @"reason" : self.inputRectView.text,
                           @"isInvite" : [NSNumber numberWithBool:YES]
                           };
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    msg.objectId = jsonStr;
    [g_xmpp sendMessage:msg roomName:nil];
    
    //    msg.fromUserId = self.roomJid;
    //    msg.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
    //    msg.content = @"申请已发送给群主，请等待群主确认";
    //    [msg insert:self.roomJid];
    //    if ([self.delegate respondsToSelector:@selector(needVerify:)]) {
    //        [self.delegate needVerify:msg];
    //    }
}

-(void)xmppRoomDidJoin{
    
    NSDictionary *dict = _array[_sel];
    JXUserObject* user = [[JXUserObject alloc]init];
    user.userNickname = [dict objectForKey:@"name"];
    user.userId = [dict objectForKey:@"jid"];
    user.userDescription = [dict objectForKey:@"desc"];
    user.roomId = [dict objectForKey:@"id"];
    user.showRead = [dict objectForKey:@"showRead"];
    user.showMember = [dict objectForKey:@"showMember"];
    user.allowSendCard = [dict objectForKey:@"allowSendCard"];
    user.chatRecordTimeOut = [dict objectForKey:@"chatRecordTimeOut"];
    user.talkTime = [dict objectForKey:@"talkTime"];
    user.allowInviteFriend = [dict objectForKey:@"allowInviteFriend"];
    user.allowUploadFile = [dict objectForKey:@"allowUploadFile"];
    user.allowConference = [dict objectForKey:@"allowConference"];
    user.allowSpeakCourse = [dict objectForKey:@"allowSpeakCourse"];
    user.isNeedVerify = [dict objectForKey:@"isNeedVerify"];
    if (![user haveTheUser])
        [user insertRoom];
    //    else
    //        [user update];
    //    [user release];
    
//    [g_server addRoomMember:[dict objectForKey:@"id"] userId:g_myself.userId nickName:g_myself.userNickname toView:self];
    [g_server roomJoin:[dict objectForKey:@"id"] userId:g_myself.userId nickName:g_myself.userNickname toView:self];

    dict = nil;
    _chatRoom.delegate = nil;
    
    [self showChatView];
}

-(void)startReconnect{
    
    for (int i = 0; i < [_array count]; i++) {
        NSDictionary *dict=_array[i];
        
        JXUserObject* user = [[JXUserObject alloc]init];
        user.userNickname = [dict objectForKey:@"name"];
        user.userId = [dict objectForKey:@"jid"];
        user.userDescription = [dict objectForKey:@"desc"];
        user.roomId = [dict objectForKey:@"id"];
        user.showRead = [dict objectForKey:@"showRead"];
        user.showMember = [dict objectForKey:@"showMember"];
        user.allowSendCard = [dict objectForKey:@"allowSendCard"];
        user.chatRecordTimeOut = [dict objectForKey:@"chatRecordTimeOut"];
        user.talkTime = [dict objectForKey:@"talkTime"];
        user.allowInviteFriend = [dict objectForKey:@"allowInviteFriend"];
        user.allowUploadFile = [dict objectForKey:@"allowUploadFile"];
        user.allowConference = [dict objectForKey:@"allowConference"];
        user.allowSpeakCourse = [dict objectForKey:@"allowSpeakCourse"];
        user.isNeedVerify = [dict objectForKey:@"isNeedVerify"];
        if (![user haveTheUser])
            [user insertRoom];
        else
            [user update];
        //        [user release];
        
        [g_server addRoomMember:[dict objectForKey:@"id"] userId:g_myself.userId nickName:g_myself.userNickname toView:self];
        
        dict = nil;
        _chatRoom.delegate = nil;
    }
}

-(void)showChatView{
    [_wait stop];
    NSDictionary *dict = _array[_sel];
    
    roomData * roomdata = [[roomData alloc] init];
    [roomdata getDataFromDict:dict];
    
    JXChatViewController *sendView=[JXChatViewController alloc];
    sendView.title = [dict objectForKey:@"name"];
    sendView.roomJid = [dict objectForKey:@"jid"];
    sendView.roomId = [dict objectForKey:@"id"];
    sendView.chatRoom = _chatRoom;
    sendView.room = roomdata;
    
    JXUserObject * userObj = [[JXUserObject alloc]init];
    userObj.userId = [dict objectForKey:@"jid"];
    userObj.userDescription = [dict objectForKey:@"desc"];
    userObj.roomId = [dict objectForKey:@"id"];
    if (userObj.roomId && userObj.roomId.length > 0) {
        userObj.roomFlag = [NSNumber numberWithInt:1];
    }else {
        userObj.roomFlag = [NSNumber numberWithInt:0];
    }
    userObj.timeCreate = [NSDate date];
    userObj.showRead = [dict objectForKey:@"showRead"];
    userObj.showMember = [dict objectForKey:@"showMember"];
    userObj.allowSendCard = [dict objectForKey:@"allowSendCard"];
    userObj.userNickname = [dict objectForKey:@"name"];
    userObj.chatRecordTimeOut = roomdata.chatRecordTimeOut;
    userObj.talkTime = [dict objectForKey:@"talkTime"];
    userObj.allowInviteFriend = [dict objectForKey:@"allowInviteFriend"];
    userObj.allowUploadFile = [dict objectForKey:@"allowUploadFile"];
    userObj.allowConference = [dict objectForKey:@"allowConference"];
    userObj.allowSpeakCourse = [dict objectForKey:@"allowSpeakCourse"];
    userObj.isNeedVerify = [dict objectForKey:@"isNeedVerify"];
    sendView.chatPerson = userObj;
    
    sendView = [sendView init];
    //    [g_App.window addSubview:sendView.view];
    [g_navigation pushViewController:sendView animated:YES];
    
    dict = nil;
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    
    [self stopLoading];
    if([aDownload.action isEqualToString:act_roomList]){
        self.isShowFooterPull = [array1 count]>=jx_page_size;

        if(_page == 0){
            [_array removeAllObjects];
            
            if([array1 count]>0)
                [_array addObjectsFromArray:array1];
        }
        
        [_table reloadData];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
