//
//  JXLocMapVC.m
//  shiku_im
//
//  Created by Apple on 16/10/19.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXLocMapVC.h"
#import "JXLocPerImageVC.h"
//#import "JXNewResumeInfoVC.h"
#import <BMKLocationKit/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//只引入所需的单个头文件
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
//#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
#import "JXUserInfoVC.h"

@interface JXLocMapVC ()<BMKMapViewDelegate,BMKLocationManagerDelegate>{
    BMKMapView * _imageMapView;
    BMKLocationManager *_locationManager;
}

@end

@implementation JXLocMapVC


- (instancetype)initWithFrame:(CGRect)frame andType:(int)dataType
{
    self = [super init];
    if (self) {
        _wait = [ATMHud sharedInstance];
        self.view.frame = frame;
        _nearbyData = [NSMutableArray new];
        _allAnnotationView = [NSMutableArray new];
        _dataType = dataType;
        [self customView];
//        [self getServerData];
    }
    return self;
}
- (void)dealloc{
//    [_nearbyData release];
//    [_allAnnotationView release];
//    
//    [super dealloc];
    _nearbyData = nil;
    _allAnnotationView = nil;
    
}
- (void)customView{
    [self initBaiduMapView];
    //复位
    _resetLoca = [[UIButton alloc]initWithFrame:CGRectMake(20,self.view.frame.size.height -40, 30, 30)];
    [_resetLoca setImage:[UIImage imageNamed:@"ic_greeting_checked"] forState:UIControlStateNormal];
    [_resetLoca addTarget:self action:@selector(resetLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_resetLoca];
//    [_resetLoca release];
    
    //上方的滚动条
//    UIView * topBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 40)];
//    topBackground.backgroundColor = [UIColor whiteColor];
//    _topScrolView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 40)];
//    _topScrolView.tag = 11;
//    _topScrolView.showsHorizontalScrollIndicator = NO;
//    _topScrolView.delegate = self;
//    _topScrolView.contentSize = CGSizeMake(80*9, 0);
//    [self.view addSubview:topBackground];
//    [topBackground addSubview:_topScrolView];
    
    //滚动条上面的按钮
//    NSArray * nameArr = @[@"Java",@"iOS",@"保姆",@"短工",@"家教",@"维修",@"买卖",@"寻物",@"交友"];
//    int buttonWidth = 80;
//    for (int i = 0; i < [nameArr count]; i ++) {
//        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(i*buttonWidth, 0, buttonWidth, 38)];
//        [btn setTitle:[nameArr objectAtIndex:i] forState:UIControlStateNormal];
//        btn.tag = i+100;
//        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btn setTitleColor:OVERALL_BLUE_COLOR forState:UIControlStateSelected];
//        [btn addTarget:self action:@selector(topScrollBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//        [_topScrolView addSubview:btn];
//    }
    //滚动条下面的滚动View
//    _topMinView = [[UIView alloc]initWithFrame:CGRectMake(15, 38, buttonWidth -30, 2)];
//    _topMinView.backgroundColor = OVERALL_BLUE_COLOR;
//    [_topScrolView addSubview:_topMinView];
    //职位详情ScrollView
    _scrollBackground = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height + 100, JX_SCREEN_WIDTH, 100)];
    _resumeScrolView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 100)];
    _resumeScrolView.tag = 12;
    _resumeScrolView.showsHorizontalScrollIndicator = NO;
    _resumeScrolView.delegate = self;
    _resumeScrolView.hidden = YES;//用于判断是否在可见区域
    _resumeScrolView.contentSize = CGSizeMake(JX_SCREEN_WIDTH *3, 100);
    _resumeScrolView.pagingEnabled = YES;
    [self.view addSubview:_scrollBackground];
    [_scrollBackground addSubview:_resumeScrolView];
//    [_resumeScrolView release];
    
    //创建ScrollView里面三个视图
    _jobDetailOne = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 100)];
    _jobDetailOne.tag = 1;
    [self creatJobDetailView:_jobDetailOne];
    [_resumeScrolView addSubview:_jobDetailOne];//创建视图里的所有控件
