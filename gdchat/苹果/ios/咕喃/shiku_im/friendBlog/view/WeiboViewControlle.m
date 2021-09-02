//
//  WeiboViewControlle.m
//  wq
//
//  Created by weqia on 13-8-28.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//

#import "WeiboViewControlle.h"
#import "WeiboCell.h"
#import "ObjUrlData.h"
#import "JSONKit.h"
#import "LXActionSheet.h"
#import "addMsgVC.h"
#import "JXTextView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "photosViewController.h"
//#import "mvViewController.h"
//#import "userInfoVC.h"
#import "JXUserInfoVC.h"
//#import "JXCell.h"
#import "webpageVC.h"
#import "JXBlogRemind.h"
#import "JXTabMenuView.h"
#import "JXBlogRemindVC.h"
#import "JX_DownListView.h"
#import "JXReportUserVC.h"
#import "JXActionSheetVC.h"
#import "JXMenuView.h"
#import "ImageResize.h"
#import "JXCameraVC.h"
#import <WebKit/WebKit.h>

#define TopHeight 7
#define CellHeight 45

@interface WeiboViewControlle ()<UIAlertViewDelegate,JXActionSheetVCDelegate,JXSelectMenuViewDelegate,JXMenuViewDelegate,WeiboCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,JXCameraVCDelegate>
{
    BOOL _first;
    NSString * phoneNumber;
    WKWebView * webView;
    
    NSMutableArray * _images;  //测试用
    NSMutableArray * _contents;
    
    UIImageView *_topBackImageView;
}
@property (nonatomic,copy)NSString *urlStr;
@property (nonatomic, strong) JXMessageObject *remindMsg;
@property (nonatomic, strong) NSMutableArray *remindArray;

@property (nonatomic, strong) WeiboData *currentData;
@property (nonatomic, strong) JXActionSheetVC *actionVC;

@property (nonatomic, strong) WeiboCell *lastCell;   // 用于点赞、评论控件， 记录上个cell

//@property (nonatomic, strong) NSMutableArray *collectArray;

@property (nonatomic, assign) BOOL isFirstGoin;
@property (nonatomic, strong) NSString *topImageUrl;

@end

@implementation WeiboViewControlle
@synthesize replyDataTemp,selectWeiboData,deleteWeibo,refreshCount,refreshCellIndex,selectWeiboCell,user;


- (id)init
{
    self = [super init];
    if (self) {
        _pool = [[NSMutableArray alloc]init];
        refreshCellIndex = -1;
        //self.isGotoBack   = NO;
//        self.title = Localized(@"WeiboViewControlle_MyFriend");
        self.title = @"社交圈";
  
        if (self.isDetail) {
            self.isGotoBack   = YES;
            self.title = Localized(@"JX_Detail");
        }
        
//        _input.delegate = self;
        self.heightFooter = 0;
        self.heightHeader = JX_SCREEN_TOP;
#ifdef IS_SHOW_MENU
        self.isGotoBack = YES;
#endif
        self.isGotoBack = YES;

        
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self createHeadAndFoot];
        if (!self.isDetail && [self.user.userId isEqualToString:MY_USER_ID]) {
            [self buildAddMsg];
        }else {
            self.isShowFooterPull = NO;
        }
        [self buildInput];
        _first = YES;
        replyDataTemp = [[WeiboReplyData alloc]init];
        _datas=[[NSMutableArray alloc]init];
        
        [g_notify addObserver:self selector:@selector(doRefresh:) name:kUpdateUserNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(urlTouch:) name:kCellTouchUrlNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(phoneTouch:) name:kCellTouchPhoneNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(remindNotif:) name:kXMPPMessageWeiboRemind object:nil];
        [g_notify addObserver:self selector:@selector(didEnterBackground:) name:kApplicationDidEnterBackground object:nil];

        _remindArray = [[JXBlogRemind sharedInstance] doFetchUnread];
        if (_remindArray.count > 0 && !self.isNotShowRemind) {
            [self createTableHeadShowRemind];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [g_mainVC.tb setBadge:2 title:[NSString stringWithFormat:@"%lu",(unsigned long)_remindArray.count]];
            });
            
        }else {
            [self createTableHeadShowRemind];
        }
        [self getWeiboBackImage];
    }
    return self;
}

-(instancetype)initCollection{
    if (self = [super init]) {
        self.isCollection = YES;
        self.title = Localized(@"JX_MyCollection");
        self.isGotoBack = YES;
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        
        self.datas = [NSMutableArray array];
        self.user = g_myself;
        [self createHeadAndFoot];
        [self createTableHeadShowRemind];
        self.footer.hidden = YES;
        [self getWeiboBackImage];
    }
    return self;
}

-(void)dealloc{
    [_pool removeAllObjects];
    [g_notify removeObserver:self name:kUpdateUserNotifaction object:nil];
    [g_notify removeObserver:self name:kCellTouchUrlNotifaction object:nil];
    [g_notify removeObserver:self name:kXMPPMessageWeiboRemind object:nil];
    [g_notify removeObserver:self name:kApplicationDidEnterBackground object:nil];
//    NSLog(@"WeiboViewControlle.dealloc");
    //    [super dealloc];
}

