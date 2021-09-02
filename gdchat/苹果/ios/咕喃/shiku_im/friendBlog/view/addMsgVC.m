//
//  addMsgVC.m
//  sjvodios
//
//  Created by  on 12-5-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "addMsgVC.h"
#import "AppDelegate.h"
#import "JXImageView.h"
#import "JXServer.h"
#import "JXConnection.h"
#import "ImageResize.h"
#import "UIFactory.h"
#import "JXTableView.h"
#import "QBImagePickerController.h"
#import "SBJsonWriter.h"
#import "recordVideoViewController.h"
#import "JXTextView.h"
#import "JXMediaObject.h"
#import "LXActionSheet.h"
#import "myMediaVC.h"
#import "JXLocationVC.h"
#import "JXMapData.h"
#import "WhoCanSeeViewController.h"
#import "JXSelFriendVC.h"
#import "JXSelectFriendsVC.h"
#import "RITLPhotosViewController.h"
#import "RITLPhotosDataManager.h"
#import "JXMyFile.h"
#import "UIImageView+FileType.h"
#import "JXFileDetailViewController.h"
#import "JXShareFileObject.h"
#import "webpageVC.h"
#import "JXSelectorVC.h"
#ifdef Meeting_Version
#ifdef Live_Version
#import "JXSmallVideoViewController.h"
#endif
#endif
#import "JXActionSheetVC.h"
#import "JXCameraVC.h"
#import "QCheckBox.h"

#import "JXSelectCoverVC.h"

#define insert_photo_tag -100000
typedef enum {
    MsgVisible_public = 1,
    MsgVisible_private,
    MsgVisible_see,
    MsgVisible_nonSee,
//    MsgVisible_remind,
}MsgVisible;


@interface addMsgVC()<VisibelDelegate,RITLPhotosViewControllerDelegate,JXSelectorVCDelegate, JXActionSheetVCDelegate, JXCameraVCDelegate,JXSelectCoverVCDelegate,JXImageViewPanDelegate,JXActionSheetVCDelegate>

@property (nonatomic) UIButton * lableBtn;
@property (nonatomic) UIButton * locBtn;
@property (nonatomic) UIButton * canSeeBtn;
@property (nonatomic) UIButton * remindWhoBtn;
@property (nonatomic) UIButton * replybanBtn;
@property (nonatomic, strong) QCheckBox *checkbox;
@property (nonatomic) UIButton * notReplyBtn;

@property (nonatomic) UILabel * lableLabel;
@property (nonatomic) UILabel * visibleLabel;
@property (nonatomic) UILabel * remindLabel;

@property (nonatomic) MsgVisible visible;
@property (nonatomic) NSArray * userArray;
@property (nonatomic) NSArray * userIdArray;
@property (nonatomic) NSMutableArray * selLabelsArray;
@property (nonatomic) NSMutableArray * mailListUserArray;
@property (nonatomic) CLLocationCoordinate2D coor;
@property (nonatomic) NSString * locStr;
@property (nonatomic) NSArray * remindArray;
@property (nonatomic) NSArray * remindNameArray;

@property (nonatomic) NSArray * visibelArray;

@property (nonatomic, assign) int timeLen;

@property (nonatomic, assign) NSInteger currentLableIndex;


@property (nonatomic, strong) JXLocationVC *locationVC;
@property (nonatomic, strong) WhoCanSeeViewController *whoVC;
@property (nonatomic, strong) JXSelectFriendsVC *selVC;

@property (nonatomic, strong) JXImageView* iv;

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint oraginPoint;
@property (nonatomic, assign) CGPoint newPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, strong) NSMutableArray* imageViewArray;
@property (nonatomic, assign) NSTimeInterval intoBorderTime;
@property (nonatomic, assign) NSTimeInterval stayBorderTime;
@property (nonatomic, assign) BOOL inBorder;
@property (nonatomic, assign) BOOL isUpdateImage;

@property (nonatomic, strong) NSMutableArray *videoImageUlrArr; // 视频封面url
@property (nonatomic, assign) BOOL isVideoFirstUpload; // 上传封面

@property (nonatomic, strong) NSMutableDictionary *gifDataDic;

@property (nonatomic, strong) UIImageView *shareImageView;

@end

@implementation addMsgVC
@synthesize isChanged;
@synthesize audioFile;
@synthesize videoFile;
@synthesize fileFile;
@synthesize dataType;

#define video_tag -100
#define audio_tag -200
#define pause_tag -300
#define file_tag  -400


- (addMsgVC *) init
{
	self  = [super init];
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.maxImageCount = 9;
    self.isGotoBack = YES;
    self.isFreeOnClose = YES;
    self.title = Localized(@"addMsgVC_SendFriend");
    //self.view.frame = g_window.bounds;
    [self createHeadAndFoot];
    self.tableBody.backgroundColor = [UIColor whiteColor];
    _shareImageView = [[UIImageView alloc] init];
    _images = [[NSMutableArray alloc]init];
    _videoImageUlrArr = [[NSMutableArray alloc]init];
    _visible = MsgVisible_public;
    _remindArray = [NSArray array];
    _visibelArray = [NSArray arrayWithObjects:Localized(@"JXBlogVisibel_public"), Localized(@"JXBlogVisibel_private"), Localized(@"JXBlogVisibel_see"), Localized(@"JXBlogVisibel_nonSee"), nil];
#ifdef Meeting_Version
#ifdef Live_Version
    _currentLableIndex = JXSmallVideoTypeOther - 1;
#endif
#endif

	return self;
}

-(void)dealloc{
//    NSLog(@"addMsgVC.dealloc");
    [_images removeAllObjects];
//    [_images release];
//    [super dealloc];
}

-(void)setDataType:(int)value{
    dataType = value;

    [g_factory removeAllChild:self.tableBody];
    _buildHeight=0;
    
    if(dataType >= weibo_dataType_text){
        [self buildTextView];
        self.title = Localized(@"JX_SendWord");
        
        //在发布信息后调用，并使其刷新
    }
    if(dataType == weibo_dataType_image){
        [self buildImageViews];
        self.title = Localized(@"JX_SendImage");
        if (self.shareTitle) {
            _remark.textColor = [UIColor blackColor];
            _remark.text = self.shareTitle;
        }
        if (self.shareIcon) {
            [_shareImageView sd_setImageWithURL:[NSURL URLWithString:self.shareIcon] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                
                [_images addObject:image];
                [self showImages];
            }];
        }
    }
    if(dataType == weibo_dataType_audio){
        [self buildAudios];
        [self showAudios];
        self.title = Localized(@"JX_SendVoice");
    }
    if(dataType == weibo_dataType_video){
        [self buildVideos];
        if (videoFile.length > 0) {
            
            UIImage *image = [FileInfo getFirstImageFromVideo:videoFile];
            if (image) {
                [_images addObject:image];
            }
        }
        [self showVideos];
        self.title = Localized(@"JX_SendVideo");
    }
    if (dataType == weibo_dataType_file) {
        
        [self buildFiles];
        [self showFiles];
        self.title = Localized(@"JX_SendFile");
    }
    
    if (dataType == weibo_dataType_share) {
        [self buildShare];
        self.title = Localized(@"JX_ShareLifeCircle");
    }
    
    int h1 = 38,h=0,w=JX_SCREEN_WIDTH-9*2;
    CGFloat maxY = 0;
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, h+_buildHeight+10, JX_SCREEN_WIDTH, 8)];
    line.backgroundColor = HEXCOLOR(0xF2F2F2);
    [self.tableBody addSubview:line];

    //可见
    
    [self.tableBody addSubview:self.canSeeBtn];
    self.canSeeBtn.frame = CGRectMake(0, CGRectGetMaxY(line.frame), JX_SCREEN_WIDTH, 56);
    maxY = CGRectGetMaxY(self.canSeeBtn.frame);
    
    
    //提醒
    [self.tableBody addSubview:self.remindWhoBtn];
    self.remindWhoBtn.frame = CGRectMake(0, h+CGRectGetMaxY(self.canSeeBtn.frame), JX_SCREEN_WIDTH, 56);
    maxY = CGRectGetMaxY(self.remindWhoBtn.frame);
    
    if (self.isShortVideo) {
        //标签
        [self.tableBody addSubview:self.lableBtn];
        self.lableBtn.frame = CGRectMake(0, h+CGRectGetMaxY(self.remindWhoBtn.frame), JX_SCREEN_WIDTH, 56);
        maxY = CGRectGetMaxY(self.lableBtn.frame);
    }
    
    if ([g_config.isOpenPositionService intValue] == 0) {
        //位置
        [self.tableBody addSubview:self.locBtn];
        if (self.isShortVideo) {
            self.locBtn.frame = CGRectMake(0, h+CGRectGetMaxY(self.lableBtn.frame), JX_SCREEN_WIDTH, 56);
        }else {
            self.locBtn.frame = CGRectMake(0, h+CGRectGetMaxY(self.remindWhoBtn.frame), JX_SCREEN_WIDTH, 56);
        }
        maxY = CGRectGetMaxY(self.locBtn.frame);
    }
    
    //禁止他人评论
    [self.tableBody addSubview:self.replybanBtn];
    self.replybanBtn.frame = CGRectMake(0, maxY, JX_SCREEN_WIDTH, 56);
    maxY = CGRectGetMaxY(self.replybanBtn.frame);
    
    
    UIButton* btn;
    
    btn = [UIFactory createButtonWithTitle:Localized(@"JX_Send")
                                 titleFont:g_factory.font15
                                titleColor:[UIColor whiteColor]
                                    normal:nil
                                 highlight:nil];
