//
//  JXCourseListVC.h
//  shiku_im
//
//  Created by p on 2017/10/20.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXTableViewController.h"

@interface JXCourseListVC : JXTableViewController

@property (nonatomic, assign) int selNum;

- (NSInteger)getSelNum:(NSInteger)num indexNum:(NSInteger)indexNum;

@end