- (void)getWeiboBackImage {
    [g_server getUser:user.userId toView:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [g_notify  addObserver:self selector:@selector(changeKeyBoard:) name:UIKeyboardWillShowNotification object:nil];
    [[JXBlogRemind sharedInstance] updateNewMsgRead];
    NSMutableArray *array = [[JXBlogRemind sharedInstance] doFetchUnread];
    if (array.count == 0) {
        [g_mainVC.tb setBadge:2 title:@"-1" isSmall:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [g_notify  removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void) remindNotif:(NSNotification *)notif {
    JXMessageObject *msg = notif.object;
    self.remindMsg = msg;
    _remindArray = [[JXBlogRemind sharedInstance] doFetchUnread];
    if (_remindArray.count > 0 && !self.isNotShowRemind) {
        [self createTableHeadShowRemind];
    }else {
        [self showTopImage];
    }
    [self scrollToPageUp];
}

// 进入后台
- (void)didEnterBackground:(NSNotification *)notif {
    // 暂停语音播放
    for (NSInteger i = 0; i < _datas.count; i ++) {
        WeiboCell *cell = [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (cell) {
            if (cell.audioPlayer != nil) {
                [cell.audioPlayer stop];
            }
        }
    }
}

-(void)getServerData{
    [_wait start];
    if (self.isCollection) {
        [g_server userCollectionListWithType:0 pageIndex:0 toView:self];
    }else if (self.isDetail) {
        [g_server getMessage:self.detailMsgId toView:self];
    }else{
        [g_App.jxServer listMessage:0 messageId:[self getLastMessageId:_datas] toView:self];
    }
    
}

-(void)scrollToPageUp{
    [self doHideKeyboard];
    [super scrollToPageUp];
}
#pragma mark ------------------数据成功返回----------------------
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
//    [super stopLoading];
    
    if([aDownload.action isEqualToString:act_UploadFile]){
        JXUserObject *user = [[JXUserObject alloc] init];
        NSDictionary *dic = [dict[@"images"] firstObject];
        user.msgBackGroundUrl = [dic objectForKey:@"oUrl"];
        [g_server updateUser:user toView:self];
    }
    if ([aDownload.action isEqualToString:act_UserUpdate]) {
        NSString *urlStr = [NSString stringWithFormat:@"%@",dict[@"msgBackGroundUrl"]];
        if (IsStringNull(urlStr)) {
            [g_server getHeadImageLarge:user.userId userName:user.userNickname imageView:_topBackImageView];
        }else {
            [g_server getImage:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] imageView:_topBackImageView];
        }
    }
    //添加新回复
    if([aDownload.action isEqualToString:act_CommentAdd]){
        [replyDataTemp setMatch];
        if (selectWeiboData.replys.count >= 20) {
            selectWeiboData.replys = [NSMutableArray arrayWithArray:[selectWeiboData.replys subarrayWithRange:NSMakeRange(0, 19)]];
        }
        [selectWeiboData.replys insertObject:replyDataTemp atIndex:0];
        selectWeiboData.page = 0;
        selectWeiboData.commentCount += 1;
        selectWeiboData.replyHeight=[selectWeiboData heightForReply];
        if ([selectWeiboData.replys count] != 0) {
            [self.selectWeiboCell refresh];
        }
        
        replyDataTemp = [[WeiboReplyData alloc]init];
    }else if ([aDownload.action isEqualToString:act_CommentDel]){
        
        [selectWeiboData.replys removeObjectAtIndex:self.deleteReply];

        [replyDataTemp setMatch];
        selectWeiboData.page = 0;
        selectWeiboData.replyHeight=[selectWeiboData heightForReply];
        if ([selectWeiboData.replys count] != 0) {
            [self.selectWeiboCell refresh];
        }
    }
    if([aDownload.action isEqualToString:act_PraiseAdd]){
        [self doAddPraiseOK];
    }
    if([aDownload.action isEqualToString:act_PraiseDel]){
        [self doDelPraiseOK];
    }
    if([aDownload.action isEqualToString:act_GiftAdd]){
        
    }
    if([aDownload.action isEqualToString:act_userEmojiAdd]){
        WeiboData *data = _datas[self.lastCell.tag];
        data.isCollect = YES;
        [_datas replaceObjectAtIndex:self.lastCell.tag withObject:data];
        [_table reloadRow:(int)self.lastCell.tag section:0];
        [g_server showMsg:Localized(@"JX_CollectionSuccess") delay:1.3f];
    }
    if([aDownload.action isEqualToString:act_CommentList]){
        for(int i=0;i<[array1 count];i++){
            WeiboReplyData * reply=[[WeiboReplyData alloc]init];
            NSDictionary* dict = [array1 objectAtIndex:i];
            reply.type=1;
            reply.addHeight = 60;
            [reply getDataFromDict:dict];
            [reply setMatch];
            [self.selectWeiboData.replys addObject:reply];
        }
        [self.selectWeiboCell refresh];
    }
    if([aDownload.action isEqualToString:act_MsgDel]){
        [_datas removeObject:selectWeiboData];
        refreshCount++;
        [_table reloadData];
    }
    if([aDownload.action isEqualToString:act_MsgList] || [aDownload.action isEqualToString:act_MsgListUser] || [aDownload.action isEqualToString:act_MsgGet]){
        self.isShowFooterPull = [array1 count] >= jx_page_size;
        if(_page==0)
            [_datas removeAllObjects];
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //数据莫名为空
        if(_datas != nil){
            NSMutableArray * tempData = [[NSMutableArray alloc] init];
            for (int i=0; i<[array1 count]; i++) {
                NSDictionary* row = [array1 objectAtIndex:i];
                WeiboData * weibo=[[WeiboData alloc]init];
                [weibo getDataFromDict:row];
                [tempData addObject:weibo];
            }
            if (tempData.count > 0){
                [_datas addObjectsFromArray:tempData];
                [self loadWeboData:_datas complete:nil formDb:NO];
            }else {
                if (dict) {
                    WeiboData *data = [[WeiboData alloc] init];
                    [data getDataFromDict:dict];
                    [tempData addObject:data];
                    [_datas addObjectsFromArray:tempData];
                    [self loadWeboData:_datas complete:nil formDb:NO];
                }
            }
        }
        
        [_table reloadData];
    }
    if ([aDownload.action isEqualToString:act_userCollectionList]) {
        if (_page ==0) {
            [_datas removeAllObjects];
        }
        NSMutableArray * tempData = [[NSMutableArray alloc] init];
        for (int i=0; i<[array1 count]; i++) {
            NSDictionary* row = [array1 objectAtIndex:i];
            NSString * msgStr = row[@"msg"];
//            NSDictionary * msgDict = [[[SBJsonParser alloc]init]objectWithString:msgStr];
//
//            JXMessageObject *msg=[[JXMessageObject alloc] init];
////            [msg fromDictionary:bodyDict];
//            [msg fromXmlDict:msgDict];
            
            int collectType = [row[@"type"] intValue];
            NSTimeInterval createTime = [row[@"createTime"] doubleValue];
            NSString * emojiId = row[@"emojiId"];
            
            NSString *url = row[@"url"];
            NSString *fileLength = row[@"fileLength"];
            NSString *fileName = row[@"fileName"];
            NSString *fileSize = row[@"fileSize"];
            NSString *collectContent = row[@"collectContent"];

            WeiboData * weibo=[[WeiboData alloc]init];
            weibo.createTime = createTime;
            weibo.objectId = emojiId;
            if (collectContent.length > 0) {
                weibo.content = collectContent;
            }
//            [weibo getDataFromDict:row];
            [self weiboData:weibo WithUrl:url msg:msgStr collectType:collectType fileLength:fileLength fileName:fileName fileSize:fileSize];
            [tempData addObject:weibo];
        }
        if (tempData.count > 0){
            [_datas addObjectsFromArray:tempData];
            [self loadWeboData:_datas complete:nil formDb:NO];
        }
        [_table reloadData];
        
    }
    if ([aDownload.action isEqualToString:act_WeiboDeleteCollect]) {
        [g_server showMsg:Localized(@"JX_weiboCancelCollect") delay:1.3f];
        WeiboData *data = _datas[self.lastCell.tag];
        data.isCollect = NO;
        [_datas replaceObjectAtIndex:self.lastCell.tag withObject:data];
        [_table reloadRow:(int)self.lastCell.tag section:0];
    }
    if ([aDownload.action isEqualToString:act_userEmojiDelete]) {
        [g_server showMsg:Localized(@"JXAlert_DeleteOK") delay:1.3f];
        NSIndexPath * indexPath = [_table indexPathForCell:selectWeiboCell];
        [_datas removeObject:selectWeiboData];
//        [_table deleteRow:(int)indexPath.row section:(int)indexPath.section];
        [_table reloadData];
    }

    if([aDownload.action isEqualToString:act_PhotoList]){
        if([array1 count]>0){
            [photosViewController showPhotos:array1];
        }else{
            
        }
    }
    if( [aDownload.action isEqualToString:act_UserGet] ){
        JXUserObject* p = [[JXUserObject alloc]init];
        [p getDataFromDict:dict];

        if (!self.isFirstGoin) {
            self.isFirstGoin = YES;
            _topImageUrl = p.msgBackGroundUrl;
            [self showTopImage];

            return;
        }
        
        JXUserInfoVC* vc = [JXUserInfoVC alloc];
        vc.user       = p;
        vc.fromAddType = 6;
        vc = [vc init];
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
        [_pool addObject:vc];
//        [p release];
    }
    
    if([aDownload.action isEqualToString:act_Report]){
        [_wait stop];
        [g_App showAlert:Localized(@"JXUserInfoVC_ReportSuccess")];
    }
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
//    [super stopLoading];
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
//    [super stopLoading];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
}

-(void)weiboData:(WeiboData *)weiboData WithUrl:(NSString *)dataUrl msg:(NSString *)msg collectType:(int)collectType fileLength:(NSString *)fileLength fileName:(NSString *)fileName fileSize:(NSString *)fileSize{
//    weiboData.messageId = msg.messageId;
    weiboData.userId = MY_USER_ID;
    weiboData.userNickName = MY_USER_NAME;
    
//    weiboData.createTime = [[dict objectForKey:@"time"] longLongValue];
//    weiboData.deviceModel = [dict objectForKey:@"model"];
//    weiboData.location = [dict objectForKey:@"location"];
//    weiboData.flag = [[dict objectForKey:@"flag"] intValue];
//    weiboData.visible = [[dict objectForKey:@"visible"] intValue];
//    weiboData.isPraise = [[dict objectForKey:@"isPraise"] boolValue];
//    weiboData.isLoved = [[dict objectForKey:@"isLoved"] boolValue];
    
//    weiboData.loveCount = [[[dict objectForKey:@"count"] objectForKey:@"collect"] intValue];
//    weiboData.shareCount = [[[dict objectForKey:@"count"] objectForKey:@"share"] intValue];
//    weiboData.playCount = [[[dict objectForKey:@"count"] objectForKey:@"play"] intValue];
//    weiboData.forwardCount = [[[dict objectForKey:@"count"] objectForKey:@"forward"] intValue];
//    weiboData.praiseCount = [[[dict objectForKey:@"count"] objectForKey:@"praise"] intValue];
//    weiboData.commentCount = [[[dict objectForKey:@"count"] objectForKey:@"comment"] intValue];
//    weiboData.giftCount = [[[dict objectForKey:@"count"] objectForKey:@"money"] intValue];
//    weiboData.giftTotalPrice = [[[dict objectForKey:@"count"] objectForKey:@"total"] intValue];
    
//    weiboData.title = @"titletitle";
//    weiboData.type = [[[dict objectForKey:@"body"] objectForKey:@"type"] intValue];
    
    //    self.audios   = [[dict objectForKey:@"body"] objectForKey:@"audios"];
    //    self.videos   = [[dict objectForKey:@"body"] objectForKey:@"videos"];
//    weiboData.time = [[dict objectForKey:@"body"]  objectForKey:@"time"];
//    weiboData.address = [[dict objectForKey:@"body"]  objectForKey:@"address"];
//    weiboData.remark = [[dict objectForKey:@"body"]  objectForKey:@"remark"];
    
//    NSDictionary* row = nil;
    
    
//    CollectTypeEmoji    = 6,//表情
//    CollectTypeImage    = 1,//图片
//    CollectTypeVideo    = 2,//视频
//    CollectTypeFile     = 3,//文件
//    CollectTypeVoice    = 4,//语音
//    CollectTypeText     = 5,//文本
    
    
    if (collectType == 1) {//图片
        weiboData.type = weibo_dataType_image;
//        weiboData.images = [NSMutableArray arrayWithObject:msg.content];
        NSArray *urlArr = [dataUrl componentsSeparatedByString:@","];
        for (int i = 0; i < urlArr.count; i++) {
            ObjUrlData * url=[[ObjUrlData alloc] init];
            url.url= urlArr[i];
            url.mime=@"image/pic";
            [weiboData.smalls addObject:url];
            [weiboData.larges addObject:url];
            [weiboData.images addObject:url];
        }
        
    }else if (collectType == 2) {//视频
        weiboData.type = weibo_dataType_video;
        ObjUrlData * url=[[ObjUrlData alloc] init];
        url.url= dataUrl;
        url.fileSize = fileSize;
        url.timeLen = @([fileLength intValue]);
        [weiboData.videos addObject:url];
    }else if (collectType == 3) {//文件
        weiboData.type = weibo_dataType_file;
        ObjUrlData * url=[[ObjUrlData alloc] init];
        url.url= msg;
        url.fileSize = fileSize;
        url.type = @"4";
        if (fileName.length > 0) {
            url.name = [fileName lastPathComponent];
        }else {
            url.name = [msg lastPathComponent];
        }
        [weiboData.files addObject:url];
    }else if (collectType == 4) {//语音
        weiboData.type = weibo_dataType_audio;
        ObjUrlData * url=[[ObjUrlData alloc] init];
        url.url= dataUrl;
        url.fileSize =fileSize;
        url.timeLen = @([fileLength intValue]);
        [weiboData.audios addObject:url];
    }else if (collectType == 5) {//文本
        weiboData.type = weibo_dataType_text;
        weiboData.content= msg;
    }else if (collectType == 6) {//表情
        
    }
//    NSArray* p = nil;
//    weiboData.images = [[dict objectForKey:@"body"] objectForKey:@"images"];
//
//    for(int i=0;i<[p count];i++){
//        row = [p objectAtIndex:i];
//
//        ObjUrlData * url=[[ObjUrlData alloc] init];
//        url.url= [row objectForKey:@"tUrl"];
//        url.mime=@"image/pic";
//        [smalls addObject:url];
//
//        url =[[ObjUrlData alloc]init];
//        url.url= [row objectForKey:@"oUrl"];
//        url.mime=@"image/pic";
//        [larges addObject:url];
//    }
    
//    p = [[dict objectForKey:@"body"] objectForKey:@"audios"];
//    for(int i=0;i<[p count];i++){
//        row = [p objectAtIndex:i];
//
//        ObjUrlData * url=[[ObjUrlData alloc] init];
//        url.url= [row objectForKey:@"oUrl"];
//        url.fileSize = [row objectForKey:@"size"];
//        url.timeLen = [row objectForKey:@"length"];
//        [audios addObject:url];
//    }
    
//    p = [[dict objectForKey:@"body"] objectForKey:@"videos"];
//    for(int i=0;i<[p count];i++){
//        row = [p objectAtIndex:i];
//
//        ObjUrlData * url=[[ObjUrlData alloc] init];
//        url.url= [row objectForKey:@"oUrl"];
//        url.fileSize = [row objectForKey:@"size"];
//        url.timeLen = [row objectForKey:@"length"];
//        [videos addObject:url];
//    }
    
    if( ([weiboData.audios count]>0 || [weiboData.videos count]>0) && [weiboData.images count]<=0){//假如没图，则用头像代替
        ObjUrlData * url=[[ObjUrlData alloc]init];
        //        url.url= @"http://www.feizl.com/upload2007/2013_02/130227014423722.jpg";
        url.url= [g_server getHeadImageOUrl:MY_USER_ID];
        url.mime=@"image/pic";
        [weiboData.smalls addObject:url];
    }
    
//    p = [dict objectForKey:@"praises"];
//    for(int i=0;i<[p count];i++){
//        WeiboReplyData * reply=[[WeiboReplyData alloc]init];
//        reply.type=reply_data_praise;
//        //        reply.addHeight = self.minHeightForComment;
//        reply.messageId=self.messageId;
//        row = [p objectAtIndex:i];
//        [reply getDataFromDict:row];
//        [praises addObject:reply];
//    }
    
    
//    p = [dict objectForKey:@"gifts"];
//    for(int i=0;i<[p count];i++){
//        WeiboReplyData * reply=[[WeiboReplyData alloc]init];
//        reply.type=reply_data_gift;
//        //        reply.addHeight = self.minHeightForComment;
//        reply.messageId=self.messageId;
//        row = [p objectAtIndex:i];
//        [reply getDataFromDict:row];
//        [gifts addObject:reply];
//    }
    
//    p = [dict objectForKey:@"comments"];
//    for(NSInteger i = p.count - 1; i >= 0; i--){
//        WeiboReplyData * reply=[[WeiboReplyData alloc]init];
//        reply.type=reply_data_comment;
//        reply.addHeight = self.minHeightForComment;
//        reply.messageId=self.messageId;
//        row = [p objectAtIndex:i];
//        [reply getDataFromDict:row];
//        [replys addObject:reply];
//    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.isDetail) {
        //使大头像显示不全，让下方不被tabbar遮挡
        _table.contentInset = UIEdgeInsetsMake(-JX_SCREEN_WIDTH/5*1.8, 0, 49, 0);
    }
//    _table.contentOffset = CGPointMake(0,JX_SCREEN_WIDTH/16.0*8.0);
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self scrollToPageUp];
    //监听键盘状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    [self doHideKeyboard];
}

//- (void)textFieldDidEndEditing:(UITextField *)textField{
//    [self doHideKeyboard];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    return [_datas count];
}
#pragma mark - Table view     --------代理--------     data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *CellIdentifier = [NSString stringWithFormat:@"WeiboCell_%d_%ld",refreshCount,indexPath.row];
    NSString *CellIdentifier = nil;
    if (self.isCollection)
        CellIdentifier = [NSString stringWithFormat:@"collectionCell"];
    else
        CellIdentifier = [NSString stringWithFormat:@"WeiboCell"];
    
    WeiboCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell = [WeiboCell alloc];
        cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (self.isSend) {
        cell.contentView.userInteractionEnabled = NO;
    }else {
        cell.contentView.userInteractionEnabled = YES;
    }
    
    WeiboData * weibo;
    if ([_datas count] > indexPath.row) {
        weibo=[_datas objectAtIndex:indexPath.row];
    }
    cell.delegate = self;
    cell.controller=self;
    cell.tableViewP = tableView;
    cell.tag   = indexPath.row;
    cell.isPraise = weibo.isPraise;
    cell.isCollect = weibo.isCollect;
    cell.weibo = weibo;
    [cell setupData];
    
    float height=[self tableView:tableView heightForRowAtIndexPath:indexPath];
    UIView * view=[cell.contentView viewWithTag:1200];
    if(view==nil){
        UIView* line = [[UIView alloc]init];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        line.frame=CGRectMake(0, height-1, JX_SCREEN_WIDTH, 0.5);
        [cell.contentView  addSubview:line];
        line.tag=1200;
    }else{
        view.frame=CGRectMake(0, height-1, JX_SCREEN_WIDTH, 0.5);
    }
    if (self.isCollection) {
        cell.btnReply.hidden = YES;
        cell.btnLike.hidden = YES;
        cell.btnReport.hidden = YES;
        cell.btnCollection.hidden = YES;
    }
    if (self.isCollection || [weibo.userId isEqualToString:MY_USER_ID]) {
        
        cell.delBtn.hidden = NO;
    }else {
        cell.delBtn.hidden = YES;
    }
    
    if (self.isSend) {
        cell.delBtn.hidden = YES;
    }
    
    [self doAutoScroll:indexPath];
    return cell;
}

