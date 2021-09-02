//
//  UIFactory.h
//  SmartMeeting
//
//  Created by luddong on 12-3-30.
//  Copyright (c) 2012年 Twin-Fish. All rights reserved.
//

#import <UIKit/UIKit.h>

#define g_UIFactory [UIFactory sharedUIFactory]

@interface UIFactory : NSObject

/**--------------------------------
 * Create UITextField
 *
 * frame            :CGRect
 * delegate         :id<UITextFieldDelegate>
 * returnKeyType    :UIReturnKeyType
 * secureTextEntry  :BOOL
 * placeholder      :NSString
 * font             :UIFont
 *
 */
+ (id)createTextFieldWith:(CGRect)frame 
                 delegate:(id<UITextFieldDelegate>)delegate
            returnKeyType:(UIReturnKeyType)returnKeyType
          secureTextEntry:(BOOL)secureTextEntry
              placeholder:(NSString *)placeholder 
                     font:(UIFont *)font;


/**--------------------------------
 * Create UILabel
 *
 * frame :CGRect
 * label :NSString
 *
 */
+ (id)createLabelWith:(CGRect)frame 
                text:(NSString *)text;

/**--------------------------------
 * Create UILabel
 *
 * frame :CGRect
 * label :NSString
 *
 */
+ (id)createClearBackgroundLabelWith:(CGRect)frame 
                                text:(NSString *)text;

/**--------------------------------
 * Create UILabel
 *
 * frame            :CGRect
 * label            :NSString
 * backgroundColor  :UIColor
 *
 */
+ (id)createLabelWith:(CGRect)frame 
                text:(NSString *)text 
      backgroundColor:(UIColor *)backgroundColor;

/**--------------------------------
 * Create UILabel
 *
 * frame            :CGRect
 * label            :NSString
 * font             :UIFont
 * textColor        :UIColor
 * backgroundColor  :UIColor
 *
 */
+ (id)createLabelWith:(CGRect)frame 
                text:(NSString *)text 
                 font:(UIFont *)font 
            textColor:(UIColor *)textColor 
      backgroundColor:(UIColor *)backgroundColor;

/**--------------------------------
 * Convert Resizable (Stretchable) Image;
 *
 *  title           :NSString *
 *  message         :NSString *
 */
+(UIView*)createLine:(UIColor*)color parent:(UIView*)parent;
+(UIView*)createLine:(UIView*)parent;

+ (UIImage*)resizableImageWithSize:(CGSize)size
                             image:(UIImage*)image;

+ (UIColor*)maskColor:(UIColor *)color withMask:(UIColor *)maskColor withAlpha:(CGFloat )alpha;
+ (CGFloat )singleColorBlend:(CGFloat )color withMask:(CGFloat )maskColor withAlpha:(CGFloat )alpha;

+ (UIButton *)createCommonButton:(NSString *)title target:(id)target action:(SEL)selector;

+ (UIButton *)createButtonWithTitle:(NSString *)title
                          titleFont:(UIFont *)font
                         titleColor:(UIColor *)titleColor
                             normal:(NSString *)normalImage
                           highlight:(NSString *)clickIamge;

+ (UIButton *)createButtonWithImage:(NSString *)normalImage
                           highlight:(NSString *)clickIamge
                             target:(id)target
                           selector:(SEL)selector;

+ (UIButton *)createButtonWithImage:(NSString *)normalImage
                           selected:(NSString *)clickIamge
                             target:(id)target
                           selector:(SEL)selector;

+ (UIButton *)createButtonWithTitle:(NSString *)title
                          titleFont:(UIFont *)font
                         titleColor:(UIColor *)titleColor
                             normal:(NSString *)normalImage
                          highlight:(NSString *)clickIamge
                           selected:(NSString *)selectIamge;

    
+ (UIButton *)createButtonWithRect:(CGRect)frame
                             title:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                          selected:(NSString *)clickIamge
                          selector:(SEL)selector
                            target:(id)target;

+ (UIButton *)createButtonWithRect:(CGRect)frame 
                             title:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                         highlight:(NSString *)clickIamge
                          selector:(SEL)selector
                            target:(id)target;

+ (UIButton *)createButtonWithRect:(CGRect)frame 
                             title:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                         highlight:(NSString *)clickIamge
                             fixed:(CGSize)fixedSize
                          selector:(SEL)selector
                            target:(id)target;

