//
//  JXGoogleMapVC.m
//  shiku_im
//
//  Created by 1 on 2018/8/20.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXGoogleMapVC.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "JXNearMarkCell.h"
#import "JXMapData.h"
#import "SPAlertController.h"

@interface JXGoogleMapVC () <GMSMapViewDelegate,UIScrollViewDelegate,CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource,JXActionSheetVCDelegate>
@property (nonatomic, strong) GMSMapView *gooMapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) GMSMarker *marker;
@property (nonatomic, strong) GMSGeocoder *geocoder;
@property (nonatomic, strong) GMSMutableCameraPosition *camera;
@property (nonatomic, strong) NSMutableArray *nearMarkArray;
@property (nonatomic, strong) JXPlaceMarkModel *model;

@property (nonatomic, assign) CGRect frame;

@property (nonatomic, strong) JXNearMarkCell *lastCell;

@end

@implementation JXGoogleMapVC

- (instancetype)init {
    if (self = [super init]) {
        self.title = Localized(@"JXUserInfoVC_Loation");
        self.heightHeader = _locationType ==JXGooLocationTypeShowStaticLocation ? 0 : JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
        [self createHeadAndFoot];
        _nearMarkArray = [[NSMutableArray alloc] init];
        if (_locationType ==JXGooLocationTypeShowStaticLocation) {
            UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, JX_SCREEN_TOP - 38, 31, 31)];
            [backBtn setBackgroundImage:[UIImage imageNamed:@"map_back"] forState:UIControlStateNormal];
            [backBtn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:backBtn];

//            UIButton* btn = [UIFactory createButtonWithImage:@"title_more" highlight:nil target:self selector:@selector(moreBtnAction)];
//            btn.frame = CGRectMake(JX_SCREEN_WIDTH-24-8, JX_SCREEN_TOP - 34, 24, 24);
//            [self.tableHeader addSubview:btn];
            UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-100, JX_SCREEN_WIDTH, 100)];
            baseView.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:baseView];
            
            UILabel *adrLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, JX_SCREEN_WIDTH-20*3-60, 20)];
            adrLabel.text = self.placeNames;
            [baseView addSubview:adrLabel];
            
            UIButton* btn = [UIFactory createButtonWithImage:@"adress_navigation" highlight:nil target:self selector:@selector(moreBtnAction)];
            btn.frame = CGRectMake(CGRectGetMaxX(adrLabel.frame)+20, 20, 60, 60);
            [baseView addSubview:btn];
            
            //复位
            UIButton * resetLoca = [[UIButton alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH -80+30-15, JX_SCREEN_HEIGHT -100-50, 30, 30)];
            [resetLoca setImage:[UIImage imageNamed:@"ic_greeting_checked"] forState:UIControlStateNormal];
            [resetLoca addTarget:self action:@selector(resetMapCenter) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:resetLoca];

        } else {
            //发送
            if(self.isSend){
                _sendButton = [UIFactory createCommonButton:Localized(@"JX_Send") target:self action:@selector(onSelect)];
                _sendButton.frame = CGRectMake(JX_SCREEN_WIDTH-60, JX_SCREEN_TOP - 34, 60, 24);
                [_sendButton setBackgroundImage:nil forState:UIControlStateNormal];
                [_sendButton setBackgroundImage:nil forState:UIControlStateHighlighted];
                [_sendButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
                [self.tableHeader addSubview:_sendButton];
            }
        }

        if (!_locations)
            _locations = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createGoogleMap];
    [self customView];
    [self startLocation];
    self.tableBody.contentSize = CGSizeMake(0, JX_SCREEN_HEIGHT - JX_SCREEN_TOP);
}



-(void)startLocation{
    if (_locationType == JXGooLocationTypeShowStaticLocation) {
        JXMapData * staticData = [_locations firstObject];
        self.latitude = [staticData.latitude doubleValue];
        self.longitude = [staticData.longitude doubleValue];
        //        [self makeMapCenter:staticData];
        //        [self addPointAnnotations:_locations];
        self.title = staticData.title;
        
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(self.latitude, self.longitude);
        marker.title = self.title;
        //        marker.snippet = @"Hong Kong";
        marker.icon = [UIImage imageNamed:@"position"];
        marker.map = _gooMapView;
        [self resetMapCenter];  // 移动镜头
    }else {
        //定位服务
        _locationManager=[[CLLocationManager alloc]init];
        if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined){
            [_locationManager requestWhenInUseAuthorization];
        }else if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse){
            _locationManager.delegate=self;
            _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
            [_locationManager startUpdatingLocation];
        }
    }

}

