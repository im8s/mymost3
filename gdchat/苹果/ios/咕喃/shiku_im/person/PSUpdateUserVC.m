 //
//  PSUpdateUserVC.m
//  shiku_im
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "PSUpdateUserVC.h"
//#import "selectTreeVC.h"
#import "selectValueVC.h"
#import "selectProvinceVC.h"
#import "ImageResize.h"
#import "JXQRCodeViewController.h"
#import "JXActionSheetVC.h"
#import "JXCameraVC.h"
#import "JXSetShikuNumVC.h"
#import "JXInputValueVC.h"

#define HEIGHT 56
#define IMGSIZE 36


@interface PSUpdateUserVC ()<UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, JXActionSheetVCDelegate,JXCameraVCDelegate,JXSetShikuNumVCDelegate,UIScrollViewDelegate>

@property (nonatomic, assign) BOOL isUpdate;
@property (nonatomic, strong) UILabel *desLabel;
@end

@implementation PSUpdateUserVC
@synthesize user;

- (id)init
{
    self = [super init];
    if (self) {
        self.isGotoBack   = YES;
        if(self.isRegister)
            self.title = [NSString stringWithFormat:@"4.%@",Localized(@"PSUpdateUserVC")];
        else
            self.title = Localized(@"JX_BaseInfo");
        self.heightFooter = 0;
        self.heightHeader = JX_SCREEN_TOP;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self createHeadAndFoot];
        self.tableBody.backgroundColor = HEXCOLOR(0xF2F2F2);
        self.tableBody.scrollEnabled = YES;
        self.tableBody.delegate = self;
//        UIButton * qrButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        qrButton.frame = CGRectMake(JX_SCREEN_WIDTH-35-8, 30, 35, 30);
//        [qrButton setBackgroundImage:[UIImage imageNamed:@"qrcodeImage_white"] forState:UIControlStateNormal];
//        [qrButton setBackgroundImage:[UIImage imageNamed:@"qrcodeImage_white"] forState:UIControlStateHighlighted];
//        [qrButton addTarget:self action:@selector(showUserQRCode) forControlEvents:UIControlEventTouchUpInside];
//        [self.tableHeader addSubview:qrButton];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [g_notify postNotificationName:kUpdateUserNotifaction object:self userInfo:nil];
        });
        
        [g_server delHeadImage:user.userId];
        
        [self createCustomView];
        

        [g_notify addObserver:self selector:@selector(changeKeyBoard:) name:UIKeyboardWillShowNotification object:nil];
        [g_notify addObserver:self selector:@selector(updateUserInfo:) name:kXMPPMessageUpadteUserInfoNotification object:nil];

    }
    return self;
}

