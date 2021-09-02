//
//  JXRPacketListCell.m
//  shiku_im
//
//  Created by Apple on 16/8/31.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXRPacketListCell.h"

@implementation JXRPacketListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _headerImage.layer.cornerRadius = 5;
    _headerImage.clipsToBounds = YES;
    _buttomLine.frame = CGRectMake(_buttomLine.frame.origin.x, _buttomLine.frame.origin.y, JX_SCREEN_WIDTH, LINE_WH);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
//    [_headerImage release];
//    [_nameLabel release];
//    [_timeLabel release];
//    [_moneyLabel release];
//    [_buttomLine release];
//    [super dealloc];
}
@end
