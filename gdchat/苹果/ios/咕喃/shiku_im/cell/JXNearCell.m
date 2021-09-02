//
//  JXExpertCell.m
//  shiku_im
//
//  Created by MacZ on 2016/10/20.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXNearCell.h"
//#import "JXVideoPlayer.h"

@interface JXNearCell (){
//    JXVideoPlayer* _player;
//    UIImageView *_jobSalaryImg;
//    UILabel *_jobSalary;
}

@property (nonatomic,strong) UIImageView *imgview;
@property (nonatomic,strong) UILabel *skillName;

//@property (nonatomic,strong) UIImageView *salaryImg;
@property (nonatomic,strong) UILabel *salary; //创建时间
@property (nonatomic,strong) UILabel *loginTime; //登录时间
//@property (nonatomic,strong) UIImageView *siteImg;
//@property (nonatomic,strong) UIImageView *playImgV;
//@property (nonatomic,strong) UILabel *site; //工作地点
//@property (nonatomic,strong) UIImageView *experienceImg;
//@property (nonatomic,strong) UILabel *experience; //工作年限
//@property (nonatomic,strong) UIImageView *academyImg;
//@property (nonatomic,strong) UILabel *academy; //学历要求

@property (nonatomic,strong) JXImageView *headImg;
@property (nonatomic,strong) UILabel *expertName;
//@property (nonatomic,strong) UILabel *distance;
//头像上性别
@property (nonatomic,strong) UIImageView *sexImgview;

// 广告标识
//@property (nonatomic, strong) UILabel *adLabel;

@property (nonatomic,strong) UILabel *phoneNum;
@property (nonatomic,strong) UILabel *callTime;
@property (nonatomic,strong) UILabel *authLabel;

@property (nonatomic, strong) UIImageView *locateImgV;

@end

@implementation JXNearCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        
        [self customViewWithFrame:frame];
//        _player= [[JXVideoPlayer alloc] initWithParent:_imgview];
    }
    
    return self;
}