//    [btn setBackgroundImage:[g_theme themeTintImage:@"feaBtn_backImg_sel"] forState:UIControlStateNormal];
//    [btn setBackgroundImage:[g_theme themeTintImage:@"feaBtn_backImg_sel"] forState:UIControlStateDisabled];
    
    [btn setBackgroundImage:[UIImage createImageWithColor:THEMECOLOR] forState:UIControlStateNormal];
    UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
    [btn setBackgroundImage:img forState:UIControlStateHighlighted];
    [btn setBackgroundImage:[UIImage createImageWithColor:[THEMECOLOR colorWithAlphaComponent:0.5]] forState:UIControlStateDisabled];

    
    btn.frame = CGRectMake(JX_SCREEN_WIDTH-15-51, JX_SCREEN_TOP-9-29, 51, 29);
    btn.custom_acceptEventInterval = .25f;
    btn.layer.cornerRadius = 3.f;
    btn.layer.masksToBounds = YES;
    btn.enabled = NO;
    [btn addTarget:self action:@selector(actionSave) forControlEvents:UIControlEventTouchUpInside];
    [self.tableHeader addSubview:btn];
    _sendBtn = btn;
    
    [self showImages];
}

- (UIButton *)lableBtn {
    if (!_lableBtn) {
        _lableBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lableBtn setBackgroundColor:[UIColor whiteColor]];
        [_lableBtn setTitle:Localized(@"JX_SelectionLabel") forState:UIControlStateNormal];
        [_lableBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_lableBtn setTitleColor:HEXCOLOR(0x576b95) forState:UIControlStateSelected];
        _lableBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_lableBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
        _lableBtn.titleLabel.font = g_factory.font16;
        _lableBtn.custom_acceptEventInterval = 1.0f;
        [_lableBtn addTarget:self action:@selector(lableBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView * line = [[UIView alloc] init];
        line.frame = CGRectMake(15, 55.5, JX_SCREEN_WIDTH-15*2, LINE_WH);
        line.backgroundColor = THE_LINE_COLOR;
        [_lableBtn addSubview:line];
        
        UIImageView * locImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tap"]];
        locImg.frame = CGRectMake(15, 17, 22, 22);
        [_lableBtn addSubview:locImg];
        
        //        _locLabel = [UIFactory createLabelWith:CGRectZero text:@"所在位置" font:g_factory.font15 textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor]];
        //        _locLabel.frame = CGRectMake(CGRectGetMaxX(locImg.frame)+10, 8, JX_SCREEN_WIDTH-CGRectGetMaxX(locImg.frame)-10-50, 30);
        //        [_locBtn addSubview:_locLabel];
        
        UIImageView * arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15-7, 21.5, 7, 13)];
        arrowView.image = [UIImage imageNamed:@"new_icon_>"];
        [_lableBtn addSubview:arrowView];
        
        _lableLabel = [UIFactory createLabelWith:CGRectZero text:Localized(@"OTHER") font:g_factory.font16 textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor]];
        _lableLabel.frame = CGRectMake(arrowView.frame.origin.x - 200 - 10, 17, 200, 22);
        _lableLabel.textAlignment = NSTextAlignmentRight;
        [_lableBtn addSubview:_lableLabel];
        
    }
    return _lableBtn;
}

-(UIButton *)locBtn{
    if (!_locBtn) {
        _locBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_locBtn setBackgroundColor:[UIColor whiteColor]];
        [_locBtn setTitle:Localized(@"JXUserInfoVC_Loation") forState:UIControlStateNormal];
        [_locBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_locBtn setTitleColor:HEXCOLOR(0x576b95) forState:UIControlStateSelected];
        _locBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_locBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 20)];
        _locBtn.titleLabel.font = g_factory.font16;
        _locBtn.custom_acceptEventInterval = 1.0f;
        [_locBtn addTarget:self action:@selector(locBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView * line = [[UIView alloc] init];
        line.frame = CGRectMake(50, 55.5, JX_SCREEN_WIDTH-15*2, LINE_WH);
        line.backgroundColor = THE_LINE_COLOR;
        [_locBtn addSubview:line];
        
        UIImageView * locImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"currentLocation_gray"]];
        locImg.frame = CGRectMake(15, 17, 22, 22);
        [_locBtn addSubview:locImg];
        
//        _locLabel = [UIFactory createLabelWith:CGRectZero text:@"所在位置" font:g_factory.font15 textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor]];
//        _locLabel.frame = CGRectMake(CGRectGetMaxX(locImg.frame)+10, 8, JX_SCREEN_WIDTH-CGRectGetMaxX(locImg.frame)-10-50, 30);
//        [_locBtn addSubview:_locLabel];
        
        UIImageView * arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15-7, 21.5, 7, 13)];
        arrowView.image = [UIImage imageNamed:@"new_icon_>"];
        [_locBtn addSubview:arrowView];

    }
    return _locBtn;
}

-(UIButton *)canSeeBtn{
    if (!_canSeeBtn) {
        _canSeeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_canSeeBtn setBackgroundColor:[UIColor whiteColor]];
        [_canSeeBtn setTitle:Localized(@"JXBlog_whocansee") forState:UIControlStateNormal];
//        [_canSeeBtn setTitle:Localized(@"JXBlog_whocansee") forState:UIControlStateSelected];
        [_canSeeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_canSeeBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        _canSeeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_canSeeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
        _canSeeBtn.titleLabel.font = g_factory.font16;
        _canSeeBtn.custom_acceptEventInterval = 1.0f;
        [_canSeeBtn addTarget:self action:@selector(whoCanSeeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView * line = [[UIView alloc] init];
        line.frame = CGRectMake(50, 55.5, JX_SCREEN_WIDTH-15*2, LINE_WH);
        line.backgroundColor = THE_LINE_COLOR;
        [_canSeeBtn addSubview:line];
        
        UIImageView * locImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"seeVisibel_gray"]];
        locImg.frame = CGRectMake(15, 17, 22, 22);
        [_canSeeBtn addSubview:locImg];
        
        UIImageView * arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15-7, 21.5, 7, 13)];
        arrowView.image = [UIImage imageNamed:@"new_icon_>"];
        [_canSeeBtn addSubview:arrowView];
        
        _visibleLabel = [UIFactory createLabelWith:CGRectZero text:_visibelArray[_visible-1] font:g_factory.font16 textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor]];
        _visibleLabel.frame = CGRectMake(CGRectGetMaxX(_canSeeBtn.titleLabel.frame)+_canSeeBtn.titleEdgeInsets.left+10, 17, CGRectGetMinX(arrowView.frame)-CGRectGetMaxX(_canSeeBtn.titleLabel.frame)-_canSeeBtn.titleEdgeInsets.left-10-10, 22);
        _visibleLabel.textAlignment = NSTextAlignmentRight;
        _visibleLabel.textColor = HEXCOLOR(0x999999);
        [_canSeeBtn addSubview:_visibleLabel];
        
    }
    return _canSeeBtn;
}

-(UIButton *)remindWhoBtn{
    if (!_remindWhoBtn) {
        _remindWhoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_remindWhoBtn setBackgroundColor:[UIColor whiteColor]];
        [_remindWhoBtn setTitle:Localized(@"JXBlog_remindWho") forState:UIControlStateNormal];
        [_remindWhoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_remindWhoBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        [_remindWhoBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        _remindWhoBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_remindWhoBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
        _remindWhoBtn.titleLabel.font = g_factory.font16;
        _remindWhoBtn.custom_acceptEventInterval = 1.0f;
        [_remindWhoBtn addTarget:self action:@selector(remindWhoBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView * line = [[UIView alloc] init];
        line.frame = CGRectMake(50, 55.5, JX_SCREEN_WIDTH-15*2, LINE_WH);
        line.backgroundColor = THE_LINE_COLOR;
        [_remindWhoBtn addSubview:line];
        
        UIImageView * locImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blogRemind_gray"]];
        locImg.frame = CGRectMake(15, 17, 22, 22);
        [_remindWhoBtn addSubview:locImg];
        
        UIImageView * arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15-7, 21.5, 7, 13)];
        arrowView.image = [UIImage imageNamed:@"new_icon_>"];
        [_remindWhoBtn addSubview:arrowView];

        _remindLabel = [UIFactory createLabelWith:CGRectZero text:@"" font:g_factory.font16 textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor]];
        _remindLabel.frame = CGRectMake(CGRectGetMaxX(_remindWhoBtn.titleLabel.frame)+_remindWhoBtn.titleEdgeInsets.left+30, 17, CGRectGetMinX(arrowView.frame)-CGRectGetMaxX(_remindWhoBtn.titleLabel.frame)-_remindWhoBtn.titleEdgeInsets.left-10-30, 22);
        _remindLabel.textAlignment = NSTextAlignmentRight;
        _remindLabel.textColor = HEXCOLOR(0x999999);
        [_remindWhoBtn addSubview:_remindLabel];
        
        
    }
    return _remindWhoBtn;
}

