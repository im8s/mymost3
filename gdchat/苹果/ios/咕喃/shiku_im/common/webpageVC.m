//
//  webpageVC.m
//  sjvodios
//
//  Created by  on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
// 测试

#import "webpageVC.h"
#import "AppDelegate.h"
#import "JXServer.h"
#import "ImageSelectorViewController.h"
#import "JXRelayVC.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "JXWebAuthView.h"
#import "JXLinksShareVC.h"
#import "addMsgVC.h"
#import "JXReportUserVC.h"
#import "UIWebView+JXSearchWebView.h"
#import "JXWebviewProgress.h"
#import "JXShareManager.h"
#import "JXShareModel.h"
#import "JXVerifyPayVC.h"
#import "JXPayPasswordVC.h"
#import "JXSkPayVC.h"

@interface webpageVC ()<ImageSelectorViewDelegate,JXWebAuthViewDelegate,UITextFieldDelegate,UIScrollViewDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate,JXSkPayVCDelegate>

@property (nonatomic, strong) webpageVC *pSelf;
@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) UIButton *sendBtn;

@property (nonatomic,copy) NSString *appId;
@property (nonatomic,copy) NSString *callbackUrl;
@property (nonatomic, strong) JXLinksShareVC *linksShareVC;
@property (nonatomic, strong) ImageSelectorViewController *SelectorVC;
@property (nonatomic, strong) addMsgVC* addMsgVC;
@property (nonatomic, strong) JXReportUserVC * reportVC;
@property (nonatomic, strong) JXRelayVC *relayVC;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIView *keyboardView;
@property (nonatomic, strong) UIButton *suspensionBtn;
@property (nonatomic, assign) CGRect subWindowFrame;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *numLabel;

@property (nonatomic, strong) NSString *textStr;

@property (nonatomic, assign) int textType;
@property (nonatomic, assign) BOOL isFloatWindow;

@property (nonatomic, assign) int clickTime;
@property (nonatomic, assign) int keywordsNum;

@property (nonatomic, strong) UIImage *firstImage;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, strong) NSDictionary *shareDic;
@property (nonatomic, strong) NSURL *audioPath;
@property (nonatomic, copy) NSString *amrPath;

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) NSDictionary *skPayDic;
@property (nonatomic, strong) JXVerifyPayVC * verVC;
@property (nonatomic, strong) NSDictionary *orderDic;

// 进度条
@property (nonatomic, strong) JXWebviewProgress *progressLine;

@end

@implementation webpageVC
@synthesize webView,url;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_pSelf) {
        return;
    }
    NSURL *audioUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@share.wav",docFilePath]];
    self.audioPath = audioUrl;
    
    _pSelf = self;
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    //        self.view.frame = g_window.bounds;
    self.isGotoBack = YES;
    [self createHeadAndFoot];
    self.tableBody.backgroundColor = HEXCOLOR(0xF2F2F2);
    self.textType = 0;
    self.isFloatWindow = NO;
    if (self.isSend) {
        //            self.sendBtn = [UIFactory createButtonWithTitle:Localized(@"JXSendToFriend") titleFont:[UIFont systemFontOfSize:15] titleColor:[UIColor whiteColor] normal:nil highlight:nil];
        //            [self.sendBtn addTarget:self action:@selector(onSend) forControlEvents:UIControlEventTouchUpInside];
        //            wCGSize btnSize = [Localized(@"JXSendToFriend") boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0]} context:nil].size;
        //            self.sendBtn.frame = CGRectMake(JX_SCREEN_WIDTH - btnSize.width - 10, JX_SCREEN_TOP - 34, btnSize.width + 10, 30);
        //            self.sendBtn.enabled = NO;
        //            self.sendBtn.alpha = 0.5;
        //            [self.tableHeader addSubview:self.sendBtn];
        UIButton* btn = [UIFactory createButtonWithImage:@"chat_more_black"
                                               highlight:nil
                                                  target:self
                                                selector:@selector(onMore)];
        btn.custom_acceptEventInterval = 1.0f;
        btn.frame = CGRectMake(JX_SCREEN_WIDTH - 18-15, JX_SCREEN_TOP - 18-15, 18, 18);
        [self.tableHeader addSubview:btn];
    }
    if ([self checkIsChinese:self.url]) {
        // 如果url 有中文，转译一次
        self.url = [self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }

    self.images = [NSMutableArray array];
    
    webView = [[UIWebView alloc] initWithFrame:self.tableBody.bounds];
    webView.backgroundColor = [UIColor whiteColor];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    webView.scrollView.delegate = self;
    [self.tableBody addSubview:webView];
    
    aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    aiv.center = self.view.center;
    aiv.hidesWhenStopped = YES;
    [self.view addSubview:aiv];
    
    if (self.titleString.length > 0) {
        self.title = self.titleString;
    }
    
    self.progressLine = [[JXWebviewProgress alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, 0, 3)];
    self.progressLine.lineColor = HEXCOLOR(0x18B710);
    [self.view addSubview:self.progressLine];
    // 开始走进度条
    [self.progressLine startLoadingAnimation];

    //        url = @"http://192.168.0.141:8080/websiteAuthorh/test.html";
    
    if ([url rangeOfString:@"http"].location != NSNotFound && g_server.isLogin) {
        // 验证链接url是否被锁定
//        NSString *encodeUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodeUrl = (NSString *)
        CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                  (CFStringRef)url,
                                                                  NULL,
                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                  kCFStringEncodingUTF8));
        [g_server userCheckReportUrl:encodeUrl toView:self];
    }else {
        [self webViewLoad];
    }
    
    // 监听UIWindow url改变
    [g_notify addObserver:self selector:@selector(onWebViewChangeUrl:) name:kWebViewChangeUrlNotif object:nil];
    [g_notify addObserver:self selector:@selector(actionQuitVC:) name:kActionRelayQuitVC object:nil];
    //监听UIWindow隐藏(网页视频全屏播放后会导致状态栏消失，这里做处理)
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endFullScreen) name:UIWindowDidBecomeHiddenNotification object:nil];
    // 监听键盘高度
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)webViewLoad {
    
    
    if (url) {
        NSURLRequest* p= nil;
        NSString *curl = [url copy];
        curl = curl.lowercaseString;
        if (![curl hasPrefix:@"http"]) {
            p = [[NSURLRequest alloc] initWithURL:[NSURL fileURLWithPath:url]];
        }else{
            p = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
            if (!p.URL) {
                p = [[NSURLRequest alloc] initWithURL:[NSURL fileURLWithPath:url]];
                self.title = Localized(@"JX_ShikuProtocolTitle");
            }
        }
        
        
        
        NSString *lastName =[[url lastPathComponent] lowercaseString];
        //先判断是 TXT 文件
        if ([lastName containsString:@".txt"]) {
            
            NSData *data = [NSData dataWithContentsOfURL:p.URL];
            // 加载二进制文件
            [self.webView loadData:data MIMEType:@"text/html" textEncodingName:@"GBK" baseURL:nil];
        }else {
            [webView loadRequest:p];
        }
        
        NSLog(@"webUrl=%@",url);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.webView.scrollView == scrollView) {
        if ([self.textField isFirstResponder]) {
            [self.textField resignFirstResponder];
        }
    }
}


