//
//  JXSquareViewController.m
//  shiku_im
//
//  Created by 1 on 2018/11/7.
//  Copyright © 2018年 Reese. All rights reserved.
//



#import "JXSquareViewController.h"
#import "WeiboViewControlle.h"
#import "JXActionSheetVC.h"
#ifdef Meeting_Version
#import "JXSelectFriendsVC.h"
#import "JXAVCallViewController.h"
#endif

#ifdef Live_Version
#import "JXLiveViewController.h"
#endif

#import "JXScanQRViewController.h"
#import "JXNearVC.h"
#import "JXBlogRemind.h"
#import "JXTabMenuView.h"
#ifdef Meeting_Version
#ifdef Live_Version
#import "GKDYHomeViewController.h"
#import "JXSmallVideoViewController.h"
#endif
#endif
#import "ImageResize.h"
#import "JXChatViewController.h"
#import "JXCell.h"
#import "JXUserInfoVC.h"
#import "UIView+Frame.h"

/*
 *   如果要改变左右间隔
 *   减少间隔，则增加 SQUARE_HEIGHT
 *   增加间隔，则减少 SQUARE_HEIGHT
 */
#define SQUARE_HEIGHT      52      //图片宽高
#define INSET_IMAGE       7        // 字和图片的间距


typedef NS_ENUM(NSInteger, JXSquareType) {
    JXSquareTypeLife,           // 生活圈
    JXSquareTypeVideo,          // 视频会议
    JXSquareTypeAudio,          // 音频会议
    JXSquareTypeVideoLive,      // 视频直播
    JXSquareTypeShortVideo,     // 短视频
    JXSquareTypeQrcode,         // 扫一扫
    JXSquareTypeNearby,         // 附近的人
};

@interface JXSquareViewController () <JXActionSheetVCDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NSArray *iconArr;
@property (nonatomic, assign) JXSquareType type;
@property (nonatomic, assign) int isAudioMeeting;
@property (nonatomic, strong) UILabel *weiboNewMsgNum;
@property (nonatomic, strong) NSMutableArray *remindArray;
@property (nonatomic, strong) UIButton *imgV;
@property (nonatomic, strong) UIImageView *topImageView;

@property (nonatomic, strong) NSMutableArray *subviews;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, assign) NSInteger page;
@property(nonatomic,strong) MJRefreshFooterView *footer;
@property(nonatomic,strong) MJRefreshHeaderView *header;
@property(nonatomic,strong) NSMutableArray *hotApply;
@end

@implementation JXSquareViewController

-(NSMutableArray *)hotApply{
    if (!_hotApply) {
        _hotApply = [NSMutableArray array];
    }
    return _hotApply;
}
- (instancetype)init {
    if (self = [super init]) {
//        self.title = Localized(@"JXMainViewController_Find");
        _array = [NSMutableArray array];
        self.heightFooter = 0;
        self.heightHeader = JX_SCREEN_TOP;
        [self createHeadAndFoot];
        self.tableBody.backgroundColor = HEXCOLOR(0xf0f0f0);
        self.tableBody.delegate = self;
        self.tableBody.bounces = NO;
        self.tableBody.scrollEnabled = NO;
        self.subviews = [[NSMutableArray alloc] init];
        
        [self setupViews];
        [g_notify addObserver:self selector:@selector(remindNotif:) name:kXMPPMessageWeiboRemind object:nil];
    }
    return self;
}

- (void)remindNotif:(NSNotification *)notif {
//    JXMessageObject *msg = notif.object;
//    _remindArray = [[JXBlogRemind sharedInstance] doFetchUnread];
//    if (_remindArray.count > 0) {
//        NSString *newMsgNum = [NSString stringWithFormat:@"%ld",_remindArray.count];
//        self.weiboNewMsgNum.hidden = NO;
//        self.weiboNewMsgNum.text = newMsgNum;
//        [g_mainVC.tb setBadge:2 title:newMsgNum];
//    }
    [self showNewMsgNoti];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getServerData];
}

- (void)onQrCode {
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        [g_server showMsg:Localized(@"JX_CanNotopenCenmar")];
        return;
    }
    
    JXScanQRViewController * scanVC = [[JXScanQRViewController alloc] init];
    [g_navigation pushViewController:scanVC animated:YES];
    
}

- (void)getServerData {
    [g_server searchPublicWithKeyWorld:@"" limit:20 page:(int)_page toView:self];
}


