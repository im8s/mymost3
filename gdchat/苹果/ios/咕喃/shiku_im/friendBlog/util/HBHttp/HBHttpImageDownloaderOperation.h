//
//  HBHttpImageDownloaderOperation.h
//  MyTest
//
//  Created by weqia on 13-8-21.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HBHttpImageDownloadStartNotification @"HBHttpImageDownloadStartNotification"

#define HBHttpImageDownloadStopNotification  @"HBHttpImageDownloadStopNotification"

typedef void(^HBHttpImageDownloaderProcessBlock)(NSUInteger,long long);

typedef void(^HBHttpImageDownloaderCompleteBlock)(UIImage*,NSData*,NSError*,BOOL);

typedef void(^HBHttpImageDownloaderCancelBlock)();

typedef enum {
    HBHttpImageDownloaderOptionRetry=1<<0,
    /**
     *  低优先级
     **/
    HBHttpImageDownloaderOptionLowPriority=1<<1,
    /**
     *  缓存中加载
     **/
    HBHttpImageDownloaderOptionUseCache=1<<3,
    /**
     *  显示加载过程
     **/
    HBHttpImageDownloaderOptionProgressiveDownload=1<<4
}HBHttpImageDownloaderOption;

@protocol HBHttpOperationDelegate <NSObject>
-(void) cancel;
@end

@interface HBHttpImageDownloaderOperation : NSOperation<HBHttpOperationDelegate>{
    BOOL _finished;
    BOOL _concurrent;
}

@property (nonatomic,readonly) NSURLRequest * request;
@property (nonatomic,readonly) HBHttpImageDownloaderOption option;

-(id)initWithURL:(NSURL*)url
         options:(HBHttpImageDownloaderOption)option
         process:(HBHttpImageDownloaderProcessBlock)process
        complete:(HBHttpImageDownloaderCompleteBlock)complete
          cancel:(void(^)())cancel;
-(void)retry;
@end
