//
//  JXMsgAndUserObject.m
//
//  Created by Reese on 13-8-15.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "JXMsgAndUserObject.h"

@implementation JXMsgAndUserObject
@synthesize message,user;


+(JXMsgAndUserObject *)unionWithMessage:(JXMessageObject *)aMessage andUser:(JXUserObject *)aUser
{
    JXMsgAndUserObject *unionObject=[[JXMsgAndUserObject alloc]init];
    unionObject.user = aUser;
    unionObject.message = aMessage;
//    NSLog(@"%d,%d",aMessage.retainCount,aUser.retainCount);
    return unionObject;
}

-(void)dealloc{
//    NSLog(@"JXMsgAndUserObject.dealloc");
    self.user = nil;
    self.message = nil;
//    [super dealloc];
}



@end
