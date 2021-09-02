//
//  JXUserPublicKeyObj.h
//  shiku_im
//
//  Created by p on 2019/8/7.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXUserPublicKeyObj : NSObject


@property (nonatomic,copy) NSString *userId;    // 好友userId
@property (nonatomic,copy) NSString *publicKey; // 好友的公钥
@property (nonatomic, strong) NSDate *keyCreateTime;    // 公钥创建时间

+ (instancetype)sharedManager;

//数据库增删改查
-(BOOL)insert;
-(BOOL)delete;

// 获取好友的公钥列表
- (NSMutableArray *)fetchPublicKeyWithUserId:(NSString *)userId;
// 删除好友的公钥列表
- (BOOL)deletePublicKeyWIthUserId:(NSString *)userId;

@end

NS_ASSUME_NONNULL_END