- (void)videoStartPlayer {
    [_videoPlayer switch];
}

- (void)weiboCell:(WeiboCell *)weiboCell clickVideoWithIndex:(NSInteger)index {
    self.videoIndex = index;
    _videoPlayer = [JXVideoPlayer alloc];
    _videoPlayer.videoFile = [[_datas objectAtIndex:index] getMediaURL];
    _videoPlayer.type = JXVideoTypeWeibo;
    _videoPlayer.didVideoPlayEnd = @selector(didVideoPlayEnd);
    _videoPlayer.isShowHide = YES;
    _videoPlayer.delegate = self;
    _videoPlayer = [_videoPlayer initWithParent:self.view];
    [self performSelector:@selector(videoStartPlayer) withObject:self afterDelay:0.2];

}

- (void)weiboCell:(WeiboCell *)weiboCell shareUrlActionWithUrl:(NSString *)url title:(NSString *)title {
    webpageVC *webVC = [webpageVC alloc];
    webVC.isGotoBack= YES;
    webVC.isSend = YES;
    webVC.title = title;
    webVC.url = url;
    webVC = [webVC init];
    [g_navigation.navigationView addSubview:webVC.view];
//    [g_navigation pushViewController:webVC animated:YES];
}

#pragma mark - Table view delegate

