//
//  inputPhoneVC.m
//  shiku_im
//
//  Created by flyeagleTang on 14-6-7.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "inputPhoneVC.h"
#import "inputPwdVC.h"
#import "JXTelAreaListVC.h"
#import "JXUserObject.h"
#import "PSRegisterBaseVC.h"
#import "resumeData.h"
#import "webpageVC.h"
#import "loginVC.h"

#define HEIGHT 56

@interface inputPhoneVC ()<UITextFieldDelegate>
{
    NSTimer *_timer;
    UIButton *_areaCodeBtn;
    JXUserObject *_user;
    UIImageView * _imgCodeImg;
    UITextField *_imgCode;   //图片验证码
    UIButton * _graphicButton;
    UIButton* _skipBtn;
    BOOL _isSkipSMS;
    BOOL _isSendFirst;
    // 同意协议勾选
    UIImageView * _agreeImgV;
}
//@property (nonatomic, strong) UIView *imgCodeView;
@property (nonatomic, assign) BOOL isSmsRegister;
@property (nonatomic, assign) BOOL isCheckToSMS;  // YES:发送短信处验证手机号  NO:注册处验证手机号
@property (nonatomic, strong)UILabel *arealCodeL;
@property (nonatomic, strong)UILabel *sendL;
@property (nonatomic, assign)NSInteger amount;
@end

@implementation inputPhoneVC

- (id)init
{
    self = [super init];
    if (self) {
        _seconds = 0;
        self.isGotoBack   = YES;
        self.title = Localized(@"JX_Register");
        self.heightFooter = 0;
        self.heightHeader = 0;
        //self.view.frame = g_window.bounds;
        [self createHeadAndFoot];
        self.tableBody.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoardToView)];
        [self.tableBody addGestureRecognizer:tap];
        self.tableBody.scrollEnabled = NO;
        _isSendFirst = YES;  // 第一次发送短信
        int n = INSETS;
        int distance = 25; // 左右间距
        self.isSmsRegister = NO;
        _amount = 60;
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP-38 , 46, 46)];
        [btn setBackgroundImage:[UIImage imageNamed:@"title_back_black_big"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
        [self.tableBody addSubview:btn];
        
        
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
        
        n += JX_SCREEN_TOP+8;
        
        UILabel *titleL = [UIFactory createLabelWith:CGRectMake(25, n, 200, 24) text:@"注册用户"];
        titleL.font = [UIFont systemFontOfSize:25 weight:UIFontWeightSemibold];
        titleL.textColor = RGB(6, 10, 20);
        titleL.textAlignment = NSTextAlignmentLeft;
        [self.tableBody addSubview:titleL];
        
        if (screenX >=828)
        {
             n += 90;
        }else{
            n+= 60;
        }
        //手机号
        if (!_phone) {
            NSString *placeHolder;
            if ([g_config.regeditPhoneOrName intValue] == 0) {
                placeHolder = Localized(@"JX_InputPhone");
            }else {
                placeHolder = Localized(@"JX_InputUserAccount");
            }
            _phone = [UIFactory createTextFieldWith:CGRectMake(distance, n, self_width-distance*2, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:placeHolder font:g_factory.font16];
            _phone.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolder attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
            _phone.borderStyle = UITextBorderStyleNone;
            if ([g_config.regeditPhoneOrName intValue] == 1) {
                _phone.keyboardType = UIKeyboardTypeDefault;  // 仅支持大小写字母数字
            }else {
                _phone.keyboardType = UIKeyboardTypeNumberPad;  // 限制只能数字输入，使用数字键盘
            }
            _phone.clearButtonMode = UITextFieldViewModeWhileEditing;
            [_phone addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
            _phone.textColor = [UIColor blackColor];
            [self.tableBody addSubview:_phone];
            
            if ([g_config.regeditPhoneOrName intValue] == 0) {
                UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, HEIGHT)];
                _phone.leftView = leftView;
                _phone.leftViewMode = UITextFieldViewModeAlways;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(areaCodeBtnClick:)];
                leftView.userInteractionEnabled = YES;
                [leftView addGestureRecognizer:tap];

                NSString *areaStr;
                if (![g_default objectForKey:kMY_USER_AREACODE]) {
                    areaStr = @"+86";
                } else {
                    areaStr = [NSString stringWithFormat:@"+%@",[g_default objectForKey:kMY_USER_AREACODE]];
                }
                
                
                UILabel *arealCodeL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 38, HEIGHT)];
                arealCodeL.text = areaStr;
                arealCodeL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
                [leftView addSubview:arealCodeL];
                _arealCodeL = arealCodeL;
                
                UIImageView *dragImgView = [[UIImageView alloc]initWithFrame:CGRectMake(38, 27.5, 9, 6)];
                dragImgView.image = [UIImage imageNamed:@"login_drag"];
                [leftView addSubview:dragImgView];
            }else {
                UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, HEIGHT)];
                _phone.leftView = rightView;
                _phone.leftViewMode = UITextFieldViewModeAlways;
                
                UILabel *pwdL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, HEIGHT)];
                pwdL.text = @"用户名";
                pwdL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
                [rightView addSubview:pwdL];
                _phone.leftView = rightView;
            }
            
            UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-LINE_WH, _phone.frame.size.width, LINE_WH)];
            verticalLine.backgroundColor = THE_LINE_COLOR;
            [_phone addSubview:verticalLine];
            

