//
//  JXConstant.m
//  shiku_im
//
//  Created by flyeagleTang on 14-11-7.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXConstant.h"
#import "FMDatabase.h"
#import "JXMyTools.h"

#define DB_NAME @"constant.db"

@implementation JXConstant
@synthesize country,province,city,cityN;
@synthesize diploma,workexp,salary,nature,scale,cometime,worktype,industry,function;
@synthesize country_name;
@synthesize country_value;
@synthesize province_name;
@synthesize province_value;
@synthesize diploma_name;
@synthesize diploma_value;
@synthesize workexp_name;
@synthesize workexp_value;
@synthesize salary_name;
@synthesize salary_value;
@synthesize nature_name;
@synthesize nature_value;
@synthesize scale_name;
@synthesize scale_value;
@synthesize cometime_name;
@synthesize cometime_value;
@synthesize worktype_name;
@synthesize worktype_value;
@synthesize industry_name;
@synthesize industry_value;
@synthesize function_name;
@synthesize function_value;
@synthesize major;
@synthesize major_name;
@synthesize major_value;

-(id)init{
    self = [super init];
    
    NSString *lang = [g_default stringForKey:kLocalLanguage];
    if (!lang || lang.length <= 0) {
        lang = [JXMyTools getCurrentSysLanguage];
    }
    _sysLanguage =lang;
    _sysName = [self getCurCountryFieldName];
    
    country = [[NSMutableDictionary alloc]init];
    city = [[NSMutableDictionary alloc]init];
    cityN = [[NSMutableDictionary alloc]init];
    country_name = [[NSMutableArray alloc]init];
    country_value = [[NSMutableArray alloc]init];
    province_name = [[NSMutableArray alloc]init];
    province_value = [[NSMutableArray alloc]init];
    diploma_name = [[NSMutableArray alloc]init];
    diploma_value = [[NSMutableArray alloc]init];
    workexp_name = [[NSMutableArray alloc]init];
    workexp_value = [[NSMutableArray alloc]init];
    salary_name = [[NSMutableArray alloc]init];
    salary_value = [[NSMutableArray alloc]init];
    nature_name = [[NSMutableArray alloc]init];
    nature_value = [[NSMutableArray alloc]init];
    scale_name = [[NSMutableArray alloc]init];
    scale_value = [[NSMutableArray alloc]init];
    cometime_name = [[NSMutableArray alloc]init];
    cometime_value = [[NSMutableArray alloc]init];
    worktype_name = [[NSMutableArray alloc]init];
    worktype_value = [[NSMutableArray alloc]init];
    industry_name = [[NSMutableArray alloc]init];
    industry_value = [[NSMutableArray alloc]init];
    function_name = [[NSMutableArray alloc]init];
    function_value = [[NSMutableArray alloc]init];
    major_name = [[NSMutableArray alloc]init];
    major_value = [[NSMutableArray alloc]init];
    _telArea = [[NSMutableArray alloc] init];
    _userBackGroundImage = [NSMutableDictionary dictionary];
    
    [self getData];
    
//    [self getTelArea];
////    _sysName = [self getCurCountryFieldName];
//
//    self.city  = [self getCity];
//    self.cityN = [self getCity2];
//    self.country  = [self getCountrys];
////    self.province = [self getProvince:1];
//    self.diploma  = [self getDiploma];
//    self.workexp  = [self getWorkExp];
//    self.salary   = [self getSalary];
//    self.nature   = [self getNature];
//    self.scale    = [self getScale];
//    self.cometime = [self getComeTime];
//    self.worktype = [self getWorkType];
//    self.industry = [self getIndustry];
//    self.function = [self getFunction];
//    self.major    = [self getMajor];
//    self.localized = [self getLocalized];

////    [self getProvince:1];
////    [self getCity:430000];
////    [self getArea:430400];
    return self;
}

