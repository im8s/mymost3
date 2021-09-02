package com.shiku.im.push.autoconfigure;


import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Setter
@Getter
@Configuration
@ConfigurationProperties(prefix="pushconfig")
public class PushConfig {



    // 服务器地区 例  CN、HK
    private String serverAdress="CN";

    private String packageName;

    // 小米
    private String xm_appSecret;

    // 华为
    private String hw_appSecret;
    private String hw_appId;
    private String hw_tokenUrl;
    private String hw_apiUrl;
    private String hw_iconUrl;
    private byte IsOpen;// 是否使用单独部署华为推送   1是    0：否

    // 百度
    private String bd_appStore_appId;
    private String bd_appStore_appKey;
    private String bd_appStore_secret_key;
    private String[] bd_appKey;
    private String bd_rest_url;
    private String[] bd_secret_key;

    // 极光
    private String jPush_appKey;
    private String jPush_masterSecret;

    // google FCM
    private String FCM_dataBaseUrl;
    private String FCM_keyJson;

    // 魅族
    private String mz_appSecret;
    private long mz_appId;

    // VIVO
    private int vivo_appId;
    private String vivo_appKey;
    private String vivo_appSecret;

    // OPPO
    private String oppo_appKey;
    private String oppo_masterSecret;

    //企业版 测试版 apns 推送证书
    private String betaApnsPk;

    //appStore 版本 App 包名
    private String appStoreAppId;
    //appStore apns 推送证书
    private String appStoreApnsPk;

    //voip 证书
    private String voipPk;

    //证书 密码
    private String pkPassword;

    private byte isApnsSandbox=0;

    //调试模式  打印 log
    private byte isDebug=0;

    // 企业版 app 包名
    protected String betaAppId;


}
