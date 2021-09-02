package com.shiku.im.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

/**
 * rocketmq  的 配置
 *
 * 
 *
 */
@Getter
@Setter
@Configuration
public  class MQConfig {
    @Value("${rocketmq.name-server}")
    protected String nameAddr="localhost:9876";

    @Value("${rocketmq.producer.access-key:PAK}")
    protected String producerAccesskey="AK";

    @Value("${rocketmq.producer.secret-key:PSK}")
    protected String producerSecretkey="SK";

    @Value("${rocketmq.consumer.access-key:PAK}")
    protected String consumerAccesskey="AK";

    @Value("${rocketmq.consumer.secret-key:PSK}")
    protected String consumerSecretkey="SK";


}