//    [_jobDetailOne release];
    _jobDetailTwo = [[UIView alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH , 0, JX_SCREEN_WIDTH, 100)];
    _jobDetailTwo.tag = 2;
    [self creatJobDetailView:_jobDetailTwo];//创建视图里的所有控件
    [_resumeScrolView addSubview:_jobDetailTwo];
//    [_jobDetailTwo release];
    _jobDetailThree = [[UIView alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH*2, 0, JX_SCREEN_WIDTH, 100)];
    _jobDetailThree.tag = 3;
    [self creatJobDetailView:_jobDetailThree];//创建视图里的所有控件
    [_resumeScrolView addSubview:_jobDetailThree];
//    [_jobDetailThree release];
    
    //放大缩小
    _scaleView = [[UIView alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 100, self.view.frame.size.height - 40, 90, 30)];
    _scaleView.backgroundColor = [UIColor whiteColor];
    _scaleView.layer.cornerRadius = 15;
    _scaleView.clipsToBounds = YES;
    [self.view addSubview:_scaleView];
//    [_scaleView release];
    UIButton * narrowButton = [[UIButton alloc]initWithFrame:CGRectMake(15, 0, 30, 30)];
    [narrowButton setImage:[UIImage imageNamed:@"lose"] forState:UIControlStateNormal];
    narrowButton.tag = 10001;
    [narrowButton addTarget:self action:@selector(doScale:) forControlEvents:UIControlEventTouchUpInside];
    narrowButton.layer.cornerRadius = 15;
    narrowButton.clipsToBounds = YES;
    [_scaleView addSubview:narrowButton];
//    [narrowButton release];
    UIButton * enlargeButton = [[UIButton alloc]initWithFrame:CGRectMake(45, 0, 30, 30)];
    [enlargeButton setImage:[UIImage imageNamed:@"enlarge"] forState:UIControlStateNormal];
    [enlargeButton addTarget:self action:@selector(doScale:) forControlEvents:UIControlEventTouchUpInside];
    enlargeButton.layer.cornerRadius = 15;
    enlargeButton.clipsToBounds = YES;
    enlargeButton.tag = 10002;
    [_scaleView addSubview:enlargeButton];
//    [enlargeButton release];
    
    //当前位置图标
//    UIImageView * pointImage = [[UIImageView alloc]initWithFrame:CGRectMake((JX_SCREEN_WIDTH - 20) /2, (JX_SCREEN_HEIGHT - 25 +64)/2, 20, 25)];
//    pointImage.image = [UIImage imageNamed:@"location"];
//    pointImage.userInteractionEnabled = NO;
//    [self.view addSubview:pointImage];
//    [pointImage release];
}

-(void)creatJobDetailView:(UIView*)jobView{
    //白色背景
    UIButton * detailButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 0, JX_SCREEN_WIDTH-40, 90)];
    [detailButton addTarget:self action:@selector(showDetailResume:) forControlEvents:UIControlEventTouchUpInside];
    detailButton.backgroundColor = [UIColor whiteColor];
//    detailButton.tag = 1000 + jobView.tag;
    detailButton.layer.cornerRadius = 5;
    detailButton.clipsToBounds = YES;
    [jobView addSubview:detailButton];
//    [detailButton release];
    //灰色背景
//    UIView * grayView = [[UIView alloc]initWithFrame:CGRectMake(20, 50, JX_SCREEN_WIDTH - 40, 40)];
//    grayView.backgroundColor = OVERALL_LIGHT_GRAY;
//    grayView.layer.cornerRadius = 5;
//    grayView.clipsToBounds = YES;
//    [jobView addSubview:grayView];
//    [grayView release];
    if (jobView.tag == 1) {
        //标题
        _titleLabelOne = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, JX_SCREEN_WIDTH - 160, 20)];
        [jobView addSubview:_titleLabelOne];
//        [_titleLabelOne release];
        //付费方式
        _payLabelOne = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 180 + 30, 5, 110, 20)];
        _payLabelOne.textAlignment = NSTextAlignmentRight;
        _payLabelOne.font = [UIFont systemFontOfSize:11];
        [jobView addSubview:_payLabelOne];
