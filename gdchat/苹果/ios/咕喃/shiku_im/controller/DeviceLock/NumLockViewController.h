//
//  NumLockViewController.h
//  numLockTest
//
//  Created by banbu01 on 15-2-5.
//  Copyright (c) 2015年 com.koochat.test0716. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NumLockViewController;

@protocol NumLockViewControllerDelegate <NSObject>

- (void)numLockVCSetSuccess:(NumLockViewController *)numLockVC;

@end

@interface NumLockViewController : UIViewController

@property (nonatomic, assign) BOOL isSet;
@property (nonatomic, assign) BOOL isClose;
@property (nonatomic, weak) id<NumLockViewControllerDelegate> delegate;

@end