-(void)endFullScreen{
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)actionQuitVC:(NSNotification *)notif {
    [self actionQuit];
}

- (void)actionQuit {
    if (self.isFloatWindow) {
        [self hideFloatWindow];
        return;
    }
    [super actionQuit];
    _pSelf = nil;
}

- (void)onMore {
    [self.view endEditing:YES];

    self.linksShareVC = [[JXLinksShareVC alloc] init];
//    self.linksShareVC.titleStr = [[NSURL URLWithString:self.url] host];
    self.linksShareVC.titleStr = self.url;
    self.linksShareVC.isFloatWindow = self.isFloatWindow;
    self.linksShareVC.delegate = self;
    self.linksShareVC.onSend = @selector(onSend);
    self.linksShareVC.onShare = @selector(onShare);
    self.linksShareVC.onWXSend = @selector(onWXSend);
    self.linksShareVC.onWXShare = @selector(onWXShare);
    self.linksShareVC.onCollection = @selector(onCollection);
    self.linksShareVC.onSafari = @selector(onSafari);
    self.linksShareVC.onReport = @selector(onReport);
    self.linksShareVC.onPasteboard = @selector(onPasteboard);
    self.linksShareVC.onUpdate = @selector(onUpdate);
    self.linksShareVC.onSearch = @selector(onSearch);
    self.linksShareVC.onTextType = @selector(onTextType);
    self.linksShareVC.onFloatWindow = @selector(onFloatWindow);
    [self.view addSubview:self.linksShareVC.view];
}

- (void) onSend {
    
    [self.linksShareVC hideShareView];
    
    if (self.shareDic) {
        JXMessageObject *msg = [[JXMessageObject alloc] init];
        msg.type = [NSNumber numberWithInt:kWCMessageTypeShare];
        msg.content = Localized(@"JX_[Link]");
        
        NSDictionary *dict = @{
                               @"url" : [self.shareDic objectForKey:@"url"],
//                               @"downloadUrl" : [self.shareDic objectForKey:@"downloadUrl"],
                               @"title" : [self.shareDic objectForKey:@"title"],
                               @"subTitle" : [self.shareDic objectForKey:@"subTitle"],
                               @"imageUrl" : [self.shareDic objectForKey:@"imageUrl"],
                               @"appName" : [self.shareDic objectForKey:@"appName"],
                               @"appIcon" : [self.shareDic objectForKey:@"appIcon"],
//                               @"urlSchemes" : [self.shareDic objectForKey:@"urlSchemes"]
                               };
        
        SBJsonWriter * OderJsonwriter = [SBJsonWriter new];
        NSString * jsonString = [OderJsonwriter stringWithObject:dict];
        
        msg.objectId = jsonString;
        
        self.relayVC = [[JXRelayVC alloc] init];
        self.relayVC.shareSchemes = [self.shareDic objectForKey:@"subTitle"];
        NSMutableArray *array = [NSMutableArray arrayWithObject:msg];
        self.relayVC.relayMsgArray = array;
        [self.view addSubview:self.relayVC.view];
    }else {
        
//        _SelectorVC = [[ImageSelectorViewController alloc] init];
//        _SelectorVC.imageFileNameArray = self.images;
//        _SelectorVC.title = Localized(@"JX_SelectImage");
//        _SelectorVC.imgDelegete = self;
//        //    [g_navigation pushViewController:vc animated:YES];
//        [self.view addSubview:_SelectorVC.view];
        
        JXMessageObject *msg = [[JXMessageObject alloc] init];
        msg.type = [NSNumber numberWithInt:kWCMessageTypeLink];
        NSMutableDictionary *dict = @{
                                      @"title" : self.titleStr,
                                      @"url" : self.shareUrl.length > 0 ? self.shareUrl : self.url,
                                      @"subTitle" : self.subTitle,
                                      }.mutableCopy;
        if (self.images.count > 0) {
            [dict addEntriesFromDictionary:@{@"img" : [self.images firstObject]}];
        }
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        msg.content = jsonStr;
        
        _relayVC = [[JXRelayVC alloc] init];
        NSMutableArray *array = [NSMutableArray arrayWithObject:msg];
        //    vc.msg = msg;
        _relayVC.relayMsgArray = array;
        _relayVC.isUrl = YES;
        [self.view addSubview:_relayVC.view];

    }
    
}

