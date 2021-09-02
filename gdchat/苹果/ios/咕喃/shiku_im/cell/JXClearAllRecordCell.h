//
//  JXClearAllRecordCell.h
//  shiku_im
//
//  Created by IMAC on 2019/9/6.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXClearAllRecordCell : UITableViewCell
@property(nonatomic ,strong)NSString *titleString;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTitle:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
