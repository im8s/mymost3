//
//  HBHttpRequest.h
//  MyTest
//
//  Created by weqia on 13-8-15.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBHttpRequest : NSObject

+(HBHttpRequest*)shareIntance;


- (void)getBitmapURL:(NSString*)indirectUrl  complete:(void(^)(NSString*))complete;

@end
