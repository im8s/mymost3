//
//  JXNearTableViewCell.m
//  lveliao_IM
//
//  Created by liangjian on 2020/3/10.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "JXNearTableViewCell.h"
#import "UIView+Frame.h"

@interface JXNearTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UILabel *distanceL;


@end
@implementation JXNearTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headImageView.layer.cornerRadius = 5;
    // Initialization code
}
- (void)doRefreshNearExpert:(NSDictionary *)dict{
    
    if (!dict) {
        return;
    }
    self.nameL.text = [dict objectForKey:@"nickname"];
    self.distanceL.text = [self getDistance:dict];
    NSDictionary * loginlogDic = [dict objectForKey:@"loginLog"];
    NSString* loginTime = [loginlogDic objectForKey:@"loginTime"];
    long long n = [loginTime longLongValue];
    long long m = [[dict objectForKey:@"createTime"] longLongValue];
    self.timeL.text = [TimeUtil getTimeStrStyle1:m];
     
//    NSString *sex = [dict objectForKey:@"sex"];;
    
    //性别
    NSNumber *sex = [dict objectForKey:@"sex"];
    if ([sex intValue] == 0) {
        self.sexImageView.hidden = NO;
        self.sexImageView.image = [UIImage imageNamed:@"ic_new_nv"];
    }else if ([sex intValue] == 1){
        self.sexImageView.hidden = NO;
        self.sexImageView.image = [UIImage imageNamed:@"ic_new_nan"];
    }else{
        self.sexImageView.hidden = YES;
    }
    
//    [_imgview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [g_server getHeadImageLarge:[dict objectForKey:@"userId"] userName:[dict objectForKey:@"nickname"] imageView:self.headImageView];
    

    
}

#pragma mark   --------------获取距离-------------
- (NSString *)getDistance:(NSDictionary* ) dict{
    
    NSString* diploma = [g_constant.diploma objectForKey:[dict objectForKey:@"dip"]];
    NSString* salary  = [g_constant.salary objectForKey:[dict objectForKey:@"salary"]];
//    NSString* address = [g_constant getAddressForNumber:[dict objectForKey:@"provinceId"] cityId:[dict objectForKey:@"cityId"] areaId:[dict objectForKey:@"areaId"]];
     NSDictionary * locDic = [dict objectForKey:@"loc"];
    double latitude  = [[locDic objectForKey:@"lat"] doubleValue];
    double longitude = [[locDic objectForKey:@"lng"] doubleValue];
    double m = [g_server getLocation:latitude longitude:longitude];
    NSString* s=[NSString stringWithFormat:@"%.2lfkm ",m/1000];
    
    //        if(address)
    //            s = [s stringByAppendingString:address];
    if(diploma){
        s = [s stringByAppendingString:@" | "];
        s = [s stringByAppendingString:diploma];
    }
    if(salary){
        s = [s stringByAppendingString:@" | "];
        s = [s stringByAppendingString:salary];
    }
    if (latitude <= 0 && longitude <= 0 && ![g_myself.telephone isEqualToString:@"18938880001"]) {
        // 未开启位置权限
        s = Localized(@"JX_FriendLocationNotEnabled");
    }
    
    return s;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
