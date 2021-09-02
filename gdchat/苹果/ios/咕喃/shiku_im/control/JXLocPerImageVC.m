//
//  JXLocPerImageVC.m
//  shiku_im
//
//  Created by Apple on 16/10/23.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXLocPerImageVC.h"

@implementation JXLocPerImageVC



-(id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        [self creatUI];
    }
    return self;
}


-(void)creatUI{
    //自定义图片view
    _headView = [[UIView alloc]initWithFrame:CGRectMake(-25, -60, 50, 60)];
    _headView.backgroundColor = [UIColor clearColor];
    _pointImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 60)];
    _pointImage.image = [UIImage imageNamed:@"locationAcc2"];
    [_headView addSubview:_pointImage];
    _headImage = [[JXImageView alloc]initWithFrame:CGRectMake(5, 3, 40, 40)];
    _headImage.layer.cornerRadius = 5;
    _headImage.clipsToBounds = YES;
    [_headView addSubview:_headImage];
    [self addSubview:_headView];
}

-(void)selectAnimation{
    [UIView animateWithDuration:0.3 animations:^{
        _headView.frame = CGRectMake(-30, -70, 60, 70);
        _pointImage.frame = CGRectMake(0, 0, 60, 70);
        _headImage.layer.cornerRadius = 5;
        _headImage.frame = CGRectMake(6, 2, 48, 48);
    }];
}

-(void)cancelSelectAnimation{
    [UIView animateWithDuration:0.3 animations:^{
        _headView.frame = CGRectMake(-25, -60, 50, 60);
        _pointImage.frame = CGRectMake(0, 0, 50, 60);
        _headImage.frame = CGRectMake(5, 3, 40, 40);
        _headImage.layer.cornerRadius = 5;
    }];
}

-(void)setData:(NSDictionary*)data andType:(int)dataType{

    [g_server getHeadImageSmall:[NSString stringWithFormat:@"%lld",[data[@"userId"] longLongValue]] userName:data[@"nickname"] imageView:_headImage getHeadHandler:nil];
   
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        CGPoint tempoint = [_headImage convertPoint:point fromView:self];
        if (CGRectContainsPoint(_headImage.bounds, tempoint))
        {
            view = _headImage;
        }
    }
    return view;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