- (UIButton *)replybanBtn {
    if (!_replybanBtn) {
        _replybanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _checkbox = [[QCheckBox alloc] initWithDelegate:self];
//        _checkbox.frame = CGRectMake(15, 15, 20, 20);
//        [_replybanBtn addSubview:_checkbox];
        
        _notReplyBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 17, 22, 22)];
        [_notReplyBtn setBackgroundImage:[UIImage imageNamed:@"weibo_not_reply"] forState:UIControlStateNormal];
        [_notReplyBtn setBackgroundImage:[UIImage imageNamed:@"sel_check_wx2"] forState:UIControlStateSelected];
        [_notReplyBtn addTarget:self action:@selector(clickReplyBanBtn) forControlEvents:UIControlEventTouchUpInside];
        [_replybanBtn addSubview:_notReplyBtn];

        
        CGSize size = [Localized(@"JX_DoNotCommentOnThem") sizeWithAttributes:@{NSFontAttributeName:SYSFONT(16)}];
    
        UILabel *tint = [[UILabel alloc] initWithFrame:CGRectMake(50, 18, size.width, 20)];
        tint.text = Localized(@"JX_DoNotCommentOnThem");
        tint.font = SYSFONT(16);
        [_replybanBtn addSubview:tint];
        
        UILabel *tintGray = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(tint.frame)+15, 18, JX_SCREEN_WIDTH-15*2-50- size.width, 20)];
        tintGray.text = Localized(@"JX_ EveryoneCanNotComment");
        tintGray.textColor = HEXCOLOR(0x999999);
        tintGray.font = SYSFONT(12);
        tintGray.textAlignment = NSTextAlignmentRight;
        [_replybanBtn addSubview:tintGray];
        
        [_replybanBtn addTarget:self action:@selector(clickReplyBanBtn) forControlEvents:UIControlEventTouchUpInside];

    }
    return _replybanBtn;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

-(void)doRefresh{
    _refreshCount++;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.urlShare.length > 0) {
        _remark.text = self.urlShare;
    }

}

-(void)buildTextView{
    _buildHeight = 0;
    _remark = [[UITextView alloc] initWithFrame:CGRectMake(15, 1, JX_SCREEN_WIDTH -30,78)];
//    _remark.target = self;
//    _remark.didTouch = @selector(actionSave);
    //_remark.placeHolder = @"这一刻的想法..";
    _remark.backgroundColor = [UIColor clearColor];
//    _remark.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
//    _remark.layer.borderWidth = 0.65f;
//    _remark.layer.cornerRadius = 6.0f;
    _remark.returnKeyType = UIReturnKeyDone;
    _remark.font = g_factory.font16;
    _remark.text = Localized(@"addMsgVC_Mind");
    _remark.textColor = [UIColor grayColor];
    _remark.delegate = self;
    
    [self.tableBody addSubview:_remark];
    _buildHeight += 80;
}

- (void)textViewDidChange:(UITextView *)textView {
    _sendBtn.enabled = fileFile.length > 0 || _images.count > 0 || videoFile.length > 0 || audioFile.length > 0 || textView.text.length > 0;
}

-(void)buildImageViews{
//    UILabel* lb = [[UILabel alloc]initWithFrame:CGRectMake(0, _buildHeight, JX_SCREEN_WIDTH, 25)];
//    lb.text = Localized(@"addMsgVC_AddPhoto");
//    lb.font = g_UIFactory.font16;
//    lb.backgroundColor = [UIColor clearColor];
//    [self.tableBody addSubview:lb];
    
    svImages = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _buildHeight+25, JX_SCREEN_WIDTH,80)];
    svImages.pagingEnabled = YES;
    svImages.delegate = self;
    svImages.showsVerticalScrollIndicator = NO;
    svImages.showsHorizontalScrollIndicator = NO;
    svImages.backgroundColor = [UIColor clearColor];
    svImages.userInteractionEnabled = YES;
    [self.tableBody addSubview:svImages];
    
    _buildHeight += 105;
}

-(void)buildAudios{
//    UILabel* lb = [[UILabel alloc]initWithFrame:CGRectMake(0, _buildHeight, JX_SCREEN_WIDTH, 25)];
//    lb.text = Localized(@"addMsgVC_AddVoice");
//    lb.font = g_UIFactory.font14;
//    lb.backgroundColor = [UIColor clearColor];
//    [self.tableBody addSubview:lb];
    
    svAudios = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _buildHeight+25, JX_SCREEN_WIDTH,80)];
    svAudios.pagingEnabled = YES;
    svAudios.delegate = self;
    svAudios.showsVerticalScrollIndicator = NO;
    svAudios.showsHorizontalScrollIndicator = NO;
    svAudios.backgroundColor = [UIColor clearColor];
    svAudios.userInteractionEnabled = YES;
    [self.tableBody addSubview:svAudios];
    
   _buildHeight += 105;
}

-(void)buildVideos{
//    UILabel* lb = [[UILabel alloc]initWithFrame:CGRectMake(0, _buildHeight, JX_SCREEN_WIDTH, 25)];
//    lb.text = Localized(@"addMsgVC_AddVideo");
//    lb.font = g_UIFactory.font14;
//    lb.backgroundColor = [UIColor clearColor];
//    [self.tableBody addSubview:lb];
    
    svVideos = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _buildHeight+25, JX_SCREEN_WIDTH ,80)];
    svVideos.pagingEnabled = YES;
    svVideos.delegate = self;
    svVideos.showsVerticalScrollIndicator = NO;
    svVideos.showsHorizontalScrollIndicator = NO;
    svVideos.backgroundColor = [UIColor clearColor];
    svVideos.userInteractionEnabled = YES;
    [self.tableBody addSubview:svVideos];
    
    _buildHeight += 105;
}

-(void)buildFiles{
//    UILabel* lb = [[UILabel alloc]initWithFrame:CGRectMake(0, _buildHeight, JX_SCREEN_WIDTH, 25)];
//    lb.text = Localized(@"JX_AddMsgVC_AddFile");
//    lb.font = g_UIFactory.font14;
//    lb.backgroundColor = [UIColor clearColor];
//    [self.tableBody addSubview:lb];
    
    svFiles = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _buildHeight+25, JX_SCREEN_WIDTH ,80)];
    svFiles.pagingEnabled = YES;
    svFiles.delegate = self;
    svFiles.showsVerticalScrollIndicator = NO;
    svFiles.showsHorizontalScrollIndicator = NO;
    svFiles.backgroundColor = [UIColor clearColor];
    svFiles.userInteractionEnabled = YES;
    [self.tableBody addSubview:svFiles];
    
    _buildHeight += 105;
}

- (void)buildShare{
    
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(10, _buildHeight + 25, JX_SCREEN_WIDTH - 20, 70)];
    view.backgroundColor = HEXCOLOR(0xf0f0f0);
    [view addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableBody addSubview:view];
    
    JXImageView *imageView = [[JXImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];

//    imageView.image = [UIImage imageNamed:@"ALOGO_120"];
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.shareIcon] placeholderImage:[UIImage imageNamed:@"ALOGO_120"]];
    [view addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, imageView.frame.origin.y, view.frame.size.width - CGRectGetMaxX(imageView.frame) - 15, imageView.frame.size.height)];
    label.numberOfLines = 0;
//    label.text = @"哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈";
    label.text = self.shareTitle;
    label.font = [UIFont systemFontOfSize:14.0];
    [view addSubview:label];
    
    _buildHeight += 105;
}

- (void)shareAction:(UIButton *)btn {
    
    webpageVC *webVC = [webpageVC alloc];
    webVC.isGotoBack= YES;
    webVC.isSend = YES;
    webVC.title = self.shareTitle;
    webVC.url = self.shareUr;
    webVC = [webVC init];
    [g_navigation.navigationView addSubview:webVC.view];
//    [g_navigation pushViewController:webVC animated:YES];
}

-(void)showImages{
    int i;
    [g_factory removeAllChild:svImages];
    
    NSInteger n = [_images count];
    _sendBtn.enabled = n > 1 || _remark.text.length > 0;
    svImages.contentSize = CGSizeMake((n+1) * 80, svImages.frame.size.height);
    for(i=0;i<n&&i<9;i++){
        JXImageView* iv = [[JXImageView alloc]initWithFrame:CGRectMake(i*78+15, 10, 63,63)];
        iv.delegate = self;
        iv.panDelegate = self;
        iv.userInteractionEnabled = YES;
        iv.layer.cornerRadius = 6;
        iv.layer.masksToBounds = YES;
        iv.animationType = JXImageView_Animation_Line;
        iv.tag = i;
        [iv addLongPressGesture];
        [iv addTapGesture];
        iv.image = [_images objectAtIndex:i];
        [svImages addSubview:iv];
//        [iv release];
    }
    _imageViewArray = [NSMutableArray arrayWithArray:svImages.subviews];
    UIButton* btn = [self createButton:nil icon:@"add_picture" action:@selector(actionImage:) parent:svImages];
    btn.frame = CGRectMake(i*78+15, 10, 63, 63);
    btn.tag = insert_photo_tag;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, btn.frame.size.width, 15)];
    label.font = SYSFONT(11);
    label.textColor = HEXCOLOR(0xB3B3B3);
    label.textAlignment = NSTextAlignmentCenter;
    label.text = Localized(@"JX_AddPictures");
    [btn addSubview:label];
}

- (void)tapImageView:(JXImageView *)imageView{
    [self actionImage:imageView];
}

- (void)getTouchWhenMove:(JXImageView *)imageView withTouch:(NSSet *)touch withEvent:(UIEvent *)event withLongPressGes:(UILongPressGestureRecognizer *)lpGes{
    UITouch *mytouch = touch.allObjects.lastObject;
    CGPoint inWindow = [mytouch locationInView:nil];
    if ((inWindow.x > JX_SCREEN_WIDTH - 30 && inWindow.x < JX_SCREEN_WIDTH && svImages.contentOffset.x == 0) || (inWindow.x < 30 && svImages.contentOffset.x > 0)) {
        if (_inBorder) {
            _stayBorderTime = mytouch.timestamp - _intoBorderTime;
            if (_stayBorderTime > 0.3) {
                [self changeWhenPan:imageView gesture:lpGes];
            }
        }else{
            _inBorder = YES;
            _intoBorderTime = mytouch.timestamp;
        }
    }else{
        _inBorder = NO;
        _intoBorderTime = 0;
    }
}

