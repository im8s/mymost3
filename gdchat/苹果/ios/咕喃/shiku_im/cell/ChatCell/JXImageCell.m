//
//  JXImageCell.m
//  shiku_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXImageCell.h"
#import "ImageBrowserViewController.h"
#import "SCGIFImageView.h"


@implementation JXImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dealloc{
    //[g_notify removeObserver:self name:kCellReadDelNotification object:self.msg];
}
-(void)creatUI{
    _chatImage=[[FLAnimatedImageView alloc]initWithFrame:CGRectZero];
    [_chatImage setBackgroundColor:[UIColor clearColor]];
//    _chatImage.layer.cornerRadius = 6;
//    _chatImage.layer.masksToBounds = YES;
    self.bubbleBg.backgroundColor = [UIColor clearColor];
    [self.bubbleBg addSubview:_chatImage];
//    [_chatImage release];
    
    _imageProgress = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    _imageProgress.center = CGPointMake(_chatImage.frame.size.width/2,_chatImage.frame.size.height/2);
    _imageProgress.layer.masksToBounds = YES;
    _imageProgress.layer.borderWidth = 2.f;
    _imageProgress.layer.borderColor = [UIColor whiteColor].CGColor;
    _imageProgress.layer.cornerRadius = _imageProgress.frame.size.width/2;
    _imageProgress.text = @"0%";
    _imageProgress.hidden = YES;
    _imageProgress.font = SYSFONT(13);
    _imageProgress.textAlignment = NSTextAlignmentCenter;
    _imageProgress.textColor = [UIColor whiteColor];
    [_chatImage addSubview:_imageProgress];

}

- (void)updateFileLoadProgress {
    dispatch_async(dispatch_get_main_queue(), ^{
        // UI更新代码
            if ([self.fileDict isEqualToString:self.msg.messageId]) {
                _imageProgress.hidden = NO;
                if (self.loadProgress >= 1) {
                    _imageProgress.text = [NSString stringWithFormat:@"99%@",@"%"];
                }else {
                    _imageProgress.text = [NSString stringWithFormat:@"%d%@",(int)(self.loadProgress*100),@"%"];
                }
            }
//            if (self.loadProgress >= 1) {
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    _imageProgress.hidden = YES;
//                });
//            }
    });
    
}

- (void)sendMessageToUser {
    _imageProgress.text = [NSString stringWithFormat:@"100%@",@"%"];
    _imageProgress.hidden = YES;
}


-(void)setCellData{
    [super setCellData];
    [self setUIFrame];
    [g_notify addObserver:self selector:@selector(imageDidDismiss:) name:kImageDidTouchEndNotification object:nil];
}

- (void)setUIFrame{
    
    NSURL* url;
    if(self.msg.isMySend && isFileExist(self.msg.fileName))
        url = [NSURL fileURLWithPath:self.msg.fileName];
    else
        url = [NSURL URLWithString:self.msg.content];
    
    [self setCellSubViewFrame:CGSizeMake([self.msg.location_x floatValue], [self.msg.location_y floatValue])];
    [self setBackgroundImage];
    
    // 加载前清除一次，防止cell重用
    self.chatImage.image = nil;
    
    if (!self.chatImage.image) {
        self.chatImage.image = [UIImage imageNamed:@"Default_Gray"];
    }
    if ([url.absoluteString rangeOfString:@".gif"].location != NSNotFound) {
        
        [self loadAnimatedImageWithURL:url completion:^(FLAnimatedImage *animatedImage) {
            self.chatImage.animatedImage = animatedImage;
            if (_chatImage.frame.size.width <= 0 || _chatImage.frame.size.height <= 0) {
                
                [self setCellSubViewFrame:_chatImage.image.size];
                [self setBackgroundImage];
            }
//            self.wait.hidden = YES;
//            [self.wait stopAnimating];
        }];
        
    }else {
        
//        self.wait.hidden = NO;
//        [self.wait startAnimating];
        
        [_chatImage sd_setImageWithURL:url placeholderImage:self.chatImage.image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            _chatImage.image = image;
            if (_chatImage.frame.size.width <= 0 || _chatImage.frame.size.height <= 0) {
                
                [self setCellSubViewFrame:_chatImage.image.size];
                [self setBackgroundImage];
            }
//            self.wait.hidden = YES;
//            [self.wait stopAnimating];
        }];
        
    }
    if ([self.msg.isReadDel boolValue]) {
        _chatImage.alpha = 0.1;
    }else {
        _chatImage.alpha = 1;
    }
    
}

