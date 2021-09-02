//
//  JXInputVC.h
//  shiku_im
//
//  Created by flyeagleTang on 15-2-4.
//  Copyright (c) 2015年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JXInputVC : UIViewController <UITextFieldDelegate>{
    UITextField* _value;
    JXInputVC* _pSelf;
    
}
@property (nonatomic,strong) NSString*  inputTitle;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic,strong) NSString*  inputHint;
@property (nonatomic,strong) NSString*  inputBtn;
@property (nonatomic,strong) NSString*  inputText;
@property (nonatomic, weak) NSObject* delegate;
@property (nonatomic, assign) SEL		didTouch;

@end
