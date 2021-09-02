//
//  JXSetNoteAndLabelVC.m
//  shiku_im
//
//  Created by 1 on 2019/5/7.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXSetNoteAndLabelVC.h"
#import "JXLabelObject.h"
#import "JXSetLabelVC.h"
#import "UIImage+Color.h"

#define HEIGHT 54

@interface JXSetNoteAndLabelVC () <UIScrollViewDelegate,UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UITextField *name; //备注
@property (nonatomic, strong) UITextField *textField; //标签
@property (nonatomic, strong) UITextView *detail; //描述

@property (nonatomic, strong) UILabel *labT;
@property (nonatomic, strong) UILabel *labContLab;
@property (nonatomic, strong) UIView *baseView;

@property (nonatomic, strong) UIColor *textVColor;

@property (nonatomic, strong) NSMutableArray *array;    // 已选择标签
@property (nonatomic, strong) NSMutableArray *allArray; // 所有标签

@property (nonatomic, strong) UILabel *watermarkLab;// 水印

@end

@implementation JXSetNoteAndLabelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack = YES;
    [self createHeadAndFoot];
    
    self.tableBody.delegate = self;
    
    self.textVColor = HEXCOLOR(0xC4C4CA);
//    self.tableBody.backgroundColor = HEXCOLOR(0xf0eff4);
    
    
//    _array = [NSMutableArray array];
//    _allArray = [NSMutableArray array];

    [self customView];

}

- (void)customView {
    JXLabel *p = [self createLabel:self.tableHeader default:Localized(@"JX_Confirm") selector:@selector(onSave)];
    p.textColor = [UIColor whiteColor];
    p.layer.masksToBounds = YES;
    p.layer.cornerRadius = 3.f;
    [p setBackgroundColor:THEMECOLOR];
    [p setFont:SYSFONT(15)];
    p.textAlignment = NSTextAlignmentCenter;
    p.frame = CGRectMake(JX_SCREEN_WIDTH - 51 - 15, JX_SCREEN_TOP - 8 - 29, 51, 29);

    // 备注
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(15, INSETS, 60, 18)];
    nameLab.text = Localized(@"JX_MemoName");
    nameLab.textColor = HEXCOLOR(0x333333);
    nameLab.font = SYSFONT(15);
    [self.tableBody addSubview:nameLab];

    _name = [[UITextField alloc] initWithFrame:CGRectMake(15,CGRectGetMaxY(nameLab.frame)+INSETS,JX_SCREEN_WIDTH-30,40)];
    _name.placeholder = Localized(@"JX_AddRemarkName");
    _name.font = [UIFont systemFontOfSize:15.0];
    _name.delegate = self;
    _name.returnKeyType = UIReturnKeyDone;
    _name.backgroundColor = HEXCOLOR(0xF5F5F5);
    _name.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 0)];
    _name.leftViewMode = UITextFieldViewModeAlways;
    _name.layer.masksToBounds = YES;
    _name.layer.cornerRadius = 7.f;
    _name.text = _user.remarkName;
    [self.tableBody addSubview:_name];
    [_name addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];

    // 标签
    _labT = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_name.frame)+20, 40, 18)];
    _labT.text = Localized(@"JX_Label");
    _labT.textColor = HEXCOLOR(0x333333);
    _labT.font = SYSFONT(15);
    [self.tableBody addSubview:_labT];

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_labT.frame)+INSETS, JX_SCREEN_WIDTH-30, 40)];
    btn.backgroundColor = THESIMPLESTYLE ? [UIColor blackColor] : [UIColor whiteColor];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 7.f;
    [btn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xF5F5F5)] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage createImageWithColor:self.textVColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(onLabel) forControlEvents:UIControlEventTouchUpInside];
    [self.tableBody addSubview:btn];
    
    
    _labContLab = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, JX_SCREEN_WIDTH-INSETS-41, 40)];
    _labContLab.backgroundColor = [UIColor clearColor];
    _labContLab.textColor = HEXCOLOR(0x333333);
    _labContLab.font = SYSFONT(15);
