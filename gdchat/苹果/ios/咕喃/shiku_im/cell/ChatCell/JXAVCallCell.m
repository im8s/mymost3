//
//  JXAVCallCell.m
//  shiku_im
//
//  Created by p on 2017/8/7.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXAVCallCell.h"

@interface JXAVCallCell ()

@property (nonatomic, strong) UILabel *avLabel;
@property (nonatomic, strong) UIImageView *avImageView;

@end

@implementation JXAVCallCell

-(void)creatUI{
    
    _avLabel = [[UILabel alloc] init];
    _avLabel.textColor = [UIColor blackColor];
    _avLabel.font = [UIFont systemFontOfSize:g_constant.chatFont];
    [self.bubbleBg addSubview:_avLabel];
    
    _avImageView = [[UIImageView alloc] init];
    [self.bubbleBg addSubview:_avImageView];
    
}

-(void)setCellData{
    [super setCellData];
    
    _avLabel.text = self.msg.content;
    int type = 0;
    switch ([self.msg.type intValue]) {
        case kWCMessageTypeAudioChatCancel:
        case kWCMessageTypeAudioChatEnd:
        case kWCMessageTypeAudioMeetingInvite:
            type = 1;
            break;
        case kWCMessageTypeVideoMeetingInvite:
        case kWCMessageTypeVideoChatCancel:
        case kWCMessageTypeVideoChatEnd:
            type = 2;
            break;
        case kWCMessageTypeScreenShareCancel:
        case kWCMessageTypeScreenShareEnd:
        case kWCMessageTypeScreenShareMeetingInvite:
            type = 3;
            break;
        case kWCMessageTypeAVBusy:{
            if ([self.msg.objectId isEqualToString:@"1"]) {
                type = 2;
            }else if ([self.msg.objectId isEqualToString:@"0"]){
                type = 1;
            }else{
                type = 3;
            }
        }
            break;
            
        default:
            break;
    }
    if (type == 1) {
        _avImageView.image = [UIImage imageNamed:@"end_of_voice_call_icon"];
        
    }else if (type == 2){
        
        _avImageView.image = [UIImage imageNamed:@"video_call_closed_icon"];
    }else {
        _avImageView.image = [UIImage imageNamed:@"screenshare_call_closed_icon"];
    }
    
    [self creatBubbleBg];
}
-(void)creatBubbleBg{
    CGSize textSize = [self.msg.content boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_avLabel.font} context:nil].size;
    int n = textSize.width;

    if(self.msg.isMySend){
        self.bubbleBg.frame=CGRectMake(CGRectGetMinX(self.headImage.frame)-INSETS*2-n - 30-CHAT_WIDTH_ICON, INSETS, n+INSETS*2 + 30, textSize.height+INSETS*2);
        [_avLabel setFrame:CGRectMake(INSETS*0.4 + 3, INSETS, n + 5, textSize.height)];
        [_avImageView setFrame:CGRectMake(CGRectGetMaxX(_avLabel.frame) + 3, (self.bubbleBg.frame.size.height - 21) / 2, 21, 21)];
        
    }else
    {
        self.bubbleBg.frame=CGRectMake(CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON, INSETS2(self.msg.isGroup), n+INSETS*2 + 25, textSize.height+INSETS*2);
        [_avImageView setFrame:CGRectMake(INSETS + 3, (self.bubbleBg.frame.size.height - 21) / 2, 21, 21)];
        [_avLabel setFrame:CGRectMake(CGRectGetMaxX(_avImageView.frame) + 5, INSETS, n + 5, textSize.height)];
    }
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    
}


+ (float)getChatCellHeight:(JXMessageObject *)msg {
    
    if ([msg.chatMsgHeight floatValue] > 1) {
        return [msg.chatMsgHeight floatValue];
    }
    
    float n;
    if (msg.isShowTime) {
        n = 95;
    }else {
        n = 55;
    }
    
    msg.chatMsgHeight = [NSString stringWithFormat:@"%f",n];
    if (!msg.isNotUpdateHeight) {
        [msg updateChatMsgHeight];
    }
    return n;
}

-(void)didTouch:(UIButton*)button{
    [g_notify postNotificationName:kCellSystemAVCallNotifaction object:self.msg];
}

@end
