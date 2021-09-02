//
//  JXLocationVC.m
//  CustomMKAnnotationView
//
//  Created by Jian-Ye on 12-11-22.
//  Copyright (c) 2012年 Jian-Ye. All rights reserved.
//

#import "JXLocationVC.h"

#import "JXMapData.h"
#import "admobViewController.h"
#import "JXPlaceMarkModel.h"
#import "JXNearMarkCell.h"
#import "SPAlertController.h"
#import "JZLocationConverter.h"


@interface JXLocationVC()<JXActionSheetVCDelegate>

@property (nonatomic, strong) JXPlaceMarkModel*model;

@property (nonatomic, strong) JXNearMarkCell *lastCell;

@property (nonatomic, strong) BMKUserLocation *userLocation; //当前位置对象

@end
@implementation JXLocationVC


- (id)init
{
    self = [super init];
    if (self) {
        self.title = Localized(@"JXUserInfoVC_Loation");
        self.heightHeader = _locationType ==JXLocationTypeShowStaticLocation ? 0 : JX_SCREEN_TOP;
        self.heightFooter = 0;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.isGotoBack = YES;
        
        // 定位回调或反编码回调前，self被销毁会造成闪退
        self.isFreeOnClose = NO;
        if (!_locations)
            _locations = [[NSMutableArray alloc]init];
        
        _address = g_server.address;
        _nearMarkArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createHeadAndFoot];
    [self initBaiduMapView];
    [self initUserLocationManager];
    [self requestLocation];
//    [self requesetSerialLocation];
    
    [self customView];
    self.tableBody.contentSize = CGSizeMake(0, JX_SCREEN_HEIGHT - JX_SCREEN_TOP);
//    _baiduMapView.showsUserLocation = YES;//显示定位图层
//    [_baiduMapView updateLocationData:userLocation];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_baiduMapView viewWillAppear];
    _baiduMapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_baiduMapView viewWillDisappear];
    _baiduMapView.delegate = nil; // 不用时，置nil
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (_locationType == JXLocationTypeShowStaticLocation) {
        JXMapData * staticData = [_locations firstObject];
        [self makeMapCenter:staticData];
        [self addPointAnnotations:_locations];
        self.title = staticData.title;
    }else {
        //定位服务
        [self requesetSerialLocation];
    }
    
}

- (void)customView{
    if (_locationType == JXLocationTypeShowStaticLocation) {
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, JX_SCREEN_TOP - 38, 31, 31)];
        [backBtn setBackgroundImage:[UIImage imageNamed:@"map_back"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backBtn];

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
        
    }else{
        //发送
        if(self.isSend){
            _sendButton = [UIFactory createCommonButton:self.isCircleCome ? Localized(@"JX_Confirm") : Localized(@"JX_Send") target:self action:@selector(onSelect)];
            _sendButton.frame = CGRectMake(JX_SCREEN_WIDTH - 15-32, JX_SCREEN_TOP - 30, 32, 15);
            [self.tableHeader addSubview:_sendButton];
            [_sendButton setBackgroundImage:nil forState:UIControlStateNormal];
            [_sendButton setBackgroundImage:nil forState:UIControlStateHighlighted];
            [_sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            _sendButton.titleLabel.font = SYSFONT(15);
            _sendButton.hidden = YES;
//            _sendButton.userInteractionEnabled = NO;
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                _sendButton.userInteractionEnabled = YES;
//            });
        }
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
        _nearMarkTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT - 200, JX_SCREEN_WIDTH, 200) style:UITableViewStylePlain];
        _nearMarkTableView.dataSource = self;
        _nearMarkTableView.delegate = self;
        _nearMarkTableView.separatorStyle = UITableViewCellSelectionStyleNone;
        [self.view addSubview:_nearMarkTableView];
    }
}
//复位按钮响应事件
-(void)resetLocation{
    [self requestLocation];
    if (self.userLocation.location == nil) {
        [g_App showAlert:Localized(@"JXLoc_StartLocNotice")];
        return;
    }
    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(self.userLocation.location.coordinate, BMKCoordinateSpanMake(0.0001f,0.0001f));
//    BMKCoordinateRegion adjustedRegion = [_baiduMapView regionThatFits:viewRegion];
    [_baiduMapView setRegion:viewRegion animated:YES];
    
}

-(void)resetMapCenter{
    [self makeMapCenter:[_locations firstObject]];
}

