//
//  JXScanQRViewController.m
//  shiku_im
//
//  Created by 1 on 17/9/15.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXScanQRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "JXUserInfoVC.h"
#import "JXRoomObject.h"
#import "JXRoomPool.h"
#import "JXChatViewController.h"
#import "webpageVC.h"
#import "JXRoomRemind.h"
#import "JXInputVC.h"
#import "RITLPhotosViewController.h"
#import "JXInputMoneyVC.h"
#import "GCDAsyncSocket.h"
#import "JXChatLogMoveActionVC.h"
#import "JXWebLoginVC.h"
#import "QRImage.h"
#import "PSMyViewController.h"

//#define TOP (JX_SCREEN_TOP + 45)
//#define LEFT (JX_SCREEN_WIDTH-200)/2
//#define kScanRect CGRectMake(LEFT, TOP, 200, 200)

@interface JXScanQRViewController ()<AVCaptureMetadataOutputObjectsDelegate,RITLPhotosViewControllerDelegate,GCDAsyncSocketDelegate,JXWebLoginVCDelegate,JXRoomObjectDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    CAShapeLayer *cropLayer;
    JXRoomObject *_chatRoom;
    NSDictionary * _dataDict;
    
    CGFloat QRWIDTH;
    CGFloat TOP;
    CGFloat LEFT;
    CGRect kScanRect;
}
//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic)AVCaptureDevice *device;

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic)AVCaptureDeviceInput *input;

//设置输出类型为Metadata，因为这种输出类型中可以设置扫描的类型，譬如二维码
//当启动摄像头开始捕获输入时，如果输入中包含二维码，就会产生输出
@property(nonatomic)AVCaptureMetadataOutput *output;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic)AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UIImageView * line;

// 扫描到群组参数
@property (nonatomic, copy) NSString *roomJid;
@property (nonatomic, copy) NSString *roomUserId;
@property (nonatomic, copy) NSString *roomUserName;


@property(nonatomic,strong)GCDAsyncSocket *tcpScoket;
@property (nonatomic, strong) NSMutableArray *connectHostMuArr;
@property (nonatomic, strong) NSData *lastData;

@property (nonatomic, assign) BOOL isMyLog; //是否是自己的聊天记录
@property (nonatomic, copy) NSString *logUserId;    // 聊天记录的用户Id；

@property (nonatomic, strong) JXChatLogMoveActionVC *moveActionVC;

@property (nonatomic,copy) NSString *qrCodeKey; // web端扫描二维码登录key
@property (nonatomic, assign) BOOL isQRLoginAction;

@property (nonatomic, strong) JXInputRectView *inputRectView;

@end

@implementation JXScanQRViewController

-(instancetype)init{
    if (self = [super init]) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
        self.title = Localized(@"JXQR_Scan");
        self.connectHostMuArr = [NSMutableArray array];
    }
    return self;
}
-(void)dealloc{
    [timer invalidate];
    timer = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.isShowMyQR) {
        QRWIDTH = (JX_SCREEN_HEIGHT - 200 - JX_SCREEN_TOP) / 2;
        TOP = (JX_SCREEN_TOP + 45);
        LEFT = (JX_SCREEN_WIDTH-QRWIDTH)/2;
        kScanRect = CGRectMake(LEFT, TOP, QRWIDTH, QRWIDTH);
    }else {
        QRWIDTH = 300;
        TOP = (JX_SCREEN_HEIGHT-QRWIDTH)/2;
        LEFT = (JX_SCREEN_WIDTH-QRWIDTH)/2;
        kScanRect = CGRectMake(LEFT, TOP, QRWIDTH, QRWIDTH);
    }
    
    [self createHeadAndFoot];
    self.tableBody.hidden = YES;
    [self setCropRect:kScanRect];
    [self setupCamera];
    [self configView];
    [self setupPhotoAlbum];
    [_session startRunning];
}

