//
//  loginVC.m
//  shiku_im
//
//  Created by flyeagleTang on 14-6-7.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "loginVC.h"
#import "forgetPwdVC.h"
#import "inputPhoneVC.h"
#import "JXMainViewController.h"
#import "JXTelAreaListVC.h"
#import "QCheckBox.h"
#import "webpageVC.h"
#import "JXLocation.h"
#import "WXApi.h"
#import "JXInputTextFieldView.h"

#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

#define HEIGHT 56
#define tyCurrentWindow [[UIApplication sharedApplication].windows firstObject]

@interface loginVC ()<UITextFieldDelegate,QCheckBoxDelegate,JXLocationDelegate,JXLocationDelegate,WXApiDelegate,WXApiManagerDelegate,TencentSessionDelegate,TencentLoginDelegate>
{
    UIButton *_areaCodeBtn;
    QCheckBox * _checkProtocolBtn;
    UIButton *_forgetBtn;
    BOOL _isFirstLocation;
    NSString *_myToken;
    
    //短信验证码登录
    UIButton *_switchLogin; //切换登录方式
    UIImageView * _imgCodeImg;
    UITextField *_imgCode;   //图片验证码
    UIButton *_send;   //发送短信
    UIButton * _graphicButton;
    NSString* _smsCode;
    int _seconds;
    NSTimer *_timer;
    NSInteger setServerNum;
}
@property(nonatomic,strong)dispatch_source_t authTimer;
@property(nonatomic,assign)NSInteger count;
@property(nonatomic,strong)UIView *waitAuthView;
@property (nonatomic, strong) JXInputTextFieldView *inputTextFieldView;

@property (nonatomic, strong) NSDictionary *loginDict;

@property (nonatomic, retain)TencentOAuth *oauth;

@property (nonatomic, strong)UILabel *arealCodeL;
@property (nonatomic, strong)UILabel *sendL;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, assign)NSInteger amount;
@property (nonatomic, strong)UIButton *wxbtn;
@property (nonatomic, strong)UIButton *smsbtn;
@property (nonatomic, strong)UILabel *wxL;
@property (nonatomic, strong)UILabel *smsL;
@end

@implementation loginVC

- (id)init
{
    self = [super init];
    if (self) {
//        _pSelf = self;
        _user = [[JXUserObject alloc] init];
        //        self.isGotoBack   = self.isSwitchUser;
        self.heightFooter = 0;
        self.heightHeader = 0;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        if (_isThirdLogin) {
//            self.isGotoBack = YES;
//            self.title = Localized(@"JX_BindNo.");
            self.title = Localized(@"JX_BindExistingAccount");
        }
  
        _amount = 60;
        g_server.isManualLogin = NO;

        [self createHeadAndFoot];
        self.tableBody.backgroundColor = [UIColor whiteColor];
        _myToken = [g_default objectForKey:kMY_USER_TOKEN];
        [g_default setObject:nil forKey:kMyPayPrivateKey];

        int n = INSETS;
        g_server.isLogin = NO;
        g_navigation.lastVC = nil;
        
        
        //title
        NSString * titleStr;
#if TAR_IM
        titleStr = APP_NAME;
//#elif TAR_LIVE
//        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//        // app名称
//        titleStr = [infoDictionary objectForKey:@"CFBundleDisplayName"];
#endif
//        UILabel * kuliaoTitleLabel = [UIFactory createLabelWith:CGRectMake(0, CGRectGetMaxY(kuliaoIconView.frame), 100, 35) text:titleStr font:g_factory.font20 textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor]];
//        kuliaoTitleLabel.center = CGPointMake(kuliaoIconView.center.x, kuliaoTitleLabel.center.y);
//        kuliaoTitleLabel.textAlignment = NSTextAlignmentCenter;
//        [self.tableBody addSubview:kuliaoTitleLabel];
        
//        UIButton* lb;
        /*
         lb = [[JXLabel alloc]initWithFrame:CGRectMake(10, 100, 60, 30)];
         lb.textColor = [UIColor blackColor];
         lb.backgroundColor = [UIColor clearColor];
         lb.text = @"手机：";
         [self.tableBody addSubview:lb];
         [lb release];
         
         lb = [[JXLabel alloc]initWithFrame:CGRectMake(10, 150, 60, 30)];
         lb.textColor = [UIColor blackColor];
         lb.backgroundColor = [UIColor clearColor];
         lb.text = @"密码：";
         [self.tableBody addSubview:lb];
         [lb release];*/
        //(INSETS, n, self_width-INSETS-INSETS, HEIGHT)
        self.tableBody.scrollEnabled = NO;
              if (self.isSMSLogin) {
                    self.title = Localized(@"JX_SMSLogin");
        //            self.isGotoBack = YES;
                    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP-38 , 46, 46)];
                    [btn setBackgroundImage:[UIImage imageNamed:@"title_back_black_big"] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
                    [self.tableBody addSubview:btn];
                }
        
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
        
         n += 10+JX_SCREEN_TOP;
         UILabel *titleL = [UIFactory createLabelWith:CGRectMake(25, n, 200, 24) text:@"密码登录"];
         titleL.font = [UIFont systemFontOfSize:25 weight:UIFontWeightSemibold];
         titleL.textColor = RGB(6, 10, 20);
         titleL.textAlignment = NSTextAlignmentLeft;
         if (_isSMSLogin) {
             titleL.text = @"短信登录";
         }
         [self.tableBody addSubview:titleL];
        BOOL isSmall = NO;
        // 屏幕太小，第三方登录超过登录界面，就另外计算y
        

        if (screenX >=828)
        {
            isSmall=NO;
             n += 90;
        }else{
            isSmall = YES;
            n+= 60;
        }
        NSInteger rightWidth = 52;
         if (_isSMSLogin) {
             rightWidth +=20;
         }
        //区号
        if (!_phone) {
            
            NSLog(@"天气%@",g_config.regeditPhoneOrName);
            if ([g_config.regeditPhoneOrName intValue] != 1) {
                _phone = [UIFactory createTextFieldWith:CGRectMake(25, n, JX_SCREEN_WIDTH-25*2, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:Localized(@"JX_InputPhone") font:g_factory.font16];
                _phone.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_InputPhone") attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
                _phone.keyboardType = UIKeyboardTypeNumberPad;
                UIView *riPhView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, HEIGHT)];
                _phone.leftView = riPhView;
                _phone.leftViewMode = UITextFieldViewModeAlways;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(areaCodeBtnClick:)];
                riPhView.userInteractionEnabled = YES;
                [riPhView addGestureRecognizer:tap];
                
                [_phone addTarget:self action:@selector(longLimit:) forControlEvents:UIControlEventEditingChanged];
                NSString *areaStr;
                if (![g_default objectForKey:kMY_USER_AREACODE]) {
                    areaStr = @"+86";
                } else {
                    areaStr = [NSString stringWithFormat:@"+%@",[g_default objectForKey:kMY_USER_AREACODE]];
                }
                
                
                UILabel *arealCodeL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 38, HEIGHT)];
                arealCodeL.text = areaStr;
                arealCodeL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
                [riPhView addSubview:arealCodeL];
                _arealCodeL = arealCodeL;
                
                UIImageView *dragImgView = [[UIImageView alloc]initWithFrame:CGRectMake(38, 27.5, 9, 6)];
                dragImgView.image = [UIImage imageNamed:@"login_drag"];
                [riPhView addSubview:dragImgView];
            }else {
                _phone = [UIFactory createTextFieldWith:CGRectMake(25, n, JX_SCREEN_WIDTH-25*2, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:Localized(@"JX_InputUserAccount") font:g_factory.font16];
                _phone.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_InputUserAccount") attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
                 _phone.keyboardType = UIKeyboardTypeDefault;
            }
            
            _phone.borderStyle = UITextBorderStyleNone;
            _phone.clearButtonMode = UITextFieldViewModeWhileEditing;
            _phone.textColor = [UIColor blackColor];
           
            [self.tableBody addSubview:_phone];
            [_phone addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-LINE_WH, _phone.frame.size.width, LINE_WH)];
            line.backgroundColor = THE_LINE_COLOR;
            [_phone addSubview:line];
 

            /*
            _areaCodeBtn = [[UIButton alloc] initWithFrame:riPhView.bounds];
            [_areaCodeBtn setTitle:areaStr forState:UIControlStateNormal];
            _areaCodeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            _areaCodeBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
            [_areaCodeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_areaCodeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 14)];
            [_areaCodeBtn setImage:[UIImage imageNamed:@"login_drag"] forState:UIControlStateNormal];
            [_areaCodeBtn setImageEdgeInsets:UIEdgeInsetsMake((HEIGHT-7)*0.5+3, 39, (HEIGHT-7)*0.5-3, 5)];
//            _areaCodeBtn.custom_acceptEventInterval = 1.0f;
            [_areaCodeBtn addTarget:self action:@selector(areaCodeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//            [self resetBtnEdgeInsets:_areaCodeBtn];
            [riPhView addSubview:_areaCodeBtn];
             */
         }
        

        n = n+HEIGHT;
        //监听账号是否被删除
        //
        //        UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 30)];
        //        leftView.image = [UIImage imageNamed:@"userhead"];
        //        leftView.contentMode = UIViewContentModeScaleAspectFit;
        //        _phone.leftView = leftView;
        //        _phone.leftViewMode = UITextFieldViewModeAlways;
        
        if (self.isSMSLogin) {
            //图片验证码
            _imgCode = [UIFactory createTextFieldWith:CGRectMake(25, n, JX_SCREEN_WIDTH-25*2-70-INSETS-35-4, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:Localized(@"JX_inputImgCode") font:g_factory.font16];
            _imgCode.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_inputImgCode") attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
            _imgCode.borderStyle = UITextBorderStyleNone;
            _imgCode.clearButtonMode = UITextFieldViewModeWhileEditing;
            [self.tableBody addSubview:_imgCode];
            
            UIView *imCView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rightWidth, HEIGHT)];
            _imgCode.leftView = imCView;
            _imgCode.leftViewMode = UITextFieldViewModeAlways;
            
             UILabel *arealCodeL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, rightWidth, HEIGHT)];
             arealCodeL.text = @"图形码";
             arealCodeL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
             [imCView addSubview:arealCodeL];
            
            UIView *imCLine = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-LINE_WH, _phone.frame.size.width, LINE_WH)];
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
            n = n+HEIGHT;
        }
        
        //密码
        _pwd = [[UITextField alloc] initWithFrame:CGRectMake(25, n, JX_SCREEN_WIDTH-25*2, HEIGHT)];
        _pwd.delegate = self;
        _pwd.font = g_factory.font16;
        _pwd.autocorrectionType = UITextAutocorrectionTypeNo;
        _pwd.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _pwd.enablesReturnKeyAutomatically = YES;
