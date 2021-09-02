//
//  JXAddressBookCell.h
//  shiku_im
//
//  Created by p on 2018/8/30.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCheckBox.h"
#import "JXAddressBook.h"

@class JXAddressBookCell;
@protocol JXAddressBookCellDelegate <NSObject>

- (void)addressBookCell:(JXAddressBookCell *)abCell checkBoxSelectIndexNum:(NSInteger)indexNum isSelect:(BOOL)isSelect;
- (void)addressBookCell:(JXAddressBookCell *)abCell addBtnAction:(JXAddressBook *)addressBook;

@end

@interface JXAddressBookCell : UITableViewCell <QCheckBoxDelegate>

@property (nonatomic, strong) JXImageView *headImage;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *nickName;
@property (nonatomic, strong) QCheckBox *checkBox;
@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL isShowSelect;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, weak) id<JXAddressBookCellDelegate>delegate;

@property (nonatomic, strong) JXAddressBook *addressBook;

@property (nonatomic, assign) BOOL isInvite;

@end