- (void)initBaiduMapView{
    _baiduMapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, self.tableBody.frame.size.width, self.tableBody.frame.size.height)];
    _baiduMapView.minZoomLevel = 6;
    _baiduMapView.zoomEnabled = YES;
    
    _baiduMapView.showsUserLocation = YES;
    [self.tableBody addSubview:_baiduMapView];
}

- (void)initUserLocationManager{
    BMKLocationViewDisplayParam *parm = [[BMKLocationViewDisplayParam alloc] init];
    parm.isAccuracyCircleShow = YES;
    [_baiduMapView updateLocationViewWithParam:parm];
    
    _locationManager = [[BMKLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
    _locationManager.pausesLocationUpdatesAutomatically = NO;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    _locationManager.locationTimeout = 15;
    _locationManager.reGeocodeTimeout = 15;
    
}

- (void)requestLocation{
    __weak typeof(self) weakSelf = self;
    
    [_locationManager requestLocationWithReGeocode:YES withNetworkState:YES completionBlock:^(BMKLocation * _Nullable location, BMKLocationNetworkState state, NSError * _Nullable error) {
//        weakSelf.userLocation.location = location.location;
//        if (error) {
//
//        }
//        if (location.location) {
//            if (!weakSelf.userLocation) {
//                weakSelf.userLocation = [[BMKUserLocation alloc] init];
//            }
//            [_baiduMapView updateLocationData:weakSelf.userLocation];
//            CLLocationCoordinate2D mycoordinate = location.location.coordinate;
//            [_baiduMapView setCenterCoordinate:mycoordinate animated:YES];
//        }
        CLLocationCoordinate2D  coor;
               if (weakSelf.latitude == 0 && weakSelf.longitude ==0) {
                   if (location.location == nil) {
                       [g_App showAlert:Localized(@"JXLoc_StartLocNotice")];
                       return;
                   }
                   weakSelf.latitude = location.location.coordinate.latitude;
                   weakSelf.longitude = location.location.coordinate.longitude;
                   coor = location.location.coordinate;
               }else{
                   coor = (CLLocationCoordinate2D){weakSelf.longitude,weakSelf.latitude};
               }

               if (location) {
                   [_locationManager stopUpdatingLocation];
               }
               
           //    _annotation.coordinate = coor;
               ///表示一个经纬度区域
               BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(coor, BMKCoordinateSpanMake(0.0001f,0.0001f));
               [_baiduMapView setRegion:viewRegion animated:YES];
               _baiduMapView.zoomLevel = 17;
           
               //设置地图中心为用户经纬度
               //    [_mapView updateLocationData:userLocation];
               if (_reverseGeoCodeOption==nil) {
                   _reverseGeoCodeOption= [[BMKReverseGeoCodeSearchOption alloc] init];
               }
               if (_geoCodeSearch==nil) {
                   //初始化地理编码,
                   _geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
                   _geoCodeSearch.delegate = weakSelf;

               }
               //返回当前位置附近的信息
               _reverseGeoCodeOption.location = coor;
               [_geoCodeSearch reverseGeoCode:_reverseGeoCodeOption];
        
    }];
}

- (void)requesetSerialLocation{
    _locationManager.locatingWithReGeocode = YES;
    [_locationManager startUpdatingLocation];
}

-(void)addPointAnnotations:(NSArray *)locArray{
    // 在地图中添加PointAnnotation
    for (JXMapData * mapData in locArray) {
        CLLocationCoordinate2D coor = [mapData coordinate2D];
        BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc]init];
        annotation.title = mapData.title;
        annotation.subtitle = mapData.subtitle;
        annotation.coordinate = coor;
        [_baiduMapView addAnnotation:annotation];
    }
}

-(void)makeMapCenter:(JXMapData *)centerData{
    
    CLLocationCoordinate2D coor = [centerData coordinate2D];
    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(coor, BMKCoordinateSpanMake(0.0001f,0.0001f));
//    BMKCoordinateRegion adjustedRegion = [_baiduMapView regionThatFits:viewRegion];
    [_baiduMapView setRegion:viewRegion animated:YES];
    [_baiduMapView setCenterCoordinate:coor animated:YES];
    
}

#pragma mark BMKLocationServiceDelegate
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager doRequestAlwaysAuthorization:(CLLocationManager * _Nonnull)locationManager
{
    
    [locationManager requestAlwaysAuthorization];
}

- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error{
     //定位到当前位置
        CLLocationCoordinate2D  coor;
        if (self.latitude == 0 && self.longitude ==0) {
            if (location.location == nil) {
                [g_App showAlert:Localized(@"JXLoc_StartLocNotice")];
                return;
            }
            self.latitude = location.location.coordinate.latitude;
            self.longitude = location.location.coordinate.longitude;
            coor = location.location.coordinate;
        }else{
            coor = (CLLocationCoordinate2D){self.longitude,self.latitude};
        }

        if (location) {
            [_locationManager stopUpdatingLocation];
        }
        
    //    _annotation.coordinate = coor;
        ///表示一个经纬度区域
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(coor, BMKCoordinateSpanMake(0.0001f,0.0001f));
        [_baiduMapView setRegion:viewRegion animated:YES];
        _baiduMapView.zoomLevel = 17;
    
        //设置地图中心为用户经纬度
        //    [_mapView updateLocationData:userLocation];
        if (_reverseGeoCodeOption==nil) {
            _reverseGeoCodeOption= [[BMKReverseGeoCodeSearchOption alloc] init];
        }
        if (_geoCodeSearch==nil) {
            //初始化地理编码,
            _geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
            _geoCodeSearch.delegate = self;

        }
        //返回当前位置附近的信息
        _reverseGeoCodeOption.location = coor;
        [_geoCodeSearch reverseGeoCode:_reverseGeoCodeOption];
}


#pragma mark BMKMapViewDelegate
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (_locationType == JXLocationTypeShowStaticLocation) {
        
    }else{
        CLLocationCoordinate2D mapCoordinate=  mapView.getMapStatus.targetGeoPt;
        self.latitude = mapCoordinate.latitude;
        self.longitude = mapCoordinate.longitude;
        NSLog(@"精度%f 维度%f   %d",self.latitude,self.longitude,self.tableBody.userInteractionEnabled);
//        CLLocationCoordinate2D  coor;
//        coor = (CLLocationCoordinate2D){self.locX,self.locY};
        //    _annotation.coordinate = coor;
        
        //    _reverseGeoCodeOption.reverseGeoPoint = (CLLocationCoordinate2D){114.060456,22.615227};
        _reverseGeoCodeOption.location = mapCoordinate;
        BOOL flag = [_geoCodeSearch reverseGeoCode:_reverseGeoCodeOption];
        
        if(flag)
        {
            NSLog(@"反geo检索发送成功");
        }else
        {
            NSLog(@"反geo检索发送失败");
        }
    }
}
//-(void)mapView:(BMKMapView *)mapView onDrawMapFrame:(BMKMapStatus *)status{
////    NSLog(@"%f,%f",status.targetScreenPt.x,status.targetScreenPt.y);
//        NSLog(@"targetGeoPt:%f,%f",status.targetGeoPt.latitude,status.targetGeoPt.longitude);
//    _annotation.coordinate = status.targetGeoPt;
//}

//返回反地理编码搜索结果
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error{
//    [_address release];
    _address = [[NSString alloc]initWithFormat:@"%@",result.address];
    
    NSLog(@"%@",result.addressDetail);
    //获取周边用户信息
    _sendButton.hidden = NO;
    if (error==BMK_SEARCH_NO_ERROR) {
        [_nearMarkArray removeAllObjects];
        
        for(BMKPoiInfo *poiInfo in result.poiList)
        {
            [_nearMarkArray addObject:[JXPlaceMarkModel modelByBMKPoiInfo:poiInfo]];
        }
        _selIndex = 0;
        if (!_nearMarkArray || _nearMarkArray.count <= 0) {
            return;
        }
        JXPlaceMarkModel*model = [_nearMarkArray objectAtIndex:0];
        NSLog(@"%@",model);
        model.address = result.address;
        if (result.sematicDescription.length > 0) {
            model.name = result.sematicDescription;
        }
        model.latitude = result.location.latitude;
        model.longitude = result.location.longitude;
        self.model = model;
//
        [_nearMarkTableView reloadData];
        
    }else{
        NSLog(@"BMKSearchErrorCode: %u",error);
    }
}

-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *myAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];                 //初始化一个大头针标注
        myAnnotationView.pinColor = BMKPinAnnotationColorGreen;
        myAnnotationView.animatesDrop = YES;
//        myAnnotationView.draggable = YES;
        myAnnotationView.image = [UIImage imageNamed:@"position"];
        return myAnnotationView;
    }
    return nil;
}
-(void)dealloc{
    NSLog(@"JXLocationVC dealloc");
    
    [_locations removeAllObjects];
    _locations = nil;
    _delegate = nil;
}

-(void)onSelect{
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
    [_baiduMapView removeFromSuperview];
    
//    _pSelf = nil;
}

