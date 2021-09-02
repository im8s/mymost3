//
//  HBHttpRequest.m
//  MyTest
//
//  Created by weqia on 13-8-15.
//  Copyright (c) 2013年 weqia. All rights reserved.


#import "HBHttpRequest.h"
//#import "WeqiaAppDelegate.h"
//#import "ObjUrlData.h"


@interface HBHttpRequest ()
{
    NSMutableDictionary * _callBackBlocks;
}
@end

@implementation HBHttpRequest

-(id)init
{
    self=[super init];
    if(self){
        _callBackBlocks=[[NSMutableDictionary alloc]init];
    }
    return self;
}
#pragma -mark 接口方法 

+(HBHttpRequest*)newIntance
{
    static HBHttpRequest * request=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        request=[[HBHttpRequest alloc]init];
    });
    return request;
}

- (void)getBitmapURL:(NSString*)indirectUrl  complete:(void(^)(NSString*))complete
{
//    if([NSStrUtil isEmptyOrNull:indirectUrl])
//        return nil;
//    NSMutableDictionary * dic=[NSMutableDictionary dictionary];
//    [dic setObject:indirectUrl forKey:@"url"];
//    [dic setObject:complete  forKey:@"completeBlock"];
//    NSUInteger index=[self newIndex];
//    [_callBackBlocks setObject:dic forKey:[NSNumber numberWithInteger:index]];
//    ServiceParam *param = [[ServiceParam alloc] init];
//    [param put:@"urls" withValue:IndirectUrl];
//    
//    NSURL *url = [NSURL URLWithString: [[UserService sharedInstance] getFileUrl] ];
//    ASIFormDataRequest *asiFormRequest = [ASIFormDataRequest requestWithURL: url];
//    [[UserService sharedInstance] addParam:param toRequest:asiFormRequest];
//    asiFormRequest.delegate=self;
//    [asiFormRequest setDidFailSelector:@selector(error:)];
//    [asiFormRequest setDidFinishSelector:@selector(getBitmapUrlComplete:)];
//    asiFormRequest.tag=index;
//    [asiFormRequest startAsynchronous];
 //   return nil;
}
#pragma -mark 回调方法





@end
