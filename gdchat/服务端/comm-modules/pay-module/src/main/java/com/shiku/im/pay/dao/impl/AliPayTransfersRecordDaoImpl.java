package com.shiku.im.pay.dao.impl;
import com.shiku.im.pay.dao.AliPayTransfersRecordDao;
import com.shiku.im.pay.entity.AliPayTransfersRecord;
import com.shiku.im.repository.MongoRepository;
import org.bson.types.ObjectId;
import org.springframework.stereotype.Repository;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/4 9:47
 */
@Repository
public class AliPayTransfersRecordDaoImpl extends MongoRepository<AliPayTransfersRecord, ObjectId> implements AliPayTransfersRecordDao {



    @Override
    public Class<AliPayTransfersRecord> getEntityClass() {
        return AliPayTransfersRecord.class;
    }

    @Override
    public void addAliPayTransfersRecord(AliPayTransfersRecord aliPayTransfersRecord) {
        getDatastore().save(aliPayTransfersRecord);
    }
}
