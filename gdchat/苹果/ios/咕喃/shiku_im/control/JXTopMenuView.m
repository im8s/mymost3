//
//  JXTopMenuView.m
//  sjvodios
//
//  Created by daxiong on 13-4-17.
//
//

#import "JXTopMenuView.h"
#import "JXBadgeView.h"

@implementation JXTopMenuView
@synthesize delegate,items,arrayBtns,selected;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        for(int i=0;i<MAX_MENU_ITEM;i++)
            _showMore[i] = 0;
        self.backgroundColor = [UIColor clearColor];
        int width=frame.size.width/[items count];
        self.userInteractionEnabled = YES;
        
        arrayBtns = [[NSMutableArray alloc]init];
        arrayBage = [[NSMutableArray alloc]init];
        UIButton* btn;
        
        int i;
        for(i=0;i<[items count];i++){
            btn = [UIFactory createButtonWithTitle:[items objectAtIndex:i]
                                         titleFont:g_factory.font13
                                        titleColor:HEXCOLOR(0x2d2f32)
                                            normal:@"menu_bg"
                                          highlight:@"menu_bg_press"
                                          selected:@"menu_bg_bingo"];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            btn.frame = CGRectMake(i*width, 0, width, frame.size.height);
            [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i;
            [self addSubview:btn];
            [arrayBtns addObject:btn];

            JXBadgeView* p = [[JXBadgeView alloc] initWithFrame:CGRectMake(btn.frame.size.width-16-2, 2, 16, 16)];
            p.badgeString  = nil;
            p.userInteractionEnabled = NO;
            [btn addSubview:p];
//            [p release];
            
            [arrayBage addObject:p];
        }
    }
    return self;
}

-(void)dealloc{
    [arrayBage removeAllObjects];
    [arrayBtns removeAllObjects];
//    [arrayBage release];
//    [arrayBtns release];
//    [items release];
//    [super dealloc];
}

-(void)onClick:(UIButton*)sender{
    [self unSelectAll];
    sender.selected = YES;


//    NSLog(@"%d",sender.tag);
    selected = (int)sender.tag;
	if(self.delegate != nil && [self.delegate respondsToSelector:self.onClick])
		[self.delegate performSelectorOnMainThread:self.onClick withObject:sender waitUntilDone:NO];
}

-(void)unSelectAll{
    for(int i=0;i<[arrayBtns count];i++)
        ((UIButton*)[arrayBtns objectAtIndex:i]).selected = NO;
    selected = -1;
}

-(void)selectOne:(int)n{
    [self unSelectAll];
    if(n >= [self.arrayBtns count]-1 || n<0)
        return;
    ((UIButton*)[self.arrayBtns objectAtIndex:n]).selected=YES;
    selected = n;
}

-(void)setTitle:(int)n title:(NSString*)s{
    if(n >= [self.arrayBtns count])
        return;
    [[self.arrayBtns objectAtIndex:n] setTitle:s forState:UIControlStateNormal];
}

-(void)setBadge:(int)n title:(NSString*)s{
    if(n >= [self.arrayBtns count])
        return;
    [[arrayBage objectAtIndex:n] setBadgeString:s];
}

-(void)showMore:(int)index onSelected:(SEL)onSelected{
    if(index >= [self.arrayBtns count])
        return;
    _showMore[index] = 1;
    UIButton* more = [UIFactory createButtonWithImage:@"menu_normal"
                                 highlight:@"menu_press"
                                target:delegate
                                  selector:onSelected];
    more.frame = CGRectMake(self.frame.size.width/[items count]-25, 17, 10, 10);
    UIButton* btn = [self.arrayBtns objectAtIndex:index];
    [btn addSubview:more];
}

@end
