//
//  JXMyTools.h
//  shiku_im
//
//  Created by daxiong on 17/4/15.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JXMyTools : NSObject
+ (NSString *)getCurrentSysLanguage;
+ (UIView *)bottomLineWithFrame:(CGRect)frame;
+ (void)showTipView:(NSString *)tip;    //渐变提示框

+ (BOOL)isChineseLanguage:(NSString *)lang;     //是否是中文语系,lang==nil时取系统语言
/**
 本地语言字符串转为和服务器一致,不为空
 */
+ (NSString *)severLanguage:(NSString *)localLanguage;
@end