//    _labContLab.userInteractionEnabled = YES;
    [btn addSubview:_labContLab];
    [self getLab];

//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onLabel)];
//    [_labContLab addGestureRecognizer:tap];
    
    UIImageView *imgV =[[UIImageView alloc] initWithFrame:CGRectMake(btn.frame.size.width-15-7, 13.5, 7, 13)];
    imgV.image = [UIImage imageNamed:@"new_icon_>"];
    [btn addSubview:imgV];
    

    // 描述
    UILabel *deatilLab = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(btn.frame)+20, 40, 18)];
    deatilLab.text = Localized(@"JX_UserInfoDescribe");
    deatilLab.textColor = HEXCOLOR(0x333333);
    deatilLab.font = SYSFONT(15);
    [self.tableBody addSubview:deatilLab];
    
    _baseView = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(deatilLab.frame)+INSETS, JX_SCREEN_WIDTH-30, 40)];
    _baseView.backgroundColor = HEXCOLOR(0xF5F5F5);
    _baseView.layer.masksToBounds = YES;
    _baseView.layer.cornerRadius = 7.f;
    [self.tableBody addSubview:_baseView];

    _detail = [self createTextField:_baseView default:_user.remarkName];
    CGSize sizeD = [_detail sizeThatFits:CGSizeMake(_detail.frame.size.width, MAXFLOAT)];
    _detail.frame = CGRectMake(15,3,_baseView.frame.size.width-30,sizeD.height);
    _detail.text = _user.describe.length > 0 ? _user.describe : @"";
    _detail.returnKeyType = UIReturnKeyDefault;
    
    //水印
    _watermarkLab = [[UILabel alloc] initWithFrame:CGRectMake(5, (_detail.frame.size.height-20)/2, _detail.frame.size.width-10, 20)];
    _watermarkLab.text = Localized(@"JX_AddMoreComments");
    _watermarkLab.textColor = self.textVColor;
    _watermarkLab.font = SYSFONT(15);
    [_detail addSubview:_watermarkLab];
    
    if (_user.describe.length > 0) {
        [self textViewDidChange:_detail];
    }

    if ([self validateCellPhoneNumber:[self getNumber:_detail.text]]) {
        NSMutableAttributedString *atbs =[[NSMutableAttributedString alloc] initWithAttributedString: _detail.attributedText];
        NSRange range = [[atbs string] rangeOfString:[self getNumber:_detail.text]];
        [atbs addAttributes:@{NSLinkAttributeName:[self getNumber:_detail.text],NSForegroundColorAttributeName:[UIColor redColor]} range:range];
        _detail.attributedText= atbs;
        _detail.selectable=YES;
    }
}

- (void)getLab {
    _array = [[JXLabelObject sharedInstance] fetchLabelsWithUserId:self.user.userId];
    NSMutableString *labelsName = [NSMutableString string];
    for (NSInteger i = 0; i < _array.count; i ++) {
        JXLabelObject *labelObj = _array[i];
        if (i == 0) {
            [labelsName appendString:labelObj.groupName];
        }else {
            [labelsName appendFormat:@",%@",labelObj.groupName];
        }
    }
    if (labelsName.length > 0) {
        _labContLab.text = labelsName;
        _labContLab.textColor = HEXCOLOR(0x333333);
    }else {
        _labContLab.text = Localized(@"JX_ClassifyContactsByLabel");
        _labContLab.textColor = self.textVColor;
    }

}
- (void)onLabel {
    JXSetLabelVC *vc = [[JXSetLabelVC alloc] init];
    vc.title = Localized(@"JX_SettingLabel");
    vc.delegate = self;
    vc.didSelect = @selector(refreshLabel:);
    vc.array = _array;
    vc.allArray = _allArray;
    vc.user = self.user;
    [g_navigation pushViewController:vc animated:YES];
}