//        _pwd.borderStyle = UITextBorderStyleRoundedRect;
        _pwd.returnKeyType = UIReturnKeyDone;
        _pwd.clearButtonMode = UITextFieldViewModeWhileEditing;
        _pwd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_InputPassWord") attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        _pwd.secureTextEntry = !self.isSMSLogin;
        _pwd.userInteractionEnabled = YES;
        
        [self.tableBody addSubview:_pwd];
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, HEIGHT)];
        _pwd.leftView = rightView;
        _pwd.leftViewMode = UITextFieldViewModeAlways;
        
        UILabel *pwdL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, HEIGHT)];
        pwdL.text = @"输入密码";
        pwdL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        [rightView addSubview:pwdL];
        
        UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-LINE_WH, _pwd.frame.size.width, LINE_WH)];
        verticalLine.backgroundColor = THE_LINE_COLOR;
        [_pwd addSubview:verticalLine];
//        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(_pwd.frame.size.width-.5, 8, .5, (HEIGHT-8)/2)];
//        line.backgroundColor = HEXCOLOR(0xD6D6D6);
//        [_pwd addSubview:line];
        
//        //忘记密码
//        UIButton *lbUser = [[UIButton alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-60-50, n+10, 70, 20)];
//        [lbUser setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [lbUser setTitle:Localized(@"JX_ForgetPassWord") forState:UIControlStateNormal];
//        lbUser.titleLabel.font = g_factory.font16;
//        lbUser.custom_acceptEventInterval = 1.0f;
//        [lbUser addTarget:self action:@selector(onForget) forControlEvents:UIControlEventTouchUpInside];
//        lbUser.titleEdgeInsets = UIEdgeInsetsMake(0, -27, 0, 0);
//        [self.tableBody addSubview:lbUser];
//        _forgetBtn = lbUser;

        
        if (self.isSMSLogin) {
            _pwd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_InputMessageCode") attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
            
            
            UILabel *sendL = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-130-25, n+HEIGHT/2-15, 130, 30)];
              sendL.text = @"发送";
            sendL.textAlignment = NSTextAlignmentRight;
              sendL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
            sendL.textColor = g_theme.themeColor;
              [self.tableBody addSubview:sendL];
            sendL.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sendSMS)];
            [sendL addGestureRecognizer:tap];
            _sendL = sendL;
            
//            _send = [UIFactory createButtonWithTitle:Localized(@"JX_Send")
//                                           titleFont:g_factory.font16
//                                          titleColor:[UIColor whiteColor]
//                                              normal:nil
//                                           highlight:nil ];
//            _send.frame = CGRectMake(JX_SCREEN_WIDTH-70-25, n+HEIGHT/2-15, 70, 30);
//            [_send addTarget:self action:@selector(sendSMS) forControlEvents:UIControlEventTouchUpInside];
//            _send.backgroundColor = g_theme.themeColor;
//
//            UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
//            [_send setBackgroundImage:img forState:UIControlStateHighlighted];
//            _send.layer.masksToBounds = YES;
//            _send.layer.cornerRadius = 7.f;
//            [self.tableBody addSubview:_send];
            
            UIView *imCView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rightWidth, HEIGHT)];
              _pwd.leftView = imCView;
              _pwd.leftViewMode = UITextFieldViewModeAlways;
              
               UILabel *arealCodeL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, rightWidth, HEIGHT)];
               arealCodeL.text = @"验证码";
               arealCodeL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
               [imCView addSubview:arealCodeL];
            
        }else {
            UIView *eyeView = [[UIView alloc]initWithFrame:CGRectMake(_pwd.frame.size.width-HEIGHT, 0, HEIGHT, HEIGHT)];
            _pwd.rightView = eyeView;
            _pwd.rightViewMode = UITextFieldViewModeAlways;
            UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(HEIGHT/2-10.5+5, HEIGHT/2-9, 21, 18)];
            [rightBtn setBackgroundImage:[UIImage imageNamed:@"login_codehide"] forState:UIControlStateNormal];
            [rightBtn setBackgroundImage:[UIImage imageNamed:@"login_codeshow"] forState:UIControlStateSelected];
            [rightBtn addTarget:self action:@selector(passWordRightViewClicked:) forControlEvents:UIControlEventTouchUpInside];
            [eyeView addSubview:rightBtn];
        }

        
        n = n+HEIGHT;
        
