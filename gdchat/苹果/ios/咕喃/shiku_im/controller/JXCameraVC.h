//
//  JXCameraVC.h
//  shiku_im
//
//  Created by p on 2017/11/6.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JXCameraVC;
@protocol JXCameraVCDelegate <NSObject>

- (void)cameraVC:(JXCameraVC *)vc didFinishWithImage:(UIImage *)image;
- (void)cameraVC:(JXCameraVC *)vc didFinishWithVideoPath:(NSString *)filePath timeLen:(NSInteger)timeLen;

@end

@interface JXCameraVC : UIViewController

@property (nonatomic, weak) id<JXCameraVCDelegate>cameraDelegate;


@property(nonatomic,assign) int maxTime;
@property(nonatomic,assign) int minTime;
@property(nonatomic,weak) id delegate;
@property(assign) SEL didRecord;
@property (nonatomic,strong) NSString* outputFileName;//返回的video


/**
 * isVideo  YES:开启视频录制,若不需要即不需赋值
 * isPhoto  YES:开启照片拍摄,若不需要即不需赋值
 * 若需要 视频录制、照片拍摄同时开启，即都不赋值
 */
@property (nonatomic, assign) BOOL isVideo;
@property (nonatomic, assign) BOOL isPhoto;


@end