- (void)changeWhenPan:(JXImageView *)sender gesture:(UILongPressGestureRecognizer *)sender2{
    BOOL isBorderStart = NO;
    if (sender2.state == UIGestureRecognizerStateBegan) {
        [svImages setScrollEnabled:NO];
        sender.alpha = 0.5;
        self.startPoint = [sender2 locationInView:svImages];
        CGPoint inWindow = [sender2 locationInView:nil];
        if ((inWindow.x > JX_SCREEN_WIDTH - 30 && inWindow.x < JX_SCREEN_WIDTH && svImages.contentOffset.x == 0) || (inWindow.x < 30 && svImages.contentOffset.x > 0)) {
            isBorderStart = YES;
        }else{
            isBorderStart = NO;
        }
        self.oraginPoint = sender.center;
        _lastPoint = _oraginPoint;
        [self.view bringSubviewToFront:svImages];
        [svImages bringSubviewToFront:sender];
    }else if (sender2.state == UIGestureRecognizerStateChanged) {
        self.newPoint = [sender2 locationInView:svImages];
        CGFloat xChange = _newPoint.x - _startPoint.x;
        CGFloat yChange = _newPoint.y - _startPoint.y;
        sender.center = CGPointMake(_oraginPoint.x + xChange, _oraginPoint.y + yChange);
        CGPoint inWindow = [sender2 locationInView:nil];
        if (isBorderStart) {
            if ((inWindow.x < JX_SCREEN_WIDTH - 30 && svImages.contentOffset.x == 0) && (inWindow.x > 30 && svImages.contentOffset.x > 0)){
                isBorderStart = NO;
            }
        }
        if (inWindow.x < 30 && svImages.contentOffset.x > 0 && !isBorderStart && _stayBorderTime > 0.3) {
            for (int num = 0; num <_imageViewArray.count; num++) {
                JXImageView *imgView = _imageViewArray[num];
                if (imgView.tag != num) {
                    [_imageViewArray exchangeObjectAtIndex:num withObjectAtIndex:imgView.tag];
                }
            }
            [UIView animateWithDuration:0.3 animations:^{
                [svImages setContentOffset:CGPointMake(0, 0)];
            }];
            _stayBorderTime = 0;
            _inBorder = NO;
            NSInteger index = sender.tag;
            for (NSInteger i = index - 1; i > -1; i--) {
                JXImageView *imgView = _imageViewArray[i];
                [_images exchangeObjectAtIndex:imgView.tag withObjectAtIndex:imgView.tag + 1];
                [UIView animateWithDuration:0.5 animations:^{
                    imgView.tag = imgView.tag + 1;
                    CGPoint center = imgView.center;
                    imgView.center = _lastPoint;
                    _lastPoint = center;
                }];
            }
            sender.tag = 0;

        }else if (inWindow.x > g_window.frame.size.width - 30 && _newPoint.x < svImages.contentSize.width && !isBorderStart && _stayBorderTime > 0.3) {
            for (int num = 0; num <_imageViewArray.count; num++) {
                JXImageView *imgView = _imageViewArray[num];
                if (imgView.tag != num) {
                    [_imageViewArray exchangeObjectAtIndex:num withObjectAtIndex:imgView.tag];
                }
            }
            [UIView animateWithDuration:0.3 animations:^{
                [svImages setContentOffset:CGPointMake(svImages.contentSize.width - JX_SCREEN_WIDTH, 0)];
            }];
            _stayBorderTime = 0;
            _inBorder = NO;
            NSInteger index = sender.tag;
            for (NSInteger i = index + 1; i < _imageViewArray.count; i++) {
                JXImageView *imgView = _imageViewArray[i];
                [_images exchangeObjectAtIndex:imgView.tag withObjectAtIndex:imgView.tag - 1];
                [UIView animateWithDuration:0.5 animations:^{
                    imgView.tag = imgView.tag - 1;
                    CGPoint center = imgView.center;
                    imgView.center = _lastPoint;
                    _lastPoint = center;
                }];
            }
            sender.tag = _imageViewArray.count - 1;

        }else{
            for (int num = 0; num <_imageViewArray.count; num++) {
                JXImageView *imgView = _imageViewArray[num];
                if (imgView.tag != num) {
                    [_imageViewArray exchangeObjectAtIndex:num withObjectAtIndex:imgView.tag];
                }
            }
            for (NSInteger i = 0;i < _imageViewArray.count; i++) {
                JXImageView * imgView = _imageViewArray[i];
                if (CGRectContainsPoint(imgView.frame, _newPoint)) {
                    if (imgView == sender) {
                        continue;
                    }
                    [UIView animateWithDuration:0.3 animations:^{
                        CGPoint point = imgView.center;
                        imgView.center = _lastPoint;
                        _lastPoint = point;
                    }];
                    [_images exchangeObjectAtIndex:imgView.tag withObjectAtIndex:sender.tag];
                    NSInteger l = imgView.tag;
                    imgView.tag = sender.tag;
                    sender.tag = l;
                }
            }
            if (!CGRectContainsPoint(svImages.bounds, _newPoint)) {
                [sender2 setState:UIGestureRecognizerStateEnded];
            }
        }
    
    }else if(sender2.state == UIGestureRecognizerStateEnded) {
        sender.alpha = 1;
        [UIView animateWithDuration:0.3 animations:^{
            sender.center = _lastPoint;
        }];
        [svImages setScrollEnabled:YES];
    }
}

-(void)showAudios{
//    int i;
    [g_factory removeAllChild:svAudios];
    
    if(audioFile){
        _sendBtn.enabled = YES;
        JXImageView* iv = [[JXImageView alloc]initWithFrame:CGRectMake(10, 10, 60, 60)];
        iv.userInteractionEnabled = YES;
        iv.layer.cornerRadius = 6;
        iv.layer.masksToBounds = YES;
        iv.delegate = self;
//        iv.didTouch = @selector(onDelAudio);
        iv.didTouch = @selector(donone);
        iv.animationType = JXImageView_Animation_Line;
        iv.tag = audio_tag;
        [svAudios addSubview:iv];
//        [iv release];
        
        if([_images count]>0)
            iv.image = [_images objectAtIndex:0];
        else
            [g_server getHeadImageSmall:g_server.myself.userId userName:g_server.myself.userNickname imageView:iv getHeadHandler:nil];

        audioPlayer = [[JXAudioPlayer alloc] initWithParent:iv];
        audioPlayer.isOpenProximityMonitoring = NO;
        audioPlayer.pauseBtn.userInteractionEnabled = NO;
        audioPlayer.audioFile = audioFile;
        
    }else{
        _sendBtn.enabled = _remark.text.length > 0;
        UIButton* btn = [self createButton:nil icon:@"add_voice" action:@selector(onAddAudio) parent:svAudios];
        btn.frame = CGRectMake(15, 10, 63, 63);
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, btn.frame.size.width, 15)];
        label.font = SYSFONT(11);
        label.textColor = HEXCOLOR(0xB3B3B3);
        label.textAlignment = NSTextAlignmentCenter;
        label.text = Localized(@"JX_AddMsg_AddRecording");
        [btn addSubview:label];
    }
}

-(void)showVideos{
//    int i;
    [g_factory removeAllChild:svVideos];
    
    if(videoFile){
        _sendBtn.enabled = YES;
        _iv = [[JXImageView alloc] initWithFrame:CGRectMake(15, 10, 60, 60)];
        _iv.userInteractionEnabled = YES;
        _iv.layer.cornerRadius = 6;
        _iv.layer.masksToBounds = YES;
        _iv.delegate = self;
//        iv.didTouch = @selector(onDelVideo);
        _iv.didTouch = @selector(donone);
        _iv.animationType = JXImageView_Animation_Line;
        _iv.tag = video_tag;
        if([_images count]>0)
            _iv.image = [_images objectAtIndex:0];
        else
            [g_server getHeadImageSmall:g_server.myself.userId userName:g_server.myself.userNickname imageView:_iv getHeadHandler:nil];
        [svVideos addSubview:_iv];
//        [iv release];
        UIButton *pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        pauseBtn.center = CGPointMake(_iv.frame.size.width/2,_iv.frame.size.height/2);
        [pauseBtn setBackgroundImage:[UIImage imageNamed:@"playvideo"] forState:UIControlStateNormal];
        [pauseBtn addTarget:self action:@selector(showTheVideo) forControlEvents:UIControlEventTouchUpInside];
        [_iv addSubview:pauseBtn];
        pauseBtn.userInteractionEnabled = NO;
        
//        videoPlayer = [[JXVideoPlayer alloc] initWithParent:iv];
//        videoPlayer.videoFile = videoFile;
        
    }else{
        _sendBtn.enabled = _remark.text.length > 0;
        UIButton* btn = [self createButton:nil icon:@"add_video" action:@selector(onAddVideo) parent:svVideos];
        btn.frame = CGRectMake(15, 10, 63, 63);
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, btn.frame.size.width, 15)];
        label.font = SYSFONT(11);
        label.textColor = HEXCOLOR(0xB3B3B3);
        label.textAlignment = NSTextAlignmentCenter;
        label.text = Localized(@"JX_AddMsg_AddVideo");
        [btn addSubview:label];
    }
}


