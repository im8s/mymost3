package com.shiku.im.pay.entity;

import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * 
 * @Description: TODO(付款码支付、二维码收款记录实体)
 * 
 * @date 2019年2月26日 下午3:14:18
 * @version V1.0
 */
@Document(value = "codePay")
@Data
public class CodePay {
	
	private @Id
	ObjectId id;
	
	private Integer userId;// 码的所有人id
	
	private String userName;// 码的所有人名称
	
	private Integer toUserId;// 扫码的人Id
	
	private String toUserName;// 扫码的人的名称

	//支付二维码
    @Indexed
	private String qrCode;

	private Double money;// 金额
	
	private int type;// 类型  1：付款码    2：二维码收款
	
	private long createTime;// 交易时间

	private byte status;//状态
}
