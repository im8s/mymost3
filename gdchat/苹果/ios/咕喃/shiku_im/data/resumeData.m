
//
//  resumeData.m
//  shiku_im
//
//  Created by flyeagleTang on 14-12-1.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "resumeData.h"

@implementation resumeBaseData

-(id)init{
    self = [super init];
    return self;
}

-(void)dealloc{
//    [_idNumber release];
//    [_email release];
//    [_evaluate release];
//    [_telephone release];
//    [_location release];
//    [_name release];
    
    NSLog(@"resumeBaseData.dealloc");
//    [super dealloc];
}

-(void)getDataFromDict:(NSDictionary*)dict{
    self.countryId = [[dict objectForKey:@"countryId"] intValue];
    self.provinceId = [[dict objectForKey:@"provinceId"] intValue];
    self.cityId = [[dict objectForKey:@"cityId"] intValue];
    self.areaId = [[dict objectForKey:@"areaId"] intValue];
    self.homeCityId = [[dict objectForKey:@"homeCityId"] intValue];
    self.salaryId = [[dict objectForKey:@"salary"] intValue];
    self.workexpId = [[dict objectForKey:@"w"] intValue];
    self.jobStatus = [[dict objectForKey:@"j"] intValue];
    self.diplomaId = [[dict objectForKey:@"d"] intValue];
    self.birthday = [[dict objectForKey:@"b"] longLongValue];
    self.sex = [[dict objectForKey:@"s"] boolValue];
    self.marital = [[dict objectForKey:@"m"] boolValue];
    
    self.name = [dict objectForKey:@"name"];
    self.idNumber = [dict objectForKey:@"idNumber"];
    self.email = [dict objectForKey:@"email"];
    self.evaluate = [dict objectForKey:@"evaluate"];
    self.telephone = [dict objectForKey:@"telephone"];
    self.location = [dict objectForKey:@"location"];
}

-(NSMutableDictionary*)setDataToDict{
    NSMutableDictionary* d = [[NSMutableDictionary alloc]init];
    add_dict_object(d ,[NSNumber numberWithInt:self.countryId] ,@"countryId");
    add_dict_object(d ,[NSNumber numberWithInt:self.provinceId] ,@"provinceId");
    add_dict_object(d ,[NSNumber numberWithInt:self.cityId] ,@"cityId");
    add_dict_object(d ,[NSNumber numberWithInt:self.areaId] ,@"areaId");
    add_dict_object(d ,[NSNumber numberWithInt:self.homeCityId] ,@"homeCityId");
    add_dict_object(d ,[NSNumber numberWithInt:self.salaryId] ,@"salary");
    add_dict_object(d ,[NSNumber numberWithInt:self.workexpId] ,@"w");
    add_dict_object(d ,[NSNumber numberWithInt:self.jobStatus] ,@"j");
    add_dict_object(d ,[NSNumber numberWithInt:self.diplomaId] ,@"d");
    add_dict_object(d ,[NSNumber numberWithLongLong:self.birthday] ,@"b");
    add_dict_object(d ,[NSNumber numberWithInt:self.sex] ,@"s");
    add_dict_object(d ,[NSNumber numberWithInt:self.marital] ,@"m");
    add_dict_object(d ,self.name ,@"name");
    add_dict_object(d ,self.idNumber ,@"idNumber");
    add_dict_object(d ,self.email ,@"email");
    add_dict_object(d ,self.evaluate ,@"evaluate");
    add_dict_object(d ,self.telephone ,@"telephone");
    add_dict_object(d ,self.location, @"location");
    return d;
}

-(void)copyFromUser:(JXUserObject*)user{
    self.telephone   = user.telephone;
    self.name        = user.userNickname;
    self.birthday    = [user.birthday timeIntervalSince1970];
    self.sex         = [user.sex boolValue];
    self.countryId   = [user.countryId intValue];
    self.provinceId  = [user.provinceId intValue];
    self.cityId      = [user.cityId intValue];
    self.areaId      = [user.areaId intValue];
}

@end
