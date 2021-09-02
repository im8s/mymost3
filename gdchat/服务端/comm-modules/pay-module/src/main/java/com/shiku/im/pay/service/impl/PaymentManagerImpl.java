package com.shiku.im.pay.service.impl;

import com.alipay.api.AlipayApiException;
import com.alipay.api.internal.util.AlipaySignature;
import com.alipay.util.AliPayUtil;
import com.shiku.im.common.service.PaymentManager;
import com.shiku.im.pay.dao.ConsumeRecordDao;
import com.shiku.im.pay.dao.impl.TransferDaoImpl;
import com.shiku.im.pay.dto.BillRecordCountDTO;
import com.shiku.im.pay.entity.BaseConsumeRecord;
import com.shiku.im.pay.model.AliPayConfig;
import com.shiku.im.pay.service.PayRedisService;
import com.shiku.im.pay.utils.PayPassword;
import com.shiku.im.user.config.WXConfig;
import com.wxpay.utils.HttpUtils;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * @Description: TODO (common-api 支付实现类)
 *
 * @Date 2019/12/2
 **/
@Service
public class PaymentManagerImpl implements PaymentManager, CommandLineRunner {

    @Autowired
    private ConsumeRecordManagerImpl consumeRecordManager;

    @Autowired
    private ConsumeRecordDao consumeRecordDao;

    @Autowired
    private TransferDaoImpl transferDao;

    @Autowired
    private PayRedisService payRedisService;

    @Autowired
	private AliPayConfig aliPayConfig;

    @Autowired
    private WXConfig wxConfig;


    @Override
    public Object recharge(int userId, int type, int page, int limit, String startDate, String endDate, String tradeNo) {
        return consumeRecordManager.recharge(userId, type, page, limit, startDate, endDate, tradeNo);
    }

    @Override
    public void addConsumRecord(BaseConsumeRecord consumeRecord) {
        consumeRecordDao.addConsumRecord(consumeRecord);
    }

    @Override
    public void savaConsumeRecor(BaseConsumeRecord consumeRecord) {
        consumeRecordDao.save(consumeRecord);
    }

    @Override
    public Object consumeRecordList(Integer userId, int page, int limit, byte state, String startDate, String endDate, int type) {
        return consumeRecordManager.consumeRecordList(userId, page, limit, (byte) 1,startDate,endDate,type);
    }

    @Override
    public Object getConsumeRecordByTradeNo(String tradeNo) {
        return consumeRecordManager.getConsumeRecordByTradeNo(tradeNo);
    }

    @Override
    public Object payment(int userId, int type, int page, int limit, String startDate, String endDate) {
        return consumeRecordManager.payment(userId, type, page, limit, startDate, endDate);
    }

    @Override
    public Object getTransferTimeOut(long currentTime, int status) {
        return transferDao.getTransferTimeOut(currentTime,status);
    }

    @Override
    public void updateTransferTimeOut(long currentTime, int status, Map<String, Object> map) {
        transferDao.updateTransferTimeOut(currentTime,status,map);
    }

    @Override
    public Object getTransfer(ObjectId id) {
        return transferDao.getTransfer(id);
    }

    @Override
    public void saveConsumeRecord(Object obj) {
        BaseConsumeRecord entity = (BaseConsumeRecord) obj;
        if(null==entity.getId())
            consumeRecordDao.addConsumRecord(entity);
        else
            consumeRecordDao.updateConsumeRecord(entity.getId(),entity);
    }

    @Override
    public Object getTransferList(int pageIndex, int pageSize, String keyword, String startDate, String endDate) {
        return transferDao.getTransferList(pageIndex,pageSize,keyword,startDate,endDate);
    }

    @Override
    public void deleteConsumRecordByUserId(Integer userId) {
        consumeRecordDao.deleteConsumRecordByUserId(userId);
    }

    @Override
    public boolean cleanTransactionSignCode(int userId, String codeId) {
        return payRedisService.cleanTransactionSignCode(userId,codeId);
    }

    @Override
    public String queryTransactionSignCode(int userId, String codeId) {
        return payRedisService.queryTransactionSignCode(userId,codeId);
    }

    @Override
    public void saveTransactionSignCode(int userId, String codeId, String code) {
        payRedisService.saveTransactionSignCode(userId,codeId,code);
    }

    @Override
    public String encodeFromOldPassword(String userId, String oldPassword) {
        return PayPassword.encodeFromOldPassword(userId +"",oldPassword);
    }

    @Override
    public Map<String, String> getAccountNumber() {
        Map<String, String> data = new HashMap<>();
        String appid = AliPayUtil.APP_ID;
        String pid = AliPayUtil.PID;
        String appPrivateKey = AliPayUtil.APP_PRIVATE_KEY;
        String chanrse = AliPayUtil.CHARSET;
        data.put("appid",appid);
        data.put("pid",pid);
        data.put("appPrivateKey",appPrivateKey);
        data.put("chanrse",chanrse);
        return data;
    }

    @Override
    public String getRsaSign(String content, String appPrivateKey, String chanrse, String str) {
        try {
            return  AlipaySignature.rsaSign(content, appPrivateKey,chanrse, str);
        } catch (AlipayApiException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public Object consumeRecordList(Integer userId,int page,int limit,byte state){
        return consumeRecordManager.consumeRecordList(userId,page,limit,state);
    }
    @Override
    public BillRecordCountDTO queryCashGroupCount(long startTime, long endTime){
        return consumeRecordDao.queryCashGroupCount(startTime,endTime);


    }
    @Override
    public String queryRechargeGroupCount(long startTime, long endTime){
        return consumeRecordDao.queryRechargeGroupCount(startTime,endTime);
    }


    @Override
    public void run(String... args) throws Exception {
        AliPayUtil.setAppConfig(aliPayConfig);
        HttpUtils.setWxConfig(wxConfig);

        /**
         * 初始化 changeType
         */
        consumeRecordDao.initRecordChangeType();
    }
}
