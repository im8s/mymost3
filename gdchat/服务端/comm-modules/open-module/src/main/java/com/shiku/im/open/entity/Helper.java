package com.shiku.im.open.entity;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import org.bson.types.ObjectId;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@ApiModel("群助手实体类")
@Data
@Document(value = "helper")
public class Helper {
	@ApiModelProperty("编号")
	private @Id ObjectId id;
	@ApiModelProperty("App编号")
	private String openAppId;
	@ApiModelProperty("标题")
	private String name;// 标题
	@ApiModelProperty("描述")
	private String desc;// 描述
	@ApiModelProperty("图标")
	private String iconUrl;// 图标
	@ApiModelProperty("开发者")
	private String developer;// 开发者
	@ApiModelProperty("地址")
	private String link;// 地址
	@ApiModelProperty("富文本")
	private Other other;// 富文本
	@ApiModelProperty("群助手类型\t1:自动回复  2:网页链接  3:富文本")
	private Integer type;// 群助手类型	1:自动回复  2:网页链接  3:富文本
	@ApiModelProperty("创建时间")
	private long createTime;// 创建时间
	@ApiModelProperty("android app包名  type=2、3 时会有")
	private String appPackName;// android app包名  type=2、3 时会有
	@ApiModelProperty("android回调类 type=2、3时会有")
	private String callBackClassName;// android回调类 type=2、3时会有
	@ApiModelProperty("ios跳转必填参数 URL Scheme")
	private String iosUrlScheme;//ios跳转必填参数 URL Scheme

	@ApiModel("其他")
	@Data
	public static class Other{
		@ApiModelProperty("标题")
		private String title;
		@ApiModelProperty("副标题")
		private String subTitle;
		@ApiModelProperty("路径")
		private String url;
		@ApiModelProperty("图片路径")
		private String imageUrl;
		@ApiModelProperty("app图像")
		private String appIcon;
		@ApiModelProperty("app名称")
		private String appName;
		@ApiModelProperty("app下载地址")
		private String downloadUrl;
	}
}