- (void) getData {
    [self getTelArea];
    //    _sysName = [self getCurCountryFieldName];
    
    self.city  = [self getCity];
    self.cityN = [self getCity2];
    self.country  = [self getCountrys];
    //    self.province = [self getProvince:1];
    self.diploma  = [self getDiploma];
    self.workexp  = [self getWorkExp];
    self.salary   = [self getSalary];
    self.nature   = [self getNature];
    self.scale    = [self getScale];
    self.cometime = [self getComeTime];
    self.worktype = [self getWorkType];
    self.industry = [self getIndustry];
    self.function = [self getFunction];
    self.major    = [self getMajor];
    self.localized = [self getLocalized];
    self.userBackGroundImage = [self getUserBackGroundImage];
    CGFloat chatFont = [[g_default objectForKey:kChatFont] floatValue];
    if (chatFont > 0) {
        self.chatFont = chatFont;
    }else {
        self.chatFont = 15.0;
    }
}

- (NSMutableDictionary *)getUserBackGroundImage {
    
    NSString *path = backImage;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    return dict;
}

-(void)dealloc{
    self.country = nil;
    self.province = nil;
    self.city = nil;
    self.cityN = nil;
    self.diploma = nil;
    self.workexp = nil;
    self.salary = nil;
    self.nature = nil;
    self.scale = nil;
    self.cometime = nil;
    self.worktype = nil;
    self.industry = nil;
    self.function = nil;
    self.major = nil;
    self.localized = nil;
    
    self.country_name = nil;
    self.country_value = nil;
    self.province_name = nil;
    self.province_value = nil;
    self.diploma_name = nil;
    self.diploma_value = nil;
    self.workexp_name = nil;
    self.workexp_value = nil;
    self.salary_name = nil;
    self.salary_value = nil;
    self.nature_name = nil;
    self.nature_value = nil;
    self.scale_name = nil;
    self.scale_value = nil;
    self.cometime_name = nil;
    self.cometime_value = nil;
    self.worktype_name = nil;
    self.worktype_value = nil;
    self.industry_name = nil;
    self.industry_value = nil;
    self.function_name = nil;
    self.function_value = nil;
    self.major_name = nil;
    self.major_value = nil;
    
    
    [_db close];
//    [_db release];

//    [super dealloc];
}

- (FMDatabase*)openDB{
        if(_db && [_db goodConnection])
            return _db;
    
    NSString* s = [NSString stringWithFormat:@"%@%@",imageFilePath,DB_NAME];
    
    [_db close];
//    [_db release];

    _db = [[FMDatabase alloc] initWithPath:s];
    if (![_db open]) {
//        NSLog(@"数据库打开失败");
        return nil;
    };
    return _db;
}

// 获取表情包
- (NSMutableArray *)emojiArray {
    NSString* sql= [NSString stringWithFormat:@"select filename,english,chinese,sort from emoji order by sort"];
    FMDatabase *db = [self openDB];
    FMResultSet *rs = [db executeQuery:sql];
    NSMutableArray *dataArr = [NSMutableArray array];
    while ([rs next]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[rs stringForColumn:@"filename"] forKey:@"filename"];
        [dic setObject:[rs stringForColumn:@"english"] forKey:@"english"];
        [dic setObject:[rs stringForColumn:@"chinese"] forKey:@"chinese"];
        [dataArr addObject:dic];
    }
    return dataArr;
}
#pragma mark----获取语言字典
-(NSMutableDictionary*) getLocalized{
//    NSString *language = [JXMyTools getCurrentSysLanguage];
    NSString* sql= [NSString stringWithFormat:@"select ios,%@ from lang",_sysName];
    FMDatabase *db = [self openDB];
    FMResultSet *rs = [db executeQuery:sql];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    while ([rs next]) {
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        NSString *valueStr = [rs stringForColumn:@"ios"];
//        [dic setObject:[rs stringForColumn:@"zh"] forKey:@"zh"];
//        [dic setObject:[rs stringForColumn:@"big5"] forKey:@"big5"];
//        [dic setObject:[rs stringForColumn:@"en"] forKey:@"en"];
//        [dict setObject:dic forKey:valueStr];
        [dict setObject:[rs stringForColumn:_sysName] forKey:[rs stringForColumn:@"ios"]];
    }
    
    return dict;
    
}

