//
//  myMediaVC.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXTableViewController.h"
#import <UIKit/UIKit.h>
@class menuImageView;
@class JXMediaCell;

@interface myMediaVC: JXTableViewController{
    NSMutableArray* _array;
    int _refreshCount;
    JXMediaCell* _cell;
}
@property(nonatomic,weak) id delegate;
@property(assign) SEL didSelect;
- (void) onAddVideo;

@end
