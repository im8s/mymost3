//
//  TimeUtil.m
//  wq
//
//  Created by berwin on 13-7-20.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//

#import "TimeUtil.h"
#import "JXMyTools.h"

@implementation TimeUtil


+ (NSString*)getTimeStr:(long) createdAt
{
    // Calculate distance time string
    //
    NSString *timestamp;
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now, createdAt);
    if (distance < 0) distance = 0;
    
    if (distance < 60) {
        timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "second ago" : "seconds ago"];
    }
    else if (distance < 60 * 60) {
        distance = distance / 60;
        timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "minute ago" : "minutes ago"];
    }
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "hour ago" : "hours ago"];
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "day ago" : "days ago"];
    }
    else if (distance < 60 * 60 * 24 * 7 * 4) {
        distance = distance / 60 / 60 / 24 / 7;
        timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "week ago" : "weeks ago"];
    }
    else {
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        }
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:createdAt]; 
        timestamp = [dateFormatter stringFromDate:date];
    }
    return timestamp;
}

+ (NSString*)getTimeStr1:(long long)time
{
    NSDate * date=[NSDate dateWithTimeIntervalSince1970:time];
    NSCalendar * calendar=[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitMonth | NSCalendarUnitDay|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents * component=[calendar components:unitFlags fromDate:date];
    NSString * string=[NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d",[component year],[component month],[component day],[component hour],[component minute]];
    return string;
}

+ (NSString*)getTimeStr1Short:(long long)time
{
    NSDate * date=[NSDate dateWithTimeIntervalSince1970:time];
    NSCalendar * calendar=[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitMonth | NSCalendarUnitDay|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents * component=[calendar components:unitFlags fromDate:date];
    NSString * string=[NSString stringWithFormat:@"%04d-%02d-%02d",[component year],[component month],[component day]];
    return string;
}

+ (NSString*)getMDStr:(long long)time
{
    
    NSDate * date=[NSDate dateWithTimeIntervalSince1970:time];
    NSCalendar * calendar=[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitMonth | NSCalendarUnitDay|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents * component=[calendar components:unitFlags fromDate:date];
    NSString * string=[NSString stringWithFormat:@"%d%@%d%@",[component month],Localized(@"JX_Month"),[component day],Localized(@"JX_Day1")];
    return string;
}

+(NSDateComponents*) getComponent:(long long)time
{
    NSDate * date=[NSDate dateWithTimeIntervalSince1970:time];
    NSCalendar * calendar=[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitMonth | NSCalendarUnitDay|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents * component=[calendar components:unitFlags fromDate:date];
    return component;
}


+(NSString*) getTimeStrStyle1:(long long)time
{
    NSDate * date=[NSDate dateWithTimeIntervalSince1970:time];
    NSCalendar * calendar=[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitMonth | NSCalendarUnitDay|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitWeekOfMonth|NSCalendarUnitWeekday;
    NSDateComponents * component=[calendar components:unitFlags fromDate:date];

    NSInteger year=[component year];
    NSInteger month=[component month];
    NSInteger day=[component day];
    
    NSInteger hour=[component hour];
    NSInteger minute=[component minute];
    
    NSDate * today=[NSDate date];
    component=[calendar components:unitFlags fromDate:today];
    
    NSInteger t_year=[component year];
    NSInteger t_day = [component day];
    
    NSString*string=nil;
//    NSString *timeString = nil;
    long long now=[today timeIntervalSince1970];
    
    long distance=now-time;
    
    if(distance<60){
        string=Localized(@"TimeUtil_Utill");
    }else if(distance<60*30){
        if ([g_constant.sysLanguage isEqualToString:@"en"]) {
            string=[NSString stringWithFormat:@"%@ %ld %@",Localized(@"JX_Before"),distance/60,Localized(@"JX_Min")];
            
        }else{
           string=[NSString stringWithFormat:@"%ld %@%@",distance/60,Localized(@"JX_Min"),Localized(@"JX_Before")];
        }
    
    }else if(distance<60*60*24){
        
        if (day == t_day) {
             string = [NSString stringWithFormat:@"%d:%02d",hour,minute];
        }else {
            string = [NSString stringWithFormat:@"%@ %d:%02d",Localized(@"YESTERDAY"),hour,minute];
        }
       
        
//        if ([[JXMyTools getCurrentSysLanguage] isEqualToString:@"en"]) {
//            
//            timeString = nil;
//            timeString = [NSString stringWithFormat:@"%@",Localized(@"JX_Hour")];
//            if (distance/60.0/60.0 > 1.0) {//hours
//                timeString = [timeString stringByAppendingString:@"s"];
//            }
//            string=[NSString stringWithFormat:@"%@ %ld %@",Localized(@"JX_Before"),distance/60/60,timeString];
//            
//        }else{
//            string=[NSString stringWithFormat:@"%ld %@%@",distance/60/60,Localized(@"JX_Hour"),Localized(@"JX_Before")];
//        }
        //string=[NSString stringWithFormat:@"before %ld hour",distance/60/60];
    }else if(distance<60*60*24 * 2){
        if (t_day - day == 1) {
            string = [NSString stringWithFormat:@"%@ %d:%02d",Localized(@"YESTERDAY"),hour,minute];
        }else {
            string = [NSString stringWithFormat:@"%@ %d:%02d",Localized(@"BEFORE_YESTERDAY"),hour,minute];
        }

    }else if(distance<60*60*24 * 3){
        if (t_day - day == 2) {
            string = [NSString stringWithFormat:@"%@ %d:%02d",Localized(@"BEFORE_YESTERDAY"),hour,minute];
        }else {
            string=[NSString stringWithFormat:@"%02d-%02d %d:%02d",month,day,hour,minute];
        }
        
    }
//    else if(distance<60*60*24*7){
//        if ([[JXMyTools getCurrentSysLanguage] isEqualToString:@"en"]) {
//            timeString = nil;
//            timeString = [NSString stringWithFormat:@"%@",Localized(@"JX_Day")];
//            if (distance/60.0 > 1.0) {
//                timeString = [timeString stringByAppendingString:@"s"];
//            }
//            string=[NSString stringWithFormat:@"%@ %ld %@",Localized(@"JX_Before"),distance/60/60/24,timeString];
//        }else{
//        string=[NSString stringWithFormat:@"%ld %@%@",distance/60/60/24,Localized(@"JX_Day"),Localized(@"JX_Before")];
//        }
//        //string=[NSString stringWithFormat:@"before %ld day",distance/60/60/24];
//    }
    else if(year==t_year){
        string=[NSString stringWithFormat:@"%02d-%02d %d:%02d",month,day,hour,minute];
    }else{
        string=[NSString stringWithFormat:@"%d-%d-%d",year,month,day];
    }
    
    return string;   
    
}
+(NSString*) getTimeStrStyle2:(long long)time
{
    
    NSDate * date=[NSDate dateWithTimeIntervalSince1970:time];
    NSCalendar * calendar=[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitMonth | NSCalendarUnitDay|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitWeekOfMonth|NSCalendarUnitWeekday;
    NSDateComponents * component=[calendar components:unitFlags fromDate:date];
    
    NSInteger year=[component year];
    NSInteger month=[component month];
    NSInteger day=[component day];
    NSInteger hour=[component hour];
    NSInteger minute=[component minute];
    NSInteger week=[component weekOfMonth];
    NSInteger weekday=[component weekday];
    
    NSDate * today=[NSDate date];
    component=[calendar components:unitFlags fromDate:today];
    
    NSInteger t_year=[component year];
    NSInteger t_month=[component month];
    NSInteger t_day=[component day];
    NSInteger t_week=[component weekOfMonth];
    
    NSString*string=nil;
    if(year==t_year&&month==t_month&&day==t_day)
    {
        if(hour<6&&hour>=0)
            string=[NSString stringWithFormat:@"%d:%02da.m",hour,minute];
        else if(hour>=6&&hour<12)
            string=[NSString stringWithFormat:@"%d:%02da.m",hour,minute];
        else if(hour>=12&&hour<18)
            string=[NSString stringWithFormat:@"%d:%02dp.m",hour,minute];
        else
            string=[NSString stringWithFormat:@"%d:%02dp.m",hour,minute];
    }
    else if(year==t_year&&week==t_week)
    {
        NSString * daystr=nil;
        switch (weekday) {
            case 1:
                daystr=Localized(@"TimeUtil_Sun");
                break;
            case 2:
                daystr=Localized(@"TimeUtil_Mon");
                break;
            case 3:
                daystr=Localized(@"TimeUtil_Tue");
                break;
            case 4:
                daystr=Localized(@"TimeUtil_Wed");
                break;
            case 5:
                daystr=Localized(@"TimeUtil_Thu");
                break;
            case 6:
                daystr=Localized(@"TimeUtil_Fri");
                break;
            case 7:
                daystr=Localized(@"TimeUtil_Sat");
                break;
            default:
                break;
        }
        string=[NSString stringWithFormat:@"%@ %d:%02d",daystr,hour,minute];
    }
    else if(year==t_year)
        string=[NSString stringWithFormat:@"%d:%d",month,day];
    else
        string=[NSString stringWithFormat:@"%d:%d:%d",year,month,day];
    
    return string;
}

+(int)dayCountForMonth:(int)month andYear:(int)year
{
    if (month==1||month==3||month==5||month==7||month==8||month==10||month==12) {
        return 31;
    }else if(month==4||month==6||month==9||month==11){
        return 30;
    }else if([self isLeapYear:year]){
        return 29;
    }else{
        return 28;
    }
}
+(BOOL)isLeapYear:(int)year
{
    if (year%400==0) {
        return YES;
    }else{
        if (year%4==0&&year%100!=0) {
            return YES;
        }else{
            return NO;
        }
    }
}

+(NSString*)getTimeShort:(long long)t{
    if(t<0)
        t = 0;
    int m = (int)(t/60);
    int n = t%60;
    return [NSString stringWithFormat:@"%.2d:%.2d",m,n];
}

+(NSString*)getTimeShort1:(long long)t{
    if(t<0)
        t = 0;
    int p = (int)(t / 3600);
    t = t % 3600;
    int m = (int)(t/60);
    int n = t%60;
    if (p <= 0) {
        return [NSString stringWithFormat:@"%.2d:%.2d",m,n];
    }
    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d",p,m,n];
}

+(NSDate*)dateFromString:(NSString*)s format:(NSString*)str{
    NSDateFormatter* f=[[NSDateFormatter alloc]init];
    if(str==nil)
        str = @"yyyy-MM-dd";
    [f setDateFormat:str];
    NSDate* d = [f dateFromString:s];
    return d;
}

+(NSString*)formatDateFromStr:(NSString*)s format:(NSString*)str{
    NSDateFormatter* f=[[NSDateFormatter alloc]init];
    if(!str)
        str = @"yyyy-MM-dd HH:mm:ss";
    [f setDateFormat:str];
    NSDate* d = [f dateFromString:s];
    
    f.dateFormat = str;
    NSString* s1 = [f stringFromDate:d];
//    [f release];
    return  s1;
}

+(NSString*)formatDate:(NSDate*)d format:(NSString*)str{
    NSDateFormatter* f=[[NSDateFormatter alloc]init];
    f.dateFormat = str;
    NSString* s = [f stringFromDate:d];
//    [f release];
    return  s;
}

+(NSString*)getDateStr:(long long)time{
    NSDateFormatter* f=[[NSDateFormatter alloc]init];
    f.dateFormat = @"yyyy-MM-dd";
    NSString* s = [f stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
    //    [f release];
    return  s;
}



@end
