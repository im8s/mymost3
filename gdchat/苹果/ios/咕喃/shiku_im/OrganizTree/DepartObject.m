//
//  DepartObject.m
//  shiku_im
//
//  Created by 1 on 17/5/11.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "DepartObject.h"
#import "EmployeObject.h"

@interface DepartObject()
{
    NSMutableArray * _allDict;
}

@end

@implementation DepartObject

-(instancetype)initDepart:(NSDictionary *)nodeDict  allData:(NSMutableArray *)allDict{
    self = [super init];
    if (self) {
        
        if (nodeDict[@"departName"] != nil)
            self.departName = nodeDict[@"departName"];
        if (nodeDict[@"id"] != nil)
            self.departId = nodeDict[@"id"];
        if (nodeDict[@"companyId"] != nil)
            self.companyId = nodeDict[@"companyId"];
        if (nodeDict[@"createUserId"] != nil)
            self.createUserId = [NSString stringWithFormat:@"%@",nodeDict[@"createUserId"]];
        if (nodeDict[@"empNum"] != nil)
            self.empNum = [nodeDict[@"empNum"] integerValue];
        if (nodeDict[@"employees"] != nil)
            self.employees = nodeDict[@"employees"];
        if (nodeDict[@"parentId"] != nil) {
            self.parentId = nodeDict[@"parentId"];
        }

        if (nodeDict[@"noticeContent"] != nil)
            self.noticeContent = nodeDict[@"noticeContent"];

        if (allDict) {
            _allDict = allDict;
            NSMutableArray * departArr = [[NSMutableArray alloc] init];
            for (NSDictionary * data in allDict) {
//                NSDictionary * data = [allDict objectForKey:key];
                if (data[@"parentId"] != nil && [data[@"parentId"] isEqualToString:self.departId]) {
                    [departArr addObject:data];
                }
            }
            if (departArr.count > 0) {
                self.departes = departArr;
            }else{
                self.departes = [NSArray array];
            }
            NSMutableArray * childArr = [NSMutableArray array];
            if (self.employees.count > 0) {
                [childArr addObjectsFromArray:self.employees];
            }
            if (self.departes.count > 0) {
                [childArr addObjectsFromArray:self.departes];
            }
            if (childArr.count > 0) {
                self.children = childArr;
            }
        }
        
        if (!_children)
            _children = [NSArray array];
        if (!_employees)
            _employees = [NSArray array];
        if (!_departes)
            _departes = [NSArray array];
        
        _allDict = nil;
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
    }
    return self;
}

-(void)setDepartes:(NSArray *)departes{
    if (departes != nil && departes.count > 0) {
        if ([departes[0] isKindOfClass:[DepartObject class]]) {
            _departes = departes;
            NSMutableArray * childArr = [NSMutableArray array];
            [childArr addObjectsFromArray:_departes];
            [childArr addObjectsFromArray:_employees];
            _children = childArr;
            return;
        }
        NSMutableArray *childArray = [NSMutableArray array];
        for (NSDictionary * childDict in departes) {
            DepartObject * departObj = [DepartObject departmentObjectWith:childDict allData:_allDict];
            [childArray addObject:departObj];
        }
        _departes = [NSArray arrayWithArray:childArray];
    }else{
        _departes = [NSArray array];
    }
}

/** 创建员工节点 */
-(void)setEmployees:(NSArray *)employees{
    if (employees != nil && employees.count > 0) {
        if ([employees[0] isKindOfClass:[EmployeObject class]]) {
            _employees = employees;
            _empNum = _employees.count;
            NSMutableArray * childArr = [NSMutableArray array];
            [childArr addObjectsFromArray:_departes];
            [childArr addObjectsFromArray:_employees];
            _children = childArr;
            return;
        }
        
        NSMutableArray *childArray = [NSMutableArray array];
        for (NSDictionary * childDict in employees) {
            EmployeObject * employeObj = [EmployeObject employWithDict:childDict];
            [childArray addObject:employeObj];
        }
        _employees = [NSArray arrayWithArray:childArray];
    }else{
        _employees = [NSArray array];
    }
    
}

-(void)setChildren:(NSArray *)children{
    if ([children[0] isKindOfClass:[DepartObject class]] || [children[0] isKindOfClass:[EmployeObject class]]) {
        _children = children;
        return;
    }
//    NSMutableArray *childArray = [NSMutableArray array];
//    for (NSDictionary * childDict in children) {
//        if (!childDict[@"userId"]) {
////            EmployeObject * employ = [EmployeObject employ:childDict];
////            [childArray addObject:];
//        }else if () {
////            DepartObject * depart = [DepartObject de];
////            [childArray addObject:organiz];
//        }
//        
//    }
//    _children = [NSArray arrayWithArray:childArray];
}

- (void)addChild:(id)child
{
    NSMutableArray *children = [self.children mutableCopy];
    if ([child isMemberOfClass:[DepartObject class]]) {
        NSMutableArray *departs = [self.departes mutableCopy];
//        [departs insertObject:child atIndex:0];
        [departs addObject:child];
        _departes = [departs copy];
//        [children insertObject:child atIndex:0];
        [children addObject:child];
    }else if ([child isMemberOfClass:[EmployeObject class]]) {
        NSMutableArray *employee = [self.employees mutableCopy];
//        [employee insertObject:child atIndex:0];
        [employee addObject:child];
        _employees = [employee copy];
        
//        NSUInteger insert = _departes.count ? (_departes.count -1) : 0;
        
//        [children insertObject:child atIndex:(insert)];
//        [children addObject:child];
        NSInteger num = 0;
        BOOL ishave = NO;
        for (NSInteger i = 0; i < children.count; i ++) {
            if ([children[i] isKindOfClass:[DepartObject class]]) {
                num = i;
                ishave = YES;
                break;
            }
        }
        if (ishave) {
            [children insertObject:child atIndex:num];
        }else{
            [children addObject:child];
        }
        
        _empNum = _employees.count;
    }
    
    _children = [children copy];
}

- (void)removeChild:(id)child
{
    if ([child isMemberOfClass:[DepartObject class]]) {
        NSMutableArray *departs = [self.departes mutableCopy];
        [departs removeObject:child];
        _departes = [departs copy];
    }else if ([child isMemberOfClass:[EmployeObject class]]) {
        NSMutableArray *employee = [self.children mutableCopy];
        [employee removeObject:child];
        _employees = [employee copy];
        
        _empNum = _employees.count;
    }
    
    NSMutableArray *children = [self.children mutableCopy];
    [children removeObject:child];
    _children = [children copy];
}


/** 创建部门节点 */
+(instancetype)departmentObjectWith:(NSDictionary *)nodeDict allData:(NSMutableArray *)allDict{
    return [[self alloc] initDepart:nodeDict allData:allDict];
}

@end