- (void)actionSheet:(JXActionSheetVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    if (index == 0) {
        [self onDaoHangForIOSMap];
    }
    else if (index == 1) {
        
        [self onDaoHangForBaiDuMap];
        
    }
    else if (index == 2) {
        
        [self onDaoHangForGaoDeMap];
        
    }
    else if (index == 3) {
        
        [self onDaoHangForBaiDuMap];
        
    }
    else if (index == 4) {
        
        [self onQQMap];
        
    }

}

-(void)moreBtnAction{
    
    JXActionSheetVC *actionVC = [[JXActionSheetVC alloc] initWithImages:nil names:@[Localized(@"JX_MapApple"),Localized(@"JX_MapBaidu"),Localized(@"JX_MapGaode"),Localized(@"JX_TencentMap")]];
    actionVC.delegate = self;
    [g_navigation.subViews.lastObject presentViewController:actionVC animated:NO completion:nil];

    
//    SPAlertController *alertSheet = [SPAlertController alertControllerWithTitle:nil message:nil preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDefault];
//    
//    //    UIAlertController * alertSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
////    SPAlertAction *actionApple = [SPAlertAction actionWithTitle:Localized(@"JX_MapApple") style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
////        NSLog(@"苹果");
////        [self onDaoHangForIOSMap];
////    }];
////    [alertSheet addAction:actionApple];
//    
//    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]){
//        SPAlertAction * actionAMap = [SPAlertAction actionWithTitle:Localized(@"JX_MapGaode") style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
//            NSLog(@"高德");
//            [self onDaoHangForGaoDeMap];
//        }];
//        [alertSheet addAction:actionAMap];
//    }
//    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
//        SPAlertAction * actionBaidu = [SPAlertAction actionWithTitle:Localized(@"JX_MapBaidu") style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
//            NSLog(@"百度");
//            [self onDaoHangForBaiDuMap];
//        }];
//        [alertSheet addAction:actionBaidu];
//    }
//    
//    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]){
//        SPAlertAction *actionGoogle = [SPAlertAction actionWithTitle:Localized(@"JX_MapGoogle") style:SPAlertActionStyleDefault handler:^(SPAlertAction *action) {
//            NSLog(@"谷歌");
//            [self onGoogleMap];
//        }];
//        [alertSheet addAction:actionGoogle];
//    }
//    
//    //    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
//    //        UIAlertAction *actionQq = [UIAlertAction actionWithTitle:@"腾讯地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//    //            NSLog(@"腾讯地图");
//    //            [self onQQMap];
//    //        }];
//    //        [alertSheet addAction:actionQq];
//    //    }
//    
//    SPAlertAction * cancelAction = [SPAlertAction actionWithTitle:Localized(@"JX_Cencal") style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
//        NSLog(@"取消");
//    }];
//    [alertSheet addAction:cancelAction];
//    
//    
//    //    if ([alertSheet respondsToSelector:@selector(popoverPresentationController)]) {
//    //        alertSheet.popoverPresentationController.sourceView = self.view; //必须加
//    //        alertSheet.popoverPresentationController.sourceRect = CGRectMake(0, JX_SCREEN_HEIGHT, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);//可选，我这里加这句代码是为了调整到合适的位置
//    //    }
//    [self presentViewController:alertSheet animated:YES completion:nil];
    
    
}
#pragma mark ------------------------------ 导航 - iosMap
-(void) onDaoHangForIOSMap
{
    //起点
    //    CLLocation * location = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    //    location = [location locationMarsFromBaidu];
    //
    //    CLLocationCoordinate2D coor =location.coordinate;
    //    MKMapItem *currentLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc]                         initWithCoordinate:coor  addressDictionary:nil]];
    //    currentLocation.name =@"我的位置";
    
    JXMapData * staticData = [_locations firstObject];
    CLLocationCoordinate2D toCoor = [staticData coordinate2D];
    //    self.title = staticData.title;
    //目的地的位置
    CLLocation * location2 = [[CLLocation alloc]initWithLatitude:toCoor.latitude longitude:toCoor.longitude];
    //    location2 = [location2 locationMarsFromBaidu];
    
    CLLocationCoordinate2D coor2 =location2.coordinate;
    //    CLLocationCoordinate2D coords = self.location;
    
    
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coor2 addressDictionary:nil]];
    
    toLocation.name = staticData.title;
    
    NSArray *items = [NSArray arrayWithObjects:toLocation, nil];
    NSString * mode = MKLaunchOptionsDirectionsModeDriving;
    //    switch (_seleIndex) {
    //        case 1:
    //        {
    //            mode = MKLaunchOptionsDirectionsModeTransit;
    //        }
    //            break;
    //        case 2:
    //        {
    //            mode = MKLaunchOptionsDirectionsModeDriving;
    //        }
    //            break;
    //        case 3:
    //        {
    //            mode = MKLaunchOptionsDirectionsModeWalking;
    //        }
    //            break;
    //
    //        default:
    //            break;
    //    }
    NSDictionary *options = @{ MKLaunchOptionsDirectionsModeKey:mode, MKLaunchOptionsMapTypeKey: [NSNumber                                 numberWithInteger:MKMapTypeStandard], MKLaunchOptionsShowsTrafficKey:@YES };
    //打开苹果自身地图应用，并呈现特定的item
    [MKMapItem openMapsWithItems:items launchOptions:options];
}

