package com.shiku.im.pay.service;


import com.shiku.im.comm.constants.KConstants;
import com.shiku.redisson.AbstractRedisson;
import org.redisson.api.RBucket;
import org.redisson.api.RedissonClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

@Service
public class PayRedisService extends AbstractRedisson {

    @Autowired(required=false)
    private RedissonClient redissonClient;

    @Override
    public RedissonClient getRedissonClient() {
        return redissonClient;
    }

    /**
     * 支付相关接口  请求随机码  code
     */
    public static final String PAY_TRANSACTION_CODE = "transaction:%s:%s";

    /**
     * 对外支付加签结果
     */
    public static final String PAY_ORDER_SIGN = "payOrderSign:%s";




    /**
     * 维护sign
     * @param orderId
     * @param sign
     */
    public void savePayOrderSign(String orderId,String sign){
        String key = String.format(PAY_ORDER_SIGN, orderId);
        RBucket<Object> rbucket = redissonClient.getBucket(key);
        rbucket.set(sign, KConstants.Expire.DAY1, TimeUnit.SECONDS);
    }

    /**
     * 通过orderId获取sign
     * @param orderId
     * @return
     */
    public String queryPayOrderSign(String orderId){
        String key = String.format(PAY_ORDER_SIGN,orderId);
        RBucket<String> bucket = redissonClient.getBucket(key);
        return bucket.get();
    }



    /**
     * @param userId
     * @param code
     */
    public void saveTransactionSignCode(int userId,String codeId,String code){
        String key = String.format(PAY_TRANSACTION_CODE, userId,codeId);
        RBucket<Object> rbucket = redissonClient.getBucket(key);
        rbucket.set(code,KConstants.Expire.MINUTE, TimeUnit.SECONDS);
    }

    /**
     * @param userId
     * @param code
     * @return
     */
    public String queryTransactionSignCode(int userId,String codeId){
        String key = String.format(PAY_TRANSACTION_CODE, userId,codeId);
        RBucket<String> bucket = redissonClient.getBucket(key);
        return bucket.get();
    }
    public boolean cleanTransactionSignCode(int userId,String codeId){
        String key = String.format(PAY_TRANSACTION_CODE, userId,codeId);
        RBucket<String> bucket = redissonClient.getBucket(key);
        return bucket.delete();
    }


    /**
     * 获取用户支付码
     * @param paymentCode
     * @return
     */
    public Integer getPaymentCode(String paymentCode){
        String key=paymentCode;
        RBucket<Integer> bucket = redissonClient.getBucket(key);
        return bucket.get();
    }

    /**
     * 保存用户支付码
     * @param paymentCode
     * @param userId
     */
    public void savePaymentCode(String paymentCode,Integer userId){
        String key=paymentCode;
        RBucket<Object> bucket = redissonClient.getBucket(key);
        bucket.set(userId, 600, TimeUnit.SECONDS);// 保存10分钟
    }





    /**
     * 二维码付款 支付    payQrKey:userId
     */
    public static final String PAY_QRKEY = "payQrKey:%s";

    public void savePayQrKey(int userId,String qrKey){
        String key = buildRedisKey(PAY_QRKEY, userId);
        setBucket(key,qrKey,KConstants.Expire.DAY1);
    }
    public String queryPayQrKey(int userId){
        String key = buildRedisKey(PAY_QRKEY, userId);
        RBucket<String> bucket = redissonClient.getBucket(key);
        return bucket.get();
    }
    public boolean cleanPayQrKey(int userId){
        return deleteBucket(PAY_QRKEY,userId);
    }



}
