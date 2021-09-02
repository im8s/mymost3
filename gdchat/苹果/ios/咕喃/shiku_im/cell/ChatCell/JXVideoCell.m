//
//  JXVideoCell.m
//  shiku_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXVideoCell.h"
#import <AVFoundation/AVFoundation.h>
#import "JXVideoPlayer.h"
#import "SCGIFImageView.h"


@implementation JXVideoCell

- (void)dealloc{
    NSLog(@"JXVideoCell.dealloc");
    //[g_notify removeObserver:self name:kCellReadDelNotification object:self.msg];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)creatUI{
    
    //预览图
    _chatImage=[[JXImageView alloc]initWithFrame:CGRectZero];
    [_chatImage setBackgroundColor:[UIColor clearColor]];
//    _chatImage.layer.cornerRadius = 6;
//    _chatImage.layer.masksToBounds = YES;
    [self.bubbleBg addSubview:_chatImage];
//    [_chatImage release];
    
    _pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    _pauseBtn.center = CGPointMake(_chatImage.frame.size.width/2,_chatImage.frame.size.height/2);
    [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"playvideo"] forState:UIControlStateNormal];
//    [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"pausevideo"] forState:UIControlStateSelected];
    [_pauseBtn addTarget:self action:@selector(showTheVideo) forControlEvents:UIControlEventTouchUpInside];
    [_chatImage addSubview:_pauseBtn];
    
    _videoProgress = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    _videoProgress.center = CGPointMake(_chatImage.frame.size.width/2,_chatImage.frame.size.height/2);
    _videoProgress.layer.masksToBounds = YES;
    _videoProgress.layer.borderWidth = 2.f;
    _videoProgress.layer.borderColor = [UIColor whiteColor].CGColor;
    _videoProgress.layer.cornerRadius = _videoProgress.frame.size.width/2;
    _videoProgress.text = @"0%";
    _videoProgress.hidden = YES;
    _videoProgress.font = SYSFONT(13);
    _videoProgress.textAlignment = NSTextAlignmentCenter;
    _videoProgress.textColor = [UIColor whiteColor];
    [_chatImage addSubview:_videoProgress];

}

- (void)showTheVideo {    
    if (self.videoDelegate && [self.videoDelegate respondsToSelector:@selector(showVideoPlayerWithTag:)]) {
        [self didVideoOpen];
        [self.videoDelegate showVideoPlayerWithTag:self.indexTag];
    }
//    _player= [[JXVideoPlayer alloc] initWithParent:g_App.window];
//    _player.didVideoOpen = @selector(didVideoOpen);
//    _player.didVideoPlayEnd = @selector(didVideoPlayEnd);
//    _player.delegate = self;
//    [self setUIFrame];
//    [_player switch];
}


- (void)didVideoOpen{
    [self.msg sendAlreadyReadMsg];
    if (self.msg.isGroup) {
        self.msg.isRead = [NSNumber numberWithInt:1];
        [self.msg updateIsRead:nil msgId:self.msg.messageId];
    }
    if ([self.msg.isReadDel boolValue] && !self.msg.isMySend) {
        [self timeGo:self.msg.fileName];
    }
    if(!self.msg.isMySend){
        [self drawIsRead];
    }
}


-(void)setCellData{
    [super setCellData];
    [self setUIFrame];
}


- (void)setUIFrame{
    float n = imageItemHeight;
    
/*location_x没有值的情况下，会卡：
    _chatImage.image = [FileInfo getFirstImageFromVideo:self.msg.content];
    int w = _chatImage.image.size.width;
    int h = _chatImage.image.size.height;
*/
    float w = [self.msg.location_x intValue] * kScreenWidthScale;
    float h = [self.msg.location_y intValue];

    if (w <= 0 || h <= 0){
        w = n;
        h = n;
    }
    
    float k = w/(h/n);
    if(k+INSETS > JX_SCREEN_WIDTH - 80)//如果超出屏幕宽度
        k = JX_SCREEN_WIDTH-n-INSETS;
    
    if (self.msg.isMySend) {
        self.bubbleBg.frame=CGRectMake(CGRectGetMinX(self.headImage.frame)-k-CHAT_WIDTH_ICON-2, INSETS, INSETS+k, n+INSETS-4);
        _chatImage.frame = self.bubbleBg.bounds;
    }else{
        self.bubbleBg.frame=CGRectMake(CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON, INSETS2(self.msg.isGroup), k+INSETS, n+INSETS-4);
        _chatImage.frame = self.bubbleBg.bounds;
    }
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    _pauseBtn.center = CGPointMake(_chatImage.frame.size.width/2,_chatImage.frame.size.height/2);
    _videoProgress.center = CGPointMake(_chatImage.frame.size.width/2,_chatImage.frame.size.height/2);
    if (!_chatImage.image) {
        _chatImage.image = [UIImage imageNamed:@"Default_Gray"];
    }
    if([self.msg.content rangeOfString:@"http://"].location == NSNotFound && [self.msg.content rangeOfString:@"https://"].location == NSNotFound) {
        [FileInfo getFirstImageFromVideo:self.msg.fileName imageView:_chatImage];
    }else {
        [FileInfo getFirstImageFromVideo:self.msg.content imageView:_chatImage];
    }
//    _player.parent = g_App.window;
//    if(self.msg.isMySend && isFileExist(self.msg.fileName))
//        _player.videoFile = self.msg.fileName;
//    else
//        _player.videoFile = self.msg.content;
    
    //音视频点击事件
    _chatImage.didTouch = @selector(doNotThing);
    
    [self setMaskLayer:_chatImage];
    
    if(!self.msg.isMySend)
        [self drawIsRead];
    
}

