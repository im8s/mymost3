//
//  JXLocationCell.m
//  shiku_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXLocationCell.h"
#import "JXLocationVC.h"
//#import "JXClickSendedLocationVC.h"


@implementation JXLocationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)creatUI{
    _imageBackground =[[UIImageView alloc]initWithFrame:CGRectZero];
    [_imageBackground setBackgroundColor:[UIColor whiteColor]];
    _imageBackground.layer.cornerRadius = 6;
    _imageBackground.layer.masksToBounds = YES;
    [self.bubbleBg addSubview:_imageBackground];

    _mapImageView =[[UIImageView alloc]initWithFrame:CGRectZero];
    [_mapImageView setBackgroundColor:[UIColor clearColor]];
    //    _mapImageView.layer.cornerRadius = 6;
    _mapImageView.layer.masksToBounds = YES;
    _mapImageView.contentMode = UIViewContentModeScaleToFill;
    [_imageBackground addSubview:_mapImageView];
    
    //
    _addressLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _addressLabel.numberOfLines = 1;
    _addressLabel.textAlignment = NSTextAlignmentCenter;
    _addressLabel.font = g_factory.font15;
    [_imageBackground addSubview:_addressLabel];

}

-(void)setCellData{
    [super setCellData];
    int n = imageItemHeight;
    if(self.msg.isMySend)
    {
        self.bubbleBg.frame=CGRectMake(CGRectGetMinX(self.headImage.frame)- kChatCellMaxWidth - CHAT_WIDTH_ICON, INSETS, kChatCellMaxWidth, n+INSETS -4);
        _imageBackground.frame = self.bubbleBg.bounds;
        
    }
    else
    {
        self.bubbleBg.frame=CGRectMake(CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON, INSETS2(self.msg.isGroup), kChatCellMaxWidth, n+INSETS -4);
        _imageBackground.frame = self.bubbleBg.bounds;
    }
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    
    [self setMaskLayer:_imageBackground];
    
    _mapImageView.frame = CGRectMake(0, 0, CGRectGetWidth(_imageBackground.frame), n-25);
    _addressLabel.frame = CGRectMake(5,n-25, CGRectGetWidth(_imageBackground.frame)-5*2, 25);
    
    NSURL* url;
    if(self.msg.isMySend && isFileExist(self.msg.fileName)){
        url = [NSURL fileURLWithPath:self.msg.fileName];
//        _imageBackground.image = [UIImage imageWithContentsOfFile:self.msg.fileName];
    }else{
        url = [NSURL URLWithString:self.msg.content];
//        [_imageBackground sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"发送位置.png"]];
    }
    if (url) {
        [_mapImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"发送位置.png"]];
//        [_mapImageView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            _mapImageView.image = image;
//        }];
    }else{
//        _imageBackground.image = [UIImage imageNamed:@"发送位置.png"];
    }
    if ([self.msg.objectId length]>0) {
        NSString * address = self.msg.objectId;
//        NSRange addRange = [address rangeOfString:Localized(@"selectProvinceVC_City")];
//        if (addRange.length) {
//            NSString * showAddress = [address substringFromIndex:(addRange.location+addRange.length)];
            _addressLabel.text = address;
//        }
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
    
    [g_notify postNotificationName:kCellLocationNotifaction object:self.msg];

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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
