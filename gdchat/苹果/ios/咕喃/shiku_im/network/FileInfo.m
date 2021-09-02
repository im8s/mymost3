//
//  FileInfo.m
//  iPhoneFTP
//
//  Created by Zhou Weikuan on 10-6-15.
//  Copyright 2010 sino. All rights reserved.
//

#import "FileInfo.h"


@implementation FileInfo

+ (NSURL *)smartURLForString:(NSString *)str
{
    NSURL *     result;
    NSString *  trimmedStr;
    NSRange     schemeMarkerRange;
    NSString *  scheme;
    
    assert(str != nil);
	
    result = nil;
    
    trimmedStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( (trimmedStr != nil) && (trimmedStr.length != 0) ) {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
        
        if (schemeMarkerRange.location == NSNotFound) {
            result = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@", trimmedStr]];
        } else {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme != nil);
            
            if ( ([scheme compare:@"ftp"  options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
                result = [NSURL URLWithString:trimmedStr];
            } else {
                // It looks like this is some unsupported URL scheme.
            }
        }
    }
    
    return result;
}


+ (uint64_t) getFTPStreamSize:(CFReadStreamRef)stream {
	return 0ll;
}


+ (NSString*) pathForDocument {
    NSString *s = [NSString stringWithFormat:@"%@/Library/Caches/",NSHomeDirectory()];
    //NSLog(@"%@",s);
    return s;
}

+ (uint64_t) getFileSize:(NSString *)filePath {
	NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![filePath isKindOfClass:[NSString class]]) {
        return 0;
    }
	NSDictionary  * dict = [fileManager attributesOfItemAtPath:filePath error:nil];
	return [dict fileSize];
}

+(void)createDir:(NSString*)s{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:s]) {
        [fileManager createDirectoryAtPath:s withIntermediateDirectories:YES attributes:nil error:nil];
    }
    fileManager = nil;
}

+(NSString*)getUUIDFileName:(NSString*)ext{
    NSString* s =[NSUUID UUID].UUIDString;
    s = [[s stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    NSString *fileName = [NSString stringWithFormat:@"%@.%@",s,ext];
    return [myTempFilePath stringByAppendingPathComponent:fileName];
}

+ (NSString *)getAttachImgFilePath:(NSString *)ext{
    NSString *s = [NSUUID UUID].UUIDString;
    s = [[s stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    NSString *filePath = [NSString stringWithFormat:@"%@%@.%@",myTempFilePath,s,ext];
    return filePath;
}

+ (NSString *)getComImgFileName:(NSString *)ext{
    NSString *s = [NSUUID UUID].UUIDString;
    s = [[s stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    NSString *fileName = [NSString stringWithFormat:@"%@%@/comImgs/%@.%@",docFilePath,g_myself.userId,s,ext];
    return fileName;
}

+ (void)deleteComImg{
    NSString *imgPath = [NSString stringWithFormat:@"%@%@/comImgs/comImg.png",docFilePath,g_myself.userId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:imgPath error:nil];
    }
}

+(void)deleleFileAndDir:(NSString*)s{
    NSString* dir=s;
    NSString* Path;
    
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:NULL];
    for (NSString *aPath in contentOfFolder) {
        Path = [dir stringByAppendingPathComponent:aPath];
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:Path isDirectory:&isDir])
        {
            if(isDir)
                [FileInfo deleleFileAndDir:Path];
            else{
                [[NSFileManager defaultManager] removeItemAtPath:Path error:nil];
                [[NSRunLoop currentRunLoop]runUntilDate:[NSDate distantPast]];//重要
            }
        }
    }
    contentOfFolder = nil;
}

+(NSMutableArray*)getFiles:(NSString*)s{
    NSMutableArray* a = [[NSMutableArray alloc] init];
    NSString* dir=s;
    NSString* Path;
    
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:NULL];
    for (NSString *aPath in contentOfFolder) {
        Path = [dir stringByAppendingPathComponent:aPath];
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:Path isDirectory:&isDir])
        {
            if(!isDir){
                [a addObject:Path];
            }
        }
    }
    contentOfFolder = nil;
    return a;
}

+(NSMutableArray *)getFilesName:(NSString *)s {
    NSMutableArray* a = [[NSMutableArray alloc] init];
    NSString* dir=s;
    NSString* Path;
    
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:NULL];
    for (NSString *aPath in contentOfFolder) {
        Path = [dir stringByAppendingPathComponent:aPath];
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:Path isDirectory:&isDir])
        {
            if(!isDir){
                [a addObject:[Path lastPathComponent]];
            }
        }
    }
    contentOfFolder = nil;
    return a;
}

