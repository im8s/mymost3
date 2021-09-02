package com.shiku.im.admin.service;

import com.shiku.common.model.PageResult;
import com.shiku.im.company.entity.Company;
import com.shiku.im.company.entity.Department;
import com.shiku.im.company.entity.Employee;
import org.bson.types.ObjectId;

import java.util.List;

/**
 * 
 * @Date Created in 2019/11/22 14:12
 * @description TODO (web后台我的同事逻辑层)
 * @modified By:
 */
public interface ColleagueManager {

    //公司列表
    public PageResult<Company> companyList(int pageSize, int pageIndex);

    //公司部门列表
    public List<Department> departmentList(String companyId);

    //查询公司全部部门
    public Employee findEmployeeMsg(ObjectId id);

    //查询公司全部部门
    public List<Department> departmentAllList(ObjectId companyId);

    //根据公司编号 查询公司部门id
    public Department queryDepartmentId(ObjectId companyId);

    //web后台修改部门
    public Department webModifyDepartmentInfo(Department department,String oldDepartmentName);

    //关键字查询公司
    public PageResult<Company> findCompanyByKeyworldLimit(String keyworld, int page, int limit);

    //添加员工(支持多个)
    public ObjectId webAddEmployee(ObjectId companyId, ObjectId departmentId,int  userId);

    //删除部门
    public void deleteDepartment(ObjectId departmentId);

    //创建部门
    public Department createDepartment(ObjectId companyId, ObjectId parentId, String departName, int createUserId);

    public Employee modifyEmpInfo(Employee employee);

    //获取员工详情
    public Employee getEmployee(ObjectId employeeId);

    //删除员工
    public void deleteEmployee(List<Integer> userIds, ObjectId departmentId);

    //查询上级个数
    public int getRetractNumber(ObjectId id);

    //创建公司
    public Company createCompany(String companyName, int createUserId);

    //部门列表
    public List<Department> departmentList(ObjectId companyId);

    //删除公司(即隐藏公司,不真正删除)
    public void deleteCompany(ObjectId companyId, int userId);
}
