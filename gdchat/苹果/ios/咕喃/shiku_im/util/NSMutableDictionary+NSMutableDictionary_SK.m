//
//  NSMutableDictionary+NSMutableDictionary_SK.m
//  shiku_im
//
//  Created by p on 2019/7/25.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "NSMutableDictionary+NSMutableDictionary_SK.h"

@implementation NSMutableDictionary (NSMutableDictionary_SK)

- (void)setNotNullObject:(id)anObject forKey:(id<NSCopying>)aKey;{
    if (anObject) {
        [self setObject:anObject forKey:aKey];
    }
}

@end
