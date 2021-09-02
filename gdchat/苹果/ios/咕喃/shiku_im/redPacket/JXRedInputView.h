//
//  JXRedInputView.h
//  shiku_im
//
//  Created by 1 on 17/8/15.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXRedInputView : UIView

@property (nonatomic, assign) NSUInteger type;
@property (nonatomic, assign) BOOL isRoom;
@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) UIView * countView;
@property (nonatomic, strong) UIView * moneyView;
@property (nonatomic, strong) UIView * greetView;

@property (nonatomic, strong) UIButton * sendButton;
@property (nonatomic, strong) UILabel * noticeTitle;


@property (nonatomic, strong) UITextField * countTextField;
@property (nonatomic, strong) UITextField * moneyTextField;
@property (nonatomic, strong) UITextField * greetTextField;

@property (nonatomic, strong) UILabel * countTitle;
@property (nonatomic, strong) UILabel * moneyTitle;
@property (nonatomic, strong) UILabel * greetTitle;


@property (nonatomic, strong) UILabel * countUnit;
@property (nonatomic, strong) UILabel * moneyUnit;


@property (nonatomic, strong) UILabel * allMoneyLab;
@property (nonatomic, strong) UIView * line;

-(instancetype)initWithFrame:(CGRect)frame type:(NSUInteger)type isRoom:(BOOL)isRoom delegate:(id)delegate;

-(void)stopEdit;

@end
