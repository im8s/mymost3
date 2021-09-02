package com.shiku.im.admin.service.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.admin.service.ColleagueManager;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.company.CompanyConstants;
import com.shiku.im.company.dao.CompanyDao;
import com.shiku.im.company.dao.DepartmentDao;
import com.shiku.im.company.dao.EmployeeDao;
import com.shiku.im.company.entity.Company;
import com.shiku.im.company.entity.Department;
import com.shiku.im.company.entity.Employee;
import com.shiku.im.company.service.impl.CompanyManagerImpl;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.utils.DateUtil;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * 
 * @description TODO （web后台我的同事操作逻辑层实现类）
 * @Date Created in 2019/11/22 14:12
 */
@Service
public class ColleagueManagerImpl implements ColleagueManager {

    public int num = 0;

    @Autowired
    private CompanyManagerImpl companyManager;

    @Autowired
    private UserCoreService userCoreService;



    @Autowired
    private DepartmentDao departmentDao;
    public DepartmentDao getDepartmentDao(){
        return departmentDao;
    }

    @Autowired
    private CompanyDao companyDao;
    public CompanyDao getCompanyDao(){
        return companyDao;
    }

    @Autowired
    private EmployeeDao employeeDao;
    public EmployeeDao getEmployeeDao(){
        return employeeDao;
    }



    /**
     * 
     * @date 2019/11/22 14:25
     *      公司列表
     */
    @Override
    public PageResult<Company> companyList(int pageSize, int pageIndex) {
        return getCompanyDao().companyList(pageSize, pageIndex);
    }


    /**
     * 
     * @date 2019/9/23 16:17
     * 	公司部门列表
     */
    @Override
    public List<Department> departmentList(String companyId){
        List<Department> departments = getDepartmentDao().departmentList(new ObjectId(companyId)); //查找出该公司所有的部门数据
        for(Iterator<Department> iter = departments.iterator(); iter.hasNext(); ){
            Department department = iter.next();
            //查找该部门中的员工,并封装到department中
            List<Employee> employees = employeeDao.departEmployeeList(department.getId());
            setUserNickname(employees); //将用户昵称封装到员工数据
            department.setEmployees(employees); //将员工数据封装进部门中
        }
        return departments;
    }

    /**
     * 
     * @date 2019/9/26 11:23
     * 		根据员工编号查询员信息
     */
    @Override
    public Employee findEmployeeMsg(ObjectId id) {

        return employeeDao.findById(id);
    }

    /**
     * 
     * @date 2019/9/26 12:24
     * 	查询公司全部部门
     */
    @Override
    public List<Department> departmentAllList(ObjectId companyId) {
        return departmentDao.departmentAllList(companyId);
    }

    //添加员工(支持多个)
    @Override
    public ObjectId webAddEmployee(ObjectId companyId, ObjectId departmentId,int  userId) {
        List<Integer> list = new ArrayList<>();

        //判断是否能够添加
        List<Employee> compEmps = getEmployeeDao().compEmployeeList(companyId); //得到公司的所有员工
        for(Iterator<Employee> iter = compEmps.iterator(); iter.hasNext(); ){
            Employee emp = iter.next();
            list.add(emp.getUserId());
        }


        for (Integer id : list) {
            if (id == userId){
                return null;
            }
        }

        Employee emp = new Employee();
        emp.setDepartmentId(departmentId);
        emp.setCompanyId(companyId);
        emp.setRole(CompanyConstants.ROLE.COMMON_EMPLOYEE);
        emp.setUserId(userId);
        //将用户昵称封装到员工数据
        User user = userCoreService.getUser(userId);
        String nickname =null!=user?user.getNickname():"";
        emp.setNickname(nickname);

        //正常添加员工
        ObjectId objectId = getEmployeeDao().addEmployee(emp);//存入员工记录

        //修改公司记录里的员工数目
        Company company = getCompanyDao().findById(companyId);
        company.setEmpNum(company.getEmpNum()+1);
        getCompanyDao().modifyCompany(company);

        //修改部门记录里的员工数目
        Department department = getDepartmentDao().findById(departmentId);
        department.setEmpNum(department.getEmpNum()+1);
        getDepartmentDao().modifyDepartment(department);

        return objectId;
    }

    /**
     * 
     * @date 2019/10/8 9:40
     *  根据公司编号 查询公司部门id
     */
    @Override
    public Department queryDepartmentId(ObjectId companyId) {
        return departmentDao.queryDepartmentId(companyId);
    }

