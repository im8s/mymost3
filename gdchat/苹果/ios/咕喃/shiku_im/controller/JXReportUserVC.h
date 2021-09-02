//
//  JXReportUserVC.h
//  shiku_im
//
//  Created by 1 on 17/6/26.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXTableViewController.h"

@protocol JXReportUserDelegate <NSObject>

-(void)report:(JXUserObject *)reportUser reasonId:(NSNumber *)reasonId;

@end

@interface JXReportUserVC : JXTableViewController

@property (nonatomic, strong) JXUserObject * user;

@property (nonatomic, weak) id delegate;

@property (nonatomic, assign) BOOL isUrl;


@end
