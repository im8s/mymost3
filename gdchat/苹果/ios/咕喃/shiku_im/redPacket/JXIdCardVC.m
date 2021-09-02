//
//  JXIdCardVC.m
//  shiku_im
//
//  Created by 1 on 2019/11/7.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXIdCardVC.h"

#define HEIGHT 56


@interface JXIdCardVC () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *name;
@property (nonatomic, strong) UITextField *idCard;
@property (nonatomic, strong) UITextField *telephone;


// 短信验证码
@property (nonatomic, strong) UITextField *imgCode;   //图片验证码
@property (nonatomic, strong) UIImageView *imgCodeImg;
@property (nonatomic, strong) UIButton *graphicButton;
@property (nonatomic, strong) UITextField *code;
@property (nonatomic, strong) UIButton *send;
@property (nonatomic, strong) NSString *smsCode;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int seconds;

@property (nonatomic, strong) UIButton *skipBtn;
@property (nonatomic, assign) int isSkipSMS;
@property (nonatomic, assign) int isSendFirst;


@end

@implementation JXIdCardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack = YES;
    [self createHeadAndFoot];

    self.title = Localized(@"JX_OpenAccount");
    self.tableBody.backgroundColor = HEXCOLOR(0xF2F2F2);
    
    
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, HEIGHT*5)];
    baseView.backgroundColor = [UIColor whiteColor];
    [self.tableBody addSubview:baseView];
    
    
    int h = 0;
    int distance = 20; // 左右间距
    JXImageView* iv;

    iv = [self createButton:Localized(@"JX_RealName") drawTop:NO drawBottom:YES must:NO click:nil];
    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _name = [self createTextField:iv default:nil hint:Localized(@"JX_PleaseEnterYourRealName")];
    h+=iv.frame.size.height;

    iv = [self createButton:Localized(@"JX_IDNumber") drawTop:NO drawBottom:YES must:NO click:nil];
    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _idCard = [self createTextField:iv default:nil hint:Localized(@"JX_PleaseEnterIDNumber")];
    h+=iv.frame.size.height;
    
    iv = [self createButton:Localized(@"JX_MobilePhoneNo.") drawTop:NO drawBottom:YES must:NO click:nil];
    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _telephone = [self createTextField:iv default:nil hint:Localized(@"JX_InputPhone")];
    _telephone.keyboardType = UIKeyboardTypePhonePad;
    h+=iv.frame.size.height;

    
    
    //图片验证码
    _imgCode = [UIFactory createTextFieldWith:CGRectMake(distance, h, self_width-distance*2-70-INSETS-35-4, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:Localized(@"JX_inputImgCode") font:g_factory.font16];
    _imgCode.placeholder = Localized(@"JX_inputImgCode");
    _imgCode.borderStyle = UITextBorderStyleNone;
    _imgCode.clearButtonMode = UITextFieldViewModeWhileEditing;
    _imgCode.backgroundColor = [UIColor whiteColor];
    _imgCode.textAlignment = NSTextAlignmentRight;
    [self.tableBody addSubview:_imgCode];
    
    UIView *imCView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 37, HEIGHT)];
    _imgCode.leftView = imCView;
    _imgCode.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *imCIView = [[UILabel alloc] initWithFrame:CGRectMake(2, HEIGHT/2-11, 100, 22)];
    imCIView.text = @"图形码";
    imCIView.font = SYSFONT(16);
    [imCView addSubview:imCIView];

    UIView *imCLine = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-LINE_WH, JX_SCREEN_WIDTH, LINE_WH)];
    imCLine.backgroundColor = THE_LINE_COLOR;
    [_imgCode addSubview:imCLine];
    
    _imgCodeImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_imgCode.frame)+INSETS, 0, 70, 35)];
    _imgCodeImg.center = CGPointMake(_imgCodeImg.center.x, _imgCode.center.y);
    _imgCodeImg.userInteractionEnabled = YES;
    [self.tableBody addSubview:_imgCodeImg];
    
    UIView *imgCodeLine = [[UIView alloc] initWithFrame:CGRectMake(_imgCodeImg.frame.size.width, 3, LINE_WH, _imgCodeImg.frame.size.height-6)];
    imgCodeLine.backgroundColor = THE_LINE_COLOR;
    [_imgCodeImg addSubview:imgCodeLine];
    
    _graphicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _graphicButton.frame = CGRectMake(CGRectGetMaxX(_imgCodeImg.frame)+6, 7, 26, 26);
    _graphicButton.center = CGPointMake(_graphicButton.center.x,_imgCode.center.y);
    [_graphicButton setBackgroundImage:[UIImage imageNamed:@"refreshGraphic"] forState:UIControlStateNormal];
    [_graphicButton setBackgroundImage:[UIImage imageNamed:@"refreshGraphic"] forState:UIControlStateHighlighted];
    [_graphicButton addTarget:self action:@selector(refreshGraphicAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableBody addSubview:_graphicButton];
    
    h = h+HEIGHT;
    
    _code = [[UITextField alloc] initWithFrame:CGRectMake(distance, h, JX_SCREEN_WIDTH-75-distance*2, HEIGHT)];
    _code.placeholder = Localized(@"JX_InputMessageCode");
    _code.font = g_factory.font16;
    _code.delegate = self;
    _code.autocorrectionType = UITextAutocorrectionTypeNo;
    _code.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _code.enablesReturnKeyAutomatically = YES;
    _code.borderStyle = UITextBorderStyleNone;
    _code.textAlignment = NSTextAlignmentRight;
    _code.returnKeyType = UIReturnKeyDone;
    _code.clearButtonMode = UITextFieldViewModeWhileEditing;
    _code.backgroundColor = [UIColor whiteColor];

    UIView *codeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 37, HEIGHT)];
    _code.leftView = codeView;
    _code.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *codeIView = [[UILabel alloc] initWithFrame:CGRectMake(2, HEIGHT/2-11, 100, 22)];
    codeIView.text = @"短信验证码";
    codeIView.font = SYSFONT(16);
    [codeView addSubview:codeIView];
    
    
    [self.tableBody addSubview:_code];
    
    _send = [UIFactory createButtonWithTitle:Localized(@"JX_Send")
                                   titleFont:g_factory.font16
                                  titleColor:[UIColor whiteColor]
                                      normal:nil
                                   highlight:nil];
    _send.frame = CGRectMake(JX_SCREEN_WIDTH-70-11, h+HEIGHT/2-15, 70, 30);
    [_send addTarget:self action:@selector(sendSMS) forControlEvents:UIControlEventTouchUpInside];
    _send.backgroundColor = g_theme.themeColor;
    UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
    [_send setBackgroundImage:img forState:UIControlStateHighlighted];
    _send.layer.masksToBounds = YES;
    _send.layer.cornerRadius = 7.f;
    
    [self.tableBody addSubview:_send];
    
    h = h+HEIGHT;
    

    UIButton *btn = [UIFactory createCommonButton:Localized(@"JX_OpenAccount") target:self action:@selector(openUserBankCard)];
    //    [btn setBackgroundImage:nil forState:UIControlStateHighlighted];
    btn.custom_acceptEventInterval = 1.f;
    btn.frame = CGRectMake(15,h+20, JX_SCREEN_WIDTH-30, 40);
    [btn setBackgroundImage:nil forState:UIControlStateNormal];
    btn.backgroundColor = THEMECOLOR;
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 7.f;
    [self.tableBody addSubview:btn];


}

