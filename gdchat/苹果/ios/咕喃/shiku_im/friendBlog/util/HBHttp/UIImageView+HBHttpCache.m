//
//  UIImageView+HBHttpCache.m
//  MyTest
//
//  Created by weqia on 13-8-22.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import "UIImageView+HBHttpCache.h"
#import "UIImage+HBClass.h"
#import "HBHttpRequestCache.h"

@implementation UIImageView (HBHttpCache)

static char operationKey='a';


#pragma -mark 私有方法
-(void)cancel
{
    id<HBHttpOperationDelegate> operation=objc_getAssociatedObject(self, &operationKey);
    if(operation){
        [operation cancel];
        objc_setAssociatedObject(self, &operationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

#pragma -mark 接口方法

-(void) setImageWithURL:(NSString*)url
{
    [self setImageWithURL:url layout:UIImageViewLayoutNone placeholderImage:nil process:nil complete:nil option:HBHttpImageDownloaderOptionUseCache|HBHttpImageDownloaderOptionRetry];
}


-(void) setImageWithURL:(NSString*)url
                 layout:(UIImageViewLayoutType)layout
{
    [self setImageWithURL:url layout:layout placeholderImage:nil process:nil complete:nil option:HBHttpImageDownloaderOptionUseCache|HBHttpImageDownloaderOptionRetry];
}


-(void) setImageWithURL:(NSString *)url
                 layout:(UIImageViewLayoutType)layout
       placeholderImage:(UIImage*)placeholderImage
{
      [self setImageWithURL:url layout:layout placeholderImage:placeholderImage process:nil complete:nil option:HBHttpImageDownloaderOptionUseCache|HBHttpImageDownloaderOptionRetry];
}


-(void) setImageWithURL:(NSString *)url
                 layout:(UIImageViewLayoutType)layout
       placeholderImage:(UIImage*)placeholderImage
                process:(HBHttpImageDownloaderProcessBlock) process
               complete:(HBHttpImageDownloaderCompleteBlock)complete
{
    [self setImageWithURL:url layout:layout placeholderImage:placeholderImage process:process complete:complete option:HBHttpImageDownloaderOptionUseCache|HBHttpImageDownloaderOptionRetry];

}


-(void) setImageWithURL:(NSString *)url
                 layout:(UIImageViewLayoutType)layout
       placeholderImage:(UIImage*)placeholderImage
                process:(HBHttpImageDownloaderProcessBlock)process
               complete:(HBHttpImageDownloaderCompleteBlock)complete
                 option:(HBHttpImageDownloaderOption)option
{
    self.image=placeholderImage;
    /****图片处理block****/
    __block void(^block)(UIImage*);
    /****图片下载block****/
    void(^download)()=^{
        [self cancel];
            [[HBHttpImageDownloader shareDownlader] downBitmapWithURL:url process:process complete:^(UIImage *image, NSData *data, NSError *error, BOOL success){
            /****回调处理****/
            if(block){
                block(image);
            }
            if(complete){
                if([NSThread isMainThread]){
                    if(complete){
                        complete(image,data,error,success);
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(complete){
                            complete(image,data,error,success);
                        }
                    });
                }
            }
        } option:option valueReturn:^(id<HBHttpOperationDelegate> operation) {
           /****operation 注册为属性，以便于停止下载操作****/
            objc_setAssociatedObject(self, &operationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }];
    };
    __weak UIImageView * wself=self;        // 防止 UIImageView 释放时， self  变成废指针
    if(layout==UIImageViewLayoutNone){
        block=^(UIImage * image){
            if(!wself) return;
            __strong UIImageView * sself=wself;         // 在操作为完成之前，UIImageView 不能被释放
            /*****界面操作需放在主线程*****/
            if([NSThread isMainThread]){
                sself.image=image;
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    sself.image=image;
                });
            }
        };
        download(); // 执行下载操作
    }else if(layout==UIImageViewLayoutLimit){
        NSMutableString * key=[NSMutableString stringWithString:url];
        [key appendFormat:@".limit"];
        block=^(UIImage * image){
            if(image){
                if(!wself) return;
                __strong UIImageView * sself=wself;
                UIImage * limitimage=[image getLimitImage:sself.frame.size];
                /*****界面操作需放在主线程*****/
                if([NSThread isMainThread]){
                    CGRect frame=sself.frame;
                    frame.size=limitimage.size;
                    sself.frame=frame;
                    sself.image=limitimage;
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CGRect frame=sself.frame;
                        frame.size=limitimage.size;
                        sself.frame=frame;
                        sself.image=limitimage;
                    });
                }if(option&HBHttpImageDownloaderOptionUseCache){
                    /***将生成的限制大小的图片缓存起来***/
                    [[HBHttpRequestCache shareCache] storeBitmap:limitimage withKey:key complete:nil];
                }
            }
        };
        /*****如果是HBHttpImageDownloaderOptionUseCache 先从缓存中加载限制大小的图片*****/
        if(option&HBHttpImageDownloaderOptionUseCache){
            [[HBHttpRequestCache shareCache] getBitmap:key complete:^(UIImage *image) {
                if(!wself) return;
                __strong UIImageView * sself=wself;
                if(image){
                    CGRect frame=sself.frame;
                    frame.size=image.size;
                    sself.frame=frame;
                    sself.image=image;
                    if(complete){
                         complete(image,nil,nil,YES);
                    }
                }else{
                    /*****如果缓存中没有，则从已缓存的原图生成，如果没有已缓存的原图，则会下载原图并生成目标图****/
                    download();
                }
            }];
        }else{
            download();
        }
    }else if(layout==UIImageViewLayoutClick){
        NSMutableString * key=[NSMutableString stringWithString:url];
        [key appendFormat:@".click"];
        block=^(UIImage * image){
            if(!wself) return;
            __strong UIImageView * sself=wself;
            if(image){
                UIImage * clickimage=[image getClickImage:sself.frame.size];
                /*****界面操作需放在主线程*****/
                if([NSThread isMainThread]){
                    sself.image=clickimage;
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        sself.image=clickimage;
                    });
                }if(option&HBHttpImageDownloaderOptionUseCache){
                    /*****将生成的裁减过的图片缓存起来****/
                    [[HBHttpRequestCache shareCache] storeBitmap:clickimage withKey:key complete:nil];
                }
            }
        };
         /*****如果是HBHttpImageDownloaderOptionUseCache  先从缓存中加载裁减过的图片*****/
        if(option&HBHttpImageDownloaderOptionUseCache){
            [[HBHttpRequestCache shareCache] getBitmap:key complete:^(UIImage *image) {
                if(!wself) return;
                __strong UIImageView * sself=wself;
                if(image){
                    sself.image=image;
                    if(complete){
                        complete(image,nil,nil,YES);
                    }
                }else{
                    /*****如果缓存中没有，则从已缓存的原图生成，如果没有已缓存的原图，则会下载原图并生成目标图****/
                    download();
                }
            }];
        }else{
            download();
        }
    }
 }

