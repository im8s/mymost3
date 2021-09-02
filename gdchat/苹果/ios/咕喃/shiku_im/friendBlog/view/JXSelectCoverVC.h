//
//  JXSelectCoverVC.h
//  shiku_im
//
//  Created by IMAC on 2019/7/31.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "admobViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class JXSelectCoverVC;
@protocol JXSelectCoverVCDelegate <NSObject>

- (void)touchAtlasButtonReturnCover:(UIImage *)img;
- (void)selectImage:(UIImage *)img toView:(JXSelectCoverVC *)view;

@end
@interface JXSelectCoverVC : admobViewController

@property (nonatomic,weak) id<JXSelectCoverVCDelegate> delegate;
- (instancetype)initWithVideo:(NSString *)video;

@end

NS_ASSUME_NONNULL_END
