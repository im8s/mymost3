//
//  KKImageEditorViewController.h
//  WWImageEdit
//
//  Created by 邬维 on 2016/12/29.
//  Copyright © 2016年 kook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKImageToolInfo.h"
#import "PHAsset+RITLPhotos.h"

static NSString* const KTextEditDoneNotification = @"KTextEditDoneNotification";

@protocol KKImageEditorDelegate <NSObject>
@optional
- (void)imageDidFinishEdittingWithImage:(UIImage*)image asset:(PHAsset *)asset;

@end


@interface KKImageEditorViewController : UIViewController<UIScrollViewDelegate>{

    __weak UIScrollView *_scrollView; //readonly
}

@property (nonatomic, strong) UIImageView *imageView;   //显示的图片

@property (nonatomic, readonly) UIScrollView *scrollView; //图片的父视图，裁剪后大小会变化
@property (nonatomic, strong)  UIView *menuView;        //底部工具
@property (nonatomic,weak) id<KKImageEditorDelegate> delegate;

@property (nonatomic, strong) PHAsset *asset;  // 记录一下被编辑的图片


- (instancetype)initWithImage:(UIImage*)image delegate:(id<KKImageEditorDelegate>)delegate;



- (void)fixZoomScaleWithAnimated:(BOOL)animated;
- (void)resetZoomScaleWithAnimated:(BOOL)animated;

@end
