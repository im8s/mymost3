//
//  JXMyTools.m
//  shiku_im
//
//  Created by daxiong on 17/4/15.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXMyTools.h"
#import "JXTipBlackView.h"

@implementation JXMyTools

#pragma mark----获取当前系统语言
+ (NSString *)getCurrentSysLanguage{
    //    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];  //国家代号 （CN）
    //    NSString *editedCountryCode = [NSString stringWithFormat:@"-%@",countryCode];  //(-CN)
    // 简体中文：zh-Hans-US
    // 繁体中文：zh-Hant-US
    // 繁体台湾：zh-Hant-TW
    // 繁体香港：zh-Hant-HK
    // 繁体澳门：zh-Hant-MO
    NSArray *languageArr = [g_default objectForKey:@"AppleLanguages"];
    NSString *systemLanguage = [languageArr objectAtIndex:0];   //当前系统语言 （zh-Hans-CN）
    //    if ([systemLanguage rangeOfString:editedCountryCode].location != NSNotFound) {
    //        systemLanguage = [systemLanguage stringByReplacingOccurrencesOfString:editedCountryCode withString:@""];
    //    }
    
    if ([systemLanguage rangeOfString:@"zh-Hans"].location != NSNotFound) {
        
        // 中文
        systemLanguage = @"zh";
        
    }else if ([systemLanguage rangeOfString:@"zh-Hant"].location != NSNotFound) {
        // 繁体
        systemLanguage = @"big5";
        
    }else {
        // 其他
        systemLanguage = @"en";
    }
    
    //    if ([systemLanguage rangeOfString:@"zh-"].location == NSNotFound) {    //如果不是中文就返回英文
    //        systemLanguage = @"en";
    //    }else{
    //        systemLanguage = @"zh";
    //    }
    
    return systemLanguage;
}

+ (BOOL)isChineseLanguage:(NSString *)lang{
    NSString * language;
    
    if (lang && lang.length > 0)
        language = lang;
    else
        language = [JXMyTools getCurrentSysLanguage];
    
    if ([language isEqualToString:@"zh"] || [language isEqualToString:@"big5"]) {
        return YES;
    }else{
        return NO;
    }
}

+ (NSString *)severLanguage:(NSString *)localLanguage{
    NSString * serverLang = nil;
    if ([localLanguage isEqualToString:@"zh"]) {
        serverLang = @"zh";
    }else if ([localLanguage isEqualToString:@"big5"]) {
        serverLang = @"big5";
    }else if ([localLanguage isEqualToString:@"th"]) {
        serverLang = @"th";
    }else if ([localLanguage isEqualToString:@"malay"]) {
        serverLang = @"ms";
    }else {
        serverLang = @"en";
    }
    return serverLang;
}



+ (UIView *)bottomLineWithFrame:(CGRect)frame{
    UIView *line = [[UIView alloc] initWithFrame:frame];
    line.backgroundColor = THE_LINE_COLOR;
    
    return line;
}
+ (void)showTipView:(NSString *)tip{
    JXTipBlackView *tipView = [[JXTipBlackView alloc] initWithTitle:tip];
    [g_window addSubview:tipView];
    //    [tipView release];
    
    [tipView show];
}

@end
