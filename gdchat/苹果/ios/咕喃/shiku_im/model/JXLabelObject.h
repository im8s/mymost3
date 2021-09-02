//
//  JXLabelObject.h
//  shiku_im
//
//  Created by p on 2018/6/21.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JXLabelObject : NSObject

@property (nonatomic, copy) NSString *tableName;

@property (nonatomic, copy) NSString *userId;// 标签拥有者
@property (nonatomic, copy) NSString *groupId; // 标签Id
@property (nonatomic, copy) NSString *groupName;//标签名字
@property (nonatomic, copy) NSString *userIdList;// 该标签下的用户Id [100,120]

+(JXLabelObject*)sharedInstance;

//数据库增删改查
-(BOOL)insert;
-(BOOL)delete;
-(BOOL)update;

// 获取所有标签
-(NSMutableArray *)fetchAllLabelsFromLocal;

// 获取用户的所有标签
- (NSMutableArray *)fetchLabelsWithUserId:(NSString *)userId;

@end