- (void)setupPhotoAlbum {
    UIButton *moreBtn = [UIFactory createButtonWithImage:@""
                                          highlight:nil
                                             target:self
                                           selector:@selector(onPhotoAlbum:)];
    [moreBtn setTitle:Localized(@"ALBUM") forState:UIControlStateNormal];
    [moreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [moreBtn.titleLabel setFont:SYSFONT(15)];
    moreBtn.custom_acceptEventInterval = 1.0f;
    moreBtn.frame = CGRectMake(JX_SCREEN_WIDTH - 32-15, JX_SCREEN_TOP - 30, 32, 15);
    [self.tableHeader addSubview:moreBtn];
}

- (void)onPhotoAlbum:(UIButton *)button {
    RITLPhotosViewController *photoController = RITLPhotosViewController.photosViewController;
    photoController.configuration.maxCount = 1;//最大的选择数目
    photoController.configuration.containVideo = NO;//选择类型，目前只选择图片不选择视频
    photoController.configuration.containImage = YES;//选择类型，目前只选择图片不选择视频
    photoController.configuration.isRichScan = YES;//选择类型，目前只选择图片不选择视频
    photoController.photo_delegate = self;
    photoController.thumbnailSize = CGSizeMake(320, 320);//缩略图的尺寸
    //    photoController.defaultIdentifers = self.saveAssetIds;//记录已经选择过的资源
    photoController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:photoController animated:true completion:^{}];

}

#pragma mark - 图库选择二维码后的回调
- (void)photosViewController:(UIViewController *)viewController thumbnailImages:(NSArray *)thumbnailImages infos:(NSArray<NSDictionary *> *)infos {
    
    UIImage *image = [thumbnailImages firstObject];
    if(image){
        
        //1. 初始化扫描仪，设置设别类型和识别质量
        CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
        
        //2. 扫描获取的特征组
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        
        //3. 获取扫描结果
        if (features.count <= 0) {
            [g_App showAlert:Localized(@"JX_NoQrCode")];
            return;
        }
        
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        
        NSString *stringValue = feature.messageString;
        NSRange range = [stringValue rangeOfString:@"shikuId"];
        if (range.location != NSNotFound) {
            
            NSString * idStr = [stringValue substringFromIndex:range.location + range.length + 1];
            
            if ([stringValue rangeOfString:@"=user"].location != NSNotFound) {
                
                [g_server userGetByAccountWithAccount:idStr toView:self];
                
                
            }else if ([stringValue rangeOfString:@"=group"].location != NSNotFound) {
                [g_server getRoom:idStr toView:self];
            }else if ([stringValue rangeOfString:@"=open"].location != NSNotFound) {
                if ([idStr rangeOfString:@"http://"].location != NSNotFound && [idStr rangeOfString:@"https://"].location != NSNotFound) {
                    webpageVC * webVC = [webpageVC alloc];
                    webVC.url= idStr;
                    webVC.isSend = YES;
                    webVC = [webVC init];
                    [self actionQuit];
                    [g_navigation.navigationView addSubview:webVC.view];
//                    [g_navigation pushViewController:webVC animated:YES];
                }else{
                    [g_App showAlert:Localized(@"JX_TheUrlNotOpen")];
                }
            }
            
        }else {
            NSRange idRange = [stringValue rangeOfString:@"userId"];
            NSRange nameRange = [stringValue rangeOfString:@"userName"];
            
            if ([stringValue hasPrefix:@"http://"] || [stringValue hasPrefix:@"https://"]) {
                webpageVC * webVC = [webpageVC alloc];
                webVC.url= stringValue;
                webVC.isSend = YES;
                webVC = [webVC init];
                [self actionQuit];
                [g_navigation.navigationView addSubview:webVC.view];
//                [g_navigation pushViewController:webVC animated:YES];
                
            }else if (stringValue.length == 20 && [self isNumber:stringValue]){
                // 对面付款， 己方收款
                [self getMoney:stringValue];
            }else if (idRange.location != NSNotFound && nameRange.location != NSNotFound) {
                // 己方付款， 对面收款
                [self PaySide:stringValue];
            }
        }
    }else {
        
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:Localized(@"JX_ScanResults") message:Localized(@"JX_Haven'tQrCode") delegate:nil cancelButtonTitle:Localized(@"JX_Confirm") otherButtonTitles:nil, nil];
        
        [alertView show];
    }
}

- (void)getMoney:(NSString *)stringValue {
    JXInputMoneyVC *inputVC = [[JXInputMoneyVC alloc] init];
    inputVC.type = JXInputMoneyTypeCollection;
    inputVC.paymentCode = stringValue;
    [g_navigation pushViewController:inputVC animated:YES];
    [self actionQuit];
}

