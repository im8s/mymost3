//
//  PSRegisterBaseVC.m
//  shiku_im
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "PSRegisterBaseVC.h"
//#import "selectTreeVC.h"
#import "selectValueVC.h"
#import "selectProvinceVC.h"
#import "ImageResize.h"
#import "resumeData.h"
#import "JXActionSheetVC.h"
#import "JXCameraVC.h"
#import "UIView+Frame.h"

#define HEIGHT 56
#define IMGSIZE 100


@interface PSRegisterBaseVC ()<UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,JXActionSheetVCDelegate,JXCameraVCDelegate>
@property (nonatomic, strong)UIButton *selectBtn;
@property (nonatomic, strong)UIButton *manBtn;
@property (nonatomic, strong)UIButton *womanBtn;
@property (nonatomic, strong)UIButton *headBtn;
@end

@implementation PSRegisterBaseVC
@synthesize resumeId;
@synthesize resume;
@synthesize user;

- (id)init
{
    self = [super init];
    if (self) {
//        self.isGotoBack   = !self.isRegister;
        self.isGotoBack   = YES;
        if(self.isRegister){
            resume.telephone   = user.telephone;
            self.title = [NSString stringWithFormat:@"%@",Localized(@"JX_BaseInfo")];
        }
        else
            self.title = Localized(@"JX_BaseInfo");
        self.heightFooter = 0;
        self.heightHeader = 0;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self createHeadAndFoot];
//        self.tableBody.backgroundColor = HEXCOLOR(0xF2F2F2);
        self.tableBody.scrollEnabled = NO;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoardToView)];
        [self.tableBody addGestureRecognizer:tap];
        
        CGFloat scale = [UIScreen mainScreen].scale;
          CGFloat screenX = JX_SCREEN_WIDTH * scale;
          CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
           CGFloat imgVHeight = 0;
           if (statusHeight>20) {
               imgVHeight = JX_SCREEN_WIDTH*165/375;
           }else{
               imgVHeight = JX_SCREEN_WIDTH*135/375;
           }
           UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, -statusHeight, JX_SCREEN_WIDTH, imgVHeight)];
           imgV.contentMode =  UIViewContentModeScaleToFill;
           imgV.image = [UIImage imageNamed:@"login_back"];
          [self.tableBody insertSubview:imgV atIndex:0];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP-38 , 46, 46)];
        [btn setBackgroundImage:[UIImage imageNamed:@"title_back_black_big"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
        [self.tableBody addSubview:btn];
        
        UILabel *titleL = [UIFactory createLabelWith:CGRectMake((JX_SCREEN_WIDTH-200)*0.5, JX_SCREEN_TOP*0.5+8, 200, 24) text:@"完善资料"];
        titleL.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        titleL.textColor = RGB(6, 10, 20);
        titleL.textAlignment = NSTextAlignmentCenter;
        [self.tableBody addSubview:titleL];
        int h = 0;
        NSString* s;
        
        JXImageView* iv;
        iv = [[JXImageView alloc]init];
        iv.frame = self.tableBody.bounds;
        iv.delegate = self;
        iv.didTouch = @selector(hideKeyboard);
        [self.tableBody addSubview:iv];
//        [iv release];
        
//        _head = [[JXImageView alloc]initWithFrame:CGRectMake((JX_SCREEN_WIDTH-IMGSIZE)/2, JX_SCREEN_TOP+30, IMGSIZE, IMGSIZE)];
//        _head.layer.cornerRadius = IMGSIZE*0.5;
//        _head.layer.masksToBounds = YES;
//        _head.didTouch = @selector(pickImage);
//        _head.delegate = self;
//        _head.image = [UIImage imageNamed:@"register_head"];
//
//        [g_server getHeadImageSmall:s userName:resume.name imageView:_head getHeadHandler:nil];
//        [self.tableBody addSubview:_head];
        
        UIButton *headBtn = [UIButton buttonWithType:0];
        headBtn.frame =CGRectMake((JX_SCREEN_WIDTH-IMGSIZE)/2, JX_SCREEN_TOP+30, IMGSIZE, IMGSIZE);
        [headBtn setImage:[UIImage imageNamed:@"register_head"] forState:0];
        [headBtn setBackgroundImage:[UIImage createImageWithColor:RGB(228, 228, 228)] forState:UIControlStateNormal];
        [headBtn addTarget:self action:@selector(pickImage) forControlEvents:UIControlEventTouchUpInside];
        headBtn.layer.cornerRadius = IMGSIZE*0.5;
        headBtn.layer.masksToBounds = YES;
        [self.tableBody addSubview:headBtn];
        self.headBtn= headBtn;
        if(self.isRegister)
            s = user.userId;
        else
            s = g_myself.userId;
        [g_server getHeadImageSmall:s userName:resume.name imageView:_head getHeadHandler:^(BOOL isRoom, UIImage *image, NSError *error) {
            [headBtn setImage:image forState:0];
        }];
//        [_head release];
        h = headBtn.bottom+40;
 
//        iv = [self createButton:Localized(@"JX_Name") drawTop:NO drawBottom:YES must:YES click:nil];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        _name = [self createTextField:self.tableBody default:resume.name hint:@"请输入您的昵称（必填）"];
        
        _name.frame = CGRectMake(58, h, JX_SCREEN_WIDTH-58*2, HEIGHT);
        _name.textAlignment = NSTextAlignmentCenter;
        _name.font = [UIFont systemFontOfSize:16];
        
        UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(58, _name.bottom, JX_SCREEN_WIDTH-58*2, 0.5)];
        verticalLine.backgroundColor = THE_LINE_COLOR;
        [self.tableBody addSubview:verticalLine];
//        h+=iv.frame.size.height;
        [_name addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
      
        CGFloat padding = (JX_SCREEN_WIDTH-92*2-38)*0.5;
        
        UIButton *manBtn = [UIButton buttonWithType:0];
        manBtn.frame = CGRectMake(padding, iv.bottom+30, 92, 50);
        manBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [manBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [manBtn setTitleColor:RGB(151, 151, 151) forState:UIControlStateNormal];
        [manBtn setTitle:@"男" forState:0];
        [manBtn setImage:[UIImage imageNamed:@"register_man"] forState:0];
        [manBtn setBackgroundImage:[UIImage createImageWithColor:THEMECOLOR] forState:UIControlStateSelected];
        [manBtn setBackgroundImage:[UIImage createImageWithColor:RGB(228, 228, 228)] forState:UIControlStateNormal];
        
        
        [manBtn setImageEdgeInsets:UIEdgeInsetsMake(17.5, 50, 17.5, 27)];
        [manBtn setTitleEdgeInsets:UIEdgeInsetsMake(10, -35, 10, 0)];
        [manBtn addTarget:self action:@selector(chooseSex:) forControlEvents:UIControlEventTouchUpInside];
        manBtn.tag = 0;
        manBtn.layer.cornerRadius = 25;
        manBtn.layer.masksToBounds = YES;
        [self.tableBody addSubview:manBtn];
        self.manBtn = manBtn;
        
        UIButton *womanBtn = [UIButton buttonWithType:0];
        womanBtn.frame = CGRectMake(padding+92+38, iv.bottom+30, 92, 50);
        womanBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [womanBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [womanBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [womanBtn setTitle:@"女" forState:0];
        [womanBtn setImage:[UIImage imageNamed:@"register_woman"] forState:0];
         [womanBtn setBackgroundImage:[UIImage createImageWithColor:THEMECOLOR] forState:UIControlStateSelected];
         [womanBtn setBackgroundImage:[UIImage createImageWithColor:RGB(228, 228, 228)] forState:UIControlStateNormal];
        [womanBtn setImageEdgeInsets:UIEdgeInsetsMake(17.5, 50, 17.5, 27)];
        [womanBtn setTitleEdgeInsets:UIEdgeInsetsMake(10, -35, 10, 0)];
        [womanBtn addTarget:self action:@selector(chooseSex:) forControlEvents:UIControlEventTouchUpInside];
        womanBtn.tag = 1;
        womanBtn.layer.cornerRadius = 25;
        womanBtn.layer.masksToBounds = YES;
        [self.tableBody addSubview:womanBtn];
        self.womanBtn = womanBtn;

        h+=INSETS;
        UIButton* _btn;
        if(self.isRegister)
            _btn = [UIFactory createCommonButton:Localized(@"JX_NextStep") target:self action:@selector(onInsert)];
        else
            _btn = [UIFactory createCommonButton:Localized(@"JX_Update") target:self action:@selector(onUpdate)];
        _btn.layer.cornerRadius = 25;
        _btn.clipsToBounds = YES;
        _btn.custom_acceptEventInterval = .25f;
        _btn.frame = CGRectMake(58, manBtn.bottom+35, JX_SCREEN_WIDTH-58*2, 50);
        [self.tableBody addSubview:_btn];
        
        _date = [[JXDatePicker alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-200, JX_SCREEN_WIDTH, 200)];
        _date.date = [NSDate dateWithTimeIntervalSince1970:resume.birthday];
        _date.datePicker.datePickerMode = UIDatePickerModeDate;
        _date.delegate = self;
        _date.didChange = @selector(onDate:);
        _date.didSelect = @selector(onDate:);
    }
    return self;
}

-(void)dealloc{
//    NSLog(@"PSRegisterBaseVC.dealloc");
//    [_image release];
    self.resumeId = nil;
    self.user = nil;
    self.resume = nil;
    
    [_date removeFromSuperview];
//    [_date release];
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
-(void)chooseSex:(UIButton *)btn{
    
    if (self.selectBtn == nil) {
        btn.selected = YES;
        self.selectBtn = btn;
    }else {
        self.selectBtn.selected= NO;
        btn.selected = YES;
        self.selectBtn =btn;
    }
    

    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(textField == _birthday){
        [self hideKeyboard];
        [g_window addSubview:_date];
        _date.hidden = NO;
        return NO;
    }else{
        _date.hidden = YES;
        return YES;
    }
}


- (void)textDidChange:(UITextField *)textField {
    if (textField == _name) {
//        if (textField.text.length > 0) {
//            _name.frame = CGRectMake(JX_SCREEN_WIDTH/2-8,INSETS,JX_SCREEN_WIDTH/2,HEIGHT-INSETS*2);
//        }else {
//            _name.frame = CGRectMake(JX_SCREEN_WIDTH/2-15,INSETS,JX_SCREEN_WIDTH/2,HEIGHT-INSETS*2);
//        }
        [self validationText:textField];
        
    }
}
//过滤非法字符
- (NSString *)disable_Text:(NSString *)text
{
    NSLog(@"过滤--->%@",text);
    
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    //过滤emoji表情
    return [self disable_emoji:text];
}

//过滤emoj表情
- (NSString *)disable_emoji:(NSString *)text
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}

- (NSString *)validationText:(UITextField *)textField
{
    //不论中文英文,如果有空格,回车,都要过滤掉
    NSString *toBeString = [self disable_Text:textField.text];
    
    NSString *lang = [textField.textInputMode primaryLanguage];
    
    NSLog(@"%@",lang);
    
    //判断输入法
    if ([lang isEqualToString:@"zh-Hans"]) {
        
        UITextRange *selectedRange = [textField markedTextRange];
        
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        
        if (!position) {
            if (toBeString.length>=50) {
                NSString *strNew = [NSString stringWithString:toBeString];
                [textField setText:[strNew substringToIndex:50]];
            }else{
                [textField setText:toBeString];
            }
        }
        else
        {
            NSLog(@"输入的英文还没有转化为汉字的状态");
        }
        
    }
    else{
        if (toBeString.length > 50) {
            textField.text = [toBeString substringToIndex:50];
        }else{
            textField.text = toBeString;
        }
    }
    
    return textField.text;
    
}



- (IBAction)onDate:(id)sender {
    NSDate *selected = [_date date];
    _birthday.text = [TimeUtil formatDate:selected format:@"yyyy-MM-dd"];
    //    _date.hidden = YES;
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hideWithoutAnimation];
    
    if( [aDownload.action isEqualToString:act_Config]){
        
        [g_config didReceive:dict];
        
        [user copyFromResume:resume];

//        [g_server registerUser:user inviteCode:_inviteCode.text workexp:resume.workexpId diploma:resume.diplomaId isSmsRegister:self.isSmsRegister toView:self];
        g_server.temporaryPWD = self.password;
        [g_loginServer registerUserV1:user type:self.type inviteCode:_inviteCodeStr workexp:resume.workexpId diploma:resume.diplomaId isSmsRegister:self.isSmsRegister smsCode:self.smsCode password:self.password toView:self];
    }
    
    if( [aDownload.action isEqualToString:act_UploadHeadImage] ){
        [self.headBtn setImage:_image forState:0];
        _head.image = _image;
        [self.headBtn setImage:_image forState:0];
//        [_image release];
        _image = nil;
        
        if(self.isRegister){
        }else{
            [g_server delHeadImage:user.userId];
            [g_App showAlert:Localized(@"JXAlert_UpdateOK")];
        }
        [g_notify postNotificationName:kUpdateUserNotifaction object:self userInfo:nil];
        [g_notify postNotificationName:kRegisterNotifaction object:self userInfo:nil];
        [self actionQuit];
    }
    if( [aDownload.action isEqualToString:act_Register] || [aDownload.action isEqualToString:act_RegisterV1]){
        [g_default setBool:NO forKey:kTHIRD_LOGIN_AUTO];
        [g_server doLoginOK:dict user:user];
        self.user = g_server.myself;

        self.resumeId   = [(NSDictionary *)[dict objectForKey:@"cv"] objectForKey:@"resumeId"];
//        [g_server autoLogin:self];
        [g_server getUser:[[dict objectForKey:@"userId"] stringValue] toView:self];

    }
    if([aDownload.action isEqualToString:act_UserGet]){

        if ([dict objectForKey:@"settings"]) {

            g_server.myself.chatRecordTimeOut = [NSString stringWithFormat:@"%@",[(NSDictionary *)[dict objectForKey:@"settings"] objectForKey:@"chatRecordTimeOut"]];
            g_server.myself.chatSyncTimeLen = [NSString stringWithFormat:@"%@",[(NSDictionary *)[dict objectForKey:@"settings"] objectForKey:@"chatSyncTimeLen"]];
            g_server.myself.groupChatSyncTimeLen = [NSString stringWithFormat:@"%@",[(NSDictionary *)[dict objectForKey:@"settings"] objectForKey:@"groupChatSyncTimeLen"]];
            g_server.myself.friendsVerify = [NSString stringWithFormat:@"%@",[(NSDictionary *)[dict objectForKey:@"settings"] objectForKey:@"friendsVerify"]];
            g_server.myself.isEncrypt = [NSString stringWithFormat:@"%@",[(NSDictionary *)[dict objectForKey:@"settings"] objectForKey:@"isEncrypt"]];
            g_server.myself.isTyping = [NSString stringWithFormat:@"%@",[(NSDictionary *)[dict objectForKey:@"settings"] objectForKey:@"isTyping"]];
            g_server.myself.isVibration = [NSString stringWithFormat:@"%@",[(NSDictionary *)[dict objectForKey:@"settings"] objectForKey:@"isVibration"]];
            g_server.myself.multipleDevices = [NSString stringWithFormat:@"%@",[(NSDictionary *)[dict objectForKey:@"settings"] objectForKey:@"multipleDevices"]];
            g_server.myself.isUseGoogleMap = [NSString stringWithFormat:@"%@",[(NSDictionary *)[dict objectForKey:@"settings"] objectForKey:@"isUseGoogleMap"]];
            
        }
        
        
        [g_server uploadHeadImage:user.userId image:_image toView:self];
        
    }
    
    if( [aDownload.action isEqualToString:act_resumeUpdate] ){
        if(_image)
            [g_server uploadHeadImage:g_myself.userId image:_image toView:self];
        else{
            g_myself.userNickname = _name.text;
            g_myself.sex = [NSNumber numberWithInteger:_sex.selectedSegmentIndex];
            g_myself.birthday = _date.date;
            g_myself.cityId = [NSNumber numberWithInt:[_city.text intValue]];
            [g_App showAlert:Localized(@"JXAlert_UpdateOK")];
            [g_notify postNotificationName:kUpdateUserNotifaction object:self userInfo:nil];
            [self actionQuit];
        }
    }
    if ([aDownload.action isEqualToString:act_registerSDK] || [aDownload.action isEqualToString:act_registerSDKV1]) {
        [g_default setBool:YES forKey:kTHIRD_LOGIN_AUTO];
        g_server.openId = nil;
        [g_server doLoginOK:dict user:user];
        self.user = g_server.myself;
        
        self.resumeId   = [(NSDictionary *)[dict objectForKey:@"cv"] objectForKey:@"resumeId"];
        [g_server getUser:[[dict objectForKey:@"userId"] stringValue] toView:self];
    }
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hideWithoutAnimation];
    if( [aDownload.action isEqualToString:act_UploadHeadImage] ){
        _head.image = _image;
        [self.headBtn setImage:_image forState:0];
        //        [_image release];
        _image = nil;
        
        if(self.isRegister){
        }else{
            [g_server delHeadImage:user.userId];
            [g_App showAlert:Localized(@"JXAlert_UpdateOK")];
        }
        [g_notify postNotificationName:kUpdateUserNotifaction object:self userInfo:nil];
        [g_notify postNotificationName:kRegisterNotifaction object:self userInfo:nil];
        [self actionQuit];
    }
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hideWithoutAnimation];
    if( [aDownload.action isEqualToString:act_UploadHeadImage] ){
        _head.image = _image;
        [self.headBtn setImage:_image forState:0];
        //        [_image release];
        _image = nil;
        
        if(self.isRegister){
        }else{
            [g_server delHeadImage:user.userId];
            [g_App showAlert:Localized(@"JXAlert_UpdateOK")];
        }
        [g_notify postNotificationName:kUpdateUserNotifaction object:self userInfo:nil];
        [g_notify postNotificationName:kRegisterNotifaction object:self userInfo:nil];
        [self actionQuit];
    }
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait startWithouAnimation];
}

