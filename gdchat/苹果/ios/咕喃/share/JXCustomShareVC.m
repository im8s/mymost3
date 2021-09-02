//
//  JXCustomShareVC.m
//  share
//
//  Created by 1 on 2019/3/20.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXCustomShareVC.h"
#import "JXSelectFriendVC.h"
#import "JXShareViewController.h"
#import "JXHttpRequet.h"
#import "JXShareViewController.h"
#import "JXShareUser.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#define HEIGHT 70
#define MY_INSET  0  // 每行左右间隙
#define TOP_ADD_HEIGHT  400  // 顶部添加的高度，防止下拉顶部空白

@interface JXCustomShareVC () <JXShareVCDlegate, JXSelectFriendVCDlegate>
@property (nonatomic, strong) UIScrollView *tableBody;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIImageView *imgV;
@property (nonatomic, strong) UIButton *sendFBtn;
@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIProgressView *rateProgressView;
@property (nonatomic, assign) int proInt;
@property (nonatomic, strong) UILabel *proTitle;
@property (nonatomic, strong) UILabel *proOkLabel;
@property (nonatomic, strong) UILabel *proDesLab;
@property (nonatomic, strong) UILabel *proTotalLab;
@property (nonatomic, strong) UIView *whiteV;
@property (nonatomic, strong) UIView *proLine;

@property (nonatomic, strong) JXShareUser *user;

@property (nonatomic, assign) BOOL isSendToFriend;

@property (nonatomic, strong) UIButton *pauseBtn;
@property (nonatomic, strong) AVPlayerViewController *playerVC;
@property (nonatomic, strong) UIView *Playerview;
// 保存数据
@property (nonatomic, strong) NSMutableArray *imgArray;
@property (nonatomic, strong) NSMutableArray *videoArray;

@property (nonatomic, strong) UIImageView *urlImageV;
@property (nonatomic, strong) UILabel *urlTitle;
@property (nonatomic, strong) UILabel *urlDetail;
@property (nonatomic, strong) NSString *url;

@end

@implementation JXCustomShareVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    if ([share_defaults objectForKey:kMY_ShareExtensionToken]) {
        self.imgArray = [[NSMutableArray alloc] init];
        self.videoArray = [[NSMutableArray alloc] init];
        // 获取图片数据
        NSExtensionItem *extensionItem = self.extensionContext.inputItems.firstObject;
        [self getDataWithItem:extensionItem];
    }else {
        [self setTintView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setTintView {
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
    self.baseView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:self.baseView];
    
    UIView *bigV = [[UIView alloc] initWithFrame:CGRectMake(30, (JX_SCREEN_HEIGHT-300)/2, JX_SCREEN_WIDTH-60, 300)];
    bigV.backgroundColor = [UIColor whiteColor];
    bigV.layer.masksToBounds = YES;
    bigV.layer.cornerRadius = 3.f;
    [self.baseView addSubview:bigV];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, bigV.frame.size.width, 20)];
    title.text = APP_NAME;
    title.textAlignment = NSTextAlignmentCenter;
    [bigV addSubview:title];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(title.frame)+20, bigV.frame.size.width, LINE_WH)];
    topLine.backgroundColor = THE_LINE_COLOR;
    [bigV addSubview:topLine];
    
    UILabel *tintLab = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(topLine.frame), bigV.frame.size.width- 40, 180)];
    tintLab.textAlignment = NSTextAlignmentCenter;
    tintLab.textColor = [UIColor grayColor];
    tintLab.numberOfLines = 0;
    tintLab.text = [NSString stringWithFormat:@"抱歉，请先打开%@，并登录，才可以使用分享功能",APP_NAME];
    [bigV addSubview:tintLab];
    
    UIView *botLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tintLab.frame), bigV.frame.size.width, LINE_WH)];
    botLine.backgroundColor = THE_LINE_COLOR;
    [bigV addSubview:botLine];
    
    UILabel *okLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(botLine.frame), bigV.frame.size.width, bigV.frame.size.height-CGRectGetMaxY(botLine.frame))];
    okLabel.textAlignment = NSTextAlignmentCenter;
    okLabel.userInteractionEnabled = YES;
    okLabel.text = @"我知道了";
    okLabel.textColor = HEXCOLOR(0x31AD2A);
    [bigV addSubview:okLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelBtnClickHandler:)];
    [okLabel addGestureRecognizer:tap];

}

