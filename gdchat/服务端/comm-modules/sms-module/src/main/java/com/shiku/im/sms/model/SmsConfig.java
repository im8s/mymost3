package com.shiku.im.sms.model;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "smsconfig")
public class SmsConfig {

    private int openSMS = 1;// 是否发送短信验证码
    // 天天国际短信服务
    private String host;
    private int port;
    private String api;
    private String username;// 短信平台用户名
    private String password;// 短信平台密码
    private String templateChineseSMS;// 中文短信模板
    private String templateEnglishSMS;// 英文短信模板
    // 阿里云短信服务
    private String product;// 云通信短信API产品,无需替换
    private String domain;// 产品域名,无需替换
    private String accesskeyid;// AK key
    private String accesskeysecret;// AK value
    private String signname;// 短信签名
    private String chinase_templetecode;// 中文短信模板标识
    private String international_templetecode;// 国际短信模板
    private String cloudWalletVerification;// 云钱包开户短信验证码模板标识
    private String cloudWalletNotification;// 云钱包开户通知短信模板

}