- (void)onShare {
    [self.linksShareVC hideShareView];
    
    if (self.shareDic) {
        
        _addMsgVC = [[addMsgVC alloc] init];
        //在发布信息后调用，并使其刷新
        _addMsgVC.block = ^{
        };
        _addMsgVC.shareUr = [self.shareDic objectForKey:@"url"];
        _addMsgVC.shareTitle = [self.shareDic objectForKey:@"title"];
        _addMsgVC.shareIcon = [self.shareDic objectForKey:@"imageUrl"];
        _addMsgVC.dataType = weibo_dataType_share;
        _addMsgVC.delegate = self;
        [self.view addSubview:_addMsgVC.view];
    }else{
        _addMsgVC = [[addMsgVC alloc] init];
        _addMsgVC.dataType = 2;
        _addMsgVC.urlShare = self.url;
        //    [g_navigation pushViewController:vc animated:YES];
        [self.view addSubview:_addMsgVC.view];
    }
}

- (void) onWXSend {

    [self didShareBtnClick:0];
}

- (void)onWXShare {
    [self didShareBtnClick:1];
}

- (void)didShareBtnClick:(NSInteger)shareTo{
    //    NSString *userId = [NSString stringWithFormat:@"%lld",[[_dataDict objectForKey:@"userId"] longLongValue]-1];
    //    NSString *userId = [NSString stringWithFormat:@"%lld",[[_dataDict objectForKey:@"userId"] longLongValue]];
    
    JXShareModel *shareModel = [[JXShareModel alloc] init];
    shareModel.shareTo = shareTo;
    //分享标题
    shareModel.shareTitle = self.titleStr;
    
    //分享内容
    shareModel.shareContent = self.subTitle;
    //    //分享链接
    //    shareModel.shareUrl = [NSString stringWithFormat:@"%@%@?userId=%lld&language=%@",g_config.shareUrl,act_ShareBoss,[[_dataDict objectForKey:@"userId"] longLongValue],[JXMyTools getCurrentSysLanguage]];
    //分享链接
    shareModel.shareUrl = self.url;
    
    //分享头像
    
//        shareModel.shareImageUrl = self.images.firstObject;
    shareModel.shareImage = self.firstImage;
    [[JXShareManager defaultManager] shareWith:shareModel delegate:self];
    
}

- (void)onCollection {
    
    [self.linksShareVC hideShareView];
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    
    [dataDict setValue:self.url forKey:@"msg"];
    [dataDict setValue:@5 forKey:@"type"];
    [dataDict setValue:@-1 forKey:@"collectType"];
    [dataDict setValue:self.url forKey:@"collectContent"];

    NSMutableArray * emoji = [NSMutableArray array];
    [emoji addObject:dataDict];
    [g_server addFavoriteWithEmoji:emoji toView:self];

}

- (void)onSafari {
    [self.linksShareVC hideShareView];
    NSURL *url;
    if ([self.url hasPrefix:@"http://"] || [self.url hasPrefix:@"https://"]) {
        url = [NSURL URLWithString:self.url];
    }else {
        url = [NSURL URLWithString:[@"http://" stringByAppendingString:self.url]];
    }
    [[UIApplication sharedApplication] openURL:url];
}


- (void)onReport {
    [self.linksShareVC hideShareView];
    _reportVC = [[JXReportUserVC alloc] init];
    _reportVC.delegate = self;
    _reportVC.isUrl = YES;
//    [g_navigation pushViewController:reportVC animated:YES];
    [self.view addSubview:_reportVC.view];
}

- (void)onPasteboard {
    [self.linksShareVC hideShareView];
    [g_server showMsg:Localized(@"JX_CopySuccess")];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.url;

}

- (void)onUpdate {
    [self.linksShareVC hideShareView];
    self.textType = 0;
    [self.webView reload];
}

- (void)onSearch {
    [self.linksShareVC hideShareView];

    self.keyboardView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM, JX_SCREEN_WIDTH, JX_SCREEN_BOTTOM)];
    self.keyboardView.backgroundColor = HEXCOLOR(0xE2E2E2);
    [self.view addSubview:self.keyboardView];
    
    UIButton *shutBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 14.5, 40, 20)];
    [shutBtn setTitle:Localized(@"JX_Close") forState:UIControlStateNormal];
    [shutBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [shutBtn addTarget:self action:@selector(clickShutBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.keyboardView addSubview:shutBtn];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(shutBtn.frame)+10, 5, JX_SCREEN_WIDTH-50-100, 39)];
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.layer.masksToBounds = YES;
    self.textField.layer.cornerRadius = 3.f;
    self.textField.returnKeyType = UIReturnKeySearch;
    self.textField.delegate = self;
    [self.keyboardView addSubview:self.textField];
    
    self.numLabel = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-50-100-45, 12, 40, 15)];
    self.numLabel.textColor = [UIColor lightGrayColor];
    self.numLabel.font = SYSFONT(13);
    [self.textField addSubview:self.numLabel];
    
    UIButton *upBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.textField.frame)+10, 9.5, 30, 30)];
    [upBtn setImage:[UIImage imageNamed:@"im_webpage_up"] forState:UIControlStateNormal];
    [upBtn setTag:100];
    [upBtn addTarget:self action:@selector(didBtnTurnThePage:) forControlEvents:UIControlEventTouchUpInside];
    [self.keyboardView addSubview:upBtn];

    UIButton *downBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(upBtn.frame)+10, 9.5, 30, 30)];
    [downBtn setImage:[UIImage imageNamed:@"im_webpage_down"] forState:UIControlStateNormal];
    [downBtn setTag:101];
    [downBtn addTarget:self action:@selector(didBtnTurnThePage:) forControlEvents:UIControlEventTouchUpInside];
    [self.keyboardView addSubview:downBtn];
    
    [self.textField becomeFirstResponder];
}