//        [_payLabelOne release];
        //详情
        _detailLabelOne = [[UILabel alloc]initWithFrame:CGRectMake(30, 28, JX_SCREEN_WIDTH - 100, 15)];
        _detailLabelOne.font = [UIFont systemFontOfSize:10];
        _detailLabelOne.numberOfLines = 2;
        [jobView addSubview:_detailLabelOne];
//        [_detailLabelOne release];
        //头像
        _headImageOne = [[UIImageView alloc]initWithFrame:CGRectMake(30, 53, 30, 30)];
        _headImageOne.layer.cornerRadius = 5;
        _headImageOne.clipsToBounds = YES;
        [jobView addSubview:_headImageOne];
//        [_headImageOne release];
        //昵称
        _nameLabelOne = [[UILabel alloc]initWithFrame:CGRectMake(65, 60, 200, 15)];
        _nameLabelOne.font = [UIFont systemFontOfSize:11];
        [jobView addSubview:_nameLabelOne];
//        [_nameLabelOne release];
        //认证
//        _identImageOne = [[UIImageView alloc]initWithFrame:CGRectMake(65, 68, 15, 15)];
//        _identImageOne.image = [UIImage imageNamed:[JXMyTools verImgName:@"ic_website"]];
//        _identImageOne.layer.cornerRadius = 2;
//        _identImageOne.clipsToBounds = YES;
//        [jobView addSubview:_identImageOne];
//        [_identImageOne release];
        //信誉积分背景
//        _integralImageOne = [[UIImageView alloc]initWithFrame:CGRectMake(85, 68, 40, 15)];
//        _integralImageOne.image = [UIImage imageNamed:@"feaBtn_backImg_lightGreen"];
//        _integralImageOne.layer.cornerRadius = 2;
//        _integralImageOne.clipsToBounds = YES;
//        [jobView addSubview:_integralImageOne];
//        [_integralImageOne release];
        //信誉积分
//        _integralLabelOne = [[UILabel alloc]initWithFrame:CGRectMake(95, 68, 30, 15)];
//        _integralLabelOne.font = [UIFont systemFontOfSize:13];
//        [jobView addSubview:_integralLabelOne];
//        [_integralLabelOne release];
        //距离
        _distanceLabelOne = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 180 + 30, 60, 110, 20)];
        _distanceLabelOne.textAlignment = NSTextAlignmentRight;
        _distanceLabelOne.font = [UIFont systemFontOfSize:11];
        [jobView addSubview:_distanceLabelOne];
//        [_distanceLabelOne release];
    }
    if (jobView.tag == 2) {
        //标题
        _titleLabelTwo = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, JX_SCREEN_WIDTH - 160, 20)];
        [jobView addSubview:_titleLabelTwo];
//        [_titleLabelTwo release];
        //付费方式
        _payLabelTwo = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 180 + 30, 5, 110, 20)];
        _payLabelTwo.textAlignment = NSTextAlignmentRight;
        _payLabelTwo.font = [UIFont systemFontOfSize:11];
        [jobView addSubview:_payLabelTwo];
//        [_payLabelTwo release];
        //详情
        _detailLabelTwo = [[UILabel alloc]initWithFrame:CGRectMake(30, 28, JX_SCREEN_WIDTH - 100, 15)];
        _detailLabelTwo.font = [UIFont systemFontOfSize:10];
        _detailLabelTwo.numberOfLines = 2;
        [jobView addSubview:_detailLabelTwo];
//        [_detailLabelTwo release];
        //头像
        _headImageTwo = [[UIImageView alloc]initWithFrame:CGRectMake(30, 53, 30, 30)];
        _headImageTwo.layer.cornerRadius = 5;
        _headImageTwo.clipsToBounds = YES;
        [jobView addSubview:_headImageTwo];
//        [_headImageTwo release];
        //昵称
        _nameLabelTwo = [[UILabel alloc]initWithFrame:CGRectMake(65, 60, 200, 15)];
        _nameLabelTwo.font = [UIFont systemFontOfSize:11];
        [jobView addSubview:_nameLabelTwo];
//        [_nameLabelTwo release];
        //认证
