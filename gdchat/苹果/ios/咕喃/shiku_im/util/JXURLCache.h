//
//  JXURLCache.h
//  shiku_im
//
//  Created by 1 on 2019/11/30.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXURLCache : NSURLCache

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request;

@end

NS_ASSUME_NONNULL_END