#pragma mark - 开户
- (void)openUserBankCard {
    if (_name.text.length <= 0) {
        [JXMyTools showTipView:Localized(@"JX_PleaseEnterYourRealName")];
        return;
    }
    if (_idCard.text.length <= 0) {
        [JXMyTools showTipView:Localized(@"JX_PleaseEnterIDNumber")];
        return;
    }
    if (_telephone.text.length <= 0) {
        [JXMyTools showTipView:Localized(@"JX_InputPhone")];
        return;
    }
    if([_code.text length]<6){
        if([_code.text length]<=0){
            [g_App showAlert:Localized(@"JX_InputMessageCode")];
            return;
        }
        [g_App showAlert:Localized(@"inputPhoneVC_MsgCodeNotOK")];
        return;
    }

    
    [g_server openAccount:_name.text certificateNo:_idCard.text mobile:_telephone.text areaCode:@"86" smsCode:_code.text toView:self];
}

-(void)refreshGraphicAction:(UIButton *)button{
    [self getImgCodeImg];
    
}

//验证手机号格式
- (void)sendSMS{
    [_telephone resignFirstResponder];
    [_imgCode resignFirstResponder];
    [_code resignFirstResponder];
    
    if([self isMobileNumber:_telephone.text]){
        //请求验证码
        if (_imgCode.text.length < 3) {
            [g_App showAlert:Localized(@"JX_inputImgCode")];
        }else {
            if (!_send.selected) {
                [_wait start:Localized(@"JX_Testing")];
                NSString *areaCode = [@"86" stringByReplacingOccurrencesOfString:@"+" withString:@""];
                [g_server yopPaySendSms:[NSString stringWithFormat:@"%@",_telephone.text] areaCode:areaCode imgCode:_imgCode.text toView:self];
                [_send setTitle:Localized(@"JX_Sending") forState:UIControlStateNormal];
            }

        }
    }
}

