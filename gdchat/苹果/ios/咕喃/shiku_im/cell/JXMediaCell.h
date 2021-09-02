//
//  JXMediaCell.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXVideoPlayer.h"

@class JXMediaObject;

@interface JXMediaCell : UITableViewCell{
    UIImageView* bageImage;
    UILabel* bageNumber;
    JXVideoPlayer* _player;
}
@property (nonatomic,strong) UIButton* pauseBtn;
@property (nonatomic,strong) UIImageView* head;
@property (nonatomic,strong) NSString*  bage;
@property (nonatomic,strong) JXMediaObject* media;
@property (nonatomic,weak) id delegate;
@end