//            UIImageView *phIgView = [[UIImageView alloc] initWithFrame:CGRectMake(2, HEIGHT/2-11, 22, 22)];
//            phIgView.image = [UIImage imageNamed:@"account"];
//            phIgView.contentMode = UIViewContentModeScaleAspectFit;
//            [leftView addSubview:phIgView];
//            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-LINE_WH, _phone.frame.size.width, LINE_WH)];
//            line.backgroundColor = THE_LINE_COLOR;
//            [_phone addSubview:line];
//
//            UIView *riPhView = [[UIView alloc] initWithFrame:CGRectMake(_phone.frame.size.width-44, 0, HEIGHT, HEIGHT)];
//            _phone.rightView = riPhView;
//            _phone.rightViewMode = UITextFieldViewModeAlways;
//            NSString *areaStr;
//            if (![g_default objectForKey:kMY_USER_AREACODE]) {
//                areaStr = @"+86";
//            } else {
//                areaStr = [NSString stringWithFormat:@"+%@",[g_default objectForKey:kMY_USER_AREACODE]];
//            }
//            _areaCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, HEIGHT/2-8, HEIGHT-5, 22)];
//            [_areaCodeBtn setTitle:areaStr forState:UIControlStateNormal];
//            _arealCodeL.text.font = SYSFONT(15);
//            _areaCodeBtn.hidden = [g_config.regeditPhoneOrName intValue] == 1;
//            [_areaCodeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
////            [_areaCodeBtn setImage:[UIImage imageNamed:@"account"] forState:UIControlStateNormal];
//            [_areaCodeBtn addTarget:self action:@selector(areaCodeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//            [self resetBtnEdgeInsets:_areaCodeBtn];
//            [riPhView addSubview:_areaCodeBtn];
        }
        n = n+HEIGHT;
        //密码
        _pwd = [[UITextField alloc] initWithFrame:CGRectMake(distance, n, JX_SCREEN_WIDTH-distance*2, HEIGHT)];
        _pwd.delegate = self;
        _pwd.font = g_factory.font16;
        _pwd.autocorrectionType = UITextAutocorrectionTypeNo;
        _pwd.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _pwd.enablesReturnKeyAutomatically = YES;
        _pwd.returnKeyType = UIReturnKeyDone;
        _pwd.clearButtonMode = UITextFieldViewModeWhileEditing;
        _pwd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_InputPassWord") attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        _pwd.secureTextEntry = YES;
        _pwd.userInteractionEnabled = YES;

        [_pwd addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
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
        
        n = n+HEIGHT;
        
        if ([g_config.registerInviteCode intValue] != 0) {
            //邀请码
            _inviteCode = [[UITextField alloc] initWithFrame:CGRectMake(distance, n, JX_SCREEN_WIDTH-distance*2, HEIGHT)];
            _inviteCode.delegate = self;
            _inviteCode.font = g_factory.font16;
            _inviteCode.autocorrectionType = UITextAutocorrectionTypeNo;
            _inviteCode.autocapitalizationType = UITextAutocapitalizationTypeNone;
            _inviteCode.enablesReturnKeyAutomatically = YES;
            _inviteCode.returnKeyType = UIReturnKeyDone;
            _inviteCode.clearButtonMode = UITextFieldViewModeWhileEditing;
            _inviteCode.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"邀请码" attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
            _inviteCode.secureTextEntry = YES;
            _inviteCode.userInteractionEnabled = YES;
            [self.tableBody addSubview:_inviteCode];
            
            UIView *inviteRightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, HEIGHT)];
            _inviteCode.leftView = inviteRightView;
            _inviteCode.leftViewMode = UITextFieldViewModeAlways;
            
            UILabel *inviteL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, HEIGHT)];
              inviteL.text = @"邀请码";
              inviteL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
              [inviteRightView addSubview:inviteL];
