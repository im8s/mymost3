//
//  JXSearchMoreCell.h
//  shiku_im
//
//  Created by IMAC on 2019/8/30.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXSearchMoreCell : UITableViewCell
@property (nonatomic,strong) NSString *imgName;
@property (nonatomic,strong) NSString *moreName;
@property (nonatomic,strong) UIView *baseView;
@property (nonatomic,strong) UIImageView *ImgView;
@property (nonatomic,strong) UILabel *moreLable;
@property (nonatomic,strong) UIView *selectView;

@end

NS_ASSUME_NONNULL_END
