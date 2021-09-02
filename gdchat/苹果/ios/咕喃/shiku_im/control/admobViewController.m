//
//  admobViewController.m
//  sjvodios
//
//  Created by  on 11-12-6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "admobViewController.h"
#import "AppDelegate.h"
#import "versionManage.h"
#import "JXImageView.h"
#import "JXLabel.h"
#import "UIImage+Tint.h"


@implementation admobViewController
@synthesize heightFooter,heightHeader,leftBarButtonItem,rightBarButtonItem,tableHeader,tableFooter,isGotoBack,tableBody,footerBtnLeft,footerBtnMid,footerBtnRight,headerTitle,isFreeOnClose;

#define AdMob_REFRESH_PERIOD 60.0 // display fresh ads once per second

-(id)init{
    self = [super init];
    heightHeader=JX_SCREEN_TOP;
    heightFooter=JX_SCREEN_BOTTOM;
    isFreeOnClose = YES;
    [g_window endEditing:YES];
    //self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        heightHeader=JX_SCREEN_TOP;
        heightFooter=49;
        isFreeOnClose = YES;

    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isGotoBack) {
//        self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        
//        [self screenEdgePanGestureRecognizer];
    }
    _wait = [ATMHud sharedInstance];
    if (THESIMPLESTYLE) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
#ifdef XCode11
        if (@available(iOS 13.0, *)) {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
        } else {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        }
#else
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
#endif
//    _pSelf = self;
}


//创建边缘手势
-(void)screenEdgePanGestureRecognizer
{
    
    UIScreenEdgePanGestureRecognizer *screenPan = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(screenPanAction:)];
    screenPan.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:screenPan];
    
    [self.tableBody.panGestureRecognizer requireGestureRecognizerToFail:screenPan];
    
}
//边缘手势事件
-(void)screenPanAction:(UIScreenEdgePanGestureRecognizer *)screenPan
{
    
    CGPoint p = [screenPan translationInView:self.view];
    NSLog(@"p = %@",NSStringFromCGPoint(p));
    self.view.frame = CGRectMake(p.x, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    if (screenPan.state == UIGestureRecognizerStateEnded) {
        if (p.x > JX_SCREEN_WIDTH/2) {
            [self actionQuit];
        }else {
            [self resetViewFrame];
        }
    }
    
}

- (void)dealloc {
    NSLog(@"dealloc - %@",[self class]);
    self.title = nil;
    self.headerTitle = nil;
//    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"CurrentController = %@",[self class]);
    //页面zuo移
//    if (self.isGotoBack) {
//        if (self.view.frame.origin.x != 0) {
////            UIView *view = g_window.subviews.lastObject;
//            [UIView animateWithDuration:0.3 animations:^{
////                view.frame = CGRectMake(-85, 0, JX_SCREEN_WIDTH, self.view.frame.size.height);
//                //自己归位
//                [self resetViewFrame];
//            }];
//        }
//    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)createHeaderView{
    tableHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, heightHeader)];
    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, heightHeader)];
    
    if (THESIMPLESTYLE) {
        iv.image = [[UIImage imageNamed:@"navBarBackground"] imageWithTintColor:[UIColor whiteColor]];
//        [self LX_SetShadowPathWith:HEXCOLOR(0xD9D9D9) shadowOpacity:0.3 shadowRadius:2 shadowPathWidth:10 view:tableHeader];
    }else {
        iv.image = [g_theme themeTintImage:@"navBarBackground"];//[UIImage imageNamed:@"navBarBackground"];
    }
    iv.userInteractionEnabled = YES;
    [tableHeader addSubview:iv];
    
        
    JXLabel* p = [[JXLabel alloc]initWithFrame:CGRectMake(60, JX_SCREEN_TOP -15- 17, JX_SCREEN_WIDTH-60*2, 20)];
    p.backgroundColor = [UIColor clearColor];
    p.textAlignment   = NSTextAlignmentCenter;
    p.textColor       = THESIMPLESTYLE ? [UIColor blackColor] : [UIColor whiteColor];;
    p.text = self.title;
    p.font = [UIFont boldSystemFontOfSize:18.0];
    p.userInteractionEnabled = YES;
    p.didTouch = @selector(actionTitle:);
    p.delegate = self;
    p.changeAlpha = NO;
    [tableHeader addSubview:p];
//    [p release];

    self.headerTitle = p;
    
    if(isGotoBack){
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP - 46, 46, 46)];
        [btn setBackgroundImage:[UIImage imageNamed:@"title_back_black_big"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
        [self.tableHeader addSubview:btn];
    }
}

-(void)createFooterView{
    tableFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, heightFooter)];
    tableFooter.backgroundColor = [UIColor whiteColor];

    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,LINE_WH)];
    line.backgroundColor = THE_LINE_COLOR;
    [tableFooter addSubview:line];
    UIButton* btn;
    
    if(isGotoBack)
        return;

    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((JX_SCREEN_WIDTH-76)/2, (49-36)/2, 152/2, 72/2);
