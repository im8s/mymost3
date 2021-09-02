//
//  JXGroupHelperCell.m
//  shiku_im
//
//  Created by 1 on 2019/5/29.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXGroupHelperCell.h"

@implementation JXGroupHelperCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7, 50, 50)];
        imageView.layer.cornerRadius = 50 / 2;
        imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:imageView];
        _imageV = imageView;
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, 10, JX_SCREEN_WIDTH - 65 - (CGRectGetMaxX(imageView.frame) + 10) - 10, 20)];
        title.font = [UIFont systemFontOfSize:16.0];
        [self.contentView addSubview:title];
        _title = title;
        
        
        UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, CGRectGetMaxY(title.frame) + 7, JX_SCREEN_WIDTH - 65 - (CGRectGetMaxX(imageView.frame) + 10) - 10, 20)];
        subTitle.font = [UIFont systemFontOfSize:14.0];
        subTitle.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:subTitle];
        _subTitle = subTitle;
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 65, 20, 50, 24)];
        btn.backgroundColor = THEMECOLOR;
        [btn setTitle:Localized(@"JX_Add") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        btn.layer.cornerRadius = 3.0;
        btn.layer.masksToBounds = YES;
        btn.tag = self.tag;
        [btn addTarget:self action:@selector(onAdd:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btn];
        _addBtn = btn;
    }
    return self;
}


- (void)setDataWithModel:(JXHelperModel *)model {
    [_imageV sd_setImageWithURL:[NSURL URLWithString:model.iconUrl] placeholderImage:[UIImage imageNamed:@"avatar_normal"]];
    _title.text = model.name;
    _subTitle.text = model.desc;
    _addBtn.hidden = [_groupHelperArr containsObject:model.helperId];
}

- (void)onAdd:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(groupHelperCell:clickAddBtnWithIndex:)]) {
        [self.delegate groupHelperCell:self clickAddBtnWithIndex:self.tag];
    }
}


@end
