//
//  JXAddressBook.h
//  shiku_im
//
//  Created by p on 2017/4/14.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JXAddressBook : NSObject

@property (nonatomic, copy) NSString *_id;
@property (nonatomic, strong) NSNumber *registerEd;
@property (nonatomic, strong) NSDate *registerTime;
@property (nonatomic, copy) NSString *telephone;
@property (nonatomic, copy) NSString *toTelephone;
@property (nonatomic, copy) NSString *toUserId;
@property (nonatomic, copy) NSString *toUserName;
@property (nonatomic, copy) NSString *addressBookName;

@property (nonatomic, strong) NSNumber *isRead;

@property (nonatomic, copy) NSString *tableName;

+(JXAddressBook*)sharedInstance;

//数据库增删改查
-(BOOL)insert;
-(BOOL)delete;
-(BOOL)update;

// 查询未读消息
-(NSMutableArray *)doFetchUnread;
// 将未读消息设置为已读
- (BOOL)updateUnread;

// 获取通讯录
- (NSDictionary *) getMyAddressBook;
// 上传手机通讯录联系人
- (void) uploadAddressBookContacts;
// 获取所有手机联系人用户
- (NSMutableArray *)fetchAllAddressBook;
@end
