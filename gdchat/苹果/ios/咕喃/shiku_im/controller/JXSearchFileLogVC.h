//
//  JXSearchFileLogVC.h
//  shiku_im
//
//  Created by p on 2019/4/8.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FileLogType_file,
    FileLogType_Link,
    FileLogType_transact,
} FileLogType;

@interface JXSearchFileLogVC : JXTableViewController

@property (nonatomic, assign) FileLogType type;

@property (nonatomic, strong) JXUserObject *user;

@property (nonatomic, assign) BOOL isGroup;

@end

NS_ASSUME_NONNULL_END
