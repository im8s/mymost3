package com.shiku.im.pay.entity;

import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * 
 * @Description: TODO(支付宝提现记录)
 * 
 * @date 2019年1月16日 下午7:56:48
 * @version V1.0
 */

@Data
@Document(value="aliPaytransfersRecord")
public class AliPayTransfersRecord {
	@Id
	private ObjectId id;
	
	private int userId;
	
	private long createTime;
	
	/**
	 * 订单状态   0 创建   1 支付成功  -1 支付失败
	 */
	private int status;
	
	private String appid;
	
	private String aliUserId;
	
	/**
	 * 商户转账订单号
	 */
	@Indexed
	private  String outTradeNo;
	
	/**
	 * 提现金额  
	 */
	private String totalFee;
	
	/**
	 * 手续费
	 */
	private String fee;
	
	/**
	 * 实际到账金额
	 */
	private String realFee;
	
	/**
	 * 微信支付成功时间
	 */
	private String payTime;
	
	private String resultCode;
	private String returnCode;
	
	/**
	 * 错误信息
	 */
	private String errCode;
	private String errDes;
}
