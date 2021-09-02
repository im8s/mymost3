package com.shiku.im.api.service;

import com.alibaba.fastjson.JSON;
import com.shiku.redisson.AbstractRedisson;
import lombok.extern.slf4j.Slf4j;
import org.redisson.api.RedissonClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

@Service
@Slf4j
public class IdempotenceApiService extends AbstractRedisson {

    @Autowired(required = false)
    private RedissonClient redissonClient;

    @Override
    public RedissonClient getRedissonClient() {
        return redissonClient;
    }


    /**
     * api幂等数据临时存储key + API_MAC_KEY("api:mac:${userId}:${url + api req secret}")
     */
    public static final String GLOBAL_IDEMPOTENCE_API_DATA = "global:idempotence:api:data:";

    /**
     * 获取存储接口幂等数据的redis key
     *
     * @param userId 用户id
     * @param mac    mac：url + api req secret
     */
    private String keyOfGlobalIdempotenceApiData(Integer userId, String mac) {
        return GLOBAL_IDEMPOTENCE_API_DATA + userId + ":" + mac;
    }

    /**
     * 获取接口幂等数据
     *
     * @param userId 用户id
     * @param mac    mac：url + api req secret
     */
    public Object getGlobalIdempotenceApiData(Integer userId, String mac) {
        String redisKey = this.keyOfGlobalIdempotenceApiData(userId, mac);
        log.info("【DEBUG-获取幂等缓存返回值】uid：[{}]，mac：[{}]，redisKey:[{}]", userId, mac, redisKey);
        Object result = redissonClient.getBucket(redisKey).get();
        if (null == result) {
            try {
                //休眠200再获取，防止业务请求还未完成时就发起请求
                Thread.sleep(200);
            } catch (InterruptedException e) {
                log.error(e.getMessage(), e);
            }
            return redissonClient.getBucket(this.keyOfGlobalIdempotenceApiData(userId, mac)).get();
        }
        return result;
    }

    /**
     * 添加接口幂等数据
     *
     * @param userId 用户id
     * @param mac    mac：url + api req secret
     */
    public void addGlobalIdempotenceApiData(Integer userId, String mac, Object data) {
        redissonClient.getBucket(this.keyOfGlobalIdempotenceApiData(userId, mac)).set(data, 3, TimeUnit.SECONDS);
    }
}
