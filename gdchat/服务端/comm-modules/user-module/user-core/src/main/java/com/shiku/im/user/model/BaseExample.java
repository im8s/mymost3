package com.shiku.im.user.model;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;

@ApiModel("基本信息")
public class BaseExample {

	@ApiModelProperty("客户端使用的接口版本号")
	protected String apiVersion;// 客户端使用的接口版本号
	@ApiModelProperty("客户端设备型号")
	protected String model;// 客户端设备型号
	@ApiModelProperty("客户端设备操作系统版本号")
	protected String osVersion;// 客户端设备操作系统版本号
	@ApiModelProperty("客户端设备序列号")
	protected String serial;// 客户端设备序列号

	@ApiModelProperty("区县Id")
	protected Integer areaId;// 区县Id
	@ApiModelProperty("城市Id")
	protected Integer cityId;// 城市Id
	@ApiModelProperty("城市名称")
	protected String cityName;// 城市名称
	@ApiModelProperty("国家Id")
	protected Integer countryId;// 国家Id
	@ApiModelProperty("省份Id")
	protected Integer provinceId;// 省份Id
	@ApiModelProperty("详细地址")
	protected String address;// 详细地址
	@ApiModelProperty("位置描述")
	protected String location;// 位置描述
	@ApiModelProperty("纬度")
	protected double latitude;// 纬度
	@ApiModelProperty("经度")
	protected double longitude;// 经度

	public String getApiVersion() {
		return apiVersion;
	}

	public void setApiVersion(String apiVersion) {
		this.apiVersion = apiVersion;
	}
	
	public String getModel() {
		return model;
	}

	public void setModel(String model) {
		this.model = model;
	}

	public String getOsVersion() {
		return osVersion;
	}

	public void setOsVersion(String osVersion) {
		this.osVersion = osVersion;
	}

	public String getSerial() {
		return serial;
	}

	public void setSerial(String serial) {
		this.serial = serial;
	}

	public Integer getAreaId() {
		return areaId;
	}

	public void setAreaId(Integer areaId) {
		this.areaId = areaId;
	}

	public Integer getCityId() {
		return cityId;
	}

	public void setCityId(Integer cityId) {
		this.cityId = cityId;
	}

	public String getCityName() {
		return cityName;
	}

	public void setCityName(String cityName) {
		this.cityName = cityName;
	}

	public Integer getCountryId() {
		return countryId;
	}

	public void setCountryId(Integer countryId) {
		this.countryId = countryId;
	}

	public Integer getProvinceId() {
		return provinceId;
	}

	public void setProvinceId(Integer provinceId) {
		this.provinceId = provinceId;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public double getLatitude() {
		return latitude;
	}

	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}

	public double getLongitude() {
		return longitude;
	}

	public void setLongitude(double longitude) {
		this.longitude = longitude;
	}

}