#pragma mark - 发送给朋友
- (void)sendToFriend {
    JXSelectFriendVC *selVC = [[JXSelectFriendVC alloc] init];
    selVC.delegate = self;
    selVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:selVC animated:NO completion:nil];
}

- (void)sendToFriendSuccess:(JXSelectFriendVC *)selectVC user:(JXShareUser *)user {
    self.user = user;
    self.proInt = 0;
    self.isSendToFriend = YES;
    [self setProgressView];
    [self updateViewsIsComplete:NO title:nil content:nil];
    if (self.url.length > 0) {
        int chatType = self.user.roomId.length > 0 ? 2 : 1;
        
        [[JXHttpRequet shareInstance] sendMsgToUserId:self.user.userId chatType:chatType type:1 content:self.url fileName:nil toView:self];
        return;
    }
    
    NSArray *arr;
    if (self.imgArray.count > 0) {
        arr = self.imgArray;
    }else if (self.videoArray.count > 0) {
        arr = self.videoArray;
    }
    for (int i = 0; i < arr.count; i++) {
        if (self.imgArray.count > 0) {
            NSString *url = [[JXHttpRequet shareInstance] getDataUrlWithImage:arr[i]];
            [[JXHttpRequet shareInstance] uploadFile:url validTime:nil messageId:nil toView:self];
        }else if (self.videoArray.count > 0) {
            [[JXHttpRequet shareInstance] uploadFile:arr[i] validTime:nil messageId:nil toView:self];
        }
    }
}

#pragma mark - 分享给生活圈
- (void)shareLifeCircle {
    if (self.url.length > 0) {
        //分享图片到生活圈
        [self setProgressView];
        [self updateViewsIsComplete:NO title:nil content:nil];
        [[JXHttpRequet shareInstance] addMessage:self.url type:1 data:nil flag:3 toView:self];
        return;
    }

    JXShareViewController *shareVC = [[JXShareViewController alloc] init];
    shareVC.delegate = self;
    shareVC.image = self.imgV.image;
    shareVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:shareVC animated:NO completion:nil];

}

- (void)sendToLifeCircleSucces:(JXShareViewController *)shareVC {
    self.text = shareVC.textView.text;
    self.proInt = 0;
    self.isSendToFriend = NO;
    [self setProgressView];
    [self updateViewsIsComplete:NO title:nil content:nil];
    
    NSString *path = [[JXHttpRequet shareInstance] getDataUrlWithImage:shareVC.image];
    [[JXHttpRequet shareInstance] uploadFile:path validTime:nil messageId:nil toView:self];
}

- (void)setProgressView {
    [self.baseView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.baseView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    _whiteV = [[UIView alloc] initWithFrame:CGRectMake(30, (JX_SCREEN_HEIGHT-189)/2, JX_SCREEN_WIDTH-60, 183)];
    _whiteV.backgroundColor = [UIColor whiteColor];
    _whiteV.layer.masksToBounds = YES;
    _whiteV.layer.cornerRadius = 3.f;
    [self.baseView addSubview:_whiteV];
    
    _proTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, _whiteV.frame.size.width, 20)];
    _proTitle.textAlignment = NSTextAlignmentCenter;
    _proDesLab.font = [UIFont boldSystemFontOfSize:17];
    [_whiteV addSubview:_proTitle];
    
    // 进度条初始化
    self.rateProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_proTitle.frame)+20, _whiteV.frame.size.width-40, 20)];
    // 进度条的底色
    self.rateProgressView.trackTintColor = [UIColor lightGrayColor];
    self.rateProgressView.progressTintColor = HEXCOLOR(0x31AD2A);
    self.rateProgressView.layer.masksToBounds = YES;
    self.rateProgressView.layer.cornerRadius = 1;
    [_whiteV addSubview:self.rateProgressView];
    
    _proDesLab = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_proTitle.frame)+27, _whiteV.frame.size.width-40, 25)];
    _proDesLab.textAlignment = NSTextAlignmentCenter;
    [_whiteV addSubview:_proDesLab];
    
    _proTotalLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.rateProgressView.frame)+20, _whiteV.frame.size.width, 20)];
    _proTotalLab.textAlignment = NSTextAlignmentCenter;
    _proTotalLab.textColor = [UIColor grayColor];
    _proTotalLab.text = [NSString stringWithFormat:@"共%ld张",self.imgArray.count];
    [_whiteV addSubview:_proTotalLab];
    
    _proLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_proTotalLab.frame)+20, _whiteV.frame.size.width, LINE_WH)];
    _proLine.backgroundColor = THE_LINE_COLOR;
    [_whiteV addSubview:_proLine];
    
    _proOkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_proLine.frame), _whiteV.frame.size.width, _whiteV.frame.size.height-CGRectGetMaxY(_proLine.frame))];
    _proOkLabel.textAlignment = NSTextAlignmentCenter;
    _proOkLabel.userInteractionEnabled = YES;
    _proOkLabel.textColor = HEXCOLOR(0x31AD2A);
    _proOkLabel.text = @"好的";
    [_whiteV addSubview:_proOkLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelBtnClickHandler:)];
    [_proOkLabel addGestureRecognizer:tap];
}

