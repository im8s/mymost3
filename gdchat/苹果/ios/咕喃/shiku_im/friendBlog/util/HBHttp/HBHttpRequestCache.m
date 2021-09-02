//
//  HBHttpRequestCache.m
//  wq
//
//  Created by weqia on 13-8-15.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//

#import "HBHttpRequestCache.h"
#import "HBHttpCacheData.h"
#import <CommonCrypto/CommonDigest.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
@implementation HBHttpRequestCache

-(id)init
{
    self=[super init];
    if(self){
        /**创建数据库，如果不存在*/
        _dbHelper=[[LKDBHelper alloc]init];
        [_dbHelper createTableWithModelClass:[HBHttpCacheData class]];
        /**默认文件路径**/
        NSArray * paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSMutableString * path=[NSMutableString stringWithString:[paths objectAtIndex:0]];
        [path appendFormat:@"/HBHttpCache"];
        _cacheFilePath=path;
        /****创建缓存目录****/
        NSFileManager * manager=[NSFileManager defaultManager];
        if(![manager fileExistsAtPath:_cacheFilePath])
           [manager createDirectoryAtPath:_cacheFilePath withIntermediateDirectories:YES attributes:nil error:NULL];
        /***设置内存缓存****/
        _memoryCache=[[NSCache alloc]init];
        [_memoryCache setTotalCostLimit:7*1024*1024];   //默认最大缓存空间为7M
        
        /***穿件线程队列**/
        _queue=dispatch_queue_create("com.HBHhttp.imageCache", NULL);
        
        /***默认过期时间为三天***/
        _staleTime=24*60*60*3;
        
        _timeLimit=NO;   //默认期限开关为关
        
    }
    return self;
}
#pragma -mark  私有方法

-(void)clearCache
{
    dispatch_async(_queue, ^{
        /**获取所有图片路径**/
        NSArray* array=[_dbHelper search:[HBHttpCacheData class] where:[NSString stringWithFormat:@"cacheType=%d",HBHttpCacheDataTypeImage] orderBy:nil offset:0 count:MAXFLOAT];
        NSFileManager * manager=[NSFileManager defaultManager];
        for(HBHttpCacheData * cache in array){
            [manager removeItemAtPath:cache.cacheData error:nil];      //删除所有图片路径
        }
        [LKDBHelper clearTableData:[HBHttpCacheData class]];         // 清空数据库
        [self clearMemoryCache];   // 清除内存缓存
    });
}


/******检测缓存数据是否过期*****/
-(BOOL)timeOutCheck:(HBHttpCacheData*)data
{
    NSDate * date=[NSDate date];
    long long now=(long long)date.timeIntervalSince1970;
    if((now-data.timestamp.longLongValue)>_staleTime){
        [self timeOutCheck:data];
        return YES;
    }else{
        return NO;
    }
}
/********检测到数据过期后的操作*********/
-(void)timeOutAction:(HBHttpCacheData*)data
{
    if(data.cacheType==HBHttpCacheDataTypeText){
        [_dbHelper deleteToDB:data];
    }else if(data.cacheType==HBHttpCacheDataTypeImage){
        NSFileManager * manager=[NSFileManager defaultManager];
        [manager removeItemAtPath:data.cacheData error:nil];
        [_dbHelper deleteToDB:data];
    }
}



#pragma -mark  接口方法


+(HBHttpRequestCache*)shareCache
{
    static HBHttpRequestCache * server=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        server=[[HBHttpRequestCache alloc]init];
    });
    return server;
}

+(void)clearCache
{
    [[self shareCache] clearCache];
}

- (void)clearOneCache:(NSString *)url{
    [_memoryCache removeObjectForKey:url];
}

-(void)setTimeLimit:(long long)time
{
    _staleTime=time;
}

/*********根据传入的url生成文件名称**********/
-(NSString *)getFileName:(NSString*)key
{
    const char *str = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
}


