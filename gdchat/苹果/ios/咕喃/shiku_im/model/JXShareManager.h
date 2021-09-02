//
//  JXShareManager.h
//  shiku_im
//
//  Created by MacZ on 16/8/19.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMSocial.h"
#import "JXShareModel.h"
//#import <FBSDKShareKit/FBSDKShareKit.h>

@protocol ShareManagerDelegate <NSObject>

- (void)didShareSuccess;

@end

@interface JXShareManager : NSObject<UMSocialUIDelegate/*,FBSDKSharingDelegate*/>

@property (nonatomic,weak) id delegate;

+ (JXShareManager *)defaultManager;

- (void)shareWith:(JXShareModel *)shareModel delegate:(id)delegate;

@end
