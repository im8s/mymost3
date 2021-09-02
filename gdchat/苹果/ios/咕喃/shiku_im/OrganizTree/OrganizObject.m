//
//  OrganizObject.m
//  shiku_im
//
//  Created by 1 on 17/5/11.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "OrganizObject.h"
#import "JXUserObject.h"

@implementation OrganizObject

-(id)initWithDict:(NSDictionary *)nodeDict
{
    self = [super init];
    if (self) {
        if (nodeDict[@"nickname"] != nil)
            self.nodeName = nodeDict[@"nickname"];
        if (nodeDict[@"userId"] != nil)
            self.userId = nodeDict[@"userId"];
//        if (nodeDict[@""] != nil)
//            self.parentId;
//        if (nodeDict[@"child"] != nil && [nodeDict[@"child"] count] > 0)
//            self.children = nodeDict[@"child"];
//        else
//            _children = @[];
    }
    return self;
}

//-(instancetype)initDepart:(NSDictionary *)nodeDict  allData:(NSDictionary *)allDict{
//    self = [super init];
//    if (self) {
//        
//        
//        if (nodeDict[@"departName"] != nil)
//            self.departName = nodeDict[@"departName"];
//            self.createUserId
//            self.empNum
//            self.employees
//            self.departId = nodeDict[@"id"];
//        {
//            "companyId": "591e5ea35da45bc34f99d940",
//            "createTime": 1495162531,
//            "createUserId": 10007882,
//            "departName": "跳跳糖",
//            "empNum": 1,
//            "employees": [
//                          {
//                              "companyId": "591e5ea35da45bc34f99d940",
//                              "departmentId": "591e5ea35da45bc34f99d941",
//                              "id": "591e5ea35da45bc34f99d942",
//                              "role": 3,
//                              "userId": 10007882
//                          }
//                          ],
//            "id": "591e5ea35da45bc34f99d941"
//        }
//    }
//    return self;
//}
//
///** 创建部门节点 */
//+(instancetype)departmentObjectWith:(NSDictionary *)nodeDict allData:(NSDictionary *)allDict{
//    return [[self alloc] initDepart:nodeDict allData:allDict];
//}

-(void)setChildren:(NSArray *)children{
    if ([children[0] isKindOfClass:[OrganizObject class]]) {
        _children = children;
        return;
    }
    NSMutableArray *childArray = [NSMutableArray array];
    for (NSDictionary * childDict in children) {
        OrganizObject * organiz = [OrganizObject organizObjectWithDict:childDict];
        [childArray addObject:organiz];
    }
    _children = [NSArray arrayWithArray:childArray];
}
+(id)organizObjectWithDict:(NSDictionary *)nodeDict
{
    return [[self alloc] initWithDict:nodeDict];
}

- (void)addChild:(id)child
{
    NSMutableArray *children = [self.children mutableCopy];
    [children insertObject:child atIndex:0];
    _children = [children copy];
}

- (void)removeChild:(id)child
{
    NSMutableArray *children = [self.children mutableCopy];
    [children removeObject:child];
    _children = [children copy];
}


@end
