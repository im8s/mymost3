package com.shiku.im.company.entity;

import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.List;

@Data
@Document(value = "department")
public class Department {
	
	private @Id ObjectId id; //部门id
	private @Indexed ObjectId companyId; //公司id，表示该部门所属的公司
	private @Indexed ObjectId parentId; //parentId 表示上一级的部门ID
	private @Indexed String departName; //部门名称
	private @Indexed int createUserId; //创建者userId
	private long createTime; //创建时间
	private int empNum = -1; //部门总人数
	private String parentId1;//解决我的同事问题
	private @Indexed int type = 0; //类型值  0:普通部门  1:根部门  2:分公司    5:默认加入的部门  6.客服部门
	
	
	//此属性用于封装部门员工列表
	private @Transient
	List<Employee> employees;  //部门员工列表
	
	//此属性用于封装该部门的子部门
	private @Transient List<Department> childDepartment; //子部门

	//===================================分割线==========================================
	//用户后台树结构展示用的临时属性
	private byte role; //员工角色：0：普通员工     1：部门管理者(暂时没用)    2：公司管理员    3：公司创建者
	private String position = "员工";  //职位（头衔），如：经理、总监等
	private @Transient int isCustomer;//是否为客服    0:不是  1:是
	private int isMenu =0;
	private int isDep = 0;//0=是部门  1=不是部门
	private int userId;//用户编号
	private int retract; //缩进个数
	private int isStaff=0;//是否员工 1：是 0不是


	public int getType() {
		return type;
	}
	public void setType(int type) {
		this.type = type;
	}
	
	public ObjectId getId() {
		return id;
	}
	public void setId(ObjectId id) {
		this.id = id;
	}
	public List<Employee> getEmployees() {
		return employees;
	}
	public void setEmployees(List<Employee> employees) {
		this.employees = employees;
	}
	public ObjectId getCompanyId() {
		return companyId;
	}
	public void setCompanyId(ObjectId companyId) {
		this.companyId = companyId;
	}
	public ObjectId getParentId() {
		return parentId;
	}
	public void setParentId(ObjectId parentId) {
		this.parentId = parentId;
	}
	public String getDepartName() {
		return departName;
	}
	public void setDepartName(String departName) {
		this.departName = departName;
	}
	public int getCreateUserId() {
		return createUserId;
	}
	public void setCreateUserId(int createUserId) {
		this.createUserId = createUserId;
	}
	public long getCreateTime() {
		return createTime;
	}
	public void setCreateTime(long createTime) {
		this.createTime = createTime;
	}
	public int getEmpNum() {
		return empNum;
	}
	public void setEmpNum(int empNum) {
		this.empNum = empNum;
	}
	public List<Department> getChildDepartment() {
		return childDepartment;
	}
	public void setChildDepartment(List<Department> childDepartment) {
		this.childDepartment = childDepartment;
	}
	
	
}
