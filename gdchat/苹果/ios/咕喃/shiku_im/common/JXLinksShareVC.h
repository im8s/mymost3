//
//  JXLinksShareVC.h
//  shiku_im
//
//  Created by 1 on 2019/3/11.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXLinksShareVC : UIViewController
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, assign) BOOL isFloatWindow; // 当前是否开启了浮窗  YES:开启  NO:未开启

@property (weak, nonatomic) id delegate;
@property (nonatomic, assign) SEL onSend;
@property (nonatomic, assign) SEL onShare;
@property (nonatomic, assign) SEL onWXSend;
@property (nonatomic, assign) SEL onWXShare;
@property (nonatomic, assign) SEL onCollection;
@property (nonatomic, assign) SEL onSafari;
@property (nonatomic, assign) SEL onReport;
@property (nonatomic, assign) SEL onPasteboard;
@property (nonatomic, assign) SEL onUpdate;
@property (nonatomic, assign) SEL onTextType;
@property (nonatomic, assign) SEL onFloatWindow;
@property (nonatomic, assign) SEL onSearch;

- (void)hideShareView;


@end

NS_ASSUME_NONNULL_END
