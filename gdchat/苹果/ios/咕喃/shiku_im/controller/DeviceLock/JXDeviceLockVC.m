//
//  JXDeviceLockVC.m
//  shiku_im
//
//  Created by p on 2019/4/2.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXDeviceLockVC.h"
#import "NumLockViewController.h"


#define HEIGHT 50
#define IMGSIZE 170
#define TAG_LABEL 1999

@interface JXDeviceLockVC ()<NumLockViewControllerDelegate>

@property (nonatomic, strong) UISwitch *setSwitch;
@property (nonatomic, assign) BOOL isSetSwitch;

@property (nonatomic, strong) JXImageView *setIV;
@property (nonatomic, strong) NumLockViewController * numLockVC;

@end

@implementation JXDeviceLockVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack   = YES;
    //self.view.frame = g_window.bounds;
    
    [self createHeadAndFoot];
    
    self.title = Localized(@"JX_EquipmentLock");
    
    int y = 0;
    JXImageView *iv = [self createButton:Localized(@"JX_Unlocking") drawTop:NO drawBottom:YES must:NO click:@selector(switchAction:) ParentView:self.tableBody];
    iv.frame = CGRectMake(0, y, JX_SCREEN_WIDTH, HEIGHT);
    y+=iv.frame.size.height;
    
    _setIV = [self createButton:Localized(@"JX_SetDeviceLockPassword") drawTop:NO drawBottom:YES must:NO click:@selector(setDeviceLockPassWord) ParentView:self.tableBody];
    _setIV.frame = CGRectMake(0, y, JX_SCREEN_WIDTH, HEIGHT);
    y+=_setIV.frame.size.height;
    
    NSString *str = [g_default stringForKey:kDeviceLockPassWord];
    if (str.length > 0) {
        _setIV.hidden = NO;
    }else {
        _setIV.hidden = YES;
    }
    
}

- (void)setDeviceLockPassWord {
    
    _numLockVC = [[NumLockViewController alloc]init];
    _numLockVC.delegate = self;
    NSString *str = [g_default stringForKey:kDeviceLockPassWord];
    if (str.length > 0) {
        self.isSetSwitch = NO;
    }else {
        self.isSetSwitch = YES;
    }
    _numLockVC.isSet = YES;
//    [self presentViewController:_numLockVC animated:YES completion:nil];
    [g_window addSubview:_numLockVC.view];
}

- (void)numLockVCSetSuccess:(NumLockViewController *)numLockVC {
    
    if (self.isSetSwitch) {
        [_setSwitch setOn:!_setSwitch.on];
        if (!_setSwitch.on) {
            [g_default removeObjectForKey:kDeviceLockPassWord];
        }
    }
    
    NSString *str = [g_default stringForKey:kDeviceLockPassWord];
    if (str.length > 0) {
        _setIV.hidden = NO;
    }else {
        _setIV.hidden = YES;
    }
}

-(JXImageView*)createButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom must:(BOOL)must click:(SEL)click ParentView:(UIView *)parent{
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    if(click)
        btn.didTouch = click;
    else
        btn.didTouch = @selector(hideKeyboard);
    btn.delegate = self;
    [parent addSubview:btn];
    //    [btn release];
    
    if(must){
        UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, 5, 20, HEIGHT-5)];
        p.text = @"*";
        p.font = g_factory.font18;
        p.backgroundColor = [UIColor clearColor];
        p.textColor = [UIColor redColor];
        p.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:p];
        //        [p release];
    }
    //前面的说明label
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(20, 0, 200, HEIGHT)];
    p.text = title;
    p.font = [UIFont boldSystemFontOfSize:16];
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    p.tag = TAG_LABEL;
    [btn addSubview:p];
    //    [p release];
    //分割线
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(15,0,JX_SCREEN_WIDTH-30,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
        //        [line release];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(15,HEIGHT-LINE_WH,JX_SCREEN_WIDTH-30,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
        //        [line release];
    }
    //这个选择器仅用于判断，之后会修改为不可点击
    SEL check = @selector(switchAction:);
    //创建switch
    if(click == check){
        UISwitch * switchView = [[UISwitch alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-51, 6, 20, 20)];

        NSString *str = [g_default stringForKey:kDeviceLockPassWord];
        if (str.length > 0) {
            [switchView setOn:YES];
        }else {
            [switchView setOn:NO];
        }
        
        switchView.onTintColor = THEMECOLOR;
        [switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [btn addSubview:switchView];
        _setSwitch = switchView;
        //取消调用switchAction
        btn.didTouch = nil;
        
    }else if(click){
        btn.frame = CGRectMake(btn.frame.origin.x -20, btn.frame.origin.y, btn.frame.size.width, btn.frame.size.height);
        
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15-7, (HEIGHT-13)/2, 7, 13)];
        iv.image = [UIImage imageNamed:@"new_icon_>"];
        [btn addSubview:iv];
        //        [iv release];
    }
    return btn;
}

-(void)switchAction:(id) sender {
    if (_setSwitch.on) {
        [_setSwitch setOn:NO];
    }else {
        [_setSwitch setOn:YES];
    }
    _numLockVC = [[NumLockViewController alloc]init];
    _numLockVC.delegate = self;
    _numLockVC.isClose = _setSwitch.on;
//    [self presentViewController:_numLockVC animated:YES completion:nil];
    [g_window addSubview:_numLockVC.view];
    self.isSetSwitch = YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
