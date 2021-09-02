//
//  JXSelectorVC.h
//  shiku_im
//
//  Created by p on 2017/8/26.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXTableViewController.h"
@class JXSelectorVC;

@protocol JXSelectorVCDelegate <NSObject>

- (void) selector:(JXSelectorVC*)selector selectorAction:(NSInteger)selectIndex;

@end

@interface JXSelectorVC : JXTableViewController

@property (nonatomic, strong) NSArray *array;

@property (nonatomic, assign) NSInteger selectIndex;

@property (nonatomic, weak) id delegate;

@property (nonatomic, assign) SEL didSelected;

@property (nonatomic, weak) id<JXSelectorVCDelegate> selectorDelegate;

@end
