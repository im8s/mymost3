//
//  resumeData.h
//  shiku_im
//
//  Created by flyeagleTang on 14-12-1.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface resumeBaseData : NSObject{
}
@property(nonatomic,assign) int countryId;//国家
@property(nonatomic,assign) int provinceId;//省份
@property(nonatomic,assign) int cityId;//城市
@property(nonatomic,assign) int areaId;//区域
@property(nonatomic,assign) int homeCityId;//户口
@property(nonatomic,assign) int workexpId;//经验
@property(nonatomic,assign) int diplomaId;//学历
//@property(nonatomic,assign) int worktypeId;//工作类型
@property(nonatomic,assign) int jobStatus;//在职状态
@property(nonatomic,assign) int salaryId;//目前待遇

@property(nonatomic,assign) NSTimeInterval birthday;//生日
@property(nonatomic,strong) NSString* idNumber;//身份证号
@property(nonatomic,strong) NSString* email;//邮箱
@property(nonatomic,strong) NSString* evaluate;//自我介绍
@property(nonatomic,strong) NSString* telephone;//手机
@property(nonatomic,strong) NSString* location;//居住地
@property(nonatomic,strong) NSString* name;//名字

@property(nonatomic,assign) BOOL sex;//性别
@property(nonatomic,assign) BOOL marital;//婚姻

-(void)getDataFromDict:(NSDictionary*)dict;
-(NSMutableDictionary*)setDataToDict;
-(void)copyFromUser:(JXUserObject*)user;
@end

