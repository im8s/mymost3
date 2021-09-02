//
//  JJHeaders.m
//  QQHeader
//
//  Created by lijunjie on 16/1/5.
//  Copyright © 2016年 ljj. All rights reserved.
//

#import "JJHeaders.h"
#import "JJCustomLayer.h"

static inline float radians(double degrees) { return degrees * M_PI / 180; }

@implementation JJHeaders

+ (UIView *)createHeaderView:(CGFloat)headerWH images:(NSArray<UIImage *> *)images;
{
    if (!images || [images count] <= 0) {
        return nil;
    }
    
    UIView *view = nil;
    switch ([images count]) {
        case 1: {
            view = [JJHeaders getView1:headerWH images:images];
            break;
        }
        case 2: {
            view = [JJHeaders getView2:headerWH images:images];
            break;
        }
        case 3: {
            view = [JJHeaders getView3:headerWH images:images];
            break;
        }
        case 4: {
            view = [JJHeaders getView4:headerWH images:images];
            break;
        }
        case 5: {
            view = [JJHeaders getView5:headerWH images:images];
            break;
        }
        case 6: {
             view = [JJHeaders getView6:headerWH images:images];
             break;
         }
        case 7: {
             view = [JJHeaders getView7:headerWH images:images];
             break;
         }
        case 8: {
             view = [JJHeaders getView8:headerWH images:images];
             break;
         }
        case 9: {
            view = [JJHeaders getView9:headerWH images:images];
            break;
        }
        default:
            break;
    }
    return view;
}

+ (UIView *)getView1:(CGFloat)headerWH images:(NSArray<UIImage *> *)images
{
    CGFloat diameter = headerWH;
    CGFloat r = diameter / 2;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerWH, headerWH)];
    view.backgroundColor = [UIColor clearColor];
    
    UIImage *image = images[0];
    JJCustomLayer *layer0 = [JJCustomLayer createWithImage:image degrees:0 isClip:NO];
    layer0.frame = CGRectMake(4, 4, headerWH-8, headerWH-8);
    [view.layer addSublayer:layer0];
    [layer0 setNeedsDisplay];
    
    return view;
}

+ (UIView *)getView2:(CGFloat)headerWH images:(NSArray *)images
{
    CGFloat diameter = (headerWH + headerWH - sqrtf(2) * headerWH)-1;
    CGFloat r = diameter / 2-1;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerWH, headerWH)];
    view.backgroundColor = [UIColor clearColor];
    
    CGFloat picWith = headerWH/2-2-4;
    
    UIImage *image = images[0];
    CGSize imageSize = image.size;
    CGFloat correctScale = headerWH / imageSize.height;
    JJCustomLayer *layer0 = [JJCustomLayer createWithImage:image degrees:0 isClip:NO];
    layer0.frame = CGRectMake(4, (headerWH-picWith)*0.5, picWith, picWith);
    [view.layer addSublayer:layer0];
    [layer0 setNeedsDisplay];
    
    image = images[1];
    imageSize = image.size;
    correctScale = headerWH / imageSize.height;
    JJCustomLayer *layer1 = [JJCustomLayer createWithImage:image degrees:180 - 45 isClip:YES];
    layer1.frame = CGRectMake(picWith+4+4, (140-picWith)*0.5, picWith, picWith);
    [view.layer addSublayer:layer1];
    [layer1 setNeedsDisplay];
    
    return view;
}