//            UIImageView *inviteRiIgView = [[UIImageView alloc] initWithFrame:CGRectMake(2, HEIGHT/2-11, 22, 22)];
//            inviteRiIgView.image = [UIImage imageNamed:@"password"];
//            inviteRiIgView.contentMode = UIViewContentModeScaleAspectFit;
//            [inviteRightView addSubview:inviteRiIgView];
//
            verticalLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(inviteRightView.frame)-4, _inviteCode.frame.size.width, 0.5)];
            verticalLine.backgroundColor = HEXCOLOR(0xD6D6D6);
            [_inviteCode addSubview:verticalLine];
            
            n = n+HEIGHT;
        }
        
        //图片验证码
        _imgCode = [UIFactory createTextFieldWith:CGRectMake(distance, n, self_width-distance*2-70-INSETS-35-4, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:Localized(@"JX_inputImgCode") font:g_factory.font16];
        _imgCode.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_inputImgCode") attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        _imgCode.borderStyle = UITextBorderStyleNone;
        _imgCode.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.tableBody addSubview:_imgCode];

        UIView *imCView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, HEIGHT)];
        _imgCode.leftView = imCView;
        _imgCode.leftViewMode = UITextFieldViewModeAlways;

        UILabel *imgL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, HEIGHT)];
        imgL.text = @"图形码";
        imgL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        [imCView addSubview:imgL];
        
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
        if ([g_config.isOpenSMSCode boolValue] && [g_config.regeditPhoneOrName intValue] != 1) {
            n = n+HEIGHT;
        }else {
            n = n+INSETS;
        }
#ifdef IS_TEST_VERSION
#else
#endif
        
        _code = [[UITextField alloc] initWithFrame:CGRectMake(distance, n, JX_SCREEN_WIDTH-110-distance*2, HEIGHT)];
        _code.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_InputMessageCode") attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        _code.font = g_factory.font16;
        _code.delegate = self;
        _code.autocorrectionType = UITextAutocorrectionTypeNo;
        _code.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _code.enablesReturnKeyAutomatically = YES;
        _code.borderStyle = UITextBorderStyleNone;
        _code.returnKeyType = UIReturnKeyDone;
        _code.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        UIView *codeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, HEIGHT)];
        _code.leftView = codeView;
        _code.leftViewMode = UITextFieldViewModeAlways;
        
        UILabel *codeL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, HEIGHT)];
        codeL.text = @"验证码";
        codeL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        [codeView addSubview:codeL];
        
        UIView *codeILine = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-LINE_WH, _phone.frame.size.width, LINE_WH)];
        codeILine.backgroundColor = THE_LINE_COLOR;
        [_code addSubview:codeILine];

        
        [self.tableBody addSubview:_code];

        
        UILabel *sendL = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-110-25, n+HEIGHT/2-15, 110, 30)];
          sendL.text = @"发送";
        sendL.textAlignment = NSTextAlignmentRight;
          sendL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        sendL.textColor = g_theme.themeColor;
          [self.tableBody addSubview:sendL];
        sendL.userInteractionEnabled = YES;
        UITapGestureRecognizer *sendTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sendSMS)];
        [sendL addGestureRecognizer:sendTap];
        _sendL = sendL;
        
        //测试版隐藏了短信验证
        if ([g_config.isOpenSMSCode boolValue] && [g_config.regeditPhoneOrName intValue] != 1) {
            n = n+HEIGHT+INSETS+INSETS;
        }else {
            _send.hidden = YES;
            _code.hidden = YES;
            _imgCode.hidden = YES;
            _imgCodeImg.hidden = YES;
            _graphicButton.hidden = YES;
            _sendL.hidden = YES;
        }
