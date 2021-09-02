//
//  JXSearchMoreCell.m
//  shiku_im
//
//  Created by IMAC on 2019/8/30.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXSearchMoreCell.h"

@implementation JXSearchMoreCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        self.baseView.backgroundColor = [UIColor clearColor];
        self.ImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7.5, 14, 15)];
        [self.baseView addSubview:self.ImgView];
        self.moreLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 80, 10)];
        self.moreLable.textColor = HEXCOLOR(0x55BEB8);
        self.moreLable.font = [UIFont systemFontOfSize:13];
        self.moreLable.numberOfLines = 0;
        [self.baseView addSubview:self.moreLable];
        [self.contentView addSubview:self.baseView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.selectView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, JX_SCREEN_WIDTH - 16, 50)];
        self.selectView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.selectView];
        self.selectView.hidden = YES;
        [self cutSelectedView];
    }
    return self;
}
- (void)setImgName:(NSString *)imgName{
    _imgName = imgName;
    self.ImgView.image = [UIImage imageNamed:_imgName];
}

- (void)setMoreName:(NSString *)moreName{
    _moreName = moreName;
    self.moreLable.text = _moreName;
    CGSize labelsize = [self.moreLable.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:13],NSFontAttributeName,nil]];
    self.moreLable.frame = CGRectMake(CGRectGetMaxX(self.ImgView.frame) + 10, (self.baseView.frame.size.height - labelsize.height) / 2, labelsize.width, labelsize.height);
    self.baseView.frame = CGRectMake(0, 0, 44 + labelsize.width, 30);
    self.baseView.center = CGPointMake(self.center.x + 25, 25);

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.selectView.hidden = NO;
        [self performSelector:@selector(hiddenSelectView) withObject:nil afterDelay:0.5];
    }
    
    
    
}
- (void)cutSelectedView{
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGRect bounds = CGRectInset(self.selectView.bounds, 0, 0);
    CGFloat cornerRadius = 7;
    CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
    CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
    CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
    CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
    layer.path = pathRef;
    CFRelease(pathRef);
    layer.fillColor = [UIColor grayColor].CGColor;
    [self.selectView.layer addSublayer:layer];
    self.selectView.alpha = 0.3;
}
- (void)hiddenSelectView{
    self.selectView.hidden = YES;
}
@end
