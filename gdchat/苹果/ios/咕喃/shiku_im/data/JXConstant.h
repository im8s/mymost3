//
//  JXConstant.h
//  shiku_im
//
//  Created by flyeagleTang on 14-11-7.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;

#define NAME @"zh"         // 中文
#define ENNAME @"en"       //英文
#define ZHHANTNAME @"big5" // 繁体
#define MALAYNAME @"malay"
#define THNAME @"th"
#define JANAME @"ja"       // 日文
#define KONAME @"ko"       // 韩语
#define IDYNAME @"idy"     // 印尼语
#define VINAME @"vi"       // 越南语
#define MSNAME @"ms"       // 马来语
#define FYNAME @"fy"       // 菲律宾语


@interface JXConstant : NSObject{
    FMDatabase* _db;
    NSString *_sysName;
//    NSMutableDictionary* _country;
//    NSMutableDictionary* _province;
//    NSMutableDictionary* _city;
//    NSMutableDictionary* _area;
}

@property (nonatomic,strong) NSString *sysLanguage;
@property (nonatomic,assign) CGFloat chatFont;

@property(nonatomic,strong) NSMutableDictionary* country;
@property(nonatomic,strong) NSMutableDictionary* province;
@property(nonatomic,strong) NSMutableDictionary* city;
@property(nonatomic,strong) NSMutableDictionary* cityN;
@property(nonatomic,strong) NSMutableDictionary* diploma;
@property(nonatomic,strong) NSMutableDictionary* workexp;
@property(nonatomic,strong) NSMutableDictionary* salary;
@property(nonatomic,strong) NSMutableDictionary* nature;
@property(nonatomic,strong) NSMutableDictionary* scale;
@property(nonatomic,strong) NSMutableDictionary* cometime;
@property(nonatomic,strong) NSMutableDictionary* worktype;
@property(nonatomic,strong) NSMutableDictionary* industry;
@property(nonatomic,strong) NSMutableDictionary* function;
@property(nonatomic,strong) NSMutableDictionary* major;
@property(nonatomic,strong) NSMutableDictionary* localized;
@property (nonatomic, strong) NSMutableDictionary *userBackGroundImage;

@property(nonatomic,strong) NSMutableArray* country_name;
@property(nonatomic,strong) NSMutableArray* country_value;
@property(nonatomic,strong) NSMutableArray* province_name;
@property(nonatomic,strong) NSMutableArray* province_value;
@property(nonatomic,strong) NSMutableArray* diploma_name;
@property(nonatomic,strong) NSMutableArray* diploma_value;
@property(nonatomic,strong) NSMutableArray* workexp_name;
@property(nonatomic,strong) NSMutableArray* workexp_value;
@property(nonatomic,strong) NSMutableArray* salary_name;
@property(nonatomic,strong) NSMutableArray* salary_value;
@property(nonatomic,strong) NSMutableArray* nature_name;
@property(nonatomic,strong) NSMutableArray* nature_value;
@property(nonatomic,strong) NSMutableArray* scale_name;
@property(nonatomic,strong) NSMutableArray* scale_value;
@property(nonatomic,strong) NSMutableArray* cometime_name;
@property(nonatomic,strong) NSMutableArray* cometime_value;
@property(nonatomic,strong) NSMutableArray* worktype_name;
@property(nonatomic,strong) NSMutableArray* worktype_value;
@property(nonatomic,strong) NSMutableArray* industry_name;
@property(nonatomic,strong) NSMutableArray* industry_value;
@property(nonatomic,strong) NSMutableArray* function_name;
@property(nonatomic,strong) NSMutableArray* function_value;
@property(nonatomic,strong) NSMutableArray* major_name;
@property(nonatomic,strong) NSMutableArray* major_value;
@property (nonatomic,strong) NSMutableArray *telArea;

@property (nonatomic,strong) NSMutableArray *emojiArray;

//-(void) getCountry;
-(NSMutableDictionary*) getProvince:(int)countryId;
-(NSMutableDictionary*) getCity:(int)provinceId;
-(NSMutableDictionary*) getArea:(int)cityId;

-(NSMutableDictionary*) getDiploma;
-(NSMutableDictionary*) getWorkExp;
-(NSMutableDictionary*) getSalary;
-(NSMutableDictionary*) getNature;
-(NSMutableDictionary*) getScale;
-(NSMutableDictionary*) getComeTime;
-(NSMutableDictionary*) getWorkType;
-(NSMutableDictionary*) getIndustry;
-(NSMutableDictionary*) getFunction;
-(NSMutableDictionary*) getLocalized;

-(NSString*)getAddress:(NSString*)provinceId cityId:(NSString*)cityId areaId:(NSString*)cityId;
-(NSString*)getAddressForInt:(int)provinceId cityId:(int)cityId areaId:(int)areaId;
-(NSString*)getAddressForNumber:(NSNumber*)provinceId cityId:(NSNumber*)cityId areaId:(NSNumber*)areaId;

-(NSArray*)getSortKeys:(NSMutableDictionary*)dict;
-(NSArray*)getSortValues:(NSMutableDictionary*)dict;

-(NSMutableDictionary*)doGetDict:(int)n name:(NSMutableArray*)name value:(NSMutableArray*)value;
-(void)getNameValues:(int)n name:(NSMutableArray*)name value:(NSMutableArray*)value;
- (NSString *)LocalizedWithStr:(NSString *)str;
- (NSMutableArray *) getSearchTelAreaWithName:(NSString *) name ;

-(NSString*) getCityID:(NSString *)s;
-(NSString *)getParentWithCityId:(int)cityId;

// 重置本地语言
- (void) resetlocalized;

@end