-(void)doHideMenu{
    [self resignFirstResponder];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuVisible:NO];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.menuView) {
        [self.menuView dismissBaseView];
        self.lastCell = nil;
    }
    [self doHideMenu];
    [self doHideKeyboard];
    
    if (self.isCollection) {
        
        if ([self.delegate respondsToSelector:@selector(weiboVC:didSelectWithData:)]) {
            WeiboData *data = _datas[indexPath.row];
            _currentData = data;
            [g_App showAlert:Localized(@"JXWantSendCollectionMessage") delegate:self tag:2457 onlyConfirm:NO];
        }
    }
    
    return;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    //依据数据的多少修改cell的高度
    if ([_datas count] != 0 && [_datas count] > indexPath.row) {
        WeiboData * data=[_datas objectAtIndex:indexPath.row];
        float n = [WeiboCell getHeightByContent:data];
        return n+20;
    }
    return 0;
}

#pragma -mark 回调方法
- (void)urlTouch:(NSNotification *)notification{
    self.actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:@[Localized(@"JXEmoji_OpenUrl")]];
    self.actionVC.delegate = self;
    self.actionVC.tag = 105;
    NSMutableString *str = notification.object;
    if ([str rangeOfString:@"http"].location == NSNotFound) {
        self.urlStr = [NSString stringWithFormat:@"http://%@",str];
    }else {
        self.urlStr = [str copy];
    }
    [g_App.window addSubview:self.actionVC.view];
}

- (void)phoneTouch:(NSNotification *)notification{
    
    self.actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:@[Localized(@"JXEmoji_CallPhone")]];
    self.actionVC.delegate = self;
    self.actionVC.tag = 102;
    phoneNumber=notification.object;
    [g_App.window addSubview:self.actionVC.view];
}

