//
//  JXTabMenuView.m
//  sjvodios
//
//  Created by daxiong on 13-4-17.
//
//

#import "JXTabMenuView.h"
#import "JXLabel.h"
#import "JXTabButton.h"
#import "JXBadgeView.h"

@implementation JXTabMenuView
@synthesize delegate,items,height,selected,imagesNormal,imagesSelect,onClick,backgroundImageName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        int width = JX_SCREEN_WIDTH/[items count];
        height    = 49;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
//        self.image = [UIImage imageNamed:backgroundImageName];

        _arrayBtns = [[NSMutableArray alloc]init];
        
        int i;
        for(i=0;i<[items count];i++){
            CGRect r = CGRectMake(width*i, -2, width, height);
            JXTabButton *btn = [JXTabButton buttonWithType:UIButtonTypeCustom];
            btn.iconName = [imagesNormal objectAtIndex:i];
            btn.selectedIconName = [imagesSelect objectAtIndex:i];
            btn.text  = [items objectAtIndex:i];
            btn.textColor = HEXCOLOR(0x333333);
            btn.selectedTextColor = THEMECOLOR;
            btn.delegate  = self.delegate;
            btn.onDragout = self.onDragout;
//            if(i==1)
//                btn.bage = @"1";
            btn.frame = r;
            btn.tag = i;
            if ((onClick != nil) && (delegate != nil))
                [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn show];
            btn.lbBage.userInteractionEnabled = NO;
            [self addSubview:btn];
            [_arrayBtns addObject:btn];
        }

        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [self addSubview:line];
//        [line release];
    }
    return self;
}

-(void)dealloc{
//    [_arrayBtns release];
//    [items release];
//    [super dealloc];
}

-(void)onClick:(JXTabButton*)sender{
    [self unSelectAll];
    sender.selected = YES;
    self.selected = sender.tag;
	if(self.delegate != nil && [self.delegate respondsToSelector:self.onClick])
		[self.delegate performSelectorOnMainThread:self.onClick withObject:sender waitUntilDone:NO];
}

-(void)unSelectAll{
    for(int i=0;i<[_arrayBtns count];i++){
        ((JXTabButton*)[_arrayBtns objectAtIndex:i]).selected = NO;
    }
    selected = -1;
}

-(void)selectOne:(int)n{
    [self unSelectAll];
    if(n >= [_arrayBtns count])
        return;
    ((JXTabButton*)[_arrayBtns objectAtIndex:n]).selected=YES;
    selected = n;
}

-(void)setTitle:(int)n title:(NSString*)s{
    if(n >= [_arrayBtns count])
        return;
    [[_arrayBtns objectAtIndex:n] setTitle:s forState:UIControlStateNormal];
}

-(void)setBadge:(int)n title:(NSString*)s{
    if(n >= [_arrayBtns count])
        return;
    JXTabButton *btn = [_arrayBtns objectAtIndex:n];
    btn.bage = s;
    btn = nil;
}

-(void)setBadge:(int)n title:(NSString*)s isSmall:(BOOL )isSmall{
    if(n >= [_arrayBtns count])
        return;
    JXTabButton *btn = [_arrayBtns objectAtIndex:n];
    [btn updateBage:s isSmall:isSmall];
    btn = nil;
}
@end
