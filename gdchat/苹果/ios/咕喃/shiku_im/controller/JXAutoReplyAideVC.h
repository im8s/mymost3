//
//  JXAutoReplyAideVC.h
//  shiku_im
//
//  Created by p on 2019/5/14.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "admobViewController.h"
#import "JXGroupHeplerModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface JXAutoReplyAideVC : admobViewController

@property (nonatomic, strong) JXHelperModel *model;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *roomJid;


@end

NS_ASSUME_NONNULL_END
