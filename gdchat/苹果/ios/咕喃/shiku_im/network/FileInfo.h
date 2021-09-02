//
//  FileInfo.h
//  iPhoneFTP
//
//  Created by Zhou Weikuan on 10-6-15.
//  Copyright 2010 sino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileInfo : NSObject {

}

+ (NSURL *)smartURLForString:(NSString *)str;
+ (uint64_t) getFTPStreamSize:(CFReadStreamRef)stream;

+ (NSString*) pathForDocument;
+ (uint64_t) getFileSize:(NSString *)filePath;

+(void)createDir:(NSString*)s;
+(NSString*)getUUIDFileName:(NSString*)ext;
+(void)deleleFileAndDir:(NSString*)s;
+(NSMutableArray*)getFiles:(NSString*)s;
+(NSMutableArray*)getFilesName:(NSString*)s;
+ (NSString *)getAttachImgFilePath:(NSString *)ext;
+ (NSString *)getComImgFileName:(NSString *)ext;
+ (void)deleteComImg;

+ (double )getVideoTimeFromVideo:(NSString *)video;//获取视频总时长
+(UIImage *)getImagesFromVideo:(NSString *)video withTimeInterval:(double )time;//根据视频间隔取帧

+(UIImage*) getFirstImageFromVideo:(NSString*)video;
// 被裁剪后的第一帧图片
+(void)getFirstImageFromVideo:(NSString*)video imageView:(UIImageView*)iv;
// 根据imageview大小剪裁图片
+(void)getFirstImageFromVideoWithImageVIew:(NSString *)video imageView:(UIImageView*)iv;
// 完整的第一帧图片
+(void)getFullFirstImageFromVideo:(NSString*)video imageView:(UIImageView*)iv;

+(double)getTimeLenFromVideo:(NSString*)video;
@end