-(void)dealloc{
    [g_notify removeObserver:self name:kXMPPMessageWeiboRemind object:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showNewMsgNoti];
}

- (void)showNewMsgNoti {
    _remindArray = [[JXBlogRemind sharedInstance] doFetchUnread];
    NSMutableArray *newMsgArray = [[JXBlogRemind sharedInstance] doFetchNewMsgUnread];
    
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
    JXCell *cell = [self.tableView cellForRowAtIndexPath:indexpath];
    
    NSInteger haveNewWeibo = newMsgArray.count;
    NSInteger newMessageCount = _remindArray.count;
    
    NSString *newMsgNum = [NSString stringWithFormat:@"%ld",newMessageCount];
    if (newMessageCount >= 10 && newMessageCount <= 99) {
        self.weiboNewMsgNum.font = SYSFONT(12);
    }else if (newMessageCount > 0 && newMessageCount < 10) {
        self.weiboNewMsgNum.font = SYSFONT(13);
    }else if(newMessageCount > 99){
        self.weiboNewMsgNum.font = SYSFONT(9);
    }

    self.weiboNewMsgNum.text = newMsgNum;
    cell.lbBage.badgeString = newMsgNum;
    CGPoint center = self.weiboNewMsgNum.center;
    if (newMessageCount > 0) {
        self.weiboNewMsgNum.text = newMsgNum;
        self.weiboNewMsgNum.hidden = NO;
        self.weiboNewMsgNum.frame = CGRectMake(0, 0, 20, 20);
        self.weiboNewMsgNum.layer.cornerRadius = self.weiboNewMsgNum.frame.size.width / 2;
        self.weiboNewMsgNum.center = center;
        cell.lbBage.hidden = NO;
        [cell setLbageStr:newMsgNum];
        [g_mainVC.tb setBadge:2 title:newMsgNum];
    }else if (haveNewWeibo > 0){
        self.weiboNewMsgNum.text = @"";
        self.weiboNewMsgNum.hidden = NO;
        self.weiboNewMsgNum.frame = CGRectMake(0, 0, 10, 10);
        self.weiboNewMsgNum.layer.cornerRadius = self.weiboNewMsgNum.frame.size.width / 2;
        self.weiboNewMsgNum.center = center;
        cell.lbBage.hidden = NO;
        [cell updateBage:@"0" isSmall:YES];
        [g_mainVC.tb setBadge:2 title:@"0" isSmall:YES];
    }else{
        self.weiboNewMsgNum.hidden = YES;
        cell.lbBage.hidden = YES;
    }
    
}