- (void)updateUserInfo:(NSNotification *)noti {
    [g_server getUser:g_server.myself.userId toView:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _date.hidden = YES;
}

- (void) createCustomView {
    
    int h = 0;
    NSString* s;
    
    JXImageView* iv;
    iv = [[JXImageView alloc]init];
    iv.frame = self.tableBody.bounds;
    iv.delegate = self;
    iv.didTouch = @selector(hideKeyboard);
    [self.tableBody addSubview:iv];

    iv = [self createButton:Localized(@"JX_Icon") drawTop:NO drawBottom:YES must:YES click:@selector(pickImage)];
    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);

    _head = [[JXImageView alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-IMGSIZE-41, (HEIGHT-IMGSIZE)/2, IMGSIZE, IMGSIZE)];
    _head.layer.cornerRadius = 5;
    _head.layer.masksToBounds = YES;
    _head.image = self.headImage;
    s = user.userId;
    [g_server getHeadImageLarge:s userName:user.userNickname imageView:_head getHeadHandler:nil];
    
    [iv addSubview:_head];

    h+=iv.frame.size.height;

    NSString* city = [g_constant getAddressForNumber:user.provinceId cityId:user.cityId areaId:user.areaId];

    iv = [self createButton:Localized(@"JX_Name") drawTop:NO drawBottom:YES must:YES click:nil];
    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _name = [self createTextField:iv default:user.userNickname hint:Localized(@"JX_InputName")];
    //        _name.userInteractionEnabled = self.isRegister;
    h+=iv.frame.size.height;
    [_name addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    iv = [self createButton:Localized(@"JX_Sex") drawTop:NO drawBottom:YES must:YES click:nil];
    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _sex = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:Localized(@"JX_Wuman"),Localized(@"JX_Man"),nil]];
    _sex.frame = CGRectMake(JX_SCREEN_WIDTH -100 - 15,INSETS+3,100,HEIGHT-INSETS*2-6);
    _sex.userInteractionEnabled = YES;
    //样式
    //        _sex.segmentedControlStyle= UISegmentedControlStyleBar;
    _sex.tintColor = THEMECOLOR;
    _sex.layer.cornerRadius = 5;
    _sex.layer.borderWidth = 1.5;
    _sex.layer.borderColor = [THEMECOLOR CGColor];
    _sex.clipsToBounds = YES;
    //设置文字属性
    _sex.selectedSegmentIndex = [user.sex boolValue];
    _sex.apportionsSegmentWidthsByContent = NO;
    [iv addSubview:_sex];
    //        [_sex release];
    h+=iv.frame.size.height;
    
    iv = [self createButton:Localized(@"JX_BirthDay") drawTop:NO drawBottom:YES must:YES click:nil];
    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _birthday = [self createTextField:iv default:[TimeUtil getDateStr:[user.birthday timeIntervalSince1970]] hint:Localized(@"JX_BirthDay")];
    h+=iv.frame.size.height;
    
    if ([g_config.isOpenPositionService intValue] == 0) {
        iv = [self createButton:Localized(@"JXUserInfoVC_Address") drawTop:NO drawBottom:YES must:YES click:@selector(onCity)];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        _city = [self createLabel:iv default:city];
        h+=iv.frame.size.height;
    }
    
    if (!self.isRegister) {
        iv = [self createButton:Localized(@"JX_MyQRImage") drawTop:NO drawBottom:YES must:NO click:@selector(showUserQRCode)];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        UIImageView * qrView = [[UIImageView alloc] init];
        qrView.frame = CGRectMake(JX_SCREEN_WIDTH-15-7-9-16, (HEIGHT-16)/2, 16, 16);
        qrView.image = [UIImage imageNamed:@"qrcodeImage"];
        [iv addSubview:qrView];
        h+=iv.frame.size.height;
        
//        UIImageView * qrView = [[UIImageView alloc] init];
//        qrView.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3-30, 10, 30, 30);
//        qrView.image = [UIImage imageNamed:@"qrcodeImage"];
//        [iv addSubview:qrView];
        
        iv = [self createButton:Localized(@"JX_MyPhoneNumber") drawTop:NO drawBottom:YES must:NO click:nil];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        [self createLabel:iv default:g_myself.telephone];
        h+=iv.frame.size.height;
        
        // 鲸鱼号
        if ([self.user.setAccountCount integerValue] > 0) {
            
            iv = [self createButton:Localized(@"JX_Communication") drawTop:NO drawBottom:NO must:NO click:nil];
        }else {
            
            iv = [self createButton:Localized(@"JX_Communication") drawTop:NO drawBottom:NO must:NO click:@selector(onShikuNum)];
        }
        UILabel *lab = [self createLabel:iv default:self.user.account];
        
        if ([self.user.setAccountCount integerValue] <= 0) {
            CGSize lSize = [self.user.account sizeWithAttributes:@{NSFontAttributeName:SYSFONT(15)}];
            CGRect frame = lab.frame;
            frame.origin.x = JX_SCREEN_WIDTH - lSize.width - INSETS - 20;
            lab.frame = frame;
        }
        
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        //            [self createLabel:iv default:g_myself.telephone];
        h+=iv.frame.size.height;
        
        if ([g_config.registerInviteCode intValue] == 2) {
            iv = [self createButton:Localized(@"JX_InvitationCode") drawTop:YES drawBottom:NO must:NO click:nil];
            iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
            [self createLabel:iv default:g_myself.myInviteCode];
            h+=iv.frame.size.height;
        }
        
        iv = [self createButton:Localized(@"PERSONALIZED_SIGNATURE") drawTop:YES drawBottom:NO must:NO click:@selector(onIputDes)];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
         _desLabel = [self createLabel:iv default:self.user.userDescription];
        h+=iv.frame.size.height;
        if (self.user.userDescription.length > 0) {
            [self updateDesLabelFrame];
        }

    }
    
    h+=40;
    UIButton* _btn;
    if(self.isRegister)
        _btn = [UIFactory createCommonButton:Localized(@"JX_NextStep") target:self action:@selector(onInsert)];
    else
        _btn = [UIFactory createCommonButton:Localized(@"JX_Update") target:self action:@selector(onUpdate)];
    _btn.layer.cornerRadius = 7;
    _btn.clipsToBounds = YES;
    _btn.custom_acceptEventInterval = 1.0f;
    _btn.frame = CGRectMake(INSETS, h, WIDTH, 40);
    [self.tableBody addSubview:_btn];
    int height = 200;
    if (THE_DEVICE_HAVE_HEAD) {
        height = 235;
    }
    _date = [[JXDatePicker alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-height, JX_SCREEN_WIDTH, height)];
    _date.datePicker.datePickerMode = UIDatePickerModeDate;
    _date.date = user.birthday;
    _date.delegate = self;
    _date.didChange = @selector(onDate:);
    _date.didSelect = @selector(onDate:);
    
    if (self.tableBody.frame.size.height < h+HEIGHT+INSETS) {
        self.tableBody.contentSize = CGSizeMake(0, h+HEIGHT+INSETS);
    }
}