//        _identImageTwo = [[UIImageView alloc]initWithFrame:CGRectMake(65, 68, 15, 15)];
//        _identImageTwo.image = [UIImage imageNamed:[JXMyTools verImgName:@"ic_website"]];
//        _identImageTwo.layer.cornerRadius = 2;
//        _identImageTwo.clipsToBounds = YES;
//        [jobView addSubview:_identImageTwo];
////        [_identImageTwo release];
//        //信誉积分背景
//        _integralImageTwo = [[UIImageView alloc]initWithFrame:CGRectMake(85, 68, 40, 15)];
//        _integralImageTwo.image = [UIImage imageNamed:@"feaBtn_backImg_lightGreen"];
//        _integralImageTwo.layer.cornerRadius = 2;
//        _integralImageTwo.clipsToBounds = YES;
//        [jobView addSubview:_integralImageTwo];
////        [_integralImageTwo release];
//        //信誉积分
//        _integralLabelTwo = [[UILabel alloc]initWithFrame:CGRectMake(95, 68, 30, 15)];
//        _integralLabelTwo.font = [UIFont systemFontOfSize:13];
//        [jobView addSubview:_integralLabelTwo];
//        [_integralLabelTwo release];
        //距离
        _distanceLabelTwo = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 180 + 30, 60, 110, 20)];
        _distanceLabelTwo.textAlignment = NSTextAlignmentRight;
        _distanceLabelTwo.font = [UIFont systemFontOfSize:11];
        [jobView addSubview:_distanceLabelTwo];
//        [_distanceLabelTwo release];
    }
    if (jobView.tag == 3) {
        //标题
        _titleLabelThree = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, JX_SCREEN_WIDTH - 160, 20)];
        [jobView addSubview:_titleLabelThree];
//        [_titleLabelThree release];
        //付费方式
        _payLabelThree = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 180 + 30, 5, 110, 20)];
        _payLabelThree.textAlignment = NSTextAlignmentRight;
        _payLabelThree.font = [UIFont systemFontOfSize:11];
        [jobView addSubview:_payLabelThree];
//        [_payLabelThree release];
        //详情
        _detailLabelThree = [[UILabel alloc]initWithFrame:CGRectMake(30, 28, JX_SCREEN_WIDTH - 100, 15)];
        _detailLabelThree.font = [UIFont systemFontOfSize:10];
        _detailLabelThree.numberOfLines = 2;
        [jobView addSubview:_detailLabelThree];
//        [_detailLabelThree release];
        //头像
        _headImageThree = [[UIImageView alloc]initWithFrame:CGRectMake(30, 53, 30, 30)];
        _headImageThree.layer.cornerRadius = 5;
        _headImageThree.clipsToBounds = YES;
        [jobView addSubview:_headImageThree];
//        [_headImageThree release];
        //昵称
        _nameLabelThree = [[UILabel alloc]initWithFrame:CGRectMake(65, 60, 200, 15)];
        _nameLabelThree.font = [UIFont systemFontOfSize:11];
        [jobView addSubview:_nameLabelThree];
//        [_nameLabelThree release];
        //认证
//        _identImageThree = [[UIImageView alloc]initWithFrame:CGRectMake(65, 68, 15, 15)];
//        _identImageThree.image = [UIImage imageNamed:[JXMyTools verImgName:@"ic_website"]];
//        _identImageThree.layer.cornerRadius = 2;
//        _identImageThree.clipsToBounds = YES;
//        [jobView addSubview:_identImageThree];
////        [_identImageThree release];
//        //信誉积分背景
//        _integralImageThree = [[UIImageView alloc]initWithFrame:CGRectMake(85, 68, 40, 15)];
//        _integralImageThree.image = [UIImage imageNamed:@"feaBtn_backImg_lightGreen"];
//        _integralImageThree.layer.cornerRadius = 2;
//        _integralImageThree.clipsToBounds = YES;
//        [jobView addSubview:_integralImageThree];
////        [_integralImageThree release];
//        //信誉积分
//        _integralLabelThree = [[UILabel alloc]initWithFrame:CGRectMake(95, 68, 30, 15)];
//        _integralLabelThree.font = [UIFont systemFontOfSize:13];
//        [jobView addSubview:_integralLabelThree];
//        [_integralLabelThree release];
        //距离
        _distanceLabelThree = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 180 + 30, 60, 110, 20)];
        _distanceLabelThree.textAlignment = NSTextAlignmentRight;
        _distanceLabelThree.font = [UIFont systemFontOfSize:11];
        [jobView addSubview:_distanceLabelThree];
