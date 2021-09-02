//
//  searchData.h
//  shiku_im
//
//  Created by flyeagleTang on 15-2-3.
//  Copyright (c) 2015年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface searchData : NSObject{
}
@property(nonatomic,assign) int countryId;//国家
@property(nonatomic,assign) int provinceId;//省份
@property(nonatomic,assign) int cityId;//城市
@property(nonatomic,assign) int areaId;//区域

@property(nonatomic,strong) NSString* name;//名字
@property(nonatomic,assign) int sex;//性别
@property(nonatomic,assign) int minAge;
@property(nonatomic,assign) int maxAge;
@property(nonatomic,assign) int showTime;//出现时间


@end