- (void)updateViewsIsComplete:(BOOL)isComplete title:(NSString *)title content:(NSString *)content {
    _proTitle.text = isComplete ? title : @"正在发送";
    _proOkLabel.hidden = !isComplete;
    self.rateProgressView.hidden = isComplete;
    _proTotalLab.hidden = isComplete;
    _proDesLab.hidden = !isComplete;
    _proLine.hidden = !isComplete;
    _proDesLab.text = content;
    CGRect frame = _whiteV.frame;
    frame.size.height = isComplete ? 183 : 183 - _proOkLabel.frame.size.height;
    frame.origin.y = (JX_SCREEN_HEIGHT - frame.size.height)/2;
    _whiteV.frame = frame;
    if (isComplete) {
        self.proInt = 0;
    }
}

- (void)getDataWithItem:(NSExtensionItem *)extensionItem {
    //可以从NSExtensionItem项中的attachments属性中获得附件数据，如音频、视频、图片等，NSItemProvide就是实例的表示
    NSItemProvider *itemProvider = [[extensionItem attachments] firstObject];
    
    if(!itemProvider){
        return;
    }
    // 获取图片数据
    if([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]){
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
            
            if(image){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.imgArray addObject:image];
                    // 图片加载完成后再创建UI， 避免出现无图片的空档时间
                    [self setupViewsIsVideo:NO];
                    
                    //显示图片
                    self.imgV.image = image;
                    // 更新界面
                    CGFloat b = image.size.height/image.size.width;
                    // 图片最大高度
                    CGFloat h = JX_SCREEN_HEIGHT - JX_SCREEN_TOP -230;
                    
                    CGRect frame = self.imgV.frame;
                    frame.size = image.size;
                    if (image.size.width > JX_SCREEN_WIDTH/3*2) {
                        frame.size.width = JX_SCREEN_WIDTH/3*2;
                        frame.size.height = JX_SCREEN_WIDTH/3*2 * b;
                        if (frame.size.height > h) {
                            frame.size.height = h;
                            frame.size.width = h *(1/b);
                        }
                    }
                    
                    frame.origin.x = (JX_SCREEN_WIDTH-frame.size.width)/2;
                    self.imgV.frame = frame;
                    
                    self.sendFBtn.frame = CGRectMake(MY_INSET,CGRectGetMaxY(self.imgV.frame)+30, JX_SCREEN_WIDTH-MY_INSET*2, HEIGHT);
                    self.shareBtn.frame = CGRectMake(MY_INSET,CGRectGetMaxY(self.sendFBtn.frame), JX_SCREEN_WIDTH-MY_INSET*2, HEIGHT);
                });
            }
        }];
    }
    // 获取视频数据
    if([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMovie]){
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeMovie options:nil completionHandler:^(NSData *video, NSError *error) {
            
            if(video){
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *path = [[JXHttpRequet shareInstance] getDataUrlWithVideo:video];
                    [self.videoArray addObject:path];

                    // 获取第一帧图片
                    UIImage *image = [[JXHttpRequet shareInstance] getFirstImageFromVideo:path];
                    // 图片加载完成后再创建UI， 避免出现无图片的空档时间
                    [self setupViewsIsVideo:YES];

                    //显示图片
                    self.imgV.image = image;
                    // 更新界面
                    CGFloat b = image.size.height/image.size.width;
                    // 图片最大高度
                    CGFloat h = JX_SCREEN_HEIGHT - JX_SCREEN_TOP -230;

                    CGRect frame = self.imgV.frame;
                    frame.size = image.size;
                    if (image.size.width > JX_SCREEN_WIDTH/3*2) {
                        frame.size.width = JX_SCREEN_WIDTH/3*2;
                        frame.size.height = JX_SCREEN_WIDTH/3*2 * b;
                        if (frame.size.height > h) {
                            frame.size.height = h;
                            frame.size.width = h *(1/b);
                        }
                    }

                    frame.origin.x = (JX_SCREEN_WIDTH-frame.size.width)/2;
                    self.imgV.frame = frame;
                    
                    self.imgV.hidden = YES;
                    self.Playerview = [[UIView alloc] initWithFrame:self.imgV.frame];
                    self.Playerview.backgroundColor = [UIColor blackColor];
                    [self.tableBody addSubview:self.Playerview];
                    
                    self.playerVC = [[AVPlayerViewController alloc] init];
                    self.playerVC.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:[self.videoArray firstObject]]];
                    self.playerVC.showsPlaybackControls = YES;
                    self.playerVC.view.frame = self.imgV.bounds;
                    [self.Playerview addSubview:self.playerVC.view];
                    
                    self.pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 26, 26)];
                    [self.pauseBtn setBackgroundImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
                    [self.pauseBtn setBackgroundImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateHighlighted];
                    [self.pauseBtn addTarget:self action:@selector(openStart) forControlEvents:UIControlEventTouchUpInside];
                    [self.imgV addSubview:self.pauseBtn];
                    
                    CGRect frameP = self.pauseBtn.frame;
                    frameP.origin.x = (self.imgV.frame.size.width-frameP.size.width) * 0.5;
                    frameP.origin.y = (self.imgV.frame.size.height-frameP.size.height) * 0.5;
                    self.pauseBtn.frame = frameP;

                    self.sendFBtn.frame = CGRectMake(MY_INSET,CGRectGetMaxY(self.imgV.frame)+30, JX_SCREEN_WIDTH-MY_INSET*2, HEIGHT);
                });
            }
        }];
    }
    // 获取URL数据
    if([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]){
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
            
            if(url){
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 图片加载完成后再创建UI， 避免出现无图片的空档时间
                    self.url = url.absoluteString;
                    [self setupUrlViewWithUrl:url];
                    //显示图片
                });
            }
        }];
    }
}

