package com.shiku.im.user.model;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;

@ApiModel("附近用户类")
public class NearbyUser extends BasePoi {
	@ApiModelProperty("最后出现时间")
	private Long active;
	@ApiModelProperty("生日")
	private Long birthday;// 生日
	@ApiModelProperty("签名")
	private String description;// 签名
	@ApiModelProperty("学历")
	private Integer diploma;// 学历
	@ApiModelProperty("最大年龄")
	private Integer maxAge;
	@ApiModelProperty("最小年龄")
	private Integer minAge;
	@ApiModelProperty("姓名")
	private String name;// 姓名
	@ApiModelProperty("昵称")
	private String nickname;// 昵称
	@ApiModelProperty("薪水")
	private Integer salary;// 薪水
	@ApiModelProperty("性别")
	private Integer sex;// 性别
	@ApiModelProperty("用户Id")
	private Integer userId;// 用户Id
	@ApiModelProperty("工作经验")
	private Integer workExp;// 工作经验
	
	//距离  km  公里  附件筛选条件
	@ApiModelProperty("距离  km  公里  附件筛选条件")
	private int distance=0;

	public int getDistance() {
		return distance;
	}

	public void setDistance(int distance) {
		this.distance = distance;
	}

	public Long getActive() {
		return active;
	}

	public Long getBirthday() {
		return birthday;
	}

	public String getDescription() {
		return description;
	}

	public Integer getDiploma() {
		return diploma;
	}

	public Integer getMaxAge() {
		return maxAge;
	}

	public Integer getMinAge() {
		return minAge;
	}

	public String getName() {
		return name;
	}

	public String getNickname() {
		return nickname;
	}

	public Integer getSalary() {
		return salary;
	}

	public Integer getSex() {
		return sex;
	}

	public Integer getUserId() {
		return userId;
	}

	public Integer getWorkExp() {
		return workExp;
	}

	public void setActive(Long active) {
		this.active = active;
	}

	public void setBirthday(Long birthday) {
		this.birthday = birthday;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public void setDiploma(Integer diploma) {
		this.diploma = diploma;
	}

	public void setMaxAge(Integer maxAge) {
		this.maxAge = maxAge;
	}

	public void setMinAge(Integer minAge) {
		this.minAge = minAge;
	}

	public void setName(String name) {
		this.name = name;
	}

	public void setNickname(String nickname) {
		this.nickname = nickname;
	}

	public void setSalary(Integer salary) {
		this.salary = salary;
	}

	public void setSex(Integer sex) {
		this.sex = sex;
	}

	public void setUserId(Integer userId) {
		this.userId = userId;
	}

	public void setWorkExp(Integer workExp) {
		this.workExp = workExp;
	}

}
