//
//  JXSearchUserVC.m
//  shiku_im
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXSearchUserVC.h"
//#import "selectTreeVC.h"
#import "selectProvinceVC.h"
#import "selectValueVC.h"
#import "ImageResize.h"
#import "searchData.h"
#import "JXSearchUserListVC.h"

#define HEIGHT 44
#define STARTTIME_TAG 1
#define IMGSIZE 100

@interface JXSearchUserVC ()<UITextFieldDelegate>

@end

@implementation JXSearchUserVC
@synthesize job,delegate,didSelect;

- (id)init
{
    self = [super init];
    if (self) {
        job = [[searchData alloc] init];
        self.isGotoBack   = YES;
        if (self.type == JXSearchTypeUser) {
            self.title = Localized(@"JXNearVC_AddFriends");
        }else {
            self.title = Localized(@"JX_SearchPublicNumber");
        }
        self.heightFooter = 0;
        self.heightHeader = JX_SCREEN_TOP;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self createHeadAndFoot];
        
        int h = 0;
        _values = [[NSMutableArray alloc]initWithObjects:Localized(@"JXSearchUserVC_AllDate"),Localized(@"JXSearchUserVC_OneDay"),Localized(@"JXSearchUserVC_TwoDay"),Localized(@"JXSearchUserVC_ThereDay"),Localized(@"JXSearchUserVC_OneWeek"),Localized(@"JXSearchUserVC_TwoWeek"),Localized(@"JXSearchUserVC_OneMonth"),Localized(@"JXSearchUserVC_SixWeek"),Localized(@"JXSearchUserVC_TwoMonth"),nil];
        _numbers = [[NSMutableArray alloc]initWithObjects:@"0",@"1",@"2",@"3",@"7",@"14",@"30",@"42",@"60",nil];
        
//        NSString* city = [g_constant getAddressForNumber:g_myself.provinceId cityId:g_myself.cityId areaId:g_myself.areaId];
        job.sex    = -1;
        
        JXImageView* iv;
        
        NSString *name;
        NSString *phoneN;
        NSString *input;
        if (self.type == JXSearchTypeUser) {
            if ([g_config.nicknameSearchUser intValue] != 0 && [g_config.regeditPhoneOrName intValue] == 0) {
                name = Localized(@"JX_NickName");
                phoneN = Localized(@"JX_OrPhoneNumber");
                input = Localized(@"JX_InputNickName");
            }else if([g_config.nicknameSearchUser intValue] == 0 && [g_config.regeditPhoneOrName intValue] == 0) {
                name = Localized(@"JX_SearchPhoneNumber");
                phoneN = @"";
                input = Localized(@"JX_InputPhone");
            }else if ([g_config.nicknameSearchUser intValue] == 0 && [g_config.regeditPhoneOrName intValue] == 1) {
                name = Localized(@"JX_UserName");
                phoneN = @"";
                input = Localized(@"JX_InputUserAccount");
            }else {
                name = Localized(@"JX_NickName");
                phoneN = Localized(@"JX_SearchOrUserName");
                input = Localized(@"JX_InputNickName");
            }
        }else {
            name = @"";
            phoneN = Localized(@"JX_PublicNumber");
            input = Localized(@"JX_PleaseEnterThe");
        }
        
        iv = [self createButton:[NSString stringWithFormat:@"%@%@",name,phoneN] drawTop:NO drawBottom:YES must:NO click:nil];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        _name = [self createTextField:iv default:job.name hint:[NSString stringWithFormat:@"%@%@",input,phoneN]];
        [_name becomeFirstResponder];
        h+=iv.frame.size.height;
        
        /*
        iv = [self createButton:Localized(@"JX_Sex") drawTop:NO drawBottom:YES must:NO click:@selector(onSex)];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        _sex = [self createLabel:iv default:Localized(@"JXSearchUserVC_All")];
        h+=iv.frame.size.height;
        
        iv = [self createButton:Localized(@"JXSearchUserVC_MinAge") drawTop:NO drawBottom:YES must:NO click:nil];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        _minAge = [self createTextField:iv default:@"0" hint:Localized(@"JXSearchUserVC_MinAge")];
        h+=iv.frame.size.height;
        
        iv = [self createButton:Localized(@"JXSearchUserVC_MaxAge") drawTop:NO drawBottom:YES must:NO click:nil];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        _maxAge = [self createTextField:iv default:@"200" hint:Localized(@"JXSearchUserVC_MaxAge")];
        h+=iv.frame.size.height;
        
        iv = [self createButton:Localized(@"JXSearchUserVC_AppearTime") drawTop:NO drawBottom:YES must:NO click:@selector(onDate)];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        _date = [self createLabel:iv default:[_values objectAtIndex:0]];
        h+=iv.frame.size.height;
        */
        h+=30;
        UIButton* _btn;
        _btn = [UIFactory createCommonButton:Localized(@"JX_Seach") target:self action:@selector(onSearch)];
        _btn.custom_acceptEventInterval = .25f;
        _btn.frame = CGRectMake(15, h, JX_SCREEN_WIDTH-30, 40);
        _btn.titleLabel.font = SYSFONT(16);
        _btn.layer.masksToBounds = YES;
        _btn.layer.cornerRadius = 7.f;
        [self.tableBody addSubview:_btn];
        
    }
    return self;
}

