//
//  JXHttpRequet.m
//  share
//
//  Created by 1 on 2019/3/21.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXHttpRequet.h"
#import "JXCustomShareVC.h"

@interface JXHttpRequet ()<JXNetworkDelegate>
@property (nonatomic, strong) NSString *urlPath;

@end


@implementation JXHttpRequet
static JXHttpRequet *_httpRequet = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _httpRequet = [[JXHttpRequet alloc] init];
    });
    return _httpRequet;
}


- (instancetype)init {
    if (self = [super init]) {
        self.access_token = [share_defaults objectForKey:kMY_ShareExtensionToken];
        self.userId = [share_defaults objectForKey:kMY_ShareExtensionUserId];
        self.apiUrl = [share_defaults objectForKey:kApiUrl];
        self.uploadUrl = [share_defaults objectForKey:kUploadUrl];
        self.timeDifference = [[share_defaults objectForKey:kShare_timeDifference] doubleValue];
        self.httpKey = [share_defaults objectForKey:kMY_ShareExtensionHttpKey];
    }
    return self;
}

//上传文件到服务器（传路径）
-(void)uploadFile:(NSString*)file validTime:(NSString *)validTime messageId:(NSString *)messageId toView:(id)toView{
    if(!file)
        return;
    if(![[NSFileManager defaultManager] fileExistsAtPath:file])
        return;
    
    JXNetwork* p = [self addTask:act_UploadFile param:nil toView:toView];

    [p setPostValue:self.userId forKey:@"userId"];
    if (!validTime) {
        validTime = @"-1";
    }
    [p setPostValue:validTime forKey:@"validTime"];
    [p setData:[NSData dataWithContentsOfFile:file] forKey:[file lastPathComponent] messageId:nil];
    p.userData = [file lastPathComponent];
    p.messageId = messageId;
    [p go];
}