- (void)onTextType {
    [self.linksShareVC hideShareView];

    self.baseView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.baseView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.baseView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideTextTypeBaseView)];
    [self.baseView addGestureRecognizer:tap];

    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - JX_SCREEN_BOTTOM - 80, JX_SCREEN_WIDTH, JX_SCREEN_BOTTOM + 80)];
    view.backgroundColor = [UIColor whiteColor];
    [self.baseView addSubview:view];
    
    //滑块设置
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 50, JX_SCREEN_WIDTH - 40, 20)];
    _slider.minimumValue = 1;
    _slider.maximumValue = 6;
    _slider.minimumTrackTintColor = [UIColor clearColor];
    _slider.maximumTrackTintColor = [UIColor clearColor];
    
    [_slider setValue:self.textType > 0 ? self.textType : 2];
    
    //背景图
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 55, _slider.frame.size.width - 5, 10)];
    UIImage *img = [UIImage imageNamed:@"sliderbg"];
    imageView.image = img;
    
    //添加点击手势和滑块滑动事件响应
    [_slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    UITapGestureRecognizer *tapS = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    
    [_slider addGestureRecognizer:tapS];
    [view addSubview:imageView];
    [view addSubview:_slider];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x, 25, 20, 20)];
    label.font = [UIFont systemFontOfSize:14.0];
    label.textColor = [UIColor blackColor];
    label.text = @"A";
    [view addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) - 15, 25, 20, 20)];
    label.font = [UIFont systemFontOfSize:19.0];
    label.textColor = [UIColor blackColor];
    label.text = @"A";
    [view addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + (imageView.frame.size.width / 6), 25, 40, 20)];
    label.font = [UIFont systemFontOfSize:15.0];
    label.textColor = HEXCOLOR(0xB1B2B1);
    label.text = Localized(@"JX_Standard");
    [view addSubview:label];
}

- (void)onFloatWindow {
    [self.linksShareVC hideShareView];
    
    if (self.isFloatWindow) {
        self.isFloatWindow = NO;
        return;
    }
    
    self.isFloatWindow = YES;
    g_subWindow.frame = CGRectMake(JX_SCREEN_WIDTH - 80 - 10, 50, 60, 60);
    g_subWindow.backgroundColor = HEXCOLOR(0x424242);
    g_subWindow.layer.masksToBounds = YES;
    g_subWindow.layer.cornerRadius = 30;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [g_subWindow addGestureRecognizer:pan];
    
    _suspensionBtn = [[UIButton alloc] initWithFrame:g_subWindow.bounds];
    _suspensionBtn.backgroundColor = [UIColor clearColor];
    [_suspensionBtn addTarget:self action:@selector(showFloatWindow) forControlEvents:UIControlEventTouchUpInside];
    [g_subWindow addSubview:_suspensionBtn];

    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 20, 20)];
    imgV.image = [UIImage imageNamed:@"browser"];
    [g_subWindow addSubview:imgV];

    [self hideFloatWindow];
}

- (void)hideFloatWindow {
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, self.view.frame.size.width, 0);
    } completion:^(BOOL finished) {
        g_subWindow.hidden = NO;
        self.view.hidden = YES;
    }];
}


- (void)showFloatWindow {
    [g_navigation.navigationView bringSubviewToFront:self.view];
    g_subWindow.hidden = YES;
    self.view.hidden = NO;
    self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, self.view.frame.size.width, 0);
    
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
    }];
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.subWindowFrame = g_subWindow.frame;
    }
    CGPoint offset = [pan translationInView:g_App.window];
    CGPoint offset1 = [pan translationInView:g_subWindow];
    NSLog(@"pan - offset = %@, offset1 = %@", NSStringFromCGPoint(offset), NSStringFromCGPoint(offset1));
    
    CGRect frame = self.subWindowFrame;
    frame.origin.x += offset.x;
    frame.origin.y += offset.y;
    g_subWindow.frame = frame;
    
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        if (frame.origin.x <= JX_SCREEN_WIDTH / 2) {
            frame.origin.x = 10;
        }else {
            frame.origin.x = JX_SCREEN_WIDTH - frame.size.width - 10;
        }
        if (frame.origin.y < 0) {
            frame.origin.y = 10;
        }
        if ((frame.origin.y + frame.size.height) > JX_SCREEN_HEIGHT) {
            frame.origin.y = JX_SCREEN_HEIGHT - frame.size.height - 10;
        }
        [UIView animateWithDuration:0.5 animations:^{
            
            g_subWindow.frame = frame;
        }];
    }
}


- (void)clickShutBtn {
    self.keyboardView.hidden = YES;
    [self.keyboardView removeFromSuperview];
}

- (void)didBtnTurnThePage:(UIButton *)button {
    if (self.textField.text.length <= 0) return;
        
    if (button.tag == 100) {
        //上翻
        self.clickTime --;
        if (self.clickTime < 1) {
            self.clickTime = self.keywordsNum;
        }
        
    }else {
        //下翻
        self.clickTime ++;
        if (self.clickTime > self.keywordsNum) {
            self.clickTime = 1;
        }

    }
    self.keywordsNum = (int)[self.webView highlightAllOccurencesOfString:self.textStr index:self.clickTime];
    self.numLabel.text = [NSString stringWithFormat:@"%d/%d",self.clickTime,self.keywordsNum];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.returnKeyType==UIReturnKeySearch) {
        self.textStr = self.textField.text;
        self.keywordsNum = (int)[self.webView highlightAllOccurencesOfString:textField.text index:1];
        self.clickTime = self.keywordsNum != 0 ? 1 : 0;
        self.numLabel.text = [NSString stringWithFormat:@"%d/%d",self.clickTime,self.keywordsNum];
    }
    return YES;
}