+ (UIView *)getView3:(CGFloat)headerWH images:(NSArray *)images
{
    CGFloat diameter = headerWH/2;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerWH, headerWH)];
    view.backgroundColor = [UIColor clearColor];
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 2 * diameter, diameter + sqrtf(3) / 2 * diameter);
    
    CGFloat picWith = layer.frame.size.height/2-2-4;
    
    UIImage *image = images[0];
    CGSize imageSize = image.size;
    CGFloat correctScale = headerWH / imageSize.height;
    CGPoint center0 = CGPointMake(diameter, diameter / 2);
    JJCustomLayer *layer0 = [JJCustomLayer createWithImage:image degrees:30 isClip:YES];
    layer0.frame = CGRectMake((layer.frame.size.height-picWith)*0.5+4, 4, picWith, picWith);
    [layer addSublayer:layer0];
    [layer0 setNeedsDisplay];
    
    image = images[1];
    imageSize = image.size;
    correctScale = headerWH / imageSize.height;
    CGPoint center1 = CGPointMake(center0.x - diameter * sin(radians(30)), diameter / 2 + diameter * cos(radians(30)));
    JJCustomLayer *layer1 = [JJCustomLayer createWithImage:image degrees:270 isClip:YES];
    layer1.frame = CGRectMake(8, picWith+4+4, picWith, picWith);
    [layer addSublayer:layer1];
    [layer1 setNeedsDisplay];
    
    image = images[2];
    imageSize = image.size;
    correctScale = headerWH / imageSize.height;
    CGPoint center2 = CGPointMake(center1.x + diameter, center1.y);
    JJCustomLayer *layer2 = [JJCustomLayer createWithImage:image degrees:180 - 30 isClip:YES];
    layer2.frame = CGRectMake(picWith+8+4, picWith+4+4, picWith, picWith);
    [layer addSublayer:layer2];
    [layer2 setNeedsDisplay];
    
    CGRect f = layer.frame;
    f.origin.y = (view.frame.size.height - f.size.height) / 2;
    layer.frame = f;
    [view.layer addSublayer:layer];
    return view;
}

+ (UIView *)getView4:(CGFloat)headerWH images:(NSArray *)images
{
    CGFloat diameter = headerWH/2;
    CGFloat r = diameter / 2;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerWH, headerWH)];
    view.backgroundColor = [UIColor clearColor];
    
    CGFloat picWith = headerWH/2-2-4;
    
    UIImage *image = images[0];
    CGSize imageSize = image.size;
    CGFloat correctScale = headerWH / imageSize.height;
    CGPoint center0 = CGPointMake(r, r);
    JJCustomLayer *layer0 = [JJCustomLayer createWithImage:image degrees:0 isClip:YES];
    layer0.frame =  CGRectMake(4, 4, picWith, picWith);
    [view.layer addSublayer:layer0];
    [layer0 setNeedsDisplay];
    
    image = images[1];
    imageSize = image.size;
    correctScale = headerWH / imageSize.height;
    CGPoint center1 = CGPointMake(center0.x, center0.y + diameter);
    JJCustomLayer *layer1 = [JJCustomLayer createWithImage:image degrees:270 isClip:YES];
    layer1.frame =  CGRectMake(picWith+4+4, 4, picWith, picWith);
    [view.layer addSublayer:layer1];
    [layer1 setNeedsDisplay];
    
    image = images[2];
    imageSize = image.size;
    correctScale = headerWH / imageSize.height;
    CGPoint center2 = CGPointMake(center1.x + diameter, center1.y);
    JJCustomLayer *layer2 = [JJCustomLayer createWithImage:image degrees:180 isClip:YES];
    layer2.frame = CGRectMake(4, picWith+4+4, picWith, picWith);
    [view.layer addSublayer:layer2];
    [layer2 setNeedsDisplay];
    
    image = images[3];
    imageSize = image.size;
    correctScale = headerWH / imageSize.height;
    CGPoint center3 = CGPointMake(center2.x, center2.y - diameter);
    JJCustomLayer *layer3 = [JJCustomLayer createWithImage:image degrees:90 isClip:YES];
    layer3.frame = CGRectMake(picWith+4+4, picWith+4+4, picWith, picWith);
    [view.layer addSublayer:layer3];
    [layer3 setNeedsDisplay];
    return view;
}