    /**
     * 
     * @date 2019/10/8 10:02
     * 		   web后台修改部门
     */
    @Override
    public Department webModifyDepartmentInfo(Department department,String oldDepartmentName) {
        if(department.getDepartName() != null && ! "".equals(department.getDepartName()) ){
            ObjectId companyId = getDepartmentDao().getCompanyId(department.getId()); //通过部门id得到公司id
            int departType = getDepartmentDao().findById(department.getId()).getType();
			/*if( departType == 1 || departType == 4 || departType == 5 ){ //判断是否为特殊部门    1:表示根部门  4:演示数数据中的普通部门  5: 演示数据中的让用户加入的部门
				throw new ServiceException(KConstants.ResultCode.NO_PERMISSION);
			}*/

            if (!department.getDepartName().equals(oldDepartmentName+"部")){
                if(getDepartmentDao().findOneByName(companyId, department.getDepartName()) != null)  //判断名称是否重复
                    throw new ServiceException(CompanyConstants.ResultCode.DeptNameRepeat);
            }
        }
        Department depart = getDepartmentDao().modifyDepartment(department);
        return depart;
    }



    /**
     * 
     * @date 2019/11/22 14:26
     *      关键字查询公司
     */
    @Override
    public PageResult<Company> findCompanyByKeyworldLimit(String keyworld, int page, int limit) {
        PageResult<Company> companyByNameLimit = getCompanyDao().findCompanyByNameLimit(keyworld, page, limit);
        return companyByNameLimit;
    }

    //此方法用于获取user表中的用户昵称，并封装进员工数据中
    public void setUserNickname(List<Employee> employees){
        for(Iterator<Employee> iter = employees.iterator();iter.hasNext();){  //遍历员工数据
            Employee employee = iter.next();
            User user = userCoreService.getUser(employee.getUserId());
            String nickname =null!=user?user.getNickname():"";
            employee.setNickname(nickname);
        }
    }

    //删除部门
    @Override
    public void deleteDepartment(ObjectId departmentId) {
        //做相关的判断，特殊部门不能删除
        int departType = getDepartmentDao().findById(departmentId).getType();
        if(departType == 1 || departType == 4 || departType == 5){ //1:  根部门    4:演示数数据中的普通部门  5: 演示数据中的让用户加入的部门
            throw new ServiceException(CompanyConstants.ResultCode.DeptNotDelete);
        }
        if(getEmployeeDao().existsEmployee(departmentId)){
            throw new ServiceException(KConstants.ResultCode.HaveDataCanNotDelete);
        }else if(getDepartmentDao().findChildDepartmeny(departmentId).size()>0){
            throw new ServiceException(KConstants.ResultCode.HaveDataCanNotDelete);
        }
        //首先删除该部门的员工记录
        getEmployeeDao().delEmpByDeptId(departmentId);

        getDepartmentDao().deleteDepartment(departmentId); //删除部门记录
    }

    //创建部门
    @Override
    public Department createDepartment(ObjectId companyId, ObjectId parentId, String departName, int createUserId) {
        //检查部门名称是否重复
        if(getDepartmentDao().findOneByName(companyId, departName) != null)
            throw new ServiceException(CompanyConstants.ResultCode.DeptNameRepeat);
        Department department = new Department();
        department.setCompanyId(companyId);

        if (companyId.equals(parentId)){
            Department dep = queryDepartmentId(companyId);
            department.setParentId(dep.getId());
        }else{
            department.setParentId(parentId);
        }
        department.setEmpNum(0);
        department.setDepartName(departName);
        department.setCreateUserId(createUserId);
        department.setCreateTime(DateUtil.currentTimeSeconds());
        ObjectId departmentId = getDepartmentDao().addDepartment(department);

        return getDepartmentDao().findDepartmentById(departmentId);
    }

    @Override
    public Employee modifyEmpInfo(Employee employee) {
        //Employee oldemp =getEmployeeDao().findById(employee.getId());
        Employee emp = getEmployeeDao().modifyEmployees(employee);

        String nickname = userCoreService.getUser(emp.getUserId()).getNickname();
        emp.setNickname(nickname);
        return emp;
    }

    //获取员工详情
    @Override
    public Employee getEmployee(ObjectId employeeId) {
        Employee emp =  getEmployeeDao().findById(employeeId);
        String nickname = userCoreService.getUser(emp.getUserId()).getNickname();
        emp.setNickname(nickname);
        return emp;
    }

    //删除员工
    @Override
    public void deleteEmployee(List<Integer> userIds, ObjectId departmentId) {
        //修改部门记录里的员工数目    -1
        Department department = getDepartmentDao().findById(departmentId);
        userIds.forEach(delUserId ->{
            if(delUserId.equals(department.getCreateUserId()))
                // 公司创建者不能被删除
                throw new ServiceException(KConstants.ResultCode.NO_PERMISSION);
        });
        getEmployeeDao().deleteEmployee(userIds, departmentId); //删除员工记录
        department.setEmpNum(department.getEmpNum()-1);
        getDepartmentDao().modifyDepartment(department);

        //修改公司记录里的员工数目
        Company company = getCompanyDao().findById(department.getCompanyId());
        company.setEmpNum(company.getEmpNum()-1);
        getCompanyDao().modifyCompany(company);
    }


