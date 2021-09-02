//
//  NSMutableDictionary+NSMutableDictionary_SK.h
//  shiku_im
//
//  Created by p on 2019/7/25.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (NSMutableDictionary_SK)

- (void)setNotNullObject:(id)anObject forKey:(id<NSCopying>)aKey;

@end

NS_ASSUME_NONNULL_END
