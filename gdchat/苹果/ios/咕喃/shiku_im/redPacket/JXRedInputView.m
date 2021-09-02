 //
//  JXRedInputView.m
//  lveliao_IM
//
//  Created by 1 on 17/8/15.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXRedInputView.h"

#define RowHeight 56
#define RowMaxHeight 60

#define RowMargin 20
#define RowMaxMargin 20

@interface JXRedInputView () <UITextFieldDelegate> {
    CGFloat _greetY;
    CGFloat _countY;
    CGFloat _moneyY;
    CGFloat _sendY;
}

@end


@implementation JXRedInputView

-(instancetype)initWithFrame:(CGRect)frame type:(NSUInteger)type isRoom:(BOOL)isRoom delegate:(id)delegate{
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        self.type = type;
        self.delegate = delegate;
        self.isRoom = isRoom;
        
        [self customSubViews];
    }
    return self;
}

-(instancetype)init{
    if (self = [super init]) {
        [self customSubViews];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self customSubViews];
    }
    return self;
}

-(void)layoutSubviews{
    if (_type == 3) {
        _greetY = RowMargin;
        if(_isRoom){
            _countY = RowMargin + RowHeight+ 43;
            _moneyY = _countY + RowHeight+RowMargin;
            _sendY = RowHeight*3+RowMaxHeight+RowMargin+80;
        }else{
            _moneyY = RowMargin + RowHeight+43;
            _sendY = RowHeight+RowMaxHeight+RowMargin+RowMaxHeight+60;
        }
    }else{
        if(_isRoom){
            _countY = RowMargin;
            _moneyY = _countY + RowHeight+RowMargin;
            _greetY = _moneyY + RowHeight + 43;
            _sendY = RowHeight*2+RowMaxHeight+RowMargin+RowMaxHeight+80;
        }else{
            _moneyY = RowMargin;
            _greetY = _moneyY +RowMargin*2 + RowHeight;
            _sendY = RowHeight+RowMaxHeight+RowMargin+RowMaxHeight+60;
            if (_type == 1) {
                _greetY = _moneyY + RowHeight + RowMaxMargin;
                _sendY = RowHeight+RowMaxHeight+RowMargin+RowMaxHeight+50;
            }
        }
    }
    
    if(_isRoom){
        _countView.frame = CGRectMake(24, _countY, self.frame.size.width-48, RowHeight);
        _countView.layer.cornerRadius = 10;
        _countView.layer.masksToBounds = YES;
        _countUnit.frame = CGRectMake(CGRectGetWidth(_countView.frame)-40, 0, 40, RowHeight);
        _countTextField.frame = CGRectMake(CGRectGetMaxX(_countTitle.frame), 0, CGRectGetMinX(_countUnit.frame)-CGRectGetMaxX(_countTitle.frame), RowHeight);
        
        _line.frame = CGRectMake(15, RowHeight-LINE_WH, JX_SCREEN_WIDTH-15, LINE_WH);
    }
    _moneyView.frame = CGRectMake(24, _moneyY, self.frame.size.width-48, RowHeight);
    _moneyView.layer.cornerRadius = 10;
    _moneyView.layer.masksToBounds = YES;
    _moneyUnit.frame = CGRectMake(CGRectGetWidth(_moneyView.frame)-40, 0, 40, RowHeight);
    _moneyTextField.frame = CGRectMake(CGRectGetMaxX(_moneyTitle.frame), 0, CGRectGetMinX(_moneyUnit.frame)-CGRectGetMaxX(_moneyTitle.frame), RowHeight);

    _greetView.frame = CGRectMake(24, _greetY, self.frame.size.width-48, _type == 1 || (_type == 2 && _isRoom) ? RowMaxHeight : RowHeight);
    _greetView.layer.cornerRadius = 10;
    _greetView.layer.masksToBounds = YES;
    _sendButton.frame = CGRectMake(24, _sendY+23, self.frame.size.width-24*2, 43);
    _sendButton.tag = _type;
    
    _allMoneyLab.frame = CGRectMake(0, CGRectGetMinY(_sendButton.frame)-22 - 26-23, JX_SCREEN_WIDTH, 40);

    
    if (_type == 3) {
        _greetTitle.hidden = NO;
        _greetTextField.frame = CGRectMake(CGRectGetMaxX(_greetTitle.frame), 0, CGRectGetWidth(_greetView.frame)-CGRectGetWidth(_greetTitle.frame)-15, RowHeight);
        _noticeTitle.frame = CGRectMake(24, CGRectGetMaxY(_greetView.frame)+14, JX_SCREEN_WIDTH-24, 13);
    }else{
        _greetTitle.hidden = YES;
        _noticeTitle.frame = CGRectMake(24, CGRectGetMaxY(_moneyView.frame)+14, JX_SCREEN_WIDTH-24, 13);
        _greetTextField.frame = CGRectMake(0, 0, CGRectGetWidth(_greetView.frame), _type == 1 || (_type == 2 && _isRoom)  ? RowMaxHeight : RowHeight);
    }
    
    
    
    [self viewLocalized];
}