-(BOOL)storeTextToDB:(NSString*)text withUrl:(NSString*)url
{
     /*******生成缓存对象，并设置内容*********/
    HBHttpCacheData * cache=[[HBHttpCacheData alloc]init];
    cache.cacheData=text;
    cache.cacheUrl=url;
    cache.cacheType=HBHttpCacheDataTypeText;
     /*******判断当前缓存中是否已经存在该内容*********/
    int rowCount=[_dbHelper rowCount:[HBHttpCacheData class] where:@{@"cacheUrl":url}];
    if(rowCount==0)
        return [_dbHelper insertToDB:cache];   // 如果缓存中不存在则直接插入 
    else {
        if([_dbHelper deleteToDB:cache])
           return  [_dbHelper insertToDB:cache];
        else
           return NO;
    }   //如果已经存在，则更新内容
}

-(NSString*) getTextFromDB:(NSString*)url
{
    HBHttpCacheData * cache=[_dbHelper searchSingle:[HBHttpCacheData class] where:@{@"cacheUrl":url} orderBy:nil];
    /****检测是否过期***/
    if(_timeLimit){
       if([self timeOutCheck:cache])
            return nil;
    }
    if(cache&&cache.cacheType==HBHttpCacheDataTypeText)
        return cache.cacheData;
    return nil;
}

-(BOOL)storeBitmapToMemory:(UIImage*)image withKey:(NSString*)key
{
    id object=[_memoryCache objectForKey:key];
    if(object==nil){
        if(image){
            [_memoryCache setObject:image forKey:key];
            return YES;
        }else
            return NO;
    }else
        return NO;
}

-(void)storeBitmapToDisk:(UIImage*)image withKey:(NSString*)key complete:(void(^)(BOOL))complete
{
    dispatch_async(_queue, ^{
        BOOL success=NO;
        /*****生成文件路径*****/
        NSMutableString * fileName=[NSMutableString stringWithString:_cacheFilePath];
        [fileName appendFormat:@"/%@",[self getFileName:key]];
        /*******生成缓存对象，并设置内容*********/
        HBHttpCacheData * cache=[[HBHttpCacheData alloc]init];
        cache.cacheData=fileName;
        cache.cacheType=HBHttpCacheDataTypeImage;
        cache.cacheUrl=key;
        /*******判断当前缓存中是否已经存在该内容*********/
        int rowCount=[_dbHelper rowCount:[HBHttpCacheData class] where:@{@"cacheUrl":key}];
        if(rowCount==0){     // 如果缓存中不存在则直接插入
            if([_dbHelper insertToDB:cache]){       
                NSFileManager * manager=[NSFileManager defaultManager];
                //在该路径下创建文件，如果创建失败，数据库回滚
                if(![manager createFileAtPath:fileName contents:UIImageJPEGRepresentation(image, 0.5) attributes:nil]){
                    [_dbHelper deleteToDB:cache];   
                }else{
                    success=YES;
                }
            }
        }else{          //如果已经存在，则更新该路径下的文件
            NSFileManager * manager=[NSFileManager defaultManager];
            [manager removeItemAtPath:cache.cacheData error:nil];
            if(![manager createFileAtPath:fileName contents:UIImageJPEGRepresentation(image, 0.5) attributes:nil]){
                [_dbHelper deleteToDB:cache];           // 如果更新文件失败，则删除该条数据库记录
            }else{
                success=YES;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(success);
        });

    });
  }

-(void)storeBitmap:(UIImage*)image withKey:(NSString*)key complete:(void(^)(BOOL))complete
{
    /***先将图片缓存到硬盘中***/
    [self storeBitmapToDisk:image withKey:key complete:^(BOOL success) {
        if(success){  // 如果成功缓存到硬盘，则继续缓存到内存中
            [self storeBitmapToMemory:image withKey:key];
        }
        if(complete){
            complete(success);
        }
    }];
    
}

-(UIImage*)getBitmapFromMemory:(NSString*)key
{
    return [_memoryCache objectForKey:key];
}

