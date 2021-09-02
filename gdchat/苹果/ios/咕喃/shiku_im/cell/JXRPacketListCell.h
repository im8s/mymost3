//
//  JXRPacketListCell.h
//  shiku_im
//
//  Created by Apple on 16/8/31.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXRPacketListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *headerImage;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *moneyLabel;
@property (strong, nonatomic) IBOutlet UIView *buttomLine;
@property (strong, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headImageWidthCon;
@property (strong, nonatomic) IBOutlet UIImageView *kingImgV;
@property (strong, nonatomic) IBOutlet UILabel *bestLab;

@property (nonatomic, strong) UIView *line;

@end