//        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 37, HEIGHT)];
//        _pwd.rightView = rightView;
//        _pwd.rightViewMode = UITextFieldViewModeAlways;
//        UIImageView *riIgView = [[UIImageView alloc] initWithFrame:CGRectMake(2, HEIGHT/2-11, 22, 22)];
//        riIgView.image = [UIImage imageNamed:@"login_codehide"];
//        riIgView.contentMode = UIViewContentModeScaleAspectFit;
//        [rightView addSubview:riIgView];
        
//        UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-LINE_WH, _pwd.frame.size.width, LINE_WH)];
//        verticalLine.backgroundColor = THE_LINE_COLOR;
//        [_pwd addSubview:verticalLine];
        
        n+=50;
        
        //登陆按钮
        _btn = [UIFactory createCommonButton:Localized(@"JX_LoginNow") target:self action:@selector(onClick)];
        _btn.custom_acceptEventInterval = 1.0f;
        
        [_btn.titleLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium]];
        _btn.layer.cornerRadius = 25.f;
        _btn.clipsToBounds = YES;
        _btn.frame = CGRectMake(32, n, JX_SCREEN_WIDTH-32*2, 50);
        
        _btn.userInteractionEnabled = NO;
        [self.tableBody addSubview:_btn];
        
        n += 76;
        //忘记密码
        UIButton *lbUser = [[UIButton alloc]initWithFrame:CGRectMake(40, n, 100, 20)];
        [lbUser setTitleColor:RGB(102, 102, 102) forState:UIControlStateNormal];
        [lbUser setTitle:Localized(@"JX_ForgetPassWord") forState:UIControlStateNormal];
        lbUser.titleLabel.font = g_factory.font16;
        lbUser.custom_acceptEventInterval = 1.0f;
        [lbUser addTarget:self action:@selector(onForget) forControlEvents:UIControlEventTouchUpInside];
        lbUser.titleEdgeInsets = UIEdgeInsetsMake(0, -27, 0, 0);
        [self.tableBody addSubview:lbUser];
        lbUser.hidden = self.isSMSLogin;
        _forgetBtn = lbUser;
        
        //注册用户
        CGSize size =[Localized(@"JX_Register") boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:g_factory.font16} context:nil].size;
        UIButton *lb = [[UIButton alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-40-(140 - (140 - size.width) / 2), n, 140, 20)];
        lb.titleLabel.font = g_factory.font16;
        [lb setTitleColor:RGB(102, 102, 102) forState:UIControlStateNormal];
        [lb setTitle:Localized(@"JX_Register") forState:UIControlStateNormal];
        lb.custom_acceptEventInterval = 1.0f;
        [lb addTarget:self action:@selector(onRegister) forControlEvents:UIControlEventTouchUpInside];
        lb.hidden = self.isSMSLogin;
        
        [self.tableBody addSubview:lb];
        
        if (!self.isSMSLogin) {
            n = n+36;
        }
        
//        if (![[g_default objectForKey:@"agreement"] boolValue]) {            //用户协议
//            UIView * protocolView = [[UIView alloc] init];
//            [self.tableBody addSubview:protocolView];
////
////            UIButton * catProtocolbtn = [UIButton buttonWithType:UIButtonTypeSystem];
////            catProtocolbtn.frame = CGRectMake(0, 0, protocolView.frame.size.width, 25);
//            NSString * agreeStr = Localized(@"JX_IAgree");
//            NSString * protocolStr = Localized(@"JX_ShikuProtocolTitle");
//
////            NSString * agreeProtocolStr = [NSString stringWithFormat:@"%@%@",agreeStr,protocolStr];
////            NSMutableAttributedString* tncString = [[NSMutableAttributedString alloc] initWithString:agreeProtocolStr];
////
////            [tncString addAttribute:NSUnderlineStyleAttributeName
////                              value:@(NSUnderlineStyleSingle)
////                              range:(NSRange){agreeStr.length,[protocolStr length]}];
////            [tncString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor]  range:NSMakeRange(agreeStr.length,[protocolStr length])];
////            [tncString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]  range:NSMakeRange(0,agreeStr.length)];
////            [tncString addAttribute:NSUnderlineColorAttributeName value:[UIColor blueColor] range:(NSRange){agreeStr.length,[protocolStr length]}];
////            [catProtocolbtn setAttributedTitle:tncString forState:UIControlStateNormal];
////            [catProtocolbtn addTarget:self action:@selector(catUserProtocol) forControlEvents:UIControlEventTouchUpInside];
////            [protocolView addSubview:catProtocolbtn];
//
//            UIButton *agrBtn = [[UIButton alloc] init];
//            CGSize agreSize = [agreeStr boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:agrBtn.titleLabel.font} context:nil].size;
//            agrBtn.frame = CGRectMake(0, 0, agreSize.width, agreSize.height);
//            [agrBtn setTitle:agreeStr forState:UIControlStateNormal];
//            [agrBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//            agrBtn.titleLabel.font = SYSFONT(15);
//            [agrBtn addTarget:self
//                       action:@selector(agrBtnAction:)
//             forControlEvents:UIControlEventTouchUpInside];
//            [protocolView addSubview:agrBtn];
//
//            UILabel *protocolLab = [[UILabel alloc] init];
//            CGSize proSize = [protocolStr boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:protocolLab.font} context:nil].size;
//            protocolLab.frame = CGRectMake(CGRectGetMaxX(agrBtn.frame), 0, proSize.width, proSize.height);
//            protocolLab.textColor = [UIColor blueColor];
//            protocolLab.font = SYSFONT(16);
//            NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
//            NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:protocolStr attributes:attribtDic];
//            protocolLab.attributedText = attribtStr;
//            [protocolView addSubview:protocolLab];
//            protocolLab.userInteractionEnabled = YES;
//            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(catUserProtocol)];
//            [protocolLab addGestureRecognizer:tap];
//
//            CGFloat w = agreSize.width+proSize.width;
//            protocolView.frame = CGRectMake((JX_SCREEN_WIDTH -w)/2, n, w, 25);
//            _checkProtocolBtn = [[QCheckBox alloc] initWithDelegate:self];
//            [self.tableBody addSubview:_checkProtocolBtn];
//            _checkProtocolBtn.frame = CGRectMake((JX_SCREEN_WIDTH -w)/2-20, n, 20, 20);
//
////            CGSize size = [agreeProtocolStr boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:catProtocolbtn.titleLabel.font} context:nil].size;
////            _checkProtocolBtn.frame = CGRectMake((catProtocolbtn.frame.size.width - size.width) / 2 - 28, 3, 20, 20);
//
//
//            n+=25;
//        }
        

        n = n+HEIGHT+INSETS;
        
        // 屏幕太小，第三方登录超过登录界面，就另外计算y
        CGFloat wxWidth = 80;
