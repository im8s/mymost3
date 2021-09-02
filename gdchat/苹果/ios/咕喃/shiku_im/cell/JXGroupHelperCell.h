//
//  JXGroupHelperCell.h
//  shiku_im
//
//  Created by 1 on 2019/5/29.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXHelperModel.h"

NS_ASSUME_NONNULL_BEGIN


@class JXGroupHelperCell;

@protocol JXGroupHelperCellDelegate <NSObject>

- (void)groupHelperCell:(JXGroupHelperCell *)cell clickAddBtnWithIndex:(NSInteger)index;

@end


@interface JXGroupHelperCell : UITableViewCell

@property (nonatomic, strong) UIImageView *imageV;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *subTitle;
@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) NSArray *groupHelperArr;

@property (weak, nonatomic) id <JXGroupHelperCellDelegate>delegate;


- (void)setDataWithModel:(JXHelperModel *)model;


@end

NS_ASSUME_NONNULL_END