-(NSString *)screenShotAction{
//    BOOL su = [_baiduMapView zoomOut];
//    UIImage *image = [_baiduMapView takeSnapshot:CGRectMake(0, (CGRectGetHeight(_baiduMapView.frame)-JX_SCREEN_WIDTH/2.2)/2, JX_SCREEN_WIDTH-100, JX_SCREEN_WIDTH/2.2-100)];
//    UIImage *logoImage = [self addImageLogo:image text:[UIImage imageNamed:@"position"]];
//    //写入文件
//    NSString* filePath = [FileInfo getUUIDFileName:@"jpg"];
//    [g_server saveImageToFile:logoImage file:filePath isOriginal:NO];
    UIImage *image = [self snapshotToImage:CGSizeMake(JX_SCREEN_WIDTH, JX_SCREEN_WIDTH/2.2)];
    UIImage *logoImage = [self addImageLogo:image text:[UIImage imageNamed:@"position"]];
    NSString* filePath = [FileInfo getUUIDFileName:@"jpg"];
    [g_server saveImageToFile:logoImage file:filePath isOriginal:NO];

    return filePath;
}

- (nullable UIImage *)snapshotToImage:(CGSize)size {
    CGPoint map_center = _baiduMapView.center;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [_baiduMapView drawViewHierarchyInRect:CGRectMake(0, -(map_center.y - size.height)-JX_SCREEN_TOP, _baiduMapView.bounds.size.width, _baiduMapView.bounds.size.height) afterScreenUpdates:YES];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshotImage;
}

-(UIImage *)addImageLogo:(UIImage *)img text:(UIImage *)logo
{
    
    int w = img.size.width;
    int h = img.size.height;
    int logoWidth = 40;
    int logoHeight = 80;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGContextDrawImage(context, CGRectMake((w-logoWidth)/2, h/2-10, logoWidth, logoHeight), [logo CGImage]);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:imageMasked];
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
////    UIAlertController * alertSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
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
////    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
////        UIAlertAction *actionQq = [UIAlertAction actionWithTitle:@"腾讯地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
////            NSLog(@"腾讯地图");
////            [self onQQMap];
////        }];
////        [alertSheet addAction:actionQq];
////    }
//    
//    SPAlertAction * cancelAction = [SPAlertAction actionWithTitle:Localized(@"JX_Cencal") style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
//        NSLog(@"取消");
//    }];
//    [alertSheet addAction:cancelAction];
//
//    
////    if ([alertSheet respondsToSelector:@selector(popoverPresentationController)]) {
////        alertSheet.popoverPresentationController.sourceView = self.view; //必须加
////        alertSheet.popoverPresentationController.sourceRect = CGRectMake(0, JX_SCREEN_HEIGHT, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);//可选，我这里加这句代码是为了调整到合适的位置
////    }
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
    
    // 转换坐标
    toCoor = [JZLocationConverter bd09ToGcj02:toCoor];
    
    
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
    //    m	驾车：0：速度最快，1：费用最少，2：距离最短，3：不走高速，4：躲避拥堵，5：不走高速且避免收费，6：不走高速且躲避拥堵，7：躲避收费和拥堵，8：不走高速躲避收费和拥堵 公交：0：最快捷，2：最少换乘，3：最少步行，5：不乘地铁 ，7：只坐地铁 ，8：时间短	是
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
    
    // 转换坐标
    toCoor = [JZLocationConverter bd09ToGcj02:toCoor];

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
    //    mode	导航模式，固定为transit、driving、walking，分别表示公交、驾车和步行
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
    
    // 转换坐标
    toCoor = [JZLocationConverter bd09ToGcj02:toCoor];

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




#pragma mark  tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _nearMarkArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JXNearMarkCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JXNearMarkCell class])];
    if (cell == nil) {
        cell = [[JXNearMarkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([JXNearMarkCell class])];
    }
    [cell refreshWithModel:[_nearMarkArray objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    [_locationManager stopUpdatingLocation];
    
    _selIndex = indexPath.row;
    
    JXPlaceMarkModel*model = [_nearMarkArray objectAtIndex:indexPath.row];
//    _locationTF.text = model.address;
//    
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

#pragma mark 设置cell分割线做对齐
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

-(void)viewDidLayoutSubviews {
    
    if ([_nearMarkTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_nearMarkTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_nearMarkTableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [_nearMarkTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)actionQuit {
    if (self.isAddWindow) {
        [self.view removeFromSuperview];
        self.view = nil;
    }else{
        [super actionQuit];
    }
}

@end