- (void)PaySide:(NSString *)stringValue {
    SBJsonParser * resultParser = [[SBJsonParser alloc] init] ;
    NSDictionary *dict = [resultParser objectWithString:stringValue];
    JXInputMoneyVC *inputVC = [[JXInputMoneyVC alloc] init];
    inputVC.type = JXInputMoneyTypePayment;
    inputVC.userId = [dict objectForKey:@"userId"];
    inputVC.userName = [dict objectForKey:@"userName"];
    if ([dict objectForKey:@"money"]) {
        inputVC.money = [dict objectForKey:@"money"];
    }
    if ([dict objectForKey:@"description"]) {
        inputVC.desStr = [dict objectForKey:@"description"];
    }
    [g_navigation pushViewController:inputVC animated:YES];
    [self actionQuit];

}


-(void)configView{
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:kScanRect];
    [self.view addSubview:imageView];
    
    if (self.isShowMyQR) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP + 20, JX_SCREEN_WIDTH, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = Localized(@"JX_ISweepYou");
        label.font = [UIFont systemFontOfSize:16.0];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 5, JX_SCREEN_WIDTH, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = Localized(@"JX_PutQrCodeIntoBox");
        label.font = [UIFont systemFontOfSize:16.0];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame) + 30, JX_SCREEN_WIDTH, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = Localized(@"JX_YouSweepMe");
        label.font = [UIFont systemFontOfSize:16.0];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        
        NSMutableString * qrStr = [NSMutableString stringWithFormat:@"%@?action=user",g_config.website];
        [qrStr appendFormat:@"&shikuId=%@",g_myself.account];
        UIImage * qrImage = [QRImage qrImageForString:qrStr imageSize:QRWIDTH logoImage:g_mainVC.psMyviewVC.head.image logoImageSize:50];
        UIImageView *qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT,CGRectGetMaxY(label.frame) + 5, QRWIDTH, QRWIDTH)];
        qrImageView.image = qrImage;
        [self.view addSubview:qrImageView];
    }
    
    upOrdown = NO;
    num =0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT, TOP+10, QRWIDTH, 2)];
    _line.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
}

-(void)animation1
{
    if (upOrdown == NO) {
        _line.frame = CGRectMake(LEFT, TOP+10+2*num, QRWIDTH, 2);
        if (2*num >= (QRWIDTH - 10)) {
            upOrdown = YES;
        }else {
            num ++;
        }
    }
    else {
        _line.frame = CGRectMake(LEFT, TOP+10+2*num, QRWIDTH, 2);
        if (2*num <= 0) {
            upOrdown = NO;
        }else {
            num --;
        }
    }
    
}

- (void)setCropRect:(CGRect)cropRect{
    cropLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, cropRect);
//    CGPathAddRect(path, nil, self.view.bounds);
    CGRect viewRect = self.view.bounds;
    viewRect.origin.y += JX_SCREEN_TOP;
    viewRect.size.height -= JX_SCREEN_TOP;
    CGPathAddRect(path, nil, viewRect);
    
    [cropLayer setFillRule:kCAFillRuleEvenOdd];
    [cropLayer setPath:path];
    [cropLayer setFillColor:[UIColor blackColor].CGColor];
    [cropLayer setOpacity:0.6];
    
    
    [cropLayer setNeedsDisplay];
    
    [self.view.layer addSublayer:cropLayer];
}


