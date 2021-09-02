//
//  ReplyCell.m
//  shiku_im
//
//  Created by Apple on 16/6/25.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "ReplyCell.h"

@implementation ReplyCell

@synthesize label;
-(void)prepareForReuse
{
    self.label.match=nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    self.pointIndex = point.x/10;
//    printf("point = %lf,%lf\n", point.x, point.y);
//    [self setNeedsDisplay];
    [super touchesEnded:touches withEvent:event];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
