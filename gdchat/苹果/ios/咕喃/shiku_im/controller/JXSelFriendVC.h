//
//  JXSelFriendVC.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXTableViewController.h"
#import <UIKit/UIKit.h>
@class menuImageView;
@class JXRoomObject;

typedef NS_OPTIONS(NSInteger, JXSelUserType) {
    JXSelUserTypeGroupAT    = 1,
    JXSelUserTypeSpecifyAdmin,
    JXSelUserTypeSelMembers,
    JXSelUserTypeSelFriends,
    JXSelUserTypeCustomArray,
    JXSelUserTypeDisAble,
    JXSelUserTypeRoomTransfer,
    JXSelUserTypeRoomInvisibleMan,  //设置隐身人
    JXSelUserTypeRoomMonitorPeople, // 设置监控人
};

@interface JXSelFriendVC: JXTableViewController{
    NSMutableArray* _array;
    int _refreshCount;
    menuImageView* _tb;
    UIView* _topView;
    int _selMenu;
    
}
@property (nonatomic,strong) JXRoomObject* chatRoom;
@property (nonatomic,strong) roomData* room;
@property (assign) BOOL isNewRoom;
@property (nonatomic, weak) NSObject* delegate;
@property (nonatomic, assign) SEL		didSelect;
@property (nonatomic,strong) NSMutableSet* set;
@property (nonatomic,strong) NSMutableArray* array;
//@property (nonatomic,strong) memberData* member;
@property (nonatomic,strong) NSSet * existSet;
@property (nonatomic,strong) NSSet * disableSet;
@property (nonatomic,assign) JXSelUserType type;
@property (nonatomic, assign) BOOL isShowMySelf;

@property (nonatomic, assign) BOOL isForRoom;
@property (nonatomic, strong) JXUserObject *forRoomUser;
@property (nonatomic, strong) NSMutableArray *userIds;
@property (nonatomic, strong) NSMutableArray *userNames;

@property (nonatomic, assign) BOOL isShowAlert;
@property (nonatomic, assign) SEL alertAction;
@end
