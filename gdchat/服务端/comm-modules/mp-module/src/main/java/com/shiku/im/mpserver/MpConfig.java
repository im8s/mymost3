package com.shiku.im.mpserver;


import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;


@Setter
@Getter
@Configuration
@ConfigurationProperties(prefix="mpconfig")
public class MpConfig {
	// ,locations="classpath:application-test.properties" //外网测试环境
	// ,locations="classpath:application-local.properties" //本地测试环境
	//// application

	public MpConfig() {
		// TODO Auto-generated constructor stub
	}


	// 是否开启wss协议
	private int isOpenWss = 0;






}