#pragma mark --键盘弹出
- (void)keyboardWillChangeFrame:(NSNotification *)notification{
    //取出键盘动画的时间(根据userInfo的key----UIKeyboardAnimationDurationUserInfoKey)
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //取得键盘最后的frame(根据userInfo的key----UIKeyboardFrameEndUserInfoKey = "NSRect: {{0, 227}, {320, 253}}";)
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //计算控制器的view需要平移的距离
    CGFloat transformY = keyboardFrame.origin.y - self.view.frame.size.height;

    //执行动画
    [UIView animateWithDuration:duration animations:^{
        self.keyboardView.frame = CGRectMake(self.keyboardView.frame.origin.x, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM+transformY, self.keyboardView.frame.size.width, self.keyboardView.frame.size.height);
    }];
    if (self.tradeNo.length > 0 || self.redPacketNo.length > 0 || self.transferNo.length > 0 || self.withdrawalNo.length > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.webView.scrollView setContentOffset:CGPointMake(0, 150) animated:NO];
        });
    }
}
#pragma mark --键盘收回
- (void)keyboardDidHide:(NSNotification *)notification{
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        self.keyboardView.frame = CGRectMake(self.keyboardView.frame.origin.x, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM, self.keyboardView.frame.size.width, self.keyboardView.frame.size.height);
    }];
}

- (void)valueChanged:(UISlider *)sender
{
    //只取整数值，固定间距
    NSString *tempStr = [self numberFormat:sender.value];
    [sender setValue:tempStr.floatValue];
        NSLog(@"--------%@",tempStr);
    //设置网页字体大小
    int font = (tempStr.floatValue -1) *10 + 90;
    NSString* fontSize = [NSString stringWithFormat:@"%d%%",font];
    NSString* str = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%@'",fontSize];
    [self.webView stringByEvaluatingJavaScriptFromString:str];
    self.textType = [tempStr intValue];
}

- (void)tapAction:(UITapGestureRecognizer *)sender
{
    //取得点击点
    CGPoint p = [sender locationInView:_slider];
    //计算处于背景图的几分之几，并将之转换为滑块的值（1~6）
    float tempFloat = (p.x - 20) / (_slider.frame.size.width) * 6 + 1;
    NSString *tempStr = [self numberFormat:tempFloat];
    [_slider setValue:tempStr.floatValue];
//    NSLog(@"-------- %f,%f,%@", p.x, tempFloat, tempStr);
    //设置网页字体大小
    int font = (tempStr.floatValue -1) *10 + 90;
    NSString* fontSize = [NSString stringWithFormat:@"%d%%",font];
    NSString* str = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%@'",fontSize];
    [self.webView stringByEvaluatingJavaScriptFromString:str];
    self.textType = [tempStr intValue];
}

- (void)hideTextTypeBaseView {
    if (self.baseView) {
        [self.baseView removeFromSuperview];
    }
}

- (void)report:(JXUserObject *)reportUser reasonId:(NSNumber *)reasonId {
    [g_server reportUser:nil roomId:nil webUrl:self.url reasonId:reasonId toView:self];
}

-(void)imageSelectorDidiSelectImage:(NSString *)imagePath {

//    JXMessageObject *msg = [[JXMessageObject alloc] init];
//    msg.type = [NSNumber numberWithInt:kWCMessageTypeLink];
//    NSMutableDictionary *dict = @{
//                           @"title" : self.titleStr,
//                           @"url" : self.shareUrl,
//                           @"subTitle" : self.subTitle,
//                           }.mutableCopy;
//    if (imagePath.length > 0) {
//        [dict addEntriesFromDictionary:@{@"img" : imagePath}];
//    }
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    msg.content = jsonStr;
//
//    _relayVC = [[JXRelayVC alloc] init];
//    NSMutableArray *array = [NSMutableArray arrayWithObject:msg];
//    //    vc.msg = msg;
//    _relayVC.relayMsgArray = array;
//    _relayVC.isUrl = YES;
//    [self.view addSubview:_relayVC.view];
//    [g_navigation pushViewController:vc animated:YES];
}

-(void)dealloc{
     [[NSNotificationCenter defaultCenter]removeObserver:self];
//    NSLog(@"webpageVC.dealloc");
    self.url = nil;
//    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)onBack{
    [webView stopLoading];
    if(webView.canGoBack)
        [webView goBack];
    else
        [_wait start:Localized(@"webpageVC_NoPage") delay:2];
}

- (void)webAuthViewConfirmBtnAction {
    
    [g_server openCodeAuthorCheckAppId:self.appId state:g_server.access_token callbackUrl:self.callbackUrl toView:self];
    
}

