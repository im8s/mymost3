//
//  JXConnection.m
//  JXConnection
//
//  Created by Hao Tan on 11-11-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "JXConnection.h"
#import "AppDelegate.h"
#import "MD5Util.h"
//#import "NSDataEx.h"


//#define MULTIPART @"multipart/form-data; boundary=------------0x0x0x0x0x0x0x0x"
//#define MULTIPART @"multipart/form-data"
//#define MULTIPART @"application/x-www-form-urlencoded"

#define UploadDefultTimeout     60
#define NormalDefultTimeout     15

@interface JXConnection ()
@property (nonatomic, strong) NSMutableDictionary *uploadDataDic;
@property (nonatomic, strong) AFHTTPSessionManager *httpManager;
@property (nonatomic, assign) BOOL isUpload;

@end

@implementation JXConnection

@synthesize action;
@synthesize toView;
@synthesize downloadFile;


static AFHTTPSessionManager *afManager;

-(AFHTTPSessionManager *)sharedHttpSessionManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        afManager = [AFHTTPSessionManager manager];
        afManager.requestSerializer.timeoutInterval = 10.0;
    });
    
    return afManager;
}

- (id) init {
    if (self = [super init]) {
        self.params = [NSMutableDictionary dictionary];
        self.uploadDataDic = [NSMutableDictionary dictionary];
        self.httpManager = [self sharedHttpSessionManager];
        self.httpManager.requestSerializer = [AFHTTPRequestSerializer serializer];// 请求
        self.httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];// 响应
//        self.httpManager.requestSerializer.timeoutInterval = jx_connect_timeout;
    }
    
    return self;
}

-(void)dealloc{
//    NSLog(@"JXConnection.dealloc:%@=%d",action,self.retainCount);
    self.action = nil;
    self.toView = nil;
//    self.userInfo = nil;
    self.delegate = nil;
    self.url = nil;
    self.param = nil;
    self.params = nil;
    self.uploadDataDic = nil;
    self.downloadFile = nil;
//    [self.httpManager release];
//    
//    [super dealloc];
}

-(BOOL)isImage{
    return [action rangeOfString:@".jpg"].location != NSNotFound || [action rangeOfString:@".png"].location != NSNotFound || [action rangeOfString:@".gif"].location != NSNotFound;
}

-(BOOL)isVideo{
    NSString* s = [action lowercaseString];
    BOOL b = [s rangeOfString:@".mp4"].location != NSNotFound
    || [s rangeOfString:@".qt"].location != NSNotFound
    || [s rangeOfString:@".mpg"].location != NSNotFound
    || [s rangeOfString:@".mov"].location != NSNotFound
    || [s rangeOfString:@".avi"].location != NSNotFound;
    return b;
}

-(BOOL)isAudio{
    NSString* s = [action lowercaseString];
    return [s rangeOfString:@".mp3"].location != NSNotFound || [s rangeOfString:@".amr"].location != NSNotFound|| [s rangeOfString:@".wav"].location != NSNotFound;
}

-(void)go{
    
    if([self isImage] || [self isVideo] || [self isAudio]) {
        self.isUpload = NO;
        [self downloadRequestData];
        
    }else {
        
        [self setPostValue:g_constant.sysLanguage forKey:@"language"];
        
        if (self.uploadDataDic.count > 0) {
            self.isUpload = YES;
            [self getSecret];
            [self upLoadRequestData];
        }else {
            self.isUpload = NO;
            [self getSecret];
            [self normalRequestData];
        }
    }
}