//        BOOL isSmall = JX_SCREEN_HEIGHT-JX_SCREEN_TOP - wxWidth - 30 <= CGRectGetMaxY(_btn.frame)+30;
        CGFloat loginY = isSmall?JX_SCREEN_HEIGHT-JX_SCREEN_TOP - wxWidth  : JX_SCREEN_HEIGHT-JX_SCREEN_TOP - wxWidth - 90;
//        UIImageView *wxLogin = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH-wxWidth*3)/4, loginY, wxWidth, wxWidth)];
//        wxLogin.image = [UIImage imageNamed:@"login_wechat"];
//        wxLogin.userInteractionEnabled = YES;
//        [self.tableBody addSubview:wxLogin];
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didWechatToLogin:)];
//        [wxLogin addGestureRecognizer:tap];
//        wxLogin.hidden = (_isThirdLogin || self.isSMSLogin);
//        if (isSmall) {
//            self.tableBody.contentSize = CGSizeMake(0, CGRectGetMaxY(wxLogin.frame)+20);
//        }
        CGFloat padding = (JX_SCREEN_WIDTH-80*2)/3;
        
        UIButton *wxBtn = [UIButton buttonWithType:0];
        [wxBtn setImage:[UIImage imageNamed:@"login_wechat"] forState:0];
        wxBtn.frame =CGRectMake(padding+16, loginY, 48, 48);
        [wxBtn addTarget:self action:@selector(didWechatToLogin:) forControlEvents:UIControlEventTouchUpInside];
        [self.tableBody addSubview:wxBtn];
        self.wxbtn = wxBtn;
        wxBtn.hidden = (_isThirdLogin || self.isSMSLogin);
        
        if ([g_config.regeditPhoneOrName intValue] == 1) {
            wxBtn.centerX = self.tableBody.centerX;
          }
        UILabel *wxL = [[UILabel alloc]initWithFrame:CGRectMake(0, wxBtn.bottom+8, 100, 14)];
        wxL.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
        wxL.textColor = RGB(102, 102, 102);
        wxL.textAlignment = NSTextAlignmentCenter;
        wxL.text = @"微信登录";
        [self.tableBody addSubview:wxL];
        wxL.centerX = wxBtn.centerX;
        wxL.hidden = (_isThirdLogin || self.isSMSLogin);
        self.wxL = wxL;
  
        //QQ登录
//        UIImageView *qqLogin = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH-wxWidth*3)/4*2+wxWidth, loginY, wxWidth, wxWidth)];
//        qqLogin.image = [UIImage imageNamed:@"qq_login"];
//        qqLogin.userInteractionEnabled = YES;
//        [self.tableBody addSubview:qqLogin];
//        qqLogin.hidden = (_isThirdLogin || self.isSMSLogin);
//
//        UITapGestureRecognizer *qqTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didQQToLogin:)];
//        [qqLogin addGestureRecognizer:qqTap];

        
        //短信登录
//        UIImageView *smsLogin = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH-wxWidth*3)/4*3+wxWidth*2, loginY, wxWidth, wxWidth)];
//        smsLogin.image = [UIImage imageNamed:@"login_msg"];
//        smsLogin.userInteractionEnabled = YES;
//        [self.tableBody addSubview:smsLogin];
//        smsLogin.hidden = (_isThirdLogin || self.isSMSLogin);
//
//        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchLoginWay)];
//        [smsLogin addGestureRecognizer:tap1];
        
        UIButton *smsBtn = [UIButton buttonWithType:0];
         [smsBtn setImage:[UIImage imageNamed:@"login_msg"] forState:0];
         smsBtn.frame =CGRectMake(padding*2+80+16, loginY, 48, 48);
         [smsBtn addTarget:self action:@selector(switchLoginWay) forControlEvents:UIControlEventTouchUpInside];
         [self.tableBody addSubview:smsBtn];
        smsBtn.hidden = (_isThirdLogin || self.isSMSLogin);
        self.smsbtn = smsBtn;
        
        UILabel *smsL = [[UILabel alloc]initWithFrame:CGRectMake(0, smsBtn.bottom+8, 100, 14)];
        smsL.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
        smsL.textColor = RGB(102, 102, 102);
        smsL.textAlignment = NSTextAlignmentCenter;
        smsL.text = @"短信登录";
        [self.tableBody addSubview:smsL];
        smsL.hidden = (_isThirdLogin || self.isSMSLogin);
        smsL.centerX = smsBtn.centerX;
        self.smsL =smsL;
        if ([g_config.regeditPhoneOrName intValue] == 1) {
              smsBtn.hidden = YES;
            smsL.hidden = YES;
            }
        // 微信登录回调
        [WXApiManager sharedManager].delegate = self;

        if ([g_default objectForKey:kMY_USER_NICKNAME])
            _user.userNickname = MY_USER_NAME;
        
        if ([g_default objectForKey:kMY_USER_ID])
            _user.userId = [g_default objectForKey:kMY_USER_ID];
        
        if ([g_default objectForKey:kMY_USER_COMPANY_ID])
            _user.companyId = [g_default objectForKey:kMY_USER_COMPANY_ID];
        
        if ([g_default objectForKey:kMY_USER_LoginName]) {
            [_phone setText:[g_default objectForKey:kMY_USER_LoginName]];
            
            _user.telephone = _phone.text;
        }
        if ([g_default objectForKey:kMY_USER_PASSWORD]) {
//            [_pwd setText:[g_default objectForKey:kMY_USER_PASSWORD]];
            
            _user.password = _pwd.text;
            
        }
        if ([g_default objectForKey:kLocationLogin]) {
            NSDictionary *dict = [g_default objectForKey:kLocationLogin];
            g_server.longitude = [[dict objectForKey:@"longitude"] doubleValue];
            g_server.latitude = [[dict objectForKey:@"latitude"] doubleValue];
        }
        

        
        [g_notify addObserver:self selector:@selector(onRegistered:) name:kRegisterNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(authRespNotification:) name:kWxSendAuthRespNotification object:nil];

        if(!self.isAutoLogin || IsStringNull(_myToken)) {
            _btn.userInteractionEnabled = YES;
        }else {
            _launchImageView = [[UIImageView alloc] init];
            _launchImageView.frame = self.view.bounds;
            if (STATUS_BAR_BIGGER_THAN_20) {
                CGRect frame = _launchImageView.frame;
                frame.origin.y +=20;
                _launchImageView.frame = frame;
            }
            _launchImageView.image = [UIImage imageNamed:[self getLaunchImageName]];
            [self.view addSubview:_launchImageView];
        }
//        NSString *area = [g_default objectForKey:kLocationArea];
//        if (area.length > 0) {
        
        if(self.isAutoLogin && !IsStringNull(_myToken))
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [_wait start:Localized(@"JX_Logining")];
                [_wait startWithClearColor];
            });
        if (!_isThirdLogin) {
            [g_server getSetting:self];
        }
        
//        }else {
//            _isFirstLocation = NO;
//            JXLocation *location = [[JXLocation alloc] init];
//            location.delegate = self;
//            [location getLocationWithIp];
//        }
    }
    return self;
}

//验证手机号格式
- (void)sendSMS{
    if (!_send.selected) {
        NSString *areaCode = [_arealCodeL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        _user = [JXUserObject sharedInstance];
        _user.areaCode = areaCode;
        
        [g_server sendSMS:[NSString stringWithFormat:@"%@",_phone.text] areaCode:areaCode isRegister:NO imgCode:_imgCode.text toView:self];
        _sendL.text = @"重新发送 (60)";
        _sendL.userInteractionEnabled = NO;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reduceNum) userInfo:nil repeats:YES];
    }
}