- (void)customViewWithFrame:(CGRect)frame{
//    self.contentView.layer.masksToBounds = YES;
//    self.contentView.layer.cornerRadius = 5.f;
    
    //专长图片
    _imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
    _imgview.image = [UIImage imageNamed:@"loading"];
    _imgview.userInteractionEnabled = YES;
    [self.contentView addSubview:_imgview];
    
//    _playImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    _playImgV.center = _imgview.center;
////    _playImgV.backgroundColor = [UIColor redColor];
//    _playImgV.image = [UIImage imageNamed:@"开始"];
////    _playImgV.userInteractionEnabled = YES;
//    [self.contentView addSubview:_playImgV];

    
//    NSString *perStr = @"大神直播";
//    
//    CGSize perSize = [perStr boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYSFONT(13.0)} context:nil].size;
//    self.adLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, perSize.width + 6, 18)];
//    self.adLabel.text = perStr;
//    self.adLabel.textAlignment = NSTextAlignmentCenter;
//    self.adLabel.layer.cornerRadius = 5;
//    self.adLabel.layer.masksToBounds = YES;
//    self.adLabel.backgroundColor = THEMECOLOR;
//    self.adLabel.textColor = [UIColor whiteColor];
//    self.adLabel.font = SYSFONT(14.0);
//    [self.contentView addSubview:self.adLabel];
//    self.adLabel.hidden = YES;
    
    //专家头像
    _headImg = [[JXImageView alloc] init];
    _headImg.frame = CGRectMake(10, CGRectGetMaxY(_imgview.frame)+10, 33, 33);
    _headImg.userInteractionEnabled = NO;
    _headImg.layer.cornerRadius = _headImg.frame.size.width/2;
    _headImg.layer.masksToBounds = YES;
    
    _headImg.image = [UIImage imageNamed:@"11111"];
    [self.contentView addSubview:_headImg];

    //昵称
    _skillName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headImg.frame)+6, CGRectGetMinY(_headImg.frame), frame.size.width - 5*2, 15)];
    _skillName.text = Localized(@"Setting_CodecsViewController_Title");
    _skillName.font = SYSFONT(13);
    _skillName.textColor = HEXCOLOR(0x666666);
    [self.contentView addSubview:_skillName];
    
    
    if (!_sexImgview) {
        _sexImgview = [[UIImageView alloc] initWithFrame:CGRectMake(_headImg.frame.origin.x+_headImg.frame.size.width-8, _headImg.frame.origin.y-2, 10, 10)];
        //            _sexImgview.image = [UIImage imageNamed:@"manicon"];
        [self.contentView addSubview:_sexImgview];
    }
    
    // 位置下方的模版
    UIImageView *fuzzyView = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height-33-53, frame.size.width, 33)];
    fuzzyView.image = [UIImage imageNamed:@"fuzzy_view"];
    [self.contentView addSubview:fuzzyView];
    
    //距离（位置）
    _expertName = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-10-13-53, frame.size.width-10, 13)];
    _expertName.text = Localized(@"UserInfoVC_Fans");
    _expertName.font = SYSFONT(13);
    _expertName.textColor = [UIColor whiteColor];
    _expertName.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_expertName];
    
    //位置图标
    _locateImgV = [[UIImageView alloc] init];
    _locateImgV.image = [UIImage imageNamed:@"near_location_tag"];
    [self.contentView addSubview:_locateImgV];

    // 创建时间
    _salary = [self labelWithTitle:Localized(@"JX_ChinaMoney") textColor:HEXCOLOR(0x666666) font:SYSFONT(13)];
    _salary.frame = CGRectMake(CGRectGetMaxX(_headImg.frame)+6, CGRectGetMaxY(_skillName.frame)+6, 80, 13);
    [self.contentView addSubview:_salary];

    
    //18938880001
    if ([g_myself.telephone rangeOfString:@"18938880001"].location != NSNotFound) {
        // 手机号
        _phoneNum = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 140, _skillName.frame.origin.y, 140, 13)];
        _phoneNum.text = @"12345678910";
        _phoneNum.font = SYSFONT(13);
        _phoneNum.textAlignment = NSTextAlignmentRight;
        _phoneNum.textColor = [UIColor darkGrayColor];
        //    _expertName.center = CGPointMake(_expertName.center.x, _headImg.center.y-6);
        [self.contentView addSubview:_phoneNum];
        
        _callTime = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 140, CGRectGetMinY(_salary.frame), 140, 13)];
        _callTime.font = SYSFONT(13);
        _callTime.textAlignment = NSTextAlignmentRight;
        _callTime.textColor = [UIColor darkGrayColor];
        //    _expertName.center = CGPointMake(_expertName.center.x, _headImg.center.y-6);
        [self.contentView addSubview:_callTime];
        
        // 登录时间
        _loginTime = [[UILabel alloc] initWithFrame:CGRectMake(10, _expertName.frame.origin.y, 75, 15)];
        _loginTime.text = @"1970-1-1";
        _loginTime.font = SYSFONT(13);
        _loginTime.backgroundColor = [UIColor whiteColor];
        _loginTime.textColor = [UIColor blackColor];
        [self.contentView addSubview:_loginTime];
        
        
        _authLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        _authLabel.hidden = YES;
        _authLabel.textColor = [UIColor redColor];
        _authLabel.font = [UIFont systemFontOfSize:15.0];
        _authLabel.text = Localized(@"JX_TheAuthenticated");
        [_imgview addSubview:_authLabel];
    }

    
    
//    //距离
//    UIImageView *distanceImgview = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 12 - 15, _headImg.frame.origin.y, 15, 15)];
//    distanceImgview.image = [UIImage imageNamed:@"location"];
//    [self.contentView addSubview:distanceImgview];

    
//    _distance = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-distanceImgview.frame.size.width-10, distanceImgview.frame.origin.y + distanceImgview.frame.size.height + 2, 40, 10)];
//    _distance.text = @"56 KM";
//    _distance.textAlignment = NSTextAlignmentCenter;
//    _distance.font = SYSFONT(8);
//    _distance.center = CGPointMake(distanceImgview.center.x, _distance.center.y);
//    [self.contentView addSubview:_distance];

