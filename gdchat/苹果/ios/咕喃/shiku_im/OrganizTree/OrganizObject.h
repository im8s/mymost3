//
//  OrganizObject.h
//  shiku_im
//
//  Created by 1 on 17/5/11.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

//@class JXUserObject;

@interface OrganizObject : NSObject

/** 节点名 */
@property (copy, nonatomic) NSString *nodeName;
/** 节点Id */
@property (copy, nonatomic) NSString *nodeId;
/** 父节点Id */
@property (copy, nonatomic) NSString * parentId;

/** 类型 */
@property (assign, nonatomic) int type;

/** 节点为员工时有值,否则为nil */
@property (copy, nonatomic) NSString *userId;

/** 子节点数组 */
@property (strong, nonatomic) NSArray *children;


- (id)initWithDict:(NSDictionary *)nodeDict;

+ (id)organizObjectWithDict:(NSDictionary *)nodeDict;


- (void)addChild:(id)child;
- (void)removeChild:(id)child;


@end
