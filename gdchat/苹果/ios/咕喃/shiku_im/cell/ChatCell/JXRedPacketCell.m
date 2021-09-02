//
//  JXRedPacketCell.m
//  lveliao_IM
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXRedPacketCell.h"
#import "UIView+Frame.h"

@interface JXRedPacketCell ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *title;

@end

@implementation JXRedPacketCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)creatUI{
    self.bubbleBg.custom_acceptEventInterval = 1.0;
    
    _imageBackground =[[JXImageView alloc]initWithFrame:CGRectZero];
    [_imageBackground setBackgroundColor:[UIColor clearColor]];
    _imageBackground.layer.cornerRadius = 6;
    _imageBackground.image = [UIImage imageNamed:@"hongbaokuan"];
    _imageBackground.contentMode = UIViewContentModeScaleAspectFill;
    _imageBackground.layer.masksToBounds = YES;
    [self.bubbleBg addSubview:_imageBackground];
    
    _headImageView = [[UIImageView alloc]init];
    _headImageView.frame = CGRectMake(20,15, 32, 42);
    _headImageView.image = [UIImage imageNamed:@"hongb"];
    _headImageView.userInteractionEnabled = NO;
//    _headImageView.hidden = YES;
    [_imageBackground addSubview:_headImageView];
    
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + 15,20, 180, 20);
    _nameLabel.font = g_factory.font16;
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.numberOfLines = 0;
    _nameLabel.userInteractionEnabled = NO;
    [_imageBackground addSubview:_nameLabel];

    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxY(_headImageView.frame) + 15, CGRectGetMaxX(_nameLabel.frame)+5, 100, 14)];
    _title.text = @"鲸鱼红包";
    _title.font = SYSFONT(12.0);
    _title.textColor = HEXCOLOR(0x999999);
    [_imageBackground addSubview:_title];
    
    //
//    _redPacketGreet = [[JXEmoji alloc]initWithFrame:CGRectMake(5, 25, 80, 16)];
//    _redPacketGreet.textAlignment = NSTextAlignmentCenter;
//    _redPacketGreet.font = [UIFont systemFontOfSize:12];
//    _redPacketGreet.textColor = [UIColor whiteColor];
//    _redPacketGreet.userInteractionEnabled = NO;
//    [_imageBackground addSubview:_redPacketGreet];
}

-(void)setCellData{
    [super setCellData];
    int n = imageItemHeight;
    
    if(self.msg.isMySend)
    {
        self.bubbleBg.frame=CGRectMake(CGRectGetMinX(self.headImage.frame)- kChatCellMaxWidth+35 - CHAT_WIDTH_ICON, INSETS, kChatCellMaxWidth-35, n+INSETS -4-15-10);
        _imageBackground.frame = self.bubbleBg.bounds;
        _headImageView.frame = CGRectMake(14,27, 32, 42);
        
    }
    else
    {
        self.bubbleBg.frame=CGRectMake(CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON, INSETS2(self.msg.isGroup), kChatCellMaxWidth-35, n+INSETS -4-15-10);
        _imageBackground.frame = self.bubbleBg.bounds;
        _headImageView.frame = CGRectMake(20,27, 32, 42);
        
    }
    _headImageView.top = (self.bubbleBg.height-_headImageView.height)*0.5-8;
    
    _nameLabel.left = CGRectGetMaxX(_headImageView.frame) + 13;
    _nameLabel.top += 1;
//    _title.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + 15, CGRectGetMaxY(_nameLabel.frame)+2.5, 100, 14);
//    _title.left =  _nameLabel.left;
    _nameLabel.centerY = _headImageView.centerY;
//    _title.bottom = _headImageView.bottom-3;
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    
    [self setMaskLayer:_imageBackground];
    
    //服务端返回的数据类型错乱，强行改
    self.msg.fileName = [NSString stringWithFormat:@"%@",self.msg.fileName];
    if ([self.msg.fileName isEqualToString:@"3"]) {
//        _imageBackground.image = [UIImage imageNamed:@"口令红包"];
//        _redPacketGreet.frame = CGRectMake(5, 45, _imageBackground.frame.size.width -10, 16);
        _nameLabel.text = self.msg.content;
//        _title.text = Localized(@"JX_MesGift");
    }else{
//        _imageBackground.image = [UIImage imageNamed:@"红包"];
//        _redPacketGreet.frame = CGRectMake(5, 25, _imageBackground.frame.size.width -10, 16);
        _nameLabel.text = self.msg.content;
//        _title.text = Localized(@"JXredPacket");
    }
    _title.frame = CGRectMake(_headImageView.left-3, _headImageView.bottom+12, 100, 20);
    if ([self.msg.fileSize intValue] == 2) {
//        _nameLabel.text = @"已领取红包";
        _headImageView.image = [UIImage imageNamed:@"hongb_select"];
//        _title.text  = @"";
        
        _imageBackground.alpha = 0.5;
    }else {
        _headImageView.image = [UIImage imageNamed:@"hongb"];
        _imageBackground.alpha = 1;
    }

}

-(void)didTouch:(UIButton*)button{
    if ([self.msg.fileName isEqualToString:@"3"]) {
//        //如果可以打开
//        if([self.msg.fileSize intValue] != 2){
//            [g_App showAlert:Localized(@"JX_WantOpenGift")];
//            return;
//        }
        
        [g_notify postNotificationName:kcellRedPacketDidTouchNotifaction object:self.msg];
    }
    
    if ([self.msg.fileName isEqualToString:@"1"] || [self.msg.fileName isEqualToString:@"2"]) {
        //如果可以打开
//        if([self.msg.fileSize intValue] != 2){
            [g_notify postNotificationName:kcellRedPacketDidTouchNotifaction object:self.msg];
            return;
//        }
    }
    
//    [g_server getRedPacket:self.msg.objectId toView:self.chatView];
}

+ (float)getChatCellHeight:(JXMessageObject *)msg {
    if ([g_App.isShowRedPacket intValue] == 1){
        if ([msg.chatMsgHeight floatValue] > 1) {
            return [msg.chatMsgHeight floatValue];
        }
        
        float n = 0;
        if (msg.isGroup && !msg.isMySend) {
            if (msg.isShowTime) {
                n = JX_SCREEN_WIDTH/3 + 10 + 5;
            }else {
                n = JX_SCREEN_WIDTH/3 -5;
            }
            n += GROUP_CHAT_INSET;
        }else {
            if (msg.isShowTime) {
                n = JX_SCREEN_WIDTH/3 +25;
            }else {
                n = JX_SCREEN_WIDTH/3-15;
            }
        }
        
        msg.chatMsgHeight = [NSString stringWithFormat:@"%f",n];
        if (!msg.isNotUpdateHeight) {
            [msg updateChatMsgHeight];
        }
        return n;
        
    }else{
        
        msg.chatMsgHeight = [NSString stringWithFormat:@"0"];
        if (!msg.isNotUpdateHeight) {
            [msg updateChatMsgHeight];
        }
        return 0;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
