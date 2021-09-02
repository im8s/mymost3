//
//  JXCardCell.m
//  shiku_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXCardCell.h"
#import "JXMessageObject.h"
#import "JXServer.h"
#import "AppDelegate.h"


@implementation JXCardCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)creatUI{
    _imageBackground =[[UIImageView alloc]initWithFrame:CGRectZero];
    [_imageBackground setBackgroundColor:[UIColor clearColor]];
    _imageBackground.layer.cornerRadius = 6;
    _imageBackground.layer.masksToBounds = YES;
    [self.bubbleBg addSubview:_imageBackground];
//    [_imageBackground release];
    //
    
    _cardHeadImage = [[UIImageView alloc]init];
    _cardHeadImage.frame = CGRectMake(15,15, 50, 50);
    _cardHeadImage.userInteractionEnabled = NO;
    [_imageBackground addSubview:_cardHeadImage];
    
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.frame = CGRectMake(CGRectGetMaxX(_cardHeadImage.frame) + 10,25, 100, 30);
    _nameLabel.font = g_factory.font15;
    _nameLabel.userInteractionEnabled = NO;
    [_imageBackground addSubview:_nameLabel];
    
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = THE_LINE_COLOR;
    [_imageBackground addSubview:_lineView];
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 30)];
    _title.text = Localized(@"JX_BusinessCard");
    _title.font = SYSFONT(13);
    _title.textColor = [UIColor grayColor];
    [_imageBackground addSubview:_title];
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
    
    _lineView.frame = CGRectMake(0, _imageBackground.frame.size.height - 30, _imageBackground.frame.size.width, LINE_WH);
    _title.frame = CGRectMake(15, _imageBackground.frame.size.height - 30, 200, 30);
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    
    [self setMaskLayer:_imageBackground];
    
    [g_server getHeadImageSmall:self.msg.objectId userName:self.msg.content imageView:_cardHeadImage getHeadHandler:nil];
    _nameLabel.text = self.msg.content;
    
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
    
    [g_notify postNotificationName:kCellShowCardNotifaction object:self.msg];
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
