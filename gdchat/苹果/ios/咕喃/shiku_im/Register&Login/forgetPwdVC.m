//
//  forgetPwdVC.m
//  shiku_im
//
//  Created by flyeagleTang on 14-6-7.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "forgetPwdVC.h"
#import "JXTelAreaListVC.h"
#import "JXUserObject.h"
#import "loginVC.h"
#import "MD5Util.h"

#define HEIGHT 56


@interface forgetPwdVC () <UITextFieldDelegate,UIAlertViewDelegate>
{
   UIButton *_areaCodeBtn;
   NSTimer* timer;
   JXUserObject *_user;
   UIImageView * _imgCodeImg;
   UITextField *_imgCode;   //图片验证码
   UIButton * _graphicButton;
}
@property (nonatomic, strong)UILabel *arealCodeL;
@property (nonatomic, strong)UILabel *sendL;
@property (nonatomic, assign)NSInteger amount;
@end

@implementation forgetPwdVC

- (id)init
{
   self = [super init];
   if (self) {
      
   }
   return self;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   if (self.isModify) {
      self.title = Localized(@"JX_UpdatePassWord");
   }else{
      self.title = Localized(@"JX_ForgetPassWord");
   }
   
   
   _user = [JXUserObject sharedInstance];
   _seconds = 0;
   self.isGotoBack   = YES;
   self.heightFooter = 0;
   self.heightHeader = 0;
   //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
   [self createHeadAndFoot];
//   self.tableBody.backgroundColor = HEXCOLOR(0xF2F2F2);
   _amount = 60;
    int n = INSETS;
   
   UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoardToView)];
   [self.tableBody addGestureRecognizer:tap];
   
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
   
   n += 10+JX_SCREEN_TOP;
   NSString *titleStr = @"";
   if (self.isModify) {
      titleStr = Localized(@"JX_UpdatePassWord");
   }else{
      titleStr = Localized(@"JX_ForgetPassWord");
   }
   UILabel *titleL = [UIFactory createLabelWith:CGRectMake(25, n, 200, 24) text:titleStr];
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
   
   CGFloat W = self.tableBody.frame.size.width;
   
  
   
   /*
    JXLabel* lb;
    lb = [[JXLabel alloc]initWithFrame:CGRectMake(10, 50-n, 60, 30)];
    lb.textColor = [UIColor blackColor];
    lb.backgroundColor = [UIColor clearColor];
    lb.text = @"手机号";
    [self.tableBody addSubview:lb];
    [lb release];
    
    lb = [[JXLabel alloc]initWithFrame:CGRectMake(10, 100-n, 60, 30)];
    lb.textColor = [UIColor blackColor];
    lb.backgroundColor = [UIColor clearColor];
    lb.text = @"验证码";
    [self.tableBody addSubview:lb];
    [lb release];
    
    lb = [[JXLabel alloc]initWithFrame:CGRectMake(10, 150-n, 60, 30)];
    lb.textColor = [UIColor blackColor];
    lb.backgroundColor = [UIColor clearColor];
    lb.text = @"新密码";
    [self.tableBody addSubview:lb];
    [lb release];
    
    lb = [[JXLabel alloc]initWithFrame:CGRectMake(10, 200-n, 60, 30)];
    lb.textColor = [UIColor blackColor];
    lb.backgroundColor = [UIColor clearColor];
    lb.text = @"确认";
    [self.tableBody addSubview:lb];
    [lb release];*/
   
   //区号
   if (!_phone) {
      _phone = [UIFactory createTextFieldWith:CGRectMake(25, n, W-50, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:Localized(@"JX_InputPhone") font:g_factory.font16];
      _phone.clearButtonMode = UITextFieldViewModeWhileEditing;
      _phone.borderStyle = UITextBorderStyleNone;
      _phone.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_InputPhone") attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
      [self.tableBody addSubview:_phone];
      
//      [self showLine:_phone];

      UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, HEIGHT)];
      _phone.leftView = leftView;
      _phone.leftViewMode = UITextFieldViewModeAlways;
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

      UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-LINE_WH, _phone.frame.size.width, LINE_WH)];
       verticalLine.backgroundColor = THE_LINE_COLOR;
       [_phone addSubview:verticalLine];
      