- (void)setupViews {
    
    NSInteger statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    UILabel *titleL = [[UILabel alloc]initWithFrame:CGRectMake(20, statusHeight, JX_SCREEN_WIDTH*0.5, 44)];
    titleL.text = @"探索";
    titleL.font = [UIFont boldSystemFontOfSize:22];
    [self.tableHeader addSubview: titleL];
    
//    UIButton *qrCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15*2-18, JX_SCREEN_TOP-15*2-18, 18+15*2, 18+15*2)];
//    [qrCodeBtn setImage:[UIImage imageNamed:@"square_qrcode"] forState:UIControlStateNormal];
//    [qrCodeBtn addTarget:self action:@selector(onQrCode) forControlEvents:UIControlEventTouchUpInside];
//    [self.tableHeader addSubview:qrCodeBtn];

//    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 0)];
//    baseView.backgroundColor = [UIColor whiteColor];
//    [self.tableBody addSubview:baseView];
//
//    CGFloat y = 0;
    //顶部图片
//    if (g_config.headBackgroundImg != nil && ![g_config.headBackgroundImg isEqualToString:@""]) {
//        _topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, JX_SCREEN_WIDTH, 180)];
//        [baseView addSubview:_topImageView];
//        CGFloat fl = (_topImageView.frame.size.width/_topImageView.frame.size.height);
//        [_topImageView sd_setImageWithURL:[NSURL URLWithString:g_config.headBackgroundImg] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//            if (error) {
//                image = [UIImage imageNamed:@"Default_Gray"];
//            }
//            _topImageView.image = [ImageResize image:image fillSize:CGSizeMake((_topImageView.frame.size.height+200)*fl, _topImageView.frame.size.height+200)];
//        }];
//        y = CGRectGetMaxY(_topImageView.frame)+20;
//    }
    
//    UIView *hotTopView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 8)];
//    hotTopView.backgroundColor = HEXCOLOR(0xf0f0f0);
//    [baseView addSubview:hotTopView];
//
//    //热门应用
//    CGSize size = [Localized(@"JX_TopicalApplication") boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYSFONT(18)} context:nil].size;
//    UILabel *hotLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(hotTopView.frame)+12, size.width, 20)];
//    hotLabel.text = Localized(@"JX_TopicalApplication");
//    hotLabel.font = SYSFONT(17);
//    [baseView addSubview:hotLabel];
//
//    UIView *segmentView = [[UIView alloc]initWithFrame:CGRectMake(0, hotLabel.bottom+13, JX_SCREEN_WIDTH, 1)];
//    segmentView.backgroundColor = RGB(231, 231, 231);
//    [baseView addSubview:segmentView];
//
//    UIView *lifeCircleView = [[UIView alloc]initWithFrame:CGRectMake(0, segmentView.bottom, JX_SCREEN_WIDTH, 52)];
//    lifeCircleView.tag = JXSquareTypeLife;
//    [baseView addSubview:lifeCircleView];
//    UITapGestureRecognizer *lifeCircleTap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickButtonWithTag:)];
//    lifeCircleView.userInteractionEnabled = YES;
//    [lifeCircleView addGestureRecognizer:lifeCircleTap];
//    UIImageView *lifeImgView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 16, 20, 20)];
//    lifeImgView.image = [UIImage imageNamed:@"square_circle"];
//    [lifeCircleView addSubview:lifeImgView];
//
//    UILabel *lifeL = [[UILabel alloc]initWithFrame:CGRectMake(lifeImgView.right+24, 17, 100, 18)];
//    lifeL.text = @"生活圈";
//    lifeL.font = [UIFont systemFontOfSize:16];
//    lifeL.textColor = RGB(20, 20, 20);
//    [lifeCircleView addSubview:lifeL];
//
//    UIView *segmentView1 = [[UIView alloc]initWithFrame:CGRectMake(lifeL.left, 51, JX_SCREEN_WIDTH, 1)];
//    segmentView1.backgroundColor = HEXCOLOR(0xf0f0f0);
//    [lifeCircleView addSubview:segmentView1];
//
//    UIView *scanView = [[UIView alloc]initWithFrame:CGRectMake(0, lifeCircleView.bottom, JX_SCREEN_WIDTH, 52)];
//    [baseView addSubview:scanView];
//    UITapGestureRecognizer *scanTap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onQrCode)];
//    scanView.userInteractionEnabled = YES;
//    [scanView addGestureRecognizer:scanTap];
//
//    UIImageView *scanImgView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 16, 20, 20)];
//    scanImgView.image = [UIImage imageNamed:@"square_scan"];
//    [scanView addSubview:scanImgView];
//
//    UILabel *scanL = [[UILabel alloc]initWithFrame:CGRectMake(scanImgView.right+24, 17, 100, 18)];
//    scanL.text = @"扫一扫";
//    scanL.font = [UIFont systemFontOfSize:16];
//    scanL.textColor = RGB(20, 20, 20);
//    [scanView addSubview:scanL];
//
//    UIView *segmentView2 = [[UIView alloc]initWithFrame:CGRectMake(lifeL.left, 51, JX_SCREEN_WIDTH, 1)];
//    segmentView2.backgroundColor = HEXCOLOR(0xf0f0f0);
//    [scanView addSubview:segmentView2];
//
//    UIView *nearView = [[UIView alloc]initWithFrame:CGRectMake(0, scanView.bottom, JX_SCREEN_WIDTH, 52)];
//    [baseView addSubview:nearView];
//    nearView.tag = JXSquareTypeNearby;
//    UITapGestureRecognizer *nearTap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickButtonWithTag:)];
//    nearView.userInteractionEnabled = YES;
//    [nearView addGestureRecognizer:nearTap];
//
//    UIImageView *nearImgView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 16, 20, 20)];
//    nearImgView.image = [UIImage imageNamed:@"square_near"];
//    [nearView addSubview:nearImgView];
//
//    UILabel *nearL = [[UILabel alloc]initWithFrame:CGRectMake(nearImgView.right+24, 17, 100, 18)];
//    nearL.text = @"附近的人";
//    nearL.font = [UIFont systemFontOfSize:16];
//    nearL.textColor = RGB(20, 20, 20);
//    [nearView addSubview:nearL];
//
//    UIView *segmentView3 = [[UIView alloc]initWithFrame:CGRectMake(lifeL.left, 51, JX_SCREEN_WIDTH, 1)];
//    segmentView3.backgroundColor = HEXCOLOR(0xf0f0f0);
//    [nearView addSubview:segmentView3];
    
    
    
    /*
    // 左右滑 菜单栏
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(hotLabel.frame)+5, JX_SCREEN_WIDTH, 0)];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [baseView addSubview:_scrollView];
    
    BOOL lifeCircle = YES;      // 生活圈
    BOOL videoMeeting = YES;    // 视频会议
    BOOL liveVideo = YES;       // 视频直播
    BOOL shortVideo = YES;      // 短视频
    BOOL peopleNearby = YES;    // 附近的人
    BOOL scan = YES;            // 扫一扫
    if (g_config.popularAPP) {
        lifeCircle = [[g_config.popularAPP objectForKey:@"lifeCircle"] boolValue];
        videoMeeting = [[g_config.popularAPP objectForKey:@"videoMeeting"] boolValue];
        liveVideo = [[g_config.popularAPP objectForKey:@"liveVideo"] boolValue];
        shortVideo = [[g_config.popularAPP objectForKey:@"shortVideo"] boolValue];
        peopleNearby = [[g_config.popularAPP objectForKey:@"peopleNearby"] boolValue];
        scan = [[g_config.popularAPP objectForKey:@"scan"] boolValue];
    }
    
    UIButton *button;
    // 图片在button中的左右间隙
    int  leftInset = (button.frame.size.width - SQUARE_HEIGHT)/2;
    int btnX = 0;
    int btnY = 0;

    if (lifeCircle) {
        // 生活圈
        button = [self createButtonWithFrame:CGRectMake(0, btnY, JX_SCREEN_WIDTH/5, 0) title:Localized(@"JX_LifeCircle") icon:@"square_life" highlighted:@"square_life_highlighted" index:JXSquareTypeLife];
    }
    
#ifdef Meeting_Version
    if (videoMeeting) {
        // 视频会议
        btnX += button.frame.size.width;
        button = [self createButtonWithFrame:CGRectMake(btnX, btnY, JX_SCREEN_WIDTH/5, 0) title:Localized(@"JXSettingVC_VideoMeeting") icon:@"square_video" highlighted:@"square_video_highlighted" index:JXSquareTypeVideo];
        
        // 音频会议
        btnX += button.frame.size.width;
        button = [self createButtonWithFrame:CGRectMake(btnX, btnY, JX_SCREEN_WIDTH/5, 0) title:Localized(@"JX_Meeting") icon:@"square_audio" highlighted:@"square_audio_highlighted" index:JXSquareTypeAudio];
    }
#endif
    
#ifdef Live_Version
    if (liveVideo) {
        // 视频直播
        btnX += button.frame.size.width;
        button = [self createButtonWithFrame:CGRectMake(btnX, btnY, JX_SCREEN_WIDTH/5, 0) title:Localized(@"JX_LiveVideo") icon:@"square_videochat" highlighted:@"square_videochat_highlighted" index:JXSquareTypeVideoLive];
    }
#endif
    
#ifdef Meeting_Version
#ifdef Live_Version
    if (shortVideo) {
        // 抖音模块
        btnX += button.frame.size.width;
        button = [self createButtonWithFrame:CGRectMake(btnX, btnY, JX_SCREEN_WIDTH/5, 0) title:Localized(@"JX_ShorVideo") icon:@"square_douyin" highlighted:@"square_douyin_highlighted" index:JXSquareTypeShortVideo];
    }
#endif
#endif


    if (peopleNearby && [g_config.isOpenPositionService intValue] == 0) {
        // 附近的人
        btnX += button.frame.size.width;
        button = [self createButtonWithFrame:CGRectMake(btnX, btnY, JX_SCREEN_WIDTH/5, 0) title:Localized(@"JXNearVC_NearPer") icon:@"square_nearby" highlighted:@"square_nearby_highlighted" index:JXSquareTypeNearby];
    }
    
//    if (scan) {
//        // 扫一扫
//        btnX += button.frame.size.width;
//        button = [self createButtonWithFrame:CGRectMake(btnX, btnY, JX_SCREEN_WIDTH/5, 0) title:Localized(@"JX_Scan") icon:@"square_qrcode" index:JXSquareTypeQrcode];
//    }
    
    CGRect scrollFrame = _scrollView.frame;
    scrollFrame.size.height = button.frame.size.height;
    _scrollView.frame = scrollFrame;

    _scrollView.contentSize = CGSizeMake(btnX+button.frame.size.width, 0);
    */
//    CGRect frame = baseView.frame;
//    frame.size.height = CGRectGetMaxY(nearView.frame);
//    baseView.frame = frame;
    
    if ([g_config.enableMpModule boolValue]) {
 
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - JX_SCREEN_TOP -JX_SCREEN_BOTTOM) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = HEXCOLOR(0xF2F2F2);
        _tableView.scrollEnabled = YES;
        //    _tableView.tableHeaderView = headerView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
        
        [self addHeader];
        [self addFooter];
    }
    
}
- (void)stopLoading {
    
    [_footer endRefreshing];
    [_header endRefreshing];
}
- (void)addFooter
{
    if(_footer){
        //        [_footer free];
        //        return;
    }
    _footer = [MJRefreshFooterView footer];
    _footer.scrollView = _tableView;
    __weak JXSquareViewController *weakSelf = self;
    _footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        [weakSelf scrollToPageDown];
        //        NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    _footer.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        
        // 刷新完毕就会回调这个Block
        //        NSLog(@"%@----刷新完毕", refreshView.class);
    };
    _footer.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
                //                NSLog(@"%@----切换到：普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
                //                NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
                //                NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
                break;
            default:
                break;
        }
    };
}