- (void)setupCamera
{

    if (![g_server checkCameraLimits]) {
        return;
    }
    
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置扫描区域
    CGFloat top = TOP/JX_SCREEN_HEIGHT;
    CGFloat left = LEFT/JX_SCREEN_WIDTH;
    CGFloat width = QRWIDTH/JX_SCREEN_WIDTH;
    CGFloat height = QRWIDTH/JX_SCREEN_HEIGHT;
    ///top 与 left 互换  width 与 height 互换
    [_output setRectOfInterest:CGRectMake(top,left, height, width)];
    
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    [_output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
    
    // Preview
    _previewLayer =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    
//    // Start
//    [_session startRunning];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        //停止扫描
        [_session stopRunning];
        [timer setFireDate:[NSDate distantFuture]];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        NSLog(@"扫描结果：%@",stringValue);
        
        NSString *action = [self subString:stringValue withString:@"action"];
        if ([action isEqualToString:@"sendChatHistory"]) {
            
            NSString *userId = [self subString:stringValue withString:@"userId"];
            if (![userId isEqualToString:g_myself.userId]) {

                [JXMyTools showTipView:Localized(@"JX_PleaseLoginSameAccountScan")];
                return;
            }
            
            NSString *host = [self subString:stringValue withString:@"ip"];
            NSString *port = [self subString:stringValue withString:@"port"];
            
            self.tcpScoket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
            
            NSError *error;
            BOOL isConnect = [self.tcpScoket connectToHost:host onPort:[port intValue] withTimeout:-1 error:&error];
            
            [self.tcpScoket readDataWithTimeout:-1 tag:0];
            
            if (isConnect) {
                
                self.moveActionVC = [[JXChatLogMoveActionVC alloc] init];
                [g_navigation pushViewController:self.moveActionVC animated:YES];
                
                NSLog(@"连接成功");
            }else {
                [JXMyTools showTipView:Localized(@"JX_ConnectFailed")];
                NSLog(@"连接失败");
            }
            
            return;
        }
        
        if ([action isEqualToString:@"webLogin"]) {
            
            NSString *qrCodeKey = [self subString:stringValue withString:@"qrCodeKey"];
            self.qrCodeKey = qrCodeKey;
            self.isQRLoginAction = NO;
            [g_server userQrCodeLoginWithQRCodeKey:qrCodeKey type:@"1" toView:self];
            
            return;
        }
        
        NSRange range = [stringValue rangeOfString:@"shikuId"];
        if (range.location != NSNotFound) {
            
            NSString * idStr = [stringValue substringFromIndex:range.location + range.length + 1];
            
            if ([stringValue rangeOfString:@"=user"].location != NSNotFound) {
//                [g_server getUser:idStr toView:self];
                [g_server userGetByAccountWithAccount:idStr toView:self];
            }else if ([stringValue rangeOfString:@"=group"].location != NSNotFound) {
                [g_server getRoom:idStr toView:self];
            }else if ([stringValue rangeOfString:@"=open"].location != NSNotFound) {
                if ([idStr rangeOfString:@"http://"].location != NSNotFound && [idStr rangeOfString:@"https://"].location != NSNotFound) {
                    webpageVC * webVC = [webpageVC alloc];
                    webVC.url= idStr;
                    webVC.isSend = YES;
                    webVC = [webVC init];
                    [self actionQuit];
                    [g_navigation.navigationView addSubview:webVC.view];
//                    [g_navigation pushViewController:webVC animated:YES];
                }else{
                    [g_App showAlert:Localized(@"JX_TheUrlNotOpen")];
                }
            }
            
        }else {
            NSRange idRange = [stringValue rangeOfString:@"userId"];
            NSRange nameRange = [stringValue rangeOfString:@"userName"];

            if ([stringValue hasPrefix:@"http://"] || [stringValue hasPrefix:@"https://"]) {
                webpageVC * webVC = [webpageVC alloc];
                webVC.url= stringValue;
                webVC.isSend = YES;
                webVC = [webVC init];
                [self actionQuit];
                [g_navigation.navigationView addSubview:webVC.view];
//                [g_navigation pushViewController:webVC animated:YES];
                
            }else if (stringValue.length == 19 && [self isNumber:stringValue]){
                // 对面付款， 己方收款
                [self getMoney:stringValue];
            }else if (idRange.location != NSNotFound && nameRange.location != NSNotFound) {
                // 己方付款， 对面收款
                [self PaySide:stringValue];
            }
        }
        
//        NSDictionary * dict = [[[SBJsonParser alloc] init] objectWithString:stringValue];
//        
//        if (dict[@"shiku"] && dict[@"action"]) {
//            NSString * idStr = dict[@"shiku"];
//            NSString * actionStr = dict[@"action"];
//            if ([actionStr isEqualToString:@"user"]) {
//                [g_server getUser:idStr toView:self];
//            }else if ([actionStr isEqualToString:@"group"]) {
//                [g_server getRoom:idStr toView:self];
//            }else if ([actionStr isEqualToString:@"open"]){
//                if ([idStr rangeOfString:@"http://"].location != NSNotFound && [idStr rangeOfString:@"https://"].location != NSNotFound) {
//                    webpageVC * webVC = [webpageVC alloc];
//                    webVC.url= idStr;
//                    webVC.isSend = YES;
//                    webVC = [webVC init];
//                    [g_window addSubview:webVC.view];
//                }else{
//                    [g_App showAlert:@"URL不标准,无法打开"];
//                }
//                
//            }
//        }else{
//            if ([stringValue hasPrefix:@"http://"] || [stringValue hasPrefix:@"https://"]) {
//                webpageVC * webVC = [webpageVC alloc];
//                webVC.url= stringValue;
//                webVC.isSend = YES;
//                webVC = [webVC init];
//                [g_window addSubview:webVC.view];
//                [self actionQuit];
//                
//            }else {
//    
//            }
//        }
        

        
        
//        NSArray *arry = metadataObject.corners;
//        for (id temp in arry) {
//            NSLog(@"%@",temp);
//        }
        
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"扫描结果" message:stringValue preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            if (_session != nil && timer != nil) {
//                [_session startRunning];
//                [timer setFireDate:[NSDate date]];
//            }
//            
//        }]];
//        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        NSLog(@"%@",Localized(@"JX_NoScanningInformation"));
        return;
    }
    
}

- (NSString *)subString:(NSString *)url withString:(NSString *)str {
    NSString *urlStr = [url copy];
    
    NSRange range = [urlStr rangeOfString:@"//"];
    if (range.location != NSNotFound) {
        urlStr = [urlStr substringFromIndex:range.location + range.length];
    }
    
    range = [urlStr rangeOfString:[NSString stringWithFormat:@"%@=",str]];
    if (range.location == NSNotFound) {
        return nil;
    }
    urlStr = [urlStr substringFromIndex:range.location + range.length];
    
    range = [urlStr rangeOfString:@","];
    if (range.location != NSNotFound) {
        urlStr = [urlStr substringToIndex:range.location];
    }else {
        range = [urlStr rangeOfString:@"&"];
        if (range.location != NSNotFound) {
            urlStr = [urlStr substringToIndex:range.location];
        }
    }
    
    return urlStr;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    
    if (err) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [g_notify postNotificationName:kXMPPAllMsgNotifaction object:nil userInfo:nil];
            
            [self actionQuit];
            [self.moveActionVC moveActionFinish];
        });
        NSLog(@"断开连接");
    }
}