-(void)reduceNum{
    
    _amount -= 1;
    _sendL.text = [NSString stringWithFormat:@"重新发送 (%ld)",(long)_amount];
    if (_amount == 0) {
        [_timer invalidate];
        _timer = nil;
        _amount = 60;
        _sendL.userInteractionEnabled = YES;
         _sendL.text = @"发送";
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == _imgCode) {
        if (!_imgCodeImg.image) {
            
            [self refreshGraphicAction:nil];
        }
    }
}


- (void)switchLoginWay {
    if (self.isSMSLogin) {
//        [self actionQuit];
        loginVC *vc = [loginVC alloc];
        vc.isSMSLogin = NO;
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
    }else {
        loginVC *vc = [loginVC alloc];
        vc.isSMSLogin = YES;
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
    }
}


-(void)refreshGraphicAction:(UIButton *)button{
    NSString *areaCode = [_arealCodeL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    [g_server checkPhone:_phone.text areaCode:areaCode verifyType:1 toView:self];
}

-(void)getImgCodeImg{
    if([self isMobileNumber:_phone.text]){
        //    if ([self checkPhoneNum]) {
        //请求图片验证码
        NSString *areaCode = [_arealCodeL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        NSString * codeUrl = [g_server getImgCode:_phone.text areaCode:areaCode];
        
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
    }
    
}

//验证手机号码格式
- (BOOL)isMobileNumber:(NSString *)number{
    if ([g_config.isOpenSMSCode boolValue] && [g_config.regeditPhoneOrName intValue] != 1) {
        if ([_phone.text length] == 0) {
            [g_App showAlert:Localized(@"JX_InputPhone")];
            return NO;
        }
    }
    return YES;
}



#pragma mark - 微信登录
- (void)didWechatToLogin:(UITapGestureRecognizer *)tap {
//    if (![[g_default objectForKey:@"agreement"] boolValue]) {
//        [g_App showAlert:Localized(@"JX_NotAgreeProtocol")];
//        return;
//    }

    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo"; // @"post_timeline,sns"
    req.state = @"login";
    req.openID = @"";
    
    [WXApi sendAuthReq:req
        viewController:self
              delegate:[WXApiManager sharedManager]];
}

- (void)authRespNotification:(NSNotification *)notif {
    SendAuthResp *response = notif.object;
    NSString *strMsg = [NSString stringWithFormat:@"Auth结果 code:%@,state:%@,errcode:%d", response.code, response.state, response.errCode];
    self.type = JXLoginWX;
    NSLog(@"-------%@",strMsg);

    if (response.code.length > 0) {
        [g_server getWxOpenId:response.code toView:self];
    }

}


#pragma mark - QQ登录
- (void)didQQToLogin:(UITapGestureRecognizer *)tap {

    NSString *appid = g_App.QQ_LOGIN_APPID;
    _oauth = [[TencentOAuth alloc] initWithAppId:appid
                                     andDelegate:self];

    _oauth.authMode = kAuthModeClientSideToken;
    [_oauth authorize:[self getPermissions] inSafari:NO];
}

// QQ登录成功回调
- (void)tencentDidLogin {
    NSString *qqOpenId = _oauth.openId;
    g_server.openId = qqOpenId;
    self.type = JXLoginQQ;

    if (qqOpenId.length > 0) {
//        [g_server wxSdkLogin:_user type:1 openId:qqOpenId toView:self];
        [g_loginServer wxSdkLoginV1:_user type:1 openId:qqOpenId toView:self];
    }
}


- (NSMutableArray *)getPermissions {
    NSMutableArray * g_permissions = [[NSMutableArray alloc] initWithObjects:kOPEN_PERMISSION_GET_USER_INFO,
                                      kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                                      kOPEN_PERMISSION_ADD_ALBUM,
                                      kOPEN_PERMISSION_ADD_TOPIC,
                                      kOPEN_PERMISSION_CHECK_PAGE_FANS,
                                      kOPEN_PERMISSION_GET_INFO,
                                      kOPEN_PERMISSION_GET_OTHER_INFO,
                                      kOPEN_PERMISSION_LIST_ALBUM,
                                      kOPEN_PERMISSION_UPLOAD_PIC,
                                      kOPEN_PERMISSION_GET_VIP_INFO,
                                      kOPEN_PERMISSION_GET_VIP_RICH_INFO, nil];
    return g_permissions;
}


- (void)agrBtnAction:(UIButton *)btn {
    
    _checkProtocolBtn.selected = !_checkProtocolBtn.selected;
    [self didSelectedCheckBox:_checkProtocolBtn checked:_checkProtocolBtn.selected];
}

//设置文本框只能输入数字
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (_phone == textField) {
        return [self validateNumber:string];
    }
    return YES;
    
}
- (BOOL)validateNumber:(NSString*)number {
//    if ([g_config.regeditPhoneOrName intValue] == 1) {
        // 如果用户名注册选项开启， 则不筛选
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"] invertedSet];
        NSString *filtered = [[number componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [number isEqualToString:filtered];
//    }
//    BOOL res = YES;
//    NSCharacterSet *tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
//    int i = 0;
//    while (i < number.length) {
//        NSString *string = [number substringWithRange:NSMakeRange(i, 1)];
//        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
//        if (range.length == 0) {
//            res = NO;
//            break;
//        }
//        i ++;
//    }
//    return res;
    
}

-(void)location:(JXLocation *)location getLocationWithIp:(NSDictionary *)dict {
    if (_isFirstLocation) {
        return;
    }
    NSString *area = [NSString stringWithFormat:@"%@,%@,%@",dict[@"country"],dict[@"region"],dict[@"city"]];
    [g_default setObject:area forKey:kLocationArea];
    [g_default synchronize];
    
    if(self.isAutoLogin && !IsStringNull(_myToken))
        [_wait start:Localized(@"JX_Logining")];
    if (!_isThirdLogin) {
        [g_server getSetting:self];
    }
}

- (void)location:(JXLocation *)location getLocationError:(NSError *)error {
    if (_isFirstLocation) {
        return;
    }
    [g_default setObject:nil forKey:kLocationArea];
    [g_default synchronize];
    
    if(self.isAutoLogin && !IsStringNull(_myToken))
        [_wait start:Localized(@"JX_Logining")];
    if (!_isThirdLogin) {
        [g_server getSetting:self];
    }
}

-(void)longLimit:(UITextField *)textField
{
//    if (textField.text.length > 11) { 
//        textField.text = [textField.text substringToIndex:11];
//    }
}

-(void)dealloc{
//    _pSelf = nil;
    //    NSLog(@"loginVC.dealloc");
    [g_notify  removeObserver:self name:kRegisterNotifaction object:nil];
    if (_timer != nil) {
        [_timer invalidate];
    }
    
    _timer = nil;
    //    [_user release];
    //    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 防止用户乱跳界面，统一处理，当回到登录界面时,当前不是第三方登录/注册过程，清除openId
    if (!self.isThirdLogin) {
        g_server.openId = nil;
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) textFieldDidChange:(UITextField *) TextField{
    if ([TextField.text isEqualToString:@""]) {
        _pwd.text = @"";
    }
//    if (TextField == _phone) { // 限制手机号最多只能输入11位,为了适配外国电话，将不能显示手机号位数
//        if ([g_config.regeditPhoneOrName intValue] == 1) {
//            if (_phone.text.length > 10) {
//                _phone.text = [_phone.text substringToIndex:10];
//            }
//        }else {
//            if (_phone.text.length > 11) {
//                _phone.text = [_phone.text substringToIndex:11];
//            }
//        }
//    }
}

-(void)onClick{
    
    //    self.isSwitchUser = NO;
    
    if([_phone.text length]<=0){
        if ([g_config.regeditPhoneOrName intValue] == 1) {
            [g_App showAlert:Localized(@"JX_InputUserAccount")];
        }else {
            [g_App showAlert:Localized(@"JX_InputPhone")];
        }
        return;
    }
    if([_pwd.text length]<=0){
        [g_App showAlert:self.isSMSLogin ? Localized(@"JX_InputMessageCode") : Localized(@"JX_InputPassWord")];
        return;
    }
//    if (![[g_default objectForKey:@"agreement"] boolValue]) {
//        [g_App showAlert:Localized(@"JX_NotAgreeProtocol")];
//        return;
//    }
    [self.view endEditing:YES];
    if (self.isSMSLogin) {
        _user.verificationCode = _pwd.text;
    }else {
        _user.password  = [g_server getMD5String:_pwd.text];
    }
    _user.telephone = _phone.text;
    _user.areaCode = [_arealCodeL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    self.isAutoLogin = NO;
    [_wait start:Localized(@"JX_Logining")];
    [g_server getSetting:self];
//    [g_App.jxServer login:_user toView:self];
}

- (void)actionConfig {
    // 自动登录失败，清除token后，重新赋值一次
    _myToken = [g_default objectForKey:kMY_USER_TOKEN];

    if ([g_config.regeditPhoneOrName intValue] == 1) {
        _areaCodeBtn.hidden = YES;
        _forgetBtn.hidden = YES;
//        _phone.keyboardType = UIKeyboardTypeDefault;  // 仅支持大小写字母数字
        _phone.placeholder = Localized(@"JX_InputUserAccount");
        self.wxbtn.centerX = self.tableBody.centerX;
        self.wxL.centerX = self.wxbtn.centerX;
        self.smsbtn.hidden = YES;
        self.smsL.hidden = YES;
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, HEIGHT)];
        _phone.leftView = rightView;
        _phone.leftViewMode = UITextFieldViewModeAlways;
        _phone.keyboardType = UIKeyboardTypeDefault;
        UILabel *pwdL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, HEIGHT)];
        pwdL.text = @"用户名";
        pwdL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        [rightView addSubview:pwdL];
        _phone.leftView = rightView;
    }else {
        _areaCodeBtn.hidden = NO;
//        _forgetBtn.hidden = NO;
        _phone.keyboardType = UIKeyboardTypeNumberPad;  // 限制只能数字输入，使用数字键盘
        _phone.placeholder = Localized(@"JX_InputPhone");
        // 短信登录界面不显示忘记密码
        _forgetBtn.hidden = self.isSMSLogin;
    }

    if ([g_config.isOpenPositionService intValue] == 0) {
        _isFirstLocation = YES;
        _location = [[JXLocation alloc] init];
        _location.delegate = self;
        g_server.location = _location;
        [g_server locate];
    }
    if((self.isAutoLogin && !IsStringNull(_myToken)) || _isThirdLogin)
        if (_isThirdLogin) {
//            [g_server thirdLogin:_user type:2 openId:g_server.openId isLogin:NO toView:self];
            
            [g_loginServer thirdLoginV1:_user password:_pwd.text type:self.type openId:g_server.openId isLogin:NO toView:self];
        }else {
            [self performSelector:@selector(autoLogin) withObject:nil afterDelay:.5];
        }
    else if (IsStringNull(_myToken) && !IsStringNull(_phone.text) && !IsStringNull(_pwd.text)) {
        
        [g_default setObject:nil forKey:kMY_USER_PrivateKey_DH];
        [g_default setObject:nil forKey:kMY_USER_PrivateKey_RSA];
        
        g_server.isManualLogin = YES;
//        [g_App.jxServer login:_user toView:self];
        NSString *areaCode = [_arealCodeL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        
        if (self.isSMSLogin) {
            [g_loginServer smsLoginWithUser:_user areaCode:areaCode account:_phone.text toView:self];
        }else {
            g_server.temporaryPWD = _pwd.text;
            [g_loginServer loginWithUser:_user password:_pwd.text areaCode:areaCode account:_phone.text toView:self];
        }
        
    }
    else
        [_wait stop];
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    if( [aDownload.action isEqualToString:act_Config]){
        
        [g_config didReceive:dict];
        [self actionConfig];
    }
    if([aDownload.action isEqualToString:act_CheckPhone]){
        [self getImgCodeImg];
    }
    if([aDownload.action isEqualToString:act_SendSMS]){
        [JXMyTools showTipView:Localized(@"JXAlert_SendOK")];
        _send.selected = YES;
        _send.userInteractionEnabled = NO;
        _send.backgroundColor = [UIColor grayColor];
        _smsCode = [[dict objectForKey:@"code"] copy];
        
        [_send setTitle:@"60s" forState:UIControlStateSelected];
        _seconds = 60;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showTime:) userInfo:_send repeats:YES];
    }
    if( [aDownload.action isEqualToString:act_UserLogin] || [aDownload.action isEqualToString:act_thirdLogin] || [aDownload.action isEqualToString:act_thirdLoginV1] || [aDownload.action isEqualToString:act_sdkLogin] || [aDownload.action isEqualToString:act_sdkLoginV1] || [aDownload.action isEqualToString:act_UserLoginV1] || [aDownload.action isEqualToString:act_UserSMSLogin]){
        
        if ([dict.allKeys containsObject:@"authKey"]) {
            [_wait stop];
            [self createWaitAuthView];
            [self startAuthDevice:[dict objectForKey:@"authKey"]];
            
            return;
        }
        
        if ([aDownload.action isEqualToString:act_thirdLogin] || [aDownload.action isEqualToString:act_thirdLoginV1] || [aDownload.action isEqualToString:act_sdkLogin] || [aDownload.action isEqualToString:act_sdkLoginV1] ) {
        
            g_server.openId = nil;
            [g_default setBool:YES forKey:kTHIRD_LOGIN_AUTO];
        }else {
            [g_default setBool:NO forKey:kTHIRD_LOGIN_AUTO];
        }
//        if (!IsStringNull(_pwd.text)) {
//            _user.password = [g_server getMD5String:_pwd.text];
//        }
//        [g_default setBool:[[dict objectForKey:@"multipleDevices"] boolValue] forKey:kISMultipleLogin];
//        [g_default synchronize];
        
        if ([aDownload.action isEqualToString:act_sdkLoginV1] || [aDownload.action isEqualToString:act_UserSMSLogin]) {
            
            if(self.isSwitchUser){
                
                [g_server doLoginOK:dict user:_user];
                //切换登录，同步好友
                [g_notify postNotificationName:kXmppClickLoginNotifaction object:nil];
                
                // 更新“我”页面
                [g_notify postNotificationName:kUpdateUserNotifaction object:nil];
            }
            else{
                if ([[dict objectForKey:@"isSupportSecureChat"] intValue] == 1) {
                    
                    self.loginDict = dict;
                    self.inputTextFieldView = [[JXInputTextFieldView alloc] initWithFrame:self.view.bounds sureBtnTitle:Localized(@"JX_Confirm")];
                    self.inputTextFieldView.title = Localized(@"JX_PleaseEnterLgoinKey");
                    self.inputTextFieldView.isTitleCenter = YES;
                    self.inputTextFieldView.delegate = self;
                    self.inputTextFieldView.onRelease = @selector(onRelease);
                    self.inputTextFieldView.isInputPWD = YES;
                    
                    [g_window addSubview:self.inputTextFieldView];
                    
//                    self.inputRectView.placeString = @"123456";
                }else {
                    
                    [g_server doLoginOK:dict user:_user];
                    [g_App showMainUI];
                }
            }
            if ([[dict objectForKey:@"isSupportSecureChat"] intValue] != 1) {
                [self actionQuit];
            }
        }else {
            [g_server doLoginOK:dict user:_user];
            
            if(self.isSwitchUser){
                //切换登录，同步好友
                [g_notify postNotificationName:kXmppClickLoginNotifaction object:nil];
                
                // 更新“我”页面
                [g_notify postNotificationName:kUpdateUserNotifaction object:nil];
            }
            else{
                    [g_App showMainUI];
            }
            [self actionQuit];
        }
        
        
        
        [_wait stop];
    }
    if([aDownload.action isEqualToString:act_userLoginAuto] || [aDownload.action isEqualToString:act_userLoginAutoV1]){
//        int status = [[dict objectForKey:@"serialStatus"] intValue];
//        int token  = [[dict objectForKey:@"tokenExists"] intValue];
//        if(status == 2){//序列号一致
//            if(token==1){//Token也存在，说明不用登录了
        
//        [g_default setBool:[[dict objectForKey:@"multipleDevices"] boolValue] forKey:kISMultipleLogin];
//        [g_default synchronize];
        
                [g_server doLoginOK:dict user:_user];
                if (g_server.isLogin) {
                    [g_App showMainUI];
                }
                [self actionQuit];
//            }else{
//                //Token不存在
//                [g_App showAlert:Localized(@"JX_LoginAgain")];
//                _launchImageView.hidden = YES;
//            }
//        }else{
//            //设备号已换
//            [g_App showAlert:Localized(@"JX_LoginAgainNow")];
//            _launchImageView.hidden = YES;
//        }
        
        [_wait stop];
    }
    if ([aDownload.action isEqualToString:act_GetWxOpenId]) {
        _launchImageView.hidden = NO;
        g_server.openId = [dict objectForKey:@"openid"];
//        [g_server wxSdkLogin:_user type:2 openId:g_server.openId toView:self];
        [g_loginServer wxSdkLoginV1:_user type:2 openId:g_server.openId toView:self];
    }
    
    if ([aDownload.action isEqualToString:act_userVerifyPassword]) {
        
        [self.inputTextFieldView hide];
        
        [g_server doLoginOK:self.loginDict user:_user];
        [g_App showMainUI];
    }
    
    _btn.userInteractionEnabled = YES;
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    _btn.userInteractionEnabled = YES;
    _launchImageView.hidden = YES;
    if ([aDownload.action isEqualToString:act_UserDeviceIsAuth]) {
        if ([[dict objectForKey:@"resultCode"] intValue] == 101987) {
            [self changeAccount];
            [g_server getSetting:self];
        }
        return hide_error;
    }
    if ([aDownload.action isEqualToString:act_Config]) {
        
        NSString *url = [g_default stringForKey:kLastApiUrl];
        g_config.apiUrl = url;
        
        [self actionConfig];
        return hide_error;
    }
    [_wait stop];
    if (([aDownload.action isEqualToString:act_sdkLogin] || [aDownload.action isEqualToString:act_sdkLoginV1]) && [[dict objectForKey:@"resultCode"] intValue] == 1040305) {
        inputPhoneVC *vc = [[inputPhoneVC alloc] init];
        vc.isThirdLogin = YES;
        vc.type = self.type;
        [g_navigation pushViewController:vc animated:YES];

//        loginVC *login = [loginVC alloc];
//        login.isThirdLogin = YES;
//        login.isAutoLogin = NO;
//        login.isSwitchUser= NO;
//        login = [login init];
//        [g_navigation pushViewController:login animated:YES];
        return show_error;
    }
    if (([aDownload.action isEqualToString:act_thirdLogin] || [aDownload.action isEqualToString:act_thirdLoginV1]) && [[dict objectForKey:@"resultCode"] intValue] == 1040306) {
        inputPhoneVC *vc = [[inputPhoneVC alloc] init];
        vc.isThirdLogin = YES;
        vc.type = self.type;
        [g_navigation pushViewController:vc animated:YES];
        return show_error;
    }
    if([aDownload.action isEqualToString:act_userLoginAuto] || [aDownload.action isEqualToString:act_userLoginAutoV1]){
        [g_default removeObjectForKey:kMY_USER_TOKEN];
        [share_defaults removeObjectForKey:kMY_ShareExtensionToken];
    }
    if ([aDownload.action isEqualToString:act_thirdLogin] || [aDownload.action isEqualToString:act_thirdLoginV1]) {
//        g_server.openId = nil;
    }
    if ([aDownload.action isEqualToString:act_SendSMS]) {
        [_send setTitle:Localized(@"JX_Send") forState:UIControlStateNormal];
    }
    if ([aDownload.action isEqualToString:act_userVerifyPassword]) {
        [self.inputTextFieldView cleanText];
    }
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    _btn.userInteractionEnabled = YES;
    _launchImageView.hidden = YES;

    if ([aDownload.action isEqualToString:act_Config]) {
        
        NSString *url = [g_default stringForKey:kLastApiUrl];
        g_config.apiUrl = url;
        
        [self actionConfig];
        return hide_error;
    }
    if([aDownload.action isEqualToString:act_userLoginAuto] || [aDownload.action isEqualToString:act_userLoginAutoV1]){
        [g_default removeObjectForKey:kMY_USER_TOKEN];
        [share_defaults removeObjectForKey:kMY_ShareExtensionToken];
    }
    if ([aDownload.action isEqualToString:act_thirdLogin] || [aDownload.action isEqualToString:act_thirdLoginV1]) {
//        g_server.openId = nil;
    }
    
    if ([aDownload.action isEqualToString:act_SendSMS]) {
        [_send setTitle:Localized(@"JX_Send") forState:UIControlStateNormal];
    }
    
    if ([aDownload.action isEqualToString:act_userVerifyPassword]) {
        [self.inputTextFieldView cleanText];
    }
    [_wait stop];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
//    _btn.userInteractionEnabled = NO;
    if([aDownload.action isEqualToString:act_thirdLogin] || [aDownload.action isEqualToString:act_thirdLoginV1] || [aDownload.action isEqualToString:act_sdkLogin]|| [aDownload.action isEqualToString:act_sdkLoginV1]){
        [_wait start];
    }
}

