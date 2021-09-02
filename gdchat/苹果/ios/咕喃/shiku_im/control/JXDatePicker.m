//
//  JXDatePicker.m
//  shiku_im
//
//  Created by flyeagleTang on 15-1-7.
//  Copyright (c) 2015年 Reese. All rights reserved.
//

#import "JXDatePicker.h"

@implementation JXDatePicker
@synthesize delegate,didCancel,datePicker,didSelect,didChange;

- (id)initWithFrame:(CGRect)frame{
    int h = 26;
    
    self = [super initWithFrame:frame];
    if (self) {
        self.hint = Localized(@"JXDatePicker_Sel");
//        self.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        self.backgroundColor = [UIColor whiteColor];
        datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, h, frame.size.width, 200-h)];
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        datePicker.backgroundColor = [UIColor whiteColor];
        datePicker.date = [NSDate date];
        datePicker.maximumDate = [NSDate date];
        [datePicker addTarget:self action:@selector(onDate:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:datePicker];
//        [datePicker release];
        
        NSLocale *p = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        datePicker.locale = p;
//        [p release];
        
       _sel = [[JXLabel alloc] initWithFrame:CGRectMake(h, 0, frame.size.width-h*2, h)];
        _sel.font = g_factory.font16;
        _sel.textAlignment = NSTextAlignmentCenter;
        _sel.textColor = [UIColor grayColor];
        _sel.delegate = self;
        _sel.didTouch = @selector(onClose);
        [self addSubview:_sel];
//        [_sel release];
        
        JXImageView* iv = [[JXImageView alloc]initWithFrame:CGRectMake(0, 0, h, h)];
        iv.image = [UIImage imageNamed:@"title_back"];
        iv.delegate = self;
        iv.didTouch = @selector(onClose);
        [self addSubview:iv];
//        [iv release];
        
        iv = [[JXImageView alloc]initWithFrame:CGRectMake(frame.size.width-h, 0, h, h)];
        iv.image = [UIImage imageNamed:@"icon_selected"];
        iv.delegate = self;
        iv.didTouch = @selector(onSelect);
        [self addSubview:iv];
//        [iv release];
    }
    return self;
}

-(void)dealloc{
    self.hint = nil;
//    [super dealloc];
}

-(void)onClose{
    [self removeFromSuperview];
    if (delegate && [delegate respondsToSelector:didCancel])
//		[delegate performSelector:didCancel withObject:nil];
        [delegate performSelectorOnMainThread:didCancel withObject:nil waitUntilDone:NO];
}

-(void)onSelect{
    [self removeFromSuperview];
    if (delegate && [delegate respondsToSelector:didSelect])
//		[delegate performSelector:didSelect withObject:self];
        [delegate performSelectorOnMainThread:didSelect withObject:self waitUntilDone:NO];
}

- (void)onDate:(UIView*)sender{
    NSString* s = nil;
    if(datePicker.datePickerMode == UIDatePickerModeDateAndTime)
        s = @"yyyy-MM-dd HH:mm";
    if(datePicker.datePickerMode == UIDatePickerModeDate)
        s = @"yyyy-MM-dd";
    if(datePicker.datePickerMode == UIDatePickerModeTime)
        s = @"HH:mm:ss";
    
    _sel.text = [NSString stringWithFormat:@"%@:%@",self.hint,[TimeUtil formatDate:datePicker.date format:s]];
    if(sender)
        if (delegate && [delegate respondsToSelector:didChange])
//            [delegate performSelector:didChange withObject:self];
            [delegate performSelectorOnMainThread:didChange withObject:self waitUntilDone:NO];
}

-(NSDate*)date{
    return datePicker.date;
}

-(void)setDate:(NSDate *)p{
    datePicker.date = p;
    [self onDate:nil];
}

- (void)didMoveToSuperview{
    datePicker.tag = self.tag;
    [self onDate:nil];
    [super didMoveToSuperview];
}

@end