#pragma mark ------------------------------ 导航 - 高德
-(void) onDaoHangForGaoDeMap
{
    //    m    驾车：0：速度最快，1：费用最少，2：距离最短，3：不走高速，4：躲避拥堵，5：不走高速且避免收费，6：不走高速且躲避拥堵，7：躲避收费和拥堵，8：不走高速躲避收费和拥堵 公交：0：最快捷，2：最少换乘，3：最少步行，5：不乘地铁 ，7：只坐地铁 ，8：时间短    是
    //    t = 0：驾车 =1：公交 =2：步行
    
    //    NSString * t = @"0";
    //    switch (_seleIndex) {
    //        case 1:
    //        {
    //            t = @"1";
    //        }
    //            break;
    //        case 2:
    //        {
    //            t = @"0";
    //        }
    //            break;
    //        case 3:
    //        {
    //            t = @"2";
    //        }
    //            break;
    //
    //        default:
    //            break;
    //    }
    //起点
    //    CLLocation * location = [[CLLocation alloc]initWithLatitude:[SingleObject shareSingleObject].currentCoordinate.latitude longitude:[SingleObject shareSingleObject].currentCoordinate.longitude];
    //    location = [location locationMarsFromBaidu];
    //
    //    CLLocationCoordinate2D coor =location.coordinate;
    
    //目的地的位置
    //    CLLocation * location2 = [[CLLocation alloc]initWithLatitude:self.location.latitude longitude:self.location.longitude];
    //    location2 = [location2 locationMarsFromBaidu];
    //
    //    CLLocationCoordinate2D coor2 =location2.coordinate;
    JXMapData * staticData = [_locations firstObject];
    CLLocationCoordinate2D toCoor = [staticData coordinate2D];
    //    self.title = staticData.title;
    //目的地的位置
    CLLocation * location2 = [[CLLocation alloc]initWithLatitude:toCoor.latitude longitude:toCoor.longitude];
    //    location2 = [location2 locationMarsFromBaidu];
    
    CLLocationCoordinate2D coor2 =location2.coordinate;
    
    
    //    导航 URL：iosamap://navi?sourceApplication=%@&poiname=%@&lat=%lf&lon=%lf&dev=0&style=0",@"ABC"
    //    路径规划 URL：iosamap://path?sourceApplication=applicationName&sid=BGVIS1&slat=39.92848272&slon=116.39560823&sname=A&did=BGVIS2&dlat=39.98848272&dlon=116.47560823&dname=B&dev=0&m=0&t=0
    // -- 不能直接让用户进入导航，应该给用户更多的选择，所以先进行路径规划
    
    //    NSURL *myLocationScheme = [NSURL URLWithString:@"iosamap://path?sourceApplication=shikuim"];
    
    
    
    
    NSString *url = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=shikuim&sid=BGVIS1&did=BGVIS2&dlat=%lf&dlon=%lf&dname=%@&dev=0",coor2.latitude,coor2.longitude,staticData.title] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]])// -- 使用 canOpenURL 判断需要在info.plist 的 LSApplicationQueriesSchemes 添加 iosamap
    {
        if ([[UIDevice currentDevice].systemVersion integerValue] >= 10) { //iOS10以后,使用新API
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
                NSLog(@"scheme调用结束"); }];
        }else { //iOS10以前,使用旧API
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }else{
        [g_App showAlert:Localized(@"JX_MapSelNotInstall")];
    }
    
    
}

