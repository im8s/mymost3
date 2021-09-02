//
//  JXSelectCashWithdrawalCell.h
//  shiku_im
//
//  Created by p on 2019/12/9.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXSelectCashWithdrawalCell : UITableViewCell

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) UILabel *addLabel;

@end

NS_ASSUME_NONNULL_END
