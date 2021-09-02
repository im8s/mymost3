package com.shiku.im.user.entity;

import com.shiku.utils.DateUtil;
import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.HashSet;
import java.util.Set;

/**
 * 
 *用户 权限验证数据表
 */
@Data
@Document(value = "auth_keys")
public class AuthKeys {

	public  AuthKeys(){

	}
	public  AuthKeys(int userId){
		this.userId=userId;
		this.createTime= DateUtil.currentTimeSeconds();
	}
	@Id
	private int userId;
	/**
	 * 用户登陆密码
	 */
	private String password;
	
	private long createTime;
	
	private long modifyTime;


	/**
	 * 登陆钥匙对
	 */
	private KeyPair loginKeyPair;

	/**
	 * 支付钥匙对
	 */
	private KeyPair payKeyPair;
	
	/**
	 *消息DH钥匙对
	 */
	private KeyPair msgDHKeyPair;
	/**
	 *消息DH公钥列表
	 */
	private Set<PublicKey> dhMsgKeyList=new HashSet<PublicKey>();
	/**
	 *消息RSA钥匙对
	 */
	private KeyPair msgRsaKeyPair;

	/**
	 * 用户支付密码
 	 */
	private String payPassword;

	/**
	 * 微信 openId
	 */
	private String wxOpenId;

	/**
	 * 支付宝用户Id
	 */
	private String aliUserId;

	/**
	 * 易宝支付用户钱包账户ID
	 */
	private String walletUserNo;

	/**
	 * 易宝支付账户钱包等级
	 */
	private String walletCategory;
	
	@Data
	public static class PublicKey{
		private long time;
		private String key;
	}

	@Data
	public static class KeyPair{
		private  String publicKey;
		private String  privateKey;
		private long createTime;
		private long modifyTime;
		public KeyPair(){

		}
		public 	KeyPair(String publicKey,String privateKey){
			this.publicKey=publicKey;
			this.privateKey=privateKey;
		}
	}
	
	
}