// 发送消息
- (void)sendMsgToUserId:(NSString *)jid chatType:(int)chatType type:(int)type content:(NSString *)content fileName:(NSString *)fileName toView:(id)toView{
    JXNetwork* p = [self addTask:act_SendMsg param:nil toView:toView];
    [p setPostValue:jid forKey:@"jid"];
    [p setPostValue:[NSNumber numberWithInt:chatType] forKey:@"chatType"];
    [p setPostValue:[NSNumber numberWithInt:type] forKey:@"type"];
    [p setPostValue:content forKey:@"content"];
    [p setPostValue:fileName forKey:@"fileName"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    
    [p go];
}


// 发送生活圈
-(void)addMessage:(NSString*)text type:(int)type data:(NSDictionary*)dict flag:(int)flag toView:(id)toView{
    NSMutableArray* array;
    
    NSString * jsonFiles=nil;
    //    NSMutableArray* a=[[NSMutableArray alloc]init];
    SBJsonWriter * OderJsonwriter = [SBJsonWriter new];
    
    array = [dict objectForKey:@"images"];
    NSString * jsonImages = nil;
    if([array count]>0){
        [self doCheckUploadResult:array];
        jsonImages = [OderJsonwriter stringWithObject:array];
        jsonFiles = jsonImages;
    }
    
    array = [dict objectForKey:@"videos"];
    NSString * jsonVideos=nil;
    if([array count]>0){
        [self doCheckUploadResult:array];
        jsonVideos = [OderJsonwriter stringWithObject:array];
        jsonFiles = jsonVideos;
        //        for(int i =0;i<[array count];i++)
        //            [a addObject:[[array objectAtIndex:i] objectForKey:@"oUrl"]];
        //        jsonVideos = [OderJsonwriter stringWithObject:a];
    }
    
    array = [dict objectForKey:@"audios"];
    NSString * jsonAudios=nil;
    if([array count]>0){
        [self doCheckUploadResult:array];
        jsonAudios = [OderJsonwriter stringWithObject:array];
        jsonFiles = jsonAudios;
        //        for(int i =0;i<[array count];i++)
        //            [a addObject:[[array objectAtIndex:i] objectForKey:@"oUrl"]];
        //        jsonAudios = [OderJsonwriter stringWithObject:a];
    }
    
    array = [dict objectForKey:@"files"];
    if([array count]>0){
        [self doCheckUploadResult:array];
        jsonFiles = [OderJsonwriter stringWithObject:array];
        //        for(int i =0;i<[array count];i++)
        //            [a addObject:[[array objectAtIndex:i] objectForKey:@"oUrl"]];
        //        jsonAudios = [OderJsonwriter stringWithObject:a];
    }
    
    
    array = nil;
    
    JXNetwork* p = [self addTask:act_MsgAdd param:nil toView:toView];
    [p setPostValue:[NSNumber numberWithInt:type] forKey:@"type"];
    [p setPostValue:[NSNumber numberWithInt:flag] forKey:@"flag"];
//    [p setPostValue:[NSNumber numberWithInt:visible] forKey:@"visible"];
    [p setPostValue:[NSNumber numberWithInt:1] forKey:@"cityId"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:text forKey:@"text"];
    if (type == 5) {
        [p setPostValue:jsonFiles forKey:@"files"];
    }else if (type == 6) {
        [p setPostValue:[dict objectForKey:@"sdkUrl"] forKey:@"sdkUrl"];
        [p setPostValue:[dict objectForKey:@"sdkIcon"] forKey:@"sdkIcon"];
        [p setPostValue:[dict objectForKey:@"sdkTitle"] forKey:@"sdkTitle"];
    }
    else {
        [p setPostValue:jsonImages forKey:@"images"];
        [p setPostValue:jsonAudios forKey:@"audios"];
        [p setPostValue:jsonVideos forKey:@"videos"];
    }
//    [p setPostValue:myself.model forKey:@"model"];
//    [p setPostValue:myself.osVersion forKey:@"osVersion"];
//    [p setPostValue:myself.serialNumber forKey:@"serialNumber"];
//    [p setPostValue:lable forKey:@"lable"];
//
//    if (location.length > 0) {
//        [p setPostValue:[NSNumber numberWithDouble:coor.latitude] forKey:@"latitude"];
//        [p setPostValue:[NSNumber numberWithDouble:coor.longitude] forKey:@"longitude"];
//        [p setPostValue:location forKey:@"location"];
//    }
    
//    if (lookArray.count >0 && (visible == 3 || visible == 4)) {
//        NSString * lookStr = [lookArray componentsJoinedByString:@","];
//        NSString * arrayTitle = nil;
//        switch (visible) {
//            case 3:
//                arrayTitle = @"userLook";
//                break;
//            case 4:
//                arrayTitle = @"userNotLook";
//                break;
//            default:
//                arrayTitle = @"";
//                break;
//        }
//        [p setPostValue:lookStr forKey:arrayTitle];
//    }
    
//    if (remindArray.count > 0) {
//        [p setPostValue:[remindArray componentsJoinedByString:@","] forKey:@"userRemindLook"];
//    }
    
    [p go];
}

-(void)doCheckUploadResult:(NSMutableArray*)a{
    NSMutableDictionary* p;
    for(NSInteger i=[a count]-1;i>=0;i--){
        p = [a objectAtIndex:i];
        if([[p objectForKey:@"status"]intValue]!=1){
            [a removeObjectAtIndex:i];
            continue;
        }
        [p removeObjectForKey:@"status"];

    }
}


-(JXNetwork*)addTask:(NSString*)action param:(id)param toView:(id)delegate{
    if([action length]<=0)
        return nil;
    if(param==nil)
        param = @"";
    
    NSString* url=nil;
    NSString* s=@"";
    
    JXNetwork *task = [[JXNetwork alloc] init];
    
    if([action rangeOfString:@"http://"].location == NSNotFound){
        if([action isEqualToString:act_UploadFile]){
            s = self.uploadUrl;
        }else {
            NSRange range = [self.apiUrl rangeOfString:@"config"];
            if (range.location != NSNotFound) {
                s = [self.apiUrl substringToIndex:range.location];
            }else {
                s = self.apiUrl;
            }
        }
    }
    url = [NSString stringWithFormat:@"%@%@%@",s,action,param];
    
    task.url = url;
    task.param = param;
    task.delegate = self;
    task.action = action;
    task.toView  = delegate;
    //    [url1 release];
    
    if([task.toView respondsToSelector:@selector(didServerNetworkStart:)])
        [task.toView didServerNetworkStart:task];
    
    if([task isImage] || [task isAudio] || [task isVideo])
        [task go];
    
//    [_arrayConnections addObject:task];
    //    [task release];
    return task;
}


- (void)requestSuccess:(JXNetwork *)task {
    
    @autoreleasepool {
        NSString* string = task.responseData;
        //    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSString* error=nil;
        
        SBJsonParser * resultParser = [[SBJsonParser alloc] init] ;
        NSDictionary *resultObject = [resultParser objectWithString:string];
        //    id resultObject = [resultParser objectWithData:task.responseData];
        //    [resultParser release];
        
        if( [resultObject isKindOfClass:[NSDictionary class]] ){
            int resultCode = [[resultObject objectForKey:@"resultCode"] intValue];
            if(resultCode != 1)
            {
                error = [resultObject objectForKey:@"resultMsg"];
                if([error length]<=0)
                    error = @"出错拉";
            }
        }else{
            error = @"不能识别返回值";
            if([string length]>=6){
                if([[string substringToIndex:6] isEqualToString:@"<html>"])
                    error = @"服务器好像有点问题";
            }
        }
        
        if(error){
            [self doError:task dict:resultObject resultMsg:string errorMsg:error];
        }else{
            NSLog(@"%@成功:%@",task.action,string);
            resultObject = [resultObject objectForKey:@"data"];
            NSDictionary * dict = nil;
            NSArray* array = nil;
            
            if( [resultObject isKindOfClass:[NSDictionary class]] )
                dict  = resultObject;
            if( [resultObject isKindOfClass:[NSArray class]] )
                array = resultObject;
            
            if( [task.toView respondsToSelector:@selector(didServerNetworkResultSucces:dict:array:)] )
                [task.toView didServerNetworkResultSucces:task dict:dict array:array];
            
            dict = nil;
            array = nil;
        }
        resultObject = nil;
        //    [pool release];
//        [_arrayConnections removeObject:task];
    }
}


- (void)requestError:(JXNetwork *)task {
    if([task.toView respondsToSelector:@selector(didServerNetworkError:error:)] ){
        [task.toView didServerNetworkError:task error:task.error];
    }
}


-(void) doError:(JXNetwork*)task dict:(NSDictionary*)dict resultMsg:(NSString*)string errorMsg:(NSString*)errorMsg{

    if ([task.toView respondsToSelector:@selector(didServerNetworkResultFailed:dict:)])
        [task.toView didServerNetworkResultFailed:task dict:dict];
}



- (NSString *)getDataUrlWithImage:(UIImage *)image {
    NSData *data = UIImagePNGRepresentation(image);
    
    NSString *fileName = [self generateUUID];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *groupURL = [manager containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID];
    NSString *filePath = [NSString stringWithFormat:@"%@.jpg",fileName];
    NSURL *fileURL = [groupURL URLByAppendingPathComponent:filePath];
    NSString *path = [fileURL.absoluteString substringFromIndex:7];
    [data writeToFile:path atomically:YES];
    
    return path;
}

- (NSString *)getDataUrlWithVideo:(NSData *)video {
    
    NSString *fileName = [self generateUUID];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *groupURL = [manager containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID];
    NSString *filePath = [NSString stringWithFormat:@"%@.mp4",fileName];
    NSURL *fileURL = [groupURL URLByAppendingPathComponent:filePath];
    NSString *path = [fileURL.absoluteString substringFromIndex:7];
    [video writeToFile:path atomically:YES];
    
    return path;
}


- (NSString *)generateUUID
{
    return [NSUUID UUID].UUIDString;
}


-(UIImage*)getFirstImageFromVideo:(NSString*)video {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *groupURL = [manager containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID];
    NSString *path = [groupURL.absoluteString substringFromIndex:7];
    
    NSString *filePath = [NSString stringWithFormat:@"%@%@.jpg",path,[[video lastPathComponent] stringByDeletingPathExtension]];
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
        return nil;
    }
    //保存图片到本地
    NSData * imageData = UIImageJPEGRepresentation([UIImage imageWithCGImage:cgImage], 1);
    NSError *imageerror =nil;
    BOOL isSuccess = [imageData writeToFile:filePath atomically:YES];
    if (!isSuccess) {
        NSLog(@"获取视频第一帧图片写入失败,%@",imageerror);
    }
    
    return [UIImage imageWithCGImage:cgImage];
}
// 获取视频时长
- (CGFloat)getVideoLength:(NSURL *)url{
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:url];
    CMTime time = [avUrl duration];
    int second = ceil(time.value/time.timescale);
    return second;
}

