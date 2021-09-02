//
//  menuImageView.m
//  sjvodios
//
//  Created by daxiong on 13-4-17.
//
//

#import "menuImageView.h"

@implementation menuImageView
@synthesize type,delegate,items,offset,arrayBtns,itemWidth,selected,menuFont,showSelected;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.showSelected = YES;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        arrayBtns = [[NSMutableArray alloc] init];
        if(menuFont==nil)
            self.menuFont = g_factory.font13;
        [self draw];
    }
    return self;
}

-(void)draw{
    int width=self.frame.size.width/[items count];
    int n = 0;
    int t = (self.frame.size.height-30)/2;
    UIButton* btn;
    
    btn = [self createButtonWithRect:CGRectMake(n, t, width, 30)
                               title:[items objectAtIndex:0]
                           titleFont:menuFont
                              normal:@"title_button_left"
                            selected:@"title_button_left_press"
                            selector:@selector(onClick:)
                              target:self];
    btn.tag = 0;
//    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:btn];
    [arrayBtns addObject:btn];
    
    NSInteger i;
    for(i=1;i<[items count]-1;i++){
        btn = [self createButtonWithRect:CGRectMake(n+width*i, t, width, 30)
                                   title:[items objectAtIndex:i]
                               titleFont:menuFont
                                  normal:@"title_button_middle"
                                selected:@"title_button_middle_press"
                                selector:@selector(onClick:)
                                  target:self];
        btn.tag = i;
//        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:btn];
        [arrayBtns addObject:btn];
    }
    
    i =[items count]-1;
    btn = [self createButtonWithRect:CGRectMake(n+width*i, t, width, 30)
                               title:[items objectAtIndex:i]
                           titleFont:menuFont
                              normal:@"title_button_right"
                            selected:@"title_button_right_press"//@"title_button_right_press.png"
                            selector:@selector(onClick:)
                              target:self];
    btn.tag = i;
//    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:btn];
    [arrayBtns addObject:btn];
}

-(void)dealloc{
//    [arrayBtns release];
//    [items release];
//    [super dealloc];
}

-(void)onClick:(UIButton*)sender{
    //全设为非选中
    [self unSelectAll];
    if(showSelected)
        sender.selected = YES;
    self.selected = (int)sender.tag;
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
    if(n >= [self.arrayBtns count]-1 || n < 0 )
        return;
    
    ((UIButton*)[self.arrayBtns objectAtIndex:n]).selected = YES;
    selected = n;
}

-(void)setTitle:(int)n title:(NSString*)s{
    if(n >= [self.arrayBtns count])
        return;
    [[self.arrayBtns objectAtIndex:n] setTitle:s forState:UIControlStateNormal];
}

- (UIButton *)createButtonWithRect:(CGRect)frame
                             title:(NSString *)title
                         titleFont:(UIFont *)font
                            normal:(NSString *)normalImage
                          selected:(NSString *)clickIamge
                          selector:(SEL)selector
                            target:(id)target;
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    if (title != nil)
        [button setTitle:title forState:UIControlStateNormal];
    
//    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    if (font != nil)
        [button.titleLabel setFont:font];
    
    //是发送按钮不变色
    if ([title isEqualToString:Localized(@"JX_MyRoom")]||[title isEqualToString:Localized(@"JX_AllRoom")]) {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [button.titleLabel setFont:g_factory.font16];
    }
    
    
//    UIEdgeInsets ed = {1.0f, 1.0f, 1.0f, 1.0f};
    
    if (normalImage != nil)
//        [button setBackgroundImage:[[UIImage imageNamed:normalImage] resizableImageWithCapInsets:ed resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        //拉伸
        [button setBackgroundImage:[[UIImage imageNamed:normalImage] stretchableImageWithLeftCapWidth:6 topCapHeight:6] forState:UIControlStateNormal];
//        [button setBackgroundImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    
    if (clickIamge != nil)
//        [button setBackgroundImage:[[UIImage imageNamed:clickIamge] resizableImageWithCapInsets:ed resizingMode:UIImageResizingModeStretch] forState:UIControlStateSelected];
        [button setBackgroundImage:[[UIImage imageNamed:clickIamge] stretchableImageWithLeftCapWidth:6 topCapHeight:6] forState:UIControlStateSelected];
//        [button setBackgroundImage:[UIImage imageNamed:clickIamge] forState:UIControlStateSelected];
    
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    //让“发送”按钮不被选中
    
    return button;
}

-(void)reset{
    [arrayBtns removeAllObjects];
    for(NSInteger i=[[self subviews] count]-1;i>=0;i--){
        UIView* p = [self.subviews objectAtIndex:i];
        [p removeFromSuperview];
    }
}

@end