-(UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView
{
    return webView;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString* s = request.URL.absoluteString;
    
    NSRange range = [s rangeOfString:@"websiteAuthorh/index.html"];
    if (range.location != NSNotFound && range.length > 0) {
        
        NSString *webAppName = [[self subString:s withString:@"webAppName"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *appId = [self subString:s withString:@"appId"];
        NSString *callbackUrl = [self subString:s withString:@"callbackUrl"];
        NSString *webAppsmallImg = [self subString:s withString:@"webAppsmallImg"];
        
        self.appId = appId;
        self.callbackUrl = callbackUrl;
        
        JXWebAuthView *view = [[JXWebAuthView alloc] init];
        view.tipTitle.text = [NSString stringWithFormat:@"%@%@:",webAppName,Localized(@"JX_ApplyFollowingPermissions")];
        view.delegate = self;
        [view.headImage sd_setImageWithURL:[NSURL URLWithString:webAppsmallImg] placeholderImage:[UIImage imageNamed:@"avatar_normal"]];
        [g_window addSubview:view];
        
        return NO;
    }
    
    NSRange rangeName  = [s rangeOfString:@"?productName="];
    NSRange rangePrice = [s rangeOfString:@"&productPrice="];
    if(rangeName.location != NSNotFound && rangePrice.location != NSNotFound){
        rangeName.location = rangeName.location+rangeName.length;    
        rangeName.length   = rangePrice.location-rangeName.location;
        
        rangePrice.location = rangePrice.location+rangePrice.length;
        rangePrice.length   = [s length]-rangePrice.location;
        
        _product = [s substringWithRange:rangeName];
        _price   = [[s substringWithRange:rangePrice] floatValue];
        
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);    
        _product =[_product stringByReplacingPercentEscapesUsingEncoding:enc];
        
//        [g_server doBuy:_product price:_price buyCallback:self];
        return NO;
    }
    if (![s isEqualToString:self.url] && [s containsString:@"paysuccessexample"]) {
        if (self.tradeNo.length > 0) {
            // 跳转预留地址,查看充值结果
            [g_server queryRechargeTradeNo:self.tradeNo toView:self];
            self.tradeNo = nil;
        }
        if (self.redPacketNo.length > 0) {
            // 红包支付回调
            [g_server queryRedPacketPayment:self.redPacketNo toView:self];
            self.redPacketNo = nil;
        }
        if (self.transferNo.length > 0) {
            // 转账支付回调
            [g_server yopPayQueryTransfer:self.transferNo toView:self];
            self.transferNo = nil;
        }
        if (self.withdrawalNo.length > 0) {
            // 提现回调
            [g_server yopPayQueryWithdraw:self.withdrawalNo toView:self];
            self.withdrawalNo = nil;
        }
        
        return YES;
    }
    
    //webView.hidden   = YES;
    return YES;
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
    
    range = [urlStr rangeOfString:@"&"];
    if (range.location != NSNotFound) {
        urlStr = [urlStr substringToIndex:range.location];
    }
    
    return urlStr;
}

-(int) didBuyOK:(AlixPayResult*)result{
//    [g_server updateMoneyForBuy:_product price:_price num:1 type:_type toView:self];
//    [_product release];
    return 0;
}

- (void)onWebViewChangeUrl:(NSNotification *)noti {
    if (self.isCloud) {
        dispatch_async(dispatch_get_main_queue(), ^{
            static  NSString * const hideWebReturn = @"document.querySelector('.back.left').style.display = 'none';";
            [self.webView stringByEvaluatingJavaScriptFromString:hideWebReturn];//注入js方法
        });
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
//    aiv.hidden = NO;
//    [aiv startAnimating];
//    [self.progressLine startLoadingAnimation];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
//    [aiv stopAnimating];
    
    NSString *string = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSLog(@"title===%@",string);
    if (self.titleString.length > 0) {
        self.title = self.titleString;
        self.titleStr = self.titleString;
    }else {
        self.titleStr = string;
        self.title = string;
    }
    self.url = [self.webView.request.URL absoluteString];
    self.subTitle = self.url;
//    NSString *articleImageUrl = [self.webView stringByEvaluatingJavaScriptFromString:@"document.images[0].src"];
//    NSLog(@"imageurl===%@",articleImageUrl);
//    NSString *lJs = [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
//    NSLog(@"lJs===%@",lJs);
    
    //这里是js，主要目的实现对url的获取
//    static  NSString * const jsGetImages =
//    @"var str = new Array();"
//    "$('img').each(function(){str.push($(this).attr('src'));});" "str.join('+') ";
    
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgScr = '';\
    for(var i=0;i<objs.length;i++){\
    imgScr = imgScr + objs[i].src + '+';\
    };\
    return imgScr;\
    };";
    
    [self.webView stringByEvaluatingJavaScriptFromString:jsGetImages];//注入js方法
    NSString *urlResurlt = [self.webView stringByEvaluatingJavaScriptFromString:@"getImages()"];
    NSMutableArray *mUrlArray = [NSMutableArray arrayWithArray:[urlResurlt componentsSeparatedByString:@"+"]];
    [self.images removeAllObjects];
    for (NSInteger i = 0; i < mUrlArray.count; i ++) {
        NSString *urlStr = mUrlArray [i];
        if (urlStr.length > 0) {
            [self.images addObject:urlStr];
        }
    }
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.images.firstObject]];
    if (data) {
        self.firstImage = [UIImage imageWithData:data];
    }
    
    self.sendBtn.enabled = YES;
    self.sendBtn.alpha = 1;
    
    [self.progressLine endLoadingAnimation];
    
    
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"updateShareData"] = ^() {
        
//        [g_App showAlert:@"成功"];
        
        NSArray *arguments = [JSContext currentArguments];
        for (JSValue *jsValue in arguments) {
            NSLog(@"=======%@",jsValue);
            NSData *jsonData = [[jsValue toString] dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData   options:NSJSONReadingMutableContainers error:&err];
            self.shareDic = [dic copy];
            NSLog(@"dict1 ===== %@",dic);
            
        }
        
    };
    
    
    // 网页调用开始录音
    context[@"startRecord"] = ^() {
        
        [self startRecord];
    };
    
    // 网页调用结束录音
    context[@"stopRecord"] = ^() {
        NSString *path = [self stopRecord];
        self.amrPath = path;
        return path;
    };
    
    // 开始播放
    context[@"playVoice"] = ^() {
        
        NSArray *arguments = [JSContext currentArguments];
        for (JSValue *jsValue in arguments) {
            self.amrPath = [jsValue toString];
        }
        [self playVoice];
    };
    
    // 暂停播放
    context[@"pauseVoice"] = ^() {
        [self pauseVoice];
    };
    
    // 停止播放
    context[@"stopVoice"] = ^() {
        [self stopVoice];
    };
    
    // 网页支付
    context[@"chooseSKPayInApp"] = ^() {
        NSArray *arguments = [JSContext currentArguments];
        for (JSValue *jsValue in arguments) {
            NSLog(@"=======%@",jsValue);
            NSData *jsonData = [[jsValue toString] dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData   options:NSJSONReadingMutableContainers error:&err];
            self.orderDic = [dic copy];
            [g_server payGetOrderInfoWithAppId:[dic objectForKey:@"appId"] prepayId:[dic objectForKey:@"prepayId"] toView:self];
            NSLog(@"dict1 ===== %@",dic);
            
        }
    };
    
    // 分享参数
    context[@"getShareParams"] = ^() {
        return self.shareParam;
    };
    
}

