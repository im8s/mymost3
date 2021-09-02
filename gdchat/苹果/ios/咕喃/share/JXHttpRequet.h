//
//  JXHttpRequet.h
//  share
//
//  Created by 1 on 2019/3/21.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXNetwork.h"

#define act_UploadFile @"upload/UploadServlet" //上传文件
#define act_SendMsg    @"user/sendMsg" //发消息
#define act_MsgAdd @"b/circle/msg/add" //发送生活圈

@interface JXHttpRequet : NSObject

//上传文件
-(void)uploadFile:(NSString*)file validTime:(NSString *)validTime messageId:(NSString *)messageId toView:(id)toView;
// 发送消息
- (void)sendMsgToUserId:(NSString *)jid chatType:(int)chatType type:(int)type content:(NSString *)content fileName:(NSString *)fileName toView:(id)toView;
//发送生活圈
-(void)addMessage:(NSString*)text type:(int)type data:(NSDictionary*)dict flag:(int)flag  toView:(id)toView;


// 返回图片本地路径
- (NSString *)getDataUrlWithImage:(UIImage *)image;
// 返回视频本地路径
- (NSString *)getDataUrlWithVideo:(NSData *)video;

// 获取视频第一帧图片
-(UIImage*)getFirstImageFromVideo:(NSString*)video;
// 获取视频时长
- (CGFloat)getVideoLength:(NSURL *)url;
//压缩
- (NSString *)compressionVideoWithUlr:(NSURL *)url;

+ (instancetype)shareInstance;

@property (nonatomic, strong) NSString *access_token;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *apiUrl;
@property (nonatomic, strong) NSString *uploadUrl;
@property (nonatomic, assign) NSTimeInterval timeDifference;
@property (nonatomic, strong) NSString *httpKey;

@end

