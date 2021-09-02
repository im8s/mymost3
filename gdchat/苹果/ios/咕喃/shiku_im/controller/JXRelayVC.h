//
//  JXRelayVC.h
//  shiku_im
//
//  Created by p on 2017/6/27.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXTableViewController.h"
#import "JXChatViewController.h"

@class JXRelayVC;
@protocol JXRelayVCDelegate <NSObject>

@optional

- (void)relay:(JXRelayVC *)relayVC MsgAndUserObject:(JXMsgAndUserObject *)obj;

- (void)shareSuccess;

@end

@interface JXRelayVC : JXTableViewController

//@property (nonatomic, strong) JXMessageObject *msg;
@property (nonatomic, strong) NSMutableArray *relayMsgArray;

@property (nonatomic, assign) BOOL isCourse;
@property (nonatomic, weak) id<JXRelayVCDelegate> relayDelegate;

@property (nonatomic, strong) JXUserObject *chatPerson;
@property (nonatomic,copy) NSString *roomJid;

@property (nonatomic, assign) BOOL isShare;
@property (nonatomic, assign) int shareType;
@property (nonatomic, copy) NSString *shareSchemes;
@property (nonatomic, assign) BOOL isUrl;
@property (nonatomic, assign) BOOL isMoreSel;
@property (nonatomic, weak) JXChatViewController *chatVC; ;


@end
