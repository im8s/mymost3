//
//  NSString+ContainStr.m
//  shiku_im
//
//  Created by 1 on 17/7/4.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "NSString+ContainStr.h"

@implementation NSString (ContainStr)

-(BOOL)containsMyString:(NSString *)str{
    if ([self rangeOfString:str].location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

@end
