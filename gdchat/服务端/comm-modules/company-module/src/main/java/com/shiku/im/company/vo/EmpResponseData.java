package com.shiku.im.company.vo;

import com.shiku.im.company.entity.Employee;
import org.bson.types.ObjectId;

import java.util.List;

/**
 * 
 * @Date Created in 2019/9/25 11:40
 * @description TODO
 * @modified By: 用于 我的同事 解决麻烦的前台页面拼接 创建的响应数据类
 */
public class EmpResponseData {
    private ObjectId depId; //部门id
    private String departName; //部门名称

    private List<Employee> employees;



}