#ifdef IS_TEST_VERSION
#else
#endif
        
        // 返回登录
        CGSize size = [Localized(@"JX_HaveAccountLogin") boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:g_factory.font16} context:nil].size;
        UIButton *goLoginBtn = [[UIButton alloc] initWithFrame:CGRectMake(distance, n, size.width+4, size.height)];
        [goLoginBtn setTitle:Localized(@"JX_HaveAccountLogin") forState:UIControlStateNormal];
        goLoginBtn.titleLabel.font = g_factory.font16;
        [goLoginBtn setTitleColor:RGB(102, 102, 102) forState:UIControlStateNormal];
        [goLoginBtn addTarget:self action:@selector(goToLoginVC) forControlEvents:UIControlEventTouchUpInside];
        [self.tableBody addSubview:goLoginBtn];
#ifdef IS_Skip_SMS
            // 跳过当前界面进入下个界面
            CGSize skipSize = [Localized(@"JX_NotGetSMSCode") boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:g_factory.font16} context:nil].size;
            _skipBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-distance-skipSize.width, n, skipSize.width+4, skipSize.height)];
            [_skipBtn setTitle:Localized(@"JX_NotGetSMSCode") forState:UIControlStateNormal];
            _skipBtn.titleLabel.font = g_factory.font16;
            _skipBtn.hidden = YES;
            [_skipBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_skipBtn addTarget:self action:@selector(enterNextPage) forControlEvents:UIControlEventTouchUpInside];
            [self.tableBody addSubview:_skipBtn];
#else
        
#endif
        //弃用手机验证
        //#ifdef IS_TEST_VERSION
        //        UIButton* _btn = [UIFactory createCommonButton:@"下一步" target:self action:@selector(onTest)];
        //#else
        //        UIButton* _btn = [UIFactory createCommonButton:@"下一步" target:self action:@selector(onClick)];
        //#endif
        //新添加的手机验证（注册）
        n = n+46;
        
        CGFloat loginY = JX_SCREEN_HEIGHT-JX_SCREEN_TOP;
        UIButton* _btn = [UIFactory createCommonButton:Localized(@"REGISTERS") target:self action:@selector(checkPhoneNumber)];
        [_btn.titleLabel setFont:g_factory.font16];
        _btn.frame = CGRectMake(32, n, JX_SCREEN_WIDTH-32*2, 50);
        _btn.layer.masksToBounds = YES;
        _btn.layer.cornerRadius = 25.f;
        [self.tableBody addSubview:_btn];
        
        n = n+HEIGHT+INSETS;
        UILabel *agreeLab = [[UILabel alloc] init];
        agreeLab.font = SYSFONT(13);
        agreeLab.text = Localized(@"JX_ByRegisteringYouAgree");
        agreeLab.textColor = RGB(102, 102, 102);
        agreeLab.userInteractionEnabled = YES;
        [self.tableBody addSubview:agreeLab];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didAgree)];
        [agreeLab addGestureRecognizer:tap1];

        UILabel*termsLab = [[UILabel alloc] init];
        termsLab.text = Localized(@"《Privacy Policy and Terms of Service》");
        termsLab.font = SYSFONT(13);
        termsLab.textColor = RGB(102, 102, 102);
        termsLab.userInteractionEnabled = YES;
        [self.tableBody addSubview:termsLab];

        UITapGestureRecognizer *tapT = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkTerms)];
        [termsLab addGestureRecognizer:tapT];

        CGSize sizeA = [agreeLab.text sizeWithAttributes:@{NSFontAttributeName:agreeLab.font}];
        CGSize sizeT = [termsLab.text sizeWithAttributes:@{NSFontAttributeName:termsLab.font}];

        UIImageView *agreeNotImgV = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH-sizeA.width-sizeT.width-15)/2, loginY-6, 25, 25)];
        agreeNotImgV.image = [UIImage imageNamed:@"registered_not_agree"];
        agreeNotImgV.userInteractionEnabled = YES;
        [self.tableBody addSubview:agreeNotImgV];
        
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didAgree)];
        [agreeNotImgV addGestureRecognizer:tap2];
        
        agreeLab.frame = CGRectMake(CGRectGetMaxX(agreeNotImgV.frame), loginY, sizeA.width, sizeA.height);
        termsLab.frame = CGRectMake(CGRectGetMaxX(agreeLab.frame), loginY, sizeT.width, sizeT.height);

        _agreeImgV = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(agreeNotImgV.frame), loginY-10, 25, 30)];
        _agreeImgV.image = [UIImage imageNamed:@"registered_agree"];
        _agreeImgV.userInteractionEnabled = YES;
        [self.tableBody addSubview:_agreeImgV];

        UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didAgree)];
        [_agreeImgV addGestureRecognizer:tap3];
        //添加提示