-(void) setImageWithIndirectURL:(NSString *)indirectURL
{
    [self setImageWithURL:indirectURL layout:UIImageViewLayoutNone placeholderImage:nil process:nil complete:nil option:HBHttpImageDownloaderOptionRetry|HBHttpImageDownloaderOptionUseCache];
}


-(void) setImageWithIndirectURL:(NSString *)indirectURL
                         layout:(UIImageViewLayoutType)layout
{
    [self setImageWithURL:indirectURL layout:layout placeholderImage:nil process:nil complete:nil option:HBHttpImageDownloaderOptionRetry|HBHttpImageDownloaderOptionUseCache];
}


-(void) setImageWithIndirectURL:(NSString *)indirectURL
                         layout:(UIImageViewLayoutType)layout
               placeholderImage:(UIImage *)placeholderImage
{
     [self setImageWithURL:indirectURL layout:layout placeholderImage:placeholderImage process:nil complete:nil option:HBHttpImageDownloaderOptionRetry|HBHttpImageDownloaderOptionUseCache];
}


-(void) setImageWithIndirectURL:(NSString *)indirectURL
                         layout:(UIImageViewLayoutType)layout
               placeholderImage:(UIImage *)placeholderImage
                        process:(HBHttpImageDownloaderProcessBlock)process
                       complete:(HBHttpImageDownloaderCompleteBlock)complete
{
    [self setImageWithURL:indirectURL layout:layout placeholderImage:placeholderImage process:process complete:complete option:HBHttpImageDownloaderOptionRetry|HBHttpImageDownloaderOptionUseCache];
}