//        [_distanceLabelThree release];
    }
}
//点击标签时，加载数据
- (void)setData:(int)centerIndex{
    if (centerIndex == 0) {
        [self setOneData:centerIndex];
        [_resumeScrolView setContentOffset:CGPointMake(0, 0)];
        if ([_nearbyData count] > 1) {
            [self setTwoData:centerIndex +1];
        }
        
    }else if (centerIndex+1 < [_nearbyData count]) {
        [self setTwoData:centerIndex];
        [_resumeScrolView setContentOffset:CGPointMake(JX_SCREEN_WIDTH, 0)];
        [self setOneData:centerIndex -1];
        [self setThreeData:centerIndex +1];
        
    }else{
        [self setThreeData:centerIndex];
        [_resumeScrolView setContentOffset:CGPointMake(JX_SCREEN_WIDTH *2, 0)];
        [self setTwoData:centerIndex -1];
    }
}
#pragma mark ------------------填充数据------------------
-(void)setOneData:(int)centerIndex{
    NSDictionary * dataDict = [_nearbyData objectAtIndex:centerIndex];
    //标题
    _titleLabelOne.text = dataDict[@"nickname"];
    
    //付费方式
    _payLabelOne.text = dataDict[@"telephone"];
    
    //详情
    //    _detailLabelTwo.text = twoData[@"loc"][@"lat"];
    //头像
    [g_server getHeadImageSmall:[NSString stringWithFormat:@"%lld",[dataDict[@"userId"] longLongValue]] userName:dataDict[@"nickname"] imageView:_headImageOne getHeadHandler:nil];
    
    //昵称
    //    _nameLabelOne.text = dataDict[@"nickname"];
    
    //距离
    _distanceLabelOne.text = [NSString stringWithFormat:@"%.3fkm",[g_server getLocation:[dataDict[@"loc"][@"lat"] doubleValue] longitude:[dataDict[@"loc"][@"lng"] doubleValue]]/1000];

}
-(void)setTwoData:(int)centerIndex{
    NSDictionary * dataDict = [_nearbyData objectAtIndex:centerIndex];
    //标题
    _titleLabelTwo.text = dataDict[@"nickname"];
    
    //付费方式
    _payLabelTwo.text = dataDict[@"telephone"];
    
    //详情
//    _detailLabelTwo.text = twoData[@"loc"][@"lat"];
    //头像
    [g_server getHeadImageSmall:[NSString stringWithFormat:@"%lld",[dataDict[@"userId"] longLongValue]] userName:dataDict[@"nickname"] imageView:_headImageTwo getHeadHandler:nil];
    
    //昵称
//    _nameLabelTwo.text = twoData[@"nickname"];
    
    //距离
    _distanceLabelTwo.text = [NSString stringWithFormat:@"%.3fkm",[g_server getLocation:[dataDict[@"loc"][@"lat"] doubleValue] longitude:[dataDict[@"loc"][@"lng"] doubleValue]]/1000];
}
-(void)setThreeData:(int)centerIndex{
    NSDictionary * dataDict = [_nearbyData objectAtIndex:centerIndex];
    //标题
    _titleLabelThree.text = dataDict[@"nickname"];
    
    //付费方式
    _payLabelThree.text = dataDict[@"telephone"];
    
    //详情
    //    _detailLabelTwo.text = twoData[@"loc"][@"lat"];
    //头像
    [g_server getHeadImageSmall:[NSString stringWithFormat:@"%lld",[dataDict[@"userId"] longLongValue]] userName:dataDict[@"nickname"] imageView:_headImageThree getHeadHandler:nil];
    
    //昵称
    //    _nameLabelTwo.text = twoData[@"nickname"];
    
    //距离
    _distanceLabelThree.text = [NSString stringWithFormat:@"%.3fkm",[g_server getLocation:[dataDict[@"loc"][@"lat"] doubleValue] longitude:[dataDict[@"loc"][@"lng"] doubleValue]]/1000];
}
#pragma mark ---------------------viewDidLoad---------------------
- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated{
}

