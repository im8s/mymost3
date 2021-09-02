//
//  EmployeObject.h
//  shiku_im
//
//  Created by 1 on 17/5/11.
//  Copyright © 2017年 Reese. All rights reserved.
//

@interface EmployeObject : NSObject


/** 公司Id */
@property (copy, nonatomic) NSString * companyId;

/** 部门Id */
@property (copy, nonatomic) NSString * departmentId;

/** 员工Id */
@property (copy, nonatomic) NSString * employeeId;

/** 角色类型 */
@property (assign, nonatomic) NSInteger role;

/** userId */
@property (copy, nonatomic) NSString * userId;

/** 员工名 */
@property (copy, nonatomic) NSString * nickName;


/** 员工职位 */
@property (copy, nonatomic) NSString * position;

              //                          {"companyId":"593f44d0cfb99718102efb92","departmentId":"593f44d0cfb99718102efb94","id":"593f44d0cfb99718102efb96","nickname":"acup","position":"员工","role":3,"userId":10007882}

+(instancetype)employWithDict:(NSDictionary *)dataDict;

@end
