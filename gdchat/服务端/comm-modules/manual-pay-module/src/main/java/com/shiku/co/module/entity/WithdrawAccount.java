package com.shiku.co.module.entity;

import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 *
 * @version V1.0
 * @Description: TODO(提现账户)
 * 用户可绑定多个提现账户
 * @date 2019/12/2 11:58
 */
@Data
@Document(value = "wuthdrawAccount")
public class WithdrawAccount {
    @Id
    private ObjectId id;

    private int userId;// 提现用户id

    private int type;// 提现类型 1.支付宝  2.银行卡

    private String aliPayName;// 支付宝名称

    private String aliPayAccount;// 支付宝账户

    private String cardName;// 持卡人姓名

    private String bankCardNo;// 银行卡号

    private String bankName;// 银行名称

    private String bankBranchName;// 支行名称

    private String desc;// 备注信息

    private int status=1;// 1.正常  -1.删除

    private long createTime;
}