- (void)setHeadView {
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
    self.baseView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.baseView];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_TOP)];
    [self.baseView addSubview:headView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, JX_SCREEN_TOP - 35, 40, 20)];
    [btn setTitle:@"关闭" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(cancelBtnClickHandler:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:btn];
    
    UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(60, JX_SCREEN_TOP - 35, JX_SCREEN_WIDTH-60*2, 20)];
    p.backgroundColor = [UIColor clearColor];
    p.textAlignment   = NSTextAlignmentCenter;
    p.text = APP_NAME;
    p.font = [UIFont boldSystemFontOfSize:18.0];
    [headView addSubview:p];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP-LINE_WH, JX_SCREEN_WIDTH, LINE_WH)];
    line.backgroundColor = [UIColor lightGrayColor];
    [headView addSubview:line];
    
    self.tableBody = [[UIScrollView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_TOP)];
    self.tableBody.showsVerticalScrollIndicator = NO;
    self.tableBody.showsHorizontalScrollIndicator = NO;
    [self.baseView addSubview:self.tableBody];

}

- (void)setupUrlViewWithUrl:(NSURL *)url {
    [self setHeadView];
//    self.urlImageV = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 50, 50)];
//    self.urlImageV.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/favicon.ico", url.scheme, url.host]]]];
//    [self.tableBody addSubview:self.urlImageV];
    CGSize size = [url.absoluteString boundingRectWithSize:CGSizeMake(JX_SCREEN_WIDTH-140, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYSFONT(17)} context:nil].size;
    self.urlTitle = [[UILabel alloc] initWithFrame:CGRectMake(70, 20, JX_SCREEN_WIDTH-140, size.height)];
    self.urlTitle.text = url.absoluteString;
    self.urlTitle.textColor = [UIColor grayColor];
    self.urlTitle.numberOfLines = 0;
    [self.tableBody addSubview:self.urlTitle];

    _sendFBtn = [self createButton:@"发送给朋友" drawTop:YES drawBottom:YES icon:@"im_linksShare_send_friend" click:@selector(sendToFriend)];
    _sendFBtn.frame = CGRectMake(MY_INSET,CGRectGetMaxY(_urlTitle.frame)+30, JX_SCREEN_WIDTH-MY_INSET*2, HEIGHT);
    _shareBtn = [self createButton:@"分享给社交圈" drawTop:NO drawBottom:YES icon:@"im_linksShare_life" click:@selector(shareLifeCircle)];
    _shareBtn.frame = CGRectMake(MY_INSET,CGRectGetMaxY(_sendFBtn.frame), JX_SCREEN_WIDTH-MY_INSET*2, HEIGHT);
}


