//
//  JXGroupViewController
//  BaseProject
//
//  Created by Huan Cho on 13-8-3.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXTableViewController.h"
#import "JXTopSiftJobView.h"

@protocol XMPPRoomDelegate;
@class JXRoomObject;
@class menuImageView;

@interface JXGroupViewController : JXTableViewController{
    
    int _refreshCount;
    int _recordCount;

    NSString* _roomJid;
    JXRoomObject *_chatRoom;
    UITextField* _inputText;

    menuImageView* _tb;
    UIScrollView * _scrollView;
    int _selMenu;
    JXTopSiftJobView *_topSiftView; //表头筛选控件
//    UIButton * _myRoomBtn;
//    UIButton * _allRoomBtn;
//    UIView *_topScrollLine;
//    int _sel;
}
@property (nonatomic,strong) NSMutableArray * array;
@property (assign,nonatomic) int sel;

//- (void)actionNewRoom;
//- (void)reconnectToRoom;
@end
