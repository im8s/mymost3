//
//  JXTelAreaCell.m
//  shiku_im
//
//  Created by MacZ on 16/7/7.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXTelAreaCell.h"
#import "JXMyTools.h"

@implementation JXTelAreaCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //国家名
        _countryName = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, JX_SCREEN_WIDTH-15-15-15-50, TELAREA_CELL_HEIGHT)];
        _countryName.font = SYSFONT(15);
        _countryName.text = @"";
        [self.contentView addSubview:_countryName];
        //        [_countryName release];
        //        _countryName.backgroundColor = [UIColor orangeColor];
        
        //区号
        _areaNum = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15-50, 0, 50, TELAREA_CELL_HEIGHT)];
        _areaNum.text = @"+1896";
        _areaNum.font = SYSFONT(14);
        _areaNum.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_areaNum];
        //        [_areaNum release];
        //        _areaNum.backgroundColor = [UIColor magentaColor];
        
        //下划线
        _bottomLine = [JXMyTools bottomLineWithFrame:CGRectMake(15, TELAREA_CELL_HEIGHT-LINE_WH, JX_SCREEN_WIDTH-15*2, LINE_WH)];
        [self.contentView addSubview:_bottomLine];
        //        [_bottomLine release];
    }
    return self;
}

- (void)doRefreshWith:(NSDictionary *)dict language:(NSString *)language{
    if ([language isEqualToString:@"zh"]) {
        _countryName.text = [dict objectForKey:@"country"];
    }else if ([language isEqualToString:@"big5"]) {
        _countryName.text = [dict objectForKey:@"big5"];
    }else{
        _countryName.text = [dict objectForKey:@"enName"];
    }
    _areaNum.text = [NSString stringWithFormat:@"+%@",[dict objectForKey:@"prefix"]];
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