- (void)updateDesLabelFrame {
    CGSize lSize = [self.user.userDescription sizeWithAttributes:@{NSFontAttributeName:SYSFONT(15)}];
    if (lSize.width > JX_SCREEN_WIDTH/2-INSETS - 20) {
        lSize.width = JX_SCREEN_WIDTH/2-INSETS - 20;
    }
    CGRect frame = _desLabel.frame;
    frame.origin.x = JX_SCREEN_WIDTH - lSize.width - INSETS - 20;
    frame.size.width = lSize.width;
    _desLabel.frame = frame;

}
- (void)onIputDes {
    JXInputValueVC* vc = [JXInputValueVC alloc];
    vc.value = g_myself.userDescription;
    vc.title = Localized(@"PERSONALIZED_SIGNATURE");
    vc.delegate  = self;
    vc.didSelect = @selector(onSaveRoomName:);
    vc.isLimit = YES;
    vc.limitLen = 30;
    vc = [vc init];
    
    [g_navigation pushViewController:vc animated:YES];
}

- (void)onSaveRoomName:(JXInputValueVC*)vc {
    self.isUpdate = YES;
    _desLabel.text = vc.value;
    user.userDescription = vc.value;
    
    [self updateDesLabelFrame];
}

-(void)dealloc{
//    NSLog(@"PSUpdateUserVC.dealloc");
    [g_notify removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [g_notify removeObserver:self name:kXMPPMessageUpadteUserInfoNotification object:nil];
//    [_image release];
    self.user = nil;
    
    [_date removeFromSuperview];
//    [_date release];
//    [super dealloc];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
    if(textField == _birthday){
        [self.view endEditing:YES];
        [g_window addSubview:_date];
        _date.hidden = NO;
        return NO;
    }else{
        if (textField == _name && textField.text.length > 0) {
            _name.frame = CGRectMake(JX_SCREEN_WIDTH/2-8,INSETS,JX_SCREEN_WIDTH/2,HEIGHT-INSETS*2);
        }
        _date.hidden = YES;
        return YES;
    }

}

- (void)textDidChange:(UITextField *)textField {
    if (textField == _name) {
        if (textField.text.length > 0) {
            _name.frame = CGRectMake(JX_SCREEN_WIDTH/2-8,INSETS,JX_SCREEN_WIDTH/2,HEIGHT-INSETS*2);
        }else {
            _name.frame = CGRectMake(JX_SCREEN_WIDTH/2-15,INSETS,JX_SCREEN_WIDTH/2,HEIGHT-INSETS*2);
        }
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


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == _name) {
        _name.frame = CGRectMake(JX_SCREEN_WIDTH/2-15,INSETS,JX_SCREEN_WIDTH/2,HEIGHT-INSETS*2);
    }

    return YES;
}

- (IBAction)onDate:(id)sender {
    NSDate *selected = [_date date];
//    user.birthday = selected;
    _birthday.text = [TimeUtil formatDate:selected format:@"yyyy-MM-dd"];
    //    _date.hidden = YES;
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:act_UploadHeadImage] ){
//        _head.image = _image;
//        [_image release];
        _image = nil;
        
        [g_server delHeadImage:user.userId];
        if(self.isRegister){
            [g_App showMainUI];
            [g_App showAlert:Localized(@"JX_RegOK")];
        }else{
            [g_App showAlert:Localized(@"JXAlert_UpdateOK")];
        }
        
        NSString* s1;
        //获取userId
        if([user.userId isKindOfClass:[NSNumber class]])
            s1 = [(NSNumber*)user.userId stringValue];
        else
            s1 = user.userId;
        
        NSString* dir1 = [NSString stringWithFormat:@"%lld",[s1 longLongValue] % 10000];
        //头像网址
        NSString* url2  = [NSString stringWithFormat:@"%@avatar/o/%@/%@.jpg",g_config.downloadAvatarUrl,dir1,s1];
        [_head sd_setImageWithURL:[NSURL URLWithString:url2] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [g_notify postNotificationName:kUpdateUserNotifaction object:self userInfo:nil];
            [self actionQuit];
        }];
        
    }
    if( [aDownload.action isEqualToString:act_Register] || [aDownload.action isEqualToString:act_RegisterV1] ){
        [g_server doLoginOK:dict user:user];
        self.user = g_server.myself;
        [g_server uploadHeadImage:user.userId image:_image toView:self];
        
        [g_notify postNotificationName:kRegisterNotifaction object:self userInfo:nil];
    }
    if( [aDownload.action isEqualToString:act_UserUpdate] ){
        if(_image)
            [g_server uploadHeadImage:user.userId image:_image toView:self];
        else{
            user.userNickname = _name.text;
            user.sex = [NSNumber numberWithInteger:_sex.selectedSegmentIndex];
            user.birthday = _date.date;
            user.cityId = [NSNumber numberWithInt:[_city.text intValue]];
            [g_App showAlert:Localized(@"JXAlert_UpdateOK")];
            g_server.myself.userNickname = user.userNickname;
            g_server.myself.userDescription = user.userDescription;
            [g_default setObject:g_server.myself.userNickname forKey:kMY_USER_NICKNAME];
            [g_notify postNotificationName:kUpdateUserNotifaction object:self userInfo:nil];
            [self actionQuit];
        }
    }
    if ([aDownload.action isEqualToString:act_UserGet]) {
        JXUserObject* user = [[JXUserObject alloc]init];
        [user getDataFromDict:dict];
        self.user = user;
        [self createCustomView];
    }
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];    
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
//    [btn release];
    
