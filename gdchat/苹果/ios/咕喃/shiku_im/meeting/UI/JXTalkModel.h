//
//  JXTalkModel.h
//  lveliao_IM
//
//  Created by p on 2019/6/18.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXTalkModel : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic, assign) long talkTime;

@end

NS_ASSUME_NONNULL_END