- (void)refreshLabel:(JXSetLabelVC *)vc {
    [self getLab];
    _array = [vc.array mutableCopy];
    _allArray = [vc.allArray mutableCopy];
    
    NSMutableString *labelsName = [NSMutableString string];
    for (NSInteger i = 0; i < _array.count; i ++) {
        JXLabelObject *labelObj = _array[i];
        if (i == 0) {
            [labelsName appendString:labelObj.groupName];
        }else {
            [labelsName appendFormat:@",%@",labelObj.groupName];
        }
    }
    if (labelsName.length > 0) {
        _labContLab.text = labelsName;
        _labContLab.textColor = HEXCOLOR(0x333333);
    }else {
        _labContLab.text = Localized(@"JX_ClassifyContactsByLabel");
        _labContLab.textColor = self.textVColor;
    }
    
}

// 确定按钮
- (void)onSave {
    
    BOOL flag = NO;
    for (NSInteger i = 0; i < _array.count; i ++) {
        JXLabelObject *labelObj = _array[i];
        
        // 添加输入框输入的新创建的标签
        if (!labelObj.groupId) {
            flag = YES;
            [g_server friendGroupAdd:labelObj.groupName toView:self];
        }
    }
    
    // 没有新创建的标签，直接更新已存在标签
    if (!flag) {
        NSMutableString *userIdListStr = [NSMutableString string];
        for (NSInteger i = 0; i < _array.count; i ++) {
            JXLabelObject *obj = _array[i];
            if (i == 0) {
                [userIdListStr appendFormat:@"%@", obj.groupId];
            }else {
                [userIdListStr appendFormat:@",%@", obj.groupId];
            }
        }
        
        [g_server friendGroupUpdateFriendToUserId:self.user.userId groupIdStr:userIdListStr toView:self];
    }
}


-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([self validateCellPhoneNumber:textView.text]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",textView.text]]];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    _watermarkLab.hidden = textView.text.length > 0;
    
    static CGFloat maxHeight = 70.0f;
    
    //防止输入时在中文后输入英文过长直接中文和英文换行
    
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(JX_SCREEN_WIDTH-14, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    
    if (size.height >= maxHeight)
    {
        size.height = maxHeight;
        textView.scrollEnabled = YES;   // 允许滚动
    }
    else
    {
        textView.scrollEnabled = NO;    // 不允许滚动
    }
    
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
    _baseView.frame = CGRectMake(_baseView.frame.origin.x, _baseView.frame.origin.y, _baseView.frame.size.width, size.height+6);
    
}



//服务器返回数据
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if ([aDownload.action isEqualToString:act_FriendGroupAdd]) {
        
        NSMutableString *userIdListStr = [NSMutableString stringWithFormat:@"%@", self.user.userId];
        
        // 添加新标签后更新标签的用户列表
        [g_server friendGroupUpdateGroupUserList:dict[@"groupId"] userIdListStr:userIdListStr toView:self];
        
        JXLabelObject *label = [[JXLabelObject alloc] init];
        if (dict) {
            label.userId = dict[@"userId"];
            label.groupId = dict[@"groupId"];
            label.groupName = dict[@"groupName"];
        }
        label.userIdList = userIdListStr;
        // 插入新创建的标签
        [label insert];
        
        JXLabelObject *lastObj;
        // 查找到新创建的标签的最后一个
        for (NSInteger i = _array.count - 1; i >= 0; i --) {
            JXLabelObject *obj = _array[i];
            if (!obj.groupId) {
                lastObj = obj;
                break;
            }
        }
        
        // 更新新创建的标签的其他字段
        for (JXLabelObject *labelObj in _array) {
            if ([label.groupName isEqualToString:labelObj.groupName]) {
                labelObj.groupId = label.groupId;
                labelObj.userId = label.userId;
                labelObj.userIdList = label.userIdList;
                break;
            }
        }
        
        // 如果接口已成功添加完最后一条标签后，再更新用户的标签列表
        if ([label.groupName isEqualToString:lastObj.groupName]) {
            
            NSMutableString *userIdListStr = [NSMutableString string];
            for (NSInteger i = 0; i < _array.count; i ++) {
                JXLabelObject *obj = _array[i];
                if (i == 0) {
                    [userIdListStr appendFormat:@"[%@", obj.groupId];
                }else if (i == self.array.count - 1) {
                    [userIdListStr appendFormat:@",%@]", obj.groupId];
                }else {
                    [userIdListStr appendFormat:@",%@", obj.groupId];
                }
            }
            
            [g_server friendGroupUpdateFriendToUserId:self.user.userId groupIdStr:userIdListStr toView:self];
            
        }
    }
    
    if ([aDownload.action isEqualToString:act_FriendGroupUpdateFriend]) {
        
        // 更新数据库
        for (JXLabelObject *labelObj in _allArray) {
            [labelObj update];
        }
        self.user.remarkName = _name.text;
        if (_detail.textColor != self.textVColor) {
            self.user.describe = _detail.text;
        }else {
            self.user.describe = nil;
        }
        if ([self.delegate respondsToSelector:self.didSelect]) {
            [self.delegate performSelectorOnMainThread:self.didSelect withObject:self.user waitUntilDone:NO];
        }

        [self actionQuit];
    }
}



