//
//  JXNavigation.m
//  shiku_im
//
//  Created by p on 2017/12/1.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXNavigation.h"
#import "UIImage+Tint.h"

@interface JXNavigation ()

@property (nonatomic, strong) UIView *tableHeader;
@property (nonatomic, assign) BOOL isReset;


@end
@implementation JXNavigation
static JXNavigation *navigation;

+(JXNavigation*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        navigation=[[JXNavigation alloc]init];
    });
    return navigation;
}
-(instancetype)init{
    self = [super init];
    if(self){
        _navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
        _navigationView.backgroundColor = [UIColor whiteColor];
        //此处添加到g_APP.window 添加到g_window 会导致push页面黑屏
        [g_App.window addSubview:_navigationView];
        _subViews = [NSMutableArray array];
        // APP从后台进入前台活跃状态
        [g_notify addObserver:self selector:@selector(applicationWillResignActive) name:kApplicationDidBecomeActive object:nil];
    }
    return self;
}

-(void)createHeaderView{
    if (self.tableHeader) {
        [self.tableHeader removeFromSuperview];
        self.tableHeader = nil;
    }
    self.tableHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_TOP)];
    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_TOP)];
    
    if (THESIMPLESTYLE) {
        iv.image = [[UIImage imageNamed:@"navBarBackground"] imageWithTintColor:[UIColor whiteColor]];
        //        [self LX_SetShadowPathWith:HEXCOLOR(0xD9D9D9) shadowOpacity:0.3 shadowRadius:2 shadowPathWidth:10 view:tableHeader];
    }else {
        iv.image = [g_theme themeTintImage:@"navBarBackground"];//[UIImage imageNamed:@"navBarBackground"];
    }
    iv.userInteractionEnabled = YES;
    [self.tableHeader addSubview:iv];
    
    JXLabel* p = [[JXLabel alloc]initWithFrame:CGRectMake(40, JX_SCREEN_TOP - 32, JX_SCREEN_WIDTH-40*2, 20)];
    p.backgroundColor = [UIColor clearColor];
    p.textAlignment   = NSTextAlignmentCenter;
    p.textColor       = [UIColor whiteColor];
    p.font = [UIFont systemFontOfSize:18.0];
    p.userInteractionEnabled = YES;
    p.didTouch = @selector(actionTitle:);
    p.delegate = self;
    p.changeAlpha = NO;
    [self.tableHeader addSubview:p];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(8, JX_SCREEN_TOP - 38, 31, 31)];
    [btn setBackgroundImage:[UIImage imageNamed:@"title_back_black_big"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
    [self.tableHeader addSubview:btn];
    
    [self.navigationView addSubview:self.tableHeader];
}
- (void)actionQuit {
    UIViewController *vc = _subViews.lastObject;
    [self dismissViewController:vc animated:YES];
}

// APP进入活跃状态
- (void)applicationWillResignActive {
    UIViewController *vc = self.subViews.lastObject;
    if (vc == self.lastVC) {
        return;
    }
    // 页面复位
    vc.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, vc.view.frame.size.height);
    self.lastVC.view.frame = CGRectMake(-JX_SCREEN_WIDTH, 0, self.lastVC.view.frame.size.width, self.lastVC.view.frame.size.height);
    [self.lastVC.view removeFromSuperview];
    vc.view.userInteractionEnabled = YES;
    self.lastVC.view.userInteractionEnabled = YES;
}

// 边缘手势
- (void)screenEdgePanGestureRecognizer:(UIViewController *)viewController{
    UIScreenEdgePanGestureRecognizer *screenPan = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(screenPanAction:)];
    screenPan.edges = UIRectEdgeLeft;
    [viewController.view addGestureRecognizer:screenPan];
    if ([viewController isKindOfClass:[admobViewController class]]) {
        admobViewController *vc = (admobViewController *)viewController;
        [vc.tableBody.panGestureRecognizer requireGestureRecognizerToFail:screenPan];
    }else if([viewController isKindOfClass:[JXTableViewController class]]) {
        JXTableViewController *vc = (JXTableViewController *)viewController;
        [vc.tableView.panGestureRecognizer requireGestureRecognizerToFail:screenPan];
    }
}

