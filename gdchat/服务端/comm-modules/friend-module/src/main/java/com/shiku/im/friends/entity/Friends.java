package com.shiku.im.friends.entity;

import com.alibaba.fastjson.annotation.JSONField;
import com.shiku.utils.DateUtil;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.index.CompoundIndexes;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.List;

@Document(value = "u_friends")
@CompoundIndexes(@CompoundIndex(name = "userId_toUserId",def = "{'userId':1,'toUserId':1}"))
public class Friends {

	public static String getDBName(){
		return "u_friends";
	}

	public static class Blacklist {
		public static final int No = 0;
		public static final int Yes = 1;
	}

	public static class Status {
		/** 关注 */
		public static final int Attention = 1; 
		/** 好友 */
		public static final int Friends = 2;
		/** 陌生人 */
		public static final int Stranger = 0;
	}

	private Integer blacklist=0;// 是否拉黑（1=是；0=否）
	
	private Integer isBeenBlack=0; //是否被拉黑（1=是；0=否）
	
	private Integer offlineNoPushMsg=0;//消息免打扰（1=是；0=否）
	

	private long createTime;// 建立关系时间
	@Id
	@JSONField(serialize = false) 
	private  ObjectId id;// 关系Id
	
	private long modifyTime;// 修改时间
	
	private long lastTalkTime; //最后沟通时间
	
	private long msgNum;//未读消息数量
	
	private String remarkName;// 备注
	
	private Integer status;// 状态（1=关注；2=好友；0=陌生人 ；-1=黑名单）
	
	private String toNickname;// 好友昵称
	
	private int toUserId;// 好友Id
	
	private int toUserType;// 好友的user type
	
	private List<Integer> toFriendsRole;// 好友的角色信息
	
	private int userId;// 用户Id
	
	@Transient
	private String nickname;// 自己的昵称
	
	//聊天记录过期时间  -1 为永久  数值 为天数。默认15天
	private double chatRecordTimeOut=0.0007;
	
	private String describe;// 描述
	
	private Integer fromAddType = 0;// 通过什么方式添加 0 : 系统添加好友  1:二维码 2：名片 3：群组 4: 手机号搜索 5:昵称搜索 
	
	private byte isOpenSnapchat = 0;// 是否开启阅后即焚 0：关闭，1：开启

	private long openTopChatTime = 0;// 开启置顶聊天时间
	

	/**
	 * dh 消息公钥
	 */
	@Transient
	private String dhMsgPublicKey;


	/**
	 * rsa 消息公钥
	 */
	@Transient
	private String rsaMsgPublicKey;

	//针对该好友的消息加密方式
	private byte  encryptType = 0; //0明文传输 1desed加密传输  2aes加密传输  3端到端加密传输


	public Friends() {
		super();
	}

	public Friends(int userId) {
		super();
		this.userId = userId;
	}

	public Friends(int userId, int toUserId) {
		super();
		this.userId = userId;
		this.toUserId = toUserId;
		this.createTime = DateUtil.currentTimeSeconds();
	}

	public Friends(int userId, int toUserId,String toNickname, Integer status) {
		super();
		this.userId = userId;
		this.toUserId = toUserId;
		this.toNickname=toNickname;
		this.status = status;
		this.createTime = DateUtil.currentTimeSeconds();
	}
	
	public Friends(int userId, int toUserId,String toNickname, Integer status,Integer toUserType,List<Integer> toFriendsRole) {
		super();
		this.userId = userId;
		this.toUserId = toUserId;
		this.toNickname=toNickname;
		this.status = status;
		this.createTime = DateUtil.currentTimeSeconds();
		this.toUserType = toUserType;
		this.toFriendsRole = toFriendsRole;
	}
	
	public Friends(int userId, int toUserId,String toNickname, Integer status, Integer blacklist,Integer isBeenBlack) {
		super();
		this.userId = userId;
		this.toUserId = toUserId;
		this.toNickname=toNickname;
		this.status = status;
		this.blacklist = blacklist;
		this.isBeenBlack=isBeenBlack;
		this.createTime = DateUtil.currentTimeSeconds();
	}
	
	public Friends(int userId, int toUserId,String toNickname, Integer status, Integer blacklist,Integer isBeenBlack,List<Integer> toUserRole,int toUserType,Integer fromAddType) {
		super();
		this.userId = userId;
		this.toUserId = toUserId;
		this.toNickname=toNickname;
		this.status = status;
		this.blacklist = blacklist;
		this.isBeenBlack=isBeenBlack;
		this.toFriendsRole=toUserRole;
		this.createTime = DateUtil.currentTimeSeconds();
		this.toUserType=toUserType;
		this.fromAddType=fromAddType;
	}
	