//    if(must){
//        UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, 5, 20, HEIGHT-5)];
//        p.text = @"*";
//        p.font = g_factory.font18;
//        p.backgroundColor = [UIColor clearColor];
//        p.textColor = [UIColor redColor];
//        p.textAlignment = NSTextAlignmentCenter;
//        [btn addSubview:p];
//    }
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(15, 0, JX_SCREEN_WIDTH/2-15, HEIGHT)];
    p.text = title;
    p.font = g_factory.font15;
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    [btn addSubview:p];
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(15,0,JX_SCREEN_WIDTH-15,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(15, HEIGHT-LINE_WH,JX_SCREEN_WIDTH-15,LINE_WH)];
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
    UITextField* p = [[UITextField alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2-15,INSETS,JX_SCREEN_WIDTH/2,HEIGHT-INSETS*2)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.borderStyle = UITextBorderStyleNone;
    p.returnKeyType = UIReturnKeyDone;
    p.clearButtonMode = UITextFieldViewModeWhileEditing;
    p.textAlignment = NSTextAlignmentRight;
    p.userInteractionEnabled = YES;
    p.textColor = HEXCOLOR(0x999999);
    p.text = s;
    p.placeholder = hint;
    p.font = g_factory.font15;
    [parent addSubview:p];
    return p;
}

