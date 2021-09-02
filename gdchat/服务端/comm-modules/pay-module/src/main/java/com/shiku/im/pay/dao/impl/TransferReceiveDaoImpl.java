package com.shiku.im.pay.dao.impl;

import com.shiku.im.pay.dao.TransferReceiveDao;
import com.shiku.im.pay.entity.TransferReceive;
import com.shiku.im.repository.MongoRepository;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class TransferReceiveDaoImpl extends MongoRepository<TransferReceive, ObjectId> implements TransferReceiveDao {


    @Override
    public Class<TransferReceive> getEntityClass() {
        return TransferReceive.class;
    }

    @Override
    public void addTransferReceive(TransferReceive entity) {
        getDatastore().save(entity);
    }

    @Override
    public List<TransferReceive> getTransferReceiveList(int userId, int pageIndex, int pageSize) {
        Query query =createQuery("userId",userId);
        if(0 != pageSize){
            query.with(createPageRequest(pageIndex,pageSize));
        }
        descByquery(query,"time");
        return queryListsByQuery(query);
    }


}
