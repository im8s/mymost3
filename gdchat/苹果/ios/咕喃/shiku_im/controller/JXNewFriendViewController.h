//
//  JXNewFriendViewController.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXTableViewController.h"
#import <UIKit/UIKit.h>

@class JXFriendObject;
@class JXFriendCell;

@interface JXNewFriendViewController: JXTableViewController<UITextFieldDelegate>{
    NSMutableArray* _array;
    int _refreshCount;
    JXFriendObject *_user;
    NSMutableDictionary* poolCell;
    int _friendStatus;
    JXFriendCell* _cell;
}

@end
