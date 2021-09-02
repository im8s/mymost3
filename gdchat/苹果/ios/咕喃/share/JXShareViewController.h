//
//  JXShareViewController.h
//  share
//
//  Created by 1 on 2019/3/20.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>


@class JXShareViewController;
@protocol JXShareVCDlegate <NSObject>

- (void)sendToLifeCircleSucces:(JXShareViewController *)shareVC;

@end

@interface JXShareViewController : UIViewController

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSDictionary *dataDict;
@property (nonatomic, strong) UITextView *textView;

@property (weak, nonatomic) id <JXShareVCDlegate> delegate;

@end

