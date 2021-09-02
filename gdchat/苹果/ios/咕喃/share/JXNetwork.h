//
//  JXNetwork.h
//  JXNetwork
//
//  Created by Hao Tan on 11-11-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JXNetwork;

@protocol JXNetworkDelegate <NSObject>

-(void)requestSuccess:(JXNetwork*)task;
-(void)requestError:(JXNetwork *)task;

@end


@interface JXNetwork : NSObject


@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *downloadFile;
@property (nonatomic, assign) NSInteger timeout;
@property (nonatomic, assign) long uploadDataSize;//只返回最后一个文件的大小

@property (nonatomic, weak) id toView;
@property (nonatomic, strong) id userData;
@property (nonatomic, strong) id param;
@property (nonatomic, weak) id<JXNetworkDelegate> delegate;
@property (nonatomic, strong) id responseData;
@property (nonatomic, strong) NSString *messageId;

- (void)go;              //开始下载
- (void)stop;           //停止下载
- (BOOL)isImage;
- (BOOL)isVideo;
- (BOOL)isAudio;

- (id)init;
- (void)setPostValue:(id <NSObject>)value forKey:(NSString *)key;
- (void)setData:(NSData *)data forKey:(NSString *)key messageId:(NSString *)messageId;

@end
