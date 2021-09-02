//
//  ReplyCell.h
//  shiku_im
//
//  Created by Apple on 16/6/25.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HBCoreLabel.h"
@interface ReplyCell : UITableViewCell
@property(nonatomic,retain) HBCoreLabel * label;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *name;

@property(nonatomic,assign) int pointIndex;

@end
