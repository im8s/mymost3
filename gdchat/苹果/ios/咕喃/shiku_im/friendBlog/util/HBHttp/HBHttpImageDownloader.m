
//
//  HBHttpImageDownloader.m
//  MyTest
//
//  Created by weqia on 13-8-22.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import "HBHttpImageDownloader.h"
#import "HBHttpRequestCache.h"
#import "HBHttpRequest.h"

@interface HBHttpImageDownloader ()
{
    HBHttpRequestCache * _cache;
    
    NSOperationQueue * _queue;
    
    NSMutableArray * _downloadUrls;     //正在下载得url
}
@end


@implementation HBHttpImageDownloader

#pragma -mark 接口方法
+(HBHttpImageDownloader*) shareDownlader
{
    static HBHttpImageDownloader * downloder=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloder=[[HBHttpImageDownloader alloc]init];
    });
    return downloder;
}
-(id)init
{
    self=[super init];
    if(self){
        _cache=[HBHttpRequestCache shareCache];
        _queue=[[NSOperationQueue alloc]init];
        _queue.maxConcurrentOperationCount=2;
        
        _downloadUrls=[NSMutableArray array];
    }
    return self;
}


-(void) downBitmapWithURL:(NSString *)url
                                         process:(HBHttpImageDownloaderProcessBlock)process
                                        complete:(HBHttpImageDownloaderCompleteBlock)complete
                                          option:(HBHttpImageDownloaderOption)option
                                     valueReturn:(void(^)(id<HBHttpOperationDelegate>)) value
{
    NSURL * URL=[NSURL URLWithString:url];
    if(URL==nil)
        return;
    __block HBHttpImageDownloaderOperation * opration;
    void(^block)()=^{
        if([_downloadUrls containsObject:url])
            return;
        @synchronized(_downloadUrls){
            [_downloadUrls addObject:url];
        }
         opration=[[HBHttpImageDownloaderOperation alloc]initWithURL:URL options:option process:^(NSUInteger receiveSize, long long expectedSize) {
            if(process){
                process(receiveSize,expectedSize);
            }
        } complete:^(UIImage * image, NSData * data, NSError * error, BOOL success) {
            @synchronized(_downloadUrls){
                if([_downloadUrls containsObject:url])
                    [_downloadUrls removeObject:url];
            }
            if(image){
                if(option&HBHttpImageDownloaderOptionUseCache){
                    [_cache storeBitmap:image withKey:url complete:nil];
                }
                if(complete){
                    complete(image,data,error,success);
                }
            }else if(option&HBHttpImageDownloaderOptionRetry){
                [opration  retry];
            }
        } cancel:^{
            @synchronized(_downloadUrls){
                if([_downloadUrls containsObject:url])
                    [_downloadUrls removeObject:url];
            }
        }];
        if([_queue.operations containsObject:opration])
            return ;
        [_queue addOperation:opration];
        if(option&HBHttpImageDownloaderOptionLowPriority){
            [opration setQueuePriority:NSOperationQueuePriorityLow];
        }if(value){
            value(opration);
        }
    };
    if(option&HBHttpImageDownloaderOptionUseCache){
           /*****如果缓存里已经存在，则直接返回*****/
        [_cache getBitmap:url complete:^(UIImage * image){
            if(image){
                complete(image,nil,nil,YES);
            }else{
                block();        //开始执行下载
            }
        }];
       }else{
           block();     //开始执行下载
       }

}
-(void) downBitmapWithIndirectURL:(NSString *)indirectURL
                          process:(HBHttpImageDownloaderProcessBlock)process
                         complete:(HBHttpImageDownloaderCompleteBlock)complete
                           option:(HBHttpImageDownloaderOption)option
                      valueReturn:(void(^)(id<HBHttpOperationDelegate>)) value
{
    __block HBHttpImageDownloaderOperation *opration;
    void(^block)()=^{
        HBHttpRequest * request=[HBHttpRequest shareIntance];
        [request getBitmapURL:indirectURL complete:^(NSString *url) {
            NSURL * URL=[NSURL URLWithString:url];
            if(URL==nil)
                return ;
            opration=[[HBHttpImageDownloaderOperation alloc]initWithURL:URL options:option process:^(NSUInteger receiveSize, long long expectedSize) {
                process(receiveSize,expectedSize);
            } complete:^(UIImage * image, NSData * data, NSError * error, BOOL success) {
                if(success||!image){
                    if(option&HBHttpImageDownloaderOptionUseCache){
                        [_cache storeBitmap:image withKey:indirectURL complete:nil];
                    }
                    complete(image,data,error,success);
                }else if(option&HBHttpImageDownloaderOptionRetry){
                    [opration  retry];
                }
            } cancel:^{
            }];
            if(value){
                value(opration);
            }
            [_queue addOperation:opration];
            if(option&HBHttpImageDownloaderOptionLowPriority){
                [opration setQueuePriority:NSOperationQueuePriorityLow];
            }
        }];
    };
    if(option&HBHttpImageDownloaderOptionUseCache){
        /*****如果缓存里已经存在，则直接返回*****/
        [_cache getBitmap:indirectURL complete:^(UIImage * image){
            if(image){
                complete(image,nil,nil,YES);
            }else{
                block();
            }
        }];
    }else{
        block();
    }
}


@end
