//
//  JXFileDetailViewController.m
//  shiku_im
//
//  Created by 1 on 17/7/7.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXFileDetailViewController.h"
#import "JXShareFileObject.h"
#import "MCDownloader.h"
#import "webpageVC.h"
#import "UIImageView+FileType.h"

@interface JXFileDetailViewController ()<UITextViewDelegate>

@property (strong, nonatomic) UIImageView * typeView;
@property (strong, nonatomic) UILabel * fileTitleLabel;
@property (strong, nonatomic) UITextView * textView;
@property (strong, nonatomic) UIButton * downloadBtn;
@property (strong, nonatomic) UIView * downloadingView;

@property (strong, nonatomic) UILabel * receivedLabel;
@property (strong, nonatomic) UIProgressView * progressView;
@property (strong, nonatomic) UIButton * stopButton;

@property (assign, atomic) BOOL dalay;
@end

@implementation JXFileDetailViewController


-(instancetype)init{
    self = [super init];
    if (self) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _shareFile.fileName;
    [self createHeadAndFoot];
    [self customView];
    [self setViewDataWith:0 expectedSize:0 speed:0];
   
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     MCDownloadReceipt *receipt = [[MCDownloader sharedDownloader] downloadReceiptForURLString:_shareFile.url];
    if (receipt.state == MCDownloadStateDownloading) {
        [self downloadBtnAction];
    }
}
-(void)customView{
    if(!_typeView){
        _typeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, 60, 55)];
        _typeView.center = CGPointMake(self.tableBody.center.x, _typeView.center.y);
        _typeView.layer.cornerRadius = 3;
        _typeView.layer.masksToBounds = YES;
        _typeView.backgroundColor = [UIColor redColor];
        [_typeView setFileType:[_shareFile.type integerValue]];
        [self.tableBody addSubview:_typeView];
    }
    
    if(!_fileTitleLabel){
        _fileTitleLabel = [UIFactory createLabelWith:CGRectZero text:_shareFile.fileName font:g_factory.font16 textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor]];
        _fileTitleLabel.frame = CGRectMake(15, CGRectGetMaxY(_typeView.frame)+15, JX_SCREEN_WIDTH - 30, 25);
        _fileTitleLabel.center = CGPointMake(self.tableBody.center.x, _fileTitleLabel.center.y);
        _fileTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self.tableBody addSubview:_fileTitleLabel];
    }
    
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.frame = CGRectMake(0, CGRectGetMaxY(_fileTitleLabel.frame), 150, 25);
        _textView.center = CGPointMake(self.tableBody.center.x, _textView.center.y);
        _textView.delegate = self;
        [self.tableBody addSubview:_textView];
        [self protocolIsSelect];
    }
    
    
    
    if(!_downloadBtn){
        _downloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _downloadBtn.backgroundColor = THEMECOLOR;
        _downloadBtn.layer.masksToBounds = YES;
        _downloadBtn.layer.cornerRadius = 7.f;
        _downloadBtn.titleLabel.font = SYSFONT(16);
        [_downloadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_downloadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        _downloadBtn.frame = CGRectMake(0, CGRectGetMaxY(_fileTitleLabel.frame) +45, 200, 30);
        _downloadBtn.center = CGPointMake(self.tableBody.center.x, _downloadBtn.center.y);
        [self.tableBody addSubview:_downloadBtn];
        [_downloadBtn addTarget:self action:@selector(downloadBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!_downloadingView) {
        _downloadingView = [[UIView alloc] init];
        _downloadingView.backgroundColor = [UIColor clearColor];
        _downloadingView.frame = CGRectMake(30, CGRectGetMaxY(_fileTitleLabel.frame) +85, self_width-30*2, 40);
        _downloadingView.center = CGPointMake(self.tableBody.center.x, _downloadingView.center.y);
        [self.tableBody addSubview:_downloadingView];
        
        if(!_receivedLabel){
            _receivedLabel = [[UILabel alloc] init];
            _receivedLabel.font = g_factory.font13;
            _receivedLabel.textAlignment = NSTextAlignmentCenter;
            _receivedLabel.frame = CGRectMake(0, 0, CGRectGetWidth(_downloadingView.frame), 17);
            [_downloadingView addSubview:_receivedLabel];
        }
        
        if (!_progressView) {
            _progressView = [[UIProgressView alloc] init];
            _progressView.frame = CGRectMake(0, 20, CGRectGetWidth(_downloadingView.frame)-30, 5);
            _progressView.progress = 0;
            _progressView.progressTintColor = [UIColor greenColor];
            _progressView.trackTintColor = [UIColor lightGrayColor];
            [_downloadingView addSubview:_progressView];
            //        progressImage
            //        trackImage
        }
        
        if (!_stopButton) {
            _stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _stopButton.frame = CGRectMake(CGRectGetMaxX(_progressView.frame)+3, 0, 25, 25);
            _stopButton.center = CGPointMake(_stopButton.center.x, _progressView.center.y);
            [_stopButton setBackgroundImage:[UIImage imageNamed:@"stopDownload"] forState:UIControlStateNormal];
            [_downloadingView addSubview:_stopButton];
            [_stopButton addTarget:self action:@selector(stopDownloadFile) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
}

-(void)setViewDataWith:(NSInteger)receivedSize expectedSize:(NSInteger)expectedSize speed:(NSInteger)speed{
    
    MCDownloadReceipt *receipt = [[MCDownloader sharedDownloader] downloadReceiptForURLString:_shareFile.url];
    if (receipt.state == MCDownloadStateNone) {
        _downloadBtn.hidden = NO;
        _downloadingView.hidden = YES;
        NSString * downStr = nil;
        if ([_shareFile.size longValue]/1000.0/1000 >= 1) {
            downStr = [NSString stringWithFormat:@"%@(%.02fMB)",Localized(@"JX_Download"),[_shareFile.size longValue]/1000.0/1000];
        }else{
            downStr = [NSString stringWithFormat:@"%@(%.02fKB)",Localized(@"JX_Download"),[_shareFile.size longValue]/1000.0];
        }
        
        [_downloadBtn setTitle:downStr forState:UIControlStateNormal];
        [_downloadBtn setTitle:downStr forState:UIControlStateHighlighted];
    }else if (receipt.state == MCDownloadStateWillResume){
        _downloadBtn.hidden = YES;
        _downloadingView.hidden = NO;
        
        NSString * progressStr = nil;
        if ([_shareFile.size longValue]/1024.0/1024 >= 1) {
            progressStr = [NSString stringWithFormat:@"%@...(%.02fMB / %.02fMB)",Localized(@"JX_Downloading"),receipt.progress.completedUnitCount/1024.0/1024,receipt.progress.totalUnitCount/1024.0/1024];
        }else{
            progressStr = [NSString stringWithFormat:@"%@...(%.02fKB / %.02fKB)",Localized(@"JX_Downloading"),receipt.progress.completedUnitCount/1024.0,receipt.progress.totalUnitCount/1024.0];
        }
//        float progress = receivedSize / [_shareFile.size doubleValue];
//        [_progressView setProgress:progress animated:YES];
        [_progressView setProgress:receipt.progress.fractionCompleted animated:YES];

        _receivedLabel.text = progressStr;

        
    }else if (receipt.state == MCDownloadStateDownloading){
        _downloadBtn.hidden = YES;
        _downloadingView.hidden = NO;
        
        NSString * progressStr = nil;
        if ([_shareFile.size longValue]/1024.0/1024 >= 1) {
            progressStr = [NSString stringWithFormat:@"%@...(%.02fMB / %.02fMB)",Localized(@"JX_Downloading"),receipt.progress.completedUnitCount/1024.0/1024,receipt.progress.totalUnitCount/1024.0/1024];
        }else{
            progressStr = [NSString stringWithFormat:@"%@...(%.02fKB / %.02fKB)",Localized(@"JX_Downloading"),receipt.progress.completedUnitCount/1024.0,receipt.progress.totalUnitCount/1024.0];
        }
//        float progress = receivedSize / [_shareFile.size doubleValue];
        [_progressView setProgress:receipt.progress.fractionCompleted animated:YES];
        
        _receivedLabel.text = progressStr;
        
    }else if (receipt.state == MCDownloadStateCompleted) {
        _downloadBtn.hidden = NO;
        _downloadingView.hidden = YES;
        [_downloadBtn setTitle:Localized(@"JX_Open") forState:UIControlStateNormal];
        [_downloadBtn setTitle:Localized(@"JX_Open") forState:UIControlStateHighlighted];
        [_downloadBtn removeTarget:self action:@selector(downloadBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_downloadBtn addTarget:self action:@selector(openFileAction) forControlEvents:UIControlEventTouchUpInside];
        
    }else if (receipt.state == MCDownloadStateFailed) {
        _downloadBtn.hidden = NO;
        _downloadingView.hidden = YES;
        [_downloadBtn setTitle:Localized(@"JX_ReDownload") forState:UIControlStateNormal];
        [_downloadBtn setTitle:Localized(@"JX_ReDownload") forState:UIControlStateHighlighted];
        [_downloadBtn removeTarget:self action:@selector(downloadBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_downloadBtn addTarget:self action:@selector(retryDownload) forControlEvents:UIControlEventTouchUpInside];
    }else if (receipt.state == MCDownloadStateSuspened) {
        
    }
    
}


-(void)downloadBtnAction{
    [[MCDownloader sharedDownloader] downloadDataWithURL:[NSURL URLWithString:_shareFile.url] progress:^(NSInteger receivedSize, NSInteger expectedSize, NSInteger speed, NSURL * _Nullable targetURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setViewDataWith:receivedSize expectedSize:expectedSize speed:speed];
            
        });
    } completed:^(MCDownloadReceipt *receipt, NSError * _Nullable error, BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setViewDataWith:0 expectedSize:0 speed:0];
            if (!error && finished) {
                [self openFileAction];
                
                NSData *data = [NSData dataWithContentsOfFile:receipt.filePath];
                NSString *filePath = [NSString stringWithFormat:@"%@%@",myTempFilePath,[receipt.filePath lastPathComponent]];
                NSFileManager *manager = [NSFileManager defaultManager];
                BOOL isExist = [manager fileExistsAtPath:filePath];
                if (!isExist) {
                    BOOL isSave = [data writeToFile:filePath atomically:YES];
                    NSLog(@"isSave");
                }
                
            }else{
                [g_App showAlert:Localized(@"DOWNLOAD_FAILED")];
            }
 
        });
        
    }];
}

-(void)openFileAction{
    if (_dalay){
        return;
    }
    _dalay = YES;
    [self performSelector:@selector(delayClick) withObject:nil afterDelay:0.4];
    MCDownloadReceipt *receipt = [[MCDownloader sharedDownloader] downloadReceiptForURLString:_shareFile.url];
    
    webpageVC * webVC = [webpageVC alloc];
    webVC.url = receipt.filePath;
    webVC.shareUrl = _shareFile.url;
    webVC.titleString = _shareFile.fileName;
    webVC = [webVC init];
    [g_navigation.navigationView addSubview:webVC.view];
//    [g_navigation pushViewController:webVC animated:YES];
}
-(void)stopDownloadFile{

    MCDownloadReceipt *receipt = [[MCDownloader sharedDownloader] downloadReceiptForURLString:_shareFile.url];
    [[MCDownloader sharedDownloader] cancel:receipt completed:^{
        [self setViewDataWith:0 expectedSize:0 speed:0];
    }];
}
-(void)delayClick{
    if (_dalay) {
        _dalay = NO;
    }
}

-(void)retryDownload{
    MCDownloadReceipt *receipt = [[MCDownloader sharedDownloader] downloadReceiptForURLString:_shareFile.url];
    [[MCDownloader sharedDownloader] remove:receipt completed:^{
        [self downloadBtnAction];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)protocolIsSelect {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:Localized(@"JXFile_fileBeforeOnline")];
    [attributedString addAttribute:NSLinkAttributeName
                             value:_shareFile.url
                             range:[[attributedString string] rangeOfString:Localized(@"JXFile_online")]];

    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:[[attributedString string] rangeOfString:Localized(@"JXFile_fileBefore")]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, attributedString.length)];
    _textView.attributedText = attributedString;
    _textView.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor blueColor],
                                     NSUnderlineColorAttributeName: [UIColor lightGrayColor],
                                     NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};
    
    //    _textView.delegate = self;
    _textView.editable = NO;        //必须禁止输入，否则点击将弹出输入键盘
    _textView.scrollEnabled = NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL absoluteString] isEqualToString:_shareFile.url]) {
        webpageVC * webVC = [webpageVC alloc];
        webVC.url = _shareFile.url;
        webVC.isSend = YES;
        webVC.titleString = _shareFile.fileName;
        webVC = [webVC init];
        [g_navigation.navigationView addSubview:webVC.view];
//        [g_navigation pushViewController:webVC animated:YES];
        return NO;
    }
    return YES;
}

@end