- (void)actionSheet:(JXActionSheetVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    if (actionSheet.tag==105){
        if(0==index){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                webpageVC *webVC = [webpageVC alloc];
                webVC.isGotoBack= YES;
                webVC.isSend = YES;
                webVC.title = Localized(@"JXEmoji_OpenUrl");
                webVC.url = self.urlStr;
                webVC = [webVC init];
                [g_navigation.navigationView addSubview:webVC.view];
//                [g_navigation pushViewController:webVC animated:YES];
            });
        }
    }else if (actionSheet.tag==102){
        if(0==index){
            NSString * string=[NSString stringWithFormat:@"tel:%@",phoneNumber];
            if(webView==nil)
                webView=[[WKWebView alloc]initWithFrame:self.view.bounds];
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:string]]];
            webView.hidden=YES;
            [self.view addSubview:webView];
        }
    }else if (actionSheet.tag == 111){
        if (index == 0) {
            UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
            ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
            ipc.delegate = self;
            ipc.allowsEditing = YES;
            //选择图片模式
            ipc.modalPresentationStyle = UIModalPresentationCurrentContext;
            if (IS_PAD) {
                UIPopoverController *pop =  [[UIPopoverController alloc] initWithContentViewController:ipc];
                [pop presentPopoverFromRect:CGRectMake((self.view.frame.size.width - 320) / 2, 0, 300, 300) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }else {
                
                ipc.modalPresentationStyle = UIModalPresentationFullScreen;
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

}
-(void)coreLabel:(HBCoreLabel*)coreLabel linkClick:(NSString*)linkStr
{
    
}
-(void)coreLabel:(HBCoreLabel *)coreLabel phoneClick:(NSString *)linkStr
{
    self.actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:@[Localized(@"JXEmoji_CallPhone")]];
    self.actionVC.delegate = self;
    self.actionVC.tag = 102;
    phoneNumber=linkStr;
    [g_App.window addSubview:self.actionVC.view];

}
-(void)coreLabel:(HBCoreLabel *)coreLabel mobieClick:(NSString *)linkStr
{
    self.actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:@[Localized(@"JXEmoji_CallPhone"),Localized(@"JX_SendMessage")]];
    self.actionVC.delegate = self;
    self.actionVC.tag = 103;
    phoneNumber=linkStr;
    [g_App.window addSubview:self.actionVC.view];

}



//-(void)footViewBeginLoad:(PageLoadFootView*)footView
//{
//    //    [self loadFromDb:NO];
//}

-(void)loadWeboData:(NSArray*)webos complete:(void(^)())complete formDb:(BOOL)fromDb
{
    //用i循环遍历
    for(int i = 0 ; i < [webos count];i++){
        WeiboData * weibo = [webos objectAtIndex:i];
        weibo.match=nil;
        [weibo setMatch];
        weibo.uploadFailed=NO;
        weibo.linesLimit=YES;
        weibo.imageHeight=[HBShowImageControl heightForFileStr:weibo.smalls];
        weibo.replyHeight=[weibo heightForReply];
        if(weibo.type == weibo_dataType_file) weibo.fileHeight = 90;
        if (weibo.type == weibo_dataType_share) {
            weibo.shareHeight = 70;
        }
    }
    //需要在遍历时改变内容，所以弃用
//    for(WeiboData * weibo in webos){
//        weibo.match=nil;
//        [weibo setMatch];
//        weibo.uploadFailed=NO;
//        weibo.linesLimit=YES;
//        weibo.imageHeight=[HBShowImageControl heightForFileStr:weibo.smalls];
//        weibo.replyHeight=[weibo heightForReply];
//    }
    dispatch_async(dispatch_get_main_queue(), ^{
        refreshCount++;
        [self.tableView reloadData];
        if(complete){
            complete();
        }
    });
}

- (void)loadWeboData:(NSArray *) webos {
    [self loadWeboData:webos complete:nil formDb:NO];
}


#pragma -mark 私有方法

#pragma -mark 事件响应方法

-(void)buildAddMsg{
    NSString *image = THESIMPLESTYLE ? @"im_003_more_button_black" : @"im_003_more_button_normal";
    UIButton* btn = [UIFactory createButtonWithImage:image
                                           highlight:nil
                                              target:self
                                            selector:@selector(onAddMsg:)];
    btn.frame = CGRectMake(JX_SCREEN_WIDTH - 40, JX_SCREEN_TOP - 34, 24, 24);
    [self.tableHeader addSubview:btn];
}
#pragma mark   ---------------发说说------------
- (void)onAddMsg:(UIButton *)btn{
    if (self.menuView) {
        [self.menuView dismissBaseView];
        self.menuView = nil;
    }
//    //标题数组
//    NSMutableArray * titleArr = [[NSMutableArray alloc]initWithArray:@[Localized(@"JX_SendWord"),Localized(@"JX_SendImage"),Localized(@"JX_SendVoice"),Localized(@"JX_SendVideo"),Localized(@"JX_NewCommentAndPraise")]];

    JX_SelectMenuView *menuView = [[JX_SelectMenuView alloc] initWithTitle:@[
//                                                                             Localized(@"JX_SendWord"),
                                                                             Localized(@"JX_SendImage"),
                                                                             Localized(@"JX_SendVoice"),
                                                                             Localized(@"JX_SendVideo"),
                                                                             Localized(@"JX_SendFile"),
                                                                             Localized(@"JX_NewCommentAndPraise")]
                                                                     image:@[]
                                                                cellHeight:45];
    menuView.delegate = self;
    [g_App.window addSubview:menuView];

}

- (void)didMenuView:(JX_SelectMenuView *)MenuView WithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        case 1:
        case 2:
        case 3:{
            addMsgVC* vc = [[addMsgVC alloc] init];
            //在发布信息后调用，并使其刷新
            vc.block = ^{
                [self scrollToPageUp];
            };
            vc.dataType = (int)index + 2;
            vc.delegate = self;
            vc.didSelect = @selector(hideKeyShowAlert);
            //        [g_window addSubview:vc.view];
            [g_navigation pushViewController:vc animated:YES];
            vc.view.hidden = NO;
        }
            break;
        case 4:{
            
            JXBlogRemindVC *vc = [[JXBlogRemindVC alloc] init];
            vc.remindArray = self.remindArray;
            vc.isShowAll = YES;
            //        [g_window addSubview:vc.view];
            [g_navigation pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void) moreListActionWithIndex:(NSInteger)index {
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch * touch = touches.anyObject;
    if (_selectView == nil) {
        return;
    }
    CGPoint location = [touch locationInView:_selectView];
    //不在选择范围内
    if (location.x < 0 || location.x > JX_SCREEN_WIDTH/2 || location.y < 7) {
        [self viewDisMissAction];
        return;
    }
    int num = (location.y - TopHeight)/CellHeight;
    if (num >= 0 && num < 4) {
        addMsgVC* vc = [[addMsgVC alloc] init];
        //在发布信息后调用，并使其刷新
        vc.block = ^{
            [self scrollToPageUp];
        };
        vc.dataType = num+1;
        vc.delegate = self;
        vc.didSelect = @selector(hideKeyShowAlert);
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
        vc.view.hidden = NO;
    }
    if (num == 4) {
        JXBlogRemindVC *vc = [[JXBlogRemindVC alloc] init];
        vc.remindArray = self.remindArray;
        vc.isShowAll = YES;
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
    }
    
    [self viewDisMissAction];

}

- (void)viewDisMissAction{
    [UIView animateWithDuration:0.4 animations:^{
        _bgBlackAlpha.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_selectView removeFromSuperview];
        _selectView = nil;
        [_bgBlackAlpha removeFromSuperview];
    }];
}

//单独加在weiboview上，弃用
- (void) hideKeyShowAlert
{
    [self doHideKeyboard];
    
    
}

//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (actionSheet.tag==102){
//        if(0==buttonIndex){
//            NSString * string=[NSString stringWithFormat:@"tel:%@",phoneNumber];
//            if(webView==nil)
//                webView=[[UIWebView alloc]initWithFrame:self.view.bounds];
//            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:string]]];
//            webView.hidden=YES;
//            [self.view addSubview:webView];
//        }
//    }else if (actionSheet.tag==103){
//        if(0==buttonIndex){
//            NSString * string=[NSString stringWithFormat:@"tel:%@",phoneNumber];
//            if(webView==nil)
//                webView=[[UIWebView alloc]initWithFrame:self.view.bounds];
//            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:string]]];
//            webView.hidden=YES;
//            [self.view addSubview:webView];
//        }else if(1==buttonIndex){
//
//        }
//    }
//}

- (void)tableView:(UITableView *)tableView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self doHideMenu];
    [self doHideKeyboard];
}

- (void)tapHide:(UITapGestureRecognizer *)tap{
    [self doHideMenu];
    [self doHideKeyboard];
}

//创建回复keyBoard上的回复小黑条
-(void)buildInput{
    self.clearBackGround = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
    
    UITapGestureRecognizer * tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHide:)];
    
    [self.clearBackGround addGestureRecognizer:tapG];
    
    _inputParent = [[UIView alloc]initWithFrame:CGRectMake(0, 200, JX_SCREEN_WIDTH, 30)];
    _inputParent.backgroundColor  = [UIColor whiteColor];
    [self.view addSubview:self.clearBackGround];
    [self.clearBackGround addSubview:_inputParent];
    // 配置自适应
    _inputParent.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.clearBackGround.hidden = YES;
    _inputParent.opaque = YES;
    _inputParent.hidden = YES;
    
    
    _input=[[JXTextView alloc]initWithFrame:CGRectMake(5, 0, JX_SCREEN_WIDTH -10 , 30)];
    
    _input.target = self;
//    _input.delegate = self;
    _input.didTouch = @selector(onInputText:);
    _input.backgroundColor = [UIColor whiteColor];
    _input.layer.borderWidth = 0.5f;
    _input.layer.borderColor = HEXCOLOR(0xe6e6e7).CGColor;
    _input.placeHolder = Localized(@"JXAlert_InputSomething");
    [_inputParent addSubview:_input];
}