- (void)onRelease {
    g_server.temporaryPWD = self.inputTextFieldView.text;
    NSString *userId = [[self.loginDict objectForKey:@"userId"] stringValue];
    [g_default setObject:userId forKey:kMY_USER_ID];
    g_server.access_token = [self.loginDict objectForKey:@"access_token"];
    if([self.loginDict objectForKey:@"httpKey"])
        g_server.httpKey = [self.loginDict objectForKey:@"httpKey"];
    [g_server userVerifyPassword:self.inputTextFieldView.text toView:self];
}

-(void)onRegister{
    inputPhoneVC* vc = [[inputPhoneVC alloc]init];
//    [g_window addSubview:vc.view];
    vc.type = self.type;
    vc.isThirdLogin = self.isThirdLogin;
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onForget{
    forgetPwdVC* vc = [[forgetPwdVC alloc] init];
    vc.isModify = NO;
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)autoLogin{
    
//    _btn.userInteractionEnabled = ![g_server autoLogin:self];
    
    NSString * token = [[NSUserDefaults standardUserDefaults] stringForKey:kMY_USER_TOKEN];
    _btn.userInteractionEnabled = token.length > 0;
    if (token.length > 0) {
        [g_loginServer autoLoginWithToView:self];
    }else {
        _launchImageView.hidden = YES;
    }
//    if (_btn.userInteractionEnabled) {
//        _launchImageView.hidden = YES;
//    }
    
}

-(void)onRegistered:(NSNotification *)notifacation{
    [self actionQuit];
    if(!self.isSwitchUser)
        [g_App showMainUI];
}

-(void)actionQuit{
    [super actionQuit];
//    _pSelf = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _phone) {
        [_pwd becomeFirstResponder];
    }else{
        [self.view endEditing:YES];
    }
    return YES;
}

