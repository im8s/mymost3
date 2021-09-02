//
//  JXLocation.h
//  shiku_im
//
//  Created by p on 2017/4/1.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JXLocation;
@protocol JXLocationDelegate <NSObject>

// 定位后返回地理信息
- (void) location:(JXLocation *)location CountryCode:(NSString *)countryCode CityName:(NSString *)cityName CityId:(NSString *)cityId Address:(NSString *)address Latitude:(double)lat Longitude:(double)lon;

- (void)location:(JXLocation *)location getLocationWithIp:(NSDictionary *)dict;
- (void)location:(JXLocation *)location getLocationError:(NSError *)error;

@end

@interface JXLocation : NSObject

@property (nonatomic, weak) id<JXLocationDelegate> delegate;

// 开始定位
- (void) locationStart;

// 根据ip获取到地理位置
- (void) getLocationWithIp;

@end
