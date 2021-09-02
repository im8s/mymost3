//
//  JXURLCache.m
//  shiku_im
//
//  Created by 1 on 2019/11/30.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXURLCache.h"

@implementation JXURLCache


- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    // 可以在此处进行拦截并执行相应的操作
    NSLog(@"url-------%@",request.URL.absoluteString);
    if ([request.URL.absoluteString isEqualToString:@""]) {
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:@"text/plain" expectedContentLength:1 textEncodingName:nil];
        NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:[NSData dataWithBytes:" " length:1]];
        [super storeCachedResponse:cachedResponse forRequest:request];
    }
    
    [g_notify postNotificationName:kWebViewChangeUrlNotif object:nil];
    
    return [super cachedResponseForRequest:request];
}

@end