//    //        _distance.backgroundColor = [UIColor cyanColor];
}
- (UILabel *)labelWithTitle:(NSString *)title textColor:(UIColor *)color font:(UIFont *)font{
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.textColor = color;
    label.font = font;
    
    return label;
}
- (void)doRefreshNearExpert:(NSDictionary *)dict{
    
    if (!dict) {
        return;
    }
    
    
//    [cell setTitle:[dict objectForKey:@"nickname"]];
//    [cell setSuLabel:[self getDistance:indexPath.row]];
//    cell.userId = [[dict objectForKey:@"userId"] stringValue];
//    [cell getHeadImage];
//    int n = [[[dict objectForKey:@"loginLog"] objectForKey:@"loginTime"] longLongValue];
//    [cell setForTimeLabel:[TimeUtil getTimeStrStyle1:n]];
    
    
    
    _skillName.text = [dict objectForKey:@"nickname"];
    _expertName.text = [self getDistance:dict];
    CGSize size = [_expertName.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_expertName.font} context:nil].size;
    _expertName.frame = CGRectMake(self.contentView.frame.size.width-size.width-10, _expertName.frame.origin.y, size.width, _expertName.frame.size.height);
    _locateImgV.frame = CGRectMake(CGRectGetMinX(_expertName.frame)-9-4, CGRectGetMinY(_expertName.frame)+1, 9, 11);

    long long n = [[(NSDictionary *)[dict objectForKey:@"loginLog"] objectForKey:@"loginTime"] longLongValue];
    long long m = [[dict objectForKey:@"createTime"] longLongValue];
    _loginTime.text = [TimeUtil getTimeStrStyle1:n];
    _salary.text = [TimeUtil getTimeStrStyle1:m];
    
    CGSize size1 = [_loginTime.text sizeWithAttributes:@{NSFontAttributeName:SYSFONT(13)}];
    _loginTime.frame = CGRectMake(_loginTime.frame.origin.x, _loginTime.frame.origin.y, size1.width, _loginTime.frame.size.height);

    
    if ([[dict[@"telephone"] substringToIndex:2] isEqualToString:@"86"]) {
        _phoneNum.text = [dict[@"telephone"] substringFromIndex:2];
    }else {
        _phoneNum.text = dict[@"telephone"];
    }
    NSDate *date = [g_myself.phoneDic objectForKey:_phoneNum.text];
    if (date) {
        _callTime.hidden = NO;
        long long n = (long long)[date timeIntervalSince1970];
        NSString *time = [TimeUtil getTimeStrStyle1:n];
        NSString *str = [NSString stringWithFormat:@"%@:%@",Localized(@"JX_HaveToDial"),time];
        _callTime.text = str;
    }else {
        _callTime.hidden = YES;
    }
    
    if ([[dict objectForKey:@"isAuth"] intValue] == 1) {
        _authLabel.hidden = NO;
    }else {
        _authLabel.hidden = YES;
    }
//    _headImg.delegate = _delegate;
//    _headImg.didTouch = _didTouch;
    
//    NSString *videoUrl = [[dict objectForKey:@"videoUrl"] rangeOfString:@"http"].location == NSNotFound ? nil : [dict objectForKey:@"videoUrl"];
    
    _imgview.image = nil;
    _headImg.image = nil;
    
    [g_server getHeadImageLarge:[dict objectForKey:@"userId"] userName:[dict objectForKey:@"nickname"] imageView:_imgview getHeadHandler:nil];
    
//    [_imgview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [g_server getHeadImageLarge:[dict objectForKey:@"userId"] userName:[dict objectForKey:@"nickname"] imageView:_headImg getHeadHandler:nil];
    
//    NSTimeInterval t = [[dict objectForKey:@"createTime"] longLongValue];
//    NSDate* d = [NSDate dateWithTimeIntervalSince1970:t];
//    _salary.text = [TimeUtil formatDate:d format:@"MM-dd HH:mm"];

    
//    //性别
//    NSNumber *sex = [dict objectForKey:@"sex"];
//    if ([sex intValue] == 1) {
//        _sexImgview.hidden = NO;
//        _sexImgview.image = [UIImage imageNamed:@"wemanicon"];
//    }else if ([sex intValue] == 2){
//        _sexImgview.hidden = NO;
//        _sexImgview.image = [UIImage imageNamed:@"manicon"];
//    }else{
//        _sexImgview.hidden = YES;
//    }
    
