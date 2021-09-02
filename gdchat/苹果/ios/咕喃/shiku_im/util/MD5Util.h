//
//  MD5Util.h
//  shiku_im
//
//  Created by p on 2019/7/15.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "md5.h"

NS_ASSUME_NONNULL_BEGIN

@interface MD5Util : NSObject

+(NSString*)getMD5StringWithString:(NSString*)s;
+(NSData*)getMD5DataWithData:(NSData*)data;
+(NSData*)getMD5DataWithString:(NSString*)str;
+(NSString*)getMD5StringWithData:(NSData*)data;

@end

NS_ASSUME_NONNULL_END
