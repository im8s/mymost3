//
//  JXLabel.m
//  sjvodios
//
//  Created by  on 12-2-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JXLabel.h"

@interface JXLabel ()

@property (nonatomic, assign) BOOL isAction; // 防止重复点击

@end

@implementation JXLabel

@synthesize delegate;
@synthesize didTouch;
@synthesize changeAlpha,line;

- (id)initWithFrame:(CGRect)frame
{

    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        changeAlpha = NO;
        line = 0;
        _isAction = NO;
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //[super touchesBegan: touches withEvent: event];
    if(changeAlpha){
        if (CGColorEqualToColor(self.backgroundColor.CGColor, [g_theme themeColor].CGColor) ) {
            self.backgroundColor = [UIFactory maskColor:[g_theme themeColor] withMask:HEXCOLOR(0x000000) withAlpha:0.2];
        }else{
            self.alpha = 0.5;
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSLog(@"touchesMoved");
    [super touchesMoved: touches withEvent: event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //[super touchesEnded: touches withEvent: event];
    if(changeAlpha){
        if (CGColorEqualToColor(self.backgroundColor.CGColor, [UIFactory maskColor:[g_theme themeColor] withMask:HEXCOLOR(0x000000) withAlpha:0.2].CGColor) ) {
            self.backgroundColor = [g_theme themeColor];
        }else{
            self.alpha = 1;
        }
    }
    if (self.isAction) {
        return;
    }
    self.isAction = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isAction = NO;
    });
    
    BOOL inside = YES;
    for(int i=0;i<[touches count];i++){
        CGPoint p = [[[touches allObjects] objectAtIndex:i] locationInView:self];
//        NSLog(@"%d=%f,%f",i,p.x,p.y);
        if(p.x<0 || p.y <0){
            inside = NO;
            break;
        }
        if(p.x>self.frame.size.width || p.y>self.frame.size.height){
            inside = NO;
            break;
        }
    }
    if(!inside)
        return;
	if(self.delegate != nil && [self.delegate respondsToSelector:self.didTouch])
		[self.delegate performSelectorOnMainThread:self.didTouch withObject:self waitUntilDone:NO];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    //[super touchesCancelled: touches withEvent: event];
    if(changeAlpha){
        if (CGColorEqualToColor(self.backgroundColor.CGColor, [UIFactory maskColor:[g_theme themeColor] withMask:HEXCOLOR(0x000000) withAlpha:0.2].CGColor) ) {
            self.backgroundColor = [g_theme themeColor];
        }else{
            self.alpha = 1;
        }
    }
}

- (void)dealloc
{
    delegate = nil;
    didTouch = nil;
    //[_delegate release];
//    [super dealloc];
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if(line>0){
        CGContextRef ctx = UIGraphicsGetCurrentContext();
//        CGSize fontSize =[self.text sizeWithFont:self.font
//                                        forWidth:self.bounds.size.width
//                                   lineBreakMode:UILineBreakModeTailTruncation];
        CGSize fontSize = [self.text boundingRectWithSize:CGSizeMake(self.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil].size;
        
        // Get the fonts color.
        const CGFloat * colors = CGColorGetComponents(self.textColor.CGColor);
        // Sets the color to draw the line
        CGContextSetRGBStrokeColor(ctx, colors[0], colors[1], colors[2], line); // Format : RGBA
        
        [self.textColor set];
        
        // Line Width : make thinner or bigger if you want
        CGContextSetLineWidth(ctx, line);
        
        // Calculate the starting point (left) and target (right)
        CGPoint l,r;
        if (self.textAlignment == NSTextAlignmentLeft) {
            l = CGPointMake(0, self.frame.size.height/2.0 +fontSize.height/2.0);
            r = CGPointMake(fontSize.width/2.0, self.frame.size.height/2.0 + fontSize.height/2.0);
        }else if (self.textAlignment == NSTextAlignmentRight) {
            l = CGPointMake(self.frame.size.width - fontSize.width,
                            self.frame.size.height/2.0 +fontSize.height/2.0);
            r = CGPointMake(self.frame.size.width,
                            self.frame.size.height/2.0 + fontSize.height/2.0);
        }else if (self.textAlignment == NSTextAlignmentCenter) {
            l = CGPointMake(self.frame.size.width/2.0 - fontSize.width/2.0,
                            self.frame.size.height/2.0 + fontSize.height/2.0);
            r = CGPointMake(self.frame.size.width/2.0 + fontSize.width/2.0,
                            self.frame.size.height/2.0 + fontSize.height/2.0);
        }
        
        // Add Move Command to point the draw cursor to the starting point
        CGContextMoveToPoint(ctx, l.x, l.y);
        
        // Add Command to draw a Line
        CGContextAddLineToPoint(ctx, r.x, r.y);
        
        
        // Actually draw the line.
        CGContextStrokePath(ctx);
        
        // should be nothing, but who knows...
//            [super drawRect:rect];
    }
}

-(void)setDidTouch:(SEL)value{
    if(value){
        didTouch = value;
        changeAlpha = YES;
        self.userInteractionEnabled = YES;
    }

}

@end
