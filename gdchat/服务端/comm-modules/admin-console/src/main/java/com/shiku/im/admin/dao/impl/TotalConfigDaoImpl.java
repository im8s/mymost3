package com.shiku.im.admin.dao.impl;

import com.shiku.im.admin.dao.TotalConfigDao;
import com.shiku.im.admin.entity.TotalConfig;
import com.shiku.im.repository.MongoRepository;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.Map;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/3 19:12
 */
@Repository
public class TotalConfigDaoImpl extends MongoRepository<TotalConfig, ObjectId> implements TotalConfigDao {


    @Override
    public Class<TotalConfig> getEntityClass() {
        return TotalConfig.class;
    }

    @Override
    public void addTotalConfig(TotalConfig totalConfig) {
        getDatastore().save(totalConfig);
    }

    @Override
    public void updateTotalConfig(ObjectId id, Map<String, Object> map) {
        Query query = createQuery(id);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        update(query,ops);
    }
}
