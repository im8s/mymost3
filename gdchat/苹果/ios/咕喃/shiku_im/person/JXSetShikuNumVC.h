//
//  JXSetShikuNumVC.h
//  shiku_im
//
//  Created by p on 2019/4/11.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "admobViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class JXSetShikuNumVC;

@protocol JXSetShikuNumVCDelegate <NSObject>

-(void)setShikuNum:(JXSetShikuNumVC *)setShikuNumVC updateSuccessWithAccount:(NSString *)account;

@end

@interface JXSetShikuNumVC : admobViewController

@property (nonatomic, strong) JXUserObject *user;

@property (nonatomic, weak) id<JXSetShikuNumVCDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