//压缩
- (NSString *)compressionVideoWithUlr:(NSURL *)url{
//    NSLog(@"压缩前大小 %f MB",[self fileSize:url]);

    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *groupURL = [manager containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID];
    NSString *fileName = [self generateUUID];
    
    NSString* path1 = [[groupURL.absoluteString substringFromIndex:7] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",fileName]];

    
    NSString *bakPath= path1; //新路径不能存在文件 如果存在是不能压缩成功的
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPreset1280x720];
    exportSession.outputURL = [NSURL fileURLWithPath:bakPath];
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse= YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
//         BOOL goToUploadFile=NO;
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"AVAssetExportSessionStatusCancelled");
                 break;
             case AVAssetExportSessionStatusUnknown:
                 NSLog(@"AVAssetExportSessionStatusUnknown");
                 break;
             case AVAssetExportSessionStatusWaiting:
                 NSLog(@"AVAssetExportSessionStatusWaiting");
                 break;
             case AVAssetExportSessionStatusExporting:
                 NSLog(@"AVAssetExportSessionStatusExporting");
                 break;
             case AVAssetExportSessionStatusCompleted:{
                //压缩成功
                 self.urlPath = bakPath;
             }
                 break;
             case AVAssetExportSessionStatusFailed:
             {
                 NSError *error=exportSession.error;
                 if (error) {
                     
                 }
             }
                 
                 break;
             default:
                 
                 break;
         }
         
     }];
    if (self.urlPath.length > 0) {
        return self.urlPath;
    }
    return nil;
}

//计算压缩大小
- (CGFloat)fileSize:(NSURL *)path
{
    return [[NSData dataWithContentsOfURL:path] length]/1024.00 /1024.00;
}


@end
