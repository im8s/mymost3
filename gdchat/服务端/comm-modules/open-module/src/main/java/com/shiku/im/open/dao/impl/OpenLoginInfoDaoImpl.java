package com.shiku.im.open.dao.impl;

import com.shiku.im.open.dao.OpenLoginInfoDao;
import com.shiku.im.open.opensdk.entity.OpenLoginInfo;
import com.shiku.im.repository.MongoRepository;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/5 17:17
 */
@Repository
public class OpenLoginInfoDaoImpl extends MongoRepository<OpenLoginInfo, ObjectId> implements OpenLoginInfoDao {

    @Override
    public Class<OpenLoginInfo> getEntityClass() {
        return OpenLoginInfo.class;
    }

    @Override
    public void addOpenLoginInfo(OpenLoginInfo openLoginInfo) {
        getDatastore().save(openLoginInfo);
    }

    @Override
    public OpenLoginInfo getOpenLoginInfo(int userId) {
        Query query =createQuery("userId",userId);
        return findOne(query);
    }
}