-(void)viewWillAppear:(BOOL)animated
{
    [_imageMapView viewWillAppear];
    if (_imageMapView.delegate == nil) {
        _imageMapView.delegate = self; //此处记得不用的时候需要置nil，否则影响内存的释放
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_imageMapView viewWillDisappear];
    _imageMapView.delegate = nil; // 不用时，置nil
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initBaiduMapView{
    _imageMapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, self.view.frame.size.height)];
    _imageMapView.delegate = self;
    [self.view addSubview:_imageMapView];
//    [_imageMapView release];
    _imageMapView.zoomLevel = 13;
    _imageMapView.showsUserLocation = YES;
//    [_imageMapView updateLocationData:userLocation];
    //定位服务
    if (_locationManager == nil) {
        _locationManager = [[BMKLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    [_locationManager startUpdatingLocation];
}
#pragma mark ----------------------ScrollViewDelegate----------------
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView.tag == 12) {
        _lastContentSet = _resumeScrolView.contentOffset;
        _resumeScrolView.userInteractionEnabled = NO;
    }
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.tag == 12) {
        if (_lastContentSet.x > _resumeScrolView.contentOffset.x) {
            _direction = -1;//左
        }else{
            _direction = 1;//右
        }
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.tag == 12) {
        if (fabs(_lastContentSet.x - _resumeScrolView.contentOffset.x) < 300) {
            _resumeScrolView.userInteractionEnabled = YES;
            return;
        }
        
        if (_direction == -1) {
            _currentIndex -= 1;
        }else if (_direction == 1) {
            _currentIndex += 1;
        }
        
        if (_currentIndex != [_nearbyData count] -1 && _currentIndex != 0) {
            //设置中间view的数据
            [self setTwoData:_currentIndex];
            [_resumeScrolView setContentOffset:CGPointMake(JX_SCREEN_WIDTH, 0)];
            [self setOneData:_currentIndex -1];
            [self setThreeData:_currentIndex +1];
        }
        //动画
        [_lastAnnotationView cancelSelectAnimation];
        for ( int i = 0; i < [_allAnnotationView count]; i++) {
            JXLocPerImageVC * annoView = [_allAnnotationView objectAtIndex:i];
            if ([annoView.annotation.title intValue] == _currentIndex) {
                [self reAddAnnotationView:annoView];
                break;
            }
        }
        _resumeScrolView.userInteractionEnabled = YES;
    }


}


#pragma mark -----------------------获取服务器数据----------------
-(void)getServerData{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self showLocationDeniedAlert];
    }else{
        [_wait start];

        [g_server nearbyUser:_search nearOnly:YES lat:self.locY lng:self.locX page:0 toView:self];
        
    }
}

-(void)getDataByCurrentLocation{

    [g_server nearbyUser:_search nearOnly:YES lat:self.locY lng:self.locX page:0 toView:self];
}

//位置权限被禁时，弹出提醒框
- (void)showLocationDeniedAlert{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localized(@"JX_Tip") message:Localized(@"JX_LocationDisable") delegate:self cancelButtonTitle:Localized(@"JX_Cencal") otherButtonTitles:Localized(@"JX_Confirm"), nil];
    [alertView show];
//    [alertView release];
}

#pragma mark BMKLocationManagerDelegate
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error{
    //定位到当前位置
    CLLocationCoordinate2D  coor;
    if (self.locX == 0 && self.locY ==0) {
        if (location.location == nil) {
            [g_App showAlert:Localized(@"JXLoc_StartLocNotice")];
            return;
        }
        self.locX = location.location.coordinate.longitude;
        self.locY = location.location.coordinate.latitude;
        coor = location.location.coordinate;
    }else{
        coor = (CLLocationCoordinate2D){self.locY,self.locX};
    }
    self.locX = location.location.coordinate.longitude;
    self.locY = location.location.coordinate.latitude;
    //表示一个经纬度区域
    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(coor, BMKCoordinateSpanMake(0.0001f,0.0001f));
    [_imageMapView setRegion:viewRegion animated:YES];
    
    [_locationManager stopUpdatingLocation];
    
    [self getServerData];
}

