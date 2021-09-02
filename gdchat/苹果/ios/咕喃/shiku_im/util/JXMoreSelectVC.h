//
//  JXMoreSelectVC.h
//  shiku_im
//
//  Created by 1 on 2019/4/16.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JXMoreSelectVC;

@protocol JXMoreSelectVCDelegate <NSObject>

- (void)didSureBtn:(JXMoreSelectVC *)moreSelectVC indexStr:(NSString *)indexStr;

@end


@interface JXMoreSelectVC : UIViewController

@property (nonatomic, strong) NSString *indexStr;
@property (weak, nonatomic) id <JXMoreSelectVCDelegate>delegate;


- (instancetype)initWithTitle:(NSString *)title dataArray:(NSArray *)dataArray;

@end

