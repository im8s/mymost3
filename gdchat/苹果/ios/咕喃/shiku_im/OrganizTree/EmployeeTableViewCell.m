//
//  EmployeeTableViewCell.m
//  shiku_im
//
//  Created by 1 on 17/5/18.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "EmployeeTableViewCell.h"

@implementation EmployeeTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [UIView new];
        self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
        
        [self customUI];
    }
    return self;
}

-(void)customUI{

    self.backgroundColor = [UIColor whiteColor];
    
    _headImageView = [[UIImageView alloc]init];
    _headImageView.frame = CGRectMake(10,12,36,36);
    _headImageView.layer.cornerRadius = _headImageView.frame.size.width/2;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [self.contentView addSubview:self.headImageView];

    _customTitleLabel = [UIFactory createLabelWith:CGRectMake(CGRectGetMaxX(_headImageView.frame)+16, 12, 100, 15) text:@"" font:g_UIFactory.font15 textColor:[UIColor blackColor] backgroundColor:nil];
    _customTitleLabel.textAlignment = NSTextAlignmentLeft;
    _customTitleLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:_customTitleLabel];
    
    
    _positionLabel = [UIFactory createLabelWith:CGRectMake(CGRectGetMaxX(_headImageView.frame)+16, CGRectGetMaxY(_headImageView.frame)-13, 100, 13) text:@"" font:g_factory.font13 textColor:THEMECOLOR backgroundColor:nil];
//    _positionLabel.layer.backgroundColor = [UIColor orangeColor].CGColor;
//    _positionLabel.layer.cornerRadius = 5;
//    _positionLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_positionLabel];
    
    _line = [[UIView alloc] initWithFrame:CGRectMake(15, 60-LINE_WH, JX_SCREEN_WIDTH-15, LINE_WH)];
    _line.backgroundColor = THE_LINE_COLOR;
    [self.contentView addSubview:_line];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self layoutIfNeeded];
    
}
- (void)prepareForReuse
{
    [super prepareForReuse];
}
//- (void)willTransitionToState:(UITableViewCellStateMask)state{
//    
//}

- (void)setupWithData:(EmployeObject *)dataObj level:(NSInteger)level
{
    self.customTitleLabel.text = dataObj.nickName;
    self.positionLabel.text = dataObj.position;
    [g_server getHeadImageSmall:dataObj.userId userName:dataObj.nickName imageView:_headImageView getHeadHandler:nil];
    self.employObject = dataObj;
    
   
    CGFloat left = 11 + 20 * level;
    
//    CGRect titleFrame = self.customTitleLabel.frame;
    CGRect headFrame = self.headImageView.frame;
    headFrame.origin.x = left;
    self.headImageView.frame = headFrame;
    
    
    self.customTitleLabel.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame)+16, 12, 100, 15);
    
    self.positionLabel.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame)+16, CGRectGetMaxY(_headImageView.frame)-13, 100, 13);
    
    self.line.frame = CGRectMake(left, self.line.frame.origin.y, JX_SCREEN_WIDTH-left, self.line.frame.size.height);
//    CGSize nameSize =[dataObj.nickName sizeWithAttributes:@{NSFontAttributeName:self.customTitleLabel.font}];
//    titleFrame.origin.x = left + CGRectGetWidth(_headImageView.frame) + 4;
//    titleFrame.size = nameSize;
//    self.customTitleLabel.frame = titleFrame;
//    self.customTitleLabel.center = CGPointMake(_customTitleLabel.center.x, self.headImageView.center.y);
    
//    CGSize positionSize =[dataObj.position sizeWithAttributes:@{NSFontAttributeName:self.positionLabel.font}];
//    if (positionSize.width >150)
//        positionSize.width = 150;
//    self.positionLabel.frame = CGRectMake(CGRectGetMaxX(self.customTitleLabel.frame)+2, CGRectGetMinY(self.customTitleLabel.frame), positionSize.width+4, positionSize.height);
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
