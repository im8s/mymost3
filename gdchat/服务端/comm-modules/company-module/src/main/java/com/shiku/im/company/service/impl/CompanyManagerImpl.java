package com.shiku.im.company.service.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.company.CompanyConstants;
import com.shiku.im.company.CompanyConstants.ROLE;
import com.shiku.im.company.CompanyConstants.ResultCode;
import com.shiku.im.company.dao.CompanyDao;
import com.shiku.im.company.dao.DepartmentDao;
import com.shiku.im.company.dao.EmployeeDao;
import com.shiku.im.company.entity.Company;
import com.shiku.im.company.entity.Department;
import com.shiku.im.company.entity.Employee;
import com.shiku.im.company.service.CompanyManager;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Random;

@Service
public class CompanyManagerImpl implements CompanyManager {



	

	@Lazy
	@Autowired(required = false)
	private CompanyDao companyDao;

	@Lazy
	@Autowired(required = false)
	private DepartmentDao departmentDao;

	@Lazy
	@Autowired(required = false)
	private EmployeeDao employeeDao;
	

	@Autowired(required = false)
	private UserCoreService userCoreService;

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
			throw new ServiceException(ResultCode.CompanyNameAlreadyExists);
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

	@Override
	// 清除被删除用户相关组织架构数据
	public void delCompany(Integer userId){
		try {
			// 删除对应创建的公司数据
			List<Company> companyList = companyDao.findCompanyListByCreateUserId(userId);
			for(Company company : companyList){
				companyDao.deleteComplay(company);
				// 对应的部门、员工数据
				departmentDao.deleteAllDepartment(company.getId());
				employeeDao.deleteAllEmployee(company.getId());
			}
			// 退出对应部门 删除员工数据
//			Query<Employee> employeeQuery = getDatastore().createQuery(Employee.class).field("userId").equal(userId);
//			List<Employee> employees = employeeQuery.asList();
			List<Employee> employees = employeeDao.findByUserId(userId);
			for(Employee employee : employees){
				// 维护对应部门人数
				Department department = departmentDao.findById(employee.getDepartmentId());
				Department departmentEntity = new Department();
				departmentEntity.setEmpNum(department.getEmpNum()-1);
				departmentDao.modifyDepartment(departmentEntity);

				// 维护公司员工人数
				Company company = companyDao.findById(employee.getCompanyId());
				Company companyEntity = new Company();
				companyEntity.setEmpNum(company.getEmpNum()-1);
				companyDao.modifyCompany(companyEntity);
			}
			employeeDao.delEmpByUserId(userId);
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	//根据userId 反向查找公司
	@Override
	public List<Company> findCompanyByUserId(int userId) {
		//首先查找员工相关记录
		List<Employee> employees = employeeDao.findByUserId(userId);
		if (employees == null){
			return null;
		}
			
		List<Company> companys = new ArrayList<Company>(); //用于存放公司的集合
		//遍历员工记录
		for(Iterator<Employee> iter = employees.iterator(); iter.hasNext();){
			Employee emp = iter.next();
			ObjectId companyId = emp.getCompanyId();
			Company comp = companyDao.findById(companyId);
			if(null==comp)
				continue;
			if(comp.getDeleteUserId() == 0){  //排除掉 执行删除操作，从而被隐藏起来的公司
				companys.add(comp);
			}
		}
		//判断是否存在公司数据
		
		return companys;
		
	}
	
	
	
	/**
	 * 根据id查找公司
	 */
	@Override
	public Company getCompany(ObjectId companyId){
		return companyDao.findById(companyId);
	}
	
	
	/**
	 * 设置管理员
	 * managerId:管理员userId
	 */
	@Override
	public void setManager(ObjectId companyId, List<Integer> managerId) {
		Employee employee = new Employee();
		for(Iterator<Integer> iter = managerId.iterator();iter.hasNext(); ){
			int userId = iter.next();
			
			employee.setUserId(userId);
			employee.setCompanyId(companyId);
			employee.setRole(CompanyConstants.ROLE.COMPANY_MANAGER); //2:公司管理者
			employeeDao.modifyEmployees(employee);
		}
		
	}
	
	
	//管理员列表
	@Override
	public List<Employee> managerList(ObjectId companyId) {
		int role = 2; //2:公司管理员
		List<Employee> list = employeeDao.findByRole(companyId, role);
		return list;
	}
	
	
	//修改公司信息
	@Override
	public Company modifyCompanyInfo(Company company) {
		//修改公司名称的同时.修改根部门名称
		if(company.getCompanyName() != null && !"".equals(company.getCompanyName()) ){
			//判断公司名称是否重复
			if(companyDao.findOneByName(company.getCompanyName()) != null)
				throw new ServiceException(ResultCode.CompanyNameAlreadyExists);
			Department department = new Department();
			department.setDepartName(company.getCompanyName());
			departmentDao.modifyRootDepartByCompId(company.getId(), department);  //修改根部门名称
		}
		return companyDao.modifyCompany(company);
	}
	

	//通过关键字查找公司
	@Override
	public List<Company> findCompanyByKeyworld(String keyworld) {
		List<Company> companys = companyDao.findCompanyByName(keyworld);
		if(companys.size()==0){
			return null;
		}
		return companys;
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
			throw new ServiceException(ResultCode.CompanyNotExists);
		}
		company.setDeleteUserId(userId);
		company.setDeleteTime(DateUtil.currentTimeSeconds());
		companyDao.modifyCompany(company);
	}
	
	
	//公司列表  
	@Override
	public PageResult<Company> companyList(int pageSize, int pageIndex) {
		return companyDao.companyList(pageSize, pageIndex);
	}
	
	
	
	//创建部门
	@Override
	public Department createDepartment(ObjectId companyId, ObjectId parentId, String departName, int createUserId) {
		//检查部门名称是否重复
		if(departmentDao.findOneByName(companyId, departName) != null)
			throw new ServiceException(ResultCode.DeptNameRepeat);
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
		ObjectId departmentId = departmentDao.addDepartment(department);
		
		return departmentDao.findDepartmentById(departmentId);
	}

	//修改部门信息
	@Override
	public Department modifyDepartmentInfo(Department department) {
		if(department.getDepartName() != null && ! "".equals(department.getDepartName()) ){
			ObjectId companyId = departmentDao.getCompanyId(department.getId()); //通过部门id得到公司id
			int departType = departmentDao.findById(department.getId()).getType();
			if( departType == 1 || departType == 4 || departType == 5 ){ //判断是否为特殊部门    1:表示根部门  4:演示数数据中的普通部门  5: 演示数据中的让用户加入的部门 
				throw new ServiceException(KConstants.ResultCode.NO_PERMISSION);
			}
			if(departmentDao.findOneByName(companyId, department.getDepartName()) != null)  //判断名称是否重复
				throw new ServiceException(ResultCode.DeptNameRepeat);
		}
		Department depart = departmentDao.modifyDepartment(department);
		return depart;
	}
	
	//删除部门
	@Override
	public void deleteDepartment(ObjectId departmentId) {
		//做相关的判断，特殊部门不能删除
		int departType = departmentDao.findById(departmentId).getType();
		if(departType == 1 || departType == 4 || departType == 5){ //1:  根部门    4:演示数数据中的普通部门  5: 演示数据中的让用户加入的部门 
			throw new ServiceException(ResultCode.DeptNotDelete);
		}
		if(employeeDao.existsEmployee(departmentId)){
			throw new ServiceException(KConstants.ResultCode.HaveDataCanNotDelete);
		}else if(departmentDao.findChildDepartmeny(departmentId).size()>0){
			throw new ServiceException(KConstants.ResultCode.HaveDataCanNotDelete);
		}
		//首先删除该部门的员工记录
		employeeDao.delEmpByDeptId(departmentId);
		
		departmentDao.deleteDepartment(departmentId); //删除部门记录
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
	public List<Department> departmentList(List<Department> departments) {
		 
		for(Iterator<Department> iter = departments.iterator();iter.hasNext(); ){  
			Department department = iter.next();
			//查找该部门中的员工,并封装到department中
			List<Employee> employees = employeeDao.departEmployeeList(department.getId());
			setUserNickname(employees); //将用户昵称封装到员工数据
			department.setEmployees(employees); //将员工数据封装进部门中
		}
		return departments;
	}
	
	
	//添加员工(支持多个) 
	@Override
	public List<Employee> addEmployee(ObjectId companyId, ObjectId departmentId, List<Integer> userId) {
		//判断是否能够添加
		List<Employee> compEmps = employeeDao.compEmployeeList(companyId); //得到公司的所有员工
		for(Iterator<Integer> uids = userId.iterator(); uids.hasNext();){  //遍历userId，和公司的所有员工进行比对
			int uid = uids.next();
			for(Iterator<Employee> iter = compEmps.iterator(); iter.hasNext(); ){
				Employee emp = iter.next();	
				if(emp.getUserId() == uid){  //判断员工是否存在
					// 不能重复添加
					throw new ServiceException(KConstants.ResultCode.NotRepeatOperation);
				}
			}
			
		}
		
		//正常添加员工
		List<Employee> employees = employeeDao.addEmployees(userId, companyId, departmentId);  //存入员工记录
		//修改公司记录里的员工数目
		Company company = companyDao.findById(companyId);
		company.setEmpNum(company.getEmpNum()+userId.size());
		companyDao.modifyCompany(company);
		
		//修改部门记录里的员工数目
		Department department = departmentDao.findById(departmentId);
		department.setEmpNum(department.getEmpNum()+userId.size());
		departmentDao.modifyDepartment(department);
		
		setUserNickname(employees);//将用户昵称封装到员工数据
		return employees;
	}
	
	
	//删除员工
	@Override
	public void deleteEmployee(List<Integer> userIds, ObjectId departmentId) {
		//修改部门记录里的员工数目    -1
		Department department = departmentDao.findById(departmentId);
		userIds.forEach(delUserId ->{
			if(delUserId.equals(department.getCreateUserId()))
				// 公司创建者不能被删除
				throw new ServiceException(KConstants.ResultCode.NO_PERMISSION);
		});
		employeeDao.deleteEmployee(userIds, departmentId); //删除员工记录
		department.setEmpNum(department.getEmpNum()-1);
		departmentDao.modifyDepartment(department);
		
		//修改公司记录里的员工数目
		Company company = companyDao.findById(department.getCompanyId());
		company.setEmpNum(company.getEmpNum()-1);
		companyDao.modifyCompany(company);
	}
	
	//客服模块，更改员工信息
	@Override
	public Employee changeEmployeeInfo(Employee employee) {
		if (!StringUtil.isEmpty(employee.toString())) {
			//根据公司，部门，用户id查出员工信息
			Employee employeeData = employeeDao.findEmployee(employee);
			if (null != employeeData && !"".equals(employeeData)) {
				// 根据员工id查询员工信息
				Employee employeeInfo = employeeDao.findById(employeeData.getId());
				if (employeeInfo.getChatNum() == 5 && employee.getOperationType() == 1) {
					throw new ServiceException(ResultCode.ManyConversation);
				} else {
					//该员工的当前会话人数
					int num = employeeInfo.getChatNum();
					// 建立会话
					if (employee.getOperationType() == 1) {
						employee.setChatNum(num + 1);
					} else if (employee.getOperationType() == 2) {
						// 结束回话
						employee.setChatNum(num - 1);
					} else {
						employee.setChatNum(employeeInfo.getChatNum());
					}
					// 如果只是修改会话人数，保证会话状态正常
					if (employee.getOperationType() != 0 && employee.getIsPause() == 0) {
						employee.setIsPause(employeeInfo.getIsPause());
					}
					if (employee.getChatNum() < 0) {
						//throw new ServiceException("当前会话人数异常！");
						return null;
					} else {
						Employee emp = modifyEmpInfo(employee);
						return emp;
					}
				}
			} else {
				throw new ServiceException(ResultCode.UserNotBelongCustomer);
			}
		} else {
			throw new ServiceException(KConstants.ResultCode.ParamsAuthFail);
		}
	}
	
	public Employee updateDeparmen(Employee employee){
		updateEmpDeft(employee);
		return modifyEmpInfo(employee);
	}


	@Override
	public Employee modifyEmpInfo(Employee employee) {
		//Employee oldemp =employeeDao.findById(employee.getId());
		Employee emp = employeeDao.modifyEmployees(employee);

		String nickname = userCoreService.getUser(emp.getUserId()).getNickname();
		emp.setNickname(nickname);
		return emp;
	}

	@Override
	public Employee updateEmpDeft(Employee employee) {
		// 旧部门人数减少
		ObjectId oldDeptId = employeeDao.getEmployeeByUserId(employee.getCompanyId(),employee.getUserId()).getDepartmentId();
		departmentDao.updateDepartment(oldDeptId,-1);

		Employee emp = employeeDao.modifyEmployees(employee);

		// 新部门人数增加
		departmentDao.updateDepartment(employee.getDepartmentId(),1);
		String nickname = userCoreService.getUser(emp.getUserId()).getNickname();
		emp.setNickname(nickname);
		return emp;
	}
	
	
	//员工列表(公司的所有员工)
	@Override
	public List<Employee> employeeList(ObjectId companyId) {
		List<Employee> employees = employeeDao.compEmployeeList(companyId);
		setUserNickname(employees);//将用户昵称封装到员工数据
		return employees;
	}
	
	//部门员工列表
	public List<Employee> departEmployeeList(ObjectId departmentId){
		List<Employee> employees = employeeDao.departEmployeeList(departmentId);
		setUserNickname(employees); //将用户昵称封装到员工数据
		return  employees;
	}


	
	//获取员工详情
	@Override
	public Employee getEmployee(ObjectId employeeId) {
		Employee emp =  employeeDao.findById(employeeId);
		String nickname = userCoreService.getUser(emp.getUserId()).getNickname();
		emp.setNickname(nickname);
		return emp;
	}

	
	//获取部门详情
	@Override
	public Department getDepartmentVO(ObjectId departmentId) {
		Department department = departmentDao.findById(departmentId);
		return department;
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
	

	
	//此方法用于将客户自动随机加入默认的公司,便于客户体验组织架构功能
	@Override
	public Company autoJoinCompany(int userId){
		Employee employee = new Employee();
		List<Company> companys = companyDao.findByType(5);  //查找默认加入的公司
		if(companys == null || companys.isEmpty()){
			return null;
		}
		//随机选择一个公司
		Random random = new Random();
		int comp = random.nextInt(companys.size()); 
		employee.setCompanyId(companys.get(comp).getId());  //设置 员工记录的companyId 为默认随机加入的公司的id
		
		
		//随机选择该公司下的一个部门
		List<Department> departments = departmentDao.findByType(companys.get(comp).getId(), 5);
		
		int dept = random.nextInt(departments.size());
		employee.setDepartmentId(departments.get(dept).getId()); //设置 员工记录的departmentId 为随机加入的部门的id
		
		employee.setUserId(userId);
		employee.setRole(ROLE.COMMON_EMPLOYEE);
		employeeDao.addEmployee(employee);
		//将公司数据返回
		return companyDao.findById(companys.get(comp).getId());
	}
	
	
	//员工退出公司
	@Override
	public void empQuitCompany(ObjectId companyId, int userId) {
		//判断员工身份，若为创建者直接删除公司(隐藏公司)，非创建者将该员工从公司中移除
		int employeeRole = employeeDao.findRole(companyId, userId);//获取员工角色值
		if(employeeRole == 3){    //  3 : 表示公司的创建者
			//删除（隐藏公司）
			deleteCompany(companyId, userId);
		}else{
			//删除员工记录
			employeeDao.delEmpByCompId(companyId, userId);
		}
		
	}


	//获取公司中某位员工的角色值
	@Override
	public int getEmpRole(ObjectId companyId, int userId) {
		return employeeDao.findRole(companyId, userId);
	}




	/**
	 * 根据用户id来修改员工信息
	 */
	@Override
	public Employee modifyEmployeesByuserId(int userId) {
		Employee employee = employeeDao.modifyEmployeesByuserId(userId);
		if (!StringUtil.isEmpty(employee.toString())) {
			return employee;
		}else{
			throw new ServiceException(ResultCode.UpdateFailure);
		}
	}

	
	/**
	 * 查询员工是否为客服
	 */
	@Override
	public Employee findEmployee(Employee employee,User.UserSettings userSettings) {
		if (!StringUtil.isEmpty(String.valueOf(employee.getCompanyId()))
				|| !StringUtil.isEmpty(String.valueOf(employee.getDepartmentId()))
				|| !StringUtil.isEmpty(String.valueOf(employee.getCompanyId()))) {
			Employee employeeInfo = employeeDao.findEmployee(employee, userSettings);
			if (null != employeeInfo && !"".equals(employeeInfo)) {
				// 判断当前会话人数是否为0,否则不能关闭客服模式
				if (employeeInfo.getChatNum() > 0) {
					throw new RuntimeException("当前还有" + employeeInfo.getChatNum() + "个客户正在会话，请结束会话再试!");
				} else {
					// 维护用户表中的是否开启客服模式字段
					if (userSettings.getOpenService() == 0 || userSettings.getOpenService() == 1) {
//						User user = SKBeanUtils.getUserRepository().updateSettings(employee.getUserId(), userSettings);
						User user = userCoreService.updateSettings(employee.getUserId(),userSettings);
						employeeInfo.setIsCustomer(user.getSettings().getOpenService());
						// 如果关闭客服模式则维护客服服务状态
						if (userSettings.getOpenService() == 0) {
							employeeDao.modifyEmployees(employee);
						}
					} else {
						throw new ServiceException(KConstants.ResultCode.ParamsAuthFail);
					}
				}
				return employeeInfo;
			} else {
				throw new ServiceException(ResultCode.UserNotBelongCustomer);
			}
		} else {
			throw new ServiceException(KConstants.ResultCode.ParamsAuthFail);
		}
	}


	/**
	 * 权限验证,通过公司id
	 * 
	 *  操作者userId
	 * 权限验证类型 type   3 : 公司创建者   2 : 公司管理员   1: 部门管理者 
	 */
	public boolean verifyAuthByCompanyId (ObjectId companyId, int userId, byte type) {
		//role  值  0：普通员工     1：部门管理者    2：管理员    3：公司创建者(超管)
		/*for(byte type : types) {
		}*/
		return ( employeeDao.findRole(companyId, userId) >= type);
	}
	
	
	/**
	 * 权限验证,通过部门id
	 * 
	 *  操作者userId
	 * 权限验证类型 type   3 : 公司创建者   2 : 公司管理员   1: 部门管理者 
	 */
	public boolean verifyAuthByDepartmentId (ObjectId departmentId, int userId, byte type) {
		//role  值  0：普通员工     1：部门管理者    2：管理员    3：公司创建者(超管)
		Department department = departmentDao.findDepartmentById(departmentId);
		return ( employeeDao.findRoleByDepartmentId(department.getCompanyId(), userId) >= type);
	}

	/**
	 * 
	 * @date 2019/10/8 9:40
	 *  根据公司编号 查询公司部门id
	 */
    public Department queryDepartmentId(ObjectId companyId) {
      return departmentDao.queryDepartmentId(companyId);
    }

}