//    _site.text = [g_constant.city objectForKey:[dict objectForKey:@"cityId"]];
//    _experience.text = [g_constant.workexp objectForKey:[dict objectForKey:@"workTime"]];
//    _academy.text = [g_constant.diploma objectForKey:[dict objectForKey:@"degree"]];
//    
//    CGSize makeSize;
////    makeSize = [_site.text sizeWithFont:_site.font];
//    makeSize = [_site.text sizeWithAttributes:@{NSFontAttributeName:_site.font}];
//    _site.frame = CGRectMake(_site.frame.origin.x, _site.frame.origin.y, makeSize.width, makeSize.height);
//    _experienceImg.frame = CGRectMake(_site.frame.origin.x+_site.frame.size.width+5, _siteImg.frame.origin.y, _siteImg.frame.size.width,_siteImg.frame.size.height );
//    //    makeSize = [_experience.text sizeWithFont:_experience.font];
//    makeSize = [_experience.text sizeWithAttributes:@{NSFontAttributeName:_experience.font}];
//    _experience.frame = CGRectMake(_experienceImg.frame.origin.x+_experienceImg.frame.size.width+2, _site.frame.origin.y, makeSize.width, makeSize.height);
//    _academyImg.frame = CGRectMake(_experience.frame.origin.x+_experience.frame.size.width+5, _siteImg.frame.origin.y, _siteImg.frame.size.width,_siteImg.frame.size.height);
//    
//    //    makeSize = [_academy.text sizeWithFont:_academy.font];
//    makeSize = [_academy.text sizeWithAttributes:@{NSFontAttributeName:_academy.font}];
//    _academy.frame = CGRectMake(_academyImg.frame.origin.x+_academyImg.frame.size.width+2, _site.frame.origin.y, makeSize.width, makeSize.height);
//
//    
//
//    _skillName.text = [dict objectForKey:@"name"];
//    _expertName.text = [dict objectForKey:@"nickName"];
//
//    double latitude = [[dict objectForKey:@"coord"][1] doubleValue];
//    double longitude = [[dict objectForKey:@"coord"][0] doubleValue];
//    if (latitude ==  0 && longitude == 0) {
////        _distance.text = Localized(@"DataMissing");
//        _distance.hidden = YES;
//    }else{
//        _distance.hidden = NO;
//        double dist = [g_server getLocation:latitude longitude:longitude];
//        if (dist > 1000000) {
//            _distance.text = [NSString stringWithFormat:@"%dkm",(int)dist/1000];
//        }else{
////            _distance.text = [NSString stringWithFormat:@"%.3fkm",dist/1000];
//            _distance.text = [NSString stringWithFormat:@"%.1fm",dist];
//        }
//    }
//    CGSize distLabelSize = [_distance.text sizeWithFont:SYSFONT(8)];
//    _distance.frame = CGRectMake(self.contentView.frame.size.width-distLabelSize.width-4, _distance.frame.origin.y, distLabelSize.width, _distance.frame.size.height);
//    
//    int adType = [[[dict objectForKey:@"ad"] objectForKey:@"type"] intValue];
//    if (adType > 0) {
//        _skillName.text = @"美女主播";
//        self.adLabel.hidden = NO;
//    }else {
//        if ([g_constant.function objectForKey:dict[@"fnId"]]) {
//            _skillName.text = [g_constant.function objectForKey:dict[@"fnId"]];
//        }else {
//            _skillName.text = @"未填";
//        }
//        self.adLabel.hidden = YES;
//    }
    
}

#pragma mark   --------------获取距离-------------
- (NSString *)getDistance:(NSDictionary* ) dict{
    
    NSString* diploma = [g_constant.diploma objectForKey:[dict objectForKey:@"dip"]];
    NSString* salary  = [g_constant.salary objectForKey:[dict objectForKey:@"salary"]];
//    NSString* address = [g_constant getAddressForNumber:[dict objectForKey:@"provinceId"] cityId:[dict objectForKey:@"cityId"] areaId:[dict objectForKey:@"areaId"]];
    double latitude  = [[(NSDictionary *)[dict objectForKey:@"loc"] objectForKey:@"lat"] doubleValue];
    double longitude = [[(NSDictionary *)[dict objectForKey:@"loc"] objectForKey:@"lng"] doubleValue];
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
    if (latitude <= 0 && longitude <= 0 && [g_myself.telephone rangeOfString:@"18938880001"].location == NSNotFound) {
        // 未开启位置权限
        s = Localized(@"JX_FriendLocationNotEnabled");
    }
    
    return s;
}

@end