//已经连接上
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    
    NSLog(@"连接上: host = %@, port = %d", host, port);
    [self.connectHostMuArr addObject:host];
    
    [self.tcpScoket readDataWithTimeout:-1 tag:0];
}


- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock {
    
    NSLog(@"断开连接");
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock{
    NSLog(@"断开连接");
    //    [self addMessage:[NSString stringWithFormat:@"%d断开连接:%@ ",a,sock]];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    if (self.lastData.length > 0) {
        NSMutableData *mData = [[NSMutableData alloc] init];
        [mData appendData:self.lastData];
        [mData appendData:data];
        data = [mData copy];
    }
    
    if (data.length < 4) {
        self.lastData = data;
        return;
    }
    
    // 取出消息长度
    NSData *da = [data subdataWithRange:NSMakeRange(0, 4)];
    int len;
    [da getBytes:&len length:sizeof(len)];
    NTOHL(len);
    
    if (len > (data.length - 4)) {
        self.lastData = data;
        return;
    }
    
    self.lastData = nil;
    
    // 取出消息体
    da = [data subdataWithRange:NSMakeRange(4, len)];
    
    NSString *jsonStr = [[NSString alloc] initWithData: da encoding:NSUTF8StringEncoding];
    SBJsonParser * resultParser = [[SBJsonParser alloc] init] ;
    NSDictionary *resultObject = [resultParser objectWithString:jsonStr];
    
    if (!resultObject && jsonStr.length > 0) {
        NSArray *ids = [jsonStr componentsSeparatedByString:@","];
        if (ids.count > 0) {
            self.isMyLog = [[ids firstObject] isEqualToString:g_myself.userId];
            self.logUserId = [ids lastObject];
        }
    }
    
    if (!self.isMyLog) {
        return;
    }
    
    JXMessageObject *msg = [[JXMessageObject alloc] init];
    msg.isNoEncrypt = YES;
    [msg fromDictionary:resultObject];
    msg.timeSend = [NSDate dateWithTimeIntervalSince1970:[[resultObject objectForKey:kMESSAGE_TIMESEND] doubleValue] / 1000.0];
    if (msg.messageId.length > 0) {
        if ([msg doInsertMsg:MY_USER_ID tableName:self.logUserId]) {
            [msg updateLastSend:UpdateLastSendType_None];
        }
        
    }
    
    [self.tcpScoket readDataWithTimeout: -1 tag: 0];
    
    
    if (data.length - 4 > len) {
        [self socket:sock didReadData:[data subdataWithRange:NSMakeRange(4 + len, data.length - (4 + len))] withTag:tag];
    }
}
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    
    NSLog(@"发送成功");
}