#pragma mark ------------------------------ 导航 - 百度
-(void) onDaoHangForBaiDuMap
{
    //    百度地图如何调起APP进行导航
    //    mode    导航模式，固定为transit、driving、walking，分别表示公交、驾车和步行
    NSString * modeBaiDu = @"driving";
    //    switch (_seleIndex) {
    //        case 1:
    //        {
    //            modeBaiDu = @"transit";
    //        }
    //            break;
    //        case 2:
    //        {
    //            modeBaiDu = @"driving";
    //        }
    //            break;
    //        case 3:
    //        {
    //            modeBaiDu = @"walking";
    //        }
    //            break;
    //
    //        default:
    //            break;
    //    }
    
    JXMapData * staticData = [_locations firstObject];
    CLLocationCoordinate2D toCoor = [staticData coordinate2D];
    //    self.title = staticData.title;
    //目的地的位置
    CLLocation * location2 = [[CLLocation alloc]initWithLatitude:toCoor.latitude longitude:toCoor.longitude];
    //    location2 = [location2 locationMarsFromBaidu];
    
    CLLocationCoordinate2D coor2 =location2.coordinate;
    
    NSString *url = [[NSString stringWithFormat:@"baidumap://map/direction?origin=%lf,%lf&destination=%f,%f&mode=%@&src=公司|APP",coor2.latitude,coor2.longitude,coor2.latitude,coor2.longitude,modeBaiDu] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]])// -- 使用 canOpenURL 判断需要在info.plist 的 LSApplicationQueriesSchemes 添加 baidumap 。
    {
        if ([[UIDevice currentDevice].systemVersion integerValue] >= 10) { //iOS10以后,使用新API
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
                NSLog(@"scheme调用结束");
            }];
        }else { //iOS10以前,使用旧API
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }else{
        [g_App showAlert:Localized(@"JX_MapSelNotInstall")];
    }
    
}

#pragma mark --- google
-(void)onGoogleMap{
    JXMapData * staticData = [_locations firstObject];
    CLLocationCoordinate2D toCoor = [staticData coordinate2D];
    //    self.title = staticData.title;
    //目的地的位置
    CLLocation * location2 = [[CLLocation alloc]initWithLatitude:toCoor.latitude longitude:toCoor.longitude];
    //    location2 = [location2 locationMarsFromBaidu];
    
    CLLocationCoordinate2D coor2 =location2.coordinate;
    
    NSString *url = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&saddr=&daddr=%f,%f&directionsmode=driving",@"shikuim",coor2.latitude, coor2.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]])// -- 使用 canOpenURL 判断需要在info.plist 的 LSApplicationQueriesSchemes 添加 baidumap 。
    {
        if ([[UIDevice currentDevice].systemVersion integerValue] >= 10) { //iOS10以后,使用新API
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
                NSLog(@"scheme调用结束"); }];
        }else { //iOS10以前,使用旧API
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }else{
        [g_App showAlert:Localized(@"JX_MapSelNotInstall")];
    }
    
}

