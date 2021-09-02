//
//  TipBlackView.h
//  shiku_im
//
//  Created by MacZ on 16/4/18.
//  Copyright (c) 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXTipBlackView : UIView{
    UILabel *_titleLabel;
}

- (id)initWithTitle:(NSString *)title;
- (void)show;

@end
