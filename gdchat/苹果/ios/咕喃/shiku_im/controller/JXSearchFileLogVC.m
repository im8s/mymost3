//
//  JXSearchFileLogVC.m
//  shiku_im
//
//  Created by p on 2019/4/8.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXSearchFileLogVC.h"
#import "JXSearchFileLogCell.h"
#import "JXShareFileObject.h"
#import "JXFileDetailViewController.h"
#import "webpageVC.h"
#import "JXTransferDeatilVC.h"
#import "JXredPacketDetailVC.h"
#import "JXChatViewController.h"

@interface JXSearchFileLogVC ()

@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation JXSearchFileLogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack = YES;
    self.isShowFooterPull = NO;
    self.isShowHeaderPull = NO;
    [self createHeadAndFoot];
    
    _array = [NSMutableArray array];
    [self getServerData];
}

- (void)getServerData {
    
    switch (self.type) {
        case FileLogType_file:{
            
            _array = [[JXMessageObject sharedInstance] fetchAllMessageListWithUser:self.user.userId withTypes:@[[NSNumber numberWithInt:kWCMessageTypeFile]]];
            self.title = Localized(@"JX_File");
        }
            break;
        case FileLogType_Link:{
            _array = [[JXMessageObject sharedInstance] fetchAllMessageListWithUser:self.user.userId withTypes:@[[NSNumber numberWithInt:kWCMessageTypeLink],[NSNumber numberWithInt:kWCMessageTypeShare]]];
            self.title = Localized(@"JXLink");
        }
            
            break;
        case FileLogType_transact:{
            _array = [[JXMessageObject sharedInstance] fetchAllMessageListWithUser:self.user.userId withTypes:@[[NSNumber numberWithInt:kWCMessageTypeRedPacket],[NSNumber numberWithInt:kWCMessageTypeTransfer]]];
            self.title = Localized(@"JX_Trading");
        }
            break;
            
        default:
            break;
    }
}