//- (void)creatCaptureDevice{
//    //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
//    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    
//    //使用设备初始化输入
//    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
//    
//    //生成输出对象
//    self.output = [[AVCaptureMetadataOutput alloc]init];
//    
//    //设置代理，一旦扫描到指定类型的数据，就会通过代理输出
//    //在扫描的过程中，会分析扫描的内容，分析成功后就会调用代理方法在队列中输出
//    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
//    
//    //生成会话，用来结合输入输出
//    self.session = [[AVCaptureSession alloc]init];
//    if ([self.session canAddInput:self.input]) {
//        [self.session addInput:self.input];
//    }
//    if ([self.session canAddOutput:self.output]) {
//        [self.session addOutput:self.output];
//    }
//    
//    //指定当扫描到二维码的时候，产生输出
//    //AVMetadataObjectTypeQRCode 指定二维码
//    //指定识别类型一定要放到添加到session之后
//    [self.output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
//    //设置扫描信息的识别区域，左上角为(0,0),右下角为(1,1),不设的话全屏都可以识别。设置过之后可以缩小信息扫描面积加快识别速度。
//    //这个属性并不好设置，整了半天也没太搞明白，到底x,y,width,height,怎么是对应的，这是我一点一点试的扫描区域，看不到只能调一下，扫一扫试试
////    [self.output setRectOfInterest:CGRectMake(95/JX_SCREEN_HEIGHT, 40/JX_SCREEN_WIDTH, 240/JX_SCREEN_HEIGHT, 240/JX_SCREEN_WIDTH)];
//    //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
//    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
//    self.previewLayer.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH , JX_SCREEN_HEIGHT);
//    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    [self.view.layer addSublayer:self.previewLayer];
//    
//    //开始启动
//    [self.session startRunning];
//}
//
//#pragma mark 输出的代理
////metadataObjects ：把识别到的内容放到该数组中
//- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
//{
//    //停止扫描
//    [self.session stopRunning];
////    [self.timer invalidate];
////    self.timer = nil;
////    [self.lineView removeFromSuperview];
//    if ([metadataObjects count] >= 1) {
//        //数组中包含的都是AVMetadataMachineReadableCodeObject 类型的对象，该对象中包含解码后的数据
//        AVMetadataMachineReadableCodeObject *qrObject = [metadataObjects lastObject];
//        //拿到扫描内容在这里进行个性化处理
//        [g_App showAlert:qrObject.stringValue];
//        NSLog(@"识别成功%@",qrObject.stringValue);
//    }
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    
    if ([aDownload.action isEqualToString:act_roomJoin]) {
        
        dict = _dataDict;
        
        BOOL isNeedVerify = [dict[@"isNeedVerify"] boolValue];
        long userId = [dict[@"userId"] longLongValue];
        if (isNeedVerify && userId != [g_myself.userId longLongValue]) {
            
            self.roomJid = [dict objectForKey:@"jid"];
            self.roomUserName = [dict objectForKey:@"nickname"];
            self.roomUserId = [dict objectForKey:@"userId"];
            
            //                JXInputVC* vc = [JXInputVC alloc];
            //                vc.delegate = self;
            //                vc.didTouch = @selector(onInputHello:);
            //                vc.inputTitle = Localized(@"JX_GroupOwnersHaveEnabled");
            //                vc.titleColor = [UIColor lightGrayColor];
            //                vc.titleFont = [UIFont systemFontOfSize:13.0];
            //                vc.inputHint = Localized(@"JX_PleaseEnterTheReason");
            //                vc = [vc init];
            //                [g_window addSubview:vc.view];
            
            self.inputRectView = [[JXInputRectView alloc] initWithFrame:self.view.bounds sureBtnTitle:Localized(@"JX_Send")];
            self.inputRectView.title = Localized(@"JX_GroupOwnersHaveEnabled");
            self.inputRectView.placeString = Localized(@"JX_PleaseEnterTheReason");
            self.inputRectView.delegate = self;
            self.inputRectView.onRelease = @selector(onInputHello);
            
            [g_window addSubview:self.inputRectView];
            
        }else {
            _chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] lastDate:nil isNew:YES];
            //        [_wait start:Localized(@"JXAlert_AddRoomIng") delay:30];
            //新房间:
            _chatRoom.delegate = self;
            [_chatRoom joinRoom:YES];
            
            [self showChatView];
            
        }
        
    }
    
    if( [aDownload.action isEqualToString:act_UserGet] ){
        JXUserObject* user = [[JXUserObject alloc]init];
        [user getDataFromDict:dict];
        
        JXUserInfoVC* vc = [JXUserInfoVC alloc];
        vc.user       = user;
        vc = [vc init];
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
        
        [self actionQuit];
    }else if( [aDownload.action isEqualToString:act_roomGet] ){
        
        _dataDict = dict;
        
        if(g_xmpp.isLogined != 1){
            // 掉线后点击title重连
            // 判断XMPP是否在线  不在线重连
            [g_xmpp showXmppOfflineAlert];
            return;
        }
        
//        _chatRoom = [g_xmpp.roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] isNew:YES];
        
#ifdef IS_MsgEncrypt
        if ([g_config.isOpenSecureChat boolValue]) {
            if ([[dict objectForKey:@"isSecretGroup"] boolValue]) {
                
                if (!g_msgUtil.dhPrivateKey) {
                    
                    [self actionQuit];
                    //不能进入私密群组
                    [JXMyTools showTipView:Localized(@"JX_CannotEnterPrivateGroup")];
                    return;
                }
                
            }
        }
#endif
        
        JXUserObject *user = [[JXUserObject sharedInstance] getUserById:[dict objectForKey:@"jid"]];
        if(user && [user.groupStatus intValue] == 0){
            //老房间:
            _chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] lastDate:nil isNew:YES];
            //老房间:
            [self showChatView];
            [self actionQuit];
        }else{
            [g_server roomJoin:[dict objectForKey:@"id"] userId:g_myself.userId nickName:g_myself.userNickname toView:self];
        }
    }
    
    if ([aDownload.action isEqualToString:act_UserQrCodeLogin]) {
        
        if (self.isQRLoginAction) {
            [JXMyTools showTipView:Localized(@"JX_SuccessfulLogin")];
        }else {
            JXWebLoginVC *vc = [[JXWebLoginVC alloc] init];
            vc.delegate = self;
            vc.isQRLogin = YES;
            [g_navigation pushViewController:vc animated:YES];
            
            [self actionQuit];
        }
    }
    
    if ([aDownload.action isEqualToString:act_UserGetByAccount]) {
        JXUserInfoVC* vc = [JXUserInfoVC alloc];
        vc.userId       = dict[@"userId"];
        vc.fromAddType = 1;
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
        [self actionQuit];
    }
}

