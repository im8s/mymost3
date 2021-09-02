//
//  JXRoomMember.h
//  shiku_im
//
//  Created by 1 on 17/6/27.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JXRoomMember : NSObject{
    NSString* _tableName;
}


//@property (nonatomic, strong) JXUserObject * user;
@property (nonatomic, strong) NSString * roomId;
@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSString * userName;
@property (nonatomic, strong) NSString * cardName;
@property (nonatomic, assign) NSUInteger isAdmin;

@end
