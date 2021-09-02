//
//  JXAuthViewController.h
//  shiku_im
//
//  Created by p on 2018/11/2.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "admobViewController.h"

@interface JXAuthViewController : admobViewController

@property (nonatomic, copy) NSString *urlSchemes;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appSecret;

@property (nonatomic, assign) BOOL isWebAuth;
@property (nonatomic,copy) NSString *callbackUrl;

@end
