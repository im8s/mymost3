package com.shiku.im.user.model;

import com.shiku.utils.StringUtil;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

@ApiModel("用户登陆信息")
@Data
public class LoginExample {

    @ApiModelProperty("密码")
    private  String password;

    @ApiModelProperty("手机号")
    private  String telephone;
    @ApiModelProperty("语言")
    private String language="zh";

    /**
     * 账号
     */
    @ApiModelProperty("账号")
    private String account;

    /**
     * account 加密后的通讯账号
     */
    @ApiModelProperty("account 加密后的通讯账号")
    private String encryAccount;
    @ApiModelProperty("用户Id")
    private int userId=0;
    @ApiModelProperty("手机区号")
    private String areaCode="86";
    @ApiModelProperty("编码")
    private String randcode;

    @ApiModelProperty("用户类型")
    private Integer userType;
    @ApiModelProperty("当前包名")
    private String appId;//ios  当前包名

    @ApiModelProperty("我的邀请码")
    private String myInviteCode; //我的邀请码
    @ApiModelProperty("注册时填写的邀请码")
    private String inviteCode; //注册时填写的邀请码

    @ApiModelProperty("第三方登录标识 0 不是     1 是")
    private int isSdkLogin;// 第三方登录标识  0 不是     1 是
    @ApiModelProperty("登录类型 0：账号密码登录，1：短信验证码登录")
    private int loginType;// 登录类型 0：账号密码登录，1：短信验证码登录
    @ApiModelProperty("短信验证码")
    private String verificationCode;// 短信验证码

    //当前登陆设备
    @ApiModelProperty("设备Key")
    private String deviceKey;
    @ApiModelProperty("设备编号")
    private String deviceId;
    @ApiModelProperty("登录token")
    private String loginToken;
    @ApiModelProperty("客户端使用的接口版本号")
    private String apiVersion;// 客户端使用的接口版本号
    @ApiModelProperty("客户端设备型号")
    private String model;// 客户端设备型号
    @ApiModelProperty("客户端设备操作系统版本号")
    private String osVersion;// 客户端设备操作系统版本号
    @ApiModelProperty("客户端设备序列号")
    private String serial;// 客户端设备序列号

    @ApiModelProperty("区县Id")
    private Integer areaId;// 区县Id
    @ApiModelProperty("城市Id")
    private Integer cityId;// 城市Id
    @ApiModelProperty("城市名称")
    private String cityName;// 城市名称
    @ApiModelProperty("短信验证码")
    private Integer countryId;// 国家Id
    @ApiModelProperty("省份Id")
    private Integer provinceId;// 省份Id
    @ApiModelProperty("纬度")
    private double latitude;// 纬度
    @ApiModelProperty("经度")
    private double longitude;// 经度
    @ApiModelProperty("详细地址")
    private String address;// 详细地址
    @ApiModelProperty("位置描述")
    private String location;// 位置描述
    @ApiModelProperty("用户地理位置")
    private String area;// 用户地理位置
    @ApiModelProperty("设备类型")
    private String deviceType;
    @ApiModelProperty("ip地址")
    private String ip;
    @ApiModelProperty("ip位置")
    private String ipLocation;
    @ApiModelProperty("0-普通会员 1-商务号 (用来区分是否可以主动添加会员)")
    private Integer permitUserType;


    public void copySignExample(LoginExample example){
        if(StringUtil.isEmpty(this.telephone))
             this.telephone=example.getTelephone();
        if(StringUtil.isEmpty(this.account))
            this.account=example.getAccount();
        this.userId=example.getUserId();
        this.deviceId=example.getDeviceId();
        this.deviceType = example.getDeviceType();
        this.ip = example.getIp();
        this.ipLocation = example.getIpLocation();
    }

}
