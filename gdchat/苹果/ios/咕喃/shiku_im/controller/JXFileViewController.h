//
//  JXFileViewController.h
//  shiku_im
//
//  Created by 1 on 17/7/4.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "admobViewController.h"


typedef NS_OPTIONS(NSInteger, JSFileVCType) {
   JSFileVCTypeGroup    = 1 << 0,
};


@interface JXFileViewController : JXTableViewController
@property (nonatomic,strong) roomData * room;

@end
