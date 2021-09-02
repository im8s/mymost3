//
//  JXTalkViewController.h
//  lveliao_IM
//
//  Created by p on 2019/6/18.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "admobViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol JXTalkViewControllerDelegate <NSObject>

- (void)talkVCCloseBtnAction;
- (void)talkVCTalkStart;
- (void)talkVCTalkStop;

@end

@interface JXTalkViewController : admobViewController

@property (nonatomic, weak) id<JXTalkViewControllerDelegate> delegate;
@property (nonatomic,copy) NSString *roomNum;

@end

NS_ASSUME_NONNULL_END
