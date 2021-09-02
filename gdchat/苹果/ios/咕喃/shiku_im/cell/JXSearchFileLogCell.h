//
//  JXSearchFileLogCell.h
//  shiku_im
//
//  Created by p on 2019/4/8.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXSearchFileLogVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface JXSearchFileLogCell : UITableViewCell

@property (nonatomic, strong) JXMessageObject *msg;

@property (nonatomic, assign) FileLogType type;

@end

NS_ASSUME_NONNULL_END