-(void)changeKeyBoard:(NSNotification *)aNotifacation
{
    //    return;
    //获取到键盘frame 变化之前的frame
    NSValue *keyboardBeginBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect=[keyboardBeginBounds CGRectValue];
    
    //获取到键盘frame变化之后的frame
    NSValue *keyboardEndBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect endRect=[keyboardEndBounds CGRectValue];
    
    CGFloat deltaY=endRect.origin.y-beginRect.origin.y;
    //拿frame变化之后的origin.y-变化之前的origin.y，其差值(带正负号)就是我们self.view的y方向上的增量
    deltaY=-endRect.size.height;
    
//    NSLog(@"deltaY:%f",deltaY);
    
    [_table setFrame:CGRectMake(0, JX_SCREEN_HEIGHT+deltaY-_table.frame.size.height, _table.frame.size.width, _table.frame.size.height)];
    [_inputParent setFrame:CGRectMake(0, JX_SCREEN_HEIGHT+deltaY-_inputParent.frame.size.height, _inputParent.frame.size.width, _inputParent.frame.size.height)];
}

-(void)doHideKeyboard{
    [_input resignFirstResponder];
    _table.frame =CGRectMake(0,self.heightHeader,self_width,JX_SCREEN_HEIGHT-self.heightHeader-self.heightFooter);
    _inputParent.frame = CGRectMake(0,JX_SCREEN_HEIGHT-30,self_width,30);
    _inputParent.hidden = YES;
    self.clearBackGround.hidden = YES;
}

-(void)setupTableViewHeight:(CGFloat)height tag:(NSInteger)tag{
    _table.contentSize = CGSizeMake(_table.contentSize.width, _table.contentSize.height+height);
    [_table reloadRow:(int)tag section:0];
}


-(IBAction)deleteAction:(id)sender
{
    UIAlertView * alert=[[UIAlertView alloc]initWithTitle:Localized(@"JX_DeleteShare")
                                                  message:nil
                                                 delegate:self
                                        cancelButtonTitle:Localized(@"JX_Cencal")
                                        otherButtonTitles:Localized(@"JX_Confirm"), nil];
    alert.tag=222;
    [alert show];
}
//发送回复
-(void)onInputText:(NSString*)s{
    _input.text = nil;
    [self doHideKeyboard];
    
    replyDataTemp.messageId = selectWeiboData.messageId;
    replyDataTemp.body      = s;
    replyDataTemp.userId    = MY_USER_ID;
    replyDataTemp.userNickName    = g_server.myself.userNickname;
    
    [g_App.jxServer addComment:replyDataTemp toView:self];
}

-(void)delBtnAction:(WeiboData *)cellData{
    selectWeiboData = cellData;
    NSUInteger index = [_datas indexOfObject:cellData];
    if (index != NSNotFound) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        selectWeiboCell = [_table cellForRowAtIndexPath:indexPath];
    }
    
    if (self.isCollection) {
        
        [g_server userEmojiDeleteWithId:selectWeiboData.objectId toView:self];
    }else {
        [self deleteAction];
    }
}

- (void)fileAction:(WeiboData *)cellData {
    ObjUrlData * obj= [cellData.files firstObject];
    webpageVC *webVC = [webpageVC alloc];
    webVC.isGotoBack= YES;
    webVC.isSend = YES;
    if (obj.name.length > 0) {
        webVC.titleString = obj.name;
    }else {
        webVC.titleString = [obj.url lastPathComponent];
    }
    webVC.url = obj.url;
    webVC = [webVC init];
    [g_navigation.navigationView addSubview:webVC.view];
//    [g_navigation pushViewController:webVC animated:YES];
}

//#pragma mark - 点赞、评论控件 delegate
//- (void)didMenuView:(JXMenuView *)menuView WithButtonIndex:(NSInteger)index {
//    self.menuView = nil;
//    if (index == 0) {
//        if (!selectWeiboData.isPraise) {
//            [self praiseAddAction];
//        } else {
//            [self praiseDelAction];
//        }
//    }else if (index == 1) {
//        [self commentAction];
//    }else if (index == 2) {
//        if ([selectWeiboData.userId isEqualToString:MY_USER_ID]) {
//            [self deleteAction];
//        }else {
//            [self reportUserView];
//        }
//    }
//}

#pragma mark - 点赞、评论控件创建
-(void)btnReplyAction:(UIButton *)sender WithCell:(WeiboCell *)cell {
//    if (self.menuView) {
//        [self.menuView dismissBaseView];
//        if (cell == _lastCell) {
//            self.lastCell = nil;
//            return;
//        }
//    }
    self.lastCell = cell;
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:cell.tag inSection:0];
    selectWeiboCell = [_table cellForRowAtIndexPath:indexPath];
    selectWeiboData = [_datas objectAtIndex:cell.tag];
    
//    BOOL isDelete = [selectWeiboData.userId isEqualToString:MY_USER_ID];
//    NSArray *strArr = @[selectWeiboData.isPraise ? Localized(@"JX_Cencal") : Localized(@"JX_Good"),Localized(@"JX_Comment"),isDelete ? Localized(@"JX_Delete") : Localized(@"JXUserInfoVC_Report")];
//    NSArray *imgArr = @[@"blog_giveLike",@"blog_comments",isDelete ? @"blog_delete" : @"blog_report"];
//
//    CGPoint point = cell.replyContent.frame.origin;
//    CGFloat y = point.y-5;
//
//
//    self.menuView = [[JXMenuView alloc] initWithPoint:CGPointMake(0, y) Title:strArr Images:imgArr];
//    self.menuView.delegate = self;
//    [cell addSubview:self.menuView];
    NSInteger btnTag = sender.tag % 1000;
    if (btnTag == 1) {  // 点赞
        if (!selectWeiboData.isPraise) {
            [self praiseAddAction];
        } else {
            [self praiseDelAction];
        }
    }else if(btnTag == 2) { // 评论
        if (cell.weibo.isAllowComment == 0) {
            [self commentAction];
        }else {
            [g_server showMsg:Localized(@"JX_NotComments") delay:.5];
        }
    }else  if(btnTag == 3) { // 收藏
        [self collectionWeibo];
    }else{  // 举报
        [self reportUserView];
    }
    
    
}

- (void)collectionWeibo {
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    WeiboData * weibo = [_datas objectAtIndex:self.lastCell.tag];
    
    if (weibo.isCollect) { // 如果已被收藏,则取消收藏
        [g_server userWeiboEmojiDeleteWithId:weibo.messageId toView:self];
    }else {
        ObjUrlData *data;
        NSString *msg;
        if (weibo.images.count > 0 || weibo.videos.count > 0) { // 图片或者视频都会进
            if (weibo.videos.count > 0) { // 如果是视频
                data = [weibo.videos firstObject];
                msg = data.url;
                weibo.type = 2;
            }else {  // 只是图片
                NSMutableArray *imgArr = [NSMutableArray array];
                for (NSDictionary *dict in weibo.images) {
                    NSString *imgUrl = [dict objectForKey:@"oUrl"];
                    [imgArr addObject:imgUrl];
                }
                if (imgArr.count > 1) {
                    msg = [imgArr componentsJoinedByString:@","];
                }else {
                    msg = [imgArr firstObject];
                }
                weibo.type = 1;
            }
        }else if (weibo.audios.count > 0) {
            data = [weibo.audios firstObject];
            msg = data.url;
            weibo.type = 4;
        }else if (weibo.files.count > 0){
            data = [weibo.files firstObject];
            msg = data.url;
            weibo.type = 3;
        }else if (weibo.videos.count > 0){
            // 视频放在图片中做处理
        }else { // 纯文本
            weibo.type = 5;
            msg = weibo.content;
        }

        [dataDict setValue:msg forKey:@"msg"];
        [dataDict setValue:@(weibo.type) forKey:@"type"];
        [dataDict setValue:data.name forKey:@"fileName"];
        [dataDict setValue:data.fileSize forKey:@"fileSize"];
        [dataDict setValue:data.timeLen forKey:@"fileLength"];
        [dataDict setValue:weibo.content forKey:@"collectContent"];
        [dataDict setValue:weibo.messageId forKey:@"collectMsgId"];
        [dataDict setValue:@1 forKey:@"collectType"];
        
        NSMutableArray * emoji = [NSMutableArray array];
        [emoji addObject:dataDict];
        [g_server addFavoriteWithEmoji:emoji toView:self];
    }
}

