//
//  OrganizTableViewCell.h
//  shiku_im
//
//  Created by 1 on 17/5/12.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DepartObject.h"

@interface OrganizTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView * arrowView;
@property (nonatomic) BOOL arrowExpand;
//@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *additionButton;
@property (nonatomic, strong) UILabel *noticeLab;

@property (strong, nonatomic) DepartObject *organizObject;

@property (nonatomic, copy) void (^additionButtonTapAction)(id sender);

@property (nonatomic, copy) void (^noticeLabTapAction)(DepartObject *dataObj);

//@property (nonatomic) BOOL additionButtonHidden;

- (void)setupWithData:(DepartObject *)dataObj level:(NSInteger)level expand:(BOOL)expand;
//- (void)setArrowExpand:(BOOL)arrowExpand animated:(BOOL)animated;
//- (void)setAdditionButtonHidden:(BOOL)additionButtonHidden animated:(BOOL)animated;


@end