//      UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(_areaCodeBtn.frame.size.width+7, HEIGHT/2 - 8, LINE_WH, 16)];
//      verticalLine.backgroundColor = THE_LINE_COLOR;
//      [self.tableBody addSubview:verticalLine];
      
   }
   n = n+HEIGHT;
   
   //        _code = [[UITextField alloc] initWithFrame:CGRectMake(INSETS,n,188,HEIGHT)];
   //        _code.delegate = self;
   //        _code.autocorrectionType = UITextAutocorrectionTypeNo;
   //        _code.autocapitalizationType = UITextAutocapitalizationTypeNone;
   //        _code.enablesReturnKeyAutomatically = YES;
   //        _code.borderStyle = UITextBorderStyleRoundedRect;
   //        _code.returnKeyType = UIReturnKeyDone;
   //        _code.clearButtonMode = UITextFieldViewModeWhileEditing;
   //        _code.placeholder = Localized(@"JX_InputMessageCode");
   //        [self.tableBody addSubview:_code];
   ////        [_code release];
   //
   //        _send = [UIFactory createButtonWithTitle:Localized(@"JX_Send")
   //                                       titleFont:g_factory.font14
   //                                      titleColor:[UIColor whiteColor]
   //                                          normal:@"feaBtn_backImg_sel"
   //                                       highlight:@"feaBtn_backImg_sel" ];
   //        [_send addTarget:self action:@selector(onSend) forControlEvents:UIControlEventTouchUpInside];
   //        _send.frame = CGRectMake(JX_SCREEN_WIDTH-27-105+INSETS*2, n, 105, HEIGHT);
   //        [self.tableBody addSubview:_send];
   
   if (!self.isModify) {

      
      //图片验证码
      _imgCode = [UIFactory createTextFieldWith:CGRectMake(25, n, self_width-25*2-70-INSETS-35-4, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:Localized(@"JX_inputImgCode") font:g_factory.font16];
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

      n = n+HEIGHT;
      
      
      _code = [[UITextField alloc] initWithFrame:CGRectMake(25, n, JX_SCREEN_WIDTH-75-25*2, HEIGHT)];
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

      
      UILabel *sendL = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-130-25, n+HEIGHT/2-15, 130, 30)];
        sendL.text = @"发送";
      sendL.textAlignment = NSTextAlignmentRight;
        sendL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
      sendL.textColor = g_theme.themeColor;
        [self.tableBody addSubview:sendL];
      sendL.userInteractionEnabled = YES;
      UITapGestureRecognizer *sendTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sendSMS)];
      [sendL addGestureRecognizer:sendTap];
      _sendL = sendL;
      n = n+HEIGHT;

   }
   
   
   if (self.isModify) {
      _oldPwd = [[UITextField alloc] initWithFrame:CGRectMake(25,n,W-50,HEIGHT)];
      _oldPwd.delegate = self;
      _oldPwd.autocorrectionType = UITextAutocorrectionTypeNo;
      _oldPwd.autocapitalizationType = UITextAutocapitalizationTypeNone;
      _oldPwd.enablesReturnKeyAutomatically = YES;
//      _oldPwd.borderStyle = UITextBorderStyleRoundedRect;
      _oldPwd.returnKeyType = UIReturnKeyDone;
      _oldPwd.clearButtonMode = UITextFieldViewModeWhileEditing;
      _oldPwd.placeholder = Localized(@"JX_InputOldPassWord");
      _oldPwd.secureTextEntry = YES;
      _oldPwd.font = g_factory.font16;
      _oldPwd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_InputOldPassWord") attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
      [self.tableBody addSubview:_oldPwd];
      [self showLine:_oldPwd];

      UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, HEIGHT)];
      _oldPwd.leftView = rightView;
      _oldPwd.leftViewMode = UITextFieldViewModeAlways;
      
      UILabel *pwdL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, HEIGHT)];
      pwdL.text = @"输入密码";
      pwdL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
      [rightView addSubview:pwdL];
      
      UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-LINE_WH, _pwd.frame.size.width, LINE_WH)];
      verticalLine.backgroundColor = THE_LINE_COLOR;
      [_pwd addSubview:verticalLine];
      
