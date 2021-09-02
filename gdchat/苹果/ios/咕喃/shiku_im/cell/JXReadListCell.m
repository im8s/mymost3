//
//  JXReadListCell.m
//  shiku_im
//
//  Created by p on 2017/9/2.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXReadListCell.h"

@interface JXReadListCell ()

@property (nonatomic, strong) JXImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLable;
@property (nonatomic, strong) UILabel *subLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation JXReadListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        _headImageView = [[JXImageView alloc]init];
        _headImageView.userInteractionEnabled = NO;
        _headImageView.frame = CGRectMake(13,5,50,50);
        _headImageView.layer.cornerRadius = 25;
        _headImageView.layer.masksToBounds = YES;
        //        _headImageView.layer.borderWidth = 0.5;
        _headImageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        [self.contentView addSubview:self.headImageView];
        
        _nameLable = [[UILabel alloc] initWithFrame:CGRectMake(80, 9, JX_SCREEN_WIDTH -60 - 80, 20)];
        _nameLable.textColor = [UIColor blackColor];
        _nameLable.userInteractionEnabled = NO;
        _nameLable.backgroundColor = [UIColor clearColor];
        _nameLable.font = g_factory.font15;
        _nameLable.tag = self.index;
        [self.contentView addSubview:_nameLable];
        
        _subLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 23, JX_SCREEN_WIDTH-60, 35)];
        _subLabel.textColor = [UIColor lightGrayColor];
        _subLabel.userInteractionEnabled = NO;
        _subLabel.backgroundColor = [UIColor clearColor];
        _subLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_subLabel];
        
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 220, 9, 200, 20)];
        _timeLabel.textColor = [UIColor lightGrayColor];
        _timeLabel.userInteractionEnabled = NO;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:_timeLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 60 - LINE_WH, JX_SCREEN_WIDTH, LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [self.contentView addSubview:line];
    }
    
    return self;
}

- (void) setData:(JXUserObject *)obj {
    _headImageView.tag = self.index;
    _headImageView.delegate = self.delegate;
    _headImageView.didTouch = self.didTouch;
    [g_server getHeadImageLarge:obj.userId userName:obj.userNickname imageView:_headImageView getHeadHandler:nil];
    NSString *name = [NSString string];
    for (memberData *member in _room.members) {
        if ([obj.userId intValue] == (int)member.userId) {
            name = member.lordRemarkName.length > 0 ? member.lordRemarkName : member.userNickName;
        }
    }
    _nameLable.text = obj.userNickname.length > 0 ? obj.userNickname : name;
    _subLabel.text = obj.userId;
    _timeLabel.text = [NSString stringWithFormat:@"%@：%@",Localized(@"JX_ReadingTime"),[TimeUtil formatDate:obj.timeSend format:@"MM-dd HH:mm"]];

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
