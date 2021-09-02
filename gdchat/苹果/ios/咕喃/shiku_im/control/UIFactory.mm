//
//  UIFactory.m
//  SmartMeeting
//
//  Created by luddong on 12-3-30.
//  Copyright (c) 2012年 Twin-Fish. All rights reserved.
//

#import "AlertView.h"
#import "ConfirmView.h"
#import "UIFactory.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import <arpa/inet.h>

static UIFactory* factory;
NSString *kStyle2Dir;

#define kDefaultLanguage                @"kDefaultLanguage"
#define kDefaultIsFirstLaunch           @"kDefaultIsFirstLaunch"

/*
@implementation UIImage(ImageNamed)

+ (UIImage *)imageNamed:(NSString *)name {
    NSString *skin = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultSkin];
    NSString *image_file = nil;
    
    if (name == nil || [name length] == 0)
        return nil;
    
    if ([skin isEqualToString:SKIN_SECOND] == YES) {
        if ([[name pathExtension] isEqualToString:@""] == YES)  // Assumes test=>test.png
            image_file = [[NSBundle mainBundle] pathForResource:name ofType:@"png" inDirectory:kStyle2Dir];
        else
            image_file = [[NSBundle mainBundle] pathForResource:name  ofType:@"" inDirectory:kStyle2Dir];
    }
    if (image_file == nil) {
        if ([[name pathExtension] isEqualToString:@""] == YES)  //Assumes test=>test.png
            image_file = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
        else
            image_file = [[NSBundle mainBundle] pathForResource:name ofType:@""];
    }
    
    return [UIImage imageWithContentsOfFile:image_file];
}

@end*/


@implementation UIFactory
@synthesize font7,font8,font9,font10,font11,font12,font13,font14,font15,font16,font17,font18,font20,font24,font28;
@synthesize font7b,font8b,font9b,font10b,font11b,font12b,font13b,font14b,font15b,font16b,font17b,font18b,font20b,font24b,font28b;

+ (UIFactory*)sharedUIFactory{
 
    if(factory == nil)
        factory = [[UIFactory alloc]init];
    return factory;
}

-(id)init{
    self = [super init];
    self.font7 = [UIFont systemFontOfSize:7];
    self.font8 = [UIFont systemFontOfSize:8];
    self.font9 = [UIFont systemFontOfSize:9];
    self.font10= [UIFont systemFontOfSize:10];
    self.font11= [UIFont systemFontOfSize:11];
    self.font12= [UIFont systemFontOfSize:12];
    self.font13= [UIFont systemFontOfSize:13];
    self.font14= [UIFont systemFontOfSize:14];
    self.font15= [UIFont systemFontOfSize:15];
    self.font16= [UIFont systemFontOfSize:16];
    self.font17= [UIFont systemFontOfSize:17];
    self.font18= [UIFont systemFontOfSize:18];
    self.font20= [UIFont systemFontOfSize:20];
    self.font24= [UIFont systemFontOfSize:24];
    self.font28= [UIFont systemFontOfSize:28];
    
    self.font7b = [UIFont boldSystemFontOfSize:7];
    self.font8b = [UIFont boldSystemFontOfSize:8];
    self.font9b = [UIFont boldSystemFontOfSize:9];
    self.font10b= [UIFont boldSystemFontOfSize:10];
    self.font11b= [UIFont boldSystemFontOfSize:11];
    self.font12b= [UIFont boldSystemFontOfSize:12];
    self.font13b= [UIFont boldSystemFontOfSize:13];
    self.font14b= [UIFont boldSystemFontOfSize:14];
    self.font15b= [UIFont boldSystemFontOfSize:15];
    self.font16b= [UIFont boldSystemFontOfSize:16];
    self.font17b= [UIFont boldSystemFontOfSize:17];
    self.font18b= [UIFont boldSystemFontOfSize:18];
    self.font20b= [UIFont boldSystemFontOfSize:20];
    self.font24b= [UIFont boldSystemFontOfSize:24];
    self.font28b= [UIFont boldSystemFontOfSize:28];
    return self;
}

