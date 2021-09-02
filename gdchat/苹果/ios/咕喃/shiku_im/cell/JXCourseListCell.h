//
//  JXCourseListCell.h
//  shiku_im
//
//  Created by p on 2017/10/20.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXCourseListVC.h"

typedef int(^JXCourseListCellBlock)(int type);

@interface JXCourseListCell : UITableViewCell

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, weak) JXCourseListVC *vc;
@property (nonatomic, assign) JXCourseListCellBlock block;
@property (nonatomic, assign) BOOL isMultiselect;
@property (nonatomic, assign) NSInteger indexNum;

@property (nonatomic, strong) UIButton *multiselectBtn;

- (void) setData:(NSDictionary *)dict;

@end