// 普通网络请求
- (void) normalRequestData {
    
    if (self.timeout && self.timeout > 0) {
        self.httpManager.requestSerializer.timeoutInterval = self.timeout;
    }else {
        self.httpManager.requestSerializer.timeoutInterval = NormalDefultTimeout;
    }
    
    NSMutableString *urlStr = [NSMutableString string];
    if (YES) {
        NSRange range = [self.url rangeOfString:@"?"];
        if (range.location == NSNotFound) {
            
            urlStr = [NSMutableString stringWithFormat:@"%@?",self.url];
        }else{
            urlStr = [self.url mutableCopy];
        }
        for (NSString *key in self.params.allKeys) {
            NSString *str = [NSString stringWithFormat:@"&%@=%@",key, self.params[key]];
            [urlStr appendString:str];
        }
        NSLog(@"urlStr = %@", urlStr);
    }
    
    urlStr = [[urlStr stringByReplacingOccurrencesOfString:@" " withString:@""] copy];
    
    if ([self.action isEqualToString:act_Config]) {
        [self.httpManager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            // 转码
            NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            self.responseData = string;
            NSLog(@"requestSuccess");
            if ([self.delegate respondsToSelector:@selector(requestSuccess:)]) {
                [self.delegate requestSuccess:self];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@:requestFailed",self.url);
            self.error = error;
            if ([self.delegate respondsToSelector:@selector(requestError:)]) {
                [self.delegate requestError:self];
            }
        }];
    }else {
        [self.httpManager POST:self.url parameters:self.params progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            
            // 转码
            NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            self.responseData = string;
            NSLog(@"requestSuccess");
            if ([self.delegate respondsToSelector:@selector(requestSuccess:)]) {
                [self.delegate requestSuccess:self];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@:requestFailed",self.url);
            self.error = error;
            if ([self.delegate respondsToSelector:@selector(requestError:)]) {
                [self.delegate requestError:self];
            }
            
        }];
    }
}

// 上传
- (void) upLoadRequestData{
    
    if (self.timeout && self.timeout > 0) {
        self.httpManager.requestSerializer.timeoutInterval = self.timeout;
    }else {
        NSUInteger dataLength = 0;
        for (NSString *key in self.uploadDataDic.allKeys) {
            NSData *data = self.uploadDataDic[key];
            dataLength = dataLength + data.length;
        }
        NSUInteger timeOut = dataLength / 1024 / 20;
        if (timeOut > UploadDefultTimeout) {
            self.httpManager.requestSerializer.timeoutInterval = timeOut;
        }else {
            self.httpManager.requestSerializer.timeoutInterval = UploadDefultTimeout;
        }
    }
    
    self.httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"image/png",
                                                         @"image/gif",
                                                         @"application/octet-stream",
                                                         @"text/json",
                                                         @"video/mp4",
                                                         @"video/quicktime",
                                                         nil];
    
    //上传图片/文字，只能同POST
    [self.httpManager POST:self.url parameters:self.params constructingBodyWithBlock:^(id  _Nonnull formData) {
        // 上传文件
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        for (NSString *key in self.uploadDataDic.allKeys) {
            NSData *data = self.uploadDataDic[key];
            NSString *mimeType = [self getUploadDataMimeType:key];
            [formData appendPartWithFileData:data name:key fileName:key mimeType:mimeType];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"---------- uploadProgress = %@",uploadProgress);
        if (self.messageId.length > 0) {
            [g_notify postNotificationName:kUploadFileProgressNotifaction object:@{@"uploadProgress":uploadProgress,@"file":self.messageId}];
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@, task = %@",responseObject,task);
        
        
        // 转码
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        self.responseData = string;
        
        NSLog(@"requestSuccess");
        if ([self.delegate respondsToSelector:@selector(requestSuccess:)]) {
            [self.delegate requestSuccess:self];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
        self.error = error;
        if ([self.delegate respondsToSelector:@selector(requestError:)]) {
            [self.delegate requestError:self];
        }
    }];
}

// 下载
- (void) downloadRequestData {

    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *urlManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:conf];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.action]];
    NSURLSessionDownloadTask *task = [urlManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
//        NSLog(@"文件下载进度:%lld/%lld",downloadProgress.completedUnitCount,downloadProgress.totalUnitCount);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[targetPath lastPathComponent]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error ---- %@", error);
            self.error = error;
            if ([self.delegate respondsToSelector:@selector(requestError:)]) {
                [self.delegate requestError:self];
            }
        }else {
            NSLog(@"downloadSuccess");
            NSString *downloadPath = [NSString stringWithFormat:@"%@", filePath];
            NSData *data = [NSData dataWithContentsOfURL:filePath];
            self.responseData = data;
            if ([self.delegate respondsToSelector:@selector(requestSuccess:)]) {
                [self.delegate requestSuccess:self];
            }
            
            [[NSFileManager defaultManager] removeItemAtPath:downloadPath error:nil];
        }
    }];
    
    [task resume];
