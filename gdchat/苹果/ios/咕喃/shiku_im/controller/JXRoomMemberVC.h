//
//  JXRoomMemberVC.h
//  shiku_im
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "admobViewController.h"
@class roomData;
@class JXRoomObject;

@protocol JXRoomMemberVCDelegate <NSObject>

- (void) setNickName:(NSString *)nickName;
- (void) needVerify:(JXMessageObject *)msg;

@end

@interface JXRoomMemberVC : admobViewController<LXActionSheetDelegate>{
    JXLabel* _desc;
    JXLabel* _userName;
    JXLabel* _roomName;
    UILabel* _memberCount;
    UILabel* _creater;
    UILabel* _size;
    NSMutableArray* _deleteArr;
    NSMutableArray* _images;
    NSMutableArray* _names;
    BOOL _delMode;
    JXRoomObject *_chatRoom;
    int _h;
    BOOL _isAdmin;
    BOOL _allowEdit;
    UILabel* _note;
    UILabel* _userNum;
    UIView* _heads;
    int _delete;
    int _disable;
    BOOL _disableMode;
    BOOL _unfoldMode;
    JXUserObject* _user;
    JXImageView* _blackBtn;
    int _modifyType;
    NSString* _content;
    NSString* _toUserId;
    NSString* _toUserName;
    UISwitch * _readSwitch;
    UISwitch *_messageFreeSwitch;
    UISwitch *_allNotTalkSwitch;
    UISwitch *_topSwitch;
    UISwitch *_notMsgSwitch;
    UILabel* _roomNum;
}

@property (nonatomic, assign) NSString *roomId;

@property (nonatomic,strong) JXRoomObject* chatRoom;
@property (nonatomic,strong) roomData* room;
@property (nonatomic,strong) JXImageView * iv;
@property (nonatomic, weak) id<JXRoomMemberVCDelegate>delegate;
@property (nonatomic, assign) int rowIndex;

//@property (nonatomic,strong) NSString* userNickname;

@end