-(void)viewLocalized{
    _countTitle.text = Localized(@"JXRed_numberPackets");// @"红包个数";//
    _moneyTitle.text = Localized(@"JXRed_totalAmount");//@"总金额";//
    _countUnit.text = Localized(@"JXRed_A");//@"个";//
    _moneyUnit.text = Localized(@"JX_ChinaMoney");//@"元";//
    [_sendButton setTitle:Localized(@"JXRed_send") forState:UIControlStateNormal];//@"塞钱进红包"
    [_sendButton setTitle:Localized(@"JXRed_send") forState:UIControlStateHighlighted];
    
    _moneyTextField.placeholder = Localized(@"JXRed_inputAmount");//@"输入金额";//
    _countTextField.placeholder = Localized(@"JXRed_inputNumPackets");//@"请输入红包个数";//
    
    switch (_type) {
        case 1:{
            if (_isRoom) {
                _noticeTitle.text = Localized(@"JXRed_sameAmount");//@"小伙伴领取的金额相同";//
            }
            _greetTextField.placeholder = Localized(@"JXRed_greetOlace");//@"恭喜发财，万事如意";// Congratulation, everything goes well
            
            
            break;
        }
        case 2:{
            _noticeTitle.text = Localized(@"JXRed_ARandomAmount");//@"小伙伴领取的金额随机";//
            _greetTextField.placeholder = Localized(@"JXRed_greetOlace");//@"恭喜发财，万事如意";
            
            break;
        }
        case 3:{
            _noticeTitle.text = Localized(@"JXRed_NoticeOrder");//@"小伙伴需回复口令抢红包";//
            _greetTextField.placeholder = Localized(@"JXRed_orderPlace");//@"如“我真帅”";// eg."I'm so handsome";
            _greetTitle.text = Localized(@"JXRed_setOrder");//@"设置口令";//
            break;
        }
        default:
            break;
    }
}

-(void)customSubViews{
    if(_isRoom)
        [self addSubview:self.countView];
    [self addSubview:self.moneyView];
    [self addSubview:self.greetView];
    
    [self addSubview:self.sendButton];
    [self addSubview:self.noticeTitle];
    [self addSubview:self.allMoneyLab];
}


- (void)textFieldDidChange:(UITextField *)textField {
    _allMoneyLab.text = [NSString stringWithFormat:@"¥%.2f",[textField.text doubleValue]];
    _sendButton.enabled =  [_moneyTextField.text doubleValue] > 0;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == _countTextField) {
        if ([textField.text rangeOfString:@"."].location != NSNotFound) {
            return NO;
        }
    }
    if (textField == _moneyTextField) {
//        if ([toBeString doubleValue] > 500) {
//            return NO;
//        }
        // 首位不能输入 .
        if (IsStringNull(textField.text) && [string isEqualToString:@"."]) {
            return NO;
        }
        //限制.后面最多有两位，且不能再输入.
        if ([textField.text rangeOfString:@"."].location != NSNotFound) {
            //有.了 且.后面输入了两位  停止输入
            if (toBeString.length > [toBeString rangeOfString:@"."].location+3) {
                return NO;
            }
            //有.了，不允许再输入.
            if ([string isEqualToString:@"."]) {
                return NO;
            }
        }
        //限制首位0，后面只能输入. 和 删除
        if ([textField.text isEqualToString:@"0"]) {
            if (![string isEqualToString:@"."] && ![string isEqualToString:@""]) {
                return NO;
            }
        }
        //限制只能输入：1234567890.
        NSCharacterSet * characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890."] invertedSet];
        NSString * filtered = [[string componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
    
    return YES;
}



- (UILabel *)allMoneyLab {
    if (!_allMoneyLab) {
        _allMoneyLab = [[UILabel alloc] init];
        _allMoneyLab.font = SYSFONT(40);
        _allMoneyLab.text = @"¥0.00";
        _allMoneyLab.textAlignment = NSTextAlignmentCenter;
    }
    return _allMoneyLab;
}


-(UIView *)countView{
    if (!_countView) {
        _countView = [[UIView alloc] init];
            _countView.backgroundColor = [UIColor whiteColor];
        [_countView addSubview:self.countTitle];
        [_countView addSubview:self.countTextField];
        [_countView addSubview:self.countUnit];
//        [_countView addSubview:self.line];
    }
    return _countView;
}

-(UIView *)moneyView{
    if (!_moneyView) {
        _moneyView = [[UIView alloc] init];
        _moneyView.backgroundColor = [UIColor whiteColor];
        [_moneyView addSubview:self.moneyTitle];
        [_moneyView addSubview:self.moneyTextField];
        [_moneyView addSubview:self.moneyUnit];
    }
    return _moneyView;
}

-(UIView *)greetView{
    if (!_greetView) {
        _greetView = [[UIView alloc] init];
        _greetView.backgroundColor = [UIColor whiteColor];
        [_greetView addSubview:self.greetTitle];
        [_greetView addSubview:self.greetTextField];
    }
    return _greetView;
}

-(UIButton *)sendButton{
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendButton setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xFA585E)] forState:UIControlStateNormal];
        [_sendButton setBackgroundImage:[UIImage createImageWithColor:[HEXCOLOR(0xFA585E) colorWithAlphaComponent:0.5]] forState:UIControlStateDisabled];
        [_sendButton.titleLabel setFont:g_factory.font16];
        _sendButton.enabled = NO;
        _sendButton.layer.masksToBounds = YES;
        _sendButton.layer.cornerRadius = 7.f;
        
    }
    return _sendButton;
}

