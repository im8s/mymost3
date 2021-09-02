//
//  JXSearchRecordCell.h
//  shiku_im
//
//  Created by IMAC on 2019/8/27.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger ,JXSearchShowCellStyle){
    JXSearchShowCellStyleUser,
    JXSearchShowCellStyleRecord,
};
NS_ASSUME_NONNULL_BEGIN

@interface JXSearchShowCell : UITableViewCell
@property (nonatomic,assign)JXSearchShowCellStyle cellStyle;
@property (nonatomic,strong)UIImageView *headImgView;
@property (nonatomic,strong)UILabel *aboveLable;
@property (nonatomic,strong)UILabel *belowLable;
@property (nonatomic,strong)UILabel *rightLable;
@property (nonatomic,strong)NSString *headImg;
@property (nonatomic,strong)NSString *aboveText;
@property (nonatomic,strong)NSMutableAttributedString *aboveAttributedText;
@property (nonatomic,strong)NSString *belowText;
@property (nonatomic,strong)NSMutableAttributedString *belowAttributedText;
@property (nonatomic,strong)NSString *rightText;
@property (nonatomic,strong)UIView *selectView;
@property (nonatomic,strong)NSString *searchText;
@property (nonatomic,assign)NSInteger num;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withNewStyle:(JXSearchShowCellStyle)newStyle;
- (void)cutSelectedView;
@end

NS_ASSUME_NONNULL_END
