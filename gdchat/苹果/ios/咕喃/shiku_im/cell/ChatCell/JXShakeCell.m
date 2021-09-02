//
//  JXShakeCell.m
//  shiku_im
//
//  Created by p on 2018/5/30.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXShakeCell.h"

@implementation JXShakeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)creatUI{
    self.shakeImageView = [[UIImageView alloc] init];
    [self.bubbleBg addSubview:self.shakeImageView];
}

- (void)setCellData {
    
    [super setCellData];
    NSMutableArray *array = [NSMutableArray array];
    NSString* file,*s;
    if(self.msg.isMySend)
        file = @"pj_right_";
    else
        file = @"pj_left_";
    for(int i=1;i<=6;i++){
        s = [NSString stringWithFormat:@"%@%d",file,i];
        [array addObject:[UIImage imageNamed:s]];
    }
    self.shakeImageView.animationImages = array;
    self.shakeImageView.animationDuration = 0.5;
    self.shakeImageView.animationRepeatCount = 2;
    self.shakeImageView.image = [array objectAtIndex:[array count]-1];
    
    if(self.msg.isMySend){
        self.bubbleBg.frame = CGRectMake(CGRectGetMinX(self.headImage.frame)-105-CHAT_WIDTH_ICON, 0, 105, 105);
    }
    else{
        self.bubbleBg.frame = CGRectMake(CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON, 0, 105, 105);
    }
    
    if ([self.msg.fileName intValue] == 0) {
        self.msg.fileName = @"1";
        [self.shakeImageView startAnimating];
        [self.msg updateFileName];
    }
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    
    self.shakeImageView.frame=self.bubbleBg.bounds;
}

-(void)didTouch:(UIButton*)button{
    
    [self.shakeImageView startAnimating];
    [g_notify postNotificationName:kCellSystemShakeNotifaction object:self.msg];
    
}

+ (float)getChatCellHeight:(JXMessageObject *)msg {
    
    if ([msg.chatMsgHeight floatValue] > 1) {
        return [msg.chatMsgHeight floatValue];
    }
    
    float n = 0;
    if (msg.isGroup && !msg.isMySend) {
        if (msg.isShowTime) {
            n = 105+20*2 + 40;
        }else {
            n = 105+20*2;
        }
        n += GROUP_CHAT_INSET;
    }else {
        if (msg.isShowTime) {
            n = 105+10*2 + 40;
        }else {
            n = 105+10*2;
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