+ (id)createTextFieldWith:(CGRect)frame 
                 delegate:(id<UITextFieldDelegate>)delegate
            returnKeyType:(UIReturnKeyType)returnKeyType
          secureTextEntry:(BOOL)secureTextEntry
              placeholder:(NSString *)placeholder 
                     font:(UIFont *)font {
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    if (delegate != nil) {
        textField.delegate = delegate;
        textField.returnKeyType = returnKeyType;
        textField.secureTextEntry = secureTextEntry;
        textField.placeholder = placeholder;
        textField.font = font;
        // Default property
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.enablesReturnKeyAutomatically = YES;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return textField;
}


+ (id)createLabelWith:(CGRect)frame text:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    return label;
}

+ (id)createLabelWith:(CGRect)frame 
                 text:(NSString *)text 
       backgroundColor:(UIColor *)backgroundColor {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.backgroundColor = backgroundColor;
    return label;
}

+ (id)createClearBackgroundLabelWith:(CGRect)frame 
                                text:(NSString *)text {
    return [UIFactory createLabelWith:frame 
                                 text:text 
                      backgroundColor:[UIColor clearColor]];
}

+ (id)createLabelWith:(CGRect)frame 
                text:(NSString *)text 
                 font:(UIFont *)font 
            textColor:(UIColor *)textColor 
      backgroundColor:(UIColor *)backgroundColor {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.font = font;
    label.textColor = textColor;
    if (backgroundColor != nil) {
      label.backgroundColor = backgroundColor;
    }
    return label ;
}

+ (UIImage*)resizableImageWithSize:(CGSize)size
                             image:(UIImage*)image {
    if (image == nil)
        return nil;
    
    if ([image respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        return [image resizableImageWithCapInsets:UIEdgeInsetsMake(size.height, size.width, size.height, size.width)];
    } else {
        return [image stretchableImageWithLeftCapWidth:size.width topCapHeight:size.height];
    }
}

+ (UIColor*)maskColor:(UIColor *)color withMask:(UIColor *)maskColor withAlpha:(CGFloat )alpha{
    CGFloat r;
    CGFloat g;
    CGFloat b;
    BOOL getColor = [color getRed:&r green:&g blue:&b alpha:nil];
    
    CGFloat maskR;
    CGFloat maskG;
    CGFloat maskB;
    BOOL getmaskColor = [maskColor getRed:&maskR green:&maskG blue:&maskB alpha:nil];
    
    if (getColor && getmaskColor) {
        CGFloat newR = [UIFactory singleColorBlend:r withMask:maskR withAlpha:alpha];
        CGFloat newG = [UIFactory singleColorBlend:g withMask:maskG withAlpha:alpha];
        CGFloat newB = [UIFactory singleColorBlend:b withMask:maskB withAlpha:alpha];
        return [UIColor colorWithRed:newR green:newG blue:newB alpha:1];
    }
    return nil;
    
}

+ (CGFloat )singleColorBlend:(CGFloat )color withMask:(CGFloat )maskColor withAlpha:(CGFloat )alpha{
    return (CGFloat ) (color * (1 - alpha) + maskColor * alpha);
}

+ (UIButton *)createCommonButton:(NSString *)title target:(id)target action:(SEL)selector{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (title != nil)
        [button setTitle:title forState:UIControlStateNormal];
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:g_factory.font15];
    
    UIImage* p = [UIFactory resizableImageWithSize:CGSizeMake(10, 10) image:[g_theme themeTintImage:@"navBarBackground"]];
    [button setBackgroundImage:p forState:UIControlStateNormal];
    
//    p = [UIFactory resizableImageWithSize:CGSizeMake(10, 10) image:[g_theme themeTintImage:@"navBarBackground"]];
    UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
    [button setBackgroundImage:img forState:UIControlStateHighlighted];
    p = nil;
    
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];

    return button;
}