#pragma mark BMKMapViewDelegate
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLLocationCoordinate2D mapCoordinate=  mapView.getMapStatus.targetGeoPt;
    NSLog(@"locX: %f locY: %f, long: %f lat: %f",_locX,_locY,mapCoordinate.longitude,mapCoordinate.latitude);
    if (fabs(self.locX-mapCoordinate.longitude) > 0.0001 || fabs(self.locY-mapCoordinate.latitude) > 0.0001) {
        self.locX = mapCoordinate.longitude;
        self.locY = mapCoordinate.latitude;
        
        [g_server nearbyUser:_search nearOnly:YES lat:mapCoordinate.latitude lng:mapCoordinate.longitude page:0 toView:self];
    }
    
    
}
#pragma mark  -----------------自定义view覆盖物--------------
-(void)addPointAnnotation{
    [_imageMapView removeAnnotations:_imageMapView.annotations];
    if (_nearbyData.count == 0) {
        return;
    }
    for (int i = 0 ; i < [_nearbyData count]; i++) {
        [self creatAnnotation:i];
    }
}
-(void)creatAnnotation:(int)i{
    NSDictionary * dict = [_nearbyData objectAtIndex:i];
    BMKPointAnnotation * pointAnnotation = [[BMKPointAnnotation alloc]init];
    CLLocationCoordinate2D coor = {0,0};
    
        coor.latitude = [dict[@"loc"][@"lat"] doubleValue];
        coor.longitude = [dict[@"loc"][@"lng"] doubleValue];
//    NSLog(@"annotcoor-> %d %f %f",i,[dict[@"loc"][@"lat"] doubleValue],[dict[@"loc"][@"lng"] doubleValue]);
    
    pointAnnotation.coordinate = coor;
    pointAnnotation.title = [NSString stringWithFormat:@"%d",i];
    pointAnnotation.subtitle = @"NO";//是否被点击
    [_imageMapView addAnnotation:pointAnnotation];
}

-(BMKPointAnnotation *)copyAnnotation:(BMKPointAnnotation*)pointAnnotation{
    BMKPointAnnotation * copyAnnotation = [[BMKPointAnnotation alloc]init];
    copyAnnotation.coordinate = pointAnnotation.coordinate;
    copyAnnotation.title = pointAnnotation.title;
    copyAnnotation.subtitle = pointAnnotation.subtitle;
    return copyAnnotation;
}

#pragma mark  ----------------anntation生成对应的View------------------
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation

{
    //创建AnnotationView
    NSString *AnnotationViewID = @"ClusterMark";
    JXLocPerImageVC *annotationView = [[JXLocPerImageVC alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    _lastAnnotationView = annotationView;
    [_allAnnotationView addObject:annotationView];
    annotationView.frame = CGRectMake(0, 0, 0, 0);
//    annotationView.canShowCallout = YES;//在点击大头针的时候会弹出那个黑框框
    annotationView.draggable = NO;//禁止标注在地图上拖动
    annotationView.annotation = annotation;
    [annotationView setData:[_nearbyData objectAtIndex:[annotation.title intValue]] andType:self.dataType];
    if ([annotationView.annotation.subtitle isEqualToString:@"YES"]) {
        [annotationView selectAnimation];
    }

    return annotationView;
    
}
-(void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    NSLog(@"didSelectAnnotationView");
    //清除上一个放大的标签
    if (_lastAnnotationView) {
        BMKPointAnnotation * anno = _lastAnnotationView.annotation;
        anno.subtitle = @"NO";
        [_lastAnnotationView cancelSelectAnimation];
    }
    //获取被点击的序列号
    _currentIndex = [view.annotation.title intValue];
    //点击的到最前面
    [self reAddAnnotationView:view];
    
    //ScrollView从底部出现
    if (_resumeScrolView.hidden) {
        _resumeScrolView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _resetLoca.frame = CGRectMake(20, self.view.frame.size.height -140, 30, 30);
            _scrollBackground.frame = CGRectMake(0, self.view.frame.size.height - 100, JX_SCREEN_WIDTH, 100);
            _scaleView.frame = CGRectMake(JX_SCREEN_WIDTH -100, self.view.frame.size.height -145, 90, 30);
        }];
    }
    [self setData:_currentIndex];
}

