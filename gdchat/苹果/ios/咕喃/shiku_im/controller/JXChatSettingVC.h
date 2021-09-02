//
//  JXChatSettingVC.h
//  shiku_im
//
//  Created by p on 2018/5/19.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "admobViewController.h"
#import "JXRoomObject.h"

@interface JXChatSettingVC : admobViewController

@property (nonatomic,strong) JXUserObject *user;
@property (nonatomic,strong) JXRoomObject* chatRoom;
@property (nonatomic,strong) roomData * room;

@end
