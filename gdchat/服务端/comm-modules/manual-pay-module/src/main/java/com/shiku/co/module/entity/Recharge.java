package com.shiku.co.module.entity;

import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * 
 * @version V1.0
 * @Description: TODO(充值申请记录)
 * @date 2019/12/2 11:25
 */
@Data
@Document(value = "recharge")
public class Recharge {
    @Id
    private ObjectId id;

    private int userId;// 用户Id

    private double money;

    private int type;// 类型 1.微信支付 2.支付宝 3.银行卡

    private String orderNo;// 订单号

    private double serviceCharge;// 手续费

    private double actualMoney;// 实际金额

    private long createTime;

    private int status; // 状态 -1.忽略 1.申请中 2.已完成

    private long modifyTime;

    /**
     * 当前账号余额
     */
    @Transient
    private double currentMoney;

    // 用户昵称
    @Transient
    private String nickName;

}
