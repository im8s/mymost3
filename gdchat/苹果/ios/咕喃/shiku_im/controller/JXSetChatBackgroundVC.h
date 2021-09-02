//
//  JXSetChatBackgroundVC.h
//  shiku_im
//
//  Created by p on 2017/12/8.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "admobViewController.h"

@class JXSetChatBackgroundVC;
@protocol JXSetChatBackgroundVCDelegate <NSObject>

- (void)setChatBackgroundVC:(JXSetChatBackgroundVC *)setChatBgVC image:(UIImage *)image;

@end

@interface JXSetChatBackgroundVC : admobViewController

@property (nonatomic, weak) id<JXSetChatBackgroundVCDelegate>delegate;
@property (nonatomic, copy) NSString *userId;

@end