	public Friends(int userId, int toUserId,String toNickname, Integer status, Integer blacklist,Integer isBeenBlack,List<Integer> toUserRole,String toRemarkName,int toUserType) {
		super();
		this.userId = userId;
		this.toUserId = toUserId;
		this.toNickname=toNickname;
		this.status = status;
		this.blacklist = blacklist;
		this.isBeenBlack=isBeenBlack;
		this.toFriendsRole=toUserRole;
		this.createTime = DateUtil.currentTimeSeconds();
		this.remarkName = toRemarkName;
		this.toUserType=toUserType;
	}

	public Integer getBlacklist() {
		return blacklist;
	}

	public Integer getIsBeenBlack() {
		return isBeenBlack;
	}

	public void setIsBeenBlack(Integer isBeenBlack) {
		this.isBeenBlack = isBeenBlack;
	}


	public Integer getOfflineNoPushMsg() {
		return offlineNoPushMsg;
	}

	public void setOfflineNoPushMsg(Integer offlineNoPushMsg) {
		this.offlineNoPushMsg = offlineNoPushMsg;
	}

	public long getCreateTime() {
		return createTime;
	}

	public ObjectId getId() {
		return id;
	}

	public long getModifyTime() {
		return modifyTime;
	}

	public String getRemarkName() {
		return remarkName;
	}

	public Integer getStatus() {
		return status;
	}

	public String getToNickname() {
		return toNickname;
	}

	public int getToUserId() {
		return toUserId;
	}

	public int getUserId() {
		return userId;
	}

	public void setBlacklist(Integer blacklist) {
		this.blacklist = blacklist;
	}

	

	public void setCreateTime(long createTime) {
		this.createTime = createTime;
	}

	public void setId(ObjectId id) {
		this.id = id;
	}

	public void setModifyTime(long modifyTime) {
		this.modifyTime = modifyTime;
	}

	public void setRemarkName(String remarkName) {
		this.remarkName = remarkName;
	}

	public void setStatus(Integer status) {
		this.status = status;
	}

	public void setToNickname(String toNickname) {
		this.toNickname = toNickname;
	}

	public void setToUserId(int toUserId) {
		this.toUserId = toUserId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public long getLastTalkTime() {
		return lastTalkTime;
	}

	public void setLastTalkTime(long lastTalkTime) {
		this.lastTalkTime = lastTalkTime;
	}

	public long getMsgNum() {
		return msgNum;
	}

	public void setMsgNum(long msgNum) {
		this.msgNum = msgNum;
	}

	public double getChatRecordTimeOut() {
		return chatRecordTimeOut;
	}

	public void setChatRecordTimeOut(double chatRecordTimeOut) {
		this.chatRecordTimeOut = chatRecordTimeOut;
	}

	public List<Integer> getToFriendsRole() {
		return toFriendsRole;
	}

	public void setToFriendsRole(List<Integer> toFriendsRole) {
		this.toFriendsRole = toFriendsRole;
	}

	public String getNickname() {
		return nickname;
	}

	public void setNickname(String nickname) {
		this.nickname = nickname;
	}

	public int getToUserType() {
		return toUserType;
	}

	public void setToUserType(int toUserType) {
		this.toUserType = toUserType;
	}

	public String getDescribe() {
		return describe;
	}

	public void setDescribe(String describe) {
		this.describe = describe;
	}

	public Integer getFromAddType() {
		return fromAddType;
	}

	public void setFromAddType(Integer fromAddType) {
		this.fromAddType = fromAddType;
	}

	/**
	 * @return the isOpenSnapchat
	 */
	public byte getIsOpenSnapchat() {
		return isOpenSnapchat;
	}

	/**
	 * @param isOpenSnapchat the isOpenSnapchat to set
	 */
	public void setIsOpenSnapchat(byte isOpenSnapchat) {
		this.isOpenSnapchat = isOpenSnapchat;
	}

	public long getOpenTopChatTime() {
		return openTopChatTime;
	}

	public void setOpenTopChatTime(long openTopChatTime) {
		this.openTopChatTime = openTopChatTime;
	}

	public String getDhMsgPublicKey() {
		return dhMsgPublicKey;
	}

	public void setDhMsgPublicKey(String dhMsgPublicKey) {
		this.dhMsgPublicKey = dhMsgPublicKey;
	}

	public String getRsaMsgPublicKey() {
		return rsaMsgPublicKey;
	}

	public void setRsaMsgPublicKey(String rsaMsgPublicKey) {
		this.rsaMsgPublicKey = rsaMsgPublicKey;
	}

	public byte getEncryptType() {
		return encryptType;
	}

	public void setEncryptType(byte encryptType) {
		this.encryptType = encryptType;
	}




}