-(void)reportUserView{
    JXReportUserVC * reportVC = [[JXReportUserVC alloc] init];
    reportVC.user = self.user;
    reportVC.delegate = self;
    [g_navigation pushViewController:reportVC animated:YES];
    
}

- (void)report:(JXUserObject *)reportUser reasonId:(NSNumber *)reasonId {
    [g_server reportUser:selectWeiboData.userId roomId:nil webUrl:nil reasonId:reasonId toView:self];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}


- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
        if (action == @selector(allCommentAction) ||
            action == @selector(commentAction) ||
            action == @selector(giftAction) ||
            action == @selector(forwardAction) ||
            action == @selector(deleteAction) ||
            (action == @selector(praiseAddAction) && !selectWeiboData.isPraise) ||
            (action == @selector(praiseDelAction) &&  selectWeiboData.isPraise) || action == @selector(reportUserView))
            return YES;
        else
            return NO;
}

-(void)delAndReplyAction
{
    
}

-(void)allCommentAction{
    
}

-(void)doShowAddComment:(NSString*)s{
    _input.placeHolder = s;
    self.clearBackGround.hidden = NO;
    _inputParent.hidden = NO;
    [_input becomeFirstResponder];
}

-(void)commentAction{
    replyDataTemp.toUserId  = nil;
    replyDataTemp.toNickName  = nil;
    [self doShowAddComment:nil];
}

-(void)praiseAddAction{
    if(!selectWeiboData.isPraise)
        [g_App.jxServer addPraise:selectWeiboData.messageId toView:self];
}

-(void)praiseDelAction{
    if(selectWeiboData.isPraise)
        [g_App.jxServer delPraise:selectWeiboData.messageId toView:self];
}

-(void)giftAction{
    return;
//    NSMutableArray* p = [[NSMutableArray alloc]init];
//    for(int i=0;i<2;i++){
//        NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
//        [dict setValue:[NSNumber numberWithInt:i+1] forKey:@"goodsId"];
//        [dict setValue:@"3" forKey:@"count"];
//        [p addObject:dict];
//    }
//    SBJsonWriter * OderJsonwriter = [SBJsonWriter new];
//    NSString * jsonString = [OderJsonwriter stringWithObject:p];
//    //    [OderJsonwriter release];
//    //    [p release];
//    [g_App.jxServer addGift:selectWeiboData.messageId gifts:jsonString toView:self];
}

-(void)forwardAction{
    
}
//删除说说
-(void)deleteAction{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localized(@"JX_IsDeletionConfirmed") message:nil delegate:self cancelButtonTitle:Localized(@"JX_Cencal") otherButtonTitles:Localized(@"JX_Confirm"), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        if (alertView.tag == 2457) {
            
            [self.delegate weiboVC:self didSelectWithData:_currentData];
            [self actionQuit];
        }else {
            
            NSInteger i = [_datas indexOfObject:selectWeiboData];
            WeiboCell *cell = [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (cell.audioPlayer != nil) {
                [cell.audioPlayer stop];
                cell.audioPlayer = nil;
            }
            
            if (cell.videoPlayer != nil) {
                [cell.videoPlayer stop];
                cell.videoPlayer = nil;
            }
            [g_server delMessage:selectWeiboData.messageId toView:self];
        }
        
    }
}

