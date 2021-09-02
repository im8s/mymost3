//
//  JXInputVC.m
//  shiku_im
//
//  Created by flyeagleTang on 15-2-4.
//  Copyright (c) 2015年 Reese. All rights reserved.
//

#import "JXInputVC.h"

#define INPUT_WIDTH 220

@implementation JXInputVC
@synthesize inputBtn,inputHint,inputTitle,inputText;

- (id)init
{
    self = [super init];
    if (self) {
        _pSelf = self;
//        self.parent.alpha = 0.5;
        if(!inputTitle)
            self.inputTitle = Localized(@"JX_Reply");
        if(!inputHint)
            self.inputHint = Localized(@"JXInputVC_InputReply");
        if(!inputBtn)
            self.inputBtn = Localized(@"JX_Send");
        if (!_titleFont) {
            self.titleFont = g_factory.font15b;
        }
        if (!_titleColor) {
            self.titleColor = [UIColor blackColor];
        }

        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        UIView* iv = [[UIView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH-INPUT_WIDTH)/2, self.view.center.y - 80, INPUT_WIDTH, 110)];
        iv.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
        iv.layer.cornerRadius = 3;
        iv.layer.masksToBounds = YES;
        [self.view addSubview:iv];
//        [iv release];
        
        JXLabel* p;
        p = [self createLabel:iv default:inputTitle];
        p.font = self.titleFont;
        p.textColor = self.titleColor;
        p.numberOfLines = 0;
        CGSize size = [inputTitle boundingRectWithSize:CGSizeMake(INPUT_WIDTH - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : p.font} context:nil].size;
        
        if (size.height < 25) {
            p.textAlignment = NSTextAlignmentCenter;
        }else {
            p.textAlignment = NSTextAlignmentLeft;
        }
        
//        if (size.height < 50) {
//            size.height = 50;
//        }
        p.frame = CGRectMake(10, 10, INPUT_WIDTH - 20, size.height);
        
        _value = [self createTextField:iv default:inputText hint:inputHint];
        _value.frame = CGRectMake(10, CGRectGetMaxY(p.frame) + 10, INPUT_WIDTH-20, 25);
        [_value becomeFirstResponder];
       
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(_value.frame) + 10,JX_SCREEN_WIDTH,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [iv addSubview:line];
//        [line release];
        
        line = [[UIView alloc]initWithFrame:CGRectMake(INPUT_WIDTH/2,CGRectGetMaxY(line.frame),LINE_WH,34)];
        line.backgroundColor = THE_LINE_COLOR;
        [iv addSubview:line];
        
        p = [self createLabel:iv default:Localized(@"JX_Cencal")];
        p.frame = CGRectMake(0, line.frame.origin.y, INPUT_WIDTH/2, 34);
        p.textColor = [UIColor blueColor];
        p.delegate = self;
        p.didTouch = @selector(onCancel);
        
        p = [self createLabel:iv default:inputBtn];
        p.frame = CGRectMake(INPUT_WIDTH/2, line.frame.origin.y, INPUT_WIDTH/2, 34);
        p.textColor = [UIColor blueColor];
        p.delegate = self;
        p.didTouch = @selector(onEnter);
        
        iv.frame = CGRectMake(iv.frame.origin.x, iv.frame.origin.y, iv.frame.size.width, CGRectGetMaxY(p.frame));
        
    }
    return self;
}

-(JXLabel*)createLabel:(UIView*)parent default:(NSString*)s{
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(0,0,INPUT_WIDTH,40)];
    p.userInteractionEnabled = NO;
    p.text = s;
    p.font = g_factory.font15;
    p.textAlignment = NSTextAlignmentCenter;
    [parent addSubview:p];
//    [p release];
    return p;
}

-(UITextField*)createTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint{
    UITextField* p = [[UITextField alloc] init];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.borderStyle = UITextBorderStyleRoundedRect;
    p.returnKeyType = UIReturnKeyDone;
//    p.clearButtonMode = UITextFieldViewModeAlways;
    p.textAlignment = NSTextAlignmentLeft;
    p.userInteractionEnabled = YES;
    p.text = s;
    p.placeholder = hint;
    p.font = g_factory.font14;
    p.layer.borderWidth = 0;
    p.layer.cornerRadius = 0;
    p.layer.masksToBounds = YES;
    [parent addSubview:p];
//    [p release];
    return p;
}

-(void)dealloc{
    NSLog(@"JXInputVC.dealloc");
//    [super dealloc];
}

-(void)onEnter{
    if([_value.text length]<=0){
        [g_App showAlert:Localized(@"JXAlert_InputSomething")];
        return;
    }
    self.inputText = _value.text;
	if(self.delegate != nil && [self.delegate respondsToSelector:self.didTouch])
		[self.delegate performSelectorOnMainThread:self.didTouch withObject:self waitUntilDone:NO];
    [self onCancel];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)onCancel{
    [self.view endEditing:YES];
    [self.view removeFromSuperview];
//    [self release];
    _pSelf = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self onEnter];
    return YES;
}

@end
