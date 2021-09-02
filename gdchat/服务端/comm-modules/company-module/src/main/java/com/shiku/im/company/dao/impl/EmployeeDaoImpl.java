package com.shiku.im.company.dao.impl;

import com.shiku.im.comm.utils.NumberUtil;
import com.shiku.im.company.CompanyConstants;
import com.shiku.im.company.dao.EmployeeDao;
import com.shiku.im.company.entity.Employee;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.mongodb.springdata.BaseMongoRepository;
import com.shiku.utils.StringUtil;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.FindAndModifyOptions;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

@Repository
public class EmployeeDaoImpl extends BaseMongoRepository<Employee,ObjectId> implements EmployeeDao {


    @Autowired
    private UserCoreService userCoreService;

    @Override
    public Class<Employee> getEntityClass() {
        return Employee.class;
    }
    //添加员工（单个）
    @Override
    public ObjectId addEmployee(Employee employee) {

        employee.setId(new ObjectId());
        getDatastore().save(employee);
        return employee.getId();
    }

    //添加员工（多个）
    @Override
    public List<Employee> addEmployees(List<Integer> userId, ObjectId companyId, ObjectId departmentId) {


        for(Iterator<Integer> iter = userId.iterator(); iter.hasNext();){
            Integer uId = iter.next();
            Employee emp = new Employee();
            emp.setDepartmentId(departmentId);
            emp.setCompanyId(companyId);
            emp.setRole(CompanyConstants.ROLE.COMMON_EMPLOYEE);
            emp.setUserId(uId);
            getDatastore().save(emp);//存入员工数据
        }
        //将整个部门的员工数据封装返回
        Query query = createQuery("departmentId",departmentId);

        return queryListsByQuery(query);
    }


    //修改员工信息
    @Override
    public Employee modifyEmployees(Employee employee) {
        int userId = employee.getUserId();
        ObjectId companyId = employee.getCompanyId();

        if(userId == 0 || companyId == null){
            return null;
        }
        Query query = createQuery("userId",userId);
        addToQuery(query,"companyId",companyId);
        Update ops = createUpdate();
        //是否客服
        ops.set("isCustomer",employee.getIsCustomer());
        if(null != employee.getDepartmentId())
            ops.set("departmentId", employee.getDepartmentId());
        if(0 <= employee.getRole() && employee.getRole() <= 3)
            ops.set("role", employee.getRole());
        if(null != employee.getPosition() && employee.getPosition() != "")
            ops.set("position", employee.getPosition());
        //当前回话人数
        if (0<= employee.getChatNum() && employee.getChatNum() <= 5) {
            ops.set("chatNum", employee.getChatNum());
        }
        //会话状态（是否暂停，开启）
        if(!StringUtil.isEmpty(String.valueOf(employee.getIsPause()))){
            ops.set("isPause",employee.getIsPause());
        }
        return getDatastore().findAndModify(query, ops,new FindAndModifyOptions().returnNew(true), getEntityClass());
    }


    //通过userId查找员工
    @Override
    public List<Employee> findByUserId(int userId){
        Query query = createQuery("userId",userId);
        return queryListsByQuery(query);

    }



    //查找公司中某个角色的所有员工
    @Override
    public List<Employee> findByRole(ObjectId companyId, int role) {

        Query query =createQuery("companyId",companyId);
        addToQuery(query,"role",role);
        return queryListsByQuery(query);
    }



    //删除整个部门的员工
    @Override
    public void delEmpByDeptId(ObjectId departmentId) {
        //根据部门id找到员工
        Query query =createQuery("departmentId",departmentId);
        deleteByQuery(query);
    }

    // 删除整个公司员工
    @Override
    public void deleteAllEmployee(ObjectId companyId) {
        Query query = createQuery("companyId",companyId);
        deleteByQuery(query);
    }

    //删除员工
    @Override
    public void deleteEmployee(List<Integer> userIds, ObjectId departmentId) {
        Query query =createQuery("departmentId",departmentId);
        query.addCriteria(Criteria.where("userId").in(userIds));
        deleteByQuery(query);
    }

    @Override
    public void delEmpByUserId(Integer userId) {
        Query query = createQuery("userId",userId);
       deleteByQuery(query);
    }

    //根据公司ID查询员工(员工列表)
    @Override
    public List<Employee> compEmployeeList(ObjectId companyId) {
        Query query = createQuery("companyId",companyId);
        return queryListsByQuery(query);
    }
    @Override
    public boolean existsEmployee(ObjectId departmentId){
        Query query =createQuery("departmentId",departmentId);
        return exists(query);
    }


