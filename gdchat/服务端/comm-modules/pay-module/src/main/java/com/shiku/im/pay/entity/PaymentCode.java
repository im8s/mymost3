package com.shiku.im.pay.entity;

import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * 
 * @Description: TODO(用户付款码记录)
 *
 * @date 2019年2月19日 下午12:31:19
 * @version V1.0
 */
@Document(value ="paymentCode")
@Data
public class PaymentCode {
	private @Id
	ObjectId id;

	@Indexed
	private Integer userId;// 用户Id
	
	private String paymentCode;// 付款码
	
	private int status;// 1:完成
	
	private double money;// 金额
	
	private long time;
}