-(JXImageView*)createButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom must:(BOOL)must click:(SEL)click{
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    if(click)
        btn.didTouch = click;
    else
        btn.didTouch = @selector(hideKeyboard);
    btn.delegate = self;
    [self.tableBody addSubview:btn];
    
//    if(must){
//        UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, 5, 20, HEIGHT-5)];
//        p.text = @"*";
//        p.font = g_factory.font18;
//        p.backgroundColor = [UIColor clearColor];
//        p.textColor = [UIColor redColor];
//        p.textAlignment = NSTextAlignmentCenter;
//        [btn addSubview:p];
//    }
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(15, 0, 130, HEIGHT)];
    p.text = title;
    p.font = g_factory.font16;
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    [btn addSubview:p];
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(15,0,JX_SCREEN_WIDTH-15,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(15,HEIGHT-LINE_WH,JX_SCREEN_WIDTH-15,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15-7, (HEIGHT-13)/2, 7, 13)];
        iv.image = [UIImage imageNamed:@"new_icon_>"];
        [btn addSubview:iv];
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
    p.textAlignment = NSTextAlignmentCenter;
    p.textColor = HEXCOLOR(0x666666);
    p.userInteractionEnabled = YES;
    p.text = s;
    p.placeholder = hint;
    p.font = g_factory.font16;
    [parent addSubview:p];

    return p;
}

