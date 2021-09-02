package com.shiku.im.common.service;


import com.shiku.im.pay.dto.BillRecordCountDTO;
import com.shiku.im.pay.entity.BaseConsumeRecord;
import org.bson.types.ObjectId;

import java.util.Map;

/**
 * @Description: TODO（支付接口 功能）
 *
 * @Date 2019/12/2
 **/
public interface PaymentManager {

    public Object recharge(int userId, int type, int page, int limit, String startDate, String endDate, String tradeNo);

    public void addConsumRecord(BaseConsumeRecord consumeRecord);

    public void savaConsumeRecor(BaseConsumeRecord consumeRecord);

    public Object consumeRecordList(Integer userId, int page, int limit, byte state, String startDate, String endDate, int type);

    public Object getConsumeRecordByTradeNo(String tradeNo);

    public Object payment(int userId, int type, int page, int limit, String startDate, String endDate);

    public Object getTransferTimeOut(long currentTime, int status);

    void updateTransferTimeOut(long currentTime, int status, Map<String,Object> map);

    Object getTransfer(ObjectId id);

    public void saveConsumeRecord(Object entity);

    Object getTransferList(int pageIndex, int pageSize, String keyword, String startDate, String endDate);

    public void deleteConsumRecordByUserId(Integer userId);

    public boolean cleanTransactionSignCode(int userId,String codeId);

    public String queryTransactionSignCode(int userId,String codeId);

    public void saveTransactionSignCode(int userId,String codeId,String code);

    public String encodeFromOldPassword(String userId, String oldPassword);

    public Map<String,String> getAccountNumber();

    public String getRsaSign(String content,String appPrivateKey,String chanrse,String str);

    public Object consumeRecordList(Integer userId,int page,int limit,byte state);

    BillRecordCountDTO queryCashGroupCount(long startTime, long endTime);

    String queryRechargeGroupCount(long startTime, long endTime);
}
