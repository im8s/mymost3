//
//  JXShareFileTableViewCell.m
//  shiku_im
//
//  Created by 1 on 17/7/6.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXShareFileTableViewCell.h"
#import "JXShareFileObject.h"
#import "MCDownloader.h"
#import "UIImageView+FileType.h"

@interface JXShareFileTableViewCell ()

@property (nonatomic, strong) MCDownloadReceipt * receipt;
@end

@implementation JXShareFileTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self customView];
    }
    return self;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    
//    [_receipt.progress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) context:nil];
//    [_receipt.progress removeObserver:self forKeyPath:NSStringFromSelector(@selector(state)) context:nil];
}
-(void)customView{
    if(!_typeView){
        _typeView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 45, 45)];
        _typeView.layer.cornerRadius = 3;
        _typeView.layer.masksToBounds = YES;
//        _typeView.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:_typeView];
    }
    
    if(!_fileTitleLabel){
        _fileTitleLabel = [UIFactory createLabelWith:CGRectZero text:@"--.--" font:g_factory.font15 textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor]];
        _fileTitleLabel.frame = CGRectMake(CGRectGetMaxX(_typeView.frame) +5, CGRectGetMinY(_typeView.frame), 150, 25);
        _fileTitleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_fileTitleLabel];
    }
    
    if(!_sizeLabel){
        _sizeLabel = [UIFactory createLabelWith:CGRectZero text:@"--kb" font:g_factory.font10 textColor:[UIColor lightGrayColor] backgroundColor:[UIColor clearColor]];
        _sizeLabel.frame = CGRectMake(CGRectGetMinX(_fileTitleLabel.frame), CGRectGetMaxY(_typeView.frame)-15, 50, 15);
        _sizeLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_sizeLabel];
    }
    
    
    if(!_fromLabel){
        _fromLabel = [UIFactory createLabelWith:CGRectZero text:Localized(@"JXFile_from") font:g_factory.font10 textColor:[UIColor lightGrayColor] backgroundColor:[UIColor clearColor]];
        _fromLabel.frame = CGRectMake(CGRectGetMaxX(_sizeLabel.frame)+3, CGRectGetMinY(_sizeLabel.frame), 24, 15);
        [self.contentView addSubview:_fromLabel];
    }
    
    
    if(!_fromUserLabel){
        _fromUserLabel = [UIFactory createLabelWith:CGRectZero text:@"--" font:g_factory.font11 textColor:[UIColor blueColor] backgroundColor:[UIColor clearColor]];
        _fromUserLabel.frame = CGRectMake(CGRectGetMaxX(_fromLabel.frame), CGRectGetMinY(_sizeLabel.frame), 55, 15);
        [self.contentView addSubview:_fromUserLabel];
    }
    
    if(!_timeLabel){
        _timeLabel = [UIFactory createLabelWith:CGRectZero text:@"00-00" font:g_factory.font9 textColor:[UIColor lightGrayColor] backgroundColor:[UIColor clearColor]];
        _timeLabel.frame = CGRectMake(CGRectGetWidth(self.contentView.frame)-20-35, CGRectGetMinY(_typeView.frame), 35, 15);
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_timeLabel];
    }
    
    if(!_didDownView){
        _didDownView = [[UIImageView alloc] init];
        _didDownView.image = [UIImage imageNamed:@"finishDownload"];
//        _didDownView.backgroundColor = [UIColor greenColor];
        _didDownView.frame = CGRectMake(CGRectGetMaxX(_typeView.frame)-15, CGRectGetMaxY(_typeView.frame)-15, 15, 15);
        [self.contentView addSubview:_didDownView];
    }
    
    
    if(!_progressView){
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(CGRectGetMinX(_fileTitleLabel.frame), CGRectGetMaxY(_typeView.frame), CGRectGetWidth(_fileTitleLabel.frame), 2);
        _progressView.progressTintColor = [UIColor greenColor];
        _progressView.trackTintColor = [UIColor lightGrayColor];
        _progressView.progress = 0.0;
        [self.contentView addSubview:_progressView];
    }
    
    if(!_downloadStateBtn){
        _downloadStateBtn = [[UIButton alloc] init];
        _downloadStateBtn.frame = CGRectMake(0, 0, 21, 21);
        _downloadStateBtn.center = CGPointMake(_timeLabel.center.x, _typeView.center.y);
        [_downloadStateBtn setBackgroundImage:[UIImage imageNamed:@"pauseDownload"] forState:UIControlStateNormal];
        [_downloadStateBtn setBackgroundImage:[UIImage imageNamed:@"starDownload"] forState:UIControlStateSelected];
//        [_downloadStateBtn setBackgroundImage:[UIImage imageNamed:@"errorDownload"] forState:UIControlStateDisabled];
        [self.contentView addSubview:_downloadStateBtn];
        [_downloadStateBtn addTarget:self action:@selector(downStateAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

-(void)setShareFileListCellWith:(JXShareFileObject *)shareFileObjcet indexPath:(NSIndexPath *)indexPath{
    [_typeView setFileType:[shareFileObjcet.type integerValue]];
    _fileTitleLabel.text = shareFileObjcet.fileName;
    _fileTitleLabel.frame = CGRectMake(CGRectGetMaxX(_typeView.frame) +5, CGRectGetMinY(_typeView.frame), CGRectGetWidth(self.contentView.frame)-20-35-20-CGRectGetMaxX(_typeView.frame) -5, 25);
    NSString * downStr = nil;
    if ([shareFileObjcet.size longValue]/1024.0/1024 >= 1) {
        downStr = [NSString stringWithFormat:@"%.02fMB",[shareFileObjcet.size longValue]/1024.0/1024];
    }else{
        downStr = [NSString stringWithFormat:@"%.02fKB",[shareFileObjcet.size longValue]/1024.0];
    }
    _sizeLabel.text = downStr;
    _fromLabel.text = Localized(@"JXFile_from");
    _fromUserLabel.text = shareFileObjcet.createUserName;
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd"];

    _timeLabel.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[shareFileObjcet.time doubleValue]]];
    _timeLabel.frame = CGRectMake(CGRectGetWidth(self.contentView.frame)-20-35, CGRectGetMinY(_typeView.frame), 35, 15);
    _didDownView.hidden = YES;
    _progressView.hidden = YES;
    _downloadStateBtn.hidden = YES;
    
    
    self.shareFile = shareFileObjcet;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setShareFile:(JXShareFileObject *)shareFile{
    _shareFile = shareFile;
    
    _receipt = [[MCDownloader sharedDownloader] downloadReceiptForURLString:shareFile.url];
    self.progressView.progress = 0;
    [self.progressView setProgress:_receipt.progress.fractionCompleted animated:YES];
    
    
//    [_receipt.progress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
//    [_receipt addObserver:self forKeyPath:NSStringFromSelector(@selector(state)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    if (_receipt.state == MCDownloadStateDownloading || _receipt.state == MCDownloadStateWillResume) {
        //正在下载
        _didDownView.hidden = YES;
        _progressView.hidden = NO;
        _downloadStateBtn.hidden = NO;
        _downloadStateBtn.selected = NO;
    }else if (_receipt.state == MCDownloadStateCompleted) {
        //下载完成
        _didDownView.hidden = NO;
        _progressView.hidden = YES;
        _downloadStateBtn.hidden = YES;
    }else{
        //没有开始下载
        
    }
    
    
    __weak typeof(_receipt) weakReeceeipt = _receipt;
    __weak typeof(self) weakSelf = self;
    _receipt.downloaderProgressBlock = ^(NSInteger receivedSize, NSInteger expectedSize,  NSInteger speed, NSURL * _Nullable targetURL) {
//        __strong typeof(weakReeceeipt) strongReceipt = weakReeceeipt;
        if ([targetURL.absoluteString isEqualToString:weakSelf.shareFile.url]) {
//            [weakSelf.downloadStateBtn setTitle:@"pause" forState:UIControlStateNormal];
//            weakSelf.progressView.progress = (receivedSize/1024.0/1024) / (expectedSize/1024.0/1024);
            weakSelf.didDownView.hidden = YES;
            weakSelf.progressView.hidden = NO;
            weakSelf.downloadStateBtn.hidden = NO;
            [weakSelf.progressView setProgress:weakReeceeipt.progress.fractionCompleted animated:YES];
        }
    };
    
    _receipt.downloaderCompletedBlock = ^(MCDownloadReceipt * _Nullable receipt, NSError * _Nullable error, BOOL finished) {
        if (error) {
            
        }else{
            weakSelf.didDownView.hidden = NO;
            weakSelf.progressView.hidden = YES;
            weakSelf.downloadStateBtn.hidden = YES;
        }
    };
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
//    if ([keyPath isEqualToString:NSStringFromSelector(@selector(fractionCompleted))]) {
//        [_progressView setProgress:[change[@"new"] doubleValue] animated:YES];
//    }else if ([keyPath isEqualToString:NSStringFromSelector(@selector(state))]){
//        if ([change[@"new"] integerValue] == MCDownloadStateDownloading) {
//            _didDownView.hidden = YES;
//            _progressView.hidden = NO;
//            _downloadStateBtn.hidden = NO;
//        }
//        if ([change[@"new"] integerValue] == MCDownloadStateCompleted) {
//            _didDownView.hidden = NO;
//            _progressView.hidden = YES;
//            _downloadStateBtn.hidden = YES;
//        }
//    }
    
}
-(void)downloadBtnAction{
    [[MCDownloader sharedDownloader] downloadDataWithURL:[NSURL URLWithString:_shareFile.url] progress:^(NSInteger receivedSize, NSInteger expectedSize, NSInteger speed, NSURL * _Nullable targetURL) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self setViewDataWith:receivedSize expectedSize:expectedSize speed:speed];
//            
//        });
    } completed:^(MCDownloadReceipt *receipt, NSError * _Nullable error, BOOL finished) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self setViewDataWith:0 expectedSize:0 speed:0];
