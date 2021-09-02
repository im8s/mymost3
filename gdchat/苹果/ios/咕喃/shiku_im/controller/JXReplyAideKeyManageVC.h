//
//  JXReplyAideKeyManageVC.h
//  shiku_im
//
//  Created by p on 2019/5/15.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "admobViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class JXHelperModel;

@interface JXReplyAideKeyManageVC : admobViewController

@property (nonatomic, strong) NSMutableArray *keys;

@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *helperId;
@property (nonatomic, strong) JXHelperModel *model;

@end

NS_ASSUME_NONNULL_END