- (void)startRecord {
    NSDictionary *settings=[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithFloat:8000],AVSampleRateKey,
                            [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                            [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                            [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                            nil];
    
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: &error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
    
    NSURL *url = [NSURL fileURLWithPath:[FileInfo getUUIDFileName:@"wav"]];
    self.audioPath = url;
    
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:self.audioPath settings:settings error:&error];
    _audioRecorder.delegate = self;
    
    BOOL flag = NO;
    flag = [_audioRecorder prepareToRecord];
    [_audioRecorder setMeteringEnabled:YES];
    flag = [_audioRecorder peakPowerForChannel:1];
    flag = [_audioRecorder record];
}

- (NSString *)stopRecord {
    [_audioRecorder pause];
    [_audioRecorder stop];
    NSString *amrPath = [VoiceConverter wavToAmr:self.audioPath.path];
    [[ChatCacheFileUtil sharedInstance] deleteWithContentPath:self.audioPath.path];
    return amrPath;
}

- (void)playVoice {
    
    if (!self.amrPath) {
        self.amrPath = [VoiceConverter wavToAmr:self.audioPath.path];
    }

    [self setHardware];
    
    if ([self.amrPath rangeOfString:@"http"].location == NSNotFound) {
        
        NSString *file = [VoiceConverter amrToWav:self.amrPath];
        _player = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:file] error:nil];
    }else {
        
        NSString *path = [NSString stringWithFormat:@"%@%@",docFilePath,[self.amrPath lastPathComponent]];
        [[NSData dataWithContentsOfURL:[NSURL URLWithString:self.amrPath]] writeToFile:path atomically:YES];
        NSString *file = [VoiceConverter amrToWav:path];
        if (!file) {
            file = path;
        }
        
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:file] error:nil];
    }
    
    _player.delegate = self;
    //将播放文件加载到缓冲区
    [_player prepareToPlay];
    _player.volume = 1;
    [_player play];
}

- (void)pauseVoice {
    
    if (_player.isPlaying) {
        [_player pause];
    }else {
        [_player play];
    }
    
}

- (void)stopVoice {
    
    [_player stop];
    _player = nil;
}

// 播放完成
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player1 successfully:(BOOL)flag{
    
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSString *textJS = @"sk.playFinish()";
    [context evaluateScript:textJS];
}

-(void)setHardware{
    //    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    //初始化播放器的时候如下设置,添加监听
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    //默认情况下扬声器播放
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    //    audioSession = nil;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
//    [aiv stopAnimating];
//    [aiv removeFromSuperview];
    
    [self.progressLine endLoadingAnimation];
}

-(float)getMoney:(char*)s{
    char t[255]={};
    int j=0;
    for(int i=0;i<strlen(s);i++)
        if(s[i] == '?'){
            j=i;
            break;            
        }
    if(j<=0)
        return 0;
    for(int i=j+1;i<strlen(s);i++)
        t[i-j-1] = s[i];
    return atof(t);
}


- (void)didVerifyPay:(NSString *)sender {
    long time = (long)[[NSDate date] timeIntervalSince1970];
    time = (time *1000 + g_server.timeDifference)/1000;
    NSString *appId = [self.orderDic objectForKey:@"appId"];
    NSString *prepayId = [self.orderDic objectForKey:@"prepayId"];
    NSString *sign = [self.orderDic objectForKey:@"sign"];
    NSString *secret = [self getSecretWithPassword:sender time:time];
    
    // 参数顺序不能变,先放key再放value
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"appId",appId,@"prepayId",prepayId,@"sign",sign,@"money",self.skPayDic[@"money"], nil];
    
    [g_payServer payServerWithAction:act_PayPasswordPaymentV1 param:arr payPassword:sender time:time toView:self];
    
//    [g_server payPasswordPaymentWithAppId:appId prepayId:prepayId sign:sign time:[NSString stringWithFormat:@"%ld",time] secret:secret toView:self];
}

- (NSString *)getSecretWithPassword:(NSString *)password time:(long)time {
    NSMutableString *str1 = [NSMutableString string];
    [str1 appendString:g_myself.userId];
    [str1 appendString:g_server.access_token];
    
    NSMutableString *str2 = [NSMutableString string];
    [str2 appendString:APIKEY];
    [str2 appendString:[NSString stringWithFormat:@"%ld",time]];
    [str2 appendString:[g_server getMD5String:password]];
    str2 = [[g_server getMD5String:str2] mutableCopy];
    
    [str1 appendString:str2];
    str1 = [[g_server getMD5String:str1] mutableCopy];
    
    return [str1 copy];
}

- (void)dismissVerifyPayVC {
    [self.verVC.view removeFromSuperview];
}