-(UILabel*)createLabel:(UIView*)parent default:(NSString*)s{
    UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2,INSETS,JX_SCREEN_WIDTH/2 -30,HEIGHT-INSETS*2)];
    p.userInteractionEnabled = NO;
    p.text = s;
    p.font = g_factory.font15;
    p.textAlignment = NSTextAlignmentRight;
    p.textColor = HEXCOLOR(0x999999);
    [parent addSubview:p];
    
    CGSize size = [s boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:g_factory.font15} context:nil].size;
    CGRect frame = p.frame;
    frame.size.width = size.width;
    frame.origin.x = JX_SCREEN_WIDTH - size.width - INSETS;
    p.frame = frame;
    
    NSString* city = [g_constant getAddressForNumber:user.provinceId cityId:user.cityId areaId:user.areaId];
    
    if ([s isEqualToString:city]) {
        CGSize size = [Localized(@"JXUserInfoVC_Address") boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:g_factory.font13} context:nil].size;
        p.frame = CGRectMake(size.width + 30 + 10, INSETS, JX_SCREEN_WIDTH - size.width - 30 - 10 - 30, HEIGHT - INSETS * 2);
    }
    if ([s isEqualToString:g_myself.myInviteCode]) {
        p.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPre:)];
        [p addGestureRecognizer:longPress];
        _inviteCode = p;
    }
    
    return p;
}

// 使label能够成为响应事件，为了能接收到事件（能成为第一响应者）
- (BOOL)canBecomeFirstResponder{
    return YES;
}
// 可以控制响应的方法
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return (action == @selector(copy:));
}
//针对响应方法的实现，最主要的复制的两句代码
- (void)copy:(id)sender{
    //UIPasteboard：该类支持写入和读取数据，类似剪贴板
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    pasteBoard.string = [_inviteCode text];
}
// 处理长按事件
- (void)longPre:(UILongPressGestureRecognizer *)recognizer{
    [self becomeFirstResponder]; // 用于UIMenuController显示，缺一不可
    UIView *view = recognizer.view;
    //UIMenuController：可以通过这个类实现点击内容，或者长按内容时展示出复制等选择的项，每个选项都是一个UIMenuItem对象
//    UIMenuItem *copyLink = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copy:)];
//    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:copyLink, nil]];
    [[UIMenuController sharedMenuController] setTargetRect:view.frame inView:view.superview];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
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
    if (self) {
        [self resetViewFrame];
    }

    if ([user.cityId intValue] != sender.cityId) {
        self.isUpdate = YES;
    }

    user.cityId = [NSNumber numberWithInt:sender.cityId];
    user.provinceId = [NSNumber numberWithInt:sender.provinceId];
    user.areaId = [NSNumber numberWithInt:sender.areaId];
    user.countryId = [NSNumber numberWithInt:1];
    _city.text = sender.selValue;
}
//归位
- (void)resetViewFrame{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, self.view.frame.size.height);
    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _image = [ImageResize image:[info objectForKey:@"UIImagePickerControllerEditedImage"] fillSize:CGSizeMake(640, 640)];
//    [_image retain];
    _head.image = _image;
    [picker dismissViewControllerAnimated:YES completion:nil];
//    [picker.view removeFromSuperview];
    //	[self dismissModalViewControllerAnimated:YES];
    
    
    
//	[picker release];
}