-(void)getBitmapFromDisk:(NSString*)key complete:(void(^)(UIImage *))complete
{
    dispatch_async(_queue, ^{
        /***从数据库中获取缓存路径 **/
        HBHttpCacheData * cache=[_dbHelper searchSingle:[HBHttpCacheData class] where:@{@"cacheUrl":key} orderBy:nil];
        /****检测是否过期***/
        if(_timeLimit){
            if([self timeOutCheck:cache]){
                complete(nil);
            }
        }
        if(cache&&cache.cacheType==HBHttpCacheDataTypeImage){          //如果缓存存在并且缓存类型为图片类型
            /**判断该路径是否存在文件*/
            NSFileManager * manager=[NSFileManager defaultManager];
            if(![manager fileExistsAtPath:cache.cacheData]){
                /**如果该路径下不存在文件或者已经被删除，则删除掉该条数据库记录**/
                [_dbHelper deleteToDB:cache];
                complete(nil);   //  执行回调，并返回nil
            }
            /**文件存在，则生成图片**/
            UIImage *image=[UIImage imageWithContentsOfFile:cache.cacheData];
            if(image==nil){
                /**如果文件格式不正确，则删除该条数据库记录，并且删除该文件**/
                [_dbHelper deleteToDB:cache];
                [manager removeItemAtPath:cache.cacheData error:nil];
                complete(nil);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(image);
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil);
            });
        }
    });
}
-(UIImage*)getBitmapFromDisk:(NSString *)key
{
    HBHttpCacheData * cache=[_dbHelper searchSingle:[HBHttpCacheData class] where:@{@"cacheUrl":key} orderBy:nil];
    /****检测是否过期***/
    if(_timeLimit){
        if([self timeOutCheck:cache]){
            return nil;
        }
    }
    if(cache&&cache.cacheType==HBHttpCacheDataTypeImage){          //如果缓存存在并且缓存类型为图片类型
        /**判断该路径是否存在文件*/
        NSFileManager * manager=[NSFileManager defaultManager];
        if(![manager fileExistsAtPath:cache.cacheData]){
            /**如果该路径下不存在文件或者已经被删除，则删除掉该条数据库记录**/
            [_dbHelper deleteToDB:cache];
            return nil;   //  执行回调，并返回nil
        }
        /**文件存在，则生成图片**/
        UIImage *image=[UIImage imageWithContentsOfFile:cache.cacheData];
        if(image==nil){
            /**如果文件格式不正确，则删除该条数据库记录，并且删除该文件**/
            [_dbHelper deleteToDB:cache];
            [manager removeItemAtPath:cache.cacheData error:nil];
            return nil;
        }
        return image;
    }
    return nil;
}

-(void)getBitmap:(NSString*)key  complete:(void(^)(UIImage *))complete
{
    /**先从内存缓存中获取**/
    UIImage * image=[self getBitmapFromMemory:key];
    if(image)
        complete(image);
    else{
        /**如果内存缓存中不存在，则到硬盘中获取**/
        [self getBitmapFromDisk:key complete:^(UIImage * image){
            if(image){
               [self storeBitmapToMemory:image withKey:key];
            }
            if(complete){
                complete(image);
            }
        }];
    }    
}


-(void) clearMemoryCache
{
    [_memoryCache removeAllObjects];
}

-(void) clearDiskCache
{
    NSFileManager * manager=[NSFileManager defaultManager];
    if([manager fileExistsAtPath:_cacheFilePath]){
        [manager removeItemAtPath:_cacheFilePath error:NULL];
        [manager createDirectoryAtPath:_cacheFilePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}
-(void)setDirectoryAtPath:(NSString*) path
{
    _cacheFilePath=path;
    NSFileManager * manager=[NSFileManager defaultManager];
    if(![manager fileExistsAtPath:_cacheFilePath])
        [manager createDirectoryAtPath:_cacheFilePath withIntermediateDirectories:YES attributes:nil error:NULL];
}

@end