- (void)loadAnimatedImageWithURL:(NSURL *const)url completion:(void (^)(FLAnimatedImage *animatedImage))completion
{
    NSString *const filename = url.lastPathComponent;
    NSString *const diskPath = [dataFilePath stringByAppendingPathComponent:filename];
    
    NSData * __block animatedImageData = [[NSFileManager defaultManager] contentsAtPath:diskPath];
    FLAnimatedImage * __block animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:animatedImageData];
    
    if (animatedImage) {
        if (completion) {
            completion(animatedImage);
        }
    } else {
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            animatedImageData = data;
            animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:animatedImageData];
            if (animatedImage) {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(animatedImage);
                    });
                }
                [data writeToFile:diskPath atomically:YES];
            }
        }] resume];
    }
}

- (void) setCellSubViewFrame:(CGSize)size {
    
    int n = imageItemHeight;
    //后设置imageview大小
    float w = size.width * kScreenWidthScale;
    float h = size.height;
    
    if (w <= 0 || h <= 0){
        w = n;
        h = n;
    }
    
    float k = w/(h/n);
    if(k+INSETS > JX_SCREEN_WIDTH - 100)//如果超出屏幕宽度
        k = JX_SCREEN_WIDTH-n-INSETS;
    
    if(self.msg.isMySend)
    {
        if(w != 0 && h != 0){
            self.bubbleBg.frame=CGRectMake(CGRectGetMinX(self.headImage.frame)-k-CHAT_WIDTH_ICON-INSETS, INSETS, INSETS+k, n+INSETS-4);
            //                _chatImage.frame = CGRectMake(INSETS*0.2 , INSETS*0.3, k, n);
            _chatImage.frame = self.bubbleBg.bounds;
        }
    }
    else
    {
        self.bubbleBg.frame=CGRectMake(CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON, INSETS2(self.msg.isGroup), k+INSETS-5, n+INSETS -4);
        //            self.chatImage.frame = CGRectMake(INSETS*0.5, INSETS*0.3, k, n);
        _chatImage.frame = self.bubbleBg.bounds;
        //            _chatImage.contentMode = UIViewContentModeScaleAspectFit;
        
        /*
         //            如果超出屏幕宽度
         if(self.bubbleBg.frame.size.width > (JX_SCREEN_WIDTH - 80)){
         self.bubbleBg.frame = CGRectMake(self.bubbleBg.frame.origin.x, self.bubbleBg.frame.origin.y, JX_SCREEN_WIDTH - n, self.bubbleBg.frame.size.height);
         _chatImage.frame = CGRectMake(_chatImage.frame.origin.x, _chatImage.frame.origin.y, JX_SCREEN_WIDTH - n, _chatImage.frame.size.height);
         }
         */
    }
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    _imageProgress.center = CGPointMake(_chatImage.frame.size.width/2,_chatImage.frame.size.height/2);

    [self setMaskLayer:_chatImage];
}

