//
//  webpageVC.h
//  sjvodios
//
//  Created by  on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
//@class admobViewController;
@protocol JXServerResult;
#import "admobViewController.h"

@interface webpageVC : admobViewController<UIScrollViewDelegate>{
    UIWebView*  webView;
    UIActivityIndicatorView *aiv;

    int   _type;
    float _num;
    float _price;
    NSString* _product;
}

@property(nonatomic,strong) UIWebView* webView;
@property(nonatomic,strong) NSString* url;
@property(nonatomic,strong) NSString* shareUrl;
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, assign) BOOL isSend;
@property (nonatomic,copy) NSString *shareParam;

@property (nonatomic, strong) NSString *tradeNo; // 订单号，银行卡支付
@property (nonatomic, strong) NSString *redPacketNo; // 红包id，银行卡支付
@property (nonatomic, strong) NSString *transferNo;  // 转账id，银行卡支付
@property (nonatomic, strong) NSString *withdrawalNo; // 提现订单号，银行卡支付
@property (nonatomic, assign) BOOL isCloud;

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) SEL isPayComplete;




-(float)getMoney:(char*)s;
@end
