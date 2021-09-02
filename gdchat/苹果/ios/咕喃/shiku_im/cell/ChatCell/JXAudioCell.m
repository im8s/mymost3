//
//  JXAudioCell.m
//  shiku_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXAudioCell.h"

@implementation JXAudioCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)creatUI{
    _audioPlayer = [[JXAudioPlayer alloc]initWithParent:self.bubbleBg frame:CGRectNull isLeft:YES];
    _audioPlayer.isOpenProximityMonitoring = YES;
    _audioPlayer.isChatAudio = YES;
    _audioPlayer.delegate = self;
    _audioPlayer.didAudioPlayEnd = @selector(didAudioPlayEnd);
    _audioPlayer.didAudioPlayBegin = @selector(didAudioPlayBegin);
    _audioPlayer.didAudioOpen = @selector(didAudioOpen);
}

-(void)dealloc{
    //[g_notify removeObserver:self name:kCellReadDelNotification object:self.msg];
    NSLog(@"JXAudioCell.dealloc");
//    [_audioPlayer release];
//    [super dealloc];
    _audioPlayer = nil;
}
- (void)didAudioOpen{
    [self.msg sendAlreadyReadMsg];
    if (self.msg.isGroup) {
        self.msg.isRead = [NSNumber numberWithInt:1];
        [self.msg updateIsRead:nil msgId:self.msg.messageId];
    }
    if ([self.msg.isReadDel boolValue] && !self.msg.isMySend) {
        [self timeGo:self.msg.fileName];
    }
}
- (void)setCellData{
    [super setCellData];
    int w = (JX_SCREEN_WIDTH-HEAD_SIZE-INSETS*2-70)/30;
    w = 70+w*[self.msg.timeLen intValue];
    if(w<70)
        w = 70;
    if(w>200)
        w = 200;
    
    
    if(self.msg.isMySend){
        self.bubbleBg.frame=CGRectMake(CGRectGetMinX(self.headImage.frame)-w-CHAT_WIDTH_ICON+2, INSETS, w, 37);
    }
    else{
        self.bubbleBg.frame=CGRectMake(CGRectGetMaxX(self.headImage.frame)+CHAT_WIDTH_ICON, INSETS2(self.msg.isGroup), w, 37);
    }
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    
    if(self.msg.isMySend && isFileExist(self.msg.fileName))
       _audioPlayer.audioFile = self.msg.fileName;
    else
        _audioPlayer.audioFile = self.msg.content;
    _audioPlayer.timeLen = [self.msg.timeLen intValue];
    _audioPlayer.isLeft  = !self.msg.isMySend;
    _audioPlayer.frame = self.bubbleBg.bounds;
    if(self.msg.isMySend)
        _audioPlayer.timeLenView.textColor = [UIColor darkGrayColor];
    else
        _audioPlayer.timeLenView.textColor = [UIColor grayColor];
    if(!self.msg.isMySend)
        [self drawIsRead];
}

//语音红点
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
        
        if (self.msg.isGroup && self.msg.showRead) {
            self.readImage.frame = CGRectMake(self.bubbleBg.frame.origin.x+self.bubbleBg.frame.size.width+13, self.bubbleBg.frame.origin.y+22, 8, 8);
        }
        else if ([self.msg.isReadDel boolValue]) {
            self.readImage.frame = CGRectMake(self.bubbleBg.frame.origin.x+self.bubbleBg.frame.size.width+9, self.bubbleBg.frame.origin.y+3, 8, 8);
        }
        else {
            self.readImage.frame = CGRectMake(self.bubbleBg.frame.origin.x+self.bubbleBg.frame.size.width+7, self.bubbleBg.frame.origin.y+13, 8, 8);
            self.readImage.center = CGPointMake(self.readImage.center.x, self.bubbleBg.center.y);
        }

    }
}

-(void)didAudioPlayBegin{
    if(!self.msg.isMySend){
        self.msg.isRead = [NSNumber numberWithInt:1];
        [self drawIsRead];
    }
}

-(void)didAudioPlayEnd{
    [g_notify postNotificationName:kCellVoiceStartNotifaction object:self];
    
}

#pragma mark----开始计时
- (void)timeGo:(NSString *)fileName{
    //防止删除操作重复调用
    if (_oldFileName) {
        if ([_oldFileName isEqualToString:fileName]) {
            return;
        }else{
            self.oldFileName = fileName;
        }
    }else{
        self.oldFileName = fileName;
        
    }
    
    //阅后即焚图片通知
    [g_notify postNotificationName:kCellReadDelNotification object:self.msg];
    
    //if (self.msg.isReadDel) {
    //计时删除
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self.msg.timeLen intValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(self.delegate != nil && [self.delegate respondsToSelector:self.readDele]){
                [self deleteMsg];
                
                
            }
        });
    //}
}
#pragma mark----阅后即焚
- (void)deleteMsg{
    //播放删除动画
//    NSString *path = [[NSBundle mainBundle]pathForResource:@"delete.gif" ofType:nil];
//    NSData *gifData = [NSData dataWithContentsOfFile:path];
//    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(self.bubbleBg.frame.origin.x, self.bubbleBg.frame.origin.y, self.frame.size.width/3, 37)];
//    
//    webView.scalesPageToFit = YES;
//    [webView loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
//    webView.backgroundColor = [UIColor clearColor];
//    webView.opaque = NO;
//    self.bubbleBg.hidden = YES;
//    [self addSubview:webView];
    [UIView animateWithDuration:2 animations:^{
        self.bubbleBg.alpha = 0;
        self.burnImage.alpha = 0;
    }];//渐变隐藏
    //动画结束后删除UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //[webView removeFromSuperview];
        //self.bubbleBg.hidden = NO;
        [self.delegate performSelectorOnMainThread:self.readDele withObject:self.msg waitUntilDone:NO];
        self.bubbleBg.alpha = 1;
        self.burnImage.alpha = 1;
        self.oldFileName = nil;
    });
}

+ (float)getChatCellHeight:(JXMessageObject *)msg {
    
    if ([msg.chatMsgHeight floatValue] > 1) {
        return [msg.chatMsgHeight floatValue];
    }
    
    float n = 0;
    if (msg.isGroup && !msg.isMySend) {
        if (msg.isShowTime) {
            n = 65 + 40;
        }else {
            n = 65;
        }
        n += GROUP_CHAT_INSET;
    }else {
        if (msg.isShowTime) {
            n = 55 + 40;
        }else {
            n = 55;
        }
    }
    
    msg.chatMsgHeight = [NSString stringWithFormat:@"%f",n];
    if (!msg.isNotUpdateHeight) {
        [msg updateChatMsgHeight];
    }
    return n;
}

@end
