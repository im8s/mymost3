package com.shiku.xmpppush.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "imconfig")
public  class IMConfig {
    private String host;

    private int port;

    private long pingTime;

    private String serverToken;
}