- (void)donone {
    if (audioFile) {
        NSArray *names = @[Localized(@"JX_Re-record"),Localized(@"PLAY")];
        if (audioPlayer.player.isPlaying) {
            names = @[Localized(@"JX_Re-record"),Localized(@"JX_timeOut")];
        }
        JXActionSheetVC *vc = [[JXActionSheetVC alloc] initWithImages:nil names:names];
        vc.delegate = self;
        vc.tag = 10021;
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if (videoFile) {
        JXActionSheetVC *vc = [[JXActionSheetVC alloc] initWithImages:nil names:@[Localized(@"JX_Reselect"),Localized(@"JX_Re-record"),Localized(@"PLAY")]];
        vc.delegate = self;
        vc.tag = 10022;
        [self presentViewController:vc animated:YES completion:nil];

    }
}

- (void)selectImageView:(id)imgView index:(NSInteger)tag{
    NSLog(@"我的tag = %ld",(long)tag);
    _iv.image = _images[tag];
    [self saveImgCover:_images[tag]];
}
// 保存封面图
- (void)saveImgCover:(UIImage *)img{
    
    NSString *filePath = [NSString stringWithFormat:@"%@%@.jpg",myTempFilePath,[[videoFile lastPathComponent] stringByDeletingPathExtension]];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isExist = [manager fileExistsAtPath:filePath];
    NSError *error;
    if (isExist) {
        [manager removeItemAtPath:filePath error:&error];
    }
    NSData * imageData = UIImageJPEGRepresentation(img, 1);
    BOOL isSave = [imageData writeToFile:filePath atomically:YES];
    if (!isSave) {
        NSLog(@"保存封面图失败");
        return;
    }
    [self.videoImageUlrArr removeAllObjects];
    self.isVideoFirstUpload = YES;
    [g_server uploadFile:filePath validTime:nil messageId:nil toView:self];

}
- (void)showTheVideo {
//    UIView *playerView = [[UIView alloc] initWithFrame:self.view.bounds];
//    [self.view addSubview:playerView];
    videoPlayer= [JXVideoPlayer alloc];
    videoPlayer.videoFile = videoFile;
    videoPlayer.didVideoPlayEnd = @selector(didVideoPlayEnd);
    videoPlayer.isStartFullScreenPlay = YES; //全屏播放
    videoPlayer.delegate = self;
    videoPlayer = [videoPlayer initWithParent:self.view];
    [videoPlayer switch];
}

-(void)showFiles{
    //    int i;
    [g_factory removeAllChild:svFiles];
    
    if(fileFile){
        _sendBtn.enabled = YES;
        JXImageView* iv = [[JXImageView alloc] initWithFrame:CGRectMake(15, 10, 60, 60)];
        iv.userInteractionEnabled = YES;
        iv.layer.cornerRadius = 6;
        iv.layer.masksToBounds = YES;
        iv.delegate = self;
        iv.didTouch = @selector(actionFile:);
        iv.animationType = JXImageView_Animation_Line;
        iv.tag = file_tag;
        
        NSString * fileExt = [fileFile pathExtension];
        NSInteger fileType = [self fileTypeWithExt:fileExt];
        
        [iv setFileType:fileType];
//        if([_images count]>0)
//            iv.image = [_images objectAtIndex:0];
//        else
//            [g_server getHeadImageSmall:g_server.myself.userId imageView:iv];
        [svFiles addSubview:iv];
        
    }else{
        _sendBtn.enabled = _remark.text.length > 0;
        UIButton* btn = [self createButton:nil icon:@"add_file" action:@selector(onAddFile) parent:svFiles];
        btn.frame = CGRectMake(15, 10, 63, 63);
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, btn.frame.size.width, 15)];
        label.font = SYSFONT(11);
        label.textColor = HEXCOLOR(0xB3B3B3);
        label.textAlignment = NSTextAlignmentCenter;
        label.text = Localized(@"JX_AddMsg_AddFiel");
        [btn addSubview:label];
    }
}

- (void)actionFile:(JXImageView *)imageView {
    
    JXActionSheetVC *vc = [[JXActionSheetVC alloc] initWithImages:nil names:@[Localized(@"JX_Re-record"),Localized(@"JX_Open")]];
    vc.delegate = self;
    vc.tag = 10001;
    [self presentViewController:vc animated:YES completion:nil];

//    JXFileDetailViewController * detailVC = [[JXFileDetailViewController alloc] init];
//    NSDictionary *dict = @{
//                           @"url":fileFile,
//                           @"name":[fileFile pathExtension]
//                           };
//    JXShareFileObject *fileObj = [JXShareFileObject shareFileWithDict:dict];
//    detailVC.shareFile = fileObj;
//    [g_navigation pushViewController:detailVC animated:YES];
//    [g_navigation pushViewController:webVC animated:YES];
}


-(int)fileTypeWithExt:(NSString *)fileExt{
    int fileType = 0;
    if ([fileExt isEqualToString:@"jpg"] || [fileExt isEqualToString:@"jpeg"] || [fileExt isEqualToString:@"png"] || [fileExt isEqualToString:@"gif"] || [fileExt isEqualToString:@"bmp"])
        fileType = 1;
    else if ([fileExt isEqualToString:@"amr"] || [fileExt isEqualToString:@"mp3"] || [fileExt isEqualToString:@"wav"])
        fileType = 2;
    else if ([fileExt isEqualToString:@"mp4"] || [fileExt isEqualToString:@"mov"])
        fileType = 3;
    else if ([fileExt isEqualToString:@"ppt"] || [fileExt isEqualToString:@"pptx"])
        fileType = 4;
    else if ([fileExt isEqualToString:@"xls"] || [fileExt isEqualToString:@"xlsx"])
        fileType = 5;
    else if ([fileExt isEqualToString:@"doc"] || [fileExt isEqualToString:@"docx"])
        fileType = 6;
    else if ([fileExt isEqualToString:@"zip"] || [fileExt isEqualToString:@"rar"])
        fileType = 7;
    else if ([fileExt isEqualToString:@"txt"])
        fileType = 8;
    else if ([fileExt isEqualToString:@"pdf"])
        fileType = 10;
    else
        fileType = 9;
    return fileType;
}

- (void)viewDidload{
    [super viewDidLoad];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:Localized(@"addMsgVC_Mind")]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    return YES;
}



- (void)textViewDidEndEditing:(UITextView *)textView{
//    [textView resignFirstResponder];
    
    return;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"] ) {
        [self.view endEditing:YES];
    }

    if(textView.text.length > 10000 && ![text isEqualToString:@""]){
        
        [JXMyTools showTipView:Localized(@"JX_InputLimit")];
        return NO;
    }

    return YES;
}

-(void)actionImage:(JXImageView*)sender{
    _photoIndex = sender.tag;
    
    if(_photoIndex==insert_photo_tag&&[_images count]>8){
        [g_App showAlert:Localized(@"addMsgVC_SelNinePhoto")];
        return;
    }else if(_photoIndex==insert_photo_tag){
        
        JXActionSheetVC *actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:@[Localized(@"JX_ChoosePhoto"),Localized(@"JX_TakePhoto")]];
        actionVC.delegate = self;
        actionVC.tag = 111;
        [self presentViewController:actionVC animated:NO completion:nil];
        
        return;
    }
    LXActionSheet* _menu = [[LXActionSheet alloc]
                            initWithTitle:nil
                            delegate:self
                            cancelButtonTitle:Localized(@"JX_Cencal")
                            destructiveButtonTitle:Localized(@"JX_Update")
                            otherButtonTitles:@[Localized(@"JX_Delete")]];
    [g_window addSubview:_menu];
//    [_menu release];
}

