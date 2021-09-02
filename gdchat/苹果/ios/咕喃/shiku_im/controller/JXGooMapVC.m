//
//  JXGooMapVC.m
//  shiku_im
//
//  Created by Apple on 16/12/6.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXGooMapVC.h"
#import "UIView+ScreenShot.h"
#import "JXUserInfoVC.h"
#ifdef USE_GOOGLEMAP
@interface JXGooMapVC ()<GMSMapViewDelegate,UIScrollViewDelegate>
@property (nonatomic, strong)GMSMutableCameraPosition *camera;
@property (nonatomic, strong)GMSMapView *gooMapView;
@property (nonatomic, strong)GMSMarker *marker;
@property (nonatomic, strong)GMSGeocoder *geocoder;
@end
#endif

@implementation JXGooMapVC

- (instancetype)initWithFrame:(CGRect)frame andType:(int)dataType
{
    self = [super init];
    if (self) {
#ifdef USE_GOOGLEMAP
        _wait = [ATMHud sharedInstance];
        self.view.frame = frame;
        _nearbyData = [NSMutableArray new];
        _allMarkerView = [NSMutableArray new];
        _dataType = dataType;
        _zoomLevel = 14;
        [self customView];
//        [self getServerData];
#endif
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
#ifdef USE_GOOGLEMAP
    [self initGoogleMapView];
#endif
}
#ifdef USE_GOOGLEMAP
-(void)customView{
    
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
    _scaleView = [[UIView alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height - 40, 90, 30)];
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
}

-(void)initGoogleMapView{
    
    GMSCameraPosition *camera = nil;
    if (self.locY == 0 ) {
        camera = [GMSCameraPosition cameraWithLatitude:22.290664
                                             longitude:114.195304
                                                  zoom:14];
    }else{
        camera = [GMSCameraPosition cameraWithLatitude:self.locY
                                             longitude:self.locX
                                                  zoom:14];
    }
    
    _gooMapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _gooMapView.delegate = self;
    self.view = _gooMapView;
    _gooMapView.myLocationEnabled = YES;
    _gooMapView.settings.myLocationButton = YES;
    
    self.locX = _gooMapView.myLocation.coordinate.longitude;
    self.locY = _gooMapView.myLocation.coordinate.latitude;
    
//    GMSMarker *marker = [[GMSMarker alloc] init];
//    marker.position = CLLocationCoordinate2DMake(22.290664, 114.195304);
//    marker.title = @"香港";
//    marker.snippet = @"Hong Kong";
//    marker.map = _gooMapView;
    [self getServerData];
}

-(void)getServerData{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self showLocationDeniedAlert];
    }else{
        [_wait start];
//        searchData *search = [[searchData alloc] init];
//        search.minAge = 0;
//        search.maxAge = 200;
//        search.sex = -1;
        
        [g_server nearbyUser:_search nearOnly:YES lat:self.locY lng:self.locX page:0 toView:self];
        
    }
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
//    grayView.backgroundColor = [UIColor whiteColor];
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
        _headImageOne.layer.cornerRadius = 15;
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
////        [_identImageOne release];
//        //信誉积分背景
//        _integralImageOne = [[UIImageView alloc]initWithFrame:CGRectMake(85, 68, 40, 15)];
//        _integralImageOne.image = [UIImage imageNamed:@"feaBtn_backImg_lightGreen"];
//        _integralImageOne.layer.cornerRadius = 2;
//        _integralImageOne.clipsToBounds = YES;
//        [jobView addSubview:_integralImageOne];
////        [_integralImageOne release];
//        //信誉积分
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
        _headImageTwo.layer.cornerRadius = 15;
        _headImageTwo.clipsToBounds = YES;
        [jobView addSubview:_headImageTwo];
//        [_headImageTwo release];
        //昵称
        _nameLabelTwo = [[UILabel alloc]initWithFrame:CGRectMake(65, 60, 200, 15)];
        _nameLabelTwo.font = [UIFont systemFontOfSize:11];
        [jobView addSubview:_nameLabelTwo];
//        [_nameLabelTwo release];
//        //认证
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
//        [_integralImageTwo release];
        //信誉积分
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
        _headImageThree.layer.cornerRadius = 15;
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
////        [_integralLabelThree release];
//        //距离
//        _distanceLabelThree = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 180 + 30, 60, 110, 20)];
//        _distanceLabelThree.textAlignment = NSTextAlignmentRight;
//        _distanceLabelThree.font = [UIFont systemFontOfSize:11];
//        [jobView addSubview:_distanceLabelThree];
//        [_distanceLabelThree release];
    }
}

//位置权限被禁时，弹出提醒框
- (void)showLocationDeniedAlert{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localized(@"JX_Tip") message:Localized(@"JX_LocationDisable") delegate:self cancelButtonTitle:Localized(@"JX_Cencal") otherButtonTitles:Localized(@"JX_Confirm"), nil];
    [alertView show];
//    [alertView release];
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
    [g_server getHeadImageSmall:[NSString stringWithFormat:@"%lld",[dataDict[@"userId"] longLongValue]]
                       userName:dataDict[@"nickname"] imageView:_headImageOne getHeadHandler:nil];
    
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
    [g_server getHeadImageSmall:[NSString stringWithFormat:@"%lld",[dataDict[@"userId"] longLongValue]]userName:dataDict[@"nickname"] imageView:_headImageThree getHeadHandler:nil];
    
    //昵称
    //    _nameLabelTwo.text = twoData[@"nickname"];
    
    //距离
    _distanceLabelThree.text = [NSString stringWithFormat:@"%.3fkm",[g_server getLocation:[dataDict[@"loc"][@"lat"] doubleValue] longitude:[dataDict[@"loc"][@"lng"] doubleValue]]/1000];
}

