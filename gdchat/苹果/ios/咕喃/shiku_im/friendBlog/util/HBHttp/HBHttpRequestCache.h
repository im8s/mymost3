//
//  HBHttpRequestCache.h
//  wq
//
//  Created by weqia on 13-8-15.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LKDBHelper.h"

@interface HBHttpRequestCache : NSObject
{
    LKDBHelper * _dbHelper;
    NSString *_cacheFilePath;
    NSCache * _memoryCache;
    dispatch_queue_t _queue;
    
    long long _staleTime;       // 过期时间
    BOOL _timeLimit;    //是否有时间限制
}

+(HBHttpRequestCache*)shareCache;


/*
 *清除所有的硬盘缓存 和 数据库缓存
 */
+(void)clearCache;

- (void)clearOneCache:(NSString *)url;
/*
 *设置过期时间
 */
-(void)setTimeLimit:(long long)time;

/*
 *缓存内容较多且基本固定的文本内容
 *
 */
-(BOOL)storeTextToDB:(NSString*)text withUrl:(NSString*)url;
/*
 *从数据库中获取缓存的文本内容
 */
-(NSString*) getTextFromDB:(NSString*)url;

/*
 * 缓存图片到内存中
 */
-(BOOL)storeBitmapToMemory:(UIImage*)image withKey:(NSString*)key;
/*
 * 缓存图片到硬盘中
 */
-(void)storeBitmapToDisk:(UIImage*)image withKey:(NSString*)key complete:(void(^)(BOOL))complete;
/*
 * 缓存图片倒内存、硬盘中
 */
-(void)storeBitmap:(UIImage*)image  withKey:(NSString*)key complete:(void(^)(BOOL))complete;
/*
 * 从内存缓存获取图片  如果没有对应图片，返回nil
 */
-(UIImage*)getBitmapFromMemory:(NSString*)key;
/*
 * 从硬盘中获取对应url 的图片 (同步方法)
 */
-(UIImage*)getBitmapFromDisk:(NSString *)key;

/*
 * 从硬盘中获取对应url 的图片 ，成功是调用回调，并返回 图片
 */
-(void)getBitmapFromDisk:(NSString*)key complete:(void(^)(UIImage *))complete;
/*
 * 先从内存缓存中获取图片，如果存在，直接调用回调，返回图片。 如果没有，从硬盘中获取，并调用回调返回图片，
 */
-(void)getBitmap:(NSString*)key  complete:(void(^)(UIImage *))complete;
                                                                          
                                                                        

/*
 *清除当前缓存路径下的缓存
 */
-(void) clearDiskCache;

/*
 *清除内存缓存
 */
-(void) clearMemoryCache;


/*
 * 设置当前缓存的缓存路径
 */
-(void) setDirectoryAtPath:(NSString*) path;

@end