- (void)skPayVC:(JXSkPayVC *)skPayVC payBtnAction:(NSDictionary *)payDic {
    if ([g_server.myself.isPayPassword boolValue]) {
        self.verVC = [JXVerifyPayVC alloc];
        self.verVC.type = JXVerifyTypeSkPay;
        self.verVC.RMB = [payDic objectForKey:@"money"];
        self.verVC.titleStr = [payDic objectForKey:@"desc"];
        self.verVC.delegate = self;
        self.verVC.didDismissVC = @selector(dismissVerifyPayVC);
        self.verVC.didVerifyPay = @selector(didVerifyPay:);
        self.verVC = [self.verVC init];
        
        [self.view addSubview:self.verVC.view];
    } else {
        JXPayPasswordVC *payPswVC = [JXPayPasswordVC alloc];
        payPswVC.type = JXPayTypeSetupPassword;
        payPswVC.enterType = JXVerifyTypeSkPay;
        payPswVC = [payPswVC init];
        [g_navigation pushViewController:payPswVC animated:YES];
    }
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    
    if ([aDownload.action isEqualToString:act_openCodeAuthorCheck]) {
        
        NSString *callbackUrl = [dict objectForKey:@"callbackUrl"];
        callbackUrl = [callbackUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString *url;
        if ([callbackUrl rangeOfString:@"?"].location != NSNotFound) {
            url = [NSString stringWithFormat:@"%@&code=%@",callbackUrl,[dict objectForKey:@"code"]];
        }else {
            url = [NSString stringWithFormat:@"%@?code=%@",callbackUrl,[dict objectForKey:@"code"]];
        }
        
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURLRequest *p = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        [webView loadRequest:p];
    }
    if([aDownload.action isEqualToString:act_userEmojiAdd]){
        [g_server showMsg:Localized(@"JX_CollectionSuccess")];
    }
    if([aDownload.action isEqualToString:act_Report]){
        [g_App showAlert:Localized(@"JXUserInfoVC_ReportSuccess")];
    }
    
    if ([aDownload.action isEqualToString:act_userCheckReportUrl]) {
        [self webViewLoad];
    }
    
    if ([aDownload.action isEqualToString:act_PayGetOrderInfo]) {
        
        self.skPayDic = [dict copy];
        JXSkPayVC *vc = [[JXSkPayVC alloc] init];
        vc.payDic = [dict copy];
        vc.delegate = self;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
    
    if ([aDownload.action isEqualToString:act_PayPasswordPayment] || [aDownload.action isEqualToString:act_PayPasswordPaymentV1]) {
        
        [self dismissVerifyPayVC];
        JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        NSString *textJS = @"sk.paySuccess()";
        [context evaluateScript:textJS];
    }
    if ([aDownload.action isEqualToString:act_queryRedPacketPayment] || [aDownload.action isEqualToString:act_yopPayQueryTransfer]) {
        if (self.delegate && [self.delegate respondsToSelector:self.isPayComplete]) {
            [self.delegate performSelectorOnMainThread:self.isPayComplete withObject:nil waitUntilDone:NO];
            [self actionQuit];
        }
    }
    if ([aDownload.action isEqualToString:act_queryRecharge] ) {
        [JXMyTools showTipView:Localized(@"JX_AddMoneyOK")];
        [self actionQuit];
    }
    if ([aDownload.action isEqualToString:act_yopPayQueryTransfer]) {
        [self actionQuit];
    }
    if ([aDownload.action isEqualToString:act_yopPayQueryWithdraw] ) {
        [JXMyTools showTipView:Localized(@"JX_WithdrawalSuccess")];
        [self actionQuit];
    }

}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    if ([aDownload.action isEqualToString:act_userCheckReportUrl]) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"prohibit" ofType:@"html"];
        NSURL* url = [NSURL  fileURLWithPath:path];//创建URL
        NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
        [webView loadRequest:request];//加载
        
        self.title = Localized(@"JX_ShikuProtocolTitle");

        return hide_error;
    }
    if ([aDownload.action isEqualToString:act_queryRecharge] || [aDownload.action isEqualToString:act_yopPayQueryTransfer] || [aDownload.action isEqualToString:act_queryRedPacketPayment] || [aDownload.action isEqualToString:act_yopPayQueryTransfer] || [aDownload.action isEqualToString:act_yopPayQueryWithdraw]) {
        [self actionQuit];
    }
    

    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    if ([aDownload.action isEqualToString:act_queryRecharge] || [aDownload.action isEqualToString:act_yopPayQueryTransfer] || [aDownload.action isEqualToString:act_queryRedPacketPayment] || [aDownload.action isEqualToString:act_yopPayQueryTransfer] || [aDownload.action isEqualToString:act_yopPayQueryWithdraw]) {
        [self actionQuit];
    }
    
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
//    [_wait start];
}

/**
 *  四舍五入
 *
 *  @param num 待转换数字
 *
 *  @return 转换后的数字
 */
- (NSString *)numberFormat:(float)num
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"0"];
    return [formatter stringFromNumber:[NSNumber numberWithFloat:num]];
}
/**
 *  @author zhengju, 16-06-29 10:06:05
 *
 *  @brief 检测字符串中是否含有中文，备注：中文代码范围0x4E00~0x9FA5，
 *
 *  @param string 传入检测到中文字符串
 *
 *  @return 是否含有中文，YES：有中文；NO：没有中文
 */
- (BOOL)checkIsChinese:(NSString *)string{
    for (int i=0; i<string.length; i++) {
        unichar ch = [string characterAtIndex:i];
        if (0x4E00 <= ch  && ch <= 0x9FA5) {
            return YES;
        }
    }
    return NO;
}


@end
