//
//  JXWhoCanSeeCell.h
//  shiku_im
//
//  Created by p on 2018/6/27.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JXWhoCanSeeCell;
@protocol JXWhoCanSeeCellDelegate <NSObject>

- (void)whoCanSeeCell:(JXWhoCanSeeCell *)whoCanSeeCell selectAction:(NSInteger)index;
- (void)whoCanSeeCell:(JXWhoCanSeeCell *)whoCanSeeCell editBtnAction:(NSInteger)index;

@end

@interface JXWhoCanSeeCell : UITableViewCell
@property (nonatomic, strong) UIButton *contentBtn;
@property (nonatomic, strong) UIImageView *selImageView;
@property (nonatomic, strong) JXLabel *title;
@property (nonatomic, strong) JXLabel *userNames;
@property (nonatomic, strong) UIButton *editBtn;

@property (nonatomic, weak) id<JXWhoCanSeeCellDelegate>delegate;
@property (nonatomic, assign) NSInteger index;
@end