+ (UIButton *)createButtonWithTitle:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                          highlight:(NSString *)clickIamge
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (title != nil)
        [button setTitle:title forState:UIControlStateNormal];
    
    if (titleColor != nil)
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    if (font != nil)
        [button.titleLabel setFont:font];
    
    if (normalImage != nil){
        UIImage* p = [UIFactory resizableImageWithSize:CGSizeMake(10, 10) image:[UIImage imageNamed:normalImage]];
        [button setBackgroundImage:p forState:UIControlStateNormal];
        p = nil;
    }
    
    if (clickIamge != nil){
        UIImage* p = [UIFactory resizableImageWithSize:CGSizeMake(10, 10) image:[UIImage imageNamed:clickIamge]];
        [button setBackgroundImage:p forState:UIControlStateHighlighted];
        p = nil;
    }
    
    return button;
}

+ (UIButton *)createButtonWithTitle:(NSString *)title
                          titleFont:(UIFont *)font
                         titleColor:(UIColor *)titleColor
                             normal:(NSString *)normalImage
                          highlight:(NSString *)clickIamge
                          selected:(NSString *)selectIamge
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (title != nil)
        [button setTitle:title forState:UIControlStateNormal];
    
    if (titleColor != nil)
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    if (font != nil)
        [button.titleLabel setFont:font];
    
    if (normalImage != nil){
        UIImage* p = [UIFactory resizableImageWithSize:CGSizeMake(10, 10) image:[UIImage imageNamed:normalImage]];
        [button setBackgroundImage:p forState:UIControlStateNormal];
        p = nil;
    }
    
    if (clickIamge != nil){
        UIImage* p = [UIFactory resizableImageWithSize:CGSizeMake(10, 10) image:[UIImage imageNamed:clickIamge]];
        [button setBackgroundImage:p forState:UIControlStateHighlighted];
        p = nil;
    }
    
    if (clickIamge != nil){
        UIImage* p = [UIFactory resizableImageWithSize:CGSizeMake(10, 10) image:[UIImage imageNamed:selectIamge]];
        [button setBackgroundImage:p forState:UIControlStateSelected];
        p = nil;
    }
    
    return button;
}

+ (UIButton *)createButtonWithImage:(NSString *)normalImage
                          highlight:(NSString *)clickIamge
                            target:(id)target
                        selector:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    
    button.custom_acceptEventInterval = 0.5f;
    if (normalImage != nil)
        [button setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    
    if (clickIamge != nil)
        [button setImage:[UIImage imageNamed:clickIamge] forState:UIControlStateHighlighted];
    
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}


+ (UIButton *)createButtonWithImage:(NSString *)normalImage
                          selected:(NSString *)clickIamge
                             target:(id)target
                           selector:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    if (normalImage != nil)
        [button setBackgroundImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    
    if (clickIamge != nil)
        [button setBackgroundImage:[UIImage imageNamed:clickIamge] forState:UIControlStateSelected];
    
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}