- (void)areaCodeBtnClick:(UIButton *)but{
    [self.view endEditing:YES];
    JXTelAreaListVC *telAreaListVC = [[JXTelAreaListVC alloc] init];
    telAreaListVC.telAreaDelegate = self;
    telAreaListVC.didSelect = @selector(didSelectTelArea:);
//    [g_window addSubview:telAreaListVC.view];
    [g_navigation pushViewController:telAreaListVC animated:YES];
}
- (void)didSelectTelArea:(NSString *)areaCode{
    _arealCodeL.text = [NSString stringWithFormat:@"+%@",areaCode];
    [self resetBtnEdgeInsets:_areaCodeBtn];
}
- (void)resetBtnEdgeInsets:(UIButton *)btn{
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.frame.size.width-2, 0, btn.imageView.frame.size.width+2)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.frame.size.width+2, 0, -btn.titleLabel.frame.size.width-2)];
}
- (void)passWordRightViewClicked:(UIButton *)but{
    [_pwd resignFirstResponder];
    but.selected = !but.selected;
    _pwd.secureTextEntry = !but.selected;
    
}


- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked{
    [g_default setObject:[NSNumber numberWithBool:checked] forKey:@"agreement"];
    [g_default synchronize];
}


-(void)catUserProtocol{
    webpageVC * webVC = [webpageVC alloc];
    webVC.url = [self protocolUrl];
    webVC.isSend = NO;
//    [[NSBundle mainBundle] pathForResource:@"用户协议" ofType:@"html"];
    webVC = [webVC init];
    [g_navigation.navigationView addSubview:webVC.view];
//    [g_navigation pushViewController:webVC animated:YES];
}


