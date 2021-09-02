package com.shiku.im.pay.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.pay.dto.BillRecordCountDTO;
import com.shiku.im.pay.dto.ConsumRecordCountDTO;
import com.shiku.im.pay.entity.BaseConsumeRecord;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Map;

public interface ConsumeRecordDao extends IMongoDAO<BaseConsumeRecord,ObjectId> {

    void addConsumRecord(BaseConsumeRecord consumeRecord);

    void updateConsumeRecord(ObjectId consumeRecordId, BaseConsumeRecord consumeRecord);

    BaseConsumeRecord getConsumeReCord(ObjectId id, Integer userId);

    BaseConsumeRecord getConsumeRecordByTradeNo(String tradeNo);

    BaseConsumeRecord getConsumRecord(String tradeNo, int status);

    List<BaseConsumeRecord> getConsumRecordList(int type, int userId, int pageIndex, int pageSize);

    PageResult<BaseConsumeRecord> getConsumRecordList(int userId, int type, String tradeNo, long startTime, long endTime, int pageIndex, int pageSize, byte state);

    PageResult<BaseConsumeRecord> getConsumRecordPayList(int userId, int type, long startTime, long endTime, int pageIndex, int pageSize, byte state);

    PageResult<BaseConsumeRecord> getConsumrecordList(int userId, double money, int status, int pageIndex, int pageSize, byte state);

    PageResult<BaseConsumeRecord> getConsumrecordList(int userId, int toUserId, double money, int status, int type, int pageIndex, int pageSize, byte state);

    PageResult<BaseConsumeRecord> queryConsumRecordList(int userId, int status, int type, long startTime, long endTime, int pageIndex, int pageSize, byte state);

    Map<String, Object> queryConsumRecord(int userId,int status,int type,long startTime,long endTime,int pageIndex,int pageSize,byte state);

    void deleteConsumRecordByUserId(Integer userId);
    double getUserPayMoney(int userId,int type,int status,long startTime, long endTime );


    ConsumRecordCountDTO queryConsumeRecordCount(int userId, long startTime, long endTime, int pageIndex, int pageSize,boolean needCount,boolean isNext);

    String queryRechargeGroupCount(long startTime, long endTime);

    BillRecordCountDTO queryCashGroupCount(long startTime, long endTime);

    /**
     * 初始化新加自动  ChangeType
     */
    void initRecordChangeType();
}
