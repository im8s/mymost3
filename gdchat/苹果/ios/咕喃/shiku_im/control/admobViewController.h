//
//  admobViewController.h
//  sjvodios
//
//  Created by  on 11-12-6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
@class JXImageView;
@class JXLabel;

@interface admobViewController : UIViewController{
    ATMHud* _wait;
//    admobViewController* _pSelf;
}
@property(nonatomic,retain,setter = setLeftBarButtonItem:)  UIBarButtonItem *leftBarButtonItem;
@property(nonatomic,retain,setter = setRightBarButtonItem:) UIBarButtonItem *rightBarButtonItem;
@property(nonatomic,assign) BOOL isGotoBack;
@property(nonatomic,assign) BOOL isFreeOnClose;
@property(nonatomic,strong) UIView *tableHeader;
@property(nonatomic,strong) UIView *tableFooter;
@property(nonatomic,strong) UIScrollView *tableBody;
@property(nonatomic,assign) int heightHeader;
@property(nonatomic,assign) int heightFooter;
@property(nonatomic,strong) UIButton *footerBtnMid;
@property(nonatomic,strong) UIButton *footerBtnLeft;
@property(nonatomic,strong) UIButton *footerBtnRight;
@property(nonatomic,strong) JXLabel  *headerTitle;

-(void)createHeadAndFoot;
-(void)actionQuit;
-(void)onGotoHome;
@end