-(NSString *)protocolUrl{
    NSString * protocolStr = g_config.privacyPolicyPrefix;
    NSString * lange = g_constant.sysLanguage;
    if (![lange isEqualToString:ZHHANTNAME] && ![lange isEqualToString:NAME]) {
        lange = ENNAME;
    }
    return [NSString stringWithFormat:@"%@%@.html",protocolStr,lange];
}


// 获取启动图
- (NSString *)getLaunchImageName
{
    NSString *viewOrientation = @"Portrait";
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        viewOrientation = @"Landscape";
    }
    NSString *launchImageName = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    CGSize viewSize = tyCurrentWindow.bounds.size;
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImageName = dict[@"UILaunchImageName"];
        }
    }
    return launchImageName;
}

#pragma mark JXLocationDelegate
- (void)location:(JXLocation *)location CountryCode:(NSString *)countryCode CityName:(NSString *)cityName CityId:(NSString *)cityId Address:(NSString *)address Latitude:(double)lat Longitude:(double)lon{
    g_server.countryCode = countryCode;
    g_server.cityName = cityName;
    g_server.cityId = [cityId intValue];
    g_server.address = address;
    g_server.latitude = lat;
    g_server.longitude = lon;
    
    NSDictionary *dict = @{@"latitude":@(lat),@"longitude":@(lon)};
    
    [g_default setObject:dict forKey:kLocationLogin];
}

-(void)showTime:(NSTimer*)sender{
    UIButton *but = (UIButton*)[_timer userInfo];
    _seconds--;
    [but setTitle:[NSString stringWithFormat:@"%ds",_seconds] forState:UIControlStateSelected];
    
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


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)createWaitAuthView{
    self.waitAuthView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH,JX_SCREEN_HEIGHT)];
    self.waitAuthView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeAccount)];
    [self.waitAuthView addGestureRecognizer:ges];
    [self.view addSubview:self.waitAuthView];
    
    UIView *authView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH - 80, JX_SCREEN_HEIGHT / 3)];
    authView.backgroundColor = [UIColor whiteColor];
    authView.layer.cornerRadius = 10;
    authView.layer.masksToBounds = YES;
    CGPoint center = authView.center;
    
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 95, 95)];
    imgV.image = [UIImage imageNamed:@"ALOGO_120"];
    [authView addSubview:imgV];
    imgV.center = CGPointMake(center.x, 20 + 95/2);
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH - 200, 50)];
    lab.text = Localized(@"JX_WaitingForAuthorization");
    lab.font = [UIFont systemFontOfSize:17];
    lab.textColor = [UIColor blackColor];
    lab.textAlignment = NSTextAlignmentCenter;
    [authView addSubview:lab];
    lab.center = CGPointMake(center.x, CGRectGetMaxY(imgV.frame) + 30);
    
    
    UIButton *btn = [UIFactory createCommonButton:Localized(@"JX_SwitchAccount") target:self action:@selector(changeAccount)];
    btn.custom_acceptEventInterval = 1.0f;
    [btn.titleLabel setFont:g_factory.font17];
    btn.layer.cornerRadius = 20;
    btn.clipsToBounds = YES;
    btn.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH-100*2, 40);
    [authView addSubview:btn];
    btn.center = CGPointMake(center.x, CGRectGetMaxY(authView.frame) - 40);
    btn.userInteractionEnabled = NO;
    
    [self.waitAuthView addSubview:authView];
    authView.center = self.waitAuthView.center;
}
- (void)changeAccount{
    [self.waitAuthView removeFromSuperview];
    dispatch_cancel(_authTimer);
    _authTimer = nil;
}
- (void)startAuthDevice:(NSString *)str{
    if (_authTimer) {
        dispatch_cancel(_authTimer);
        _authTimer = nil;
    }
    dispatch_queue_t queue = dispatch_get_main_queue();
    _authTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = DISPATCH_TIME_NOW;
    dispatch_time_t interval = 1.0 * NSEC_PER_SEC;
    dispatch_source_set_timer(_authTimer, start, interval, 0);
    dispatch_source_set_event_handler(_authTimer, ^{
        _count ++;
        [g_server loginIsAuthKey:str toView:self];
        if (_count == 300 ) {
            _count = 0;
            [self changeAccount];
        }
    });
    dispatch_resume(_authTimer);
}


@end
