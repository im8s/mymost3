//
//  JXChatLogVC.m
//  shiku_im
//
//  Created by p on 2018/7/5.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXChatLogVC.h"
#import "JXBaseChatCell.h"
#import "JXMessageCell.h"
#import "JXImageCell.h"
#import "JXLocationCell.h"
#import "JXGifCell.h"
#import "JXVideoCell.h"
#import "JXAudioCell.h"
#import "JXFileCell.h"
#import "ImageBrowserViewController.h"
#import "JXVideoPlayer.h"


@interface JXChatLogVC () <ImageBrowserVCDelegate,JXVideoCellDelegate>
@property (nonatomic, strong) NSMutableArray *allChatImageArr;
@property (nonatomic, strong) JXVideoPlayer *player;


@end

@implementation JXChatLogVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = HEXCOLOR(0xF2F2F2);
    self.tableView.backgroundColor = HEXCOLOR(0xF2F2F2);
    self.isShowFooterPull = NO;
    self.isShowHeaderPull = NO;
    self.isGotoBack = YES;

    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    [self createHeadAndFoot];
    
    _allChatImageArr = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
    [g_notify addObserver:self selector:@selector(onDidImage:) name:kCellImageNotifaction object:nil];//照片

}


- (void)actionQuit {
    [super actionQuit];
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JXMessageObject *msg=[_array objectAtIndex:indexPath.row];
    
    NSLog(@"indexPath.row:%ld,%ld",indexPath.section,indexPath.row);
    
    //返回对应的Cell
    JXBaseChatCell * cell = [self getCell:msg indexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    msg.changeMySend = 1;
    cell.msg = msg;
    cell.indexNum = (int)indexPath.row;
    cell.delegate = self;
    //    cell.chatCellDelegate = self;
    //    cell.readDele = @selector(readDeleWithUser:);
    cell.isShowHead = YES;
    [cell setCellData];
    [cell setHeaderImage];
    [cell setBackgroundImage];
    [cell isShowSendTime];
    //转圈等待
    if ([msg.isSend intValue] == transfer_status_ing) {
        [cell drawIsSend];
    }
    msg = nil;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JXMessageObject *msg=[_array objectAtIndex:indexPath.row];
    
    switch ([msg.type intValue]) {
        case kWCMessageTypeText:
            return [JXMessageCell getChatCellHeight:msg];
            break;
        case kWCMessageTypeImage:
            if (![_allChatImageArr containsObject:msg]) {
                [_allChatImageArr addObject:msg];
            }
            return [JXImageCell getChatCellHeight:msg];
            break;
        case kWCMessageTypeLocation:
            return [JXLocationCell getChatCellHeight:msg];
            break;
        case kWCMessageTypeGif:
            return [JXGifCell getChatCellHeight:msg];
            break;
        case kWCMessageTypeVideo:
            return [JXVideoCell getChatCellHeight:msg];
            break;
        case kWCMessageTypeVoice:
            return [JXAudioCell getChatCellHeight:msg];
            break;
        case kWCMessageTypeFile:
            return [JXFileCell getChatCellHeight:msg];
            break;

        default:
            return [JXBaseChatCell getChatCellHeight:msg];
            break;
    }
}


#pragma mark -----------------获取对应的Cell-----------------
- (JXBaseChatCell *)getCell:(JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    JXBaseChatCell * cell = nil;
    switch ([msg.type intValue]) {
        case kWCMessageTypeText:
            cell = [self creatMessageCell:msg indexPath:indexPath];
            break;
            
        case kWCMessageTypeImage:
            cell = [self creatImageCell:msg indexPath:indexPath];
            break;
            
        case kWCMessageTypeLocation:
            cell = [self creatLocationCell:msg indexPath:indexPath];
            break;
            
        case kWCMessageTypeGif:
            cell = [self creatGifCell:msg indexPath:indexPath];
            break;
            
        case kWCMessageTypeVideo:
            cell = [self creatVideoCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeVoice:
            cell = [self creatAudioCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeFile:
            cell = [self creatFileCell:msg indexPath:indexPath];
            break;

        default:
            cell = [[JXBaseChatCell alloc] init];
            break;
    }
    return cell;
}
#pragma  mark -----------------------创建对应的Cell---------------------
//文本
- (JXBaseChatCell *)creatMessageCell:(JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"JXMessageCell";
    JXMessageCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[JXMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    return cell;
}
//图片
- (JXBaseChatCell *)creatImageCell:(JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"JXImageCell";
    JXImageCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[JXImageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        //        cell.chatImage.delegate = self;
        //        cell.chatImage.didTouch = @selector(onCellImage:);
    }
    return cell;
}
//视频
- (JXBaseChatCell *)creatVideoCell:(JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"JXVideoCell";
    JXVideoCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[JXVideoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.videoDelegate = self;
    }
    return cell;
}
//位置
- (JXBaseChatCell *)creatLocationCell:(JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"JXLocationCell";
    JXLocationCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[JXLocationCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}
//动画
- (JXBaseChatCell *)creatGifCell:(JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"JXGifCell";
    JXGifCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[JXGifCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}
//文件
- (JXBaseChatCell *)creatFileCell:(JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"JXFileCell";
    JXFileCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[JXFileCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}
//音频
- (JXBaseChatCell *)creatAudioCell:(JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"JXAudioCell";
    JXAudioCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[JXAudioCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.indexNum = (int)indexPath.row;
    return cell;
}

#pragma mark-------照片查看
- (void)onDidImage:(NSNotification*)notification{
    JXMessageObject *msg = [_array objectAtIndex:[notification.object intValue]];
    //图片路径数组
    NSMutableArray *imagePathArr = [[NSMutableArray alloc]init];
    NSMutableArray *msgArray = [NSMutableArray array];
    
    for (int i = 0; i < [_allChatImageArr count]; i++) {
        JXMessageObject * msgP = [_allChatImageArr objectAtIndex:i];
        if (![msgP.isReadDel boolValue] && [msgP.content rangeOfString:@".gif"].location == NSNotFound) {//得到的消息中含有阅后即焚 或 gif图片 的剔除掉
            if (msgP.content) {
                [msgArray addObject:msgP];
                NSString* url;
                if(msgP.isMySend && isFileExist(msgP.fileName))
                    url = msgP.fileName;
                else
                    url = msgP.content;
                [imagePathArr addObject:url];
            }
        }
    }
    //查到当前点击的图片的位置
    for (int i = 0; i < [msgArray count]; i++) {
        JXMessageObject * msgObj = [msgArray objectAtIndex:i];
        if ([msg.messageId isEqualToString:msgObj.messageId]) {
            
            [ImageBrowserViewController show:self delegate:self isReadDel:[msgObj.isReadDel boolValue] type:PhotoBroswerVCTypeModal contentArray:msgArray index:i imagesBlock:^NSArray *{
                return imagePathArr;
            }];
            
        }
    }
    imagePathArr = nil;
}

// 显示全屏视频播放
- (void)showVideoPlayerWithTag:(NSInteger)tag {
    
    _player= [JXVideoPlayer alloc];
    _player.type = JXVideoTypeChat;
    _player.isShowHide = YES; //播放中点击播放器便销毁播放器
    _player.isStartFullScreenPlay = YES; //全屏播放
    _player.didVideoPlayEnd = @selector(didVideoPlayEnd);
    _player.delegate = self;
    JXMessageObject *msg = [_array objectAtIndex:tag];
    if(msg.isMySend && isFileExist(msg.fileName))
        _player.videoFile = msg.fileName;
    else
        _player.videoFile = msg.content;
    _player.isReadDel = [msg.isReadDel boolValue];
    _player = [_player initWithParent:self.view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_player switch];
    });
}

- (void)dealloc {
    [g_notify removeObserver:self];
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