//边缘手势事件
-(void)screenPanAction:(UIScreenEdgePanGestureRecognizer *)screenPan
{
    UIViewController *vc = self.subViews.lastObject;
    
    CGPoint p = [screenPan translationInView:vc.view];      // 移动点
    CGPoint velocity = [screenPan velocityInView:vc.view];  // 移动速度
    
    // 侧滑前将上一个view添加上
    [_navigationView addSubview:self.lastVC.view];
    // 侧滑时当前view与上一个view都不触发事件
    vc.view.userInteractionEnabled = NO;
    self.lastVC.view.userInteractionEnabled = NO;
    // 滑动时实时更改当前view与上一个view的frame
    vc.view.frame = CGRectMake(p.x, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    self.lastVC.view.frame = CGRectMake(p.x - JX_SCREEN_WIDTH, 0, self.lastVC.view.frame.size.width, self.lastVC.view.frame.size.height);
    self.isReset = YES;
    
    // 滑动结束
    if (screenPan.state == UIGestureRecognizerStateEnded) {
        // 已经结束手势，禁止重置Frame
        self.isReset = NO;
        // 滑动距离大于屏幕一半 或 滑动速度大于1000
        if (p.x > JX_SCREEN_WIDTH/2 || velocity.x > 1000) {
            [UIView animateWithDuration:0.3 animations:^{
                // 滑动结束更改当前view与上一个view的frame
                vc.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, vc.view.frame.size.height);
                self.lastVC.view.frame = CGRectMake(0, 0, self.lastVC.view.frame.size.width, self.lastVC.view.frame.size.height);
            } completion:^(BOOL finished) {
                [g_server stopConnection:self];
                [_navigationView endEditing:YES];
                
                // 滑动结束时将当前view与上一个view接收触发事件
                vc.view.userInteractionEnabled = YES;
                self.lastVC.view.userInteractionEnabled = YES;
                vc.view.tag = 10000;
                
                // 如果是tableviewController 销毁header和footer
                if([vc isKindOfClass:[JXTableViewController class]]) {
                    JXTableViewController *tableVC = (JXTableViewController *)vc;
                    [tableVC actionQuit];
                    [tableVC.footer removeFromSuperview];
                    [tableVC.header removeFromSuperview];
                    tableVC.header = nil;
                    tableVC.footer = nil;
                }else if([vc isKindOfClass:[admobViewController class]]){
                    admobViewController *admobVC = (admobViewController *)vc;
                    [admobVC actionQuit];
                }
                
                // 滑动结束销毁当前view 并 重置上一个view lastVC
                if (self.subViews.count > 1) {
                    [vc.view removeFromSuperview];
                    [self.subViews removeObject:vc];
                    if (self.subViews.count > 1) {
                        self.lastVC = self.subViews[self.subViews.count - 2];
                    }
                }
                
            }];
        }else {
            
            // 没滑动到一半时处理
            [UIView animateWithDuration:0.3 animations:^{
                vc.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, vc.view.frame.size.height);
                self.lastVC.view.frame = CGRectMake(-JX_SCREEN_WIDTH, 0, self.lastVC.view.frame.size.width, self.lastVC.view.frame.size.height);
            } completion:^(BOOL finished) {
                [self.lastVC.view removeFromSuperview];
                vc.view.userInteractionEnabled = YES;
                self.lastVC.view.userInteractionEnabled = YES;
            }];
        }
    }
    
}

// 入栈
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    // 添加入栈的view
    [_navigationView addSubview:viewController.view];
    
    // 取出上一个view
    UIViewController *vc = self.subViews.lastObject;
    vc.view.userInteractionEnabled = NO;
    if (animated) { // 有动画
        //添加viewController到屏幕右侧
        viewController.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        //移动viewController到屏幕上并添加动画
        [UIView animateWithDuration:.3 animations:^{
            viewController.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        }];
    } else { // 没有动画
        // 直接设置viewController的位置
        viewController.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    }
    // 将当前控制器加入总栈
    [self.subViews addObject:viewController];
    if (self.subViews.count > 1 && animated) {
        // 更新lastVC
        self.lastVC = self.subViews[self.subViews.count - 2];
        // 创建侧滑手势
        [self screenEdgePanGestureRecognizer:viewController];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        vc.view.userInteractionEnabled = YES;
        if (self.subViews.count > 1) {
            // 销毁上一个view
            [vc.view removeFromSuperview];
        }
    });
}

// 出栈
- (void)dismissViewController:(UIViewController *)viewController animated:(BOOL)animated{
    UIViewController *vc = _subViews.lastObject;
    
    // 侧滑出栈已经处理过，，不需要下面的逻辑处理
    if (viewController.view.tag == 10000) {
        return;
    }
    
    // 如果销毁的view是最顶层的
    if (vc == viewController) {
        if (self.subViews.count >= 2) {
            vc.view.userInteractionEnabled = NO;
            // 取出上一个控制器
            UIViewController *lastVC = self.subViews[self.subViews.count - 2];
            [_navigationView addSubview:lastVC.view];
            if (animated) { //有动画
                // 先将上一个view添加到左侧屏幕外边
                lastVC.view.frame = CGRectMake(-JX_SCREEN_WIDTH, lastVC.view.frame.origin.y, lastVC.view.frame.size.width, lastVC.view.frame.size.height);
                
                [UIView animateWithDuration:0.3 animations:^{
                    // 动画将上一个view移入屏幕
                    lastVC.view.frame = CGRectMake(0, lastVC.view.frame.origin.y, lastVC.view.frame.size.width, lastVC.view.frame.size.height);
                }];
            } else { // 没有动画
                lastVC.view.frame = CGRectMake(0, lastVC.view.frame.origin.y, lastVC.view.frame.size.width, lastVC.view.frame.size.height);
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                vc.view.userInteractionEnabled = YES;
                if (self.subViews.count > 1) {
                    // 延时将当前的要销毁的view销毁
                    [vc.view removeFromSuperview];
                    [self.subViews removeObject:vc];
                    if (self.subViews.count > 1) {
                        // 更新上一个控制器lastVC
                        self.lastVC = self.subViews[self.subViews.count - 2];
                    }
                }
            });
        }else {
            [self popToRootViewController];
        }
    }else {
        // 当销毁的view不是最上层的view，直接销毁
        [viewController.view removeFromSuperview];
        [self.subViews removeObject:viewController];
        if (self.subViews.count > 1) {
            self.lastVC = self.subViews[self.subViews.count - 2];
        }
    }
}