-(NSMutableDictionary*) getCountrys{
//    NSString *language = [self getLanguage];
    
    NSString *name = @"name";
    if (![_sysLanguage isEqualToString:NAME]) {
        name = @"enName";
    }
    NSString* sql= [NSString stringWithFormat:@"select %@,id from tb_areas where type=1",name];
    return [self doGetDict1:sql name:country_name value:country_value];
}

-(NSMutableDictionary*) getProvince:(int)countryId{
    [province_name removeAllObjects];
    [province_value removeAllObjects];
    
    NSString *name = @"name";
    if (![_sysLanguage isEqualToString:NAME]) {
        name = @"enName";
    }
    
    NSString* sql= [NSString stringWithFormat:@"select %@,id from tb_areas where type=2 and parent_Id=%d order by id",name,countryId];
    
    return [self doGetDict1:sql name:province_name value:province_value];
}

-(NSMutableDictionary*) getCity2{
    NSString* sql= [NSString stringWithFormat:@"select name,id from tb_areas"];
    return [self doGetDict2:sql name:nil value:nil];
}

-(NSMutableDictionary*) getCity{
//    NSString *language = [self getLanguage];
    
    NSString *name = @"name";
    if (![_sysLanguage isEqualToString:NAME]) {
        name = @"enName";
    }
    NSString* sql= [NSString stringWithFormat:@"select %@,id from tb_areas",name];
    return [self doGetDict1:sql name:nil value:nil];
}

-(NSMutableDictionary*) getCity:(int)provinceId{
//    NSString *language = [self getLanguage];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
    
    FMDatabase* db = [self openDB];
    
    NSString* sql= [NSString stringWithFormat:@"select %@,id from tb_areas where type=3 and parent_Id=%d",@"name",provinceId];
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        [dict setObject:[rs objectForColumnName:@"name"] forKey:[self formatId:[rs objectForColumnName:@"id"]]];
    }
    return dict;
}

-(NSMutableDictionary*) getArea:(int)cityId{
//    NSString *language = [self getLanguage];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
    
    FMDatabase* db = [self openDB];
    
    NSString* sql= [NSString stringWithFormat:@"select %@,id from tb_areas where type=4 and parent_Id=%d",_sysLanguage,cityId];
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        [dict setObject:[rs objectForColumnName:_sysLanguage] forKey:[self formatId:[rs objectForColumnName:@"id"]]];
    }
    return dict;
}

-(NSMutableDictionary*) getDiploma{
    return [self doGetDict:1 name:diploma_name value:diploma_value];
}

-(NSMutableDictionary*) getWorkExp{
    return [self doGetDict:2 name:workexp_name value:workexp_value];
}

-(NSMutableDictionary*) getSalary{
    return [self doGetDict:3 name:salary_name value:salary_value];
}

-(NSMutableDictionary*) getNature{
    return [self doGetDict:32 name:nature_name value:nature_value];
}

-(NSMutableDictionary*) getScale{
    return [self doGetDict:44 name:scale_name value:scale_value];
}

-(NSMutableDictionary*) getComeTime{
    return [self doGetDict:52 name:cometime_name value:cometime_value];
}

-(NSMutableDictionary*) getWorkType{
    return [self doGetDict:59 name:worktype_name value:worktype_value];
}

-(NSMutableDictionary*) getIndustry{
    NSMutableDictionary* d = [[NSMutableDictionary alloc]init];
    [self getTree:63 name:industry_name value:industry_value];
    for (int i=0; i<[industry_name count]; i++) {
        [d setObject:[industry_name objectAtIndex:i] forKey:[industry_value objectAtIndex:i]];
    }
    return d;
}

