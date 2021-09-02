//
//  JXFriendCell.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JXFriendObject;
@class JXFriendCell;

@protocol JXFriendCellDelegate <NSObject>

- (void) friendCell:(JXFriendCell *)friendCell headImageAction:(NSString *)userId;

@end

@interface JXFriendCell : UITableViewCell{
    UIImageView* bageImage;
    UILabel* bageNumber;
    UIButton* _btn2;
    UIButton* _btn1;
    UILabel* _lbSubtitle;
    UILabel* _timeLab;
}
@property (nonatomic,strong) NSString*  title;
@property (nonatomic,strong) NSString*  subtitle;
@property (nonatomic,strong) NSString*  rightTitle;
@property (nonatomic,strong) NSString*  bottomTitle;
@property (nonatomic,strong) NSString*  headImage;
@property (nonatomic,strong) NSString*  bage;
@property (nonatomic,strong) JXFriendObject* user;
@property (nonatomic,strong) id target;
@property (nonatomic, weak) id<JXFriendCellDelegate>delegate;

@property (nonatomic, strong) UIView* lineView;

-(void)update;

@end
