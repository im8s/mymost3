package com.shiku.im.company.entity;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

@ApiModel("员工实体")
@Document(value = "employee")
public class Employee {
	@ApiModelProperty("员工id")
	@Id
	private ObjectId id; //员工id
	@ApiModelProperty("用户id,用于和用户表关联")
	private @Indexed int userId; //用户id,用于和用户表关联
	@ApiModelProperty("部门Id,表示员工所属部门  ")
	private @Indexed ObjectId departmentId;  //部门Id,表示员工所属部门
	@ApiModelProperty("公司id，表示员工所属公司")
	private @Indexed ObjectId companyId; //公司id，表示员工所属公司
	@ApiModelProperty("员工角色：0：普通员工     1：部门管理者(暂时没用)    2：公司管理员    3：公司创建者")
	private byte role; //员工角色：0：普通员工     1：部门管理者(暂时没用)    2：公司管理员    3：公司创建者
	@ApiModelProperty("职位（头衔），如：经理、总监等")
	private String position = "员工";  //职位（头衔），如：经理、总监等

	@ApiModelProperty("用户昵称，和用户表一致")
	private @Transient
	String nickname;  //用户昵称，和用户表一致
	
	//客服模块所需字段
	@ApiModelProperty("当前会话的人数")
	private int chatNum;//当前会话的人数
	@ApiModelProperty("是否暂停    0：暂停,1:正常")
	private int isPause;//是否暂停    0：暂停,1:正常
	@ApiModelProperty("操作类型 1.建立会话操作 2.结束回话操作")
	private @Transient int operationType;//操作类型 1.建立会话操作 2.结束回话操作
	@ApiModelProperty("是否为客服    0:不是  1:是")
	private @Transient int isCustomer;//是否为客服    0:不是  1:是

	private int retract; //缩进个数
	private int isStaff=0;//是否员工 1：是 0不是

	private String parentId1;//解决我的同事问题

	public int getIsCustomer() {
		return isCustomer;
	}
	public void setIsCustomer(int isCustomer) {
		this.isCustomer = isCustomer;
	}
	public int getOperationType() {
		return operationType;
	}
	public void setOperationType(int operationType) {
		this.operationType = operationType;
	}
	public int getIsPause() {
		return isPause;
	}
	public void setIsPause(int isPause) {
		this.isPause = isPause;
	}
	public int getChatNum() {
		return chatNum;
	}
	public void setChatNum(int chatNum) {
		this.chatNum = chatNum;
	}
	public String getNickname() {
		return nickname;
	}
	public void setNickname(String nickname) {
		this.nickname = nickname;
	}
	public ObjectId getId() {
		return id;
	}
	public void setId(ObjectId id) {
		this.id = id;
	}
	public int getUserId() {
		return userId;
	}
	public void setUserId(int userId) {
		this.userId = userId;
	}
	public ObjectId getDepartmentId() {
		return departmentId;
	}
	public void setDepartmentId(ObjectId departmentId) {
		this.departmentId = departmentId;
	}
	public ObjectId getCompanyId() {
		return companyId;
	}
	public void setCompanyId(ObjectId companyId) {
		this.companyId = companyId;
	}
	public byte getRole() {
		return role;
	}
	public void setRole(byte role) {
		this.role = role;
	}
	public String getPosition() {
		return position;
	}
	public void setPosition(String position) {
		this.position = position;
	}
	public int getRetract() { return retract; }
	public void setRetract(int retract) { this.retract = retract; }
	public int getIsStaff() { return isStaff; }
	public void setIsStaff(int isStaff) { this.isStaff = isStaff; }
}
