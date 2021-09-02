package com.shiku.im.admin.dao.impl;

import com.shiku.im.admin.dao.PayConfigDao;
import com.shiku.im.entity.PayConfig;
import com.shiku.im.repository.MongoRepository;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2020/1/4 11:23
 */
@Repository
public class PayConfigDaoImpl extends MongoRepository<PayConfig,Long> implements PayConfigDao {

    @Override
    public Class<PayConfig> getEntityClass() {
        return PayConfig.class;
    }

    @Override
    public MongoTemplate getDatastore() {
        return super.getDatastore();
    }

    @Override
    public PayConfig getPayConfig() {
        Query query = createQuery();
        query.addCriteria(Criteria.where("_id").ne(null));
        return findOne(query);
    }

    @Override
    public void addPayConfig(PayConfig payConfig) {
        getDatastore().save(payConfig);
    }
}