+ (UIButton *)createButtonWithRect:(CGRect)frame 
                             title:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                          selected:(NSString *)clickIamge
                          selector:(SEL)selector
                            target:(id)target;
{    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = frame;
    if (title != nil)
        [button setTitle:title forState:UIControlStateNormal];
    
    if (titleColor != nil)
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    if (font != nil)
        [button.titleLabel setFont:font];
    
    if (normalImage != nil)
        [button setBackgroundImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    
    if (clickIamge != nil)
        [button setBackgroundImage:[UIImage imageNamed:clickIamge] forState:UIControlStateSelected];
    
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+ (UIButton *)createButtonWithRect:(CGRect)frame 
                             title:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                         highlight:(NSString *)clickIamge
                          selector:(SEL)selector
                            target:(id)target;
{    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = frame;
    if (title != nil)
        [button setTitle:title forState:UIControlStateNormal];
    
    if (titleColor != nil)
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    if (font != nil)
        [button.titleLabel setFont:font];
    
    if (normalImage != nil)
        [button setBackgroundImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    
    if (clickIamge != nil)
        [button setBackgroundImage:[UIImage imageNamed:clickIamge] forState:UIControlStateHighlighted];
    
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+ (UIButton *)createButtonWithRect:(CGRect)frame 
                             title:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                         highlight:(NSString *)clickIamge
                             fixed:(CGSize)fixedSize
                          selector:(SEL)selector
                            target:(id)target
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = frame;
    
    if (title != nil)
        [button setTitle:title forState:UIControlStateNormal];
    
    if (titleColor != nil)
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    if (font != nil)
        [button.titleLabel setFont:font];
    
    if (normalImage != nil) {
        [button setBackgroundImage:[UIFactory resizableImageWithSize:fixedSize image:[UIImage imageNamed:normalImage]]
                          forState:UIControlStateNormal];
    }
    
    if (clickIamge != nil) {
        [button setBackgroundImage:[UIFactory resizableImageWithSize:fixedSize image:[UIImage imageNamed:clickIamge]]
                          forState:UIControlStateHighlighted];
    }
    
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+ (UIButton *)createButtonWithRect:(CGRect)frame 
                             title:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                         highlight:(NSString *)clickIamge
                          selected:(NSString *)selectedImage
                          selector:(SEL)selector
                            target:(id)target
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.backgroundColor = [UIColor clearColor];

    if (title != nil)
        [button setTitle:title forState:UIControlStateNormal];
    
    if (titleColor != nil)
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    if (font != nil)
        [button.titleLabel setFont:font];
    
    if (normalImage != nil)
        [button setBackgroundImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    
    if (clickIamge != nil)
        [button setBackgroundImage:[UIImage imageNamed:clickIamge] forState:UIControlStateHighlighted];
    
    if (selectedImage != nil)
        [button setBackgroundImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
    
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchDown];
    
    return button;
    
}

+ (UITextField *)createTextFieldWithRect:(CGRect)frame
                            keyboardType:(UIKeyboardType)keyboardType
                                  secure:(BOOL)secure
                             placeholder:(NSString *)placeholder
                                    font:(UIFont *)font
                                   color:(UIColor *)color
                                delegate:(id)delegate;
{
    UITextField *textField = [UIFactory createTextFieldWith:frame 
                                                   delegate:delegate 
                                              returnKeyType:UIReturnKeyNext 
                                            secureTextEntry:secure 
                                                placeholder:placeholder
                                                       font:font];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.keyboardType = keyboardType;
    if (color != nil)
        [textField setTextColor:color];
    
    return textField;
}

+(UIButton*)createCheckButtonWithRect:(CGRect)frame
                             selector:(SEL)selector
                               target:(id)target
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setBackgroundImage:[UIImage imageNamed:@"com_checkbox1_normal"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"com_checkbox1_select"] forState:UIControlStateSelected];
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+(UIButton*)createCheckButtonWithRect1:(CGRect)frame
                             selector:(SEL)selector
                               target:(id)target
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setBackgroundImage:[UIImage imageNamed:@"select_none"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"select_default"] forState:UIControlStateSelected];
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIButton *)createRadioButtonWithRect:(CGRect)frame
                            normalImage:(NSString *)normalImage
                          selectedImage:(NSString *)selectedImage
                              labelText:(NSString *)labelText
                              textColor:(UIColor*)textColor
                               selector:(SEL)selector
                                 target:(id)target
                               thisView:(UIView*)thisView
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGRect frame1;
    frame1 = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), 25,25);
    button.frame = frame1;
    [button setBackgroundImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [thisView addSubview:button];

    frame1 = CGRectMake(CGRectGetMinX(frame)+30, CGRectGetMinY(frame), CGRectGetWidth(frame)-30,CGRectGetHeight(frame));
    JXLabel* label = [[JXLabel alloc]initWithFrame:frame1];
    label.backgroundColor = [UIColor clearColor];
    label.text = labelText;
    label.userInteractionEnabled = YES;
    label.textColor = textColor;
    label.font = [UIFactory sharedUIFactory].font16;
    label.didTouch = selector;
    label.delegate = target;
    [thisView addSubview:label];
    
    return button;
}

