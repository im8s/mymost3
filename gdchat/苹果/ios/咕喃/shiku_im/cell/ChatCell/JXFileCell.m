//
//  JXFileCell.m
//  shiku_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXFileCell.h"
#import "JXMyFile.h"

@interface JXFileCell ()

@property (nonatomic, strong) UIImageView *fileImage;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation JXFileCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)creatUI{
    _imageBackground =[[UIImageView alloc]initWithFrame:CGRectZero];
    [_imageBackground setBackgroundColor:[UIColor clearColor]];
    _imageBackground.layer.cornerRadius = 6;
    _imageBackground.layer.masksToBounds = YES;
    [self.bubbleBg addSubview:_imageBackground];
//    [_imageBackground release];
    
    _fileImage = [[UIImageView alloc]init];
    _fileImage.frame = CGRectMake(15,15, 50, 50);
    _fileImage.userInteractionEnabled = NO;
    _fileImage.image = [UIImage imageNamed:@"im_file"];
    [_imageBackground addSubview:_fileImage];

    _fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_fileImage.frame) + 10,_fileImage.frame.origin.y, kChatCellMaxWidth  - CGRectGetMaxX(_fileImage.frame) - 20, 50)];
    _fileNameLabel.numberOfLines = 0;
    _fileNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _fileNameLabel.backgroundColor = [UIColor clearColor];
    _fileNameLabel.font = g_factory.font15;
    [_imageBackground addSubview:_fileNameLabel];
    
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = THE_LINE_COLOR;
    [_imageBackground addSubview:_lineView];
    
    _progressView = [[UIProgressView alloc] init];
    _progressView.progressTintColor = [UIColor greenColor];
    _progressView.progressViewStyle = UIProgressViewStyleDefault;
    _progressView.hidden = YES;
    [_imageBackground addSubview:_progressView];
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 30)];
    _title.text = Localized(@"JX_File");
    _title.font = SYSFONT(13);
    _title.textColor = [UIColor grayColor];
    [_imageBackground addSubview:_title];
    
    
//    [_fileNameLabel release];
}

-(void)setCellData{
    [super setCellData];
    int n = imageItemHeight;

    if(self.msg.isMySend)
    {
        self.bubbleBg.frame=CGRectMake(CGRectGetMinX(self.headImage.frame)-kChatCellMaxWidth-CHAT_WIDTH_ICON, INSETS, kChatCellMaxWidth, n+INSETS -4);
        _imageBackground.frame = self.bubbleBg.bounds;
        
        _imageBackground.image = [[UIImage imageNamed:@"chat_bubble_whrite_right_icon"]stretchableImageWithLeftCapWidth:stretch topCapHeight:stretch];
    }
    else
    {
        self.bubbleBg.frame=CGRectMake(CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON, INSETS2(self.msg.isGroup), kChatCellMaxWidth, n+INSETS -4);
        _imageBackground.frame = self.bubbleBg.bounds;
        
        _imageBackground.image = [[UIImage imageNamed:@"chat_bg_white"]stretchableImageWithLeftCapWidth:stretch topCapHeight:stretch];
    }
    
    _lineView.frame = CGRectMake(0, _imageBackground.frame.size.height - 30, _imageBackground.frame.size.width, LINE_WH);
    _progressView.frame = CGRectMake(2, _imageBackground.frame.size.height - 30, _imageBackground.frame.size.width-2, LINE_WH);
    _title.frame = CGRectMake(15, _imageBackground.frame.size.height - 30, 200, 30);
//    _fileNameLabel.frame = CGRectMake(_fileNameLabel.frame.origin.x, _fileNameLabel.frame.origin.y, _fileNameLabel.frame.size.width, _lineView.frame.origin.y - _fileNameLabel.frame.origin.y - 10);
    
    
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    
    [self setMaskLayer:_imageBackground];
    
    if (self.msg.fileName.length > 0) {
        _fileNameLabel.text = [NSString stringWithFormat:@"%@",[self.msg.fileName lastPathComponent]];
    }
    
//    if (JX_SCREEN_WIDTH >320) {
//        if (self.msg.content.length > 0) {
//           _fileNameLabel.text = [NSString stringWithFormat:@"  %@:%@...",Localized(@"JX_File"),[[self.msg.content lastPathComponent] substringToIndex:15]];
//        }
//    }else{
//        if (self.msg.content.length > 0) {
//            _fileNameLabel.text = [NSString stringWithFormat:@"  %@:%@...",Localized(@"JX_File"),[[self.msg.content lastPathComponent] substringToIndex:9]];
//        }
//    }
    
    if(!self.msg.isMySend)
        [self drawIsRead];
}


//未读红点
-(void)drawIsRead{
    if (self.msg.isMySend) {
        return;
    }
    if([self.msg.isRead boolValue]){
        self.readImage.hidden = YES;
    }
    else{
        if(self.readImage==nil){
            self.readImage=[[UIButton alloc]init];
            [self.contentView addSubview:self.readImage];
            //            [self.readImage release];
        }
        [self.readImage setImage:[UIImage imageNamed:@"new_tips"] forState:UIControlStateNormal];
        self.readImage.hidden = NO;
        self.readImage.frame = CGRectMake(self.bubbleBg.frame.origin.x+self.bubbleBg.frame.size.width+7, self.bubbleBg.frame.origin.y+13, 8, 8);
        self.readImage.center = CGPointMake(self.readImage.center.x, self.bubbleBg.center.y);
        
    }
}

- (void)updateFileLoadProgress {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.fileDict isEqualToString:self.msg.messageId]) {
            _progressView.hidden = NO;
            // UI更新代码
            if (self.loadProgress >= 1) {
                [_progressView setProgress:0.99 animated:YES];
            }
            else {
                [_progressView setProgress:self.loadProgress animated:YES];
            }
//            _progressView.hidden = self.loadProgress >= 1;
        }
    });
}

- (void)sendMessageToUser {
    [_progressView setProgress:1 animated:YES];
    _progressView.hidden = YES;
}


+ (float)getChatCellHeight:(JXMessageObject *)msg {
    
    if ([msg.chatMsgHeight floatValue] > 1) {
        return [msg.chatMsgHeight floatValue];
    }
    
    float n = 0;
    if (msg.isGroup && !msg.isMySend) {
        if (msg.isShowTime) {
            n = imageItemHeight+20*2 + 40;
        }else {
            n = imageItemHeight+20*2;
        }
        n += GROUP_CHAT_INSET;
    }else {
        if (msg.isShowTime) {
            n = imageItemHeight+10*2 + 40;
        }else {
            n = imageItemHeight+10*2;
        }
    }
    
    msg.chatMsgHeight = [NSString stringWithFormat:@"%f",n];
    if (!msg.isNotUpdateHeight) {
        [msg updateChatMsgHeight];
    }
    return n;
}

-(void)didTouch:(UIButton*)button{

//    JXMyFile* vc = [[JXMyFile alloc]init];
//    [g_window addSubview:vc.view];
    
    
    [self.msg sendAlreadyReadMsg];
    if (self.msg.isGroup) {
        self.msg.isRead = [NSNumber numberWithInt:1];
        [self.msg updateIsRead:nil msgId:self.msg.messageId];
    }
    if(!self.msg.isMySend){
        self.msg.isRead = [NSNumber numberWithInt:1];
        [self drawIsRead];
    }
    
    [g_notify postNotificationName:kCellSystemFileNotifaction object:self.msg];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
