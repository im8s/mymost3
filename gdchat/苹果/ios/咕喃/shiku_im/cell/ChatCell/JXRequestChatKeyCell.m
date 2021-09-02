//
//  JXRequestChatKeyCell.m
//  shiku_im
//
//  Created by p on 2019/9/10.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXRequestChatKeyCell.h"

@implementation JXRequestChatKeyCell

-(void)creatUI{
    _imageBackground =[[UIImageView alloc]initWithFrame:CGRectZero];
    [_imageBackground setBackgroundColor:[UIColor clearColor]];
    _imageBackground.layer.cornerRadius = 6;
    _imageBackground.layer.masksToBounds = YES;
    _imageBackground.userInteractionEnabled = YES;
    [self.bubbleBg addSubview:_imageBackground];
    
    _headImageView= [[UIImageView alloc]init];
    _headImageView.frame = CGRectMake(15,15, 50, 50);
    _headImageView.userInteractionEnabled = NO;
    [_imageBackground addSubview:_headImageView];
    
    _title = [[UILabel alloc]init];
    _title.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + 10,25, 100, 30);
    _title.font = g_factory.font15;
    _title.text = Localized(@"JX_RequestKey");
    _title.userInteractionEnabled = NO;
    [_imageBackground addSubview:_title];
    
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = THE_LINE_COLOR;
    [_imageBackground addSubview:_lineView];
    
    _sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, 100, 50)];
    [_sendBtn setTitle:@"发送秘钥" forState:UIControlStateNormal];
    [_sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _sendBtn.titleLabel.font = SYSFONT(15);
    [_sendBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    [_imageBackground addSubview:_sendBtn];

}

-(void)setCellData{
    [super setCellData];
    int n = imageItemHeight + 20;
    if(self.msg.isMySend)
    {
        self.bubbleBg.frame=CGRectMake(CGRectGetMinX(self.headImage.frame)- kChatCellMaxWidth-CHAT_WIDTH_ICON, INSETS, kChatCellMaxWidth, n+INSETS -4);
        _imageBackground.frame = self.bubbleBg.bounds;
        _imageBackground.image = [[UIImage imageNamed:@"chat_bubble_whrite_right_icon"]stretchableImageWithLeftCapWidth:stretch topCapHeight:stretch];
        
    }
    else
    {
        self.bubbleBg.frame=CGRectMake(CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON, INSETS2(self.msg.isGroup), kChatCellMaxWidth + INSETS * 2, n+INSETS -4);
        _imageBackground.frame = self.bubbleBg.bounds;
        
        _imageBackground.image = [[UIImage imageNamed:@"chat_bg_white"]stretchableImageWithLeftCapWidth:stretch topCapHeight:stretch];
    }
    
    _lineView.frame = CGRectMake(0, _imageBackground.frame.size.height - 50, _imageBackground.frame.size.width, LINE_WH);
    _sendBtn.frame = CGRectMake(0, _imageBackground.frame.size.height - 50, _imageBackground.frame.size.width, 50);
    
    if ([self.msg.generalMark intValue] == 1) {
        [_sendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }else {
        [_sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    
    [self setMaskLayer:_imageBackground];
    
    [g_server getHeadImageSmall:self.msg.fromUserId userName:self.msg.fromUserName imageView:_headImageView getHeadHandler:nil];
    
    
    if(!self.msg.isMySend)
        [self drawIsRead];
}

- (void)updateChatKey {
    self.msg.generalMark = [NSNumber numberWithInt:1];
    [_sendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

+ (float)getChatCellHeight:(JXMessageObject *)msg {
    
    if ([msg.chatMsgHeight floatValue] > 1) {
        return [msg.chatMsgHeight floatValue];
    }
    
    float n = 0;
    if (msg.isGroup && !msg.isMySend) {
        if (msg.isShowTime) {
            n = imageItemHeight+20*2 + 40 + 20;
        }else {
            n = imageItemHeight+20*2 + 20;
        }
        n += GROUP_CHAT_INSET;
    }else {
        if (msg.isShowTime) {
            n = imageItemHeight+10*2 + 40 + 20;
        }else {
            n = imageItemHeight+10*2 + 20;
        }
    }
    
    msg.chatMsgHeight = [NSString stringWithFormat:@"%f",n];
    if (!msg.isNotUpdateHeight) {
        [msg updateChatMsgHeight];
    }
    return n;
}

- (void)sendAction {
    
    if ([self.msg.generalMark boolValue]) {
        //        [JXMyTools showTipView:@"已被其他群成员抢先发送啦"];
        return;
    }
    
    if (self.msg.isMySend) {
        [JXMyTools showTipView:Localized(@"JX_Can'tSendMyselfKey")];
        return;
    }
    
    [g_notify postNotificationName:kCellSendChatKeyNotification object:self.msg];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