//            if (!error && finished) {
//                [self openFileAction];
//            }else{
//                [g_App showAlert:error.description];
//            }
//            
//        });
        
    }];
}
-(void)stopDownloadFile{
    
//    MCDownloadReceipt *receipt = [[MCDownloader sharedDownloader] downloadReceiptForURLString:_shareFile.url];
    [[MCDownloader sharedDownloader] cancel:_receipt completed:^{
        
    }];
}

-(void)retryDownload{
    MCDownloadReceipt *receipt = [[MCDownloader sharedDownloader] downloadReceiptForURLString:_shareFile.url];
    [[MCDownloader sharedDownloader] remove:receipt completed:^{
        [self downloadBtnAction];
    }];
}

-(void)downStateAction{
    if (_receipt.state == MCDownloadStateDownloading || _receipt.state == MCDownloadStateWillResume) {
        //正在下载
        [self stopDownloadFile];
        _downloadStateBtn.selected = YES;
    }else if (_receipt.state == MCDownloadStateCompleted) {
        //下载完成
        
    }else if (_receipt.state == MCDownloadStateFailed) {
        [_downloadStateBtn setBackgroundImage:[UIImage imageNamed:@"errorDownload"] forState:UIControlStateNormal];
        [self retryDownload];
    }else if (_receipt.state == MCDownloadStateNone) {
        [self downloadBtnAction];
        _downloadStateBtn.selected = NO;
        [_downloadStateBtn setBackgroundImage:[UIImage imageNamed:@"pauseDownload"] forState:UIControlStateNormal];
    }
}
@end