-(UILabel*)createLabel:(UIView*)parent default:(NSString*)s{
    UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2 -30 ,INSETS,JX_SCREEN_WIDTH/2,HEIGHT-INSETS*2)];
    p.userInteractionEnabled = NO;
    p.text = s;
    p.font = g_factory.font15;
    p.textAlignment = NSTextAlignmentRight;
    [parent addSubview:p];
//    [p release];
    return p;
}

-(void)onWorkexp{
    if([self hideKeyboard])
        return;
    
    selectValueVC* vc = [selectValueVC alloc];
    vc.values = g_constant.workexp_name;
    vc.selNumber = resume.workexpId;
    vc.numbers   = g_constant.workexp_value;
    vc.delegate  = self;
    vc.didSelect = @selector(onSelWorkExp:);
    vc.quickSelect = YES;
    vc = [vc init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onDiploma{
    if([self hideKeyboard])
        return;
    
    selectValueVC* vc = [selectValueVC alloc];
    vc.values = g_constant.diploma_name;
    vc.selNumber = resume.diplomaId;
    vc.numbers   = g_constant.diploma_value;
    vc.delegate  = self;
    vc.didSelect = @selector(onSelDiploma:);
    vc.quickSelect = YES;
    vc = [vc init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onCity{
    if([self hideKeyboard])
        return;
    
    selectProvinceVC* vc = [selectProvinceVC alloc];
    vc.delegate = self;
    vc.didSelect = @selector(onSelCity:);
    vc.showCity = YES;
    vc.showArea = NO;
    vc.parentId = 1;
    vc = [vc init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onSelCity:(selectProvinceVC*)sender{
    resume.cityId = sender.cityId;
    resume.provinceId = sender.provinceId;
    resume.areaId = sender.areaId;
    resume.countryId = 1;
    _city.text = sender.selValue;
}

-(void)onSelDiploma:(selectValueVC*)sender{
    resume.diplomaId = sender.selNumber;
    _dip.text = sender.selValue;
}

-(void)onSelWorkExp:(selectValueVC*)sender{
    resume.workexpId = sender.selNumber;
    _workexp.text = sender.selValue;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _image = [ImageResize image:[info objectForKey:@"UIImagePickerControllerEditedImage"] fillSize:CGSizeMake(640, 640)];
//    [_image retain];
    _head.image = _image;
    [self.headBtn setImage:_image forState:0];
//    [picker.view removeFromSuperview];
    [picker dismissViewControllerAnimated:YES completion:nil];
    //	[self dismissModalViewControllerAnimated:YES];
//	[picker release];
}

- (void) pickImage
{
    [self hideKeyboard];
    
    JXActionSheetVC *actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:@[Localized(@"JX_ChoosePhoto"),Localized(@"JX_TakePhoto")]];
    actionVC.delegate = self;
    [self presentViewController:actionVC animated:NO completion:nil];
    
	UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
	ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
	ipc.delegate = self;
	ipc.allowsEditing = YES;
    ipc.modalPresentationStyle = UIModalPresentationFullScreen;
//    [g_window addSubview:ipc.view];
    if (IS_PAD) {
        UIPopoverController *pop =  [[UIPopoverController alloc] initWithContentViewController:ipc];
        [pop presentPopoverFromRect:CGRectMake((self.view.frame.size.width - 320) / 2, 0, 300, 300) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }else {
        [self presentViewController:ipc animated:YES completion:nil];
    }
}
- (void)actionSheet:(JXActionSheetVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    if (index == 0) {
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        ipc.delegate = self;
        ipc.allowsEditing = YES;
        //选择图片模式
        ipc.modalPresentationStyle = UIModalPresentationCurrentContext;
        //    [g_window addSubview:ipc.view];
        if (IS_PAD) {
            UIPopoverController *pop =  [[UIPopoverController alloc] initWithContentViewController:ipc];
            [pop presentPopoverFromRect:CGRectMake((self.view.frame.size.width - 320) / 2, 0, 300, 300) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }else {
            [self presentViewController:ipc animated:YES completion:nil];
        }
        
    }else {
        JXCameraVC *vc = [JXCameraVC alloc];
        vc.cameraDelegate = self;
        vc.isPhoto = YES;
        vc = [vc init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)cameraVC:(JXCameraVC *)vc didFinishWithImage:(UIImage *)image {
    _image = [ImageResize image:image fillSize:CGSizeMake(640, 640)];
    //    [_image retain];
    _head.image = _image;
    [self.headBtn setImage:_image forState:0];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
//    [picker.view removeFromSuperview];
    [picker dismissViewControllerAnimated:YES completion:nil];
//    [picker release];
    //	[self dismissModalViewControllerAnimated:YES];
}

-(void)onUpdate{
    if(![self getInputValue])
        return;
//    NSString* s = [g_server jsonFromObject:[resume setDataToDict]];
//    [g_server updateResume:resumeId nodeName:@"p" text:s toView:self];
}

-(void)onInsert{
    if(![self getInputValue])
        return;
    
    [g_server getSetting:self];
}

-(BOOL)getInputValue{
    if (self.selectBtn == nil) {
        return NO;
    }
    if(_image==nil && self.isRegister){
        [g_App showAlert:Localized(@"JX_SetHead")];
        return NO;
    }
    if([_name.text length]<=0){
        [g_App showAlert:Localized(@"JX_InputName")];
        return NO;
    }
    if(!self.isRegister){
        if(resume.workexpId<=0){
            [g_App showAlert:Localized(@"JX_InputWorking")];
            return NO;
        }
        if(resume.diplomaId<=0){
            [g_App showAlert:Localized(@"JX_School")];
            return NO;
        }
        if(resume.cityId<=0){
            [g_App showAlert:Localized(@"JX_Live")];
            return NO;
        }
    }
    
//    else {
//        if ([g_config.registerInviteCode intValue] == 1) {
//            if ([_inviteCode.text length] <= 0) {
//                [g_App showAlert:Localized(@"JX_EnterInvitationCode")];
//                return NO;
//            }
//        }
//    }
    resume.name = _name.text;
    resume.birthday = [_date.date timeIntervalSince1970];
    
    resume.sex = self.selectBtn.tag;
    return  YES;
}

-(BOOL)hideKeyboard{
    BOOL b = _name.editing || _pwd.editing || _repeat.editing;
    _date.hidden = YES;
    [self.view endEditing:YES];
    return b;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}
- (void)hideKeyBoardToView {
    [self.view endEditing:YES];
}

@end
