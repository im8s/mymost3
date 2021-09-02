//
//  JXNearMarkCell.m
//  shiku_im
//
//  Created by MacZ on 16/8/25.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXNearMarkCell.h"
#import "JXMyTools.h"
#import <MapKit/MapKit.h>

@implementation JXNearMarkCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _markImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 15, 18)];
        _markImgView.center = CGPointMake(_markImgView.center.x, NEAERMAEK_CELL_HEIGHT/2);
        _markImgView.image = [UIImage imageNamed:@"location_gray"];
        [self.contentView addSubview:_markImgView];
//        [_markImgView release];
        
        //地址名
        _markName = [[UILabel alloc] initWithFrame:CGRectMake(_markImgView.frame.origin.x + _markImgView.frame.size.width + 10, 10, JX_SCREEN_WIDTH - _markImgView.frame.origin.x - _markImgView.frame.size.width - 10 - 30, 15)];
        _markName.font = [UIFont boldSystemFontOfSize:15];
        [self.contentView addSubview:_markName];
//        [_markName release];
//        _markName.backgroundColor = [UIColor cyanColor];
        
        //地址位置
        _markPlace = [[UILabel alloc] initWithFrame:CGRectMake(_markName.frame.origin.x, _markName.frame.origin.y + _markName.frame.size.height + 5, _markName.frame.size.width, 12)];
        _markPlace.font = SYSFONT(14);
        [self.contentView addSubview:_markPlace];
//        [_markPlace release];
//        _markPlace.backgroundColor = [UIColor cyanColor];
        
        //选中标志
        _selFlag = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 30-15, 10, 30, 30)];
        _selFlag.image = [UIImage imageNamed:@"ic_has_input"];
        _selFlag.hidden = YES;
        [self.contentView addSubview:_selFlag];
//        [_selFlag release];
//        _selFlag.backgroundColor = [UIColor magentaColor];
        
        //下划线
        UIView *bottomLine = [JXMyTools bottomLineWithFrame:CGRectMake(8, NEAERMAEK_CELL_HEIGHT - LINE_WH, JX_SCREEN_WIDTH - 8*2, LINE_WH)];
        [self.contentView addSubview:bottomLine];
//        [bottomLine release];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.selFlag.hidden = NO;
    }else {
        self.selFlag.hidden = YES;
    }
}

- (void)refreshWith:(MKMapItem *)item{
    
    _markName.text = item.name;
    _markPlace.text = item.placemark.thoroughfare;
}

- (void)refreshWithModel:(JXPlaceMarkModel *)model{
    _markName.text = model.placeName;
    _markPlace.text = model.address;
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