#pragma mark --------------google地图事件代理GMSMapViewDelegate-------------

- (void)mapView:(GMSMapView *)mapView
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"You tapped at %f,%f", coordinate.latitude, coordinate.longitude);
    [self dissmissScrollView];
}
//移动
-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{

    self.locX = position.target.longitude;
    self.locY = position.target.latitude;
    [g_server nearbyUser:_search nearOnly:YES lat:position.target.latitude lng:position.target.longitude page:0 toView:self];
   
}
- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    [mapView clear];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
    if (_lastMarkerView == marker) {
        return NO;
    }
    marker.zIndex = _lastMarkerView.zIndex + 1;
    if (_lastMarkerView != nil) {
        _lastMarkerView.icon = [UIView scaleImage:_lastMarkerView.icon toScale:1/1.3];
    }
    
    _lastMarkerView = marker;
    marker.icon = [UIView scaleImage:marker.icon toScale:1.3];
    
    //ScrollView从底部出现
    if (_resumeScrolView.hidden) {
        _resumeScrolView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _scrollBackground.frame = CGRectMake(0, self.view.frame.size.height - 100, JX_SCREEN_WIDTH, 100);
            _scaleView.frame = CGRectMake(20, self.view.frame.size.height -145, 90, 30);
        }];
    }
    _currentIndex = [marker.userData intValue];
    [self setData:_currentIndex];
    
    return YES;
}


-(void)dissmissScrollView{
    _scrollBackground.frame = CGRectMake(0, self.view.frame.size.height + 100, JX_SCREEN_WIDTH, 100);
    _resumeScrolView.hidden = YES;
    _scaleView.frame = CGRectMake(20,self.view.frame.size.height -40, 90, 30);
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
        [self changeSelectMarker];
        _resumeScrolView.userInteractionEnabled = YES;
    }
    
    
}
#pragma mark -----------------返回数据---------------------
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if([aDownload.action isEqualToString:act_nearbyUser]){
        [_nearbyData removeAllObjects];
        [_nearbyData addObjectsFromArray:array1];
//        [self addPointAnnotation];
        [self addPointMarker];
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

-(void)addPointMarker{
//    [_gooMapView clear];
    for (GMSMarker *marker in _allMarkerView) {
        [marker setMap:NULL];
    }
    
    [_allMarkerView removeAllObjects];
    if (_nearbyData.count == 0) {
        return;
    }
    for (int i = 0 ; i < [_nearbyData count]; i++) {
        [self creatMarker:i];
    }
}

-(void)creatMarker:(int)i{
    NSDictionary * dict = [_nearbyData objectAtIndex:i];
    GMSMarker *customMarker = [[GMSMarker alloc] init];
    float latitude;
    float longitude;
    
    latitude = [dict[@"loc"][@"lat"] doubleValue];
    longitude = [dict[@"loc"][@"lng"] doubleValue];
    customMarker.position = CLLocationCoordinate2DMake(latitude, longitude);
        //自定义图片view
    UIView * headViewBG = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 60)];
    headViewBG.backgroundColor = [UIColor clearColor];
    UIImageView * pointImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 60)];
    pointImage.image = [UIImage imageNamed:@"locationAcc2"];
    [headViewBG addSubview:pointImage];
    UIImageView * headImage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 3, 40, 40)];
    headImage.layer.cornerRadius = 20;
    headImage.clipsToBounds = YES;
    [headViewBG addSubview:headImage];
    //头像网址
    NSString *userId = [NSString stringWithFormat:@"%lld",[dict[@"userId"] longLongValue]];
    
    if([userId longLongValue]<10100 && [userId longLongValue]>=10000){
        return;
    }
    if([userId length]<=0){
        headImage.image = [UIImage imageNamed:@"avatar_normal"];
        return;
    }
    NSString* dir  = [NSString stringWithFormat:@"%lld",[userId longLongValue] % 10000];
    NSString* urlString  = [NSString stringWithFormat:@"%@avatar/t/%@/%@.jpg",g_config.downloadAvatarUrl,dir,userId];
    NSURL * url = [[NSURL alloc]initWithString:urlString];
    [headImage sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        headImage.image = image;
        customMarker.icon = [headViewBG viewSnapshot:headViewBG withInRect:headViewBG.frame];
    }];
    customMarker.userData = @(i);
    customMarker.map = _gooMapView;
    
    [_allMarkerView addObject:customMarker];
}

-(void)getDataByCurrentLocation{
    [g_server nearbyUser:_search nearOnly:YES lat:self.locY lng:self.locX page:0 toView:self];
}
#pragma  mark   ----------------按钮响应事件---------------
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

-(void)doScale:(UIButton *)button{
    NSLog(@"doScale");
    if (button.tag == 10001) {
        _zoomLevel -= 1;
        [_gooMapView animateToZoom:_zoomLevel];
    }else if(button.tag == 10002){
        _zoomLevel += 1;
        [_gooMapView animateToZoom:_zoomLevel];
    }
}

-(void)changeSelectMarker{

    _lastMarkerView.icon = [UIView scaleImage:_lastMarkerView.icon toScale:1/1.3];
    
    for ( int i = 0; i < [_allMarkerView count]; i++) {
        GMSMarker * markerD = [_allMarkerView objectAtIndex:i];
        if ([markerD.userData intValue] == _currentIndex) {
            markerD.icon = [UIView scaleImage:markerD.icon toScale:1.3];
            _lastMarkerView = markerD;
        }
    }
    
}

-(void)showDetailResume:(UIButton*)button{
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#endif
@end
