package com.shiku.im.repository;

import com.alibaba.fastjson.JSON;
import com.shiku.im.entity.ClientConfig;
import com.shiku.im.entity.Config;
import com.shiku.im.entity.PayConfig;
import com.shiku.redisson.AbstractRedisson;
import com.shiku.utils.StringUtil;
import org.redisson.api.RedissonClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository
public class CoreRedisRepository extends AbstractRedisson {

    @Autowired
    private RedissonClient redissonClient;

    @Override
    public RedissonClient getRedissonClient() {
        return redissonClient;
    }


    public static final String GET_CONFIG = "app:config";
    public static final String GET_CLIENTCONFIG = "clientConfig";
    public static final String GET_PAYCONFIG = "payConfig";


    public  void setConfig(Config config) {
        setBucket(GET_CONFIG, config.toString());
    }


    public  Config getConfig() {
        String config=getBucket(String.class,GET_CONFIG);
        return StringUtil.isEmpty(config) ? null : JSON.parseObject(config, Config.class);
    }
    public  ClientConfig getClientConfig() {
        String config=getBucket(String.class,GET_CLIENTCONFIG);
        return StringUtil.isEmpty(config) ? null : JSON.parseObject(config, ClientConfig.class);
    }

    public  void setClientConfig(ClientConfig clientConfig) {
         setBucket(GET_CLIENTCONFIG,JSON.toJSONString(clientConfig));
    }

    public void setPayConfig(PayConfig payConfig){
        setBucket(GET_PAYCONFIG,JSON.toJSONString(payConfig));
    }

    public PayConfig getPayConfig(){
        String config = getBucket(String.class,GET_PAYCONFIG);
        return StringUtil.isEmpty(config) ? null : JSON.parseObject(config,PayConfig.class);
    }
}
