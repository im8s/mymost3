//
//  JXShareManage.h
//  shiku_im
//
//  Created by p on 2018/11/1.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JXAuthViewController.h"

@interface JXShareManage : NSObject

+ (instancetype)sharedManager;

// 第三方APP 跳转回调
-(BOOL) handleOpenURL:(NSURL *) url delegate:(id) delegate;

@end
