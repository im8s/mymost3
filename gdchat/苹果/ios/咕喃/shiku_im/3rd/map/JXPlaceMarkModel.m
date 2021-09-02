//
//  JXPlaceMarkModel.m
//  shiku_im
//
//  Created by MacZ on 16/8/31.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXPlaceMarkModel.h"
#import <MapKit/MapKit.h>

#import <BaiduMapAPI_Search/BMKPoiSearchType.h>

@implementation JXPlaceMarkModel

+ (JXPlaceMarkModel *)modelByCLPlacemark:(CLPlacemark *)placeMark{
    JXPlaceMarkModel *model = [[JXPlaceMarkModel alloc] init];
    
    model.longitude = placeMark.location.coordinate.longitude;
    model.latitude = placeMark.location.coordinate.latitude;
    model.placeName = placeMark.thoroughfare;
    model.address = [placeMark.name stringByReplacingOccurrencesOfString:placeMark.country withString:@""]; //去掉国家名
    model.address = [model.address stringByReplacingOccurrencesOfString:placeMark.administrativeArea withString:@""];   //去掉省份名
    
    return model;
}

+ (JXPlaceMarkModel *)modelByMKMapItem:(MKMapItem *)mapItem{
    JXPlaceMarkModel *model = [[JXPlaceMarkModel alloc] init];
    
    model.longitude = mapItem.placemark.location.coordinate.longitude;
    model.latitude = mapItem.placemark.location.coordinate.latitude;
    model.placeName = mapItem.name;
    model.address = mapItem.placemark.thoroughfare;
    
    return model;
}

+ (JXPlaceMarkModel *)modelByBMKPoiInfo:(BMKPoiInfo *)bmkPoiInfo{
    JXPlaceMarkModel *model = [[JXPlaceMarkModel alloc] init];
    
    model.longitude = bmkPoiInfo.pt.longitude;
    model.latitude = bmkPoiInfo.pt.latitude;
    model.placeName = bmkPoiInfo.name;
    model.address = bmkPoiInfo.address;
    
    model.name = bmkPoiInfo.name;
    model.city = bmkPoiInfo.city;
    
    return model;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"name:%@,经纬度:(%f,%f),建筑名:%@,地址:%@,城市:%@",self.name,self.longitude,self.latitude,self.placeName,self.address,self.city];
}

@end
