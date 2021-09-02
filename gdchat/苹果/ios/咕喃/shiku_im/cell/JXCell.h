//
//  JXCell.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXBadgeView.h"

@interface JXCell : UITableViewCell{
    
}
@property (nonatomic,retain,setter=setTitle:) NSString*  title;
@property (nonatomic,strong) NSString*  subtitle;
@property (nonatomic,strong) NSString*  bottomTitle;
@property (nonatomic,strong) NSString*  headImage;
@property (nonatomic,strong) NSString*  bage;
@property (nonatomic,strong) NSString*  roomId;
@property (nonatomic,strong) NSString*  userId;
@property (strong, nonatomic) NSString * positionTitle;
@property (nonatomic,strong) JXImageView * headImageView;

@property (nonatomic) int index;
@property (nonatomic, assign) NSObject* delegate;
@property (nonatomic, assign) SEL		didTouch;
@property (nonatomic, assign) SEL       didDragout;
@property (nonatomic, assign) SEL       didReplay;
@property (nonatomic, assign) SEL       didDelMsg;


@property (nonatomic,strong) JXLabel*   lbTitle;
@property (nonatomic,strong) JXLabel*   lbBottomTitle;
@property (nonatomic,strong) JXLabel*   lbSubTitle;
@property (nonatomic,strong) JXLabel*   timeLabel;
@property (strong, nonatomic) UILabel * positionLabel;
@property (nonatomic, strong) JXBadgeView* bageNumber;
@property (nonatomic, strong) JXBadgeView* lbBage;
@property (nonatomic, strong) NSString *lbageStr;
@property (nonatomic,strong) JXImageView * notPushImageView;
@property (nonatomic,strong) JXImageView * replayView;
@property (nonatomic, strong) UIImageView *replayImgV;

@property (nonatomic, strong) id dataObj;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, assign) BOOL isSmall;
@property (nonatomic, assign) BOOL isNotPush;
@property (nonatomic, assign) BOOL isMsgVCCome; 

@property (nonatomic, strong) JXUserObject *user;

@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, strong) UIButton *delBtn;

//存cell的badge用的dict
//@property (nonatomic,strong) NSMutableDictionary * bageDict;
//
//- (void) saveBadge:(NSString*)badge withTitle:(NSString*)titl;
- (void)setSuLabel:(NSString *)s;
-(void)setForTimeLabel:(NSString *)s;
//- (void)getHeadImage;


//-(void)msgCellDataSet:(JXMsgAndUserObject *) msgObject indexPath:(NSIndexPath *)indexPath;
//-(void)groupCellDataSet:(NSDictionary *)dataDict indexPath:(NSIndexPath *)indexPath;
-(void)headImageViewImageWithUserId:(NSString *)userId roomId:(NSString *)roomIdStr;
-(void)setLbageStr:(NSString *)lbageStr;
-(void)updateBage:(NSString *)s  isSmall:(BOOL )isSmall;
@end