- (void)addHeader
{
    if(_header){
        //        [_header free];
        //        return;
    }
    _header = [MJRefreshHeaderView header];
    _header.scrollView = _tableView;
    __weak JXSquareViewController *weakSelf = self;
    _header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        [weakSelf scrollToPageUp];
    };
    _header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
        //        NSLog(@"%@----刷新完毕", refreshView.class);
    };
    _header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
                //                NSLog(@"%@----切换到：普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
                //                NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
                //                NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
                break;
            default:
                break;
        }
    };
}

//顶部刷新获取数据
-(void)scrollToPageUp{
    
    _page = 0;
    [self getServerData];
}

-(void)scrollToPageDown{
    
    [self getServerData];
}

#pragma mark - tableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }
    return _array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (_array.count == 1) {
//        return 100;
//    }
    return 59;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    //热门公众号 以及列表
     UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 58)];
     headerView.backgroundColor = [UIColor whiteColor];

     UIView *segmentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 8)];
     segmentView.backgroundColor = HEXCOLOR(0xf0f0f0);
     [headerView addSubview:segmentView];
    
     UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 23, 240, 20)];
     if (section == 0) {
         numLabel.text = @"热门应用";
     }else{
         numLabel.text = Localized(@"JX_PopularPublicAccount");
     }
     numLabel.font = [UIFont boldSystemFontOfSize:17];
     [headerView addSubview:numLabel];
     
     UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 57, JX_SCREEN_WIDTH, 1)];
     line.backgroundColor = RGB(231, 231, 231);
     [headerView addSubview:line];
    
    return headerView;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 58;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"JXCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    JXUserObject *user = _array[indexPath.row];
