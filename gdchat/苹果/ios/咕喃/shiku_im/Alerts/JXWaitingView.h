//  shiku_im
//
//  Created by flyeagleTang on 14-5-31.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXImageView.h"

@interface JXWaitingView : UIView{
    UIActivityIndicatorView* _aiv;
    UIImageView* _iv;
    UILabel* _title;
}
- (id)initWithTitle:(NSString*)s;
-(void)start:(NSString*)s;
-(void)stop;
+(JXWaitingView*)sharedInstance;

@property (nonatomic,assign) BOOL isShowing;
@end
