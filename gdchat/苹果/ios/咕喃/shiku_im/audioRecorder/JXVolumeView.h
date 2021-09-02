//
//  JXVolumeView.h
//  shiku_im
//
//  Created by flyeagleTang on 14-7-24.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXVolumeView : UIView{
    JXImageView* _input;
    JXImageView* _volume;

}
@property(nonatomic,assign) double volume;

@property (nonatomic, assign) BOOL isWillCancel;

-(void)show;
-(void)hide;
@end
