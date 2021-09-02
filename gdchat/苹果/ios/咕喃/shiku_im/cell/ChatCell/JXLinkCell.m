//
//  JXLinkCell.m
//  shiku_im
//
//  Created by p on 2017/8/17.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXLinkCell.h"
#import "ImageResize.h"

@implementation JXLinkCell

-(void)creatUI{
    _imageBackground =[[UIImageView alloc]initWithFrame:CGRectZero];
    [_imageBackground setBackgroundColor:[UIColor whiteColor]];
    _imageBackground.layer.cornerRadius = 6;
    _imageBackground.layer.masksToBounds = YES;
    _imageBackground.clipsToBounds = YES;
    [self.bubbleBg addSubview:_imageBackground];
    
    _headImageView = [[UIImageView alloc]init];
    _headImageView.contentMode = UIViewContentModeScaleToFill;
    [_imageBackground addSubview:_headImageView];
    
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.font = g_factory.font15;
    _nameLabel.numberOfLines = 1;
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [_imageBackground addSubview:_nameLabel];
    
}

-(void)setCellData{
    [super setCellData];
    int n = imageItemHeight;
    if(self.msg.isMySend)
    {
        self.bubbleBg.frame=CGRectMake(CGRectGetMinX(self.headImage.frame)- kChatCellMaxWidth-CHAT_WIDTH_ICON, INSETS, kChatCellMaxWidth, n+INSETS -4);
        _imageBackground.frame = self.bubbleBg.bounds;
        
        _imageBackground.image = [[UIImage imageNamed:@"chat_bubble_whrite_right_icon"]stretchableImageWithLeftCapWidth:stretch topCapHeight:stretch];
    }
    else
    {
        self.bubbleBg.frame=CGRectMake(CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON, INSETS2(self.msg.isGroup), kChatCellMaxWidth, n+INSETS -4);
        _imageBackground.frame = self.bubbleBg.bounds;
        
        _imageBackground.image = [[UIImage imageNamed:@"chat_bg_white"]stretchableImageWithLeftCapWidth:stretch topCapHeight:stretch];
    }
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    
    [self setMaskLayer:_imageBackground];
    
    _headImageView.frame = CGRectMake(0, 0, CGRectGetWidth(_imageBackground.frame), n-25);
    _nameLabel.frame = CGRectMake(5,n-25, CGRectGetWidth(_imageBackground.frame)-5*2, 25);
    
    SBJsonParser * parser = [[SBJsonParser alloc] init] ;
    id content = [parser objectWithString:self.msg.content];
    if ([(NSDictionary *)content objectForKey:@"title"]) {
        _nameLabel.text = [NSString stringWithFormat:@"[%@] %@",Localized(@"JXLink"),[(NSDictionary *)content objectForKey:@"title"]];
    }
    NSString *imgStr = [(NSDictionary *)content objectForKey:@"img"];
    CGFloat fl = (_headImageView.frame.size.width/_headImageView.frame.size.height);
    if (imgStr.length > 0) {
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:imgStr] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            _headImageView.image = [ImageResize image:image fillSize:CGSizeMake((_headImageView.frame.size.height+200)*fl, _headImageView.frame.size.height+200)];
        }];

//        [_headImageView sd_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:[UIImage imageNamed:@"Default_Gray"] options:SDWebImageRetryFailed];
    }else {
        _headImageView.image = [UIImage imageNamed:@"Default_Gray"];
    }
    
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

-(void)didTouch:(UIButton*)button{
    
    [self.msg sendAlreadyReadMsg];
    if (self.msg.isGroup) {
        self.msg.isRead = [NSNumber numberWithInt:1];
        [self.msg updateIsRead:nil msgId:self.msg.messageId];
    }
    if(!self.msg.isMySend){
        [self drawIsRead];
    }
    
    [g_notify postNotificationName:kCellSystemLinkNotifaction object:self.msg];
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
