//
//  JXUserInfoVC.h
//  shiku_im
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "admobViewController.h"
#import "JX_SelectMenuView.h"
#import "JXGoogleMapVC.h"
#import "JXChatViewController.h"

@class DMScaleTransition;

@interface JXUserInfoVC : admobViewController<LXActionSheetDelegate>{
    UILabel* _name;
    UILabel* _remarkName;
    UILabel* _describe;
    UILabel* _workexp;
    UILabel* _city;
    UILabel* _dip;
    UILabel* _date;
    UILabel* _tel;
    UILabel* _lastTime;
    UILabel* _showNum;
    UILabel* _account;
    UILabel* _label;
    UIImageView* _sex;
    JXLabel *_labelLab;
    UILabel* _desLab;

    UISwitch *_messageFreeSwitch;
    UIView *_baseView;
    
    JXImageView *_describeImgV;
    JXImageView *_lifeImgV;
    JXImageView *_birthdayImgV;
    JXImageView *_lastTImgV;
    JXImageView *_showNImgV;
    JXImageView *_circleImgV;
    JXImageView *_desImgV;

    double _latitude;
    double _longitude;
    
    JXImageView* _head;
//    JXImageView* _body;

    int _friendStatus;
    NSString*   _xmppMsgId;
    UIButton* _btn;
    BOOL _deleleMode;
    NSMutableArray * _titleArr;
    DMScaleTransition *_scaleTransition;
    JXGoogleMapVC *_gooMap;
}

@property (nonatomic,strong) JXUserObject* user;
@property (nonatomic,strong) UIView * bgBlackAlpha;
@property (nonatomic,strong) JX_SelectMenuView * selectView;
@property (nonatomic, assign) BOOL isJustShow;
@property (nonatomic, assign) BOOL isShowGoinBtn;
@property (nonatomic, copy) NSString *userId;

@property (nonatomic, assign) int fromAddType;

@property (nonatomic, weak) JXChatViewController *chatVC;


@end
