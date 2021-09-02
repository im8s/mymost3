//
//  JXClearAllRecordCell.m
//  shiku_im
//
//  Created by IMAC on 2019/9/6.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXClearAllRecordCell.h"

@implementation JXClearAllRecordCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTitle:(NSString *)title{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleString = title;
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    if ([self.titleString isEqualToString:@"history"]) {
        CGFloat y = self.textLabel.center.y;
        CGFloat x = self.imageView.center.x;
        CGRect rect = self.textLabel.frame;
        self.imageView.frame = CGRectMake(0, 0, 15, 15);
        self.imageView.center = CGPointMake(x, y);
        self.textLabel.frame = CGRectMake(rect.origin.x - 10 , rect.origin.y, rect.size.width, rect.size.height);
    }else{
        CGFloat y = self.textLabel.center.y;
        self.textLabel.center = CGPointMake(JX_SCREEN_WIDTH / 2, y);
        
    }
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
