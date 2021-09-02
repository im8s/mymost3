//
//  JXSelectFriendsVC.h
//  shiku_im
//
//  Created by p on 2018/7/2.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXTableViewController.h"
#import <UIKit/UIKit.h>
@class menuImageView;
@class JXRoomObject;

typedef NS_OPTIONS(NSInteger, JXSelectFriendType) {
    JXSelectFriendTypeGroupAT    = 1,
    JXSelectFriendTypeSpecifyAdmin,
    JXSelectFriendTypeSelMembers,
    JXSelectFriendTypeSelFriends,
    JXSelectFriendTypeCustomArray,
    JXSelectFriendTypeDisAble,
};

@interface JXSelectFriendsVC: JXTableViewController{
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
@property (nonatomic, assign) SEL        didSelect;
@property (nonatomic,strong) NSMutableSet* set;
@property (nonatomic,strong) NSMutableArray* array;
//@property (nonatomic,strong) memberData* member;
@property (nonatomic,strong) NSSet * existSet;
@property (nonatomic,strong) NSSet * disableSet;
@property (nonatomic,assign) JXSelectFriendType type;
@property (nonatomic, assign) BOOL isShowMySelf;

@property (nonatomic, assign) BOOL isForRoom;
@property (nonatomic, strong) JXUserObject *forRoomUser;
@property (nonatomic, strong) NSMutableArray *userIds;
@property (nonatomic, strong) NSMutableArray *userNames;

@property (nonatomic, strong) UITextField *seekTextField;
//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;

@property (nonatomic, strong) NSMutableArray *searchArray;

@property (nonatomic, strong) NSMutableArray *addressBookArr;

@property (nonatomic, assign) BOOL isShowAlert;
@property (nonatomic, assign) SEL alertAction;

@property (nonatomic, assign) BOOL isAddWindow; // 是否是添加到window上

@property (nonatomic, assign) int maxSize;  // 最多可选择

@end
