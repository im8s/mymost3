//
//  JXShareSelectView.h
//  shiku_im
//
//  Created by MacZ on 15/8/26.
//  Copyright (c) 2015年 Reese. All rights reserved.
//

#import "admobViewController.h"
#import <UIKit/UIKit.h>

#import "JXShareModel.h"

@protocol ShareListDelegate <NSObject>

- (void)didShareBtnClick:(UIButton *)shareBtn;

@end

@interface JXShareListVC : UIViewController{
    UIView *_listView;
    
    JXShareListVC *_pSelf;
}

@property (nonatomic,weak) id<ShareListDelegate> shareListDelegate;

- (void)showShareView;

@end
