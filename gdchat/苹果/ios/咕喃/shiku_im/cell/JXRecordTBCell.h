//
//  JXRecordTBCell.h
//  shiku_im
//
//  Created by Apple on 16/9/6.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXRecordTBCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *moneyLabel;
@property (strong, nonatomic) IBOutlet UILabel *refundLabel;
@property (strong, nonatomic) IBOutlet UIImageView *stastusImg;

@end
