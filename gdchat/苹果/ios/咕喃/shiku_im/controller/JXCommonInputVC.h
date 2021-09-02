//
//  JXCommonInputVC.h
//  shiku_im
//
//  Created by p on 2019/4/1.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "admobViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class JXCommonInputVC;

@protocol JXCommonInputVCDelegate <NSObject>

- (void)commonInputVCBtnActionWithVC:(JXCommonInputVC *)commonInputVC;

@end

@interface JXCommonInputVC : admobViewController

@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic,copy) NSString *subTitle;
@property (nonatomic,copy) NSString *tip;
@property (nonatomic,copy) NSString *btnTitle;
@property (nonatomic, strong) UITextField *name;
@property (nonatomic, weak) id<JXCommonInputVCDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
