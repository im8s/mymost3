//
//  JXTelAreaListVC.h
//  shiku_im
//
//  Created by daxiong on 17/4/24.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXTableViewController.h"

@interface JXTelAreaListVC : JXTableViewController
@property (nonatomic,assign) SEL didSelect;
@property (nonatomic,weak) id telAreaDelegate;
@end
