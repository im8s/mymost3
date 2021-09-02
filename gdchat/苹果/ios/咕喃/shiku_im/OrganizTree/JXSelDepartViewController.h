//
//  JXSelDepartViewController.h
//  shiku_im
//
//  Created by 1 on 17/6/1.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "admobViewController.h"
@class DepartObject;

@protocol SelDepartDelegate <NSObject>

-(void)selNewDepartmentWith:(DepartObject *)newDepart;

@end

@interface JXSelDepartViewController : admobViewController

//@property (nonatomic,copy) NSString * oldDepartId;
@property (nonatomic, strong) DepartObject * oldDepart;
@property (nonatomic, strong) NSArray * dataArray;
@property (nonatomic, weak) id delegate;

@end