//    [urlManager release];
}

// 返回上传数据类型
- (NSString *) getUploadDataMimeType:(NSString *) key {
    NSString *mimeType = nil;
    key = [key lowercaseString];
    if ([key rangeOfString:@".jpg"].location != NSNotFound || [key rangeOfString:@"image"].location != NSNotFound) {
        mimeType = @"image/jpeg";
    }else if ([key rangeOfString:@".png"].location != NSNotFound) {
        mimeType = @"image/png";
        
    }else if ([key rangeOfString:@".mp3"].location != NSNotFound) {
        mimeType = @"audio/mpeg";
        
    }else if ([key rangeOfString:@".qt"].location != NSNotFound) {
        mimeType = @"video/quicktime";
        
    }else if ([key rangeOfString:@".mp4"].location != NSNotFound) {
        mimeType = @"video/mp4";
        
    }else if ([key rangeOfString:@".amr"].location != NSNotFound) {
        mimeType = @"audio/amr";
    }else if ([key rangeOfString:@".gif"].location != NSNotFound) {
        mimeType = @"image/gif";
    }else if ([key rangeOfString:@".mov"].location != NSNotFound) {
        mimeType = @"video/quicktime";
    }else if ([key rangeOfString:@".wav"].location != NSNotFound) {
        mimeType = @"audio/wav";
    }else {
        mimeType = @"";
    }
    
    return mimeType;
}

- (void)stop{
//    [self clearDelegatesAndCancel];
    AFHTTPSessionManager *manager = [self sharedHttpSessionManager];
    [manager.operationQueue cancelAllOperations];
}

- (void)setData:(NSData *)data forKey:(NSString *)key messageId:(NSString *)messageId
{
    if(data==nil)
        return;
    [self.uploadDataDic setObject:data forKey:key];
    self.messageId = messageId;
    self.uploadDataSize = data.length;
}

- (void)setPostValue:(id <NSObject>)value forKey:(NSString *)key
{
    if(value==nil)
        return;
    [self.params setObject:value forKey:key];
}
// 接口加密
- (NSString *)getSecret {
    
    if (!g_server.saltDic) {
        g_server.saltDic = [NSMutableDictionary dictionary];
    }
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    long time=[date timeIntervalSince1970]*1000;
    time = (time + g_server.timeDifference);

    NSString *salt = [NSString stringWithFormat:@"%ld",time];
    
    if (self.action) {
        NSString *action = [g_server.saltDic objectForKey:salt];
        if (action && [action isEqualToString:self.action]) {
            time += 1;
            salt = [NSString stringWithFormat:@"%ld",time];
        }
        [g_server.saltDic setObject:self.action forKey:salt];
    }
    
    if (self.params[@"salt"])
        salt = self.params[@"salt"];
    
    if (self.params[@"access_token"]) {
        
        NSMutableString *macStr = [NSMutableString string];
        [macStr appendString:APIKEY];
        [macStr appendString:MY_USER_ID];
        [macStr appendString:g_server.access_token];
        NSString *paramStr = [self getParamStr];
        [macStr appendString:paramStr];
        [macStr appendString:salt];
        
        NSData *keyData = [[NSData alloc] initWithBase64EncodedString:g_server.httpKey options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSData *macData = [g_securityUtil getHMACMD5:[macStr dataUsingEncoding:NSUTF8StringEncoding] key:keyData];
        
        NSString *secret = [macData base64EncodedStringWithOptions:0];
        if (!self.params[@"salt"]) {
            [self setPostValue:salt forKey:@"salt"];
        }
        [self setPostValue:secret forKey:@"secret"];
        
        return secret;
    }else {
        
        NSMutableString *macStr = [NSMutableString string];
        [macStr appendString:APIKEY];
        NSString *paramStr = [self getParamStr];
        [macStr appendString:paramStr];
        [macStr appendString:salt];
        
        NSData *macData = [g_securityUtil getHMACMD5:[macStr dataUsingEncoding:NSUTF8StringEncoding] key:[MD5Util getMD5DataWithString:APIKEY]];
        NSString *secret = [macData base64EncodedStringWithOptions:0];
        
        if (!self.params[@"salt"]) {
            [self setPostValue:salt forKey:@"salt"];
        }
        if ([self.action isEqualToString:act_Config]) {
            secret = (NSString *)
            CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                      (CFStringRef)secret,
                                                                      NULL,
                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                      kCFStringEncodingUTF8));
        }
        
        [self setPostValue:secret forKey:@"secret"];
        
        return secret;
    }
    
}

