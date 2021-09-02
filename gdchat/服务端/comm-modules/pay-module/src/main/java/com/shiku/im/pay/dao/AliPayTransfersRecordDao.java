package com.shiku.im.pay.dao;

import com.shiku.im.pay.entity.AliPayTransfersRecord;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

public interface AliPayTransfersRecordDao extends IMongoDAO<AliPayTransfersRecord, ObjectId> {

    void addAliPayTransfersRecord(AliPayTransfersRecord aliPayTransfersRecord);
}
