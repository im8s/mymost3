//
//  JXCommonInputVC.m
//  shiku_im
//
//  Created by p on 2019/4/1.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXCommonInputVC.h"

#define HEIGHT 44
#define STARTTIME_TAG 1
#define IMGSIZE 100

@interface JXCommonInputVC ()<UITextFieldDelegate>


@end

@implementation JXCommonInputVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isGotoBack   = YES;
    self.title = self.titleStr;
    self.heightFooter = 0;
    self.heightHeader = JX_SCREEN_TOP;
    //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    [self createHeadAndFoot];
    
    int h = 0;
    JXImageView *iv = [self createButton:self.subTitle drawTop:NO drawBottom:YES must:NO click:nil];
    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _name = [self createTextField:iv default:nil hint:self.tip];
    [_name becomeFirstResponder];
    h+=iv.frame.size.height;

    h+=30;
    UIButton* _btn;
    _btn = [UIFactory createCommonButton:self.btnTitle target:self action:@selector(onSearch)];
    _btn.custom_acceptEventInterval = .25f;
    _btn.layer.masksToBounds = YES;
    _btn.layer.cornerRadius = 7.f;
    _btn.frame = CGRectMake(15, h, JX_SCREEN_WIDTH-30, 40);
    [self.tableBody addSubview:_btn];
}

- (void)onSearch {
    
    [self actionQuit];
    
    if ([self.delegate respondsToSelector:@selector(commonInputVCBtnActionWithVC:)]) {
        [self.delegate commonInputVCBtnActionWithVC:self];
    }
    
}

-(JXImageView*)createButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom must:(BOOL)must click:(SEL)click{
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.delegate = self;
    if(click)
        btn.didTouch = click;
    else
        btn.didTouch = @selector(hideKeyboard);
    [self.tableBody addSubview:btn];
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
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(20, 0, JX_SCREEN_WIDTH/2-40, HEIGHT)];
    p.text = title;
    p.font = g_factory.font16;
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    [btn addSubview:p];
    //    [p release];
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
        //        [line release];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,HEIGHT-LINE_WH,JX_SCREEN_WIDTH,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
        //        [line release];
    }
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15-7, (HEIGHT-13)/2, 7, 13)];
        iv.image = [UIImage imageNamed:@"new_icon_>"];
        [btn addSubview:iv];
        //        [iv release];
    }
    return btn;
}

-(UITextField*)createTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint{
    UITextField* p = [[UITextField alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2,INSETS,JX_SCREEN_WIDTH/2-15,HEIGHT-INSETS*2)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.borderStyle = UITextBorderStyleNone;
    p.returnKeyType = UIReturnKeyDone;
    p.clearButtonMode = UITextFieldViewModeWhileEditing;
    p.textAlignment = NSTextAlignmentRight;
    p.userInteractionEnabled = YES;
    p.text = s;
    p.placeholder = hint;
    p.font = g_factory.font16;
    [parent addSubview:p];
    //    [p release];
    return p;
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