- (void)setupViewsIsVideo:(BOOL)isVideo {
    [self setHeadView];
    _imgV = [[UIImageView alloc] initWithFrame:CGRectMake(120, 30, JX_SCREEN_WIDTH-240, 300)];
    _imgV.image = [UIImage imageNamed:@"custom_share_no_image"];
    _imgV.userInteractionEnabled = YES;
    [self.tableBody addSubview:_imgV];
    
    _sendFBtn = [self createButton:@"发送给朋友" drawTop:YES drawBottom:YES icon:@"im_linksShare_send_friend" click:@selector(sendToFriend)];
    _sendFBtn.frame = CGRectMake(MY_INSET,CGRectGetMaxY(_imgV.frame)+30, JX_SCREEN_WIDTH-MY_INSET*2, HEIGHT);
    if (!isVideo) {
        _shareBtn = [self createButton:@"分享给社交圈" drawTop:NO drawBottom:YES icon:@"im_linksShare_life" click:@selector(shareLifeCircle)];
        _shareBtn.frame = CGRectMake(MY_INSET,CGRectGetMaxY(_sendFBtn.frame), JX_SCREEN_WIDTH-MY_INSET*2, HEIGHT);
    }

}

- (void)openStart {
    [self.playerVC.player play];
}

#pragma mark - 服务器返回数据
-(void) didServerNetworkResultSucces:(JXNetwork*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    if ([aDownload.action isEqualToString:act_MsgAdd]) {
        NSLog(@"---分享朋友圈成功---");
        if (self.proInt >= self.imgArray.count || self.proInt >= self.videoArray.count || self.url.length > 0) {
            [self updateViewsIsComplete:YES title:@"已发送"content:[NSString stringWithFormat:@"你可以在%@里查看",APP_NAME]];
        }
    }
    if ([aDownload.action isEqualToString:act_UploadFile]) {
        self.proInt += 1;
        if (self.isSendToFriend) {
            //发送消息给好友/群组
            int chatType = self.user.roomId.length > 0 ? 2 : 1;
            NSString *url;
            NSString *fileName;
            int type = 0;
            if (self.imgArray.count > 0) {
                url = [(NSDictionary *)[[dict objectForKey:@"images"] firstObject] objectForKey:@"oUrl"];
                fileName = [(NSDictionary *)[[dict objectForKey:@"images"] firstObject] objectForKey:@"oFileName"];
                type = 2;
                [self.rateProgressView setProgress:self.proInt/self.imgArray.count animated:YES];
            }else if (self.videoArray.count > 0) {
                url = [(NSDictionary *)[[dict objectForKey:@"videos"] firstObject] objectForKey:@"oUrl"];
                fileName = [(NSDictionary *)[[dict objectForKey:@"videos"] firstObject] objectForKey:@"oFileName"];
                type = 6;
                [self.rateProgressView setProgress:self.proInt/self.videoArray.count animated:YES];
            }

            [[JXHttpRequet shareInstance] sendMsgToUserId:self.user.userId chatType:chatType type:type content:url fileName:fileName toView:self];
        }else {
            //分享图片到生活圈
            [[JXHttpRequet shareInstance] addMessage:self.text type:2 data:dict flag:3 toView:self];
        }
    }
    if ([aDownload.action isEqualToString:act_SendMsg]) {
        NSLog(@"---发送消息成功---");
        if (self.proInt >= self.imgArray.count || self.proInt >= self.videoArray.count || self.url.length > 0) {
            [self updateViewsIsComplete:YES title:@"已发送"content:[NSString stringWithFormat:@"你可以在%@里查看",APP_NAME]];
        }
    }

}

