//
//  PhotoView.m
//  ImageBrowser
//
//  Created by msk on 16/9/1.
//  Copyright © 2016年 msk. All rights reserved.
//

#import "PhotoView.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"

@interface PhotoView ()<UIScrollViewDelegate>{

    MBProgressHUD *HUD;
}

@end

@implementation PhotoView

-(id)initWithFrame:(CGRect)frame withPhotoUrl:(NSString *)photoUrl{
    self = [super initWithFrame:frame];
    if (self) {
            //添加图片
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        NSURL *url;
        if (![photoUrl hasPrefix:@"http"]) {
            url = [NSURL fileURLWithPath:photoUrl];
        }else{
            url = [NSURL URLWithString:photoUrl];
        }
        
        HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
        HUD.mode = MBProgressHUDModeDeterminate;

        [manager loadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
            HUD.progress = ((float)receivedSize)/expectedSize;

        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (cacheType == SDImageCacheTypeDisk || cacheType == SDImageCacheTypeMemory) {
                UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:url.absoluteString];
                self.imageView.frame=[self caculateOriginImageSizeWith:cachedImage];
                self.imageView.image=cachedImage;
                if ([photoUrl rangeOfString:@".gif"].location != NSNotFound) {
                    
                    HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
                    HUD.mode = MBProgressHUDModeDeterminate;
                    
                    [self loadAnimatedImageWithURL:[NSURL URLWithString:photoUrl] completion:^(FLAnimatedImage *animatedImage) {
                        self.imageView.animatedImage = animatedImage;
                        NSLog(@"图片加载完成");
                        [HUD hide:YES];
                    }];
                    
                }
            }else {
                [self.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"ic-zanwu@3x"] options:0 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    self.imageView.frame=[self caculateOriginImageSizeWith:image];
                    NSLog(@"图片加载完成");
                    if ([photoUrl rangeOfString:@".gif"].location != NSNotFound) {
                        
                        HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
                        HUD.mode = MBProgressHUDModeDeterminate;
                        
                        [self loadAnimatedImageWithURL:url completion:^(FLAnimatedImage *animatedImage) {
                            self.imageView.animatedImage = animatedImage;
                            NSLog(@"图片加载完成");
                            [HUD hide:YES];
                        }];
                        
                    }
                }];
                
            }
        }];
        
//        [manager cachedImageExistsForURL:url completion:^(BOOL isInCache) {
//            if (!isInCache) {//没有缓存
//                HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
//                HUD.mode = MBProgressHUDModeDeterminate;
//
//
//                [self.imageView sd_setImageWithPreviousCachedImageWithURL:url placeholderImage:[UIImage imageNamed:@"ic-zanwu@3x"] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//                    HUD.progress = ((float)receivedSize)/expectedSize;
//                } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//                    self.imageView.frame=[self caculateOriginImageSizeWith:image];
//                    NSLog(@"图片加载完成");
//                    if ([photoUrl rangeOfString:@".gif"].location != NSNotFound) {
//
//                        HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
//                        HUD.mode = MBProgressHUDModeDeterminate;
//
//                        [self loadAnimatedImageWithURL:url completion:^(FLAnimatedImage *animatedImage) {
//                            self.imageView.animatedImage = animatedImage;
//                            NSLog(@"图片加载完成");
//                            [HUD hide:YES];
//                        }];
//
//                    }
//                    if (!isInCache) {
//                        [HUD hide:YES];
//                    }
//                }];
//            }else{//直接取出缓存的图片，减少流量消耗
//                UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:url.absoluteString];
//                self.imageView.frame=[self caculateOriginImageSizeWith:cachedImage];
//                self.imageView.image=cachedImage;
//                if ([photoUrl rangeOfString:@".gif"].location != NSNotFound) {
//
//                    HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
//                    HUD.mode = MBProgressHUDModeDeterminate;
//
//                    [self loadAnimatedImageWithURL:[NSURL URLWithString:photoUrl] completion:^(FLAnimatedImage *animatedImage) {
//                        self.imageView.animatedImage = animatedImage;
//                        NSLog(@"图片加载完成");
//                        [HUD hide:YES];
//                    }];
//
//                }
//            }
//        }];
        
        
        
        
//        BOOL isCached = [manager cachedImageExistsForURL:[NSURL URLWithString:photoUrl]];
        
    }
    return self;
}
- (void)loadAnimatedImageWithURL:(NSURL *const)url completion:(void (^)(FLAnimatedImage *animatedImage))completion
{
    NSString *const filename = url.lastPathComponent;
    NSString *const diskPath = [dataFilePath stringByAppendingPathComponent:filename];
    
    NSData * __block animatedImageData = [[NSFileManager defaultManager] contentsAtPath:diskPath];
    FLAnimatedImage * __block animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:animatedImageData];
    
    if (animatedImage) {
        if (completion) {
            completion(animatedImage);
        }
    } else {
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            animatedImageData = data;
            animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:animatedImageData];
            if (animatedImage) {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(animatedImage);
                    });
                }
                [data writeToFile:diskPath atomically:YES];
            }
        }] resume];
    }
}