+ (UIView *)getView5:(CGFloat)headerWH images:(NSArray *)images
{
    CGFloat r = headerWH / 2 / (2 * sin(radians(54)) + 1);
    CGFloat diameter = r * 2;
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0,headerWH, r / tan(radians(36)) + r / sin(radians(36)) + diameter);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerWH, headerWH)];
    view.backgroundColor = [UIColor clearColor];
    CGFloat picWith = (headerWH-16)/3;
    CGFloat padding = (headerWH-picWith*2-4-8)*0.5;
    UIImage *image = images[0];
    CGSize imageSize = image.size;
    CGFloat correctScale = headerWH / imageSize.height;
    CGPoint center0 = CGPointMake(headerWH / 2, r);
    JJCustomLayer *layer0 = [JJCustomLayer createWithImage:image degrees:54 isClip:YES];
    layer0.frame = CGRectMake((headerWH-picWith*2-4)*0.5,padding, picWith, picWith);
    [view.layer addSublayer:layer0];
    [layer0 setNeedsDisplay];
    
    image = images[1];
    imageSize = image.size;
    correctScale = headerWH / imageSize.height;
    CGPoint center1 = CGPointMake(center0.x - diameter * sin(radians(54)), center0.y + diameter * cos(radians(54)));
    JJCustomLayer *layer1 = [JJCustomLayer createWithImage:image degrees:270 + 72 isClip:YES];
    layer1.frame = CGRectMake((headerWH-picWith*2-4)*0.5+picWith+4, padding, picWith, picWith);
    [view.layer addSublayer:layer1];
    [layer1 setNeedsDisplay];
    
    image = images[2];
    imageSize = image.size;
    correctScale = headerWH / imageSize.height;
    CGPoint center2 = CGPointMake(center1.x + diameter * cos(radians(72)), center1.y + diameter * sin(radians(72)));
    JJCustomLayer *layer2 = [JJCustomLayer createWithImage:image degrees:270 isClip:YES];
    layer2.frame = CGRectMake(4, padding+picWith+4, picWith, picWith);
    [view.layer addSublayer:layer2];
    [layer2 setNeedsDisplay];
    
    image = images[3];
    imageSize = image.size;
    correctScale = headerWH / imageSize.height;
    CGPoint center3 = CGPointMake(center2.x + diameter, center2.y);
    JJCustomLayer *layer3 = [JJCustomLayer createWithImage:image degrees:180 + 18 isClip:YES];
    layer3.frame = CGRectMake(picWith+4+4, padding+picWith+4, picWith, picWith);
    [view.layer addSublayer:layer3];
    [layer3 setNeedsDisplay];
    
    image = images[4];
    imageSize = image.size;
    correctScale = headerWH / imageSize.height;
    JJCustomLayer *layer4 = [JJCustomLayer createWithImage:image degrees:90 + 36 isClip:YES];
    layer4.frame = CGRectMake((picWith+4)*2+4, padding+picWith+4, picWith, picWith);
    [view.layer addSublayer:layer4];
    [layer4 setNeedsDisplay];
    
    CGRect f = layer.frame;
    f.origin.y = (view.frame.size.height - f.size.height) / 2;
    layer.frame = f;
    [view.layer addSublayer:layer];
    
    return view;
}

+ (UIView *)getView6:(CGFloat)headerWH images:(NSArray *)images
{
    CGFloat r = headerWH / 2 / (2 * sin(radians(54)) + 1);
    CGFloat diameter = r * 2;
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0,headerWH, r / tan(radians(36)) + r / sin(radians(36)) + diameter);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerWH, headerWH)];
    view.backgroundColor = [UIColor clearColor];
    
    CGFloat picWith = (headerWH-16)/3;
    CGFloat padding = (headerWH-picWith*2-4-8)*0.5;
    
    for (NSInteger i=0; i<6; i++) {
        NSInteger x = i/3;
        NSInteger y = i%3;
        UIImage *image = images[i];
        JJCustomLayer *layer0 = [JJCustomLayer createWithImage:image degrees:54 isClip:YES];
        layer0.frame = CGRectMake(y*(picWith+4)+4, padding+x*(picWith+4)+4, picWith, picWith);
        [layer addSublayer:layer0];
        [layer0 setNeedsDisplay];
    }

    CGRect f = layer.frame;
    f.origin.y = (view.frame.size.height - f.size.height) / 2;
    layer.frame = f;
    [view.layer addSublayer:layer];
    
    return view;
}

