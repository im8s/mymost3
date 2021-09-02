//
//  JXLocationVC.h
//  CustomMKAnnotationView
//
//  Created by Jian-Ye on 12-11-22.
//  Copyright (c) 2012年 Jian-Ye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "admobViewController.h"
#import <QuartzCore/QuartzCore.h>

#import <BaiduMapAPI_Map/BMKMapComponent.h>//只引入所需的单个头文件
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BMKLocationKit/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件

typedef NS_OPTIONS(NSUInteger, JXLocationType){
    JXLocationTypeCurrentLocation     = 0,
    JXLocationTypeShowStaticLocation  = 2,
};


@interface JXLocationVC : admobViewController<BMKMapViewDelegate,BMKLocationManagerDelegate,BMKGeoCodeSearchDelegate,UITableViewDelegate,UITableViewDataSource>{
    BMKMapView *_baiduMapView;   //地图类
    BMKLocationManager *_locationManager;  //定位
    BMKGeoCodeSearch *_geoCodeSearch;   //搜索服务
    BMKReverseGeoCodeSearchOption *_reverseGeoCodeOption; //反地理编码对象
    BMKPointAnnotation *_annotation;
//    BMKPinAnnotationView * _pinAnnotationView;
    NSInteger _selIndex;
    NSMutableArray *_nearMarkArray; //周边检索数据源
    UITableView * _nearMarkTableView;
}

@property (nonatomic,assign) JXLocationType locationType;

@property (nonatomic,assign) double latitude;
@property (nonatomic,assign) double longitude;
@property (nonatomic,copy) NSString * address;
//@property (nonatomic,copy) NSString * imagePath;
@property (nonatomic,copy) NSString * placeNames;

@property (nonatomic,retain)  NSMutableArray *locations;
@property (nonatomic, assign) NSObject* delegate;
@property (nonatomic, assign) SEL		didSelect;
@property (nonatomic, assign) BOOL      isSend;

@property (nonatomic, assign) BOOL      isCircleCome;

@property (nonatomic,retain)  UIButton * sendButton;

@property (nonatomic, assign) BOOL isAddWindow;

@end
