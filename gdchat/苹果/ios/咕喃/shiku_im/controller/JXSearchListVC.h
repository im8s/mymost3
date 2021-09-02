//
//  JXSearchListVC.h
//  shiku_im
//
//  Created by IMAC on 2019/8/9.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SCREEN_BAR (THE_DEVICE_HAVE_HEAD ? 44 : 20)
#define SCREEN_VIEW (THE_DEVICE_HAVE_HEAD ? 44+44 : 20+44)
#define CONTACT Localized(@"JX_SelectImageContact")
#define GROUP Localized(@"JX_ManyPerChat")
#define PUBLIC Localized(@"JX_PublicNumberOfInterest")
#define RECORD Localized(@"JX_ChatRecord")
#define USERNUMBER Localized(@"JX_Communication")
#define CONTAIN Localized(@"JX_Contain")
#define RECORDNUMBERS Localized(@"JX_RelatedChatHistory")
#define MORE Localized(@"JX_More")
#define SEARCH Localized(@"JX_Seach")
#define CANCEL Localized(@"JX_Cencal")
NS_ASSUME_NONNULL_BEGIN
@protocol JXSearchListDelegate <NSObject>

- (void)tapSearchCancelBtn;
- (void)tapBackBtn:(BOOL )hasRecord;
- (void)listDidAppear:(BOOL )hasRecord;
- (void)listWillDisappear:(BOOL )hasRecord;
- (void)saveSearchRecord:(NSString *)searchRecord;

@end
@interface JXSearchListVC : UIViewController
@property (nonatomic,strong)UISearchBar *searchbar;
@property (nonatomic,strong)UITableView *tableview;
@property (nonatomic,strong)UITableView *recordtableview;
@property (nonatomic,strong)UIButton *backbtn;
@property (nonatomic,weak)id<JXSearchListDelegate> delegate;
- (instancetype)initWithLable:(NSString *)lable withSearchText:(NSString *)searchtext withUserArray:(nullable NSMutableArray *)array withGroupDictionary:(nullable NSMutableDictionary *)groupdic withMsgDictionary:(nullable NSMutableDictionary *)msgDic isChatRecord:(BOOL )isChatRecord  enterChatRecord:(BOOL )enterChatRecord withPeople:(nullable JXUserObject *)people;
@end

NS_ASSUME_NONNULL_END
