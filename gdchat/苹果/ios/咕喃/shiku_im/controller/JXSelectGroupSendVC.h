//
//  JXSelectGroupSendVC.h
//  shiku_im
//
//  Created by IMAC on 2019/8/14.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXTableViewController.h"

#define SELECTGroup Localized(@"JX_SelectGroup")
#define SELECTColleague Localized(@"JX_ChooseColleagues")
#define SELECTMaillist Localized(@"JX_SelectPhoneContact")
NS_ASSUME_NONNULL_BEGIN
@class JXSelectGroupSendVC;
@protocol JXSelectGroupSendVCDelegate <NSObject>

- (void)selectVC:(JXSelectGroupSendVC *)selectLabelsVC selectArray:(NSMutableArray *)array;

@end

@interface JXSelectGroupSendVC : JXTableViewController
@property (nonatomic,strong)NSString *titleString;
@property (nonatomic,weak) id<JXSelectGroupSendVCDelegate> delegate;
@property (nonatomic,strong) NSMutableArray *seletedArray;
- (instancetype)initWithTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
