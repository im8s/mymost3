//
//  JXSearchRecordCell.m
//  shiku_im
//
//  Created by IMAC on 2019/9/6.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXSearchRecordCell.h"

@implementation JXSearchRecordCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 32, 16.5, 17, 17)];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete_icon"] forState:UIControlStateNormal];
        _deleteBtn.layer.cornerRadius = 10;
        _deleteBtn.layer.masksToBounds = YES;
        [_deleteBtn addTarget:self action:@selector(deleteSelf) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_deleteBtn];
    }
    return self;
}
- (void)deleteSelf{
    if ([self.delegate respondsToSelector:@selector(deleteCell:)]) {
        [self.delegate deleteCell:self];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
