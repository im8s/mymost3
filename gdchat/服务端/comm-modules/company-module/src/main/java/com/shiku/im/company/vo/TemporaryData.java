package com.shiku.im.company.vo;

import lombok.Data;
import org.bson.types.ObjectId;

/**
 *
 * @Date Created in 2019/9/29 17:48
 * @description TODO
 * @modified By:   用于解决数结构问题  临时转存的类
 */
@Data
public class TemporaryData {
    private ObjectId id; //id
    private String nickname; //昵称
    private byte role; //员工角色：0：普通员工     1：部门管理者(暂时没用)    2：公司管理员    3：公司创建者
    private String position = "员工";  //职位（头衔），如：经理、总监等
    private int isCustomer;//是否为客服    0:不是  1:是
    private ObjectId departmentId;  //部门Id,表示员工所属部门
    private int userId;//用户id
    private int retract; //缩进个数
    private String parentId1;//解决我的同事问题
}
