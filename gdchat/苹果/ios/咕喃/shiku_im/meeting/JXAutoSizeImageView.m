//
//  JXAutoSizeImageView.m
//  lveliao_IM
//
//  Created by MacZ on 2017/8/9.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXAutoSizeImageView.h"

@implementation JXAutoSizeImageView

#define _width self.frame.size.width
#define _height self.frame.size.height
#define max_person 16

@synthesize users = _users;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _users  = [[NSMutableArray alloc]init];
        _images = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)customView {
}

-(BOOL)isMember:(NSString*)userId{
    return [_users indexOfObject:userId] != NSNotFound;
}

-(void)add:(NSString*)userId{
    if([_users indexOfObject:userId] != NSNotFound )
        return;
    [_users addObject:userId];
    if([_users count]<=max_person){
        JXImageView* p;
        if([_images count]>[_users count]-1)
            p = [_images objectAtIndex:[_users count]-1];
        else{
            p = [[JXImageView alloc] init];
            p.didTouch = @selector(clickUser:);
            p.layer.borderWidth = 0.5;
            p.layer.borderColor = [UIColor yellowColor].CGColor;
            [self addSubview:p];
            [_images addObject:p];
        }
        p.delegate = self.delegate;
        [g_server getHeadImageLarge:[_users objectAtIndex:[_users count]-1] userName:nil imageView:p];
        [self show];
    }
}

-(void)delete:(NSString*)userId{
    NSInteger n = [_users indexOfObject:userId];
    if(n == NSNotFound )
        return;
    JXImageView* p;
    p = [_images objectAtIndex:n];
    [p removeFromSuperview];
    [_users removeObjectAtIndex:n];
    [_images removeObjectAtIndex:n];
    [self show];
}

-(void)show{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1];
    
    [self adjust];
    [UIView commitAnimations];
}

-(void)clear{
    for(int i=0;i<[_images count];i++){
        JXImageView* p = [_images objectAtIndex:i];
        p.image = nil;
    }
    [_images removeAllObjects];
    [_users removeAllObjects];
}

-(void)adjust{
    int w,h,i,j,n,x,y;
    if([_users count]>=13){//13人以上
        w = _width/4;
        h = _height/4;
        x = 0;
        y = 0;
        n = 0;
        for(int i=0;i<4;i++){
            for(int j=0;j<4;j++){
                if(n>=[_users count])
                    break;
                [self setImage:n x:x y:y w:w h:h];
                x += w;
                n++;
            }
            x = 0;
            y += h;
            if(n>=[_users count])
                break;
        }
        return;
    }
    if([_users count]>=10){//10人以上
        w = _width/4;
        h = _height/3;
        x = 0;
        y = 0;
        n = 0;
        for(int i=0;i<3;i++){
            for(int j=0;j<4;j++){
                if(n>=[_users count])
                    break;
                [self setImage:n x:x y:y w:w h:h];
                x += w;
                n++;
            }
            x = 0;
            y += h;
            if(n>=[_users count])
                break;
        }
        return;
    }
    if([_users count]>=7){//7人以上
        w = _width/3;
        h = _height/3;
        x = 0;
        y = 0;
        n = 0;
        for(int i=0;i<3;i++){
            for(int j=0;j<3;j++){
                if(n>=[_users count])
                    break;
                [self setImage:n x:x y:y w:w h:h];
                x += w;
                n++;
            }
            x = 0;
            y += h;
            if(n>=[_users count])
                break;
        }
        return;
    }
    if([_users count]>=5){//5人以上
        w = _width/3;
        h = _height/2;
        x = 0;
        y = 0;
        n = 0;
        for(int i=0;i<2;i++){
            for(int j=0;j<3;j++){
                if(n>=[_users count])
                    break;
                [self setImage:n x:x y:y w:w h:h];
                x += w;
                n++;
            }
            x = 0;
            y += h;
            if(n>=[_users count])
                break;
        }
        return;
    }
    
    if([_users count]==4){//4人
        w = _width/2;
        h = _height/2;
        x = 0;
        y = 0;
        n = 0;
        for(int i=0;i<2;i++){
            for(int j=0;j<2;j++){
                if(n>=[_users count])
                    break;
                [self setImage:n x:x y:y w:w h:h];
                x += w;
                n++;
            }
            y += h;
            x = 0;
            if(n>=[_users count])
                break;
        }
        return;
    }
    
    if([_users count]==3){//3人
        w = _width/2;
        h = _height/2;
        x = 0;
        y = 0;
        n = 0;
        for(int i=0;i<2;i++){
            [self setImage:i x:x y:y w:w h:h];
            x += w;
        }
        JXImageView* p=[_images objectAtIndex:2];
        p.frame = CGRectMake(w/2, h, w, h);
        return;
    }
    
    if([_users count]==2){//小于2人
        w = _width/2;
        h = _height;
        x = 0;
        y = 0;
        for(int i=0;i<[_users count];i++){
            [self setImage:i x:x y:y w:w h:h];
            x += w;
        }
        return;
    }
    if([_users count]==1){//小于1人
        w = _width/2;
        h = _height;
        [self setImage:0 x:w/2 y:0 w:w h:h];
        return;
    }
}

-(void)setImage:(int)n x:(int)x y:(int)y w:(int)w h:(int)h{
    JXImageView* p=[_images objectAtIndex:n];
    [g_server getHeadImageLarge:[_users objectAtIndex:n] userName:nil imageView:p];
    p.frame = CGRectMake(x, y, w, h);
}

@end
