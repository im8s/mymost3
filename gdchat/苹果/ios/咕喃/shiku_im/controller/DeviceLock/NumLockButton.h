//
//  NumLockButton.h
//  numLockTest
//
//  Created by banbu01 on 15-2-5.
//  Copyright (c) 2015年 com.koochat.test0716. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NumLockButton : UIButton

@property (nonatomic, readonly, assign) NSUInteger number;
@property (nonatomic, readonly, copy) NSString *letters;

@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *lettersLabel;

@property (nonatomic, strong) UIColor *backgroundColorBackup;
- (instancetype)initWithNumber:(NSUInteger)number letters:(NSString *)letters;

@end