- (void)actionSheet:(JXActionSheetVC *)actionSheet didButtonWithIndex:(NSInteger)index {

    if (actionSheet.tag == 2457) {
        if (index == 0) {
            RITLPhotosViewController *photoController = RITLPhotosViewController.photosViewController;
            photoController.configuration.maxCount = 1;//最大的选择数目
            photoController.configuration.containVideo = YES;//选择类型，目前只选择图片不选择视频
            photoController.configuration.containImage = NO;//选择类型，目前只选择视频不选择图片
            photoController.photo_delegate = self;
            //    photoController.thumbnailSize = CGSizeMake(220, 220);//缩略图的尺寸
            //    photoController.defaultIdentifers = self.saveAssetIds;//记录已经选择过的资源
            photoController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:photoController animated:true completion:^{}];
            
        }else {
            
            JXCameraVC *vc = [JXCameraVC alloc];
            vc.cameraDelegate = self;
            vc.isVideo = YES;
            vc = [vc init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:vc animated:YES completion:nil];
        }
        
    }
    else if (actionSheet.tag == 10001) {
        if (index == 0) {
            [self onAddFile];
        }
        else if (index == 1) {
            webpageVC *webVC = [webpageVC alloc];
            webVC.isGotoBack= YES;
            webVC.isSend = YES;
            webVC.title = [fileFile pathExtension];
            webVC.url = fileFile;
            webVC = [webVC init];
            [g_navigation.navigationView addSubview:webVC.view];
        }

    }
    else if (actionSheet.tag == 10021) {
        if (index == 0) {
            [self onAddAudio];
        }
        else if (index == 1) {
            [audioPlayer switch];
        }
    }
    else if (actionSheet.tag == 10022) {
        if (index == 0) {
            RITLPhotosViewController *photoController = RITLPhotosViewController.photosViewController;
            photoController.configuration.maxCount = 1;//最大的选择数目
            photoController.configuration.containVideo = YES;//选择类型，目前只选择图片不选择视频
            photoController.configuration.containImage = NO;//选择类型，目前只选择视频不选择图片
            photoController.photo_delegate = self;
            //    photoController.thumbnailSize = CGSizeMake(220, 220);//缩略图的尺寸
            //    photoController.defaultIdentifers = self.saveAssetIds;//记录已经选择过的资源
            photoController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:photoController animated:true completion:^{}];
        }
        else if (index == 1) {
            JXCameraVC *vc = [JXCameraVC alloc];
            vc.cameraDelegate = self;
            vc.isVideo = YES;
            vc = [vc init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:vc animated:YES completion:nil];
        }
        else {
            [self showTheVideo];
        }
    }
    else{
        
        if (index == 0) {
            
            self.maxImageCount = self.maxImageCount - (int)[_images count];
            self.isUpdateImage = NO;
            [self pickImages:YES];
            
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

- (void)cameraVC:(JXCameraVC *)vc didFinishWithImage:(UIImage *)image {
    [_images addObject:image];
    [self showImages];
}

- (void)cameraVC:(JXCameraVC *)vc didFinishWithVideoPath:(NSString *)filePath timeLen:(NSInteger)timeLen {
    
    [_images removeAllObjects];
    
    JXMediaObject* media = [[JXMediaObject alloc] init];
    media.userId = MY_USER_ID;
    media.fileName = filePath;
    media.isVideo = [NSNumber numberWithBool:YES];
    media.timeLen = [NSNumber numberWithInteger:timeLen];
    media.createTime = [NSDate date];
//    media.photoPath = filePath.absoluteString;
    
    [media insert];

    NSString* file = media.fileName;
    UIImage *image = [FileInfo getFirstImageFromVideo:file];
    videoFile = [file copy];
    //    file = [NSString stringWithFormat:@"%@.jpg",[file stringByDeletingPathExtension]];
    //    [_images addObject:[UIImage imageWithContentsOfFile:file]];
    [_images addObject:image];

    JXSelectCoverVC *Vc = [[JXSelectCoverVC alloc] initWithVideo:videoFile];
    Vc.delegate = self;
    [g_navigation pushViewController:Vc animated:YES];
    
    [self showVideos];
    
}


- (void)didClickOnButtonIndex:(LXActionSheet*)sender buttonIndex:(int)buttonIndex{
    if(buttonIndex<0)
        return;
    _nSelMenu = buttonIndex;
    [self doOutputMenu];
}


-(void)doOutputMenu{
    if(_nSelMenu==0){
        if(_photoIndex == audio_tag){
            [self onAddAudio];
            return;
        }
        if(_photoIndex == video_tag){
            [self onAddVideo];
            return;
        }
        self.isUpdateImage = YES;
        [self pickImages:NO];
    }
    if(_nSelMenu==1){
        if(_photoIndex == audio_tag){
            [self onDelAudio];
            return;
        }
        if(_photoIndex == video_tag){
            [self onDelVideo];
            return;
        }
        [_images removeObjectAtIndex:_photoIndex];
        [self showImages];
    }
}

-(void)pickImages:(BOOL)Multi{
    RITLPhotosViewController *photoController = RITLPhotosViewController.photosViewController;
    if (!self.isUpdateImage) {
        photoController.configuration.maxCount = 9 - _images.count;//最大的选择数目
    }else {
        photoController.configuration.maxCount = 1;//最大的选择数目
    }
    photoController.configuration.containVideo = NO;//选择类型，目前只选择图片不选择视频
    
    photoController.photo_delegate = self;
    photoController.thumbnailSize = CGSizeMake(320, 320);//缩略图的尺寸
    //    photoController.defaultIdentifers = self.saveAssetIds;//记录已经选择过的资源
    photoController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:photoController animated:true completion:^{}];

//    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
//    __weak id weakSelf = self;
//    imagePickerController.delegate = weakSelf;
//    imagePickerController.allowsMultipleSelection = YES;
//    imagePickerController.limitsMaximumNumberOfSelection = YES;
////    imagePickerController.limitsMinimumNumberOfSelection = YES;
//    imagePickerController.maximumNumberOfSelection = self.maxImageCount;
////    imagePickerController.minimumNumberOfSelection = 1;
//
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
//    [self presentViewController:navigationController animated:YES completion:NULL];
//    [imagePickerController release];
//    [navigationController release];
}

#pragma mark - 发送原图
- (void)photosViewController:(UIViewController *)viewController images:(NSArray<UIImage *> *)images infos:(NSArray<NSDictionary *> *)infos {
    if (self.isUpdateImage) {
        _images[_photoIndex] = images.firstObject;
    }else {
        [_images addObjectsFromArray:images.mutableCopy];
    }
    self.gifDataDic = nil;
    self.gifDataDic = [NSMutableDictionary dictionary];
    for (int i = 0; i < images.count; i++) {
        UIImage *image = images[i];
        if (image.images.count > 0) {
            NSDictionary *dic = [infos objectAtIndex:i];
            NSData *data = [dic objectForKey:@"gifData"];
            [self.gifDataDic setValue:data forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }
    [self showImages];
}
#pragma mark - 发送缩略图
- (void)photosViewController:(UIViewController *)viewController thumbnailImages:(NSArray *)thumbnailImages infos:(NSArray<NSDictionary *> *)infos {
    if (self.isUpdateImage) {
        _images[_photoIndex] = thumbnailImages.firstObject;
    }else {
        [_images addObjectsFromArray:thumbnailImages.mutableCopy];
    }
    self.gifDataDic = nil;
    self.gifDataDic = [NSMutableDictionary dictionary];
    for (int i = 0; i < thumbnailImages.count; i++) {
        UIImage *image = thumbnailImages[i];
        if (image.images.count > 0) {
            NSDictionary *dic = [infos objectAtIndex:i];
            NSData *data = [dic objectForKey:@"gifData"];
            [self.gifDataDic setValue:data forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }
    [self showImages];
}


- (void)imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    if(imagePickerController.allowsMultipleSelection) {
        NSArray *mediaInfoArray = (NSArray *)info;
//        NSLog(@"Selected %d photos", mediaInfoArray.count);
        
        for(int i=0;i<[mediaInfoArray count];i++){
            NSDictionary *selected = (NSDictionary *)[mediaInfoArray objectAtIndex:i];
            [_images addObject:[selected objectForKey:@"UIImagePickerControllerOriginalImage"]];
        }
    } else {
        NSDictionary *selected = (NSDictionary *)info;
        [_images replaceObjectAtIndex:_photoIndex withObject:[selected objectForKey:@"UIImagePickerControllerOriginalImage"]];
//        NSLog(@"Selected: %@", selected);
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self showImages];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:^{
    }];
}
- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos{
    
    return [NSString stringWithFormat:@"%ld photos",numberOfPhotos];
}
//- (NSString *)descriptionForSelectingAllAssets:(QBImagePickerController *)imagePickerController
//{
//    return @"全部选择";
//}
//
//- (NSString *)descriptionForDeselectingAllAssets:(QBImagePickerController *)imagePickerController
//{
//    return @"取消全部";
//}


- (NSString *)getNumberFromStr:(NSString *)str
{
    NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return[[str componentsSeparatedByCharactersInSet:nonDigitCharacterSet] componentsJoinedByString:@""];
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    //    [g_App hideMessage:g_App.lastMsgView];
    
    [_wait stop];
    if([aDownload.action isEqualToString:act_UploadFile]){
        if (self.isVideoFirstUpload) {
            self.isVideoFirstUpload = NO;
//            [self.videoImageUlrArr removeAllObjects];
            self.videoImageUlrArr = [dict objectForKey:@"images"];
//            [g_server uploadFile:_images audio:audioFile video:videoFile file:fileFile type:self.dataType+1 validTime:@"-1" timeLen:_timeLen toView:self];
            return;
        }
        
        NSDictionary *dataD;
        if (_timeLen > 0) {  // 和安卓统一，所以自己传length，暂时只有语音处理
            NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
            [dataDict setObject:@(_timeLen) forKey:@"length"];
            [dataDict setObject:[(NSDictionary *)[[dict objectForKey:@"audios"] firstObject] objectForKey:@"oFileName"] forKey:@"oFileName"];
            [dataDict setObject:[(NSDictionary *)[[dict objectForKey:@"audios"] firstObject] objectForKey:@"status"] forKey:@"status"];
            [dataDict setObject:[(NSDictionary *)[[dict objectForKey:@"audios"] firstObject] objectForKey:@"oUrl"] forKey:@"oUrl"];
            NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithDictionary:dict];
            NSMutableArray *mutArr = [NSMutableArray arrayWithObjects:dataDict, nil];
            [mutDict setObject:mutArr forKey:@"audios"];
            dataD = mutDict;
        }else {
            NSMutableArray *array = [NSMutableArray arrayWithArray:[dict objectForKey:@"images"]];
            if (array.count > 0) {
                for (NSInteger i = 0; i < array.count -1; i++) {
                    for (NSInteger j = 0; j < array.count - 1; j++) {
                        NSString *str1 = [(NSDictionary *)array[j] objectForKey:@"oFileName"];
                        NSString *str2 = [(NSDictionary *)array[j+1] objectForKey:@"oFileName"];
                        NSInteger num1 = [[self getNumberFromStr:str1] integerValue];
                        NSInteger num2 = [[self getNumberFromStr:str2] integerValue];
                        if (num1 > num2) {
                            [array exchangeObjectAtIndex:j withObjectAtIndex:j+1];
                        }
                    }
                }
                [dict setValue:array forKey:@"images"];
            }
            
            if (self.videoImageUlrArr.count > 0) {
                [dict setValue:self.videoImageUlrArr forKey:@"images"];
            }
            dataD = dict;
        }
        
        NSString *label = nil;
        if (self.isShortVideo) {
            label = [NSString stringWithFormat:@"%ld",self.currentLableIndex + 1];
        }
        
        [g_server addMessage:_remark.text type:dataType data:dataD flag:3 visible:_visible lookArray:_userIdArray coor:_coor location:_locStr remindArray:_remindArray lable:label isAllowComment:self.notReplyBtn.selected toView:self];
    }
    if([aDownload.action isEqualToString:act_MsgAdd]){
        if (self.block) {
            self.block();
        }
        [g_App showAlert:Localized(@"JXAlert_SendOK")];
        
        [self hideKeyboard];
        if (self.urlShare.length > 0) {
            [self.view removeFromSuperview];
        }else {
            [self actionQuit];
        }
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    if([aDownload.action isEqualToString:act_UploadFile]){
        if (self.isVideoFirstUpload) {
            self.isVideoFirstUpload = NO;
        }
    }
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    if([aDownload.action isEqualToString:act_UploadFile]){
        if (self.isVideoFirstUpload) {
            self.isVideoFirstUpload = NO;
        }
    }
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start:Localized(@"JX_SendNow")];
}

- (void)lableBtnAction:(UIButton *)button {
    JXSelectorVC *vc = [[JXSelectorVC alloc] init];
    vc.title = Localized(@"JX_SelectionLabel");
    vc.array = @[Localized(@"JX_Food"),Localized(@"JX_Attractions"),Localized(@"JX_Culture"),Localized(@"JX_HaveFun"),Localized(@"JX_Hotel"),Localized(@"JX_Shopping"),Localized(@"JX_Movement"),Localized(@"OTHER"),];
    //    vc.array = @[@"简体中文", @"繁體中文(香港)", @"English",@"Bahasa Melayu",@"ภาษาไทย"];
    vc.selectIndex = _currentLableIndex;
    vc.selectorDelegate = self;
    //    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)selector:(JXSelectorVC *)selector selectorAction:(NSInteger)selectIndex {
    
    self.currentLableIndex = selectIndex;
    self.lableLabel.text = selector.array[selectIndex];

}

-(void)locBtnAction:(UIButton *)button{
    _locationVC = [JXLocationVC alloc];
    _locationVC.isSend = YES;
    _locationVC.locationType = JXLocationTypeCurrentLocation;
    _locationVC.delegate  = self;
    _locationVC.didSelect = @selector(onSelLocation:);
    _locationVC.isCircleCome = YES;
    _locationVC = [_locationVC init];
    _locationVC.isAddWindow = YES;
    [g_navigation.navigationView addSubview:_locationVC.view];
    
//    [g_navigation pushViewController:_locationVC animated:YES];
}
-(void)whoCanSeeBtnAction:(UIButton *)button{
    _whoVC = [[WhoCanSeeViewController alloc] init];
    _whoVC.visibelDelegate = self;
    _whoVC.type = _visible;
    _whoVC.selLabelsArray = self.selLabelsArray.count > 0 ? self.selLabelsArray : [NSMutableArray array];
    _whoVC.mailListUserArray = self.mailListUserArray.count > 0 ? self.mailListUserArray : [NSMutableArray array];
    _whoVC.isAddWindow = YES;
    [g_navigation.navigationView addSubview:_whoVC.view];
//    [g_navigation pushViewController:whoVC animated:YES];
}
-(void)remindWhoBtnAction:(UIButton *)button{
    _selVC = [[JXSelectFriendsVC alloc] init];
    _selVC.delegate = self;
    _selVC.didSelect = @selector(selRemindDelegate:);
    if (_visible == MsgVisible_see) {
        _selVC.type = JXSelUserTypeCustomArray;
        _selVC.array = [_userArray mutableCopy];
    }else if (_visible == MsgVisible_nonSee) {
        _selVC.type = JXSelUserTypeDisAble;
        NSMutableSet * set = [NSMutableSet set];
        [set addObjectsFromArray:_userIdArray];
        _selVC.disableSet = set;
    }else {
        _selVC.type = JXSelUserTypeSelFriends;
        NSMutableSet * set = [NSMutableSet set];
        [set addObjectsFromArray:_remindArray];
        _selVC.existSet = set;
    }
    
    _selVC.isAddWindow = YES;
    [g_navigation.navigationView addSubview:_selVC.view];
//    [g_navigation pushViewController:selVC animated:YES];
}

- (void)clickReplyBanBtn  {
//    _checkbox.checked = !_checkbox.checked;
    _notReplyBtn.selected = !_notReplyBtn.selected;
}

-(void)selRemindDelegate:(JXSelectFriendsVC*)vc{
    NSArray * indexArr = [vc.set allObjects];
    NSMutableArray * adduserArr = [NSMutableArray array];
    NSMutableArray * userNameArr = [NSMutableArray array];
    for (NSNumber * index in indexArr) {
        JXUserObject * selUser;
        if ([index intValue] / 1000000 == 9) {
            selUser = vc.searchArray[[index intValue] % 9000000-1];
        }else{
            selUser = [[vc.letterResultArr objectAtIndex:[index intValue] / 100000-1] objectAtIndex:[index intValue] % 100000-1];
        }
        [adduserArr addObject:selUser.userId];
        [userNameArr addObject:selUser.userNickname];
    }
    _remindArray = [NSArray arrayWithArray:adduserArr];
    _remindNameArray = [NSArray arrayWithArray:userNameArr];
    if (_remindNameArray.count > 0) {
        _remindLabel.text = [_remindNameArray componentsJoinedByString:@","];
    }
}

-(void)seeVisibel:(int)visibel userArray:(NSArray *)userArray selLabelsArray:(NSMutableArray *)selLabelsArray mailListArray:(NSMutableArray *)mailListArray{
    _visible = visibel+1;
    _selLabelsArray = selLabelsArray;
    _mailListUserArray = mailListArray;
    _visibleLabel.text = _visibelArray[visibel];
    
    if (_visible == 3 || _visible == 4) {
        NSMutableArray * uArray = [NSMutableArray array];
        NSMutableArray * userIdArray = [NSMutableArray array];
        for (JXUserObject * selUser in userArray) {
            JXUserObject *user = [[JXUserObject sharedInstance] getUserById:selUser.userId];
            [uArray addObject:user];
            [userIdArray addObject:selUser.userId];
        }

        _userIdArray = userIdArray;
        _userArray = uArray;
    }
    
    switch (_visible) {
        case 1:
        case 3:
        case 4:
            _remindWhoBtn.enabled = YES;
            _remindArray = [NSArray array];
            _remindLabel.text = @"";
            break;
        case 2:
            _remindWhoBtn.enabled = NO;
            _remindArray = nil;
            _remindLabel.text = @"";
            break;
        
        default:
            break;
    }
    
//    if (visibel == 3 || visibel ==4) {
//        NSMutableArray * nameArray = [NSMutableArray array];
//        for (JXUserObject * selUser in userArray) {
//            [nameArray addObject:selUser.userNickname];
//        }
//        if (nameArray.count > 0) {
//            NSString * nameStr = [nameArray componentsJoinedByString:@","];
//            _visibleLabel.text = nameStr;
//        }
//    }
    
    
//    NSMutableArray * nameArray = [NSMutableArray array];
//    for (JXUserObject * selUser in userArray) {
//        [nameArray addObject:selUser.userNickname];
//    }
    
}


#pragma mark - 点击发布调用的方法
-(void)actionSave{

    [audioPlayer stop];
    audioPlayer = nil;
    [videoPlayer stop];
    videoPlayer = nil;
    
    [self hideKeyboard];
    /**
     取消单独文字发送
     */
//    if(self.dataType == weibo_dataType_text){
//        if ([_remark.text isEqualToString:Localized(@"addMsgVC_Mind")]||[_remark.text isEqual:@""]) {
//            [g_App showAlert:Localized(@"JXAlert_InputSomething")];
//            return;
//        }
//        [g_server addMessage:_remark.text type:dataType data:nil flag:3 visible:_visible lookArray:_userIdArray coor:_coor location:_locStr remindArray:_remindArray toView:self];
//    }
//    else
    if(self.dataType == weibo_dataType_image) {
        if (_images.count <=0 && _remark.text.length <= 0) {
            [g_App showAlert:Localized(@"JXAlert_InputSomething")];
            return;
        }
        else if(_images.count <= 0 && _remark.text.length > 0) {

            if ([_remark.text isEqualToString:Localized(@"addMsgVC_Mind")]) {
                [g_App showAlert:Localized(@"JXAlert_InputSomething")];
                return;
            }
            
            NSString *str = [_remark.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (str.length <= 0) {
                
                [g_App showAlert:Localized(@"JX_PleaseEnterValidContent")];
                return;
            }

            [g_server addMessage:_remark.text type:1 data:nil flag:3 visible:_visible lookArray:_userIdArray coor:_coor location:_locStr remindArray:_remindArray lable:nil isAllowComment:self.notReplyBtn.selected toView:self];
            
        }else if(_images.count > 0){
            if ([_remark.text isEqualToString:Localized(@"addMsgVC_Mind")]){
                _remark.text = @"";
            }
            [g_server uploadFile:_images audio:audioFile video:videoFile file:fileFile type:self.dataType+1 validTime:@"-1" timeLen:_timeLen toView:self gifDic:self.gifDataDic];
        }
    }
    else if (self.dataType == weibo_dataType_share) {
        NSDictionary *dict = @{
                               @"sdkUrl" : self.shareUr,
                               @"sdkIcon" : self.shareIcon,
                               @"sdkTitle": self.shareTitle
                               };
        [g_server addMessage:_remark.text type:dataType data:dict flag:3 visible:_visible lookArray:_userIdArray coor:_coor location:_locStr remindArray:_remindArray lable:nil isAllowComment:self.notReplyBtn.selected toView:self];
    }
    else{
        if (_images.count <= 0 && audioFile.length <= 0 && videoFile.length <= 0 && fileFile.length <= 0) {
            [g_App showAlert:Localized(@"JX_AddFile")];
            return;
        }
        if ([_remark.text isEqualToString:Localized(@"addMsgVC_Mind")]){
            _remark.text = @"";
        }
        [g_server uploadFile:_images audio:audioFile video:videoFile file:fileFile type:self.dataType+1 validTime:@"-1" timeLen:_timeLen toView:self gifDic:self.gifDataDic];
    }

}

- (BOOL) hideKeyboard {
    [_remark resignFirstResponder];
    [self.view endEditing:YES];
    return YES;
}

-(void)onAddVideo{
    [self hideKeyboard];
    
    JXActionSheetVC *actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:@[Localized(@"JXMyMediaVC_LoationMedia"),Localized(@"JX_RecordVideo")]];
    actionVC.delegate = self;
    actionVC.tag = 2457;
    [self presentViewController:actionVC animated:NO completion:nil];
    
//    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
//    {
//        [g_server showMsg:Localized(@"JX_CanNotopenCenmar")];
//        return;
//    }
//    if ([[JXMediaObject sharedInstance] fetch].count <= 0) {
//
//        myMediaVC* vc = [[myMediaVC alloc]init];
//        vc.delegate = self;
//        vc.didSelect = @selector(onSelMedia:);
////        [g_window addSubview:vc.view];
//        [g_navigation pushViewController:vc animated:YES];
//        [vc onAddVideo];
//    }else {
//        myMediaVC* vc = [[myMediaVC alloc]init];
//        vc.delegate = self;
//        vc.didSelect = @selector(onSelMedia:);
////        [g_window addSubview:vc.view];
//        [g_navigation pushViewController:vc animated:YES];
//    }
    

//    recordVideoViewController * videoRecordVC = [recordVideoViewController alloc];
//    videoRecordVC.maxTime = 30;
//    videoRecordVC.isReciprocal = NO;
//    videoRecordVC.delegate = self;
//    videoRecordVC.didRecord = @selector(newVideo:);
//    [videoRecordVC init];
//    [g_window addSubview:videoRecordVC.view];
}

#pragma mark - 发送视频
- (void)photosViewController:(UIViewController *)viewController media:(JXMediaObject *)media {
    [_images removeAllObjects];
    media.userId = g_server.myself.userId;
    media.isVideo = [NSNumber numberWithBool:YES];
    [media insert];
    
    NSString* file = media.fileName;
    UIImage *image = [FileInfo getFirstImageFromVideo:file];
    videoFile = [file copy];
//    file = [NSString stringWithFormat:@"%@.jpg",[file stringByDeletingPathExtension]];
//    [_images addObject:[UIImage imageWithContentsOfFile:file]];
    [_images addObject:image];
    
//    double integer = [FileInfo getVideoTimeFromVideo:videoFile];
//    NSInteger num = 0;
//    double interval;
//    if (integer < 16) {
//        interval = integer/16;
//        num = 15;
//    }else if (integer >= 16 && integer <= 32){
//        interval = 1;
//        num = ceil(integer) - 1;
//    }else{
//        interval = integer/32;
//        num = 31;
//    }
//    
//    for (int i = 0; i< num; i++) {
//        UIImage *image = [FileInfo getImagesFromVideo:videoFile withTimeInterval:interval*(i+1)];
//        if (image) {
//            [_images addObject:image];
//        }
//    }
    JXSelectCoverVC *vc = [[JXSelectCoverVC alloc] initWithVideo:videoFile];
    vc.delegate = self;
    [g_navigation pushViewController:vc animated:YES];
    
    [self showVideos];
    
}

- (void)touchAtlasButtonReturnCover:(UIImage *)img{
    _iv.image = img;
    [self saveImgCover:img];
}
- (void)selectImage:(UIImage *)img toView:(JXSelectCoverVC *)view{
    _iv.image = img;
    [self saveImgCover:img];
    
}

-(void)onSelMedia:(JXMediaObject*)p{
// 
//    p.userId = g_server.myself.userId;
//    p.isVideo = [NSNumber numberWithBool:YES];
////    [p insert];
//
//    NSString* file = p.fileName;
//    videoFile = [file copy];
//    file = [NSString stringWithFormat:@"%@.jpg",[file stringByDeletingPathExtension]];
//    [_images addObject:[UIImage imageWithContentsOfFile:file]];
//    [self showVideos];
//    
}

-(void)onAddFile{
    [self hideKeyboard];
    
    JXMyFile* vc = [[JXMyFile alloc]init];
    vc.delegate = self;
    vc.didSelect = @selector(onSelFile:);
    [g_navigation pushViewController:vc animated:YES];
}
-(void)onSelFile:(NSString*)file{
    //发送文件，file仅仅包含文件在本地的地址
    
    fileFile = [file copy];
//    file = [NSString stringWithFormat:@"%@.jpg",[file stringByDeletingPathExtension]];
//    [_images addObject:[UIImage imageWithContentsOfFile:file]];
    [self showFiles];
}

-(void)onAddAudio{
    [self hideKeyboard];
//    recordAudioVC* vc = [[recordAudioVC alloc]init];
//    vc.delegate = self;
//    vc.didRecord = @selector(newAudio:);
//    [g_window addSubview:vc.view];

//    [self stopAllPlayer];
    //跳转音频录制界面
    JXAudioRecorderViewController * audioRecordVC = [[JXAudioRecorderViewController alloc] init];
    audioRecordVC.delegate = self;
    audioRecordVC.maxTime = 60;
//    [g_window addSubview:audioRecordVC.view];
    [g_navigation pushViewController:audioRecordVC animated:YES];
    

}

//音频录制返回
#pragma mark JXaudioRecorder delegate
-(void)JXaudioRecorderDidFinish:(NSString *)filePath TimeLen:(int)timenlen{
//    _editingType = @"audio";
//    _voiceTimeLen = timenlen;
    //上传
//    [_wait start:@"正在上传音频"];
//    [g_server uploadFile:filePath toView:self];
    
//    NSString* file = sender.outputFileName;
    
    JXMediaObject* p = [[JXMediaObject alloc]init];
    p.userId = g_server.myself.userId;
    p.fileName = filePath;
    p.isVideo = [NSNumber numberWithBool:NO];
    p.timeLen = [NSNumber numberWithInt:timenlen];
//    [p insert];
    //    [p release];
    self.timeLen = timenlen;
    audioFile = [filePath copy];
    [self showAudios];
    filePath = nil;
}




-(void)newVideo:(recordVideoViewController *)sender;
{
    if( ![[NSFileManager defaultManager] fileExistsAtPath:sender.outputFileName] )
        return;
    NSString* file = sender.outputFileName;

    JXMediaObject* p = [[JXMediaObject alloc]init];
    p.userId = g_server.myself.userId;
    p.fileName = file;
    p.isVideo = [NSNumber numberWithBool:YES];
    p.timeLen = [NSNumber numberWithInt:sender.timeLen];
//    [p insert];
//    [p release];
    
    videoFile = [file copy];
    file = [NSString stringWithFormat:@"%@.jpg",[file stringByDeletingPathExtension]];
    [_images addObject:[UIImage imageWithContentsOfFile:file]];
    [self showVideos];
    file = nil;
}


-(void)onSelLocation:(JXMapData*)location{
    
    _coor = (CLLocationCoordinate2D){[location.latitude doubleValue],[location.longitude doubleValue]};
    
    if (location.title.length > 0) {
        _locStr = [NSString stringWithFormat:@"%@ %@",location.title,location.subtitle];
    }else{
        _locStr = location.subtitle;
    }
//    _locLabel.text = _locStr;
    [self.locBtn setTitle:_locStr forState:UIControlStateSelected];
    self.locBtn.selected = YES;
}

//-(void)newAudio:(recordAudioVC *)sender
//{
//    if( ![[NSFileManager defaultManager] fileExistsAtPath:sender.outputFileName] )
//        return;
//    NSString* file = sender.outputFileName;
//
//    JXMediaObject* p = [[JXMediaObject alloc]init];
//    p.userId = g_server.myself.userId;
//    p.fileName = file;
//    p.isVideo = [NSNumber numberWithBool:NO];
//    p.timeLen = [NSNumber numberWithInt:sender.timeLen];
//    [p insert];
////    [p release];
//
//    audioFile = [file copy];
//    [self showAudios];
//    file = nil;
//}

-(UIButton*)createButton:(NSString*)title icon:(NSString*)icon action:(SEL)action parent:(UIView*)parent{
    UIButton* btn = [UIFactory createButtonWithImage:icon
                           highlight:nil
                              target:self
                            selector:action];
    btn.titleEdgeInsets = UIEdgeInsetsMake(45, -60, 0, 0);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:HEXCOLOR(0x999999) forState:UIControlStateNormal];
    btn.titleLabel.font = g_factory.font10;
    [parent addSubview:btn];
    return btn;
}

-(void)onDelVideo{
    videoFile = nil;
    [self showVideos];
}

-(void)onDelAudio{
    audioFile = nil;
    [self showAudios];
}

-(void)actionQuit{
    [super actionQuit];
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelect])
        [self.delegate performSelectorOnMainThread:self.didSelect withObject:self waitUntilDone:NO];
}

@end
