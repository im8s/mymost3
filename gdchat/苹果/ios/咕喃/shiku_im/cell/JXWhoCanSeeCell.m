//
//  JXWhoCanSeeCell.m
//  shiku_im
//
//  Created by p on 2018/6/27.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXWhoCanSeeCell.h"

@implementation JXWhoCanSeeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self customView];
    }
    return self;
}

- (void)customView {
    
    _contentBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [_contentBtn addTarget:self action:@selector(contentBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_contentBtn];
    
    _selImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 20, 20, 20)];
    _selImageView.image = [UIImage imageNamed:@"sel_nor_wx2"];
    [self.contentView addSubview:_selImageView];
    
    
    _title = [[JXLabel alloc] initWithFrame:CGRectMake(60, 6, JX_SCREEN_WIDTH-60-30, 20)];
    _title.font = g_factory.font16;
    _title.backgroundColor = [UIColor clearColor];
    _title.textColor = [UIColor blackColor];
    [self.contentView addSubview:_title];

    _userNames = [[JXLabel alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(_title.frame)+6, JX_SCREEN_WIDTH-60-30, 17)];
    _userNames.font = g_factory.font15;
    _userNames.backgroundColor = [UIColor clearColor];
    _userNames.textColor = [UIColor grayColor];
    [self.contentView addSubview:_userNames];
    
    
    _editBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 40, 20, 20, 20)];
    [_editBtn setBackgroundImage:[UIImage imageNamed:@"icg"] forState:UIControlStateNormal];
    [_editBtn addTarget:self action:@selector(editBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_editBtn];
}

- (void)contentBtnAction:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        self.selImageView.image = [UIImage imageNamed:@"sel_check_wx2"];
    }else {
        self.selImageView.image = [UIImage imageNamed:@"sel_nor_wx2"];
    }
    
    if ([self.delegate respondsToSelector:@selector(whoCanSeeCell:selectAction:)]) {
        [self.delegate whoCanSeeCell:self selectAction:self.index];
    }
}

- (void)editBtnAction:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(whoCanSeeCell:editBtnAction:)]) {
        [self.delegate whoCanSeeCell:self editBtnAction:self.index];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    

    // Configure the view for the selected state
}

@end