    @Override
    public int getRetractNumber(ObjectId id){
        Department department = departmentDao.findDepartmentById(id);
        if (department != null){
            if (department.getParentId() != null){
                ++num;
                getRetractNumber(department.getParentId());
            }
        }

        return num;
    }

    /**
     * 创建公司 （添加演示数据版）
     */
    @Override
    public Company createCompany(String companyName, int createUserId) {

        //检查该用户是否创建过公司
		/*if(null != getCompanyRepository().findCompanyByCreaterUserId(createUserId)){
			throw new ServiceException("已创建过公司");
		}*/

        //检查是否有重名的公司
        if(null != companyDao.findOneByName(companyName)){
            throw new ServiceException(CompanyConstants.ResultCode.CompanyNameAlreadyExists);
        }

        ObjectId rootDpartId = new ObjectId();
        //添加公司记录
        Company company =  companyDao.addCompany(companyName, createUserId, rootDpartId);

        //给该公司默认添加一条根部门记录
        Department department = new Department();
        department.setCompanyId(company.getId());
        department.setParentId(null);  //根部门的ParentId 为null
        department.setDepartName(companyName);
        department.setCreateUserId(createUserId); //根部门的创建者即公司的创建者
        department.setCreateTime(DateUtil.currentTimeSeconds());
        department.setEmpNum(0);
        department.setType(1);  //1:根部门

        rootDpartId = departmentDao.addDepartment(department); //添加根部门记录
        List<ObjectId> rootList = new ArrayList<ObjectId>();
        rootList.add(rootDpartId);

        //给该公司创建两个部门(人事部,财务部)
        Department personDepart = new Department();
        personDepart.setCompanyId(company.getId());
        personDepart.setParentId(rootDpartId);  //ParentId 为根部门的id
        personDepart.setDepartName("人事部");
        personDepart.setCreateUserId(createUserId); //创建者即公司的创建者
        personDepart.setCreateTime(DateUtil.currentTimeSeconds());
        personDepart.setEmpNum(1);
        ObjectId personDepartId = departmentDao.addDepartment(personDepart); //添加部门记录

        Department financeDepart = new Department();
        financeDepart.setCompanyId(company.getId());
        financeDepart.setParentId(rootDpartId);  //ParentId 为根部门的id
        financeDepart.setDepartName("财务部");
        financeDepart.setCreateUserId(createUserId); //创建者即公司的创建者
        financeDepart.setCreateTime(DateUtil.currentTimeSeconds());
        financeDepart.setEmpNum(0);
        departmentDao.addDepartment(financeDepart); //添加部门记录

        //客服部
        Department Customer = new Department();
        Customer.setCompanyId(company.getId());
        Customer.setParentId(rootDpartId);  //ParentId 为根部门的id
        Customer.setDepartName("客服部");
        Customer.setCreateUserId(createUserId); //创建者即公司的创建者
        Customer.setCreateTime(DateUtil.currentTimeSeconds());
        Customer.setEmpNum(0);
        Customer.setType(6);
        departmentDao.addDepartment(Customer); //添加部门记录

        //给创建者添加员工记录，将其置于人事部门中
        Employee employee = new Employee();
        employee.setDepartmentId(personDepartId);
        employee.setRole(CompanyConstants.ROLE.COMPANY_CREATER);   //3：公司创建者(超管)
        employee.setUserId(createUserId);
        employee.setCompanyId(company.getId());
        employee.setPosition("创建者");
        employeeDao.addEmployee(employee);

        company.setRootDpartId(rootList);
        company.setCreateTime(DateUtil.currentTimeSeconds());
        //将根部门id存入公司记录
        companyDao.modifyCompany(company);


        return company;
    }


    //部门列表（包括员工数据）
    @Override
    public List<Department> departmentList(ObjectId companyId) {
        List<Department> departments = departmentDao.departmentList(companyId); //查找出该公司所有的部门数据
        for(Iterator<Department> iter = departments.iterator();iter.hasNext(); ){
            Department department = iter.next();
            //查找该部门中的员工,并封装到department中
            List<Employee> employees = employeeDao.departEmployeeList(department.getId());
            setUserNickname(employees); //将用户昵称封装到员工数据
            department.setEmployees(employees); //将员工数据封装进部门中
        }
        return departments;
    }

    //删除公司(即隐藏公司,不真正删除)
    @Override
    public void deleteCompany(ObjectId companyId, int userId) {
        //只有公司创建者才能执行删除操作
        Company company = companyDao.findById(companyId);
        if(company.getCreateUserId() != userId){ //判断是否为创建者userId
            throw new ServiceException(KConstants.ResultCode.NO_PERMISSION);
        }
        if(0!=company.getDeleteUserId()) {
            throw new ServiceException(CompanyConstants.ResultCode.CompanyNotExists);
        }
        company.setDeleteUserId(userId);
        company.setDeleteTime(DateUtil.currentTimeSeconds());
        companyDao.modifyCompany(company);
    }

}