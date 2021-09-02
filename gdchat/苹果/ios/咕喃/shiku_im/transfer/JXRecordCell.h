//
//  JXRecordCell.h
//  shiku_im
//
//  Created by 1 on 2019/4/20.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JXRecordModel;

NS_ASSUME_NONNULL_BEGIN

@interface JXRecordCell : UITableViewCell

@property (nonatomic, strong) UIView *lineView;

- (void)setData:(JXRecordModel *)model;

@end

NS_ASSUME_NONNULL_END