//      [self createLeftViewWithImage:[UIImage imageNamed:@"password"] superView:_oldPwd];
      n = n+HEIGHT;
      
   }
   
   if (!self.isPayPWD) {
      
      _pwd = [[UITextField alloc] initWithFrame:CGRectMake(25,n,W-50,HEIGHT)];
      _pwd.delegate = self;
      _pwd.autocorrectionType = UITextAutocorrectionTypeNo;
      _pwd.autocapitalizationType = UITextAutocapitalizationTypeNone;
      _pwd.enablesReturnKeyAutomatically = YES;
      //   _pwd.borderStyle = UITextBorderStyleRoundedRect;
      _pwd.returnKeyType = UIReturnKeyDone;
      _pwd.clearButtonMode = UITextFieldViewModeWhileEditing;
      _pwd.placeholder = Localized(@"JX_InputNewPassWord");
      _pwd.secureTextEntry = YES;
      _pwd.font = g_factory.font16;
      [self.tableBody addSubview:_pwd];
      _pwd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_InputNewPassWord") attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
      [self showLine:_pwd];
      
      UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, HEIGHT)];
      _pwd.leftView = rightView;
      _pwd.leftViewMode = UITextFieldViewModeAlways;
      
      UILabel *pwdL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, HEIGHT)];
      pwdL.text = @"新密码";
      pwdL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
      [rightView addSubview:pwdL];
      
      UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-LINE_WH, _pwd.frame.size.width, LINE_WH)];
      verticalLine.backgroundColor = THE_LINE_COLOR;
      [_pwd addSubview:verticalLine];
      
//      [self createLeftViewWithImage:[UIImage imageNamed:@"password"] superView:_pwd];
      n = n+HEIGHT;
      
      _repeat = [[UITextField alloc] initWithFrame:CGRectMake(25,n,W-50,HEIGHT)];
      _repeat.delegate = self;
      _repeat.autocorrectionType = UITextAutocorrectionTypeNo;
      _repeat.autocapitalizationType = UITextAutocapitalizationTypeNone;
      _repeat.enablesReturnKeyAutomatically = YES;
      //   _repeat.borderStyle = UITextBorderStyleRoundedRect;
      _repeat.returnKeyType = UIReturnKeyDone;
      _repeat.clearButtonMode = UITextFieldViewModeWhileEditing;
      _repeat.placeholder = Localized(@"JX_ConfirmNewPassWord");
      _repeat.secureTextEntry = YES;
      _repeat.font = g_factory.font16;
      UIView *repeatRightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, HEIGHT)];
      _repeat.leftView = repeatRightView;
      _repeat.leftViewMode = UITextFieldViewModeAlways;
      _repeat.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_ConfirmNewPassWord") attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
      UILabel *repeatL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, HEIGHT)];
      repeatL.text = @"输入密码";
      repeatL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
      [repeatRightView addSubview:repeatL];
      
      UIView *repeatVerticalLine = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-LINE_WH, _repeat.frame.size.width, LINE_WH)];
      repeatVerticalLine.backgroundColor = THE_LINE_COLOR;
      [_repeat addSubview:repeatVerticalLine];
//      [self createLeftViewWithImage:[UIImage imageNamed:@"password"] superView:_repeat];
      [self.tableBody addSubview:_repeat];
      [self showLine:_repeat];
      
      n = n+HEIGHT;
   }
   
   n += 50;
   
   UIButton* _btn = [UIFactory createCommonButton:Localized(@"JX_UpdatePassWord") target:self action:@selector(onClick:)];
   [_btn.titleLabel setFont:g_factory.font16];
   _btn.layer.masksToBounds = YES;
   _btn.layer.cornerRadius = 25.f;
   _btn.frame = CGRectMake(32, n, W-64, 50);
   [self.tableBody addSubview:_btn];
   
   
   CGRect frame = self.tableBody.frame;
   frame.size.height = CGRectGetMaxY(_btn.frame)+150;
   self.tableBody.frame = frame;
   self.tableBody.scrollEnabled = NO;
   
   _phone.text = g_myself.phone;
   if (self.isModify) {
      _phone.enabled = NO;

   }else{
      if (_phone.text.length > 0) {
         [self getImgCodeImg];
      }

   }
   
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}

