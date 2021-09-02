//
//  JXLoadingCell.m
//  shiku_im
//
//  Created by p on 2019/11/14.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXLoadingCell.h"

@implementation JXLoadingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)creatUI{
    
    _loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loading.hidden = NO;
    _loading.frame = CGRectMake((JX_SCREEN_WIDTH - 10) / 2, 10, 10, 10);
    [self.contentView addSubview:_loading];
    [_loading startAnimating];
}


-(void)setCellData{
    [_loading startAnimating];
}

+ (float)getChatCellHeight:(JXMessageObject *)msg {
    
    return 30;
}


@end
