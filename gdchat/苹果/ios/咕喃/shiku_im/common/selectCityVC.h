//
//  selectCityVC.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXTableViewController.h"
#import <UIKit/UIKit.h>
@class menuImageView;

@interface selectCityVC: JXTableViewController{
    NSMutableDictionary* _array;
    NSArray* _keys;
    int _refreshCount;
}
@property(assign)int parentId;
@property(strong,nonatomic)NSString* parentName;
@property(nonatomic,assign) BOOL showArea;
@property(nonatomic,assign) int selected;
@property(nonatomic,strong) NSString* selValue;
@property(nonatomic,weak) id delegate;
@property(assign) SEL didSelect;
@property(nonatomic,assign) int cityId;
@property(nonatomic,assign) int areaId;
@end