+ (UIButton *)createRadioButtonWithRect:(CGRect)frame
                              labelText:(NSString *)labelText
                              textColor:(UIColor*)textColor
                               selector:(SEL)selector
                                 target:(id)target
                               thisView:(UIView*)thisView
{
    UIButton* button = [self createRadioButtonWithRect:frame 
                                           normalImage:@"com_radiobox_normal" 
                                         selectedImage:@"com_radiobox_select" 
                                             labelText:labelText 
                                             textColor:textColor
                                              selector:selector 
                                                target:target 
                                              thisView:thisView];
    return button;
}

+(UIButton*)createTopButton:(NSString*)s action:(SEL)action target:(id)target{
    UIButton* btn = [UIFactory createButtonWithRect:CGRectMake(5, 5, 70, 30)
                              title:s
                          titleFont:[UIFactory sharedUIFactory].font13
                         titleColor:nil
                             normal:@"enter"
                          highlight:nil
                           selector:action
                             target:target
     ];
//    btn.showsTouchWhenHighlighted = YES;
    return btn;
}

+ (UINavigationBar *)createNavigationBarWithBackgroundImage:(UIImage *)backgroundImage title:(NSString *)title {
    UINavigationBar *customNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 44)];
    UIImageView *navigationBarBackgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    [customNavigationBar addSubview:navigationBarBackgroundImageView];
//    [navigationBarBackgroundImageView release];
    UINavigationItem *navigationTitle = [[UINavigationItem alloc] initWithTitle:title];
    [customNavigationBar pushNavigationItem:navigationTitle animated:NO];
//    [navigationTitle release];
    return customNavigationBar;
}

+ (void)showAlert:(NSString *)message
{
    AlertView *view = [[AlertView alloc] initWithTitle:@""
                                               message:message
                                              delegate:nil
                                     cancelButtonTitle:[UIFactory localized:@"Ok"]
                                     otherButtonTitles:nil, nil];
    [view show];
}

+ (void)showAlert:(NSString *)message tag:(NSUInteger)tag delegate:(id)delegate
{
    AlertView *view = [[AlertView alloc] initWithTitle:@""
                                                message:message
                                               delegate:delegate
                                      cancelButtonTitle:[UIFactory localized:@"Ok"]
                                      otherButtonTitles:nil, nil];
    view.tag = tag;
    [view show];
}

+ (void)showConfirm:(NSString *)message tag:(NSUInteger)tag delegate:(id)delegate
{
    ConfirmView *view = [[ConfirmView alloc] initWithTitle:@""
                                               message:message
                                              delegate:delegate
                                     cancelButtonTitle:[UIFactory localized:@"Cancel"]
                                     otherButtonTitles:[UIFactory localized:@"Ok"], nil];
    view.tag = tag;
    [view show];
}

+ (NSString *)localized:(NSString *)key
{
    NSString *langCode = @"";
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:kDefaultIsFirstLaunch] == nil) {
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        NSArray *languages = [defs objectForKey:@"AppleLanguages"];
        langCode = [languages objectAtIndex:0];
        if ([langCode isEqualToString:@"zh-Hans"] == NO)
            langCode = @"en";
    } else {
        NSString *appLanguage = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultLanguage];
        if ([appLanguage isEqualToString:@"English"] == YES) {
            langCode = @"en";
        } else {
            langCode = @"zh-Hans";
        }
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:langCode ofType:@"lproj"];
    NSBundle *languageBundle = [NSBundle bundleWithPath:path];
    return [languageBundle localizedStringForKey:key value:@"" table:nil];
}

+ (BOOL)isValidIPAddress:(NSString *)address
{
    if ([address length] < 1)
        return NO;
    
    struct in_addr addr;
    return (inet_aton([address UTF8String], &addr) == 1);
}

+ (BOOL)isValidPortAddress:(NSString *)address
{
    return [UIFactory checkIntValueRange:address min:1 max:65535];
}

+ (BOOL)checkIntValueRange:(NSString *)value min:(int)min max:(int)max
{
    if ([value length] < 1)
        return NO;
    
    NSScanner * scanner = [NSScanner scannerWithString:value];
    if ([scanner scanInt:nil] && [scanner isAtEnd]) {
//        NSLog(@"min = %u, max = %u, value = %u %@", min, max, [value integerValue], value);
        return (min <= [value integerValue]) && ([value integerValue] <= max);
    }
    
    return NO;
}

