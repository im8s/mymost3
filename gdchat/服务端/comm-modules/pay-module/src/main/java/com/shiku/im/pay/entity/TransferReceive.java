package com.shiku.im.pay.entity;

import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * 
 * @Description: TODO(转账收款实体)
 *
 * @date 2019年2月18日 下午3:52:18
 * @version V1.0
 */
@Document(value = "TransferReceive")
@Data
public class TransferReceive {
	@Id
	private  ObjectId id;

	@Indexed
	private String transferId;// 转账Id
	
	private @Indexed Integer userId;// 接受者用户ID
	
	private @Indexed Integer sendId;// 发送者用户Id
	
	private String userName;// 接受者用户名称
	
	private String sendName;// 转账发送者昵称
	
	private Double money;// 接受转账金额
	
	private long time;// 接受转账时间
}
