//
//  JXSelectLabelGroupCell.m
//  shiku_im
//
//  Created by IMAC on 2019/8/29.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXSelectLabelGroupCell.h"

@implementation JXSelectLabelGroupCell
- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect rect = self.textLabel.frame;
    self.textLabel.frame = CGRectMake(60, rect.origin.y, rect.size.width, rect.size.height);
    CGRect detail = self.detailTextLabel.frame;
    self.detailTextLabel.frame = CGRectMake(60, detail.origin.y, detail.size.width, detail.size.height);
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