- (void)updateFileLoadProgress {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.fileDict isEqualToString:self.msg.messageId]) {
            _videoProgress.hidden = NO;
            _pauseBtn.hidden = YES;
            // UI更新代码
            if (self.loadProgress >= 1) {
                _videoProgress.text = [NSString stringWithFormat:@"99%@",@"%"];
            }else {
                _videoProgress.text = [NSString stringWithFormat:@"%d%@",(int)(self.loadProgress*100),@"%"];
            }
//            _videoProgress.hidden = self.loadProgress >= 1;
//            _pauseBtn.hidden = self.loadProgress < 1;
        }
    });

}

- (void)sendMessageToUser {
    _videoProgress.text = [NSString stringWithFormat:@"100%@",@"%"];
    _pauseBtn.hidden = NO;
    _videoProgress.hidden = YES;
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

- (void)timeGo:(NSString *)fileName{
    if (_oldFileName) {
        if ([_oldFileName isEqualToString:fileName]) {
            return;
        }else{
            self.oldFileName = fileName;
        }
    }else{
        self.oldFileName = fileName;
        
    }
    if ([self.msg.timeLen intValue] <= 0) {
        self.msg.timeLen = [NSNumber numberWithLong:_player.player.timeLen];
    }
    //阅后即焚通知
    [g_notify postNotificationName:kCellReadDelNotification object:self.msg];
    if ([self.msg.isReadDel boolValue] && self.msg.isMySend) {
        [self deleteMsg];
    }
    
}
- (void)deleteMsg{
//    //播放删除动画
//    NSString *path = [[NSBundle mainBundle]pathForResource:@"delete.gif" ofType:nil];
//    //NSData *gifData = [NSData dataWithContentsOfFile:path];
//    CGRect webFrame;
//    if(self.msg.isMySend){
//        CGFloat webW = webWidth-self.bubbleBg.frame.size.width;
//        webFrame = CGRectMake(self.bubbleBg.frame.origin.x - webW, self.bubbleBg.frame.origin.y, webWidth, self.frame.size.height - self.bubbleBg.frame.origin.y);
//    }else{
//        webFrame = CGRectMake(self.bubbleBg.frame.origin.x, self.bubbleBg.frame.origin.y, webWidth, self.frame.size.height - self.bubbleBg.frame.origin.y);
//    }
//    SCGIFImageView *gifImageView = [[SCGIFImageView alloc]initWithGIFFile:path];
//    gifImageView.frame = webFrame;
//    gifImageView.userInteractionEnabled = NO;
//    //UIWebView *webView = [[UIWebView alloc]initWithFrame:webFrame];
//    
//    //webView.scalesPageToFit = YES;
//    //[webView loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
//    //webView.backgroundColor = [UIColor clearColor];
//    //webView.opaque = NO;
//    self.bubbleBg.hidden = YES;
//    [self addSubview:gifImageView];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [gifImageView removeFromSuperview];
//        [self.delegate performSelectorOnMainThread:self.readDele withObject:self.msg waitUntilDone:NO];
//        self.bubbleBg.hidden = NO;
//        self.oldFileName = nil;
//    });
//    if (!_isEndVideo) {
//        return;
//    }
    if (![self.msg.isReadDel boolValue]) {
        return;
    }
    //渐变隐藏
    [UIView animateWithDuration:2.f animations:^{
        self.bubbleBg.alpha = 0;
        self.chatImage.alpha = 0;
        self.readImage.alpha = 0;
        self.burnImage.alpha = 0;
    } completion:^(BOOL finished) {
        //动画结束后删除UI
        if(self.delegate != nil && [self.delegate respondsToSelector:self.readDele]){
            [self.delegate performSelectorOnMainThread:self.readDele withObject:self.msg waitUntilDone:NO];
        }
        self.bubbleBg.alpha = 1;
        self.chatImage.alpha = 1;
        self.readImage.alpha = 1;
        self.burnImage.alpha = 1;
        self.oldFileName = nil;
    }];
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

@end