-(void)didTouch:(UIButton*)button{
    NSLog(@"imageCell ------");
    [g_notify postNotificationName:kCellImageNotifaction object:@(self.indexNum)];
    
    if ([self.msg.isReadDel boolValue] && !self.msg.isMySend) {
        
        [self.msg sendAlreadyReadMsg];
        //阅后即焚图片通知
        [g_notify postNotificationName:kCellReadDelNotification object:self.msg];
        
//        [self.delegate performSelectorOnMainThread:self.readDele withObject:self.msg waitUntilDone:NO];
        _chatImage.alpha = 1;
    }
//    ImageBrowserViewController *imageVC = [ImageBrowserViewController sharedInstance];
//    imageVC.delegate = self;
//    imageVC.seeOK = @selector(imageDidDismiss);
    
}

- (void)timeGo:(JXMessageObject *)msg {
    if (self.msg.isMySend && [self.msg.isReadDel boolValue]) {
        [self deleteReadMsg];
    }
}


- (void)deleteReadMsg {
    if (![self.msg.isReadDel boolValue]) {
        return;
    }
    if(self.delegate != nil && [self.delegate respondsToSelector:self.readDele]){
        [UIView animateWithDuration:2.f animations:^{
            _chatImage.alpha = 0.0f;
            self.readImage.alpha = 0.f;
            self.burnImage.alpha = 0;
        } completion:^(BOOL finished) {
            [self.delegate performSelectorOnMainThread:self.readDele withObject:self.msg waitUntilDone:NO];
            _chatImage.alpha = 1.0f;
            self.readImage.alpha = 1.f;
            self.burnImage.alpha = 1.f;
        }];
    }
}



- (void)imageDidDismiss:(NSNotification *)notification{
    
    JXMessageObject *msg = notification.object;
    
    if ([msg.messageId isEqualToString:self.msg.messageId]) {
        if (![self.msg.isReadDel boolValue]) {
            return;
        }
        if (self.msg.isMySend) {
            if (!self.isRemove) {
                return;
            }
        }
//        if ([self.msg.isReadDel boolValue] && !self.msg.isMySend && self.isRemove) {
            if(self.delegate != nil && [self.delegate respondsToSelector:self.readDele]){
                //删除动画
//                NSString *path = [[NSBundle mainBundle]pathForResource:@"delete.gif" ofType:nil];
//                //NSData *gifData = [NSData dataWithContentsOfFile:path];
//                CGRect webFrame;
//                if(self.msg.isMySend){
//                    CGFloat webW = webWidth-self.bubbleBg.frame.size.width;
//                     webFrame = CGRectMake(self.bubbleBg.frame.origin.x - webW, self.bubbleBg.frame.origin.y, webWidth, self.frame.size.height - self.bubbleBg.frame.origin.y);
//                }else{
//                    webFrame = CGRectMake(self.bubbleBg.frame.origin.x, self.bubbleBg.frame.origin.y, webWidth, self.frame.size.height - self.bubbleBg.frame.origin.y);
//                }
//                SCGIFImageView *gifImageView = [[SCGIFImageView alloc]initWithGIFFile:path];
//                gifImageView.frame = webFrame;
//                gifImageView.userInteractionEnabled = NO;
//                //UIWebView *webView = [[UIWebView alloc]initWithFrame:webFrame];
//                //webView.scalesPageToFit = YES;
//                //[webView loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
//                //webView.backgroundColor = [UIColor clearColor];
//                //webView.opaque = NO;
//                self.bubbleBg.hidden = YES;
//                [self addSubview:gifImageView];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [gifImageView removeFromSuperview];
//                [UIView animateWithDuration:2.f animations:^{
//                    _chatImage.alpha = 0.0f;
//                } completion:^(BOOL finished) {
//                    [self.delegate performSelectorOnMainThread:self.readDele withObject:self.msg waitUntilDone:NO];
//                    _chatImage.alpha = 1.0f;
//                }];
//                    self.bubbleBg.hidden = NO;
//                });
                
            }
        }
//    }
    
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(int)getImageWidth{
    return [self.msg.location_x intValue];
}

-(int)getImageHeight{
    return [self.msg.location_y intValue];
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
