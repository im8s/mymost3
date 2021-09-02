//
//  JXFriendTableViewCell.h
//  shiku_im
//
//  Created by liangjian on 2020/10/7.
//  Copyright © 2020 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXFriendTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *subTitleL;
@property (weak, nonatomic) IBOutlet UILabel *FriendNewCountL;

@end

NS_ASSUME_NONNULL_END
