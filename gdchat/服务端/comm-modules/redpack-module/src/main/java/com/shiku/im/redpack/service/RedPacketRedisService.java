package com.shiku.im.redpack.service;

import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.utils.NumberUtil;
import com.shiku.im.comm.utils.RandomUtil;
import com.shiku.im.redpack.entity.RedPacket;
import com.shiku.im.redpack.entity.RedReceive;
import com.shiku.im.vo.JSONMessage;
import com.shiku.redisson.AbstractRedisson;
import com.shiku.redisson.LockCallBack;
import org.redisson.api.RList;
import org.redisson.api.RedissonClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.TimeUnit;


@Service
public class RedPacketRedisService extends AbstractRedisson {

    @Autowired
    private RedissonClient redissonClient;

    @Override
    public RedissonClient getRedissonClient() {
        return redissonClient;
    }




    private static final String REDPACK_KEY = "redpack:record:%s";

    /**
     * 红包领取列表
     */
    private static final String REDPACK_RECEIVE_LIST = "redpack:receivelist:%s";



    public RedPacket queryRedPacket(String redPacketId){
        String redisKey = buildRedisKey(REDPACK_KEY, redPacketId);
        return getBucket(RedPacket.class,redisKey);
    }

    public void saveRedPacket(String redPacketId, RedPacket redPacket){
        String redisKey = buildRedisKey(REDPACK_KEY, redPacketId);
        setBucket( redisKey,redPacket,KConstants.Expire.HOUR12);
    }

    public void deleteRedPacket(String redPacketId){
        String redisKey = buildRedisKey(REDPACK_KEY, redPacketId);
        getRedissonClient().getBucket(redisKey).delete();
    }


    public List<RedReceive> queryReceiveList(String redPacketId){
        String redisKey = buildRedisKey(REDPACK_RECEIVE_LIST, redPacketId);
        RList<RedReceive> rList = getRedissonClient().getList(redisKey);
       return rList.readAll();
    }

    public void saveReceiveList(String redPacketId,List<RedReceive> list){
        String redisKey = buildRedisKey(REDPACK_RECEIVE_LIST, redPacketId);
        RList<RedReceive> rList = getRedissonClient().getList(redisKey);
        rList.clear();
        rList.addAll(list);

       expire(rList,KConstants.Expire.HOUR12);
    }

    public void deleteReceiveList(String redPacketId){
        String redisKey = buildRedisKey(REDPACK_RECEIVE_LIST, redPacketId);
        getRedissonClient().getBucket(redisKey).delete();
    }



}
