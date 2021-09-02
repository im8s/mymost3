//
//  inputPwdVC.m
//  shiku_im
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "inputPwdVC.h"
#import "PSRegisterBaseVC.h"
#import "resumeData.h"

#define HEIGHT 44


@interface inputPwdVC ()<UITextFieldDelegate>

@end

@implementation inputPwdVC
@synthesize telephone;

- (id)init
{
    self = [super init];
    if (self) {
        self.isGotoBack   = YES;
        self.title = [NSString stringWithFormat:@"%@",Localized(@"JX_PassWord")];
        self.heightFooter = 0;
        self.heightHeader = JX_SCREEN_TOP;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self createHeadAndFoot];
        self.tableBody.backgroundColor = HEXCOLOR(0xF2F2F2);
        int n = INSETS;
        
        _pwd = [[UITextField alloc] initWithFrame:CGRectMake(INSETS,n,WIDTH,HEIGHT)];
        _pwd.delegate = self;
        _pwd.autocorrectionType = UITextAutocorrectionTypeNo;
        _pwd.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _pwd.enablesReturnKeyAutomatically = YES;
        _pwd.borderStyle = UITextBorderStyleRoundedRect;
        _pwd.returnKeyType = UIReturnKeyDone;
        _pwd.clearButtonMode = UITextFieldViewModeWhileEditing;
        _pwd.placeholder = Localized(@"JX_InputPassWord");
        _pwd.secureTextEntry = YES;
        [self.tableBody addSubview:_pwd];
        //        [_pwd release];
        n = n+HEIGHT+INSETS;
        
        _repeat = [[UITextField alloc] initWithFrame:CGRectMake(INSETS,n,WIDTH,HEIGHT)];
        _repeat.delegate = self;
        _repeat.autocorrectionType = UITextAutocorrectionTypeNo;
        _repeat.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _repeat.enablesReturnKeyAutomatically = YES;
        _repeat.borderStyle = UITextBorderStyleRoundedRect;
        _repeat.returnKeyType = UIReturnKeyDone;
        _repeat.clearButtonMode = UITextFieldViewModeWhileEditing;
        _repeat.placeholder = Localized(@"JX_ConfirmPassWord");
        _repeat.secureTextEntry = YES;
        [self.tableBody addSubview:_repeat];
        //        [_repeat release];
        n = n+HEIGHT+INSETS;
        
        
        UIButton* _btn = [UIFactory createCommonButton:Localized(@"JX_NextStep") target:self action:@selector(onClick)];
        _btn.custom_acceptEventInterval = .25f;
        _btn.frame = CGRectMake(INSETS, n, WIDTH, HEIGHT);
        [self.tableBody addSubview:_btn];
        
    }
    return self;
}

-(void)dealloc{
    //    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)onClick{
    if([_pwd.text length]<=0){
        [g_App showAlert:Localized(@"JX_InputPassWord")];
        return;
    }
    if([_repeat.text length]<=0){
        [g_App showAlert:Localized(@"JX_ConfirmPassWord")];
        return;
    }
    if(![_pwd.text isEqualToString:_repeat.text]){
        [g_App showAlert:Localized(@"JX_PasswordFiled")];
        return;
    }
    
    JXUserObject* user = [JXUserObject sharedInstance];
    user.telephone = telephone;
    user.password  = [g_server getMD5String:_pwd.text];
    user.companyId = [NSNumber numberWithInt:self.isCompany];
    
    PSRegisterBaseVC* vc = [PSRegisterBaseVC alloc];
    vc.password = _pwd.text;
    vc.isRegister = YES;
    vc.resumeId   = nil;
    vc.resume     = [[resumeBaseData alloc]init];
    
    vc.user       = user;
    
    vc = [vc init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
    
    //    [user release];
    [self actionQuit];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

@end