    //根据部门ID查询员工(部门员工列表)
    @Override
    public List<Employee> departEmployeeList(ObjectId departmentId) {
        Query query =createQuery("departmentId",departmentId);
        return queryListsByQuery(query);
    }

    //根据id查找员工
    @Override
    public Employee findById(ObjectId employeeId) {
       return get(employeeId);
    }


    //查找某个员工的角色，通过公司id
    @Override
    public byte findRole(ObjectId companyId, int userId) {
       /* Query query = createQuery("companyId",companyId);
        addToQuery(query,"userId", userId);*/
        Document query=new Document("companyId",companyId).append("userId", userId);
        Object role = queryOneField("role",query);
        if(role!=null && NumberUtil.isNumeric(role.toString())) {
            return ((Integer)role).byteValue();
        }
        return -1;
    }


    //查找某个员工的角色
    @Override
    public byte findRoleByDepartmentId(ObjectId companyId, int userId) {

        if(companyId!=null) {
            return findRole(companyId,userId);
        }
        return -1;
    }

    //删除员工(根据公司id）
    @Override
    public void delEmpByCompId(ObjectId companyId, int userId) {
        Query query = createQuery("companyId",companyId);
        addToQuery(query,"userId", userId);
       deleteByQuery(query);
    }

    /**
     * 根据用户id来修改员工信息
     */
    @Override
    public Employee modifyEmployeesByuserId(int userId) {
        Employee employeeInfo = new Employee();
        if (!StringUtil.isEmpty(String.valueOf(userId))) {
            // 根据用户id来查询员工信息
            Query query =createQuery("userId", userId);
            // 修改

            // 赋值
            List<Employee> employeeList =queryListsByQuery(query);
            for (Employee employee2 : employeeList) {
                if (null != employee2 && !"".equals(employee2)) {
                    Update uo =createUpdate();
                    // 会话人数
                    if (!StringUtil.isEmpty(String.valueOf(employee2.getChatNum()))) {
                        uo.set("chatNum", 0);
                    }
                    // 会话状态
                    if (!StringUtil.isEmpty(String.valueOf(employee2.getIsPause()))) {
                        uo.set("isPause", 0);
                    }
                    // employeeInfo = getDatastore().findAndModify(query,uo);
                    update(createQuery("_id",employee2.getId()),uo);
                }

            }
        }
        return employeeInfo;
    }

    /**
     * 查询员工是否为客服
     */
    @Override
    public Employee findEmployee(Employee employee, User.UserSettings userSettings) {
        Query query =createQuery("userId", employee.getUserId());
        addToQuery(query,"departmentId",employee.getDepartmentId());
        addToQuery(query,"companyId",employee.getCompanyId());
        return findOne(query);
    }

    /**
     *根据公司，部门，用户id来查询出员工信息
     */
    @Override
    public Employee findEmployee(Employee employee) {
        Query query =createQuery("userId", employee.getUserId());
		if(null!=employee.getDepartmentId()){
            addToQuery(query,"departmentId",employee.getDepartmentId());
		}
		if(null!=employee.getCompanyId()){
            addToQuery(query,"companyId",employee.getCompanyId());
		}

        return findOne(query);
    }
    @Override
    public Employee getEmployeeByUserId(ObjectId companyId, int userId) {
        Query query =createQuery("companyId", companyId);
        addToQuery(query,"userId",userId);
        return findOne(query);
    }

    @Override
    public Map<Integer, Integer> findWaiter(ObjectId companyId, ObjectId departmentId) {
        Map<Integer,Integer> map = new HashMap<Integer,Integer>();
        Query query =createQuery("companyId", companyId);
        addToQuery(query,"departmentId",departmentId);
        addToQuery(query,"isPause",1);

        List<Employee> emps= queryListsByQuery(query);

        for(Iterator<Employee> iter = emps.iterator(); iter.hasNext(); ){
            Employee emp = iter.next();
            map.put(emp.getUserId(), emp.getChatNum());
        }
        return map;
    }

    /**
     * 
     * @date 2019/9/23 17:30
     *  查询员工列表  分页
     */
    @Override
    public List<Employee> compEmployeeList(ObjectId companyId, int pageSize, int pageIndex) {
        Query query =createQuery("companyId",companyId);
        List<Employee> employee = queryListsByQuery(query,pageIndex,pageSize);
        employee.forEach(emp->{
            User user = userCoreService.getUser(emp.getUserId());
            //emp.setNickname(user.getNickname());
        });
        return employee;
    }

    /**
     * 
     * @date 2019/9/24 18:44
     *      根据部门编号查询员工
     */
    public List<Employee> employeeList(ObjectId departmentId) {
        Query query =createQuery("departmentId",departmentId);
        return queryListsByQuery(query);
    }

}