- (NSString *)getParamStr {
    NSMutableString *paramStr = [NSMutableString string];
    NSArray *keys = [[self.params allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (NSInteger i = 0; i < keys.count; i ++) {
        NSString *key = keys[i];
        if ([key isEqualToString:@"salt"]) {
            continue;
        }
        if ([key isEqualToString:@"access_token"]) {
            continue;
        }
        NSString *value = self.params[key];
        if ([self.params[key] isKindOfClass:[NSNumber class]]) {
            NSNumber *num = self.params[key];
            value = [num stringValue];
        }
        [paramStr appendString:value];
        [self.params setObject:value forKey:key];
    }
    return paramStr;
}

// 接口加密
//- (NSString *)getSecret {
//
//    // 提现/发红包/转账/扫码支付/网页支付另做处理
//    if ([self.action isEqualToString:act_TransferWXPay] ||  [self.action isEqualToString:act_sendRedPacket] || [self.action isEqualToString:act_sendRedPacketV1] ||[self.action isEqualToString:act_OpenAuthInterface] || [self.action isEqualToString:act_alipayTransfer] || [self.action isEqualToString:act_sendTransfer] || [self.action isEqualToString:act_codePayment] || [self.action isEqualToString:act_codeReceipt] || [self.action isEqualToString:act_PayPasswordPayment]) {
//        return nil;
//    }
//
//    long time = (long)[[NSDate date] timeIntervalSince1970];
//    time = (time *1000 + g_server.timeDifference)/1000;
//    [self setPostValue:[NSString stringWithFormat:@"%ld",time] forKey:@"time"];
//
//    NSString *secret;
//    if ( [self.action isEqualToString:act_sendRedPacket]) {
//
////        NSMutableString *str1 = [NSMutableString string];
////        [str1 appendString:APIKEY];
////        [str1 appendString:[NSString stringWithFormat:@"%ld",time]];
////        str1 = [[g_server getMD5String:str1] mutableCopy];
////
////        [str1 appendString:g_myself.userId];
////        [str1 appendString:g_server.access_token];
////        str1 = [[g_server getMD5String:str1] mutableCopy];
////
////        secret = [str1 copy];
//
//    }else if([self.action isEqualToString:act_getSign] || [self.action isEqualToString:act_openRedPacket] || [self.action isEqualToString:act_receiveTransfer]) {
//        NSMutableString *str1 = [NSMutableString string];
//        [str1 appendString:APIKEY];
//        [str1 appendString:[NSString stringWithFormat:@"%ld",time]];
//        str1 = [[g_server getMD5String:str1] mutableCopy];
//
//        [str1 appendString:g_myself.userId];
//        [str1 appendString:g_server.access_token];
//        str1 = [[g_server getMD5String:str1] mutableCopy];
//
//        secret = [str1 copy];
//    } else {
//
//        NSMutableString *str1 = [NSMutableString string];
//        [str1 appendString:APIKEY];
//        [str1 appendString:[NSString stringWithFormat:@"%ld",time]];
//
//        if (((IsStringNull(g_myself.userId) || IsStringNull(g_server.access_token) || !g_server.isLogin || self.isUpload) && ![self.action isEqualToString:act_userLoginAuto]) || [self.action isEqualToString:act_GetWxOpenId] || [self.action isEqualToString:act_thirdLogin]) {
//            secret = [g_server getMD5String:str1];
//        }else {
//            [str1 appendString:g_myself.userId];
//            [str1 appendString:g_server.access_token];
//            secret = [g_server getMD5String:str1];
//        }
//
//    }
//
//    [self setPostValue:secret forKey:@"secret"];
//
//    return secret;
//}

@end