//    if (_array.count == 1) {
//        if ([cell isKindOfClass:[JXCell class]]) {
//            cell = nil;
//        }
//        if (!cell) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//
//            UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(15, 30, 40, 40)];
//            imgV.tag = 100;
//            imgV.layer.cornerRadius = imgV.frame.size.width/2;
//            imgV.layer.masksToBounds = YES;
//            [cell.contentView addSubview:imgV];
//
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imgV.frame)+10, 41.5, 200, 17)];
//            label.tag = 101;
//            [cell.contentView addSubview:label];
//
//        }
//        UIImageView *imgV = [cell.contentView viewWithTag:100];
//        UILabel *label = [cell.contentView viewWithTag:101];
//        [g_server getHeadImageSmall:user.userId userName:user.userNickname imageView:imgV getHeadHandler:nil];
//        label.text = user.userNickname;
//    }else {
        JXCell *cell=nil;
    
        
        if(cell==nil){
            cell = [[JXCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
    
        cell.index = (int)indexPath.row;
        cell.isSmall = YES;
    
        if (indexPath.section == 1) {
            JXUserObject *user = _array[indexPath.row];
            cell.title = user.userNickname;
            cell.userId = user.userId;
            [cell.lbTitle setText:cell.title];
            [cell headImageViewImageWithUserId:nil roomId:nil];
        }else{
            
            switch (indexPath.row) {
                case 0:
                    cell.lbTitle.text = @"社交圈";
                    cell.headImageView.image = [UIImage imageNamed:@"square_circle"];
                   
                    break;
                case 1:
                    cell.lbTitle.text = @"扫一扫";
                    cell.headImageView.image = [UIImage imageNamed:@"square_scan"];
                    break;
                case 2:
                    cell.lbTitle.text = @"附近的人";
                    cell.headImageView.image = [UIImage imageNamed:@"square_near"];
                    break;
                    
                default:
                    break;
                    
                 
            }
            
            cell.headImageView.frame = CGRectMake(20,13,30,30);
            cell.headImageView.centerY = cell.lbTitle.centerY;
            
        }
    cell.lbTitle.font = [UIFont boldSystemFontOfSize:16];
        
       
//        cell.lineView.hidden = YES;
//        if (indexPath.row == _array.count - 1) {
//            cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width, 0);
//        }else {
//            cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width, LINE_WH);
//        }
        
        
//        return cell;
//    }
    
    return cell;
}
- (void)showBage:(JXCell *)cell {
    _remindArray = [[JXBlogRemind sharedInstance] doFetchUnread];
    NSMutableArray *newMsgArray = [[JXBlogRemind sharedInstance] doFetchNewMsgUnread];
    
    NSInteger haveNewWeibo = newMsgArray.count;
    NSInteger newMessageCount = _remindArray.count;
    
    NSString *newMsgNum = [NSString stringWithFormat:@"%ld",(long)newMessageCount];

    cell.lbBage.badgeString = newMsgNum;

    if (newMessageCount > 0) {
        cell.lbBage.hidden = NO;
        [g_mainVC.tb setBadge:2 title:newMsgNum];
    }else if (haveNewWeibo > 0){
        cell.lbBage.hidden = NO;
    }else{
        cell.lbBage.hidden = YES;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (indexPath.section == 0) {
        [self clickButtonWithTag:indexPath.row];
    }else{
        JXUserObject *user = _array[indexPath.row];
        
        [g_server getUser:user.userId toView:self];
    }



}

//服务端返回数据djk
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    
    
    if( [aDownload.action isEqualToString:act_PublicSearch] ){
        [self stopLoading];
        
        if (array1.count < 20) {
            _footer.hidden = YES;
        }
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        if(_page == 0){
            [_array removeAllObjects];
            for (int i = 0; i < array1.count; i++) {
                JXUserObject *user = [[JXUserObject alloc] init];
                [user getDataFromDict:array1[i]];
                [arr addObject:user];
            }
            [_array addObjectsFromArray:arr];
        }else{
            if([array1 count]>0){
                for (int i = 0; i < array1.count; i++) {
                    JXUserObject *user = [[JXUserObject alloc] init];
                    [user getDataFromDict:array1[i]];
                    [arr addObject:user];
                }
                [_array addObjectsFromArray:arr];
            }
        }
        _page ++;
        [self setTableviewHeight];
        [_tableView reloadData];
    }
    if( [aDownload.action isEqualToString:act_UserGet] ){
        JXUserObject* user = [[JXUserObject alloc]init];
        [user getDataFromDict:dict];

        if([user.userType intValue] == 2 && [user.status intValue] != 2){
            
            JXUserInfoVC* userVC = [JXUserInfoVC alloc];
            userVC.userId = user.userId;
            userVC.user = user;
            userVC.fromAddType = 6;
            userVC = [userVC init];
            
            [g_navigation pushViewController:userVC animated:YES];
            return;
        }
        
        
        JXChatViewController *sendView=[JXChatViewController alloc];
        
        sendView.scrollLine = 0;
        sendView.title = user.userNickname;
        sendView.chatPerson = user;
        sendView = [sendView init];
        [g_navigation pushViewController:sendView animated:YES];

    }

}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    [self stopLoading];
    return hide_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    [self stopLoading];
    return hide_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
//    [_wait start];
}

- (void)setTableviewHeight {
//    int height = [self tableView:_tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    CGRect frame = _tableView.frame;
//    frame.size.height = height*_array.count;
//    _tableView.frame = frame;
//
//    self.tableBody.contentSize = CGSizeMake(0, CGRectGetMaxY(_tableView.frame)+50+8);
}


- (void)clickButtonWithTag:(NSInteger )row {
   
    switch (row) {
        case 0:{// 生活圈
            WeiboViewControlle *weiboVC = [WeiboViewControlle alloc];
            weiboVC.user = g_server.myself;
            weiboVC = [weiboVC init];
            [g_navigation pushViewController:weiboVC animated:YES];
        }
            break;
//        case JXSquareTypeVideo:
//        case JXSquareTypeAudio: {// 音视频会议
//#ifdef Meeting_Version
//
//            if(g_xmpp.isLogined != 1){
//                [g_xmpp showXmppOfflineAlert];
//                return;
//            }
//            if (btnTag == JXSquareTypeAudio) {
//                [self onGroupAudioMeeting:nil];
//            }else{
//                [self onGroupVideoMeeting:nil];
//            }
//#endif
//        }
//            break;
//        case JXSquareTypeVideoLive:{ // 视频直播
//#ifdef Live_Version
//
//            JXLiveViewController *vc = [[JXLiveViewController alloc] init];
//            [g_navigation pushViewController:vc animated:YES];
//#endif
//        }
//            break;
//        case JXSquareTypeShortVideo:{// 短视频
//#ifdef Meeting_Version
//#ifdef Live_Version
//            JXSmallVideoViewController *vc = [[JXSmallVideoViewController alloc] init];
//            [g_navigation pushViewController:vc animated:YES];
//            return;
////            GKDYHomeViewController *vc = [[GKDYHomeViewController alloc] init];
////            [g_navigation pushViewController:vc animated:NO];
////            return;
//#endif
//#endif
//            [JXMyTools showTipView:Localized(@"JX_It'sNotOpenYet")];
//        }
//            break;
        case 1:{// 扫一扫
            AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
            {
                [g_server showMsg:Localized(@"JX_CanNotopenCenmar")];
                return;
            }
            
            JXScanQRViewController * scanVC = [[JXScanQRViewController alloc] init];
            [g_navigation pushViewController:scanVC animated:YES];
        }
            break;
        case 2:{// 附近的人
            JXNearVC * nearVc = [[JXNearVC alloc] init];
            [g_navigation pushViewController:nearVc animated:YES];
        }
            break;
            
        default:
            break;
    }

}



#ifdef Meeting_Version

-(void)onGroupAudioMeeting:(JXMessageObject*)msg{
    self.isAudioMeeting = 0;
    [self onInvite];
}

-(void)onGroupVideoMeeting:(JXMessageObject*)msg{
    self.isAudioMeeting = 1;
    [self onInvite];
}

-(void)onInvite{
    NSMutableSet* p = [[NSMutableSet alloc]init];
    
    JXSelectFriendsVC* vc = [JXSelectFriendsVC alloc];
    vc.isNewRoom = NO;
    vc.isShowMySelf = NO;
    vc.type = JXSelectFriendTypeSelFriends;
    vc.existSet = p;
    vc.delegate = self;
    vc.didSelect = @selector(meetingAddMember:);
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}




-(void)meetingAddMember:(JXSelectFriendsVC*)vc{
    int type;
    if (self.isAudioMeeting == 0) {
        type = kWCMessageTypeAudioMeetingInvite;
    }else if (self.isAudioMeeting == 1){
        type = kWCMessageTypeVideoMeetingInvite;
    }else{
        
    }
    for(NSNumber* n in vc.set){
        JXUserObject *user;
        if ([n intValue] / 1000000 == 9) {
            user = vc.searchArray[[n intValue] % 9000000-1];
        }else{
            user = [[vc.letterResultArr objectAtIndex:[n intValue] / 100000-1] objectAtIndex:[n intValue] % 100000-1];
        }
        NSString* s = [NSString stringWithFormat:@"%@",user.userId];
        [g_meeting sendMeetingInvite:s toUserName:user.userNickname roomJid:MY_USER_ID callId:nil type:type];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (g_meeting.isMeeting) {
            return;
        }
        JXAVCallViewController *avVC = [[JXAVCallViewController alloc] init];
        avVC.roomNum = MY_USER_ID;
        avVC.isAudio = self.isAudioMeeting;
        avVC.isGroup = YES;
        avVC.toUserName = MY_USER_NAME;
        avVC.view.frame = [UIScreen mainScreen].bounds;
        [g_window addSubview:avVC.view];
        
    });
}
#endif


