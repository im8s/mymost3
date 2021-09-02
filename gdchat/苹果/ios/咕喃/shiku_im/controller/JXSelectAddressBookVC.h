//
//  JXSelectAddressBookVC.h
//  shiku_im
//
//  Created by p on 2019/4/3.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class JXSelectAddressBookVC;

@protocol JXSelectAddressBookVCDelegate <NSObject>

- (void)selectAddressBookVC:(JXSelectAddressBookVC *)selectVC doneAction:(NSArray *)array;

@end

@interface JXSelectAddressBookVC : JXTableViewController

@property (nonatomic, weak) id<JXSelectAddressBookVCDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
