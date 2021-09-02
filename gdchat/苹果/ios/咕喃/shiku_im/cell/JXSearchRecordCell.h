//
//  JXSearchRecordCell.h
//  shiku_im
//
//  Created by IMAC on 2019/9/6.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class JXSearchRecordCell;
@protocol JXSearchRecordCellDelegate <NSObject>

- (void)deleteCell:(JXSearchRecordCell *)cell;

@end


@interface JXSearchRecordCell : UITableViewCell
@property (nonatomic,strong)UIButton *deleteBtn;
@property (nonatomic,weak)id<JXSearchRecordCellDelegate> delegate;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end

NS_ASSUME_NONNULL_END
