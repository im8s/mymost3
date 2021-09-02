//
//  JXNewRoomVC.h
//  shiku_im
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "admobViewController.h"
@class roomData;
@class JXRoomObject;

@interface JXNewRoomVC : admobViewController{
    UITextField* _desc;
    UILabel* _userName;
    UISwitch * _readSwitch;
    UISwitch * _publicSwitch;
    UISwitch * _secretSwitch;
    UILabel* _size;
    JXRoomObject *_chatRoom;
    roomData* _room;
}

@property (nonatomic,strong) JXRoomObject* chatRoom;
@property (nonatomic,strong) NSString* userNickname;
@property (nonatomic,strong) UITextField* roomName;
@property (nonatomic, assign) BOOL isAddressBook;
@property (nonatomic, strong) NSMutableArray *addressBookArr;

@end
