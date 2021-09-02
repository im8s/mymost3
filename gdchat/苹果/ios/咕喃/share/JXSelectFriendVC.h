//
//  JXSelectFriendVC.h
//  share
//
//  Created by 1 on 2019/3/20.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JXSelectFriendVC;
@class JXShareUser;
@protocol JXSelectFriendVCDlegate <NSObject>

- (void)sendToFriendSuccess:(JXSelectFriendVC *)selectVC user:(JXShareUser *)user;

@end

@interface JXSelectFriendVC : UIViewController
@property (nonatomic, strong) NSArray *datas;
@property (weak, nonatomic) id <JXSelectFriendVCDlegate> delegate;


@end

