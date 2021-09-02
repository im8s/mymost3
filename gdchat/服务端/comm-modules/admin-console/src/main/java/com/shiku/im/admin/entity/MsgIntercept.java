package com.shiku.im.admin.entity;


import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * 
 * @Description: TODO(敏感词消息拦截记录)
 * 
 * @date 2019年7月31日 下午5:59:27
 * @version V1.0
 */
@Document(value = "msgIntercept")
@Data
public class MsgIntercept {
	@Id
	private ObjectId id;
	
	@Indexed
	private String sender; // 发送者
	
	@Indexed
	private String receiver;// 接受者
	
	@Indexed
	private String roomJid;// 群组jid
	
	private String content;// 拦截内容
	
	private long createTime;// 拦截时间
	
	@Transient
	private String senderName;
	
	@Transient
	private String receiverName;
	
	@Transient
	private String roomName;
	
	public MsgIntercept() {

	}

	public MsgIntercept(ObjectId id, String sender, String receiver, String roomJid, String content,
			long createTime) {
		super();
		this.id = id;
		this.sender = sender;
		this.receiver = receiver;
		this.roomJid = roomJid;
		this.content = content;
		this.createTime = createTime;
	}
	
}