-(void)refreshGraphicAction:(UIButton *)button{
   [self getImgCodeImg];
}

-(void)getImgCodeImg{
   if(_phone.text.length > 0){
      //    if ([self checkPhoneNum]) {
      //请求图片验证码
      NSString *areaCode = [_arealCodeL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
      NSString * codeUrl = [g_server getImgCode:_phone.text areaCode:areaCode];
      NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:codeUrl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0];
      
      [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
         if (!connectionError) {
            UIImage * codeImage = [UIImage imageWithData:data];
            if (codeImage != nil) {
               _imgCodeImg.image = codeImage;
            }else{
               [g_App showAlert:Localized(@"JX_ImageCodeFailed")];
            }
            
         }else{
            NSLog(@"%@",connectionError);
            [g_App showAlert:connectionError.localizedDescription];
         }
      }];
//      [_imgCodeImg sd_setImageWithURL:[NSURL URLWithString:codeUrl] placeholderImage:[UIImage imageNamed:@"refreshImgCode"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//         if (!error) {
//            _imgCodeImg.image = image;
//         }else{
//            NSLog(@"%@",error);
//         }
//      }];
   }else{
      
   }
   
}


#pragma mark------验证
-(void)onClick:(UIButton *)btn{
   btn.enabled = NO;
   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      btn.enabled = YES;
   });
   if([_phone.text length]<= 0){
      [g_App showAlert:Localized(@"JX_InputPhone")];
      return;
   }

   if (!self.isModify) {

      if([_code.text length]<4){
         //_code.text = @"1315";
         [g_App showAlert:Localized(@"JX_InputMessageCode")];
         return;
      }

   }
   if (self.isModify && [_oldPwd.text length] <= 0){
      [g_App showAlert:Localized(@"JX_InputPassWord")];
      return;
   }
   
   if (!self.isPayPWD) {
      if([_pwd.text length]<=0){
         [g_App showAlert:Localized(@"JX_InputPassWord")];
         return;
      }
      if ([_pwd.text length] < 6) {
         [g_App showAlert:Localized(@"JX_TurePasswordAlert")];
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
      
      if ([_pwd.text isEqualToString:_oldPwd.text]) {
         [g_App showAlert:Localized(@"JX_PasswordOriginal")];
         return;
      }
   }
   
   //   if([_smsCode length]<=0){
   //      //忽略短信验证
   //      //_smsCode = _code.text;
   //      [g_App showAlert:@"请输入验证码"];
   //      return;
   //   }
   [self.view endEditing:YES];
   NSString *areaCode = [_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
   if (self.isModify){
      [_wait start];
      
#ifdef IS_MsgEncrypt
      if ([g_config.isOpenSecureChat boolValue]) {
         if (g_msgUtil.dhPrivateKey && g_msgUtil.dhPrivateKey.length > 0) {
            [g_server userGetRandomStr:self];
         }else {
            [g_server updatePwd:_phone.text areaCode:areaCode oldPwd:_oldPwd.text newPwd:_pwd.text checkCode:nil toView:self];
         }
      }else {
         [g_server updatePwd:_phone.text areaCode:areaCode oldPwd:_oldPwd.text newPwd:_pwd.text checkCode:nil toView:self];
      }
#else
      [g_server updatePwd:_phone.text areaCode:areaCode oldPwd:_oldPwd.text newPwd:_pwd.text checkCode:nil toView:self];
#endif
   }else{
      
      [_wait start];
      if (self.isPayPWD) {
         long time = (long)[[NSDate date] timeIntervalSince1970];
         time = time *1000 + g_server.timeDifference;
         NSString *salt = [NSString stringWithFormat:@"%ld",time];
         NSString *mac = [self getResetPayPWDMacWithSalt:salt];
         [g_server authkeysResetPayPasswordWithSalt:salt mac:mac toView:self];
      }else {
      
#ifdef IS_MsgEncrypt
         if ([g_config.isOpenSecureChat boolValue]) {
            //忘记密码将会重置端到端加密秘钥，服务器上的所有消息都将被清空
            [g_App showAlert:Localized(@"JX_ForgetPasswordResetKey") delegate:self tag:2457 onlyConfirm:NO];
         }else {
            NSString *areaCode = [_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
            [g_server resetPwd:_phone.text areaCode:areaCode randcode:_code.text newPwd:_pwd.text toView:self];
         }
#else
         NSString *areaCode = [_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
         [g_server resetPwd:_phone.text areaCode:areaCode randcode:_code.text newPwd:_pwd.text toView:self];
#endif
      }
      
//      BOOL b = YES;
//
//      b = [_code.text isEqualToString:_smsCode];
//
//      if(b){
//
//      }
//      else
//         [g_App showAlert:Localized(@"inputPhoneVC_MsgCodeNotOK")];
       //        [g_App showAlert:@"短信验证码不对"];
   }
  
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
   if (buttonIndex == 1) {
      if (alertView.tag == 2457) {
         
         NSString *areaCode = [_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
         [g_server resetPwd:_phone.text areaCode:areaCode randcode:_code.text newPwd:_pwd.text toView:self];
      }
   }
   
}

- (NSString *)getResetPayPWDMacWithSalt:(NSString *)salt {
   
   NSMutableString *str = [NSMutableString string];
   [str appendString:APIKEY];
   [str appendString:g_myself.userId];
   [str appendString:g_server.access_token];
   [str appendString:salt];
   
   NSData *key = [MD5Util getMD5DataWithString:_code.text];
   NSData *macData = [g_securityUtil getHMACMD5:[str dataUsingEncoding:NSUTF8StringEncoding] key:key];
   
   NSString *mac = [macData base64EncodedStringWithOptions:0];
   return mac;
}

//验证手机号格式
- (void)sendSMS{
   [_phone resignFirstResponder];
   [_imgCode resignFirstResponder];
   [_code resignFirstResponder];
   
   _send.enabled = NO;
   if (_imgCode.text.length < 3) {
      [g_App showAlert:Localized(@"JX_inputImgCode")];
      _send.enabled = YES;
      return;
   }
   
   [self onSend];
   
//   if([self isMobileNumber:_phone.text]){
//      //验证手机号码是否已注册
//      //        [g_server verifyPhone:[NSString stringWithFormat:@"%@%@",[_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""],_phoneNumTextField.text] toView:self];
//
//      //请求验证码
//
//
//   }else {
//      _send.enabled = YES;
//   }
}
//验证手机号码格式
- (BOOL)isMobileNumber:(NSString *)number{
   if ([_phone.text length] == 0) {
      UIAlertView* alert = [[UIAlertView alloc] initWithTitle:Localized(@"JX_Tip") message:Localized(@"JX_InputPhone") delegate:nil cancelButtonTitle:Localized(@"JX_Confirm") otherButtonTitles:nil, nil];
      [alert show];
      //        [alert release];
      return NO;
   }
   
   if ([_areaCodeBtn.titleLabel.text isEqualToString:@"+86"]) {
      NSString *regex = @"^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$";
      NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
      BOOL isMatch = [pred evaluateWithObject:number];
      
      if (!isMatch) {
         [g_App showAlert:Localized(@"inputPhoneVC_InputTurePhone")];
//         UIAlertView* alert = [[UIAlertView alloc] initWithTitle:Localized(@"JXVerifyAccountVC_Prompt") message:Localized(@"JXVerifyAccountVC_PhoneNumberError") delegate:nil cancelButtonTitle:Localized(@"JXVerifyAccountVC_OK") otherButtonTitles:nil, nil];
//         [alert show];
         //            [alert release];
         return NO;
      }
   }
   return YES;
}

-(void)onSend{
   
   if (!_send.selected) {
      [_wait start];
      NSString *areaCode = [_arealCodeL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
      //      _user = [JXUserObject sharedInstance];
      _user.areaCode = areaCode;
      [g_server sendSMS:[NSString stringWithFormat:@"%@",_phone.text] areaCode:areaCode isRegister:NO imgCode:_imgCode.text toView:self];
      _sendL.text = @"重新发送 (60)";
      _sendL.userInteractionEnabled = NO;
      timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reduceNum) userInfo:nil repeats:YES];
   }
   
}
-(void)reduceNum{
    
    _amount -= 1;
    _sendL.text = [NSString stringWithFormat:@"重新发送 (%ld)",(long)_amount];
    if (_amount == 0) {
        [timer invalidate];
        timer = nil;
        _amount = 60;
        _sendL.userInteractionEnabled = YES;
         _sendL.text = @"发送";
    }
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
   [_wait stop];
   if([aDownload.action isEqualToString:act_SendSMS]){
      [JXMyTools showTipView:Localized(@"JXAlert_SendOK")];
      _send.enabled = YES;
      _send.selected = YES;
      _send.userInteractionEnabled = NO;
      _send.backgroundColor = [UIColor grayColor];
      _smsCode = [[dict objectForKey:@"code"] copy];
      [_send setTitle:@"60s" forState:UIControlStateSelected];
      _seconds = 60;
      timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showTime:) userInfo:_send repeats:YES];
   }
   if([aDownload.action isEqualToString:act_PwdUpdate] || [aDownload.action isEqualToString:act_PwdUpdateV1]){
      [g_App showAlert:Localized(@"JX_UpdatePassWordOK")];
      g_myself.password = [g_server getMD5String:_pwd.text];
      [g_default setObject:[g_server getMD5String:_pwd.text] forKey:kMY_USER_PASSWORD];
      [g_default setObject:nil forKey:kMY_USER_PrivateKey_DH];
      [g_default setObject:nil forKey:kMY_USER_PrivateKey_RSA];
      [g_default synchronize];
      [self actionQuit];
      [self relogin];
   }
   if([aDownload.action isEqualToString:act_PwdReset] || [aDownload.action isEqualToString:act_PwdResetV1]){
      [g_App showAlert:Localized(@"JX_UpdatePassWordOK")];
      g_myself.password = [g_server getMD5String:_pwd.text];
      [g_default setObject:[g_server getMD5String:_pwd.text] forKey:kMY_USER_PASSWORD];
      [g_default synchronize];
      [self actionQuit];
   }
   
   if ([aDownload.action isEqualToString:act_UserGetRandomStr]) {
      
      NSString *checkCode = nil;
#ifdef IS_MsgEncrypt
      if ([g_config.isOpenSecureChat boolValue]) {
         NSString *userRandomStr = [dict objectForKey:@"userRandomStr"];
         SecKeyRef privateKey = [g_securityUtil getRSAKeyWithBase64Str:g_msgUtil.rsaPrivateKey isPrivateKey:YES];
         NSData *randomData = [[NSData alloc] initWithBase64EncodedString:userRandomStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
         NSData *codeData = [g_securityUtil decryptMessageRSA:randomData withPrivateKey:privateKey];
         checkCode = [[NSString alloc] initWithData:codeData encoding:NSUTF8StringEncoding];
      }
#endif
      
      NSString *areaCode = [_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
      [g_server updatePwd:_phone.text areaCode:areaCode oldPwd:_oldPwd.text newPwd:_pwd.text checkCode:checkCode toView:self];
   }
   
   if ([aDownload.action isEqualToString:act_AuthkeysResetPayPassword]) {
      if ([self.delegate respondsToSelector:@selector(forgetPwdSuccess)]) {
         [self actionQuit];
         [self.delegate forgetPwdSuccess];
      }
   }
   
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
   if([aDownload.action isEqualToString:act_SendSMS]){
      [_send setTitle:Localized(@"JX_SendAngin") forState:UIControlStateNormal];
      _send.enabled = YES;

   }else if ([aDownload.action isEqualToString:act_PwdUpdate] || [aDownload.action isEqualToString:act_PwdUpdateV1]) {
      NSString *error = [dict objectForKey:@"resultMsg"];
      
      [g_App showAlert:[NSString stringWithFormat:@"%@",error]];
      
      return hide_error;
   }
   
   [_wait stop];
   return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
   [_wait stop];
   _send.enabled = YES;
   return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
   [_wait stop];
}

-(void)showTime:(NSTimer*)sender{
   UIButton *but = (UIButton*)[timer userInfo];
   _seconds--;
   [but setTitle:[NSString stringWithFormat:@"%ds",_seconds] forState:UIControlStateSelected];
   if(_seconds<=0){
      but.selected = NO;
      but.userInteractionEnabled = YES;
      UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
      [but setBackgroundImage:img forState:UIControlStateHighlighted];
      but.backgroundColor = g_theme.themeColor;
      [_send setTitle:Localized(@"JX_SendAngin") forState:UIControlStateNormal];
      if (timer) {
         timer = nil;
         [sender invalidate];
      }
      _seconds = 60;
      
   }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{

   if (textField == _phone) {
      [self getImgCodeImg];
   }


}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
   
   if (_phone == textField) {
      return [self validateNumber:string];
   }
   return YES;
}

- (BOOL)validateNumber:(NSString*)number {
   // 只能使用字母和数字
   NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"] invertedSet];
   NSString *filtered = [[number componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
   return [number isEqualToString:filtered];
   
}





- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   [self.view endEditing:YES];
   return YES;
}
- (void)areaCodeBtnClick:(UIButton *)but{
   [self.view endEditing:YES];
   JXTelAreaListVC *telAreaListVC = [[JXTelAreaListVC alloc] init];
   telAreaListVC.telAreaDelegate = self;
   telAreaListVC.didSelect = @selector(didSelectTelArea:);
//   [g_window addSubview:telAreaListVC.view];
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
   if (timer != nil) {
      [timer invalidate];
    }
    
   timer = nil;
}

-(void)relogin{
   [g_default removeObjectForKey:kMY_USER_PASSWORD];
   [g_default removeObjectForKey:kMY_USER_TOKEN];
   [share_defaults removeObjectForKey:kMY_ShareExtensionToken];
   //    [g_default setObject:nil forKey:kMY_USER_TOKEN];
   g_server.access_token = nil;
   
   [g_notify postNotificationName:kSystemLogoutNotifaction object:nil];
   [[JXXMPP sharedInstance] logout];
   NSLog(@"XMPP ---- forgetPwdVC relogin");
   
   loginVC* vc = [loginVC alloc];
   vc.isAutoLogin = NO;
   vc.isSwitchUser= NO;
   vc = [vc init];
   [g_mainVC.view removeFromSuperview];
   g_mainVC = nil;
   [self.view removeFromSuperview];
   self.view = nil;
   
   g_navigation.rootViewController = vc;
   //    g_navigation.lastVC = nil;
   //    [g_navigation.subViews removeAllObjects];
   //    [g_navigation pushViewController:vc];
   //    g_App.window.rootViewController = vc;
   //    [g_App.window makeKeyAndVisible];
   
   //    loginVC* vc = [loginVC alloc];
   //    vc.isAutoLogin = NO;
   //    vc.isSwitchUser= NO;
   //    vc = [vc init];
   //    [g_window addSubview:vc.view];
   //    [self actionQuit];
   //    [_wait performSelector:@selector(stop) withObject:nil afterDelay:1];
   [_wait stop];
#if TAR_IM
#ifdef Meeting_Version
   [g_meeting stopMeeting];
#endif
#endif
}


- (void)createLeftViewWithImage:(UIImage *)image superView:(UITextField *)textField {
   UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 27, HEIGHT)];
   textField.leftView = leftView;
   textField.leftViewMode = UITextFieldViewModeAlways;
   UIImageView *leIgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, HEIGHT/2-10, 20, 20)];
   leIgView.image = image;
   leIgView.contentMode = UIViewContentModeScaleAspectFit;
   [leftView addSubview:leIgView];
}


- (void)showLine:(UIView *)view {
   UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height-LINE_WH, view.frame.size.width, LINE_WH)];
   line.backgroundColor = THE_LINE_COLOR;
   [view addSubview:line];
}
- (void)hideKeyBoardToView {
    [self.view endEditing:YES];
}
@end
