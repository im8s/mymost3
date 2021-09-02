package com.shiku.im.company;

public interface CompanyConstants {


    //公司相关常量
    public interface ROLE{
        static final byte COMPANY_CREATER = 3;  //公司创建者
        static final byte COMPANY_MANAGER = 2;  //公司管理员
        static final byte DEPARTMENT_MANNAGER = 1; //部门管理者
        static final byte COMMON_EMPLOYEE = 0; //普通员工
    }


    public interface ResultCode{
        /**
         * 公司组织架构相关
         * 1006**
         *
         */
        //CompanyController 创建失败
        static final int createCompanyFailure = 100601;
        // 公司名称已存在
        static final int CompanyNameAlreadyExists = 100602;
        // 公司不存在
        static final int CompanyNotExists = 100603;
        // 部门名称重复
        static final int DeptNameRepeat = 100604;
        // 该用户不属于客服部门
        static final int UserNotBelongCustomer = 100605;
        // 该部门不能删除
        static final int DeptNotDelete = 100606;
        // 会话人数过多请稍后重试
        static final int ManyConversation = 100607;
        //缺少公司Id或部门Id，请在管理后台设置
        static final int NoCompanyIdOrDepartmentId = 100608;


        // 修改失败
        static final int UpdateFailure = 100702;

    }

}
