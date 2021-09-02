package com.shiku.im.pay.entity;

import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Document(value = "payOrder")
public class PayOrder {

	@Id
	private  ObjectId id;
	
	private String money;// 订单金额
	
	private String userId;// 用户
	
	private String appId;// 应用id
	
	private String appType;// 应用type
	
	private byte status;// 订单状态  0：创建  1：支付完成  2：交易完成  -1：交易关闭
	
	private long createTime;// 创建时间
	
	private String desc;// 商品说明
	
	private String sign;// 订单签名
	
	private String callBackUrl;// 回调路径
	
	private String IPAdress;// 请求ip地址
	
	private String trade_no;// 用户生成订单号
}