//顶部大头照
-(void)createTableHeadShowRemind{
 
    if (self.isDetail) {
        _table.tableHeaderView = nil;
        return;
    }

    [g_mainVC.tb setBadge:2 title:[NSString stringWithFormat:@"%ld",_remindArray.count]];
    
    UIView* head = [[UIView alloc]initWithFrame:CGRectMake(0,0, JX_SCREEN_WIDTH,JX_SCREEN_WIDTH+40)];
    head.backgroundColor = [UIColor whiteColor];
    
    //上方大头照
    JXImageView* iv = [[JXImageView alloc]initWithFrame:CGRectMake(0,0, JX_SCREEN_WIDTH,JX_SCREEN_WIDTH)];
    iv.delegate = self;
    iv.didTouch = @selector(actionPhotos);
    iv.changeAlpha = NO;
    iv.backgroundColor = [UIColor lightGrayColor];
    iv.clipsToBounds = YES;
    iv.contentMode = UIViewContentModeScaleAspectFill;
    _topBackImageView = iv;
    [self showTopImage];
//    [g_server getHeadImageLarge:user.userId imageView:iv];
    [head addSubview:iv];
    
    
    if (!self.isDetail && [self.user.userId isEqualToString:MY_USER_ID] && !self.isCollection) {
        UIButton *btn;
        
        CGFloat btnWH = ((JX_SCREEN_WIDTH - 86)-20*5)/5;
        // 语音
        CGFloat btnX = 20;
        CGFloat btnY = iv.frame.size.height-btnWH-20;
        
        btn = [[UIButton alloc] initWithFrame:CGRectMake(20, btnY, btnWH, btnWH)];
        [btn setTag:1];
        [btn setImage:[UIImage imageNamed:@"weibo_menu_btn_voice"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(didMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
//        [head addSubview:btn];
        
        // 图文
        btnX += btn.frame.size.width+20;
        btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWH, btnWH)];
        [btn setTag:0];
        [btn setImage:[UIImage imageNamed:@"weibo_menu_btn_image"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(didMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
//        [head addSubview:btn];
        
        // 视频
        btnX += btn.frame.size.width+20;
        btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWH, btnWH)];
        [btn setTag:2];
        [btn setImage:[UIImage imageNamed:@"weibo_menu_btn_video"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(didMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
//        [head addSubview:btn];
        
        // 文件
        btnX += btn.frame.size.width+20;
        btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWH, btnWH)];
        [btn setTag:3];
        [btn setImage:[UIImage imageNamed:@"weibo_menu_btn_file"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(didMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
//        [head addSubview:btn];
        
        // 点赞/回复
        btnX += btn.frame.size.width+20;
        btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWH, btnWH)];
        [btn setTag:4];
        [btn setImage:[UIImage imageNamed:@"weibo_menu_btn_like"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(didMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
//        [head addSubview:btn];
    }
    
    UIView* v = [[UIView alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-80-6,CGRectGetMaxY(iv.frame)-50, 80,80)];
//    v.backgroundColor = HEXCOLOR(0xfefefe);
//    v.layer.masksToBounds = YES;
//    v.layer.cornerRadius = 40.f;
//    v.layer.borderWidth = 4.f;
//    v.layer.borderColor = [UIColor whiteColor].CGColor;
    [head addSubview:v];
    
    
    iv = [[JXImageView alloc]initWithFrame:CGRectMake(2,2, 74,74)];
    iv.layer.masksToBounds = YES;
    iv.layer.cornerRadius = 8;
    iv.delegate = self;
    iv.layer.borderColor = [UIColor whiteColor].CGColor;
    iv.layer.borderWidth = 3;
    iv.didTouch = @selector(actionUser);
    [g_server getHeadImageSmall:user.userId userName:nil imageView:iv getHeadHandler:^(BOOL isRoom, UIImage *image, NSError *error) {
        
    }];
//    [g_server getHeadImageSmall:user.userId userName:nil imageView:iv];
    [v addSubview:iv];
    
    UILabel *nameL = [UIFactory createLabelWith:CGRectMake(0, v.top+32, v.left-4, 16) text:user.userNickname];
    nameL.font = [UIFont systemFontOfSize:15];
    nameL.textColor = [UIColor whiteColor];
    nameL.textAlignment = NSTextAlignmentRight;
    [head addSubview:nameL];
    
    if (self.remindArray.count) {
        head.frame = CGRectMake(head.frame.origin.x, head.frame.origin.y, head.frame.size.width, head.frame.size.height + 100);
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, head.frame.size.height - 50, 150, 30)];
        btn.backgroundColor = [UIColor colorWithWhite:.2 alpha:1];
        btn.center = CGPointMake(head.frame.size.width / 2, btn.center.y);
        btn.layer.cornerRadius = 3.0;
        btn.layer.masksToBounds = YES;
        [btn addTarget:self action:@selector(remindBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [head addSubview:btn];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btn.frame.size.width, btn.frame.size.height)];
        label.font = SYSFONT(15.0);
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%ld%@",self.remindArray.count, Localized(@"JX_PieceNewMessage")];
        [btn addSubview:label];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 26, 26)];
        JXBlogRemind *br = _remindArray.firstObject;
        [g_server getHeadImageLarge:br.fromUserId userName:br.fromUserName imageView:imageView];
        imageView.layer.cornerRadius = 3.0;
        imageView.layer.masksToBounds = YES;
        [btn addSubview:imageView];
        
        UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(btn.frame.size.width - 20, 7, 15, 15)];
        arrowImage.image = [UIImage imageNamed:@"arrow_black"];
        [btn addSubview:arrowImage];
    }
    
    _table.tableHeaderView = head;
}

- (void)didMenuBtn:(UIButton *)button {
    NSInteger index = button.tag;
    switch (index) {
        case 0:
        case 1:
        case 2:
        case 3:{
            addMsgVC* vc = [[addMsgVC alloc] init];
            //在发布信息后调用，并使其刷新
            vc.block = ^{
                [self scrollToPageUp];
            };
            vc.dataType = (int)index + 2;
            vc.delegate = self;
            vc.didSelect = @selector(hideKeyShowAlert);
            [g_navigation pushViewController:vc animated:YES];
            vc.view.hidden = NO;
        }
            break;
        case 4:{
            
            JXBlogRemindVC *vc = [[JXBlogRemindVC alloc] init];
            vc.remindArray = self.remindArray;
            vc.isShowAll = YES;
            [g_navigation pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)remindBtnAction:(UIButton *)btn {
    JXBlogRemindVC *vc = [[JXBlogRemindVC alloc] init];
    vc.remindArray = self.remindArray;
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
    
    [[JXBlogRemind sharedInstance] updateUnread];
    _remindArray = [[JXBlogRemind sharedInstance] doFetchUnread];
    [self createTableHeadShowRemind];
    [g_notify postNotificationName:@"uploadRemindNotifi" object:nil];
//    [self showTopImage];
}

-(void)doRefresh:(NSNotification *)notifacation{
    [self createTableHeadShowRemind];
    [self getServerData];
}
-(void)actionUser{
//    _userVc = nil;
//    _userVc = [userInfoVC alloc];
//    _userVc.userId = self.user.userId;
//    [_userVc init];
//    [g_window addSubview:_userVc.view];
//    [g_server getUser:self.user.userId toView:self];
    
    JXUserInfoVC* vc = [JXUserInfoVC alloc];
    vc.userId       = self.user.userId;
    vc.fromAddType = 6;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    [_pool addObject:vc];
}

-(NSString*)getLastMessageId:(NSArray*)objects{
    NSString* lastId = @"";
    if(_page > 0){
        NSInteger n = [objects count]-1;
        if(n>=0){
            WeiboData* p = [objects objectAtIndex:n];
            lastId = p.messageId;
            p = nil;
        }
    }
    return lastId;
}

-(void)doAddPraiseOK{
    BOOL b=YES;
    for(int i=0;i<[selectWeiboData.praises count];i++){
        WeiboReplyData* praise = [selectWeiboData.praises objectAtIndex:i];
        if([praise.userId intValue] == [g_server.myself.userId intValue]){
            b = NO;
            break;
        }
    }
    
    if(b){
        WeiboReplyData* praise = [[WeiboReplyData alloc]init];
        praise.userId = g_server.myself.userId;
        praise.userNickName = g_server.myself.userNickname;
        praise.type = reply_data_praise;
        [self.selectWeiboData.praises insertObject:praise atIndex:0];
        selectWeiboData.replyHeight=[selectWeiboData heightForReply];
    }
    
    selectWeiboData.praiseCount++;
    selectWeiboData.isPraise = YES;
    [self.selectWeiboCell refresh];
    
    
    
//    JXMessageObject *msg = [[JXMessageObject alloc] init];
//    msg.timeSend     = [NSDate date];
//    msg.fromUserId   = MY_USER_ID;
//    msg.fromUserName = g_server.myself.userNickname;
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setObject:selectWeiboData.messageId forKey:@"id"];
//    NSString *url;
//    int type;
//    if (selectWeiboData.images.count > 0) {
//        url = [selectWeiboData.images.firstObject objectForKey:@"oUrl"];
//        type = 1;
//    }
//    if (selectWeiboData.audios.count > 0) {
//        url = selectWeiboData.audios.firstObject;
//        type = 2;
//    }
//    if (selectWeiboData.videos.count > 0) {
//        url = selectWeiboData.videos.firstObject;
//        type = 3;
//    }
//
//    [dict setObject:[NSNumber numberWithInt:type] forKey:@"type"];
//    if (url.length > 0) {
//
//        [dict setObject:url forKey:@"url"];
//    }
//
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
//                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
//                                                         error:&error];
//
//    NSString *jsonString;
//    if (! jsonData)
//    {
//        NSLog(@"Got an error: %@", error);
//    }else
//    {
//        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    }
//
//    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
//
//    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//
//    msg.objectId = jsonString;
//    [g_xmpp sendMessage:msg roomName:nil];
    
}

-(void)doDelPraiseOK{
    for(int i=0;i<[selectWeiboData.praises count];i++){
        WeiboReplyData* praise = [selectWeiboData.praises objectAtIndex:i];
        if([praise.userId intValue] == [g_server.myself.userId intValue]){
            [selectWeiboData.praises removeObjectAtIndex:i];
            break;
        }
    }
    selectWeiboData.praiseCount--;
    if(selectWeiboData.praiseCount<0)
        selectWeiboData.praiseCount=0;
    selectWeiboData.isPraise = NO;
    selectWeiboData.replyHeight=[selectWeiboData heightForReply];
    [self.selectWeiboCell refresh];
}

-(void)actionPhotos{
    if (![user.userId isEqualToString:MY_USER_ID]) {
        return;
    }
    JXActionSheetVC *actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:@[Localized(@"JX_ChoosePhoto"),Localized(@"JX_TakePhoto")]];
    actionVC.delegate = self;
    actionVC.tag = 111;
    [self presentViewController:actionVC animated:NO completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [ImageResize image:[info objectForKey:@"UIImagePickerControllerEditedImage"] fillSize:CGSizeMake(640, 640)];
    
    NSString* filePath = [FileInfo getUUIDFileName:@"jpg"];
    [g_server saveImageToFile:image file:filePath isOriginal:NO];
    [g_server uploadFile:filePath validTime:@"-1" messageId:nil toView:self];

    _topBackImageView.image = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraVC:(JXCameraVC *)vc didFinishWithImage:(UIImage *)image {
    UIImage *camImage = [ImageResize image:image fillSize:CGSizeMake(640, 640)];
    
    NSString* filePath = [FileInfo getUUIDFileName:@"jpg"];
    [g_server saveImageToFile:camImage file:filePath isOriginal:NO];
    [g_server uploadFile:filePath validTime:@"-1" messageId:nil toView:self];
    
    _topBackImageView.image = camImage;
}

// 滚动tableView  移除点赞、评论控件
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.menuView dismissBaseView];
    self.lastCell = nil;
}
- (void)showTopImage {
    if (IsStringNull(_topImageUrl)) {
        [g_server getHeadImageLarge:user.userId userName:user.userNickname imageView:_topBackImageView];
    }else {
        [g_server getImage:_topImageUrl imageView:_topBackImageView];
    }
}

@end