-(UILabel *)noticeTitle{
    if (!_noticeTitle) {
        _noticeTitle = [[UILabel alloc] initWithFrame:CGRectMake(14, -20, 200, 20)];
        _noticeTitle.font = g_factory.font13;
        _noticeTitle.textColor = [UIColor lightGrayColor];
    }
    return _noticeTitle;
}

-(UILabel *)countTitle{
    if (!_countTitle) {
        _countTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 80, RowHeight)];
        _countTitle.font = g_factory.font15;
        _countTitle.textColor = [UIColor blackColor];
//        _countTitle.text = @"红包个数";
    }
    return _countTitle;
}
-(UILabel *)moneyTitle{
    if (!_moneyTitle) {
        _moneyTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 80, RowHeight)];
        _moneyTitle.font = g_factory.font15;
        _moneyTitle.textColor = [UIColor blackColor];
//        _moneyTitle.text = @"总金额";
    }
    return _moneyTitle;
}
-(UILabel *)greetTitle{
    if (!_greetTitle) {
        _greetTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 80, RowHeight)];
        _greetTitle.font = g_factory.font15;
        _greetTitle.textColor = [UIColor blackColor];
    }
    return _greetTitle;
}


-(UITextField *)countTextField{
    if (!_countTextField) {
        _countTextField = [UIFactory createTextFieldWith:CGRectZero delegate:_delegate returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:nil font:g_factory.font15];
        _countTextField.text = @"";    // 红包默认最少为1个
        _countTextField.clearButtonMode = UITextFieldViewModeNever;
        _countTextField.textAlignment = NSTextAlignmentRight;
        _countTextField.borderStyle = UITextBorderStyleNone;
        _countTextField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _countTextField;
}
-(UITextField *)moneyTextField{
    if (!_moneyTextField) {
        _moneyTextField = [UIFactory createTextFieldWith:CGRectZero delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:nil font:g_factory.font15];
        _moneyTextField.clearButtonMode = UITextFieldViewModeNever;
        _moneyTextField.textAlignment = NSTextAlignmentRight;
        _moneyTextField.borderStyle = UITextBorderStyleNone;
        _moneyTextField.keyboardType = UIKeyboardTypeDecimalPad;
        [_moneyTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _moneyTextField;
}
-(UITextField *)greetTextField{
    if (!_greetTextField) {
        _greetTextField = [UIFactory createTextFieldWith:CGRectZero delegate:_delegate returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:nil font:g_factory.font15];
        _greetTextField.textAlignment = NSTextAlignmentLeft;
        _greetTextField.borderStyle = UITextBorderStyleNone;
        _greetTextField.keyboardType = UIKeyboardTypeDefault;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        _greetTextField.leftView = view;
        _greetTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _greetTextField;
}


-(UILabel *)countUnit{
    if (!_countUnit) {
        _countUnit = [[UILabel alloc] initWithFrame:CGRectZero];
        _countUnit.font = g_factory.font15;
        _countUnit.textColor = [UIColor blackColor];
        _countUnit.textAlignment = NSTextAlignmentCenter;
//        _countUnit.text = @"个";
    }
    return _countUnit;
}
-(UILabel *)moneyUnit{
    if (!_moneyUnit) {
        _moneyUnit = [[UILabel alloc] initWithFrame:CGRectZero];
        _moneyUnit.font = g_factory.font15;
        _moneyUnit.textColor = [UIColor blackColor];
        _moneyUnit.textAlignment = NSTextAlignmentCenter;
//        _moneyUnit.text = @"元";
    }
    return _moneyUnit;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = THE_LINE_COLOR;
    }
    return _line;
}

-(void)stopEdit{
    [_countTextField resignFirstResponder];
    [_moneyTextField resignFirstResponder];
    [_greetTextField resignFirstResponder];
}

@end
