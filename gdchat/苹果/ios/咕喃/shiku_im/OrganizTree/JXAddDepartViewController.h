//
//  JXAddDepartViewController.h
//  shiku_im
//
//  Created by 1 on 17/5/16.
//  Copyright © 2017年 Reese. All rights reserved.
//


#import "admobViewController.h"
//@class DepartObject;

typedef enum {
    OrganizAddCompany = 1,//创建公司名
    OrganizAddDepartment = 2,//创建部门名
    OrganizUpdateDepartmentName = 3,//修改部门名
    OrganizSearchCompany = 4,//搜索公司
    OrganizUpdateCompanyName = 5,//修改公司名
    OrganizModifyEmployeePosition = 6,//修改员工职位
} OrganizAddType;

@protocol AddDepartDelegate <NSObject>
//-(void)addDepartDelegate:(NSString *)departName;
//-(void)addCompanyDelegate:(NSString *)companyName;
//-(void)updateDepartmentNameDelegate:(NSString *)departNewName;

-(void)inputDelegateType:(OrganizAddType)organizType text:(NSString *)updateStr;

@end

@interface JXAddDepartViewController : admobViewController

@property (weak,nonatomic) id <AddDepartDelegate> delegate;
@property (assign,nonatomic) OrganizAddType type;
@property (copy,nonatomic) NSString * oldName;

@end
