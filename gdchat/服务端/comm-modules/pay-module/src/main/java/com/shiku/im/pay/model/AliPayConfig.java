package com.shiku.im.pay.model;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "alipayconfig")
public  class AliPayConfig{
    // 支付宝认证应用Id
    private String appid;
    // 应用私钥
    private String app_private_key;
    // 字符编码格式
    private String charset;
    // 支付宝公钥
    private String alipay_public_key;
    // 支付宝回调地址
    private String callBackUrl;
    // 账户pid
    private String pid;
}