//        UIImageView * careImage = [[UIImageView alloc]initWithFrame:CGRectMake(INSETS, n+HEIGHT+INSETS+3, INSETS, INSETS)];
//        careImage.image = [UIImage imageNamed:@"noread"];
//
//        UILabel * careTitle = [[UILabel alloc]initWithFrame:CGRectMake(INSETS*2+2, n+HEIGHT+INSETS, 100, HEIGHT/3)];
//        careTitle.font = [UIFont fontWithName:@"Verdana" size:13];
//        careTitle.text = Localized(@"inputPhoneVC_BeCareful");
//
//        n = n+HEIGHT+INSETS;
//        UILabel * careFirst = [[UILabel alloc]initWithFrame:CGRectMake(INSETS*2+2, n+HEIGHT/3+INSETS, JX_SCREEN_WIDTH-12-INSETS*2, HEIGHT/3)];
//        careFirst.font = [UIFont fontWithName:@"Verdana" size:11];
//        careFirst.text = Localized(@"inputPhoneVC_NotNeedCode");
//
//        n = n+HEIGHT/3+INSETS;
//        UILabel * careSecond = [[UILabel alloc]initWithFrame:CGRectMake(INSETS*2+2, n+HEIGHT/3+INSETS, JX_SCREEN_WIDTH-INSETS*2-12, HEIGHT/3+15)];
//        careSecond.font = [UIFont fontWithName:@"Verdana" size:11];
//        careSecond.text = Localized(@"inputPhoneVC_NoReg");
//        careSecond.numberOfLines = 0;
        
        //测试版隐藏了短信验证
#ifdef IS_TEST_VERSION
#else
//        careFirst.hidden = YES;
//        careSecond.hidden = YES;
//        careImage.hidden = YES;
//        careTitle.hidden = YES;
#endif
//        [self.tableBody addSubview:careImage];
//        [self.tableBody addSubview:careTitle];
//        [self.tableBody addSubview:careFirst];
//        [self.tableBody addSubview:careSecond];
        
    }
    return self;
}

- (void)didAgree {
    _agreeImgV.hidden = !_agreeImgV.hidden;
}

- (void)checkTerms {
    webpageVC * webVC = [webpageVC alloc];
    webVC.url = [self protocolUrl];
    webVC.isSend = NO;
    webVC = [webVC init];
    [g_navigation.navigationView addSubview:webVC.view];
}

-(NSString *)protocolUrl{
    NSString * protocolStr = g_config.privacyPolicyPrefix;
    NSString * lange = g_constant.sysLanguage;
    if (![lange isEqualToString:ZHHANTNAME] && ![lange isEqualToString:NAME]) {
        lange = ENNAME;
    }
    return [NSString stringWithFormat:@"%@%@.html",protocolStr,lange];
}


