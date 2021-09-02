//
//  JXLocation.m
//  shiku_im
//
//  Created by p on 2017/4/1.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXLocation.h"

@interface JXLocation ()<CLLocationManagerDelegate>
 
@property (nonatomic, strong) CLLocationManager *location;
@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, copy) NSString *cityId;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *address;

@end

@implementation JXLocation

- (instancetype)init {
    if ([super init]) {
        
        _location = [[CLLocationManager alloc] init] ;
        _location.delegate = self;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            //            [_location requestAlwaysAuthorization];//始终允许访问位置信息,必须关闭
            [_location requestWhenInUseAuthorization];//使用应用程序期间允许访问位置数据
        }
    }
    
    return self;
}

- (void)locationStart {
    [_location startUpdatingLocation];
    [_location stopUpdatingHeading];
}

#pragma mark -------------获取经纬度----------------
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *currentLocation = [locations lastObject];
    double latitude  =  currentLocation.coordinate.latitude;
    double longitude =  currentLocation.coordinate.longitude;
    NSLog(@"成功获得位置:latitude:%f,longitude:%f",latitude,longitude);
    
    //根据经纬度反向地理编译出地址信息
    [self getAddressInfo:currentLocation];
    
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [manager stopUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSLog(@"成功获得状态");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"找不到位置: %@", [error description]);
    [self getLocationWithIp];
    return;
}

- (void)getAddressInfo:(CLLocation *)location{
    //    37.422729, -106.000207
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    
    [self reverseGeocode:location];
}

// 国内反编码
- (void) reverseGeocode:(CLLocation *)location{
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (placemarks.count > 0) {
            CLPlacemark *placeMark = [placemarks firstObject];
            
            //            NSLog(@"placeMark:%@\n name:%@\n thoroughfare:%@\n subThoroughfare:%@\n locality:%@\n subLocality:%@\n administrativeArea:%@\n subAdministrativeArea:%@\n postalCode:%@\n ISOcountryCode:%@\n country:%@\n inlandWater:%@\n ocean:%@\n areasOfInterest:%@",placeMark.addressDictionary,placeMark.name,placeMark.thoroughfare,placeMark.subThoroughfare,placeMark.locality,placeMark.subLocality,placeMark.administrativeArea,placeMark.subAdministrativeArea,placeMark.postalCode,placeMark.ISOcountryCode,placeMark.country,placeMark.inlandWater,placeMark.ocean,placeMark.areasOfInterest);
            
            //获取城市名
            NSString *city = placeMark.locality;
            if (!city) {    //四大直辖市的城市信息可能无法通过locality获得，可通过获取省份的方法来获得
                city = placeMark.administrativeArea;
            }
            if (city) {
                self.cityName = city;
                _cityId = [g_constant getCityID:city];
            }
            if (_cityId) {
//                [[NSUserDefaults standardUserDefaults] setObject:_cityId forKey:kCityId];
//                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            
            //获取国家代号（当前所在国家代号，区分国内国外重要依据）
            self.countryCode = placeMark.ISOcountryCode;
//            self.countryCode = @"MY";
            if(self.countryCode) {
                [[NSUserDefaults standardUserDefaults] setObject:self.countryCode forKey:kISOcountryCode];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            
            //从 placeMark.addressDictionary 获取详细地址信息
            NSDictionary *addressDict = placeMark.addressDictionary;
            //            NSLog(@"addressDict:%@",addressDict);
            
            //详细地址
            NSString *addressStr = [addressDict objectForKey:@"Name"];
            //去掉国家名
            addressStr = [addressStr stringByReplacingOccurrencesOfString:placeMark.country withString:@""];
            //如果有州或省名，去掉之
            if ([addressDict objectForKey:@"State"] != nil) {
                addressStr = [addressStr stringByReplacingOccurrencesOfString:[addressDict objectForKey:@"State"] withString:@""];
            }
            
            if (_address) {
                //                [_address release];
                _address = nil;
            }
            _address = [[NSString alloc] initWithFormat:@"%@%@",self.cityName,addressStr];
            
            if ([self.delegate respondsToSelector:@selector(location:CountryCode:CityName:CityId:Address:Latitude:Longitude:)]) {
                [self.delegate location:self CountryCode:self.countryCode CityName:self.cityName CityId:self.cityId Address:self.address Latitude:location.coordinate.latitude Longitude:location.coordinate.longitude];
            }
            
            //            NSLog(@"登录地址:%@ countryCode:%@ city:%@ cityId:%d",_address,self.countryCode,_cityName,_cityId);
            
            //            if (isLogin || _isGetSetting) {
            //                [self getSetting:self];
            //            }
            
            //            [g_App.mainVc changeUserCityId];
        }else {
            [self reverseGeocodeWithGoogleapi:location];
        }
    }];
}

