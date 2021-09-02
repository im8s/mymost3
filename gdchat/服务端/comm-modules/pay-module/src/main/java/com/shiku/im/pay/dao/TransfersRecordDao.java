package com.shiku.im.pay.dao;

import com.shiku.im.pay.entity.TransfersRecord;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

/**
 * 提现记录
 */
public interface TransfersRecordDao extends IMongoDAO<TransfersRecord, ObjectId> {

    void addTransfersRecord(TransfersRecord entity);

}
