//
//  UIControl+JXCustom.h
//  shiku_im
//
//  Created by daxiong on 17/12/29.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (JXCustom)
// 可以用这个给重复点击加间隔 页面跳转暂为1秒  可连续点击暂为0.25秒
@property (nonatomic, assign) NSTimeInterval custom_acceptEventInterval;

@end