+ (UIButton *)createButtonWithRect:(CGRect)frame 
                             title:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                         highlight:(NSString *)clickIamge
                          selected:(NSString *)selectedImage
                          selector:(SEL)selector
                            target:(id)target;


+ (UITextField *)createTextFieldWithRect:(CGRect)frame
                            keyboardType:(UIKeyboardType)keyboardType
                                  secure:(BOOL)secure
                             placeholder:(NSString *)placeholder
                                    font:(UIFont *)font
                                   color:(UIColor *)color
                                delegate:(id)delegate;

+(UIButton*)createCheckButtonWithRect:(CGRect)frame
                             selector:(SEL)selector
                               target:(id)target;

+ (UIButton *)createRadioButtonWithRect:(CGRect)frame
                            normalImage:(NSString *)normalImage
                          selectedImage:(NSString *)selectedImage
                              labelText:(NSString *)labelText
                              textColor:(UIColor*)textColor
                               selector:(SEL)selector
                                 target:(id)target
                               thisView:(UIView*)thisView;

+ (UIButton *)createRadioButtonWithRect:(CGRect)frame
                              labelText:(NSString *)labelText
                              textColor:(UIColor*)textColor
                               selector:(SEL)selector
                                 target:(id)target
                               thisView:(UIView*)thisView;

+(UIButton*)createTopButton:(NSString*)s action:(SEL)action target:(id)target;

+ (NSString *)localized:(NSString *)key;

/**--------------------------------
 * Check Network Address Validation
 *
 *  address           :NSString *
 */
+ (BOOL)isValidIPAddress:(NSString *)address;
+ (BOOL)isValidPortAddress:(NSString *)address;
+ (BOOL)checkIntValueRange:(NSString *)value min:(int)min max:(int)max;
+ (NSString *)checkValidName:(NSString *)value;
+ (NSString *)checkValidPhoneNumber:(NSString *)value;

+ (void)showAlert:(NSString *)message;
+ (void)showAlert:(NSString *)message tag:(NSUInteger)tag delegate:(id)delegate;
+ (void)showConfirm:(NSString *)message tag:(NSUInteger)tag delegate:(id)delegate;

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)formatStr;
+ (NSDate *)dateFromString:(NSString *)str format:(NSString *)formatStr;

+(void)freeTable:(NSMutableArray*)pool;
+(void)addToPool:(NSMutableArray*)pool object:(NSObject*)object;

+ (UIFactory*)sharedUIFactory;

+(void)onGotoBack:(UIViewController*)vc;

-(void)removeAllChild:(UIView*)parent;

@property (nonatomic, strong) UIFont* font7;
@property (nonatomic, strong) UIFont* font8;
@property (nonatomic, strong) UIFont* font9;
@property (nonatomic, strong) UIFont* font10;
@property (nonatomic, strong) UIFont* font11;
@property (nonatomic, strong) UIFont* font12;
@property (nonatomic, strong) UIFont* font13;
@property (nonatomic, strong) UIFont* font14;
@property (nonatomic, strong) UIFont* font15;
@property (nonatomic, strong) UIFont* font16;
@property (nonatomic, strong) UIFont* font17;
@property (nonatomic, strong) UIFont* font18;
@property (nonatomic, strong) UIFont* font20;
@property (nonatomic, strong) UIFont* font24;
@property (nonatomic, strong) UIFont* font28;

@property (nonatomic, strong) UIFont* font7b;
@property (nonatomic, strong) UIFont* font8b;
@property (nonatomic, strong) UIFont* font9b;
@property (nonatomic, strong) UIFont* font10b;
@property (nonatomic, strong) UIFont* font11b;
@property (nonatomic, strong) UIFont* font12b;
@property (nonatomic, strong) UIFont* font13b;
@property (nonatomic, strong) UIFont* font14b;
@property (nonatomic, strong) UIFont* font15b;
@property (nonatomic, strong) UIFont* font16b;
@property (nonatomic, strong) UIFont* font17b;
@property (nonatomic, strong) UIFont* font18b;
@property (nonatomic, strong) UIFont* font20b;
@property (nonatomic, strong) UIFont* font24b;
@property (nonatomic, strong) UIFont* font28b;
@end

@interface UIImage (ImageNamed)

+ (UIImage *)imageNamed:(NSString *)name;

@end

extern NSString *kStyle2Dir;
