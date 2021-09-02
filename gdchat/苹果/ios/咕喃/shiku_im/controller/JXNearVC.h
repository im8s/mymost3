//
//  JXNearVC.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

//#import "JXTableViewController.h"
#import <UIKit/UIKit.h>

@class searchData;
@class JXLocMapVC;
@class JXGooMapVC;
@interface JXNearVC: admobViewController{
    NSMutableArray* _array;
    int _refreshCount;

    UIView* _topView;
    UIButton* _apply;
    UILabel* _lb;
    //searchData* _search;
    //BOOL _bNearOnly;
}
@property (nonatomic,strong)searchData *search;
@property (nonatomic,assign)BOOL bNearOnly;
@property (nonatomic,assign)int page;
@property (nonatomic,assign)BOOL isSearch;

@property (nonatomic,strong) JXLocMapVC * mapVC;
@property (nonatomic,strong) JXGooMapVC * goomapVC;

-(void)onSearch;
-(void)getServerData;
-(void)doSearch:(searchData*)p;
@end