// 国外使用谷歌api反编码
- (void)reverseGeocodeWithGoogleapi:(CLLocation *)location {
    // 国内反编码失败  启用谷歌反编码
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true",location.coordinate.latitude, location.coordinate.longitude];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    [manager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic[@"status"] isEqualToString:@"OK"]) {
            NSArray *returenArray = responseDic[@"results"];
            NSDictionary *addressDic = returenArray[0];
            
            //                    NSDictionary *locationDic = addressDic[@"geometry"][@"location"];
            //                    self.inputLocX = [locationDic[@"lng"] doubleValue];
            //                    self.inputLocY = [locationDic[@"lat"] doubleValue];
            NSArray *arr = addressDic[@"address_components"];
            
            // 获取国家代号
            for (NSDictionary *dict in arr) {
                NSArray *types = dict[@"types"];
                NSString *type = [types firstObject];
                if ([type isEqualToString:@"country"]) {
                    
                    self.countryCode = dict[@"short_name"];
                    break;
                }
            }
            
            if (self.countryCode) {
                
                [[NSUserDefaults standardUserDefaults] setObject:self.countryCode forKey:kISOcountryCode];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            // 获取到城市
            for (NSDictionary *dict in arr) {
                NSArray *types = dict[@"types"];
                NSString *type = [types firstObject];
                if ([type isEqualToString:@"locality"]) {
                    
                    self.cityName = dict[@"long_name"];
//                    self.cityId = [g_constant getTypeCityId:self.cityName];
                    break;
                }
            }
            // 如果城市id获取不到，就用省份查id（areas表里 有的外国省对应表里的城市）
            if (!self.cityId) {
                for (NSDictionary *dict in arr) {
                    NSArray *types = dict[@"types"];
                    NSString *type = [types firstObject];
                    if ([type isEqualToString:@"administrative_area_level_1"]) {
                        
                        self.cityName = dict[@"long_name"];
//                        self.cityId = [g_constant getTypeCityId:self.cityName];
                        break;
                    }
                }
            }
            
            if (_cityId) {
                
                [[NSUserDefaults standardUserDefaults] setObject:_cityId forKey:kCityId];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            _address = addressDic[@"formatted_address"];
            
            if ([self.delegate respondsToSelector:@selector(location:CountryCode:CityName:CityId:Address:Latitude:Longitude:)]) {
                [self.delegate location:self CountryCode:self.countryCode CityName:self.cityName CityId:self.cityId Address:self.address Latitude:location.coordinate.latitude Longitude:location.coordinate.longitude];
            }
            
            //
            //                    if (isLogin || _isGetSetting) {
            //                        [self getSetting:self];
            //                    }
            
            NSLog(@"response = %@",responseObject);
        }else {
            [self getLocationWithIp];
        }
        NSLog(@"response = %@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self getLocationWithIp];
        //        self.addrBtn.hidden = YES;
        NSLog(@"error = %@",error);
    }];
}

- (void)getLocationWithIp {
    NSString *urlString = @"https://ipinfo.io/geo";
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    manager.requestSerializer.timeoutInterval = 5.0;
    [manager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        
        // 国家代号
        self.countryCode = responseDic[@"country"];
        if (self.countryCode) {
            [[NSUserDefaults standardUserDefaults] setObject:self.countryCode forKey:kISOcountryCode];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        
        // 城市
        //            self.cityName = responseDic[@"city"];
        self.cityName = responseDic[@"city"];
//        self.cityId = [g_constant getCityId:self.cityName Language:@"en"];
        
        // 如果城市id获取不到，就用省份查id（areas表里 有的外国省对应表里的城市）
        if (!self.cityId) {
            self.cityName = responseDic[@"region"];
//            self.cityId = [g_constant getCityId:self.cityName Language:@"en"];
            
        }
        
        if (_cityId) {
            [[NSUserDefaults standardUserDefaults] setObject:_cityId forKey:kCityId];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        _address = [NSString stringWithFormat:@"%@%@",responseDic[@"region"],responseDic[@"city"]];
        
        NSString *loc = responseDic[@"loc"];
        NSRange range = [loc rangeOfString:@","];
        NSString *lat = [loc substringToIndex:range.location];
        NSString *lon = [loc substringFromIndex:range.location + range.length];
        
        if ([self.delegate respondsToSelector:@selector(location:CountryCode:CityName:CityId:Address:Latitude:Longitude:)]) {
            [self.delegate location:self CountryCode:self.countryCode CityName:self.cityName CityId:self.cityId Address:self.address Latitude:[lat doubleValue] Longitude:[lon doubleValue]];
        }
        
        if ([self.delegate respondsToSelector:@selector(location:getLocationWithIp:)]) {
            [self.delegate location:self getLocationWithIp:responseDic];
        }
//
//        if (isLogin || _isGetSetting) {
//            [self getSetting:self];
//        }
        
        NSLog(@"response = %@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([self.delegate respondsToSelector:@selector(location:getLocationError:)]) {
            [self.delegate location:self getLocationError:error];
        }
        //        self.addrBtn.hidden = YES;
        NSLog(@"error = %@",error);
    }];
}

@end
