//
//  JXCourseListCell.m
//  shiku_im
//
//  Created by p on 2017/10/20.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXCourseListCell.h"

@interface JXCourseListCell()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *nextImage;

@end

@implementation JXCourseListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, JX_SCREEN_WIDTH -60 - 80, 20)];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.userInteractionEnabled = NO;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = g_factory.font16;
        _nameLabel.tag = self.index;
        _nameLabel.text = [NSString stringWithFormat:@"%@:",Localized(@"JX_CourseName")];
        [self.contentView addSubview:_nameLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_nameLabel.frame) + 10, JX_SCREEN_WIDTH -60 - 80, 20)];
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.userInteractionEnabled = NO;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = g_factory.font13;
        _timeLabel.tag = self.index;
        _timeLabel.text = [NSString stringWithFormat:@"%@:",Localized(@"JX_RecordingTime")];
        [self.contentView addSubview:_timeLabel];
        
        _nextImage = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15-7, (70-13)/2, 7, 13)];
        _nextImage.image = [UIImage imageNamed:@"new_icon_>"];
        _nextImage.hidden = NO;
        [self.contentView addSubview:_nextImage];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 70 - LINE_WH, JX_SCREEN_WIDTH-15, LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [self.contentView addSubview:line];
        
        _multiselectBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-20-15, 25, 20, 20)];
        _multiselectBtn.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_multiselectBtn];
        [_multiselectBtn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
        [_multiselectBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
        _multiselectBtn.titleLabel.font = g_factory.font10;
        _multiselectBtn.layer.cornerRadius = _multiselectBtn.frame.size.width / 2;
        _multiselectBtn.layer.masksToBounds = YES;
        _multiselectBtn.layer.borderWidth = 1.0;
        _multiselectBtn.layer.borderColor = [THEMECOLOR CGColor];
        _multiselectBtn.hidden = YES;
    }
    
    return self;
}

- (void)btnAction {
    NSInteger num = [self.vc getSelNum:[_multiselectBtn.titleLabel.text integerValue] indexNum:self.indexNum];
    if (num > 0) {
        [_multiselectBtn setTitle:[NSString stringWithFormat:@"%ld",num] forState:UIControlStateNormal];
    }else {
        _multiselectBtn.titleLabel.text = @"";
        [_multiselectBtn setTitle:@"" forState:UIControlStateNormal];
    }
}

- (void)setData:(NSDictionary *)dict {
    if (self.isMultiselect) {
        _multiselectBtn.hidden = NO;
        _nextImage.hidden = YES;
    }else {
        _multiselectBtn.hidden = YES;
        _nextImage.hidden = NO;
        _multiselectBtn.titleLabel.text = @"";
        [_multiselectBtn setTitle:@"" forState:UIControlStateNormal];
    }
    NSArray *arr = dict[@"messageIds"];
    _nameLabel.text = [NSString stringWithFormat:@"%@：%@ (%ld)",Localized(@"JX_CourseName"),dict[@"courseName"],arr.count];
    _timeLabel.text = [NSString stringWithFormat:@"%@：%@",Localized(@"JX_RecordingTime"),[TimeUtil formatDate:[NSDate dateWithTimeIntervalSince1970:[dict[@"createTime"] longLongValue]] format:@"MM-dd HH:mm"]];;
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
