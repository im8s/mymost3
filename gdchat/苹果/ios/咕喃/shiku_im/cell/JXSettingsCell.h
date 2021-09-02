//
//  JXSettingsCell.h
//  shiku_im
//
//  Created by Apple on 16/5/6.
//  Copyright © 2016年 Reese. All rights reserved.
//  好友验证设置

#import <UIKit/UIKit.h>
@class JXSettingsViewController;

@interface JXSettingsCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *myLabel;
//@property (strong, nonatomic) IBOutlet UISwitch *mySwitch;
@property (strong, nonatomic) UISwitch *mySwitch;

@property (strong,nonatomic) JXSettingsViewController * inTableView;

@property (strong,nonatomic) NSString * att;
@property (strong,nonatomic) NSString * greet;
@property (strong,nonatomic) NSString * friends;

@property (nonatomic, strong) UIView *line;


@property (nonatomic,assign) void (^block)(BOOL,int);
@end
