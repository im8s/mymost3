//
//  JXSetNoteAndLabelVC.h
//  shiku_im
//
//  Created by 1 on 2019/5/7.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "admobViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface JXSetNoteAndLabelVC : admobViewController
@property (nonatomic, strong) JXUserObject *user;

@property(nonatomic,weak) id delegate;
@property(assign) SEL didSelect;

@end

NS_ASSUME_NONNULL_END
