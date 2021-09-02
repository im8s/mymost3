package com.shiku.im.user.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "wxpublicconfig")
public class WXPublicConfig {

    // 公众号appId
    private String appId;
    // 公众号appSecret
    private String appSecret;
}
