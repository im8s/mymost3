//
//  JXRemindCell.m
//  shiku_im
//
//  Created by Apple on 16/10/11.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXRemindCell.h"
#import "JXRoomRemind.h"

@implementation JXRemindCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)creatUI{
    _baseView = [[UIView alloc] initWithFrame:CGRectMake(40, 10, JX_SCREEN_WIDTH-80, 0)];
    _baseView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    _baseView.layer.cornerRadius = 3.f;
    _baseView.layer.masksToBounds = YES;
    [self.contentView addSubview:_baseView];

    _messageRemind=[[UILabel alloc] initWithFrame:CGRectMake(0, 10, 200, 20)];
    _messageRemind.userInteractionEnabled = NO;
//    _messageRemind.lineBreakMode = NSLineBreakByCharWrapping;
    _messageRemind.textAlignment = NSTextAlignmentCenter;
    _messageRemind.lineBreakMode = NSLineBreakByTruncatingTail;
    _messageRemind.backgroundColor = [UIColor clearColor];
//    _messageRemind.layer.borderWidth = 1;
//    _messageRemind.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5].CGColor;
    _messageRemind.textColor = HEXCOLOR(0x999999);
    _messageRemind.font = g_factory.font13;
    _messageRemind.numberOfLines = 0;
    [_baseView addSubview:_messageRemind];
    
    self.confirmBtn = [[UIButton alloc] init];
    self.confirmBtn.backgroundColor = [UIColor clearColor];
    [self.confirmBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_baseView addSubview:self.confirmBtn];
    
}

- (void)btnAction:(UIButton *)btn {
    [g_notify postNotificationName:kCellRemindNotifaction object:self.msg];
}

-(void)setCellData{
    if([self.msg.type intValue] == kWCMessageTypeRemind){
        
//        _messageRemind.textColor = [UIColor whiteColor];
//        _messageRemind.backgroundColor = HEXCOLOR(0xB5B5B5);
        
        if (self.isBlackTip) {
            _messageRemind.textColor = [UIColor blackColor];
        }else {
            _messageRemind.textColor = HEXCOLOR(0x999999);
        }

        NSString *content;
        
        if (self.msg.isShowTime) {
            NSString* t = [TimeUtil formatDate:self.msg.timeSend format:@"MM-dd HH:mm"];
            content = [NSString stringWithFormat:@" %@ (%@) ",self.msg.content,t];
            t = nil;
        }else {
            content = [NSString stringWithFormat:@" %@ ",self.msg.content];
        }

        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:content];
        NSRange range = [content rangeOfString:Localized(@"JX_ToConfirm")];
        NSRange range1 = [content rangeOfString:Localized(@"JX_VerifyConfirmed")];
        if (range.location == NSNotFound) {
            range = range1;
        }
        if (range.location != NSNotFound) {
            [att addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
            self.msg.remindType = [NSNumber numberWithInt:kRoomRemind_NeedVerify];
        }
        NSRange range2 = [content rangeOfString:Localized(@"JX_ShikuRedPacket")];
        if (range.location == NSNotFound) {
            if (range2.location != NSNotFound) {
                range = range2;
                [att addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(0xF58A2E) range:range2];
                self.msg.remindType = [NSNumber numberWithInt:kWCMessageTypeRedPacketReceive];
            }
        }
        

        _messageRemind.attributedText = att;
        
        CGSize size = [_messageRemind.text boundingRectWithSize:CGSizeMake(JX_SCREEN_WIDTH - 80-14, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:g_factory.font13} context:nil].size;
        CGSize allSize = [_messageRemind.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:g_factory.font13} context:nil].size;
        
//        if (size.height > 80) {
//            size.height =  80;
//        }
        
        int w = size.width;
        if (allSize.width+14 > JX_SCREEN_WIDTH-80) {
            // 多行
            w = JX_SCREEN_WIDTH-80-14;
            _baseView.frame = CGRectMake((JX_SCREEN_WIDTH-w-14)/2, _baseView.frame.origin.y, w+14, size.height+10);
            _messageRemind.frame = CGRectMake(7, 5, w, size.height);
        }else {
            //单行
            _baseView.frame = CGRectMake((JX_SCREEN_WIDTH-w-14)/2, _baseView.frame.origin.y, w+14, size.height+10);
            _messageRemind.frame = CGRectMake(6, 5, w, size.height);
        }
        
        if (range.location != NSNotFound) {
            [att addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
            NSString *str = [content substringToIndex:range.location];
            CGSize size = [str boundingRectWithSize:CGSizeMake(JX_SCREEN_WIDTH - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:g_factory.font13} context:nil].size;
            self.confirmBtn.frame = CGRectMake(size.width + _messageRemind.frame.origin.x, 0, 50, size.height + 5);
        }
    }
}

+ (float)getChatCellHeight:(JXMessageObject *)msg {
    
    NSString *str = nil;
    if (msg.isShowTime) {
        NSString* t = [TimeUtil formatDate:msg.timeSend format:@"MM-dd HH:mm"];
        str = [NSString stringWithFormat:@" %@ (%@) ",msg.content,t];
        t = nil;
    }else {
        str = [NSString stringWithFormat:@" %@ ",msg.content];
    }
    CGSize size = [str boundingRectWithSize:CGSizeMake(JX_SCREEN_WIDTH - 80-14, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:g_factory.font13} context:nil].size;
    
//    if (size.height > 80) {
//        size.height =  80;
//    }
    
    float n = size.height + 5 + 18;

    return n;
}

-(void)didTouch:(UIButton*)button{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
