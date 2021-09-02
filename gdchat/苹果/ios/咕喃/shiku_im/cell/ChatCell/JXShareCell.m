//
//  JXShareCell.m
//  shiku_im
//
//  Created by p on 2018/11/3.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXShareCell.h"

@implementation JXShareCell

-(void)creatUI{
    _imageBackground =[[UIImageView alloc]initWithFrame:CGRectZero];
    [_imageBackground setBackgroundColor:[UIColor clearColor]];
    _imageBackground.layer.cornerRadius = 6;
    _imageBackground.layer.masksToBounds = YES;
    [self.bubbleBg addSubview:_imageBackground];

    _title = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, _imageBackground.frame.size.width - 20,20)];
    _title.font = [UIFont systemFontOfSize:16.0];
    _title.numberOfLines = 2;
    _title.text = @"哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈啊哈哈哈哈哈哈";
    [_imageBackground addSubview:_title];
    
    _shareImage =[[UIImageView alloc] initWithFrame:CGRectMake(self.bubbleBg.frame.size.width - 5 - 50, CGRectGetMaxY(_title.frame) + 5, 50, 50)];
    _shareImage.backgroundColor = [UIColor grayColor];
    [_imageBackground addSubview:_shareImage];
    
    _subTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_title.frame) + 5, self.bubbleBg.frame.size.width - 50 - 20, 50)];
    _subTitle.font = [UIFont systemFontOfSize:14.0];
    _subTitle.numberOfLines = 3;
    _subTitle.textColor = [UIColor lightGrayColor];
    _subTitle.text = @"呵呵呵呵呵呵呵呵呵呵哈哈哈哈哈哈哈哈哈哈呵呵呵呵呵额呵呵呵呵呵呵";
    [_imageBackground addSubview:_subTitle];
    
    
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = THE_LINE_COLOR;
    [_imageBackground addSubview:_lineView];
    
    _skIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 15, 15)];
    _skIcon.image = [UIImage imageNamed:@"ALOGO_120"];
    [_imageBackground addSubview:_skIcon];
    
    _skLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_skIcon.frame) + 5, 10, 100, 30)];
    _skLabel.text = APP_NAME;
    _skLabel.font = SYSFONT(14);
    _skLabel.textColor = [UIColor grayColor];
    [_imageBackground addSubview:_skLabel];
    
}

-(void)setCellData{
    [super setCellData];
    
    NSDictionary * msgDict = [[[SBJsonParser alloc]init]objectWithString:self.msg.objectId];
    
    _title.text = [msgDict objectForKey:@"title"];
    _subTitle.text = [msgDict objectForKey:@"subTitle"];
    if ([msgDict objectForKey:@"imageUrl"]) {
        [_shareImage sd_setImageWithURL:[NSURL URLWithString:[msgDict objectForKey:@"imageUrl"]] placeholderImage:[UIImage imageNamed:@""]];
        
    }else {
        
        [_shareImage sd_setImageWithURL:[NSURL URLWithString:[msgDict objectForKey:@"appIcon"]] placeholderImage:[UIImage imageNamed:@""]];
    }
    _skLabel.text = [msgDict objectForKey:@"appName"];

    [_skIcon sd_setImageWithURL:[NSURL URLWithString:[msgDict objectForKey:@"appIcon"]] placeholderImage:[UIImage imageNamed:@"ALOGO_120"]];
    
    if(self.msg.isMySend)
    {
        self.bubbleBg.frame=CGRectMake(CGRectGetMinX(self.headImage.frame)- kChatCellMaxWidth - CHAT_WIDTH_ICON, INSETS, kChatCellMaxWidth, 125);
        _imageBackground.frame = self.bubbleBg.bounds;
        
        _imageBackground.image = [[UIImage imageNamed:@"chat_bubble_whrite_right_icon"]stretchableImageWithLeftCapWidth:stretch topCapHeight:stretch];
        
    }
    else
    {
        self.bubbleBg.frame=CGRectMake(CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON, INSETS2(self.msg.isGroup), kChatCellMaxWidth, 125);
        _imageBackground.frame = self.bubbleBg.bounds;
        
        _imageBackground.image = [[UIImage imageNamed:@"chat_bg_white"]stretchableImageWithLeftCapWidth:stretch topCapHeight:stretch];
    }
    
    CGFloat x = self.msg.isMySend ? (kChatCellMaxWidth / 32.25) : (kChatCellMaxWidth / 17.2);
    
    CGSize size = [_title.text boundingRectWithSize:CGSizeMake(self.bubbleBg.frame.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _title.font} context:nil].size;
    _title.frame = CGRectMake(x, _title.frame.origin.y, _imageBackground.frame.size.width - 20, 20);
    
    size = [_subTitle.text boundingRectWithSize:CGSizeMake(self.bubbleBg.frame.size.width - 50 - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _subTitle.font} context:nil].size;
    _subTitle.frame = CGRectMake(x, CGRectGetMaxY(_title.frame) + 5, _imageBackground.frame.size.width - 50 - 30, 55);
    
    _shareImage.frame = CGRectMake(CGRectGetMaxX(_subTitle.frame) + 5, CGRectGetMaxY(_title.frame) + 5, 50, 50);
    
    _lineView.frame = CGRectMake(0, CGRectGetMaxY(_shareImage.frame) + 10, _imageBackground.frame.size.width, LINE_WH);
    _skIcon.frame = CGRectMake(x, CGRectGetMaxY(_lineView.frame) + 7, 15, 15);
    _skLabel.frame = CGRectMake(_skLabel.frame.origin.x, CGRectGetMaxY(_shareImage.frame) + 10, 200, 30);
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    
    [self setMaskLayer:_imageBackground];

    
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
    
    [g_notify postNotificationName:kCellShareNotification object:self.msg];
}

+ (float)getChatCellHeight:(JXMessageObject *)msg {
    
    if ([msg.chatMsgHeight floatValue] > 1) {
        return [msg.chatMsgHeight floatValue];
    }
    
    float n = 0;
    if (msg.isGroup && !msg.isMySend) {
        if (msg.isShowTime) {
            n = 125 + 20 + 40 + INSETS * 2;
        }else {
            n = 125 + 20 + INSETS * 2;
        }
        n += GROUP_CHAT_INSET;
    }else {
        if (msg.isShowTime) {
            n = 125 + 40 + INSETS * 2;
        }else {
            n = 125 + INSETS * 2;
        }
    }
    
    msg.chatMsgHeight = [NSString stringWithFormat:@"%f",n];
    if (!msg.isNotUpdateHeight) {
        [msg updateChatMsgHeight];
    }
    return n;
}

@end