-(NSMutableDictionary*) getFunction{
    NSMutableDictionary* d = [[NSMutableDictionary alloc]init];
    [self getTree:64 name:function_name value:function_value];
    for (int i=0; i<[function_name count]; i++) {
        [d setObject:[function_name objectAtIndex:i] forKey:[function_value objectAtIndex:i]];
    }
    return d;
}


-(NSMutableDictionary*) getMajor{
    NSMutableDictionary* d = [[NSMutableDictionary alloc]init];
    [self getTree:1005 name:major_name value:major_value];
    for (int i=0; i<[major_name count]; i++) {
        [d setObject:[major_name objectAtIndex:i] forKey:[major_value objectAtIndex:i]];
    }
    return d;
}

-(NSMutableDictionary*)doGetDict2:(NSString*)sql name:(NSMutableArray*)name value:(NSMutableArray*)value{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
    FMDatabase* db = [self openDB];
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        [name addObject:[rs objectForColumnName:@"id"]];
        //        NSLog(@"%@",[rs objectForColumnName:@"name"]);
        [value addObject:[self formatId:[rs objectForColumnName:@"name"]]];
        [dict setObject:[rs objectForColumnName:@"id"] forKey:[self formatId:[rs objectForColumnName:@"name"]]];
    }
    return dict;
}

-(NSMutableDictionary*)doGetDict1:(NSString*)sql name:(NSMutableArray*)name value:(NSMutableArray*)value{
//    NSString *language = [self getLanguage];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
    FMDatabase* db = [self openDB];
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        
        NSString *nameStr = @"name";
        if (![_sysLanguage isEqualToString:NAME]) {
            nameStr = @"enName";
        }
        
        [name addObject:[rs objectForColumnName:nameStr]];
//        NSLog(@"%@",[rs objectForColumnName:@"name"]);
        [value addObject:[self formatId:[rs objectForColumnName:@"id"]]];
        [dict setObject:[rs objectForColumnName:nameStr] forKey:[self formatId:[rs objectForColumnName:@"id"]]];
    }
    return dict;
}

-(NSMutableDictionary*)doGetDict:(int)n name:(NSMutableArray*)name value:(NSMutableArray*)value{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
    
    FMDatabase* db = [self openDB];
    
    NSString* sql= [NSString stringWithFormat:@"select name,id from tb_constants where parent_Id=%d",n];
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        [name addObject:[rs objectForColumnName:@"name"]];
        [value addObject:[self formatId:[rs objectForColumnName:@"id"]]];
        [dict setObject:[rs objectForColumnName:@"name"] forKey:[self formatId:[rs objectForColumnName:@"id"]]];
    }
    return dict;
}

-(void)getNameValues:(int)n name:(NSMutableArray*)name value:(NSMutableArray*)value{
    FMDatabase* db = [self openDB];
    
    NSString* sql= [NSString stringWithFormat:@"select name,id from tb_constants where parent_Id=%d",n];
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        [name addObject:[rs objectForColumnName:@"name"]];
        [value addObject:[self formatId:[rs objectForColumnName:@"id"]]];
    }
}

-(void)getTree:(int)n name:(NSMutableArray*)name value:(NSMutableArray*)value{
    FMDatabase* db = [self openDB];
    
    NSString* sql= [NSString stringWithFormat:@"select name,id from tb_constants where parent_Id=%d",n];
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        [name addObject:[rs objectForColumnName:@"name"]];
        [value addObject:[self formatId:[rs objectForColumnName:@"id"]]];
        [self getTree:[[rs objectForColumnName:@"id"] intValue] name:name value:value];
    }
}



-(NSNumber*)formatId:(NSNumber*)n{
//    return [NSString stringWithFormat:@"%.6d",[n intValue]];
    return n;
}