- (void) pickImage
{
    [self hideKeyboard];
    
    JXActionSheetVC *actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:@[Localized(@"JX_ChoosePhoto"),Localized(@"JX_TakePhoto")]];
    actionVC.delegate = self;
    [self presentViewController:actionVC animated:NO completion:nil];
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
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
//    [picker.view removeFromSuperview];
//    [picker release];
    //	[self dismissModalViewControllerAnimated:YES];
}

-(void)onUpdate{
    if(![self getInputValue])
        return;
    
    if (_image || self.isUpdate) {
        [g_server updateUser:user toView:self];
    }else {
        
        [self actionQuit];
    }

}

-(void)onInsert{
    if(![self getInputValue])
        return;
//    [g_server registerUser:user inviteCode:nil workexp:0 diploma:0 isSmsRegister:NO toView:self];
    [g_loginServer registerUserV1:user type:0 inviteCode:nil workexp:0 diploma:0 isSmsRegister:NO smsCode:nil password:@"" toView:self];
}

-(BOOL)getInputValue{
    if(_image==nil && self.isRegister){
        [g_App showAlert:Localized(@"JX_SetHead")];
        return NO;
    }
    if([_name.text length]<=0){
        [g_App showAlert:Localized(@"JX_InputName")];
        return NO;
    }
    if(user.cityId<=0){
        [g_App showAlert:Localized(@"JX_Live")];
        return NO;
    }
    if (_birthday.text.length <= 0) {
        [g_App showAlert:Localized(@"JX_SelectDateOfBirth")];
        return NO;
    }

    if (![user.userNickname isEqualToString:_name.text] || [user.birthday timeIntervalSince1970] != [_date.date timeIntervalSince1970] || [user.sex integerValue] != _sex.selectedSegmentIndex) {
        self.isUpdate = YES;
    }

    user.userNickname = _name.text;
    user.birthday = _date.date;
    user.sex = [NSNumber numberWithBool:_sex.selectedSegmentIndex];
    
    return  YES;
}

-(BOOL)hideKeyboard{
    BOOL b = _name.editing || _pwd.editing || _repeat.editing || _birthday.editing;
    _date.hidden = YES;
    [self.view endEditing:YES];
//    [self.view setFrame:self.view.bounds];
    return b;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

-(void)changeKeyBoard:(NSNotification *)aNotifacation
{
    //    return;
    //获取到键盘frame 变化之前的frame
    NSValue *keyboardBeginBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect=[keyboardBeginBounds CGRectValue];
    
    //获取到键盘frame变化之后的frame
    NSValue *keyboardEndBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect endRect=[keyboardEndBounds CGRectValue];
    
    CGFloat deltaY=endRect.origin.y-beginRect.origin.y;
    //拿frame变化之后的origin.y-变化之前的origin.y，其差值(带正负号)就是我们self.view的y方向上的增量
    deltaY=-endRect.size.height;
    
//    NSLog(@"deltaY:%f",deltaY);
    //取消界面上移
//    [self.view setFrame:CGRectMake(0, JX_SCREEN_HEIGHT+deltaY-self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
}


-(void)showUserQRCode{
    JXQRCodeViewController * qrVC = [[JXQRCodeViewController alloc] init];
    qrVC.type = QRUserType;
    qrVC.userId = g_server.myself.userId;
    qrVC.account = g_server.myself.account;
    qrVC.nickName = g_server.myself.userNickname;
    qrVC.sex = g_server.myself.sex;
//    [g_window addSubview:qrVC.view];
    [g_navigation pushViewController:qrVC animated:YES];
}

- (void)onShikuNum {
    
    JXSetShikuNumVC *vc = [[JXSetShikuNumVC alloc] init];
    vc.delegate = self;
    vc.user = user;
    [g_navigation pushViewController:vc animated:YES];
}

- (void)setShikuNum:(JXSetShikuNumVC *)setShikuNumVC updateSuccessWithAccount:(NSString *)account {
    
    [self.tableBody.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self createCustomView];
}

@end
