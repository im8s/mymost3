package com.shiku.im.open.entity;

import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;

/**
 *
 * @Date Created in 2019/9/16 9:51
 * @description TODO 公众号账户信息
 * @modified By:
 */
@Data
public class OfficialInfo {
    @Id
    private ObjectId id;
    @Indexed
    private String telephone;//手机号码
    private String areaCode;
    private String password;//密码
    private String companyName;//公司名称
    private String companyBusinessLicense;//公司营业执照
    private int companyType;//公司类型 0--个体工商户  1--企业
    private String adminName;//管理员名称
    private String adminID;//管理员身份证号码
    private String adminTelephone;//管理员手机号码
    private long createTime;//创建用户时间
    protected String country;// 国家
    protected String province;// 省份
    protected String city;// 城市名称
    protected String desc;// 详细地址
    private int verify=0;//审核 0--未审核  1--审核通过  2--审核不通过
    private String feedback;//反馈
    private String industryImg;//工商执照图片
}
