package com.shiku.co.module.entity;


import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * 
 * @version V1.0
 * @Description: TODO(收款人)
 * @date 2019/12/2 10:30
 */
@Data
@Document(value = "receiveAccount")
public class ReceiveAccount {
    @Id
    private ObjectId id;

    private String url;// 二维码地址

    private int type;// 类型 1.微信 2.支付宝 3.银行卡

    private String name;// 账户名称

    private String payNo;// 微信或支付宝账号

    private String bankCard;// 银行卡号

    private String bankName;// 开户银行名称

    private long createTime;

}