- (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title icon:(NSString *)iconName highlighted:(NSString *)highlighted index:(NSInteger)index {
    UIButton *button = [[UIButton alloc] init];
    button.frame = frame;
    button.tag = index;
    [button addTarget:self action:@selector(didButton:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(didButtonDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(didButtonDragInside:) forControlEvents:UIControlEventTouchDragInside];
    [button addTarget:self action:@selector(didButtonDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
    
    [_scrollView addSubview:button];
    
//    CGFloat X = frame.origin.x;
//    CGFloat Y = frame.origin.y;
    CGFloat inset =(JX_SCREEN_WIDTH-SQUARE_HEIGHT*5)/10;   // 间隔
//    CGFloat originY = Y > 0 ? 20+51- INSET_IMAGE  : 20+51;
    CGFloat originY = 15;
    _imgV = [[UIButton alloc] init];
    _imgV.frame = CGRectMake(inset, originY, SQUARE_HEIGHT, SQUARE_HEIGHT);
    [_imgV setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
    [_imgV setImage:[UIImage imageNamed:highlighted] forState:UIControlStateHighlighted];
    _imgV.userInteractionEnabled = NO;
    _imgV.tag = index;
    [button addSubview:_imgV];
    [_subviews addObject:_imgV];
    _imgV.highlighted = button.highlighted;

    if (index == JXSquareTypeLife) {
        self.weiboNewMsgNum = [[UILabel alloc] initWithFrame:CGRectMake(SQUARE_HEIGHT - 18, -2, 20, 20)];
        self.weiboNewMsgNum.backgroundColor = HEXCOLOR(0xEF2D37);
        self.weiboNewMsgNum.font = SYSFONT(13);
        self.weiboNewMsgNum.textAlignment = NSTextAlignmentCenter;
        self.weiboNewMsgNum.layer.cornerRadius = self.weiboNewMsgNum.frame.size.width / 2;
        self.weiboNewMsgNum.layer.masksToBounds = YES;
        self.weiboNewMsgNum.hidden = YES;
        self.weiboNewMsgNum.textColor = [UIColor whiteColor];
        self.weiboNewMsgNum.text = @"99";
        [_imgV addSubview:self.weiboNewMsgNum];
    }
    
    CGSize size = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYSFONT(14)} context:nil].size;
    UILabel *lab = [[UILabel alloc] init];
    lab.text = title;
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = HEXCOLOR(0x323232);
    lab.font = SYSFONT(14);
    lab.frame = CGRectMake(0, CGRectGetMaxY(_imgV.frame)+INSET_IMAGE, frame.size.width - 5, size.height);
    CGPoint center = lab.center;
    center.x = _imgV.center.x;
    lab.center = center;
    
    CGRect btnFrame = button.frame;
    btnFrame.size.height = originY+SQUARE_HEIGHT+size.height+INSET_IMAGE;
    button.frame = btnFrame;
    
    [button addSubview:lab];
    
    return button;
}

// 点击事件
- (void)didButton:(UIButton *)button {
//    for (UIView *sub in button.subviews) {
//        if ([sub isKindOfClass:[UIButton class]]) {
//            UIButton *btn = (UIButton *)sub;
//            btn.highlighted = button.highlighted;
//            [self clickButtonWithTag:button.tag];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                btn.highlighted = NO;
//            });
//        }
//    }
}

// 按下事件
- (void)didButtonDown:(UIButton *)button {
    for (UIView *sub in button.subviews) {
        if ([sub isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)sub;
            btn.highlighted = button.highlighted;
        }
    }
}

// 手指在control的bounds范围内拖动的的事件
- (void)didButtonDragInside:(UIButton *)button {

    UIButton *btn;
    for (UIView *sub in button.subviews) {
        if ([sub isKindOfClass:[UIButton class]]) {
            btn = (UIButton *)sub;
            btn.highlighted = button.highlighted;
        }
    }
}

- (void)didButtonDragOutside:(UIButton *)button {
    UIButton *btn;
    for (UIView *sub in button.subviews) {
        if ([sub isKindOfClass:[UIButton class]]) {
            btn = (UIButton *)sub;
            btn.highlighted = button.highlighted;
        }
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView

{

    if (scrollView.contentOffset.y<=JX_SCREEN_TOP) {

        self.tableBody.bounces = NO;

    }else{

        self.tableBody.bounces = YES;

    }

}

@end