#pragma mark ---qq
-(void)onQQMap{
    JXMapData * staticData = [_locations firstObject];
    CLLocationCoordinate2D toCoor = [staticData coordinate2D];
    //    self.title = staticData.title;
    //目的地的位置
    CLLocation * location2 = [[CLLocation alloc]initWithLatitude:toCoor.latitude longitude:toCoor.longitude];
    //    location2 = [location2 locationMarsFromBaidu];
    
    CLLocationCoordinate2D coor2 =location2.coordinate;
    
    NSString *url = [[NSString stringWithFormat:@"qqmap://map/routeplan?from=我的位置&type=drive&tocoord=%f,%f&to=%@&coord_type=1&policy=0",coor2.latitude, coor2.longitude,staticData.title] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]])
    {
        if ([[UIDevice currentDevice].systemVersion integerValue] >= 10) { //iOS10以后,使用新API
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
                NSLog(@"scheme调用结束"); }];
        }else { //iOS10以前,使用旧API
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }else{
        [g_App showAlert:Localized(@"JX_MapSelNotInstall")];
    }
}

- (void)createGoogleMap {
    GMSCameraPosition *camera = nil;
    if (self.latitude == 0) {
        camera = [GMSCameraPosition cameraWithLatitude:22.290664
                                             longitude:114.195304
                                                  zoom:14];
    }else{
        camera = [GMSCameraPosition cameraWithLatitude:self.latitude
                                             longitude:self.longitude
                                                  zoom:14];
    }
    
    _gooMapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _gooMapView.delegate = self;
    self.view = _gooMapView;
    
}


- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *curLocation = [locations lastObject];
    CLLocationCoordinate2D curCoordinate2D=curLocation.coordinate;

    [_locationManager stopUpdatingLocation];

    dispatch_async(dispatch_get_main_queue(), ^{
//        [_gooMapView clear];
//        _gooMapView.camera=[GMSCameraPosition cameraWithLatitude:curCoordinate2D.latitude longitude:curCoordinate2D.longitude zoom:14];
        self.longitude = curCoordinate2D.longitude;
        self.latitude = curCoordinate2D.latitude;
    });
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{

}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    /**
     *    拿到授权发起定位请求
     
     */
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [_locationManager startUpdatingLocation];
    }
}

#pragma mark -  获取地理位置名称（地点名）
- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position{
    
    //反向地理编码
    [[GMSGeocoder geocoder]reverseGeocodeCoordinate:position.target completionHandler:^(GMSReverseGeocodeResponse * response, NSError * error) {
        if (response.results) {
            GMSAddress *address = response.results[0];
            NSLog(@"%@",address.thoroughfare);
            _address = address.thoroughfare;
            if (![_address isEqualToString:@""]) {
                JXPlaceMarkModel *place = [[JXPlaceMarkModel alloc] init];
                place.placeName = address.locality;
                place.address = _address;
                [_nearMarkArray removeAllObjects];
                [_nearMarkArray addObject:place];
                [_nearMarkTableView reloadData];
            }
        }
    }];
}

#pragma mark - 移动镜头 得到位置
-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    if (_locationType == JXGooLocationTypeCurrentLocation) {
        self.longitude = position.target.longitude;
        self.latitude = position.target.latitude;
    }
    
}

- (nullable UIImage *)snapshotToImage:(CGSize)size {
    _gooMapView.myLocationEnabled = NO;
    CGPoint map_center = _gooMapView.center;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [_gooMapView drawViewHierarchyInRect:CGRectMake(0, -(map_center.y - size.height)-JX_SCREEN_TOP, _gooMapView.bounds.size.width, _gooMapView.bounds.size.height) afterScreenUpdates:YES];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshotImage;
}

- (void)getServerData {
    
}

- (void)customView{
    if (_locationType == JXGooLocationTypeShowStaticLocation) {
        //复位
        UIButton * resetLoca = [[UIButton alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH -50, JX_SCREEN_HEIGHT -50, 30, 30)];
        [resetLoca setImage:[UIImage imageNamed:@"ic_greeting_checked"] forState:UIControlStateNormal];
        [resetLoca addTarget:self action:@selector(resetMapCenter) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:resetLoca];
        
    }else{
        //复位
        UIButton * resetLoca = [[UIButton alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH -50, JX_SCREEN_HEIGHT -50, 30, 30)];
        [resetLoca setImage:[UIImage imageNamed:@"ic_greeting_checked"] forState:UIControlStateNormal];
        [resetLoca addTarget:self action:@selector(resetLocation) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:resetLoca];
        //当前位置图标
        UIImageView * pointImage = [[UIImageView alloc]initWithFrame:CGRectMake((JX_SCREEN_WIDTH - 30) /2, (JX_SCREEN_HEIGHT -64)/2 - 50 +10 +64, 30, 50)];
        pointImage.image = [UIImage imageNamed:@"position"];
        pointImage.userInteractionEnabled = NO;
        [self.view addSubview:pointImage];
        //周边地点列表
        _nearMarkTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT - 100, JX_SCREEN_WIDTH, 100) style:UITableViewStylePlain];
        _nearMarkTableView.dataSource = self;
        _nearMarkTableView.delegate = self;
        _nearMarkTableView.separatorStyle = UITableViewCellSelectionStyleNone;
        [self.view addSubview:_nearMarkTableView];

    }
}