+ (UIView *)getView7:(CGFloat)headerWH images:(NSArray *)images
{
    CGFloat r = headerWH / 2 / (2 * sin(radians(54)) + 1);
    CGFloat diameter = r * 2;
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0,headerWH, r / tan(radians(36)) + r / sin(radians(36)) + diameter);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerWH, headerWH)];
    view.backgroundColor = [UIColor clearColor];
    
    CGFloat picWith = (headerWH-16)/3;
    CGFloat padding = (headerWH-picWith*3-16)*0.5;
    
    UIImage *image = images[0];
    JJCustomLayer *layer0 = [JJCustomLayer createWithImage:image degrees:54 isClip:YES];
    layer0.frame = CGRectMake((headerWH-picWith)*0.5,4, picWith, picWith);
    [view.layer addSublayer:layer0];
    [layer0 setNeedsDisplay];
    

    
    for (NSInteger i=0; i<6; i++) {
        NSInteger x = i/3;
        NSInteger y = i%3;
        UIImage *image = images[i+1];
        JJCustomLayer *layer0 = [JJCustomLayer createWithImage:image degrees:54 isClip:YES];
        layer0.frame = CGRectMake(y*(picWith+4)+4, padding+(x+1)*(picWith+4)+4, picWith, picWith);
        [view.layer addSublayer:layer0];
        [layer0 setNeedsDisplay];
    }

    
    CGRect f = layer.frame;
    f.origin.y = (view.frame.size.height - f.size.height) / 2;
    layer.frame = f;
    [view.layer addSublayer:layer];
    
    return view;
}

+ (UIView *)getView8:(CGFloat)headerWH images:(NSArray *)images
{
    CGFloat r = headerWH / 2 / (2 * sin(radians(54)) + 1);
    CGFloat diameter = r * 2;
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0,headerWH, r / tan(radians(36)) + r / sin(radians(36)) + diameter);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerWH, headerWH)];
    view.backgroundColor = [UIColor clearColor];
    
    CGFloat picWith = (headerWH-16)/3;
    CGFloat padding = (headerWH-picWith*3-16)*0.5;
    
    UIImage *image = images[0];
    JJCustomLayer *layer0 = [JJCustomLayer createWithImage:image degrees:54 isClip:YES];
    layer0.frame = CGRectMake(4,4, picWith, picWith);
    [view.layer addSublayer:layer0];
    [layer0 setNeedsDisplay];
    
    image = images[1];
    JJCustomLayer *layer1 = [JJCustomLayer createWithImage:image degrees:54 isClip:YES];
    layer1.frame = CGRectMake(picWith+4+4,4, picWith, picWith);
    [view.layer addSublayer:layer1];
    [layer1 setNeedsDisplay];

    
    for (NSInteger i=0; i<6; i++) {
        NSInteger x = i/3;
        NSInteger y = i%3;
        UIImage *image = images[i+2];
        JJCustomLayer *layer0 = [JJCustomLayer createWithImage:image degrees:54 isClip:YES];
        layer0.frame = CGRectMake(y*(picWith+4)+4, padding+(x+1)*(picWith+4)+4, picWith, picWith);
        [view.layer addSublayer:layer0];
        [layer0 setNeedsDisplay];
    }
    
    CGRect f = layer.frame;
    f.origin.y = (view.frame.size.height - f.size.height) / 2;
    layer.frame = f;
    [view.layer addSublayer:layer];
    
    return view;
}
+ (UIView *)getView9:(CGFloat)headerWH images:(NSArray *)images
{
    CGFloat r = headerWH / 2 / (2 * sin(radians(54)) + 1);
    CGFloat diameter = r * 2;
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0,headerWH, r / tan(radians(36)) + r / sin(radians(36)) + diameter);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerWH, headerWH)];
    view.backgroundColor = [UIColor clearColor];
    
    CGFloat picWith = (headerWH-16)/3;
    CGFloat padding = (headerWH-picWith*3-16)*0.5;

    
    for (NSInteger i=0; i<9; i++) {
        NSInteger x = i/3;
        NSInteger y = i%3;
        UIImage *image = images[i];
        JJCustomLayer *layer0 = [JJCustomLayer createWithImage:image degrees:54 isClip:YES];
        layer0.frame = CGRectMake(y*(picWith+4)+4, padding+x*(picWith+4)+4, picWith, picWith);
        [view.layer addSublayer:layer0];
        [layer0 setNeedsDisplay];
    }
    
    CGRect f = layer.frame;
    f.origin.y = (view.frame.size.height - f.size.height) / 2;
    layer.frame = f;
    [view.layer addSublayer:layer];
    
    return view;
}
+ (CGRect)getRect:(CGPoint)center size:(CGSize)size
{
    return CGRectMake(center.x - size.width / 2, center.y - size.height / 2, size.width, size.height);
}
@end