-(NSArray*)getSortKeys:(NSMutableDictionary*)dict{
    NSArray* keys = [dict allKeys];
    keys = [keys sortedArrayUsingSelector:@selector(compare:)];
//    [keys retain];
    return keys;
}

-(NSArray*)getSortValues:(NSMutableDictionary*)dict{
    NSArray* keys = [self getSortKeys:dict];
    NSMutableArray* values = [[NSMutableArray alloc]init];
    for(int i=0;i<[keys count];i++)
        [values addObject:[dict objectForKey:[keys objectAtIndex:i]]];
    return values;
}

-(NSString*)getAddress:(NSString*)provinceId cityId:(NSString*)cityId areaId:(NSString*)areaId{
    NSString* s=nil;
    if(provinceId)
        s = provinceId;
    else
        s = @"";
    if(cityId){
        if(cityId != provinceId){
            if (s.length > 0) {
                s = [s stringByAppendingString:@"-"];
            }
            s = [s stringByAppendingString:cityId];
        }
    }
    if(areaId){
        if(cityId != areaId){
            if (s.length > 0) {
                s = [s stringByAppendingString:@"-"];
            }
            s = [s stringByAppendingString:areaId];
        }
    }
    return s;
}

-(NSString*)getAddressForInt:(int)provinceId cityId:(int)cityId areaId:(int)areaId{
    NSString* p  = [city objectForKey:[NSNumber numberWithInt:provinceId]];
    NSString* c  = [city objectForKey:[NSNumber numberWithInt:cityId]];
    NSString* a  = [city objectForKey:[NSNumber numberWithInt:areaId]];
    NSString* address = [self getAddress:p cityId:c areaId:a];
    return address;
}

-(NSString*)getAddressForNumber:(NSNumber*)provinceId cityId:(NSNumber*)cityId areaId:(NSNumber*)areaId{
    NSString* p  = [city objectForKey:provinceId];
    NSString* c  = [city objectForKey:cityId];
    NSString* a  = [city objectForKey:areaId];
    NSString* address = [self getAddress:p cityId:c areaId:a];
    return address;
}
#pragma mark----获取当前语言下的文字
- (NSString *)LocalizedWithStr:(NSString *)str{
//    NSString *language = [iLanguage getCurrentSysLanguage];
//    NSDictionary *dic = [self.localized objectForKey:str];
    NSString *localizedStr = [_localized objectForKey:str];
    if (!localizedStr)
        localizedStr = [NSString stringWithFormat:@"%@SQL错误",str];
    return localizedStr;
}
//- (NSString *)getLanguage{
//    NSString *language;
//    if ([[JXMyTools getCurrentSysLanguage] isEqualToString:@"en"]) {
//        language = @"enName";
//    }else{
//        language = @"name";
//    }
//    return language;
//}
- (void)getTelArea{
    [_telArea removeAllObjects];
    
    FMDatabase *db = [self openDB];
    NSString * sql = nil;
    if ([JXMyTools isChineseLanguage:_sysLanguage]) {//
        sql = [NSString stringWithFormat:@"select * from SMS_country order by prefix"];
    }else{
        sql = [NSString stringWithFormat:@"select * from SMS_country order by en"];
    }
    
    FMResultSet *rs = [db executeQuery:sql];//查询数据库
    while ([rs next]) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[self formatId:[rs objectForColumnName:@"id"]] forKey:@"id"];
        [dict setObject:[rs objectForColumnName:@"en"] forKey:@"enName"];
        [dict setObject:[rs objectForColumnName:@"zh"] forKey:@"country"];
//        [dict setObject:[rs objectForColumnName:@"malay"] forKey:@"malay"];
//        [dict setObject:[rs objectForColumnName:@"th"] forKey:@"th"];
        [dict setObject:[rs objectForColumnName:@"prefix"] forKey:@"prefix"];
        [dict setObject:[rs objectForColumnName:@"price"] forKey:@"price"];
        [dict setObject:[rs objectForColumnName:@"big5"] forKey:@"big5"];
