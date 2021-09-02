package com.shiku.co.module.entity;

import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * 
 * @version V1.0
 * @Description: TODO( 提现申请记录)
 * @date 2019/12/2 11:50
 */
@Data
@Document(value = "withdraw")
public class Withdraw {
    @Id
    private ObjectId id;
    // 提现人Id
    private int userId;

    private String withdrawAccountId;// 提现账户Id

    private double money;

    private double serviceCharge;// 费率

    private double actualMoney;// 实际金额

    /**
     * 提现后余额
     */

    private double endMoney;

    // -1.已驳回 -2.已忽略 1.申请中 2.已通过

    private int status;

    private long createTime;

    private long modifyTime;

    private String orderNo;// 订单号

    // 用户昵称
    @Transient
    private String nickName;

    @Transient
    private WithdrawAccount withdrawAccount;
}