+ (NSString *)checkValidName:(NSString *)value
{
    if ([value length] == 0) {
        [self showAlert:[self localized:@"ContactInputNamePrompt"]];
        return nil;
    }
        
    NSString *newString = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([newString length] > 0) {
        NSString *str = [newString stringByTrimmingCharactersInSet:[NSCharacterSet alphanumericCharacterSet]];
        if ([str length] == 0)
            return newString;
    }
    [self showAlert:[self localized:@"ContactInputValidNamePrompt"]];
    
    return nil;
}

+ (NSString *)checkValidPhoneNumber:(NSString *)value
{
    if ([value length] == 0) {
        [self showAlert:[self localized:@"ContactInputPhonePrompt"]];
        return nil;
    }
    
    NSString *newString = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([newString length] > 0) {
        NSString *str = [newString stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
        if ([str length] == 0)
            return newString;
    }
    [self showAlert:[self localized:@"ContactInputValidPhonePrompt"]];

    return nil;
}

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)formatStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:formatStr];

    NSLocale *timeLocale;
    NSString *appLanguage = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultLanguage];
    if ([appLanguage isEqualToString:@"English"] == YES) {
        timeLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
    } else {
        timeLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh"];
    }
    [formatter setLocale:timeLocale];
    
    NSString *str = [formatter stringFromDate:date];

//    [timeLocale release];
//    [formatter release];

    return str;
}

+ (NSDate *)dateFromString:(NSString *)str format:(NSString *)formatStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:formatStr];
    
    NSLocale *timeLocale;
    NSString *appLanguage = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultLanguage];
    if ([appLanguage isEqualToString:@"English"] == YES) {
        timeLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
    } else {
        timeLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh"];
    }
    [formatter setLocale:timeLocale];
    
    NSDate *date = [formatter dateFromString:str];
    
//    [timeLocale release];
//    [formatter release];

    return date;
}


+(void)freeTable:(NSMutableArray*)pool{
    if(pool==nil)
        return;
//    NSLog(@"App.freeTable.count=%d",[pool count]);
    for(NSInteger i=[pool count]-1;i>=0;i--){
        id p = [pool objectAtIndex:i];
		if([p isKindOfClass:[UIView class]]){
            for(NSInteger i=[[p subviews] count]-1;i>=0;i--)
                [[[p subviews] objectAtIndex:i] removeFromSuperview];
            [p removeFromSuperview];
        }        
		if([p isKindOfClass:[NSMutableArray class]]){
//            NSLog(@"array.count=%d",[p retainCount]);
            //[p removeAllObjects];
        }
		if([p isKindOfClass:[NSMutableDictionary class]]){
//            NSLog(@"dict.count=%d",[p retainCount]);
            //[p removeAllObjects];
        }
        [pool removeObjectAtIndex:i];
//        [p release];
    }
}

+(void)addToPool:(NSMutableArray*)pool object:(NSObject*)object{
    if(pool == nil || object==nil)
        return;
    [pool addObject:object];
}

+(void)onGotoBack:(UIViewController*)vc{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2];
    
    vc.view.frame = CGRectMake (JX_SCREEN_WIDTH, 0, vc.view.frame.size.width, vc.view.frame.size.height);
    
    [UIView commitAnimations];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doQuit:) userInfo:vc repeats:NO];
}

+(void)doQuit:(NSTimer*)timer{
    UIViewController* vc = timer.userInfo;
    [vc.view removeFromSuperview];
//    [vc release];
    vc = nil;
}

-(void)removeAllChild:(UIView*)parent{
    for(NSInteger i=[[parent subviews] count]-1;i>=0;i--){
        [[[parent subviews] objectAtIndex:i] removeFromSuperview];
    }
}

+(UIView*)createLine:(UIColor*)color parent:(UIView*)parent{
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,0,parent.frame.size.width,0.5)];
    line.backgroundColor = color;
    [parent addSubview:line];
    return line;
}

+(UIView*)createLine:(UIView*)parent{
    return [self createLine:THE_LINE_COLOR parent:parent];
}

@end
