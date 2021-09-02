package com.shiku.im.user.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "wxconfig")
public  class WXConfig {
    // 微信认证的自己应用ID
    private String appid;
    // 商户ID
    private String mchid;
    // App secret
    private String secret;
    // api  API密钥
    private String apiKey;
    //
    /**
     * 微信支付 回调 通知 url
     * 默认   http://imapi.server.com/user/recharge/wxPayCallBack
     *
     */
    private String callBackUrl;
    //证书文件 名称
    private String pkPath;
}