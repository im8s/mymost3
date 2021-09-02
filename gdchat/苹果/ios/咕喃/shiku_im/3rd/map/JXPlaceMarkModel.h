//
//  JXPlaceMarkModel.h
//  shiku_im
//
//  Created by MacZ on 16/8/31.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class BMKPoiInfo;

@interface JXPlaceMarkModel : NSObject

@property (nonatomic,assign) double longitude;  //经度
@property (nonatomic,assign) double latitude;   //纬度

@property (nonatomic,copy) NSString *placeName;   //建筑名
@property (nonatomic,copy) NSString *address;    //街道信息

@property (nonatomic,copy) NSString *city;    //城市
@property (nonatomic,copy) NSString *imageUrl;
/**名称*/
@property(nonatomic,copy)NSString *name;

+ (JXPlaceMarkModel *)modelByCLPlacemark:(CLPlacemark *)placeMark;
+ (JXPlaceMarkModel *)modelByMKMapItem:(MKMapItem *)mapItem;
+ (JXPlaceMarkModel *)modelByBMKPoiInfo:(BMKPoiInfo *)bmkPoiInfo;

@end