//设置文本框只能输入数字
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (_phone == textField) {
        return [self validateNumber:string];
    }
    if (_pwd == textField) {
        if ([string isEqualToString:@" "]) {
            return NO;
        }
    }
    return YES;
    
}
- (BOOL)validateNumber:(NSString*)number {
    if ([g_config.regeditPhoneOrName intValue] == 1) {
        // 如果用户名注册选项开启， 则不筛选
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"] invertedSet];
        NSString *filtered = [[number componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [number isEqualToString:filtered];
    }
    BOOL res = YES;
    NSCharacterSet *tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString *string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i ++;
    }
    return res;
    
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

- (void)enterNextPage {
    _isSkipSMS = YES;
    BOOL isMobile = [self isMobileNumber:_phone.text];
    
    if ([_pwd.text length] < 6) {
        [g_App showAlert:Localized(@"JX_TurePasswordAlert")];
        return;
    }
    if (isMobile) {
        NSString *areaCode = [_arealCodeL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        [g_server checkPhone:_phone.text areaCode:areaCode verifyType:0 toView:self];
    }
}


- (void)textFieldDidChanged:(UITextField *)textField {
    if (textField == _phone) { // 限制手机号最多只能输入11位,为了适配外国电话，将不能显示手机号位数
        if ([g_config.regeditPhoneOrName intValue] == 1) {
            if (_phone.text.length > 10) {
                _phone.text = [_phone.text substringToIndex:10];
            }
        }else {
            if (_phone.text.length > 11) {
                _phone.text = [_phone.text substringToIndex:11];
            }
        }
    }
    
    if (textField == _pwd) {
        if (_pwd.text.length > 17) {
            _pwd.text = [_pwd.text substringToIndex:17];
        }
    }
}


- (void)goToLoginVC {
    if (self.isThirdLogin) {
        loginVC *login = [loginVC alloc];
        login.isThirdLogin = YES;
        login.isAutoLogin = NO;
        login.isSwitchUser= NO;
        login.type = self.type;
        login = [login init];
        [g_navigation pushViewController:login animated:YES];
    }else {
        [self actionQuit];
    }
}

//验证手机号码格式,无短信验证
- (void)checkPhoneNumber{
    _isSkipSMS = NO;
    BOOL isMobile = [self isMobileNumber:_phone.text];
    
    if ([_pwd.text length] < 6) {
        [g_App showAlert:Localized(@"JX_TurePasswordAlert")];
        return;
    }

    if ([g_config.registerInviteCode intValue] == 1) {
        if ([_inviteCode.text length] <= 0) {
            [g_App showAlert:Localized(@"JX_EnterInvitationCode")];
            return;
        }
    }

    if (isMobile) {
        NSString *areaCode = [_arealCodeL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        [g_server checkPhone:_phone.text areaCode:areaCode verifyType:0 toView:self];
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
#ifdef IS_TEST_VERSION
#else
//    if ([_phone.text length] < 11) {       //  为了适配外国电话，将不能显示手机号位数
//        [g_App showAlert:Localized(@"inputPhoneVC_InputTurePhone")];
//        return NO;
//    }
#endif
    
//    if ([_arealCodeL.text isEqualToString:@"+86"]) {
//        NSString *regex = @"^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$";
//        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//        BOOL isMatch = [pred evaluateWithObject:number];
//        
//        if (!isMatch) {
//            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:Localized(@"JXVerifyAccountVC_Prompt") message:Localized(@"JXVerifyAccountVC_PhoneNumberError") delegate:nil cancelButtonTitle:Localized(@"JXVerifyAccountVC_OK") otherButtonTitles:nil, nil];
//            [alert show];
//            //            [alert release];
//            return NO;
//        }
//    }
    return YES;
}

-(void)refreshGraphicAction:(UIButton *)button{
    [self getImgCodeImg];

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
        
        //        [_imgCodeImg sd_setImageWithURL:[NSURL URLWithString:codeUrl] placeholderImage:[UIImage imageNamed:@"refreshImgCode"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            if (!error) {
//                _imgCodeImg.image = image;
//            }else{
//                NSLog(@"%@",error);
//            }
//        }];
    }else{
        
    }
    
}

#pragma mark----验证短信验证码
-(void)onClick{
    
    if([_phone.text length]<=0){
        [g_App showAlert:Localized(@"JX_InputPhone")];
        return;
    }
    if (!_isSkipSMS) {
        if([_code.text length]<6){
            if([_code.text length]<=0){
                [g_App showAlert:Localized(@"JX_InputMessageCode")];
                return;
            }
            [g_App showAlert:Localized(@"inputPhoneVC_MsgCodeNotOK")];
            return; 
        }
        
        if([_smsCode length]<6 && ![_smsCode isEqualToString:@"-1"]){
            [g_App showAlert:Localized(@"inputPhoneVC_NoMegCode")];
            return;
        }
        if (!([_phoneStr isEqualToString:_phone.text] && [_imgCodeStr isEqualToString:_imgCode.text] && ([_smsCode isEqualToString:_code.text] || [_smsCode isEqualToString:@"-1"]))) {
            
            if (![_phoneStr isEqualToString:_phone.text]) {
                [g_App showAlert:Localized(@"JX_No.Changed,Again")];
            }else if (![_imgCodeStr isEqualToString:_imgCode.text]) {
                [g_App showAlert:Localized(@"JX_ImageCodeErrorGetAgain")];
            }else if (![_smsCode isEqualToString:_code.text]) {
                [g_App showAlert:Localized(@"inputPhoneVC_MsgCodeNotOK")];
            }
            
            
            return;
        }
        
    }


    [self.view endEditing:YES];
    if (!_isSkipSMS) {
        if([_code.text isEqualToString:_smsCode] || [_smsCode isEqualToString:@"-1"]){
            self.isSmsRegister = YES;
            [self setUserInfo];
        }
        else
            [g_App showAlert:Localized(@"inputPhoneVC_MsgCodeNotOK")];
    } else {
        self.isSmsRegister = NO;
        [self setUserInfo];
    }

}

- (void)setUserInfo {
    if (_agreeImgV.isHidden == YES) {
        [g_App showAlert:Localized(@"JX_NotAgreeProtocol")];
        return;
    }

    JXUserObject* user = [JXUserObject sharedInstance];
    user.telephone = _phone.text;
    user.password  = [g_server getMD5String:_pwd.text];
    //    user.companyId = [NSNumber numberWithInt:self.isCompany];
    PSRegisterBaseVC* vc = [PSRegisterBaseVC alloc];
    vc.password = _pwd.text;
    vc.isRegister = YES;
    vc.inviteCodeStr = _inviteCode.text;
    vc.smsCode = _code.text;
    vc.resumeId   = nil;
    vc.isSmsRegister = self.isSmsRegister;
    vc.resume     = [[resumeBaseData alloc]init];
    vc.user       = user;
    vc.type = self.type;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    [self actionQuit];
}


-(void)onTest{
    if (_agreeImgV.isHidden == YES) {
        [g_App showAlert:Localized(@"JX_NotAgreeProtocol")];
        return;
    }

//    inputPwdVC* vc = [inputPwdVC alloc];
//    vc.telephone = _phone.text;
//    vc.isCompany = NO;
//    vc = [vc init];
////    [g_window addSubview:vc.view];
//    [g_navigation pushViewController:vc animated:YES];
//    [self actionQuit];
    JXUserObject* user = [JXUserObject sharedInstance];
    user.telephone = _phone.text;
    user.password  = [g_server getMD5String:_pwd.text];
    user.areaCode = [_arealCodeL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];;
    //    user.companyId = [NSNumber numberWithInt:self.isCompany];
    PSRegisterBaseVC* vc = [PSRegisterBaseVC alloc];
    vc.password = _pwd.text;
    vc.isRegister = YES;
    vc.inviteCodeStr = _inviteCode.text;
    vc.smsCode = _code.text;
    vc.resumeId   = nil;
    vc.isSmsRegister = NO;
    vc.resume     = [[resumeBaseData alloc]init];
    
    vc.user       = user;
    vc.type = self.type;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    
    [self actionQuit];
}
//选择区号
//- (void)areaCodeBtnClick:(UIButton *)btn{
//    [self.view endEditing:YES];
//
//    JXTelAreaListVC *telAreaListVC = [[JXTelAreaListVC alloc] init];
//    telAreaListVC.telAreaDelegate = self;
//    telAreaListVC.didSelect = @selector(didSelectTelArea:);
//    [g_window addSubview:telAreaListVC.view];
//}
//
//- (void)didSelectTelArea:(NSString *)areaCode{
//    [_areaCodeBtn setTitle:[NSString stringWithFormat:@"+%@",areaCode] forState:UIControlStateNormal];
//    [self resetBtnEdgeInsets:_areaCodeBtn];
//}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if([aDownload.action isEqualToString:act_SendSMS]){
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
        
        _phoneStr = _phone.text;
        _imgCodeStr = _imgCode.text;
    }

    /*
    if([aDownload.action isEqualToString:act_CheckPhone]){
        NSString *areaCode = [_arealCodeL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        _user = [JXUserObject sharedInstance];
        _user.areaCode = areaCode;
        [g_server sendSMS:[NSString stringWithFormat:@"%@",_phone.text] areaCode:areaCode isRegister:YES toView:self];
        [_send setTitle:Localized(@"JX_Sending") forState:UIControlStateNormal];
        [_wait start:Localized(@"JX_SendNow")];
        [self.view endEditing:YES];
        
        //[g_App.jxServer sendSMS:_phone.text toView:self];
        
    }
    */
    if([aDownload.action isEqualToString:act_CheckPhone]){
        if (self.isCheckToSMS) {
            self.isCheckToSMS = NO;
            [self onSend];
            return;
        }
        if ([g_config.isOpenSMSCode boolValue] && [g_config.regeditPhoneOrName intValue] != 1) {
            [self onClick];
        }else {
            [self onTest];
        }
    }
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    if([aDownload.action isEqualToString:act_SendSMS]){
        
        [_send setTitle:Localized(@"JX_Send") forState:UIControlStateNormal];
        [g_App showAlert:dict[@"resultMsg"]];
        [self getImgCodeImg];
        return hide_error;
    }
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait stop];
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
//验证手机号格式
- (void)sendSMS{
    [_phone resignFirstResponder];
    [_pwd resignFirstResponder];
    [_imgCode resignFirstResponder];
    [_code resignFirstResponder];
    
    if([self isMobileNumber:_phone.text]){
        //请求验证码
        if (_imgCode.text.length < 3) {
            [g_App showAlert:Localized(@"JX_inputImgCode")];
        }else{
            //验证手机号码是否已注册
            self.isCheckToSMS = YES;
            NSString *areaCode = [_arealCodeL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
            [g_server checkPhone:_phone.text areaCode:areaCode verifyType:0 toView:self];
            
        }
        
    }
}

-(void)onSend{
    if (!_send.selected) {
        [_wait start:Localized(@"JX_Testing")];
        //NSString *areaCode = [_arealCodeL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        NSString *areaCode = [_arealCodeL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        _user = [JXUserObject sharedInstance];
        _user.areaCode = areaCode;
        
        [g_server sendSMS:[NSString stringWithFormat:@"%@",_phone.text] areaCode:areaCode isRegister:NO imgCode:_imgCode.text toView:self];
//        [_send setTitle:Localized(@"JX_Sending") forState:UIControlStateNormal];
        _sendL.text = @"重新发送(60)";
        _sendL.userInteractionEnabled = NO;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reduceNum) userInfo:nil repeats:YES];
        //[_wait start:Localized(@"JX_SendNow")];
        //[g_server checkPhone:_phone.text areaCode:areaCode toView:self];
    }
    
}
-(void)reduceNum{
    
    _amount -= 1;
    _sendL.text = [NSString stringWithFormat:@"重新发送(%ld)",(long)_amount];
    if (_amount == 0) {
        [_timer invalidate];
        _timer = nil;
        _amount = 60;
        _sendL.userInteractionEnabled = YES;
         _sendL.text = @"发送";
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if ([g_config.isOpenSMSCode boolValue] && [g_config.regeditPhoneOrName intValue] != 1) {
        if (textField == _phone) {
            [self getImgCodeImg];
        }
    }
#ifndef IS_TEST_VERSION
#endif
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
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
    [_areaCodeBtn setTitle:[NSString stringWithFormat:@"+%@",areaCode] forState:UIControlStateNormal];
    [self resetBtnEdgeInsets:_areaCodeBtn];
}
- (void)resetBtnEdgeInsets:(UIButton *)btn{
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.frame.size.width-2, 0, btn.imageView.frame.size.width+2)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.frame.size.width+2, 0, -btn.titleLabel.frame.size.width-2)];
}
-(void)dealloc{
    if (_timer != nil) {
        [_timer invalidate];
    }
    
    _timer = nil;
}
- (void)hideKeyBoardToView {
    [self.view endEditing:YES];
}


@end
