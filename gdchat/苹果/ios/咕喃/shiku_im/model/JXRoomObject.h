//
//  JXRoomObject.h
//  shiku_im
//
//  Created by flyeagleTang on 14-4-21.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPRoomCoreDataStorage;
@class memberData;


@protocol JXRoomObjectDelegate <NSObject>


- (void)xmppRoomDidJoin;
- (void)xmppRoomDidLeave;
- (void)xmppRoomDidDestroy;
-(void)xmppRoomDidCreate;

@end

@interface JXRoomObject : NSObject{
    BOOL _isNew;
}

@property(nonatomic, strong) NSString *roomId;                     //房间名称
@property(nonatomic, strong) NSString *roomJid;                    //房间名称
@property(nonatomic, strong) NSString *roomName;                   //房间名称
@property(nonatomic, strong) NSString *roomTitle;                  //房间主题
@property(nonatomic, strong) NSString *nickName;                   //房间主题
@property(nonatomic, strong) NSString *fullJid;
@property(nonatomic, assign) XMPPRoomCoreDataStorage* storage;
@property(nonatomic, assign) BOOL isConnected;
@property (nonatomic, weak) id<JXRoomObjectDelegate> delegate;

@property (nonatomic, strong) NSDate *lastDate;

-(void)joinRoom:(bool)isNew;//成员加入群组,isNew=Yes，则不请求历史聊天记录
-(void)createRoom;//群主创建一个群组
-(void)reconnect;
-(void)leave;
-(void)removeUser:(memberData*)userId;

// 群组请求结果
- (void)roomRequestResultWithStatus:(int)status isExit:(BOOL)isExit roomJid:(NSString *)roomJid;
@end