#pragma mark   ---------tableView协议----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JXSearchFileLogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JXSearchFileLogCell"];
    if (!cell) {
        
        cell = [[JXSearchFileLogCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JXSearchFileLogCell"];
    }
    cell.type = self.type;
    JXMessageObject *msg = _array[indexPath.row];
    cell.msg = msg;
    
    return cell;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JXMessageObject *msg = _array[indexPath.row];
    
    switch (self.type) {
        case FileLogType_file:{
            JXShareFileObject *obj = [[JXShareFileObject alloc] init];
            obj.fileName = [msg.fileName lastPathComponent];
            obj.url = msg.content;
            obj.size = msg.fileSize;
            
            JXFileDetailViewController *vc = [[JXFileDetailViewController alloc] init];
            vc.shareFile = obj;
            //    [g_window addSubview:vc.view];
            [g_navigation pushViewController:vc animated:YES];
            
        }
            break;
        case FileLogType_Link:{
            
            if ([msg.type integerValue] == kWCMessageTypeShare) {
                NSDictionary * msgDict = [[[SBJsonParser alloc]init]objectWithString:msg.objectId];
                
                NSString *url = [msgDict objectForKey:@"url"];
                NSString *downloadUrl = [msgDict objectForKey:@"downloadUrl"];
                
                if ([url rangeOfString:@"http"].location == NSNotFound) {
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:nil completionHandler:^(BOOL success) {
                        
                        if (!success) {
                            
                            webpageVC *webVC = [webpageVC alloc];
                            webVC.isGotoBack= YES;
                            webVC.isSend = YES;
                            webVC.titleString = [msgDict objectForKey:@"title"];
                            webVC.url = downloadUrl;
                            webVC = [webVC init];
                            [g_navigation.navigationView addSubview:webVC.view];
                            //                [g_navigation pushViewController:webVC animated:YES];
                        }
                        
                    }];
                    
                }else {
                    webpageVC *webVC = [webpageVC alloc];
                    webVC.isGotoBack= YES;
                    webVC.isSend = YES;
                    webVC.titleString = [msgDict objectForKey:@"title"];
                    webVC.url = url;
                    webVC = [webVC init];
                    [g_navigation.navigationView addSubview:webVC.view];
                    //        [g_navigation pushViewController:webVC animated:YES];
                }
                
            }else {
    
                SBJsonParser * parser = [[SBJsonParser alloc] init] ;
                NSDictionary *content = [parser objectWithString:msg.content];
                NSString *url = [content objectForKey:@"url"];
                
                webpageVC *webVC = [webpageVC alloc];
                webVC.isGotoBack= YES;
                webVC.isSend = YES;
                webVC.title = [content objectForKey:@"title"];
                webVC.url = url;
                webVC = [webVC init];
                [g_navigation.navigationView addSubview:webVC.view];
            }
        }
            
            break;
        case FileLogType_transact:{
            
            JXChatViewController *sendView=[JXChatViewController alloc];
            
            sendView.scrollLine = [msg getLineNumWithUserId:self.user.userId] - 1;
            sendView.title = self.user.remarkName.length > 0 ? self.user.remarkName : self.user.userNickname;
            if([self.user.roomFlag intValue] > 0 || self.user.roomId.length > 0){
                //        if(g_xmpp.isLogined != 1){
                //            // 掉线后点击title重连
                //            [g_xmpp showXmppOfflineAlert];
                //            return;
                //        }
                
                sendView.roomJid = self.user.userId;
                sendView.roomId   = self.user.roomId;
                sendView.groupStatus = self.user.groupStatus;
                
                if (self.user.roomFlag || self.user.roomId.length > 0) {
                    NSDictionary * groupDict = [self.user toDictionary];
                    roomData * roomdata = [[roomData alloc] init];
                    [roomdata getDataFromDict:groupDict];
                    sendView.room = roomdata;
                    sendView.newMsgCount = [self.user.msgsNew intValue];
                    
                    
                    self.user.isAtMe = [NSNumber numberWithInt:0];
                    [self.user updateIsAtMe];
                }
                
            }

            sendView.rowIndex = indexPath.row;
            sendView.lastMsg = msg;
            sendView.chatPerson = self.user;
            sendView = [sendView init];
            //    [g_App.window addSubview:sendView.view];
            [g_navigation pushViewController:sendView animated:YES];
            
            
            //            if ([msg.type integerValue] == kWCMessageTypeRedPacket) {
            //
            //                [g_server getRedPacket:msg.objectId toView:self];
            //            }else {
            //
            //                JXTransferDeatilVC *detailVC = [JXTransferDeatilVC alloc];
            //                detailVC.msg = msg;
            //                detailVC.onResend = @selector(onResend:);
            //                detailVC.delegate = self;
            //                detailVC = [detailVC init];
            //                [g_navigation pushViewController:detailVC animated:YES];
            //            }

        }
            
            break;
            
        default:
            break;
    }
    
}

// 重新发送转账消息
- (void)onResend:(JXMessageObject *)msg {
    JXMessageObject *msg1 = [[JXMessageObject alloc]init];
    msg1 = [msg copy];
    msg1.messageId = nil;
    msg1.timeSend     = [NSDate date];
    msg1.fromId = nil;
    msg1.isGroup = NO;
    msg1.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg1.isRead       = [NSNumber numberWithBool:NO];
    msg1.isReadDel    = [NSNumber numberWithInt:NO];
    [msg1 insert:nil];
    [g_xmpp sendMessage:msg1 roomName:nil];//发送消息
}

#pragma mark  -------------------服务器返回数据--------------------
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    //获取红包信息
    if ([aDownload.action isEqualToString:act_getRedPacket]) {

        
    }

}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{

    [_wait stop];
    
    //自己查看红包或者红包已领完，resultCode ＝0
    if ([aDownload.action isEqualToString:act_getRedPacket]) {
        
        //        [self changeMessageRedPacketStatus:dict[@"data"][@"packet"][@"id"]];
        //        [self changeMessageArrFileSize:dict[@"data"][@"packet"][@"id"]];
        
        JXredPacketDetailVC * redPacketDetailVC = [[JXredPacketDetailVC alloc]init];
        redPacketDetailVC.dataDict = [[NSDictionary alloc]initWithDictionary:dict];
        //        [g_window addSubview:redPacketDetailVC.view];
        redPacketDetailVC.isGroup = self.isGroup;
        [g_navigation pushViewController:redPacketDetailVC animated:YES];
        
    }
    
    return hide_error;
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