//    btn.showsTouchWhenHighlighted = YES;
    [btn setBackgroundImage:[UIImage imageNamed:@"singing_button_normal"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"singing_button_press"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(onSing) forControlEvents:UIControlEventTouchUpInside];
    [tableFooter addSubview:btn];
//    [btn release];
    self.footerBtnMid = btn;
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(JX_SCREEN_WIDTH-53-5, (49-33)/2, 53, 66/2);
//    btn.showsTouchWhenHighlighted = YES;
    [btn setBackgroundImage:[UIImage imageNamed:@"nearby_button_normal"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"nearby_button_press"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(onBtnRight) forControlEvents:UIControlEventTouchUpInside];
    [tableFooter addSubview:btn];
//    [btn release];
    self.footerBtnRight = btn;
}

-(void)createHeadAndFoot{
    int heightTotal = self.view.frame.size.height;

    if(heightHeader>0){
        [self createHeaderView];
        [self.view addSubview:tableHeader];
//        [tableHeader release];
    }
    
    if(heightFooter>0){
        [self createFooterView];
        [self.view addSubview:tableFooter];
//        [tableFooter release];
        tableFooter.frame = CGRectMake(0,heightTotal-heightFooter,self_width,heightFooter);
    }

    tableBody = [[UIScrollView alloc]init];
    tableBody.userInteractionEnabled = YES;
    tableBody.backgroundColor = [UIColor whiteColor];
    tableBody.showsVerticalScrollIndicator = NO;
    tableBody.showsHorizontalScrollIndicator = NO;
    tableBody.frame =CGRectMake(0,heightHeader,self_width,heightTotal-heightHeader-heightFooter);
    tableBody.contentSize = CGSizeMake(self_width, tableBody.frame.size.height + LINE_WH);
    [self.view addSubview:tableBody];
//    [tableBody release];
}

-(void) onGotoHome{
    if(self.view.frame.origin.x == 260){
//        [g_App.leftView onClick];
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    
    self.view.frame = CGRectMake (260, 0, self_width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}

-(void)actionQuit{
    [_wait stop];
    [g_server stopConnection:self];
    [g_window endEditing:YES];
    [g_notify removeObserver:self];
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [UIView beginAnimations:nil context:context];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIView setAnimationDuration:0.2];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(doQuit)];
    
    [g_navigation dismissViewController:self animated:YES];
    
//    self.view.frame = CGRectMake (JX_SCREEN_WIDTH, 0, self_width, self.view.frame.size.height);
//    NSInteger index = g_window.subviews.count;
//    if (index - 2 >= 0) {
//        UIView *view = g_window.subviews[index - 2];
//        view.frame = CGRectMake (0, 0, self_width, self.view.frame.size.height);
//    }
//    [UIView commitAnimations];
}

-(void)doQuit{
    [self.view removeFromSuperview];
//    if(isFreeOnClose)
//        _pSelf = nil;
}

-(void) setLeftBarButtonItem:(UIBarButtonItem*)button{
    leftBarButtonItem = button;
    button.customView.frame = CGRectMake(7, 7, 65, 30);
    [tableHeader addSubview:button.customView];
//    [button release];
}

-(void) setRightBarButtonItem:(UIBarButtonItem*)button{
    rightBarButtonItem = button;
    button.customView.frame = CGRectMake(self_width-7-65, 7, 65, 30);
    [tableHeader addSubview:button.customView];
//    [button release];
}

-(void)onSing{
//    [g_App.leftView onSing];
}

-(void)onBtnRight{
//    [g_App.leftView onNear];
}

-(void)actionTitle:(JXLabel*)sender{
    
}

-(void)setTitle:(NSString *)value{
    self.headerTitle.text = value;
    [super setTitle:value];
}

//归位
- (void)resetViewFrame{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, self.view.frame.size.height);
    }];
}



-(void)LX_SetShadowPathWith:(UIColor *)shadowColor shadowOpacity:(CGFloat)shadowOpacity shadowRadius:(CGFloat)shadowRadius shadowPathWidth:(CGFloat)shadowPathWidth
                        view:(UIView *)view {
    
    view.layer.masksToBounds = NO;
    
    view.layer.shadowColor = shadowColor.CGColor;
    
    view.layer.shadowOpacity = shadowOpacity;
    
    view.layer.shadowRadius =  shadowRadius;
    
    view.layer.shadowOffset = CGSizeZero;
    CGRect shadowRect;
    
    CGFloat originX = 0;
    
    CGFloat originW = view.bounds.size.width;
    
    CGFloat originH = view.bounds.size.height;

    shadowRect  = CGRectMake(originX, originH -shadowPathWidth/2, originW, shadowPathWidth);

    UIBezierPath *path =[UIBezierPath bezierPathWithRect:shadowRect];
    
    view.layer.shadowPath = path.CGPath;

}

@end
