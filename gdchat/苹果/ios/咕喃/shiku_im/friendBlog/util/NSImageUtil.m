//
//  NSImageUtil.m
//  wq
//
//  Created by weqia on 13-7-25.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//

#import "NSImageUtil.h"
#import "HBHttpRequestCache.h"
@implementation NSImageUtil
+(UIImage*)getClickImage:(UIImage*)originaLimage   withSize:(CGSize)sizeview
{
    CGSize sizeImg=originaLimage.size;
    UIImageOrientation  orientation=originaLimage.imageOrientation;
    CGRect rect=CGRectMake((sizeImg.width-sizeview.width)/2,(sizeImg.height-sizeview.height)/2, sizeview.width, sizeview.height);
    CGImageRef imgRef=CGImageCreateWithImageInRect(originaLimage.CGImage, rect);
    
    return [UIImage imageWithCGImage:imgRef scale:1 orientation:orientation];
    

}
+(UIImage*)limitSizeImage:(UIImage*)originaImage withSize:(CGSize)sizev
{
    UIImageOrientation orientation=originaImage.imageOrientation;
    CGSize size=originaImage.size;
    if(size.width==0)
        return nil;
    if(sizev.width==0)
        return nil;
    float imgScale=0.0f;
    if(size.width>0)
        imgScale=size.height/size.width;
    float viewScale=0.0f;
    if(sizev.width>0)
        viewScale=sizev.height/sizev.width;
    
    float width=size.width,height=size.height;
    if(imgScale<viewScale&&size.width>sizev.width){
        width=sizev.width;
        height=sizev.width*imgScale;
    }else if(imgScale>=viewScale&&size.height>sizev.height){
        height=sizev.height;
        if(imgScale>0)
            width=height/imgScale;
    }
    return [UIImage imageWithCGImage:originaImage.CGImage scale:(size.width/width) orientation:orientation];
}

+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    CGSize size=image.size;
    if(size.height<newSize.height&&size.width<newSize.width)
        return image;
    float imgScale=0.0f;
    if(size.width>0)
        imgScale=size.height/size.width;
    float viewScale=0.0f;
    if(newSize.width>0)
        viewScale=newSize.height/newSize.width;
    float width=size.width,height=size.height;
    if(imgScale<viewScale&&size.width>newSize.width){
        width=newSize.width;
        height=newSize.width*imgScale;
    }else if(imgScale>=viewScale&&size.height>newSize.height){
        height=newSize.height;
        if(imgScale>0)
            width=height/imgScale;
    }
    // Create a graphics image context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,width,height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

-(void) showBigImage:(UIImage*)image fromView:(UIImageView*)fromView  complete:(void(^)(UIView *bacView))complete
{
    if(image!=nil&&image.size.width==0)
        return;
    if(fromView!=nil&&fromView.frame.size.width==0)
        return;
    
    CGRect frame;
    UIView * back=[[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    back.backgroundColor=[UIColor clearColor];
    [fromView.window addSubview:back];
    CGRect rect=[fromView.superview convertRect:fromView.frame toView:back];
    UIImageView * imgView=[[UIImageView alloc]initWithFrame:rect];
    [back addSubview:imgView];
    _backView=back;
    _imageView=imgView;
    _imageView.contentMode=UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds=YES;
    
    rect=_backView.bounds;
    if(image!=nil){
        _image=image;
        imgView.image=image;
        CGSize  size=image.size;
        float imgScale=size.height/size.width;
        float viewScale=rect.size.height/rect.size.width;
        float width=size.width,height=size.height;
        if(imgScale<viewScale&&size.width>rect.size.width){
            width=rect.size.width;
            height=rect.size.width*imgScale;
        }else if(imgScale>=viewScale&&size.height>rect.size.height){
            height=rect.size.height;
            width=height/imgScale;
        }
        frame=CGRectMake((rect.size.width-width)/2, (rect.size.height-height)/2, width, height);
    }
    else{
        imgView.image=fromView.image;
        CGSize  size=fromView.image.size;
        float imgScale=size.height/size.width;
        float viewScale=rect.size.height/rect.size.width;
        float width=size.width,height=size.height;
        if(imgScale<viewScale&&size.width>rect.size.width){
            width=rect.size.width;
            height=rect.size.width*imgScale;
        }else if(imgScale>=viewScale&&size.height>rect.size.height){
            height=rect.size.height;
            width=height/imgScale;
        }
        frame=CGRectMake((rect.size.width-width)/2, (rect.size.height-height)/2, width, height);
    } 
    fromView.hidden=YES;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        back.backgroundColor=[UIColor blackColor];
        imgView.frame=frame;
    } completion:^(BOOL finished) {
        complete(back);
        fromView.hidden=NO;
        _imageView.hidden=YES;
    }];
}

-(void) showBigImageWithUrl:(NSString *)url fromView:(UIImageView *)fromView complete:(void (^)(UIView *))complete
{

    UIImage* image1=[[HBHttpRequestCache shareCache] getBitmapFromMemory:url];
    if(image1!=nil){
        [self showBigImage:image1 fromView:fromView complete:complete];
    }else{
        UIImage *image2=[[HBHttpRequestCache shareCache] getBitmapFromDisk:url];
        if(image2!=nil){
            [self showBigImage:image2 fromView:fromView complete:complete];
        }else{
            [self showBigImage:nil fromView:fromView complete:complete];
        }
    }
}

-(void) goBackToView:(UIImageView*)toView withImage:(UIImage*)image
{
    [UIApplication sharedApplication].keyWindow.clipsToBounds=YES;
    _imageView.hidden=NO;
    if(image!=nil&&image.size.width==0)
        return;
    if(toView!=nil&&toView.frame.size.width==0)
        return;
    CGRect rect1=[toView.superview convertRect:toView.frame toView:_backView];
    CGRect frame;
    _backView.hidden=NO;
    toView.hidden=YES;
    CGRect rect=_backView.bounds;
    if(image!=nil){
        CGSize  size=image.size;
        float imgScale=size.height/size.width;
        float viewScale=rect.size.height/rect.size.width;
        float width=size.width,height=size.height;
        if(imgScale<viewScale&&size.width>rect.size.width){
            width=rect.size.width;
            height=rect.size.width*imgScale;
        }else if(imgScale>=viewScale&&size.height>rect.size.height){
            height=rect.size.height;
            width=height/imgScale;
        }
        frame=CGRectMake((rect.size.width-width)/2, (rect.size.height-height)/2, width, height);
        _imageView.frame=frame;
        _imageView.image=image;
    }
    else{
        frame=toView.frame;
        _imageView.image=toView.image;
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _backView.backgroundColor=[UIColor clearColor];
        _imageView.frame=rect1;
    } completion:^(BOOL finished) {
        toView.hidden=NO;
        [_backView removeFromSuperview];
        _image=nil;
        _imageView=nil;
        _backView=nil;
        [UIApplication sharedApplication].keyWindow.clipsToBounds=YES;
        
    }];
    
    

}

-(void) goBackToView:(UIImageView *)toView withImageUrl:(NSString *)url
{
    UIImage* image=[[HBHttpRequestCache shareCache] getBitmapFromMemory:url];
    if(image){
        [self goBackToView:toView withImage:image];
    }else{
        UIImage *image=[[HBHttpRequestCache shareCache] getBitmapFromDisk:url];
        if(image){
            [self goBackToView:toView withImage:image];
        }else{
            [self goBackToView:toView withImage:nil];
        }
    }

}

@end
