//
//  JXFriendTableViewCell.m
//  shiku_im
//
//  Created by liangjian on 2020/10/7.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "JXFriendTableViewCell.h"



@implementation JXFriendTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imgView.layer.cornerRadius=5;
    self.imgView.layer.masksToBounds = YES;
    
    self.FriendNewCountL.layer.cornerRadius = self.FriendNewCountL.frame.size.width / 2;
    self.FriendNewCountL.layer.masksToBounds = YES;
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
