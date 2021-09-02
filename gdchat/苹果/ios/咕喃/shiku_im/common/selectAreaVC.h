//
//  selectAreaVC.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXTableViewController.h"
#import <UIKit/UIKit.h>
@class menuImageView;

@interface selectAreaVC: JXTableViewController{
    NSMutableDictionary* _array;
    NSArray* _keys;
    int _refreshCount;
    int _selMenu;
}
@property(assign)int parentId;
@property(nonatomic,strong)NSString* parentName;
@property(nonatomic,assign) int selected;
@property(nonatomic,strong) NSString* selValue;
@property(nonatomic,weak) id delegate;
@property(assign) SEL didSelect;
@end