//        [dict setObject:[rs objectForColumnName:@"ja"] forKey:@"ja"];
//        [dict setObject:[rs objectForColumnName:@"ko"] forKey:@"ko"];
//        [dict setObject:[rs objectForColumnName:@"idy"] forKey:@"idy"];
//        [dict setObject:[rs objectForColumnName:@"vi"] forKey:@"vi"];
//        [dict setObject:[rs objectForColumnName:@"ms"] forKey:@"ms"];
//        [dict setObject:[rs objectForColumnName:@"fy"] forKey:@"fy"];

        [_telArea addObject:dict];
    }
    
//    FMDatabase *db = [self openDB];
//    NSString * lanauage =[[NSString alloc] initWithFormat:@"%@",[JXMyTools getCurrentSysLanguage]];
//    NSString * sql = nil;
//    if ([lanauage isEqualToString:@"zh"]) {//
//        sql = [NSString stringWithFormat:@"select * from SMS_country order by prefix"];
//    }else if ([lanauage isEqualToString:@"big5"]) {//
//        sql = [NSString stringWithFormat:@"select * from SMS_country order by prefix"];
//    }else{
//        sql = [NSString stringWithFormat:@"select * from SMS_country order by en"];
//    }
//    
//    FMResultSet *rs = [db executeQuery:sql];//查询数据库
//    while ([rs next]) {
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//        [dict setObject:[self formatId:[rs objectForColumnName:@"id"]] forKey:@"id"];
//        [dict setObject:[rs objectForColumnName:@"en"] forKey:@"enName"];
//        [dict setObject:[rs objectForColumnName:@"zh"] forKey:@"country"];
//        [dict setObject:[rs objectForColumnName:@"prefix"] forKey:@"prefix"];
//        [dict setObject:[rs objectForColumnName:@"price"] forKey:@"price"];
//        [dict setObject:[rs objectForColumnName:@"big5"] forKey:@"big5"];
//        [_telArea addObject:dict];
//    }
}
-(NSString*)getCurCountryFieldName{
    NSString * name = nil;
    if ([_sysLanguage isEqualToString:@"zh"]) {
        name = [[NSString alloc] initWithFormat:@"%@",NAME];
    }else if ([_sysLanguage isEqualToString:@"big5"]) {
        
        name = [[NSString alloc] initWithFormat:@"%@",ZHHANTNAME];
    }else if ([_sysLanguage isEqualToString:@"malay"]) {
        
        name = [[NSString alloc] initWithFormat:@"%@",MALAYNAME];
    }else if ([_sysLanguage isEqualToString:@"th"]) {
        
        name = [[NSString alloc] initWithFormat:@"%@",THNAME];
    }
    else if ([_sysLanguage isEqualToString:@"en"]){
        name = [[NSString alloc] initWithFormat:@"%@",ENNAME];
    }
    else if ([_sysLanguage isEqualToString:@"ja"]){
        name = [[NSString alloc] initWithFormat:@"%@",JANAME];
    }
    else if ([_sysLanguage isEqualToString:@"ko"]){
        name = [[NSString alloc] initWithFormat:@"%@",KONAME];
    }
    else if ([_sysLanguage isEqualToString:@"idy"]){
        name = [[NSString alloc] initWithFormat:@"%@",IDYNAME];
    }
    else if ([_sysLanguage isEqualToString:@"vi"]){
        name = [[NSString alloc] initWithFormat:@"%@",VINAME];
    }
    else if ([_sysLanguage isEqualToString:@"ms"]){
        name = [[NSString alloc] initWithFormat:@"%@",MSNAME];
    }
    else if ([_sysLanguage isEqualToString:@"fy"]){
        name = [[NSString alloc] initWithFormat:@"%@",FYNAME];
    }

    return name;
//    if ([[JXMyTools getCurrentSysLanguage] isEqualToString:@"zh"]) {
//        name = [[NSString alloc] initWithFormat:@"%@",@"zh"];
//    }else if ([[JXMyTools getCurrentSysLanguage] isEqualToString:@"zhHant"]) {
//        
//        name = [[NSString alloc] initWithFormat:@"%@",@"big5"];
//    }else{
//        name = [[NSString alloc] initWithFormat:@"%@",@"en"];
//    }
//    return name;
}
// 搜索国家区号
- (NSMutableArray *) getSearchTelAreaWithName:(NSString *) name {
    FMDatabase* db = [self openDB];
    NSMutableArray *array = [NSMutableArray array];
    
    NSString* sql= [NSString stringWithFormat:@"select * from SMS_country where (zh like '%%%@%%' or en like '%%%@%%' or big5 like '%%%@%%') order by %@",name,name,name,_sysName];
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:[self formatId:[rs objectForColumnName:@"id"]] forKey:@"id"];
        [dict setObject:[rs objectForColumnName:@"en"] forKey:@"enName"];
        [dict setObject:[rs objectForColumnName:@"zh"] forKey:@"country"];
        [dict setObject:[rs objectForColumnName:@"prefix"] forKey:@"prefix"];
        [dict setObject:[rs objectForColumnName:@"price"] forKey:@"price"];
        [dict setObject:[rs objectForColumnName:@"big5"] forKey:@"big5"];
        [dict setObject:[rs objectForColumnName:@"big5"] forKey:@"ja"];
        [dict setObject:[rs objectForColumnName:@"big5"] forKey:@"ko"];
        [dict setObject:[rs objectForColumnName:@"big5"] forKey:@"idy"];
        [dict setObject:[rs objectForColumnName:@"big5"] forKey:@"vi"];
        [dict setObject:[rs objectForColumnName:@"big5"] forKey:@"ms"];
        [dict setObject:[rs objectForColumnName:@"big5"] forKey:@"fy"];
        [array addObject:dict];
    }
    
    return array;
}

