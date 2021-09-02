//
//  JXRoomPool.h
//  shiku_im
//
//  Created by flyeagleTang on 14-4-21.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JXRoomObject;
@class XMPPRoomCoreDataStorage;

@interface JXRoomPool : NSObject{
//    NSMutableDictionary* _pool;
    XMPPRoomCoreDataStorage* _storage;
}
@property (nonatomic,strong) NSMutableDictionary* pool;

-(JXRoomObject*)createRoom:(NSString*)jid title:(NSString*)title;
-(JXRoomObject*)joinRoom:(NSString*)jid title:(NSString*)title lastDate:(NSDate *)lastDate isNew:(bool)isNew;

-(void)setRoomPool:(NSString*)jid title:(NSString*)title;
//-(JXRoomObject*)connectRoom:(NSString*)jid title:(NSString*)title;

-(void)deleteAll;
-(void)createAll;
-(void)reconnectAll;
-(void)delRoom:(NSString*)jid;
-(JXRoomObject*)getRoom:(NSString*)jid;


-(void)connectRoom;
@end
