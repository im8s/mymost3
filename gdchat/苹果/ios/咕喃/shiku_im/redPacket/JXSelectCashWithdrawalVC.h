//
//  JXSelectCashWithdrawalVC.h
//  shiku_im
//
//  Created by p on 2019/12/9.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXTableViewController.h"

@protocol JXSelectCashWithdrawalVCDelegate <NSObject>

- (void)selectCashWithdrawalWithData:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_BEGIN

@interface JXSelectCashWithdrawalVC : JXTableViewController

@property (nonatomic, assign) id<JXSelectCashWithdrawalVCDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
