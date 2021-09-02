//
//  HBHttpImageDownloader.h
//  MyTest
//
//  Created by weqia on 13-8-22.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HBHttpImageDownloaderOperation.h"

@interface HBHttpImageDownloader : NSObject

+(HBHttpImageDownloader*) shareDownlader;

-(void) downBitmapWithURL:(NSString*)url
                                         process:(HBHttpImageDownloaderProcessBlock)process
                                        complete:(HBHttpImageDownloaderCompleteBlock)complete
                                          option:(HBHttpImageDownloaderOption)option
                                     valueReturn:(void(^)(id<HBHttpOperationDelegate>)) value;

-(void) downBitmapWithIndirectURL:(NSString *)url
                          process:(HBHttpImageDownloaderProcessBlock)process
                         complete:(HBHttpImageDownloaderCompleteBlock)complete
                           option:(HBHttpImageDownloaderOption)option
                      valueReturn:(void(^)(id<HBHttpOperationDelegate>)) value;


@end
