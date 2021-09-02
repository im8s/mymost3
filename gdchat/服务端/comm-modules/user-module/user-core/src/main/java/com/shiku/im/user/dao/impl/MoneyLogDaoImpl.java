package com.shiku.im.user.dao.impl;

import com.shiku.im.repository.MongoRepository;
import com.shiku.im.user.dao.MoneyLogDao;
import com.shiku.im.user.entity.UserMoneyLog;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

@Repository
public class MoneyLogDaoImpl extends MongoRepository<UserMoneyLog, ObjectId> implements MoneyLogDao {

    @Override
    public Class<UserMoneyLog> getEntityClass() {
        return UserMoneyLog.class;
    }

    @Override
    public boolean saveMoneyLog(UserMoneyLog userMoneyLog) {
        userMoneyLog.setCreateTime(System.currentTimeMillis());
       return null!=getDatastore().save(userMoneyLog);
    }

    @Override
    public boolean isExistMoneyLogProcessed(UserMoneyLog userMoneyLog) {
        Query query =createQuery("userId",userMoneyLog.getUserId());
        addToQuery(query,"businessId",userMoneyLog.getBusinessId());
        addToQuery(query,"businessType",userMoneyLog.getBusinessType());
        addToQuery(query,"logType",userMoneyLog.getLogType());


        return getDatastore().exists(query,getEntityClass());

    }
    @Override
    public boolean isExistMoneyLogProcessed(UserMoneyLog userMoneyLog, byte logType) {
        Query query =createQuery("businessId",userMoneyLog.getBusinessId());
        if(0!=userMoneyLog.getUserId()) {
            addToQuery(query,"userId",userMoneyLog.getUserId());
        }

        addToQuery(query,"businessType",userMoneyLog.getBusinessType());

        addToQuery(query,"logType",logType);

        return getDatastore().exists(query,getEntityClass());

    }

    @Override
    public boolean isExistMoneyLogProcessed(String businessId,long userId,byte businessType,byte logType) {
        Query query =createQuery("businessId",businessId);
        if(0!=userId) {
            addToQuery(query,"userId",userId);
        }

        addToQuery(query,"businessType",businessType);

        addToQuery(query,"logType",logType);

        return getDatastore().exists(query,getEntityClass());

    }

}