//获取视频的总时长
+ (double )getVideoTimeFromVideo:(NSString *)video{
    NSURL* url;
    if( [video rangeOfString:@"http://"].location == NSNotFound && [video rangeOfString:@"https://"].location == NSNotFound)
        url = [NSURL fileURLWithPath:video];
    else
        url = [NSURL URLWithString:video];
    AVURLAsset *avurl = [AVURLAsset assetWithURL:url];
    CMTime time = [avurl duration];
    int alltime = ceil(time.value/time.timescale);
    return alltime;
}
//获取指定时间的帧数
+(UIImage *)getImagesFromVideo:(NSString *)video withTimeInterval:(double )time{
    NSURL* url;
    if( [video rangeOfString:@"http://"].location == NSNotFound && [video rangeOfString:@"https://"].location == NSNotFound)
        url = [NSURL fileURLWithPath:video];
    else
        url = [NSURL URLWithString:video];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    NSError *error = nil;
    CGImageRef cgImage = NULL;
    cgImage = [generator copyCGImageAtTime:CMTimeMakeWithSeconds(time, 600) actualTime:nil error:&error];
    if (!cgImage) {
        NSLog(@"获取视频第一帧图片失败:%@",error);
        return nil;
    }
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CFRelease(cgImage);
    return image;
}

+(UIImage*)getFirstImageFromVideo:(NSString*)video{
    NSString *filePath = [NSString stringWithFormat:@"%@%@.jpg",myTempFilePath,[[video lastPathComponent] stringByDeletingPathExtension]];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        return [UIImage imageWithContentsOfFile:filePath];

    NSURL* url;
    if( [video rangeOfString:@"http://"].location == NSNotFound && [video rangeOfString:@"https://"].location == NSNotFound)
        url = [NSURL fileURLWithPath:video];
    else
        url = [NSURL URLWithString:video];
    
    
    //获取视频的首帧作为缩略图
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    NSError *error = nil;
    CGImageRef cgImage = [generator copyCGImageAtTime:CMTimeMakeWithSeconds(0.8, 600) actualTime:nil error:&error];
    if (!cgImage) {
        NSLog(@"获取视频第一帧图片失败:%@",error);
        return [UIImage createImageWithColor:[UIColor blackColor]];
    }
    //保存图片到本地
    NSData * imageData = UIImageJPEGRepresentation([UIImage imageWithCGImage:cgImage], 1);
    NSError *imageerror =nil;
    BOOL isSuccess = [imageData writeToFile:filePath atomically:YES];
    if (!isSuccess) {
        NSLog(@"获取视频第一帧图片写入失败,%@",imageerror);
    }
    
    CFRelease(cgImage);
    
    return [UIImage imageWithCGImage:cgImage];
}

+(void)getFirstImageFromVideo:(NSString*)video imageView:(UIImageView*)iv{
    if (!video) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        UIImage * image=nil;
        image = [FileInfo getFirstImageFromVideo:video];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CGRect rect;//然后，将此部分从图片中剪切出来
            if (image.size.width > image.size.height) {
                rect = CGRectMake((image.size.width - image.size.height) / 2, 0, image.size.height, image.size.height);
            }else {
                rect = CGRectMake(0, (image.size.height - image.size.width) / 2, image.size.width, image.size.width);
            }
            
            CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
            
            UIImage *image1 = [UIImage imageWithCGImage:imageRef];
            
            if (imageRef) {
                CFRelease(imageRef);
            }
            
            iv.image = image1;
        });
    });
}

// 根据imageview大小剪裁图片
+(void)getFirstImageFromVideoWithImageVIew:(NSString *)video imageView:(UIImageView*)iv {
    if (!video) {
        return;
    }
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        UIImage * image=nil;
        image = [FileInfo getFirstImageFromVideo:video];
        dispatch_semaphore_signal(sem);
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            CGFloat scale = iv.frame.size.width / iv.frame.size.height;
            
            CGRect rect;//然后，将此部分从图片中剪切出来
            if ((image.size.width / image.size.height) > scale) {
                rect = CGRectMake((image.size.width - (image.size.height * scale)) / 2, 0, image.size.height * scale, image.size.height);
            }else {
                rect = CGRectMake(0, (image.size.height - (image.size.width / scale)) / 2, image.size.width, (image.size.width / scale));
            }
            
            CGImageRef imageRef = [image CGImage];
            
            imageRef = CGImageCreateWithImageInRect(imageRef, rect);
            
            UIImage *image1 = [UIImage imageWithCGImage:imageRef];
            
            iv.image = image1;
            
            if (imageRef) {
                CFRelease(imageRef);
            }
        });
    });
}

+(void)getFullFirstImageFromVideo:(NSString*)video imageView:(UIImageView*)iv{
    if (!video) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        UIImage * image=nil;
        image = [FileInfo getFirstImageFromVideo:video];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            iv.image = image;
        });
    });
}

+(double)getTimeLenFromVideo:(NSString*)video{
    NSURL* url;
    if( [video rangeOfString:@"http://"].location == NSNotFound && [video rangeOfString:@"https://"].location == NSNotFound)
        url = [NSURL fileURLWithPath:video];
    else
        url = [NSURL URLWithString:video];
    
    
    //获取视频的首帧作为缩略图
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSParameterAssert(asset);
    
    return asset.duration.value/asset.duration.timescale;
}

@end