- (void)resetMapCenter {
    GMSCameraPosition *sydney = [GMSCameraPosition cameraWithLatitude:self.latitude
                                                            longitude:self.longitude
                                                                 zoom:14];
    [_gooMapView setCamera:sydney];
    
}

- (void)onSelect {
    NSString *imagePath = [self screenShotAction];
    
    JXMapData * data = [[JXMapData alloc]init];
    
    if (_model != nil) {
        data.latitude = [NSString stringWithFormat:@"%f",_model.latitude];
        data.longitude = [NSString stringWithFormat:@"%f",_model.longitude];
        data.subtitle = _model.name;
    }else{
        data.latitude = [NSString stringWithFormat:@"%f",self.latitude];
        data.longitude = [NSString stringWithFormat:@"%f",self.longitude];
        data.subtitle = _address;
    }
    
    if (!data.subtitle || data.subtitle.length <= 0 || [data.subtitle isEqualToString:@"null"] || [data.subtitle isEqualToString:@"(null)"]) {
        if (g_server.address.length > 0) {
            data.subtitle = g_server.address;
        }else {
            data.subtitle = @"";
        }
    }
    
    data.imageUrl = imagePath;
    
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelect])
        [self.delegate performSelectorOnMainThread:self.didSelect withObject:data waitUntilDone:NO];
    
    [self actionQuit];
    
    _delegate = nil;
    [_gooMapView removeFromSuperview];

}

-(NSString *)screenShotAction{
    UIImage *image = [self snapshotToImage:CGSizeMake(JX_SCREEN_WIDTH, JX_SCREEN_WIDTH/2.2)];
    UIImage *logoImage = [self addImageLogo:image text:[UIImage imageNamed:@"position"]];
    NSString* filePath = [FileInfo getUUIDFileName:@"jpg"];
    [g_server saveImageToFile:logoImage file:filePath isOriginal:NO];
    return filePath;
}


-(UIImage *)addImageLogo:(UIImage *)img text:(UIImage *)logo
{
    
    int w = img.size.width;
    int h = img.size.height;
//    int logoWidth = 120;
//    int logoHeight = 200;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
//    CGContextDrawImage(context, CGRectMake((w-logoWidth)/2, h/2-10, logoWidth, logoHeight), [logo CGImage]);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:imageMasked];
}

- (void)resetLocation{
        [g_App showAlert:Localized(@"JXLoc_StartLocNotice")];
    
}



#pragma mark  tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_nearMarkArray.count>0) {
        return _nearMarkArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_nearMarkArray.count>0) {
        return _nearMarkArray.count*44;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JXNearMarkCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JXNearMarkCell class])];
    if (cell == nil) {
        cell = [[JXNearMarkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([JXNearMarkCell class])];
    }
    if (_nearMarkArray.count>0) {
        [cell refreshWithModel:[_nearMarkArray objectAtIndex:indexPath.row]];
    }


    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

//    [_locService stopUserLocationService];

    _selIndex = indexPath.row;

    JXPlaceMarkModel*model = [_nearMarkArray objectAtIndex:indexPath.row];
    model.longitude = self.longitude;
    model.latitude = self.latitude;
    model.name = self.address;
    self.model = model;

    JXNearMarkCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selFlag.hidden = NO;

    if (self.lastCell != cell) {

        self.lastCell.selFlag.hidden = YES;
    }

    //    self.textString = model.address;

    if (self.lastCell != cell) {

        self.lastCell = cell;
    }
}


@end
