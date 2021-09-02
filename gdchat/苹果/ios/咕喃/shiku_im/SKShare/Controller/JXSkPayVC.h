//
//  JXSkPayVC.h
//  shiku_im
//
//  Created by p on 2019/5/16.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "admobViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class JXSkPayVC;
@protocol JXSkPayVCDelegate <NSObject>

- (void)skPayVC:(JXSkPayVC *)skPayVC payBtnAction:(NSDictionary *)payDic;

@end

@interface JXSkPayVC : admobViewController

@property (nonatomic, strong) NSDictionary *payDic;

@property (nonatomic, weak) id<JXSkPayVCDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
