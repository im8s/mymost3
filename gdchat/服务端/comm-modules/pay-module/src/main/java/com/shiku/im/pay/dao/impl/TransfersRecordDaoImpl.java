package com.shiku.im.pay.dao.impl;

import com.shiku.im.pay.dao.TransfersRecordDao;
import com.shiku.im.pay.entity.TransfersRecord;
import com.shiku.im.repository.MongoRepository;
import org.bson.types.ObjectId;
import org.springframework.stereotype.Repository;

@Repository
public class TransfersRecordDaoImpl extends MongoRepository<TransfersRecord, ObjectId> implements TransfersRecordDao {

    @Override
    public Class<TransfersRecord> getEntityClass() {
        return TransfersRecord.class;
    }

    @Override
    public void addTransfersRecord(TransfersRecord entity) {
        getDatastore().save(entity);
    }


}
