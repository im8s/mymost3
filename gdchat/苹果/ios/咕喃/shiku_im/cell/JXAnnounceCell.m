//
//  JXAnnounceCell.m
//  shiku_im
//
//  Created by 1 on 2018/8/17.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXAnnounceCell.h"

#define HEIGHT 36

@interface JXAnnounceCell ()
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIView *line;

@end

@implementation JXAnnounceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = HEXCOLOR(0xF2F2F2);
        self.baseView = [[UIView alloc] initWithFrame:CGRectMake(INSETS, INSETS, JX_SCREEN_WIDTH-INSETS*2, MAXFLOAT)];
        self.baseView.backgroundColor = [UIColor whiteColor];
        self.baseView.layer.masksToBounds = YES;
        self.baseView.layer.cornerRadius = 4.0f;
        [self.contentView addSubview:self.baseView];
        
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, HEIGHT, HEIGHT)];
        self.icon.layer.masksToBounds = YES;
        self.icon.layer.cornerRadius = self.icon.frame.size.width/2;
        [self.baseView addSubview:self.icon];
        
        self.name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.icon.frame)+15, 26, 200, 20)];
        self.name.font = SYSFONT(16);
        self.name.textColor = HEXCOLOR(0x333333);
        [self.baseView addSubview:self.name];
        
        self.time = [[UILabel alloc] initWithFrame:CGRectMake(self.baseView.frame.size.width-INSETS-100, self.name.frame.origin.y, 100, 20)];
        self.time.textAlignment = NSTextAlignmentRight;
        self.time.font = [UIFont systemFontOfSize:13];
        self.time.textColor = HEXCOLOR(0x333333);
        [self.baseView addSubview:self.time];
        
        self.line = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.icon.frame)+15, self.baseView.frame.size.width-15, LINE_WH)];
        self.line.backgroundColor = THE_LINE_COLOR;
        [self.baseView addSubview:self.line];
        
        self.content = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.line.frame)+20, self.baseView.frame.size.width-15*2, MAXFLOAT)];
        self.content.font = SYSFONT(16);
        self.content.numberOfLines = 0;
        self.content.textColor = HEXCOLOR(0x333333);
        [self.content sizeToFit];
        [self.baseView addSubview:self.content];
    }
    return self;
}

- (void)setCellHeightWithText:(NSString *)text {
    CGSize size = [text boundingRectWithSize:CGSizeMake(JX_SCREEN_WIDTH-INSETS*2-15*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:g_factory.font16} context:nil].size;
    self.content.frame = CGRectMake(15, CGRectGetMaxY(self.line.frame)+20,size.width, size.height);
    self.baseView.frame = CGRectMake(INSETS, INSETS, JX_SCREEN_WIDTH-INSETS*2, 106+size.height);
}

@end
