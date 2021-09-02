//
//  JXSettingsViewController.h
//  shiku_im
//
//  Created by Apple on 16/5/6.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXSettingsCell.h"

@interface JXSettingsViewController : admobViewController <UITableViewDataSource,UITableViewDelegate>{
    JXSettingsViewController* _pSelf;
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIView *myView;
@property (strong, nonatomic) NSDictionary * dataSorce;

@property (strong, nonatomic) NSString * att;
@property (strong, nonatomic) NSString * greet;
@property (strong, nonatomic) NSString * friends;
@property (assign, nonatomic) BOOL isEncrypt;
@end