-(void)getImgCodeImg{
    if([self isMobileNumber:_telephone.text]){
        //    if ([self checkPhoneNum]) {
        //请求图片验证码
        NSString *areaCode = [@"86" stringByReplacingOccurrencesOfString:@"+" withString:@""];
        NSString * codeUrl = [g_server getImgCode:_telephone.text areaCode:areaCode];
        
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:codeUrl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (!connectionError) {
                UIImage * codeImage = [UIImage imageWithData:data];
                _imgCodeImg.image = codeImage;
            }else{
                NSLog(@"%@",connectionError);
                [g_App showAlert:connectionError.localizedDescription];
            }
        }];
    }else{
        
    }
    
}


//服务端返回数据
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    
    if([aDownload.action isEqualToString:act_openAccount]){
        g_server.myself.walletUserNo = @1;
        [JXMyTools showTipView:Localized(@"JX_OpenAccountsSuccessfully")];
        [self actionQuit];
    }
    if([aDownload.action isEqualToString:act_yopPaySendSms]){
        [JXMyTools showTipView:Localized(@"JXAlert_SendOK")];
        _send.selected = YES;
        _send.userInteractionEnabled = NO;
        _send.backgroundColor = [UIColor grayColor];
        if ([dict objectForKey:@"code"]) {
            _smsCode = [[dict objectForKey:@"code"] copy];
        }else { // 没有返回短信验证码
            _smsCode = @"-1";
        }
        
        [_send setTitle:@"60s" forState:UIControlStateSelected];
        _seconds = 60;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showTime:) userInfo:_send repeats:YES];
        
    }

}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    if([aDownload.action isEqualToString:act_SendSMS]){
        
        [_send setTitle:Localized(@"JX_Send") forState:UIControlStateNormal];
        [g_App showAlert:dict[@"resultMsg"]];
        [self getImgCodeImg];
        return hide_error;
    }

    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
        [_wait start];
}




-(JXImageView*)createButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom must:(BOOL)must click:(SEL)click{
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.delegate = self;
    if(click)
        btn.didTouch = click;
    [self.tableBody addSubview:btn];
    
    if(must){
        UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, 5, 20, HEIGHT-5)];
        p.text = @"*";
        p.font = g_factory.font18;
        p.backgroundColor = [UIColor clearColor];
        p.textColor = [UIColor redColor];
        p.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:p];
    }
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(20, 0, JX_SCREEN_WIDTH/2-40, HEIGHT)];
    p.text = title;
    p.font = g_factory.font16;
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    [btn addSubview:p];
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,HEIGHT-LINE_WH,JX_SCREEN_WIDTH,LINE_WH)];
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
    UITextField* p = [[UITextField alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2-50,INSETS,JX_SCREEN_WIDTH/2-15+50,HEIGHT-INSETS*2)];
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
    
    return p;
}

//验证手机号码格式
- (BOOL)isMobileNumber:(NSString *)number{
    if ([g_config.isOpenSMSCode boolValue] && [g_config.regeditPhoneOrName intValue] != 1) {
        if ([_telephone.text length] == 0) {
            [g_App showAlert:Localized(@"JX_InputPhone")];
            return NO;
        }
    }
    return YES;
}

-(void)showTime:(NSTimer*)sender{
    UIButton *but = (UIButton*)[_timer userInfo];
    _seconds--;
    [but setTitle:[NSString stringWithFormat:@"%ds",_seconds] forState:UIControlStateSelected];
    if (_isSendFirst) {
        _isSendFirst = NO;
        _skipBtn.hidden = YES;
    }
    if (_seconds <= 30) {
        _skipBtn.hidden = NO;
    }
    
    if(_seconds<=0){
        but.selected = NO;
        but.userInteractionEnabled = YES;
        but.backgroundColor = g_theme.themeColor;
        UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
        [but setBackgroundImage:img forState:UIControlStateHighlighted];
        [_send setTitle:Localized(@"JX_SendAngin") forState:UIControlStateNormal];
        if (_timer) {
            _timer = nil;
            [sender invalidate];
        }
        _seconds = 60;
        
    }
}



@end