-(id)initWithFrame:(CGRect)frame withPhotoImage:(UIImage *)image{
    self = [super initWithFrame:frame];
    if (self) {
        //添加图片
        self.imageView.frame=[self caculateOriginImageSizeWith:image];
        [self.imageView setImage:image];
    }
    return self;
}

#pragma mark - UIScrollViewDelegate
/**scroll view处理缩放和平移手势，必须需要实现委托下面两个方法,另外 maximumZoomScale和minimumZoomScale两个属性要不一样*/

//1.返回要缩放的图片
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

//让图片保持在屏幕中央，防止图片放大时，位置出现跑偏
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGFloat offsetX = (_scrollView.bounds.size.width > _scrollView.contentSize.width)?(_scrollView.bounds.size.width - _scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (_scrollView.bounds.size.height > _scrollView.contentSize.height)?
    (_scrollView.bounds.size.height - _scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX,_scrollView.contentSize.height * 0.5 + offsetY);
}

//2.重新确定缩放完后的缩放倍数
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}


#pragma mark - 图片的点击，touch事件
//单击
-(void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.numberOfTapsRequired == 1) {
        [self.delegate tapHiddenPhotoView];
    }
}

// 长按
- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(longPressPhotoView:)]) {
            [self.delegate longPressPhotoView:self.imageView.image];
        }
    }
}

//双击
-(void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.numberOfTapsRequired == 2) {
        if(_scrollView.zoomScale == 1){
            float newScale = [_scrollView zoomScale] *2;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
            [_scrollView zoomToRect:zoomRect animated:YES];
        }else{
            float newScale = [_scrollView zoomScale]/2;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
            [_scrollView zoomToRect:zoomRect animated:YES];
        }
    }
}

//2手指操作
-(void)handleTwoFingerTap:(UITapGestureRecognizer *)gestureRecongnizer{
//    float newScale = [_scrollView zoomScale]/2;
//    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecongnizer locationInView:gestureRecongnizer.view]];
//    [_scrollView zoomToRect:zoomRect animated:YES];
}


#pragma mark - 缩放大小获取方法
-(CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center{
    CGRect zoomRect;
    //大小
    zoomRect.size.height = [_scrollView frame].size.height/scale;
    zoomRect.size.width = [_scrollView frame].size.width/scale;
    //原点
    zoomRect.origin.x = center.x - zoomRect.size.width/2;
    zoomRect.origin.y = center.y - zoomRect.size.height/2;
    return zoomRect;
}

#pragma mark - 懒加载
-(UIScrollView *)scrollView{
    if (_scrollView==nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 3;
        
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        
        [_scrollView setZoomScale:1];
        
        //添加scrollView
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

-(UIImageView *)imageView{
    
    if (_imageView==nil) {
        _imageView = [[FLAnimatedImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled=YES;
        
        //添加手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        doubleTap.numberOfTapsRequired = 2;//需要点两下
        twoFingerTap.numberOfTouchesRequired = 2;//需要两个手指touch
        
        [_imageView addGestureRecognizer:singleTap];
        [_imageView addGestureRecognizer:doubleTap];
        [_imageView addGestureRecognizer:twoFingerTap];
        [_imageView addGestureRecognizer:longPress];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];//如果双击了，则不响应单击事件
        
        [self.scrollView addSubview:_imageView];
    }
    return _imageView;
}

#pragma mark - 计算图片原始高度，用于高度自适应
-(CGRect)caculateOriginImageSizeWith:(UIImage *)image{
    
    CGFloat originImageHeight=[self imageCompressForWidth:image targetWidth:JX_SCREEN_WIDTH].size.height;
    if (originImageHeight>=JX_SCREEN_HEIGHT) {
        originImageHeight=JX_SCREEN_HEIGHT;
    }
    
    CGRect frame=CGRectMake(0, (JX_SCREEN_HEIGHT-originImageHeight)*0.5, JX_SCREEN_WIDTH, originImageHeight);
    
    return frame;
}

/**指定宽度按比例缩放图片*/
-(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