-(void)dealloc{
//    NSLog(@"JXSearchUserVC.dealloc");
    self.job = nil;
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
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
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

-(UILabel*)createLabel:(UIView*)parent default:(NSString*)s{
    UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2,INSETS,JX_SCREEN_WIDTH/2 - 30,HEIGHT-INSETS*2)];
    p.userInteractionEnabled = NO;
    p.text = s;
    p.font = g_factory.font14;
    p.textAlignment = NSTextAlignmentRight;
    [parent addSubview:p];
//    [p release];
    return p;
}

-(void)onSex{
    if([self hideKeyboard])
        return;
    
    selectValueVC* vc = [selectValueVC alloc];
    vc.values = [NSMutableArray arrayWithObjects:Localized(@"JXSearchUserVC_All"),Localized(@"JX_Man"),Localized(@"JX_Wuman"),nil];
    vc.selNumber = 0;
    vc.numbers   = [NSMutableArray arrayWithObjects:@"-1",@"1",@"0",nil];
    vc.delegate  = self;
    vc.didSelect = @selector(onSelSex:);
    vc.quickSelect = YES;
    vc = [vc init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onSelSex:(selectValueVC*)sender{
    if([self hideKeyboard])
        return;
    
    _sex.text  = sender.selValue;
    job.sex    = sender.selNumber;
}

-(void)onDate{
    if([self hideKeyboard])
        return;
    
    selectValueVC* vc = [selectValueVC alloc];
    vc.values = _values;
    vc.selNumber = 0;
    vc.numbers   = _numbers;
    vc.delegate  = self;
    vc.didSelect = @selector(onSelDate:);
    vc.quickSelect = YES;
    vc = [vc init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onSelDate:(selectValueVC*)sender{
    job.showTime = sender.selNumber;
    _date.text = sender.selValue;
}

-(void)onSearch{
    if ([_name.text isEqualToString:@""]) {
        if (self.type == JXSearchTypeUser) {
            if ([g_config.nicknameSearchUser intValue] == 0 && [g_config.regeditPhoneOrName intValue] == 0) {
                [g_App showAlert:Localized(@"JX_InputPhone")];
            }else if ([g_config.nicknameSearchUser intValue] == 0 && [g_config.regeditPhoneOrName intValue] == 1){
                [g_App showAlert:Localized(@"JX_InputUserAccount")];
            }else {
                [g_App showAlert:Localized(@"JX_InputNickName")];
            }
        }else {
            [g_App showAlert:Localized(@"JX_PleaseEnterTheServerNo.")];
        }
    }else{
        job.name = _name.text;
        job.minAge = [_minAge.text intValue];
        job.maxAge = [_maxAge.text intValue];
        [self actionQuit];
        JXSearchUserListVC *vc = [[JXSearchUserListVC alloc] init];
        if (self.type == JXSearchTypeUser) {
            vc.isUserSearch = YES;
        }else {
            vc.isUserSearch = NO;
        }
        vc.keyWorld = _name.text;
        vc.search = job;
        [g_navigation pushViewController:vc animated:YES];
//        if (delegate && [delegate respondsToSelector:didSelect])
////            [delegate performSelector:didSelect withObject:job];
//            [delegate performSelectorOnMainThread:didSelect withObject:job waitUntilDone:NO];
    }
    
}

-(BOOL)hideKeyboard{
    BOOL b = _name.editing;
    [self.view endEditing:YES];
    return b;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

@end
