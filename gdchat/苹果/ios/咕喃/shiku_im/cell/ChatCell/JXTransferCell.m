//
//  JXTransferCell.m
//  lveliao_IM
//
//  Created by 1 on 2019/3/1.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXTransferCell.h"
#import "UIView+Frame.h"

@interface JXTransferCell ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *moneyLabel;

@end

@implementation JXTransferCell

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
    _imageBackground.layer.masksToBounds = YES;
    _imageBackground.contentMode = UIViewContentModeScaleAspectFill;
    [self.bubbleBg addSubview:_imageBackground];
    
    _headImageView = [[UIImageView alloc]init];
    _headImageView.frame = CGRectMake(15,20, 40, 40);
    _headImageView.image = [UIImage imageNamed:@"ic_transfer_money"];
    _headImageView.userInteractionEnabled = NO;
    [_imageBackground addSubview:_headImageView];
    
    
    _moneyLabel = [[UILabel alloc]init];
    _moneyLabel.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + 15,20, 180, 15);
    _moneyLabel.font = g_factory.font16;
    _moneyLabel.textColor = [UIColor whiteColor];
    _moneyLabel.numberOfLines = 0;
    _moneyLabel.userInteractionEnabled = NO;
    [_imageBackground addSubview:_moneyLabel];

    
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + 15,CGRectGetMaxY(_moneyLabel.frame)+5, 180, 14);
    _nameLabel.font = g_factory.font15;
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.numberOfLines = 0;
    _nameLabel.userInteractionEnabled = NO;
    [_imageBackground addSubview:_nameLabel];
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxY(_headImageView.frame) + 15, CGRectGetMaxX(_nameLabel.frame)+5, 100, 14)];
    _title.text = @"鲸鱼转账";
    _title.font = SYSFONT(12.0);
    _title.textColor = HEXCOLOR(0x999999);
    [_imageBackground addSubview:_title];
//    _title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 200, 30)];
//    _title.text = Localized(@"JX_Transfer");
//    _title.font = SYSFONT(14.0);
//    _title.textColor = [UIColor whiteColor];
//    [_imageBackground addSubview:_title];
}

-(void)setCellData{
    [super setCellData];
    int n = imageItemHeight;
    
        if(self.msg.isMySend)
        {
            self.bubbleBg.frame=CGRectMake(CGRectGetMinX(self.headImage.frame)- kChatCellMaxWidth+35 - CHAT_WIDTH_ICON, INSETS, kChatCellMaxWidth-35, n+INSETS -4-15-10);
            _imageBackground.frame = self.bubbleBg.bounds;
            _headImageView.frame = CGRectMake(16,18, 36, 36);
            
        }
        else
        {
            self.bubbleBg.frame=CGRectMake(CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON, INSETS2(self.msg.isGroup), kChatCellMaxWidth-35, n+INSETS -4-15-10);
            _imageBackground.frame = self.bubbleBg.bounds;
            _headImageView.frame = CGRectMake(22,18, 36, 36);
            
        }
        _headImageView.top = (self.bubbleBg.height-_headImageView.height)*0.5-9;
        
        _nameLabel.left = CGRectGetMaxX(_headImageView.frame) + 15+2;
    //    _title.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + 15, CGRectGetMaxY(_nameLabel.frame)+2.5, 100, 14);
    //    _title.left =  _nameLabel.left;
        _nameLabel.centerY = _headImageView.centerY;
    //    _title.bottom = _headImageView.bottom-3;
    
    _moneyLabel.left = CGRectGetMaxX(_headImageView.frame) + 15;
    _nameLabel.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + 15, CGRectGetMaxY(_nameLabel.frame)+2.5, 100, 14);
    _nameLabel.left =  _moneyLabel.left;
    _moneyLabel.top = _headImageView.top-3;
    _nameLabel.bottom = _headImageView.bottom-3+3;
    
//    _nameLabel.frame = CGRectMake(15, _imageBackground.frame.size.height - 30, 200, 30);
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    
    [self setMaskLayer:_imageBackground];
    JXUserObject *user = [[JXUserObject alloc] init];
    user = [user getUserById:self.msg.toUserId];
    _nameLabel.text = self.msg.fileName.length > 0 ? self.msg.fileName : self.msg.isMySend ? [NSString stringWithFormat:@"%@%@",Localized(@"JX_TransferTo"),user.remarkName.length > 0 ? user.remarkName : user.userNickname] : Localized(@"JX_TransferToYou");
    _moneyLabel.text = [NSString stringWithFormat:@"¥%@",self.msg.content];
    _title.frame = CGRectMake(_headImageView.left-3, _headImageView.bottom+14, 100, 20);
    if ([self.msg.fileSize intValue] == 2) {
        
        _imageBackground.alpha = 0.5;
    }else {
        
        _imageBackground.alpha = 1;
    }
}

-(void)didTouch:(UIButton*)button{
    self.msg.index = self.indexNum;
    [g_notify postNotificationName:kcellTransferDidTouchNotifaction object:self.msg];
}

+ (float)getChatCellHeight:(JXMessageObject *)msg {
    if ([g_App.isShowRedPacket intValue] == 1){
        if ([msg.chatMsgHeight floatValue] > 1) {
            return [msg.chatMsgHeight floatValue];
        }
        
        float n = 0;
        if (msg.isGroup && !msg.isMySend) {
            if (msg.isShowTime) {
                n = JX_SCREEN_WIDTH/3 + 10 + 40;
            }else {
                n = JX_SCREEN_WIDTH/3 + 10;
            }
            n += GROUP_CHAT_INSET;
        }else {
            if (msg.isShowTime) {
                n = JX_SCREEN_WIDTH/3 + 40;
            }else {
                n = JX_SCREEN_WIDTH/3;
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


@end