-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
}


-(UITextView*)createTextField:(UIView*)parent default:(NSString*)s {
    UITextView* p = [[UITextView alloc] init];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.scrollEnabled = NO;
    p.returnKeyType = UIReturnKeyDone;
    p.showsVerticalScrollIndicator = NO;
    p.showsHorizontalScrollIndicator = NO;
    p.textAlignment = NSTextAlignmentLeft;
    p.userInteractionEnabled = YES;
    p.backgroundColor = HEXCOLOR(0xF5F5F5);
//    p.layer.masksToBounds = YES;
//    p.layer.cornerRadius = 3.f;
    p.text = s;
    p.font = g_factory.font15;
    [parent addSubview:p];
    return p;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableBody) {
        [self.view endEditing:YES];
    }
}


- (BOOL)validateCellPhoneNumber:(NSString *)cellNum{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,184,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[2478])\\d)\\d{7}$";
    
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,175,176,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|7[56]|8[56])\\d{8}$";
    
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,177,180,189
     22         */
    NSString * CT = @"^1((33|53|77|8[09])[0-9]|349)\\d{7}$";
    
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    // NSPredicate *regextestPHS = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    if(([regextestmobile evaluateWithObject:cellNum] == YES)
       || ([regextestcm evaluateWithObject:cellNum] == YES)
       || ([regextestct evaluateWithObject:cellNum] == YES)
       || ([regextestcu evaluateWithObject:cellNum] == YES)){
        return YES;
    }else{
        return NO;
    }
}

- (NSString *)getNumber:(NSString *)string {
    NSString *pattern = @"\\d*";
    
    NSError *error;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSLog(@"%@",error);
    __block NSString *number = [NSString string];
    [regex enumerateMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (NSMatchingReportProgress==flags) {
            
        }else{
            /**
             *  系统内置方法
             */
            if (NSTextCheckingTypePhoneNumber==result.resultType) {
                number = [string substringWithRange:result.range];
            }
            /**
             *  长度为11位的数字串
             */
            if (result.range.length==11) {
                number = [string substringWithRange:result.range];
            }
        }
    }];
    return number;
}

-(JXLabel*)createLabel:(UIView*)parent default:(NSString*)s selector:(SEL)selector{
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2,INSETS,JX_SCREEN_WIDTH/2 -20,44-INSETS*2)];
    p.userInteractionEnabled = NO;
    p.text = s;
    p.font = g_factory.font14;
    p.textAlignment = NSTextAlignmentLeft;
    p.didTouch = selector;
    p.delegate = self;
    [parent addSubview:p];
    return p;
}

- (void)textDidChange:(UITextField *)textField {
    if (textField == _name) {
        [self validationText:textField];
    }
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

@end
