package com.shiku.im.dto;

import com.shiku.im.entity.ClientConfig;
import lombok.Data;

@Data
public class ClientConfigDto extends ClientConfig {
    public static final String SECRET_VALUE = "Bax3bE578o98DSJfGq";
    private String secret;
    private String access_token;
}
