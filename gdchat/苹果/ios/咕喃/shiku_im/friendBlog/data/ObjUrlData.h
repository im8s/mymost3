//
//  ObjUrlData.h
//  wq
//
//  Created by berwin on 13-7-22.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//

#import "Jastor.h"

@interface ObjUrlData : Jastor

@property (strong, nonatomic) NSString *url;
@property (strong,nonatomic)  NSString *id;
@property (strong, nonatomic) NSString *createDate;
@property (strong, nonatomic) NSString *mime;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *type; //1-图片 2-语音 3-视频 4-其他文件
@property (strong, nonatomic) NSString *fileSize;
@property (strong, nonatomic) NSNumber *timeLen;

@end
