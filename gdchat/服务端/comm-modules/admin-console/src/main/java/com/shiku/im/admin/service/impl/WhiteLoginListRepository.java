package com.shiku.im.admin.service.impl;

import cn.hutool.core.collection.CollectionUtil;
import cn.hutool.core.map.MapUtil;
import com.shiku.im.comm.utils.DateUtil;
import com.shiku.redisson.AbstractRedisson;
import org.redisson.api.RedissonClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class WhiteLoginListRepository extends AbstractRedisson {

    @Autowired(required = false)
    private RedissonClient redissonClient;

    @Override
    public RedissonClient getRedissonClient() {
        return redissonClient;
    }


    /**
     * pc登录白名单ip列表
     */
    public static final String PC_LOGIN_WHITELIST = "pc:login:whitelist:ip";

    /**
     * 管理后台登录白名单ip列表
     */
    public static final String ADMIN_LOGIN_WHITELIST = "admin:login:whitelist:ip";

    /**
     * 登录白名单
     * @return map: key(0-pc,1-管理后台)
     */
    public Map<Integer, List<String>> getLoginWhitelist() {
        Collection<Object> pcList = redissonClient.getScoredSortedSet(PC_LOGIN_WHITELIST).readAll();
        Collection<Object> adminList = redissonClient.getScoredSortedSet(ADMIN_LOGIN_WHITELIST).readAll();
        return MapUtil.<Integer, List<String>>builder()
                .put(0, pcList.stream().map(o -> o+"").collect(Collectors.toList()))
                .put(1, adminList.stream().map(o -> o+"").collect(Collectors.toList()))
                .build();
    }

    public boolean addLoginWhitelist(String ip, int type) {
        return redissonClient.getScoredSortedSet(0 == type ? PC_LOGIN_WHITELIST : ADMIN_LOGIN_WHITELIST).add(DateUtil.currentTimeSeconds(), ip);
    }

    public boolean delLoginWhitelist(String ip, int type) {
        return redissonClient.getScoredSortedSet(0 == type ? PC_LOGIN_WHITELIST : ADMIN_LOGIN_WHITELIST).remove(ip);
    }

}
