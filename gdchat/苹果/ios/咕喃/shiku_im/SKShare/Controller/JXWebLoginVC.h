//
//  JXWebLoginVC.h
//  shiku_im
//
//  Created by p on 2019/5/28.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "admobViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class JXWebLoginVC;
@protocol JXWebLoginVCDelegate <NSObject>

- (void)webLoginSuccess;

@end

@interface JXWebLoginVC : admobViewController

@property (nonatomic, copy) NSString *callbackUrl;

@property (nonatomic, assign) BOOL isQRLogin;

@property (nonatomic, weak) id<JXWebLoginVCDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
