//
//  JXMyFile.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXTableViewController.h"
#import <UIKit/UIKit.h>
@class menuImageView;
@class JXRoomObject;

@interface JXMyFile: JXTableViewController{
    NSMutableArray* _array;
    int _refreshCount;
    menuImageView* _tb;
    UIView* _topView;
    int _selMenu;
    
}
@property (nonatomic, weak) NSObject* delegate;
@property (nonatomic, assign) SEL		didSelect;

@end
