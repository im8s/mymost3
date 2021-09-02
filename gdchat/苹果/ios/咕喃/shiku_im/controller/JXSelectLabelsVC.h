//
//  JXSelectLabelsVC.h
//  shiku_im
//
//  Created by p on 2018/7/19.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXTableViewController.h"

@class JXSelectLabelsVC;
@protocol JXSelectLabelsVCDelegate <NSObject>

- (void)selectLabelsVC:(JXSelectLabelsVC *)selectLabelsVC selectLabelsArray:(NSMutableArray *)array;

@end

@interface JXSelectLabelsVC : JXTableViewController

@property (nonatomic, strong) NSMutableArray *selLabels;

@property (nonatomic, weak) id<JXSelectLabelsVCDelegate>delegate;

@end