// 跳转至根视图
- (void)popToRootViewController {
    //获取根视图并设置位置
    UIViewController *vc = self.subViews.firstObject;
    vc.view.frame = CGRectMake(0, vc.view.frame.origin.y, vc.view.frame.size.width, vc.view.frame.size.height);
    //必须添加到_navigationView，不添加会出现push页面出现在当前控制器后面的问题
    [_navigationView addSubview:vc.view];
    //移除所有视图
    for (NSInteger i = 1; i < self.subViews.count; i++) {
        UIViewController *vc = self.subViews[i];
        [vc.view removeFromSuperview];
        vc = nil;
    }
    //清空总栈
    [self.subViews removeAllObjects];
    //添加到总栈
    [self.subViews addObject:vc];
    //重置lastVC
    self.lastVC = nil;
}

// 设置根视图
- (void)setRootViewController:(UIViewController *)rootViewController {
    [self createHeaderView];
    _rootViewController = rootViewController;
    //必须添加到_navigationView，不添加会出现push页面出现在当前控制器后面的问题
    [_navigationView addSubview:rootViewController.view];
    //设置rootViewController为根视图并显示
    g_App.window.rootViewController = rootViewController;
    [g_App.window makeKeyAndVisible];
    //移除除了根视图的所以视图
    for (NSInteger i = 0; i < self.subViews.count; i++) {
        UIViewController *vc = self.subViews[i];
        [vc.view removeFromSuperview];
        vc = nil;
    }
    //清空self.subViews
    [self.subViews removeAllObjects];
    //添加到总栈
    [self.subViews addObject:rootViewController];
    //重置lastVC
    self.lastVC = nil;
}


// 指定控制器回跳(只能跳转subViews中的VC)
- (void)popToViewController:(Class)viewController animated:(BOOL)animated{
    UIViewController *vc;
    NSUInteger index;
    for (id object in self.subViews) {
        if ([object class] == viewController) {
            //获取当前控制器的坐标
            index = [self.subViews indexOfObject:object];
            //获取将要显示的控制器
            vc = self.subViews[index];
        }
    }
    if (!vc) return;
    [_navigationView addSubview:vc.view];
    if (animated) { // 有动画
        // 先将上一个view添加到左侧屏幕外边
        vc.view.frame = CGRectMake(-JX_SCREEN_WIDTH, vc.view.frame.origin.y, vc.view.frame.size.width, vc.view.frame.size.height);
        
        [UIView animateWithDuration:0.3 animations:^{
            // 动画将上一个view移入屏幕
            vc.view.frame = CGRectMake(0, vc.view.frame.origin.y, vc.view.frame.size.width, vc.view.frame.size.height);
        }];
    } else {  // 没有动画
        vc.view.frame = CGRectMake(0, vc.view.frame.origin.y, vc.view.frame.size.width, vc.view.frame.size.height);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //销毁viewController后面的控制器
        for (NSUInteger i = index + 1; i < self.subViews.count; i++) {
            UIViewController *subVC = self.subViews[i];
            [subVC.view removeFromSuperview];
        }
        //从数组中移除多余的控制器
        [self.subViews removeObjectsInRange:NSMakeRange(index + 1, self.subViews.count - index - 1)];
        //更新上一个控制器
        if (self.subViews.count > 1) {
            self.lastVC = self.subViews[index - 1];
        } else {
            self.lastVC = nil;
        }
    });
}


- (void)resetVCFrame {
    UIViewController *vc = self.subViews.lastObject;
    if (vc == self.lastVC || !self.isReset) {
        return;
    }
    // 页面复位
    vc.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, vc.view.frame.size.height);
    self.lastVC.view.frame = CGRectMake(-JX_SCREEN_WIDTH, 0, self.lastVC.view.frame.size.width, self.lastVC.view.frame.size.height);
    [self.lastVC.view removeFromSuperview];
    vc.view.userInteractionEnabled = YES;
    self.lastVC.view.userInteractionEnabled = YES;
}


@end
