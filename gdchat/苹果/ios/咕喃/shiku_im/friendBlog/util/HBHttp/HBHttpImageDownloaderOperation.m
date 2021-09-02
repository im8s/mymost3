//
//  HBHttpImageDownloaderOperation.m
//  MyTest
//
//  Created by weqia on 13-8-21.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import "HBHttpImageDownloaderOperation.h"
#import "HBHttp.h"

@interface HBHttpImageDownloaderOperation ()
{
    NSURL * _url;
    NSURLConnection * _connection;
    long long _expectedSize;
    
    BOOL _retry;
}
@property (nonatomic,strong) HBHttpImageDownloaderProcessBlock processBlock;
@property (nonatomic,strong) HBHttpImageDownloaderCompleteBlock completeBlock;
@property (nonatomic,strong) HBHttpImageDownloaderCancelBlock cancelBlock;
@property (assign,nonatomic,getter = isFinished) BOOL finished;
@property (assign,nonatomic,getter = isExecuting) BOOL executed;
@property (assign,nonatomic,getter = isConcurrent) BOOL concurrent;
@property (nonatomic,strong) NSMutableData * imgData;

@end
@implementation HBHttpImageDownloaderOperation

#pragma -mark  接口方法
-(id<HBHttpOperationDelegate>)initWithURL:(NSURL*)url
         options:(HBHttpImageDownloaderOption)option
         process:(HBHttpImageDownloaderProcessBlock)process
        complete:(HBHttpImageDownloaderCompleteBlock)complete
          cancel:(void(^)())cancel
{
    self=[super init];
    if(self){
        _url=url;
        _option=option;
        _processBlock=[process copy];
        _completeBlock=[complete copy];
        _cancelBlock=[cancel copy];
        _request=[[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:17];
        _retry=NO;
        _executed=NO;
    }
    return self;
}
-(void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished=finished;
    [self didChangeValueForKey:@"isFinished"];
}

-(void)setExecuted:(BOOL)executed
{
    [self willChangeValueForKey:@"isExecuted"];
    _executed=executed;
    [self didChangeValueForKey:@"isExecuted"];
}

-(void)setConcurrent:(BOOL)concurrent
{
    [self willChangeValueForKey:@"isConcurrent"];
    _concurrent=concurrent;
    [self didChangeValueForKey:@"isConcurrent"];
}

#pragma -mark 私有方法
-(void)retry
{
    if(!_retry){
        [self start];
        _retry=YES;
    }
}

-(void)start
{
    if(self.isCancelled){
        _finished=YES;
        _executed=NO;
        [self reset];
        return;
    }
    if(!_request){
        if(_completeBlock){
            _completeBlock(nil,nil,[NSError errorWithDomain:NSURLErrorDomain code:HBHttpConnectionError userInfo:@{NSLocalizedDescriptionKey:Localized(@"JX_ReplyCreatFiled")}],NO);
        }
        return;
    }
    _executed=YES;
    _finished=NO;
    NSURLConnection * connection=[[NSURLConnection alloc]initWithRequest:_request delegate:self startImmediately:YES];
    _connection=connection;
    if(connection){
        if(_processBlock)
            _processBlock(0,-1);    //标志图片下载已经开始
        /****发送开始下载图片的通知***/
        [g_notify postNotificationName:HBHttpImageDownloadStartNotification object:_url];
    }
    else{
        if(_completeBlock)
            /*****连接创建失败，返回错误信息******/
            _completeBlock(nil,nil,[NSError errorWithDomain:NSURLErrorDomain code:HBHttpConnectionError userInfo:@{NSLocalizedDescriptionKey:Localized(@"JX_ContionCreatFiled")}],NO);
        return;
    }
     CFRunLoopRun();
}
-(void)reset
{
    _processBlock=nil;
    _completeBlock=nil;
    _cancelBlock=nil;
    _imgData=nil;
    _url=nil;
    _connection=nil;
}
-(void)done
{
    [self reset];
    _finished=YES;
    _executed=NO;
}

#pragma -mark 回调方法
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if(_completeBlock)
        _completeBlock(nil,nil,[NSError errorWithDomain:NSURLErrorDomain code:HBHttpDownloadError userInfo:@{NSLocalizedDescriptionKey:Localized(@"JX_ImageDownloadFiled")}],NO);
    [g_notify postNotificationName:HBHttpImageDownloadStopNotification object:_url];
    CFRunLoopStop(CFRunLoopGetCurrent());
    [self done];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSUInteger  length= [data length];
    if(length>0&&_processBlock){
        _processBlock(length,_expectedSize);
    }
    [self.imgData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    UIImage * image=[UIImage imageWithData:self.imgData];
    BOOL success=(image!=nil);
    if(_completeBlock){
        _completeBlock(image,self.imgData,nil,success);
    }
    [g_notify postNotificationName:HBHttpImageDownloadStopNotification object:_url];
    CFRunLoopStop(CFRunLoopGetCurrent());
    [self done];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    /***如果响应没有出错，则开始接受数据***/
    if(![response respondsToSelector:@selector(statusCode)]||[((NSHTTPURLResponse*)response) statusCode]<400){
        _expectedSize=[response expectedContentLength];
        if(_expectedSize>0){
            if(_processBlock)
                _processBlock(0,_expectedSize);
            self.imgData=[[NSMutableData alloc]initWithCapacity:_expectedSize];
            return;
        }
    }
    /****如果出错，则停止下载***/
    CFRunLoopStop(CFRunLoopGetCurrent());
    if(_completeBlock){
        _completeBlock(nil,nil,[NSError errorWithDomain:NSURLErrorDomain code:[((NSHTTPURLResponse*)response) statusCode] userInfo:@{NSLocalizedDescriptionKey: Localized(@"JX_ImageIsNull")}],NO);
    }
    [g_notify postNotificationName:HBHttpImageDownloadStopNotification object:_url];
    [self done];

}

-(void)cancel
{
    if(self.isCancelled||self.isFinished)return;
    if(_cancelBlock)
        _cancelBlock();
    [super cancel];
    if(_connection){
        [_connection cancel];
    }
    CFRunLoopStop(CFRunLoopGetCurrent());
    [g_notify postNotificationName:HBHttpImageDownloadStopNotification object:_url];
    [self done];
}

-(BOOL)isFinished{
    return _finished;
}

-(BOOL)isConcurrent{
    return _concurrent;
}

@end