//城市名获取ID
-(NSString*) getCityID:(NSString *)s{
    if (s == nil)
        return nil;
    
    NSString * str = [[NSString alloc]init];
    NSString* sql = [NSString stringWithFormat:@"select id from tb_areas where lower(name)=lower(\"%@\")",s];
    FMDatabase* db = [self openDB];
    FMResultSet *rs=[db executeQuery:sql];
    BOOL isNull = YES;
    while ([rs next]) {
        str =[rs stringForColumn:@"id"];
        isNull = NO;
    }
    
    //如果为空，则模糊查询
    if (isNull) {
        NSArray * arr = [ s componentsSeparatedByCharactersInSet : [NSCharacterSet characterSetWithCharactersInString :@"县区市"]];
        NSString * cityNameF = [arr firstObject];
        sql= [NSString stringWithFormat:@"select id from tb_areas where lower(name) like lower(\"%%%@%%\")",cityNameF];
        FMResultSet *rs=[db executeQuery:sql];
        while ([rs next]) {
            //直接取最后一个
            str = [rs objectForColumnName:@"id"];
        }
    }
    return str;
}

-(NSString *)getParentWithCityId:(int)cityId{
    if (cityId <= 0 ) {
        return nil;
    }

    FMDatabase * db = [self openDB];
    NSString * sql = [NSString stringWithFormat:@"select parent_id from tb_areas where id=%d",cityId];
    FMResultSet * rs = [db executeQuery:sql];
    NSString * str = [[NSString alloc]init];
    while ([rs next]) {
        str = [rs stringForColumn:@"parent_id"];
    }

    
    return str;
}

// 重置本地语言
- (void) resetlocalized {
    NSString *lang = [g_default stringForKey:kLocalLanguage];
    if (!lang || lang.length <= 0) {
        lang = [JXMyTools getCurrentSysLanguage];
    }
    _sysLanguage =lang;
    _sysName = [self getCurCountryFieldName];
    [self getData];
    // 重置皮肤单例
    [g_theme resetInstence];
}

@end