-(void)reAddAnnotationView:(BMKAnnotationView *)view{
    BMKPointAnnotation * copyAnnotation = [self copyAnnotation:view.annotation];
    copyAnnotation.subtitle = @"YES";
    [_imageMapView removeAnnotation:view.annotation];
    [_allAnnotationView removeObject:view];
    [_imageMapView addAnnotation:copyAnnotation];
}

#pragma  mark   ----------------复位按钮响应事件---------------
-(void)resetLocation{
//    if (_locService.userLocation.location == nil) {
//        [g_App showAlert:Localized(@"JXLoc_StartLocNotice")];
//    }else{
//        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(_locService.userLocation.location.coordinate, BMKCoordinateSpanMake(0.0001f,0.0001f));
//        [_imageMapView setRegion:adjustedRegion animated:YES];
//    }
}

-(void)doScale:(UIButton *)button{
    NSLog(@"doScale");
    if (button.tag == 10001) {
        [_imageMapView zoomOut];
    }else if(button.tag == 10002){
        [_imageMapView zoomIn];
    }
}

-(void)showDetailResume:(UIButton*)button{
//    NSLog(@"showDetailResume");
    NSString *jobId = nil;
    int version = 0;
    jobId = [(NSDictionary *)[_nearbyData objectAtIndex:_currentIndex] objectForKey:@"jobId"];
    version = [[(NSDictionary *)[_nearbyData objectAtIndex:_currentIndex] objectForKey:@"version"] intValue];
    NSDictionary* dict = [_nearbyData objectAtIndex:_currentIndex];
//    [_wait start];
//    [g_server getUser:[dict objectForKey:@"userId"] toView:self];
    JXUserInfoVC* vc = [JXUserInfoVC alloc];
    vc.userId       = [dict objectForKey:@"userId"];
    vc.fromAddType = 6;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];

}



- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate{
    if (_resumeScrolView.hidden == NO) {
        [UIView animateWithDuration:0.3 animations:^{
            [self dissmissScrollView];
        }];
    }
}

- (void)mapView:(BMKMapView *)mapView onClickedBMKOverlayView:(BMKOverlayView *)overlayView{
    if (_resumeScrolView.hidden == NO) {
        [UIView animateWithDuration:0.3 animations:^{
            [self dissmissScrollView];
        }];
    }
}

-(void)dissmissScrollView{
    _scrollBackground.frame = CGRectMake(0, self.view.frame.size.height + 100, JX_SCREEN_WIDTH, 100);
    _resumeScrolView.hidden = YES;
    _resetLoca.frame = CGRectMake(20,self.view.frame.size.height -40, 30, 30);
    _scaleView.frame = CGRectMake(JX_SCREEN_WIDTH - 100,self.view.frame.size.height -40, 90, 30);
}

#pragma mark -----------------返回数据---------------------
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if([aDownload.action isEqualToString:act_nearbyUser]){
        [_nearbyData removeAllObjects];
        [_nearbyData addObjectsFromArray:array1];
        [self addPointAnnotation];
        if ([_nearbyData count] == 1) {
            _resumeScrolView.contentSize = CGSizeMake(JX_SCREEN_WIDTH, 100);
        }else if ([_nearbyData count] == 2){
            _resumeScrolView.contentSize = CGSizeMake(JX_SCREEN_WIDTH*2, 100);
        }else {
            _resumeScrolView.contentSize = CGSizeMake(JX_SCREEN_WIDTH*3, 100);
        }
        if (_resumeScrolView.hidden == NO) {
            [self dissmissScrollView];
        }

    }else if([aDownload.action isEqualToString:act_UserGet]){
        JXUserObject* user = [[JXUserObject alloc]init];
        [user getDataFromDict:dict];
        
        JXUserInfoVC* vc = [JXUserInfoVC alloc];
        vc.user       = user;
        vc.fromAddType = 6;
        vc = [vc init];
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
    }
}


- (int)didServerResultFailed:(JXConnection *)aDownload dict:(NSDictionary *)dict{
    [_wait stop];
    
    return hide_error;
}

- (int)didServerConnectError:(JXConnection *)aDownload error:(NSError *)error{
    [_wait stop];
    
    
    
    return hide_error;
}

@end
