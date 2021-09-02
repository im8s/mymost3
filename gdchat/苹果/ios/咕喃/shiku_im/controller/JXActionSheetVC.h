//
//  JXActionSheetVC.h
//  shiku_im
//
//  Created by 1 on 2018/9/3.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JXActionSheetVC;

@protocol JXActionSheetVCDelegate <NSObject>

/**
 
  控件点击事件index从 0 开始,从下到上
 
 */
- (void)actionSheet:(JXActionSheetVC *)actionSheet didButtonWithIndex:(NSInteger)index;

@end

@interface JXActionSheetVC : UIViewController

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong) UIColor *backGroundColor;
@property (nonatomic, weak) id<JXActionSheetVCDelegate>delegate;

@property (nonatomic, weak) id objectInfo; // 附加对象，可以传值

- (instancetype)initWithImages:(NSArray *)images names:(NSArray *)names;
    
@end