- (void)webLoginSuccess {
    self.isQRLoginAction = YES;
    [g_server userQrCodeLoginWithQRCodeKey:self.qrCodeKey type:@"2" toView:self];
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
    [self actionQuit];
    
    //    msg.fromUserId = self.roomJid;
    //    msg.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
    //    msg.content = @"申请已发送给群主，请等待群主确认";
    //    [msg insert:self.roomJid];
    //    if ([self.delegate respondsToSelector:@selector(needVerify:)]) {
    //        [self.delegate needVerify:msg];
    //    }
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

-(void)xmppRoomDidJoin{
    
    NSDictionary * dict = _dataDict;
    
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
    user.content = @" ";
    
    if (![user haveTheUser])
        [user insertRoom];
//    else
//        [user update];
    //    [user release];
    
//    [g_server addRoomMember:[dict objectForKey:@"id"] userId:g_myself.userId nickName:g_myself.userNickname toView:self];
//    [g_server roomJoin:[dict objectForKey:@"id"] userId:g_myself.userId nickName:g_myself.userNickname toView:self];

    [self actionQuit];

    dict = nil;
    _chatRoom.delegate = nil;
    
}

-(void)showChatView{
    [_wait stop];
    NSDictionary * dict = _dataDict;
    
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
    userObj.userNickname = [dict objectForKey:@"name"];
    userObj.showMember = [dict objectForKey:@"showMember"];
    userObj.allowSendCard = [dict objectForKey:@"allowSendCard"];
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


- (BOOL)isNumber:(NSString *)strValue
{
    if (strValue == nil || [strValue length] <= 0)
    {
        return NO;
    }
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSString *filtered = [[strValue componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    if (![strValue isEqualToString:filtered])
    {
        return NO;
    }
    return YES;
}

- (void)actionQuit {
    [super actionQuit];
    
    [self.tcpScoket disconnect];
}

@end
