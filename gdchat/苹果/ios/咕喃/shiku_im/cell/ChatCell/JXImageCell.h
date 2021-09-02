//
//  JXImageCell.h
//  shiku_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXBaseChatCell.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"

@interface JXImageCell : JXBaseChatCell
@property (nonatomic,strong) FLAnimatedImageView * chatImage;//cell里的UIView

@property (nonatomic,assign) int currentIndex;//当前选中图片的序号
@property (nonatomic,assign,getter=getImageWidth) int imageWidth;
@property (nonatomic,assign,getter=getImageHeight) int imageHeight;

@property (nonatomic, assign) BOOL isRemove;

@property (nonatomic, strong) UILabel *imageProgress;


- (void)deleteReadMsg;

- (void)timeGo:(JXMessageObject *)msg;

@end
