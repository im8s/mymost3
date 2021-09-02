//
//  EmployeeTableViewCell.h
//  shiku_im
//
//  Created by 1 on 17/5/18.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmployeObject.h"

@interface EmployeeTableViewCell : UITableViewCell

//@property (strong, nonatomic) UILabel *detailedLabel;
@property (strong, nonatomic) UILabel *customTitleLabel;
@property (strong, nonatomic) UIImageView * headImageView;
@property (strong, nonatomic) UILabel * positionLabel;

@property (nonatomic, strong) UIView *line;

@property (strong, nonatomic) EmployeObject *employObject;


- (void)setupWithData:(EmployeObject *)dataObj level:(NSInteger)level;

@end
