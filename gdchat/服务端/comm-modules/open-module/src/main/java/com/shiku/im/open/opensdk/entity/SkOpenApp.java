package com.shiku.im.open.opensdk.entity;

import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import org.bson.types.ObjectId;

import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * 
 * @Description: TODO(app应用)
 * 
 * @date 2018年10月29日 下午4:42:19
 * @version V1.0
 */
@ApiModel("app应用")
@Getter
@Setter
@Document(value = "SkOpenApp")
public class SkOpenApp {
	
	@Id
	@ApiModelProperty("记录id")
	private  ObjectId id; //记录id
	
	/**
	 * 账号ID
	 */
	@ApiModelProperty("账号ID")
	private String accountId;
	@ApiModelProperty("创建时间")
	private Long createTime;
	@ApiModelProperty("首次时间")
	private Long modifyTime;
	
	/**
	 * 应用名称
	 */
	@ApiModelProperty("应用名称")
	private String appName;
	/**
	 * 应用简介
	 */
	@ApiModelProperty("应用简介")
	private String appIntroduction;
	/**
	 * 应用官网
	 */
	@ApiModelProperty("应用官网")
	private String appUrl;
	
	/**
	 * 网站信息扫描件
	 */
	@ApiModelProperty("网站信息扫描件")
	private String webInfoImg;
	
	/**
	 * 应用小 图片 28*28
	 */
	@ApiModelProperty("应用小 图片 28*28")
	private String appsmallImg;
	/**
	 * 应用大图片 108*108
	 */
	@ApiModelProperty("应用大图片 108*108")
	private String appImg;
	/**
	 * appId
	 */
	@ApiModelProperty("appId")
	private String appId;
	/**
	 * appSecret
	 */
	@ApiModelProperty("appSecret")
	private String appSecret;
	/**
	 * 分享权限  0 未获得  1 已获得   2 申请中
	 */
	@ApiModelProperty("分享权限  0 未获得  1 已获得   2 申请中")
	private Byte isAuthShare = 0;
	/**
	 * 登陆权限 0 未获得  1 已获得   2 申请中
	 */
	@ApiModelProperty("登陆权限 0 未获得  1 已获得   2 申请中")
	private Byte isAuthLogin = 0;
	/**
	 * 支付权限 0 未获得  1 已获得   2 申请中
	 */
	@ApiModelProperty("支付权限 0 未获得  1 已获得   2 申请中")
	private Byte isAuthPay = 0;
	
	/**
	 * 是否开启群助手  0 未开启  1已开启  2 申请中
	 */
	@ApiModelProperty("是否开启群助手  0 未开启  1已开启  2 申请中")
	private Byte isGroupHelper = 0;
	@ApiModelProperty("群助手名称")
	private String helperName;// 群助手名称
	@ApiModelProperty("群助手描述")
	private String helperDesc;// 群助手描述
	@ApiModelProperty("群助手开发者")
	private String helperDeveloper;// 群助手开发者

	/**
	 * 支付回调域名
	 */
	@ApiModelProperty("支付回调域名")
	private String payCallBackUrl;
	
	/**
	 * 状态 0 审核中 1正常 -1禁用 下架  2审核失败
	 */
	@ApiModelProperty("状态 0 审核中 1正常 -1禁用 下架  2审核失败")
	private Byte status = 0;
	/**
	 * IOs Bundle ID
	 */
	@ApiModelProperty("IOs Bundle ID")
	private String iosAppId;
	/**
	 * 测试版本Bundle ID
	 */
	@ApiModelProperty("测试版本Bundle ID")
	private String iosBataAppId;
	/**
	 * Ios 下载地址
	 */
	@ApiModelProperty("Ios 下载地址")
	private String iosDownloadUrl;
	
	/**
	 * android应用包名
	 */
	@ApiModelProperty("android应用包名")
	private String androidAppId;
	
	/**
	 * android下载地址
	 */
	@ApiModelProperty("android下载地址")
	private String androidDownloadUrl;
	/**
	 * 安卓应用签名
	 */
	@ApiModelProperty("安卓应用签名")
	private String androidSign;
	
	/**
	 * 网页应用授权回调域
	 */
	@ApiModelProperty("网页应用授权回调域")
	private String callbackUrl;
	
	/**
	 * 网站类型  1：app  2:网页
	 */
	@ApiModelProperty("网站类型  1：app  2:网页")
	private Byte appType = 0;
	
	public SkOpenApp(SkOpenApp skOpenApp) {
		if (!StringUtil.isEmpty(skOpenApp.getAndroidAppId()))
			this.androidAppId = skOpenApp.getAndroidAppId();
		if (!StringUtil.isEmpty(skOpenApp.getAndroidDownloadUrl()))
			this.androidDownloadUrl = skOpenApp.getAndroidDownloadUrl();
		if (!StringUtil.isEmpty(skOpenApp.getAndroidSign()))
			this.androidSign = skOpenApp.getAndroidSign();
		if (!StringUtil.isEmpty(skOpenApp.getAppIntroduction()))
			this.appIntroduction = skOpenApp.getAppIntroduction();
		if(!StringUtil.isEmpty(skOpenApp.getWebInfoImg())){
			this.webInfoImg = skOpenApp.getWebInfoImg();
		}
		if(!StringUtil.isEmpty(skOpenApp.getCallbackUrl())){
			this.callbackUrl = skOpenApp.getCallbackUrl();
		}
		this.accountId = skOpenApp.getAccountId();
		this.appName = skOpenApp.getAppName();
		this.createTime = DateUtil.currentTimeSeconds();
		this.modifyTime = DateUtil.currentTimeSeconds();
		this.appUrl = skOpenApp.getAppUrl();
		this.appsmallImg = skOpenApp.getAppsmallImg();
		this.appImg = skOpenApp.getAppImg();
		this.iosAppId = skOpenApp.getIosAppId();
		this.iosBataAppId = skOpenApp.getIosBataAppId();
		this.iosDownloadUrl = skOpenApp.getIosDownloadUrl();
		this.appType = skOpenApp.getAppType();
	}


	public SkOpenApp() {
		
	}
	
}
