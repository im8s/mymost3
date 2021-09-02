//
//  JXRoomMemberListVC.h
//  shiku_im
//
//  Created by p on 2018/7/3.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXTableViewController.h"
#import "JXRoomObject.h"

typedef enum : NSUInteger {
    Type_Default = 1,
    Type_NotTalk,
    Type_DelMember,
    Type_AddNotes,
} RoomMemberListType;

@class JXInputValueVC;
@class JXRoomMemberListVC;

@protocol JXRoomMemberListVCDelegate <NSObject>

- (void) roomMemberList:(JXRoomMemberListVC *)vc delMember:(memberData *)member;

- (void)roomMemberList:(JXRoomMemberListVC *)selfVC addNotesVC:(JXInputValueVC *)vc;

@end

@interface JXRoomMemberListVC : JXTableViewController


@property (nonatomic,strong) roomData* room;

@property (nonatomic, assign) RoomMemberListType type;
@property (nonatomic,strong) JXRoomObject* chatRoom;

@property (nonatomic, weak) id<JXRoomMemberListVCDelegate>delegate;

@end
