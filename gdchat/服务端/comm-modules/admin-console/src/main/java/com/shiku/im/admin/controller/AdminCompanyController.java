package com.shiku.im.admin.controller;

import com.alibaba.fastjson.JSON;
import com.shiku.common.model.PageResult;
import com.shiku.im.admin.service.impl.ColleagueManagerImpl;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.company.CompanyConstants;
import com.shiku.im.company.entity.Company;
import com.shiku.im.company.entity.Department;
import com.shiku.im.company.entity.Employee;
import com.shiku.im.company.vo.TemporaryData;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.vo.JSONMessage;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import springfox.documentation.annotations.ApiIgnore;

import javax.validation.Valid;
import java.util.ArrayList;
import java.util.List;

/**
 * 
 * @description TODO (我的同事操作)
 * @Date Created in 2019/11/21 17:38
 */
@ApiIgnore
@RestController
@RequestMapping("/console")
public class AdminCompanyController {

    @Autowired
    private ColleagueManagerImpl colleagueManager;

    @Autowired
    private UserCoreService userCoreService;


    // 公司列表
    @RequestMapping("/web/company/list")
    public JSONMessage companyList (@RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "15") int limit){
        PageResult<Company> data = colleagueManager.companyList(limit,page);


        return JSONMessage.success(data);
    }

    /**
     * 
     * @date 2019/9/26 16:18
     *		web 后台 查询部门列表（2）
     */
    @ApiOperation("web后台 部门列表")
    @RequestMapping("/department/list1")
    @ApiImplicitParam(paramType="query" , name="companyId" , value="公司编号",dataType="String",required=true)
    public JSONMessage departmentList1 (String companyId){
        List<Department> departments = colleagueManager.departmentList(companyId);
        List<TemporaryData> temporaryData = new ArrayList<TemporaryData>();

        //设置树结构信息
        departments.forEach(dep->{  //遍历全部部门
            dep.setRole((byte) 100);
            dep.setIsCustomer(100);
            dep.setPosition("");
            dep.setIsDep(0);
            //设置公司信息
            if (dep.getParentId()== null){
                departments.forEach(dep1->{
                    if (dep1.getParentId() != null){
                        if (dep1.getParentId().equals(dep.getId())){    //表示是公司下的部门
                            dep1.setParentId(new ObjectId("53102b43bf1044ed8b0ba36b"));
                            dep1.setParentId1("0");
                            dep1.setRetract(0);
                        }
                    }
                });
            }
            //设置空格数
            if(dep.getParentId() != null){
                dep.setRetract(colleagueManager.getRetractNumber(dep.getParentId()));
                dep.setRetract(dep.getRetract());
            }
            colleagueManager.num = 0;
        });

        //转存
        departments.forEach(dep->{      //部门下的部门
            List<Employee> employees = dep.getEmployees();
            employees.forEach(emp->{
                TemporaryData tData = new TemporaryData();
                //设置编号
                tData.setId(emp.getId());
                //设置是否客户
                tData.setIsCustomer(emp.getIsCustomer());
                //设置头衔
                tData.setPosition(emp.getPosition());
                //设置昵称
                tData.setNickname(emp.getNickname());
                //设置角色
                tData.setRole(emp.getRole());
                //设置上级部门
                tData.setDepartmentId(emp.getDepartmentId());
                //设置用户Id
                tData.setUserId(emp.getUserId());
                //设置缩进个数
                tData.setRetract(dep.getRetract());
                temporaryData.add(tData);
            });
        });

        //加入员工数据
        temporaryData.forEach(data->{
            Department department = new Department();
            //设置编号
            department.setId(data.getId());
            //设置角色
            department.setRole(data.getRole());
            //设置头衔
            department.setPosition(data.getPosition());
            //设置上级部门
            department.setParentId(data.getDepartmentId());
            department.setParentId1(String.valueOf(data.getDepartmentId()));
            //设置是否客服
            department.setIsCustomer(data.getIsCustomer());
            //设置名称
            department.setDepartName(data.getNickname());
            //设置按钮
            department.setIsMenu(1);
            department.setIsDep(1);
            department.setUserId(data.getUserId());
            department.setRetract(data.getRetract());
            department.setIsStaff(1);
            departments.add(department);
        });

        for (Department department : departments) {
            if (null == department.getParentId1()){
                department.setParentId1(String.valueOf(department.getParentId()));
            }
        }

        //改变位置
        List<Department> changeDepartments = colleagueManager.departmentList(companyId);
        for (Department department : departments) {
            if (department.getEmpNum() == -1){
                changeDepartments.add(department);
            }
        }

        for (Department department : departments) {
            if (department.getEmpNum() != -1){
                changeDepartments.add(department);
            }
        }

        return JSONMessage.success(changeDepartments);
    }

    /**
     * 
     * @date 2019/9/26 16:20
     * 		web 后台删除员工
     */
    @ApiOperation("web后台 删除员工")
    @RequestMapping("/web/employee/delete")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType="query" , name="userIds" , value="用户Id",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="departmentId" , value="部门id",dataType="String"),
    })
    public JSONMessage webDelEmployee1(@RequestParam String userIds, @RequestParam String departmentId){
        if(!ObjectId.isValid(departmentId))
            return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
        ObjectId departId = new ObjectId(departmentId);

        // 以字符串的形式接收userId，然后解析转换为int
        List<Integer> uIds= new ArrayList<Integer>();
        char first = userIds.charAt(0);
        char last = userIds.charAt(userIds.length() - 1);
        if(first=='[' && last==']'){ // 用于解析web端
            uIds = JSON.parseArray(userIds, Integer.class);
        }else{ // 用于解析Android和IOS端
            uIds.add(Integer.parseInt(userIds));
        }

        colleagueManager.deleteEmployee(uIds, departId);
        return JSONMessage.success();
    }

    /**
     * 
     * @date 2019/9/26 16:21
     * 		web 后台 根据员工ObjectId查询员工信息
     */
    @ApiOperation("查询员工信息")
    @RequestMapping("/employee/msg")
    @ApiImplicitParam(paramType="query" , name="id" , value="员工Id",dataType="String",required=true)
    public JSONMessage employeeMsg(@RequestParam String id){
        Employee employee = colleagueManager.getEmployee(new ObjectId(id));
        return JSONMessage.success(employee);
    }

    /**
     * 
     * @date 2019/9/26 16:23
     * 		web 后台 根据公司编号 查询部门列表
     */
    @ApiOperation("根据公司查询部门信息")
    @RequestMapping("/department/all")
    @ApiImplicitParam(paramType="query" , name="companyId" , value="公司Id",dataType="String",required=true)
    public JSONMessage departmentAll(@RequestParam String companyId){
        List<Department> departments = colleagueManager.departmentAllList(new ObjectId(companyId));
        return JSONMessage.success(departments);
    }

    /**
     * 
     * @date 2019/9/26 16:26
     * 		web 后台修改员工信息
     */
    @ApiOperation("修改员工信息")
    @RequestMapping("/update/employee")
    public JSONMessage updataDepartmentMsg(@Valid Employee employee){
        Employee empData = colleagueManager.modifyEmpInfo(employee);
        return JSONMessage.success(empData);
    }



    /**
     * 
     * @date 2019/9/30 16:25
     */
    @ApiOperation("web后台 创建部门")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType="query" , name="companyId" , value="公司Id",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="parentId" , value="父Id（上一级部门的Id，根部门的父id为公司Id）",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="departName" , value="部门名称",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="createUserId" , value="创建者userId",dataType="int",required=true)
    })
    @RequestMapping("/add/deparment")
    public JSONMessage addDepartment(@RequestParam String companyId, @RequestParam String parentId, @RequestParam String departName,@RequestParam int createUserId){
        if(!ObjectId.isValid(companyId))
            return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);

        Object data = colleagueManager.createDepartment(new ObjectId(companyId), new ObjectId(parentId), departName + "部", createUserId);
        return JSONMessage.success(data);
    }


    /**
     * 
     * @date 2019/9/30 16:25
     * 		web 修改部门信息
     */
    @ApiOperation("修改部门名称")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType="query" , name="departmentId" , value="部门Id",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="dpartmentName" , value="新部门名称",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="newDepId" , value="移动自新部门",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="oldDpartmentName" , value="旧部门名称",dataType="String",required=true)
    })
    @RequestMapping("/update/department")
    public JSONMessage updateDepartmentName (@RequestParam String departmentId,@RequestParam  String newDpartmentName,@RequestParam String newDepId,@RequestParam String oldDpartmentName){
        if(!ObjectId.isValid(departmentId))
            return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);

        ObjectId departId = new ObjectId(departmentId);
        Department department = new Department();
        department.setId(departId);
        department.setDepartName(newDpartmentName + "部");
        if (!newDepId.equals("0")){
            department.setParentId(new ObjectId(newDepId));
        }
        Object data = colleagueManager.webModifyDepartmentInfo(department,oldDpartmentName);
        return JSONMessage.success(data);
    }

    /**
     * 
     * @date 2019/9/30 16:26
     * 		web 删除部门
     */
    @ApiOperation("删除部门")
    @ApiImplicitParam(paramType="query" , name="departmentId" , value="要删除的部门Id",dataType="String",required=true)
    @RequestMapping("/delete/department")
    public JSONMessage deleteDepartment (@RequestParam String departmentId){
        System.out.println("departmentId = " + departmentId);
        if(!ObjectId.isValid(departmentId))
            return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
        ObjectId departId = new ObjectId(departmentId);
        colleagueManager.deleteDepartment(departId);
        return JSONMessage.success();
    }


    /**
     * 
     * @date 2019/9/30 16:26
     * 		web 添加员工
     */
    @ApiOperation("添加员工")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType="query" , name="userId" , value="要添加的用户userId集合（json字符串）",dataType="String",required=true),
            @ApiImplicitParam(paramType="query" , name="companyId" , value="公司Id",dataType="String"),
            @ApiImplicitParam(paramType="query" , name="departmentId" , value="部门Id",dataType="String"),
            @ApiImplicitParam(paramType="query" , name="role" , value="角色值 默认值:1 ,1:普通员工2：管理员 3：创建者",dataType="int")
    })
    @RequestMapping("/web/employee/add")
    public JSONMessage webAddEmployee (@RequestParam String telephone, @RequestParam String companyId,@RequestParam String departmentId){
        if(!ObjectId.isValid(companyId)||!ObjectId.isValid(departmentId))
            return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);

        telephone = "86" + telephone;
        //判断该userId是否存在
        User user = userCoreService.getUser(telephone);

        ObjectId compId = new ObjectId(companyId);
        ObjectId departId = new ObjectId(departmentId);
        Object data = colleagueManager.webAddEmployee(compId, departId, user.getUserId());
        if (data == null){
            return JSONMessage.success(KConstants.ResultCode.USEREXITS);
        }
        return JSONMessage.success(data);
    }

    /**
     * 
     * @date 2019/11/20 17:07
     * 		根据用户编号 查询公司
     */
    @RequestMapping("/web/companyById")
    public JSONMessage webQueryCompanyById (@RequestParam String keyworld,@RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "10") int limit){
        PageResult<Company> data = colleagueManager.findCompanyByKeyworldLimit(keyworld,page,limit);
        return JSONMessage.success(data);
    }


    /**
     * @Description //TODO (添加公司)
     * @Date 14:59 2019/12/21
     **/
    @RequestMapping(value = "/web/company/create")
    public JSONMessage createCompany(@RequestParam String companyName){

        try {
             int createUserId = ReqUtil.getUserId();
            if(companyName != null && !"".equals(companyName) && createUserId > 0){
                Company company = colleagueManager.createCompany(companyName, createUserId);
                company.setDepartments(colleagueManager.departmentList(company.getId()) ); //将部门及员工数据封装进公司
                Object data = company;
                return JSONMessage.success(data);
            }
        } catch (Exception e) {
            return JSONMessage.failureByException(e);

        }
        return JSONMessage.failureByErrCode(CompanyConstants.ResultCode.createCompanyFailure);

    }


    // 删除公司(即：记录删除者id,将公司信息隐藏)
    @ApiOperation("删除公司")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType="query" , name="companyId" , value="公司Id",dataType="String",required=true)
    })
    @RequestMapping("/web/company/delete")
    public JSONMessage deleteCompany(@RequestParam String companyId){
        if(!ObjectId.isValid(companyId)) {
            return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
        }
            try {
            ObjectId compId = new ObjectId(companyId);
            colleagueManager.deleteCompany(compId, ReqUtil.getUserId());
            return JSONMessage.success();
        } catch (Exception e) {
            return JSONMessage.failureByException(e);
        }
    }
}