-(int) didServerNetworkResultFailed:(JXNetwork*)aDownload dict:(NSDictionary*)dict{
    NSString *str = [NSString string];
    int resultCode = [[dict objectForKey:@"resultCode"] intValue];
    if(resultCode != 1) {
        if(resultCode == 1030101 || resultCode == 1030102){
            str = [NSString stringWithFormat:@"登录过期,请重新登录%@",APP_NAME];
                //登录过期
            return 1;
        }
    }
    if ([aDownload.action isEqualToString:act_SendMsg]) {
        str = @"消息发送失败";
    }
    if ([aDownload.action isEqualToString:act_MsgAdd]) {
        str = @"分享社交圈失败";
    }
    if ([aDownload.action isEqualToString:act_UploadFile]) {
        str = @"上传失败";
    }
    [self updateViewsIsComplete:YES title:str content:@"请检查网络"];
    return 1;
}

-(int) didServerNetworkError:(JXNetwork*)aDownload error:(NSError *)error{//error为空时，代表超时
    NSString *str = [NSString string];
    if ([aDownload.action isEqualToString:act_SendMsg]) {
        str = @"消息发送失败";
    }
    if ([aDownload.action isEqualToString:act_MsgAdd]) {
        str = @"分享社交圈失败";
    }
    if ([aDownload.action isEqualToString:act_UploadFile]) {
        str = @"上传失败";
    }
    [self updateViewsIsComplete:YES title:str content:@"请检查网络"];

    return 1;
}

-(void) didServerNetworkStart:(JXNetwork*)aDownload{
    
}



-(UIButton*)createButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom icon:(NSString*)icon click:(SEL)click{
    UIButton* btn = [[UIButton alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    [btn addTarget:self action:click forControlEvents:UIControlEventTouchUpInside];
    [self.tableBody addSubview:btn];
    
    UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(20*2+30, 0, self_width-35-20-5, HEIGHT)];
    p.text = title;
    p.font = SYSFONT(16);
    p.backgroundColor = [UIColor clearColor];
    p.textColor = HEXCOLOR(0x323232);
    [btn addSubview:p];
    
    if(icon){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, (HEIGHT-30)/2, 30, 30)];
        iv.image = [UIImage imageNamed:icon];
        [btn addSubview:iv];
    }
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(20,HEIGHT-LINE_WH,JX_SCREEN_WIDTH-40,LINE_WH)];
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

#pragma mark - 打开APP
- (void)openApp {
    //自从文章发出来后不断被问到的一个问题。其实苹果官方除了Today Extension外，其他Extension是不提供跳转接口的。所以这里总结的是一种非正常的方式。直接上代码（会不会审核被拒就得看自己人品了~)
    //这种方式主要实现原理是通过响应链找到Host App的UIApplication对象，通过该对象调用openURL方法返回自己的应用。
    UIResponder *responder = self;
    while (responder)
    {
        if ([responder respondsToSelector:@selector(openURL:)])
        {
            [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:@"testshare://"]];
            break;
        }
        responder = [responder nextResponder];
    }
}

- (void)cancelBtnClickHandler:(id)sender
{
    //取消分享
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"CustomShareError" code:NSUserCancelledError userInfo:nil]];
}

- (void)postBtnClickHandler:(id)sender
{
    //执行分享内容处理
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//当扩展处理完host app传来的图片数据后，它需要将处理好的的数据在传给host app，在扩展中的代码如下：
- (void)done:(id)sender{
    NSExtensionItem *extensionItem = [[NSExtensionItem alloc]init];
    [extensionItem setAttachments:@[[[NSItemProvider alloc] initWithItem:[self.imgV image] typeIdentifier:(NSString *)kUTTypeImage]]];
}


@end
