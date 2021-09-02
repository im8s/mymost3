//
//  JXKeyChainStore.h
//  shiku_im
//
//  Created by IMAC on 2019/8/21.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXKeyChainStore : NSObject

+ (void)save:(NSString*)service data:(id)data;
+ (id)load:(NSString*)service;
+ (void)deleteKeyData:(NSString*)service;
+ (NSString *)getUUIDByKeyChain;
@end

NS_ASSUME_NONNULL_END
