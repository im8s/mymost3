//
//  JXFriendViewController.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXTableViewController.h"
#import <UIKit/UIKit.h>
#import "JXTopSiftJobView.h"

@class menuImageView;

@interface JXFriendViewController: JXTableViewController{
    NSMutableArray* _array;
    int _refreshCount;
    menuImageView* _tb;
    UIView* _topView;
    int _selMenu;
//    UIButton * _myFriendsBtn;
//    UIButton * _listAttentionBtn;
    UIView *_topScrollLine;
    NSMutableArray * _friendArray;
    JXTopSiftJobView *_topSiftView; //表头筛选控件
    UIView *backView;
}

@property (nonatomic,assign) BOOL isOneInit;
@property (nonatomic,assign) BOOL isMyGoIn; // 是从我界面 进入

- (void) showNewMsgCount:(NSInteger)friendNewMsgNum;

@end