-(void) setImageWithIndirectURL:(NSString *)indirectURL
                         layout:(UIImageViewLayoutType)layout
               placeholderImage:(UIImage *)placeholderImage
                        process:(HBHttpImageDownloaderProcessBlock)process
                       complete:(HBHttpImageDownloaderCompleteBlock)complete
                         option:(HBHttpImageDownloaderOption)option
{
    self.image=placeholderImage;
    /****图片处理block****/
    __block void(^block)(UIImage*);
    /****图片下载block****/
    void(^download)()=^{
        [self cancel];
        [[HBHttpImageDownloader shareDownlader] downBitmapWithIndirectURL:indirectURL process:process complete:^(UIImage * image, NSData * data, NSError * error, BOOL  success) {
            if(block){
                block(image);
            }
             /****回调处理****/
            if(complete){
                complete(image,data,error,success);
            }
        } option:option valueReturn:^(id<HBHttpOperationDelegate> operation) {
            /****operation 注册为属性，以便于停止下载操作****/
            objc_setAssociatedObject(self, &operationKey, operation,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }];
    };
    __weak UIImageView * wself=self;             // 防止 UIImageView 释放时， self  变成废指针
    if(layout==UIImageViewLayoutNone){
        block=^(UIImage * image){
            if(!wself) return;
            __strong UIImageView * sself=wself;          // 在操作为完成之前，UIImageView 不能被释放
              /*****界面操作需放在主线程*****/
            if([NSThread isMainThread]){
                sself.image=image;
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    sself.image=image;
                });
            }
        };
        download();
    }else if(layout==UIImageViewLayoutLimit){
        NSMutableString * key=[NSMutableString stringWithString:indirectURL];
        [key appendFormat:@".limit"];
        block=^(UIImage * image){
            if(!wself) return;
            __strong UIImageView * sself=wself;
            if(image){
                UIImage * limitimage=[image getLimitImage:sself.frame.size];
                /*****界面操作需放在主线程*****/
                if([NSThread isMainThread]){
                    CGRect frame=sself.frame;
                    frame.size=limitimage.size;
                    sself.frame=frame;
                    sself.image=limitimage;
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CGRect frame=sself.frame;
                        frame.size=limitimage.size;
                        sself.frame=frame;
                        sself.image=limitimage;
                    });
                }if(option&HBHttpImageDownloaderOptionUseCache){
                    /*****将生成的限制大小的图片缓存起来****/
                    [[HBHttpRequestCache shareCache] storeBitmap:limitimage withKey:key complete:nil];
                }
            }
        };
        if(option&HBHttpImageDownloaderOptionUseCache){
            /*****先从缓存中加载限制大小的图片*****/
                [[HBHttpRequestCache shareCache] getBitmap:key complete:^(UIImage *image) {
                if(!wself) return;
                __strong UIImageView * sself=wself;
                if(image){
                    CGRect frame=sself.frame;
                    frame.size=image.size;
                    sself.frame=frame;
                    sself.image=image;
                    if(complete){
                        complete(image,nil,nil,YES);
                    }
                }else{
                    /*****如果缓存中没有，则从已缓存的原图生成，如果没有已缓存的原图，则会下载原图并生成目标图****/
                    download();
                }
            }];
        }else{
            download();
        }
    }else if(layout==UIImageViewLayoutClick){
        NSMutableString * key=[NSMutableString stringWithString:indirectURL];
        [key appendFormat:@".click"];
        block=^(UIImage * image){
            if(!wself) return;
            __strong UIImageView * sself=wself;
            if(image){
                UIImage * clickimage=[image getClickImage:sself.frame.size];
                /*****界面操作需放在主线程*****/
                if([NSThread isMainThread]){
                    sself.image=clickimage;
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        sself.image=clickimage;
                    });
                }if(option&HBHttpImageDownloaderOptionUseCache){
                    /*****将生成的裁减过的图片缓存起来****/
                    [[HBHttpRequestCache shareCache] storeBitmap:clickimage withKey:key complete:nil];
                }
            }
        };
        if(option&HBHttpImageDownloaderOptionUseCache){
            /*****先从缓存中加载裁减过的图片*****/
            [[HBHttpRequestCache shareCache] getBitmap:key complete:^(UIImage *image) {
                if(!wself) return;
                __strong UIImageView * sself=wself;
                if(image){
                    sself.image=image;
                    if(complete){
                        complete(image,nil,nil,YES);
                    }
                }else{
                    /*****如果缓存中没有，则从已缓存的原图生成，如果没有已缓存的原图，则会下载原图并生成目标图****/
                    download();
                }
            }];
        }else{
            download();
        }
    }

}


-(void) setImageWithCacheKey:(NSString *)key layout:(UIImageViewLayoutType)layout
                                   placeholderImage:(UIImage *)placeholderImage
{
    NSMutableString * Key=[NSMutableString stringWithString:key];
    if(layout==UIImageViewLayoutLimit){
        [Key appendFormat:@".limit"];
    }else if(layout==UIImageViewLayoutClick){
        [Key appendFormat:@".click"];
    }
    UIImage * image=[[HBHttpRequestCache shareCache] getBitmapFromMemory:Key];
    if(image){
        self.image=image;
        if(layout==UIImageViewLayoutLimit){
            CGRect frame=self.frame;
            frame.size=image.size;
            self.frame=frame;
        }
    }else{
        self.image=placeholderImage;
    }
}


@end
