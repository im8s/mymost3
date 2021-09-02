//
//  JXChatLogQRCodeVC.m
//  shiku_im
//
//  Created by p on 2019/6/5.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXChatLogQRCodeVC.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "QRImage.h"
#import "GCDAsyncSocket.h"

@interface JXChatLogQRCodeVC ()<GCDAsyncSocketDelegate>

@property(nonatomic,strong)GCDAsyncSocket *tcpScoket;
@property (nonatomic, strong) NSMutableArray *clientSocketMuArr;
@end

@implementation JXChatLogQRCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isGotoBack = YES;
    self.title = Localized(@"JX_ChatLogMove");
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    [self createHeadAndFoot];
    
    g_xmpp.isChatLogMove = YES;
    
    NSString *port = @"8888";
    
    NSLog(@"ipipip == %@", [self getCurrentLocalIP]);
    NSMutableString * qrStr = [NSMutableString stringWithFormat:@"%@?action=sendChatHistory&ip=%@&port=%@&userId=%@",g_config.website,[self getCurrentLocalIP],port,g_myself.userId];
    
    UIImage * qrImage = [QRImage qrImageForString:qrStr imageSize:200 logoImage:nil logoImageSize:0];
    UIImageView *qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH-200)/2, 100, 200, 200)];
    qrImageView.image = qrImage;
    [self.tableBody addSubview:qrImageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(qrImageView.frame) + 20, JX_SCREEN_WIDTH, 50)];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16.0];
    label.text = [NSString stringWithFormat:@"%@\n%@", Localized(@"JX_LoginAccount"), Localized(@"JX_ScanQRCode")];
    [self.tableBody addSubview:label];
    
    
    self.clientSocketMuArr = [NSMutableArray array];
    self.tcpScoket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.tcpScoket acceptOnInterface:[self getCurrentLocalIP] port:[port intValue] error:nil];
    
}

- (nullable NSString*)getCurrentLocalIP
{
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}


#pragma mark - AsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    
    [self.clientSocketMuArr addObject:newSocket];
    [newSocket readDataWithTimeout:-1 tag:0];
    
    [_wait start:Localized(@"JX_SendNow")];
    for (NSInteger i = 0; i < _selUserIdArray.count; i ++) {
        NSString *userId = _selUserIdArray[i];
        NSMutableArray *msgArr = [[JXMessageObject sharedInstance] fetchAllMessageListWithUser:userId];
        
        // 先发送标识字符串，表明接下来发送的是哪个用户的聊天记录
        NSString *str = [NSString stringWithFormat:@"%@,%@",g_myself.userId, userId];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        
        data = [self getAppendLengthData:data];
        
        [newSocket writeData:data withTimeout:-1 tag:10];
//            for (GCDAsyncSocket *soc in self.clientSocketMuArr) {
//                [soc writeData:data withTimeout:-1 tag:10];
//            }
        
        // 在发送该用户聊天记录
        for (NSInteger j = 0; j < msgArr.count; j ++) {
            JXMessageObject *msg = msgArr[j];
            SBJsonWriter * OderJsonwriter = [SBJsonWriter new];
            NSString * jsonString = [OderJsonwriter stringWithObject:[msg toDictionary]];
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            jsonData = [self getAppendLengthData:jsonData];
            NSLog(@"jsonString === %@,,,,,jsonData = %@", jsonString, jsonData);
            [newSocket writeData:jsonData withTimeout:-1 tag:10];
//                for (GCDAsyncSocket *soc in self.clientSocketMuArr) {
//                    [soc writeData:jsonData withTimeout:-1 tag:10];
//                }
            
        }
    }
    
    [_wait stop];
    
    [JXMyTools showTipView:Localized(@"JXAlert_SendOK")];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.clientSocketMuArr removeAllObjects];
        [self.tcpScoket disconnectAfterWriting];
        [self actionQuit];
    });
}

- (NSData *)getAppendLengthData:(NSData *)data {
    
    NSMutableData *da = [NSMutableData data];
    // 消息长度 4个字节
    int len = (int)data.length;
    HTONL(len);
    NSData *da1 = [NSData dataWithBytes:&len length:sizeof(len)];
    [da appendData:da1];
    [da appendData:data];
    
    return da;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *readStr = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
    NSLog(@"读到的数据：%@",readStr);
    
    //    [sock writeData:[readStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:101];
    
    [sock readDataWithTimeout:-1 tag:0];
    
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    
    NSLog(@"已连接：host = %@, port = %d", host, port);
}
-(void)socket:(GCDAsyncSocket *)sock willDisconnectWithError:(NSError *)err{
    
}
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock{
    NSLog(@"断开连接");
}
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"sock:%@  %ld",sock,tag);
}


- (void)actionQuit {
 
    g_xmpp.isChatLogMove = NO;
    [self.tcpScoket disconnect];
    
    if (g_xmpp.isLogined != login_status_yes) {
        
        [g_server performSelector:@selector(showLogin) withObject:nil afterDelay:0.5];
    }else {
        [super actionQuit];
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
